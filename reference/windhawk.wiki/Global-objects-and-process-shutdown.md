Windhawk calls `Wh_ModUninit` when a mod is unloaded. It does **not** call it when the host process itself exits — but the destructors of your global objects still run, in an environment where almost everything they assume is already gone. A destructor that is perfectly correct during a normal unload can hang or crash the host process on every sign-out.

This page explains when that happens, how to tell whether your globals are affected, and exactly how to fix each case.

## Summary

* `Wh_ModUninit` runs on **mod unload** (disable, update, reload). It does **not** run when the **host process exits** (Explorer restart, sign-out, reboot).
* Destructors of globals and function-local `static`s run on **both** paths. At process exit they run after every other thread has already been terminated, under the loader lock, on an arbitrary thread.
* A destructor that **blocks**, **can crash or call `std::terminate`**, or **requires a specific thread** will hang or crash the host process there.
* The fix is always the same shape: mark the variable `[[clang::no_destroy]]` so the automatic destructor never runs, and do the real cleanup explicitly in `Wh_ModUninit`, on the correct thread.
* A destructor that only frees heap memory is **fine** — leave it alone. Adding the attribute to such a global is unnecessary noise.

## The two teardown paths

| | Mod unload (disable, update, reload) | Host process exit (Explorer restart, sign-out, reboot) |
| --- | --- | --- |
| `Wh_ModBeforeUninit`, `Wh_ModUninit` | Called | **Not called** |
| Other threads of the process | Alive and running normally | **Already terminated**, at arbitrary points |
| Loader lock | Not held | **Held** |
| COM apartments, XAML core, DirectX, other subsystems | Alive | May already be torn down |
| Destructors of globals | Run after `Wh_ModUninit`, when the mod DLL is unloaded | Run, alone on the exiting thread |
| Cost of not releasing something | Leaks for the lifetime of the process, and accumulates on every reload | None, the process is going away |

```mermaid
graph TD
    %% Subgraphs are rendered in reverse declaration order, hence the order below.
    subgraph "Host process exit"
        p1["All other threads are terminated<br/>wherever they happen to be"] --> p2["DLL_PROCESS_DETACH,<br/>under the loader lock"]
        p2 --> p3["Destructors of globals run.<br/>Wh_ModUninit is NOT called"]
    end
    subgraph "Mod unload"
        u1(Wh_ModBeforeUninit) --> u2(Hooks are removed)
        u2 --> u3(Wh_ModUninit)
        u3 --> u4["Mod DLL is unloaded:<br/>destructors of globals run"]
    end
```

Note that the destructor of a global is the only piece of code that runs on **both** paths — and on the second path it runs without any of the preparation that `Wh_ModUninit` would have done.

A third path exists: a hard kill (`TerminateProcess`, for example `taskkill /f`, or "End task" in Task Manager). There, nothing runs at all — no callbacks and no destructors. Nothing can be done about it, and nothing needs to be: the OS reclaims everything.

## Why process exit is hostile

At process exit (`ExitProcess`), Windows first terminates every thread except the exiting one, without unwinding them, and only then delivers `DLL_PROCESS_DETACH` to the loaded DLLs. When your destructor runs:

* **Threads you depend on are already dead.** A thread killed inside your critical section never released it. A thread killed while it was going to signal an event never signals it.
* **The loader lock is held.** Loading or unloading a DLL, or waiting for anything that needs the loader lock, deadlocks.
* **Subsystems may already be gone.** COM apartments, the XAML core, DirectX devices, and the message queues of dead threads no longer work — calls into them can fail, hang, or crash.
* **You are on an unknown thread.** Not your UI thread, not your worker thread — whichever thread called `ExitProcess`. Anything with thread affinity is being touched from the wrong thread.

For users, the result is a taskbar that hangs at sign-out, a "Windows Explorer has stopped working" dialog on every reboot, or a shell that fails to restart.

## Three failure modes

A destructor that runs at process exit is dangerous if it does any of the following.

1. **It blocks.** Releasing an out-of-process COM/WinRT proxy marshals a call into an apartment whose dispatch thread no longer exists; acquiring a lock that a terminated thread still holds never returns; waiting for an event that a terminated thread was supposed to set never returns. The process hangs instead of exiting.
2. **It crashes or calls `std::terminate`.** The textbook case is a global `std::thread`: nothing joined it (`Wh_ModUninit` did not run), so it is still `joinable()`, and `~thread()` calls `std::terminate()`, which aborts the host process. Calls into an already torn-down subsystem crash in the same way.
3. **It violates thread affinity.** Releasing the last reference to a XAML element, an STA COM object, a window, or a timer from the exiting thread, when the object belongs to a thread that is already dead.

## Is my global affected?

Look at what the destructor ultimately does — transitively, including the destructors of its members and of a container's elements — and ask three questions:

1. Can it **block**? (a lock, an event, another thread, a cross-thread or cross-process call)
2. Can it **crash** or call **`std::terminate`**?
3. Does it **require a specific thread**?

If all three answers are "no" — typically the destructor just frees heap memory, or the type has no destructor at all — the global is **safe as it is**. Do not add `[[clang::no_destroy]]` to it; the attribute would only add noise and invite copying it where it does not belong.

If any answer is "yes", apply the fix below.

### Safe as-is (no attribute needed)

| Type | Why it is safe |
| --- | --- |
| Plain data, raw pointers, `HANDLE`, `HWND`, `HMODULE`, `ULONG_PTR` tokens | No destructor at all |
| `std::atomic<T>` over a scalar | Trivially destructible |
| `std::mutex`, `SRWLOCK`, `CRITICAL_SECTION` | Destruction does not block, cannot throw, has no thread affinity |
| `std::wstring`, `std::vector<int>`, `std::map<HWND, RECT>`, and other containers of plain values | Destruction only frees heap memory |
| `WindhawkUtils::StringSetting` | Frees an in-process buffer |
| `winrt::event_token` | Plain data |
| `winrt::weak_ref<T>` | Only decrements an in-process control block; no thread affinity |
| `std::unique_ptr<T>` where `~T()` is heap-only | Same as the pointee — check the pointee |

### Needs the fix

| Case | What happens at process exit |
| --- | --- |
| `std::thread` | Still `joinable()`, so `~thread()` calls `std::terminate()` and the host aborts |
| Strong WinRT/COM references, especially out-of-process proxies | `Release` marshals into a dead apartment: hang |
| XAML objects (`FrameworkElement`, `Grid`, `DispatcherTimer`, …) | Released off the UI thread, after XAML teardown: crash |
| Any container holding the above | The element destructors run, with the same consequences |
| RAII wrappers calling teardown APIs (`CoUninitialize`, `GdiplusShutdown`, `UnregisterClass`, `DestroyWindow`, `UnhookWindowsHookEx`, `RemoveWindowSubclass`, …) | Calls into subsystems that may be gone, from the wrong thread, under the loader lock |

## The fix

### Step 1: suppress the automatic destructor

`[[clang::no_destroy]]` is a Clang attribute for variables with static or thread storage duration. It means the destructor is **never** run — not at DLL unload, and not at process exit. It can be applied to globals, file-scope and namespace-scope `static`s, function-local `static`s, and `static` data members.

```cpp
[[clang::no_destroy]] std::optional<std::thread> g_workerThread;
```

Because it suppresses the destructor on **both** paths, including the normal unload path, step 2 is not optional.

### Step 2: release explicitly in `Wh_ModUninit`

`[[clang::no_destroy]]` removes the automatic release; it does not replace it. Every controlled path (`Wh_ModUninit`, and `Wh_ModSettingsChanged` if the mod re-creates state there) must still release the resource explicitly:

* **Fully**: assign `nullptr`, call `reset()`, `join()`, `CloseHandle` — the operation that actually destroys the resource. `.clear()` on a container destroys the elements but keeps the heap buffer, so it is not a full release.
* **On the correct thread**: for thread-affine objects, post the release to the owning thread (for example, to the taskbar UI thread) and let it run there.

If the explicit cleanup is missing, the mod leaks the resource permanently on **every** unload — while the process keeps running — which is worse than the problem being fixed.

### Choosing the form: `std::optional<T>` or the bare attribute

* Use the **bare attribute** only when the type is **nullable or handle-like**: it has a natural "owns nothing" state that a single assignment reaches, so `= nullptr` (or `reset()`) both frees the resource and empties the object. WinRT projected types, `winrt::com_ptr`, `std::unique_ptr`, `std::shared_ptr`, raw OS handles.
* Otherwise use **`[[clang::no_destroy]] std::optional<T>`** and release with `reset()`. This is the default. If you are not fully certain the type is nullable, use this form.

The reason is that for a non-nullable type, running `~T()` is the only complete release, and `optional::reset()` is how you run it on demand. `std::vector::clear()` keeps the buffer. `std::thread` cannot be emptied by assignment at all — move-assigning over a `joinable()` thread calls `std::terminate()`. A default-constructed `std::optional` is also trivially initialized, which side-steps static initialization order issues; use `{std::in_place}` if the object should be engaged from the start.

| | Bare attribute | `std::optional<T>` wrapper |
| --- | --- | --- |
| Applies to | Nullable / handle-like types | Everything else (the default) |
| Declaration | `[[clang::no_destroy]] Grid g_grid{nullptr};` | `[[clang::no_destroy]] std::optional<std::vector<T>> g_items{std::in_place};` |
| Create | `g_grid = MakeGrid();` | `g_items.emplace();` |
| Access | `g_grid.Children()` | `g_items->push_back(x)` |
| Release in `Wh_ModUninit` | `g_grid = nullptr;` | `g_items.reset();` |

When converting an existing global to the `optional` form, remember to change `.` accesses to `->` (or `*`), and to release with `reset()` or `= std::nullopt` — **not** `= nullptr`, which for an engaged optional assigns through to the contained object and leaves the optional engaged.

### Alternative: make the global trivially destructible

Often the cleanest fix is to not store a destructor-owning object at all. Keep the plain token or handle in the global, and do the teardown in `Wh_ModUninit`:

```cpp
ULONG_PTR g_gdiplusToken = 0;  // No destructor, nothing runs at process exit.

BOOL Wh_ModInit() {
    Gdiplus::GdiplusStartupInput input;
    Gdiplus::GdiplusStartup(&g_gdiplusToken, &input, nullptr);
    return TRUE;
}

void Wh_ModUninit() {
    Gdiplus::GdiplusShutdown(g_gdiplusToken);
}
```

## Case by case

### 1. Worker thread: `std::thread`

```cpp
// Broken: at process exit the thread was never joined, so ~thread() is called
// on a joinable thread, which calls std::terminate() and aborts the host.
std::thread g_workerThread;
```

```cpp
// Correct.
std::atomic<bool> g_stopWorker{false};
HANDLE g_wakeEvent = nullptr;
[[clang::no_destroy]] std::optional<std::thread> g_workerThread;

BOOL Wh_ModInit() {
    g_wakeEvent = CreateEvent(nullptr, FALSE, FALSE, nullptr);
    g_workerThread.emplace([] {
        while (!g_stopWorker) {
            WaitForSingleObject(g_wakeEvent, 1000);
            // ...
        }
    });
    return TRUE;
}

void Wh_ModUninit() {
    g_stopWorker = true;
    SetEvent(g_wakeEvent);  // Don't wait out a long sleep.
    if (g_workerThread->joinable()) {
        g_workerThread->join();
    }
    g_workerThread.reset();
    CloseHandle(g_wakeEvent);
    g_wakeEvent = nullptr;
}
```

The `optional` is required here, not a style choice: there is no assignment that means "release" for a `std::thread`. See [vlc-discord-rpc](https://github.com/ramensoftware/windhawk-mods/blob/main/mods/vlc-discord-rpc.wh.cpp) for this pattern in a merged mod.

Note also that the worker must actually be joined before `Wh_ModUninit` returns — after that, the mod DLL is unloaded and any thread still running its code crashes.

### 2. Worker thread: raw `HANDLE`

```cpp
HANDLE g_workerThread = nullptr;  // Safe as-is: no destructor runs at exit.
```

A `HANDLE` from `CreateThread` has no destructor, so process exit is a non-issue. The controlled path still matters: signal the thread, wait for it, and `CloseHandle` it in `Wh_ModUninit`, or the mod leaks a thread and a handle on every reload.

### 3. WinRT or COM object, especially out-of-process

```cpp
// Broken: at process exit, Release() on a proxy marshals a call into an
// apartment whose thread is already dead. The process hangs at sign-out.
GlobalSystemMediaTransportControlsSession g_session{nullptr};
```

```cpp
// Correct: WinRT projected types and com_ptr are nullable, so the bare
// attribute is the right form.
[[clang::no_destroy]] GlobalSystemMediaTransportControlsSession g_session{nullptr};
[[clang::no_destroy]] winrt::com_ptr<IAudioSessionManager2> g_sessionManager;

void Wh_ModUninit() {
    // If the object belongs to a specific apartment or worker thread, release
    // it there before that thread exits, rather than from Wh_ModUninit.
    g_session = nullptr;
    g_sessionManager = nullptr;
}
```

If the object was created on a worker thread that owns the apartment, the cleanest arrangement is to release it on that thread as part of its shutdown, and only then join the thread.

### 4. XAML and other UI-thread objects

```cpp
// Broken twice over: released from the wrong thread, and at process exit the
// XAML core may already be gone.
winrt::Windows::UI::Xaml::Controls::Grid g_grid{nullptr};
std::unordered_map<HWND, winrt::Windows::UI::Xaml::FrameworkElement> g_elements;
```

```cpp
// Correct: suppress the automatic destructor, and release on the UI thread.
[[clang::no_destroy]] winrt::Windows::UI::Xaml::Controls::Grid g_grid{nullptr};
[[clang::no_destroy]] std::optional<
    std::unordered_map<HWND, winrt::Windows::UI::Xaml::FrameworkElement>>
    g_elements{std::in_place};

void Wh_ModUninit() {
    HWND hTaskbarWnd = FindCurrentProcessTaskbarWnd();
    if (hTaskbarWnd) {
        // Runs synchronously on the window's (UI) thread.
        RunFromWindowThread(hTaskbarWnd, [](void*) {
            RestoreOriginalLayout();
            g_grid = nullptr;
            g_elements.reset();  // Runs ~unordered_map(), releasing every ref.
        }, nullptr);
    }
}
```

The `Grid` is nullable, so it takes the bare attribute; the map is not, so it takes the `optional` wrapper and `reset()`. If no UI thread can be found, it is better to leave the references alive than to release them from the wrong thread. [taskbar-folder-menus](https://github.com/ramensoftware/windhawk-mods/blob/main/mods/taskbar-folder-menus.wh.cpp) and [tray-utility-customizer](https://github.com/ramensoftware/windhawk-mods/blob/main/mods/tray-utility-customizer.wh.cpp) both do this.

If you only need to observe an element rather than keep it alive, a `winrt::weak_ref<FrameworkElement>` avoids the problem entirely — it holds no strong reference, and its destructor is safe from any thread.

### 5. Containers of resource-owning or thread-affine elements

```cpp
// Broken: ~vector() destroys every element, which releases every Button and
// every event token, from the exiting thread.
struct ButtonState {
    winrt::Windows::UI::Xaml::Controls::Button button{nullptr};
    winrt::event_token clickToken{};
};
std::vector<ButtonState> g_buttonStates;
```

```cpp
// Correct.
[[clang::no_destroy]] std::optional<std::vector<ButtonState>>
    g_buttonStates{std::in_place};

// In Wh_ModUninit, on the owning (UI) thread:
//   for (auto& s : *g_buttonStates) { s.button.Click(s.clickToken); }
//   g_buttonStates.reset();
```

Use `reset()`, not `clear()`: `clear()` destroys the elements but keeps the vector's buffer allocated, which leaks a little on every unload.

### 6. Containers of plain values

```cpp
std::vector<HWND> g_windows;         // Safe as-is.
std::wstring g_lastTitle;            // Safe as-is.
std::map<DWORD, RECT> g_savedRects;  // Safe as-is.
```

Destruction only frees heap memory: it cannot block, cannot throw, and has no thread affinity. Leave these alone — no attribute, no wrapper. At process exit the OS reclaims the memory anyway.

### 7. RAII wrappers that call teardown APIs

```cpp
// Broken: at process exit this calls into GDI+ under the loader lock, possibly
// after the subsystem is gone. The same applies to a wrapper that calls
// CoUninitialize, UnregisterClass, DestroyWindow, UnhookWindowsHookEx, etc.
struct GdiplusScope {
    ULONG_PTR token = 0;
    ~GdiplusScope() { Gdiplus::GdiplusShutdown(token); }
};
GdiplusScope g_gdiplus;
```

Prefer the trivially-destructible form shown [above](#alternative-make-the-global-trivially-destructible): store the token or handle as plain data and call the teardown API in `Wh_ModUninit`. If you want to keep the wrapper, mark it `[[clang::no_destroy]]` and trigger the teardown explicitly from `Wh_ModUninit`.

Window classes deserve a special mention: a class registered with `RegisterClass` is **not** unregistered when the mod DLL is unloaded, and its `lpfnWndProc` then points into unmapped memory. Always `UnregisterClass` in `Wh_ModUninit` — and never work around a failing `RegisterClass` by reusing an existing class, which is exactly the dangling case.

### 8. `std::unique_ptr` and `std::shared_ptr`

The hazard is transitive — look at the pointee:

```cpp
struct Config { std::wstring name; int value; };
std::unique_ptr<Config> g_config;  // Safe as-is: heap-only destruction.

struct Overlay {
    HWND hWnd;
    std::thread renderThread;
    ~Overlay();  // Destroys a window and joins a thread.
};
[[clang::no_destroy]] std::unique_ptr<Overlay> g_overlay;  // Needs the fix.

void Wh_ModUninit() {
    g_overlay.reset();  // On the right thread, with the thread stopped first.
}
```

Smart pointers are nullable, so they take the bare attribute rather than an `optional` wrapper.

### 9. Function-local `static`s

The rules are identical — a function-local `static` has static storage duration, and its destructor is registered to run at teardown just like a global's:

```cpp
void EnsureWorker() {
    [[clang::no_destroy]] static std::optional<std::thread> s_worker;
    if (!s_worker) {
        s_worker.emplace(WorkerProc);
    }
}
```

Keep in mind that the mod's cleanup code in `Wh_ModUninit` still needs a way to reach such a variable, which is usually a reason to make it a proper global instead.

### 10. Locks, atomics, handles and tokens

```cpp
std::mutex g_mutex;                    // Safe as-is.
std::atomic<bool> g_unloading{false};  // Safe as-is.
HANDLE g_stopEvent = nullptr;          // Safe as-is (close it in Wh_ModUninit).
winrt::event_token g_token{};          // Safe as-is.
WindhawkUtils::StringSetting g_theme;  // Safe as-is.
```

None of these can block, crash, or need a particular thread when destroyed. Adding `[[clang::no_destroy]]` to them is unnecessary.

## Testing

* **Exercise the real path.** `taskkill /f /im explorer.exe` and Task Manager's "End task" terminate the process without running anything, so they do **not** test this. Use a graceful exit instead: Ctrl+Shift+right-click on the taskbar and choose "Exit Explorer", or sign out, or reboot.
* **Watch for**: a sign-out that hangs, a crash dialog or a `WerFault.exe` process at exit, or a shell that does not come back. All are typical symptoms of a destructor misbehaving at shutdown.
* **Test the unload path separately.** Disable and re-enable the mod a number of times, and check in Task Manager (with the Handles and Threads columns enabled) that the host's handle and thread counts return to their baseline. This is what catches an explicit cleanup that was forgotten after adding `[[clang::no_destroy]]`.

## Checklist

* For every global, `static`, and `thread_local` with a non-trivial destructor: can it block, crash, or does it need a specific thread? If none of those, leave it alone.
* If any of those: `[[clang::no_destroy]]`, plus an explicit release in `Wh_ModUninit`.
* `std::optional<T>` wrapper by default; bare attribute only for nullable / handle-like types.
* The explicit release must **fully** free (`reset()`, `= nullptr`, `join()`, `CloseHandle`) and run **on the owning thread** for thread-affine objects.
* Every thread the mod started must be stopped and joined before `Wh_ModUninit` returns.
* No `[[clang::no_destroy]]` on a type that does not need it.

See also: [Mod lifetime](https://github.com/ramensoftware/windhawk/wiki/Mod-lifetime), [Development tips](https://github.com/ramensoftware/windhawk/wiki/Development-tips).

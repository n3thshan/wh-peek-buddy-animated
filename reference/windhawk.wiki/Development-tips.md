## Windhawk Utils

Windhawk comes with a set of utilities that can be found in `windhawk_utils.h`. To use them, include the header file, and look at its content for the available utilities and their descriptions.

### Notable utilities

* `WindhawkUtils::HookSymbols` - A simpler alternative for symbol loading and hooking (uses `Wh_FindFirstSymbol`/`Wh_FindNextSymbol` and `Wh_SetFunctionHook`). Also implements caching so that the potentially slow symbol enumeration is only done once per binary version. The [Windhawk Symbol Helper](https://github.com/ramensoftware/windhawk-symbol-helper/releases/latest) tool can be useful for listing symbol names of a module.
* `WindhawkUtils::SetWindowSubclassFromAnyThread` - Similar to [`SetWindowSubclass`](https://learn.microsoft.com/en-us/windows/win32/api/commctrl/nf-commctrl-setwindowsubclass), but can be called from any thread, unlike `SetWindowSubclass` that can't be used to subclass a window across threads.
* `WindhawkUtils::SetFunctionHook` - A strong-type wrapper for `Wh_SetFunctionHook`. Allows omitting casts and helps avoiding mistakes such as signature mismatches.
* `WindhawkUtils::StringSetting` - A RAII wrapper for a string setting. Uses `Wh_GetStringSetting` to load a value from the settings, and automatically calls `Wh_FreeStringSetting` upon destruction.

## Avoid mod loading on process startup

Some processes restart automatically when they crash. For easier development, it can be handy to load the mod only if the target process is already running. This means that the mod will load normally if enabled or compiled while the target process is running, but it will unload right away if the target process starts running while the mod is enabled.

This can be accomplished by adding the following code to the beginning of `Wh_ModInit`:

```cpp
BOOL Wh_ModInit() {
    // Unload if loaded on process startup.
#ifdef _WIN64
    const size_t OFFSET_SAME_TEB_FLAGS = 0x17EE;
#else
    const size_t OFFSET_SAME_TEB_FLAGS = 0x0FCA;
#endif
    bool isInitialThread = *(USHORT*)((BYTE*)NtCurrentTeb() + OFFSET_SAME_TEB_FLAGS) & 0x0400;
    if (isInitialThread) {
        return FALSE;
    }

    // ...
}
```
The code checks whether the currently running thread is the initial thread of the process. If it is, that's possible that it's being restarted after a crash.

See also: [Mod lifetime](https://github.com/ramensoftware/windhawk/wiki/Mod-lifetime).

## Hooks and calling conventions

A common mistake which often causes crashes is a forgotten calling convention for hook functions. For WinAPI functions, the calling convention is almost always `WINAPI`.

For example:
```cpp
using FindWindowW_t = decltype(&FindWindowW);
FindWindowW_t FindWindowW_Original;
HWND WINAPI FindWindowW_Hook(LPCWSTR lpClassName, LPCWSTR lpWindowName) {
    // ...
}

BOOL Wh_ModInit()
{
    // ...
    WindhawkUtils::SetFunctionHook(FindWindowW, FindWindowW_Hook, &FindWindowW_Original);
    // ...
}
```

Note that using `WindhawkUtils::SetFunctionHook` instead of `Wh_SetFunctionHook` helps avoiding such mistakes.
## Windhawk targets

By default, the Windhawk engine is injected into all processes, except for [predefined lists of excluded processes](#the-predefined-lists-of-excluded-processes), which are system-critical or known to be incompatible. This injection allows Windhawk to load and manage the appropriate mods in the target processes.

You can customize this behavior in the Windhawk settings:

* **Exclude additional processes**: Add them to the "Process exclusion list." This can be useful if Windhawk is not compatible with a specific program.
* **Include processes excluded by default**: Add them to the "Process inclusion list."

To modify these lists:

* Open Windhawk.
* Go to **Settings** \> **Advanced settings** \> **More advanced settings**.
* Adjust the "Process exclusion list" or "Process inclusion list" as needed.

**Note**: Excluded processes are entirely unaffected by Windhawk, regardless of installed mods or other settings.

## Mod targets

Each mod specifies the processes it targets. A target can be:

* A fixed name or path, such as `calc.exe` or `C:\Windows\notepad.exe`.
* A pattern, such as `*` to target all processes or `C:\folder\*` to target all processes in a specific folder.

When the Windhawk engine is injected into a process, it loads mods that target that process. However, there is an exception for [a predefined list of mods-excluded system processes](#mods-excluded-system-processes): pattern-based targets (for example, `*` or `C:\folder\*`) are ignored, and mods will only be loaded if they explicitly target the process (for example, `critical.exe`).

This behavior can be customized for a mod in its advanced settings tab.

## Why does Windhawk inject code into most processes?

A common question is why Windhawk injects code into most processes, even if no mods target them. Wouldn't it make sense to inject code only into processes that are customized by mods?

### The reason for injecting into most processes

Injecting code into most processes allows Windhawk to intercept the creation of new processes and load mods before a new target process starts running. Without this capability, certain mods that rely on being loaded at an early stage would not function correctly.

### Challenges of limiting injection

Determining which processes to target by default is challenging:

* **If fewer processes are targeted**: Some mods may not work correctly because they aren't loaded early enough.
* **If too many processes are targeted**: There's a higher risk of incompatibilities or system instability.

Since incompatibilities with Windhawk are rare, it was decided to inject code into most processes by default while excluding critical system processes and processes which are known to be incompatible. This strikes a balance between maintaining system stability and ensuring mods work reliably.

However, this default behavior may cause issues in certain cases:

* **Incompatibility with a program**: If a program is incompatible with Windhawk, it can be added to the exclusion list (see [Windhawk targets](#windhawk-targets)).
* **Incompatibility with antivirus or other security software**: Some antivirus or security software may conflict with Windhawk due to its code injection behavior. Some information about it can be found [here](https://github.com/ramensoftware/windhawk/wiki/Troubleshooting#windhawk-isnt-usable-or-causes-problems). If nothing else works, you can try excluding all processes but the ones you'd like to customize. Note that, as mentioned earlier, some mods might not work correctly in this case since they won't be loaded early enough. Therefore, this option is only recommended as a last resort.

### Future improvements

The ideal solution would involve a mechanism in Windows that allows mods to load early without injecting code into every process. This topic has been discussed [on GitHub](https://github.com/ramensoftware/windhawk/issues/197).

Currently, the most promising approach is to develop a **kernel driver**, which is a system component running at the core of the operating system. Using a kernel driver, Windhawk could load mods at an early stage without injecting code into every process. However, creating and signing a kernel driver for Windows is a complex and costly process, and there are currently no concrete plans to pursue it.

## The predefined lists of excluded processes

Windhawk v1.7 has the following predefined lists of excluded processes.

### Critical system processes

This list contains processes that are critical for the system's proper functioning.

```
%systemroot%\system32\autochk.exe
%systemroot%\syswow64\autochk.exe
%systemroot%\system32\chkdsk.exe
%systemroot%\syswow64\chkdsk.exe
%systemroot%\system32\consent.exe
%systemroot%\system32\csrss.exe
%systemroot%\system32\doskey.exe
%systemroot%\syswow64\doskey.exe
%systemroot%\system32\dwm.exe
%systemroot%\system32\fontdrvhost.exe
%systemroot%\system32\logonui.exe
%systemroot%\system32\lsaiso.exe
%systemroot%\system32\lsass.exe
%systemroot%\system32\searchindexer.exe
%systemroot%\syswow64\searchindexer.exe
%systemroot%\system32\searchprotocolhost.exe
%systemroot%\syswow64\searchprotocolhost.exe
%systemroot%\system32\services.exe
%systemroot%\system32\setupcl.exe
%systemroot%\system32\smss.exe
%systemroot%\system32\spoolsv.exe
%systemroot%\system32\taskhostw.exe
%systemroot%\system32\werfaultsecure.exe
%systemroot%\syswow64\werfaultsecure.exe
%systemroot%\system32\wermgr.exe
%systemroot%\syswow64\wermgr.exe
%systemroot%\system32\wininit.exe
%systemroot%\system32\winrshost.exe
%systemroot%\syswow64\winrshost.exe
%systemroot%\system32\wbem\wmiprvse.exe
%systemroot%\syswow64\wbem\wmiprvse.exe
%systemroot%\system32\wsmprovhost.exe
%systemroot%\syswow64\wsmprovhost.exe
```

### Known incompatible programs

This list contains paths to programs that are known to be incompatible with Windhawk.

```
%ProgramFiles%\Oracle\VirtualBox\*
%ProgramFiles(X86)%\Oracle\VirtualBox\*
```

### Well-known games

Games are often incompatible with Windhawk due to their intolerance for code injection, usually for anti-cheat reasons. This list contains well-known game paths.

Each entry in this list which starts with `?:\Program Files\` also has a corresponding entry which starts with `?:\Program Files (x86)\`. This is done to ensure that the same game is excluded regardless of whether it is installed in the 32-bit or 64-bit version of the Program Files folder.

```
?:\Program Files\2K Games\*
?:\Program Files\Activision\*
?:\Program Files\Battle.net\*
?:\Program Files\Bethesda Softworks\*
?:\Program Files\Bethesda.net Launcher\*
?:\Program Files\Blizzard Entertainment\*
?:\Program Files\EA Games\*
?:\Program Files\EA\*
?:\Program Files\EasyAntiCheat_EOS\*
?:\Program Files\Electronic Arts\*
?:\Program Files\Epic Games\*
?:\Program Files\GOG Galaxy\*
?:\Program Files\Google\Play Games\*
?:\Program Files\Google\Play Games Services\*
?:\Program Files\Grinding Gear Games\*
?:\Program Files\Microsoft Games\*
?:\Program Files\Origin Games\*
?:\Program Files\Paradox Interactive\*
?:\Program Files\Riot Games\*
?:\Program Files\Rockstar Games\*
?:\Program Files\Square Enix\*
?:\Program Files\Steam\*
?:\Program Files\Ubisoft\*
?:\Program Files\Valve\*
?:\Program Files\Wargaming.net\*
?:\Epic Games\*
?:\Games\*
?:\Riot Games\*
?:\WindowsApps\Microsoft.MinecraftUWP_*\*
?:\WindowsApps\Microsoft.SunriseBaseGame_*\*
*\steamapps\common\*
```

## Mods-excluded system processes

This list contains system processes which aren't excluded from Windhawk injection by default, but are excluded from pattern-based targets. This means that mods will not be loaded in these processes unless they explicitly target them. This is done to prevent potential issues with mods that may not be compatible with these processes.

The list is a combination of the paths below and the paths in the [critical system processes](#critical-system-processes) list.

```
%systemroot%\system32\svchost.exe
%systemroot%\syswow64\svchost.exe
%systemroot%\system32\werfault.exe
%systemroot%\syswow64\werfault.exe
%systemroot%\system32\winlogon.exe
```

## Targeting selected processes and excluding the rest

Windhawk allows excluding all processes but the ones you want to customize:

* Open Windhawk.
* Go to **Settings** \> **Advanced settings** \> **More advanced settings**.
* Set `*` in the "Process exclusion list" to exclude all processes.
* Add the selected processes to target in the "Process inclusion list".

Note that this will cause mods to be injected with a slight delay, which may break some mods. Therefore, it's recommended to only use this option as a last resort when nothing else works, for example in a restricted environment with an antivirus.
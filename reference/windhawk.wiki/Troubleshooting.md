Are you having problems with Windhawk or its mods? Please read this troubleshooting page before reporting an issue.

## Windhawk isn't usable or causes problems

_If Windhawk starts normally and mods can be installed, but some or all of them don't work, please refer to the relevant section: [Some or all Windhawk mods don't work](#some-or-all-windhawk-mods-dont-work)._

_If there's a problem or incompatibility with a specific program, please refer to the relevant section: [Windhawk isn't compatible with a specific program](#windhawk-isnt-compatible-with-a-specific-program)._

In many cases, problems with Windhawk occur due to incompatibility with an antivirus. Such problems include:

* Windhawk is blocked or killed by an antivirus and is unable to run.
* Other programs are blocked or killed because of Windhawk's code injection.
* Windhawk is unable to inject code into some or all processes.

In these cases, if possible, turn off the antivirus completely to temporarily check whether it fixes the problem. If it does, then you will have to find a way to make the antivirus work along with Windhawk, either by excluding it, or via other means. There's not much that can be done on Windhawk's side in these cases.

If the problem is unrelated to antivirus incompatibility, please report the problem [here](https://github.com/ramensoftware/windhawk/issues).

## Some or all Windhawk mods don't work

A mod may not work due to various reasons:

* Incompatibility with the target process, for example the Windows version is unsupported.
  * Check the mod's description for supported targets.
* Incompatibility with an old Windhawk version.
  * Make sure your copy of Windhawk is up-to-date.
* In case the mod uses debug symbols:
  * Debug symbols may be unavailable, for example if Microsoft didn't publish debug symbols for a specific Windows build.
  * Debug symbols may fail to be downloaded, for example because the download is blocked by a firewall.
* A bug in the mod.
* A bug in Windhawk.
* Incompatibility with an antivirus.

Pick a mod that doesn't work and collect debug logs as following:

* Disable the mod.
* Go to the mod's Advanced tab.
* Set **Debug logging** to **Detailed debug logs**.
* Click on **Show log output**.
* Enable the mod.
* Verify that the mod doesn't work, copy the log and save it to a file.
* Set **Debug logging** back to **None**.

Open the log file that you saved.

* If the log is empty, Windhawk likely failed to inject code into the target process. In this case, refer to: [Windhawk isn't usable or causes problems](#windhawk-isnt-usable-or-causes-problems).
* If the log contains the `HTTP_STATUS_NOT_FOUND` error, debug symbols are unavailable. Sometimes, it takes some time (usually no more than a day or two) for symbols to become available after an update is published. For some Windows builds, Microsoft doesn't publish debug symbols at all (rare, but happened in the past).
* If the log contains the `ERROR_INTERNET_CANNOT_CONNECT` error, debug symbols can't be downloaded. Check your internet connection and, if you have a firewall installed, your firewall settings.
* The log may contain a descriptive error message, such as "Windows 10 isn't supported".

If the problem wasn't solved after trying the above, please report the problem [here](https://github.com/ramensoftware/windhawk-mods/issues). Include the mod name in the title, and tag the mod's author using their GitHub handle. Attach the collected debug logs to the report.

## Windhawk isn't compatible with a specific program

Some programs are incompatible with Windhawk or with code injection in general. These programs can be added to Windhawk's exclusion list:

* Open Windhawk.
* Go to Settings.
* Expand the **Advanced settings** section.
* Click on **More advanced settings**.
* Add the incompatible process to the **Process exclusion list**.
* Finally, click on **Save and restart Windhawk**.

If the program isn't known to be incompatible with Windhawk, please report the incompatibility [here](https://github.com/ramensoftware/windhawk/issues).

Programs that are known to be incompatible with Windhawk are excluded by default. For details, see [Injection targets and critical system processes](https://github.com/ramensoftware/windhawk/wiki/Injection-targets-and-critical-system-processes).
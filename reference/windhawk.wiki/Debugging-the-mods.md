# Short summary

1. Install the CodeLLDB extension using the instructions below.
2. Add `--optimize=0 --debug` to the mod's `@compilerOptions` metadata entry.
3. Add a debugging configuration for launching a process in debug mode, or for attaching to a running process.
4. Start debugging.

## Install the CodeLLDB extension

To be able to debug mods in Windhawk, first install the CodeLLDB debugging extension for Windhawk:
1. Enter editing mode.
2. Press Ctrl+P, type "ext install vadimcn.vscode-lldb" and press Enter.
3. Restore the Windhawk sidebar by pressing the button on the bottom right or with Ctrl+B.

https://github.com/user-attachments/assets/8e048b5d-e659-4dc3-93f0-b897a60f426f

## Add debugging flags to the mod's compiler options

To be able to debug a mod properly, it has to be compiled for debugging. Add `--optimize=0 --debug` to the mod's `@compilerOptions` metadata entry.

https://github.com/user-attachments/assets/f7545836-2eb1-4f49-b610-aa3381e9d485

## Attach to a running process

1. Press Ctrl+Shift+D to switch to the Run and Debug view.
2. Click on "create a launch.json file". If another configuration already exists, click on "Add configuration..." and choose "Attach to PID".
3. Set "request" to "attach".
4. Remove "args" and "cwd".
5. Set the program path for "program", or, to pick from a list, replace "program" with `"pid": "${command:pickMyProcess}"`.
6. Make sure the right configuration is selected, and click on the green arrow to start debugging.

https://github.com/user-attachments/assets/14e97547-1865-49d0-bb11-cfcd8af1c120

## Run a process in debug mode

1. Press Ctrl+Shift+D to switch to the Run and Debug view.
2. Click on "create a launch.json file". If another configuration already exists, click on "Add configuration..." and choose "Launch".
3. Set the program path for "program". Repeat each backslash twice.
4. Make sure the right configuration is selected, and click on the green arrow to start debugging.

https://github.com/user-attachments/assets/f0013277-969c-42db-816d-850cb94b0013
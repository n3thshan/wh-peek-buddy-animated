Creating a new mod or forking an existing mod will switch Windhawk to editing mode. The editing mode is based on [Microsoft Visual Studio Code](https://github.com/microsoft/vscode) (VSCode), and if you're familiar with VSCode you'll see the similarity right away. But despite the similarity, there are several Windhawk-specific details that might be confusing at first. This page has several guidelines to help you get started.

The first guideline is that all you need for mod development can be found in the sidebar on the left. Many other options of VSCode are available via the top menu (File, Edit, etc.), the command palette (Ctrl+Shift+P) and other places, but unless you know what you're doing, you probably don't need to touch them.

![Editing mode screenshot](https://github.com/ramensoftware/windhawk/assets/4129781/ba0d6512-a087-4954-93a7-6cc3da4531c6)

More guidelines:

* Editing mode is opened with a single file named `mod.wh.cpp`, regardless of the mod name or id. That's intended, don't try to rename it.
* If `mod.wh.cpp` is accidentally closed, you can reopen it by clicking Ctrl+P and selecting `mod.wh.cpp`.
* If the Windhawk sidebar on the left is accidentally closed, you can bring it back with Ctrl+B.
* When the Windhawk sidebar is visible, Ctrl+B can be used to compile the mod.
* The editing environment is re-created each time Windhawk is switched to editing mode.
* If git is installed, Windhawk uses it to track and display code changes since the last successful compilation.
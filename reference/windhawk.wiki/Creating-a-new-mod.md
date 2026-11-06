Each mod is a single C++ file which is compiled into a dynamic library. After it's compiled, the mod is loaded by the Windhawk engine which calls the mod's callback functions and provides API functions that the mod can use.

The mod is loaded in the context of the processes that the mod targets. For example, if the mod targets Notepad, it will be loaded by the Windhawk engine in the context of each notepad.exe process.

In addition to the C++ code itself, the mod must provide information such as the mod id and name. Optionally, the mod may include a readme with information and settings to configure the mod.

To submit a mod to the official collection of Windhawk mods, refer to the readme in the [windhawk-mods](https://github.com/ramensoftware/windhawk-mods) repository.

## Mod metadata

Each mod starts with a metadata block which contains information such as the mod id and name. The general format is:

```
// ==WindhawkMod==
// @key value
// ==/WindhawkMod==
```

Some keys may have multiple values, and some keys can be localized.

Metadata block example:

```
// ==WindhawkMod==
// @id              new-mod
// @name            Your Awesome Mod
// @description     The best mod ever that does great things
// @version         0.1
// @author          You
// @github          https://github.com/nat
// @twitter         https://twitter.com/jack
// @homepage        https://your-personal-homepage.example.com/
// @include         mspaint.exe
// @compilerOptions -lcomdlg32
// @license         MIT
// ==/WindhawkMod==
```

### @id

```
// @id mod-id-1
```

Each mod must have a unique mod id. The mod id must only contain the following characters: 0-9, a-z, and a hyphen (-).

### @name

```
// @name The mod name
```

The mod name. Can be localized (see below).

### @description

```
// @description The mod description
```

A short description of the mod. Can be localized (see below).

### @version

```
// @version 1.0
```

The mod version number. Must increase with each newly published mod version.

### @author

```
// @author John Doe
```

The mod author name or nickname. Can be localized (see below).

### @github

```
// @github https://github.com/nat
```

The link to the GitHub profile of the mod author.

### @twitter

```
// @twitter https://twitter.com/jack
```

The link to the Twitter profile of the mod author.

### @homepage

```
// @homepage https://your-personal-homepage.example.com/
```

The link to the website of the mod author.

### @donateUrl

```
// @donateUrl https://your-personal-homepage.example.com/sponsor
```

The link to a web page where users can financially support or sponsor the mod author.

### @license

```
// @license MIT
```

The type of license under which the mod is released, specifying the terms for use, modification, and distribution.

### @include

```
// @include notepad.exe
// @include program-1.*.exe
// @include C:\programs\*.exe
// @include %SystemRoot%\explorer.exe
```

A list of executable file names/paths that the mod targets. For each process, the mod is loaded if the executable file path matches one of the `@include` entries and doesn't match any `@exclude` entry (see blow).

A wildcard can be used, where the `*` symbol matches any sequence of characters and `?` matches any single character.

Environment variables, such as `%SystemRoot%` and `%ProgramFiles%`, can be used. Note that `%ProgramFiles%` always refers to the native Program Files folder. `%ProgramFiles(X86)%` can be used to refer to the 32-bit Program Files folder (usually `C:\Program Files (x86)`).

There can be any number of `@include` entries.

### @exclude

```
// @exclude notepad.exe
// @exclude program-1.*.exe
// @exclude C:\programs\*.exe
// @exclude %SystemRoot%\explorer.exe
```

A list of executable file names/paths to be excluded from targeting. For each process, the mod is loaded if the executable file path matches one of the `@include` entries (see above) and doesn't match any `@exclude` entry.

A wildcard can be used, where the `*` symbol matches any sequence of characters and `?` matches any single character.

Environment variables, such as `%SystemRoot%` and `%ProgramFiles%`, can be used. Note that `%ProgramFiles%` always refers to the native Program Files folder. `%ProgramFiles(X86)%` can be used to refer to the 32-bit Program Files folder (usually `C:\Program Files (x86)`).

There can be any number of `@exclude` entries.

### @architecture

```
// @architecture x86
// @architecture x86-64
// @architecture amd64
// @architecture arm64
```

A list of supported architectures. Specifying no `@architecture` entries is equivalent to specifying both `x86` and `x86-64`.

Due to compatibility reasons, the names might be slightly misleading.

* **x86** - The mod is compiled as 32-bit (x86).
* **amd64** - The mod is compiled as 64-bit (x86-64).
* **arm64** - The mod is compiled as ARM64 (AArch64). Ignored on non-ARM64 devices.
* **x86-64** - On non-ARM64 devices, equivalent to **amd64**. On ARM64 devices: if the mod only targets processes from the predefined list below, equivalent to **arm64**. Otherwise, equivalent to specifying both **amd64** and **arm64**.
  * The predefined list of processes: StartMenuExperienceHost.exe, SearchHost.exe, explorer.exe, ShellExperienceHost.exe, ShellHost.exe, dwm.exe, notepad.exe, regedit.exe.

There can be any number of `@architecture` entries.

### @compilerOptions

```
// @compilerOptions -lcomctl32 -lgdi32 -luxtheme
```

Extra command line parameters that are passed to the compiler when compiling the mod.

## Mod metadata localization

Some of the metadata entries can be localized for multiple languages, for example:

```
// @name       Example mod
// @name:uk-UA Приклад мод
// @name:fr-FR Exemple de mod
```

## Readme

A mod may contain a readme block with information for the users. The general format is:

```
// ==WindhawkModReadme==
/*
content
*/
// ==/WindhawkModReadme==
```

[Markdown](https://en.wikipedia.org/wiki/Markdown) can be used to add links and formatting to the readme. Only images from the following domains can be embedded in the readme: `https://i.imgur.com`, `https://raw.githubusercontent.com`.

Readme example:

```
// ==WindhawkModReadme==
/*
# Your Awesome Mod
This is a place for useful information about your mod. Use it to describe
the mod, explain why it's useful, and add any other relevant details.
You can use [Markdown](https://en.wikipedia.org/wiki/Markdown) to add links
and **formatting** to the readme.
*/
// ==/WindhawkModReadme==
```

## Settings

A mod may define settings that the mod users will be able to configure. The settings are defined in [YAML](https://en.wikipedia.org/wiki/YAML) format as following:

```
// ==WindhawkModSettings==
/*
- SettingName: Default Value
*/
// ==/WindhawkModSettings==
```

Each setting is defined by a name and a default value. The default value is set when the mod is installed, and can be changed later by the user.

Possible setting types are: boolean, number, string, array of numbers, array of strings. Numbers must be integers; see [`$float`](#float) below for decimal values in Windhawk 2.0.

Options can be nested as can be seen in the example below.

In addition to the setting name and default value, several metadata values can be used to make it easier for users to edit the options:
* `$name`: The name of the option.
* `$description`: A short description of the option.
* `$options`: Possible values for a string option, displayed to the user in a combobox.

Windhawk 2.0 adds more annotations, see [Settings annotations added in Windhawk 2.0](#settings-annotations-added-in-windhawk-20) below.

The metadata values can be localized for multiple languages.

Settings example:

```
// ==WindhawkModSettings==
/*
- BooleanOption: true
  $name: Example Boolean
  $description: An example boolean setting
  $description:uk-UA: Приклад логічного налаштування
- NumberOption: 1234
- StringOption: Default string value
- StringCombobox: option1
  $options:
    - option1: First Option Description
    - option2: Second Option Description
  $options:uk-UA:
    - option1: Опис першого варіанту
    - option2: Опис другого варіанту
- NestedOptions:
    - NumberNestedOption: 2345
    - StringNestedOption: Nested option text
- ArrayOfNumbers: [1, 2, 3]
- ArrayOfStrings: [a, b, c]
- ArrayOfStringComboboxes: [a, b, c]
  $options:
    - a: First Option Description
    - b: Second Option Description
    - c: Third Option Description
- ArrayOfNestedOptions:
    - - NumberNestedOptionInArray: 3456
      - StringNestedOptionInArray: Nested option in array text
*/
// ==/WindhawkModSettings==
```

### Settings annotations added in Windhawk 2.0

*Windhawk 2.0 alpha 6.* Everything in this section is new in Windhawk 2.0. Windhawk 1.7.3, the current release, accepts only `$name`, `$description` and `$options` in a settings block: any other `$` key fails validation ("is not an allowed property"), and a mod whose settings block doesn't validate doesn't install. A mod that uses the annotations below as written therefore runs on Windhawk 2.0 only. To use them in a mod that must also install on 1.7.3, see [Settings compatibility with Windhawk 1.7.3](#settings-compatibility-with-windhawk-173).

| Annotation | Applies to | What it does |
| --- | --- | --- |
| [`$format`](#format) | A string setting, or a number setting with a range | Draws a color picker, a file or folder browse button, a font picker, a hotkey box, or a slider |
| [`$float`](#float) | A number setting | Allows a decimal value |
| [`$min` / `$max`](#min-and-max) | A number setting | Limits the value to a range in the settings editor |
| [`$dynamicSelect`](#dynamicselect) | A string setting | A combobox whose options the mod provides at runtime |
| [`$showIf` / `$hideIf`](#showif-and-hideif) | Any setting | Hides a setting while another setting holds a value under which it's ignored |

Unlike `$name`, `$description` and `$options`, none of the new annotations can be localized. All of them are hints for the settings editor: the mod reads its settings with `Wh_GetIntSetting` and `Wh_GetStringSetting` exactly as before, and nothing rejects a stored value that doesn't match an annotation.

#### `$format`

A display hint for a string setting, or, with `slider`, for a number setting with a range. The value is stored as before either way; the annotation only picks the control that the settings editor draws.

```
- AccentColor: "#3399FF"
  $name: Accent color
  $format: colorRgb
- OverlayColor: "#80FFFFFF"
  $name: Overlay color
  $format: colorArgb
- SoundFile: ""
  $name: Sound file
  $format: filePath
- ToggleHotkey: "ctrl+alt+84"
  $name: Toggle hotkey
  $format: hotkey
- IconSize: 24
  $name: Icon size
  $min: 16
  $max: 64
  $format: slider
```

| `$format` | Stored value | Control |
| --- | --- | --- |
| `colorRgb` | `#RRGGBB`, `#` and six hex digits, e.g. `#3399FF` | Color picker, with the hex text beside it |
| `colorArgb` | `#AARRGGBB`, `#` and eight hex digits, alpha first, e.g. `#80FFFFFF` | Color picker with alpha, with the hex text beside it |
| `filePath` | An absolute file path | Text field with a Browse button that opens a file dialog |
| `folderPath` | An absolute folder path | Text field with a Browse button that opens a folder dialog |
| `fontFamily` | A font family name, e.g. `Segoe UI` | Text field with completion over the installed fonts |
| `hotkey` | A keyboard shortcut, e.g. `ctrl+alt+84` (see below) | A badge showing the shortcut, which records the next shortcut pressed when clicked |
| `slider` | A number with [`$min` and `$max`](#min-and-max), stored as it would be without the format | A slider over the range, with the number field beside it |

Notes:

* The color picker writes uppercase hex with a leading `#`. It reads leniently (either case, with or without the `#`), so a value the user hasn't touched keeps rendering, but a mod which currently expects bare hex must accept the leading `#` before adopting a color format. Quote a color default in the settings block (`"#3399FF"`): unquoted, the `#` starts a YAML comment. A value the picker can't parse (e.g. an empty string or a keyword) is left as it is and shown as raw text, so a mod that accepts a keyword alongside a hex color keeps working.
* `filePath` and `folderPath` don't check that the path exists and don't restrict the extension. The user can also type into the field.
* `fontFamily` allows free text, so a font that isn't installed can still be typed in. The mod receives whatever text was stored.
* `$format` applies to a string array as well, in which case each element gets the control.
* `slider` is the one format for a number setting. It draws only when the setting declares both `$min` and `$max`, with `$min` below `$max`; a number with one bound or none, or with `$min` equal to `$max`, gets the plain number control as if the format weren't there. It works on an integer or a `$float`, and on an array of either, with a slider per element. An integer slider moves in steps of 1; a `$float` slider in steps of the largest power of ten that gives the range at least a hundred positions (`0.01` over `0..1`, `0.1` over `0..10`). The number field beside the slider takes any value in the range, so a value between steps can be typed.
* A `$format` value the settings editor doesn't know is drawn as a plain text field, so a mod may use a format that a newer Windhawk adds without failing on an older one.

The `hotkey` format stores the shortcut as `[ctrl+][alt+][shift+][win+]<vk>`: the held modifiers, lowercase, in that order, joined with `+`, followed by the Windows virtual-key code of the key as a decimal number. `ctrl+alt+84` is Ctrl+Alt+T, `shift+121` is Shift+F10, `115` is F4 on its own, and an empty string means no hotkey. The number is the `VK_*` constant, i.e. the value which `RegisterHotKey` and `GetAsyncKeyState` take: a letter is its uppercase ASCII code (`A` = 65), a digit its ASCII code (`0` = 48), `VK_F1` = 112, `VK_ESCAPE` = 27, and so on. Since a code names a key rather than a character, the value means the same thing on every keyboard layout. The editor shows the key by name (`T`, `F5`) and stores the number. Parsing it in the mod takes a few lines:

```
PCWSTR text = Wh_GetStringSetting(L"ToggleHotkey");
UINT modifiers = 0;
if (wcsstr(text, L"ctrl+")) modifiers |= MOD_CONTROL;
if (wcsstr(text, L"alt+")) modifiers |= MOD_ALT;
if (wcsstr(text, L"shift+")) modifiers |= MOD_SHIFT;
if (wcsstr(text, L"win+")) modifiers |= MOD_WIN;
PCWSTR vkText = wcsrchr(text, L'+');
UINT vk = _wtoi(vkText ? vkText + 1 : text);
Wh_FreeStringSetting(text);
if (vk != 0) {
    RegisterHotKey(nullptr, 1, modifiers | MOD_NOREPEAT, vk);
}
```

A mod which previously took a hotkey as free text (e.g. `Ctrl+Alt+T`) and switches to `$format: hotkey` changes the spelling its users have stored: the snippet above reads `vk == 0` from the old text, and the editor shows it as raw text until the next capture replaces it. Keep the old parser as a fallback for a while, or use a new setting name.

#### `$float`

Allows a decimal number. Without it, a number setting must be an integer.

```
- Opacity: 0.85
  $name: Opacity
  $float: true
- Weights: [0.25, 0.5, 1]
  $name: Weights
  $float: true
```

Applies to a number or an array of numbers. The value is stored as a string, in the shortest decimal form that represents it (`1.0` and `"1.0"` are stored as `1`, `1e3` as `1000`), and the settings editor draws a number control that accepts decimals. The mod reads it as a string and converts:

```
PCWSTR opacityStr = Wh_GetStringSetting(L"Opacity");
double opacity = wcstod(opacityStr, nullptr);
Wh_FreeStringSetting(opacityStr);
```

The default may also be written as a string holding a number (`Opacity: "0.85"`), which is the form to use together with the `#!` marker (see below). An existing integer setting can adopt `$float` without migration: a stored integer is returned as its decimal text by `Wh_GetStringSetting`, so `wcstod` sees `1` where a `1` was stored.

#### `$min` and `$max`

Limit a number setting to a range in the settings editor. Either one may be used alone, or both together. They apply to a number or an array of numbers, with or without `$float`, and the default must lie within the range.

```
- Rating: 3
  $name: Rating
  $min: 1
  $max: 5
- Opacity: 0.85
  $name: Opacity
  $float: true
  $min: 0
  $max: 1
  $format: slider
- Retries: 3
  $name: Retries
  $min: 0
```

The range is enforced by the settings editor, not by the storage: a value which is already stored outside the range, e.g. one written by an earlier mod version with a wider range, is shown and marked in the editor but still returned to the mod as it is. A mod that can't tolerate such a value clamps it after reading it.

A setting with both bounds may add `$format: slider` to be drawn as a slider over the range, with the number field beside it, which suits a value the user picks by position (an opacity, a percentage) better than one they think of in digits (a width in pixels). See [`$format`](#format).

#### `$dynamicSelect`

A combobox whose options the mod provides at runtime, for things like audio devices, monitors or installed fonts. Applies to a string setting or an array of strings.

```
- OutputDevice: ""
  $name: Output device
  $dynamicSelect: true
- Monitor: primary
  $name: Monitor
  $options:
    - primary: Primary monitor
  $dynamicSelect: true
```

The mod provides the options at runtime with [`Wh_SetDynamicSelectOption`](#wh_setdynamicselectoption), [`Wh_DeleteDynamicSelectOption`](#wh_deletedynamicselectoption) and [`Wh_ClearDynamicSelectOptions`](#wh_cleardynamicselectoptions):

```
Wh_ClearDynamicSelectOptions(L"OutputDevice");
Wh_SetDynamicSelectOption(L"OutputDevice", L"{0.0.0.00000000}.{a1b2c3d4-...}",
                          L"Speakers (Realtek High Definition Audio)");
```

* The setting path is the setting's name; for a nested setting it's the names joined with `.`, e.g. `Audio.OutputDevice`. Array indices are omitted, e.g. `Rules.Device`, and every element of the array offers the same options.
* The option value is what gets stored in the setting when the option is selected, like the key of a `$options` entry. The label is what the combobox shows.
* Options are shown in the order they were added.
* The mod can update the options at any time, e.g. in `Wh_ModInit` or on a device change notification. The settings editor reads them each time the combobox is opened.
* `$options` may be combined with `$dynamicSelect`: the static options come first, the runtime ones follow, and a runtime option whose value matches a static one replaces its label (e.g. a "Default" entry which is relabeled at runtime with the device it resolves to).
* The currently stored value is always offered, even when no option names it, so an unplugged device keeps its selection and the user can see what it was.

The options are kept in the mod's local storage, not in its settings, so saving settings doesn't clear them.

<details>
<summary><b>Pre-2.0 compatibility</b> (click to expand)</summary>

`Wh_SetDynamicSelectOption`, `Wh_DeleteDynamicSelectOption` and `Wh_ClearDynamicSelectOptions` are declared in a header that ships with the Windhawk 2.0 compiler, so a mod which calls them doesn't compile on earlier versions, such as 1.7.3. Each option is a string value in the mod's local storage, named `::wh_select_option::<setting path>::<option value>` and holding the label, so a mod can write the options with `Wh_SetStringValue` and `Wh_DeleteValue`, which every version has. Define these functions in the mod and call them instead of the `Wh_` ones:

```
// Returns the local storage name of a `$dynamicSelect` option, allocated on the
// process heap, or `NULL` on failure.
PWSTR DynamicSelectOptionName(PCWSTR settingPath, PCWSTR value) {
    static const WCHAR prefix[] = L"::wh_select_option::";
    static const WCHAR separator[] = L"::";
    size_t len = (ARRAYSIZE(prefix) - 1) + lstrlenW(settingPath) +
                 (ARRAYSIZE(separator) - 1) + lstrlenW(value);
    PWSTR name =
        (PWSTR)HeapAlloc(GetProcessHeap(), 0, (len + 1) * sizeof(WCHAR));
    if (name) {
        lstrcpyW(name, prefix);
        lstrcatW(name, settingPath);
        lstrcatW(name, separator);
        lstrcatW(name, value);
    }
    return name;
}

BOOL SetDynamicSelectOption(PCWSTR settingPath, PCWSTR value, PCWSTR label) {
    PWSTR name = DynamicSelectOptionName(settingPath, value);
    if (!name) {
        return FALSE;
    }
    BOOL result = Wh_SetStringValue(name, label);
    HeapFree(GetProcessHeap(), 0, name);
    return result;
}

BOOL DeleteDynamicSelectOption(PCWSTR settingPath, PCWSTR value) {
    PWSTR name = DynamicSelectOptionName(settingPath, value);
    if (!name) {
        return FALSE;
    }
    BOOL result = Wh_DeleteValue(name);
    HeapFree(GetProcessHeap(), 0, name);
    return result;
}
```

On Windhawk 2.0 they work like the `Wh_` functions. On an earlier version the options are written but not shown, and the setting is drawn as described in [Settings compatibility with Windhawk 1.7.3](#settings-compatibility-with-windhawk-173).

There's no counterpart for `Wh_ClearDynamicSelectOptions`, since local storage values can't be listed. To drop options that no longer apply, the mod deletes them one by one, so it has to remember which values it wrote, e.g. in another local storage value.

</details>

#### `$showIf` and `$hideIf`

Hide a setting from the settings editor while another setting holds a value under which the mod ignores it, e.g. the settings of a feature while the feature is disabled.

```
- UseAbsoluteSize: false
  $name: Use absolute sizing
- Size: 150
  $name: Thumbnail size (percentage)
  $showIf: {UseAbsoluteSize: false}
- MinWidth: 180
  $name: Minimum width (pixels)
  $showIf: {UseAbsoluteSize: true}
- SoundMode: none
  $name: Sound
  $options:
    - none: No sound
    - systemDefault: System default sound
    - custom: Custom WAV file
- SoundFile: ""
  $name: Custom sound file
  $format: filePath
  $showIf: {SoundMode: custom}
- Mode: labels
  $name: Mode
  $options:
    - labels: Show labels
    - noLabels: Hide labels
    - combined: Combine buttons
- ExcludedPrograms: [""]
  $name: Excluded programs
  $showIf: {Mode: [labels, noLabels]}
- HorizontalAlignment: same
  $name: Horizontal alignment
  $options:
    - same: Same as Notification Center
    - left: Left
    - right: Right
- HorizontalShift: 0
  $name: Horizontal shift
  $hideIf: {HorizontalAlignment: same}
```

* Each key names another setting, with a value of that setting's type (`true`/`false`, an integer or a string) or a list of such values. The key matches if the named setting has that value, or any of the listed values.
* A setting is shown only if all of its `$showIf` keys match and none of its `$hideIf` keys match. For example, `$hideIf: {UseAbsoluteSize: true, Mode: combined}` hides the setting if `UseAbsoluteSize` is `true` or if `Mode` is `combined`.
* There's no "show if any key matches" or "hide only if all keys match". If the mod needs that, use a single `$options` setting with an option for each case instead of separate settings.
* Either annotation may be placed on any setting, including a nested group or an array.
* The named setting must be a single boolean, integer or string, not an array, a nested group or a `$float` number. If it has `$options`, each string must be one of the declared option values (a typo is a validation error rather than a setting hidden forever), unless it also has `$dynamicSelect`, whose values are only known at runtime.
* A name is looked up first among the setting's own siblings (the settings of the same nested group, or of the same element in an array of nested settings), then in the enclosing groups outward to the top level. A dotted name such as `Rendering.UseVisualStyles` descends into a nested group from wherever the first part is found. A setting can't name itself, and a group can't name a setting inside it.
* Inside an array of nested settings, a setting can name its element's siblings, and each element is evaluated against its own values. A setting outside the array can't name one inside it.

The settings editor evaluates the conditions against the values as they are being edited, before they're saved, so turning a switch on reveals its settings at once. A hidden setting is removed from the form, not disabled. A setting is also hidden while a setting named in its `$showIf` or `$hideIf` is hidden. The YAML editing mode lists every setting regardless.

The annotation is only a hint for the editor. A hidden setting keeps its stored value, and the mod receives it as before, so the mod must actually ignore the setting under the declared condition: the user can no longer see the field, and a value typed earlier is still there.

### Settings compatibility with Windhawk 1.7.3

Written as above, the annotations make a mod Windhawk 2.0 only: Windhawk 1.7.3 fails to validate the settings block and refuses to install the mod. To use them in a mod that must also install on Windhawk 1.7.3, write each annotation on a line that begins with `#! ` (a `#`, a `!` and one space):

```
// ==WindhawkModSettings==
/*
- AccentColor: "#3399FF"
  $name: Accent color
  #! $format: colorRgb
- Opacity: "0.85"
  $name: Opacity
  #! $float: true
  #! $min: 0
  #! $max: 1
- Monitor: primary
  $name: Monitor
  #! $options:
  #! - primary: Primary monitor
  #! - secondary: Secondary monitor
  #! $dynamicSelect: true
- FadeEnabled: true
  $name: Fade
- FadeDelay: 100
  $name: Fade delay
  #! $showIf:
  #!   FadeEnabled: true
*/
// ==/WindhawkModSettings==
```

Windhawk 1.7.3 (and any YAML tool) reads such a line as a comment, so the block validates there and the mod installs with the plain controls. Windhawk 2.0 reads the line with the three marker characters removed, so it gets the full annotations. A mod written this way needs no minimum Windhawk version.

The rules:

* The marker works per line. What follows it is ordinary YAML, at the column the `#` held, so an annotation is written where it would be without the marker, with the marker in front of it. An annotation spanning several lines is marked on every line.
* `#!` must be followed by exactly one space. `#!$format` is an error, so a typo in the marker fails loudly instead of silently staying a comment. A regular comment, `# $format`, with a space after the `#`, stays a comment.
* Only annotations that 1.7.3 rejects may be marked: `$format`, `$float`, `$dynamicSelect`, `$min`, `$max`, `$showIf` and `$hideIf`. Marking `$name`, `$description` or a setting itself is an error.
* `$options` may be marked only next to `$dynamicSelect: true`, and then with all of its localized variants marked together. This makes the setting a free text field on 1.7.3, where any value can be typed, instead of a combobox pinned to the few declared values. Leaving `$options` unmarked is fine too, 1.7.3 then shows a combobox with the static options.
* Once a block has a marker anywhere, every annotation from the list above in that block must be marked. Windhawk 2.0 reads such a block a second time the way 1.7.3 does, and reports a bare annotation ("is not an allowed property for Windhawk 1.7.3; mark it, or mark nothing in this block"), so a marked block can't break on 1.7.3 by mistake.
* With the marker, a `$float` default must be a string (`Opacity: "0.85"`) or an integer (`Scale: 1`). A decimal literal (`Opacity: 0.85`) is rejected in a marked block, since 1.7.3 would store it truncated to an integer. With a string default, 1.7.3 shows a text field and stores the text, which the mod reads with `wcstod` as on Windhawk 2.0. With an integer default, 1.7.3 shows an integer field, and its users are limited to whole numbers.

What Windhawk 1.7.3 shows for a marked annotation, and what the mod has to do about it:

| Annotation | On Windhawk 1.7.3 | In the mod |
| --- | --- | --- |
| `$format` | A plain text field, storing the same text; for `slider`, a plain number field | Nothing |
| `$float` | A text field (string default) or an integer field (integer default) | Nothing, `Wh_GetStringSetting` and `wcstod` work on both |
| `$dynamicSelect` | A combobox with the static `$options`, or a text field if `$options` is marked too | Write the options with its own functions, see "Pre-2.0 compatibility" under [`$dynamicSelect`](#dynamicselect). The `Wh_` functions for the options require Windhawk 2.0. |
| `$min` / `$max` | No limits | Clamp the value after reading it |
| `$showIf` / `$hideIf` | Every setting is shown | Ignore the setting under the condition, which the mod does anyway |

## Callback functions

There are several callback functions that the mod can implement. Those callback functions are called by the Windhawk engine when specific events occur.

See also: [[Mod lifetime|Mod-lifetime]].

### `Wh_ModInit`

```
BOOL Wh_ModInit()
```

The first callback function that is called by the Windhawk engine. Called before the target process starts executing, unless the process is already running when the mod is loading. Allows the mod to initialize and to set up hooks using the Wh_SetFunctionHook API function (see below).

The mod must return `TRUE` if initialization is successful. If `FALSE` is returned, no further callbacks are called and the mod is unloaded.

### `Wh_ModAfterInit`

```
void Wh_ModAfterInit()
```

Called after `Wh_ModInit` and after the Windhawk engine completes setting up hooks.

### `Wh_ModBeforeUninit`

```
void Wh_ModBeforeUninit()
```

Called when the mod is about to be unloaded, before the Windhawk engine removes hooks.

### `Wh_ModUninit`

```
void Wh_ModUninit()
```

Called when the mod is about to be unloaded, after the Windhawk engine removes hooks.

### `Wh_ModSettingsChanged`

```
// Variant 1:
void Wh_ModSettingsChanged()
// Variant 2:
BOOL Wh_ModSettingsChanged(BOOL* bReload)
```

Called when the mod settings are changed. Allows the mod to load and apply the new settings.

Variant 2 of the callback allows to unload or reload the mod after settings are changed. If the callback returns `FALSE`, the mod will be unloaded for the target process, and will stay unloaded until settings are changed again. If the callback returns `TRUE` and `*bReload` is set to `TRUE`, the mod will be reloaded after the callback returns.

## API functions

There are several API functions that the mod can use.

### `Wh_Log`

```
#define Wh_Log(message, ...) /*...*/
```

Logs a message. If logging is enabled, the message can be viewed in
the editor log output window. The arguments are only evaluated if logging
is enabled.

* `message`: The message to be logged. It can optionally contain embedded
printf-style format specifiers that are replaced by the values specified
in subsequent additional arguments and formatted as requested.

### `Wh_GetIntValue`

```
int Wh_GetIntValue(PCWSTR valueName, int defaultValue);
```

Retrieves an integer value from the mod's local storage.

* `valueName`: The name of the value to retrieve.
* `defaultValue`: The default value to be returned as a fallback.

**Returns**: The retrieved integer value. If the value doesn't exist or in case of
an error, the provided default value is returned.

### `Wh_SetIntValue`

```
BOOL Wh_SetIntValue(PCWSTR valueName, int value);
```

Stores an integer value in the mod's local storage.

* `valueName`: The name of the value to store.
* `value`: The value to store.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_GetStringValue`

```
size_t Wh_GetStringValue(PCWSTR valueName, PWSTR stringBuffer, size_t bufferChars);
```

Retrieves a string value from the mod's local storage.

* `valueName`: The name of the value to retrieve.
* `stringBuffer`: The buffer that will receive the text, terminated with a
null character.
* `bufferChars`: The length of `stringBuffer`, in characters. The buffer
must be large enough to include the terminating null character.

**Returns**: The number of characters copied to the buffer, not including the
terminating null character. If the value doesn't exist, if the buffer is
not large enough, or in case of an error, an empty string is returned.

### `Wh_SetStringValue`

```
BOOL Wh_SetStringValue(PCWSTR valueName, PCWSTR value);
```

Stores a string value in the mod's local storage.

* `valueName`: The name of the value to store.
* `value`: A null-terminated string containing the value to store.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_GetBinaryValue`

```
size_t Wh_GetBinaryValue(PCWSTR valueName, void* buffer, size_t bufferSize);
```

Retrieves a binary value (raw bytes) from the mod's local storage.

* `valueName`: The name of the value to retrieve.
* `buffer`: The buffer that will receive the value.
* `bufferSize`: The length of the buffer, in bytes.

**Returns**: The number of bytes copied to the buffer. If the value doesn't exist,
if the buffer is not large enough, or in case of an error, no data is
copied and the return value is zero.

### `Wh_SetBinaryValue`

```
BOOL Wh_SetBinaryValue(PCWSTR valueName, const void* buffer, size_t bufferSize);
```

Stores a binary value (raw bytes) in the mod's local storage.

* `valueName`: The name of the value to store.
* `buffer`: An array of bytes containing the value to store.
* `bufferSize`: The size of the array of bytes.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_DeleteValue`

```
BOOL Wh_DeleteValue(PCWSTR valueName);
```

Deletes a value from the mod's local storage.

* `valueName`: The name of the value to delete.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_GetModStoragePath`

```
size_t Wh_GetModStoragePath(PWSTR pathBuffer, size_t bufferChars);
```

Retrieves the mod's storage directory path. The directory can be used by the mod
to store any necessary files. The directory will be removed when the mod is
removed.

* `pathBuffer`: The buffer that will receive the path, terminated with a null
  character.
* `bufferChars`: The length of `pathBuffer`, in characters. The buffer must be
  large enough to include the terminating null character.

**Returns**: The number of characters copied to the buffer, not including the
terminating null character. If the buffer is not large enough or in case of an
error, an empty string is returned.

### `Wh_GetIntSetting`

```
int Wh_GetIntSetting(PCWSTR valueName, ...);
```

Retrieves an integer value from the mod's user settings.

* `valueName`: The name of the value to retrieve. It can optionally contain
embedded printf-style format specifiers that are replaced by the values
specified in subsequent additional arguments and formatted as requested.

**Returns**: The retrieved integer value. If the value doesn't exist or in case of
an error, the return value is zero.

### `Wh_GetStringSetting`

```
PCWSTR Wh_GetStringSetting(PCWSTR valueName, ...);
```

Retrieves a string value from the mod's user settings. When no longer
needed, free the memory with `Wh_FreeStringSetting`.

* `valueName`: The name of the value to retrieve. It can optionally contain
embedded printf-style format specifiers that are replaced by the values
specified in subsequent additional arguments and formatted as requested.

**Returns**: The retrieved string value. If the value doesn't exist or in case of
an error, an empty string is returned.

### `Wh_FreeStringSetting`

```
void Wh_FreeStringSetting(PCWSTR string);
```

Frees a string returned by `Wh_GetStringSetting`.

* `string`: The string to free.

### `Wh_SetDynamicSelectOption`

```
BOOL Wh_SetDynamicSelectOption(PCWSTR settingPath, PCWSTR value, PCWSTR label);
```

Adds or updates an option of a `$dynamicSelect` setting.

* `settingPath`: The setting's declaration path: its key with any array
subscripts removed, e.g. `L"outputDevice"`, `L"audio.device"`, or
`L"rules.device"` for `rules[i].device`.
* `value`: The value stored in the setting when the option is selected. Can be
empty.
* `label`: The text shown for the option.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_DeleteDynamicSelectOption`

```
BOOL Wh_DeleteDynamicSelectOption(PCWSTR settingPath, PCWSTR value);
```

Removes an option of a `$dynamicSelect` setting.

* `settingPath`: The setting's declaration path, as for
`Wh_SetDynamicSelectOption`.
* `value`: The value of the option to remove.

**Returns**: A boolean value indicating whether the function succeeded. Removing
an option that doesn't exist succeeds.

### `Wh_ClearDynamicSelectOptions`

```
BOOL Wh_ClearDynamicSelectOptions(PCWSTR settingPath);
```

Removes all options of a `$dynamicSelect` setting.

* `settingPath`: The setting's declaration path, as for
`Wh_SetDynamicSelectOption`.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_SetFunctionHook`

```
BOOL Wh_SetFunctionHook(void* targetFunction, void* hookFunction, void** originalFunction);
```

Registers a hook for the specified target function. Can't be called
after `Wh_ModBeforeUninit` returns. Registered hook operations can be
applied with `Wh_ApplyHookOperations`.

* `targetFunction`: A pointer to the target function, which will be
overridden by the detour function.
* `hookFunction`: A pointer to the detour function, which will override the
target function.
* `originalFunction`: A pointer to the trampoline function, which will be
used to call the original target function. Can be `NULL`.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_RemoveFunctionHook`

```
BOOL Wh_RemoveFunctionHook(void* targetFunction);
```

Registers a hook to be removed for the specified target function.
Can't be called before `Wh_ModInit` returns or after `Wh_ModBeforeUninit`
returns. Registered hook operations can be applied with
`Wh_ApplyHookOperations`.

* `targetFunction`: A pointer to the target function, for which the hook
will be removed.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_ApplyHookOperations`

```
BOOL Wh_ApplyHookOperations();
```

Applies hook operations registered by `Wh_SetFunctionHook` and
`Wh_RemoveFunctionHook`. Called automatically by Windhawk after
`Wh_ModInit`. Can't be called before `Wh_ModInit` returns or after
`Wh_ModBeforeUninit` returns. Note: This function is very slow, avoid
using it if possible. Ideally, all hooks should be set in `Wh_ModInit`
and this function should never be used.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_FindFirstSymbol`

```
typedef struct tagWH_FIND_SYMBOL_OPTIONS {
    // Must be set to `sizeof(WH_FIND_SYMBOL_OPTIONS)`.
    size_t optionsSize;
    // The symbol server to query. Set to `NULL` to query the Microsoft public
    // symbol server.
    PCWSTR symbolServer;
    // Set to `TRUE` to only retrieve decorated symbols, making the enumeration
    // faster. Can be especially useful for very large modules such as Chrome or
    // Firefox.
    BOOL noUndecoratedSymbols;
} WH_FIND_SYMBOL_OPTIONS;

typedef struct tagWH_FIND_SYMBOL {
    void* address;
    PCWSTR symbol;
    PCWSTR symbolDecorated;
} WH_FIND_SYMBOL;

HANDLE Wh_FindFirstSymbol(HMODULE hModule, const WH_FIND_SYMBOL_OPTIONS* options, WH_FIND_SYMBOL* findData);
```

Returns information about the first symbol for the specified module
handle.

* `hModule`: A handle to the loaded module whose information is being
requested. If this parameter is `NULL`, the module of the current process
(.exe file) is used.
* `options`: Can be used to customize the symbol enumeration. Pass `NULL`
to use the default options.
* `findData`: A pointer to a structure to receive the symbol information.

**Returns**: A search handle used in a subsequent call to `Wh_FindNextSymbol` or
`Wh_FindCloseSymbol`. If no symbols are found or in case of an error, the
return value is `NULL`.

### `Wh_FindNextSymbol`

```
typedef struct tagWH_FIND_SYMBOL {
    void* address;
    PCWSTR symbol;
    PCWSTR symbolDecorated;
} WH_FIND_SYMBOL;

BOOL Wh_FindNextSymbol(HANDLE symSearch, WH_FIND_SYMBOL* findData);
```

Returns information about the next symbol for the specified search
handle, continuing an enumeration from a previous call to
`Wh_FindFirstSymbol`.

* `symSearch`: A search handle returned by a previous call to
`Wh_FindFirstSymbol`.
* `findData`: A pointer to a structure to receive the symbol information.

**Returns**: A boolean value indicating whether symbol information was retrieved.
If no more symbols are found or in case of an error, the return value is
`FALSE`.

### `Wh_FindCloseSymbol`

```
void Wh_FindCloseSymbol(HANDLE symSearch);
```

Closes a file search handle opened by `Wh_FindFirstSymbol`.

* `symSearch`: The search handle. If symSearch is `NULL`, the function does
nothing.

### `Wh_Disasm`

```
typedef struct tagWH_DISASM_RESULT {
    // The length of the decoded instruction.
    size_t length;
    // The textual, human-readable representation of the instruction.
    char text[96];
} WH_DISASM_RESULT;

BOOL Wh_Disasm(void* address, WH_DISASM_RESULT* result);
```

Disassembles an instruction and formats it to human-readable text.

* `address`: The address of the instruction to disassemble.
* `result`: A pointer to a structure to receive the disassembly
information.

**Returns**: A boolean value indicating whether the function succeeded.

### `Wh_GetUrlContent`

```
typedef struct tagWH_GET_URL_CONTENT_OPTIONS {
    // Must be set to `sizeof(WH_GET_URL_CONTENT_OPTIONS)`.
    size_t optionsSize;
    // The path to the file to which the content will be written. If set, the
    // data will be written to the file and the `data` field of the returned
    // struct will be `NULL`. If this field is `NULL`, the content will be
    // returned in the `data` field.
    PCWSTR targetFilePath;
} WH_GET_URL_CONTENT_OPTIONS;

typedef struct tagWH_URL_CONTENT {
    const char* data;
    size_t length;
    int statusCode;
} WH_URL_CONTENT;

const WH_URL_CONTENT* Wh_GetUrlContent(
    PCWSTR url,
    const WH_GET_URL_CONTENT_OPTIONS* options);
```

Retrieves the content of a URL. When no longer needed, call
`Wh_FreeUrlContent` to free the content.

* `url`: The URL to retrieve.
* `options`: The options for the URL content retrieval. Pass `NULL` to use the
  default options.

**Returns**: The retrieved content. In case of an error, `NULL` is returned.

### `Wh_FreeUrlContent`

```
void Wh_FreeUrlContent(const WH_URL_CONTENT* content);
```

Frees the content of a URL returned by `Wh_GetUrlContent`.

* `content`: The content to free. If `NULL`, the function does nothing.

## Constants

There are several defined constants that can be used in the code.

### `WH_MOD_ID`

The mod id. Example: `L"my-mod"`

### `WH_MOD_VERSION`

The mod version. Example: `L"1.0"`

## Compilation

As of version 1.7, Windhawk uses Clang 20 ([mingw-w64 toolchain](https://github.com/mstorsjo/llvm-mingw)) and compiles the mods in C++23 mode. The full command line parameters can be seen in editing mode by clicking Ctrl+P and selecting `compile_flags.txt`.
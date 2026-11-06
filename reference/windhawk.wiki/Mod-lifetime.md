Here is a simple flow chart representing the lifetime of a mod:

```mermaid
graph TD
    subgraph Main thread
        init(Wh_ModInit) --> init_hook(Implicit Wh_ApplyHookOperations)
        init_hook --> after_init(Wh_ModAfterInit)
    end
    subgraph Windhawk Engine thread
        after_init --> waiting(Waiting for events)
        waiting -->|Settings changed| settings_changed(Wh_ModSettingsChanged)
        settings_changed --> waiting
        waiting -->|Unload| before_uninit(Wh_ModBeforeUninit)
        before_uninit --> uninit_hook(Hooks are removed)
        uninit_hook --> uninit(Wh_ModUninit)
    end
```

Notes:
* The flow chart represents the lifetime of a mod which is loaded before the target process begins its execution. In case a mod is loaded into a process which is already running, all events are executed in the Windhawk Engine thread.
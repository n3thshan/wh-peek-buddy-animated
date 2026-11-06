// Local link-check stub for Windhawk's runtime API.
// Only used to build a throwaway DLL for the link check described in
// AGENTS.md ("Link check"). Never shipped with the mod.
//
// Includes the real Windhawk header so the stub function signatures match
// exactly. Build with -I pointing at the compiler's include folder.
#include <windows.h>
#include <cstdarg>
#include <cstddef>
#include "windhawk_api_internal.h"

extern "C" {

BOOL InternalWh_IsLogEnabled(void* mod) { return FALSE; }
void InternalWh_Log(void* mod, PCWSTR format, va_list args) {}
int InternalWh_GetIntValue(void* mod, PCWSTR valueName, int defaultValue) {
    return defaultValue;
}
BOOL InternalWh_SetIntValue(void* mod, PCWSTR valueName, int value) {
    return FALSE;
}
size_t InternalWh_GetStringValue(void* mod, PCWSTR valueName,
                                 PWSTR stringBuffer, size_t bufferChars) {
    return 0;
}
BOOL InternalWh_SetStringValue(void* mod, PCWSTR valueName, PCWSTR value) {
    return FALSE;
}
size_t InternalWh_GetBinaryValue(void* mod, PCWSTR valueName, void* buffer,
                                 size_t bufferSize) {
    return 0;
}
BOOL InternalWh_SetBinaryValue(void* mod, PCWSTR valueName,
                               const void* buffer, size_t bufferSize) {
    return FALSE;
}
BOOL InternalWh_DeleteValue(void* mod, PCWSTR valueName) { return FALSE; }
size_t InternalWh_GetModStoragePath(void* mod, PWSTR pathBuffer,
                                    size_t bufferChars) {
    return 0;
}
int InternalWh_GetIntSetting(void* mod, PCWSTR valueName, va_list args) {
    return 0;
}
PCWSTR InternalWh_GetStringSetting(void* mod, PCWSTR valueName,
                                   va_list args) {
    return L"";
}
void InternalWh_FreeStringSetting(void* mod, PCWSTR string) {}
BOOL InternalWh_SetFunctionHook(void* mod, void* targetFunction,
                                void* hookFunction, void** originalFunction) {
    return FALSE;
}
BOOL InternalWh_RemoveFunctionHook(void* mod, void* targetFunction) {
    return FALSE;
}
BOOL InternalWh_ApplyHookOperations(void* mod) { return FALSE; }
HANDLE InternalWh_FindFirstSymbol4(void* mod, HMODULE hModule,
                                   const WH_FIND_SYMBOL_OPTIONS* options,
                                   WH_FIND_SYMBOL* findData) {
    return nullptr;
}
BOOL InternalWh_FindNextSymbol2(void* mod, HANDLE symSearch,
                                WH_FIND_SYMBOL* findData) {
    return FALSE;
}
void InternalWh_FindCloseSymbol(void* mod, HANDLE symSearch) {}
BOOL InternalWh_HookSymbols(void* mod, HMODULE module,
                            const WH_SYMBOL_HOOK* symbolHooks,
                            size_t symbolHooksCount,
                            const WH_HOOK_SYMBOLS_OPTIONS* options) {
    return FALSE;
}
BOOL InternalWh_Disasm(void* mod, void* address, WH_DISASM_RESULT* result) {
    return FALSE;
}
const WH_URL_CONTENT* InternalWh_GetUrlContent(void* mod, PCWSTR url,
                                               const WH_GET_URL_CONTENT_OPTIONS*
                                                   options) {
    return nullptr;
}
void InternalWh_FreeUrlContent(void* mod, const WH_URL_CONTENT* content) {}

} // extern "C"

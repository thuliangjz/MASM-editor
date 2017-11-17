IFNDEF VIEW_HANDLER
VIEW_HANDLER equ <1>
include input_queue.inc
ViewKeyHandler PROTO STDCALL input:KEY_INPUT
ENDIF
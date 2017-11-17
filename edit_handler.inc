IFNDEF EDIT_HANDLER
EDIT_HANDLER equ <1>
include input_queue.inc
include ui.inc
include control.inc
include utils.inc
include linkedList.inc
include file_operations.inc

EditHandler PROTO STDCALL input:KEY_INPUT
ENDIF
IFNDEF CONTROLL
CONTROLL equ <1>
include linkedList.inc
include input_queue.inc
include ui.inc

keyInputHandle PROTO,
    keyInput: KEY_INPUT

EditingStatusHandle PROTo, 
    keyInput: KEY_INPUT

WatchingStatusHandle PROTO, 
    keyInput: KEY_INPUT

CommandStatusHandle PROTO, 
    keyInput: KEY_INPUT



ENDIF


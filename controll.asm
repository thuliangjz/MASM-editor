.386                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include controll.inc

includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

endl EQU <0dh, 0ah>

.data
outstr1 db "head:%x", endl, 0
outstr2 db "data:%s", endl, 0
outstrtest db "count : %d", endl, 0
program_status DWORD 0


keyInputHandle PROC, keyInput: KEY_INPUT
    pushad
        .if program_status == 0
            invoke 
    popad
    ret
keyInputHandle ENDP

EditingStatusHandle PROC, keyInput: KEY_INPUT

EditingStatusHandle ENDP



WatchingStatusHandle PROC, keyInput: KEY_INPUT

WatchingStatusHandle ENDP

CommandStatusHandle PROC, keyInput: KEY_INPUT

CommandStatusHandle ENDP
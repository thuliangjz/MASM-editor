include irvine32.inc

includelib irvine32.lib
includelib user32.lib
includelib kernel32.lib

BUFFER_SIZE = 501
DELAY_TIME = 10


.data

.code 
main PROC
L1:
    mov eax,DELAY_TIME
    call Delay
    call ReadKey
    jz L1
    call writeChar
    jmp L1

main ENDP


END main


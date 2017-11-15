IFNDEF LINKED_LIST
LINKED_LIST equ <1>
; (linkedList.inc)
include windows.inc
include kernel32.inc
include msvcrt.inc
include masm32.inc

String STRUCT
    string        DWORD     0 
    dataLength    DWORD     0
    bufferLength  DWORD     0
String ENDS

Node STRUCT
    data          String    <>
    next          DWORD     0
    prev          DWORD     0
Node ENDS 

LinkedList STRUCT
    head         DWORD    0
    currentNode  DWORD    0
    listLength   DWORD    0

LinkedList ENDS



;create the head node of the list and initial currentNode and listLength
InitList PROTO, 
    listPtr: DWORD

InsertNode PROTO,
    listPtr: DWORD 

;delete currentNode and currentNode will be the next node, if doesn't have next node ,currentNode will be the prev node
DeleteNode PROTO,
    listPtr: DWORD  

InitString PROTO, 
    stringPtr: DWORD

InsertChar PROTO,
    stringPtr: DWORD, char: BYTE, pos:DWORD

DeleteChar PROTO,
    stringPtr: DWORD, pos:DWORD

DestroyString PROTO, 
    stringPtr: DWORD
ENDIF

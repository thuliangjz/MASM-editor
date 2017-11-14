; (linkedList.inc)
include masm32.inc
include msvcrt.inc
include kernel32.inc
;include windows.inc


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

List STRUCT
    head         DWORD    0
    currentNode  DWORD    0
    listLength   DWORD    0

List ENDS




InitList PROTO, 
    listPtr: DWORD

InsertNode PROTO,
    listPtr: DWORD 

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
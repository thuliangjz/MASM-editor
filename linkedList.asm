; (linkedList.asm)
.386                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include linkedList.inc

includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

BUFFER_INIT_LENGTH EQU 100
endl EQU <0dh, 0ah>
thisNode EQU <(Node PTR [esi])>
thisList EQU <(List PTR [edi])>


.data
;head Node <0, 0, 0, 0>
outstr1 db "head:%x", endl, 0
outstr2 db "data:%s", endl, 0
outstrtest db "count : %d", endl, 0
tmpAddr DWORD ?
head Node <>
mylist List <>



.code
main PROC
    local data: DWORD
    local tmpStr: BYTE
;    invoke crt_printf, ADDR outstr1, ADDR head
;    pushad
;    INVOKE crt_malloc, SIZEOF Node
;    mov tmpAddr, eax
;    popad
;    mov eax, tmpAddr
;    mov head.next, eax

;    pushad
;    invoke crt_printf, ADDR outstr1, head.next
;    popad
;    mov eax,  head.next
;    mov (Node PTR [eax]).data, 2
;    mov eax, head.next
;    invoke crt_printf, ADDR outstr2, (Node PTR [eax]).data
;    invoke ExitProcess, 0
    invoke InitList, ADDR mylist
    mov tmpStr, 'a'
    mov ecx, 10
createList:
    invoke InsertNode, ADDR mylist
    mov esi, mylist.currentNode
    mov esi, thisNode.data.string
    mov al, tmpStr
    mov BYTE PTR[esi], al
    mov BYTE PTR[esi + 1], 0
    inc tmpStr
    loop createList

    mov ecx, 10
    mov esi, mylist.head
printList:
    mov eax, thisNode.data.string
    mov data, eax
    pushad
        invoke crt_printf, ADDR outstr2, data
    popad
    mov eax, thisNode.next
    mov esi, eax
    loop printList

    mov ecx, 5
    mov esi, mylist.head
    mov edi, thisNode.next
    mov mylist.currentNode, edi
deleteList:
    invoke DeleteNode, ADDR mylist
    loop deleteList


    mov ecx, 5
    mov esi, mylist.currentNode
printList2:
    mov eax, thisNode.data.string
    mov data, eax
    pushad
        invoke crt_printf, ADDR outstr2, data
    popad
    mov eax, thisNode.next
    mov esi, eax
    loop printList2


    invoke ExitProcess, 0
main ENDP



;init the list
InitList PROC, listPtr: DWORD
    ;LOCAL @tmpAddr: DWORD 
    pushad

        invoke crt_malloc, SIZEOF Node
        mov edi, listPtr
        mov thisList.head, eax
        mov thisList.currentNode, eax
        mov esi, eax
        mov thisNode.data.string, 0
        mov thisNode.data.dataLength, 0
        mov thisNode.data.bufferLength, 0
        mov thisNode.prev, 0
        mov thisNode.next, 0

    popad
    ret
InitList ENDP


InsertNode PROC, listPtr: DWORD
    LOCAL tmpString: DWORD
    pushad
        ;eax: newnode,   ebx:oldnode.next  ecx:oldnode
        invoke crt_malloc, SIZEOF Node
        mov edi, listPtr
        mov ecx, thisList.currentNode
        mov esi, ecx
        mov ebx, thisNode.next        ;thisNode == oldnode
        mov thisNode.next, eax         
        .if ebx != 0
            mov esi, ebx              ;thisNode == oldnode.next
            mov thisNode.prev, eax
        .endif
        mov esi, eax                  ;thisNode == newnode
        mov thisNode.prev, ecx
        mov thisNode.next, ebx

        mov thisList.currentNode, eax
        inc thisList.listLength
        
        invoke InitString, ADDR thisNode.data

;        pushad
;            invoke crt_malloc, BUFFER_INIT_LENGTH
;            mov tmpString, eax
;        popad
;        mov eax, tmpString
;        mov thisNode.data.string, eax   
;        mov thisNode.data.dataLength, 0
;        mov thisNode.data.bufferLength, BUFFER_INIT_LENGTH
        
        
    popad
    ret
InsertNode ENDP

DeleteNode PROC, listPtr: DWORD 
    
    pushad
        mov edi, listPtr
        mov esi, thisList.currentNode
        mov ecx, thisNode.prev
        
        .if ecx == 0                      ;is head node
            jmp quit
        .endif
        mov ecx, thisNode.next
        .if ecx == 0                      ;there is no next,  eax:prev
            mov eax, thisNode.prev 
            
            pushad
                invoke crt_free, esi
            popad

            mov esi, eax
            mov thisNode.next, 0  ;thisNode == currentNode.prev
            
            mov thisList.currentNode, eax
            dec thisList.listLength
            jmp quit
        .endif

        mov eax, thisNode.prev
        mov ebx, thisNode.next
        pushad
            invoke crt_free, esi
        popad
        mov esi, eax                
        mov thisNode.next, ebx  ;thisNode == currentNode.prev    
        mov esi, ebx
        mov thisNode.prev, eax

        mov thisList.currentNode, ebx
        dec thisList.listLength

quit:   
    popad
    ret
DeleteNode ENDP


InitString PROC, stringPtr: DWORD
    pushad
        invoke crt_malloc, BUFFER_INIT_LENGTH
        mov esi, stringPtr
        mov (String PTR [esi]).string, eax
        mov (String PTR [esi]).bufferLength, BUFFER_INIT_LENGTH
        mov (String PTR [esi]).dataLength, 0
    popad
    ret
InitString ENDP

InsertChar PROC, data: String, char: BYTE, pos:DWORD
    pushad
        


    popad
    ret
InsertChar ENDP

DeleteChar PROC,  data: String, pos:DWORD
    pushad



    popad
    ret
DeleteChar ENDP

DestroyString PROC, stringPtr: DWORD
    pushad
        mov esi, stringPtr
        mov eax, (String PTR [esi]).bufferLength
        .if eax == 0
            jmp quit
        .endif
        mov (String PTR [esi]).bufferLength, 0
        mov (String PTR [esi]).dataLength, 0
        pushad
            invoke crt_free, (String PTR [esi]).string
        popad
quit:
    popad
    ret
DestroyString ENDP

END main



; (linkedList.asm)
.386                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include linkedList.inc

includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

endl EQU <0dh, 0ah>
thisNode EQU <(Node PTR [esi])>
thisList EQU <(List PTR [edi])>

.data
;head Node <0, 0, 0, 0>
outstr1 db "head:%x", endl, 0
outstr2 db "data:%d", endl, 0
outstrtest db "count : %d", endl, 0
tmpAddr DWORD ?
head Node <>
mylist List <>



.code
main PROC
    local data: DWORD
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
    mov ecx, 10

createList:

    invoke InsertNode, ADDR mylist
    mov esi, mylist.currentNode
    mov thisNode.data.string , ecx
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
    ;LOCAL @tmpNext: DWORD
    pushad
        ;eax: new node,   ebx:oldnode.next  ecx:oldnode
        invoke crt_malloc, SIZEOF Node
        mov edi, listPtr
        mov ecx, thisList.currentNode
        mov esi, ecx
        mov ebx, thisNode.next        ;thisNode == list.currentNode, ebx = list.currentNode->next
        mov thisNode.next, eax         
      
        mov esi, eax  
     
        mov thisNode.data.string, 0   ;thisNode == the new node
        mov thisNode.data.dataLength, 0
        mov thisNode.data.bufferLength, 0
        mov thisNode.prev, ecx
        mov thisNode.next, ebx

        mov thisList.currentNode, eax
        inc thisList.listLength
        ;mov list.currentNode.next, eax
        
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

InsertChar PROC, data: String
    pushad
        
    popad
    ret
InsertChar ENDP

DeleteChar PROC, data: String
    pushad

    popad
    ret
DeleteChar ENDP

END main



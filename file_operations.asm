.486                                    ; create 32 bit code
.model flat, stdcall                    ; 32 bit memory model
option casemap :none                    ; case sensitive

include controll.inc
include linkedList.inc
include ui.inc

includelib masm32.lib
includelib kernel32.lib
includelib msvcrt.lib

;EXTERNDEF text_list:LinkedList
endl EQU <0dh, 0ah>
BUFFER_SIZE EQU 500

.data
read_buffer db 501 DUP(0)
nowPlace DWORD 0
nextPlace DWORD 0
bytes_read DWORD 0
bytes_write DWORD 0
endlStr db 0dh, 0ah, 0


.code
FindEndl PROC
    pushad
        mov eax, nowPlace
        mov nextPlace, eax

    findEndlLoop:
        mov ebx, nextPlace
        .if read_buffer[ebx] == 0dh
            jmp quit
        .endif
        inc nextPlace
        inc ebx
        .if ebx == bytes_read
            jmp quit
        .endif
        jmp findEndlLoop

quit:
    popad
    ret
FindEndl ENDP



ReadFileToList PROC,  p_file_name: DWORD
    local  file_handle, error_code
    pushad
        ;init list first
        invoke InitList, ADDR text_list
        
        invoke CreateFile, addr name_file, GENERIC_READ, 0, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        mov file_handle, eax
        
        invoke GetLastError
        mov error_code, eax
        
        .if error_code ==  ERROR_FILE_NOT_FOUND
        ;if the file doesn't exist
            invoke CloseHandle, file_handle
            invoke InsertNode, addr text_list
            ;create new node
            mov cursor_position_ui.x, 0
            mov cursor_position_ui.y, 0
            mov esi, text_list.currentNode
            mov cursor_position_logic.p_node, esi
            mov cursor_position_logic.index_char, 0        
            
            jmp quit

        .endif
        
        ;create a new node
        invoke InsertNode, addr text_list
        mov esi, text_list.currentNode
        

    readfileloop:
        ;if the file exist
        invoke ReadFile, file_handle, addr read_buffer, BUFFER_SIZE, ADDR bytes_read, NULL
        .if bytes_read == 0
            jmp readfileFinish

        ;init two places        
        mov nowPlace, 0
        mov nextPlace, 0

        createListLoop:
            invoke FindEndl
            mov eax, nowPlace
            mov ebx, nextPlace
            .if eax == ebx
                ;if nowplace is 0dh
                ;create a new node
                invoke InsertNode, addr text_list
                add eax, 2
                .if eax >= bytes_read
                    jmp readfileloop
                .endif
                mov nowPlace, eax
                jmp createListLoop

            .else
                ;if nowplace isn't 0dh
                mov esi, text_list.currentNode
                sub ebx, eax   ;ebx == the number of char to insert
                pushad
                    mov ecx, (Node PTR[esi]).data.bufferLength
                    mov edx, (Node PTR[esi]).data.dataLength
                    add edx, ebx
                    .if edx >= ecx
                        ;如果空间不够则申请空间
                        mov ecx, edx
                        add ecx, ecx
                        mov (Node PTR[esi]).data.bufferLength, ecx
                        
                        invoke crt_malloc, ecx
                        mov edi, eax
                        mov esi, text_list.currentNode
                        mov ecx, (Node PTR[esi]).data.dataLength
                        mov esi, (Node PTR[esi]).data.string
                        cld
		                rep movsb
                        mov esi, text_list.currentNode
                        push eax
                        invoke crt_free, (Node PTR[esi]).data.string
                        mov esi, text_list.currentNode
                        pop (Node PTR[esi]).data.string
                    .endif
                popad

                mov eax,(Node PTR[esi]).data.dataLength
                add esi, eax
                mov edi, esi
                
                push edi
                mov esi, OFFSET read_buffer
                add esi, nowPlace
                mov ecx, ebx
                cld
                rep movsb
                pop edi

                add edi, ebx
                mov BYTE PTR [edi], 0
                
                mov edi, text_list.currentNode
                add (Node PTR[edi]).data.dataLength, ebx
                
                invoke InsertNode, addr text_list
                mov eax, nextPlace
                add eax, 2
                .if eax >= bytes_read
                    jmp readfileloop
                .endif
                mov nowPlace, eax
                jmp createListLoop
                
            .endif

    readfileFinish:
        mov cursor_position_ui.x, 0
        mov cursor_position_ui.y, 0
        mov esi, text_list.head
        mov esi, (Node PTR [esi]).next
        mov cursor_position_logic.p_node, esi
        mov cursor_position_logic.index_char, 0   
        invoke CloseHandle, file_handle   
quit:
    popad
    ret
ReadFileToList ENDP

WriteListToFile PROC, p_file_name: DWORD
    local file_handle
    pushad
        invoke CreateFile, addr name_file, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
        mov file_handle, eax

        mov esi, text_list.head
        .if (Node PTR[esi]).next == 0
            jmp writeToFileFinish
        mov esi, (Node PTR[esi]).next
    writeToFileLoop:
        push esi
            invoke WriteFile, file_handle,  (Node PTR[esi]).data.string, (Node PTR[esi]).dataLength, addr bytes_write, NULL
        pop esi
        ;write the 0dh, 0ah
        push esi
            invoke WriteFile, file_handle,  addr endlStr, 2, addr bytes_write, NULL
        pop esi
        
        mov esi, (Node PTR[esi]).next
        .if esi == 0
            jmp writeToFileFinish
        .endif

        .if (Node PTR[esi]).next == 0
            jmp writeToFileFinish
        .else
            jmp writeToFileLoop
        .endif

    writeToFileFinish:
        .if esi != 0
            push esi
                invoke WriteFile, file_handle,  (Node PTR[esi]).data.string, (Node PTR[esi]).dataLength, addr bytes_write, NULL
            pop esi
        .endif
        invoke CloseHandle, file_handle 
        
    popad
    ret


WriteListToFile ENDP 

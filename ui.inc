IFNDEF UI_TEXT
UI_TEXT equ <1>
include linkedList.inc
include windows.inc
include kernel32.inc
include masm32.inc

CURSOR_POSITION_LOGIC STRUCT
	p_node DWORD
	index_char DWORD
CURSOR_POSITION_LOGIC ENDS
EXTERNDEF text_list:List
EXTERNDEF window_size:COORD
EXTERNDEF cursor_position:COORD
EXTERNDEF cursor_position_logic:CURSOR_POSITION_LOGIC
UIInit PROTO STDCALL hScreenBuffer:HANDLE
ENDIF

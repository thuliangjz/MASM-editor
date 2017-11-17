IFNDEF INPUT_QUEUE
INPUT_QUEUE equ <1>
include windows.inc
include kernel32.inc
include masm32.inc
KEY_INPUT STRUCT
  is_special BOOL ?
  virtual_key WORD ?	;see wVirtualKeyCode field in KEY_EVENT_RECORD
  ALIGN DWORD
  ascii_char BYTE ?
  ALIGN DWORD
KEY_INPUT ENDS
GetUserKeyInput PROTO STDCALL
InitInputQueue PROTO STDCALL
PopInputQueue PROTO STDCALL p_key_input:DWORD	;return 0 if success, 1 otherwise, change head pointer's position
PeekInputQueue PROTO STDCALL p_key_input:DWORD	;return 0 if success, 1 oterwise, won't change head pointer's position
ENDIF

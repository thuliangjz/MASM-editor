IFNDEF COMMAND_HANDLER
COMMAND_HANDLER equ <1>
include input_queue.inc
include utils.inc
include control.inc

EXTERNDEF console_input_string_length:DWORD
EXTERNDEF console_input_string:BYTE
EXTERNDEF console_cursor_index:DWORD
EXTERNDEF process_result:BYTE
EXTERNDEF process_result_length:DWORD
CommandHandler PROTO, user_input:KEY_INPUT
InitCommandHandler PROTO
ENDIF
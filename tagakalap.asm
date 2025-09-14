; preprocessor directives
%define SYS_EXIT 60
%define SYS_WRITE 1
%define SYS_OPEN 2
%define STDOUT 1
%define O_RDONLY 0
%define EV_KEY 1

	default		rel
	global 		main ; use main for gcc

	section		.data

no_param_msg:
	db			"Parameter is required.", 0xa
param_msg_len equ $ - no_param_msg

error_open_msg:
	db			"Error opening device.", 0xa
error_open_msg_len equ $ - error_open_msg

EVIOCGBIT_KEY equ 0x80000000 | (5 << 16) | ('E' << 8) | (0x21) ; ioctl constant for EVIOCGBIT

	section		.bss

ev_bits: ; variable to store ioctl result
	resb 16

	section		.text

main:
	; get command line parameter/argument
	sub			rsp, 8
	cmp			rdi, 2 ; check argc if less than 2
	jl			no_param

	mov			rdi, [rsi + 8] ; get argv

	; set open syscall params
	mov			rsi, O_RDONLY
	mov			rdx, 0
	; call open syscall
	call		open
	cmp			rax, 0
	jl			error_open

	xor			rdi, rdi
	call		exit

; no command line argument, print error then exit with -1
no_param:
	mov			rsi, no_param_msg
	mov			rdx, param_msg_len
	call		print
	mov			rdi, -1
	call		exit

; ioctl error or can't open device
error_open:
	mov			rsi, error_open_msg
	mov			rdx, error_open_msg_len
	call		print
	mov			rdi, -2
	call		exit

; sys_write syscall to print string in stdout
print:
	mov			rax, SYS_WRITE
	mov			rdi, STDOUT
	syscall
	ret

; sys_open syscall
open:
	mov			rax, SYS_OPEN
	syscall
	ret

; sys_exit syscall (mov rdi, [error_number] to set error number) 
exit:
	mov			rax, SYS_EXIT
	syscall
	ret

	section		.note.GNU-stack
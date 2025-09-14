; preprocessor directives
%define SYS_EXIT 60
%define SYS_WRITE 1
%define SYS_OPEN 2
%define SYS_IOCTL 16
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

error_not_keyboard:
	db			"Not a keyboard device.", 0xa
error_not_keyboard_len equ $ - error_not_keyboard

reading_msg:
	db			"Reading input. Press Ctrl+C to stop.", 0xa
reading_msg_len equ $ - reading_msg

keymap: 
	db 			0, 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 0, 0, 0, 0, \
				'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 0, 0, 0, 0, \
				'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 0, 0, 0, 0, 0, \
				'z', 'x', 'c', 'v', 'b', 'n', 'm', 0, 0, 0, 0, 0, 0, ' ', 0
keymap_len equ $ - keymap

char1:
	db			"Character: '"

char2:
	db			"'", 0xa

evchar:
	db			0

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

	; set ioctl param (return of open)
	mov			rdi, rax
	call		ioctl
	cmp			rax, 0
	jl			error_open

	; check if keyboard device
	mov			rbx, qword [ev_bits]
	mov			rcx, 1
	shl			rcx, EV_KEY
	and			rbx, rcx
	jz			not_keyboard

	; start reading inputs
	mov			rsi, reading_msg
	mov			rdx, reading_msg_len
	call		print

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

; not a keyboard error
not_keyboard:
	mov			rsi, error_not_keyboard
	mov			rdx, error_not_keyboard_len
	call		print
	mov			rdi, -3
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

; sys_ioctl syscall
ioctl:
	mov rax, SYS_IOCTL
	mov rsi, EVIOCGBIT_KEY
	mov rdx, ev_bits   
	syscall
	ret

; sys_exit syscall (mov rdi, [error_number] to set error number) 
exit:
	mov			rax, SYS_EXIT
	syscall
	ret

	section		.note.GNU-stack
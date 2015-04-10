EXTERN read_long
EXTERN write_long

SECTION .text
global main

; adds two long number
;    rcx -- address of summand #1 (long number)
;    rdx -- length of long numbers in qwords
;    r8 -- address of summand #2 (long number)
; result:
;    sum is written to rcx
; destroys:
; RAX
add_long_long:
	push rcx
	push rdx
	push r8

	clc

.loop:
	mov rax,[r8]
	adc[rcx],rax
	lea rcx,[rcx+8]
	lea r8,[r8+8]
	dec rdx
	jnz .loop

	pop r8
	pop rdx
	pop rcx

	ret

main:
	push rbp
	mov rbp, rsp
	sub rsp, 2 * 128 * 8; malloc

	mov rcx, rsp
	mov rdx, 128

	call read_long

	mov r8, rcx; now first in r8
	add rcx, 128*8

	call read_long

	;second in rcx, ready to add and write

	call add_long_long

	call write_long

	mov rsp,rbp
	pop rbp

	ret

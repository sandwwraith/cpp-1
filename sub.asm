EXTERN read_long
EXTERN write_long

SECTION .text
global main

;subs two long number (#1-#2)
;    rcx -- address of operand #1 (long number)
;    rdx -- length of long numbers in qwords
;    r8 -- address of operand #2 (long number)
; Assume that operand 1 greater than operand 2
; result:
;    res is written to rcx
; destroys:
; RAX
sub_long_long:
	push rcx
	push rdx
	push r8

	clc

.loop:
	mov rax,[r8]
	sbb [rcx],rax
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

	xchg r8,rcx ; swap args to make 1 - 2

	call sub_long_long

	call write_long

	mov rsp,rbp
	pop rbp

	ret

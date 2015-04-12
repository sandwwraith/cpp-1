EXTERN read_long
EXTERN write_long
EXTERN add_long_long
EXTERN set_zero

SECTION .text
global main


; Multiplies long number by a short and moves it
;    rcx -- address of multiplier #1 (long number)
;    rdx -- length of long number in qwords
;    r8 -- multiplier #2 (64-bit unsigned)
; 	 r9 -- address for result
; result:
;    product is written to r9
;destroys:
;	r10,r11
mul_mov_long_short:
	push r9
	push rax
	push rdx
	push rcx

	xor r10,r10 ; Using r10 for carry;
	mov r11,rdx ; We will use rdx in mul, so r11 is length now.

.loop:
	mov rax, [rcx]
	mul r8
	add rax,r10
	adc rdx,0
	mov [r9], rax
	add rcx,8
	add r9,8
	mov r10,rdx
	dec r11
	jnz .loop

	pop rcx
	pop rdx
	pop rax
	pop r9

	ret


;Shift lefts long number
; Args are not in standart registers, for usability in calling code
;	r9 - location
;	RDX - length
;	RDI - amount of shift
; destroys:
;	rax
shift_left_long:
	push r9
	push rdx
	push rdi
	push r15
	push r14

	lea r9, [r9 + 8*rdx - 8]; Go to number's end.
	mov r15,rdx
	sub r15,rdi ;r15 - number of significant blocks

.loop:
	;mov rax,[r9 - 8 * rdi] Unfortunately, we can't do this command
	mov rax,r9
	mov r14, rdi
	shl r14,3
	sub rax,r14
	mov rax,[rax]

	mov [r9], rax
	sub r9,8
	dec r15
	jnz .loop

	;Fill the rest with zeros
	;An issue for zero shift.
	test rdi,rdi
	jz .end

.loop2:
	mov qword [r9],0
	sub r9,8
	dec rdi
	jnz .loop2

.end:
	pop r14
	pop r15
	pop rdi
	pop rdx
	pop r9

	ret


;Moves long number
;	Rcx - source
;	Rdx - length
;	Rsi - destination
;destroys:
;	rax
mov_long_long:
	push rcx
	push rdx
	push rsi

.loop:
	mov rax,[rcx]
	mov [rsi],rax
	add rcx,8
	add rsi,8
	dec rdx
	jnz .loop

	pop rsi
	pop rdx
	pop rsi

	ret

;Multiplies two long numbers
;	RCX - location of operand one
;	RDX - length (128)
;	R8 - location of operand two
;Result written to RCX
mul_long_long:
	push rcx
	push rdx
	push r8
	push rsi
	push rdi
	push r9
	push r15
	push rbp

	mov rbp, rsp
	sub rsp, 2 * 8 * 128

	mov rsi, rsp ;rsi - accumulator
	push rcx
	mov rcx,rsi
	call set_zero
	pop rcx

	lea r9, [rsp + 8*128]; r9 - current multiplication result
	xor rdi,rdi ; Shift amount
	mov r15,rdx ; Actual length

.loop:
	push r8
	lea r8, [r8 + rdi*8]
	mov r8,[r8]
	call mul_mov_long_short
	pop r8

	call shift_left_long
	inc rdi

	push rcx
	push r8

	mov rcx,rsi
	mov r8,r9

	call add_long_long

	pop r8
	pop rcx

	dec r15
	jnz .loop

	;Finally, we need to move result from rsi to rcx
	xchg rcx,rsi
	call mov_long_long

	mov rsp,rbp ; Clean memory and restore registers

	pop rbp
	pop r15
	pop r9
	pop rdi
	pop rsi
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

	call mul_long_long

	call write_long

	mov rsp,rbp
	pop rbp

	ret


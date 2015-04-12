EXTERN printf
EXTERN scanf

SECTION .rodata
frmt: db "%s",0
frmt_ch db "%c",0x0D,0x0A,0

;------------------------------------------------------------------
;				MICROSOFT x64 CALLING CONVENTIONS
;
;	-Arguments passed in registers RCX,RDX,R8,R9
;	-Others passed by stack in reverse order
;	-The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are
; 	 considered nonvolatile and must be saved and restored by a function that uses them.
;	-The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile
;	 and may be destroyed by called function
;	-Even if functions gets 4 or less args, you MUST allocate space on stack before call for exact four arguments.
;	 It is called "Home area" or "Shadow memory"
;	-Stack frame must be aligned to 16 bytes, so, because returns addres is 8 bytes, and 4 args uses 32 bytes,
;	 before any external call, you should do
;
;	 sub rsp, 0x28
;
;	 and restore it after call.
;
;------------------------------------------------------------------

SECTION .text
global read_long
global write_long
global set_zero ;Neccessary for mul operation

;Cheks a zero in number
;	RCX - location
;	RDX - length in qwords
check_zero:
	push rdx
	push rcx
	push rax

.loop:
	mov rax, [rcx]
	test rax,rax
	jnz .end_loop
	add rcx, 8
	dec rdx
	jnz .loop
	;ZF already 1/0
.end_loop:
	pop rax
	pop rcx
	pop rdx
	ret

;Sets a zero in number
;	RCX - location
;	RDX - length in qwords
set_zero:
	push rdx
	push rcx

.loop:
	mov qword [rcx], 0
	add rcx, 8
	dec rdx
	jnz .loop

.end_loop:
	pop rcx
	pop rdx
	ret


;Multiplies long number by a short
;	rcx - address of multiplier #1 (long number)
;	rdx - length of long number in qwords
; 	r8 - multiplier #2 (64-bit unsigned)
; result:
;   product is written to rcx
;destroys:
;	r10,r11
;You can notice that Long numbers are in Little Endian mode.
mul_long_short:
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
	mov [rcx], rax
	add rcx,8
	mov r10,rdx
	dec r11
	jnz .loop

	pop rcx
	pop rdx
	pop rax

	ret

; Add 64-bit number to long number
;    rcx -- address of summand #1 (long number)
;    rdx -- length of long number in qwords
;    r8 -- summand #2 (64-bit unsigned)
; result:
;    sum is written to rcx
add_long_short:
	push rax
	push rdx
	push rcx
	push r8

	xor rax,rax ; Using for carry

.loop:
	add [rcx], r8
	adc rax,0
	mov r8,rax
	xor rax,rax
	add rcx,8
	dec rdx
	jnz .loop

	pop r8
	pop rcx
	pop rdx
	pop rax

	ret


; divides long number by a short
;    rcx -- address of dividend (long number)
;    rdx -- length of long number in qwords
;    r8 -- divisor (64-bit unsigned)
; result:
;    quotient is written to rcx
;    rax -- remainder
;destroys:
; 	R9
div_long_short:
	push rcx
	push rdx

	lea rcx, [rcx + 8*rdx - 8]; Go to number's end.
	mov r9,rdx; R9 is actual number's length
	xor rdx,rdx; rdx is remainder now

.loop:
	mov rax, [rcx]
	div r8
	mov [rcx], rax
	sub rcx,8
	dec r9
	jnz .loop

	mov rax,rdx ;move remainder to RAX

	pop rdx
	pop rcx

	ret



;Reading long 128*8-byte number from stdin
;Args:
;RCX - location(reference for output)
;RDX - length in qwords (actually, 128)
read_long:
	push r8
	push rdx
	push rcx
	push rsi; Use rsi as address for string
	push rax; AL for char
	sub rsp, 128 * 8; Place for string
	mov rsi,rsp

	call set_zero


	push rcx; We need this registers to pass args to scanf
	push rdx

	sub rsp, 0x28 ; Shadow call
	mov rcx,frmt
	mov rdx,rsi; Our string
	call scanf
	add rsp,0x28

	pop rdx
	pop rcx

	xor rax,rax; Storage for current char
.loop:
	mov al, [rsi]; Load char
	cmp al,0x0D ; CR
	je .done
	cmp al, 0x0A ; LF
	je .done
	cmp al, 0x0 ; Null-terminator
	je .done
	; Assuming we got a valid char

	sub al,'0'
	mov r8,10
	call mul_long_short
	mov r8,rax
	call add_long_short

	inc rsi
	jmp .loop

.done:
	add rsp, 128*8 ; Restore memory back
	pop rax
	pop rsi
	pop rcx
	pop rdx
	pop r8

	ret


;Writing long 128*8-byte number to stdout
;Args:
;RCX - location(reference for output)
;RDX - length in qwords (actually, 128)
write_long:
	push r8
	push rbp
	push rdx
	push rcx
	push rsi ;As address for string
	push r12; because rdx uses in multiply, we'll store length in r12.

	mov r12, rdx

	mov rax,20 ; allocate 20*length memory, 'cause 2^64 ~ 1e19
	mul r12
	mov rbp,rsp
	sub rsp,rax

	mov rdx, r12; Restore
	mov rsi,rbp

	dec rsi
	mov rax, 0x0
	mov [rsi], al ; Adding null-terminator

.loop:
	mov  r8,10
	call div_long_short
	add rax, '0'

	dec rsi
	mov [rsi], al
	call check_zero
	jnz .loop

	; Now we need just to print

	push rdx
	push rcx

	sub rsp,0x28
	mov rcx,frmt
	mov rdx,rsi
	call printf
	add rsp, 0x28

	pop rcx
	pop rdx

	; Free memory, restore stack

	mov rsp,rbp
	pop r12
	pop rsi
	pop rcx
	pop rdx
	pop rbp
	pop r8

	ret

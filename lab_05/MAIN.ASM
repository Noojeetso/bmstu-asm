PUBLIC unsigned_hex

EXTRN scan_menu_number: near
EXTRN update_unsigned_hex: near
EXTRN print_newline: near
EXTRN print_unsigned_hex: near
EXTRN print_unsigned_bin: near
EXTRN print_signed_dec: near

STACKSEG SEGMENT PARA STACK 'STACK'
	DB 200h DUP(?)
STACKSEG ENDS

DATASEG SEGMENT PARA PUBLIC 'DATA'
	menu_prompt DB 'Menu:', 13, 10  ; '
	DB '1. Input unsigned hexadecimal number', 13, 10
	DB '2. Print unsigned binary number', 13, 10
	DB '3. Print signed decimal number', 13, 10
	DB '0. Exit', 13, 10, '$'
	
	unsigned_hex DB 2 DUP(?)
	
	jumptable DW exit, update_unsigned_hex, print_unsigned_bin, print_signed_dec
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, SS:STACKSEG, DS:DATASEG
main:
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
menu_loop:
	; PRINT MENU PROMPT
	call print_unsigned_hex
	
	mov dx, offset menu_prompt
	mov ah, 09h
	int 21h
	
	call scan_menu_number
	; CHECK FOR ERROR INPUT
	cmp ax, 0
	jne menu_loop
	
	; CALL FUNCTION FROM JUMPTABLE
	mov si, bx
	call jumptable[si]
	
	call print_newline
	jmp menu_loop


exit proc near
	mov ah, 'L'
	int 21h
exit endp


CODESEG ENDS
END main

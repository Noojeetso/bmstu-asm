PUBLIC scan_menu_number
PUBLIC update_unsigned_hex

EXTRN print_newline: near
EXTRN print_space: near
EXTRN fill_hex_string_buffer: near

EXTRN unsigned_hex: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	matrix_dimension_error_prompt DB 'Error: matrix dimensions should be positive numbers!', 13, 10, '$'  ; '
	digit_error_prompt DB 'Error: character must be between 0 and 9 or A and F inclusive (hexadecimal)', 13, 10, '$'  ; '
	unsigned_hex_input_prompt DB 'Input unsigned hex number: $'
	menu_number_prompt DB 'Input menu number: $'
	menu_number_error_prompt DB 'Error: menu number should be between 0 and 3 inclusive', 13, 10, '$'  ; '
	current_digit DB 0
	iterations_left DW 0
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG
	

scan_menu_number proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; PRINT MENU NUMBER INPUT PROMPT
	mov dx, offset menu_number_prompt
	mov ah, 09h
	int 21h
	
	; INPUT MENU NUMBER
	mov ah, 01h
	int 21h
	xor bx, bx
	mov bl, al
	
	call print_newline
	
	cmp bl, '0'
	jl input_error
	cmp bl, '3'
	jg input_error
	
	call print_newline
	
	sub bl, '0'
	mov al, bl
	mov cl, 2
	mul cl
	mov bl, al
	
	mov ax, 0
	ret
	
input_error:
	; PRINT MENU NUMBER INPUT ERROR PROMPT
	mov dx, offset menu_number_error_prompt
	mov ah, 09h
	int 21h
	
	call print_newline
	
	mov ax, 1
	ret
scan_menu_number endp


scan_hex_digit proc near
	mov ah, 01h
	int 21h
	;sub al, '0'
	mov current_digit, al

	mov al, current_digit
	
	cmp al, '0'
	jl not_hex
	cmp al, '9'
	jl hex_dec
	cmp al, 'a'
	jl not_hex
	cmp al, 'f'
	jle hex_lower_char
	cmp al, 'A'
	jl not_hex
	cmp al, 'F'
	jle hex_upper_char
	
not_hex:
	mov ax, 1
	ret
hex_dec:
	xor ax, ax
	mov al, current_digit
	sub al, '0'
	mov current_digit, al
	mov ax, 0
	ret
hex_lower_char:
	xor ax, ax
	mov al, current_digit
	sub al, 'a'
	add al, 10
	mov current_digit, al
	mov ax, 0
	ret
hex_upper_char:
	xor ax, ax
	mov al, current_digit
	sub al, 'A'
	add al, 10
	mov current_digit, al
	mov ax, 0
	ret
scan_hex_digit endp


update_unsigned_hex proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax

	mov dx, offset unsigned_hex_input_prompt
	mov ah, 09h
	int 21h
	
	mov word ptr [unsigned_hex], 0
	mov cx, 4
	
read_number:
	mov iterations_left, cx
	mov si, cx
	
	call scan_hex_digit
	cmp al, 0
	jne input_error
	
	xor ax, ax
	mov al, current_digit
	
	; multiply by 4 if it's high byte
	test cx, 1
	jnz add_next_digit
	mov cl, 4
	shl al, cl
add_next_digit:
	dec si
	shr si, 1
	add unsigned_hex[si], al
	
	mov cx, iterations_left
	loop read_number
	
	call print_newline
	
	call fill_hex_string_buffer
	
	mov ax, 0
	ret
	
input_error:
	call print_newline
	
	mov dx, offset digit_error_prompt
	mov ah, 09h
	int 21h
	
	mov ax, 1
	ret
update_unsigned_hex endp


CODESEG ENDS
END

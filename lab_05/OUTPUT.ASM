PUBLIC print_newline
PUBLIC print_unsigned_hex
PUBLIC print_unsigned_bin
PUBLIC print_signed_dec

PUBLIC binary_string
PUBLIC decimal_string

EXTRN fill_binary_string_buffer: near
EXTRN fill_decimal_string_buffer: near

EXTRN unsigned_hex: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	hex_number_output_prompt DB 'Output hex number: $'  ; DEPRECATED
	binary_number_output_prompt DB 'Output binary number: $'
	decimal_number_output_prompt DB 'Output decimal number: $'
	binary_string DB 17 DUP('$')
	decimal_string DB 7 DUP('$')
	iterations_left DW 0
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG


print_newline proc near
	mov ah, 02h
	
	mov dl, 10
	int 21h
	
	mov dl, 13
	int 21h
	
	ret
print_newline endp


print_space proc near
	mov ah, 02h
	mov dl, ' '
	int 21h
	
	ret
print_space endp

; DEPRECATED
print_unsigned_hex proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	mov dx, offset hex_number_output_prompt
	mov ah, 09h
	int 21h
	
	mov cx, 4
	
print_unsigned_hex_digit:
	mov iterations_left, cx
	mov si, cx
	
	dec si
	shr si, 1
	mov dl, unsigned_hex[si]
	
	; check if it's low byte
	test cx, 1
	mov cl, 4  ; preparing for the byte shifting
	jz byte_to_hex
	; multiply number by 16 (zero high bytes)
	shl dl, cl
	
byte_to_hex:
	; divide number by 16 (for both high and low byte conversions)
	shr dl, cl
	cmp dl, 9
	jg extended_hex_digit
	add dl, '0'
	jmp end_unsigned_hex_digit_conversion
extended_hex_digit:
	sub dl, 10
	add dl, 'A'
end_unsigned_hex_digit_conversion:
	mov ah, 02h
	int 21h
	
	mov cx, iterations_left
	loop print_unsigned_hex_digit
	
	call print_newline
	
	ret
print_unsigned_hex endp


print_unsigned_bin proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	mov dx, offset binary_number_output_prompt
	mov ah, 09h
	int 21h
	
	call fill_binary_string_buffer
	
	mov ah, 09h
	mov dx, offset binary_string
	int 21h
	
	call print_newline
	
	ret
print_unsigned_bin endp


print_signed_dec proc near
	; LINK DS WITH DATA SEGMENT
	mov ax, DATASEG
	mov ds, ax
	
	; PRINT PROMPT
	mov dx, offset decimal_number_output_prompt
	mov ah, 09h
	int 21h
	
	call fill_decimal_string_buffer
	
	mov ah, 09h
	mov dx, offset decimal_string
	int 21h
	
	call print_newline
	
	ret
print_signed_dec endp


CODESEG ENDS
END

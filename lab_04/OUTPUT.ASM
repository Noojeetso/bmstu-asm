PUBLIC print_newline
PUBLIC print_matrix

EXTRN matrix_max_rows: byte
EXTRN matrix_max_columns: byte
EXTRN matrix_rows: byte
EXTRN matrix_columns: byte
EXTRN matrix_data: byte

DATASEG SEGMENT PARA PUBLIC 'DATA'
	empty_matrix_output_prompt DB 'Output matrix is empty'
	DB 13
	DB 10
	DB '$'
	matrix_output_prompt DB 'Output matrix:'
	DB 13
	DB 10
	DB '$'
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, DS:DATASEG


print_newline proc far
	mov ah, 02h
	mov dl, 10
	int 21h
	
	mov dl, 13
	int 21h
	
	ret
print_newline endp


print_space proc far
	mov ah, 02h
	mov dl, ' '
	int 21h
	
	ret
print_space endp


print_matrix proc far	
	mov ax, DATASEG
	mov ds, ax
	
	; check if matrix is empty
	cmp matrix_columns, 0
	je print_empty_matrix
	
	cmp matrix_rows, 0
	je print_empty_matrix
	
	; at this point matrix is not empty
	mov dx, offset matrix_output_prompt
	mov ah, 09h
	int 21h
	
	xor cx, cx
	mov cl, matrix_rows
	
	mov si, 0  ; row offset in bytes from the beginning of the matrix
	
print_loop:
	mov bx, 0  ; value index in the matrix row (offest in bytes)
	print_row_loop:
		; print current matrix value
		mov dl, matrix_data[si + bx]
		add dl, '0'
		mov ah, 02h
		int 21h
		
		call print_space
		
		inc bx
		
		; do a new iteration if it's not the last column
		cmp bl, matrix_columns
		jne print_row_loop
	
	call print_newline
	
	; shift row offset by matrix_max_columns bytes to access a new row
	xor ax, ax
	mov al, matrix_max_columns
	add si, ax
	
	loop print_loop
	
	ret
	
print_empty_matrix:
	mov dx, offset empty_matrix_output_prompt
	mov ah, 09h
	int 21h
	
	ret
print_matrix endp


CODESEG ENDS
END

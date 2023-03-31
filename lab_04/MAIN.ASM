PUBLIC matrix_max_rows
PUBLIC matrix_max_columns
PUBLIC matrix_rows
PUBLIC matrix_columns
PUBLIC matrix_data

EXTRN read_matrix: far
EXTRN print_matrix: far
EXTRN delete_column_with_max_zeros: far

STACKSEG SEGMENT PARA STACK 'STACK'
	DB 200h DUP(?)
STACKSEG ENDS

DATASEG SEGMENT PARA PUBLIC 'DATA'
	matrix_max_rows DB 9
	matrix_max_columns DB 9
	matrix_rows DB 0
	matrix_columns DB 0
	matrix_data DB 9 * 9 DUP(0)
DATASEG ENDS

CODESEG SEGMENT para public 'CODE'
	ASSUME CS:CODESEG, SS:STACKSEG, DS:DATASEG
main:
	mov ax, DATASEG
	mov ds, ax
	
	call read_matrix
	
	; check for error input
	cmp ax, 0
	jne program_end
	
	call delete_column_with_max_zeros
	
	call print_matrix

program_end:
	mov ah, 'L'
	int 21h
CODESEG ENDS
END main

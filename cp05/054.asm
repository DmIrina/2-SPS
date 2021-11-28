dseg segment
msg_01 db "Assembler AUTS",10,13,'$'
msg_02 db "Lab 05 (Lab 04(4) with macros)",10,13,'$'
msg_03 db "---------------------------",10,13,'$'
msg_err  db 10,13,"Incorrect input!$"
msg_over_err db "Size of array must be less than 100 elements total (rows*cols)",10,13,"set up default rows=3, cols=3",10,13,"$"
msg_cr 	  db 10,13,'$'
msg_input db 10,13,"> $"
msg_prompt_count db 10,13,"Enter size of array - rows, cols:",'$'
msg_prompt_find db "Enter element for find: $"
msg_prompt_fill_array db 10,13,"Fill array:",10,13,'row 0','$'
msg_no_elements db 0ah,0dh,'Array has not that element',10,13,'$'
msg_has_elements db 0ah,0dh,'Element is present ','$'
msg_ones db ' one(s)',0ah,0dh,'$'
msg_row db "row $"
msg_col db " col $"

len = 0
maxlen  = 6		; buf
buf  db maxlen,len,maxlen DUP ('$')	; 

max_len_array equ 100		; определить константу - размерность массива
len_array dw 10		; определить константу - макс размерность массива
array dw max_len_array dup ('$')
foundtime db ? ;количество найденных элементов

rows db 5		; 
cols db 2		; 
elem dw 3	 ;элемент для поиска

include macros4.asm

dseg ends

sseg segment
sseg ends

cseg segment
assume cs:cseg, ss:sseg, ds:dseg

main proc far

; ініціалізація DS
   mov ax, dseg
   mov ds, ax

   introduction msg_01, msg_02, msg_03
   input_param   
   input_array

   xor si,si   
   mov cx,len_array ; всего чисел
   
@@loop_num: ; цикл 
   
   mov bx, array[si]   
   cmp bx, elem
   ;если текущий совпал с искомым, то переход на found для обработки,
   ;иначе продолж поиск
   je @@found
@@found_ret:   
   inc si
   inc si	; слово - через байт
loop @@loop_num
   jmp exit
   
@@found:
   push ax
   push bx
   push cx
   push dx
   
   xor dx, dx   
   mov ax, si
   mov bx, 2
   div bx			; ax = si/2
   xor bx, bx
   mov bl, cols   
   div bx		; ah = si%*col     al = si / col
				; dx - залишок від ділення слів - col
   mov bx, ax	; bx = ax - ціле від ділення - row
   print_cr
   push dx
   print msg_row
   out_int bx
   
   mov ah,09h
   mov dx,offset msg_col
   int 21h   
   pop ax		; из стека то что сохраняли dx
   out_int ax
   
   inc foundtime ;иначе увеличиваем счётчик совпавших   
   pop dx
   pop cx   
   pop bx
   pop ax   
   jmp @@found_ret

exit:   
   cmp foundtime,0h ;сравнение числа совпавших с 0
   ja eql ;если больше 0, то переход
not_equal: ;нет элементов, совпавших с искомым
   
   print msg_no_elements 
   jmp exit2 ;на выход
eql: ;есть элементы, совпавшие с искомым
    print msg_has_elements
	xor ax,ax
	mov al, foundtime
	out_int ax
    print msg_ones
	
exit2: ;выход
   mov ax,4c00h ;стандартное завершение программы
   int 21h

main endp

cseg ends
end main


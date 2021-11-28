dseg segment
msg_01 db "Assembler AUTS",10,13,'$'
msg_02 db "Lab 04 Task 4",10,13,'$'
msg_03 db "---------------------------",10,13,'$'
msg_err  db 10,13,"Incorrect input!$"
msg_over_err db "Size of array must be less than 100 elements total (rows*cols)",10,13,"set up default rows=3, cols=3",10,13,"$"

msg_cr 	  db 10,13,'$'
msg_tab   db '  $'
msg_input db "> $"

msg_prompt_count db 10,13,"Enter size of array - rows, cols:",10,13,'$'
msg_prompt_find db "Enter element for find: $'
msg_prompt_fill_array db 10,13,"Fill array:",10,13,'row 0',10,13,'$'
msg_max db 10,13,"Max element = ",10,13,'$'
msg_sum db 10,13,"Sum elements = ",10,13,'$'

msg_unsorted_array DB "Unsorted array",10,13,'$'
msg_sorted_array DB 10,13,"Sorted array",10,13,'$'
msg_failed db 0ah,0dh,'Array has not that element',10,13,'$'
msg_success db 0ah,0dh,'Element is present ','$'

msg_row db "row $"
msg_col db " col $"

len = 0
maxlen  = 6		; buf

buf  db maxlen,len,maxlen DUP ('$')	; 
max_len_array equ 100		
len_array dw 10		
array dw max_len_array dup ('$')

rows db 0		; кільк строк
cols db 0		; кільк стовбців
elem dw 0	    ; елемент для пошуку

foundtime db 0 ;количество найденных элементов
msg_fnd db ' one(s)',0ah,0dh,'$'

dseg ends

sseg segment
sseg ends

cseg segment
assume cs:cseg, ss:sseg, ds:dseg

main proc

push bp
push ds
push ax

; ініціалізація DS
mov ax, dseg
mov ds, ax

call introduction   
call input_param		    ; rows, cols, elem 
call input_array			; rows х cols
   
xor ax,ax
xor si,si   
xor bx,bx

mov al, cols
mul rows
mov cx,ax 					; всего чисел
   
; ----------------------- пошук елемента в масиві
   
@@loop_num: 				; цикл 
   
   mov dx, array[si]
   cmp dx, elem
							;если текущий совпал с искомым, то переход на found для обработки,
							;иначе продолж поиск
   je @@found
@@found_ret:   
   inc si
   inc si					; слово - через байт
   inc bx 					; № elem
   jcxz exit 				; если CX==0 --> exit
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
   div bx					; ax = si/2
   xor bx, bx
   mov bl, cols   
   div bx					; dx = si%cols    ==> N col - залиш від ділення  
							; ax = si / cols  ==> N row - ціле  від ділення 
   call print_cr
   push dx
   mov dx,offset msg_row
   call print
   call out_int
      
   mov dx,offset msg_col
   call print
   
   pop ax					; из стека то что сохраняли dx (N col)
   call out_int
   
   inc foundtime			;иначе увеличиваем счётчик совпавших
   pop dx
   pop cx   
   pop bx
   pop ax   
   jmp @@found_ret
exit:   
   cmp foundtime,0h 		;сравнение числа совпавших с 0
   ja eql 					;если больше 0, то переход
not_equal: 					;нет элементов, совпавших с искомым
   
   mov dx,offset msg_failed
   call print
   jmp exit2 				;на выход
eql: 						;есть элементы, совпавшие с искомым
   
    mov dx,offset msg_success
    call print
	xor ax,ax
	mov al, foundtime
	call out_int   
    mov dx,offset msg_fnd
    call print
	
exit2:						;выход
   mov ax,4c00h 			;стандартное завершение программы
   int 21h

pop ax
pop ds
pop bp

main endp

;-----------------------------------------------------------------------------------
;выводит знаковое 16-разрядное число из регистра AX на экран
;-----------------------------------------------------------------------------------
; на входе: 	ax - число для отображения 
; на выходе:  	число на экране
proc out_int
	push bx
	push cx
	push ax
	push dx
        mov     bx,     10      ;основание системы счисления (делитель)
        xor     cx,     cx      ;количество символов в модуле числа
        or      ax,     ax      ;для отрицательного числа
        jns     @@divide
                neg     ax      ;поменять знак (сделать положительным)
                push    ax      ;и вывести на экран символ "-" (минус)
                mov     ah,     02h
                mov     dl,     '-'
                int     21h
                pop     ax
        @@divide:               ;делим число на 10
                xor     dx,     dx
                div     bx
                push    dx      ;остаток сохраняем в стеке
                inc     cx      ;количество цифр в числе
                or      ax,     ax
        jnz     @@divide        ;повторяем, пока в числе есть цифры
        mov     ah,     02h		; вывод символа (int 21h в цикле)
        @@store:
                pop     dx      ;извлекаем цифры (остатки от деления на 10) из стека
                add     dl,     '0'     ;преобразуем в символы цифр
                int     21h     ;и выводим их на экран
        loop    @@store
	pop dx
	pop ax
	pop cx
	pop bx	
	ret
endp out_int

;-----------------------------------------------------------------------------------
proc input_int				; Ввод числа x в виде строки,   на выходе ax - число	
	push si
    lea     dx,msg_input	; печать msg_input (dx)
	call 	print			; [dx] -->  на экран
    mov     ah,0ah		    ; Ввод строки в buf
    lea     dx,buf		    
    int     21h
	call print_cr		    ; \n	
	call string_to_int		;Преобразование строки buf в число	
	pop si
endp input_int

;-----------------------------------------------------------------------------------
; на входе: buf - строка (буфер): 0-й - размер буфера, 1-й - колич введенных символов, 2-й - .... - символы для преобразования 
; на выходе:  	ax - число 
proc string_to_int			; преобразовывает строку цифр в число 
	push bx
	push dx
	push cx
	push di
	push si
    xor ax,ax                   ;обнуляется регистр
    lea di,buf+2                ;di - индексный регистр - указывает на строку с цифрами
    lea bx,buf+1				;в bx адрес второго элемента буфера 
    mov cx,[bx]   			 	;в cx количество введенных символов - длина строки
    xor ch,ch        		    ;обнуляется регистр	        
    mov si,10                   ;si содержит множитель 10
    xor bh,bh                   ;обнуляется регистр
	mov dl,[di]
	push dx
	cmp dl,'-'  				;Это '-'?
	jne @@start_loop     		;Нет - перейти на обработку.
	inc di                      ;инкремент di - пропустить "-1"
	dec cx						;в циклі на 1 цифру менше
					
@@start_loop:		                ; ----- цикл1
    mul     si                      ;умножить ax на si(10)
    mov     bl,[di]                 ;к произвдению добавить число
    cmp     bl, 30h                 ;сравнение
    jl      @@common_err            ;если меньше
    cmp     bl, 39h                 ;сравнение
    jg      @@common_err            ;если больше
    sub     bl,30h                  ;отнять 30h
    add     ax,bx                   ;добачить число к сумме ax
    inc     di                      ;инкремент di
    loop    @@start_loop            ;повтор цикла
	pop 	dx
	cmp 	dl,'-'  				;Это '-'?
	jne 	@@positiv     			;Нет - 
	neg 	ax      				;Да - сменить знак числа.	

@@positiv:	
	pop si
	pop di
	pop cx
	pop dx
	pop bx
	ret

@@common_err:			   		    ; общие ошибки ввода
	mov ah,9h
	lea dx,msg_err
	int 21h
	mov ax,4C00h
	int 21h	

endp string_to_int


;-----------------------------------------------------------------------------------
proc print							;Вывод строки [dx] на экран (без cr)
	push	ax
	mov     ah,9h
    int     21h
	pop 	ax	
	ret
endp print

;-----------------------------------------------------------------------------------
proc print_cr			    	   ; \n
	push	ax
	push	dx
	mov     ah,9h
	lea     dx,msg_cr
    int     21h
	pop 	dx	
	pop 	ax	
	ret
endp print_cr

;-----------------------------------------------------------------------------------
proc introduction					; Вывод условия и приглашения
    mov     ah,9h
    lea     dx,msg_01
    int     21h
    lea     dx,msg_02
    int     21h
    lea     dx,msg_03
    int     21h
	ret
endp introduction

;-----------------------------------------------------------------------------------
; на вих.     rows, cols, len_arr - длина массива
proc input_param
   push dx   
   push ax
   
   lea dx, msg_prompt_find		; пошуковий елемент
   call print
   call input_int
   mov [elem], ax
      
   lea dx, msg_prompt_count
   call print    
   call input_int				; rows
   mov [rows], al
   call input_int				; cols
   mov [cols], al
   mul rows	                    ; ax = rows*cols
   mov len_array, ax			; len_array = rows*cols
   cmp ax, max_len_array        ; сравнение введенных чисел с макс для предотвращения переполнения
   jg @@over_err                ; len_array > max_len_array (100)
   
@@L2:   
   pop ax
   pop dx
   ret

@@over_err:						; спроба встановити розмір масиву більше ніж зарезервовано    
   lea dx, msg_over_err
   call print
   mov [rows],3					; set default rows=3
   mov[cols],3					;             cols=3   
   mov [len_array],9
   jmp @@L2
endp input_param

;-----------------------------------------------------------------------------------
; на вих.     array - заповнений введеними елементами
proc input_array					; заповнює масив введеними з клавіатури значеннями
   push dx   
   push bx   
   push ax 

   lea dx, msg_prompt_fill_array	; запрошення до вводу елементів масиву
   call print
   xor si,si						
   xor bx,bx						
   mov cx, len_array

@@loop_input:
   call input_int
   mov array[si], ax
   inc si
   inc si
   inc bx				; індекс одномірного масиву
   
   mov ax,bx
   xor dx,dx
   div cols				; al = bx / cols - ціле    - № рядка
						; ah = bx % cols - залишок - № колонки
   cmp ah,0
   je @@next_row    	; ah == 0 - новий рядок
@@next_inp:
   loop @@loop_input
   
@@ex:  
  pop ax
   pop bx
   pop dx
   ret
@@next_row:
   call print_cr
   cmp bx, len_array	; останній елемент масиву?
   je @@ex     			; если bx==len_array --> exit ("row" not display)
   
   mov dx,offset msg_row
   call print
   xor ah,ah			; залишити в ах тільки № рядка
   call out_int			; № рядка
   call print_cr   
   jmp @@next_inp   
   
endp input_array

cseg ends
end main


;-----------------------------------------------------------------------------------
introduction MACRO msg_1, msg_02, msg_03			; introduction - Вывод условия и приглашения
    mov     ah,9h
    lea     dx,msg_01
    int     21h
    lea     dx,msg_02
    int     21h
    lea     dx,msg_03
    int     21h
ENDM introduction

;-----------------------------------------------------------------------------------
print_cr MACRO			       ; \n
	push	ax
	push	dx
	mov     ah,9h
	lea     dx,msg_cr
    int     21h
	pop 	dx	
	pop 	ax		
ENDM print_cr

;-----------------------------------------------------------------------------------
print MACRO msg					;Вывод строки [dx] на экран (без cr)
	push ax
	mov ah,9h
	lea dx,msg
    int 21h
	pop ax		
ENDM print

;-----------------------------------------------------------------------------------
;out_int выводит знаковое 16-разрядное число из регистра AX на экран
;-----------------------------------------------------------------------------------
; на входе: 	num - число для отображения 
; на выходе:  	число на экране
out_int MACRO num
   LOCAL divide, store
   push bx
   push cx
   push ax
   push dx
   mov ax, num   
   mov     bx,     10      ;основание системы счисления (делитель)
   xor     cx,     cx      ;количество символов в модуле числа
   or      ax,     ax      ;для отрицательного числа
   jns     divide
   neg     ax      		   ;поменять знак (сделать положительным)
   push    ax    		   ;и вывести на экран символ "-" (минус)
   mov     ah,     02h
   mov     dl,     '-'
   int     21h
   pop     ax
divide:                    ;делим число на 10
   xor     dx,     dx
   div     bx
   push    dx     		   ;остаток сохраняем в стеке
   inc     cx     		   ;количество цифр в числе
   or      ax,     ax
   jnz     divide          ;повторяем, пока в числе есть цифры
   mov     ah,     02h	   ; вывод символа (int 21h в цикле)
store:
   pop     dx      		   ;извлекаем цифры (остатки от деления на 10) из стека
   add     dl,     '0'     ;преобразуем в символы цифр
   int     21h    		   ;и выводим их на экран
   loop    store
   pop dx
   pop ax
   pop cx
   pop bx		
ENDM out_int

;-----------------------------------------------------------------------------------
input_int MACRO buf, msg_input	; Ввод числа x в виде строки,   на выходе ax - число	
	push si
	print msg_input		   	    ; \n	
    mov     ah,0ah		        ; Ввод строки в buf
    lea     dx,buf	
    int     21h	
;	print_cr		 		    ; \n	
	string_to_int buf		    ;Преобразование строки buf в число	
	pop si
ENDM input_int



;-----------------------------------------------------------------------------------
; на входе: buf - строка (буфер): 0-й - размер буфера, 1-й - колич введенных символов, 2-й - .... - символы для преобразования 
; на выходе:  	ax - число 
string_to_int MACRO buf			; преобразовывает строку цифр в число 
   LOCAL @@start_loop, @@positiv, @@common_err, @@ret3
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
	jne @@start_loop    	 	;Нет - перейти на обработку.
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
	jmp @@ret3

@@common_err:			 	      ; общие ошибки ввода
	print msg_err
	mov ax,4C00h
	int 21h	
@@ret3:
ENDM string_to_int


;-----------------------------------------------------------------------------------
; на вих.     rows, cols, len_array - длина массива
input_param MACRO
LOCAL @@L2, @@over_err
   push dx   
   push ax

   print msg_prompt_find
   input_int buf, msg_input
   mov [elem], ax
   print msg_prompt_count
   input_int buf, msg_input
   mov [rows], al
   input_int buf, msg_input
   mov [cols], al
   mul rows	                    ; ax = rows*cols
   mov len_array, ax
   cmp  ax, max_len_array       ;сравнение введенных чисел с макс для предотвращения переполнения
   jg @@over_err                ;если больше
   
@@L2:   
   pop ax
   pop dx   
   jmp @@end_ip

@@over_err:						; спроба встановити розмір масиву більше ніж зарезервовано
   mov ah,9h
   lea dx, msg_over_err
   int 21h
   mov [rows],3					; set default rows=3
   mov[cols],3					; cols=3   
   mov [len_array],9
   jmp @@L2

@@end_ip:
ENDM input_param

;-----------------------------------------------------------------------------------
; на вих.     array - заповнений введеними елементами
input_array	MACRO				; заповнює масив введеними з клавіатури значеннями
   push dx   
   push bx   
   push ax 

   lea dx, msg_prompt_fill_array	; запрошення до вводу елементів масиву
   mov ah, 9 
   int 21h  
   xor si,si
   xor bx,bx
   mov cx, len_array
@@loop_input:   
   input_int buf, msg_input
   mov array[si], ax
   inc si
   inc si   
   inc bx					; індекс одномірного масиву   
   mov ax,bx
   xor dx,dx
   div cols					; al = bx / cols - ціле    - № рядка
							; ah = bx % cols - залишок - № колонки
   cmp ah,0
   je @@next_row    		; dx == 0
@@next_inp:
   loop @@loop_input   
@@ex:  
   jmp @@end_ia
@@next_row:
   print_cr
   cmp bx, len_array
   je @@ex     				 ; если bx==len_array --> exit ("row" not display)
   print msg_row
   xor ah,ah
   out_int ax
   jmp @@next_inp
@@end_ia:
   pop ax
   pop bx
   pop dx
ENDM input_array

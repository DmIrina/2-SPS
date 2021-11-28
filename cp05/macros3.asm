;-----------------------------------------------------------------------------------
print MACRO msg					;вивід строки [dx] на екран (без cr)
	push ax
	mov ah,9h
	lea dx,msg
    int 21h
	pop ax		
ENDM print

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

introduction MACRO msg_1, msg_02, msg_03 ; introduction - Вывод условия и приглашения
	print msg_01
	print msg_02
	print msg_03
ENDM introduction


; -------------------------------------------------------------------------------------------------------
; string_to_int - строка цифр у число 

; на вхід: buf - строка (буфер): 
; 0-й байт - розмір буферу, 1-й - кількість введених символів
; 2-й - .... - символи для перетворення 						
; на вихід: число з ах

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
    mov cx,[bx]    				;в cx количество введенных символов - длина строки
    xor ch,ch       		    ;обнуляется регистр	        
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
	jmp @@ret3

@@common_err:			    	   ; общие ошибки ввода
	print msg_err
	mov ax,4C00h
	int 21h	
@@ret3:
ENDM string_to_int


;-----------------------------------------------------------------------------------
input_int MACRO buf, msg_input		; введення числа (ціле зі знаком), результат - в ax
	push si
	print msg_input		  	        ; \n	
    mov     ah,0ah		   			; Ввод строки в buf
    lea     dx,buf		
    int     21h	
	print_cr		   				; \n	
	string_to_int buf				;Преобразование строки buf в число	
	pop si
ENDM input_int


; out_int виведення знакового 16-розрядного числа з AX на екран
; вхід: 	num - число для отображения 
; вихід:  	число на екрані

out_int MACRO num
   LOCAL @@divide, @@store
   push bx
   push cx
   push ax
   push dx
   mov ax, num   
   mov     bx,     10      ;основание системы счисления (делитель)
   xor     cx,     cx      ;количество символов в модуле числа
   or      ax,     ax      ;для отрицательного числа
   jns     @@divide
   neg     ax      		   ;поменять знак (сделать положительным)
   push    ax     		   ;и вывести на экран символ "-" (минус)
   mov     ah,     02h
   mov     dl,     '-'
   int     21h
   pop     ax
@@divide:                  ;делим число на 10
   xor     dx,     dx
   div     bx
   push    dx    		   ;остаток сохраняем в стеке
   inc     cx    		   ;количество цифр в числе
   or      ax,     ax
   jnz     @@divide        ;повторяем, пока в числе есть цифры
   mov     ah,     02h	   ; вывод символа (int 21h в цикле)
@@store:
   pop     dx      		   ;извлекаем цифры (остатки от деления на 10) из стека
   add     dl,     '0'     ;преобразуем в символы цифр
   int     21h     		   ;и выводим их на экран
   loop    @@store
   pop dx
   pop ax
   pop cx
   pop bx		
ENDM out_int


; обчислення значення функції

; на вхід:	x, y
; на вихід: ax - z

func_z MACRO x, y 
LOCAL @@verr, @@over, @@v2, @@v3, @@endf
;	xor	ax, ax
    mov ax,x
	mov cx,y
	cmp bx, 0
        jl @@v2			; якщо менше 35x^2+8x
	cmp bx, 10
        jg @@v3    		; якщо більше (10-x)^2
	cmp	bx, cx	
	je	@@verr			; якщо x=y		
	print msg_v1
	mov ax, bx			; ax = x
	sub ax, cx			; ax = x - y
	imul cx				; ax = (x-y)*y
	jo	@@over			; флаг of==1 - переповнення
	mov cx, ax			; dx = (x-y)*y
	mov ax, 15
	imul bx				; ax = 15x
	sub ax, 1
	xor dx, dx
	idiv cx	
	jmp @@endf

@@verr:	
	print msg_verr
	mov ax,4C00h
	int 21h	
        		
; переповнення
      		
@@over:
	mov ah, 9h
	lea dx, msg_over
	int 21h
	mov ax, 4C00h
	int 21h	

@@v2:	
	print msg_v2
	mov ax, 35
	imul bx				; 35x
	imul bx				; 35*x*x
	jo	@@over			; флаг of == 1 - переповнення
	mov cx, ax
	mov ax, 8
	jo	@@over			; флаг of == 1 - переповнення
	imul bx
	add ax, cx	
	jmp @@endf

@@v3:	
	print msg_v3
	mov ax, 10
	sub ax, bx
	imul ax
	jo	@@over			; флаг of==1 - переповнення
	
@@endf:
ENDM func_z
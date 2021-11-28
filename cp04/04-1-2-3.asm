dseg segment
msg_01 db "Assembler AUTS",10,13,'$'
msg_02 db "Lab 04",10,13,'$'
msg_03 db "---------------------------",10,13,'$'
msg_err  db 10,13,"Incorrect input!$"
msg_over_err db "Size of array must be less than max_len_array and set up = $"

msg_cr 	  db 10,13,'$'
msg_input db "> $"

msg_prompt_count db "Enter size of array:",10,13,'$'
msg_prompt_fill_array db 10,13,"Fill array:",10,13,'$'
msg_max db 10,13,"Max element = ",10,13,'$'
msg_sum db 10,13,"Sum elements = ",10,13,'$'

msg_unsorted_array DB "Unsorted array",10,13,'$'
msg_sorted_array DB 10,13,"Sorted array",10,13,'$'

len = 0
maxlen  = 5		; buf

buf  db maxlen,len,maxlen DUP ('$')	; 
max_len_array equ 20															; визначити константу - розмірність масиву
len_arr dw 10																	

mas dw max_len_array dup ('$')
tmp dw 0

dseg ends

sseg segment
sseg ends

cseg segment
assume cs:cseg, ss:sseg, ds:dseg

main proc

push ds
sub ax, ax
push ax

; ініціалізація DS
mov ax, dseg
mov ds, ax


call introduction
call input_len_arr
call input_mas
	
; вивід на екран заголовку масиву 
LEA DX, msg_unsorted_array 													; ефективна адреса (зміщення) msg_unsorted_array
call print
call out_array	     														; вивiд невідсортированого масиву   

; ------------------------- завдання 2
call print_msg_max
call find_max
call out_int

; ------------------------- завдання 1
call print_msg_sum
call sum_arr
call out_int	   

; ------------------------- завдання 3
; вивід на екран заголовку масиву 
LEA DX, msg_sorted_array 	
call print
call sort_arr
call out_array 
   
mov ax,4c00h
int 21h

main endp

;-----------------------------------------------------------------------------------
; на вхід: 	mas - массив, на вих.  mas - відсортований масив
proc sort_arr		;  SORT array
   mov cx,len_arr
   dec cx			; сх--
@@big:
   push cx
   xor si,si
@@cycle:
   mov ax,mas[si]
   cmp ax,mas[si+2]
   jl @@less				; mas[si] < mas[si+2]
   mov bx,mas[si]
   mov tmp,bx				; tmp = mas[si] (через bx)
   mov bx,mas[si+2]
   mov mas[si],bx
   mov bx, tmp
   mov mas[si+2],bx
     
@@less:
   inc si
   inc si
   loop @@cycle
   pop cx					; 2 цикла --> cx зберігаємо в стеку та відновлюемо для зовнішнього циклу (@@big)
   loop @@big
   ret
endp sort_arr


;-----------------------------------------------------------------------------------
; на вхід: 						mas - масив
; 								cx - довжина массива
proc out_array					; вивід масиву, разділяючи елементи " " 
   push cx
   mov cx, len_arr
   mov si, 0 					; (source index register) – індекс джерела;
show_next:               
   mov ax, mas[si] 
   call out_int
   mov ah, 02h 					; " " 
   mov dl, ' ' 	    			; вивід символа з dl на дисплей
   int 21h
   add si, 2 					; si = si+2
   loop show_next   
   pop cx
   ret
endp out_array


;-----------------------------------------------------------------------------------
; на вих.     len_arr - длина массива
proc input_len_arr					
   push dx   
   push ax
   
   lea dx, msg_prompt_count 
   mov ah, 9 
   int 21h  
    
   call input_int
   mov [len_arr], ax			; len_arr = ax
   cmp  ax, max_len_array       ; ax > max_len_array (передбачення переповнення)
   jg   @@over_err              ; якщо більше
   
@@L2:   
   pop ax
   pop dx
   ret

@@over_err:						; спроба встановити розмір масиву більше ніж зарезервовано
   mov ah,9h
   lea dx, msg_over_err
   int 21h
   mov ax, max_len_array
   mov [len_arr], ax			; len_arr = max_len_array
   call out_int	
   jmp @@L2

endp input_len_arr


;-----------------------------------------------------------------------------------
; на вих.     mas - заповнений введеними елементами
proc input_mas						; заповнює масив введеними з клавіатури значеннями
   push dx   
   push ax 

   lea dx, msg_prompt_fill_array	; запрошення до вводу елементів масиву
   call 	print					; [dx] -->  на экран

   xor si,si
   mov cx, len_arr					; cx - лічильник кільк. елементів масиву

@@loopinput:
   call input_int
   mov mas[si], ax
   inc si
   inc si
   loop @@loopinput		; cx--

   pop ax
   pop dx
   ret
endp input_mas

;-----------------------------------------------------------------------------------
; на вхід: 	mas - масив, len_arr - довжина масива
; на вих.   ax - max
proc find_max					; знаходить максимальне значення масиву
   push cx
   push si
   mov cx, len_arr
   dec cx						; порівнянь на 1 менше ніж елементів
   
   mov si, 0 					; (source index register) – індекс джерела;
   mov ax, mas[si]
   add si, 2
@@show_next:              		; вивід значень елементів початкового масиву на екран 
   cmp mas[si], ax			
   jg      @@local_max    	 	; mas[si] > ax
@@cont:	
   add si, 2 
   loop @@show_next  		    ; сх--
   pop si						; коли сх==0
   pop cx
   ret
@@local_max:
   mov ax, mas[si]				; запамятати локальний макс
   jmp @@cont
endp find_max


;-----------------------------------------------------------------------------------
; на вхід: 	mas - масив, на вих.      ax - max
proc sum_arr					; знаходить sum
   push cx 
   mov cx, len_arr
   xor ax, ax
   mov si, 0 					; (source index register) – индекс источника;
@@sum_arr_next:                 
   add ax, mas[si]
   add si, 2
   loop @@sum_arr_next   
   pop cx
   ret
endp sum_arr

;-----------------------------------------------------------------------------------
;ПРОЦЕДУРА out_int выводит знаковое 16-разрядное число из регистра AX на экран
;-----------------------------------------------------------------------------------
; на входе: 	ax - число для отображения 
; на выходе:  	число на экране
proc out_int
	push cx
        mov     bx,     10      ;основание системы счисления (делитель)
        xor     cx,     cx      ;количество символов в модуле числа
        or      ax,     ax      ;для отрицательного числа
        jns     @@divide
                neg     ax      ;поменять знак (сделать положительным)
                push    ax      ;вывести на экран символ "-" (минус)
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
                add     dl,'0'  ;преобразуем в символы цифр
                int     21h     ;и выводим их на экран
        loop    @@store
	pop cx
	ret
endp out_int


;-----------------------------------------------------------------------------------
proc input_int				; ввід числа x як строки,   на виході ax - число	
	push si
    lea     dx,msg_input	; вивести msg_input (dx)
	call 	print			; [dx] -->  на екран
    mov     ah,0ah		    ; ввід строки в buf
    lea     dx,buf		    
    int     21h
	call print_cr		    ; \n	
	call string_to_int		; перетворення строки buf в число
	pop si
endp input_int

;-----------------------------------------------------------------------------------
; на входе: buf - строка (буфер): 0-й - размер буфера, 1-й - колич введенных символов, 2-й - .... - символы для преобразования 
; на выходе:  	ax - число 
proc string_to_int				; преобразовывает строку цифр в число 
	push bx
	push dx
	push cx
	push di
	push si
    xor ax,ax                   ; обнуляється регістр
    lea di,buf+2             	; di - индексный регистр - указывает на строку с цифрами
    lea bx,buf+1				;в bx адрес второго элемента буфера 
    mov cx,[bx]    				;в cx количество введенных символов - длина строки
    xor ch,ch           		;обнуляется регистр	        
    mov si,10                   ;si содержит множитель 10
    xor bh,bh                   ;обнуляется регистр
	mov dl,[di]
	push dx
	cmp dl,'-'  				;Это '-'?
	jne @@start_loop     		;Нет - перейти на обработку.
	inc di                      ;инкремент di - пропустить "-1"
	dec cx						;в циклі на 1 цифру менше
					
@@start_loop:		            ; ----- цикл1
    mul     si                  ;умножить ax на si(10)
    mov     bl,[di]             ;к произвдению добавить число
    cmp     bl, 30h             ;сравнение
    jl      @@common_err        ;если меньше
    cmp     bl, 39h             ;сравнение
    jg      @@common_err        ;если больше
    sub     bl,30h              ;отнять 30h
    add     ax,bx               ;добачить число к сумме ax
    inc     di                  ;инкремент di
    loop    @@start_loop        ;повтор цикла
	pop 	dx
	cmp 	dl,'-'  			;Это '-'?
	jne 	@@positiv     		;Нет - 
	neg 	ax      			;Да - сменить знак числа.	

@@positiv:	
	pop si
	pop di
	pop cx
	pop dx
	pop bx
	ret

@@common_err:			       ; общие ошибки ввода
	mov ah,9h
	lea dx,msg_err
	int 21h
	mov ax,4C00h
	int 21h	

endp string_to_int

;-----------------------------------------------------------------------------------
proc introduction			 ; вивід умови й запрошення
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
proc print_msg_max
    mov     ah,9h
    lea     dx,msg_max
    int     21h
	ret
endp print_msg_max
;-----------------------------------------------------------------------------------

proc print_msg_sum
    mov     ah,9h
    lea     dx,msg_sum
    int     21h
	ret
endp print_msg_sum

;-----------------------------------------------------------------------------------
proc print					; вивід строки [dx] на екран (без cr)
	push	ax
	mov     ah,9h
    int     21h
	pop 	ax	
	ret
endp print

;-----------------------------------------------------------------------------------
proc print_cr			       ; \n
	push	ax
	push	dx
	mov     ah,9h
	lea     dx,msg_cr
    int     21h
	pop 	dx	
	pop 	ax	
	ret
endp print_cr

cseg ends
end main

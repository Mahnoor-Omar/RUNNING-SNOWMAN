[org 0x0100]
jmp start11

main_msg: dw "THE RUNNING SNOWMAN"
dot: db '.'
dash: db '_'
brcket_open: db '('
brcket_close: db ')'
colon: db ':'
comma: db ','

buffer db 0, 0 ; Buffer to store character and attribute (2 bytes)

print_main:
    push ax
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    mov bx, 0
    mov ah, 0x07
    mov di, 3
    imul di, 80
    add di, 30
    shl di, 1

loopThis:
    mov al, [si+bx]
    mov [es:di], ax
    add bx, 1
    add di, 2
    cmp al, 0
    jne loopThis

    pop di
    pop cx
    pop ax
    ret

make_snowman1:
    push ax
    push cx
    push di
    push dx

    mov ax, 0xb800
    mov es, ax
    mov ah, 0x07
    mov di, 21
    imul di, 80
    add di, 10
    shl di, 1
    mov dx, 2

loop11:
    mov al, [brcket_open]
    mov [es:di], ax
    add di, 4
    mov al, [colon]
    mov [es:di], ax
    add di, 4
    mov al, [brcket_close]
    mov [es:di], ax
    sub di, 160
    sub di, 8
    sub dx, 1
    cmp dx, 0
    jne loop11

    mov al, [brcket_open]
    mov [es:di], ax
    add di, 2
    mov al, [dot]
    mov [es:di], ax
    add di, 2
    mov al, [comma]
    mov [es:di], ax
    add di, 2
    mov al, [dot]
    mov [es:di], ax
    add di, 2
    mov al, [brcket_close]
    mov [es:di], ax

    pop dx
    pop di
    pop cx
    pop ax
    ret

clearscreen1:
    push ax
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    mov ax, 0x0720
    mov cx, 2000
    xor di, di
    rep stosw

    pop di
    pop cx
    pop ax
    ret

makeGround1:
    push ax
    push cx
    push di

    mov ax, 0xb800
    mov es, ax
    mov ax, 0x7020
    mov cx, 240
    mov di, 22
    imul di, 80
    shl di, 1
    rep stosw

    pop di
    pop cx
    pop ax
    ret

make_bush1:
    push ax
    push cx
    push di
    push dx

    mov di, 160*20
    add di, dx
    mov cx, 2

draw_rows1:
    push cx
    mov cx, 5

draw_columns1:
    mov al,0x20
    mov ah, 0x20
    stosw
    loop draw_columns1
    add di, 160 - 10
    pop cx
    loop draw_rows1

    pop dx
    pop di
    pop cx
    pop ax
    ret

    start11:
    call wow1
    call clearscreen1
    call makeGround1
    call make_mountains1  ; Add mountains
    call make_snowman1
    mov dx, 57
    call make_bush1
    mov dx, 137
    call make_bush1
    mov si, main_msg
    call print_main
    call starrer


    ;mov ax, 0x4c00
    ;int 21h

wow1:
    push ax
    push cx
    push dx
    push di

    mov ah, 0x0B
    mov bh, 0
    mov bl, 15
    int 0x10

    mov cx, 80
    mov dx, 120

    mov ah, 0x0E
    mov si, welcome_message
print_welcome:
    lodsb
    cmp al, 0
    je next_line
    int 0x10
    call delay
    call delay
    call delay
    jmp print_welcome

next_line:
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10

    mov si, press_message
print_press:
    lodsb
    cmp al, 0
    je wait_for_p
    int 0x10
    call delay
    call delay
    jmp print_press

wait_for_p:
wait_key:
    mov ah, 0x00
    int 0x16
    cmp al, 'p'
    jne wait_key

end:
    call delay
    pop di
    pop dx
    pop cx
    pop ax
    ret

delay:
    mov cx, 0FFFFh
delay_loop:
    loop delay_loop
    ret

welcome_message db 'Welcome to THE RUNNING SNOWMAN game!', 0
press_message db 'Press "p" to continue...', 0

starrer:
    mov ax, 0xB800
    mov es, ax 

    mov di, (0 * 160) + (11 * 2)
    mov dx, 1

main_loop:
    mov al, [buffer]       ; Restore background character
    mov ah, [buffer+1]     ; Restore background attribute
    mov [es:di], ax        ; Write to the screen

    call move_snowflake

    mov al, '*'
    mov ah, 0x0F
    mov [es:di], ax        ; Write snowflake to new position

    call delay
    call delay
    call delay
    call delay
    call delay
   
    ; Add the ground scrolling effect here
    call scroll_ground

    jmp main_loop

move_snowflake:
    cmp dx, 1
    je move_down
    ret

move_down:
    add di, 160            ; Move down one row
    cmp di, 4000           ; Check if reached the bottom
    jl save_background
    call reset_position
    ret

save_background:
    mov ax, [es:di]        ; Save character and attribute
    mov [buffer], al
    mov [buffer+1], ah
    ret

reset_position:
    mov di, ((0 * 160) + 40) * 2
    mov ax, [es:di]
    mov [buffer], al
    mov [buffer+1], ah
    ret
make_mountains1:
    push ax
    push cx
    push di

    mov ax, 0xb800        ; Set video segment
    mov es, ax
    mov ah, 0x07          ; Attribute for white text (neutral color)
    
    ; First Mountain
    mov di, 14            ; Start at row 14
    imul di, 80           ; Calculate offset for row
    add di, 15            ; Move to column 15
    shl di, 1             ; Multiply by 2 (character and attribute)

    mov cx, 6             ; Height of the first mountain
draw_first_mountain:
    mov al, '/'           ; Draw left slope
    mov [es:di], ax
    sub di, 160           ; Move up one row
    inc di                ; Move one column to the right
    loop draw_first_mountain

    mov al, '^'           ; Draw peak
    mov [es:di], ax

    mov cx, 6             ; Right Slope
draw_first_slope:
    add di, 160           ; Move down one row
    inc di
    mov al, '\'
    mov [es:di], ax
    loop draw_first_slope

    ; Second Mountain
    add di, 20            ; Move to start of the second mountain
    mov cx, 5             ; Height of the second mountain
draw_second_mountain:
    mov al, '/'
    mov [es:di], ax
    sub di, 160
    inc di
    loop draw_second_mountain

    mov al, '^'
    mov [es:di], ax

    mov cx, 5
draw_second_slope:
    add di, 160
    inc di
    mov al, '\'
    mov [es:di], ax
    loop draw_second_slope

    ; Third Mountain
    add di, 30            ; Move to start of the third mountain
    mov cx, 7             ; Height of the third mountain
draw_third_mountain:
    mov al, '/'
    mov [es:di], ax
    sub di, 160
    inc di
    loop draw_third_mountain

    mov al, '^'
    mov [es:di], ax

    mov cx, 7
draw_third_slope:
    add di, 160
    inc di
    mov al, '\'
    mov [es:di], ax
    loop draw_third_slope

    ; Fourth Mountain
    add di, 25            ; Move to start of the fourth mountain
    mov cx, 4             ; Height of the fourth mountain
draw_fourth_mountain:
    mov al, '/'
    mov [es:di], ax
    sub di, 160
    inc di
    loop draw_fourth_mountain

    mov al, '^'
    mov [es:di], ax

    mov cx, 4
draw_fourth_slope:
    add di, 160
    inc di
    mov al, '\'
    mov [es:di], ax
    loop draw_fourth_slope

    pop di
    pop cx
    pop ax
    ret
    scroll_ground:
    push ax
    push bx
    push cx
    push di

    ; Set video segment
    mov ax, 0xb800
    mov es, ax

    ; Set starting position to the ground row
    mov di, 22         ; Ground row (line 22)
    imul di, 80        ; Offset for row 22
    shl di, 1          ; Multiply by 2 for video memory
    mov cx, 80         ; Number of characters in the row

    ; Save the first character to wrap around
    mov al, [es:di]
    mov ah, [es:di+1]  ; Save attribute byte
    push ax

    ; Scroll characters to the left
scroll_loop:
    mov bx, di
    add bx, 2          ; Next character position
    mov ax, [es:bx]
    mov [es:di], ax    ; Move character left
    add di, 2          ; Move to next character
    loop scroll_loop

    ; Restore the first character to the end
    pop ax
    mov [es:di], ax

    pop di
    pop cx
    pop bx
    pop ax
    ret
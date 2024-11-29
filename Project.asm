;Section 3J
;COAL Group 1
; Important note:
; parameter access will start from +4 since bp is pushed
; local variables access will start from -2
; I stored the screen in a buffer and the print it. This stopped the flickering
; make all the changes in buffer, and then use display_screen function to see the effects
[org 0x0100]
jmp start
musical_Score:dw 1140, 3415, 1140, 3415, 905, 3415, 761, 3415, 761, 3415, 761, 3415, 678, 3415, 761, 3415, 905, 3415, 1140, 3415, 1140
dw 3415, 1356, 3415, 1208, 3415, 1208, 3415, 854, 3415, 1140, 3415, 1140, 3415, 854, 3415, 905, 3415, 854, 3415, 905, 3415, 854
dw 3415, 1140, 3415, 1140, 3415, 905, 3415, 761, 3415, 761, 3415, 761, 3415, 678, 3415, 761, 3415, 905, 3415, 1140

duration: dw 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40
		dw 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40
		dw 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 40, 8

buffer: times 3520 db 0
seed: dw 0
ticks: db 0
stars: dw 0, 0, 0, 0, 0
pipes: dw 0, 0, 0
pipe_Gap: db 6
pipe_width: dw 3
bird_pos: dw 12
Bird_mov: db 'D'
Break: db 0
quit: db 0
free_fall: db 0		;adds delay on the bird's fall
oldisr: dd 0
oldTimer: dd 0
score: dw 0
dur: dw 0
endSp: db 0
PresSp: db 0
note: dw 0
gameStarted: db 0
tick_counter: dw 0
challenger: dw 0
collided: db 0
instructions: db 'Press UP Arrow key to move up and Esc button to pause'
pause1: db 'Paused'
pause2: db 'Press y to exit or any other button to continue'
gameOver1: db 'Your Score is'
gameOver2: db 'Press y to try again or any other button to exit the program'
loading: db 'Loading...'
title1: db 'created by'
mainScreenText: db 'Press any button to continue'
exitScreen: db 'Thank you for playing!'
name1: db 'Abdullah Ejaz'
name2: db 'Sara Rehman'
rollno1: db '23L-0537'
rollno2: db '23L-0611'
semester: db 'Fall 2024'
; PCB layout:
; ax,bx,cx,dx,si,di,ip,cs,ds,flags,next,dummy
; 0, 2, 4, 6, 8,10,12,14,16,18 , 20 , 22-30
pcb: times 2*16 dw 0
current: dw 0

kbisr:
push ax
	in al, 0x60
cmp byte[Break], 1
je QuitCheck
	cmp al, 0x48
	jne release
	mov byte[Bird_mov], 'U'
	jmp leav
release:
	cmp al, 0xC8
	jne escape
	mov byte[Bird_mov], 'D'
	mov byte[free_fall], 2		;implements the delay on bird's fall
	jmp leav
escape:
	cmp al, 0x81
	jne leav
	call pauseScreen
	mov byte[Break], 1
	in al, 0x61
	mov ah, al
	mov al, [PresSp]
	out 0x61, al
	mov [PresSp], ah
	jmp leav
QuitCheck:
	cmp al, 0x15
	jne ResumeGame
	mov Byte[quit], 1
	mov byte[gameStarted], 0
	mov al, [endSp]
	out 0x61, al
	jmp leav
ResumeGame:
cmp byte[gameStarted], 0
	je leav
	in al, 0x61
	mov ah, al
	mov al, [PresSp]
	out 0x60, al
	mov [PresSp], ah
	mov byte[Break], 0
leav:
pop ax
	jmp far [cs:oldisr]

timer:
	cmp byte[cs:free_fall], 0		; if the bird has stopped slowing down
	jg flying						; if not then set counter to 0 as a precaution
	inc word[cs:tick_counter]		; if yes, then increase counter
	cmp word[cs:tick_counter], 16	; slows the bird down after sometime
	jl endT
	mov byte[cs:free_fall], 1		; the amount of delay I am adding
	mov word[cs:tick_counter], 0	; reset counter to allow the process to repeat
	jmp endT
flying:
	mov word[cs:tick_counter], 0	; reset as a precaution
endT:
	inc word[dur]
	push ds
	push bx
	push cs
	pop ds ; initialize ds to data segment
	mov bx, [current] ; read index of current in bx
	shl bx, 1
	shl bx, 1
	shl bx, 1
	shl bx, 1
	shl bx, 1 ; multiply by 32 for pcb start
	mov [pcb+bx+0], ax ; save ax in current pcb
	mov [pcb+bx+4], cx ; save cx in current pcb
	mov [pcb+bx+6], dx ; save dx in current pcb
	mov [pcb+bx+8], si ; save si in current pcb
	mov [pcb+bx+10], di ; save di in current pcb
	pop ax ; read original bx from stack
	mov [pcb+bx+2], ax ; save bx in current pcb
	pop ax ; read original ds from stack
	mov [pcb+bx+16], ax ; save ds in current pcb
	pop ax ; read original ip from stack
	mov [pcb+bx+12], ax ; save ip in current pcb
	pop ax ; read original cs from stack
	mov [pcb+bx+14], ax ; save cs in current pcb
	pop ax ; read original flags from stack
	mov [pcb+bx+18], ax ; save flags in current pcb
	mov bx, [pcb+bx+20] ; read next pcb of this pcb
	mov [current], bx ; update current to new pcb
	mov cl, 5
	shl bx, cl ; multiply by 32 for pcb start
	mov cx, [pcb+bx+4] ; read cx of new process
	mov dx, [pcb+bx+6] ; read dx of new process
	mov si, [pcb+bx+8] ; read si of new process
	mov di, [pcb+bx+10] ; read di of new process
	push word [pcb+bx+18] ; push flags of new process
	push word [pcb+bx+14] ; push cs of new process
	push word [pcb+bx+12] ; push ip of new process
	push word [pcb+bx+16] ; push ds of new process
	mov al, 0x20
	out 0x20, al ; send EOI to PIC
	mov ax, [pcb+bx+0] ; read ax of new process
	mov bx, [pcb+bx+2] ; read bx of new process
	pop ds ; read ds of new process
iret ; return to new process

play_note:
cmp byte[Break], 1
	je endNote
	mov ax, [dur]
	mov si, [note]
	cmp ax, [duration + si]
	jb continue
	cmp word[note], 122
	jb playNow
	mov word[note], -2
playNow:
	add word[note], 2
    mov bx, [musical_Score + si] ; Access the divisor for the current note (using SI as index)
	mov word[dur], 0
    ; Enable the speaker and connect it to channel 2
    or al, 3h
    out 61h, al

    ; Set channel 2 (PIT)
    mov al, 0b6h    ; Select mode 3 (square wave) for channel 2
    out 43h, al

    ; Send the divisor to the PIT
    mov ax, bx      ; Load the divisor into AX
    out 42h, al     ; Send the LSB (lower byte)
    mov al, ah      ; Get the MSB (higher byte)
    out 42h, al     ; Send the MSB (higher byte)
continue:
endNote:
    jmp play_note

invisibleCursor:
push bp
mov bp, sp
call pushR
mov ch, 00100000b
mov cl, 0
mov ah, 01h
int 0x10
call popR
pop bp
ret

restoreCursor:
push bp
mov bp, sp
call pushR
mov ch, 0x06
mov cl, 0x07
mov ah, 01h
int 0x10
call popR
pop bp
ret

loadingScreen:
push bp
mov bp, sp
push es
call pushR
mov ax, 0xB800
mov es, ax
call clrscr
mov di, 3216
add di, 12
mov word[es:di], 0x0FC9
add di, 2
mov ax, 0x0FCD
mov cx, 50
cld 
rep stosw
mov word[es:di], 0x0FBB
mov ax, 0x0FBA
mov cx, 1
bar:
add di, 58
mov [es:di], ax
add di, 102
mov [es:di], ax
loop bar
add di, 58
mov word[es:di], 0x0FC8
add di, 2
mov ax, 0x0FCD
mov cx, 50
cld 
rep stosw
mov word[es:di], 0x0FBC

push es

mov bh, 0
mov bl, 0x0F

mov al, 0
mov dh, 7
mov dl, 36
mov cx, 10
push ds
pop es
mov bp, loading
mov ah, 13h
int 0x10

pop es
sub di, 260
mov cx, 50
mov ax, 0x0FDB
load:
	cld
	stosw
	push 20
	call paraDelay
	loop load
	
push 200
call paraDelay
call popR
pop es
pop bp
ret


titleScreen:
push bp
mov bp, sp
push es
call pushR
call clrscr
mov ax, 0xb800
mov es, ax
mov si, 660
push si
push 0x6F20
call makeS
add si, 14
push si
push 0x6F20
call makeO
add si, 14
push si
push 0x6F20
call makeA
add si, 14
push si
push 0x6F20
call makeR
add si, 20
push si
push 0x6F20
call makeQ
add si, 14
push si
push 0x6F20
call makeU
add si, 14
push si
push 0x6F20
call makeE
add si, 14
push si
push 0x6F20
call makeS
add si, 14
push si
push 0x6F20
call makeT

mov bh, 0
mov bl, 0x0F

mov al, 0
mov dh, 12
mov dl, 33
mov cx, 10
push ds
pop es
mov bp, title1
mov ah, 13h
int 0x10
mov dh, 14
mov dl, 20
mov cx, 13
mov bp, name1
mov ah, 13h
int 0x10
mov dl, 43
mov cx, 11
mov bp, name2
mov ah, 13h
int 0x10
mov dh, 16
mov dl, 22
mov cx, 8
mov bp, rollno1
mov ah, 13h
int 0x10
mov dl, 45
mov bp, rollno2
mov ah, 13h
int 0x10
mov dh, 18
mov dl, 33
mov cx, 9
mov bp, semester
mov ah, 13h
int 0x10
mov bl, 0x8F
mov dh, 21
mov dl, 23
mov cx, 28
mov bp, mainScreenText
mov ah, 13h
int 0x10
call popR
pop es
pop bp
ret

makeS:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
add di, 150
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
mov [es:di], ax
add di, 160
mov cx, 5
cld
rep stosw
sub di, 2
add di, 160
mov [es:di], ax
add di, 152
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
mov cx, 5
cld
rep stosw
call popR
pop bp
ret 4

makeO:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
mov cx, 5
add di, 150
o1:
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
loop o1
mov cx, 5
cld
rep stosw
call popR
pop bp
ret 4

makeA:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
mov cx, 6
add di, 150
a1:
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
loop a1
sub di, 640
mov cx, 5
cld
rep stosw
call popR
pop bp
ret 4

makeR:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
mov cx, 3
add di, 150
r1:
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
loop r1
mov cx, 3
r2:
mov [es:di], ax
add di, 6
mov [es:di], ax
add di, 154
loop r2
sub di, 640
mov cx, 5
cld
rep stosw
call popR
pop bp
ret 4

makeQ:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
mov cx, 5
add di, 150
q1:
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
loop q1
mov cx, 6
cld
rep stosw
call popR
pop bp
ret 4

makeU:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 6
u1:
mov [es:di], ax
add di, 8
mov [es:di], ax
add di, 152
loop u1
mov cx, 5
cld
rep stosw
call popR
pop bp
ret 4

makeE:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
mov cx, 5
add di, 150
e1:
mov [es:di], ax
add di, 160
loop e1
mov cx, 5
cld
rep stosw
sub di, 482
mov cx, 5
std
rep stosw
call popR
pop bp
ret 4

makeT:
push bp
mov bp, sp
call pushR
mov di, [bp + 6]
mov ax, [bp + 4]
mov cx, 5
cld
rep stosw
mov cx, 7
sub di, 6
t1:
mov [es:di], ax
add di, 160
loop t1
call popR
pop bp
ret 4

pauseScreen:
push bp
mov bp, sp
call pushR

call notificationBlock

mov bh, 0
mov bl, 0x1F

mov al, 0
mov dh, 7
mov dl, 37
mov cx, 6
push ds
pop es
mov bp, pause1
mov ah, 13h
int 0x10
mov bp, pause2
mov dh, 14
mov dl, 17
mov cx, 47
mov ah, 13h
int 0x10

call popR
pop bp
ret

notificationBlock:
push bp
mov bp, sp
push es
call pushR
mov ax, 5
mov bx, 80
mul bx
add ax, 10
shl ax, 1
push ax
mov di, ax
mov ax, 0xb800
mov es, ax
mov dx, 15
loop3:
mov cx, 60
mov ax, 0x1F20
cld
rep stosw
add di, 40
dec dx
jnz loop3

mov ax, 0xb800
mov es, ax
pop ax
mov di, ax
mov word[es:di], 0x1FC9
add di, 2
mov ax, 0x1FCD
mov cx, 58
cld 
rep stosw
mov word[es:di], 0x1FBB
mov ax, 0x1FBA
mov cx, 13
boundaries:
add di, 42
mov [es:di], ax
add di, 118
mov [es:di], ax
loop boundaries
add di, 42
mov word[es:di], 0x1FC8
add di, 2
mov ax, 0x1FCD
mov cx, 58
cld 
rep stosw
mov word[es:di], 0x1FBC
call popR
pop es
pop bp
ret

gameOverScreen:
push bp
mov bp, sp
push es
call pushR
call notificationBlock
mov bh, 0
mov bl, 0x1F

mov al, 0
mov dh, 7
mov dl, 35
mov cx, 13
push ds
pop es
mov bp, gameOver1
mov ah, 13h
int 0x10
mov bp, gameOver2
mov dh, 14
mov dl, 20
mov cx, 43
mov ah, 13h
int 0x10
mov dh, 15
mov dl, 33
add bp, cx
mov cx, 17
mov ah, 13h
int 0x10

call printFinalScore

call popR
pop es
pop bp
ret

instructionPanel:
push bp
mov bp, sp
push es
call pushR
mov bh, 0
mov bl, 0x3F

mov al, 0
mov dh, 7
mov dl, 15
mov cx, 53
push ds
pop es
mov bp, instructions
mov ah, 13h
int 0x10
call popR
pop es
pop bp
ret
display_screen:
push bp
mov bp, sp
call pushR
push es
mov ax, 0xB800
mov es, ax
mov cx, 1760
mov si, buffer
cld
rep movsw
pop es
call popR
pop bp
ret

endingScreen:
push bp
mov bp, sp		;parameter access will start from +4 since bp is pushed
call pushR
push es
	mov ax, 0xb800
	mov es, ax
	xor di, di
	mov cx, 80
nextChar1:
	push cx
	mov cx, 24
	allLines:
	mov word[es:di], 0x0f20
	add di, 160
	loop allLines
	mov word[es:di], 0x0f20
	pop cx
	sub di, 3838
	push 10
	call paraDelay
	loop nextChar1
	mov bh, 0
	mov bl, 0x0F

	mov al, 0
	mov dh, 12
	mov dl, 28
	mov cx, 22
	push ds
	pop es
	mov bp, exitScreen
	mov ah, 13h
	int 0x10
	push 500
	call paraDelay
	call clrscr
pop es
call popR
pop bp
ret

printScore:
push bp
mov bp, sp
call pushR
mov ax, [score] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit:
	mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit ; if no divide it again
	mov di, 78 ; point di to 70th column
	nextpos:
		pop dx ; remove a digit from the stack
		mov ax, [buffer + di]
		mov dh, ah ; use normal attribute
		mov [buffer + di], dx ; print char on screen
		add di, 2 ; move to next screen location
		loop nextpos ; repeat for all digits on stack
call popR
pop bp
ret

printFinalScore:
push bp
mov bp, sp
call pushR
mov ax, 0xb800
mov es, ax
mov ax, [score] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits
nextdigit1:
	mov dx, 0 ; zero upper half of dividend
	div bx ; divide by 10
	add dl, 0x30 ; convert digit into ascii value
	push dx ; save ascii value on stack
	inc cx ; increment count of values
	cmp ax, 0 ; is the quotient zero
	jnz nextdigit1 ; if no divide it again
	mov di, 1684 ; point di to 70th column
	nextpos1:
		pop dx ; remove a digit from the stack
		mov ax, [es:di]
		mov dh, ah ; use normal attribute
		mov [es:di], dx ; print char on screen
		add di, 2 ; move to next screen location
		loop nextpos1 ; repeat for all digits on stack
call popR
pop bp
ret

scoreCounter:
push bp
mov bp, sp
call pushR
mov si, [challenger]
cmp byte[pipes + si], 34
jne notPassed
inc word[score]
add si, 2
cmp si, 4
jbe noReset
mov word[challenger], 0
jmp notPassed
noReset:
mov [challenger], si
notPassed:
call popR
pop bp
ret

makeStationary:
push bp
mov bp, sp
call pushR
mov cx, 3
paralyse:
inc byte[pipes + si]
add si, 2
loop paralyse
inc byte[ticks]
call popR
pop bp
ret

Animation:		; Drawing the initial screen
push bp
mov bp, sp
call pushR
normalAn: 
call Move_Back		; Draws starry background
call Move_pipe		; Draw the intimidating pipe 
call Move_bird		; Draw the bird
call scoreCounter
call printScore
call Move_Ground	; Draw ground

cmp byte[Break], 1
je noDisplay
call display_screen	; Print the screen

noDisplay:
call popR
pop bp
ret

checkCollision:
push bp
mov bp, sp
call pushR
mov ax, [bp + 4]
cmp ax, 0x2F20
jne noCollision
mov byte[Break], 1
mov byte[collided], 1
noCollision:
call popR
pop bp
ret 2


initiate_Ground:		; Function to draw the ground
push bp
mov bp,sp
call pushR
push es
mov ax, 0xb800
mov es, ax
mov di, 3520
loop_Ground:
	mov word[es:di],0x6720	;Print complete ground
	add di, 2
	cmp di, 4000
	jne loop_Ground
	mov di, 3522
draw_Tracks:						;Make the checkered track
	mov word[es:di],0x7f20
	add di, 158
	mov word[es:di],0x7f20
	add di, 4
	mov word[es:di],0x7f20
	add di, 158
	mov word[es:di],0x7f20
	sub di, 320
	add di, 8
	cmp di, 3680
	jb draw_Tracks
pop es
call popR
pop bp
ret

Move_Ground:
push bp
mov bp, sp
call pushR
push es
push ds

mov ax, 0xB800
mov es, ax

push es
pop ds

mov si, 3522
mov di, 3520
mov cx, 79
mov dx, 3

nextrow:
mov ax, [es:di]
mov cx, 79
cld
rep movsw

mov word[es:di], ax
add si, 2
add di, 2
sub dx, 1
jnz nextrow

pop ds
pop es
call popR
pop bp
ret
	
birdFall:
push bp
mov bp, sp
call pushR
inc word[bird_pos]
jmp bird_create

Move_bird:		; Function to draw the bird
push bp
mov bp,sp
call pushR
cmp byte[Bird_mov], 'U'			;check if the bird should go up or down
je mov_up
cmp byte[free_fall], 0			;check if the bird should fall or not 
jg stay							;if not skip the changing of bird's pos
inc word[bird_pos]				;operation in case of down
cmp word[bird_pos], 20
jae stopD
jmp bird_create
stay:
dec byte[free_fall]				;countdown till the bird starts falling
jmp bird_create
stopD:
mov word[bird_pos], 20			; to stop it from going off the screen or on the chekerd ground
jmp bird_create
mov_up:
dec word[bird_pos]				;operation in case of up
cmp word[bird_pos], 0
jle stopU
jmp bird_create
stopU:
mov word[bird_pos], 0			; again to prevent it from going off the screen
jmp bird_create

bird_create:					;Printing bird
mov ax, [bird_pos]
mov bx, 80
mul bx
add ax, 38
shl ax, 1
mov di, ax
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x1F20
add di, 2
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x1F20
add di, 2
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x702E
add di, 154
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x1F20
add di, 2
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x1F20
add di, 2
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x1F20
add di, 2
mov ax, [buffer + di]
push ax
call checkCollision
mov word[buffer + di], 0x103E
call popR
pop bp
ret 

generate_pipe:
push bp
mov bp, sp
call pushR
mov dx, [bp + 4]
mov di, [bp + 6]
mov cx, [pipe_width]		; can change the thickness of the pipe by changing this variable
comparison:
cmp dl, 0
jl increment
cmp dl, 79
jle p
exit:
mov ax, [pipe_width]
sub ax, cx
mov bx, ax		; This calculates the final increase in di to keep the pipe straight
shl bx, 1
mov ax, 160
sub ax, bx
add di, ax
mov [bp + 6], di
call popR
pop bp
ret
increment:			; in case he pipes are at the left boundary
	inc dx
	dec cl
	inc ch
	cmp cl, 0
	jne comparison
	mov cl,ch		; this is to measure the increase in di accurately
	mov ch, 0
	jmp exit
p:
	mov word[buffer + di], 0x2F20	;Printing a line of pipe
	add di, 2
	inc dx
	dec cl
	cmp cl, 0
	jne comparison
	cmp ch, 0						;checks if the pipe was at the lower end
	je non 
	mov cl,ch			;adjusts it appropriately if the pipes are at the left edge
	mov ch, 0
non:
	jmp exit
	
	
Move_pipe:			; function to drw the pipes
push bp
mov bp,sp
call pushR
other:				; this check is to print one pipe then move on to the next
mov al, [pipes + si]
cmp al, 0xFD	; check if the pipe is present on the screen i.e x co-ordinate is not -pipe_gap 
je new				; if yes, generates a new pipe on the right edge
make:				; finding the starting node of the pipe
xor cx, cx
xor ax, ax
mov al, [pipes + si]
cmp al, 0
jge positive
mov di, 0
jmp normal
positive: 
shl al, 1
mov di, ax
normal:
mov cl, [pipes + si + 1]
inc cl				
create_upper:		; creating the upper pipe
mov dl, [pipes + si]
push di
push dx
call generate_pipe
pop di 
pop di
loop create_upper
xor ax, ax			; going to the node directly below to draw the lower pipe, keeping in mind the pipe gap
mov al, [pipe_Gap]
dec al
mov bx, 160
mul bx
add di, ax
create_lower:
cmp di, 3520		; draw till the lower pipe reaches the ground
jb generate_Lower
mov al, [pipes + si]
sub al, 1
mov [pipes + si], al
add si, 2
cmp si, 6			;checks if all the pipes are printed
jne other
call popR
pop bp
ret					;the program exits here
generate_Lower:			; draw the lower pipe
mov dl, [pipes + si]
push di
push dx
call generate_pipe
pop di 
pop di
jmp create_lower
new:					; generating the height of the new upper pipe
mov ax, 23
mov bl, [pipe_Gap]
sub ax, bx
push ax
call rand
pop dx
mov byte[pipes + si], 79		;places the pipe info in the appropriate containers
mov byte[pipes + si + 1], dl
jmp make


initiate_pipes:					; initializes the pipes in the first positions
push bp
mov bp, sp
call pushR
mov cx, 3
mov ax, 79
create:
push ax
mov ax, 23
mov bl, [pipe_Gap]
sub ax, bx
push ax
call rand
pop dx
pop ax
mov byte[pipes + si], al
add ax, 28
mov byte[pipes + si + 1], dl
add si, 2
loop create
call popR
pop bp
ret

draw_Star:					; draw a star and increment di
push ax
	mov ax, 0xBF2A
	mov [buffer + di], ax
	add di, 2
	add si, 2
pop ax
	ret
draw_Sky:					; draw a sky pixel and increment di
push ax
	mov ax, 0x3F20
	mov [buffer + di], ax
	add di, 2
pop ax
	ret
	
	
Move_Back:
push bp
mov bp,sp
call pushR
cmp byte[ticks], 0			; check if star life cycle is over
je updateSky				; if yes, refresh it
mov si, 0
No_Update:					; otherwise, print the previous stars
mov cx, [stars + si]
cmp cx, di
je star1					; if a star node is found
normal_sky:
call draw_Sky
cmp di, 3520
jne No_Update
jmp last_sky
star1:						; work towards drawing a star
cmp si, 10					; check if all the stars are already drawn
jb d_star					; if no, draw a star 
jmp normal_sky				; else draw a normal sky
d_star:						; finally drawing a star and incrementing to the next star
call draw_Star
cmp di, 3520
jne No_Update
jmp last_sky
updateSky:					; if the life cycle is finished, place new stars
mov byte[ticks], 20			; set the cycle back to zero
xor si, si
draw:						; start creating a new sky
push 250
call rand					; determine if star is to be placed by rng
pop dx
cmp dx, 0					; 1\250 chance a star will be placed
je Star						; draw star if found
draw_sky1:
call draw_Sky				; draw sky if not
cmp di, 3520
jne draw
jmp last_sky				; end loop if the printing is complete
Star:
cmp si, 10						; draw star
je draw_sky1
mov [stars + si], di
call draw_Star
cmp di, 3520
jne draw
last_sky:
dec byte[ticks]				; increment ticks by -1 to finalize it to zero
call popR
pop bp
ret


rand:
push bp
mov bp, sp
call pushR
	; Calculate new seed
	mov ax, [seed]
    mov bx, 21401          ; Set multiplier (214013 / 100)
    mul bx            ; ax = seed * 214013 (scaled down)
    add ax, 25311          ; Add increment (2531011 / 100)
    
    ; Ensure the result is non-negative
    and ax, 0x7FFF         ; Ensure ax is a positive value (mask with 0x7FFF)
    
    ; Store the new seed
    mov [seed], ax         ; Update the seed

    ; Return value in ax
    mov bx, [bp + 4]   ; Assuming RAND_MAX is defined somewhere
    xor dx, dx             ; Clear dx for division
    div bx                  ; ax = ax / (RAND_MAX + 1)
	mov [bp + 4], dx
call popR
pop bp
	ret	

ending:
mov byte[gameStarted], 0
mov byte[Break], 1
call makeStationary
	mov al, [endSp]
	out 0x61, al
checkEnd:
cmp word[bird_pos], 20
je stopEnd
call makeStationary
call Move_Back
call Move_pipe
call birdFall
call printScore
call display_screen
call delay
jmp checkEnd
stopEnd:
call gameOverScreen
call clearKeyBuffer
mov byte[quit], 0
mov byte[collided], 0
mov word[score], 0
mov word[challenger], 0
mov word[note], 0
mov word[dur], 0
mov word[bird_pos], 12
ret

clearKeyBuffer:
push bp
mov bp, sp
call pushR
clearBuffer:
mov ah, 1
int 0x16
jz cleared
mov ah, 0
int 0x16
jmp clearBuffer
cleared:
call popR
pop bp
ret


pushR:			; Function to save the state of all the registers
push ax
push bx
push cx
push dx
push si
push di
mov di, bp		; Preversing bp in di, which has already been pushed because bp is needed later on
mov bp, sp		; pointing bp to the top of the stack
mov ax, [bp + 12]	; moving the return address of this function in ax 
mov bp, di		; restoring bp
push ax			; pushing the return address to the top of the stack to allow the function to return to its original call
mov ax, 0		; prepping the registers for future use
mov bx, 0
mov cx, 0
mov dx, 0
mov si, 0
mov di, 0
ret

popR:			; function to store the previous register states
mov bp, sp
mov ax, [bp]	; gettinh the return address of this function
mov [bp + 14], ax	; placing it at the return address of the pushR function to properly allow it to exit
pop bp			; restore the states
pop di
pop si
pop dx
pop cx
pop bx
pop ax
ret


clrscr:
push bp
mov bp, sp		;parameter access will start from +4 since bp is pushed
call pushR
push es
	mov ax, 0xb800
	mov es, ax
	xor di, di
	mov cx, 2000
nextChar:
	mov word[es:di], 0x0f20
	add di, 2
	loop nextChar
pop es
call popR
pop bp
ret

seed_generator:		; Generating a seed to add variability in the random function( equivalent to int t = time(NULL); and srand(t); in c++
push bp
mov bp, sp
push 0xCCCC			; local variable
call pushR
	mov ah, 0x02
	int 0x1A		; syscall to obtain cimputer time in hours, minutes and seconds
	mov al, ch		; ch has hours, cl minutes and dh seconds
	mov ch, dh
	mov bx, 3600
	mul bx
	mov [bp - 2], ax
	mov al, cl
	mov dx, 60
	mul dx
	add al, ch
	mov bx, [bp - 2]
	add ax, bx
	mov [seed], ax
call popR
pop bp
pop bp
ret


delay:			; function to add time delay
push cx
push di
xor di, di
l:
mov cx, 0xFFFF
loop1: loop loop1
inc di
cmp di,4
jne l
pop di
pop cx
ret

paraDelay:			; function to add time delay
push bp
mov bp, sp
push cx
push di
xor di, di
l2:
mov cx, 0x3333
loop2: loop loop2
inc di
cmp di,[bp + 4]
jne l2
pop di
pop cx
pop bp
ret 2

initialize:
call initiate_Ground
call initiate_pipes
call Move_Back
call Move_pipe
call Move_bird
call printScore
call display_screen
call instructionPanel

in al, 0x61
mov [PresSp], al
mov [endSp], al
mov byte[quit], 0
mov byte[Break], 1
ret

setInterrupt:
push bp
mov bp, sp
call pushR
push es
mov ax, 16384
out 0x40, al
mov al, ah
out 0x40, al
xor ax, ax
	mov es, ax
	mov ax, [es:9*4]		;save old keyboard interrupt
	mov [oldisr], ax
	mov ax, [es:9*4+2]
	mov [oldisr + 2], ax
	
	mov ax, [es:8*4]		;save old timer
	mov [oldTimer], ax
	mov ax, [es:8*4+2]
	mov [oldTimer + 2], ax
	
	mov byte[Break], 1
	cli
	mov word[es:8*4], timer
	mov word[es:8*4+2], cs
	mov word[es:9*4], kbisr
	mov word[es:9*4+2], cs
	sti
pop es
call popR
pop bp
ret

restoreInterrupt:
push bp
mov bp, sp
call pushR
	mov al, [endSp]
	out 0x61, al
	xor ax, ax
push es
	mov es, ax
	cli
	mov ax, [oldisr]
	mov word[es:9*4], ax
	mov ax, [oldisr + 2]
	mov word[es:9*4+2], ax
	mov ax, [oldTimer]
	mov word[es:8*4], ax
	mov ax, [oldTimer + 2]
	mov word[es:8*4+2], ax
	sti
pop es
call popR
pop bp
ret

; PCB layout:
; ax,bx,cx,dx,si,di,ip,cs,ds,flags,next,dummy
; 0, 2, 4, 6, 8,10,12,14,16,18 , 20 , 22-30

intialPCB:
push bp
mov bp, sp
push bx
mov word[pcb + 20], 1
mov bx, 32
mov word[pcb + bx + 12], play_note
mov word[pcb + bx + 14], cs
mov word[pcb + bx + 16], ds
mov word[pcb + bx + 18], 0x0200
mov word[pcb + bx + 20], 0
pop bx
pop bp
ret

initialSetup:
push bp
mov bp, sp
call invisibleCursor
call intialPCB
call setInterrupt
pop bp
ret

restorePrevState:
push bp
mov bp, sp
call restoreInterrupt
call restoreCursor
call clearKeyBuffer
pop bp
ret

start:
	call initialSetup
	call loadingScreen
	call titleScreen
	call clearKeyBuffer
	mov ah, 0
	int 0x16
	call seed_generator
restart:
	mov byte[gameStarted], 0
	call initialize
	mov ah, 0
	int 0x16
	mov byte[Break], 0
l1:
	mov byte[gameStarted], 1
	cmp byte[Break], 0
	jne stop
	call Animation
	call delay
	cmp byte[collided], 1
	jne stop
	call ending
	mov ah, 0
	int 0x16
	cmp al, 'y'
	je restart
	mov byte[quit],1
stop:
	cmp byte[quit],0
je l1
	mov byte[Break], 1
	call endingScreen
	call restorePrevState
	mov ax, 0x4c00 ; terminate program
	int 0x21 
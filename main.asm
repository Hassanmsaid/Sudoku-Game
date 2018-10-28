INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE = 9*11

.data

; Arrays for loading boards 
answer BYTE BUFFER_SIZE DUP(?) 
question BYTE BUFFER_SIZE DUP(?)
user_answer BYTE BUFFER_SIZE DUP(?)
bool byte BUFFER_SIZE DUP(?)


fileHandle HANDLE ?
fileHandle2 HANDLE ?

; user game info 
wrong byte 0 
correct byte 0 
bool_counter byte 0 
cell byte ?
rows dword 11

; Number of empty cells 
empty_cells byte 0  

; Suduko File Path
easy1 byte "diff_1_1.txt",0
easy1ans byte "diff_1_1_solved.txt",0
easy2 byte "diff_1_2.txt",0
easy2ans byte "diff_1_2_solved.txt",0
easy3 byte "diff_1_3.txt",0
easy3ans byte "diff_1_3_solved.txt",0

normal1 byte "diff_2_1.txt",0
normal1ans byte "diff_2_1_solved.txt",0
normal2 byte "diff_2_2.txt",0
normal2ans byte "diff_2_2_solved.txt",0
normal3 byte "diff_2_3.txt",0
normal3ans byte "diff_2_3_solved.txt",0

hard1 byte "diff_3_1.txt",0  ;12
hard1ans byte "diff_3_1_solved.txt",0 ;19
hard2 byte "diff_3_2.txt",0
hard2ans byte "diff_3_2_solved.txt",0
hard3 byte "diff_3_3.txt",0
hard3ans byte "diff_3_3_solved.txt",0

; used file 
question_temp byte 12 dup(?),0
answer_temp byte 19 dup(?),0

;time calc.
starttime dword ?
endtime dword ?
millisecond dword ?
seconds dword ?
minutes dword ?
hours dword ?

.code
main PROC
   


	


   mWrite <"Choose difficulty :", 0dh, 0ah,"1) Easy", 0dh, 0ah, "2) Normal", 0dh, 0ah, "3) Hard",0dh, 0ah, 0>
   call getting_time
   mov starttime , eax 
call readint
cmp eax, 1
je easy
cmp eax, 2
je normal
cmp eax, 3
je hard

jmp out_of_range

easy:

call Randomize_Level 
cmp eax , 1 
je Level_One_Easy 
cmp eax , 2 
je Level_Two_Easy 
cmp eax , 3 
je Level_Three_Easy 

Level_One_Easy:
  mov edx , OFFSET  easy1
  call Set_Question_Temp
  mov edx , OFFSET  easy1ans
  call Set_Answer_Temp

  jmp done1

Level_Two_Easy:
  mov edx , OFFSET  easy2
  call Set_Question_Temp
  mov edx , OFFSET  easy2ans
  call Set_Answer_Temp

  jmp done1 

Level_Three_Easy:
  mov edx , OFFSET  easy3
  call Set_Question_Temp
  mov edx , OFFSET  easy3ans
  call Set_Answer_Temp

done1:

call Set_Arrays
call Options
jmp quit 

normal:

call Randomize_Level 
cmp eax , 1 
je Level_One_Normal 
cmp eax , 2 
je Level_Two_Normal
cmp eax , 3 
je Level_Three_Normal 

Level_One_Normal:
  mov edx , OFFSET  normal1
  call Set_Question_Temp
  mov edx , OFFSET  normal1ans
  call Set_Answer_Temp

  jmp done2

Level_Two_Normal:
  mov edx , OFFSET  normal2
  call Set_Question_Temp
  mov edx , OFFSET  normal2ans
  call Set_Answer_Temp

  jmp done2 

Level_Three_Normal:
  mov edx , OFFSET  normal3
  call Set_Question_Temp
  mov edx , OFFSET  normal3ans
  call Set_Answer_Temp

done2:
call Set_Arrays
call Options


jmp quit 
hard:

call Randomize_Level 
cmp eax , 1 
je Level_One_Hard 
cmp eax , 2 
je Level_Two_Hard 
cmp eax , 3 
je Level_Three_Hard 

Level_One_Hard:
  mov edx , OFFSET  hard1
  call Set_Question_Temp
  mov edx , OFFSET  hard1ans
  call Set_Answer_Temp

  jmp done3

Level_Two_Hard:
  mov edx , OFFSET  hard2
  call Set_Question_Temp
  mov edx , OFFSET  hard2ans
  call Set_Answer_Temp

  jmp done3 

Level_Three_Hard:
  mov edx , OFFSET  hard3
  call Set_Question_Temp
  mov edx , OFFSET  hard3ans
  call Set_Answer_Temp

done3:
call Set_Arrays
call Options

jmp quit 

out_of_range:
 mWrite < "Number Out Of Range ", 0dh, 0ah>
 jmp main 

quit:
call Getting_Time
mov endtime,eax

call time_calculations



exit
main ENDP

; -----------------------------------------------PROCEDURES-----------------------------------------------------------------------------------------

;----------------------------------------------------------------------
;Function: Choose Randomly Which Board To Use .		
;----------------------------------------------------------------------
Options PROC

mov edx , offset user_answer
call DisplayAnswer
mWrite<0dh, 0ah, "Options", 0dh, 0ah, "1) Finish Board", 0dh, 0ah, "2) Clear Board", 0dh, 0ah, "3) Edit Cell", 0dh, 0ah>
call readint
cmp eax, 1
je Finish
cmp eax, 2
je Clear
cmp eax, 3
je Edit

jmp out_of_range2 

out_of_range2:
mWrite<" Number Out Of Range ", 0dh, 0ah>



jmp Options
 

ret
Options ENDP
;----------------------------------------------------------------------
;Function: Edit cell of specific index 		
;----------------------------------------------------------------------
Edit PROC
mWrite<"Enter row : ">
	call readint
	dec eax
	cmp eax , 8 
	ja out_of_range3
	cmp eax , 0 
	jb out_of_range3
	mul rows
	mov ebx, eax

	mWrite<"Enter col : ">
	call readint
	dec eax
	cmp eax , 8 
	ja out_of_range3
	cmp eax , 0 
	jb out_of_range3
	call CheckNumber
	add ebx, eax

	 cmp bool[ebx] , 70
   je check

	mov eax,red
	call settextcolor
	mWrite<"The cell is already assigned ">
	call Set_White	
	jmp next

	check:
    
	mWrite<"Enter cell : ">
	call readint
	cmp eax ,  9
	ja out_of_range3
	cmp eax , 0
	jb out_of_range3
	call crlf
	add al , 48 
	mov dl, al

	mov al, answer[ebx]
	cmp dl, al
	je fine
	call Red1
	inc wrong 
	jmp next

	

	fine:
	call Green1
	mov user_answer[ebx] , dl
	mov bool[ebx] , 'M'
	 inc correct
	

	next:
	call crlf
	mov al , correct
	cmp al , empty_cells
	je succedd

	jmp options

	out_of_range3:
	mwrite< "Number Out Of Range ">

	jmp options 
	
	succedd:
	mov edx , offset user_answer
	call DisplayAnswer
	mwrite< "Suduko is solved  ">
	call crlf
	mwrite< "Correct Guessing : ">
	mov al , correct
	call writedec
	call crlf 
	 mwrite< "Wrong Guessing : ">
	mov al , wrong
	call writedec
	call crlf
ret
Edit ENDP

CheckNumber PROC

cmp eax , 8
ja wronno 
cmp eax , 0 
jb wronno 

jmp proceed

wronno:
	 mwrite< " Number Out Of Range ">
	 jmp options
	
	proceed:
	 
ret
CheckNumber ENDP
;----------------------------------------------------------------------
;Function: get out of options and display solved board
;----------------------------------------------------------------------
Finish PROC

call DisplaySolution
ret
Finish ENDP

;----------------------------------------------------------------------
;Function: clear all answers and start form the begining 
;----------------------------------------------------------------------
Clear PROC
call OpenQue
	mov edx,OFFSET user_answer
	call LoadQuestion
	mov wrong , 0 
	mov correct , 0 
	call SetBool
   call Options 
ret
Clear ENDP

;----------------------------------------------------------------------
;Function: set question , answer , bool , user_answer to defaults 
;----------------------------------------------------------------------
Set_Arrays PROC

call OpenQue
	mov edx,OFFSET question
	call LoadQuestion

	call OpenQue
	mov edx,OFFSET user_answer
	call LoadQuestion
	
	call SetBool
 
	call OpenAnsw
	mov edx,OFFSET answer
	call LoadAnswer

ret
Set_Arrays ENDP
;----------------------------------------------------------------------
;Function: choose randomly the board to the user 
;----------------------------------------------------------------------
Randomize_Level PROC

        mov  eax,3    ; random number from 0 to 2 
	   call Randomize  ;re-seed generator
       call RandomRange ; set eax to the random number
       inc  eax        ; make the number in range from 1 to 3  


ret
 Randomize_Level ENDP
;----------------------------------------------------------------------
;Function: set the question file name we are dealing with 
;----------------------------------------------------------------------
 Set_Question_Temp PROC

mov ecx , 12
mov ebx , OFFSET  question_temp
L1:

mov al , [edx]
mov [ebx] , al 
inc edx 
inc ebx 

loop L1

 ret
 Set_Question_Temp ENDP
 ;----------------------------------------------------------------------
;Function: set the answer file name we are dealing with 		
;----------------------------------------------------------------------
 Set_Answer_Temp PROC

mov ecx , 19
mov ebx , OFFSET  answer_temp
L1:

mov al , [edx]
mov [ebx] , al 
inc edx 
inc ebx 

loop L1

 ret
 Set_Answer_Temp ENDP

 ;----------------------------------------------------------------------
;Function: display the user answer on board  
;----------------------------------------------------------------------
DisplayAnswer PROC

 
	call crlf
	mov ecx,9
	mov ebx,1
	mWrite<" |">
	top_border:
	call Set_blue
	mov eax,ebx
	call writedec
	call Set_White
	mWrite<" ">
	inc ebx
	LOOP top_border
	call crlf
	
	
	mWrite<"-+">
	mov ecx,9
	top_border2:
	mWrite<"--">
	LOOP top_border2
	call crlf


	mov ebp,1
	mov ecx,9
	L1:
	call Set_blue
	mov eax,ebp
	call writedec
	call Set_White
	mWrite<"|">
	inc ebp
	
	mov edi , ecx
	mov ecx , 11  
	L2:
	mov eax , 0

	movzx esi , bool_counter
	cmp bool[esi] , 70
	
	je set_zero 

	cmp bool[esi] , 77

	je set_color
	jne con

	set_color:
	mov eax , green
	call settextcolor

 jmp con 
	set_zero :
	mov eax , yellow
	call settextcolor
	
	con:
	inc bool_counter
	cmp ecx , 2 
	jle normal 
	mov al , [edx]
	call writechar
	mov bl , al 
	call Set_White
	mov al , bl
	
	cmp ecx, 9
	je aywa
	cmp ecx, 6
	je aywa 
	mwrite< " ">
	jmp normal
	aywa: 
	mwrite< "|">
	
	normal:
	inc edx 
	
	loop L2
	
	mov ecx , edi
	dec ecx 
	call crlf
	cmp ecx, 6
	je aywa2
	cmp ecx, 3
	je aywa2
	jmp la2a
	aywa2:
	mwrite<"-+-----+-----+------",0dh, 0ah>
	la2a:
	cmp ecx, 0
	jne L1
	mov bool_counter , 0 

ret
DisplayAnswer ENDP

;----------------------------------------------------------------------
;Function: display the solved board  
;----------------------------------------------------------------------
DisplaySolution PROC

	call crlf
	mov ecx,9
	mov ebx,1
	mWrite<" |">
	top_border:
	call Set_blue
	mov eax,ebx
	call writedec
	call Set_White
	mWrite<" ">
	inc ebx
	LOOP top_border
	call crlf
	
	
	mWrite<"-+">
	mov ecx,9
	top_border2:
	mWrite<"--">
	LOOP top_border2
	call crlf

	mov edx,OFFSET answer
	mov ecx,9
	mov ebp,1
	L1:
	call Set_blue
	mov eax,ebp
	call writedec
	call Set_White
	mWrite<"|">
	inc ebp

	mov edi , ecx
	mov ecx , 11  
	L2:
	mov eax , 0 
			
	cmp ecx , 2 
	jle normal 
	mov al , [edx]
	call writechar
	cmp ecx, 9
	je aywa
	cmp ecx, 6
	je aywa 
	mwrite< " ">
	jmp normal
	aywa: 
	mwrite< "|">

	normal:
	inc edx 
	
	loop L2
	mov ecx , edi 
	call crlf
	cmp ecx, 7
	je aywa2
	cmp ecx, 4
	je aywa2
	jmp la2a
	aywa2:
	mwrite<"-+-----+-----+------",0dh, 0ah>
	la2a:
	loop L1	 
	call crlf


ret
DisplaySolution ENDP

;----------------------------------------------------------------------
;Function: Open the question file  
;----------------------------------------------------------------------
OpenQue PROC

mov edx,OFFSET question_temp
call OpenInputFile

ret
OpenQue ENDP

;----------------------------------------------------------------------
;Function: load question from file to array  
;----------------------------------------------------------------------
LoadQuestion PROC

  mov fileHandle,eax	
  mov ecx,buffer_size
  call ReadFromFile
  mov eax,fileHandle
	call CloseFile
ret
LoadQuestion ENDP
;----------------------------------------------------------------------
;Function: open answer file 
;----------------------------------------------------------------------
OpenAnsw PROC

mov edx,OFFSET answer_temp
call OpenInputFile

ret
OpenAnsw  ENDP
;----------------------------------------------------------------------
;Function: load answer to the array 		
;----------------------------------------------------------------------
LoadAnswer PROC

  mov fileHandle2,eax	
  mov ecx,buffer_size
  call ReadFromFile
  mov eax,fileHandle2
	call CloseFile
ret
LoadAnswer ENDP
;----------------------------------------------------------------------
;Function: set output color to red 
;----------------------------------------------------------------------
Red1 proc

	mov eax , red
 call settextcolor
	mWrite<"Wrong number", 0dh, 0ah>		
	mov eax , white
 call settextcolor
	ret
Red1 endp
;----------------------------------------------------------------------
;Function: set output color to green 
;----------------------------------------------------------------------
Green1 proc
mov eax , green
 call settextcolor
	mWrite<"Correct number", 0dh, 0ah>		
	mov eax , white
 call settextcolor
ret
Green1 endp
;----------------------------------------------------------------------
;Function: set bool array to check if an index is empty or not 
;----------------------------------------------------------------------
SetBool PROC

mov edx , offset bool
mov ebx , offset question

mov ecx,9
	L1:
	mov edi , ecx
	mov ecx , 11  
	
	L2:
	
	mov al , [ebx]
	sub al , 48          ;from ascii to number 
	cmp al , 0
	je set_to_false
	jne set_to_true

	set_to_false:
	mov esi , 'F'
	mov [edx] , esi 
	inc empty_cells

	jmp ok

	set_to_true:
	mov esi , 'T'
	mov [edx] , esi
	
	
	
	ok:
	inc edx 
	inc ebx
	  
	loop L2
	mov ecx , edi 
	
	loop L1
ret
SetBool ENDP

;----------------------------------------------------------------------
;Function: set color to white 		
;----------------------------------------------------------------------
Set_White PROC

mov eax , white
 call settextcolor

ret
Set_White ENDP


;----------------------------------------------------------------------
;Function: set color to blue		
;----------------------------------------------------------------------
Set_blue PROC

mov eax , Cyan
 call settextcolor

ret
Set_blue ENDP



Getting_Time proc
    mov eax,0
	INVOKE GetTickCount
    

   ret
Getting_time endp
;----------------------------------------------------------------------
;Function: adjust time ti hours , min and seconds 
;----------------------------------------------------------------------
Time_calculations proc

    mov ebx,starttime
	sub eax,ebx
	;mwrite<'Time in millisecond: '>
	;call writeint
	;call crlf
	mov ebx,1000
	mov edx,0
	div ebx
	mov millisecond,edx

	cmp eax,0
	je done
	mov edx,0
	mov ebx,60
	div ebx
	mov seconds,edx
	cmp eax,0
	je done
	mov edx,0
	div ebx
	mov minutes,edx
	cmp eax,0
	je done
	mov edx,0
	div ebx
	mov hours,edx

	done:
	mwrite<' Your Time : '>
	mov eax,hours
	call writedec
	mwrite<':'>
	mov eax,minutes
	call writedec
	mwrite<':'>
	mov eax,seconds
	call writedec
	mwrite<'.'>
	mov eax,millisecond
	call writedec
	call crlf

ret
Time_calculations ENDP	

END main
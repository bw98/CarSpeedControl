IOY0         EQU   0600H          ;片选IOY0对应的端口始地址
MY8255_A     EQU    IOY0+00H*2     ;8255的A口地址
MY8255_B     EQU   IOY0+01H*2     ;8255的B口地址
MY8255_C     EQU   IOY0+02H*2     ;8255的C口地址
MY8255_MODE  EQU   IOY0+03H*2     ;8255的控制寄存器地址



 
SSTACK    SEGMENT STACK
    DW 32 DUP(?)
SSTACK    ENDS
DATA SEGMENT
    NUMS DB 3FH,06H,5BH,4FH,66h,6dh,7dh,07h,7fh,6fh,79H  ;
    ;SELECT_OUTSMG1  DB  0H, 0FEH, 0FDH, 0FBH, 0F7H
    
    
DATA ENDS
CODE    SEGMENT
    ASSUME CS:CODE,SS:SSTACK
START:    
    MOV AX,DATA
    MOV DS,AX
    MOV AX,SSTACK
    MOV SS,AX
        
        
    MOV DX, MY8255_MODE
    MOV AL, 82H    ;1000 0001 表示A口C口高四位低四位输出，B口为输入
    OUT DX, AL    ;控制字送控制寄存器
    MOV BX, 0    ;清零

CTRL:        
    MOV DX , MY8255_B
    IN AL, DX    ;C口值送AL，进行输入
    
    MOV AH,0    ;AX的高8位清零
    TEST AL,1H    ;AL是否等于1，进行and操作，影响标志位
    JNZ T1           ;若AL为XXXX XXX1，跳T1
    MOV  CX ,00      ;CX送0

    JMP A1
    

T1:        
    TEST AL, 2H
    JNZ T2           ;若AL为XXXX XX1X，跳T2
    MOV CX,10        ;CX送10
    MOV DX , MY8255_B
    mov AL,00010000B ;
    out DX, AL    ;将AL的值给C口
    
    JMP A1


        
T2:        
    TEST AL, 4H
    JNZ T3           ;若AL为XXXX X1XX，跳T3
    MOV CX, 20        ;CX送20
    MOV DX , MY8255_B
    mov AL, 00100000B
    out DX, AL
    
    JMP A1
        

T3:        
    TEST AL,8H
    JNZ T4           ;若AL为XXXX 1XXX，跳T4
    MOV CX,40
    MOV DX , MY8255_B
    mov AL,01000000B
    out DX, AL


    JMP A1
        

T4:        
    MOV CX,60        ;CX送60
    MOV DX , MY8255_B
    mov AL,10000000B
    out DX, AL

    
    JMP A1
    

A1:        
    CMP BX,CX
    JNZ AMD  ;ZF=0，跳AMD
    CMP BX,0
    JE CWT    ;ZF=1,跳CWT
        
        
AMD:        
    CMP CX,BX
    JB ASD   ;CX小于BX，跳ASD
    CALL PRINT1  ;执行子程序，会返回
    JMP CTRL
ASD:
    CALL PRINT2
    JMP CTRL

CWT:        
    CALL PRI
    JMP CTRL    



PRINT1 PROC
    ;因为每次只能亮1个的原因，所以要call多次实现肉眼错觉
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    ;CALL PRI
    ;CALL PRI
    ;CALL PRI
    INC  BX
    CMP BX,CX
    JB  PRINT1
    MOV BX,CX
    RET
PRINT1 ENDP

PRINT2 PROC
        
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    CALL PRI
    ;CALL PRI
    ;CALL PRI
    ;CALL PRI
    DEC  BX
    CMP CX,BX
    JB  PRINT2
    MOV BX,CX
    RET
PRINT2 ENDP


        
PRI PROC    
    PUSH CX
    PUSH DX
       PUSH AX
       PUSH BX
            
       ;速度高位
    MOV AX,BX
      MOV CL,10
      DIV CL        ;  AH 余数  AL  商  36 / 10 = 3 ..... 6  
      MOV CX,0
      MOV CX,14 ;0000 1110b,就是设置第一个数码管亮
      MOV BL,AL   ; 3   
           
      CALL HUA
      CALL YANSHI
  
      
      ;速度低位    
      MOV BL,AH
      MOV CX,13 ;0000 1101b，就是设置第二数码管亮
      CALL HUA
      CALL YANSHI
      
      ;档位
      MOV BL, AL
      MOV CX,7 ;0000 0111b，就是设置第4个亮
      CALL HUA
      CALL YANSHI
               
           
      POP BX
    POP AX
    POP DX
    POP CX
    RET
PRI ENDP


HUA PROC
    PUSH BX
    PUSH AX
    
    ;控制第XXX灯亮
    MOV DX, MY8255_C
    MOV AX,CX
    OUT DX,AX   ;B口输出CX
    
    
    ;输出值到数码管
    MOV BH,0
    MOV DX,MY8255_A
    MOV SI,OFFSET NUMS

    MOV AX,[SI+BX]
    OUT DX,AX   ;A口输出BX，也就是NUMS[BX]

    POP AX
    POP BX
    RET
HUA ENDP    

                    
YANSHI PROC


    PUSH CX
    MOV CX,2000
YS:
    CALL YANSHI2
    DEC CX
    JNZ YS
POP CX
    RET    
YANSHI ENDP


YANSHI2 PROC
    PUSH CX
    MOV CX,1
TYUY:
    DEC CX
    JNZ TYUY
    
    POP CX
    RET
YANSHI2 ENDP
CODE    ENDS
END START

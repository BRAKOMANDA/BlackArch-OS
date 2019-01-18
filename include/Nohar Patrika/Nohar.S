CODERES SEGMENT
ASSUME  CS:RESGROUP,DS:RESGROUP,ES:RESGROUP,SS:RESGROUP
        ORG     0
ZERO    =       $
PARMBUF LABEL   WORD

        ORG     100H

RSTACK  LABEL   WORD

PROGSTART:
        JMP     CONPROC

LTPA    DW      0               ;WILL STORE TPA SEGMENT HERE
MYSEG   DW      0               ;Put our own segment here

CONTC:
        MOV     AX,CS
        MOV     DS,AX
        MOV     SS,AX
        MOV     SP,OFFSET RESGROUP:RSTACK
        STI
        CALL    SETVECT
        MOV     AH,DSKRESET
        INT     33              ;Reset disks in case files were open
        TEST    [BATCH],-1
        JZ      LODCOM
ASKEND:
        MOV     DX,OFFSET RESGROUP:ENDBATMES
        MOV     AH,PRINTBUF
        INT     33
        MOV     AX,0C00H+INCHAR
        INT     33
        AND     AL,5FH
        CMP     AL,"N"
        JZ      LODCOM
        CMP     AL,"Y"
        JNZ     ASKEND
        MOV     [BATCH],0
LODCOM:
        MOV     AX,CS
        MOV     SS,AX
        MOV     SP,OFFSET RESGROUP:RSTACK
        MOV     DS,AX
        CALL    SETVECT
        CALL    CHKSUM
        CMP     DX,[SUM]
        JZ      HAVCOM
        MOV     [LOADING],1
        CALL    LOADCOM
CHKSAME:
        CALL    CHKSUM
        CMP     DX,[SUM]
        JZ      HAVCOM
        CALL    WRONGCOM
        JMP     SHORT CHKSAME
HAVCOM:
        MOV     [LOADING],0
        MOV     SI,OFFSET RESGROUP:LTPA
        MOV     DI,OFFSET TRANGROUP:TPA
        MOV     ES,[TRNSEG]
        CLD
        MOVSW           ;Move TPA segment to transient storage
        MOVSW           ;Move resident segment too
        MOV     AX,[MEMSIZ]
        MOV     WORD PTR ES:[2],AX
        JMP     DWORD PTR [TRANS]

RESIDENT:
        ADD     DX,15
        MOV     CL,4
        SHR     DX,CL           ;Number of paragraphs of new addition
        ADD     CS:[LTPA],DX
        XOR     AX,AX
        MOV     DS,AX
        JMP     DWORD PTR DS:[80H]              ;Pretend user executed INT 20H

DSKERR:
        ;******************************************************
        ;       THIS IS THE DEFAULT DISK ERROR HANDLING CODE 
        ;       AVAILABLE TO ALL USERS IF THEY DO NOT TRY TO 
        ;       INTERCEPT INTERRUPT 24H.
        ;******************************************************
        STI
        PUSH    DS
        PUSH    CS
        POP     DS              ;Set up local data segment
        PUSH    DX
        CALL    CRLF
        POP     DX
        ADD     AL,"A"          ;Compute drive letter
        MOV     [DRVLET],AL
        TEST    AH,80H          ;Check if hard disk error
        JNZ     FATERR
        MOV     SI,OFFSET RESGROUP:READ
        TEST    AH,1
        JZ      SAVMES
        MOV     SI,OFFSET RESGROUP:WRITE
SAVMES:
        LODSW
        MOV     WORD PTR [IOTYP],AX
        LODSW
        MOV     WORD PTR [IOTYP+2],AX
        AND     DI,0FFH
        CMP     DI,12
        JBE     HAVCOD
        MOV     DI,12
HAVCOD:
        MOV     DI,WORD PTR [DI+MESBAS] ;Get pointer to error message
        XCHG    DI,DX           ;May need DX later
        MOV     AH,PRINTBUF
        INT     33              ;Print error type
        MOV     DX,OFFSET RESGROUP:ERRMES
        INT     33
        CMP     [LOADING],0
        JNZ     GETCOMDSK
ASK:
        MOV     DX,OFFSET RESGROUP:REQUEST
        MOV     AH,PRINTBUF
        INT     33
        MOV     AX,0C00H+INCHAR
        INT     33              ;Get response
        CALL    CRLF
        OR      AL,20H          ;Convert to lower case
        MOV     AH,0            ;Return code for ignore
        CMP     AL,"i"          ;Ignore?
        JZ      EXIT
        INC     AH
        CMP     AL,"r"          ;Retry?
        JZ      EXIT
        INC     AH
        CMP     AL,"a"          ;Abort?
        JNZ     ASK
EXIT:
        MOV     AL,AH
        MOV     DX,DI
        POP     DS
        IRET

FATERR:
        MOV     DX,OFFSET RESGROUP:BADFAT
        MOV     AH,PRINTBUF
        INT     33
        MOV     DX,OFFSET RESGROUP:DRVNUM
        INT     33
        MOV     AL,2            ;Abort
        POP     DS
        IRET

GETCOMDSK:
        MOV     DX,OFFSET RESGROUP:NEEDCOM
        MOV     AH,PRINTBUF
        INT     33
        MOV     AX,0C07H        ;Get char without testing or echo
        INT     33
        JMP     LODCOM

CRLF:
        MOV     DX,OFFSET RESGROUP:NEWLIN
        PUSH    AX
        MOV     AH,PRINTBUF
        INT     33
        POP     AX
RET10:  RET

LOADCOM:
        PUSH    DS
        MOV     DS,[TRNSEG]
        MOV     DX,100H
        MOV     AH,SETDMA
        INT     33
        POP     DS
        MOV     DX,OFFSET RESGROUP:COMFCB
        MOV     AH,OPEN
        INT     33              ;Open COMMAND.COM
        OR      AL,AL
        JZ      READCOM
        MOV     DX,OFFSET RESGROUP:NEEDCOM
PROMPTCOM:
        MOV     AH,PRINTBUF
        INT     33
        MOV     AX,0C07H        ;Get char without testing or echo
        INT     33
        JMP     SHORT LOADCOM
READCOM:
        MOV     WORD PTR[COMFCB+RR],OFFSET RESGROUP:TRANSTART
        XOR     AX,AX
        MOV     WORD PTR[COMFCB+RR+2],AX
        MOV     [COMFCB],AL             ;Use default drive
        INC     AX
        MOV     WORD PTR[COMFCB+RECLEN],AX
        MOV     CX,COMLEN
        MOV     DX,OFFSET RESGROUP:COMFCB
        MOV     AH,RDBLK
        INT     33
        OR      AL,AL
        JZ      RET10
WRONGCOM:
        MOV     DX,OFFSET RESGROUP:COMBAD
        JMP     SHORT PROMPTCOM

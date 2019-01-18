TRANCODE        SEGMENT PARA
TRANCODE        ENDS

TRANDATA        SEGMENT BYTE
TRANDATA        ENDS

TRANSPACE       SEGMENT BYTE
TRANSPACE       ENDS

RESGROUP        GROUP   CODERES,DATARES,INIT,TAIL
TRANGROUP       GROUP   TRANCODE,TRANDATA,TRANSPACE

;Data for resident portion

DATARES SEGMENT BYTE
        ORG     0
ZERO    =       $
MESBAS  DW      OFFSET RESGROUP:ERR0
        DW      OFFSET RESGROUP:ERR2
        DW      OFFSET RESGROUP:ERR4
        DW      OFFSET RESGROUP:ERR6
        DW      OFFSET RESGROUP:ERR8
        DW      OFFSET RESGROUP:ERR10
        DW      OFFSET RESGROUP:ERR12
ERR0    DB      "Write protect$"
ERR2    DB      "Not ready$"
ERR4    DB      "Data$"
ERR6    DB      "Seek$"
ERR8    DB      "Sector not found$"
ERR10   DB      "Write fault$"
ERR12   DB      "Disk$"
READ    DB      "read$"
WRITE   DB      "writ$"
ERRMES  DB      " error "
IOTYP   DB      "writing"
DRVNUM  DB      " drive "
DRVLET  DB      "A"
NEWLIN  DB      13,10,"$"
REQUEST DB      "Abort, Retry, Ignore? $"
BADFAT  DB      13,10,"File allocation table bad,$"
COMBAD  DB      13,10,"Invalid COMMAND.COM"
NEEDCOM DB      13,10,"Insert DOS disk in "
        IF      IBMVER
        DB      "drive A"
        ELSE
        DB      "default drive"
        ENDIF
PROMPT  DB      13,10,"and strike any key when ready",13,10,"$"
NEEDBAT DB      13,10,"Insert disk with batch file$"
ENDBATMES DB    13,10,"Terminate batch job (Y/N)? $"
LOADING DB      0
BATFCB  DB      1,"AUTOEXECBAT"
        DB      21 DUP(?)
        DW      0
        DW      0               ;Initialize RR field to zero
PARMTAB DW      10 DUP(-1)      ;No parameters initially
BATCH   DB      1               ;Assume batch mode initially
COMFCB  DB      COMDRV,"COMMAND COM"
        DB      25 DUP(?)
TRANS   DW      OFFSET TRANGROUP:COMMAND
TRNSEG  DW      ?
BATBYT  DB      ?
MEMSIZ  DW      ?
SUM     DW      ?
INITADD DB      4 DUP(?)
RESDATASIZE     EQU     $-ZERO
DATARES ENDS

;Data for transient portion

TRANDATA        SEGMENT BYTE
        ORG     0
ZERO    EQU     $
BADNAM  DB      "Bad command or file name",13,10,"$"
MISNAM  DB      "Missing file name$"
RENERR  DB      "Duplicate file name or "
NOTFND  DB      "File not found$"
EXEBAD  DB      "Error in EXE file$"
NOSPACE DB      "Insufficient disk space",13,10,"$"
FULDIR  DB      "File creation error",13,10,"$"
OVERWR  DB      "File cannot be copied onto itself",13,10,"$"
LOSTERR DB      "Content of destination lost before copy",13,10,"$"
COPIED  DB      " File(s) copied$"
DIRMES  DB      " File(s)$"
TOOBIG  DB      "Program too big to fit in memory$"
BADDRV  DB      "Invalid drive specification$"
PAUSMES DB      "Strike a key when ready . . . $"
BADSWT  DB      "Illegal switch",13,10,"$"
WEEKTAB DB      "SunMonTueWedThuFriSat"
BADDAT  DB      13,10,"Invalid date$"
CURDAT  DB      "Current date is $"
NEWDAT  DB      13,10,"Enter new date: $"
BADTIM  DB      13,10,"Invalid time$"
CURTIM  DB      "Current time is $"
NEWTIM  DB      13,10,"Enter new time: $"
SUREMES DB      "Are you sure (Y/N)? $"

COMTAB  DB      4,"DIR",1
        DW      OFFSET TRANGROUP:CATALOG
        DB      7,"RENAME",1
        DW      OFFSET TRANGROUP:RENAME
        DB      4,"REN",1
        DW      OFFSET TRANGROUP:RENAME
        DB      6,"ERASE",1
        DW      OFFSET TRANGROUP:ERASE
        DB      4,"DEL",1
        DW      OFFSET TRANGROUP:ERASE
        DB      5,"TYPE",1
        DW      OFFSET TRANGROUP:TYPEFIL
        DB      4,"REM",1
        DW      OFFSET TRANGROUP:COMMAND
        DB      5,"COPY",1
        DW      OFFSET TRANGROUP:COPY
        DB      6,"PAUSE",1
        DW      OFFSET TRANGROUP:PAUSE
        DB      5,"DATE",0
        DW      OFFSET TRANGROUP:DATE
        DB      5,"TIME",0
        DW      OFFSET TRANGROUP:TIME
        DB      0               ;Terminate command table

COMBUF  DB      128,1,13

TRANDATASIZE    EQU     $-ZERO
TRANDATA        ENDS

;Uninitialized transient data
TRANSPACE       SEGMENT BYTE
        ORG     0
ZERO    =       $
        DB      128 DUP(?)
TPA     DW      1 DUP(?)
RESSEG  DW      1 DUP(?)
CHKDRV  DB      1 DUP(?)
FILTYP  DB      1 DUP(?)
CURDRV  DB      1 DUP(?)
PARM1   DB      1 DUP(?)
PARM2   DB      1 DUP(?)
COMSW   DW      1 DUP(?)
ARG1S   DW      1 DUP(?)
ARG2S   DW      1 DUP(?)
FLAGER  DB      1 DUP(?)
CFLAG   DB      1 DUP(?)
SPECDRV DB      1 DUP(?)
BYTCNT  DW      1 DUP(?)
NXTADD  DW      1 DUP(?)
LINCNT  DB      1 DUP(?)
LINLEN  DB      1 DUP(?)
FILECNT DW      1 DUP(?)
EXEFCB  LABEL WORD
IDLEN   DB      1 DUP(?)
ID      DB      8 DUP(?)
COM     DB      3 DUP(?)
DEST    DB      37 DUP(?)
DESTNAME DB     11 DUP(?)
DIRBUF  DB      37 DUP(?)
BITS    DW      1 DUP(?)
FULLSCR DW      1 DUP(?)
EXEEND  DW      1 DUP(?)
;Header variables for EXE file load
;These are overlapped with COPY variables, below
RUNVAR  LABEL WORD
RELPT   DW      1 DUP(?)
RELSEG  DW      1 DUP(?)
PSIZE   LABEL   WORD
PAGES   DW      1 DUP(?)
RELCNT  DW      1 DUP(?)
HEADSIZ DW      1 DUP(?)
        DW      1 DUP(?)
LOADLOW DW      1 DUP(?)
INITSS  DW      1 DUP(?)
INITSP  DW      1 DUP(?)
        DW      1 DUP(?)
INITIP  DW      1 DUP(?)
INITCS  DW      1 DUP(?)
RELTAB  DW      1 DUP(?)
RUNVARSIZ       EQU     $-RUNVAR

        DB      80H DUP(?)
STACK   LABEL   WORD

PRETRLEN        EQU     $-ZERO          ;Used later to compute TRNLEN

        ORG     RUNVAR-ZERO                     ;Overlaps EXE variables

SRCPT   DW      1 DUP(?)
INEXACT DB      1 DUP(?)
APPEND  DB      1 DUP(?)
NOWRITE DB      1 DUP(?)
ASCII   DB      1 DUP(?)
PLUS    DB      1 DUP(?)
SOURCE  DB      11 DUP(?)
TRANSPACESIZE   EQU     $-ZERO
TRANSPACE       ENDS


;START OF RESIDENT PORTION

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

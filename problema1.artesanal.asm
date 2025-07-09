; ============================================   
; MACROS 
; ============================================

PUTC    MACRO   char        ; Macro com "parametro" char
        PUSH    AX          ; Guarda AX na stack pois ele vai ser sobrescrito
        MOV     AL, char    ; Coloca o char em AL de acordo com a interrupcao
        MOV     AH, 0Eh
        INT     10h         ; Executa 10h/0Eh     
        POP     AX      
ENDM

GETC    MACRO               ; Retorna o Caractere em AL   
        MOV     AH, 00h
        INT     16h        
ENDM
                            ; Coloca o ponteiro no inicio da linha e pula a linha
BARRAENE MACRO
        PUSH    AX
        MOV     AH, 0Eh
        MOV     AL, 0Dh     ; '\r'
        INT     10h
        MOV     AL, 0Ah     ; '\n'
        INT     10h
        POP     AX
ENDM

                                       
; ============================================   
; INICIO DO PROGRAMA 
; ============================================

ORG 100h

LEA BX, str_aviso           ;  Carrega a string de solicitacao de input e printa ela.
CALL PRINT_S

LEA BX, str_angulo          ; Carrega a area de memoria que vai armazenar a string angulo,
MOV DI, 3                   ; Tamanho maximo da string angulo.
CALL GET_S                  ; Pega a string

CALL STR_TO_INT_3           ; Transforma a string em um int
MOV angulo, CX              ; O resultado da transformacao em um angulo

; Printa a toda a parte da string, menos a direcao do angulo, ou seja:
LEA BX, str_inicio          
CALL PRINT_S                ; O angulo
LEA BX, str_angulo           
CALL PRINT_S                ; String do angulo (ex: 360)
LEA BX, str_representa
CALL PRINT_S                ; Representa a direcao

CMP angulo, 0               ; Se o angulo for 0, entao eh norte
JNZ not_leste               ; Se nao for, faz outras checagens
LEA BX, str_leste           ; Printa a string de LESTE.
CALL PRINT_S
JMP end                     ; Pula para o fim do programa.

not_leste:                  ; Se nao for 0, continua e checa por leste
CMP angulo, 90
JNL not_nordeste
LEA BX, str_nordeste
CALL PRINT_S
JMP end

not_nordeste:               ; Checa por norte
JNE not_norte
LEA BX, str_norte
CALL PRINT_S
JMP end

not_norte:                  ; Checa por noroeste
CMP angulo, 180
JNL not_noroeste
LEA BX, str_noroeste
CALL PRINT_S
JMP end

not_noroeste:               ; Checa por oeste
CMP angulo, 180
JNE not_oeste
LEA BX, str_oeste
CALL PRINT_S
JMP end

not_oeste:                  ; Checa por sudoeste
CMP angulo, 270
JNL not_sudoeste
LEA BX, str_sudoeste
CALL PRINT_S
JMP end

not_sudoeste:               ; Checa por sul
CMP angulo, 270
JNE not_sul
LEA BX, str_sul
CALL PRINT_S
JMP end

not_sul:                    ; Checa por sudeste
CMP angulo, 360
JNL invalido
LEA BX, str_sudeste
CALL PRINT_S
JMP end

invalido:                   ; Se não for nenhum, então é INVALIDO.
LEA BX, str_invalido
CALL PRINT_S

end:                        ; Label para encerrar a execucao
RET

; ============================================   
; VARIAVEIS
; ============================================

angulo DW 0                 ; Define a variavel de angulo como 0
str_aviso DB 'Digite o valor do angulo em graus inteiros de 0 - 359 com 3 digitos ex: "005":', 0
str_angulo DB '111', 0
str_inicio DB 'O angulo ', 0
str_representa DB ' representa a direcao ', 0
str_leste DB 'LESTE.', 0
str_nordeste DB 'NORDESTE.', 0
str_norte DB 'NORTE.', 0
str_noroeste DB 'NOROESTE', 0
str_oeste DB 'OESTE.', 0
str_sudoeste DB 'SUDOESTE.', 0
str_sudeste DB 'SUDESTE.', 0
str_sul DB 'SUL.', 0
str_invalido DB 'Angulo Invalido!', 0


; ============================================   
; PROCEDIMENTOS 
; ============================================

PRINT_S PROC; Printa uma string em BX
; Colocar o primeiro endereco da String em BX
    MOV SI, 0               ; Inicializa o indice como 0
    continue_print:         ; Label do Loop
        MOV AL, [BX + SI]   ; Define AL como o offset de SI em BX (algo como string[i])
        PUTC AL             ; Printa AL
        INC SI              ; Incrementa o Indice
        CMP [BX + SI], 0    ; Checa se o caractere atual eh o terminador nulo
        JNE continue_print  ; Se STRING[i] != '\0', o loop segue
RET
        
PRINT_S ENDP

GET_S PROC; Pega uma string do usuario de tamanho predefinido e retorna em BX
; Colocar o tamanho da string (sem terminador NULO) em DI (ate 8 bits)
; Colocar o endereco de destino da STRING em BX
    MOV SI, 0
    get_next_char:
        GETC                ; Pega o caracter e salva em AL
        PUTC AL             ; Imprime caractere atual
        MOV [BX + SI], AL   ; STRING[i] = AL        
        INC SI              ; i++
        CMP SI, DI          ; Compara se SI == DI
        JNE get_next_char   ; Se SI != AH, continua o ciclo
    MOV [BX + SI], 0        ; Insere o terminador NULO
    BARRAENE
RET
GET_S ENDP

STR_TO_INT_3 PROC           ; Transforma string de 3 caracteres numéricos em inteiro

    MOV AX, 0               ; zera acumulador
    MOV CX, 0               ; CX = resultado final

    ; Primeiro caractere (posicao 0) * 100
    MOV DL, [BX + 0]
    SUB DL, '0'
    MOV AL, DL
    MOV AH, 0
    MOV SI, 100             ; peso
    MUL SI                  ; AX = DL * 100
    ADD CX, AX

    ; Segundo caractere (posicao 1) * 10
    MOV DL, [BX + 1]
    SUB DL, '0'
    MOV AL, DL
    MOV AH, 0
    MOV SI, 10
    MUL SI                  ; AX = DL * 10
    ADD CX, AX

    ; Terceiro caractere (posicao 2) * 1
    MOV DL, [BX + 2]
    SUB DL, '0'
    MOV AL, DL
    MOV AH, 0
    ADD CX, AX        

    MOV AX, CX        
    RET
STR_TO_INT_3 ENDP
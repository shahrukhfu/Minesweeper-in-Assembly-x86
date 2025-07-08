INCLUDE Irvine32.inc

.const
ROWS = 5
COLS = 5
NUM_MINES = 3
MINE_CHAR = 'X'
SAFE_CHAR = '.'
HIDDEN_CHAR = '#'

.data
grid       BYTE ROWS * COLS DUP(0)     ; 0 = safe, 1 = mine
visible    BYTE ROWS * COLS DUP(HIDDEN_CHAR)
rowPrompt  BYTE "Enter row (0-4): ", 0
colPrompt  BYTE "Enter col (0-4): ", 0
mineMsg    BYTE "Boom! You hit a mine!", 0
winMsg     BYTE "Congratulations! You won!", 0
gridLabel  BYTE "Current Board:", 0
inputRow   DWORD ?
inputCol   DWORD ?
revealed   DWORD 0

.code
main PROC
    call Clrscr
    call Randomize
    call PlaceMines

gameLoop:
    call Clrscr
    ; Print board label in yellow
    mov eax, 14       ; yellow text
    call SetTextColor
    mov edx, OFFSET gridLabel
    call WriteString
    mov eax, 7        ; reset to light gray
    call SetTextColor
    call Crlf

    call DrawGrid

    ; Get row
getRow:
    mov eax, 14       ; yellow prompt
    call SetTextColor
    mov edx, OFFSET rowPrompt
    call WriteString
    mov eax, 7
    call SetTextColor
    call ReadInt
    mov inputRow, eax
    cmp eax, 0
    jl getRow ;check if less then zero, then invalid
    cmp eax, ROWS
    jae getRow ;check if greater than five, then invalid

    ; Get col
getCol:
    mov eax, 14
    call SetTextColor
    mov edx, OFFSET colPrompt
    call WriteString
    mov eax, 7
    call SetTextColor
    call ReadInt
    mov inputCol, eax
    cmp eax, 0
    jl getCol ;check if less then zero, then invalid
    cmp eax, COLS
    jae getCol ;check if greater than five, then invalid

    ; calculate index = row * COLS + col
    ; convert 2d array to 1d
    mov eax, inputRow
    mov ebx, COLS
    mul ebx
    add eax, inputCol     ; eax = index
    mov esi, eax

    ; check if already revealed
    mov al, visible[esi]
    cmp al, HIDDEN_CHAR
    jne gameLoop ;if not hidden, go back to gameLoop

    ; check for mine
    mov al, grid[esi]
    cmp al, 1
    je hitMine ;if yes, go to hitMine

    ; Safe cell
    mov visible[esi], SAFE_CHAR
    inc revealed

    ; Win condition
    mov eax, revealed
    cmp eax, (ROWS * COLS - NUM_MINES)
    je winGame

    jmp gameLoop

hitMine:
    call Clrscr
    call RevealAll

    ; Print board label in yellow again
    mov eax, 14
    call SetTextColor
    mov edx, OFFSET gridLabel
    call WriteString
    mov eax, 7
    call SetTextColor
    call Crlf

    call DrawGrid
    call Crlf

    mov eax, 14
    call SetTextColor
    mov edx, OFFSET mineMsg
    call WriteString
    mov eax, 7
    call SetTextColor
    call Crlf
    exit

winGame:
    call Clrscr
    call RevealAll

    mov eax, 14
    call SetTextColor
    mov edx, OFFSET gridLabel
    call WriteString
    mov eax, 7
    call SetTextColor
    call Crlf

    call DrawGrid
    call Crlf

    mov eax, 14
    call SetTextColor
    mov edx, OFFSET winMsg
    call WriteString
    mov eax, 7
    call SetTextColor
    call Crlf
    exit

main ENDP

;-----------------------------------------------
PlaceMines PROC
    mov ecx, NUM_MINES
placeLoop:
    mov eax, ROWS
    mov ebx, COLS
    mul ebx               ; eax = ROWS * COLS
    call RandomRange      ; eax = 0 .. (ROWS*COLS - 1)

    cmp grid[eax], 1 ; check if mine is already at this index
    je placeLoop

    mov grid[eax], 1
    loop placeLoop
    ret
PlaceMines ENDP

;-----------------------------------------------
DrawGrid PROC
    mov ecx, 0        ; row index
rowLoop:
    mov eax, ecx
    mov ebx, COLS
    mul ebx           ; eax = ecx * COLS
    mov esi, eax      ; start index of row

    mov ebx, 0        ; col index
colLoop:
    cmp ebx, COLS
    jae nextRow

    mov al, visible[esi]

    ; Set colors based on visible cell content
    cmp al, HIDDEN_CHAR
    je hiddenCell
    cmp al, SAFE_CHAR
    je safeCell
    cmp al, MINE_CHAR
    je mineCell

    ; Default colors for any other char
    mov eax, 7        ; light gray
    call SetTextColor
    jmp printChar

hiddenCell:
    mov eax, 8        ; dark gray for hidden
    call SetTextColor
    jmp printChar

safeCell:
    mov eax, 10       ; light green for safe
    call SetTextColor
    jmp printChar

mineCell:
    mov eax, 12       ; light red for mine
    call SetTextColor
    jmp printChar

printChar:
; print character and space then move to the next column
    mov al, visible[esi]
    call WriteChar
    mov al, ' '
    call WriteChar

    ; reset color to default white
    mov eax, 7
    call SetTextColor

    inc esi
    inc ebx
    jmp colLoop

nextRow:
; new line after each row
    call Crlf
    inc ecx
    cmp ecx, ROWS
    jl rowLoop
    ret
DrawGrid ENDP

;-----------------------------------------------
RevealAll PROC
    mov ecx, ROWS * COLS
    mov esi, 0
revealLoop:
    mov al, grid[esi]
    cmp al, 1 ;is it mine
    je showMine ;if it is mine, jump to showMine
    mov visible[esi], SAFE_CHAR
    jmp nextCell

showMine:
    mov visible[esi], MINE_CHAR

nextCell:
    inc esi
    loop revealLoop
    ret
RevealAll ENDP

END main
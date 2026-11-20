INCLUDE Irvine32.inc

BOARD_MAX = 10

AT_POS MACRO xv, yv, glyph, skip
    mov eax, curX
    cmp eax, xv
    jne skip
    mov eax, curY
    cmp eax, yv
    jne skip
    mov dl, glyph
    jmp DrawCharacter
ENDM

PICKUP MACRO xv, yv, flag, skip
    cmp flag, 0
    jne skip
    mov eax, playerX
    cmp eax, xv
    jne skip
    mov eax, playerY
    cmp eax, yv
    jne skip
    mov flag, 1
ENDM

.data
    gameBoardSize DWORD 10

    stateStart LABEL BYTE
    playerX DWORD 1
    playerY DWORD 1
    playerLives DWORD 3
    playerScore DWORD 0
    moveCount DWORD 0
    invincibleMoves DWORD 0
    coin1Collected BYTE 0
    coin2Collected BYTE 0
    coin3Collected BYTE 0
    powerUpCollected BYTE 0
    stateEnd LABEL BYTE

    obstacle1X DWORD 5
    obstacle1Y DWORD 5
    obstacle2X DWORD 6
    obstacle2Y DWORD 6
    obstacle3X DWORD 4
    obstacle3Y DWORD 7

    coin1X DWORD 3
    coin1Y DWORD 3
    coin2X DWORD 7
    coin2Y DWORD 4
    coin3X DWORD 8
    coin3Y DWORD 8

    powerUpX DWORD 5
    powerUpY DWORD 2

    goalX DWORD 10
    goalY DWORD 10

    curX DWORD 0
    curY DWORD 0

    saveFile BYTE "savegame.dat", 0
    scoreFile BYTE "highscore.dat", 0
    hFile DWORD 0
    bestScore DWORD 0
    stateBuf BYTE 64 DUP(0)

    startMsg BYTE "========================================", 0Dh, 0Ah
             BYTE "   ADVANCED CONSOLE MAZE GAME", 0Dh, 0Ah
             BYTE "========================================", 0Dh, 0Ah
             BYTE "Controls:", 0Dh, 0Ah
             BYTE "  W - Move Up    | S - Move Down", 0Dh, 0Ah
             BYTE "  A - Move Left  | D - Move Right", 0Dh, 0Ah
             BYTE "  F - Save Game  | L - Load Game", 0Dh, 0Ah
             BYTE "  Q - Quit Game", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "Game Elements:", 0Dh, 0Ah
             BYTE "  P - Player (You)", 0Dh, 0Ah
             BYTE "  G - Goal (Reach to win)", 0Dh, 0Ah
             BYTE "  X - Obstacles (Lose 1 life)", 0Dh, 0Ah
             BYTE "  $ - Coins (+10 points each)", 0Dh, 0Ah
             BYTE "  @ - Power-up (Invincibility)", 0Dh, 0Ah
             BYTE "  # - Border", 0Dh, 0Ah, 0Dh, 0Ah
             BYTE "Press L to load a saved game,", 0Dh, 0Ah
             BYTE "or any other key to start...", 0

    winMsg BYTE 0Dh, 0Ah, "========================================", 0Dh, 0Ah
           BYTE "  CONGRATULATIONS! YOU WON THE GAME!", 0Dh, 0Ah
           BYTE "========================================", 0Dh, 0Ah, 0

    gameOverMsg BYTE 0Dh, 0Ah, "========================================", 0Dh, 0Ah
                BYTE "        GAME OVER!", 0Dh, 0Ah
                BYTE "   You ran out of lives!", 0Dh, 0Ah
                BYTE "========================================", 0Dh, 0Ah, 0

    lostLifeMsg BYTE "You hit an obstacle! Lost 1 life.", 0Dh, 0Ah, 0
    coinCollectMsg BYTE "Coin collected! +10 points", 0Dh, 0Ah, 0
    powerUpMsg BYTE "Power-up! You're invincible for 5 moves!", 0Dh, 0Ah, 0
    savedMsg BYTE "Game saved to savegame.dat", 0Dh, 0Ah, 0
    loadedMsg BYTE "Game loaded from savegame.dat", 0Dh, 0Ah, 0
    saveFailMsg BYTE "Could not write savegame.dat!", 0Dh, 0Ah, 0
    loadFailMsg BYTE "No valid save file found.", 0Dh, 0Ah, 0
    newBestMsg BYTE "*** NEW HIGH SCORE! (saved to highscore.dat) ***", 0Dh, 0Ah, 0

    statusLine1 BYTE "========================================", 0
    livesStr BYTE "Lives: ", 0
    scoreStr BYTE " | Score: ", 0
    movesStr BYTE " | Moves: ", 0
    bestStr BYTE " | Best: ", 0
    invincibleStr BYTE " [INVINCIBLE]", 0
    finalScoreStr BYTE "Final Score: ", 0
    totalMovesStr BYTE "Total Moves: ", 0

.code
main PROC
    call LoadHighScore

    call Clrscr
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov edx, OFFSET startMsg
    call WriteString
    call ReadChar
    cmp al, 'l'
    je StartLoad
    cmp al, 'L'
    jne MainLoop
StartLoad:
    call LoadGame
    call Clrscr
    cmp eax, 1
    je MainLoop
    mov edx, OFFSET loadFailMsg
    call WriteString
    call WaitMsg

MainLoop:
    call Clrscr
    call DisplayStatus
    call RenderGameBoard

    call ReadChar
    mov bl, al

    cmp bl, 'A'
    jb CheckKeys
    cmp bl, 'Z'
    ja CheckKeys
    add bl, 20h

CheckKeys:
    cmp bl, 'q'
    je QuitGame
    cmp bl, 'f'
    je DoSave
    cmp bl, 'l'
    je DoLoad

    cmp bl, 'w'
    jne CheckDown
    cmp playerX, 1
    jle MainLoop
    dec playerX
    jmp Moved

CheckDown:
    cmp bl, 's'
    jne CheckLeft
    mov eax, gameBoardSize
    cmp playerX, eax
    jge MainLoop
    inc playerX
    jmp Moved

CheckLeft:
    cmp bl, 'a'
    jne CheckRight
    cmp playerY, 1
    jle MainLoop
    dec playerY
    jmp Moved

CheckRight:
    cmp bl, 'd'
    jne MainLoop
    mov eax, gameBoardSize
    cmp playerY, eax
    jge MainLoop
    inc playerY

Moved:
    inc moveCount
    cmp invincibleMoves, 0
    jle CheckCollectibles
    dec invincibleMoves

CheckCollectibles:
    PICKUP coin1X, coin1Y, coin1Collected, CheckCoin2
    add playerScore, 10
    mov edx, OFFSET coinCollectMsg
    call ShowPickupMsg
CheckCoin2:
    PICKUP coin2X, coin2Y, coin2Collected, CheckCoin3
    add playerScore, 10
    mov edx, OFFSET coinCollectMsg
    call ShowPickupMsg
CheckCoin3:
    PICKUP coin3X, coin3Y, coin3Collected, CheckPowerUp
    add playerScore, 10
    mov edx, OFFSET coinCollectMsg
    call ShowPickupMsg
CheckPowerUp:
    PICKUP powerUpX, powerUpY, powerUpCollected, CheckCollisions
    mov invincibleMoves, 5
    mov edx, OFFSET powerUpMsg
    call ShowPickupMsg

CheckCollisions:
    cmp invincibleMoves, 0
    jg CheckWin

    mov eax, playerX
    cmp eax, obstacle1X
    jne CheckObstacle2
    mov eax, playerY
    cmp eax, obstacle1Y
    je HitObstacle
CheckObstacle2:
    mov eax, playerX
    cmp eax, obstacle2X
    jne CheckObstacle3
    mov eax, playerY
    cmp eax, obstacle2Y
    je HitObstacle
CheckObstacle3:
    mov eax, playerX
    cmp eax, obstacle3X
    jne CheckWin
    mov eax, playerY
    cmp eax, obstacle3Y
    je HitObstacle

CheckWin:
    mov eax, playerX
    cmp eax, goalX
    jne MainLoop
    mov eax, playerY
    cmp eax, goalY
    jne MainLoop
    add playerScore, 50
    jmp WinState

DoSave:
    call SaveGame
    mov edx, OFFSET savedMsg
    cmp eax, 1
    je ShowSave
    mov edx, OFFSET saveFailMsg
ShowSave:
    call WriteString
    call WaitMsg
    jmp MainLoop

DoLoad:
    call LoadGame
    mov edx, OFFSET loadedMsg
    cmp eax, 1
    je ShowLoad
    mov edx, OFFSET loadFailMsg
ShowLoad:
    call WriteString
    call WaitMsg
    jmp MainLoop

HitObstacle:
    dec playerLives
    call Clrscr
    call DisplayStatus
    call RenderGameBoard
    mov edx, OFFSET lostLifeMsg
    call WriteString
    cmp playerLives, 0
    jle GameOver
    mov playerX, 1
    mov playerY, 1
    call WaitMsg
    jmp MainLoop

QuitGame:
    call ResetColor
    call Clrscr
    exit

WinState:
    call Clrscr
    call DisplayStatus
    call RenderGameBoard
    mov edx, OFFSET winMsg
    call WriteString
    call FinishGame
    exit

GameOver:
    call Clrscr
    call DisplayStatus
    call RenderGameBoard
    mov edx, OFFSET gameOverMsg
    call WriteString
    call FinishGame
    exit
main ENDP

ResetColor PROC
    push eax
    mov eax, lightGray + (black * 16)
    call SetTextColor
    pop eax
    ret
ResetColor ENDP

ShowPickupMsg PROC
    push eax
    mov eax, yellow + (black * 16)
    call SetTextColor
    call WriteString
    call WaitMsg
    pop eax
    ret
ShowPickupMsg ENDP

FinishGame PROC
    call DisplayFinalScore
    mov eax, playerScore
    cmp eax, bestScore
    jbe NoNewBest
    mov bestScore, eax
    call SaveHighScore
    mov edx, OFFSET newBestMsg
    call WriteString
NoNewBest:
    call WaitMsg
    call ResetColor
    call Clrscr
    ret
FinishGame ENDP

LoadHighScore PROC
    push edx
    mov edx, OFFSET scoreFile
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NoFile
    mov hFile, eax
    mov edx, OFFSET bestScore
    mov ecx, 4
    call ReadFromFile
    mov eax, hFile
    call CloseFile
NoFile:
    pop edx
    ret
LoadHighScore ENDP

SaveHighScore PROC
    push edx
    mov edx, OFFSET scoreFile
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je Done
    mov hFile, eax
    mov edx, OFFSET bestScore
    mov ecx, 4
    call WriteToFile
    mov eax, hFile
    call CloseFile
Done:
    pop edx
    ret
SaveHighScore ENDP

SaveGame PROC
    push ebx
    push ecx
    push edx
    mov edx, OFFSET saveFile
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je Fail
    mov hFile, eax
    mov edx, OFFSET stateStart
    mov ecx, stateEnd - stateStart
    call WriteToFile
    mov ebx, eax
    mov eax, hFile
    call CloseFile
    xor eax, eax
    cmp ebx, stateEnd - stateStart
    jne Fail
    mov eax, 1
Fail:
    pop edx
    pop ecx
    pop ebx
    ret
SaveGame ENDP

LoadGame PROC
    push ebx
    push ecx
    push edx
    push esi
    push edi
    mov edx, OFFSET saveFile
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je Fail
    mov hFile, eax
    mov edx, OFFSET stateBuf
    mov ecx, stateEnd - stateStart
    call ReadFromFile
    mov ebx, eax
    mov eax, hFile
    call CloseFile
    cmp ebx, stateEnd - stateStart
    jne Fail

    mov eax, DWORD PTR [stateBuf]
    cmp eax, 1
    jb Fail
    cmp eax, BOARD_MAX
    ja Fail
    mov eax, DWORD PTR [stateBuf + 4]
    cmp eax, 1
    jb Fail
    cmp eax, BOARD_MAX
    ja Fail
    mov eax, DWORD PTR [stateBuf + 8]
    cmp eax, 1
    jb Fail
    cmp eax, 3
    ja Fail

    cld
    mov esi, OFFSET stateBuf
    mov edi, OFFSET stateStart
    mov ecx, stateEnd - stateStart
    rep movsb
    mov eax, 1
    jmp Done
Fail:
    xor eax, eax
Done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
LoadGame ENDP

DisplayStatus PROC
    push eax
    push edx

    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov edx, OFFSET statusLine1
    call WriteString
    call Crlf

    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET livesStr
    call WriteString
    mov eax, playerLives
    call WriteDec

    mov edx, OFFSET scoreStr
    call WriteString
    mov eax, playerScore
    call WriteDec

    mov edx, OFFSET movesStr
    call WriteString
    mov eax, moveCount
    call WriteDec

    mov edx, OFFSET bestStr
    call WriteString
    mov eax, bestScore
    call WriteDec

    cmp invincibleMoves, 0
    jle SkipInvincible
    mov edx, OFFSET invincibleStr
    call WriteString
SkipInvincible:
    call Crlf
    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov edx, OFFSET statusLine1
    call WriteString
    call Crlf

    pop edx
    pop eax
    ret
DisplayStatus ENDP

DisplayFinalScore PROC
    push eax
    push edx
    call ResetColor
    mov edx, OFFSET finalScoreStr
    call WriteString
    mov eax, playerScore
    call WriteDec
    call Crlf
    mov edx, OFFSET totalMovesStr
    call WriteString
    mov eax, moveCount
    call WriteDec
    call Crlf
    call Crlf
    pop edx
    pop eax
    ret
DisplayFinalScore ENDP

RenderGameBoard PROC
    push ecx
    push eax

    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    call DrawBorder

    mov ecx, 1
DrawRowLoop:
    mov curX, ecx

    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov al, '#'
    call WriteChar
    mov al, ' '
    call WriteChar

    push ecx
    call RenderLine
    pop ecx

    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    mov al, '#'
    call WriteChar
    call Crlf

    inc ecx
    cmp ecx, gameBoardSize
    jle DrawRowLoop

    mov eax, lightMagenta + (black * 16)
    call SetTextColor
    call DrawBorder

    pop eax
    pop ecx
    ret
RenderGameBoard ENDP

DrawBorder PROC
    push ecx
    push eax

    mov ecx, gameBoardSize
    add ecx, 2
BorderLoop:
    mov al, '#'
    call WriteChar
    mov al, ' '
    call WriteChar
    dec ecx
    jnz BorderLoop
    call Crlf

    pop eax
    pop ecx
    ret
DrawBorder ENDP

RenderLine PROC
    push ecx
    push eax
    push edx

    mov ecx, 1
DrawColumnLoop:
    mov curY, ecx
    mov dl, '.'

    AT_POS playerX, playerY, 'P', CheckObst1
CheckObst1:
    AT_POS obstacle1X, obstacle1Y, 'X', CheckObst2
CheckObst2:
    AT_POS obstacle2X, obstacle2Y, 'X', CheckObst3
CheckObst3:
    AT_POS obstacle3X, obstacle3Y, 'X', CheckGoal
CheckGoal:
    AT_POS goalX, goalY, 'G', CheckC1
CheckC1:
    cmp coin1Collected, 0
    jne CheckC2
    AT_POS coin1X, coin1Y, '$', CheckC2
CheckC2:
    cmp coin2Collected, 0
    jne CheckC3
    AT_POS coin2X, coin2Y, '$', CheckC3
CheckC3:
    cmp coin3Collected, 0
    jne CheckPower
    AT_POS coin3X, coin3Y, '$', CheckPower
CheckPower:
    cmp powerUpCollected, 0
    jne DrawCharacter
    AT_POS powerUpX, powerUpY, '@', DrawCharacter

DrawCharacter:

    mov eax, lightMagenta + (black * 16)
    cmp dl, '.'
    je ColourSet
    mov eax, lightRed + (black * 16)
    cmp dl, 'X'
    je ColourSet
    mov eax, yellow + (black * 16)
    cmp dl, 'P'
    je ColourSet
    mov eax, white + (black * 16)
    cmp dl, 'G'
    je ColourSet
    mov eax, brown + (black * 16)
ColourSet:
    call SetTextColor
    mov al, dl
    call WriteChar
    mov al, ' '
    call WriteChar

    inc ecx
    cmp ecx, gameBoardSize
    jle DrawColumnLoop

    pop edx
    pop eax
    pop ecx
    ret
RenderLine ENDP

END main

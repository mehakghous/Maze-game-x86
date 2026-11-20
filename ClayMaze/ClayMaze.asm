.386
.model flat, stdcall
option casemap:none

GetModuleFileNameA   PROTO :DWORD, :DWORD, :DWORD
SetCurrentDirectoryA PROTO :DWORD
CreateFileA          PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ReadFile             PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteFile            PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
CloseHandle          PROTO :DWORD
DeleteFileA          PROTO :DWORD
ExitProcess          PROTO :DWORD
ShellExecuteA        PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WSAStartup           PROTO :DWORD, :DWORD
WSACleanup           PROTO
socket               PROTO :DWORD, :DWORD, :DWORD
bind                 PROTO :DWORD, :DWORD, :DWORD
listen               PROTO :DWORD, :DWORD
accept               PROTO :DWORD, :DWORD, :DWORD
recv                 PROTO :DWORD, :DWORD, :DWORD, :DWORD
send                 PROTO :DWORD, :DWORD, :DWORD, :DWORD
closesocket          PROTO :DWORD
select               PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
setsockopt           PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD

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

PUTS MACRO s
    mov esi, OFFSET s
    call AppendStr
ENDM
PUTN MACRO v
    mov eax, v
    call AppendDec
ENDM
PUTB MACRO v
    movzx eax, v
    call AppendDec
ENDM
PAIR MACRO xv, yv
    PUTN xv
    PUTS sComma
    PUTN yv
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

    gameState DWORD 0
    lastMsg   DWORD 0
    newBest   DWORD 0
    loadedSlot DWORD 0
    removedSlot DWORD 0
    bestScore DWORD 0
    quitFlag  DWORD 0

    histCount DWORD 0
    hsSum DWORD 0
    hsWins DWORD 0
    hsLoss DWORD 0
    hsBest DWORD 0
    hsMoves DWORD 0
    hsFirst DWORD 0
    histFile  BYTE "history.dat", 0
    saveFile  BYTE "savegame1.dat", 0
    scoreFile BYTE "highscore.dat", 0
    htmlFile  BYTE "ui\index.html", 0
    url       BYTE "http://127.0.0.1:8765/", 0
    verb      BYTE "open", 0

    sockAddr  WORD 2, 3D22h
              DWORD 0100007Fh
              DWORD 0, 0
    rcvTimeout DWORD 300
    fdCount   DWORD 1
    fdSock    DWORD 0
    fdRest    DWORD 63 DUP(0)
    tvSec     DWORD 120
    tvUsec    DWORD 0

    sOK       BYTE "HTTP/1.1 200 OK", 0
    s404      BYTE "HTTP/1.1 404 Not Found", 0
    tJson     BYTE "application/json", 0
    tHtml     BYTE "text/html; charset=utf-8", 0
    tText     BYTE "text/plain", 0
    hType     BYTE 0Dh, 0Ah, "Content-Type: ", 0
    hTail     BYTE 0Dh, 0Ah, "Cache-Control: no-store", 0Dh, 0Ah, "Connection: close", 0Dh, 0Ah, "Content-Length: ", 0
    hEnd      BYTE 0Dh, 0Ah, 0Dh, 0Ah, 0
    bodyNF    BYTE "Not found", 0
    bodyOK    BYTE "{}", 0

    rGet      BYTE "GET ", 0
    rMove     BYTE "/api/move?k=", 0
    rState    BYTE "/api/state", 0
    rSave     BYTE "/api/save?s=", 0
    rLoad     BYTE "/api/load?s=", 0
    rSlots    BYTE "/api/slots", 0
    sSlotsHdr BYTE '{"slots":[', 0
    sSlotOff  BYTE '[0,0,0,0]', 0
    sSlotOn   BYTE '[1,', 0
    rNew      BYTE "/api/new", 0
    rQuit     BYTE "/api/quit", 0
    rHist     BYTE "/api/history", 0
    rClear    BYTE "/api/clear", 0

    j1  BYTE '{"x":', 0
    j2  BYTE ',"y":', 0
    j3  BYTE ',"lives":', 0
    j4  BYTE ',"score":', 0
    j5  BYTE ',"moves":', 0
    j6  BYTE ',"shield":', 0
    j7  BYTE ',"best":', 0
    j8  BYTE ',"coins":[', 0
    j9  BYTE '],"power":', 0
    j10 BYTE ',"state":', 0
    j11 BYTE ',"msg":', 0
    j12 BYTE ',"newbest":', 0
    j18 BYTE ',"removed":', 0
    j13 BYTE ',"size":', 0
    j14 BYTE ',"obs":[[', 0
    j15 BYTE ',"coinpos":[[', 0
    j16 BYTE ',"powerpos":[', 0
    j17 BYTE '],"goal":[', 0
    h1 BYTE '{"games":', 0
    h2 BYTE ',"wins":', 0
    h3 BYTE ',"losses":', 0
    h4 BYTE ',"best":', 0
    h5 BYTE ',"avg":', 0
    h6 BYTE ',"moves":', 0
    h7 BYTE ',"winrate":', 0
    h8 BYTE ',"recent":[', 0
    sLB BYTE '[', 0
    sRB BYTE ']', 0
    sComma BYTE ',', 0
    sSep   BYTE '],[', 0
    sEnd2  BYTE ']]', 0
    sEnd   BYTE ']}', 0

.data?
    exePath  BYTE 600 DUP(?)
    wsaData  BYTE 400 DUP(?)
    stateBuf BYTE 64 DUP(?)
    reqBuf   BYTE 2048 DUP(?)
    hdrBuf   BYTE 512 DUP(?)
    outBuf   BYTE 2048 DUP(?)
    htmlBuf  BYTE 65536 DUP(?)
    histBuf  BYTE 6000 DUP(?)
    listenSock DWORD ?
    clientSock DWORD ?

.code

AppendStr PROC
    push eax
AS1:
    mov al, [esi]
    test al, al
    jz AS2
    mov [edi], al
    inc esi
    inc edi
    jmp AS1
AS2:
    pop eax
    ret
AppendStr ENDP

AppendDec PROC
    push ebx
    push ecx
    push edx
    mov ebx, 10
    xor ecx, ecx
AD1:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz AD1
AD2:
    pop edx
    add dl, '0'
    mov [edi], dl
    inc edi
    loop AD2
    pop edx
    pop ecx
    pop ebx
    ret
AppendDec ENDP

Prefix PROC
    push esi
    push edi
PF1:
    mov al, [edi]
    test al, al
    jz PFYes
    cmp al, [esi]
    jne PFNo
    inc esi
    inc edi
    jmp PF1
PFYes:
    mov eax, 1
    jmp PFOut
PFNo:
    xor eax, eax
PFOut:
    pop edi
    pop esi
    ret
Prefix ENDP

ReadFileBlob PROC USES ebx, pName:DWORD, pBuf:DWORD, nMax:DWORD
    LOCAL hF:DWORD, got:DWORD
    mov got, 0
    invoke CreateFileA, pName, 80000000h, 1, 0, 3, 80h, 0
    cmp eax, -1
    je RFFail
    mov hF, eax
    invoke ReadFile, hF, pBuf, nMax, ADDR got, 0
    invoke CloseHandle, hF
    mov eax, got
    ret
RFFail:
    xor eax, eax
    ret
ReadFileBlob ENDP

WriteFileBlob PROC USES ebx, pName:DWORD, pBuf:DWORD, nLen:DWORD
    LOCAL hF:DWORD, wrote:DWORD
    mov wrote, 0
    invoke CreateFileA, pName, 40000000h, 0, 0, 2, 80h, 0
    cmp eax, -1
    je WFFail
    mov hF, eax
    invoke WriteFile, hF, pBuf, nLen, ADDR wrote, 0
    invoke CloseHandle, hF
    mov eax, wrote
    cmp eax, nLen
    jne WFFail
    mov eax, 1
    ret
WFFail:
    xor eax, eax
    ret
WriteFileBlob ENDP

SetSlot PROC
    cmp bl, '1'
    jb SSDef
    cmp bl, '3'
    ja SSDef
    mov saveFile[8], bl
    ret
SSDef:
    mov saveFile[8], '1'
    ret
SetSlot ENDP

BuildSlotsJson PROC
    push esi
    push edi
    push ebx
    mov edi, OFFSET outBuf
    PUTS sSlotsHdr
    mov ebx, '1'
SLLoop:
    mov saveFile[8], bl
    invoke ReadFileBlob, OFFSET saveFile, OFFSET stateBuf, stateEnd - stateStart
    cmp ebx, '1'
    je SLNoComma
    PUTS sComma
SLNoComma:
    cmp eax, stateEnd - stateStart
    jne SLEmpty
    PUTS sSlotOn
    PUTN DWORD PTR stateBuf[12]
    PUTS sComma
    PUTN DWORD PTR stateBuf[16]
    PUTS sComma
    PUTN DWORD PTR stateBuf[8]
    PUTS sRB
    jmp SLNext
SLEmpty:
    PUTS sSlotOff
SLNext:
    inc ebx
    cmp ebx, '3'
    jle SLLoop
    PUTS sEnd
    mov eax, edi
    sub eax, OFFSET outBuf
    pop ebx
    pop edi
    pop esi
    ret
BuildSlotsJson ENDP

SaveGame PROC
    invoke WriteFileBlob, OFFSET saveFile, OFFSET stateStart, stateEnd - stateStart
    mov lastMsg, 6
    test eax, eax
    jnz SGOk
    mov lastMsg, 8
SGOk:
    ret
SaveGame ENDP

LoadGame PROC
    push esi
    push edi
    push ecx
    invoke ReadFileBlob, OFFSET saveFile, OFFSET stateBuf, stateEnd - stateStart
    cmp eax, stateEnd - stateStart
    jne LGFail
    mov eax, DWORD PTR [stateBuf]
    cmp eax, 1
    jb LGFail
    cmp eax, 10
    ja LGFail
    mov eax, DWORD PTR [stateBuf + 4]
    cmp eax, 1
    jb LGFail
    cmp eax, 10
    ja LGFail
    mov eax, DWORD PTR [stateBuf + 8]
    cmp eax, 1
    jb LGFail
    cmp eax, 3
    ja LGFail
    mov eax, DWORD PTR [stateBuf + 20]
    cmp eax, 5
    ja LGFail
    cld
    mov esi, OFFSET stateBuf
    mov edi, OFFSET stateStart
    mov ecx, stateEnd - stateStart
    rep movsb
    mov gameState, 0
    mov newBest, 0
    mov lastMsg, 7
    movzx eax, BYTE PTR saveFile[8]
    sub eax, '0'
    mov loadedSlot, eax
    mov removedSlot, 0
    jmp LGOut
LGFail:
    mov lastMsg, 9
LGOut:
    pop ecx
    pop edi
    pop esi
    ret
LoadGame ENDP

NewGame PROC
    mov playerX, 1
    mov playerY, 1
    mov playerLives, 3
    mov playerScore, 0
    mov moveCount, 0
    mov invincibleMoves, 0
    mov coin1Collected, 0
    mov coin2Collected, 0
    mov coin3Collected, 0
    mov powerUpCollected, 0
    mov gameState, 0
    mov lastMsg, 0
    mov newBest, 0
    mov loadedSlot, 0
    mov removedSlot, 0
    ret
NewGame ENDP

Finish PROC
    cmp loadedSlot, 0
    je FNoSlot
    mov eax, loadedSlot
    add al, '0'
    mov saveFile[8], al
    invoke DeleteFileA, OFFSET saveFile
    mov eax, loadedSlot
    mov removedSlot, eax
    mov loadedSlot, 0
FNoSlot:
    mov eax, playerScore
    cmp eax, bestScore
    jbe FNoBest
    mov bestScore, eax
    mov newBest, 1
    invoke WriteFileBlob, OFFSET scoreFile, OFFSET bestScore, 4
FNoBest:

    push esi
    push edi
    push ecx
    cmp histCount, 500
    jb FAppend
    cld
    mov esi, OFFSET histBuf + 12
    mov edi, OFFSET histBuf
    mov ecx, 499 * 12
    rep movsb
    mov histCount, 499
FAppend:
    imul edx, histCount, 12
    mov eax, playerScore
    mov DWORD PTR histBuf[edx], eax
    mov eax, moveCount
    mov DWORD PTR histBuf[edx + 4], eax
    mov eax, gameState
    mov DWORD PTR histBuf[edx + 8], eax
    inc histCount
    imul eax, histCount, 12
    invoke WriteFileBlob, OFFSET histFile, OFFSET histBuf, eax
    pop ecx
    pop edi
    pop esi
    ret
Finish ENDP

BuildHistJson PROC
    push esi
    push edi
    push ebx
    push ecx
    mov hsSum, 0
    mov hsWins, 0
    mov hsLoss, 0
    mov hsBest, 0
    mov hsMoves, 0
    mov esi, OFFSET histBuf
    mov ecx, histCount
    test ecx, ecx
    jz HSDone
HSLoop:
    mov eax, [esi]
    add hsSum, eax
    cmp eax, hsBest
    jbe HSNoBest
    mov hsBest, eax
HSNoBest:
    mov eax, [esi + 4]
    add hsMoves, eax
    cmp DWORD PTR [esi + 8], 1
    jne HSLost
    inc hsWins
    jmp HSNext
HSLost:
    inc hsLoss
HSNext:
    add esi, 12
    dec ecx
    jnz HSLoop
HSDone:
    mov edi, OFFSET outBuf
    PUTS h1
    PUTN histCount
    PUTS h2
    PUTN hsWins
    PUTS h3
    PUTN hsLoss
    PUTS h4
    PUTN hsBest
    PUTS h5
    xor ebx, ebx
    cmp histCount, 0
    je HSAvg
    xor edx, edx
    mov eax, hsSum
    div histCount
    mov ebx, eax
HSAvg:
    mov eax, ebx
    call AppendDec
    PUTS h6
    PUTN hsMoves
    PUTS h7
    xor ebx, ebx
    cmp histCount, 0
    je HSRate
    mov eax, hsWins
    imul eax, 100
    xor edx, edx
    div histCount
    mov ebx, eax
HSRate:
    mov eax, ebx
    call AppendDec
    PUTS h8
    mov ecx, histCount
    mov ebx, 10
    mov hsFirst, 1
HRLoop2:
    test ecx, ecx
    jz HREnd
    test ebx, ebx
    jz HREnd
    dec ecx
    dec ebx
    imul edx, ecx, 12
    cmp hsFirst, 1
    je HRNoComma
    PUTS sComma
HRNoComma:
    mov hsFirst, 0
    PUTS sLB
    mov eax, DWORD PTR histBuf[edx]
    call AppendDec
    PUTS sComma
    mov eax, DWORD PTR histBuf[edx + 4]
    call AppendDec
    PUTS sComma
    mov eax, DWORD PTR histBuf[edx + 8]
    call AppendDec
    PUTS sRB
    jmp HRLoop2
HREnd:
    PUTS sEnd
    mov eax, edi
    sub eax, OFFSET outBuf
    pop ecx
    pop ebx
    pop edi
    pop esi
    ret
BuildHistJson ENDP

ApplyMove PROC
    mov lastMsg, 0
    cmp gameState, 0
    jne AMDone

    cmp bl, 'w'
    jne AMDown
    cmp playerX, 1
    jle AMDone
    dec playerX
    jmp AMMoved
AMDown:
    cmp bl, 's'
    jne AMLeft
    mov eax, gameBoardSize
    cmp playerX, eax
    jge AMDone
    inc playerX
    jmp AMMoved
AMLeft:
    cmp bl, 'a'
    jne AMRight
    cmp playerY, 1
    jle AMDone
    dec playerY
    jmp AMMoved
AMRight:
    cmp bl, 'd'
    jne AMDone
    mov eax, gameBoardSize
    cmp playerY, eax
    jge AMDone
    inc playerY

AMMoved:
    inc moveCount
    cmp invincibleMoves, 0
    jle AMItems
    dec invincibleMoves

AMItems:
    PICKUP coin1X, coin1Y, coin1Collected, AMC2
    add playerScore, 10
    mov lastMsg, 1
AMC2:
    PICKUP coin2X, coin2Y, coin2Collected, AMC3
    add playerScore, 10
    mov lastMsg, 1
AMC3:
    PICKUP coin3X, coin3Y, coin3Collected, AMPow
    add playerScore, 10
    mov lastMsg, 1
AMPow:
    PICKUP powerUpX, powerUpY, powerUpCollected, AMColl
    mov invincibleMoves, 5
    mov lastMsg, 2

AMColl:
    cmp invincibleMoves, 0
    jg AMWin
    mov eax, playerX
    cmp eax, obstacle1X
    jne AMO2
    mov eax, playerY
    cmp eax, obstacle1Y
    je AMHit
AMO2:
    mov eax, playerX
    cmp eax, obstacle2X
    jne AMO3
    mov eax, playerY
    cmp eax, obstacle2Y
    je AMHit
AMO3:
    mov eax, playerX
    cmp eax, obstacle3X
    jne AMWin
    mov eax, playerY
    cmp eax, obstacle3Y
    je AMHit

AMWin:
    mov eax, playerX
    cmp eax, goalX
    jne AMDone
    mov eax, playerY
    cmp eax, goalY
    jne AMDone
    add playerScore, 50
    mov gameState, 1
    mov lastMsg, 4
    call Finish
    jmp AMDone

AMHit:
    dec playerLives
    mov lastMsg, 3
    cmp playerLives, 0
    jg AMReset
    mov gameState, 2
    mov lastMsg, 5
    call Finish
    jmp AMDone
AMReset:
    mov playerX, 1
    mov playerY, 1
AMDone:
    ret
ApplyMove ENDP

BuildJson PROC
    push esi
    push edi
    mov edi, OFFSET outBuf
    PUTS j1
    PUTN playerX
    PUTS j2
    PUTN playerY
    PUTS j3
    PUTN playerLives
    PUTS j4
    PUTN playerScore
    PUTS j5
    PUTN moveCount
    PUTS j6
    PUTN invincibleMoves
    PUTS j7
    PUTN bestScore
    PUTS j8
    PUTB coin1Collected
    PUTS sComma
    PUTB coin2Collected
    PUTS sComma
    PUTB coin3Collected
    PUTS j9
    PUTB powerUpCollected
    PUTS j10
    PUTN gameState
    PUTS j11
    PUTN lastMsg
    PUTS j12
    PUTN newBest
    PUTS j18
    PUTN removedSlot
    PUTS j13
    PUTN gameBoardSize
    PUTS j14
    PAIR obstacle1X, obstacle1Y
    PUTS sSep
    PAIR obstacle2X, obstacle2Y
    PUTS sSep
    PAIR obstacle3X, obstacle3Y
    PUTS sEnd2
    PUTS j15
    PAIR coin1X, coin1Y
    PUTS sSep
    PAIR coin2X, coin2Y
    PUTS sSep
    PAIR coin3X, coin3Y
    PUTS sEnd2
    PUTS j16
    PAIR powerUpX, powerUpY
    PUTS j17
    PAIR goalX, goalY
    PUTS sEnd
    mov eax, edi
    sub eax, OFFSET outBuf
    pop edi
    pop esi
    ret
BuildJson ENDP

SendResponse PROC USES ebx esi edi, pStatus:DWORD, pType:DWORD, pBody:DWORD, nBody:DWORD
    mov edi, OFFSET hdrBuf
    mov esi, pStatus
    call AppendStr
    mov esi, OFFSET hType
    call AppendStr
    mov esi, pType
    call AppendStr
    mov esi, OFFSET hTail
    call AppendStr
    mov eax, nBody
    call AppendDec
    mov esi, OFFSET hEnd
    call AppendStr
    mov ebx, edi
    sub ebx, OFFSET hdrBuf
    invoke send, clientSock, OFFSET hdrBuf, ebx, 0
    invoke send, clientSock, pBody, nBody, 0
    ret
SendResponse ENDP

SendState PROC
    call BuildJson
    invoke SendResponse, OFFSET sOK, OFFSET tJson, OFFSET outBuf, eax
    mov lastMsg, 0
    ret
SendState ENDP

HandleRequest PROC
    mov esi, OFFSET reqBuf
    mov edi, OFFSET rGet
    call Prefix
    test eax, eax
    jz HRNotFound

    mov esi, OFFSET reqBuf + 4
    mov edi, OFFSET rMove
    call Prefix
    test eax, eax
    jz HRState
    movzx ebx, BYTE PTR [reqBuf + 16]
    cmp bl, 'A'
    jb HRKey
    cmp bl, 'Z'
    ja HRKey
    add bl, 20h
HRKey:
    call ApplyMove
    call SendState
    ret

HRState:
    mov edi, OFFSET rState
    call Prefix
    test eax, eax
    jz HRSave
    call SendState
    ret
HRSave:
    mov edi, OFFSET rSave
    call Prefix
    test eax, eax
    jz HRLoad
    movzx ebx, BYTE PTR [reqBuf + 16]
    call SetSlot
    call SaveGame
    call SendState
    ret
HRLoad:
    mov edi, OFFSET rLoad
    call Prefix
    test eax, eax
    jz HRNew
    movzx ebx, BYTE PTR [reqBuf + 16]
    call SetSlot
    call LoadGame
    call SendState
    ret
HRNew:
    mov edi, OFFSET rNew
    call Prefix
    test eax, eax
    jz HRHist
    call NewGame
    call SendState
    ret
HRHist:
    mov edi, OFFSET rHist
    call Prefix
    test eax, eax
    jz HRClear
    call BuildHistJson
    invoke SendResponse, OFFSET sOK, OFFSET tJson, OFFSET outBuf, eax
    ret
HRClear:
    mov edi, OFFSET rClear
    call Prefix
    test eax, eax
    jz HRSlots
    mov histCount, 0
    invoke WriteFileBlob, OFFSET histFile, OFFSET histBuf, 0
    call BuildHistJson
    invoke SendResponse, OFFSET sOK, OFFSET tJson, OFFSET outBuf, eax
    ret
HRSlots:
    mov edi, OFFSET rSlots
    call Prefix
    test eax, eax
    jz HRQuit
    call BuildSlotsJson
    invoke SendResponse, OFFSET sOK, OFFSET tJson, OFFSET outBuf, eax
    ret
HRQuit:
    mov edi, OFFSET rQuit
    call Prefix
    test eax, eax
    jz HRRoot
    mov quitFlag, 1
    invoke SendResponse, OFFSET sOK, OFFSET tJson, OFFSET bodyOK, 2
    ret
HRRoot:
    cmp BYTE PTR [reqBuf + 4], '/'
    jne HRNotFound
    mov al, BYTE PTR [reqBuf + 5]
    cmp al, ' '
    je HRPage
    cmp al, '?'
    jne HRNotFound
HRPage:
    invoke ReadFileBlob, OFFSET htmlFile, OFFSET htmlBuf, 65535
    test eax, eax
    jz HRNotFound
    invoke SendResponse, OFFSET sOK, OFFSET tHtml, OFFSET htmlBuf, eax
    ret
HRNotFound:
    invoke SendResponse, OFFSET s404, OFFSET tText, OFFSET bodyNF, 9
    ret
HandleRequest ENDP

main PROC

    invoke GetModuleFileNameA, 0, OFFSET exePath, 500
    mov ecx, eax
MFind:
    dec ecx
    jl MDir
    cmp exePath[ecx], '\'
    jne MFind
    mov exePath[ecx], 0
MDir:
    invoke SetCurrentDirectoryA, OFFSET exePath

    invoke ReadFileBlob, OFFSET scoreFile, OFFSET bestScore, 4
    invoke ReadFileBlob, OFFSET histFile, OFFSET histBuf, 6000
    xor edx, edx
    mov ecx, 12
    div ecx
    mov histCount, eax

    invoke WSAStartup, 0202h, OFFSET wsaData
    invoke socket, 2, 1, 6
    mov listenSock, eax
    invoke bind, listenSock, OFFSET sockAddr, 16
    test eax, eax
    jnz MAlready
    invoke listen, listenSock, 5
    invoke ShellExecuteA, 0, OFFSET verb, OFFSET url, 0, 0, 1

ServerLoop:
    mov fdCount, 1
    mov eax, listenSock
    mov fdSock, eax
    mov tvSec, 120
    invoke select, 0, OFFSET fdCount, 0, 0, OFFSET tvSec
    cmp eax, 1
    jl MShutdown
    invoke accept, listenSock, 0, 0
    cmp eax, -1
    je ServerLoop
    mov clientSock, eax
    invoke setsockopt, clientSock, 0FFFFh, 1006h, OFFSET rcvTimeout, 4
    invoke recv, clientSock, OFFSET reqBuf, 2047, 0
    cmp eax, 0
    jle MCloseClient
    mov BYTE PTR [reqBuf + eax], 0
    call HandleRequest
MCloseClient:
    invoke closesocket, clientSock
    cmp quitFlag, 1
    jne ServerLoop

MShutdown:
    invoke closesocket, listenSock
    invoke WSACleanup
    invoke ExitProcess, 0
MAlready:
    invoke ShellExecuteA, 0, OFFSET verb, OFFSET url, 0, 0, 1
    invoke ExitProcess, 0
main ENDP
END main

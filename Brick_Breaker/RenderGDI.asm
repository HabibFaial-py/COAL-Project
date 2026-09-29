; =========================================================================
; RenderGDI.asm - Render Engine (HUD, Per-Level Scores & Orb Rendering)
; =========================================================================
RenderFrameGDI PROC hwnd:DWORD
    LOCAL ps:PAINTSTRUCT
    LOCAL hdc:DWORD
    LOCAL memDC:DWORD
    LOCAL hbm:DWORD
    LOCAL hOldBm:DWORD
    LOCAL rc:RECT
    LOCAL textRc:RECT
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL iRow:DWORD
    LOCAL iCol:DWORD
    LOCAL idx:DWORD
    LOCAL posX:DWORD
    LOCAL posY:DWORD
    LOCAL color:DWORD

    lea eax, ps
    push eax
    push hwnd
    call BeginPaint@8
    mov hdc, eax

    lea eax, rc
    push eax
    push hwnd
    call GetClientRect@8

    push hdc
    call CreateCompatibleDC@4
    mov memDC, eax

    push rc.bottom
    push rc.right
    push hdc
    call CreateCompatibleBitmap@12
    mov hbm, eax

    push hbm
    push memDC
    call SelectObject@8
    mov hOldBm, eax

    push 00000000h
    call CreateSolidBrush@4
    mov hBrush, eax

    push hBrush
    push memDC
    call SelectObject@8
    mov hOldBrush, eax

    push rc.bottom
    push rc.right
    push 0
    push 0
    push memDC
    call Rectangle@20

    push hBrush
    call DeleteObject@4

    push 1
    push memDC
    call SetBkMode@8

    ; =========================================================================
    ; TITLE MENU (GameState == 0)
    ; =========================================================================
    cmp GameState, 0
    jne DrawGamePage

    push 0000FFFFh
    push memDC
    call SetTextColor@8

    mov textRc.left, 50
    mov textRc.top, 100
    mov textRc.right, 750
    mov textRc.bottom, 150

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szTitleText
    push memDC
    call DrawTextA@20

    push 00FFFFFFh
    push memDC
    call SetTextColor@8

    mov textRc.top, 160
    mov textRc.bottom, 200

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szSubTitle
    push memDC
    call DrawTextA@20

    ; Retrieve Per-Level Best Time from Array
    mov eax, CurrentLevel
    dec eax
    imul eax, 4
    mov edx, OFFSET BestTimeArray
    add edx, eax
    mov eax, DWORD PTR [edx]

    cmp eax, 9999
    jne FormatBest
    mov eax, 0

FormatBest:
    push eax
    push CurrentLevel
    push OFFSET szLevelText
    push OFFSET szLevelBuffer
    call wsprintfA
    add esp, 16

    push 0000FF00h
    push memDC
    call SetTextColor@8

    mov textRc.top, 380
    mov textRc.bottom, 420

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szLevelBuffer
    push memDC
    call DrawTextA@20

    jmp BlitBuffer

    ; =========================================================================
    ; GAMEPLAY PAGE (GameState >= 1)
    ; =========================================================================
DrawGamePage:
    push 00FFFFFFh
    push memDC
    call SetTextColor@8

    push ElapsedTime
    push CurrentLevel
    push Lives
    push Score
    push OFFSET szHudFormat
    push OFFSET szHudBuffer
    call wsprintfA
    add esp, 24

    mov textRc.left, 50
    mov textRc.top, 10
    mov textRc.right, 750
    mov textRc.bottom, 40

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szHudBuffer
    push memDC
    call DrawTextA@20

    ; Render Bricks
    mov iRow, 0
RowLoop:
    cmp iRow, BRICK_ROWS
    jge EndRows
    mov iCol, 0

ColLoop:
    cmp iCol, BRICK_COLS
    jge NextRow

    mov eax, iRow
    imul eax, BRICK_COLS
    add eax, iCol
    mov idx, eax

    mov edx, OFFSET BrickArray
    add edx, idx
    movzx eax, BYTE PTR [edx]
    cmp eax, 0
    je SkipBrick

    cmp eax, 1
    je ColorRed
    cmp eax, 2
    je ColorYellow
    mov color, 0000FF00h
    jmp DrawB

ColorRed:
    mov color, 000000FFh
    jmp DrawB

ColorYellow:
    mov color, 0000FFFFh

DrawB:
    mov eax, iCol
    imul eax, BRICK_WIDTH
    add eax, BRICK_OFFSET_X
    mov posX, eax

    mov eax, iRow
    imul eax, BRICK_HEIGHT
    add eax, BRICK_OFFSET_Y
    mov posY, eax

    push color
    call CreateSolidBrush@4
    mov hBrush, eax

    push hBrush
    push memDC
    call SelectObject@8

    mov eax, posY
    add eax, BRICK_HEIGHT
    push eax
    mov eax, posX
    add eax, BRICK_WIDTH
    push eax
    push posY
    push posX
    push memDC
    call Rectangle@20

    push hBrush
    call DeleteObject@4

SkipBrick:
    inc iCol
    jmp ColLoop

NextRow:
    inc iRow
    jmp RowLoop

EndRows:

    ; Render Falling Power-Up Orb
    cmp PowerUpActive, 1
    jne SkipPowerUp

    push 00FF00FFh ; Magenta Orb
    call CreateSolidBrush@4
    mov hBrush, eax

    push hBrush
    push memDC
    call SelectObject@8

    mov eax, PowerUpY
    add eax, 12
    push eax
    mov eax, PowerUpX
    add eax, 12
    push eax
    mov eax, PowerUpY
    sub eax, 12
    push eax
    mov eax, PowerUpX
    sub eax, 12
    push eax
    push memDC
    call Ellipse@20

    push hBrush
    call DeleteObject@4

SkipPowerUp:

    ; Draw Paddle
    push 00FFFFFFh
    call CreateSolidBrush@4
    mov hBrush, eax

    push hBrush
    push memDC
    call SelectObject@8

    mov eax, PaddleY
    add eax, PaddleH
    push eax
    mov eax, PaddleX
    add eax, PaddleW
    push eax
    push PaddleY
    push PaddleX
    push memDC
    call Rectangle@20

    push hBrush
    call DeleteObject@4

    ; Draw Primary Ball
    push 00FFFF00h
    call CreateSolidBrush@4
    mov hBrush, eax

    push hBrush
    push memDC
    call SelectObject@8

    mov eax, BallY
    add eax, BallRadius
    push eax
    mov eax, BallX
    add eax, BallRadius
    push eax
    mov eax, BallY
    sub eax, BallRadius
    push eax
    mov eax, BallX
    sub eax, BallRadius
    push eax
    push memDC
    call Ellipse@20

    push hBrush
    call DeleteObject@4

    ; Draw Secondary Ball (if active)
    cmp Ball2InPlay, 1
    jne SkipBall2

    push 0000FFFFh ; Cyan Multi-Ball
    call CreateSolidBrush@4
    mov hBrush, eax

    push hBrush
    push memDC
    call SelectObject@8

    mov eax, Ball2Y
    add eax, BallRadius
    push eax
    mov eax, Ball2X
    add eax, BallRadius
    push eax
    mov eax, Ball2Y
    sub eax, BallRadius
    push eax
    mov eax, Ball2X
    sub eax, BallRadius
    push eax
    push memDC
    call Ellipse@20

    push hBrush
    call DeleteObject@4

SkipBall2:

    ; Overlay Messages
    cmp GameState, 2
    je DrawGameOverMsg
    cmp GameState, 3
    je DrawVictoryMsg
    cmp BallInPlay, 0
    je DrawLaunchMsg
    jmp BlitBuffer

DrawGameOverMsg:
    push 000000FFh
    push memDC
    call SetTextColor@8

    mov textRc.left, 50
    mov textRc.top, 280
    mov textRc.right, 750
    mov textRc.bottom, 320

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szGameOver
    push memDC
    call DrawTextA@20
    jmp BlitBuffer

DrawVictoryMsg:
    push 0000FF00h
    push memDC
    call SetTextColor@8

    push ElapsedTime
    push OFFSET szVictory
    push OFFSET szVictoryBuffer
    call wsprintfA
    add esp, 12

    mov textRc.left, 50
    mov textRc.top, 280
    mov textRc.right, 750
    mov textRc.bottom, 320

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szVictoryBuffer
    push memDC
    call DrawTextA@20
    jmp BlitBuffer

DrawLaunchMsg:
    push 0000FFFFh
    push memDC
    call SetTextColor@8

    mov textRc.left, 50
    mov textRc.top, 280
    mov textRc.right, 750
    mov textRc.bottom, 320

    push DWORD PTR (DT_SINGLELINE or DT_CENTER)
    lea eax, textRc
    push eax
    push -1
    push OFFSET szLaunchMsg
    push memDC
    call DrawTextA@20

BlitBuffer:
    push 00CC0020h
    push 0
    push 0
    push memDC
    push rc.bottom
    push rc.right
    push 0
    push 0
    push hdc
    call BitBlt@36

    push hOldBm
    push memDC
    call SelectObject@8

    push hbm
    call DeleteObject@4

    push memDC
    call DeleteDC@4

    lea eax, ps
    push eax
    push hwnd
    call EndPaint@8

    ret
RenderFrameGDI ENDP
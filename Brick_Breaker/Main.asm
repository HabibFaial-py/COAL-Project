; =========================================================================
; Main.asm - Orchestrator with END GAME Button & State Router
; =========================================================================
include GameVars.inc

EXTERN UpdateWindow@4 : PROC

.data
szClassName  BYTE "GDI_BrickBreaker_Class", 0
szTitle      BYTE "Brick-Breaker x86 MASM | Win32 GDI Engine", 0
szBtnClass   BYTE "BUTTON", 0
szStartTxt   BYTE "START GAME", 0
szLevelTxt   BYTE "CHANGE LEVEL", 0
szEndTxt     BYTE "END GAME", 0

.code

ToggleMenuButtons PROC
    cmp GameState, 0
    je ShowMenuBtns

    push SW_HIDE
    push hwndBtnStart
    call ShowWindow@8

    push SW_HIDE
    push hwndBtnLevel
    call ShowWindow@8

    push SW_SHOW
    push hwndBtnEnd
    call ShowWindow@8
    ret

ShowMenuBtns:
    push SW_SHOW
    push hwndBtnStart
    call ShowWindow@8

    push SW_SHOW
    push hwndBtnLevel
    call ShowWindow@8

    push SW_HIDE
    push hwndBtnEnd
    call ShowWindow@8
    ret
ToggleMenuButtons ENDP

WndProc PROC hwnd:DWORD, msg:DWORD, wParam:DWORD, lParam:DWORD
    cmp msg, WM_COMMAND
    je OnCommand

    cmp msg, WM_TIMER
    je OnTimer

    cmp msg, WM_KEYDOWN
    je OnKeyDown

    cmp msg, WM_PAINT
    je OnPaint

    cmp msg, WM_DESTROY
    je OnDestroy

    push lParam
    push wParam
    push msg
    push hwnd
    call DefWindowProcA@16
    ret

OnCommand:
    mov eax, wParam
    movzx eax, ax

    cmp eax, ID_BTN_START
    je StartClicked

    cmp eax, ID_BTN_LEVEL
    je LevelClicked

    cmp eax, ID_BTN_END
    je EndClicked
    ret

StartClicked:
    call ResetGame
    mov BallInPlay, 1
    call ToggleMenuButtons
    push hwnd
    call SetFocus@4
    push hwnd
    call InvalidateRect@12
    ret

LevelClicked:
    inc CurrentLevel
    cmp CurrentLevel, 3
    jle LevelSet
    mov CurrentLevel, 1

LevelSet:
    cmp GameState, 0
    je RefreshMenu
    call ResetGame
    call ToggleMenuButtons

RefreshMenu:
    push hwnd
    call SetFocus@4
    push hwnd
    call InvalidateRect@12
    ret

EndClicked:
    mov GameState, 0
    mov BallInPlay, 0
    call ToggleMenuButtons
    push hwnd
    call SetFocus@4
    push hwnd
    call InvalidateRect@12
    ret

OnTimer:
    call UpdatePhysics
    push 0
    push 0
    push hwnd
    call InvalidateRect@12
    ret

OnKeyDown:
    cmp wParam, VK_LEFT
    jne CheckRightKey
    mov eax, PaddleX
    cmp eax, 20
    jle KeyDone
    sub eax, 25
    mov PaddleX, eax
    jmp KeyDone

CheckRightKey:
    cmp wParam, VK_RIGHT
    jne CheckSpaceKey
    mov eax, PaddleX
    add eax, PaddleW
    cmp eax, 760
    jge KeyDone
    add PaddleX, 25
    jmp KeyDone

CheckSpaceKey:
    cmp wParam, VK_SPACE
    jne KeyDone

    cmp GameState, 0
    je StartFromMenu
    cmp GameState, 2
    je StartFromMenu
    cmp GameState, 3
    je StartFromMenu

    mov BallInPlay, 1
    jmp KeyDone

StartFromMenu:
    call ResetGame
    mov BallInPlay, 1
    call ToggleMenuButtons

KeyDone:
    ret

OnPaint:
    push hwnd
    call RenderFrameGDI
    ret

OnDestroy:
    push 1
    push hwnd
    call KillTimer@8

    push 0
    call PostQuitMessage@4
    ret
WndProc ENDP

WinMain PROC
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize, sizeof WNDCLASSEX
    mov wc.style, 3
    mov wc.lpfnWndProc, OFFSET WndProc
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov wc.hInstance, 0
    mov wc.hIcon, 0
    mov wc.hCursor, 0
    mov wc.hbrBackground, 0
    mov wc.lpszMenuName, 0
    mov wc.lpszClassName, OFFSET szClassName
    mov wc.hIconSm, 0

    lea eax, wc
    push eax
    call RegisterClassExA@4

    push 0
    push 0
    push 0
    push 0
    push WIN_HEIGHT
    push WIN_WIDTH
    push 80000000h
    push 80000000h
    push 00CF0000h
    push OFFSET szTitle
    push OFFSET szClassName
    push 0
    call CreateWindowExA@48
    mov hwndMain, eax

    ; Title Screen Buttons
    push 0
    push 0
    push ID_BTN_START
    push hwndMain
    push 45
    push 180
    push 230
    push 310
    push 50000000h
    push OFFSET szStartTxt
    push OFFSET szBtnClass
    push 0
    call CreateWindowExA@48
    mov hwndBtnStart, eax

    push 0
    push 0
    push ID_BTN_LEVEL
    push hwndMain
    push 45
    push 180
    push 300
    push 310
    push 50000000h
    push OFFSET szLevelTxt
    push OFFSET szBtnClass
    push 0
    call CreateWindowExA@48
    mov hwndBtnLevel, eax

    ; In-Game END GAME Button
    push 0
    push 0
    push ID_BTN_END
    push hwndMain
    push 25
    push 100
    push 10
    push 670
    push 50000000h
    push OFFSET szEndTxt
    push OFFSET szBtnClass
    push 0
    call CreateWindowExA@48
    mov hwndBtnEnd, eax

    call LoadLevelMap
    call ToggleMenuButtons

    push 5
    push hwndMain
    call ShowWindow@8

    push hwndMain
    call UpdateWindow@4

    push 0
    push 16
    push 1
    push hwndMain
    call SetTimer@16

MsgLoop:
    push 0
    push 0
    push 0
    lea eax, msg
    push eax
    call GetMessageA@16
    cmp eax, 0
    je ExitApp

    lea eax, msg
    push eax
    call TranslateMessage@4

    lea eax, msg
    push eax
    call DispatchMessageA@4
    jmp MsgLoop

ExitApp:
    push 0
    call ExitProcess@4
    ret
WinMain ENDP

include RenderGDI.asm
include Physics.asm

END WinMain
; =========================================================================
; GameVars.inc - Data Architecture, API Imports & Game State Variables
; =========================================================================
.386
.model flat, stdcall
option casemap:none

; Windows API Function Imports
EXTERN ExitProcess@4            : PROC
EXTERN RegisterClassExA@4       : PROC
EXTERN CreateWindowExA@48       : PROC
EXTERN GetMessageA@16           : PROC
EXTERN TranslateMessage@4       : PROC
EXTERN DispatchMessageA@4       : PROC
EXTERN PostQuitMessage@4        : PROC
EXTERN DefWindowProcA@16        : PROC
EXTERN SetTimer@16              : PROC
EXTERN KillTimer@8              : PROC
EXTERN InvalidateRect@12        : PROC
EXTERN BeginPaint@8             : PROC
EXTERN EndPaint@8               : PROC
EXTERN GetClientRect@8          : PROC
EXTERN CreateCompatibleDC@4     : PROC
EXTERN CreateCompatibleBitmap@12 : PROC
EXTERN SelectObject@8           : PROC
EXTERN DeleteObject@4           : PROC
EXTERN DeleteDC@4               : PROC
EXTERN BitBlt@36                : PROC
EXTERN CreateSolidBrush@4       : PROC
EXTERN Rectangle@20             : PROC
EXTERN Ellipse@20               : PROC
EXTERN SetBkMode@8              : PROC
EXTERN SetTextColor@8           : PROC
EXTERN DrawTextA@20             : PROC
EXTERN SetFocus@4               : PROC
EXTERN ShowWindow@8             : PROC
EXTERN GetTickCount@0           : PROC
EXTERN wsprintfA                : PROC

; Structures
POINT STRUCT
    x   DWORD 0
    y   DWORD 0
POINT ENDS

WNDCLASSEX STRUCT
    cbSize          DWORD 48
    style           DWORD 0
    lpfnWndProc     DWORD 0
    cbClsExtra      DWORD 0
    cbWndExtra      DWORD 0
    hInstance       DWORD 0
    hIcon           DWORD 0
    hCursor         DWORD 0
    hbrBackground   DWORD 0
    lpszMenuName    DWORD 0
    lpszClassName   DWORD 0
    hIconSm         DWORD 0
WNDCLASSEX ENDS

MSG STRUCT
    hwnd            DWORD 0
    message         DWORD 0
    wParam          DWORD 0
    lParam          DWORD 0
    time            DWORD 0
    pt              POINT <>
MSG ENDS

RECT STRUCT
    left    DWORD 0
    top     DWORD 0
    right   DWORD 0
    bottom  DWORD 0
RECT ENDS

PAINTSTRUCT STRUCT
    hdc         DWORD 0
    fErase      DWORD 0
    rcPaint     RECT <>
    fRestore    DWORD 0
    fIncUpdate  DWORD 0
    rgbReserved BYTE 32 DUP(0)
PAINTSTRUCT ENDS

; Constants
WM_DESTROY          EQU 0002h
WM_PAINT            EQU 000Fh
WM_TIMER            EQU 0113h
WM_KEYDOWN          EQU 0100h
WM_COMMAND          EQU 0111h

ID_BTN_START        EQU 1001
ID_BTN_LEVEL        EQU 1002
ID_BTN_END          EQU 1003

VK_LEFT             EQU 25h
VK_RIGHT            EQU 27h
VK_SPACE            EQU 20h

WIN_WIDTH           EQU 800
WIN_HEIGHT          EQU 600

BRICK_ROWS          EQU 4
BRICK_COLS          EQU 8
TOTAL_BRICKS        EQU 32
BRICK_WIDTH         EQU 85
BRICK_HEIGHT        EQU 22
BRICK_OFFSET_X      EQU 50
BRICK_OFFSET_Y      EQU 60

DT_SINGLELINE       EQU 0020h
DT_CENTER           EQU 0001h
DT_VCENTER          EQU 0004h

SW_HIDE             EQU 0
SW_SHOW             EQU 5

.data?
hInstance    DWORD ?
hwndMain     DWORD ?
hwndBtnStart DWORD ?
hwndBtnLevel DWORD ?
hwndBtnEnd   DWORD ?

.data
; Game State Flags: 0 = Title Screen, 1 = Gameplay, 2 = Game Over, 3 = Level Victory
GameState    DWORD 0
CurrentLevel DWORD 1

; Primary Ball State
BallX        DWORD 390
BallY        DWORD 480
BallRadius   DWORD 10
VelX         DWORD 4
VelY         DWORD -4
BallInPlay   DWORD 0

; Secondary Ball State (Power-up 1)
Ball2X       DWORD 0
Ball2Y       DWORD 0
Vel2X        DWORD 0
Vel2Y        DWORD 0
Ball2InPlay  DWORD 0

; Paddle State
PaddleX      DWORD 330
PaddleY      DWORD 520
PaddleW      DWORD 140
PaddleH      DWORD 18

; Power-Up Orb State
PowerUpActive DWORD 0
PowerUpX      DWORD 0
PowerUpY      DWORD 0
PowerUpType   DWORD 0 ; 1 = Extra Ball, 2 = +1 Life, 3 = -10 Sec
PointsSincePowerUp DWORD 0

; Score, Lives & Time Metrics
Score          DWORD 0
Lives          DWORD 3
StartTime      DWORD 0
ElapsedTime    DWORD 0
TimeDeduction  DWORD 0 ; Total seconds reduced via time powerups

; Individual Best Times Array (Index 0 = L1, Index 1 = L2, Index 2 = L3)
BestTimeArray  DWORD 9999, 9999, 9999

; Text String Buffers
szTitleText    BYTE "BRICK BREAKER x86 MASM", 0
szSubTitle     BYTE "Press 'START GAME' or SPACEBAR to Begin", 0
szLevelText    BYTE "SELECTED LEVEL: %d   |   BEST TIME: %d sec", 0
szLevelBuffer  BYTE 128 DUP(0)

szHudFormat    BYTE "SCORE: %d | LIVES: %d | LEVEL: %d | TIME: %d s", 0
szHudBuffer    BYTE 128 DUP(0)

szGameOver     BYTE "GAME OVER! Press START GAME to Retry", 0
szVictory      BYTE "LEVEL CLEARED! Time: %d sec", 0
szVictoryBuffer BYTE 128 DUP(0)
szLaunchMsg    BYTE "Press SPACEBAR or Click Screen to Launch Ball", 0

; Level Maps
L1_Bricks   BYTE 1,1,1,1,1,1,1,1
            BYTE 2,2,2,2,2,2,2,2
            BYTE 3,3,3,3,3,3,3,3
            BYTE 1,1,1,1,1,1,1,1

L2_Bricks   BYTE 2,0,2,0,2,0,2,0
            BYTE 0,3,0,3,0,3,0,3
            BYTE 2,0,2,0,2,0,2,0
            BYTE 0,1,0,1,0,1,0,1

L3_Bricks   BYTE 3,3,3,3,3,3,3,3
            BYTE 2,3,2,3,2,3,2,3
            BYTE 1,2,3,2,3,2,3,1
            BYTE 2,2,2,2,2,2,2,2

BrickArray  BYTE 32 DUP(0)
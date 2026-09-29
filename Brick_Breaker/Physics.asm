; =========================================================================
; Physics.asm - Trajectory, Orb Drops, Superpowers & Score Tracking
; =========================================================================

LoadLevelMap PROC
    mov esi, OFFSET L1_Bricks
    cmp CurrentLevel, 1
    je CopyMap

    mov esi, OFFSET L2_Bricks
    cmp CurrentLevel, 2
    je CopyMap

    mov esi, OFFSET L3_Bricks

CopyMap:
    mov edi, OFFSET BrickArray
    mov ecx, TOTAL_BRICKS
    rep movsb
    ret
LoadLevelMap ENDP

ResetBallToPaddle PROC
    mov eax, PaddleX
    add eax, 60
    mov BallX, eax
    mov BallY, 500
    mov BallInPlay, 0
    mov VelX, 4
    mov VelY, -4
    ret
ResetBallToPaddle ENDP

ResetGame PROC
    mov Score, 0
    mov Lives, 3
    mov GameState, 1
    mov PointsSincePowerUp, 0
    mov PowerUpActive, 0
    mov Ball2InPlay, 0
    mov TimeDeduction, 0
    call GetTickCount@0
    mov StartTime, eax
    mov ElapsedTime, 0
    call LoadLevelMap
    call ResetBallToPaddle
    ret
ResetGame ENDP

ApplyPowerUp PROC
    ; Randomly pick superpower based on system ticks
    call GetTickCount@0
    and eax, 3

    cmp eax, 0
    je MultiBallPower
    cmp eax, 1
    je ExtraLifePower

    ; Power-up 3: -10 Seconds Time Bonus
    add TimeDeduction, 10
    ret

MultiBallPower:
    mov eax, BallX
    mov Ball2X, eax
    mov eax, BallY
    mov Ball2Y, eax
    mov Vel2X, -4
    mov Vel2Y, -4
    mov Ball2InPlay, 1
    ret

ExtraLifePower:
    inc Lives
    ret
ApplyPowerUp ENDP

UpdatePhysics PROC
    cmp GameState, 1
    jne PhysicsDone

    ; Update Elapsed Time (Applying Time Bonus Deductions)
    call GetTickCount@0
    sub eax, StartTime
    mov ecx, 1000
    xor edx, edx
    div ecx

    cmp eax, TimeDeduction
    jle ResetTime
    sub eax, TimeDeduction
    mov ElapsedTime, eax
    jmp ProcessPowerUpDrop

ResetTime:
    mov ElapsedTime, 0

ProcessPowerUpDrop:
    ; Update Power-Up Orb Fall Mechanics
    cmp PowerUpActive, 1
    jne ProcessBall1

    add PowerUpY, 3

    ; Check Power-Up Paddle Catch
    mov eax, PowerUpY
    cmp eax, PaddleY
    jl CheckPowerUpFloor

    mov eax, PowerUpX
    cmp eax, PaddleX
    jl CheckPowerUpFloor

    mov edx, PaddleX
    add edx, PaddleW
    cmp eax, edx
    jg CheckPowerUpFloor

    call ApplyPowerUp
    mov PowerUpActive, 0
    jmp ProcessBall1

CheckPowerUpFloor:
    cmp PowerUpY, 580
    jle ProcessBall1
    mov PowerUpActive, 0

ProcessBall1:
    cmp BallInPlay, 0
    jne Ball1InMotion

    mov eax, PaddleX
    add eax, 60
    mov BallX, eax
    mov BallY, 500
    jmp ProcessBall2

Ball1InMotion:
    mov eax, BallX
    add eax, VelX
    mov BallX, eax

    mov eax, BallY
    add eax, VelY
    mov BallY, eax

    cmp BallX, 15
    jge CheckRight1
    mov eax, VelX
    neg eax
    mov VelX, eax
    jmp CheckTop1

CheckRight1:
    cmp BallX, 770
    jle CheckTop1
    mov eax, VelX
    neg eax
    mov VelX, eax

CheckTop1:
    cmp BallY, 15
    jge CheckBottom1
    mov eax, VelY
    neg eax
    mov VelY, eax
    jmp CheckPaddle1

CheckBottom1:
    cmp BallY, 560
    jle CheckPaddle1

    cmp Ball2InPlay, 1
    je KillBall1Only

    dec Lives
    cmp Lives, 0
    jle TriggerGameOver
    call ResetBallToPaddle
    jmp ProcessBall2

KillBall1Only:
    mov BallInPlay, 0
    jmp ProcessBall2

TriggerGameOver:
    mov GameState, 2
    jmp PhysicsDone

CheckPaddle1:
    mov eax, BallY
    add eax, BallRadius
    cmp eax, PaddleY
    jl CheckBricks1

    mov eax, BallX
    cmp eax, PaddleX
    jl CheckBricks1

    mov edx, PaddleX
    add edx, PaddleW
    cmp eax, edx
    jg CheckBricks1

    mov eax, VelY
    neg eax
    mov VelY, eax

    cmp VelY, -9
    jle CheckBricks1
    dec VelY

CheckBricks1:
    mov eax, BallY
    cmp eax, BRICK_OFFSET_Y
    jl ProcessBall2

    sub eax, BRICK_OFFSET_Y
    cdq
    mov ecx, BRICK_HEIGHT
    idiv ecx

    cmp eax, BRICK_ROWS
    jge ProcessBall2
    mov ebx, eax

    mov eax, BallX
    sub eax, BRICK_OFFSET_X
    js ProcessBall2
    cdq
    mov ecx, BRICK_WIDTH
    idiv ecx

    cmp eax, BRICK_COLS
    jge ProcessBall2

    imul ebx, BRICK_COLS
    add ebx, eax

    mov edx, OFFSET BrickArray
    add edx, ebx
    movzx eax, BYTE PTR [edx]
    cmp eax, 0
    je ProcessBall2

    dec BYTE PTR [edx]
    mov eax, VelY
    neg eax
    mov VelY, eax
    add Score, 10
    add PointsSincePowerUp, 10

    ; Spawn Orb when reaching 75 points threshold
    cmp PointsSincePowerUp, 75
    jl ProcessBall2

    mov PointsSincePowerUp, 0
    mov PowerUpActive, 1
    mov eax, BallX
    mov PowerUpX, eax
    mov eax, BallY
    mov PowerUpY, eax

; Secondary Ball Physics Processor
ProcessBall2:
    cmp Ball2InPlay, 0
    je CheckVictoryCondition

    mov eax, Ball2X
    add eax, Vel2X
    mov Ball2X, eax

    mov eax, Ball2Y
    add eax, Vel2Y
    mov Ball2Y, eax

    cmp Ball2X, 15
    jge CheckRight2
    mov eax, Vel2X
    neg eax
    mov Vel2X, eax
    jmp CheckTop2

CheckRight2:
    cmp Ball2X, 770
    jle CheckTop2
    mov eax, Vel2X
    neg eax
    mov Vel2X, eax

CheckTop2:
    cmp Ball2Y, 15
    jge CheckBottom2
    mov eax, Vel2Y
    neg eax
    mov Vel2Y, eax
    jmp CheckPaddle2

CheckBottom2:
    cmp Ball2Y, 560
    jle CheckPaddle2
    mov Ball2InPlay, 0
    jmp CheckVictoryCondition

CheckPaddle2:
    mov eax, Ball2Y
    add eax, BallRadius
    cmp eax, PaddleY
    jl CheckBricks2

    mov eax, Ball2X
    cmp eax, PaddleX
    jl CheckBricks2

    mov edx, PaddleX
    add edx, PaddleW
    cmp eax, edx
    jg CheckBricks2

    mov eax, Vel2Y
    neg eax
    mov Vel2Y, eax

CheckBricks2:
    mov eax, Ball2Y
    cmp eax, BRICK_OFFSET_Y
    jl CheckVictoryCondition

    sub eax, BRICK_OFFSET_Y
    cdq
    mov ecx, BRICK_HEIGHT
    idiv ecx

    cmp eax, BRICK_ROWS
    jge CheckVictoryCondition
    mov ebx, eax

    mov eax, Ball2X
    sub eax, BRICK_OFFSET_X
    js CheckVictoryCondition
    cdq
    mov ecx, BRICK_WIDTH
    idiv ecx

    cmp eax, BRICK_COLS
    jge CheckVictoryCondition

    imul ebx, BRICK_COLS
    add ebx, eax

    mov edx, OFFSET BrickArray
    add edx, ebx
    movzx eax, BYTE PTR [edx]
    cmp eax, 0
    je CheckVictoryCondition

    dec BYTE PTR [edx]
    mov eax, Vel2Y
    neg eax
    mov Vel2Y, eax
    add Score, 10

CheckVictoryCondition:
    mov ecx, TOTAL_BRICKS
    mov edx, OFFSET BrickArray
    mov eax, 0
CheckClearLoop:
    movzx ebx, BYTE PTR [edx]
    add eax, ebx
    inc edx
    loop CheckClearLoop

    cmp eax, 0
    jne PhysicsDone

    ; Save Best Time into Per-Level Array
    mov GameState, 3

    mov eax, CurrentLevel
    dec eax
    imul eax, 4
    mov edx, OFFSET BestTimeArray
    add edx, eax

    mov eax, ElapsedTime
    cmp eax, DWORD PTR [edx]
    jge PhysicsDone
    mov DWORD PTR [edx], eax

PhysicsDone:
    ret
UpdatePhysics ENDP
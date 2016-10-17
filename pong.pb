;*************************************************
; PROJECT   PONG
; AUTHOR    Kenneth Cason
; EMAIL     magus_fireball@yahoo.com
; VERSION   1.0
; DATE      2005 November 25
;*************************************************
InitSprite()
InitSound()
InitKeyboard()
 
 DataSection     ; ********* a includebinary file bigger .exe
   ball:    IncludeBinary "pongball.bmp"
   paddle1: IncludeBinary "pongpaddle_1.bmp"
   paddle2: IncludeBinary "pongpaddle_2.bmp"
   doot:    IncludeBinary "doot.wav"
 EndDataSection
 
#BALL = 0
#PADDLE1 = 1
#PADDLE2 = 3
#DOOT = 0
#WINDOWSCREEN = 0
#SCREENX = 640
#SCREENY = 480

If OpenWindow(#WINDOWSCREEN,200,200,#SCREENX,#SCREENY,#PB_Window_SystemMenu | #PB_Window_MinimizeGadget| #PB_Window_MaximizeGadget | #PB_Window_TitleBar | #PB_Window_SizeGadget,"PONG")
  OpenWindowedScreen(WindowID(0),0,0,#SCREENX,#SCREENY,1,0,0)

  CatchSprite(#BALL, ?ball) 
  CatchSprite(#PADDLE1, ?paddle1)
  CatchSprite(#PADDLE2, ?paddle2)
  CatchSound(#DOOT, ?doot)
  
  NEWGAME:
 
    #MOVE = 5 
    BALLHEIGHT = SpriteHeight(#BALL)
    PADDLEHEIGHT = SpriteHeight(#PADDLE1)
    score.f  = 0
    eScore.f = 0 
    setSpeed.f = 1.1
    speed.f = setSpeed 
    compErrPercent = 60
    level = 0
    Gosub SCORE
    Gosub INITPOSITION
  
  MAIN:
  
    If window = #WINDOWSCREEN
      Event = WindowEvent()
      If Event    
        Delay(10)
      EndIf 
    EndIf 
   
  ; player movement
  ExamineKeyboard()
  If KeyboardPushed(#PB_Key_Up) And p1Y - #MOVE >= 0
    p1Y - #MOVE
  ElseIf KeyboardPushed(#PB_Key_Down) And p1Y + #MOVE < #SCREENY - PADDLEHEIGHT
    p1Y + #MOVE
  ElseIf KeyboardPushed(#PB_Key_Escape)
    End
  EndIf
  ; computer AI
  If Random(100) > compErrPercent
    If p2Y < ballY ; paddle above ball
      If p2Y + #MOVE < #SCREENY - PADDLEHEIGHT
        p2Y + #MOVE
      EndIf
    ElseIf p2Y > ballY ; paddle below ball
      If p2Y - #MOVE >= 0
        p2Y - #MOVE
      EndIf
    EndIf
  EndIf
  
  ;ball movement
  If speed < 1
    speed = setSpeed
    ballX + ballSpeed * ballDirX
    ballY + ballSpeed * ballDirY
    If ballY <= 0
      ballDirY = 1
    ElseIf ballY >= #SCREENY - BALLHEIGHT
      ballDirY = -1
    EndIf
    If SpriteCollision(#BALL, ballX, ballY, #PADDLE1, p1X, p1Y)
      ballDirX = 1
      PlaySound(#DOOT)
    ElseIf SpriteCollision(#BALL, ballX, ballY, #PADDLE2, p2X, p2Y)
      ballDirX = -1
      PlaySound(#DOOT)
    EndIf
    If ballX <=0
      eScore + 1
      If eScore >= 10
        Gosub GAMEOVER
        Goto NEWGAME
      EndIf
      Gosub SCORE
    ElseIf ballX >= #SCREENX
      score + 1
      If score >= 10
        Gosub LEVELUP
      EndIf
      Gosub SCORE
    EndIf
  Else
    speed - 0.5
  EndIf
  
  ClearScreen(0,0,0)
  DisplaySprite(#BALL,ballX,ballY)
  DisplaySprite(#PADDLE1,p1X,p1Y)
  DisplaySprite(#PADDLE2,p2X,p2Y)
  StartDrawing(ScreenOutput())
    BackColor(0,0,0)
    FrontColor(255,255,255)
    Locate(#SCREENX/2-10,10) 
    DrawText(Str(level))
    Locate(100,10) 
    DrawText(Str(score))
    Locate(#SCREENX - 100,10)
    DrawText(Str(eScore))
  StopDrawing()
  FlipBuffers()
  
  Goto MAIN
  
  SCORE:
  
  INITPOSITION:
    ballX = #SCREENX/2
    ballY = #SCREENY/2
  
    p1X = 5
    p1Y = #SCREENY/2-SpriteHeight(#PADDLE1)  
    p2X = #SCREENX-20
    p2Y = #SCREENY/2-SpriteHeight(#PADDLE2)
  
    ballSpeed = 5
    ballDirX = Pow(-1, Random(1))
    ballDirY = Pow(-1, Random(1))
  Return 
    
  LEVELUP:
    compErrPercent - 5
    If compErrPercent < 1
      compErrPercent = 1
    EndIf
    score = 0
    eScore = 0
    level + 1
    Gosub SPEEDUP
    Gosub INITPOSITION
  Return
  
  GAMEOVER:
    switch = 0
    For k = 0 To 60    
      ClearScreen(switch,switch,switch)
      StartDrawing(ScreenOutput())
        BackColor(switch,switch,switch)
        FrontColor(255 - switch,255 - switch,255 - switch)
        Locate(#SCREENX/2-TextLength("GAMEOVER")/2,#SCREENY/2)
        DrawText("GAME OVER")
      StopDrawing()
      FlipBuffers()
      If switch = 0
        switch = 255
      Else
        switch = 0
      EndIf
      Delay(20)
    Next
    
  Return
  
  SPEEDUP: 
    setSpeed = 1.1 - level/2 * 0.1
    speed = setSpeed
    If setSpeed < 0
      setSpeed = 0
    EndIf
  Return   
Else
  MessageRequester("PONG","Unable To open DirectX 7.0 Or later!",#MB_ICONERROR)
EndIf 
  
; IDE Options = PureBasic v3.94 (Windows - x86)
; UseIcon = icon.ico
; Executable = PONG.exe

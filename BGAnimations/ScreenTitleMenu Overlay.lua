APEX:SetBPM(120)

TitleScene = inheritsFrom(SceneClass)

function TitleScene:Actor()
  local t = Def.ActorFrame {
    InitCommand = function(this)
      self:SetContainer(this)

      this:visible(false)
    end,

    EnterCommand = function(this)
      GAMESTATE:Reset()

      this:stoptweening()
          :visible(true)
          :sleep(0.1)
          :queuecommand("PlayMusic")
    end,

    ExitCommand = function(this)
      this:stoptweening()
          :sleep(1)
          :queuecommand("Hide")
    end,

    HideCommand = function(this)
      this:visible(false)
    end,

    StartCommand = function(this)
      this:sleep(0.65)
          :queuecommand("DoStart")
    end,

    DoStartCommand = function(this)
      local top_screen = SCREENMAN:GetTopScreen()
      top_screen:SetNextScreenName("ScreenProfileSelect")
      top_screen:StartTransitioningScreen("SM_GoToNextScreen")
    end,
  }

  -- Circle
  t[#t+1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Circle.png"),

    EnterCommand = function(this)
      this:xy(-250, 30+211)
          :decelerate(1)
          :xy(72+211, 30+211)
          :queuecommand("Animate")
    end,

    AnimateCommand = function(this)
      PulseAction(this, 1.1, 1/(APEX:GetBPM()/60))
      this:queuecommand("Animate")
    end,

    ExitCommand = function(this)
      this:stoptweening()
          :sleep(0.25)
          :accelerate(0.5)
          :x(-250)
    end,
  }

  -- Logo
  t[#t+1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Logo.png"),
    InitCommand = function(this)
      this:zoom(0.5)
    end,

    EnterCommand = function(this)
      this:xy(-this:GetWidth()/2, SCREEN_CENTER_Y)
          :decelerate(1)
          :Center()
    end,

    ExitCommand = function(this)
      this:accelerate(0.5)
          :x(-this:GetWidth()/2)
    end,
  }

  -- Press Start banner
  t[#t+1] = Def.ActorFrame {
    InitCommand = function(this)
      this:x(SCREEN_CENTER_X)
    end,

    EnterCommand = function(this)
      this:y(SCREEN_HEIGHT + 64)
          :decelerate(0.5)
          :y(748)
    end,

    ExitCommand = function(this)
      this:accelerate(0.5)
          :y(SCREEN_HEIGHT + 64)
    end,

    Def.Quad {
      InitCommand = function(this)
        this:zoomto(SCREEN_WIDTH, 64)
      end,

      EnterCommand = function(this)
        this:diffuse(ThemeColor.Black)
      end,

      StartCommand = function(this)
        this:diffuse(ThemeColor.Yellow)
      end
    },

    Def.BitmapText {
      Font = ThemeFonts.Regular,
      InitCommand = function(this)
        this:settext(string.upper(THEME:GetString("Title", "PressStart")))
            :x(-35)
      end,

      EnterCommand = function(this)
        this:stoptweening()
            :diffuse(ThemeColor.Yellow)
            :queuecommand("Blink")
      end,

      BlinkCommand = function(this)
        BlinkAction(this, 0.35)
        this:queuecommand("Blink")
      end,

      StartCommand = function(this)
        this:finishtweening()
            :diffusealpha(1)
            :diffuse(ThemeColor.Black)
            :queuecommand("StartBlink")
      end,

      StartBlinkCommand = function(this)
        BlinkAction(this, 0.04)
        this:queuecommand("StartBlink")
      end,
    },

    Def.Sprite {
      Texture = THEME:GetPathG("", "Arrow"),
      InitCommand = function(this)
        this:scaletofit(0, 0, 19, 29)
            :xy(216, 1)
      end,

      EnterCommand = function(this)
        this:stoptweening()
            :diffuse(ThemeColor.Yellow)
            :queuecommand("Animate")
      end,

      AnimateCommand = function(this)
        this:x(216)
            :accelerate(0.3)
            :x(232)
            :decelerate(0.3)
            :x(216)
            :sleep(1.5)
            :queuecommand("Animate")
      end,

      StartCommand = function(this)
        this:finishtweening()
            :diffuse(ThemeColor.Black)
            :linear(0.5)
            :x(SCREEN_CENTER_X + 32)
      end,
    }
  }

  return t
end

function TitleScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
    SCREENMAN:PlayStartSound()
    SCREENMAN:GetTopScreen():lockinput(1)
    GAMESTATE:JoinPlayer(event.PlayerNumber)
    self:GetContainer():queuecommand("Start")
  end
end

return TitleScene:Render()

local container
local starting = false

GAMESTATE:Reset()

local t = Def.ActorFrame {
  InitCommand = function(this)
    container = this
  end,

  StartCommand = function(this)
    this:sleep(0.65)
        :queuecommand("DoStart")
  end,

  DoStartCommand = function(this)
    SCREENMAN:AddNewScreenToTop("ScreenTitleMenu")
  end,
}

-- Logo
t[#t+1] = Def.Sprite {
  Texture = THEME:GetPathG("", "Logo.png"),
  InitCommand = function(this)
    this:xy(-this:GetWidth()/2, SCREEN_CENTER_Y)
        :decelerate(1)
        :Center()
  end,
}

-- Press Start banner
t[#t+1] = Def.ActorFrame {
  InitCommand = function(this)
    this:xy(SCREEN_CENTER_X, 748)
  end,

  Def.Quad {
    InitCommand = function(this)
      this:zoomto(SCREEN_WIDTH, 64)
          :diffuse(ThemeColor.Black)
    end,

    StartCommand = function(this)
      this:diffuse(ThemeColor.Yellow)
    end
  },

  Def.BitmapText {
    Font = ThemeFonts.Regular,
    InitCommand = function(this)
      this:diffuse(ThemeColor.Yellow)
          :settext(string.upper(THEME:GetString("Title", "PressStart")))
          :x(-35)
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
      this:diffuse(ThemeColor.Yellow)
          :scaletofit(0, 0, 19, 29)
          :xy(216, 1)
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

-- Input Handler
local function handle_input(event)
  if starting then return end

  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
    starting = true
    SCREENMAN:PlayStartSound()
    GAMESTATE:JoinInput(event.PlayerNumber)
    container:queuecommand("Start")
  end

end
t[#t+1] = Def.Actor {
  OnCommand = function(this)
    SCREENMAN:GetTopScreen():AddInputCallback(handle_input)
  end,
}

return t

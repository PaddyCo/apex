ProfilesScene = inheritsFrom(SceneClass)

function ProfilesScene:Actor()
  local t = Def.ActorFrame {
    InitCommand = function(this)
      self:SetContainer(this)
      this:visible(false)
    end,

    EnterCommand = function(this)
      this:visible(true)
    end,

    ExitCommand = function(this)
      this:sleep(1)
          :queuecommand("Hide")
    end,

    HideCommand = function(this)
      this:visible(false)
    end,
  }

  t[#t+1] = Def.BitmapText {
    Font = ThemeFonts.Regular,
    InitCommand = function(this)
      this:settext("TODO: Profiles")
          :diffuse(ThemeColor.Black)
          :y(SCREEN_CENTER_Y)
    end,

    EnterCommand = function(this)
      this:x(SCREEN_WIDTH+(this:GetWidth()/2))
          :sleep(0.25)
          :decelerate(0.5)
          :x(SCREEN_CENTER_X)
    end,

    ExitCommand = function(this)
      this:stoptweening()
          :accelerate(0.5)
          :x(SCREEN_WIDTH+(this:GetWidth()/2))

    end,
  }

  return t
end

function ProfilesScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
    -- TODO: Actual input handling, just go back to tile for testing purposes :)
    SCREENMAN:PlayStartSound()
    SCREENMAN:GetTopScreen():lockinput(1)
    GAMESTATE:Reset()
    SCENE:SetCurrentScene("Title")
  end
end

MainMenuScene = inheritsFrom(SceneClass)

function MainMenuScene:Actor()
  local t = Def.ActorFrame {
    InitCommand = function(this)
      self:SetContainer(this)
      this:visible(false)
    end,

    EnterCommand = function(this)
      this:visible(true)
    end,

    ExitCommand = function(this)
      this:visible(false)
    end,
  }

  t[#t+1] = Def.BitmapText {
    Font = ThemeFonts.Thin,
    InitCommand = function(this)
      this:settext("Todo: Main Menu")
          :diffuse(ThemeColor.Black)
          :Center()
    end,
  }

  return t
end

function MainMenuScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Back" then
    SCENE:SetCurrentScene("Title")
  end
end

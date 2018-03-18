StyleSelectScene = inheritsFrom(SceneClass)

function StyleSelectScene:Actor()
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
    Font = ThemeFonts.Regular,
    InitCommand = function(this)
      this:diffuse(ThemeColor.Black)
          :settext("TODO: Style Select")
          :Center()
    end,
  }
  return t
end

function StyleSelectScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
    SCENE:SetCurrentScene("Title")
  end
end

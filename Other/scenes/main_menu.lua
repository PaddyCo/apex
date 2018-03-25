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
      this:sleep(1)
          :queuecommand("Hide")
    end,

    HideCommand = function(this)
      this:visible(false)
    end,
  }

  self.buttons = {
    { key = "Regular", icon = "Regular.png" },
    { key = "Course", icon = "Course.png" },
    { key = "Battle", icon = "Battle.png" },
  }

  self.current_index = 1

  for i, button in ipairs(self.buttons) do
    t[#t+1] = Def.Sprite {
      Texture = THEME:GetPathG("", button.icon),
      InitCommand = function(this)
        this:xy((((SCREEN_WIDTH - 256)/#self.buttons) * (i-1)) + 425, 0)
            :valign(0)
            :halign(0.5)
            :queuecommand("Update")
      end,

      EnterCommand = function(this)
        this:stoptweening()
            :diffusealpha(0.5)
            :y(-100)
            :sleep(0.5)
            :visible(true)
            :decelerate(0.5)
            :y(480)
            :queuecommand("Update")
      end,

      ExitCommand = function(this)
        this:stoptweening()
            :accelerate(0.5)
            :y(-100)
      end,

      UpdateCommand = function(this)
        this:stoptweening()
            :diffusealpha(self.current_index == i and 1 or 0.5)
            :linear(0.1)
            :y(self.current_index == i and 480-16 or 480)
      end,
    }
  end

  -- Banner
  t[#t+1] = Def.ActorFrame {
    InitCommand = function(this)
      this:x(SCREEN_CENTER_X)
    end,

    EnterCommand = function(this)
      this:y(SCREEN_HEIGHT + 64)
          :sleep(1)
          :decelerate(0.5)
          :y(748)
    end,

    ExitCommand = function(this)
      this:accelerate(0.25)
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
        this:diffuse(ThemeColor.Yellow)
      end,

      OnCommand = function(this)
        this:queuecommand("Update")
      end,

      UpdateCommand = function(this)
        this:settext(THEME:GetString("MainMenu", "Mode" .. self.buttons[self.current_index].key))
      end,
    },
  }

  -- Scene title
  t[#t+1] = Def.BitmapText {
    Font = ThemeFonts.Title,
    InitCommand = function(this)
      this:settext(string.upper(THEME:GetString("MainMenu", "Title")))
          :diffuse(ThemeColor.Red)
          :halign(0)
          :valign(0)
          :x(64)
          :y(-48)
    end,

    EnterCommand = function(this)
      this:stoptweening()
          :sleep(0.8)
          :decelerate(0.2)
          :y(32)
    end,

    ExitCommand = function(this)
      this:stoptweening()
          :accelerate(0.2)
          :y(-48)
    end,
  }

  return t
end

function MainMenuScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Back" then
    SCENE:SetCurrentScene("Title")
  end

  if event.type == "InputEventType_Release" then return end

  if event.GameButton == "MenuLeft" then
    if self.current_index == 1 then return end
    self.current_index = self.current_index - 1
    self:GetContainer():queuecommand("Update")
  elseif event.GameButton == "MenuRight" then
    if self.current_index == #self.buttons then return end
    self.current_index = self.current_index + 1
    self:GetContainer():queuecommand("Update")
  end
end

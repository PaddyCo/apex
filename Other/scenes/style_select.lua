StyleSelectScene = inheritsFrom(SceneClass)

local TITLE_HEIGHT = 78
local DETAIL_BOX_HEIGHT = 200
local TITLE_WIDTH = 1024

function StyleSelectScene:Actor()
  self.current_index = 1
  self.styles = table.find_all(GAMEMAN:GetStylesForGame("Dance"), function(style)
    return style:GetName() == "single" or style:GetName() == "double"
  end)

  local t = Def.ActorFrame {
    InitCommand = function(this)
      self:SetContainer(this)

      this:x(SCREEN_CENTER_X)
          :y(-1024)
          :visible(false)
    end,

    EnterCommand = function(this)
      this:visible(true)
          :decelerate(0.5)
          :y(0)
    end,

    ExitCommand = function(this)
      this:sleep(self.fast_exit and 0 or 0.5)
          :accelerate(0.5)
          :y(-1024)
    end,
  }

  for i, style in pairs(self.styles) do
    local style_container = Def.ActorFrame {
      Font = ThemeFonts.Title,
      InitCommand = function(this)
        this:queuecommand("Update")
      end,

      UpdateCommand = function(this)
          local mod = self.current_index < i and DETAIL_BOX_HEIGHT or 0
          this:stoptweening()
              :linear(0.1)
              :y((i * (TITLE_HEIGHT + 16) + (mod)) + 320)
      end,

      EnterCommand = function(this)
        local mod = self.current_index < i and DETAIL_BOX_HEIGHT or 0
        this:y((i * (TITLE_HEIGHT + 16) + (mod)) + 320)
            :x(0)
      end,

      StartCommand = function(this)
        if i == self.current_index then
          this:accelerate(0.25)
              :y(SCREEN_CENTER_Y)
        else
          this:accelerate(0.25)
              :x(SCREEN_WIDTH)
        end
      end,
    }

    style_container[#style_container+1] = Def.Quad {
      InitCommand = function(this)
        this:diffuse(ThemeColor.Black)
            :zoomto(TITLE_WIDTH, TITLE_HEIGHT)
            :queuecommand("Update")
      end,

      UpdateCommand = function(this)
        this:stoptweening()
        if (self.current_index == i) then
          this:diffuse(ThemeColor.Yellow)
        else
          this:diffuse(ThemeColor.Black)
        end
      end,
    }

    style_container[#style_container+1] = Def.Quad {
      InitCommand = function(this)
        this:diffuse(ThemeColor.White)
            :zoomto(TITLE_WIDTH-2, TITLE_HEIGHT-3)
      end,

      UpdateCommand = function(this)
        this:visible(self.current_index ~= i)
      end,
    }

    style_container[#style_container+1] = Def.BitmapText {
      Font = ThemeFonts.Title,
      InitCommand = function(this)
        this:settext(string.upper(THEME:GetString("StyleSelect", style:GetName())))
            :diffuse(ThemeColor.Black)
            :x(-TITLE_WIDTH/2 + 16)
            :halign(0)
      end,
    }

    local style_details = Def.ActorFrame {
      InitCommand = function(this)
        this:valign(0)
            :y(TITLE_HEIGHT/2 - 1)
            :x(-TITLE_WIDTH/2)
      end,

      UpdateCommand = function(this)
        this:stoptweening()
        if (self.current_index == i) then
          this:linear(0.1)
              :zoomy(1)
        else
          this:linear(0.1)
              :zoomy(0)
        end
      end,
    }

    style_details[#style_details+1] = Def.Quad {
      InitCommand = function(this)
        this:diffuse(ThemeColor.Black)
            :zoomto(TITLE_WIDTH, DETAIL_BOX_HEIGHT)
            :valign(0)
            :halign(0)
      end,
    }

    style_details[#style_details+1] = Def.Quad {
      InitCommand = function(this)
        this:diffuse(ThemeColor.Black)
            :zoomto(TITLE_WIDTH, DETAIL_BOX_HEIGHT)
            :valign(0)
            :halign(0)
      end,
    }

    style_details[#style_details+1] = Def.BitmapText {
      Font = ThemeFonts.Thin,
      InitCommand = function(this)
        this:settext(THEME:GetString("StyleSelect", style:GetName() .. "Description"))
            :halign(0)
            :valign(0.5)
            :y(16)
            :scaletofit(16, 0, TITLE_WIDTH / 2 , DETAIL_BOX_HEIGHT)
      end,
    }

    for pad_i=0, 1 do
      style_details[#style_details+1] = Def.Sprite {
        Texture = THEME:GetPathG("", "ActivePad.png"),
        InitCommand = function(this)
          local one_side = string.match(style:GetStyleType(), "StyleType_OnePlayer(.*)") == "OneSide"
          this:x((TITLE_WIDTH - 16) - ((this:GetWidth() + 16) * pad_i))
              :Load(THEME:GetPathG("", one_side and pad_i == 0 and "InactivePad.png" or "ActivePad.png"))
              :y(100)
              :halign(1)
        end,
      }
    end

    style_container[#style_container+1] = style_details
    t[#t+1] = style_container
  end

  -- Scene title
  t[#t+1] = Def.BitmapText {
    Font = ThemeFonts.Title,
    InitCommand = function(this)
      this:settext(string.upper(THEME:GetString("StyleSelect", "Title")))
          :diffuse(ThemeColor.Red)
          :halign(0)
          :valign(0)
          :x(64 - SCREEN_CENTER_X)
          :y(-48)
    end,

    EnterCommand = function(this)
      this:stoptweening()
          :decelerate(0.2)
          :y(32)
    end,

    ExitCommand = function(this)
      this:stoptweening()
          :sleep(self.fast_exit and 0 or 0.5)
          :accelerate(0.2)
          :y(-48)
    end,
  }

  return t
end

function StyleSelectScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Back" then
    SCENE:SetCurrentScene("Profiles")
    self.fast_exit = true
  end
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
    self.fast_exit = false
    GAMESTATE:SetCurrentStyle(self.styles[self.current_index])
    SCREENMAN:PlayStartSound()
    SCENE:GetCurrentScene():GetContainer():queuecommand("Start")
    SCENE:SetCurrentScene("MainMenu")
  end

  if event.type == "InputEventType_Release" then return end

  if event.GameButton == "MenuDown" then
    if self.current_index == #self.styles then return end
    self.current_index = self.current_index + 1
    self:GetContainer():queuecommand("Update")
  elseif event.GameButton == "MenuUp" then
    if self.current_index == 1 then return end
    self.current_index = self.current_index - 1
    self:GetContainer():queuecommand("Update")
  end
end

local t = Def.ActorFrame {
  InitCommand = function(this)
    APEX:SetBackgroundContainer(this)
  end,
}

-- Background
t[#t+1] = BackgroundActor

-- Shafts
t[#t+1] = Def.Sprite {
  Texture = THEME:GetPathG("", "Shafts.png"),
  InitCommand = function(this)
    this:y(SCREEN_CENTER_Y)
        :diffuse(ThemeColor.White)
        :queuecommand("Animate")
  end,

  AnimateCommand = function(this)
    this:x(SCREEN_WIDTH + this:GetWidth())
        :linear(2)
        :x(0 - this:GetWidth())
        :sleep(2)
        :queuecommand("Animate")
  end,
}

-- Bars
local bar_colors = { ThemeColor.Green, ThemeColor.Red, ThemeColor.Yellow, ThemeColor.Blue }
for i, color in ipairs(bar_colors) do
  t[#t+1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Bar.png"),
    InitCommand = function(this)
      this.base_x = 400+(180 * i)
      this.base_y = SCREEN_HEIGHT + 160
      local offset = math.random(256)-128

      this:diffuse(color)
          :xy(this.base_x + this:GetHeight(), SCREEN_HEIGHT + this:GetHeight())
          :decelerate(1)
          :xy(this.base_x-offset, this.base_y-offset)
          :queuecommand("Animate")
    end,

    UpdateBPMCommand = function(this)
      this:stoptweening()
          :queuecommand("Animate")
    end,

    AnimateCommand = function(this)
      local offset = math.random(256)-128
      local bpm = math.max(math.min(APEX:GetBPM(), 1000), 0.000001)
      if (bpm < 1) then
        this:decelerate(1)
            :xy(this.base_x + 400, this.base_y + 400)
        return
      end

      this:decelerate(1/(bpm / 30))
          :xy(this.base_x-offset, this.base_y-offset)
          :queuecommand("Animate")

    end,
  }
end

return t

local transition_time = 0.5

local colors = { ThemeColor.Red, ThemeColor.Blue, ThemeColor.Green, ThemeColor.Purple }
APEX:SetTransitionColor(table.sample(colors))

return Def.ActorFrame {
  Def.Quad {
    OnCommand = function(self)
      self:diffuse(APEX:GetTransitionColor())
          :FullScreen()
          :x(SCREEN_WIDTH * 2)
    end,

    StartTransitioningCommand= function(self)
      self:diffuse(APEX:GetTransitionColor())
          :decelerate(transition_time / 2)
          :Center()
          :sleep(transition_time / 2)
    end
  },

  Def.Sprite {
    Texture = THEME:GetPathG("", "Logo.png"),
    InitCommand = function(this)
      this:zoom(0.35)
          :Center()
          :y((SCREEN_HEIGHT/2) - 32)
          :diffusealpha(0)
    end,

    StartTransitioningCommand = function(this)
      this:sleep(transition_time / 2)
          :linear(transition_time / 2)
          :diffuse(ThemeColor.White)
          :y(SCREEN_HEIGHT/2)
          :diffusealpha(1)
    end,
  },
}

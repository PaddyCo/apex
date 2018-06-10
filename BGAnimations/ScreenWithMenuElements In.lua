local transition_time = 0.5

return Def.ActorFrame {
  Def.Quad{
    InitCommand = function(self)
      self:diffuse(APEX:GetTransitionColor())
      self:FullScreen()
      self:Center()
    end,

    StartTransitioningCommand= function(self)
      self:accelerate(transition_time / 2)
          :x(-SCREEN_WIDTH)
          :sleep(transition_time / 2)
    end
  },

  Def.Sprite {
    Texture = THEME:GetPathG("", "Logo.png"),
    InitCommand = function(this)
      this:sleep(transition_time / 2)
          :zoom(0.35)
          :Center()
          :diffusealpha(1)
    end,

    OnCommand = function(this)
      this:linear(transition_time / 2)
          :y((SCREEN_HEIGHT/2) + 32)
          :diffusealpha(0)
    end,
  },
}

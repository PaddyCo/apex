return Def.ActorFrame {
  Def.Quad{
    InitCommand = function(self)
      self:diffuse(APEX:GetTransitionColor())
          :zoomto(SCREEN_WIDTH*1.5, SCREEN_HEIGHT / 2)
          :x(SCREEN_WIDTH/2)
          :y(SCREEN_HEIGHT/4)
    end,

    StartTransitioningCommand= function(self)
      self:accelerate(0.2)
          :y(-SCREEN_HEIGHT/4)
    end
  },

  Def.Quad{
    InitCommand = function(self)
      self:diffuse(APEX:GetTransitionColor())
          :zoomto(SCREEN_WIDTH*1.5, SCREEN_HEIGHT / 2)
          :x(SCREEN_WIDTH/2)
          :y(SCREEN_HEIGHT-SCREEN_HEIGHT/4)
    end,

    StartTransitioningCommand= function(self)
      self:accelerate(0.2)
          :y(SCREEN_HEIGHT + SCREEN_HEIGHT/4)
    end
  },

  Def.Sprite {
    Texture = THEME:GetPathG("", "Logo.png"),
    InitCommand = function(self)
      self:zoom(0.35)
          :diffusealpha(1)
          :Center()
    end,

    StartTransitioningCommand = function(self)
      self:accelerate(0.3)
          :diffusealpha(0)
          :x(SCREEN_WIDTH/2 + 128)
    end,
  }
}


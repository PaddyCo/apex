local colors = { ThemeColor.Red, ThemeColor.Blue, ThemeColor.Green, ThemeColor.Purple }
APEX:SetTransitionColor(table.sample(colors))

local quad = Def.ActorFrame {
  InitCommand = function(self)
    self:rotationz(-10)
  end,

  StartTransitioningCommand= function(self)
    self:sleep(0.3)
        :bounceend(0.1)
        :rotationz(0)
        :addy(-SCREEN_HEIGHT / 8)
  end,


  Def.Quad{
    InitCommand = function(self)
      self:zoomto(SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2)
          :diffuse(ThemeColor.Black)
          :diffusealpha(0)
          :Center()
    end,

    StartTransitioningCommand= function(self)
      self:linear(0.2)
          :diffusealpha(0.7)
    end


  },

  Def.Quad{
    InitCommand = function(self)
      self:diffuse(APEX:GetTransitionColor())
          :zoomto(SCREEN_WIDTH*1.5, SCREEN_HEIGHT / 4)
          :x(-SCREEN_WIDTH/2)
          :vertalign(0)
          :y(SCREEN_HEIGHT/2)
    end,

    StartTransitioningCommand= function(self)
      self:decelerate(0.3)
          :x(SCREEN_WIDTH/2)
          :sleep(0.3)
          :accelerate(0.1)
          :y(0)
          :zoomto(SCREEN_WIDTH*1.5, SCREEN_HEIGHT*1.5)
    end
  },

}

return Def.ActorFrame {
  quad,

  Def.Sprite {
    Texture = THEME:GetPathG("", "Logo.png"),
    InitCommand = function(self)
      self:zoom(0.35)
          :diffusealpha(0)
          :Center()
          :x(SCREEN_WIDTH/2 - 128)
    end,

    StartTransitioningCommand= function(self)
      self:decelerate(0.3)
          :diffusealpha(1)
          :x(SCREEN_WIDTH/2)
    end,
  }

}



-- return Def.ActorFrame {
--   Def.Quad{
--     InitCommand = function(self)
--       self:diffuse(APEX:GetTransitionColor())
--           :zoomto(SCREEN_WIDTH*1.5, SCREEN_HEIGHT / 4)
--           :baserotationz(angle)
--           :x(-SCREEN_WIDTH/2)
--           :y(SCREEN_HEIGHT * 0.85)
--     end,
--
--     StartTransitioningCommand= function(self)
--       self:decelerate(0.3)
--           :addx(SCREEN_WIDTH * math.cos(math.rad(angle)))
--           :addy(SCREEN_WIDTH * math.sin(math.rad(angle)))
--           :sleep(1)
--     end
--   },
-- }

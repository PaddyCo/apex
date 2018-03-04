TextBannerActor = function(y, contents)
  local t = Def.ActorFrame {
    InitCommand = function(this)
      this:xy(SCREEN_CENTER_X, y)
    end,
  }

  t[#t+1] = Def.Quad {
    InitCommand = function(this)
      this:zoomto(SCREEN_WIDTH, 64)
          :diffuse(ThemeColor.Black)
    end,
  }

  t[#t+1] = contents

  return t
end

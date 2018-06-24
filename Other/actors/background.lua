BackgroundActor = Def.Quad {
  InitCommand = function(this)
    this:FullScreen()
        :diffuse(ThemeColor.White)
  end,
}

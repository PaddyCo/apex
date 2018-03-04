BackgroundActor = Def.Quad {
  InitCommand = function(this)
    this:FullScreen()
        :diffuse(ThemeColor.White)
        :diffusebottomedge(color("#F6F6F6"))
  end,
}

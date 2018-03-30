dofile(THEME:GetPathO("", "scenes/title.lua"))
dofile(THEME:GetPathO("", "scenes/profiles.lua"))
dofile(THEME:GetPathO("", "scenes/style_select.lua"))
dofile(THEME:GetPathO("", "scenes/main_menu.lua"))

DM:SetBPM(120)

SCENE:Reset()
local scenes = {
  SCENE:AddScene("MainMenu", MainMenuScene.Create()),
  SCENE:AddScene("StyleSelect", StyleSelectScene.Create()),
  SCENE:AddScene("Title", TitleScene.Create()),
  SCENE:AddScene("Profiles", ProfilesScene.Create()),
}

local handle_input = function(event)
  if SCENE:GetCurrentScene() ~= nil then
    if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" and
       SCENE:GetCurrentKey() ~= "Title" and GAMESTATE:IsSideJoined(event.PlayerNumber) ~= true then

      GAMESTATE:JoinPlayer(event.PlayerNumber)
      SCENE:GetCurrentScene():GetContainer():queuecommand("PlayerJoin")
    else
      SCENE:GetCurrentScene():HandleInput(event)
    end
  end
end

local t = Def.ActorFrame {
  OnCommand = function(this)
    SCENE:SetCurrentScene("Title")
    SCREENMAN:GetTopScreen():AddInputCallback(handle_input)

    this:sleep(0.25)
        :queuecommand("PlayMusic")
  end,

  PlayMusicCommand = function(this)
    DM:SetBPM(120)
    SOUND:PlayMusicPart(THEME:GetPathS("", "Menu Music.ogg"), 0, 168, 0, 0, true, true, true)
  end,
}

for i, scene in ipairs(scenes) do
  t[#t+1] = scene:Actor()
end

return t

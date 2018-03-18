dofile(THEME:GetPathO("", "scenes/title.lua"))
dofile(THEME:GetPathO("", "scenes/profiles.lua"))
dofile(THEME:GetPathO("", "scenes/style_select.lua"))

DM:SetBPM(120)

SCENE:Reset()
SCENE:AddScene("Profiles", ProfilesScene.Create())
SCENE:AddScene("Title", TitleScene.Create())
SCENE:AddScene("StyleSelect", StyleSelectScene.Create())

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
  end,
}

local scenes = SCENE:GetScenes()

for key, scene in pairs(scenes) do
  t[#t+1] = scene:Actor()
end

return t

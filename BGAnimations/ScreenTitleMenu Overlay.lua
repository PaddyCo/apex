dofile(THEME:GetPathO("", "scenes/title.lua"))
dofile(THEME:GetPathO("", "scenes/profiles.lua"))

DM:SetBPM(120)

SCENE:Reset()
SCENE:AddScene("Title", TitleScene.Create())
SCENE:AddScene("Profiles", ProfilesScene.Create())

local handle_input = function(event)
  if SCENE:GetCurrentScene() ~= nil then
    SCENE:GetCurrentScene():HandleInput(event)
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

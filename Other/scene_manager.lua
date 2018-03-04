SCENE = {}
SCENE_mt = {  __index = SCENE }


SCENE._scenes = {}

function SCENE:SetCurrentScene(key)

  if self:GetCurrentScene() ~= nil then
    self:GetCurrentScene():GetContainer():queuecommand("Exit")
  end

  local new_scene = self:GetScene(key)

  if new_scene == nil then
    lua.ReportScriptError("Tried to switch to scene " .. key .. " but it doesn't exist!")
  end

  self._current_scene = new_scene

  new_scene:GetContainer():queuecommand("Enter")
end

function SCENE:GetCurrentScene()
  return self._current_scene
end

function SCENE:AddScene(key, scene)
  self._scenes[key] = scene
end

function SCENE:GetScenes()
  return self._scenes
end

function SCENE:GetScene(key)
  return self._scenes[key]
end

function SCENE:Reset()
  SCENE._scenes = {}
  SCENE._current_scene = nil
end

-- Initialize
SCENE = {}
setmetatable(SCENE, SCENE_mt)

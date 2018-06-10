APEX = {}
APEX_mt = {  __index = APEX }

-- BPM
function APEX:SetBPM(bpm)
  self._bpm = bpm
  if APEX:GetBackgroundContainer() ~= nil then
    APEX:GetBackgroundContainer():queuecommand("UpdateBPM")
  end
end

function APEX:GetBPM()
  return self._bpm
end

function APEX:SetBackgroundContainer(container)
  self._background_container = container
end

function APEX:GetBackgroundContainer()
  return self._background_container
end

function APEX:SetTransitionColor(color)
  self._transition_color = color
end

function APEX:GetTransitionColor()
  return self._transition_color
end

APEX:SetBPM(0)

-- Player Color
function APEX:GetPlayerColor(pn)
  -- TODO: Allow player to pick their profile color
  if pn == "PlayerNumber_P1" then
    return ThemeColor.Red
  else
    return ThemeColor.Blue
  end
end

-- Initialize
APEX = {}
setmetatable(APEX, APEX_mt)

APEX:SetTransitionColor(ThemeColor.Red)

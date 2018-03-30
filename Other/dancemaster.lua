DM = {}
DM_mt = {  __index = DM }

-- BPM
function DM:SetBPM(bpm)
  self._bpm = bpm
end

function DM:GetBPM()
  return self._bpm
end

DM:SetBPM(0)

-- Player Color
function DM:GetPlayerColor(pn)
  -- TODO: Allow player to pick their profile color
  if pn == "PlayerNumber_P1" then
    return ThemeColor.Red
  else
    return ThemeColor.Blue
  end
end

-- Initialize
DM = {}
setmetatable(DM, DM_mt)

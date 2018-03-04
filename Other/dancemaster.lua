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

-- Initialize
DM = {}
setmetatable(DM, DM_mt)

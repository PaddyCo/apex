SORTFUNC = {}
SORTFUNC_mt = {  __index = SORTFUNC }

function SORTFUNC.ByDifficulty(a, b)
  if (a.steps:GetMeter() == b.steps:GetMeter() and a.song:GetDisplayFullTitle() == b.song:GetDisplayFullTitle()) then
    -- For rare cases where stepfile author has set the same difficulty to multiple
    -- stepcharts, make sure they are in difficulty order at least
    return DifficultyIndex[a.steps:GetDifficulty()] < DifficultyIndex[b.steps:GetDifficulty()]
  elseif a.steps:GetMeter() == b.steps:GetMeter() then
    -- If the levels are same, sort by title
    return a.song:GetDisplayFullTitle() < b.song:GetDisplayFullTitle()
  else
    -- Otherwise, sort on level
    return a.steps:GetMeter() < b.steps:GetMeter()
  end
end

function SORTFUNC.ByTitle(a, b)
  if (a.steps:GetMeter() == b.steps:GetMeter() and a.song:GetDisplayFullTitle() == b.song:GetDisplayFullTitle()) then
    -- For rare cases where stepfile author has set the same difficulty to multiple
    -- stepcharts, make sure they are in difficulty order at least
    return DifficultyIndex[a.steps:GetDifficulty()] < DifficultyIndex[b.steps:GetDifficulty()]
  elseif a.song:GetDisplayFullTitle() == b.song:GetDisplayFullTitle() then
    -- If the titles are the same, sort on level
    return a.steps:GetMeter() < b.steps:GetMeter()
  else
    -- Otherwise, sort on title
    return a.song:GetDisplayFullTitle() < b.song:GetDisplayFullTitle()
  end
end

-- Initialize
SORTFUNC = {}
setmetatable(SORTFUNC, SORTFUNC_mt)

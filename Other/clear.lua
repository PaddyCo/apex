CLEAR = {}

function CLEAR.GetType(score)
  if score == nil then
    return nil
  end

  if score:GetGrade() == "Grade_Failed" then
    return "Failed"
  elseif table.find_index({ "StageAward_FullComboW3", "StageAward_SingleDigitW3", "StageAward_OneW3" }, score:GetStageAward()) ~= -1 then
    return "FullCombo"
  elseif table.find_index({ "StageAward_FullComboW2", "StageAward_SingleDigitW2", "StageAward_OneW2" }, score:GetStageAward()) ~= -1 then
    return "PerfectFullCombo"
  elseif award == "StageAward_FullComboW1" then
    return "MarvelousFullCombo"
  else
    return "Clear"
  end
end


-- Caclulate the current color of the clear lamp here based on current runtime, this is to make
-- sure all lamps are (depending how often they poll this) in sync no matter what.
function CLEAR.GetColor(clear_type)
  if clear_type == nil then return ThemeColor.Black end

  local function color_cycle(speed, colors)
    local color_index = (math.floor(GetTimeSinceStart() * speed) % #colors) + 1
    return colors[color_index]
  end

  if clear_type == "Clear" then
    return color_cycle(20, { ThemeColor.Yellow, Brightness(ThemeColor.Yellow, 0.95) })
  elseif clear_type == "FullCombo" or clear_type == "PerfectFullCombo" or clear_type == "MarvelousFullCombo" then
    return color_cycle(10, { ColorLightTone(ThemeColor.Yellow), ThemeColor.Blue, ThemeColor.Red, ThemeColor.Green })
  elseif clear_type == "Failed" then
    return color_cycle(30, { ThemeColor.Red, Brightness(ThemeColor.Red, 0.7) })
  else
    return ThemeColor.Black
  end
end

CLEAR = {}

function CLEAR.GetType(high_score_list)
  if high_score_list == nil then return nil end
  local high_scores = high_score_list:GetHighScores()
  if high_scores == nil then return nil end

  -- Get highest score
  local compare_grade = function(a, b)
    return GradeIndex[a:GetGrade()] < GradeIndex[b:GetGrade()]
  end
  local score = table.compare(high_scores, compare_grade)

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


function CLEAR.GetColor(clear_type)
  if clear_type == nil then return ThemeColor.Black end

  local function color_cycle(speed, colors)
    local color_index = (math.floor(GetTimeSinceStart() * speed) % #colors) + 1
    return colors[color_index]
  end

  if clear_type == "Clear" then
    return color_cycle(15, { ThemeColor.Yellow, Brightness(ThemeColor.Yellow, 0.9) })
  elseif clear_type == "FullCombo" or "PerfectFullCombo" or "MarvelousFullCombo" then
    return color_cycle(25, { ThemeColor.Yellow, ThemeColor.Blue, ThemeColor.Red, ThemeColor.Green })
  elseif clear_type == "Failed" then
    return color_cycle(30, { ThemeColor.Red, Brightness(ThemeColor.Red, 0.6) })
  else
    return ThemeColor.Black
  end
end

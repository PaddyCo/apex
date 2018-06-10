FILTERFUNC = {}

function FILTERFUNC.ByClearType(player_number, song, steps, clear_type)
  local score = SCORE.GetHighScore(player_number, song, steps)
  return CLEAR.GetType(score) == clear_type
end

function FILTERFUNC.ByGrade(player_number, song, steps, grade)
  local score = SCORE.GetHighScore(player_number, song, steps)

  if score == nil then return false end
  return score:GetGrade() == grade
end

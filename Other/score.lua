SCORE = {}

function SCORE.GetHighScore(player_number, song, steps)
  local high_score_list = PROFILEMAN:GetProfile(player_number):GetHighScoreListIfExists(song, steps)
  if high_score_list == nil then return nil end
  local high_scores = high_score_list:GetHighScores()
  if high_scores == nil then return nil end

  return high_scores[1]
end

MENUENTRY = {}
MENUENTRY_mt = {  __index = MENUENTRY }

local function create_group_entry(group_name)
  return {
    id = "Group" .. group_name,
    type = "Group",
    name = group_name,
  }
end

local function create_song_entry(song, steps)
  local high_scores = {
    PlayerNumber_P1 = PROFILEMAN:GetProfile("PlayerNumber_P1"):GetHighScoreListIfExists(song, steps),
    PlayerNumber_P2 = PROFILEMAN:GetProfile("PlayerNumber_P2"):GetHighScoreListIfExists(song, steps),
  }

  return {
    id = "Song" .. song:GetSongFilePath(), -- TODO: Make this actually unqiue, isn't used atm so no big deal
    type = "Song",
    song = song,
    steps = steps,
    high_scores = high_scores,
    clear_types = {
      PlayerNumber_P1 = CLEAR.GetType(high_scores["PlayerNumber_P1"]),
      PlayerNumber_P2 = CLEAR.GetType(high_scores["PlayerNumber_P2"]),
    },
  }
end

local function create_folder_entry(type, name)
  return {
    id = type .. name,
    type = type,
    name = name
  }
end


function MENUENTRY:SetSort(sort_func)
  self._sort_func = sort_func
end

function MENUENTRY:GetSort()
  return self._sort_func
end

function MENUENTRY:GetRoot()
  local entries = {
    create_folder_entry("All", "All songs"),
    create_folder_entry("Profile", "Perfect Full Combo"),
    create_folder_entry("Profile", "Full Combo"),
    create_folder_entry("Profile", "Clear"),
    create_folder_entry("Profile", "Failed"),
    create_folder_entry("Profile", "A"),
    create_folder_entry("Profile", "AA"),
    create_folder_entry("Profile", "AAA"),
  }

  local groups = table.map(SONGMAN:GetSongGroupNames(), create_group_entry)

  entries = table.insert_table(groups, entries, 0)

  return entries
end

function MENUENTRY:GetAll(parent_entry)
  local entries = { parent_entry }
  local all_steps = {}
  for _i, song  in ipairs(SONGMAN:GetAllSongs()) do
    for _, steps in ipairs(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
      all_steps[#all_steps+1] = create_song_entry(song, steps)
    end
  end

  table.sort(all_steps, self:GetSort())

  entries = table.insert_table(entries, all_steps, #entries)

  return entries
end

function MENUENTRY:GetGroup(group_name)
  local entries = { create_group_entry(group_name)}
  local all_steps = {}
  for _i, song  in ipairs(SONGMAN:GetSongsInGroup(group_name)) do
    local steps = table.map(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType()), function(steps) return create_song_entry(song, steps) end)
    all_steps = table.insert_table(all_steps, steps, #all_steps)
  end

  table.sort(all_steps, self:GetSort())

  entries = table.insert_table(entries, all_steps, #entries)

  return entries
end

MENUENTRY = {
  _sort_func = SORTFUNC.ByDifficulty
}
setmetatable(MENUENTRY, MENUENTRY_mt)

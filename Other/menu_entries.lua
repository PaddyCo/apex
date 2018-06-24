MENUENTRY = {}
MENUENTRY_mt = {  __index = MENUENTRY }

function MENUENTRY:InitializeSongQueue()
  if self.songs ~= nil then
    return
  end

  self.songs = {}
  self.groups = {}
  self.clear_types = {
    Failed = {},
    Clear = {},
    FullCombo = {},
    PerfectFullCombo = {},
    MarvelousFullCombo = {}
  }

  for _, group_name in pairs(SONGMAN:GetSongGroupNames()) do
    self.groups[group_name] = MENUENTRY.CreateGroupEntry(group_name)
  end

  for clear_type, _ in pairs(self.clear_types) do
    local label = THEME:GetString("ClearType", clear_type)
    self.clear_types[clear_type] = MENUENTRY.CreateFolderEntry("Profile", label)
  end

  self.song_queue = {}

  for _i, song  in ipairs(SONGMAN:GetAllSongs()) do
    for _, steps in ipairs(song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())) do
      self.song_queue[#self.song_queue+1] = { song = song, steps = steps }
    end
  end

  self.total_songs = #self.song_queue
end

function MENUENTRY:ProcessSongQueue(amount)
  for _, s in ipairs(table.slice_of(self.song_queue, 1, amount)) do
    local entry = MENUENTRY.CreateSongEntry(s.song, s.steps)
    self.songs[#self.songs+1] = entry

    -- Group by song group
    local group_name = s.song:GetGroupName()
    if self.groups[group_name] ~= nil then
      table.insert(self.groups[s.song:GetGroupName()].entries, entry.id)
    else
      lua.ReportScriptError("Group with name " .. group_name .. " not found!")
    end

    -- Group by clear type
    -- TODO: Group for every player
    local score = SCORE.GetHighScore("PlayerNumber_P1", s.song, s.steps)
    if score ~= nil then
      local clear_type = CLEAR.GetType(score)
      table.insert(self.clear_types[clear_type].entries, entry.id)
    end
  end

  self.song_queue = table.slice_of(self.song_queue, amount)


  --SM(self.total_songs - #self.song_queue  .. "/" .. self.total_songs)

  return #self.song_queue
end

function MENUENTRY:Sort()
  table.sort(self.songs, self:GetSort())
  self.song_ids = table.map(self.songs, function(s) return s.id end)
end

function MENUENTRY:SetSort(sort_func)
  self._sort_func = sort_func
end

function MENUENTRY:GetSort()
  return self._sort_func
end

function MENUENTRY:GetRoot()
  local entries = {
    MENUENTRY.CreateFolderEntry("All", "All songs"),
  }

  -- Clear types
  for _, clear_type in pairs(CLEAR.GetEnum()) do
    if #self.clear_types[clear_type].entries > 0 then
      entries[#entries+1] = self.clear_types[clear_type]
    end
  end

  -- Groups
  entries = table.insert_table(entries, table.map(SONGMAN:GetSongGroupNames(), function(name) return self.groups[name] end), #entries)


  return entries
end


function MENUENTRY:GetAll(parent_entry)
  local entries = { parent_entry }

  local all_steps = self.songs


  entries = table.insert_table(entries, all_steps, #entries)

  return entries
end

function MENUENTRY:GetGroup(group_name)
  local entries = { self.groups[group_name] }

  local all_steps = MENUENTRY:GetSongs(self.groups[group_name].entries)

  entries = table.insert_table(entries, all_steps, #entries)

  return entries
end

function MENUENTRY:GetFolder(entry)
  local entries = { entry }
  local all_steps = MENUENTRY:GetSongs(entry.entries)

  return table.insert_table(entries, all_steps, #entries)
end

function MENUENTRY:GetClearType(clear_type)
  local entries = { self.clear_types[clear_type] }

  local all_steps = MENUENTRY:GetSongs(entries.entries)

  SM(entries.entries)

  entries = table.insert_table(entries, all_steps, #entries)

  return entries
end

function MENUENTRY:GetSongs(entry_ids)
  entries = {}

  for i=1,#self.songs do
   entries[#entries+1] = 0
  end

  for _, id in pairs(entry_ids) do
    local i = table.find_index(self.song_ids, id)
    entries[i] = self.songs[i]
  end

  local compact_entries = {}
  for _, e in pairs(entries) do
    if e ~= nil and e ~= 0 then
      compact_entries[#compact_entries+1] = e
    end
  end

  return compact_entries
end

function MENUENTRY.CreateSongEntry(song, steps)
  return {
    id = "Song" .. song:GetSongFilePath() .. steps:GetDifficulty() .. steps:GetMeter(), -- TODO: Make this actually unqiue, isn't used atm so no big deal
    type = "Song",
    song = song,
    steps = steps,
    -- Calculate clear types here so they don't have to be recalculated 1000 times per second
    clear_types = {
      PlayerNumber_P1 = CLEAR.GetType(SCORE.GetHighScore("PlayerNumber_P1", song, steps)),
      PlayerNumber_P2 = CLEAR.GetType(SCORE.GetHighScore("PlayerNumber_P2", song, steps)),
    },
  }
end

function MENUENTRY.CreateGroupEntry(group_name)
  return {
    id = "Group" .. group_name,
    type = "Group",
    name = group_name,
    entries = {}
  }
end

function MENUENTRY.CreateFolderEntry(type, name, data)
  local entry = {
    id = type .. name,
    type = type,
    name = name,
    entries = {}
  }

  -- Merge entry and data tables
  if data ~= nil then
    for k, v in pairs(data) do entry[k] = v end
  end

  if type == "All" then
    -- Get all child entries
    entry.entries = MENUENTRY:GetAll(entry)
  end

  return entry
end

MENUENTRY = {
  _sort_func = SORTFUNC.ByDifficulty,
  songs = nil,
  groups = nil
}
setmetatable(MENUENTRY, MENUENTRY_mt)

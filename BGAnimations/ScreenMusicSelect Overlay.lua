APEX:SetBPM(120)

-- Item Scroller setup
local container = nil
local scroller = nil
local current_entry = nil
local current_sort = "Difficulty"
local t = Def.ActorFrame {
  InitCommand = function(this)
    container = this
  end,
}

local ITEM_HEIGHT = 54
local ITEM_MARGIN = 2
local ITEM_WIDTH = 751
local DIFFICULTY_BOX_SIZE = ITEM_HEIGHT
local CLEAR_LAMP_WIDTH = 16
local SCROLLBAR_HEIGHT = SCREEN_HEIGHT - 256

local item_mt = {
  __index = {
    set_x = function(self)
      local this = self.container
      local base_x = 0
      if self.data.type == "Song" then
        this:x(self.is_focused and base_x+33 or base_x+66)
      else
        this:x(self.is_focused and base_x-33 or base_x)
      end
    end,

    create_actors = function(self, params)
      local t = Def.ActorFrame {
        InitCommand = function(this)
          self.container = this
        end,

        SetupCommand = function(this)
          this:queuecommand("Update")
              :decelerate(0.2)
          self:set_x()
        end,

        SetCommand = function(this)
          if self.is_focused then
            this:queuecommand("Update")
          else
            this:accelerate(0.2)
                :x(ITEM_WIDTH * 1.5)
                :queuecommand("DoSet")
          end
        end,

        DoSetCommand = function(this)
          this:queuecommand("Update")
              :sleep(0.1)
              :queuecommand("AfterSet")
        end,

        ScrollCommand = function(this)
          self:set_x()
        end,

        AfterSetCommand = function(this)
          this:linear(0.1)
          self:set_x()
          this:queuecommand("Update")
        end,
      }

      -- Title
      t[#t+1] = Def.ActorFrame {
        UpdateCommand = function(this)
          this:x(self.data.type == "Song" and ((DIFFICULTY_BOX_SIZE)) or 0)
        end,

        -- Box outline
        Def.Quad {
          InitCommand = function(this)
            this:zoomto(ITEM_WIDTH, ITEM_HEIGHT)
                :diffuse(ThemeColor.Black)
          end,
        },

        -- Box fill
        Def.Quad {
          InitCommand = function(this)
            this:zoomto(ITEM_WIDTH-3, ITEM_HEIGHT-3)
                :diffuse(ThemeColor.White)
          end,
        },

        -- Box selection fill
        Def.Quad {
          InitCommand = function(this)
            this:zoomto(0, ITEM_HEIGHT-3)
                :halign(0)
                :x(-ITEM_WIDTH/2 + 1)
                :diffuse(ThemeColor.Yellow)
          end,

          UpdateCommand = function(this)
            if self.focused_last_update == self.is_focused then return end
            this:stoptweening()
            if self.is_focused then
              this:linear(0.15)
                  :zoomx(ITEM_WIDTH)
            else
              this:linear(0.15)
                  :zoomx(0)
            end

            self.focused_last_update = self.is_focused
          end,
        },

        -- Title
        Def.BitmapText {
          Font = ThemeFonts.ListDisplayTitle,
          InitCommand = function(this)
            this:diffuse(ThemeColor.Black)
                :halign(0)
                :x((-ITEM_WIDTH/2)+16)
                :zoom(0.5)
          end,

          UpdateCommand = function(this)
            if self.data.type == "Song" then
              this:settext(self.data.song:GetDisplayMainTitle())
            else
              this:settext(self.data.name)
            end

          end,
        },
      }

      -- Clear lamp
      t[#t+1] = Def.ActorFrame {
        InitCommand = function(this)
          this:x(-ITEM_WIDTH/2)
        end,

        UpdateCommand = function(this)
          this:visible(self.data.type == "Song")
        end,

        SetCommand = function(this)
          this:stoptweening()
          this:queuecommand("Blink")
        end,

        Def.Quad {
          InitCommand = function(this)
            this:zoomto(CLEAR_LAMP_WIDTH, ITEM_HEIGHT)
                :diffuse(ThemeColor.Black)
          end,

          UpdateCommand = function(this)
            this:stoptweening()
                :queuecommand("Blink")
          end,

          BlinkCommand = function(this)
            this:stoptweening()
            if self.data.type ~= "Song" then return end
            this:diffuse(CLEAR.GetColor(self.data.clear_types["PlayerNumber_P1"]))
                :sleep(0.02)
                :queuecommand("Blink")
          end,

        },

        Def.Sprite {
          InitCommand = function(this)
            this:Load(THEME:GetPathG("", "Glow.png"))
          end,

          UpdateCommand = function(this)
            this:stoptweening()
                :queuecommand("Blink")
          end,

          SetCommand = function(this)
            this:stoptweening()
                :queuecommand("Blink")
          end,

          BlinkCommand = function(this)
            this:stoptweening()
            if self.data.type ~= "Song" then
              this:visible(false)
              return
            end

            local color = CLEAR.GetColor(self.data.clear_types["PlayerNumber_P1"])

            this:visible(color ~= ThemeColor.Black)
            this:diffuse(CLEAR.GetColor(self.data.clear_types["PlayerNumber_P1"]))
                :sleep(0.02)
                :queuecommand("Blink")
          end,
        },
      }

      -- Difficulty
      t[#t+1] = Def.ActorFrame {
        InitCommand = function(this)
          this:x(((-ITEM_WIDTH/2) + (DIFFICULTY_BOX_SIZE/2)) + 2)
        end,

        UpdateCommand = function(this)
          this:visible(self.data.type == "Song")
        end,

        -- Difficulty Border
        Def.Quad {
          InitCommand = function(this)
            this:zoomto(DIFFICULTY_BOX_SIZE, DIFFICULTY_BOX_SIZE)
                :diffuse(ThemeColor.Black)
          end,
        },

        -- Difficulty Fill
        Def.Quad {
          InitCommand = function(this)
            this:zoomto(DIFFICULTY_BOX_SIZE-3, DIFFICULTY_BOX_SIZE-3)
          end,

          UpdateCommand = function(this)
            if self.data.type == "Song" then
              this:diffuse(DifficultyColor[self.data.steps:GetDifficulty()])
            end
          end,
        },

        -- Difficulty Number
        Def.BitmapText {
          Font = ThemeFonts.Regular,
          InitCommand = function(this)
            this:diffuse(ThemeColor.White)
          end,

          UpdateCommand = function(this)
            if self.data.type == "Song" then
              this:settext(self.data.steps:GetMeter())
            end
          end,
        },
      }

      -- Type Label
      t[#t+1] = Def.ActorFrame {
        InitCommand = function(this)
          this:x(ITEM_WIDTH/2)
        end,

        UpdateCommand = function(this)
          this:visible(self.data.type ~= "Song")
        end,

        Def.Sprite {
          InitCommand = function(this)
            this:Load(THEME:GetPathG("", "TypeBack.png"))
          end,

          UpdateCommand = function(this)
            this:diffuse(TypeColor[self.data.type])
          end,
        },

        Def.BitmapText {
          Font = ThemeFonts.Regular,
          InitCommand = function(this)
            this:x(-16)
          end,

          UpdateCommand = function(this)
            this:settext(self.data.type)
                :diffusealpha(0.5)
          end,

        }
      }

      return t
    end,

    transform = function(self, item_index, num_items, is_focus)
      if self.index_last_update == nil then
        -- Keep track what this entries index is, if it jumps more then one (because of scrolling multiple or it wrapping around) we should not tween it.
        self.index_last_update = item_index
      end

      self.is_focused = is_focus

      if item_index == self.index_last_update+1 or item_index == self.index_last_update-1 then
        self.container:stoptweening()
                      :decelerate(0.15)
                      :y(item_index * (ITEM_HEIGHT + (ITEM_MARGIN)))
      else
        self.container:stoptweening()
                      :y(item_index * (ITEM_HEIGHT + (ITEM_MARGIN)))
        if is_focus then
          self.container:queuecommand("Scroll")
        else
          self.container:stoptweening()
        end
      end

      self.index_last_update = item_index
    end,

    set = function(self, info)
      self.data = info
    end,
  }
}

scroller = setmetatable({ disable_wrapping = false }, item_scroller_mt)

-- Actors
t[#t+1] = scroller:create_actors("MusicList", 24, item_mt, 1095 + (ITEM_WIDTH/2), -132)


-- Scrollbar
t[#t+1] = Def.ActorFrame {
  InitCommand = function(this)
    scrollbar_container = this
    this:x(SCREEN_WIDTH - 8)
        :y((SCREEN_HEIGHT - SCROLLBAR_HEIGHT) / 2)
  end,

  -- Background
  Def.Quad {
    InitCommand = function(this)
      this:zoomto(9, SCROLLBAR_HEIGHT+2)
          :diffuse(ThemeColor.Black)
          :valign(0)
    end,
  },

  -- Scroll Indicator
  Def.Quad {
    InitCommand = function(this)
      this:diffuse(ThemeColor.White)
          :valign(0)
    end,

    SetupCommand = function(this)
      this:queuecommand("Update")
          :queuecommand("Scroll")
    end,

    SetCommand = function(this)
      this:queuecommand("Update")
    end,

    UpdateCommand = function(this)
      local height = math.max(SCROLLBAR_HEIGHT / (#scroller:get_info_set() / 18), 3)
      this:stoptweening()
          :linear(0.1)
          :y(math.min(math.max((SCROLLBAR_HEIGHT / #scroller:get_info_set()) * (scroller:get_current_index()-1) - height/2, 1), SCROLLBAR_HEIGHT - (height)))
          :zoomto(6, height)
    end,

    ScrollCommand = function(this)
      this:queuecommand("Update")
    end,
  }
}

-- Song Information
local song_information = SongInformation.Create()
t[#t+1] = song_information:CreateActors(132, 64)

-- Song Difficulty
local song_difficulty = SongDifficulty.Create("PlayerNumber_P1")
t[#t+1] = song_difficulty:CreateActors(329, 535)

local function set_song(song, current_steps)
  song_information:SetSong(song)
  song_difficulty:SetSong(song, current_steps)
end

local function set_entries(entries, focus_index)
  scroller:set_info_set(entries, focus_index)
  container:queuecommand("Set")

end

local function select_entry(entry)
  -- Root
  if entry == nil then
    set_entries(MENUENTRY:GetRoot(), 1)
  -- Close folder
  elseif current_entry ~= nil and entry.id == current_entry.id then
    local entries = MENUENTRY:GetRoot()
    local index = table.find_index(table.map(entries, function(e) return e.id end), current_entry.id)
    set_entries(MENUENTRY:GetRoot(), index)
    current_entry = nil
    set_song(nil)
  -- Groups
  elseif entry.type == "Group" then
    set_entries(MENUENTRY:GetGroup(entry.name), 1)
    current_entry = entry
  elseif entry.type == "All" then
    set_entries(entry.entries, 1)
    current_entry = entry
  elseif entry.type == "Profile" then
    set_entries(entry.entries, 1)
    current_entry = entry
  else
    lua.ReportScriptError("Unknown current entry in music wheel! Don't know action to trigger!")
  end
end

local function on_scroll()
  container:queuecommand("Scroll")
  container:queuecommand("Update")

  local info = scroller:get_info_at_focus_pos()
  if (info.type == "Song") then
    set_song(info.song, info.steps)
  else
    set_song(nil)
  end
end

local function on_stop_scroll()
  container:queuecommand("EndScroll")
end

local function on_start_scroll()
  container:queuecommand("StartScroll")
end

local function scroll(amount)
    scroller:scroll_by_amount(amount)
    on_scroll()
end

local function scroll_to(index)
    scroller:scroll_to_pos(index)
    on_scroll()
end

function scroll_to_steps(steps)
  for i, v in ipairs(scroller.info_set) do
    if v.steps == steps then
      scroll_to(i)
    end
  end
end

function scroll_difficulty(amount)
  local info = scroller:get_info_at_focus_pos()
  if info.type == "Song" then
    local all_steps = info.song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())
    -- Turn steps into entries (so we get clear lamps and can reuse the sorting functionality)
    local entries = table.map(all_steps, function(steps) return MENUENTRY.CreateSongEntry(info.song, steps) end)
    -- Find the current difficulty and set it to focused (Before sort so the indices match up)
    -- Sort it by meter and difficulty
    table.sort(entries, SORTFUNC.ByDifficulty)

    local current_steps_index = table.find_index(table.map(entries, function(e) return e.steps end), info.steps)

    local new_index = current_steps_index + amount

    if new_index >= 1 and new_index <= #all_steps then
      scroll_to_steps(entries[current_steps_index+amount].steps)
    end
  end
end

local last_button_press_timestamps = {}

local function is_double_tap(button, event, tolerance)
  if event.type == "InputEventType_FirstPress"
     and event.GameButton == button
     and last_button_press_timestamps[event.GameButton] ~= nil
     and last_button_press_timestamps[event.GameButton] > GetTimeSinceStart() - tolerance then
    last_button_press_timestamps[event.GameButton] = -1
    return true
  else
    return false
  end
end

local handle_input = function(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "MenuLeft"
  or event.type == "InputEventType_FirstPress" and event.GameButton == "MenuRight" then
    on_start_scroll()
  end

  if event.type == "InputEventType_Release" and event.GameButton == "MenuLeft"
  or event.type == "InputEventType_Release" and event.GameButton == "MenuRight" then
    on_stop_scroll()
  end

  if event.type == "InputEventType_Release" then return end

  local current_row_info = scroller:get_info_at_focus_pos()

  if event.GameButton == "Start" and event.type == "InputEventType_FirstPress" then
    select_entry(scroller:get_info_at_focus_pos())
  end

  if event.GameButton == "Back" and event.type == "InputEventType_FirstPress" then
    if current_entry ~= nil then
      select_entry(current_entry)
    else
      SCREENMAN:SetNewScreen("ScreenMainMenu")
    end
  end

  -- TODO: Find a good way for user to use "next page" functionality
  -- if is_double_tap("MenuRight", event) then
  --   local e = scroller:get_info_at_focus_pos()
  --   if e.type == "Song" then
  --     local meter_list = table.map(scroller:get_info_set(), function(i) return i.type == "Song" and i.steps:GetMeter() or 0 end)
  --     scroll_to(table.find_index(meter_list, e.steps:GetMeter()+1))
  --   end
  if event.GameButton == "MenuRight" then
    scroll(1)
  end

  -- TODO: Find a good way for user to use "previous page" functionality
  --if is_double_tap("MenuLeft", event) then
  --  local e = scroller:get_info_at_focus_pos()
  --  if e.type == "Song" then
  --    local meter_list = table.map(scroller:get_info_set(), function(i) return i.type == "Song" and i.steps:GetMeter() or 0 end)
  --    scroll_to(table.find_index(meter_list, e.steps:GetMeter()-1))
  --  end
  if event.GameButton == "MenuLeft" then
    scroll(-1)
  end

  if is_double_tap("MenuUp", event, 0.2) then
    scroll_difficulty(-1)
  end

  if is_double_tap("MenuDown", event, 0.2) then
    scroll_difficulty(1)
  end

  if event.type == "InputEventType_FirstPress" then
    -- Ignore it if set to -1, because that means a double tap was executed this update
    if last_button_press_timestamps[event.GameButton] ~= -1 then
      last_button_press_timestamps[event.GameButton] = GetTimeSinceStart()
    else
      last_button_press_timestamps[event.GameButton] = nil
    end
  end
end

t[#t+1] = Def.Quad {
  OnCommand = function(this)
    this:sleep(0.1)
        :queuecommand("LoadRoot")
  end,

  LoadRootCommand = function(this)
    MENUENTRY:InitializeSongQueue()
    this:queuecommand("ProcessQueue")
  end,

  -- TODO: Add loading indicator while processing songs
  ProcessQueueCommand = function(this)
    if MENUENTRY:ProcessSongQueue(400) > 0 then
      this:sleep(0.01)
          :queuecommand("ProcessQueue")
    else
      MENUENTRY:Sort()
      scroller:set_info_set(MENUENTRY:GetRoot(), 1)
      this:queuecommand("Setup")
    end
  end,

  SetupCommand = function(this)
    SCREENMAN:GetTopScreen():AddInputCallback(handle_input)
    container:queuecommand("Update")
        :queuecommand("PlayPreview")
        :sleep(0.1)
  end,

  StartScrollCommand = function(this)
    SOUND:StopMusic()
    APEX:SetBPM(0)
  end,

  EndScrollCommand = function(this)
    SOUND:StopMusic()
    this:stoptweening()
        :sleep(0.1)
        :queuecommand("PlayPreview")
  end,

  SetCommand = function(this)
    this:queuecommand("PlayPreview")
  end,

  PlayPreviewCommand = function(subself)
    local info = scroller:get_info_at_focus_pos()
    if info.type == "Song" then
      container:queuecommand("PauseBGM")
      local preview_beat = info.steps:GetTimingData():GetBeatFromElapsedTime(info.song:GetSampleStart())
      local preview_bpm = info.steps:GetTimingData():GetBPMAtBeat(preview_beat)
      APEX:SetBPM(preview_bpm)
      SOUND:PlayMusicPart(info.song:GetPreviewMusicPath(), info.song:GetSampleStart(), info.song:GetSampleLength(), 1, 1, true, true)
    else
      container:queuecommand("PlayBGM")
      SOUND:StopMusic()
    end
  end,
}

t[#t+1] = Def.Sound {
  InitCommand = function(this)
    this:load(THEME:GetPathS("", "Menu Music.ogg"))
  end,

  OnCommand = function(this)
    this:play()
  end,

  StartScrollCommand = function(this)
    this:stoptweening()
        :sleep(0.2)
        :queuecommand("PlayBGM")
  end,

  PlayBGMCommand = function(this)
    APEX:SetBPM(120)
    this:pause(false)
  end,

  PauseBGMCommand = function(this)
    this:stoptweening()
        :pause(true)
  end,

}

return t

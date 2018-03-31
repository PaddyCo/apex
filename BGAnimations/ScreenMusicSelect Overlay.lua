
DM:SetBPM(120)

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
local ITEM_WIDTH = 650
local DIFFICULTY_BOX_SIZE = ITEM_HEIGHT
local CLEAR_LAMP_WIDTH = 16
local SCROLLBAR_HEIGHT = SCREEN_HEIGHT - 256

local item_mt = {
  __index = {
    create_actors = function(self, params)
      local t = Def.ActorFrame {
        InitCommand = function(this)
          self.container = this
          this:x(ITEM_WIDTH * 1.5)
        end,

        SetupCommand = function(this)
          local base_x = 100
          this:queuecommand("Update")
              :decelerate(0.2)
          if self.data.type == "Song" then
            this:x(self.is_focused and base_x+33 or base_x+66)
          else
            this:x(self.is_focused and base_x-33 or base_x)
          end
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
          local base_x = 100
          if self.data.type == "Song" then
            this:x(self.is_focused and base_x+33 or base_x+66)
          else
            this:x(self.is_focused and base_x-33 or base_x)
          end
        end,

        AfterSetCommand = function(this)
          this:linear(0.1)
          local base_x = 100
          if self.data.type == "Song" then
            this:x(self.is_focused and base_x+33 or base_x+66)
          else
            this:x(self.is_focused and base_x-33 or base_x)
          end
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

        Def.Quad {
          InitCommand = function(this)
            this:zoomto(CLEAR_LAMP_WIDTH, ITEM_HEIGHT)
                :diffuse(ThemeColor.Black)
          end,
        },

        Def.Sprite {
          InitCommand = function(this)
            this:Load(THEME:GetPathG("", "Glow.png"))
                :diffuse(ThemeColor.Yellow)
                :visible(false)
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

-- Get list entries
local function get_entries()
  if current_entry == nil then
    return MENUENTRY:GetRoot()
  elseif current_entry.type == "Group" then
    return MENUENTRY:GetGroup(current_entry.name)
  elseif current_entry.type == "All" then
    return MENUENTRY:GetAll(current_entry.sort_func)
  else
    lua.ReportScriptError("Unknown current entry in music wheel! Don't know which entries to get!")
  end

  return MENUENTRY:GetRoot()
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
  -- Groups
  elseif entry.type == "Group" then
    set_entries(MENUENTRY:GetGroup(entry.name), 1)
    current_entry = entry
  elseif entry.type == "All" then
    set_entries(MENUENTRY:GetAll(entry), 1)
    current_entry = entry
  else
    lua.ReportScriptError("Unknown current entry in music wheel! Don't know action to trigger!")
  end
end

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
      local height = math.max(SCROLLBAR_HEIGHT / #scroller:get_info_set(), 3)
      this:stoptweening()
          :linear(0.1)
          :y(math.min(math.max((SCROLLBAR_HEIGHT / #scroller:get_info_set()) * (scroller:get_current_index()-1), 1), SCROLLBAR_HEIGHT - (height)))
          :zoomto(6, height)
    end,

    ScrollCommand = function(this)
      this:queuecommand("Update")
    end,
  }


}

local function on_scroll()
    container:queuecommand("Scroll")
    container:queuecommand("Update")

    local info = scroller:get_info_at_focus_pos()

    if info.type == "Song" then
      local preview_beat = info.steps:GetTimingData():GetBeatFromElapsedTime(info.song:GetSampleStart())
      local preview_bpm = info.steps:GetTimingData():GetBPMAtBeat(preview_beat)
      DM:SetBPM(preview_bpm)
    else
      DM:SetBPM(120)
    end
end

local function scroll(amount)
    scroller:scroll_by_amount(amount)
    on_scroll()
end

local function scroll_to(index)
    scroller:scroll_to_pos(index)
    on_scroll()
end

local last_button_press_timestamps = {}

local function is_double_tap(button, event)
  if event.type == "InputEventType_FirstPress"
     and event.GameButton == button
     and last_button_press_timestamps[event.GameButton] ~= nil
     and last_button_press_timestamps[event.GameButton] > GetTimeSinceStart() - 0.15 then
    return true
  else
    return false
  end
end

local handle_input = function(event)
  if event.type == "InputEventType_Release" then return end

  local current_row_info = scroller:get_info_at_focus_pos()

  if event.GameButton == "Start" and event.type == "InputEventType_FirstPress" then
    select_entry(scroller:get_info_at_focus_pos())
  end

  if event.GameButton == "Back" and event.type == "InputEventType_FirstPress" and current_entry ~= nil then
    select_entry(current_entry)
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

  if event.type == "InputEventType_FirstPress" then
    last_button_press_timestamps[event.GameButton] = GetTimeSinceStart()
  end
end

t[#t+1] = Def.Actor {
  OnCommand = function(this)
    scroller:set_info_set(MENUENTRY:GetRoot(), 1)
    container:queuecommand("Setup")
    SCREENMAN:GetTopScreen():AddInputCallback(handle_input)
  end,

  SetupCommand = function(this)
    this:queuecommand("PlayPreview")
  end,

  ScrollCommand = function(this)
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
      SOUND:PlayMusicPart(info.song:GetPreviewMusicPath(), info.song:GetSampleStart(), info.song:GetSampleLength(), 1, 1, true, true)
    else
      SOUND:StopMusic()
    end
  end,
}

return t

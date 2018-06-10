local SongDifficultyActor = {}
SongDifficulty_mt = {  __index = SongDifficultyActor }

local ITEM_WIDTH = 367
local ITEM_HEIGHT = 48
local ITEM_CONTENT_HEIGHT = 128
local DIFFICULTY_BOX_SIZE = ITEM_HEIGHT

local item_mt = {
  __index = {
    create_actors = function(self, params)
      local t = Def.ActorFrame {
        InitCommand = function(this)
          self.container = this
          this:diffusealpha(0)
        end,
        HideCommand = function(this)
          this:stoptweening()
              :linear(0.2)
              :x(-32)
              :diffusealpha(0)

        end,
        ShowCommand = function(this)
          this:stoptweening()
              :visible(true)
              :linear(0.2)
              :x(0)
              :diffusealpha(1)
        end,
      }

      t[#t+1] = Def.Quad {
        InitCommand = function(this)
          this:zoomto(ITEM_WIDTH, ITEM_HEIGHT)
              :diffuse(ThemeColor.Black)
        end,
        UpdateCommand = function(this)
          this:queuecommand("SetSong")
        end,
        SetSongCommand = function(this)
          this:diffuse(ThemeColor.Black)
          if self.data == nil then return end
          this:diffuse(self.data.is_focused and APEX:GetPlayerColor(params.player_number) or ThemeColor.Black)
        end,
      }

      t[#t+1] = Def.Quad {
        InitCommand = function(this)
          this:zoomto(ITEM_WIDTH-3, ITEM_HEIGHT-3)
              :diffuse(ThemeColor.White)
        end,

        UpdateCommand = function(this)
          this:queuecommand("SetSong")
        end,
        SetSongCommand = function(this)
          if self.data == nil then return end
          this:visible(self.data.is_focused == nil)
        end,
      }

      t[#t+1] = Def.BitmapText {
        Font = ThemeFonts.Thin,
        InitCommand = function(this)
          this:diffuse(ThemeColor.Black)
              :halign(0)
              :x((-ITEM_WIDTH/2) + 8)
        end,

        SetSongCommand = function(this)
          this:diffuse(ThemeColor.Black)
          if self.data == nil then return end
          this:settext(string.upper(THEME:GetString("Difficulty", self.data.steps:GetDifficulty())))
              :diffuse(self.data.is_focused and ThemeColor.White or ThemeColor.Black)
        end,
      }

      -- Score box
      local score_box = Def.ActorFrame {
        InitCommand = function(this)
          this:zoomy(0)
              :y(ITEM_HEIGHT/2)
        end,

        HideCommand = function(this)
          this:linear(0.1)
              :zoomy(0)
        end,

        UpdateCommand = function(this)
          if self.data == nil then return end
          this:stoptweening()
              :linear(0.1)
              :valign(0)
              :zoomy(self.data.is_focused and 1 or 0)
        end,

        -- Background
        Def.Quad {
          InitCommand = function(this)
            this:zoomto(ITEM_WIDTH, ITEM_CONTENT_HEIGHT)
                :diffuse(ThemeColor.Black)
                :valign(0)
                :y(-1)
          end,
        },
      }

      -- No Play
      score_box[#score_box+1] = Def.BitmapText {
        Font = ThemeFonts.Title,
        InitCommand = function(this)
          this:settext("No Play")
              :diffuse(ThemeColor.White)
              :y(ITEM_CONTENT_HEIGHT/2)
        end,

        UpdateCommand = function(this)
          this:visible(self.data == nil or self.data.score == nil)
        end,
      }


      -- Score
      score_box[#score_box+1] = Def.ActorFrame {
        UpdateCommand = function(this)
          this:visible(self.data ~= nil and self.data.score ~= nil)
        end,

        -- Grade
        Def.BitmapText {
          Font = ThemeFonts.Title,
          InitCommand = function(this)
            this:diffuse(ThemeColor.Yellow)
                :halign(0)
                :valign(0)
                :y(8)
          end,

          UpdateCommand = function(this)
            this:stoptweening()
            if self.data == nil then return end

            if self.data.score ~= nil then
              this:settext(THEME:GetString("Grade", self.data.score:GetGrade():gsub("Grade_", "")))
                  :diffuse(GradeIndex[self.data.score:GetGrade()] < 4 and ThemeColor.Yellow or ThemeColor.White)
                  :x((-ITEM_WIDTH/2) + 58)
                  :diffusealpha(0)
                  :decelerate(0.2)
                  :x((-ITEM_WIDTH/2) + 8)
                  :diffusealpha(1)
            end
          end,
        },

        -- Percentage
        Def.BitmapText {
          Font = ThemeFonts.Thin,
          InitCommand = function(this)
            this:diffuse(ThemeColor.White)
                :halign(1)
                :valign(0)
                :y(18)
          end,
          UpdateCommand = function(this)
            this:stoptweening()
            if self.data == nil then return end

            if self.data.score ~= nil then
              this:settext(math.floor(self.data.score:GetPercentDP() * 10000) / 100 .. "%")
                  :x((ITEM_WIDTH/2) - 58)
                  :diffusealpha(0)
                  :decelerate(0.2)
                  :x(ITEM_WIDTH/2 - 8)
                  :diffusealpha(1)
            end
          end,
        },

        -- Percentage bar
        Def.Quad {
          InitCommand = function(this)
            this:y(ITEM_CONTENT_HEIGHT-1)
                :x(-ITEM_WIDTH/2)
                :zoomto(0, 8)
                :valign(1)
                :halign(0)
          end,

          UpdateCommand = function(this)
            if self.data == nil or self.data.score == nil or self.data.is_focused == nil then
              this:stoptweening()
                  :linear(0.15)
                  :zoomx(0)
                  :diffuse(ThemeColor.White)
              return
            end

            this:stoptweening()
                :linear(0.15)
                :zoomx(ITEM_WIDTH * self.data.score:GetPercentDP())
                :diffuse(CLEAR.GetColor(self.data.clear_types["PlayerNumber_P1"]))
                :queuecommand("Blink")
          end,

          BlinkCommand = function(this)
            if self.data == nil or self.data.score == nil then return end
            this:diffuse(CLEAR.GetColor(self.data.clear_types["PlayerNumber_P1"]))
                :sleep(0.02)
                :queuecommand("Blink")
          end,
        },

      }

      t[#t+1] = score_box

      -- Difficulty Meter box
      t[#t+1] = Def.ActorFrame {
        InitCommand = function(this)
          this:x((ITEM_WIDTH/2) - (DIFFICULTY_BOX_SIZE/2))
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
            if self.data == nil then return end
            this:diffuse(DifficultyColor[self.data.steps:GetDifficulty()])
          end,
        },

        -- Difficulty Number
        Def.BitmapText {
          Font = ThemeFonts.Regular,
          InitCommand = function(this)
            this:diffuse(ThemeColor.White)
          end,

          UpdateCommand = function(this)
            if self.data == nil then return end
            this:settext(self.data.steps:GetMeter())
          end,
        },
      }

      return t
    end,

    transform = function(self, item_index, num_items, is_focus)
      if self.data == nil then
        self.container:queuecommand("Hide")
        return
      end

      local mod = self.data.index > self.data.focus_index and ITEM_CONTENT_HEIGHT or 0

      self.container:stoptweening()
                    :linear(0.1)
                    :y((item_index * (ITEM_HEIGHT + 3)) + mod)
                    :queuecommand("Show")

    end,

    set = function(self, info)
      self.data = info
    end,
  }
}

function SongDifficultyActor:CreateActors(base_x, base_y)
  self.scroller = setmetatable({ disable_wrapping = true }, item_scroller_mt)

  return Def.ActorFrame {
    InitCommand = function(this)
      self.container = this
      this:x(base_x)
          :y(base_y)
    end,

    self.scroller:create_actors("DifficultyList", 6, item_mt, 0, 0, { player_number = self.player_number })
  }

end

function SongDifficultyActor:SetSong(song, current_steps)
  if self.song == song and self.current_steps == current_steps then return end


  if song == nil and self.song ~= song then
    self.container:queuecommand("Hide")
  end

  self.song = song
  self.current_steps = current_steps

  if song == nil then return end

  local all_steps = song:GetStepsByStepsType(GAMESTATE:GetCurrentStyle():GetStepsType())
  local entries = table.map(all_steps, function(steps) return MENUENTRY.CreateSongEntry(song, steps) end)
  table.sort(entries, SORTFUNC.ByDifficulty)

  local current_steps_index = table.find_index(table.map(entries, function(e) return e.steps end), current_steps)

  entries[current_steps_index].is_focused = true
  for i, entry in ipairs(entries) do
    entries[i].score = SCORE.GetHighScore(self.player_number, entry.song, entry.steps)
    entries[i].index = i
    entries[i].focus_index = current_steps_index
  end

  self.scroller.current_steps = current_steps
  self.scroller:set_info_set(entries, current_steps_index)

  self.container:queuecommand("SetSong")
end

SongDifficulty = {}
function SongDifficulty.Create(player_number)
  song_difficulty = {
    song = nil,
    player_number = player_number,
  }
  setmetatable(song_difficulty, SongDifficulty_mt)

  return song_difficulty
end


local SongInformationActor = {}
SongInformation_mt = {  __index = SongInformationActor }

local JACKET_SIZE = 384
local BANNER_HEIGHT = 80 * (JACKET_SIZE/256)

-- TODO: Make this a preference
local WAIT_FOR_LOAD = true -- If set to true, it won't load images while you are quickly scrolling trough the list

function SongInformationActor:CreateActors(base_x, base_y)
  local t = Def.ActorFrame {
    InitCommand = function(this)
      self.container = this

      this:x(base_x - 64)
          :y(base_y)
          :diffusealpha(0)
    end,

    OnCommand = function(this)
      this:queuecommand("SetSong")
    end,

    HideCommand = function(this)
      this:stoptweening()
          :accelerate(0.3)
          :x(base_x - 64)
          :diffusealpha(0)
    end,

    ShowCommand = function(this)
      this:decelerate(0.3)
          :x(base_x)
          :diffusealpha(1)
    end,
  }

  local JACKET_X = 484 + JACKET_SIZE/2
  local JACKET_Y = JACKET_SIZE/2

  -- Jacket
  t[#t+1] = Def.ActorFrame {
    InitCommand = function(this)
      this:x(JACKET_X)
          :y(JACKET_Y)
    end,

    -- Jacket Border
    Def.Quad {
      InitCommand = function(this)
        this:zoomto(JACKET_SIZE + 3, JACKET_SIZE + 3)
            :diffuse(ThemeColor.Black)
      end,

      SetSongCommand = function(this)
        if self.song == nil then return end

        this:stoptweening()
            :linear(WAIT_FOR_LOAD and 0.1 or 0)

        if self.song:HasJacket() then
          this:zoomto(JACKET_SIZE + 4, JACKET_SIZE + 4)
        else
          this:zoomto(JACKET_SIZE + 4, BANNER_HEIGHT + 4)
        end
      end,
    },

    -- Jacket Background
    Def.Quad {
      InitCommand = function(this)
        this:zoomto(JACKET_SIZE, JACKET_SIZE)
            :diffuse(ThemeColor.White)
      end,

      SetSongCommand = function(this)
        if self.song == nil then return end

        this:stoptweening()
            :linear(WAIT_FOR_LOAD and 0.1 or 0)

        if self.song:HasJacket() then
          this:zoomto(JACKET_SIZE, JACKET_SIZE)
        else
          this:zoomto(JACKET_SIZE, BANNER_HEIGHT)
        end
      end,
    },

    -- Jacket Image
    Def.Banner {
      InitCommand = function(this)
      end,

      SetSongCommand = function(this)
        if self.song == nil then return end

        this:stoptweening()
            :diffusealpha(0)
            :sleep(WAIT_FOR_LOAD and 0.1 or 0)
            :queuecommand("Load")
      end,

      LoadCommand = function(this)
        this:stoptweening()
            :Load(nil)

        if self.song == nil then return end

        if self.song:HasJacket() then
          this:LoadBanner(self.song:GetJacketPath())
          -- For some reason, if you don't do scaletoclipped twice, it will mess up when you go from a banner to a jacket.
          this:scaletoclipped(JACKET_SIZE, JACKET_SIZE)
              :scaletoclipped(JACKET_SIZE, JACKET_SIZE)
              :linear(WAIT_FOR_LOAD and 0.1 or 0)
              :diffusealpha(1)
        elseif self.song:HasBanner() then
          this:LoadBanner(self.song:GetBannerPath())
          -- ditto
          this:scaletoclipped(JACKET_SIZE, BANNER_HEIGHT)
          this:scaletoclipped(JACKET_SIZE, BANNER_HEIGHT)
              :linear(WAIT_FOR_LOAD and 0.1 or 0)
              :diffusealpha(1)
        end
      end,
    },
  }

  -- Title/Artist/Group
  t[#t+1] = Def.ActorFrame {
    InitCommand = function(this)
      this:x((JACKET_X - (JACKET_SIZE/2)) - 32)
          :y(JACKET_Y - 32)
    end,

    -- Main Title
    Def.BitmapText {
      Font = ThemeFonts.DisplayTitle,
      InitCommand = function(this)
        this:diffuse(ThemeColor.Red)
            :halign(1)
            :valign(1)
      end,

      SetSongCommand = function(this)
        if self.song ~= nil then
          this:settext(self.song:GetDisplayMainTitle())
              :stoptweening()
              :scaletofit(-550, -26, 0, 26)
              :diffusealpha(0)
              :y(-48)
              :decelerate(0.2)
              :diffusealpha(1)
              :y(-16)
        end
      end,
    },

    -- Sub Title
    Def.BitmapText {
      Font = ThemeFonts.DisplaySubtitle,
      InitCommand = function(this)
        this:diffuse(ThemeColor.Red)
            :halign(1)
      end,

      SetSongCommand = function(this)
        if self.song ~= nil then
          this:stoptweening()
              :settext(self.song:GetDisplaySubTitle())
              :scaletofit(-550, -10, 0, 10)
              :y(32)
              :x(-32)
              :diffusealpha(0)
              :decelerate(0.2)
              :diffusealpha(1)
              :x(0)
        end
      end,
    },

    -- Artist
    Def.BitmapText {
      Font = ThemeFonts.DisplaySubtitle,
      InitCommand = function(this)
        this:diffuse(ThemeColor.Black)
            :halign(1)
      end,

      SetSongCommand = function(this)
        if self.song ~= nil then
          this:stoptweening()
              :settext(self.song:GetDisplayArtist())
              :scaletofit(-550, -8, 0, 8)
              :y(self.song:GetDisplaySubTitle() ~= "" and 64 or 32)
              :x(-32)
              :diffusealpha(0)
              :decelerate(0.2)
              :diffusealpha(1)
              :x(0)
        end
      end,
    },

    -- Group banner
    Def.Banner {
      InitCommand = function(this)
        this:halign(1)
            :valign(0)
      end,

      SetSongCommand = function(this)
        if self.song == nil then
          self.group_banner_path = nil
          return
        end

        local group_banner_path = SONGMAN:GetSongGroupBannerPath(self.song:GetGroupName())
        if group_banner_path == self.group_banner_path then
          this:stoptweening()
              :linear(WAIT_FOR_LOAD and 0.1 or 0)
              :diffusealpha(1)
              :y(self.song:GetDisplaySubTitle() ~= "" and 100 or 64)
              :x(0)
          return
        end
        self.group_banner_path = group_banner_path

        this:stoptweening()
            :diffusealpha(0)
            :sleep(WAIT_FOR_LOAD and 0.1 or 0)
            :queuecommand("Load")
      end,

      LoadCommand = function(this)
        if self.song == nil then return end

        this:LoadBanner(self.group_banner_path)
        this:scaletoclipped(182, 57)
            :diffusealpha(0)
            :x(-32)
            :y(self.song:GetDisplaySubTitle() ~= "" and 100 or 64)
            :decelerate(WAIT_FOR_LOAD and 0.2 or 0)
            :diffusealpha(1)
            :x(0)
      end,
    },
  }

  local function get_bpm_color(bpm)
    if bpm > 500 then
      return ThemeColor.Red
    elseif bpm > 280 then
      return ThemeColor.Yellow
    else
      return ThemeColor.Blue
    end

  end

  -- Misc song info
  t[#t+1] = Def.ActorFrame {
    InitCommand = function(this)
      this:x(JACKET_X)
          :y(JACKET_Y + 16)
    end,

    SetSongCommand = function(this)
      if self.song == nil then return end
      local base_y = JACKET_Y + 16
      this:stoptweening()
          :linear(0.1)
          :y(self.song:HasJacket() and base_y + JACKET_SIZE/2 or base_y + BANNER_HEIGHT/2)
    end,

    -- Length Label
    Def.BitmapText {
      Font = ThemeFonts.Regular,
      InitCommand = function(this)
        self.length_label = this
        this:settext("Length")
            :diffuse(ThemeColor.Black)
            :zoom(0.8)
            :x(-JACKET_SIZE/2)
            :y(-4)
            :valign(0)
            :halign(0)
      end,
    },

    -- Length value
    Def.ActorFrame {
      OnCommand = function(this)
        this:x(self.length_label:GetX() + self.length_label:GetWidth() - 24)
            :y(-4)
            :zoom(0.8)
      end,

      SetSongCommand = function(this)
        if self.song == nil then return end

        local color = ThemeColor.Blue
        if self.song:IsLong() then
          color = ThemeColor.Yellow
        elseif self.song:IsMarathon() then
          color = ThemeColor.Red
        end

        this:stoptweening()
            :linear(0.1)
            :diffuse(color)
      end,

      -- Minute counter
      Def.RollingNumbers {
        Font = ThemeFonts.Mono,
        InitCommand = function(this)
          this:valign(0)
              :halign(1)
              :x(52)
              :y(3)
              :set_chars_wide(2)
              :set_leading_attribute{ Diffuse = Alpha(ThemeColor.Black, 0.3) }
              :set_number_attribute{ Diffuse = ThemeColor.White }
              :target_number(0)
              :set_approach_seconds(0.5)
        end,

        SetSongCommand = function(this)
          if self.song == nil then return end

          this:stoptweening()
              :target_number(self.song:MusicLengthSeconds()/60)
        end,
      },

      -- Divider
      Def.BitmapText {
        Font = ThemeFonts.Mono,
        OnCommand = function(this)
          this:valign(0)
              :halign(0)
              :x(53)
              :y(3)
              :settext(":")
        end,
      },

      -- Second counter
      Def.RollingNumbers {
        Font = ThemeFonts.Mono,
        InitCommand = function(this)
          this:valign(0)
              :halign(0)
              :set_chars_wide(2)
              :set_leading_attribute{ Diffuse = ThemeColor.White }
              :set_number_attribute{ Diffuse = ThemeColor.White }
              :target_number(0)
              :set_approach_seconds(0.5)
              :x(72)
              :y(3)
        end,

        SetSongCommand = function(this)
          if self.song == nil then return end

          this:stoptweening()
              :target_number(self.song:MusicLengthSeconds() - math.floor(self.song:MusicLengthSeconds()/60)*60)
        end,
      },
    },

    -- BPM
    Def.ActorFrame {
      InitCommand = function(this)
        this:zoom(0.8)
            :valign(0)
            :halign(1)
            :x(100)
            :y(-4)
      end,
      SetSongCommand = function(this)
        if self.song == nil then return end

        local bpms = self.song:GetDisplayBpms()

        this:stoptweening()
            :sleep(bpms[1] ~= bpms[2] and 0.1 or 0)
            :decelerate(0.2)
            :x(bpms[1] == bpms[2] and 106 or 44)
      end,

      -- BPM Label
      Def.BitmapText {
        Font = ThemeFonts.Regular,
        InitCommand = function(this)
          this:diffuse(ThemeColor.Black)
              :valign(0)
              :settext("BPM")
        end,
      },

      Def.RollingNumbers {
        Font = ThemeFonts.Mono,
        InitCommand = function(this)
          this:valign(0)
              :halign(1)
              :set_chars_wide(3)
              :set_leading_attribute{ Diffuse = Alpha(ThemeColor.Black, 0) }
              :set_number_attribute{ Diffuse = ThemeColor.White }
              :target_number(0)
              :x(112)
              :y(3)
              :set_approach_seconds(0.5)
        end,

        SetSongCommand = function(this)
          if self.song == nil then return end

          local bpm = self.song:GetDisplayBpms()[1]

          this:stoptweening()
              :target_number(math.floor(math.max(math.min(bpm, 999), 0)))
              :set_number_attribute{ Diffuse = get_bpm_color(bpm) }
              :visible(true)
        end,
      },

      Def.BitmapText {
        Font = ThemeFonts.Mono,
        InitCommand = function(this)
          this:valign(0)
              :halign(0)
              :y(3)
              :x(112)
        end,

        SetSongCommand = function(this)
          if self.song == nil then return end

          local bpms = self.song:GetDisplayBpms()

          this:stoptweening()
              :linear(0.1)
              :diffusealpha(0)

          if bpms[1] ~= bpms[2] then
            this:settext("~" .. math.floor(math.max(math.min(bpms[2], 999), 0)))
                :linear(0.1)
                :diffuse(get_bpm_color(bpms[2]))
                :diffusealpha(1)
          else
            this:linear(0.1)
                :diffusealpha(0)
          end
        end,
      },
    }
  }

  return t
end

function SongInformationActor:SetSong(song)
  if (self.song == song) then return end

  if song == nil then
    self.container:queuecommand("Hide")
  elseif self.song == nil and song ~= nil then
    self.container:queuecommand("Show")
  end

  self.song = song
  self.container:queuecommand("SetSong")
end

SongInformation = {}
function SongInformation.Create()
  song_information = {
    song = nil
  }
  setmetatable(song_information, SongInformation_mt)

  return song_information
end


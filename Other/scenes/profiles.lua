ProfilesScene = inheritsFrom(SceneClass)

local PROFILE_TITLE_HEIGHT = 78
local DETAIL_BOX_HEIGHT = 200
local PROFILE_TITLE_WIDTH = 793

-- Get profiles
local profiles = {}
for i=0,PROFILEMAN:GetNumLocalProfiles()-1 do
  profiles[#profiles+1] = PROFILEMAN:GetLocalProfileFromIndex(i)
end

-- Create scene
function ProfilesScene:Actor()

  self.selected_profile_index = {}
  self.current_profile_index = {}

  local t = Def.ActorFrame {
    InitCommand = function(this)
      self:SetContainer(this)
      this:visible(false)
    end,

    EnterCommand = function(this)
      self.selected_profile_index = {}

      this:visible(true)
          :queuecommand("Update")
    end,

    ExitCommand = function(this)
      this:sleep(1)
          :queuecommand("Hide")
    end,

    HideCommand = function(this)
      this:visible(false)
    end,

    StartCommand = function(this)
      this:sleep(0.5)
          :queuecommand("DoStart")
    end,

    DoStartCommand = function(this)
      -- If two players, assume its versus, if not go to style select
      if #GAMESTATE:GetHumanPlayers() <= 1 then
        SCENE:SetCurrentScene("StyleSelect")
      else
        local style = table.find_first(GAMEMAN:GetStylesForGame("Dance"), function(style)
          return style:GetName() == "versus"
        end)

        GAMESTATE:SetCurrentStyle(style)
        SCENE:SetCurrentScene("MainMenu")
      end
    end,
  }

  self.profile_menu_containers = {}


  -- Players
  for player_index = 1, 2 do
    local left_side = player_index == 1
    local player_number = "PlayerNumber_P" .. player_index
    local other_player_number = player_index == 1 and "PlayerNumber_P2" or "PlayerNumber_P1"

    -- Press start to join
    local join_nag = Def.ActorFrame {
      EnterCommand = function(this)
        this:stoptweening()
            :x(left_side and -800 or SCREEN_WIDTH + 800)
            :y(SCREEN_CENTER_Y)
            :queuecommand("PlayerJoin")
      end,

      PlayerJoinCommand = function(this)
        if GAMESTATE:IsSideJoined(player_number) == false then
          this:stoptweening()
              :decelerate(0.5)
              :x(left_side and 64 or SCREEN_WIDTH - (64 + PROFILE_TITLE_WIDTH))
        else
          this:sleep(0.25)
              :queuecommand("Exit")
        end
      end,

      StartCommand = function(this)
        this:queuecommand("Exit")
      end,

      ExitCommand = function(this)
        this:stoptweening()
            :accelerate(0.25)
            :x(left_side and -800 or SCREEN_WIDTH + 800)
      end,
    }

    join_nag[#join_nag+1] = Def.Quad {
      InitCommand = function(this)
        this:zoomto(PROFILE_TITLE_WIDTH, 112)
            :halign(0)
            :diffuse(ThemeColor.Black)
      end,

      PlayerJoinCommand = function(this)
        if (GAMESTATE:IsSideJoined(player_number)) then
          this:diffuse(ThemeColor.Yellow)
        else
          this:diffuse(ThemeColor.Black)
        end
      end,
    }

    join_nag[#join_nag+1] = Def.BitmapText {
      Font = ThemeFonts.Title,
      InitCommand = function(this)
        this:settext(string.upper(THEME:GetString("Profile", "PressStart")))
            :x(PROFILE_TITLE_WIDTH/2)
      end,

      EnterCommand = function(this)
        this:stoptweening()
            :diffuse(ThemeColor.Yellow)
            :queuecommand("Blink")
      end,

      BlinkCommand = function(this)
        BlinkAction(this, 0.35)
        this:queuecommand("Blink")
      end,

      PlayerJoinCommand = function(this)
        if (GAMESTATE:IsSideJoined(player_number)) then
          this:finishtweening()
              :diffusealpha(1)
              :diffuse(ThemeColor.Black)
              :queuecommand("StartBlink")
        end
      end,

      StartBlinkCommand = function(this)
        BlinkAction(this, 0.04)
        this:queuecommand("StartBlink")
      end,
    }

    t[#t+1] = join_nag

    -- Profile menu
    self.current_profile_index[player_number] = 1
    local profile_menu = Def.ActorFrame {
      InitCommand = function(this)
        self.profile_menu_containers[player_number] = this
      end,

      EnterCommand = function(this)
        this:stoptweening()
            :x(left_side and -800 or SCREEN_WIDTH + 800)
            :queuecommand("PlayerJoin")
      end,

      PlayerJoinCommand = function(this)
        if GAMESTATE:IsSideJoined(player_number) then
          this:stoptweening()
              :sleep(0.25)
              :decelerate(0.5)
              :x(left_side and 64 or SCREEN_WIDTH - (64 + PROFILE_TITLE_WIDTH))
        else
          this:queuecommand("Exit")
        end
      end,

      ExitCommand = function(this)
        this:stoptweening()
            :accelerate(0.25)
            :x(left_side and -800 or SCREEN_WIDTH + 800)
      end,
    }

    -- Profiles
    for i, profile in ipairs(profiles) do

      -- Profiles
      local profile_entry = Def.ActorFrame {
        InitCommand = function(this)
          this:y(320 + (i * (PROFILE_TITLE_HEIGHT + 16)))
              :queuecommand("Update")
        end,

        ExitCommand = function(this)
          this:queuecommand("Update")
        end,

        UpdateCommand = function(this)
          local relative_index = i - self.current_profile_index[player_number]
          local mod = self.current_profile_index[player_number] < i and DETAIL_BOX_HEIGHT or 0
          local hide = self.selected_profile_index[player_number] and relative_index ~= 0
          local already_picked = self.selected_profile_index[other_player_number] == i
          this:stoptweening()
              :linear(0.1)
              :y(SCREEN_CENTER_Y + (relative_index * (PROFILE_TITLE_HEIGHT + 16) + (mod)))
              :diffusealpha(already_picked and 0.5 or 1)
              :x(hide and (left_side and -900 or 900) or 0)
        end,
      }

      profile_entry[#profile_entry+1] = Def.Quad {
        InitCommand = function(this)
          this:diffuse(ThemeColor.Black)
              :halign(0)
              :zoomto(PROFILE_TITLE_WIDTH, PROFILE_TITLE_HEIGHT)
              :queuecommand("Update")
        end,

        UpdateCommand = function(this)
          this:stoptweening()
          if (self.current_profile_index[player_number] == i) then
            this:diffuse(ThemeColor.Yellow)
          else
            this:diffuse(ThemeColor.Black)
          end
        end,
      }

      profile_entry[#profile_entry+1] = Def.Quad {
        InitCommand = function(this)
          this:diffuse(ThemeColor.White)
              :halign(0)
              :x(1)
              :zoomto(791, PROFILE_TITLE_HEIGHT-3)
              :queuecommand("Update")
        end,

        UpdateCommand = function(this)
          this:visible(self.current_profile_index[player_number] ~= i)
        end,
      }

      profile_entry[#profile_entry+1] = Def.BitmapText {
        Font = ThemeFonts.Title,
        InitCommand = function(this)
          this:settext(profile:GetDisplayName())
              :diffuse(ThemeColor.Black)
              :x(16)
              :halign(0)
        end,
      }

      -- Details
      local profile_details = Def.ActorFrame {
        InitCommand = function(this)
          this:valign(0)
              :halign(0)
              :y(PROFILE_TITLE_HEIGHT/2 - 1)
        end,

        UpdateCommand = function(this)
          this:stoptweening()
          if (self.current_profile_index[player_number] == i) then
            this:linear(0.1)
                :zoomy(1)
          else
            this:linear(0.1)
                :zoomy(0)
          end
        end,
      }

      profile_details[#profile_details+1] = Def.Quad {
        InitCommand = function(this)
          this:diffuse(ThemeColor.Black)
              :zoomto(PROFILE_TITLE_WIDTH, DETAIL_BOX_HEIGHT)
              :valign(0)
              :halign(0)
        end,
      }

      profile_details[#profile_details+1] = Def.Quad {
        InitCommand = function(this)
          this:diffuse(ThemeColor.Black)
              :zoomto(PROFILE_TITLE_WIDTH, DETAIL_BOX_HEIGHT)
              :valign(0)
              :halign(0)
        end,
      }

      profile_details[#profile_details+1] = self:RenderDetailRow(
        16,
        THEME:GetString("Profile", "SongsPlayed"),
        function()
          return profile:GetNumTotalSongsPlayed()
        end,
        THEME:GetString("Profile", "Songs")
      )

      profile_details[#profile_details+1] = self:RenderDetailRow(
        16 + (64 * 1),
        THEME:GetString("Profile", "DancePoints"),
        function()
          return profile:GetTotalDancePoints()
        end,
        THEME:GetString("Profile", "Points")
      )

      profile_details[#profile_details+1] = self:RenderDetailRow(
        16 + (64 * 2),
        THEME:GetString("Profile", "MostPlayed"),
        function()
          local most_popular_song = profile:GetMostPopularSong()
          if most_popular_song then return most_popular_song:GetDisplayMainTitle()
          else return "None" end
        end
      )

      profile_entry[#profile_entry+1] = profile_details

      profile_menu[#profile_menu+1] = profile_entry
    end

    -- Scene title
    t[#t+1] = Def.BitmapText {
      Font = ThemeFonts.Title,
      InitCommand = function(this)
        this:settext(string.upper(THEME:GetString("Profile", "Title")))
            :diffuse(ThemeColor.Red)
            :halign(0)
            :valign(0)
            :x(64)
      end,

      EnterCommand = function(this)
        this:stoptweening()
            :decelerate(0.2)
            :y(32)
      end,

      ExitCommand = function(this)
        this:stoptweening()
            :accelerate(0.2)
            :y(-48)
      end,
    }


    t[#t+1] = profile_menu
  end

  return t
end

function ProfilesScene:RenderDetailRow(y, title, value_func, suffix)
  local row = Def.ActorFrame {}

  -- Title
  row[#row+1] = Def.BitmapText {
    Font = ThemeFonts.Regular,
    Name = "Title",
    InitCommand = function(this)
      this:settext(string.upper(title))
          :x(16)
          :y(y)
          :halign(0)
          :valign(0)
    end,
  }

  -- Underline
  -- if suffix == nil then return end
  row[#row+1] = Def.Quad {
    InitCommand = function(this)
      this:zoomto(PROFILE_TITLE_WIDTH - 32, 2)
          :halign(0)
          :x(16)
          :diffuse(ThemeColor.White)
          :y(y + 38)
    end,
  }

  -- Value suffix
  row[#row+1] = Def.BitmapText {
    Font = ThemeFonts.Thin,
    Name = "Suffix",
    InitCommand = function(this)
      if suffix == nil then return end
      this:settext(suffix)
          :x(PROFILE_TITLE_WIDTH - 32)
          :y(y)
          :halign(1)
          :valign(0)
    end,
  }

  -- Value
  row[#row+1] = Def.BitmapText {
    Font = ThemeFonts.Thin,
    InitCommand = function(this)
      local suffix_width = 0
      if suffix ~= nil then
        local suffix = this:GetParent():GetChild("Suffix")
        suffix_width = suffix:GetWidth() + 16
      end

      title_width = this:GetParent():GetChild("Title"):GetWidth() + 32

      this:settext(value_func())
          :diffuse(ThemeColor.Blue)
          :scaletofit(0, 0, PROFILE_TITLE_WIDTH - 32 - suffix_width - title_width, 24)
          :halign(1)
          :valign(0.5)
          :x(PROFILE_TITLE_WIDTH - 32 - suffix_width)
          :y(y + 12)
    end,
  }

  return row
end

function ProfilesScene:OnEnter(previous_scene)
  SOUND:PlayOnce(THEME:GetPathS("", "profileselect.ogg"), true)
  if previous_scene ~= "Title" then
    GAMESTATE:Reset()
  end
end

function ProfilesScene:HandleInput(event)
  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" and GAMESTATE:IsSideJoined(event.PlayerNumber) ~= true then
      GAMESTATE:JoinPlayer(event.PlayerNumber)
      self:GetContainer():queuecommand("PlayerJoin")
      return
  end

  if event.type == "InputEventType_FirstPress" and event.GameButton == "Back" then
    if self.selected_profile_index[event.PlayerNumber] then
      self.selected_profile_index[event.PlayerNumber] = nil
      self.profile_menu_containers[event.PlayerNumber]:queuecommand("Update")
      GAMESTATE:UnjoinPlayer(event.PlayerNumber)
      GAMESTATE:JoinPlayer(event.PlayerNumber)
    else
      self.selected_profile_index = {}
      SCREENMAN:GetTopScreen():lockinput(1)
      GAMESTATE:Reset()
      SCENE:SetCurrentScene("Title")
    end
  end

  if event.type == "InputEventType_FirstPress" and event.GameButton == "Start" then
    for _i, player_number in ipairs(GAMESTATE:GetHumanPlayers()) do
      if self.selected_profile_index[player_number] == self.current_profile_index[event.PlayerNumber] then
        return
      end
    end

    self.selected_profile_index[event.PlayerNumber] = self.current_profile_index[event.PlayerNumber]
    self:GetContainer():queuecommand("Update")

    local load_profiles = true
    for _i, player_number in ipairs(GAMESTATE:GetHumanPlayers()) do
      if self.selected_profile_index[player_number] == nil then
        load_profiles = false
      end
    end

    if load_profiles then
      -- TODO: Maybe check if there is a better way to load profiles outside a ScreenSelectProfile
      SCREENMAN:GetTopScreen():lockinput(0.5)
      SCREENMAN:AddNewScreenToTop("ScreenSelectProfile")
      for _i, player_number in ipairs(GAMESTATE:GetHumanPlayers()) do
        SCREENMAN:GetTopScreen():SetProfileIndex(player_number, self.selected_profile_index[player_number])
      end
      self:GetContainer():queuecommand("Start")
      SCREENMAN:PlayStartSound()
    end
  end

  if event.type == "InputEventType_Release" then return end

  if self.selected_profile_index[event.PlayerNumber] ~= nil then return end

  local current_index = self.current_profile_index[event.PlayerNumber]
  if event.GameButton == "MenuDown" then
    if current_index == #profiles then return end
    self.current_profile_index[event.PlayerNumber] = current_index + 1
    self.profile_menu_containers[event.PlayerNumber]:queuecommand("Update")
  elseif event.GameButton == "MenuUp" then
    if current_index == 1 then return end
    self.current_profile_index[event.PlayerNumber] = current_index - 1
    self.profile_menu_containers[event.PlayerNumber]:queuecommand("Update")
  end
end

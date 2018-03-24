local NAME_PLATE_WIDTH = 235
local NAME_PLATE_HEIGHT = 56

local function CreditsText( pn )
  local left_side = pn == "PlayerNumber_P1"
  local text = Def.ActorFrame {
    InitCommand = function(this)
      this:y(SCREEN_HEIGHT - 16)
          :x(left_side and 0 or SCREEN_WIDTH)
          :halign(left_side and 0 or 1)
          :valign(1)
          :queuecommand("StartUpdateText")

      this.last_str = ScreenSystemLayerHelpers.GetCreditsMessage(pn)
    end,

    RefreshCreditTextMessageCommand = function(this)
      this:queuecommand("StartUpdateText")
    end,
    CoinInsertedMessageCommand = function(this)
      this:queuecommand("StartUpdateText")
    end,
    PlayerJoinedMessageCommand = function(this)
      this:queuecommand("StartUpdateText")
    end,

    StartUpdateTextCommand = function(this)
			local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn)

      if str == "" then
        this:queuecommand("Hide")
      elseif str ~= this.last_str then
        this:stoptweening()
            :accelerate(0.25)
            :x(left_side and -NAME_PLATE_WIDTH or SCREEN_WIDTH+NAME_PLATE_WIDTH)
            :queuecommand("UpdateText")
      else
        this:queuecommand("UpdateText")
      end

      this.last_str = str
    end,

    HideCommand = function(this)
      this:accelerate(0.25)
          :x(left_side and -(NAME_PLATE_WIDTH+10) or SCREEN_WIDTH+(NAME_PLATE_WIDTH+10))
    end,

    UpdateTextCommand = function(this)
      this:stoptweening()
          :decelerate(0.25)
          :x(left_side and 0 or SCREEN_WIDTH)
    end,


  }

  text[#text+1] = Def.Quad {
    InitCommand = function(this)
      this:zoomto(NAME_PLATE_WIDTH, NAME_PLATE_HEIGHT)
          :diffuse(ThemeColor.Black)
          :halign(left_side and 0 or 1)
          :valign(1)
          :x(left_side and -1 or 1)
    end,

		UpdateTextCommand=function(this)
      this:visible(GAMESTATE:IsSideJoined(pn))
		end,
  }

  text[#text+1] = Def.Quad {
    InitCommand = function(this)
      this:zoomto(10, NAME_PLATE_HEIGHT)
          :diffuse(left_side and ThemeColor.Red or ThemeColor.Blue) -- TODO: Set to the profile color when implemented
          :halign(left_side and 0 or 1)
          :valign(1)
          :x(left_side and NAME_PLATE_WIDTH-1 or -NAME_PLATE_WIDTH+1)

    end,

		UpdateTextCommand=function(this)
      this:visible(GAMESTATE:IsSideJoined(pn))
		end,
  }

	text[#text+1] = LoadFont(ThemeFonts.Regular) .. {
		InitCommand=function(this)
			this:name("Credits" .. PlayerNumberToString(pn))
          :diffuse(ThemeColor.White)
          :shadowlength(0)
          :visible(false)
		end,

		UpdateTextCommand=function(this)
			local str = ScreenSystemLayerHelpers.GetCreditsMessage(pn);
			this:settext(str)
          :visible(true)
          :xy(0, 0)
          :valign(0.5)
          :halign(0.5)
          :diffuse(ThemeColor.White)

      if GAMESTATE:IsSideJoined(pn) then
        if left_side then
          this:scaletofit(16, -(NAME_PLATE_HEIGHT-16), NAME_PLATE_WIDTH-16, -16)
        else
          this:scaletofit(-(NAME_PLATE_WIDTH-16), -(NAME_PLATE_HEIGHT-16), -16, -16)
        end
      else
        this:xy(left_side and 8 or -8, 8)
            :halign(left_side and 0 or 1)
            :zoom(0.5)
            :valign(1)
            :diffuse(ThemeColor.Black)
      end
		end,

		UpdateVisibleCommand=function(this)
			local screen = SCREENMAN:GetTopScreen();
			local bShow = true;
			if screen then
				local sClass = screen:GetName();
				bShow = THEME:GetMetric( sClass, "ShowCreditDisplay" );
			end

			this:visible( bShow );
		end,
	};

	return text;
end;

local t = Def.ActorFrame {}
	-- Aux
t[#t+1] = LoadActor(THEME:GetPathB("ScreenSystemLayer","aux"));
	-- Credits
t[#t+1] = Def.ActorFrame {
--[[  	PlayerPane( PLAYER_1 ) .. {
		InitCommand=cmd(x,scale(0.125,0,1,SCREEN_LEFT,SCREEN_WIDTH);y,SCREEN_BOTTOM-16)
	}; --]]
 	CreditsText( PLAYER_1 );
	CreditsText( PLAYER_2 );
};
	-- Text
t[#t+1] = Def.ActorFrame {
	Def.Quad {
		InitCommand=cmd(zoomtowidth,SCREEN_WIDTH;zoomtoheight,30;horizalign,left;vertalign,top;y,SCREEN_TOP;diffuse,color("0,0,0,0"));
		OnCommand=cmd(finishtweening;diffusealpha,0.85;);
		OffCommand=cmd(sleep,3;linear,0.5;diffusealpha,0;);
	};
	Def.BitmapText{
		Font=ThemeFonts.Regular;
		Name="Text";
    InitCommand = function(this)
      this:maxwidth(750)
          :horizalign(left)
          :vertalign(top)
          :y(SCREEN_TOP+10)
          :x(SCREEN_LEFT+10)
          :shadowlength(1)
          :diffusealpha(0)
          :diffuse(ThemeColor.White)
    end,
    OnCommand = function(this)
      this:finishtweening()
          :diffusealpha(1)
          :zoom(0.5)
    end,
		OffCommand=cmd(sleep,3;linear,0.5;diffusealpha,0;);
	};
	SystemMessageMessageCommand = function(self, params)
		self:GetChild("Text"):settext( params.Message );
		self:playcommand( "On" );
		if params.NoAnimate then
			self:finishtweening();
		end
		self:playcommand( "Off" );
	end;
	HideSystemMessageMessageCommand = cmd(finishtweening);
};

return t;

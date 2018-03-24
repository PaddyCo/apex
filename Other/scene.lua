SceneClass = {}
SceneClass_mt = {  __index = SceneClass }

function SceneClass.Create()
  local new_screen = {}
  setmetatable(new_screen, SceneClass_mt)
  return new_screen
end

function SceneClass:Actor()
  return Def.ActorFrame {
    InitCommand = function(this)
      self:SetContainer(this)

      this:visible(false)
    end,

    EnterCommand = function(this)
      this:visible(true)
    end,

    ExitCommand = function(this)
      this:visible(false)
    end,

    Def.BitmapText {
      Font = ThemeFonts.Regular,
      InitCommand = function(this)
        this:settext("Override me!")
            :diffuse(ThemeColor.Black)
            :Center()
      end,
    }
  }
end

function SceneClass:OnEnter(previous_scene)
end

function SceneClass:OnExit(new_scene)
end

function SceneClass:HandleInput(event)
end

function SceneClass:GetContainer()
  return self._container
end

function SceneClass:SetContainer(container)
  self._container = container
end

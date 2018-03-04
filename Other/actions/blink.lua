BlinkAction = function(self, speed)
  self:diffusealpha(1)
      :sleep(speed)
      :diffusealpha(0)
      :sleep(speed)
end

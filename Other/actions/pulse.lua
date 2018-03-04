PulseAction = function(self, zoom, speed)
  self:linear(speed / 3)
      :zoom(zoom)
      :linear(speed / 3)
      :zoom(1)
      :sleep(speed / 3)
end

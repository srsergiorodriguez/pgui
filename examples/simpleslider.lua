include "pgui.lua"

function _init()
  -- Define the initial value of the slider
  slidervalue = 10
end

function _update()
  -- Refresh pgui each frame
  pgui:refresh()
  
  -- Create a slider and set its value back from its return value
  slidervalue = pgui:component("hslider",{pos=vec(190,20),value=slidervalue})
end

function _draw()
  cls(5)
	
  -- Draw the circle, its size is based on the return value of the slider
  circfill(240,140,slidervalue,8)
  
  -- Draw all pgui components	
  pgui:draw()
end
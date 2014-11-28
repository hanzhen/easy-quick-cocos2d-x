--
-- Author: Jerry Lee
-- Date: 2014-10-12
--

local display = {}

-- create modal layer
function display.newModalLayer(color, touchCallback)
	color = color or cc.c4b(0, 0, 0, 128)
	local layer = cc.LayerColor:create(color)
	layer:setTouchEnabled(true)
	layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		if touchCallback then touchCallback(event) end
		return true
	end)
	return layer
end

return display
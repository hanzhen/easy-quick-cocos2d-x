--
-- Author: Jerry Lee
-- Date: 2014-10-09
--

local ui = {}

-- create UIHTMLTextLabel object
function ui.newHTMLTextLabel(text, params)
	local label = easy.ui.UIHTMLTextLabel.new(params)
	label:setString(text or "")
	return label
end

-- create TTF label can be touched
function ui.newMenuItemLabel(params)
	local node = display.newNode()
	local label = display.newTTFLabel(params)
	node:setTouchEnabled(true)
	node:addChild(label)
	return node
end

return ui
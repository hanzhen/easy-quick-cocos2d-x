--
-- Author: Jerry Lee
-- Date: 2014-10-09 15:38:28
--

local ui = {}

-- create UIHTMLTextLabel object
function ui.newHTMLTextLabel(text, params)
	local label = easy.ui.UIHTMLTextLabel.new(params)
	label:setString(text or "")
	return label
end

return ui
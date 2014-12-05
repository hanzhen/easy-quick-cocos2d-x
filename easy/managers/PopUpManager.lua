--
-- Pop-up view components manager
-- Author: Jerry Lee
-- Date: 2014-12-03
--

local PopUpManager = class("PopUpManager")

-- a list hold all pop-up view components
PopUpManager.popUpComponents = {}

-- add pop-up view component
function PopUpManager:addPopUp(popUp, parent)
	if not popUp then return end
	if popUp.name then self.popUpComponents[popUp.name] = popUp end
	if parent then
		parent:addChild(popUp)
	else
		local runningScene = display.getRunningScene()
		runningScene:addChild(popUp)
	end
end

-- remnove pop-up view component
function PopUpManager:removePopUp(popUp, cleanup)
	if not popUp then return end
	local parent = popUp:getParent()
	cleanup = cleanup or true
	if popUp.name then self.popUpComponents[popUp.name] = nil end
	if parent then parent:removeChild(popUp, cleanup) end
	popUp = nil
end

-- remove pop-up view component by name
function PopUpManager:removePopUpByName(popUpName)
	local popUp = self.popUpComponents[popUpName]
	self:removePopUp(popUp)
end

-- singleton instance of PopUpManager
local instance = nil

-- get singleton instance of PopUpManager
function PopUpManager:getInstance()
	if not instance then instance = PopUpManager.new() end
	return instance
end

return PopUpManager
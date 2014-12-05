--
-- Notification manager
-- Author: Jerry Lee
-- Date: 2014-12-04
--

local NotificationManager = class("NotificationManager")

-- constructor
function NotificationManager:ctor()
	-- table to hold all commands
	self.commands_ = {}
end

-- register notification command callback
function NotificationManager:registerCommand(target, notificationName, command)
	if not self.commands_[notificationName] then self.commands_[notificationName] = {} end
	self.commands_[notificationName][target] = command
end

-- remove command by target
function NotificationManager:removeCommands(target)
	for notificationName, cmds in pairs(self.commands_) do
		cmds[target] = nil
	end
end

-- remove the command of target by notification name
function NotificationManager:removeTargetCommandByNotificationName(target, notificationName)
	if not self.commands_[notificationName] then return end
	self.commands_[notificationName][target] = nil
end

-- remove all commands by notification name
function NotificationManager:removeCommandsByNotificationName(notificationName)
	self.commands_[notificationName] = nil
end

--  remove all command whatever the target is
function NotificationManager:removeAllCommands()
	self.commands_ = {}
end

-- send a notification
function NotificationManager:sendNotification(notificationName, body, notificationType)
	local targets = self.commands_[notificationName]

	if targets then
		for target, command in pairs(targets) do
			if command then command(notificationName, body, notificationType) end
		end
	end
end

-- singleton instance of NotificationManager
local instance = nil

-- get singleton instance of NotificationManager
function NotificationManager:getInstance()
	if not instance then instance = NotificationManager.new() end
	return instance
end

return NotificationManager
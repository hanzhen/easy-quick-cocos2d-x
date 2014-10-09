local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
end)

function MainScene:ctor()
	local label = cc.ui.UILabel.new({
            UILabelType = 2, text = "Hello, World", size = 64})
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	-- data manager
	local dataManager = require("easy.config.CCSGameDataManager")

	-- attribute mode
	dataManager:loadDataFile("data/test")
	
	local dataList = dataManager:getGameDataList("test")
	dump(dataList)

	local data = dataManager:getGameDataById("test", 1)
	dump(data)

	data = dataManager:getGameDataByKVP("test", "name", "cosmos2")
	dump(data)

	data = dataManager:getGameDataByKVPs("test", {name = "cosmos3", hp = 300})
	dump(data)

	-- object mode
	dataManager:setObjectMode(true)
	dataManager:loadDataFile("data/test_obj")

	dataList = dataManager:getGameDataList("test_obj")
	dump(dataList)

	local data = dataManager:getGameDataById("test_obj", 1)
	dump(data)

	data = dataManager:getGameDataByKVP("test_obj", "name", "cosmos2")
	dump(data)

	data = dataManager:getGameDataByKVPs("test_obj", {name = "cosmos3", hp = 300})
	dump(data)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene

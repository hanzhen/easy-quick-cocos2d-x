--
-- Description: Game data manager for Cocos Studio GameDataEditor.
-- Author: Jerry Lee
-- Date: 2014-10-09
--

local CCSGameDataManager = class("CCSGameDataManager")

-- constructor method
function CCSGameDataManager:ctor()
	self.dataHash_ = {}
	self.objectMode_ = false
end

-- set object mode
function CCSGameDataManager:setObjectMode(objectMode)
	self.objectMode_ = objectMode or false
end

-- load data file from file path
function CCSGameDataManager:loadDataFile(filePath)
	local hashKey = self:_genHashKey(filePath)
	local fullPath = cc.FileUtils:getInstance():fullPathForFilename(filePath)

	if io.exists(fullPath) then
		if hashKey ~= nil then self.dataHash_[hashKey] = {} else return nil end
		local json = json.decode(io.readfile(fullPath))

		if self.objectMode_ then
			-- object mode
			local fieldNames = json[1]
			local length = #json

			for i = 2, length do
				local jsonData = json[i]
				local data = {}

				for j, v in ipairs(jsonData) do
					local fieldName = fieldNames[j]
					data[fieldName] = v
				end

				if data.id ~= nil then self.dataHash_[hashKey][data.id] = data end
			end
		else
			-- attribute mode
			for i, v in ipairs(json) do
				if v.id ~= nil then self.dataHash_[hashKey][v.id] = v end
			end
		end
	else
		printInfo("no game data file for path: %s", fullPath)
	end
end

--  load data fiels from file paths
function CCSGameDataManager:loadDataFiles(filePaths)
	for i, v in ipairs(filePaths) do
		self:loadDataFile(v)
	end
end

-- get game data list by hash key
function CCSGameDataManager:getGameDataList(hashKey)
	return self.dataHash_[hashKey]
end

-- get game data by hash key and id
function CCSGameDataManager:getGameDataById(hashKey, id)
	local dataList = self:getGameDataList(hashKey)
	if dataList ~= nil then return dataList[id] else return nil end
end

-- get game data by hash key, key and value
function CCSGameDataManager:getGameDataByKVP(hashKey, key, value)
	local dataList = self:getGameDataList(hashKey)

	if dataList ~= nil then
		for k, v in pairs(dataList) do
			if v[key] == value then return v end
		end
	end

	return nil
end

--  get game data by hash key and kvp pairs
function CCSGameDataManager:getGameDataByKVPs(hashKey, kvps)
	local dataList = self:getGameDataList(hashKey)
	local nums = table.nums(kvps)

	if dataList ~= nil then
		for k, v in pairs(dataList) do
			local count = 0

			for key, value in pairs(kvps) do
				if v[key] == value then count = count + 1 end
			end

			if count == nums then return v end
		end
	end

	return nil
end

-- generate key for data hash
function CCSGameDataManager:_genHashKey(filePath)
	local dir = string.split(filePath, "/")
	local filename = dir[#dir]
	local names = string.split(filename, ".")
	return names[1]
end

return CCSGameDataManager.new()
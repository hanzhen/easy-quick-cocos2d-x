--
-- Description: HTML text label, support tag<font size="" color=""></font>, <br> or <br />, <img src="" />
-- Author: Jerry Lee
-- Date: 2014-10-09
--

local html = import("..modules.html")

if not cc.utils then cc.utils = require("framework.cc.utils.init") end

local UIHTMLTextLabel = class("UIHTMLTextLabel", function ()
	return display.newLayer()
end)

-- 构造函数
function UIHTMLTextLabel:ctor(params)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	params = params or {}
	self:setParams(params)
	self:setContentSize(cc.size(1, 1))

	self:setString(params.text or "NULL")
end

-- 设置参数
function UIHTMLTextLabel:setParams(params)
	params = params or {}
	self.color = color.hex2rgb(params.color or (self.color or "#FFFFFF"))
	self.font = params.font or (self.font or "Microsoft Yahei")
	self.fontSize = params.fontSize or (self.fontSize or 14)
	self.lineWidth = params.lineWidth or (self.linWidth or 280)
	self.lineSpace = params.lineSpace or (self.lineSpace or -4)
end

-- 设置字符串
function UIHTMLTextLabel:setString(text)
	-- 渲染文本相同时不重新渲染
	if self.text == text then return end
	self.text = text

	self:update()
end

-- 清理字符串显式
function UIHTMLTextLabel:clear()
	self:removeAllChildren()
end

-- 更新渲染
function UIHTMLTextLabel:update()
	self:clear()

	local data = html.parsestr(self.text)
	local tags = self:_parseString(data)
	self:_calculateTextWidth(tags)
	local lines = self:_createTextLines(tags)
	self:_addTextField(lines)
end

-- 解析字符串
function UIHTMLTextLabel:_parseString(data)
	local tags = {}

	-- 遍历标签数组
	for i, v in ipairs(data) do
		local tag = {}

		if type(v) ~= "table" then
			-- 非标签文字
			tag.name = "font"
			tag.text = v
			tag.color = self.color
			tag.size = self.fontSize
		else
			tag.name = v._tag

			-- 标签文字
			if v._tag == "font" then
				-- 字体标签
				tag.text = v[1]
				tag.color = color.hex2rgb(v._attr.color)
				tag.size = tonumber(v._attr.size) or self.fontSize
			elseif v._tag == "img" then
				-- 图片标签
				tag.img = {}
				tag.img.src = v._attr.src
				tag.img.width = v._attr.width
				tag.img.height = v._attr.height
			end
		end

		table.insert(tags, tag)
	end

	return tags
end

-- 计算文本宽度
function UIHTMLTextLabel:_calculateTextWidth(tags)
	local label = ui.newTTFLabel({ 
		text = "", 
		font = self.font,
		align = ui.TEXT_ALIGN_LEFT,
		valign = ui.TEXT_VALIGN_TOP
		})
	label:retain()

	for i, tag in ipairs(tags) do
		if tag.name == "font" then
			tag.chars = string.string2chars(tag.text)
			tag.charSizes = {}

			-- 计算每个字符的宽度
			for j, char in ipairs(tag.chars) do
				label:setString(char)
				label:setSystemFontSize(tag.size)
				local charSize = {}
				charSize.width = label:getContentSize().width
				charSize.height = label:getContentSize().height
				table.insert(tag.charSizes, charSize)
			end
		elseif tag.name == "img" then
			tag.sprite = display.newSprite(tag.img.src)
			if tag.img.width then tag.sprite:setContentSize(tag.img.width, tag.sprite:getContentSize().height) end
			if tag.img.height then tag.sprite:setContentSize(tag.sprite:getContentSize().width, tag.img.height) end
		end
	end

	label:release()
end

-- 创建文本行
function UIHTMLTextLabel:_createTextLines(tags)
	local currentLineWidth = 0
	local maxHeight = 0
	local str = ""
	local lineMaxHeight = 0
	local lines = {}
	local line = {}

	-- 插入行数据
	local function __insertLine()
		line.maxHeight = lineMaxHeight
		table.insert(lines, line)
	end

	-- 换行操作
	local function __newLine()
		-- 重置数据
		__insertLine()
		line = {}
		str = ""
		currentLineWidth = 0
		lineMaxHeight = 0
	end

	-- 插入新文本段
	local function __insertNewTextElement(text, color, size)
		local element = {}
		element.text = text
		element.color = color
		element.size = size
		table.insert(line, element)
	end

	-- 插入新图像段
	local function __insertNewImgElement(img, sprite)
		local element = {}
		element.img = img
		element.sprite = sprite
		table.insert(line, element)
	end

	local tagCount = #tags

	for i, tag in ipairs(tags) do
		if tag.name == "font" then
			local charCount = #tag.chars

			for j, charSize in ipairs(tag.charSizes) do
				if currentLineWidth + charSize.width > self.lineWidth then
					-- 换行
					__insertNewTextElement(str, tag.color, tag.size)
					__newLine()
				end

				-- 记录字符串
				str = str..tag.chars[j]
				lineMaxHeight = math.max(lineMaxHeight, charSize.height)
				currentLineWidth = currentLineWidth + charSize.width

				if j == charCount then
					-- 文本结束
					__insertNewTextElement(str, tag.color, tag.size)
					str = ""
					if i == tagCount then __insertLine() end
				end
			end
		elseif tag.name == "img" then
			if currentLineWidth + tag.img.width > self.lineWidth then
				-- 换行
				__newLine()
			end

			__insertNewImgElement(tag.img, tag.sprite)
			lineMaxHeight = math.max(lineMaxHeight, tag.sprite:getContentSize().height)
			currentLineWidth = currentLineWidth + tag.sprite:getContentSize().width
			if i == tagCount then __insertLine() end
		elseif tag.name == "br" then
			__newLine()
		end
	end

	return lines
end

-- 添加文本区域
function UIHTMLTextLabel:_addTextField(lines)
	local baseWidth = 0
	local baseHeight = 0
	local textFieldWidth = 0

	-- 创建文本对象
	local function __createTTFLabel(element)
		local label = ui.newTTFLabel({
			text = element.text,
			color = element.color,
			size = element.size,
			font = self.font,
			align = ui.TEXT_ALIGN_LEFT,
			valign = ui.TEXT_VALIGN_BOTTOM
			})

		return label
	end

	for i, line in ipairs(lines) do
		-- 计算基础高度
		baseHeight = baseHeight + line.maxHeight + self.lineSpace
		textFieldWidth = math.max(textFieldWidth, baseWidth)
		baseWidth = 0

		-- 遍历行元素
		for j, element in ipairs(line) do

			if element.text then
				-- 文本元素
				local label = __createTTFLabel(element)
				label:setAnchorPoint(cc.p(0, 0))
				label:setPosition(cc.p(baseWidth, -baseHeight))
				baseWidth = baseWidth + label:getContentSize().width
				self:addChild(label)
			else
				-- 图像元素
				local sprite = element.sprite
				sprite:setAnchorPoint(cc.p(0, 0))
				sprite:setPosition(cc.p(baseWidth, -baseHeight))
				baseWidth = baseWidth + element.img.width
				self:addChild(sprite)
			end
		end
	end

	self:setContentSize(cc.size(textFieldWidth, baseHeight))
end

return UIHTMLTextLabel
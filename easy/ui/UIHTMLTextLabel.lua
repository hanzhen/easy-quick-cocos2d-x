--
-- Description: HTML text label, support tag<font size="" color=""></font>, <br> or <br />, <img src="" />
-- Author: Jerry Lee
-- Date: 2014-10-09
--

-- 特殊字符
local SPECIAL_CHARACTERS = {
	"“",
	"”",
	"‘",
	"’",
	" ",
	"，",
	"。",
	"；",
	"！",
	"？"
}

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
	self.color_ = color.hex2rgb(params.color or (self.color_ or "#FFFFFF"))
	self.font_ = params.font or (self.font_ or "Microsoft Yahei")
	self.fontSize_ = params.fontSize or (self.fontSize_ or 14)
	self.lineWidth_ = params.lineWidth or (self.linWidth or 280)
	self.lineSpace_ = params.lineSpace or (self.lineSpace_ or -4)

	if params.shadowColor then
		self.shadowColor_ = color.hex2rgba(params.shadowColor)
	end
end

-- 设置字符串
function UIHTMLTextLabel:setString(text)
	-- 渲染文本相同时不重新渲染
	if self.text_ == text then return end
	self.text_ = text

	self:update()
end

-- 清理字符串显式
function UIHTMLTextLabel:clear()
	self:removeAllChildren()
end

-- 更新渲染
function UIHTMLTextLabel:update()
	self:clear()

	local data = html.parsestr(self.text_)
	local tags = self:parse_(data)
	self:calculateTextWidth_(tags)
	local lines = self:createTextLines_(tags)
	self:addTextField_(lines)
end

-- 解析
function UIHTMLTextLabel:parse_(data)
	local tags = {}

	-- 遍历标签数组
	for i, v in ipairs(data) do
		table.insert(tags, self:parseString_(v))
	end

	return tags
end

-- 解析字符串
function UIHTMLTextLabel:parseString_(v, tag)
	tag = tag or {}

	if type(v) ~= "table" then
		-- 非标签文字
		tag.name = "font"
		tag.text = v
		tag.color = self.color_
		tag.size = self.fontSize_
	else
		tag.name = v._tag

		-- 标签文字
		if v._tag == "font" then
			-- 字体标签
			tag.text = v[1]
			tag.color = color.hex2rgb(v._attr.color)
			tag.size = tonumber(v._attr.size) or self.fontSize_
		elseif v._tag == "img" then
			-- 图片标签
			tag.img = {}
			tag.img.src = v._attr.src
			tag.img.width = tonumber(v._attr.width)
			tag.img.height = tonumber(v._attr.height)
		elseif v._tag == "a" then
			-- 链接标签
			if v._attr.href then
				local hrefArr = string.split(v._attr.href, ":")
				if #hrefArr > 1 and string.lower(hrefArr[1]) == "event" then tag.event = hrefArr[2] end
			end
			
			self:parseString_(v[1], tag)
		end
	end

	return tag
end

-- 计算文本宽度
function UIHTMLTextLabel:calculateTextWidth_(tags)
	local label = cc.ui.UILabel.new({ 
		text = "", 
		font = self.font_,
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

				-- 修正部分字体中文标点符号获取宽度不准确的bug
				if self:isSpecialCharacter_(char) then charSize.width = tag.size end

				table.insert(tag.charSizes, charSize)
			end
		elseif tag.name == "img" then
			tag.sprite = display.newSprite(tag.img.src)
			local imgSize = tag.sprite:getContentSize()
			if not tag.img.width then tag.img.width = imgSize.width end
			if not tag.img.height then tag.img.height = imgSize.height end
			tag.sprite:setContentSize(tag.img.width, tag.img.height)

			if tag.event then
				-- 事件监听
				tag.sprite:setTouchEnabled(true)
				tag.sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
					self:dispatchEvent({ name = tag.event })
				end)
			end
		end
	end

	label:release()
end

-- 判断是否为特殊字符
function UIHTMLTextLabel:isSpecialCharacter_(char)
	for i, v in ipairs(SPECIAL_CHARACTERS) do
		if char == v then return true end
	end

	return false
end

-- 创建文本行
function UIHTMLTextLabel:createTextLines_(tags)
	local currentLineWidth = 0
	local maxHeight = 0
	local str = ""
	local lineMaxHeight = 0
	local lines = {}
	local line = {}

	-- 插入行数据
	local function insertLine__()
		line.maxHeight = lineMaxHeight
		table.insert(lines, line)
	end

	-- 换行操作
	local function newLine__()
		-- 重置数据
		insertLine__()
		line = {}
		str = ""
		currentLineWidth = 0
		lineMaxHeight = 0
	end

	-- 插入新文本段
	local function insertNewTextElement__(text, color, size, event)
		local element__ = {}
		element__.text = text
		element__.color = color
		element__.size = size
		element__.event = event
		table.insert(line, element__)
	end

	-- 插入新图像段
	local function insertNewImgElement__(img, sprite, event)
		local element__ = {}
		element__.img = img
		element__.sprite = sprite
		element__.event = event
		table.insert(line, element__)
	end

	local tagCount = #tags

	for i, tag in ipairs(tags) do
		if tag.name == "font" then
			local charCount = #tag.chars

			for j, charSize in ipairs(tag.charSizes) do
				if currentLineWidth + charSize.width > self.lineWidth_ then
					-- 换行
					insertNewTextElement__(str, tag.color, tag.size, tag.event)
					newLine__()
				end

				-- 记录字符串
				str = str..tag.chars[j]
				lineMaxHeight = math.max(lineMaxHeight, charSize.height)
				currentLineWidth = currentLineWidth + charSize.width

				if j == charCount then
					-- 文本结束
					insertNewTextElement__(str, tag.color, tag.size, tag.event)
					str = ""
					if i == tagCount then insertLine__() end
				end
			end
		elseif tag.name == "img" then
			if currentLineWidth + tag.img.width > self.lineWidth_ then
				-- 换行
				newLine__()
			end

			insertNewImgElement__(tag.img, tag.sprite, tag.event)
			lineMaxHeight = math.max(lineMaxHeight, tag.sprite:getContentSize().height)
			currentLineWidth = currentLineWidth + tag.sprite:getContentSize().width
			if i == tagCount then insertLine__() end
		elseif tag.name == "br" then
			newLine__()
		end
	end

	return lines
end

-- 添加文本区域
function UIHTMLTextLabel:addTextField_(lines)
	local baseWidth = 0
	local baseHeight = 0
	local textFieldWidth = 0

	-- 创建文本对象
	local function createTTFLabel__(element)
		local node__ = nil
		local label__ = cc.ui.UILabel.new({
			text = element.text,
			color = element.color,
			size = element.size,
			font = self.font_,
			align = ui.TEXT_ALIGN_LEFT,
			valign = ui.TEXT_VALIGN_BOTTOM
			})

		-- 阴影
		if self.shadowColor_ then
			label__:enableShadow(self.shadowColor_, cc.size(2, -2))
		end

		label__:setAnchorPoint(0, 0)

		if element.event then
			-- 监听事件
			local contentSize__ = label__:getContentSize()
			node__ = display.newNode()
			node__:setAnchorPoint(0, 0)
			node__:setContentSize(contentSize__.width, contentSize__.height)
			node__:setTouchEnabled(true)
			node__:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
				self:dispatchEvent({ name = element.event })
			end)
			node__:addChild(label__)
		end

		return node__ or label__
	end

	for i = #lines, 1, -1 do
		local line = lines[i]
		baseWidth = 0

		-- 遍历行元素
		for j, element in ipairs(line) do

			if element.text then
				-- 文本元素
				local label = createTTFLabel__(element)
				label:setPosition(cc.p(baseWidth, baseHeight))
				baseWidth = baseWidth + label:getContentSize().width
				self:addChild(label)
			else
				-- 图像元素
				local sprite = element.sprite
				sprite:setAnchorPoint(cc.p(0, 0))
				sprite:setPosition(cc.p(baseWidth, baseHeight))
				baseWidth = baseWidth + element.img.width
				self:addChild(sprite)
			end
		end

		-- 计算基础高度
		textFieldWidth = math.max(textFieldWidth, baseWidth)
		baseHeight = baseHeight + line.maxHeight + self.lineSpace_
	end

	self:setContentSize(cc.size(textFieldWidth, baseHeight - self.lineSpace_))
end

return UIHTMLTextLabel
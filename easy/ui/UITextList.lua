--
-- Author: Jerry Lee
-- Date: 2014-11-04
--

local UIHTMLTextLabel = import(".UIHTMLTextLabel")

local UITextList = class("UITextList", cc.ui.UIListView)

-- 构造函数
function UITextList:ctor(params)
	UITextList.super.ctor(self, params)

	if params then
		self.itemHistory_ = params.itemHistory or 0
		self.textColor_ = params.textColor or "#FFFFFF"
		self.textFont_ = params.textFont or "Microsoft Yahei"
		self.textFontSize_ = params.textFontSize or 14
		self.textLineWidth_ = params.textLineWidth or self.viewRect_.width
		self.textLineSpace_ = params.textLineSpace or -2
	end

	self.scaleToWorldSpace_ = self:scaleToParent_()
end

-- 设置条目显示记录上限
function UITextList:setItemHistory(itemHistory)
	self.itemHistory_ = itemHistory or self.itemHistory_
end

-- 添加一条多颜色文本
function UITextList:addText(text, updateVisible)
	local oldX, oldY = self.scrollNode:getPosition()

	local item = self:newItem()
	local label = UIHTMLTextLabel.new({
		color = self.textColor_,
		font = self.textFont_,
		fontSize = self.textFontSize_,
		lineWidth = self.textLineWidth_,
		lineSpace = self.textLineSpace_
		})
	label:setString(text)
	label:setTouchEnabled(false)
	local labelSize = label:getContentSize()
	item:addContent(label)
	item:setItemSize(labelSize.width, labelSize.height, true)
	self:addItem(item)
	self:reload()

	local deleteFirst = false
	local firstItemWidth, firstItemHeight = self.items_[1]:getItemSize()

	if self.itemHistory_ > 0 and self:getItemCount() > self.itemHistory_ then
		deleteFirst = true
		self:removeItem(self.items_[1])
	end

	if updateVisible then
		-- 直接到最底部
		self:gotToEnd(deleteFirst, firstItemWidth, firstItemHeight)
	else
		-- 返回原位置
		self:moveTo(oldX, oldY - labelSize.height, labelSize.height, firstItemHeight)
	end
end

-- 显示到文本末尾
function UITextList:gotToEnd(deleteFirst, firstItemWidth, firstItemHeight)
	deleteFirst = deleteFirst or false
	firstItemWidth = firstItemWidth or 0
	firstItemHeight = firstItemHeight or 0
	local x, y = self.scrollNode:getPosition()
	local bound = self:getScrollNodeRect()
	local yOffset = 0
	if deleteFirst then yOffset = -firstItemHeight end
	if bound.height >= self.viewRect_.height then
		self.scrollNode:setPosition(x, yOffset)
	end
end

-- 滚动结点移动到指定位置
function UITextList:moveTo(x, y, itemHeight, firstItemHeight)
	local bound = self:getScrollNodeRect()

	if bound.height >= self.viewRect_.height then
		self.scrollNode:setPosition(x, y)
	end
end

-- 布局方法
function UITextList:layout_()
	UITextList.super.layout_(self)

	for i, v in ipairs(self.items_) do
		local content = v:getContent()
		content:setAnchorPoint(0, 0)
	end
end

-- 获取列表项数目
function UITextList:getItemCount()
	if self.items_ then return #self.items_ else return 0 end
end

-- 阻止父类改变布局
function UITextList:setPositionByAlignment_(content, w, h, margin)
	-- body
end

return UITextList
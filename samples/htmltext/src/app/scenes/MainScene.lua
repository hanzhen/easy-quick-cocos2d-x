
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local label = ui.newHTMLTextLabel("", {})
		:addTo(self)
		:pos(display.cx, display.cy)
		
	label:setString('你好<font color="#00FF00">我不好</font>')
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene

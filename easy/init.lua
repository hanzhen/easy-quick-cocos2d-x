--
-- Author: Jerry Lee
-- Date: 2014-10-09
--

import(".functions")

easy = easy or {}
easy.FRAMEWORK_NAME = "easy-quick-cocos2d-x"

easy.managers = import(".managers.init")
easy.ui = import(".ui.init")

if not ui then ui = import("..framework.ui") end
table.merge(ui, import(".ui"))

if not display then display = import("..framework.display") end
table.merge(display, import(".display"))
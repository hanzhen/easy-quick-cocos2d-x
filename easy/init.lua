--
-- Author: Jerry Lee
-- Date: 2014-10-09 15:38:28
--

import(".functions")

easy = easy or {}
easy.FRAMEWORK_NAME = "easy-quick-cocos2d-x"

easy.ui = import(".ui.init")

if package.loaded["ui"] == nil then ui = import("..framework.ui") end
table.merge(ui, import(".ui"))
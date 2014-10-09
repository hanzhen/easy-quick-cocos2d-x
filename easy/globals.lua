--
-- Author: Jerry Lee
-- Date: 2014-10-09 15:38:28
--

-- reload script file
function reload(filename)
	package.loaded[filename] = nil
	return require(filename)
end
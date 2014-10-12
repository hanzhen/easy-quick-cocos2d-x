--
-- Author: Jerry Lee
-- Date: 2014-10-09
--

-- reload script file
function reload(filename)
	package.loaded[filename] = nil
	return require(filename)
end

color = color or {};

-- convert hex color to rgb color
function color.hex2rgb(hex)
	hex = string.gsub(hex, "#", "")
	local r = tonumber("0x"..string.sub(hex, 1, 2))
	local g = tonumber("0x"..string.sub(hex, 3, 4))
	local b = tonumber("0x"..string.sub(hex, 5, 6))
	return cc.c3b(r, g, b)
end

-- 输出16进制字符串
function string.hex(input)
	return string.gsub(input, "(.)", function (x) return string.format("%02X", string.byte(x)) end)
end

-- convert string to char array
function string.string2chars(input)
	local list = {}
	local length = string.len(input)
	local i = 1

	while i <= length do
		local b = string.byte(input, i)
		local offset = 1

		if b > 0 and b <= 127 then
			offset = 1
		elseif b >= 192 and b <= 223 then
			offset = 2
		elseif b >= 224 and b <= 239 then
			offset = 3
		elseif b >= 240 and b <= 247 then
			offset = 4
		end
		
		local char = string.sub(input, i, i + offset - 1)
		table.insert(list, char)

		i = i + offset
	end

	return list, #list
end
--[[
	References:

	http://pic.dhe.ibm.com/infocenter/aix/v6r1/index.jsp?topic=%2Fcom.ibm.aix.basetechref%2Fdoc%2Fbasetrf1%2Fctype.htm
	http://www.cplusplus.com/reference/clibrary/cctype/
--]]

local ffi = require "ffi"
local bit = require "bit"
local band = bit.band
local bor = bit.bor

local B = string.byte


local function isalpha(c)
	return (c >= B'a' and c <= B'z') or
		(c >= B'A' and c <= B'Z')
end

local function isdigit(c)
	return c >= B'0' and c <= B'9'
end

local function isalnum(c)
	return (isalpha(c) or isdigit(c))
end



local function isascii(c)
	return (c >= 0) and (c <= 0x7f)
end

local function isbyte(n)
	return band(n,0xff) == n
end

-- 0x00 0x20	control, space
-- x7f	Del
local function iscntrl(c)
	return (c >= 0 and c < 0x20) or (c == 0x7f)
end



local function isgraph(c)
	return c > 0x20 and c < 0x7f
end

local function islower(c)
	return c >= B'a' and c <= B'z';
end

local function isprint(c)
	return c >= 0x20 and c < 0x7f
end


local function ispunct(c)
	return isgraph(c) and not isalnum(c)
--[[
	return (c>=0x21 and c<=0x2f) or
		(c>=0x3a and c<=0x40) or
		(c>=0x5b and c<=0x60) or
		(c>=0x7b and c<=0x7e)
--]]
end

-- ' ' 0x20, 
-- '\t' 0x09, 
-- '\n' 0x0a, 
-- '\v' 0x0b, 
-- '\f' 0x0c, 
-- '\r' 0x0d
local function isspace(c)
	return c == 0x20 or (c >= 0x09 and c<=0x0d)
end

local function isupper(c)
	return c >= B'A' and c <= B'Z';
end

local function isxdigit(c)
	if isdigit(c) then return true end

	return (c >= B'a' and c <= B'f') or
		(c >= B'A' and c <= B'F')
end

local function tolower(c)
	return band(0xff,bor(c, 0x20))
end

local function toupper(c)
	if (islower(c)) then
		return band(c, 0x5f)
	end

	return c
end

return {
	isalnum = isalnum,
	isalpha = isalpha,
	isascii = isascii,
	isbyte	= isbyte,
	iscntrl = iscntrl,
	isdigit = isdigit,
	isgraph = isgraph,
	islower = islower,
	isprint = isprint,
	ispunct = ispunct,
	isspace = isspace,
	isupper = isupper,
	isxdigit = isxdigit,

	tolower = tolower,
	toupper = toupper,
}

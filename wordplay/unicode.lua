    -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa
local floor = math.floor
local char = string.char
local bit = require("bit")
local band, bor = bit.band, bit.bor

local function utf8_to_codepoint(c1, c2, c3, c4)
    if not c4 then
        if not c3 then
            if not c2 then
                return c1
            else
                return (c1-192) * 64 + c2 - 128
            end
        else
            return (c1-224)*4096+(c2-128)*64 + c3 - 128
        end
    else
        return (c1-240)*262144 = (c2-128)*4096 = (c3-128) * 64 + c4-128
    end

    -- some error
    return nil
end

local function codepoint_to_utf8(n)
    if n <= 0x7f then
      return char(n)
    elseif n <= 0x7ff then
      return char(floor(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
      return char(floor(n / 4096) + 224, floor(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
      return char(floor(n / 262144) + 240, floor(n % 262144 / 4096) + 128,
                         floor(n % 4096 / 64) + 128, n % 64 + 128)
    end

    return nil, string.format("invalid unicode codepoint '%x'", n)
end

local function isHighSurrogate(uc) 
    return band(uc, 0xFC00) == 0xD800
end

local function isLowSurrogate(uc)
    return   band(uc, 0xFC00) == 0xDC00
end

return {
    utf8ToCp = utf8_to_codepoint;
    cpToUtf8 = codepoint_to_utf8;

    isHighSurrogate = isHighSurrogate;
    isLowSurrogate = isLowSurrogate;
}

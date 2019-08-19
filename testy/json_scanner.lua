package.path = "../?.lua;"..package.path

local ffi = require("ffi")
local enum = require("wordplay.enum")

local cctype = require("wordplay.cctype")
local isdigit = cctype.isdigit
local isalpha = cctype.isalpha
local isalnum = cctype.isalnum
local isspace = cctype.isspace

local octetstream = require("wordplay.octetstream")

local B = string.byte


local json_common = require("json_common")
local Token = json_common.Token;
local TokenType = json_common.TokenType;
local STATES = json_common.STATES;

-- helper function
-- if the next character in the stream matches
-- what is expected, then consume it and return true
-- otherwise, don't consume it, and return false.
local function match(bs, expected)
    if bs:isEOF() then
        return false;
    end

    if bs:peekOctet() ~= expected then
        return false;
    end

    -- advance by one octet
    bs:skip(1)

    return true;
end

-- helper function
-- if the next set of characters in the stream matches
-- the string expected, then consume it and return true
-- otherwise, don't consume it, and return false.
local function matchString(bs, expected)
    if bs:isEOF() then
        return false;
    end

    for i=0,#expected-1 do
        if bs:peekOctet(i) ~= expected:byte(i+1) then
            return false;
        end
    end

    -- advance by length of expected
    bs:skip(#expected)

    return true;
end

--[[
    lexemeMap

    Provides easy connection between first character of a lexeme
    and possible code to scan it.
]]
local lexemeMap = {}

lexemeMap[B'{'] = function(bs)
    return (Token{kind = TokenType.LEFT_BRACE, lexeme='{', literal='', line=bs:tell()}); 
end

lexemeMap[B'}'] = function(bs)
    return (Token{kind = TokenType.RIGHT_BRACE, lexeme='}', literal='', line=bs:tell()}); 
end

lexemeMap[B'['] = function(bs)
    return Token{kind = TokenType.LEFT_BRACKET, lexeme='[', literal='', line=bs:tell()}; 
end

lexemeMap[B']'] = function(bs) 
    return (Token{kind = TokenType.RIGHT_BRACKET, lexeme=']', literal='', line=bs:tell()}); 
end

lexemeMap[B':'] = function(bs) 
    return (Token{kind = TokenType.COLON, lexeme=':', literal='', line=bs:tell()}); 
end

lexemeMap[B','] = function(bs) 
    return (Token{kind = TokenType.COMMA, lexeme=',', literal='', line=bs:tell()}); 
end

-- largely ignoring whitespace
lexemeMap[B' '] = function(bs) end
lexemeMap[B'\r'] = function(bs) end
lexemeMap[B'\t'] = function(bs) end
lexemeMap[B'\n'] = function(bs) end

-- string literal
lexemeMap[B'"'] = function(bs)
    local starting = bs:tell()
    local startPtr = bs:getPositionPointer();

    while bs:peekOctet() ~= B'"' and not bs:isEOF() do
        --if bs:peekOctet() == B'\n' then
        --    bs:incrementLineCount();
        --end

        -- skip to next character
        bs:skip(1);
    end

    -- unterminated string
    if bs:isEOF() then
        -- report unterminated string error
        return ;
    end

    local ending = bs:tell()
    local len = ending - starting
    
    -- skip over closing '"'
    bs:skip(1)

    local value = ffi.string(startPtr, len)

    -- return the string literal
    return (Token{kind = TokenType.STRING, lexeme='', literal=value, line=bs:tell()})
end



-- scan a number
local function lex_number(bs)
    -- start back at first digit
    bs:skip(-1)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    -- get through all digits
    while(isdigit(bs:peekOctet())) do
        bs:skip(1);
    end

    -- look for fraction part
    --print("lex_number: ", string.char(bs:peekOctet()), string.char(bs:peekOctet(1)))
    if (bs:peekOctet() == B'.') then
        if isdigit(bs:peekOctet(1)) then
            bs:skip(1);

            while isdigit(bs:peekOctet()) do
                bs:skip(1);
            end
        elseif isspace(bs:peekOctet(1)) then
            bs:skip(1)
        end
    end

    local ending = bs:tell();
    local len = ending - starting;

    local value = tonumber(ffi.string(startPtr, len))
    
    -- return the number literal
    --return (Token{kind = TokenType.NUMBER, lexeme='', literal=value, line=bs:getLine()})
    return (Token{kind = TokenType.NUMBER, lexeme='', literal=value, line=starting})
end

-- scan identifiers
-- 'null', 'false', 'true'
local function lex_identifier(bs)
    --print("lex_identifier")
    -- start back at first digit
    bs:skip(-1)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    while isalpha(bs:peekOctet()) do
    --while isalnum(bs:peekOctet()) do
        bs:skip();
    end

    local ending = bs:tell();
    local len = ending - starting;
    local value = ffi.string(startPtr, len)
--print("value: ", value)
    -- See if the identifier is a reserved word
    local kind = TokenType[value]
    local tok =  Token{kind = kind, lexeme=value, literal='', position=bs:tell()}


    if kind == TokenType["true"] then
        tok.literal = true;
    elseif kind == TokenType["false"] then
        tok.literal = false;
    elseif kind == TokenType["null"] then
        tok.literal = nil;
    else
        kind = TokenType.STRING
    end

    return tok
end

local JSONScanner = {}
local JSONScanner_mt = {
    __index = JSONScanner
}

function JSONScanner.init(self, obj)

    setmetatable(obj, JSONScanner_mt)

    return obj;
end

function JSONScanner.new(self, bs)
    if not bs then return nil end

    return self:init({stream = bs})
end

--[[
 iterator, returning individually scanned lexemes
 need to make this pure functional
 create a range on the stream?
--]]
function JSONScanner.tokens(self)
    
    local function token_gen(bs, state)
        while not bs:isEOF() do
            local c = bs:readOctet()

            if lexemeMap[c] then
                local tok, err = lexemeMap[c](bs)
                if tok then
                    return bs:tell(), tok;
                else
                    -- deal with error if there was one
                end
            else
                if isdigit(c) then
                    local tok = lex_number(bs)
                    return bs:tell(), tok
                elseif isalpha(c) then
                    local tok = lex_identifier(bs)
                    return bs:tell(), tok
                else
                    print("UNKNOWN: ", string.char(c)) 
                end
            end
        end
    end

    return token_gen, self.stream, self.stream:tell()
end


return JSONScanner

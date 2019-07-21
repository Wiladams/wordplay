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


local gcode = require("gcode")
local Token = gcode.Token;
local TokenType = gcode.TokenType;


--[[
    lexemeMap

    Provides easy connection between first character of a lexeme
    and possible code to scan it.
]]
local lexemeMap = {}
lexemeMap[B'-'] = function(bs) 
    return (Token{Kind = TokenType.MINUS, lexeme='-', literal='', line=bs:tell()}); 
end

-- processing a comment, consume til end of line or EOF
lexemeMap[B';'] = function(bs)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    while bs:peekOctet() ~= B'\n' and not bs:isEOF() do
            bs:skip(1)
    end

    local ending = bs:tell();
    local len = ending - starting;
    local value = ffi.string(startPtr, len)

    return (Token{Kind = TokenType.COMMENT, lexeme=value, literal='', line=starting});
end

-- largely ignoring whitespace
lexemeMap[B' '] = function(bs) end
lexemeMap[B'\r'] = function(bs) end
lexemeMap[B'\t'] = function(bs) end
lexemeMap[B'\n'] = function(bs)
    --bs:incrementLineCount();
end

-- nuber signs
lexemeMap[B'-'] = function(bs) 
    return (Token{Kind = TokenType.MINUS, lexeme='-', literal='', line=bs:tell()}); 
end

lexemeMap[B'+'] = function(bs) 
    return (Token{Kind = TokenType.PLUS, lexeme='+', literal='', line=bs:tell()}); 
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
    --return (Token{Kind = TokenType.NUMBER, lexeme='', literal=value, line=bs:getLine()})
    return (Token{Kind = TokenType.NUMBER, lexeme='', literal=value, line=starting})

end

-- scan identifiers
-- this is usually going to be a single character
-- but we'll deal with multiples just for fun
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
    if not kind then
        kind = TokenType.IDENTIFIER
    end

    -- return the identifier
    local tok =  Token{Kind = kind, lexeme=value, literal='', position=bs:tell()}
    return tok
end

-- iterator, returning individually scanned lexemes
-- BUGBUG - make this a non-coroutine iterator
local function scanner(bs)

    local function token_gen(bs, state)

        while not bs:isEOF() do
            local c = bs:readOctet()

            if lexemeMap[c] then
                local tok, err = lexemeMap[c](bs)
                if tok then
                    -- BUGBUG
                    -- when routines only return a token
                    -- uncomment the following
                    --coroutine.yield(result)
                    return state + 1, tok;
                else
                    -- deal with error if there was one
                end
            else
                if isdigit(c) then
                    local tok = lex_number(bs)
                    return state + 1, tok
                    --coroutine.yield(lex_number(bs))
                elseif isalpha(c) then
                    local tok = lex_identifier(bs)
                    --print(tok)
                    --coroutine.yield(tok)
                    return state + 1, tok
                else
                    print("UNKNOWN: ", string.char(c)) 
                end
            end
        end
    end

    --return coroutine.wrap(iter)
    return token_gen, bs, 0
end


return scanner

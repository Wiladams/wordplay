package.path = "../?.lua;"..package.path

--[[
    References
    http://craftinginterpreters.com/

    Implementing the lox language lexer
--]]

local ffi = require("ffi")
local C = ffi.C 

local binstream = require("wordplay.binstream")

ffi.cdef[[
enum TokenType {                                   
        // Single-character tokens.                      
        LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE,
        COMMA, DOT, MINUS, PLUS, SEMICOLON, SLASH, STAR, 
      
        // One or two character tokens.                  
        // [11]
        BANG, BANG_EQUAL,                                
        EQUAL, EQUAL_EQUAL,                              
        GREATER, GREATER_EQUAL,                          
        LESS, LESS_EQUAL,                                
      
        // Literals.                                     
        // [19]
        IDENTIFIER, 
        STRING, 
        NUMBER,                      
      
        // Keywords.                                     
        //  [22]
        AND, CLASS, ELSE, FALSE, FUN, FOR, IF, NIL, OR,  
        PRINT, RETURN, SUPER, THIS, TRUE, VAR, WHILE,    
      
        // [38]
        EOF                                              
};
]]

local keywords = {
    ["and"]     = C.AND;
    ["class"]   = C.CLASS;
    ["else"]    = C.ELSE;
    ["false"]   = C.FALSE;
    ["for"]     = C.FOR;
    ["fun"]     = C.FUN;
    ["if"]      = C.IF;
    ["nil"]     = C.NIL;
    ["or"]      = C.OR;
    ["print"]   = C.PRINT;
    ["return"]  = C.RETURN;
    ["super"]   = C.SUPER;
    ["this"]    = C.THIS;
    ["true"]    = C.TRUE;
    ["var"]     = C.VAR;
    ["while"]   = C.WHILE;
}

local B = string.byte



local T_LBRACE = string.byte('{')
local T_RBRACE = string.byte('}')
local T_COMMA = string.byte(',')
local T_DOT = string.byte('.')
local T_MINUS = string.byte('-')
local T_PLUS = string.byte('+')
local T_SEMICOLON = string.byte(';')
local T_SLASH = string.byte('/')
local T_STAR = string.byte('*')
local T_BANG = string.byte('!')



local function isDigit(c)
    return c >= B'0' and c <= B'9';
end

local function isAlpha(c)
    return c >= B'a' and c <= B'z' or
        c >= B'A' and c <= B'Z' or
        c == B'_';
end

local function isAlphaNumeric(c)
    return isAlpha(c) or isDigit(c)
end

local function match(bs, expected)
    if bs:EOF() then
        return false;
    end

    --print("peek: ", bs:peekOctet(), expected )
    if bs:peekOctet() ~= expected then

        return false;
    end

    -- advance by one
    bs:skip(1)

    return true;
end


local Token_mt = {
    __tostring = function(self)
        return string.format("%d %s %s", self.Kind, self.lexeme, self.literal)
    end;
}
local function Token(obj)
    setmetatable(obj, Token_mt)
    return obj;
end


local lexemeMap = {}

lexemeMap[B'('] = function(bs)
    coroutine.yield (Token{Kind = C.LEFT_PAREN, lexeme='(', literal='', line=bs:getLine()}); 
end

lexemeMap[B')'] = function(bs) 
    coroutine.yield (Token{Kind = C.RIGHT_PAREN, lexeme=')', literal='', line=bs:getLine()}); 
end

lexemeMap[T_LBRACE] = function(bs) 
    coroutine.yield (Token{Kind = C.LEFT_BRACE, lexeme='{', literal='', line=bs:getLine()}); 
end

lexemeMap[T_RBRACE] = function(bs) 
    coroutine.yield (Token{Kind = C.RIGHT_BRACE, lexeme='}', literal='', line=bs:getLine()}); 
end

lexemeMap[T_COMMA] = function(bs) 
    coroutine.yield (Token{Kind = C.COMMA, lexeme=',', literal='', line=bs:getLine()}); 
end

lexemeMap[T_DOT] = function(bs) 
    coroutine.yield (Token{Kind = C.DOT, lexeme='.', literal='', line=bs:getLine()}); 
end

lexemeMap[T_MINUS] = function(bs) 
    coroutine.yield (Token{Kind = C.MINUS, lexeme='-', literal='', line=bs:getLine()}); 
end

lexemeMap[T_PLUS] = function(bs) 
    coroutine.yield (Token{Kind = C.PLUS, lexeme='+', literal='', line=bs:getLine()}); 
end

lexemeMap[T_SEMICOLON] = function(bs) 
    coroutine.yield (Token{Kind = C.SEMICOLON, lexeme=';', literal='', line=bs:getLine()}); 
end

lexemeMap[T_STAR] = function(bs) 
    coroutine.yield (Token{Kind = C.STAR, lexeme='*', literal='', line=bs:getLine()}); 
end

lexemeMap[B'!'] = function(bs) 
    if match(bs, B'=') then 
        coroutine.yield (Token{Kind = C.BANG_EQUAL, lexeme='!=', literal='', line=bs:getLine()});
    else
        coroutine.yield (Token{Kind = C.BANG, lexeme='!', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'='] = function(bs) 
    if match(bs, B'=') then 
        coroutine.yield (Token{Kind = C.EQUAL_EQUAL, lexeme='==', literal='', line=bs:getLine()});
    else
        coroutine.yield (Token{Kind = C.EQUAL, lexeme='=', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'<'] = function(bs) 
    if match(bs, B'=') then 
        coroutine.yield (Token{Kind = C.LESS_EQUAL, lexeme='<=', literal='', line=bs:getLine()});
    else
        coroutine.yield (Token{Kind = C.LESS, lexeme='<', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'>'] = function(bs) 
    if match(bs, B'=') then 
        coroutine.yield (Token{Kind = C.GREATER_EQUAL, lexeme='>=', literal='', line=bs:getLine()});
    else
        coroutine.yield (Token{Kind = C.GREATER, lexeme='>', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'/'] = function(bs)
    if match(bs, B'/') then 
        -- processing a comment, consume til end of line or EOF
        -- totally throw away comment
        while bs:peekOctet() ~= B'\n' and not bs:EOF() do
            bs:skip(1)
        end
    else
        coroutine.yield (Token{Kind = C.SLASH, lexeme='/', literal='', line=bs:getLine()});
    end
end

-- largely ignoring whitespace
lexemeMap[B' '] = function(bs)
end
lexemeMap[B'\r'] = function(bs)
end
lexemeMap[B'\t'] = function(bs)
end
lexemeMap[B'\n'] = function(bs)
    bs:incrementLineCount();
end

-- string literal

lexemeMap[B'"'] = function(bs)
    local starting = bs:tell()
    local startPtr = bs:getPositionPointer();

    while bs:peekOctet() ~= B'"' and not bs:EOF() do
        if bs:peekOctet() == B'\n' then
            bs:incrementLineCount();
        end

        -- skip to next character
        bs:skip(1);
    end

    -- unterminated string
    if bs:EOF() then
        -- report unterminated string error
        return ;
    end

    local ending = bs:tell()
    local len = ending - starting
    
    -- skip over closing '"'
    bs:skip(1)

    local value = ffi.string(startPtr, len)

    -- return the string literal
    coroutine.yield (Token{Kind = C.STRING, lexeme='', literal=value, line=bs:getLine()})
end

local function lex_number(bs)
    -- start back at first digit
    bs:skip(-1)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    -- get through all digits
    while(isDigit(bs:peekOctet())) do
        bs:skip(1);
    end

    -- look for fraction part
    if bs:peekOctet() == B'.' and isDigit(bs:peekOctet(1)) then
        bs:skip(1);

        while isDigit(bs:peekOctet()) do
            bs:skip(1);
        end
    end

    local ending = bs:tell();
    local len = ending - starting;

    local value = tonumber(ffi.string(startPtr, len))
    
    -- return the number literal
    coroutine.yield (Token{Kind = C.NUMBER, lexeme='', literal=value, line=bs:getLine()})

end

local function lex_identifier(bs)
    -- start back at first digit
    bs:skip(-1)
    local starting = bs:tell();
    local startPtr = bs:getPositionPointer();

    while isAlphaNumeric(bs:peekOctet()) do
        bs:skip();
    end

    local ending = bs:tell();
    local len = ending - starting;
    local value = ffi.string(startPtr, len)

    -- See if the identifier is a reserved word
    local kind = keywords[value]
    if not kind then
        kind = C.IDENTIFIER
    end

    -- return the identifier
    coroutine.yield (Token{Kind = kind, lexeme=value, literal='', line=bs:getLine()})
end


local function lexemes(str)
    local bs = binstream(str, #str, 0)

    local function iter()

        while not bs:EOF() do
            local c = bs:readOctet()
            --print(string.char(c))
            if lexemeMap[c] then
                lexemeMap[c](bs)
            else
                if isDigit(c) then
                    lex_number(bs)
                elseif isAlpha(c) then
                    lex_identifier(bs)
                else
                    print("UNKNOWN: ", string.char(c)) 
                end
            end
        end
    end

    return coroutine.wrap(iter)
end

return lexemes
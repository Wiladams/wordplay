package.path = "../?.lua;"..package.path

-- SAME as lox_lexer, but trying some new things

--[[
    This single file is the lexer for the toy 'lox' 
    language.  The file returns a single iterator which
    can be used to scan an input, and return a stream 
    of tokens, which can be used by other processes.

    Typical usage:

    local lexemes = require("lox_lexer")
    for token in lexemes("var a = 123.45;") do
        print(token)
    end


    Note:
    This scanner is done as an iterator so that it can 
    be easily composed with other tools in a pipeline.  This
    opens up a possibility where various kinds of tools
    can be put together quickly by simply throwing together
    various iterators.  For example, I want lox language
    tokens, but I want to generate lua tables in a backend.
    
    References
    http://craftinginterpreters.com/

    lox language scanner
    http://craftinginterpreters.com/scanning.html

    Implementing the lox language lexer
--]]

local ffi = require("ffi")
local C = ffi.C 
local B = string.byte

local binstream = require("wordplay.binstream")
local enum = require("wordplay.enum")
local cctype = require("wordplay.cctype")
local isDigit = cctype.isdigit
local isAlpha = cctype.isalpha
local isAlphaNumeric = cctype.isalnum


local TokenType = enum {                                   
        -- Single-character tokens.                      
        [0] = "LEFT_PAREN", 
        "RIGHT_PAREN", 
        "LEFT_BRACE", 
        "RIGHT_BRACE",
        "COMMA", 
        "DOT", 
        "MINUS", 
        "PLUS", 
        "SEMICOLON", 
        "SLASH", 
        "STAR", 
      
        -- One or two character tokens.                  
        -- [11]
        "BANG", 
        "BANG_EQUAL",                                
        "EQUAL", 
        "EQUAL_EQUAL",                              
        "GREATER", 
        "GREATER_EQUAL",                          
        "LESS", 
        "LESS_EQUAL",                                
      
        -- Literals.                                     
        -- [19]
        "IDENTIFIER", 
        "STRING", 
        "NUMBER",                      
      
        -- Keywords.                                     
        --  [22]
        "and", 
        "class", 
        "else", 
        "false", 
        "fun", 
        "for", 
        "if", 
        "nil", 
        "or",  
        "print", 
        "return", 
        "super", 
        "this", 
        "true", 
        "var", 
        "while",    
      
        -- [38]
        "EOF"                                              
};




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


local Token_mt = {
    __tostring = function(self)
        return string.format("%d %s %s", self.Kind, self.lexeme, self.literal)
    end;
}
local function Token(obj)
    setmetatable(obj, Token_mt)
    return obj;
end

-- The lexemeMap gives us a table that represents the start of a 
-- lexeme, and what action should be taken to deal with it.
-- each entry is a function that performs the necessary, typically
-- generating a token to be consumed by whomever is scanning.
local lexemeMap = {}

lexemeMap[B'('] = function(bs)
    return (Token{Kind = TokenType.LEFT_PAREN, lexeme='(', literal='', line=bs:getLine()}); 
end

lexemeMap[B')'] = function(bs) 
    return (Token{Kind = TokenType.RIGHT_PAREN, lexeme=')', literal='', line=bs:getLine()}); 
end

lexemeMap[B'{'] = function(bs) 
    return (Token{Kind = TokenType.LEFT_BRACE, lexeme='{', literal='', line=bs:getLine()}); 
end

lexemeMap[B'}'] = function(bs) 
    return (Token{Kind = TokenType.RIGHT_BRACE, lexeme='}', literal='', line=bs:getLine()}); 
end

lexemeMap[B','] = function(bs) 
    return (Token{Kind = TokenType.COMMA, lexeme=',', literal='', line=bs:getLine()}); 
end

lexemeMap[B'.'] = function(bs) 
    return (Token{Kind = TokenType.DOT, lexeme='.', literal='', line=bs:getLine()}); 
end

lexemeMap[B'-'] = function(bs) 
    return (Token{Kind = TokenType.MINUS, lexeme='-', literal='', line=bs:getLine()}); 
end

lexemeMap[B'+'] = function(bs) 
    return (Token{Kind = TokenType.PLUS, lexeme='+', literal='', line=bs:getLine()}); 
end

lexemeMap[B';'] = function(bs) 
    return (Token{Kind = TokenType.SEMICOLON, lexeme=';', literal='', line=bs:getLine()}); 
end

lexemeMap[B'*'] = function(bs) 
    return (Token{Kind = TokenType.STAR, lexeme='*', literal='', line=bs:getLine()}); 
end

lexemeMap[B'!'] = function(bs) 
    if match(bs, B'=') then 
        return (Token{Kind = TokenType.BANG_EQUAL, lexeme='!=', literal='', line=bs:getLine()});
    else
        return (Token{Kind = TokenType.BANG, lexeme='!', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'='] = function(bs) 
    if match(bs, B'=') then 
        return (Token{Kind = TokenType.EQUAL_EQUAL, lexeme='==', literal='', line=bs:getLine()});
    else
        return (Token{Kind = TokenType.EQUAL, lexeme='=', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'<'] = function(bs) 
    if match(bs, B'=') then 
        return (Token{Kind = TokenType.LESS_EQUAL, lexeme='<=', literal='', line=bs:getLine()});
    else
        return (Token{Kind = TokenType.LESS, lexeme='<', literal='', line=bs:getLine()});
    end
end

lexemeMap[B'>'] = function(bs) 
    if match(bs, B'=') then 
        return (Token{Kind = TokenType.GREATER_EQUAL, lexeme='>=', literal='', line=bs:getLine()});
    else
        return (Token{Kind = TokenType.GREATER, lexeme='>', literal='', line=bs:getLine()});
    end
end

-- processing a comment, consume til end of line or EOF
-- totally throw away comment

lexemeMap[B'/'] = function(bs)
    if match(bs, B'/') then 
        while bs:peekOctet() ~= B'\n' and not bs:isEOF() do
            bs:skip(1)
        end
    else
        return (Token{Kind = TokenType.SLASH, lexeme='/', literal='', line=bs:getLine()});
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

    while bs:peekOctet() ~= B'"' and not bs:isEOF() do
        if bs:peekOctet() == B'\n' then
            bs:incrementLineCount();
        end

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
    return (Token{Kind = TokenType.STRING, lexeme='', literal=value, line=bs:getLine()})
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
    return (Token{Kind = TokenType.NUMBER, lexeme='', literal=value, line=bs:getLine()})

end

local function lex_identifier(bs)
    --print("lex_identifier")
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
--print("value: ", value)
    -- See if the identifier is a reserved word
    local kind = TokenType[value]
    if not kind then
        kind = TokenType.IDENTIFIER
    end

    -- return the identifier
    local tok =  Token{Kind = kind, lexeme=value, literal='', line=bs:getLine()}
--print("lex_identifier: ", tok.kind, tok.lexeme, tok.literal, tok.line)
    return tok
end


local function lexemes(str)
    local bs = binstream(str, #str, 0)

    local function iter()

        while not bs:isEOF() do
            local c = bs:readOctet()
            --print(string.char(c))
            if lexemeMap[c] then
                local result, err = lexemeMap[c](bs)
                if result then
                    -- BUGBUG
                    -- when routines only return a token
                    -- uncomment the following
                    coroutine.yield(result)
                else
                    -- deal with error if there was one
                end
            else
                if isDigit(c) then
                    coroutine.yield(lex_number(bs))
                elseif isAlpha(c) then
                    local tok = lex_identifier(bs)
                    --print(tok)
                    coroutine.yield(tok)
                else
                    print("UNKNOWN: ", string.char(c)) 
                end
            end
        end
    end

    return coroutine.wrap(iter)
end

return lexemes

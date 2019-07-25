local enum = require("wordplay.enum")

local TokenType = enum {                                   
    -- Single-character tokens.                      
    [0] = "LEFT_PAREN", -- (
    "RIGHT_PAREN",      -- )
    "LEFT_BRACKET",     -- [
    "RIGHT_BRACKET",    -- ]
    
    [10] =
    "COLON",        -- :
    "COMMA",        -- ,
    "DOT",          -- .
    "MINUS",        -- -
    "PERCENT",      -- %
    "POUND",        -- #
    "PLUS",         -- +
    "SEMICOLON",    -- ;
    "SLASH",        -- /
    "STAR",         -- *
    "QUESTION",     -- ?

    -- One or two character tokens.
    -- [11]
    [30] = 
    "BANG",         --  !
    "BANG_EQUAL",   -- !=                        
    "EQUAL",        -- =
    "EQUAL_EQUAL",  -- ==                        
    "GREATER",      -- >
    "GREATER_EQUAL",-- >=                      
    "LESS",         -- <
    "LESS_EQUAL",   -- <=                         

    -- Literals.                                     
    -- [19]
    [40] =
    "COMMENT",
    "IDENTIFIER", 
    "STRING", 
    "TEXT",
    "SPACE",
    "NUMBER",   
}

local Token_mt = {
    __tostring = function(self)
        return string.format("%s %s %s", TokenType[self.Kind], self.lexeme, self.literal)
    end;
}
local function Token(obj)
    setmetatable(obj, Token_mt)
    return obj;
end

return {
    Token = Token;
    TokenType = TokenType;
}
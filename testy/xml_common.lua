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

-- Internal states that the parser can be in at any given time.
local InternalState = {
    [0] = "START";    -- starting base state; default state
    "TEXT";              -- text state
    "START_TAG";         -- start tag state
    "START_TAGNAME";     -- start tagname state
    "START_TAGNAME_END"; -- start tagname ending state
    "END_TAG";           -- end tag state
    "END_TAGNAME";       -- end tag tagname state
    "END_TAGNAME_END";   -- end tag tagname ending
    "EMPTY_TAG";         -- empty tag state
    "SPACE";             -- linear whitespace state
    "ATTR_NAME";         -- attribute name state
    "ATTR_NAME_END";     -- attribute name ending state
    "ATTR_VAL";          -- attribute value starting state
    "ATTR_VAL2";         -- attribute value state
    "ERROR";              -- error state
}

local EVENTS = {
	EVENT_START     = 0; 	-- Start tag
	EVENT_END       = 1;    -- End tag
	EVENT_TEXT      = 2;    -- Text
	EVENT_ATTR_NAME = 3;    -- Attribute name
	EVENT_ATTR_VAL  = 4;    -- Attribute value
	EVENT_END_DOC   = 5;    -- End of document
	EVENT_MARK      = 6;    -- Internal only; notes position in buffer
	EVENT_NONE      = 7;    -- Internal only; should never see this event
}


return {
    Token = Token;
    TokenType = TokenType;
    STATES = STATES;
}
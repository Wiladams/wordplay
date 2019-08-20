package.path = "../?.lua;"..package.path

local enum = require("wordplay.enum")
local collections = require("wordplay.collections")
local stack = collections.Stack

local JSONScanner = require("json_scanner")
local json_common = require("json_common")
local TokenType = json_common.TokenType

local STATES = enum {
    [1] = 
    "START",
    
    "BEGIN_OBJECT",
    "END_OBJECT",
    "BEGIN_ARRAY",
    "END_ARRAY",

    "MONIKER",
    "VALUE",

    "END",
}


local function command(param)
    setmetatable(param, {
        __tostring = function(self)
            if self.value then
                return string.format("%s  %s", TokenType[self.kind], self.value)
            end
            
            return TokenType[self.kind]
        end
    })

    return param
end



local function command_gen(param, cmdstate)
    local gen_x, param_x = param.gen_x, param.param_x
    local state, state_x, statestack = cmdstate[1], cmdstate[2], cmdstate[3]
    
    -- This is done as a while loop
    -- because we need to build up a command
    -- by consuming a couple of tokens
    while true do
        state_x, value = gen_x(param_x, state_x)
        if state_x == nil then
            -- handle case where we've run out
            -- of tokens
            return nil
        end

        if state == STATES.START then
            -- from the start state, we want to see an element
            --   <ws> value <ws>
            -- since we swallow whitespace, it should simply be
            -- the beginning of a value (object, array, string, number, true, false, null)
            local cmd, newstate
            local next = statestack:top() or STATES.START

            if value.kind == TokenType.LEFT_BRACE then
                newstate, cmd = {STATES.BEGIN_OBJECT, state_x, statestack}, command{kind=STATES.BEGIN_OBJECT}
            elseif value.kind == TokenType.LEFT_BRACKET then
                newstate,cmd = {STATES.BEGIN_ARRAY, state_x, statestack}, command{kind=STATES.BEGIN_ARRAY}
            elseif value.kind == TokenType.STRING then
                newstate,cmd = {next, state_x, statestack}, command{kind=TokenType.STRING}
            elseif value.kind == TokenType.NUMBER then
                newstate,cmd = {next, state_x, statestack}, command{kind=TokenType.NUMBER, value =value.literal}
            elseif value.kind == TokenType["true"] then
                newstate,cmd = {next, state_x, statestack}, command{kind=TokenType["true"], value =value.literal}
            elseif value.kind == TokenType["false"] then
                newstate,cmd =  {next, state_x, statestack}, command{kind=TokenType["false"], value =value.literal}
            elseif value.kind == TokenType["null"] then
                newstate,cmd = {next, state_x, statestack}, command{kind=TokenType["null"], value =value.literal}
            end

            if not cmd then
                -- if there is no command, just continue
                -- onto the next token
                -- this will effectively swallow following ',' tokens
                print("STATES.START, UNEXPECTED TokenType: ", value)
            else
                return newstate, cmd;
            end
        elseif state == STATES.BEGIN_OBJECT then
            --print("BEGIN_OBJECT")
            statestack:push(STATES.BEGIN_OBJECT)
            if value.kind == TokenType.RIGHT_BRACE then
                local next = statestack:pop()
                return {next, state_x, statestack}, command{kind=STATES.END_OBJECT}
            end

            -- expect moniker
            if value.kind == TokenType.MONIKER then
                return {STATES.START, state_x, statestack}, command{kind=TokenType.MONIKER, value = value.literal}
            elseif value.kind == TokenType.COMMA then
                -- swallow comma
            end
        elseif state == STATES.BEGIN_ARRAY then
            statestack:push(STATES.BEGIN_ARRAY)
            -- handle array entries
            if value.kind == TokenType.RIGHT_BRACKET then
                local next = statestack:pop()
                return {next, state_x, statestack}, command{kind=STATES.END_ARRAY}
            end

            -- look for values
            if value.kind == TokenType.LEFT_BRACE then
                return {STATES.BEGIN_OBJECT, state_x}, command{kind=STATES.BEGIN_OBJECT}
            elseif value.kind == TokenType.LEFT_BRACKET then
                return {STATES.BEGIN_ARRAY, state_x}, command{kind=STATES.BEGIN_ARRAY}
            elseif value.kind == TokenType.STRING then
                return {STATES.START, state_x}, command{kind=TokenType.STRING, value =value.literal}
            elseif value.kind == TokenType.NUMBER then
                return {STATES.START, state_x}, command{kind=TokenType.NUMBER, value =value.literal}
            elseif value.kind == TokenType["true"] then
                return {STATES.START, state_x}, command{kind=TokenType["true"], value =value.literal}
            elseif value.kind == TokenType["false"] then
                return {STATES.START, state_x}, command{kind=TokenType["false"], value =value.literal}
            elseif value.kind == TokenType["null"] then
                return {STATES.START, state_x}, command{kind=TokenType["null"], value =value.literal}
            end
        end

        -- if we've gotten here, we'll just return
        -- whatever the scanner did
        return {state, state_x, statestack}, value
    end


    return nil
end

function JSONVM(bs)
    local scanner = JSONScanner:new(bs)

    local gen, param, state = scanner:tokens()

    return command_gen, {gen_x=gen, param_x = param}, {STATES.START, state, stack()}
end

return JSONVM

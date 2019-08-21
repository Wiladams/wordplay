package.path = "../?.lua;"..package.path

local enum = require("wordplay.enum")
local collections = require("wordplay.collections")
local stack = collections.Stack

local JSONScanner = require("json_scanner")
local json_common = require("json_common")
local TokenType = json_common.TokenType

local STATES = enum {
    [0] = 
    "START",
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
            --print("STATE: START - ", value)
            -- from the start state, we want to see an element
            --   <ws> value <ws>
            -- since we swallow whitespace, it should simply be
            -- the beginning of a value (object, array, string, number, true, false, null)
            local cmd, newstate
            local next = statestack:top() or STATES.START

            if value.kind == TokenType.LEFT_BRACE then
                statestack:push(TokenType.BEGIN_OBJECT)
                newstate, cmd = {TokenType.BEGIN_OBJECT, state_x, statestack}, command{kind=TokenType.BEGIN_OBJECT}
            elseif value.kind == TokenType.LEFT_BRACKET then
                statestack:push(TokenType.BEGIN_ARRAY)
                newstate,cmd = {TokenType.BEGIN_ARRAY, state_x, statestack}, command{kind=TokenType.BEGIN_ARRAY}
            end

            if not cmd then
                -- if there is no command, just continue
                -- onto the next token
                -- this will effectively swallow following ',' tokens
                print("STATES.START, UNEXPECTED TokenType: ", value)
            else
                return newstate, cmd;
            end
        elseif state == TokenType.BEGIN_OBJECT then
            --print("STATE: BEGIN_OBJECT")
            if value.kind == TokenType.RIGHT_BRACE then
                statestack:pop()
                local next = statestack:top()
                return {next, state_x, statestack}, command{kind=TokenType.END_OBJECT}
            end

            local nextstate = statestack:top() or TokenType.BEGIN_OBJECT

            if value.kind == TokenType.COMMA then
                --ignore comma, continue processing in same state
            elseif value.kind == TokenType.LEFT_BRACE then
                statestack:push(TokenType.BEGIN_OBJECT)
                return {TokenType.BEGIN_OBJECT, state_x, statestack}, command{kind=TokenType.BEGIN_OBJECT}
            elseif value.kind == TokenType.LEFT_BRACKET then
                statestack:push(TokenType.BEGIN_ARRAY)
                return {TokenType.BEGIN_ARRAY, state_x, statestack}, command{kind=TokenType.BEGIN_ARRAY}
            elseif value.kind == TokenType.MONIKER then
                return {nextstate, state_x, statestack}, command{kind=TokenType.MONIKER, value = value.literal}
            elseif value.kind == TokenType.STRING then
                return {nextstate, state_x, statestack}, command{kind=TokenType.STRING, value = value.literal}
            elseif value.kind == TokenType.NUMBER then
                return {nextstate, state_x, statestack}, command{kind=TokenType.NUMBER, value = value.literal}
            elseif value.kind == TokenType["true"] then
                return {nextstate, state_x, statestack}, command{kind=TokenType["true"], value = value.literal}
            elseif value.kind == TokenType["false"] then
                return {nextstate, state_x, statestack}, command{kind=TokenType["false"], value = value.literal}
            elseif value.kind == TokenType["null"] then
                return {nextstate, state_x, statestack}, command{kind=TokenType["null"], value = value.literal}
            end
        elseif state == TokenType.BEGIN_ARRAY then
            --print("STATE: BEGIN_ARRAY - ", value)
            if value.kind == TokenType.RIGHT_BRACKET then
                -- pop current state off the stack
                statestack:pop()
                -- next state should be whatever is now at the 
                -- top of the stack
                return {statestack:top(), state_x, statestack}, command{kind=TokenType.END_ARRAY}
            end

            local nextstate = statestack:top() or TokenType.BEGIN_ARRAY

            if value.kind == TokenType.COMMA then
                --ignore comma, continue processing in same state
            elseif value.kind == TokenType.LEFT_BRACE then
                statestack:push(TokenType.BEGIN_OBJECT)
                return {TokenType.BEGIN_OBJECT, state_x, statestack}, command{kind=TokenType.BEGIN_OBJECT}
            elseif value.kind == TokenType.LEFT_BRACKET then
                statestack:push(TokenType.BEGIN_ARRAY)
                return {TokenType.BEGIN_ARRAY, state_x, statestack}, command{kind=TokenType.BEGIN_ARRAY}
            elseif value.kind == TokenType.STRING then
                return {nextstate, state_x, statestack}, command{kind=TokenType.STRING, value = value.literal}
            elseif value.kind == TokenType.NUMBER then
                return {nextstate, state_x, statestack}, command{kind=TokenType.NUMBER, value = value.literal}
            elseif value.kind == TokenType["true"] then
                return {nextstate, state_x, statestack}, command{kind=TokenType["true"], value = value.literal}
            elseif value.kind == TokenType["false"] then
                return {nextstate, state_x, statestack}, command{kind=TokenType["false"], value = value.literal}
            elseif value.kind == TokenType["null"] then
                return {nextstate, state_x, statestack}, command{kind=TokenType["null"], value = value.literal}
            end
        end

        -- if we've gotten here, we'll just return
        -- cycle around again, ignoring the token
    end


    return nil
end

function JSONVM(bs)
    local scanner = JSONScanner:new(bs)

    local gen, param, state = scanner:tokens()

    return command_gen, {gen_x=gen, param_x = param}, {STATES.START, state, stack()}
end

return JSONVM

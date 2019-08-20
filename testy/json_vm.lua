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
    "BEGIN_MEMBER",
    "END_MEMBER",

    "MONIKER",
    "VALUE",

    "END",
}


local function command(param)
    setmetatable(param, {
        __tostring = function(self)
            if self.name then
                return string.format("%s  %s", STATES[self.kind], self.name)
            elseif self.value then
                return string.format("%s  %s", STATES[self.kind], self.value)
            end
            return STATES[self.kind]
        end
    })

    return param
end



local function command_gen(param, state)
    local gen_x, param_x = param.gen_x, param.param_x
    local state, state_x, statestack = state[1], state[2], state[3]
    
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
            local cmd 

            if value.kind == TokenType.LEFT_BRACE then
                cmd = {STATES.BEGIN_OBJECT, state_x, statestack}, command{kind=STATES.BEGIN_OBJECT}
            elseif value.kind == TokenType.LEFT_BRACKET then
                cmd = {STATES.BEGIN_ARRAY, state_x, statestack}, command{kind=STATES.BEGIN_ARRAY}
            elseif value.kind == TokenType.STRING then
                cmd = {STATES.START, state_x, statestack}, command{kind=TokenType.STRING}
            elseif value.kind == TokenType.NUMBER then
                cmd = {STATES.START, state_x, statestack}, command{kind=TokenType.NUMBER, value =value.literal}
            elseif value.kind == TokenType["true"] then
                cmd = {STATES.START, state_x, statestack}, command{kind=TokenType["true"], value =value.literal}
            elseif value.kind == TokenType["false"] then
                cmd =  {STATES.START, state_x, statestack}, command{kind=TokenType["false"], value =value.literal}
            elseif value.kind == TokenType["null"] then
                cmd = {STATES.START, state_x, statestack}, command{kind=TokenType["null"], value =value.literal}
            end

            if not cmd then
                -- if there is no command, just continue
                -- onto the next token
                -- this will effectively swallow following ',' tokens
                print("STATES.START, UNEXPECTED TokenType: ", value)
            else
                return cmd;
            end
        elseif state == STATES.BEGIN_OBJECT then
            statestack:push(STATES.BEGIN_OBJECT)
            if value.kind == TokenType.RIGHT_BRACE then
                local next = statestack:pop()
                return {next, state_x, statestack}, command{kind=STATES.END_OBJECT}
            end

            -- expect moniker
            -- expect value
            -- optional ',' separator

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
        elseif state == STATES.BEGIN_MEMBER then
            -- { ws }
            -- { members }
            -- members
            --   member
            --   member ',' members
            -- member
            --   ws string ws ':' element

            if value.kind == TokenType.STRING then
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


            print("STATES.BEGIN_MEMBER, UNEXPECTED TokenType: ", value)
            return nil;

        elseif state == STATES.BEGIN_MEMBER then
            -- fields can be of various types
            -- string, number, null, array, object
            -- there may be a trailing ','
            --print("BEGIN MEMBER: ", value)
            if value.kind == TokenType.STRING then
                -- nextstate = statestack:pop()
                return {STATES.END_MEMBER, state_x}, command{kind=STATES.END_MEMBER, value =value.literal}
            end
        elseif state == STATES.BEGIN_ARRAY then
            if value.kind == TokenType.RIGHT_BRACKET then
                return {STATES.END_ARRAY, state_x}, command{kind=STATES.END_ARRAY}
            end
        end

        -- if we've gotten here, we'll just return
        -- whatever the scanner did
        return {state, state_x}, value
    end


    return nil
end

function JSONVM(bs)
    local scanner = JSONScanner:new(bs)

    local gen, param, state = scanner:tokens()

    return command_gen, {gen_x=gen, param_x = param}, {STATES.START, state, stack()}
end

return JSONVM

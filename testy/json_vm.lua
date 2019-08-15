package.path = "../?.lua;"..package.path

local JSONScanner = require("json_scanner")
local enum = require("wordplay.enum")

local STATES = enum {
    [1] = "START",
    "BEGIN_OBJECT",
    "END_OBJECT",
    "BEGIN_ARRAY",
    "END_ARRAY",
}



-- state transitions
-- need dfa for this
-- iterator returning commands
local function command_gen(param, state)
    local gen_x, param_x = param.gen, param.param
    local state, state_x = state[1], state[2]
    state_x, value = gen_x(param_x, state_x)
    if state_x == nil then
        -- handle case where we've run out
        -- of tokens
        return nil
    end

    return {state, state_x}, value
end

function JSONVM(bs)
    local scanner = JSONScanner:new(bs)



    local gen, param, state = scanner:tokens()

    return command_gen, {gen_x=gen, param_x = param}, {STATES.START, state}
end


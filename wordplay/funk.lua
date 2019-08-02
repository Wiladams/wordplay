--[[
    A recreation of functional programming routines
    
    https://luafun.github.io/

    Why recreate?  To play with various things without disturbing
    the original.

    Do not want any usage of 'assert' or 'error', use return values
    Do not compare to 0, compare < 1
]]


local floor, ceil, pow = math.floor, math.ceil, math.pow
local unpack = rawget(table, "unpack") or unpack

local exports = {}
local methods = {}

exports.operator = {}
exports.op = exports.operator

--[[
    Comparison Operators
--]]
function exports.operator.le(a,b) return a <= b end
function exports.operator.lt(a,b) return a < b end
function exports.operator.eq(a,b) return a == b end
function exports.operator.ne(a,b) return a ~= b end
function exports.operator.ge(a,b) return a >= b end
function exports.operator.gt(a,b) return a > b end

--[[
    Arithmetic Operators
--]]
function exports.operator.add(a,b) return a + b end
function exports.operator.truediv(a,b) return a / b end
exports.operator.div = exports.operator.truediv
function exports.operator.floordiv(a,b) return floor(a/b) end
function exports.operator.intdiv(a,b)
    local q = a/b
    if a >=0 then
        return floor(q)
    else
        return ceil(q)
    end
end
function exports.operator.mod(a,b) return a % b end
function exports.operator.neg(a) return -a end
exports.operator.unm = exports.operator.neg
function exports.operator.pow(a,b) return math.pow(a,b) end
function exports.operator.sub(a,b) return a - b end


--[[
    String Operators
]]
function exports.operator.concat(a,b) return a..b end
function exports.operator.length(a) return #a end
exports.operator.len = exports.operator.length



--[[
    Logical Operators
]]
function exports.operator.land(a,b) return a and b end
function exports.operator.lor(a,b) return a or b end
function exports.operator.lnot(a) return not a end
function exports.operator.truth(a) return not not a end

--[[
    Utility Functions
]]
local function callIfNotEmpty(fn, state, ...)
    if state == nil then
        return nil;
    end

    return state, fn(...)
end

local function returnIfNotEmpty(state, ...)
    if state == nil then
        return nil
    end
    return ...
end



--[[
    The iterator_mt, combined with the wrap()
    function, form a functor, which can then 
    be fed to other functions that take a single
    parameter.

    local itar = wrap(gen, param, state)
    repeat
        state, val = itar()
        doSomethingWith(val)
    until state == nil

    particularly good for making a sequence of iterators
]]
local iterator_mt = {
    __call = function(self, param, state)
        return self.gen(param, state)
    end;

    __tostring = function(self)
        return '<generator>'
    end;

    __index = methods;
}

local function wrap(gen, param, state)

    return setmetatable({
        gen = gen,
        param = param,
        state = state
    }, iterator_mt), param, state
end
exports.wrap = wrap

local function unwrap(obj)
    return self.gen, self.param, self.state
end
methods.unwrap = unwrap

--[[
    Basic generators
]]
--[[
    nil_gen()
    a generator that only returns nil.  
    With iterators you can't return a 'nil' for the 
    generator, so we return this generator when we mean 
    to return a nil value, and it will just return nil as
    its first value, which will essentially terminate the
    iteration.
--]]
local function nil_gen(param, state)
    return nil;
end

--[[
    range_gen()

    generate a range of numbers

    param[1] - stop
    param[2] - step

--]]

local function range_gen(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state > stop then
        return nil
    end

    return state, state
end

-- same as range_gen, but going negative
local function range_rev_gen(param, state)
    local stop, step = param[1], param[2]
    local state = state + step

    if state < stop then
        return nil;
    end

    return state, state
end

--[[
    generate characters from a lua string one at a 
    time.
]]
local function string_gen(param, state)
    -- if we're at the end of the string, return nil
    if state > #param then
        return nil;
    end

    return state + 1, string.sub(param, state, state)
end

-- simple hack to get the ipairs generator function
local ipairs_gen = ipairs({})

-- simple hack to get the pairs generator function
local pairs_gen = pairs({a=0})
local dict_gen = function(tab, key)
    local key, value = pairs_gen(tab, key)
    return key, key, value
end



--[[
    Basic Functions
]]

local function rawiter(obj, param, state)
    if type(obj) == "string" then
        if #obj < 1 then
            return nil_gen, nil, nil
        end

        return string_gen, obj, 0
    elseif type(obj) == "function" then
        return obj, param, state
    elseif type(obj) == "table" then
        local mt = getmetatable(obj)
        if mt ~= nil then
            if mt == iterator_mt then
                return obj.gen, obj.param, obj.state
            elseif mt.__ipairs ~= nil then
                return mt.__ipairs(obj)
            elseif mt.__pairs ~= nil then
                return mt.__pairs(obj)
            end
        end

        if #obj > 0 then
            -- array iteration
            return ipairs(obj)   -- ipairs_gen, obj, 0
        else
            -- pairs iteration
            return dict_gen, obj, nil    -- pairs(obj)
        end
    end

    print("NOT ITERABLE: ", type(obj))
end

local function iter(obj, param, state)
    return wrap(rawiter(obj, param, state))
end
exports.iter = iter

local function method0(fn)
    return function(self)
        return fn(self.gen, self.param, self.state)
    end
end

local function method1(fn)
    return function(self, arg1)
        return fn(arg1, self.gen, self.param, self.state)
    end
end

local function method2(fn)
    return function(self, arg1, arg2)
        return fn(arg1, arg2, self.gen, self.param, self.state)
    end
end


local function export0(fn)
    return function(gen, param, state)
        return fn(rawiter(gen, param, state))
    end
end

local function export1(fn)
    return function(arg1, gen, param, state)
        return fn(arg1, rawiter(gen,param,state))
    end
end

local function export2(fn)
    return function(arg1, arg2, gen, param, state)
        return fn(arg1, arg2, rawiter(gen, param,state))
    end
end

local function each(fn, gen, param, state)
    repeat
        state = callIfNotEmpty(fn, gen(param, state))
    until state == nil
end
methods.each = method1(each)
exports.each = export1(each)


--[[
    Indexing
]]
local function index(x, gen, param, state)
    local i = 1

    for _k, r in gen, param, state do
        if r == x then
            return i 
        end
        i = i + 1;
    end
    return nil;
end

exports.index = export1(index)
methods.index = method1(index)


local function indices_gen(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    local r

    while true do
        state_x, r = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
        i = i + 1
        if r == x then
            return {i, state_x}, i
        end
    end
end

local function indexes(x, gen, param, state)
    return wrap(indices_gen, {x, gen, param}, {0,state})
end

exports.indexes = export1(indexes)
methods.indexes = method1(indexes)

--[[
    Filtering
]]
local function filter1_gen(fn, gen_x, param_x, state_x, a)
    while true do
        if state_x == nil or fn(a) then
            break;
        end
        state_x, a = gen_x(param_x, state_x)
    end
    return state_x, a
end

-- forward declaration
local filterm_gen
local function filterm_gen_shrink(fn, gen_x, param_x, state_x)
    return filterm_gen(fn, gen_x, param_x, gen_x(param_x, state_x))
end

filterm_gen = function(fn, gen_x, param_x, state_x, ...)
    if state_x == nil then
        return nil
    end
    if fn(...) then
        return state_x, ...
    end

    return filterm_gen_shrink(fn, gen_x, param_x, state_x)
end

local function filter_detect(fn, gen_x, param_x, state_x, ...)
    if select('#', ...) < 2 then
        return filter1_gen(fn, gen_x, param_x, state_x, ...)
    else
        return filterm_gen(fn, gen_x, param_x, state_x, ...)
    end
end

local function filter_gen(param, state_x)
    local fn, gen_x, param_x = param[1], param[2], param[3]
    return filter_detect(fn, gen_x, param_x, gen_x(param_x, state_x))
end

local function filter(fn, gen, param, state)
    return wrap(filter_gen, {fn, gen, param}, state)
end

exports.filter = export1(filter)
methods.filter = method1(filter)

local function grep(fun_or_regexp, gen, param, state)
    local fn = fun_or_regexp
    if type(fun_or_regexp) == "string" then
        fn = function(x) 
            return string.find(x, fun_or_regexp) ~= nil
        end
    end
    return filter(fn, gen, param, state)
end
exports.grep = export1(grep)
methods.grep = method1(grep)

local function partition(fn, gen, param, state)
    local neg_fun = function(...)
        return not fun(...)
    end

    return filter(fn, gen, param, state),
        filter(neg_fun, gen, param, state)
end

exports.partition = export1(partition)
methods.partition = method1(partition)


--[[
    Iterators
]]
local function range(start, stop, step)
    if step == nil then
        if stop == nil then
            if start == 0 then
                -- this would be an invalid range
                return nil_gen,nil, nil
            end
            stop = start
            start = stop > 0 and 1 or -1
        end
        step = start <= stop and 1 or -1
    end

    if step > 0 then
        return wrap(range_gen, {stop, step}, start - step)
    elseif step < 0 then
        return wrap(range_rev_gen, {stop, step}, start - step)
    end
end

exports.range = range

local function duplicate_table_gen(param_x, state_x)
    return state_x+1, unpack(param_x)
end

local function duplicate_fun_gen(param_x, state_x)
    return state_x+1, param_x(state_x)
end

local function duplicate_gen(param_x, state_x)
    return state_x+1, param_x
end

local function duplicate(...)
    if select('#',...) <=1 then
        return wrap(duplicate_gen, select(1,...), 0)
    else
        return wrap(duplicate_table_gen, {...}, 0)
    end
end
exports.duplicate = duplicate

local function tabulate(fn)
    return wrap(duplicate_fun_gen, fn, 0)
end
exports.tabulate = tabulate

local function zeroes()
    return wrap(duplicate_gen, 0, 0)
end
exports.zeroes = zeroes

local function ones()
    return wrap(duplicate_gen, 1, 0)
end
exports.ones = ones


--[[
    Slicing
]]
local function take_n_gen_x(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i, state_x}, ...
end

local function take_n_gen(param, state)
    local n, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i >= n then
        return nil
    end
    
    return take_n_gen_x(i+1, gen_x(param_x, state_x))
end

local function take_n(n, gen, param, state)
    --assert(n >= 0)
    return wrap(take_n_gen, {n, gen, param}, {0,state})
end

exports.take_n = export1(take_n)
methods.take_n = method1(take_n)

local function take(n_or_fun, gen, param, state)
    if type(n_or_fun) == "number" then
        return take_n(n_or_fun, gen, param, state)
    else
        return take_while(n_or_fun, gen, param, state)
    end
end

exports.take = export1(take)
methods.take = method1(take)

setmetatable(exports, {
    __call = function(self, tbl)
        tbl = tbl or _G

        for k,v in pairs(exports) do
            rawset(tbl, k, v)
        end

        return self
    end;
})
return exports

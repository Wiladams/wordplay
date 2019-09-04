local bit = require("bit")
local band, bor = bit.band, bit.bor
local DEGREES, RADIANS = math.deg, math.rad
local exports = {}
exports.MARK = "MARK"

--[[
-- Stack operators
--]]
local function dup(stk)
    stk:push(stk:top())
    return true
end
exports.dup = dup

local function exch(stk)
    local a = stk:pop()
    local b = stk:pop()
    stk:push(a)
    stk:push(b)
    return true
end
exports.exch = exch

local function pop(stk)
    stk:pop()
    return true
end
exports.pop = pop


local function copy(stk, n)
    -- create temporary stack
    local tmp = stack()

    -- get the n items into temp stack
    for i=0,n-1 do 
        tmp:push(stk:nth(i))
    end

    -- push from temp stack back onto stk
    for i=0,n-1 do 
        stk:push(tmp:pop())
    end

    return true
end
exports.copy = copy

local function roll(stk)
end

local function index(stk)
    local n = stk:pop();
    return stk:nth(n)
end


local function mark(stk)
    stk:push(exports.MARK)
    return true;
end
exports.mark = mark

local function clear(stk)
    stk:clear()
    return true;
end
exports.clear = clear

local function count(stk)
    stk:push(stk:len())
    return true
end
exports.count = count

--counttomark
local function cleartomark(stk)
    while stk:len() > 0 do 
        local item = stk:pop()
        if item == exports.MARK then
            break
        end
    end

    return true
end
exports.cleartomark = cleartomark

--[[
-- Arithmetic and Mathematical Operators
-- two arguments, result on stack
--]]
local function add(stk)
    stk:push(stk:pop()+stk:pop())
    return true
end
exports.add = add

local function sub(stk)
    local num2 = stk:pop()
    local num1 = stk:pop()
    stk:push(num1-num2)
    
    return true
end
exports.sub = sub

local function mul(stk)
    stk:push(stk:pop()*stk:pop())
end
exports.mul = mul

local function div(stk)
    local num2 = stk:pop()
    local num1 = stk:pop()
    stk:push(num1/num2)
    
    return true
end
exports.div = div

local function idiv(stk)
    local num2 = stk:pop()
    local num1 = stk:pop()
    stk:push(floor(num1/num2))
    
    return true
end
exports.idiv = idiv

local function mod(stk)
end
exports.mod = mod

--[[
-- one argument
--]]
local function abs(stk)
    stk:push(math.abs(stk:pop()))
    return true
end

local function neg(stk)
    stk:push(-(stk:pop()))
    return true
end

local function ceiling(stk)
    stk:push(math.ceil(stk:pop()))
    return true
end

local function floor(stk)
    stk:push(math.floor(stk:pop()))
    return true
end

local function round(stk)
    local n = stk:pop()
    if n >= 0 then
        stk:push(math.floor(n+0.5))
    else
        stk:push(math.ceil(n-0.5))
    end
end

--truncate

local function sqrt(stk)
    stk:push(math.floor(stk:pop()))
    return true
end

local function exp(stk)
    stk:push(math.floor(stk:pop()))
    return true
end

local function ln(stk)
    stk:push(math.floor(stk:pop()))
    return true
end

local function log(stk)
    stk:push(math.log(stk:pop()))
    return true
end

local function sin(stk)
    stk:push(math.sin(RADIANS(stk:pop())))
    return true
end

local function cos(stk)
    stk:push(math.cos(RADIANS(stk:pop())))
    return true
end

local function atan(stk)
    local den = stk:pop()
    local num = stk:pop()
    stk:push(DEGREES(math.atan(num/den)))

    return true
end

-- put random integer on the stack
local function rand(stk)
    stk:push(math.random())
    return true
end

local function srand(stk)
    local seed = stk:pop()
    --math.randomseed(seed)

    return true
end

-- put random number seed on stack
local function rrand(stk)
    local seed = math.randomseed()
    stk:push(seed)

    return true
end


--[[
-- Array, Packed Array, Dictionary, and String Operators
get
put
copy
length
forall
getinterval
putinterval
--]]

-- creation of composite objects
local function array(stk)
    stk:push({})
    return true
end

local function packedarray(stk)
end

local function dict(stk)
    local capacity = stk:pop()
    stk:push({})
    return self
end
exports.dict = dict

local function string(stk)
end
exports.string = string

--[[
-- apply to arrays
aload
astore

setpacking
currentpacking

-- dictionaries
begin
end
def
store
load
where
countdictstack
cleardictstack
dictstack
known
maxlength
undef
-- <<key1,value1, key2,value2...>>
]]

--[[
-- String Operators
--]]
local function eq(stk)
    stk:push(stk:pop() == stk:pop())
    return true
end

local function ne(stk)
    stk:push(stk:pop() ~= stk:pop())
    return true
end

local function gt(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()
    stk:push(any1 > any2)

    return true
end

local function ge(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()
    stk:push(any1 >= any2)

    return true
end

local function lt(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()
    stk:push(any1 < any2)

    return true
end

local function le(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()
    stk:push(any1 <= any2)

    return true
end

--[[
-- for both boolean and bitwise
--]]

exports["and"] = function(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()

    if type(any1 == "boolean") then
        stk:push(any1 and any2)
    else
        stk:push(band(any1, any2))
    end
    return true
end

exports["or"] = function(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()

    if type(any1 == "boolean") then
        stk:push(any1 or any2)
    else
        stk:push(bor(any1, any2))
    end
    return true
end

local function xor(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()

    if type(any1 == "boolean") then
        stk:push(any1 and any2)
    else
        stk:push(band(any1, any2))
    end
    return true
end

exports["true"] = function(stk)
    stk:push(true)
    return true
end

exports["false"] = function(stk)
    stk:push(false)
    return true
end

exports["not"] = function(stk)
    local any2 = stk:pop()
    local any1 = stk:pop()

    if type(any1 == "boolean") then
        stk:push(any1 and any2)
    else
        stk:push(band(any1, any2))
    end
    return true
end

local function bitshift(stk)
    local shift = stk:pop()
    local int1 = stk:pop()

    if shift < 0 then
        stk:push(rshift(int1,math.abs(shift)))
    else
        stk:push(lshift(int1,shift))
    end

    return true
end


--[[
-- Control Operators
if
ifelse
exec
for
repeat
loop
forall
exit
countexecstack
execstack
stop
]]

--[[
-- Type, Attribute and Conversion Operators
type
xcheck
rcheck
wcheck
cvlit
cvx
readonly
executeonly
noaccess
--]]

local function cvi(stk)
    stk:push(tonumber(stk:pop()))
    return true
end

local function cvr(stk)
    stk:push(tonumber(stk:pop()))
    return true
end

local function cvn(stk)
end

local function cvs(stk)
    stk:push(tostring(stk:pop()))
    return true 
end

local function cvrs(stk)
end



return exports
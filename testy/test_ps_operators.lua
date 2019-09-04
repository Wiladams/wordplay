package.path = "../?.lua;"..package.path

local OperatorStack = require("ps_OperatorStack")
local ops = require("ps_operators")
local add = ops.add
local sub = ops.sub
local mul = ops.mul
local div = ops.div

local stk = OperatorStack()

stk:push(10)
stk:push(20)
add(stk)
print("add: ", stk:top())
stk:push(1)
stk:push(3)
ops.mark(stk)
stk:push(5)
stk:push(7)

print("Stack length: ", stk:len())
print("clear stack")
ops.cleartomark(stk)
print("Stack length: ", stk:len())

--stk:push(3)
--print(stk:pop())
--print(stk:pop())
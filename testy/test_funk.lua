package.path = "../?.lua;"..package.path

local funk = require("wordplay.funk")()
--[[
print("STRING")
for _it, c in iter("Hello Funk.") do
    print(c)
end

print("ARRAY")
for _it, c in iter({1,2,3,4}) do
    print(c)
end

print("PAIRS")
for _it, k,v in iter({a=1, b=2, c=3}) do
    print(k,v)
end

print("EACH")
each(print, iter({'each', 'of','these','will','print'}))
--print(iter({'each', 'of','these','will','print'}))
--for _, it in iter({'each', 'of','these','will','print'}) do
--    print(it)
--end

print("RANGE")
each(print, range(1,10))

print("INDEX")
print(index(2, range(0)))
print(index("b", {"a", "b", "c", "d", "e"}))

print("INDEXES (1,6,8,9")
each(print, indexes("a", {"a", "b", "c", "d", "e", "a", "b", "a", "a"}))

print("TAKE_N (5)")
each(print, take_n(5, range(10)))
--each(print, take_n(5, enumerate(duplicate('x'))))


print("DUPLICATE")
print("each(print, take(3, duplicate('a', 'b', 'c')))")
each(print, take(3, duplicate('a', 'b', 'c')))
print("each(print, take(3, duplicate('x')))")
each(print, take(3, duplicate('x')))
for _it, a, b, c, d, e in take(3, duplicate(1, 2, 'a', 3, 'b')) do
    print(a, b, c, d, e)
end

print("TABULATE")
each(print, take(5, tabulate(function(x)  return 'a', 'b', 2*x end)))
each(print, take(5, tabulate(function(x) return x^2 end)))


print("FILTERING")
each(print, filter(function(x) return x % 3 == 0 end, range(10)))
each(print, take(5, filter(function(i, x) return i % 3 == 0 end, enumerate(duplicate('x')))))

print("REDUCING/FOLDING")
print('print(length({"a", "b", "c", "d", "e"}))')
print(length({"a", "b", "c", "d", "e"}))
print('print(length({}))')
print(length({}))
print('print(length(range(0)))')
print(length(range(0)))
print('print(length(range(10,100)))')
print(length(range(10,100)))

-- all
print('print(all(function(x) return x end, {true, true, true, true}))')
print(all(function(x) return x end, {true, true, true, true}))
print('print(all(function(x) return x end, {true, true, true, false}))')
print(all(function(x) return x end, {true, true, true, false}))
-- any
print('print(any(function(x) return x end, {false, false, false, false}))')
print(any(function(x) return x end, {false, false, false, false}))
print('print(any(function(x) return x end, {false, false, false, true}))')
print(any(function(x) return x end, {false, false, false, true}))

-- minimum
print('print(minimum(range(1, 10, 1)))')
print(minimum(range(1, 10, 1)))
print('print(minimum({"f", "d", "c", "d", "e"}))')
print(minimum({"f", "d", "c", "d", "e"}))
print('print(min({}))')
print(minimum({}))

-- maximum
print('print(max(range(1, 10, 1)))')
print(maximum(range(1, 10, 1)))
print('print(maximum({"f", "d", "c", "d", "e"}))')
print(maximum({"f", "d", "c", "d", "e"}))
print('print(maximum({}))')
print(maximum({}))
--]]
-- totable
print("totable()")
local tab = totable("abcdef")
print(type(tab), #tab)
each(print, tab)

--[[
print("TRANSFORMATIONS")
print('each(print, map(function(x) return 2 * x end, range(4)))')
each(print, map(function(x) return 2 * x end, range(4)))
local fn = function(...) return 'map', ... end
each(print, map(fn, range(4)))
print("INTERSPERSE")
--each(print, intersperse("x", {"a", "b", "c", "d", "e"}))
--]]

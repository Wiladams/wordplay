-- Just messing around, nothing of interest in here
local ffi = require("ffi")
local primes = require("primes")

local exports = {}

function exports.encode(word, len)
    len = len or #word
    local str = ffi.cast("uint8_t *", word)
    local hash = 1;

    for i=0,len-1 do
        hash = hash * (primes[i+1] * str[i])
        --print("hashing: ", i, str[i], primes[i+1], string.format("%x",hash))
    end

    return hash
end

local function factor(num, prime)
    for i = 1,100 do
        print(num, num % prime)
        num = num - prime
    end
end

function exports.decode(hash)
    local hashval = hash
    local offset = 0;

    factor(hash, primes[1])
    --print(primes[1], hashval / primes[1], hashval % primes[1])
    --print(primes[2], hashval / primes[2])
    --print(primes[3], hashval / primes[3])
    --print(primes[4], hashval / primes[4])
    
--[[
    while hashval > 0 do
        local c = hashval/primes[offset+1]
        --hashval = hashval - c
        print(c, hashval)
        --print(string.char(c))
    end
--]]
end

return exports

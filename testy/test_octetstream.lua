package.path = "../?.lua;"..package.path

local octetstream = require("wordplay.octetstream")

local os = octetstream("Hello Stream!!")

for _, c in os:enumOctets() do
    print(c, string.char(c))
end

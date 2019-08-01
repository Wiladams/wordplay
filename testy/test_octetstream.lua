package.path = "../?.lua;"..package.path

local octetstream = require("wordplay.octetstream")

local ocs = octetstream("Hello Stream!!")
print("ocs:octets(): ", ocs:octets())

print("DEFAULT")
for _, c in ocs:octets() do
    print(c, string.char(c))
end

print("OFFSET 6")
for _, c in ocs:octets(6) do
    print(c, string.char(c))
end

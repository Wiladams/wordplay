print("NEXT: ", next)

-- test array initialization
local n = 10
local param = {[2*n]=0}
local state = {[n]=0}

print("param: ", param[2*n])
print("state: ", state[n])
local primehash = require("primehash")

print("hello: ", primehash.encode("hello"))
print(" 3028: ", primehash.decode(primehash.encode("hello")))

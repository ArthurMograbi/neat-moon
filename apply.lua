m2 = require("MOD2")

l=m2.gen(40)
m2.mutSpec(l)
local lC={}
---
m2.evalPopGain(l)--{{[-2]=2,[-1]=1},{[-2]=1,[-1]=2}},{{[-99]=1.2},{[-99]=0.9}}
lC[#lC+1]=l[1].gain

m2.deep_print(l)
m2.deep_print(lC)
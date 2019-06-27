local m1 = require "MOD1"
local m2 = require "MOD2"


local l = {}
l=m2.gen(40)
m2.mutSpec(l)
local lC={}
---
m2.evalPop(l,{{[-2]=2,[-1]=1},{[-2]=1,[-1]=2}},{{[-99]=1.2},{[-99]=0.9}})--{{[-2]=2,[-1]=1},{[-2]=1,[-1]=2}},{{[-99]=1.2},{[-99]=0.9}}
lC[#lC+1]=l[1].loss
--m2.deep_print(l)
print("\n")
l=m2.nxtGen(l,0.1,40)
m2.evalPop(l,{{[-2]=2,[-1]=1},{[-2]=1,[-1]=2}},{{[-99]=1.2},{[-99]=0.9}})
--m2.selSpec(l,0.1)
--m2.deep_print(l)
lC[#lC+1]=l[1].loss

for i = 1, 20 do
  l=m2.nxtGen(l,0.1,40)
  m2.evalPop(l,{{[-2]=2,[-1]=1},{[-2]=1,[-1]=2}},{{[-99]=1.2},{[-99]=0.9}})
  lC[#lC+1]=l[1].loss
end
m2.selSpec(l,0.1)
print("\n\nBLEH")
m2.deep_print(l)
m2.deep_print(m1.exisCon)
print("\n")
m2.deep_print(lC)
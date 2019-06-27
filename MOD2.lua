local m1 = require "MOD1"
local apply = require "noLove"
local M={}
--M.popu={{}}

function M.deep_print(t)
  io.write(" {")
  for i,j in pairs(t) do
    if not(type(i)== "number") then io.write(i,":") end
    if type(j)=="table" then M.deep_print(j) else io.write(j,",") end
  end
  io.write("} ")
end
---
function M.checkErrors(pop,msg,loss)
  loss = loss or 1
  for i =1,#pop do
    for j =1,#pop do
      if i ~=j then assert(pop[i].id~=pop[j].id,"Clones: "..msg) end
    end
    if loss==1 then assert(pop[i].loss,"Loss: "..msg) end
  end
end
--
--[[
function M.genPop(size,neu,cons)
  cons= cons or {}
  local out={}
  for i =1, size do out[i] = m1.create(neu,cons,1)  end
  --for i =1, size do M.popu[1][i] = {['nG']=neu,['cG']=cons,['ecG']={}} print(M.popu[1][i]) end
  return out
end
---
function M.mutPop(pop,ws,rw,c,n)
  math.randomseed(os.time())
  ws=ws or 10
  rw = rw or 4
  c = c or 20--2
  n = n or 1
  for i= 1, #pop do
    local dice = math.random(0,100)
    local transfer = pop[i]
    if dice <c then m1.conMut(transfer,i*os.time()) print("Mut", i*os.time()) end -- <------ AQUI 
  end
end]]
---
function M.evalPop(pop,inData,exData)
  for i,j in pairs(pop) do
    local l =m1.globLoss(j, inData,exData) ---HERE
    pop[i].loss=l
  end
  table.sort(pop,function (a,b) return math.abs(a.loss)<math.abs(b.loss) end)
  M.checkErrors(pop,"evalPop")
end
--
function M.evalPopGain(pop)
  for i,j in pairs(pop) do
    local l =apply.run(j) ---HERE
    pop[i].gain=l
  end
  table.sort(pop,function (a,b) return math.abs(a.gain)>math.abs(b.gain) end)
 --M.checkErrors(pop,"evalPop")
end
---
function M.gen(num)
  local out ={}
  for i = 1, num do
    out[i]=m1.create({-1,-99},{})
  end
  M.checkErrors(out,"gen",0)
  return out
end
---
function M.mutSpec(spec)
  for i = 1, #spec do
    m1.conMut(spec[i],math.random())
  end
  M.checkErrors(spec,"mutSpec",0)
end
--
function M.selSpec(spec,survR)
  local nSurv = math.ceil(#spec*survR)
  local out= {}
  for i =1, #spec do
    if i <= nSurv then
      --spec[i] = spec[i]
    else
      spec[i]= nil
    end
  end
  M.checkErrors(spec,"selSpec")
end
----
function M.nxtGen(spec,survR,size)
  size = size or #spec
  local out ={}
  out[1],out[2]=spec[1],spec[2]
  M.selSpec(spec,survR)
  while #out <= size do
    for _,i in pairs(spec) do
      for _, j in pairs(spec) do
        if i.id ~= j.id then
          out[#out+1]=m1.breed(i,j)
        end
      end
      if #out == size then print(#out) break end
    end
  end
  print("OUT:",#out, "\n")
  M.deep_print(out)
  M.checkErrors(out,"nxtGen",0)
  return out
end
--local l =M.genPop(10,{-1,-2,-99})
--M.mutPop(l)
--M.popu[1][1].cG={{-1,-99,2,1}}
--M.evalPop({{[-1]=1,[-2]=2},{[-1]=2,[-2]=1}},{{[-99]=3},{[-99]=5}})

--M.deep_print(l)

return M
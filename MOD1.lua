local M={}

math.randomseed(os.time())
M.exisCon={} -- Iindex is "InNeuron-OutNeuron" Value is Inno
M.exisN={}
---
M.idNum=0
---
function M.trueLen(t)
  local out =0
  for _,_ in pairs(t) do
    out = out+1
  end
  return out
end
---
---
function M.create(nG,cG,spec) 
  cG=cG or {}
  spec=spec or 1
  --[[ local nwrk = {}
   nwrk.nG = nG      --- GENES DOS NEURONIOS
   nwrk.cG = cG     --- GENES DAS CONEXÕES
   nwrk.spec = spec --- GENES IDENTIFICADOR DA SPECIE
   nwrk.ecG={}
   return nwrk]]
   M.idNum=M.idNum+1
   return {['nG']=nG,['cG']=cG,['ecG']={},['id']=M.idNum}
end
----
function M.printG(genes,form)   -- imprime genes
  for a,i in pairs(genes.nG) do
    io.write(i, ", ")
  end
  print("")
  for a,i in pairs(genes.cG) do
    io.write(a,"{")
    if type(i) == 'table' then
      for a, j in pairs(i) do
        io.write(j, ", ")
      end
    else io.write(i) end
    io.write("}")
  end
  print("")
  print(genes.spec)
end
----
function M.conMut(genes, seed, maxrecursion)   --- GERADOR DE MUTAÇÃO DE CONEXÕES
  --seed=seed or os.time()
  --math.randomseed(seed)
  maxrecursion= maxrecursion or 20
  if maxrecursion == 0 then return nil end
  local s,e= genes.nG[math.random(#genes.nG)],genes.nG[math.random(#genes.nG)]
  while s<-50 do
    s= genes.nG[math.random(#genes.nG)]
  end
  while (s>0 and e>-50) or (s < 0 and (e>-50 and e<0)) do
    e= genes.nG[math.random(#genes.nG)]
  end
  local exisConInd= tostring(s).."-"..tostring(e)
  if not(genes.ecG[exisConInd]) then
    --print("IND: ",exisConInd,genes.ecG[exisConInd])
    if M.exisCon[exisConInd] then
      print("Existing",genes,s,e,math.random(100)/100)
      genes.ecG[exisConInd]=M.exisCon[exisConInd]
      genes['cG'][#genes.cG+1]={s,e, math.random(100)/100,M.exisCon[exisConInd]}
    else
      print("Not Existing",genes,s,e,math.random(100)/100)
      M.exisCon[exisConInd]=M.trueLen(M.exisCon)+1
      genes.ecG[exisConInd]=M.trueLen(M.exisCon)
      genes['cG'][#genes.cG+1]={s,e, math.random(100)/100,M.trueLen(M.exisCon)}
    end
  else
    --print("recursing...")
    M.conMut(genes,seed,maxrecursion-1)
  end
end
-----
-----
function M.swMut(genes,factor)  --- GERADOR DE MUTAÇÃO DE PESOS SHIFT
  if M.trueLen(genes.cG)~=0 then
    local ri = math.random(1,#genes.cG)
    genes.cG[ri][3]=genes.cG[ri][3]*(1+math.random(-factor,factor))
  end
end
function M.rwMut(genes,factor)  --- GERADOR DE MUTAÇÃO DE PESOS
  if M.trueLen(genes.cG)~=0 then
    local ri = math.random(1,#genes.cG)
    genes.cG[ri][3]=(math.random(-factor,factor))
  end
end
-----
function M.nMut(genes)
  --print(genes.nG)
  if M.trueLen(genes.cG)~=0 then
    local ri = math.random(1,#genes.cG)
    local inNeu,outNeu,newNeu = genes.cG[ri][1],genes.cG[ri][2],#genes.nG+1
    genes.nG[#genes.nG+1]=newNeu
    genes.cG[ri]=nil
    --print(inNeu,outNeu,newNeu)
    local exisConInd=tostring(inNeu).."-"..tostring(newNeu)
    --print(exisConInd)
    if M.exisCon[exisConInd] then
      genes.ecG[exisConInd]=M.exisCon[exisConInd]
      genes.cG[#genes.cG+1]={inNeu,newNeu,math.random(-100,100)/100,M.exisCon[exisConInd]}
    else
      M.exisCon[exisConInd]=M.trueLen(M.exisCon)+1
      genes.ecG[exisConInd]=M.trueLen(M.exisCon)
      genes.cG[#genes.cG+1]={inNeu,newNeu,math.random(-100,100)/100,M.trueLen(M.exisCon)}
    end
    --
    exisConInd=tostring(newNeu).."-"..tostring(outNeu)
    --print(exisConInd)
    if M.exisCon[exisConInd] then
      genes.ecG[exisConInd]=M.exisCon[exisConInd]
      genes.cG[#genes.cG+1]={newNeu,outNeu,math.random(-100,100)/100,M.exisCon[exisConInd]}
    else
      M.exisCon[exisConInd]=M.trueLen(M.exisCon)+1
      genes.ecG[exisConInd]=M.trueLen(M.exisCon)
      genes.cG[#genes.cG+1]={newNeu,outNeu,math.random(-100,100)/100,M.trueLen(M.exisCon)}
    end
  end
end
---
function M.neuVal(genes,neu, inV)    -- inputs delivered {-1=2,-2=10}
  local out = 0
  if neu <0 and neu>-50 then return inV[neu] end
  for _,i in pairs(genes.cG) do
    --assert(inV[-1])
    if i[2] == neu then out = out + M.neuVal(genes, i[1],inV)*i[3] end
  end
  return out
end
---
function M.evalNet(genes, inV)
  local out ={}
  for _,i in pairs(genes.nG) do
    if i < -50 then out[i]=M.neuVal(genes,i,inV) end
  end
  return out
end
--
function M.loss(genes, inV, exV)
  local out = 0
  local results = M.evalNet(genes,inV)
  for i,j in pairs(results) do
    --print(i,j,exV)
    local diff = j - exV[i]
    out = out + diff*diff ---------------------------------------------------JUST SQUARED
  end
  return out
end
--
function M.globLoss(genes, inData, exData)
  local sum = 0
  for i,j in pairs(inData) do
    sum = sum+M.loss(genes,j,exData[i])
  end
  return sum
end
---
function M.crossover(g1,g2)
  M.idNum=M.idNum+1
  local child ={['cG']={},['nG']=g1.nG,['ecG']={},['id']=M.idNum}
  for i,j in pairs(g1.ecG) do
    if g2.ecG[i] then
      if math.random() <0.5 then
        for k,l in pairs(g1.cG) do
          if l[4]==j then
            local ind = tostring(l[1]).."-"..tostring(l[2])
            child.cG[#child.cG+1]=l
            child.ecG[ind]=M.exisCon[ind]
          end
        end
      else
        for k,l in pairs(g2.cG) do
          if l[4]==j then
            local ind = tostring(l[1]).."-"..tostring(l[2])
            child.cG[#child.cG+1]=l
            child.ecG[ind]=M.exisCon[ind]
          end
        end
      end
    end
  end
  return child
end
---
function M.breed(g1, g2, rwmC, swmC, nC, cC)
  rwmC = rwmC or 0.1
  swmC = swmC or 0.5
  nC = nC or 0.02
  cC = cC or 0.05
  local child = M.crossover(g1,g2)
  if math.random()<rwmC then M.rwMut(child, 0.5) print("Random Weight!") end
  if math.random()<swmC then M.swMut(child, 0.05) print("Weight Shift!") end
  if math.random()<nC then M.nMut(child) print("New Neuron!") end
  if math.random()<cC then M.conMut(child) print("New Connection!") end
  return child
end
---
return M
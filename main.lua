local m1 = require "MOD1"
local bloco = {w = 60, h = 60, velocidade = 10, gravidade = 1.5, y = 0, dist = {}}
local chao = {w = 0, h = 0, y0 = 0, x0 = 0, x = 0, y = 0}
local obstaculos = {}
local nPulos = 0
local t = 2
local game = true
local pontos = 0
local tPontos = 0.5
local genes =  {['id']=1,['gain']=81,['ecG']= {['-1--99']=1}, ['nG']= {-1,-99},['cG']= { {-1,-99,0.901,1} } }--{['loss']=0.008,['cG']= { {-1,-99,0.03,2} }, ['nG']= {-1,-99}, ['ecG']= {['-1--99']=1} }
math.randomseed(os.time())
function netUpdate(genes,dist1)
  return m1.evalNet(genes,{[-1]=dist1})
end
----
function bloco.pula()
  bloco.velocidade = -20
end

function desenhaObstaculos()
  love.graphics.setColor(0, 0, 0)
  local w, h= love.graphics.getDimensions()
  for i = 1, #obstaculos do
    love.graphics.rectangle("fill", obstaculos[i].x, obstaculos[i].y, obstaculos[i].w, obstaculos[i].h)
  end
end

function desenhaChao()
  local w, h= love.graphics.getDimensions()
  love.graphics.setColor(0,0.8, 0.7)
  love.graphics.polygon("fill", 0, h, 0, h - chao.h, chao.w, h - chao.h, chao.w, h)
end

function desenhaBloco()
  love.graphics.setColor(1, 0.2, 0)
  love.graphics.rectangle("fill", chao.x + 100, bloco.y, bloco.w, bloco.h)
end

function love.keypressed(key)
  if(key == "space") then
    if(nPulos < 2) then
      bloco.pula()
      nPulos = nPulos + 1 
    end
  end
end

function love.load()
  love.graphics.setBackgroundColor(1, 1, 1)
  love.window.setMode(800, 600)
  local w, h= love.graphics.getDimensions()
  chao.w = w
  chao.h = h*0.2
  chao.y0 = h - (chao.h/2)
  chao.x0 = chao.w/2
  chao.x = 0
  chao.y = h*0.8
  bloco.x0 = chao.x + 100 + bloco.w/2
  bloco.y0 = chao.y - bloco.h/2
  bloco.x = chao.x + 100
  geraObstaculos()
end

function geraObstaculos()
  local w, h = love.graphics.getDimensions()
  wb = math.random(40,40)
  hb = math.random(30, 30)
  obstaculos[#obstaculos + 1] = {w = wb, h = hb, velocidade = 5, x = w, y = chao.y - hb}
end 

function colisao()
  local xi = bloco.x0
  local yi = bloco.y + bloco.w/2
  local dxi = bloco.w
  local dyi = bloco.h
  for i = 1, #obstaculos do
    xj = obstaculos[i].x + (obstaculos[i].w/2)
    yj = obstaculos[i].y + (obstaculos[i].h/2)
    dxj = obstaculos[i].w
    dyj = obstaculos[i].h
    bloco.dist[i] = obstaculos[i].x - obstaculos[i].w - bloco.x
    if(not (xi + dxi/2 <= xj - dxj/2 or xj + dxj/2 <= xi - dxi/2 or yi + dyi/2 <= yj - dyj/2 or yj + dyj/2 <= yi - dyi/2)) then
      return i
    end
  end
  return -1
end

function love.update(dt)
  if(game) then
    bloco.velocidade = bloco.velocidade + bloco.gravidade
    bloco.y = bloco.y + bloco.velocidade
    if(bloco.y > chao.y - bloco.w) then
      bloco.y = chao.y - bloco.w
      nPulos = 0
    end
    t = t - dt
    if(t < 0) then 
      geraObstaculos()
      t = math.random(1,2)       ------------------------OBJECT GEN TIME
    end
    tPontos = tPontos - dt
    if(tPontos < 0) then
      pontos = pontos + 1
    end
  end
  
  local indexCol = colisao()
  if(indexCol ~= -1) then
    game = false
    for i = 1, #obstaculos do
      obstaculos[i].velocidade = 0
    end
    if(bloco.y + bloco.h > bloco.y and obstaculos[indexCol].x > bloco.x) then
      obstaculos[indexCol].x = bloco.x + bloco.w
    else
      bloco.y = obstaculos[indexCol].y - bloco.h
    end
  end
  
  for i = #obstaculos,1, -1  do
    obstaculos[i].x = obstaculos[i].x - obstaculos[i].velocidade
    if(obstaculos[i].x < 0) then 
      table.remove(obstaculos, i)
    end
  end
end

function love.draw()
  --print(netUpdate(genes,bloco.dist[1]))
  if netUpdate(genes,bloco.dist[1])[-99]/100<0.5 and nPulos<2 then bloco.pula() nPulos = nPulos+1 end
  desenhaChao()
  desenhaObstaculos()
  desenhaBloco()
  love.graphics.print(pontos, 400, 275)
  love.graphics.print("altura do bloco:" .. nPulos, 100, 100) --bloco.y
  for c,k in pairs(bloco.dist) do
    love.graphics.print("distancia proximo bloco:".. k, 10, 10 + 10*c)
  end
end
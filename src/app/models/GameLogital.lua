local GameLogital = class("GameLogital")

GameLogital.STONE_HIDE = "HIDE"
GameLogital.STONE_SHOW = "SHOW"

local function IS_VALID_POS(X,Y)
    if not X or  X < 1 or X > 9 then
        return false
    end
    if not Y or Y < 1 or Y > 9 then
        return false
    end
    return true 
end

function GameLogital:ctor()
    self:init()
end

function GameLogital:init()
    local seed = os.time()
    print("seed:",seed)
    math.randomseed(seed)
    --石头状态，用于标记某个石头是否显示。也可以利用随机数构建一些初始可见的石头。
    self.stones = {}
    for i = 1,9 do
        local arr = {}
        self.stones[i] = arr
        for j = 1,9 do
            arr[j] = {}
            arr[j].state = GameLogital.STONE_HIDE
            arr[j].step = -1
        end
    end
    for k = 1,math.random(1,20) do
        local x = math.random(1,9)
        local y = math.random(1,9)
        self.stones[x][y].state = GameLogital.STONE_SHOW
    end

    self.rabbit_position = {x = 5,y = 5}
    
    self.win = nil
    self.lose = nil
    self.current_steps = 0
end
function GameLogital:isWin()
    return self.win
end

function GameLogital:isLose()
    return self.lose
end

function GameLogital:stepCount()
    return self.current_steps
end

function GameLogital:clearResult()
    self.win = nil
    self.lose = nil
    self.current_steps = 0
end

function GameLogital:isStoneHided(x,y)
    return self.stones[x][y].state == GameLogital.STONE_HIDE
end
function GameLogital:getRabbitPos()
    return self.rabbit_position 
end

function GameLogital:touchStone(x,y)
    print("self.stones[x][y].state",self.stones[x][y].state)
    if self.stones[x][y].state == GameLogital.STONE_SHOW then
        return false
    else
        self.stones[x][y].state = GameLogital.STONE_SHOW
        self:rabbitWall()
        
        self.current_steps = self.current_steps + 1
        return true
    end
end

--[[
获取下一步的所有石头，同时判断当前步数是否可以走出界面。
用了一个取巧的办法去标记路径，带来的负面效果是路径在一定程度上可被预测（当两条路径重叠时，会被当成1条） ,因此使用了一个随机数去掉这个可能的预测。   
--]]
function GameLogital:getNext(nextTraversal,step,stone_steps,stone_flags)
    local temp = {}
    local isDone = false
    
    --概率改变遍历方式，使得路径不可预测。原因见上边的说明
    local first = 1
    local last = #nextTraversal
    local increse = 1
    if math.random() < 0.5 then
        first,last = last,first
        increse = -1
    end
    for k = first,last,increse do
        --获取当前石头
        local curStonePos = nextTraversal[k]
        local curStone = self.stones[curStonePos.x][curStonePos.y]
        
        --判断当前石头是否可以走
        if curStone.state == GameLogital.STONE_HIDE and--当前石头的状态是隐藏的，即可以走
           stone_steps[curStone] == nil  --有值则说明这块石头之前遍历过，所以可以不用再遍历
        then
            if step == 1 then
            --如果当前是第一步，那么让这块石头索引到一个table上，详细作用请看后续注视【1】和【2】
                stone_flags[curStone] = {}
            end
            stone_steps[curStone] = step
            if self:isOutSide(curStonePos) then--遍历到一个外围的石头
                isDone = true--说明当前走过的格子最少有一条路径可以走出石盘，可以结束遍历
                stone_flags[curStone][1] = true--【2】将flag这个table标记为true，使得此前走过的路径上所有石头都被标记上true。
            else
                --遍历当前石头周围的石头
                for k,pv in ipairs(self:getAroundStone(curStonePos)) do
                    local ns = self.stones[pv.x][pv.y]
                    if ns.state == GameLogital.STONE_HIDE then 
                        if stone_flags[ns] == nil then
                            stone_flags[ns] = stone_flags[curStone]--【1】使得从某个石头出发检索到的合法石头都被标记上同一个flag。
                        end
                        if stone_steps[ns] == nil then
                            table.insert(temp,pv)
                        end
                    end
                end
            end
        end
    end
    return isDone or #temp == 0,temp--temp为空，下一步没有格子可以遍历，说明兔子被围住了
end

function GameLogital:getAroundStone(pos)
    assert(pos,"getAroundStone: invalid position")
    --获取某个位置周围的六个格子。偶数行和奇数行的结果不一样
    local x,y = pos.x,pos.y
    if y%2 == 1 then
        return {cc.p(x+1,y),cc.p(x-1,y),
                cc.p(x-1,y+1),cc.p(x,y+1),
                cc.p(x-1,y-1),cc.p(x,y-1)}
    else
        return {cc.p(x,y-1),cc.p(x+1,y-1),
                cc.p(x-1,y),cc.p(x+1,y),
                cc.p(x,y+1),cc.p(x+1,y+1)}
    end
end
function GameLogital:isOutSide(pos)
    assert(pos,"isOutSide: invalid position")
    local x,y = pos.x,pos.y
    --判断是否在外围
    if x <= 1 or x >= 9 then
        return true
    end
    if y<=1 or y >= 9 then
        return true
    end
    return false
end

function GameLogital:rabbitWall()
    if self:isOutSide(self.rabbit_position) then
    --如果已经在最外围，直接判定为输
        self.lose = true
        return
    end    
    
    --找出最短路径
    local step = 0 -- 当前所需步骤
    local stone_steps = {}--存储走到的每个石头所需的步数
    local stone_flags = {}--用于保存遍历过的石头的flag，具体看getNext函数
    local nextTraversal = self:getAroundStone(self.rabbit_position)--所有即将被遍历的石头
    local ok = false
    repeat
    	step = step + 1
    	ok,nextTraversal = self:getNext(nextTraversal,step,stone_steps,stone_flags,stone_pre) 
    until ok
    
    local nexts = self:getAroundStone(self.rabbit_position)
    local validNexts = nil --兔子周围可以走的格子
    local allCanWalls = nil--当怎么走都走不出去，处于混乱模式时使用
    for k,v in pairs(nexts)do
        local stone = self.stones[v.x][v.y]
        if stone then
            local flag = stone_flags[stone]
            if flag then 
                allCanWalls = allCanWalls or {}--有就给这个变量设置个table，就是一个偷懒的标记
                table.insert(allCanWalls,v)
                if flag[1] then
                    validNexts = validNexts or {}--同上
                    table.insert(validNexts,v)
                end
            end
        end
    end
    --无路可走，那就完蛋啦
    validNexts = validNexts or allCanWalls
    if validNexts == nil then
        self.win = true
        return
    end
    
    --随机走任意一条可行的路线
    local rnd = math.random(1,#validNexts)
    self.rabbit_position = validNexts[rnd]
end

return GameLogital
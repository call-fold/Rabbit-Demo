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
    --ʯͷ״̬�����ڱ��ĳ��ʯͷ�Ƿ���ʾ��Ҳ�����������������һЩ��ʼ�ɼ���ʯͷ��
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
��ȡ��һ��������ʯͷ��ͬʱ�жϵ�ǰ�����Ƿ�����߳����档
����һ��ȡ�ɵİ취ȥ���·���������ĸ���Ч����·����һ���̶��Ͽɱ�Ԥ�⣨������·���ص�ʱ���ᱻ����1���� ,���ʹ����һ�������ȥ��������ܵ�Ԥ�⡣   
--]]
function GameLogital:getNext(nextTraversal,step,stone_steps,stone_flags)
    local temp = {}
    local isDone = false
    
    --���ʸı������ʽ��ʹ��·������Ԥ�⡣ԭ����ϱߵ�˵��
    local first = 1
    local last = #nextTraversal
    local increse = 1
    if math.random() < 0.5 then
        first,last = last,first
        increse = -1
    end
    for k = first,last,increse do
        --��ȡ��ǰʯͷ
        local curStonePos = nextTraversal[k]
        local curStone = self.stones[curStonePos.x][curStonePos.y]
        
        --�жϵ�ǰʯͷ�Ƿ������
        if curStone.state == GameLogital.STONE_HIDE and--��ǰʯͷ��״̬�����صģ���������
           stone_steps[curStone] == nil  --��ֵ��˵�����ʯͷ֮ǰ�����������Կ��Բ����ٱ���
        then
            if step == 1 then
            --�����ǰ�ǵ�һ������ô�����ʯͷ������һ��table�ϣ���ϸ�����뿴����ע�ӡ�1���͡�2��
                stone_flags[curStone] = {}
            end
            stone_steps[curStone] = step
            if self:isOutSide(curStonePos) then--������һ����Χ��ʯͷ
                isDone = true--˵����ǰ�߹��ĸ���������һ��·�������߳�ʯ�̣����Խ�������
                stone_flags[curStone][1] = true--��2����flag���table���Ϊtrue��ʹ�ô�ǰ�߹���·��������ʯͷ���������true��
            else
                --������ǰʯͷ��Χ��ʯͷ
                for k,pv in ipairs(self:getAroundStone(curStonePos)) do
                    local ns = self.stones[pv.x][pv.y]
                    if ns.state == GameLogital.STONE_HIDE then 
                        if stone_flags[ns] == nil then
                            stone_flags[ns] = stone_flags[curStone]--��1��ʹ�ô�ĳ��ʯͷ�����������ĺϷ�ʯͷ���������ͬһ��flag��
                        end
                        if stone_steps[ns] == nil then
                            table.insert(temp,pv)
                        end
                    end
                end
            end
        end
    end
    return isDone or #temp == 0,temp--tempΪ�գ���һ��û�и��ӿ��Ա�����˵�����ӱ�Χס��
end

function GameLogital:getAroundStone(pos)
    assert(pos,"getAroundStone: invalid position")
    --��ȡĳ��λ����Χ���������ӡ�ż���к������еĽ����һ��
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
    --�ж��Ƿ�����Χ
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
    --����Ѿ�������Χ��ֱ���ж�Ϊ��
        self.lose = true
        return
    end    
    
    --�ҳ����·��
    local step = 0 -- ��ǰ���貽��
    local stone_steps = {}--�洢�ߵ���ÿ��ʯͷ����Ĳ���
    local stone_flags = {}--���ڱ����������ʯͷ��flag�����忴getNext����
    local nextTraversal = self:getAroundStone(self.rabbit_position)--���м�����������ʯͷ
    local ok = false
    repeat
    	step = step + 1
    	ok,nextTraversal = self:getNext(nextTraversal,step,stone_steps,stone_flags,stone_pre) 
    until ok
    
    local nexts = self:getAroundStone(self.rabbit_position)
    local validNexts = nil --������Χ�����ߵĸ���
    local allCanWalls = nil--����ô�߶��߲���ȥ�����ڻ���ģʽʱʹ��
    for k,v in pairs(nexts)do
        local stone = self.stones[v.x][v.y]
        if stone then
            local flag = stone_flags[stone]
            if flag then 
                allCanWalls = allCanWalls or {}--�о͸�����������ø�table������һ��͵���ı��
                table.insert(allCanWalls,v)
                if flag[1] then
                    validNexts = validNexts or {}--ͬ��
                    table.insert(validNexts,v)
                end
            end
        end
    end
    --��·���ߣ��Ǿ��군��
    validNexts = validNexts or allCanWalls
    if validNexts == nil then
        self.win = true
        return
    end
    
    --���������һ�����е�·��
    local rnd = math.random(1,#validNexts)
    self.rabbit_position = validNexts[rnd]
end

return GameLogital
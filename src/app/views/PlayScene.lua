local PlayScene = class("PlayScene", cc.load("mvc").ViewBase)

local GameLogital = import("..models.GameLogital")

function PlayScene:onCreate()

    self.root = cc.CSLoader:createNode("PlayScene.csb"):addTo(self)

    local act = cc.CSLoader:createTimeline("PlayScene.csb")
    self.root:runAction(act)

    self.logi = GameLogital:create()

    self:initStoneListeners()
    self:initSettlementInterface()
    self:updateStoneBoard()
end
function PlayScene:initStoneListeners()

    for i = 1,9 do
        for j = 1,9 do
            local sp = self:getStonePic(i,j)

            sp:setVisible(true)
            sp:setOpacity(0)
            sp:setTouchEnabled(true)
            sp:addTouchEventListener(
                function(sender,evt)
                    if self:checkWin() then
                        return 
                    end
                    if evt == 2 and self.logi:touchStone(i,j) then

                        self:updateStoneBoard()
                        self:updateRabbitPosition()

                        if self:checkWin() then
                            self:showSettlementInterface()
                        end
                    end
                end)
        end
    end
end

function PlayScene:initSettlementInterface()
    -- do nothing
end

function PlayScene:updateStoneBoard()
    for i = 1,9 do
        for j = 1,9 do
            self:showStone(i,j,self.logi:isStoneHided(i,j))
        end
    end
end

function PlayScene:showSettlementInterface()
    local logi = self.logi
    local text = "YOU LOSE" 
    local color = cc.c3b(128,128,128)
    if logi:isWin() then
        text = string.format("YOU WIN",logi:stepCount())
        color = cc.c3b(255,215,0)
    end
    local step = logi:stepCount()
    
    local act = self.root:getActionByTag(self.root:getTag())
    act:gotoFrameAndPlay(0,false)

    local settlementLayer = self.root:getChildByName("settlement")
    for k,v in pairs(settlementLayer:getChildren())do
        print(k,v:getName())
    end
    local winLabel = settlementLayer:getChildByName("tip")
    winLabel:setString(text)
    local stepLabel = settlementLayer:getChildByName("step")
    stepLabel:setString(string.format("%d step",step))

    self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(
        function ()self:getApp():enterScene("MainScene")end)))
end

function PlayScene:checkWin()
    local logi = self.logi
    if not logi:isLose() and not logi:isWin() then
        return false
    end
    return true
end

function PlayScene:updateRabbitPosition()
    local pos = self.logi:getRabbitPos()
    local coord = cc.p(self:getStonePic(pos.x,pos.y):getPosition())
    self:getRabbitPic():setPosition(coord)
end

function PlayScene:showStone(x,y,state)
    if not state then
        local obj = self:getStonePic(x,y)
        obj:setOpacity(255)
    else
        self:getStonePic(x,y)
            :setOpacity(0)
    end
end

function PlayScene:getStonePic(x,y)
    return self.root:getChildByName(string.format("%d_%d",y,x))
end
function PlayScene:getRabbitPic()
    return self.root:getChildByName("rabbit")
end
return PlayScene

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    
    local root = cc.CSLoader:createNode("MainScene.csb") --读取csb文件
    self:addChild(root)

    local btn = root:getChildByName("play") --cocos studio 中定义的
    btn:addTouchEventListener(function (sender,evt)
        if evt == 2 then
            self:getApp():enterScene("PlayScene")
        end
    end)
end

return MainScene

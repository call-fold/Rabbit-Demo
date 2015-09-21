
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    local seed = os.time()
    print("seed:",seed)
    -- math.randomseed(seed)
end

return MyApp
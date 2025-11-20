local LuaClass = require("Core/LuaClass")
local AdventureBaseVM = require("Game/Adventure/AdventureBaseVM")
local UIBindableList = require("UI/UIBindableList")
local FateTaskVM = require("Game/Adventure/AdventureRecommendFateTaskItemVM")

local AdventureRecommendFateVM = LuaClass(AdventureBaseVM)

function AdventureRecommendFateVM:Ctor()
    self.ItemList = UIBindableList.New(FateTaskVM)
end

return AdventureRecommendFateVM
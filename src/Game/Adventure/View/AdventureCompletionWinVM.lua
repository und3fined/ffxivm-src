local LuaClass = require("Core/LuaClass")
local AdventureBaseVM = require("Game/Adventure/AdventureBaseVM")
local UIBindableList = require("UI/UIBindableList")
local AdventureItemVM = require("Game/Adventure/ItemVM/AdventureItemVM")

local AdventureCompletionWinVM = LuaClass(AdventureBaseVM)

function AdventureCompletionWinVM:Ctor()
    self.ItemList = UIBindableList.New(AdventureItemVM)
end

return AdventureCompletionWinVM
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local UIUtil = require("Utils/UIUtil")
local StoreNewBlindBoxDescItemVM = require("Game/Store/VM/ItemVM/StoreNewBlindBoxDescItemVM")

---@class StoreNewBlindBoxDescVM : UIViewModel
local StoreNewBlindBoxDescVM = LuaClass(UIViewModel)
---Ctor
function StoreNewBlindBoxDescVM:Ctor()
    self.AwardVMList = UIBindableList.New(StoreNewBlindBoxDescItemVM)
end

function StoreNewBlindBoxDescVM:UpdateVM(Params)
end


return StoreNewBlindBoxDescVM
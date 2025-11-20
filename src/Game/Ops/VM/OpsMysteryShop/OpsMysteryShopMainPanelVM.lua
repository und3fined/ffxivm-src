local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local UIBindableList = require("UI/UIBindableList")
local MysteryShopGoodsListItemVM = require("Game/Ops/VM/OpsMysteryShop/MysteryShopGoodsListItemVM")

---@class OpsMysteryShopMainPanelVM : UIViewModel
local OpsMysteryShopMainPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsMysteryShopMainPanelVM:Ctor()
    self.CommodityVMList = UIBindableList.New(MysteryShopGoodsListItemVM)
end

function OpsMysteryShopMainPanelVM:Update(GoodsList)
    table.sort(GoodsList, function(a, b)
        if a.Counter == 1 and b.Counter ~= 1 then
            return false
        elseif a.Counter ~= 1 and b.Counter == 1 then
            return true
        else
            return false
        end
    end)

    self.CommodityVMList:UpdateByValues(GoodsList)
end


return OpsMysteryShopMainPanelVM
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")

---@class FishIconItemVM : UIViewModel
local FishBaitItemVM = LuaClass(ItemVM)

function FishBaitItemVM:Ctor()

end

function FishBaitItemVM:OnSelectedChange(bSelect)
    self.IsSelect = bSelect
end

function FishBaitItemVM:SetSelected(bSelect)
    self.IsSelect = bSelect
end

function FishBaitItemVM:SetInUse(bChoose)
    self.IconChooseVisible = bChoose
end

function FishBaitItemVM:SetMask(bMask)
    self.IsMask = bMask
end

return FishBaitItemVM
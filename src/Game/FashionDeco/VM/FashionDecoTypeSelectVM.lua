local LuaClass = require("Core/LuaClass")
--local ItemVM = require("Game/Item/ItemVM")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecoTypeSelectorItemVM = require("Game/FashionDeco/VM/FashionDecoTypeSelectorItemVM")
---@class FashionDecoTypeSelectVM : UIViewModel
local FashionDecoTypeSelectVM = LuaClass(UIViewModel)

function FashionDecoTypeSelectVM:Ctor()
    self.PublicItemVMList = self:ResetBindableList(self.PublicItemVMList, FashionDecoTypeSelectorItemVM)

end

function FashionDecoTypeSelectVM:GetBestFirstIndex()
    return self.ParentVM:GetBestFirstIndex()
end
function FashionDecoTypeSelectVM:OnSelectChangedItem(InIndex, ItemData, ItemView)
    self.ParentVM:OnSelectChangedItem(InIndex, ItemData, ItemView)

end
return FashionDecoTypeSelectVM
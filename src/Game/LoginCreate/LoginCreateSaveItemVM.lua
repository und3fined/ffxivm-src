local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class LoginCreateSaveItemVM : UIViewModel
local LoginCreateSaveItemVM = LuaClass(UIViewModel)


function LoginCreateSaveItemVM:Ctor()
    self.IdText = ""
    self.TimeText = ""
    self.TribeGenderText = ""
    self.bItemSelect = false
    self.FaceList = {}
end

function LoginCreateSaveItemVM:SetItemData(SaveItem)
    self.IdText = SaveItem.IdText
    self.TimeText = SaveItem.TimeText
    self.TribeGenderText = SaveItem.TribeGenderText
    self.FaceList = SaveItem.DataList
end

function LoginCreateSaveItemVM:OnSelectedChange(IsSelected)
    self.bItemSelect = IsSelected
end
return LoginCreateSaveItemVM
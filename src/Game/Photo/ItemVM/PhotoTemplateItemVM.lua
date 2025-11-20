local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local PhotoTemplateItemVM = LuaClass(UIViewModel)

function PhotoTemplateItemVM:Ctor()
    self.ID = -1
    self.IsCust = false

    self.Name = ""
    self.Icon = ""

    self.IsSelected = false
    self.IsShowDelete = false
end

function PhotoTemplateItemVM:UpdateVM(Data)
	self.ID = Data.ID
    self.IsCust = Data.IsCust
    self.IsShowDelete = Data.IsCust
    self.IsSelected = false
    local Temp = _G.PhotoMgr:GetTemplate(self.ID, self.IsCust)
    if Temp then
        local BaseInfo = PhotoTemplateUtil.GetBaseInfo(Temp)
        self.Name = BaseInfo.Name
        self.Icon = BaseInfo.Icon
    end
end

function PhotoTemplateItemVM:IsEqualVM(Data)
	return (Data.ID == self.ID) and (Data.IsCust == self.IsCust)
end

function PhotoTemplateItemVM:UpdateIconState(isShow)
	self.IsSelected = isShow
end

return PhotoTemplateItemVM
---
--- Author: mingyyzhang
--- DateTime: 2025-06-17 18:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseInfoRoommateItemVM = require("Game/House/VM/Item/HouseInfoRoommateItemVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

---@class HouseInfoRoommateItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommHead CommHeadView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoRoommateItemView = LuaClass(UIView, true)

function HouseInfoRoommateItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommHead = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoRoommateItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoRoommateItemView:OnInit()

end

function HouseInfoRoommateItemView:OnDestroy()

end

function HouseInfoRoommateItemView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local Data = Params.Data
	if Data == nil then
		return
	end
	self.OwnerID = Data.RoleID
	self:SetRoleInfo(Data.RoleID)
end

function HouseInfoRoommateItemView:OnHide()

end

function HouseInfoRoommateItemView:OnRegisterUIEvent()

end

function HouseInfoRoommateItemView:OnRegisterGameEvent()

end

function HouseInfoRoommateItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data
	self.ViewModel = ViewModel
end

function HouseInfoRoommateItemView:SetRoleInfo(RoleID)
    RoleInfoMgr:QueryRoleSimple(RoleID, function()
        local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(RoleID, true)
        if RoleVM and self.OwnerID == RoleID then
            self.TextName:SetText(RoleVM.Name)
			self.CommHead:SetInfo(RoleID)
        end
    end, nil, true)
end

return HouseInfoRoommateItemView
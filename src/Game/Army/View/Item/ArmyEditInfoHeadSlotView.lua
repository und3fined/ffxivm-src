---
--- Author: Administrator
--- DateTime: 2024-12-30 20:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")



---@class ArmyEditInfoHeadSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgEmpty UFImage
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field TextPlayerName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyEditInfoHeadSlotView = LuaClass(UIView, true)

function ArmyEditInfoHeadSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgEmpty = nil
	--self.PlayerHeadSlot = nil
	--self.TextPlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyEditInfoHeadSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyEditInfoHeadSlotView:OnInit()
	self.Binders = {
		{ "RoleName", UIBinderSetText.New(self, self.TextPlayerName)},
		{ "IsRoleQueryFinish", UIBinderValueChangedCallback.New(self, nil, self.OnIsRoleQueryFinishChange) },
		{ "IsEmpty", UIBinderValueChangedCallback.New(self, nil, self.OnIsEmptyChange) },
	}
	self.PlayerHeadSlot:SetIsTriggerClick(true)
end

function ArmyEditInfoHeadSlotView:OnIsEmptyChange(IsEmpty)
	UIUtil.SetIsVisible(self.PlayerHeadSlot, not IsEmpty)
	UIUtil.SetIsVisible(self.ImgEmpty, IsEmpty)
	local Color 
	if IsEmpty then
		Color = "6D6B65FF"
	else
		Color = "313131FF"
	end
	UIUtil.SetColorAndOpacityHex(self.TextPlayerName,Color)
end

function ArmyEditInfoHeadSlotView:OnIsRoleQueryFinishChange(IsRoleQueryFinish)
	if IsRoleQueryFinish then
		self:SetPlayerHeadSlotData()
	end
end

function ArmyEditInfoHeadSlotView:SetPlayerHeadSlotData()
	local VM = self.ViewModel
	if VM then
		local CurRoleID = VM:GetRoleID()
		self.PlayerHeadSlot:SetInfo(CurRoleID)
	end
end

function ArmyEditInfoHeadSlotView:OnDestroy()

end

function ArmyEditInfoHeadSlotView:OnShow()

end

function ArmyEditInfoHeadSlotView:OnHide()

end

function ArmyEditInfoHeadSlotView:OnRegisterUIEvent()

end

function ArmyEditInfoHeadSlotView:OnRegisterGameEvent()

end

function ArmyEditInfoHeadSlotView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local VM = Params.Data
	if VM == nil then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return ArmyEditInfoHeadSlotView
---
--- Author: Administrator
--- DateTime: 2024-05-28 09:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class TreasureHuntTransferLIstItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgFocus UFImage
---@field ProfSlot CommPlayerSimpleJobSlotView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntTransferLIstItemView = LuaClass(UIView, true)

function TreasureHuntTransferLIstItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgFocus = nil
	--self.ProfSlot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntTransferLIstItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ProfSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntTransferLIstItemView:OnInit()

end

function TreasureHuntTransferLIstItemView:OnDestroy()

end

function TreasureHuntTransferLIstItemView:OnShow()

end

function TreasureHuntTransferLIstItemView:OnHide()

end

function TreasureHuntTransferLIstItemView:OnRegisterUIEvent()
 
end

function TreasureHuntTransferLIstItemView:OnRegisterGameEvent()

end

function TreasureHuntTransferLIstItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	self.ViewModel = Params.Data

	self.Binders = {
		{ "TeamMemberName", UIBinderSetText.New(self, self.TextName)},
		{ "ImgFocusVisible", UIBinderSetIsVisible.New(self, self.ImgFocus)},
	}

	self:RegisterBinders(self.ViewModel, self.Binders)	
	--职业
	self.ProfSlot:SetParams({ Data = self.ViewModel.ProfInfoVM })
end

function TreasureHuntTransferLIstItemView:OnSelectChanged(Value)
	local Params = self.Params
	if Params ==  nil then return end 

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	ViewModel.ImgFocusVisible = Value
	if Value then
		FLOG_ERROR(""..ViewModel.TeamMemberName)
	end
end

return TreasureHuntTransferLIstItemView
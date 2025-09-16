---
--- Author: daniel
--- DateTime: 2023-03-08 16:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class ArmyArmyListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextLevel UFTextBlock
---@field TextMemberAmount UFTextBlock
---@field TextName UFTextBlock
---@field TextShortName UFTextBlock
---@field ToggleBtn UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyArmyListItemView = LuaClass(UIView, true)


function ArmyArmyListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextLevel = nil
	--self.TextMemberAmount = nil
	--self.TextName = nil
	--self.TextShortName = nil
	--self.ToggleBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyArmyListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyArmyListItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName)},
		{ "ShortName", UIBinderSetText.New(self, self.TextShortName)},
		{ "ArmyLevel", UIBinderSetText.New(self, self.TextLevel)},
		{ "MemberAmount", UIBinderSetText.New(self, self.TextMemberAmount)},
		{ "IsSelected", UIBinderSetIsChecked.New(self, self.ToggleBtn, true) },
	}
end

function ArmyArmyListItemView:OnDestroy()

end

function ArmyArmyListItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return 
	end
	if self.ViewModel then
		if self.ViewModel.IsJoinItem and _G.ArmyMgr:GetSearchArmyCount() - Params.Index == 0 and _G.ArmyMgr:GetSearchArmyListIsEnd() == false then
			_G.ArmyMgr:SendArmySearchMsg()
		end
	end
end

function ArmyArmyListItemView:OnHide()

end

function ArmyArmyListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtn, self.OnClickedItem)
end

function ArmyArmyListItemView:OnRegisterGameEvent()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ArmyArmyListItemView:OnRegisterBinder()
end

function ArmyArmyListItemView:OnClickedItem()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Params.Index)
end

return ArmyArmyListItemView
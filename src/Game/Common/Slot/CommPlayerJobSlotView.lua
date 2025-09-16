---
--- Author: stellahxhu
--- DateTime: 2022-07-05 19:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local TeamVM = require("Game/Team/VM/TeamVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class CommPlayerJobSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtn_Item UFButton
---@field FImg_Level UFImage
---@field Icon_Leader UFImage
---@field Icon_Prof UFImage
---@field Text_PlayerLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommPlayerJobSlotView = LuaClass(UIView, true)

function CommPlayerJobSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FBtn_Item = nil
	--self.FImg_Level = nil
	--self.Icon_Leader = nil
	--self.Icon_Prof = nil
	--self.Text_PlayerLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPlayerJobSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPlayerJobSlotView:OnInit()

end

function CommPlayerJobSlotView:OnDestroy()

end

function CommPlayerJobSlotView:OnShow()
	--UIUtil.SetIsVisible(self.FImg_Select, false)
end

function CommPlayerJobSlotView:OnHide()

end

function CommPlayerJobSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_Item, self.OnClickButtonMember)
end

function CommPlayerJobSlotView:OnRegisterGameEvent()

end

function CommPlayerJobSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = self.Params.Data
	if Data then
		if Data.RoleVM then
			Data = Data.RoleVM
		end
	end

	if nil == Data then
		return
	end
	local ViewModel = TeamVM:FindMemberVM(Data.RoleID)

	if ViewModel ~= nil and ViewModel.IsCaptain then
		Data.IsCaptain = true
	end

	local Binders = {
		{ "Level", UIBinderSetText.New(self, self.Text_PlayerLevel) },
		{ "IsCaptain", UIBinderSetIsVisible.New(self, self.Icon_Leader)}
	}
	-- TeamMemberVM和RoleVM字段不一致，临时方法
	if Data.Prof then
		table.insert(Binders, { "Prof", UIBinderSetProfIcon.New(self, self.Icon_Prof) })
	else
		table.insert(Binders, { "ProfID", UIBinderSetProfIcon.New(self, self.Icon_Prof) })
	end

	self:RegisterBinders(Data , Binders)
end

function CommPlayerJobSlotView:OnClickButtonMember()
	--print("CommPlayerJobSlotView:OnClickButtonMember")
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

function CommPlayerJobSlotView:OnSelectChanged(IsSelected)
	--print(self.Params.Index)
	--print("CommPlayerJobSlotView:OnSelectChanged", IsSelected)
	--UIUtil.SetIsVisible(self.FImg_Select, IsSelected)
end

return CommPlayerJobSlotView
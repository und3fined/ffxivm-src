---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class PersonInfoProfSetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconSelect UFImage
---@field PersonInfoProf PersonInfoProfItemView
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoProfSetItemView = LuaClass(UIView, true)

function PersonInfoProfSetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconSelect = nil
	--self.PersonInfoProf = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoProfSetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PersonInfoProf)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoProfSetItemView:OnInit()
	self.BindersPersonInfoVM = {
		{ "StrPerferredProfSet", UIBinderValueChangedCallback.New(self, nil, self.OnPerferredProfChanged) },
	}
end

function PersonInfoProfSetItemView:OnDestroy()

end

function PersonInfoProfSetItemView:OnShow()

end

function PersonInfoProfSetItemView:OnHide()

end

function PersonInfoProfSetItemView:OnRegisterUIEvent()
end

function PersonInfoProfSetItemView:OnRegisterGameEvent()

end

function PersonInfoProfSetItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data

	self:RegisterBinders(PersonInfoVM, self.BindersPersonInfoVM)
end

function PersonInfoProfSetItemView:OnPerferredProfChanged()
	if PersonInfoVM.CurTabIdx == PersonInfoDefine.ModuleType.ProfInfo then
		UIUtil.SetIsVisible(self.IconSelect, false) 
		return
	end
	if nil == self.ViewModel or not self.ViewModel.IsJudgeShowSelectedIcon then
		UIUtil.SetIsVisible(self.IconSelect, false) 
		return
	end

	local ProfID = self.ViewModel.ProfID
	if nil == ProfID then
		UIUtil.SetIsVisible(self.IconSelect, false) 
		return
	end

	local Item = PersonInfoVM.PerferredProfSetSlotVMList:Find(function(e) 
		return e.ProfID == ProfID 
	end)

	UIUtil.SetIsVisible(self.IconSelect, Item ~= nil) 
end


return PersonInfoProfSetItemView
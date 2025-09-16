---
--- Author: lydianwang
--- DateTime: 2023-05-30 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")

local UIBinderSetText = require("Binder/UIBinderSetText")

local PWorldMgr = nil
local QuestLogVM = nil

---@class NewQuestLogTaskCategoryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextCategory UFTextBlock
---@field ToggleBtnIcon UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestLogTaskCategoryItemView = LuaClass(UIView, true)

function NewQuestLogTaskCategoryItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextCategory = nil
	--self.ToggleBtnIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskCategoryItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskCategoryItemView:OnInit()
	PWorldMgr = _G.PWorldMgr
	QuestLogVM = QuestMainVM.QuestLogVM
end

function NewQuestLogTaskCategoryItemView:OnDestroy()

end

function NewQuestLogTaskCategoryItemView:OnShow()
	if nil == self.Params then return end
	local VMData = self.Params.Data
	if nil == VMData then return end

	if QuestLogVM.bLogInProgress then
		local CurrMapID = PWorldMgr:GetCurrMapResID()
		self.ToggleBtnIcon:SetIsChecked(VMData.MapID == CurrMapID, false)
	else
		self.ToggleBtnIcon:SetIsChecked(false, false)
	end
end

function NewQuestLogTaskCategoryItemView:OnHide()

end

function NewQuestLogTaskCategoryItemView:OnRegisterUIEvent()

end

function NewQuestLogTaskCategoryItemView:OnRegisterGameEvent()

end

function NewQuestLogTaskCategoryItemView:OnRegisterBinder()
	if nil == self.Params then return end
	local VMData = self.Params.Data
	if nil == VMData then return end

	local Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextCategory) },
	}
	self:RegisterBinders(VMData, Binders)
end

return NewQuestLogTaskCategoryItemView
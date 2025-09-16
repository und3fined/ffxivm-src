---
--- Author: lydianwang
--- DateTime: 2023-05-25 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestDefine = require("Game/Quest/QuestDefine")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local QuestLogVM = nil
local QuestTrackVM = nil

---@class NewQuestLogTaskBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTask UFButton
---@field IconTask UFImage
---@field TaskBar UFCanvasPanel
---@field TextContain URichTextBox
---@field TextDistance UFTextBlock
---@field TextLevel UFTextBlock
---@field TextTaskName URichTextBox
---@field ToggleBtnTask UToggleButton
---@field Track UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestLogTaskBarItemView = LuaClass(UIView, true)

function NewQuestLogTaskBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTask = nil
	--self.IconTask = nil
	--self.TaskBar = nil
	--self.TextContain = nil
	--self.TextDistance = nil
	--self.TextLevel = nil
	--self.TextTaskName = nil
	--self.ToggleBtnTask = nil
	--self.Track = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskBarItemView:OnInit()
	QuestLogVM = QuestMainVM.QuestLogVM
	QuestTrackVM = QuestMainVM.QuestTrackVM
end

function NewQuestLogTaskBarItemView:OnDestroy()

end

function NewQuestLogTaskBarItemView:OnShow()
	if self.TextDistance then -- 不显示距离数字，后续删除蓝图控件
		UIUtil.SetIsVisible(self.TextDistance, false)
	end

	if nil == self.Params then return end
	local ChapterVM = self.Params.Data
	if nil == ChapterVM then return end

	--ChapterVM:UpdateTargetDistance()

	ChapterVM:UpdateHighLightText()
end

function NewQuestLogTaskBarItemView:OnHide()

end

function NewQuestLogTaskBarItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnTask, self.OnStateChangedQuestSelect)
end

function NewQuestLogTaskBarItemView:OnRegisterGameEvent()

end

function NewQuestLogTaskBarItemView:OnRegisterBinder()
	if nil == self.Params then return end
	local ChapterVM = self.Params.Data
	if nil == ChapterVM then return end

	if not self.ChapterVMBinders then
		self.ChapterVMBinders = {
			{ "HighLightName", UIBinderSetText.New(self, self.TextTaskName) }, --搜索高亮使用
			{ "Name", UIBinderSetText.New(self, self.TextTaskName) },
			{ "MinLevel", UIBinderSetTextFormat.New(self, self.TextLevel, "%d级") },
			{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.IconTask) },
			{ "bTracking", UIBinderSetIsVisible.New(self, self.Track) },
			{ "bTracking", UIBinderValueChangedCallback.New(self, nil, self.OnTrackingChanged) },
			-- { "Distance", UIBinderSetIsVisible.New(self, self.TextDistance, false, true) },
			-- { "Distance", UIBinderValueChangedCallback.New(self, nil, self.OnDistanceChanged) },
		}
	end
	self:RegisterBinders(ChapterVM, self.ChapterVMBinders)
end

function NewQuestLogTaskBarItemView:OnTrackingChanged(NewValue, OldValue)
	if NewValue then
		self:PlayAnimation(self.AnimTrack)
	end
end

function NewQuestLogTaskBarItemView:OnDistanceChanged(NewValue)
	if NewValue == nil then
		self.TextDistance:SetText("")
		return
	end

	local MaxDist = QuestDefine.QuestMaxDistance
	if (NewValue > MaxDist) then
		self.TextDistance:SetText(string.format("%d米+", MaxDist))
	else
		local IntNewValue = math.floor(NewValue)
		self.TextDistance:SetText(string.format("%d米", IntNewValue))
	end
end

function NewQuestLogTaskBarItemView:OnStateChangedQuestSelect(ToggleButton, ButtonState)
	local Adapter = self.Params.Adapter
	if nil ~= Adapter then
		Adapter:OnItemClicked(self, self.Params.Index)
	end
end

function NewQuestLogTaskBarItemView:OnSelectChanged(IsSelected)
	self.ToggleBtnTask:SetChecked(IsSelected, false)
	if not IsSelected then return end

	if nil == self.Params then return end
	local ChapterVM = self.Params.Data
	if nil == ChapterVM then return end

	QuestLogVM:ChangeQuestOnType(ChapterVM.ChapterID, ChapterVM:GetType())
	QuestLogVM:ChangeQuestOnType(ChapterVM.ChapterID, QuestDefine.LogQuestTypeAll)
	_G.FLOG_INFO("NewQuestLogTaskBarItemView:OnSelectChanged #%d %s", ChapterVM.ChapterID, ChapterVM.Name)
end

return NewQuestLogTaskBarItemView
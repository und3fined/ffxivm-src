---
--- Author: Administrator
--- DateTime: 2024-02-26 20:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")


---@class NewMapTaskListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTask UFButton
---@field IconTask UFImage
---@field TaskBar UFCanvasPanel
---@field TextContain URichTextBox
---@field TextLevel UFTextBlock
---@field TextTaskName URichTextBox
---@field ToggleBtnTask UToggleButton
---@field Track UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewMapTaskListItemView = LuaClass(UIView, true)

function NewMapTaskListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTask = nil
	--self.IconTask = nil
	--self.TaskBar = nil
	--self.TextContain = nil
	--self.TextLevel = nil
	--self.TextTaskName = nil
	--self.ToggleBtnTask = nil
	--self.Track = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewMapTaskListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewMapTaskListItemView:OnInit()
	self.Binders = {
		--{ "HighLightName", UIBinderSetText.New(self, self.TextTaskName) }, --搜索高亮使用
		{ "Name", UIBinderSetText.New(self, self.TextTaskName) },
		{ "MinLevel", UIBinderSetTextFormat.New(self, self.TextLevel, _G.LSTR(400001)) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.IconTask) },
		{ "bTracking", UIBinderSetIsVisible.New(self, self.Track) },
	}
end

function NewMapTaskListItemView:OnDestroy()

end

function NewMapTaskListItemView:OnShow()

end

function NewMapTaskListItemView:OnHide()

end

function NewMapTaskListItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnTask, self.OnStateChangedQuestSelect)
end

function NewMapTaskListItemView:OnRegisterGameEvent()

end

function NewMapTaskListItemView:OnRegisterBinder()
	if nil == self.Params or  nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function NewMapTaskListItemView:OnStateChangedQuestSelect(ToggleButton, ButtonState)
	local Adapter = self.Params.Adapter
	if nil ~= Adapter then
		Adapter:SetSelectedKey(self.ViewModel.Key)
	end
end

function NewMapTaskListItemView:OnSelectChanged(IsSelected, IsByClick)
	self.ToggleBtnTask:SetChecked(IsSelected, false)
	if IsSelected then
		if nil ~= self.ViewModel then
			_G.WorldMapVM:ShowWorldMapTaskDetailPanel(true, { ChapterID = self.ViewModel.ChapterID, QuestID = self.ViewModel.QuestID, EntryMode = 2 })
			_G.QuestMgr.QuestReport:ReportTaskLog(8, self.ViewModel.QuestID, self.ViewModel.ChapterID)
			local Adapter = self.Params.Adapter
			if Adapter then
				Adapter:CancelSelected()
			end
		end
	end
end

return NewMapTaskListItemView
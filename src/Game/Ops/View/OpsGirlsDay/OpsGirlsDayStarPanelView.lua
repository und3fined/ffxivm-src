---
--- Author: yutingzhan
--- DateTime: 2025-08-27 14:19
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local OpsGirlsDayStarPanelVM = require("Game/Ops/VM/OpsGirlsDay/OpsGirlsDayStarPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class OpsGirlsDayStarPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoto UFButton
---@field CloseBtn CommonCloseBtnView
---@field IconLock UFImage
---@field IconTask UFImage
---@field ImgBanner UFImage
---@field ImgBtnDisabled UFImage
---@field ImgBtnNormal UFImage
---@field PanelTaskLock UFHorizontalBox
---@field TableViewSlot UTableView
---@field TableViewTab UTableView
---@field TextBtn UFTextBlock
---@field TextHint UFTextBlock
---@field TextReward UFTextBlock
---@field TextTaskLock UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsGirlsDayStarPanelView = LuaClass(UIView, true)

function OpsGirlsDayStarPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoto = nil
	--self.CloseBtn = nil
	--self.IconLock = nil
	--self.IconTask = nil
	--self.ImgBanner = nil
	--self.ImgBtnDisabled = nil
	--self.ImgBtnNormal = nil
	--self.PanelTaskLock = nil
	--self.TableViewSlot = nil
	--self.TableViewTab = nil
	--self.TextBtn = nil
	--self.TextHint = nil
	--self.TextReward = nil
	--self.TextTaskLock = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayStarPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsGirlsDayStarPanelView:OnInit()
	self.ViewModel = OpsGirlsDayStarPanelVM.New()
	self.TaskListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnTaskSelectedChanged, false)

	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.RewardListAdapter:SetOnClickedCallback(self.OnClickRewardIcon)

	self.Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.TextTitle)},
		{"TextInfo", UIBinderSetText.New(self, self.TextHint)},
		{"ButtonText", UIBinderSetText.New(self, self.TextBtn)},
		{"ImgBanner", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner)},
		{"TaskListList", UIBinderUpdateBindableList.New(self, self.TaskListAdapter)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{"TaskLockVisible", UIBinderSetIsVisible.New(self, self.PanelTaskLock)},
		{"TaskLockVisible", UIBinderSetIsVisible.New(self, self.TextBtn,true)},
	}
end

function OpsGirlsDayStarPanelView:OnDestroy()

end

function OpsGirlsDayStarPanelView:OnShow()
	if self.Params == nil then
		return
	end
	self.TextReward:SetText(LSTR(100175))
	self.TextTaskLock:SetText(LSTR(100176))
	local CurIndex	= self.Params.CurrentTaskIndex
	local NodeListInfo = {}
	for _, TaskInfo in ipairs(self.Params.TaskListInfo) do
		table.insert(NodeListInfo, TaskInfo.Node)
	end
	self.ViewModel:Update(NodeListInfo, CurIndex)
	self.TaskListAdapter:SetSelectedIndex(CurIndex)
end

function OpsGirlsDayStarPanelView:OnHide()

end

function OpsGirlsDayStarPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnClickGotoBtn)
end

function OpsGirlsDayStarPanelView:OnRegisterGameEvent()

end

function OpsGirlsDayStarPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsGirlsDayStarPanelView:OnTaskSelectedChanged(Index, ItemData, ItemView)
	local TaskInfo = self.Params.TaskListInfo[Index]
	self.ViewModel:SetTaskTabSelected(Index)
	self.ViewModel:SetTaskInfo(Index, TaskInfo, self.Params.CurrentTaskIndex)
end


function OpsGirlsDayStarPanelView:OnClickRewardIcon(Index, ItemData, ItemView)
	if ItemData.ResID ~= nil then
		local ItemTipsUtil = require("Utils/ItemTipsUtil")
		ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end

function OpsGirlsDayStarPanelView:OnClickGotoBtn()
	self.ViewModel:JumpTo()
end

return OpsGirlsDayStarPanelView
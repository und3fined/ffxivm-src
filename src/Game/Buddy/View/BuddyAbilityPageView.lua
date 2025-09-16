---
--- Author: Administrator
--- DateTime: 2023-11-13 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local BuddyMgr = require("Game/Buddy/BuddyMgr")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local BuddySkillCfg = require("TableCfg/BuddySkillCfg")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local TipsUtil = require("Utils/TipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local MajorUtil = require ("Utils/MajorUtil")

local LSTR = _G.LSTR
---@class BuddyAbilityPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuff UFButton
---@field BtnLeave UFButton
---@field BtnStudy CommBtnXSView
---@field Btntips UFButton
---@field FunctionTab CommHorTabsView
---@field ImgBuff UFImage
---@field ImgLeaveIcon UFImage
---@field PanelSkillLevel UFCanvasPanel
---@field ProgressBarExp UProgressBar
---@field RichTextCost URichTextBox
---@field RichTextExp URichTextBox
---@field SizeBoxBuff USizeBox
---@field SizeBoxLeave USizeBox
---@field TableViewFunction UTableView
---@field TextName UFTextBlock
---@field TextReady UFTextBlock
---@field TextSkillLevel URichTextBox
---@field TextSkillPoint UFTextBlock
---@field AnimChangeTab UWidgetAnimation
---@field BtnChangeofName UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyAbilityPageView = LuaClass(UIView, true)

function BuddyAbilityPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuff = nil
	--self.BtnLeave = nil
	--self.BtnStudy = nil
	--self.Btntips = nil
	--self.FunctionTab = nil
	--self.ImgBuff = nil
	--self.ImgLeaveIcon = nil
	--self.PanelSkillLevel = nil
	--self.ProgressBarExp = nil
	--self.RichTextCost = nil
	--self.RichTextExp = nil
	--self.SizeBoxBuff = nil
	--self.SizeBoxLeave = nil
	--self.TableViewFunction = nil
	--self.TextName = nil
	--self.TextReady = nil
	--self.TextSkillLevel = nil
	--self.TextSkillPoint = nil
	--self.AnimChangeTab = nil
	--self.BtnChangeofName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyAbilityPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnStudy)
	self:AddSubView(self.FunctionTab)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyAbilityPageView:OnInit()
	self.TableViewSkillAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewFunction)
	self.TableViewSkillAdapter:SetOnClickedCallback(self.OnSkillItemClicked)

	self.Binders = {
		{ "NameText", UIBinderSetText.New(self, self.TextName)},
		
		{ "ReadyBrokenVisible", UIBinderSetIsVisible.New(self, self.TextReady) },
		{ "ExpText", UIBinderSetText.New(self, self.RichTextExp)},
		{ "ExpProgressPercent", UIBinderSetPercent.New(self, self.ProgressBarExp) },
		{ "SkillLevelText", UIBinderSetText.New(self, self.TextSkillLevel)},

		{ "SkillVMList", UIBinderUpdateBindableList.New(self, self.TableViewSkillAdapter) },

		{ "BuffImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBuff) },
		{ "BuffImgVisible", UIBinderSetIsVisible.New(self, self.BtnBuff,false, true) },

		{ "BuffNodeVisible", UIBinderSetIsVisible.New(self, self.SizeBoxBuff) },
		{ "LeaveNodeVisible", UIBinderSetIsVisible.New(self, self.SizeBoxLeave) },

		{ "SkillPointText", UIBinderSetText.New(self, self.TextSkillPoint)},
		{ "CostSkillPointText", UIBinderSetText.New(self, self.RichTextCost)},
		{ "StudyBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnStudy, false, true)},
		{ "StudyBtnVisible", UIBinderSetIsVisible.New(self, self.BtnStudy)},
	}
end

function BuddyAbilityPageView:OnDestroy()

end

function BuddyAbilityPageView:OnShow()
end

function BuddyAbilityPageView:OnHide()

end

function BuddyAbilityPageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.FunctionTab, self.OnGroupTabsSelectionChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnStudy.Button, self.OnBtnStudySkill)
	UIUtil.AddOnClickedEvent(self, self.Btntips, self.OnBtntips)
	UIUtil.AddOnClickedEvent(self, self.BtnBuff, self.OnBtnBuff) 
	UIUtil.AddOnClickedEvent(self, self.BtnLeave, self.OnBtnLeave) 
	UIUtil.AddOnClickedEvent(self, self.BtnChangeofName, self.OnBtnChangeName)
end

function BuddyAbilityPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BuddyUpdateAbility, self.OnUpdateBuddyAbilityInfo)
	self:RegisterGameEvent(EventID.BuddyUpdateStatus, self.OnUpdateBuddyStatus)
	self:RegisterGameEvent(EventID.BuddyTickTime, self.OnUpdateBuddyTickTime)
	self:RegisterGameEvent(EventID.BuddyRenameSuccess, self.OnBuddyRenameSuccess)
end

function BuddyAbilityPageView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	
	self:RegisterBinders(ViewModel, self.Binders)

	self.TextReady:SetText(LSTR(1000042))
	self.BtnStudy:SetText(LSTR(1000043))
end

function BuddyAbilityPageView:OnGroupTabsSelectionChanged(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	for i = 1, ViewModel.SkillVMList:Length() do
		local ItemView = self.TableViewSkillAdapter:GetChildWidget(i)
		if ItemView ~= nil then
			ItemView:StopAnimation(ItemView.AnimLearned)
		end	
	end
	

	ViewModel:SetTabsSelectionIndex(Index)
end


function BuddyAbilityPageView:OnSkillItemClicked(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:SelectedSkillItem(ItemData.ID)

	local ItemWidgetPosition = UIUtil.GetWidgetPosition(ItemView)
	local TableWidgetPosition = UIUtil.GetWidgetPosition(self.TableViewFunction)

	UIViewMgr:ShowView(UIViewID.BuddySkillDetailTips, {SkillID = ItemData.ID, SlotView = ItemView, Offset = {X = 30 + (ItemWidgetPosition.X - TableWidgetPosition.X), Y = -90}})
end

function BuddyAbilityPageView:OnBtnStudySkill()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if MajorUtil.IsMajorDead() then
		_G.MsgTipsUtil.ShowTipsByID(308012)
		return
	end

	local CurLearn = BuddySkillCfg:FindCfgByKey(ViewModel.CurLearnID)
	if CurLearn == nil then
		_G.MsgTipsUtil.ShowTipsByID(308013)
		return 
	end
	local Skills = BuddyMgr:GetAbilitySkills(CurLearn.Type)
	local CurLevel = Skills and #Skills or 0
	if CurLevel > CurLearn.Index then
		_G.MsgTipsUtil.ShowTipsByID(308014)
		return
	elseif CurLevel < CurLearn.Index then
		_G.MsgTipsUtil.ShowTipsByID(308015)
		return
	end

	if BuddyMgr:GetSkillUnassigned() < CurLearn.NeedPoints then
		_G.MsgTipsUtil.ShowTipsByID(308016)
		return
	end

	BuddyMgr:SendBuddyLearnSkillMessage(ViewModel.CurLearnID)

	local ItemView = self.TableViewSkillAdapter:GetChildWidget(CurLearn.Index + 1)
	ItemView:PlayAnimation(ItemView.AnimLearned)
end

function BuddyAbilityPageView:OnUpdateBuddyAbilityInfo()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateVM()
	ViewModel:SetTabsSelectionIndex(ViewModel.TabIndex or 1)
end

function BuddyAbilityPageView:OnBtntips()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	if ViewModel.ReadyBrokenVisible == true then
		_G.MsgTipsUtil.ShowTips(string.format(LSTR(1000041), ItemCfg:GetItemName(BuddyMgr.BreakThroughItemID)))
	end
end

function BuddyAbilityPageView:OnBtnBuff()
	local State = BuddyMgr:GetBuddyBuff()
	if State == nil then
		return
	end

	local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(State)
    if StateShowCfg ~= nil then
		local ItemViewSize = UIUtil.GetWidgetSize(self.BtnBuff)
		TipsUtil.ShowSimpleTipsView({Title = StateShowCfg.EffectName, Content = StateShowCfg.Desc}, self.BtnBuff, _G.UE.FVector2D(0, ItemViewSize.Y), _G.UE.FVector2D(1, 0), false)
    end

end

function BuddyAbilityPageView:OnBtnLeave()
	local ItemViewSize = UIUtil.GetWidgetSize(self.BtnLeave)
	TipsUtil.ShowSimpleTipsView({Title = LSTR(1000039), Content = LSTR(1000040)}, self.BtnLeave, _G.UE.FVector2D(0, ItemViewSize.Y), _G.UE.FVector2D(1, 0), false)
end

function BuddyAbilityPageView:OnUpdateBuddyStatus()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateBuddyState()
end

function BuddyAbilityPageView:OnUpdateBuddyTickTime()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateBuddyActivity()
end

function BuddyAbilityPageView:OnBtnChangeName()
	_G.BuddyMgr:OpenRenamePanel()
end

function BuddyAbilityPageView:OnBuddyRenameSuccess()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateVM()
end
return BuddyAbilityPageView
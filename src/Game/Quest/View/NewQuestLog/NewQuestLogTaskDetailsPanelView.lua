---
--- Author: lydianwang
--- DateTime: 2023-05-25 14:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local QuestHelper = require("Game/Quest/QuestHelper")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local QuestDefine = require("Game/Quest/QuestDefine")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local TipsUtil = require("Utils/TipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatUtil = require("Game/Chat/ChatUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local MapUtil = require("Game/Map/MapUtil")
local MapCfg = require("TableCfg/MapCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ColorUtil = require("Utils/ColorUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")

local RDType = QuestDefine.RestrictedDialogType
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS
local LSTR = _G.LSTR
local QuestLogVM = nil
local QuestTrackVM = nil

---@class NewQuestLogTaskDetailsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackPackSlot UTableView
---@field BtnDelete UFButton
---@field BtnExecute UFCanvasPanel
---@field BtnPlace UFButton
---@field BtnShare UFButton
---@field BtnStop CommBtnMView
---@field BtnSwitchJob UFButton
---@field BtnTrack CommBtnMView
---@field EmptyPanel UFCanvasPanel
---@field FVerticalFinish UFVerticalBox
---@field IconProfession UFImage
---@field IconTask UFImage
---@field ImgBanner UFImage
---@field PanelBanner UFCanvasPanel
---@field PanelSeal UFCanvasPanel
---@field PanelSwitch UFHorizontalBox
---@field PanelSwitchProfession UFCanvasPanel
---@field RichTextName URichTextBox
---@field RichTextTips URichTextBox
---@field RulePlace UFCanvasPanel
---@field RuleTips UFCanvasPanel
---@field ScrollBoxFinish UScrollBox
---@field ScrollBoxTarget UScrollBox
---@field SizeBoxBanner USizeBox
---@field TableViewTarget UTableView
---@field TaskRule NewQuestLogTaskRuleItemView
---@field TextDetails URichTextBox
---@field TextFinishDetails URichTextBox
---@field TextLevel UFTextBlock
---@field TextPlace UFTextBlock
---@field TextProfLv UFTextBlock
---@field TextProfession UFTextBlock
---@field TextRuleTipsTitle UFTextBlock
---@field TextTime UFTextBlock
---@field ToggleButtonTrack UToggleButton
---@field AnimRuleTipsIn UWidgetAnimation
---@field AnimSharePanelIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewQuestLogTaskDetailsPanelView = LuaClass(UIView, true)

function NewQuestLogTaskDetailsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackPackSlot = nil
	--self.BtnDelete = nil
	--self.BtnExecute = nil
	--self.BtnPlace = nil
	--self.BtnShare = nil
	--self.BtnStop = nil
	--self.BtnSwitchJob = nil
	--self.BtnTrack = nil
	--self.EmptyPanel = nil
	--self.FVerticalFinish = nil
	--self.IconProfession = nil
	--self.IconTask = nil
	--self.ImgBanner = nil
	--self.PanelBanner = nil
	--self.PanelSeal = nil
	--self.PanelSwitch = nil
	--self.PanelSwitchProfession = nil
	--self.RichTextName = nil
	--self.RichTextTips = nil
	--self.RulePlace = nil
	--self.RuleTips = nil
	--self.ScrollBoxFinish = nil
	--self.ScrollBoxTarget = nil
	--self.SizeBoxBanner = nil
	--self.TableViewTarget = nil
	--self.TaskRule = nil
	--self.TextDetails = nil
	--self.TextFinishDetails = nil
	--self.TextLevel = nil
	--self.TextPlace = nil
	--self.TextProfLv = nil
	--self.TextProfession = nil
	--self.TextRuleTipsTitle = nil
	--self.TextTime = nil
	--self.ToggleButtonTrack = nil
	--self.AnimRuleTipsIn = nil
	--self.AnimSharePanelIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskDetailsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnStop)
	self:AddSubView(self.BtnTrack)
	self:AddSubView(self.TaskRule)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewQuestLogTaskDetailsPanelView:OnInit()
	QuestLogVM = QuestMainVM.QuestLogVM
	QuestTrackVM = QuestMainVM.QuestTrackVM

	self.TargetList = UIAdapterTableView.CreateAdapter(self, self.TableViewTarget, self.OnSelectTargetChanged)
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.BackPackSlot)
	self.RewardList:SetOnClickedCallback(self.OnRewardListItemClicked)
end

function NewQuestLogTaskDetailsPanelView:OnDestroy()

end

function NewQuestLogTaskDetailsPanelView:OnShow()
	self:SetFixText()
	self.BtnStop:SetIsNormalState(true)
end

function NewQuestLogTaskDetailsPanelView:OnHide()

end

function NewQuestLogTaskDetailsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.TaskRule.BtnTips, self.OnClickButtonSpecialRule)
	UIUtil.AddOnClickedEvent(self, self.BtnPlace, self.OnClickButtonPlace)
	UIUtil.AddOnClickedEvent(self, self.BtnTrack.Button, self.OnClickButtonTrack)
	UIUtil.AddOnClickedEvent(self, self.BtnStop.Button, self.OnClickButtonTrackStop)
	UIUtil.AddOnClickedEvent(self, self.BtnShare, self.OnClickButtonShare)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickButtonGiveUp)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitchJob, self.OnClickButtonSwitchJob)
end

function NewQuestLogTaskDetailsPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.UpdateQuestTrack, self.OnEventUpdateQuestTrack)
end

function NewQuestLogTaskDetailsPanelView:OnRegisterBinder()
	if not self.CurrQuestBinders then
		self.CurrQuestBinders = {
			{ "ChapterID", UIBinderValueChangedCallback.New(self, nil, self.OnSelectedQuestChanged) },
			{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.IconTask) },
			{ "Name", UIBinderSetText.New(self, self.RichTextName) },
			{ "MinLevel", UIBinderSetTextFormat.New(self, self.TextLevel, "%d级") },
			{ "LogImage", UIBinderSetIsVisible.New(self, self.PanelBanner) },
			{ "LogImage", UIBinderSetBrushFromAssetPath.New(self, self.ImgBanner) },
			{ "SpecialRule", UIBinderValueChangedCallback.New(self, nil, self.OnSpecialRuleChanged) },
			{ "QuestLogMapName", UIBinderSetText.New(self, self.TextPlace) },
			{ "TargetVMList", UIBinderUpdateBindableList.New(self, self.TargetList) },
			{ "QuestLogTargetIndex", UIBinderValueChangedCallback.New(self, nil, self.OnQuestLogTargetIndexChanged) },
			{ "QuestHistoryDesc", UIBinderValueChangedCallback.New(self, nil, self.OnQuestHistoryDescChanged) },
			{ "RewardItemVMList", UIBinderUpdateBindableList.New(self, self.RewardList) },
			{ "Status", UIBinderValueChangedCallback.New(self, nil, self.OnQuestStatusChanged) },
			{ "SubmitTime", UIBinderValueChangedCallback.New(self, nil, self.OnQuestSubmitTimeChanged) },
		}
	end
	self:RegisterBinders(QuestLogVM.CurrChapterVM, self.CurrQuestBinders)

	local MajorVM = MajorUtil.GetMajorRoleVM()
	if not self.ProfBinders  then
		self.ProfBinders = {
			{ "Prof", UIBinderSetProfIcon.New(self, self.IconProfession)},
			{ "PWorldLevel", UIBinderSetText.New(self, self.TextProfLv) },
			{ "Prof", UIBinderSetProfName.New(self, self.TextProfession) },
		}
	end
	self:RegisterBinders(MajorVM, self.ProfBinders )
end

function NewQuestLogTaskDetailsPanelView:OnSelectTargetChanged(Index, VM, View)
	if VM == nil then return end

	if VM.OwnerChapterVM then
		local TargetCfgItem = nil
		if VM.TargetID < 1000 then
			if VM.GroupedTargetIDList and #VM.GroupedTargetIDList > 0 then
				local TargetID = VM.GroupedTargetIDList[1]
				TargetCfgItem = QuestHelper.GetTargetCfgItem(VM.OwnerChapterVM.QuestID, TargetID)
			end
		else
			TargetCfgItem = QuestHelper.GetTargetCfgItem(VM.OwnerChapterVM.QuestID, VM.TargetID)
		end
		if TargetCfgItem then
			if TargetCfgItem.MapID > 0 then
				QuestLogVM.CurrChapterVM.QuestLogMapName = MapCfg:FindValue(TargetCfgItem.MapID, "DisplayName") or LSTR(390006)
			end
		end
	end
end

function NewQuestLogTaskDetailsPanelView:OnSelectedQuestChanged(NewValue, OldValue)
	if NewValue == QuestTrackVM.CurrTrackChapterID then
		self.ToggleButtonTrack:SetChecked(true, false)

	elseif (OldValue == QuestTrackVM.CurrTrackChapterID)
	or (OldValue == nil) then
		self.ToggleButtonTrack:SetChecked(false, false)
	end

	-- 首次打开界面时，父控件View绑定Binder会调用一次OnValueChanged，此时被绑定的ChapterVM还是空的
	if (NewValue == nil) and (OldValue == nil) then return end

	local Cfg = QuestHelper.GetChapterCfgItem(NewValue)
	if Cfg == nil then
		QuestHelper.PrintQuestError("NewQuestLogMainPanelView select invalid chapter")
		return
	end

	local bCanGiveUp = (Cfg.QuestGenreID > 20000) and (Cfg.CanGiveup == 1)
	UIUtil.SetIsVisible(self.BtnDelete, bCanGiveUp, true)

	local ChapterVMItem = QuestMainVM:GetChapterVM(NewValue)
	if ChapterVMItem == nil then
		QuestHelper.PrintQuestError("NewQuestLogMainPanelView get chapter VM failed")
		return
	end
	local QuestCfgItem = QuestHelper.GetQuestCfgItem(ChapterVMItem.QuestID)
	local RDList = QuestHelper.MakeRestrictedDialog(ChapterVMItem.Status, Cfg, QuestCfgItem, true)
	local bBtnSwitchVisible = (RDList[RDType.Prof] ~= nil) or (RDList[RDType.FixedProf] ~= nil)
	UIUtil.SetIsVisible(self.PanelSwitchProfession, bBtnSwitchVisible)
end

function NewQuestLogTaskDetailsPanelView:OnSpecialRuleChanged(NewValue)
	local bShowSpecialRuleProfFixed = false
	if NewValue ~= nil and NewValue.bProfFixed then
		bShowSpecialRuleProfFixed = true
	end
	-- 临时处理
	UIUtil.SetIsVisible(self.TaskRule, bShowSpecialRuleProfFixed)
	self.TaskRule:SetProfFixed()
end

function NewQuestLogTaskDetailsPanelView:OnQuestLogTargetIndexChanged(NewValue)
	if NewValue == nil then return end

	local function SortFunction(Target1, Target2)
		if Target1.Status == Target2.Status then
			return Target1.TargetID < Target2.TargetID
		end
		return Target1.Status < Target2.Status
	end

	-- 已完成目标排在后面
	QuestLogVM.CurrChapterVM.TargetVMList:Sort(SortFunction)
	self.TargetList:SetSelectedIndex(NewValue)
end

function NewQuestLogTaskDetailsPanelView:OnQuestHistoryDescChanged(Str)
	self.TextDetails:SetText(ColorUtil.ParseItemNameBrightStyle(Str))
end

-- 点击任意位置关闭特殊规则界面
function NewQuestLogTaskDetailsPanelView:OnParentPanelPreMouseButtonDown()
	local bVisible = self.TaskRule.bTipsVisible
	if bVisible then
		self.TaskRule.bPreprocessClosed = true
		-- 没有别的地方可以重置状态，故延时重置，高频点击时表现会有轻微异常
		self:RegisterTimer(function()
			self.TaskRule.bPreprocessClosed = false
		end, 0.2)

		self.TaskRule.bTipsVisible = false
		UIUtil.SetIsVisible(self.RuleTips, false)
	end
end

function NewQuestLogTaskDetailsPanelView:OnClickButtonSpecialRule()
	local bVisible = self.TaskRule.bTipsVisible
	if not bVisible and self.TaskRule.bPreprocessClosed then
		return -- 避免预点击处理带来的影响
	end
	self.TaskRule.bTipsVisible = not bVisible
	UIUtil.SetIsVisible(self.RuleTips, not bVisible, false)
end

function NewQuestLogTaskDetailsPanelView:OnClickButtonPlace()
	local TargetVM = self.TargetList:GetSelectedItemData()
	if TargetVM then
		--处理组合目标
		local TargetID = TargetVM.TargetID
		if TargetID < 1000 then
			if TargetVM.GroupedTargetIDList and #TargetVM.GroupedTargetIDList > 0 then
				TargetID = TargetVM.GroupedTargetIDList[1]
			end
		end
		local OwnerChapterVM = TargetVM.OwnerChapterVM
		if OwnerChapterVM == nil then
			QuestHelper.PrintQuestError("NewQuestLogMainPanelView OnClickButtonPlace invalid chapter")
			return
		end

		local MapID = 0
		local UIMapID = 0
		local TargetCfgItem = QuestHelper.GetTargetCfgItem(OwnerChapterVM.QuestID, TargetID)
		if TargetCfgItem then
			if TargetCfgItem.MapID > 0 then
				MapID = TargetCfgItem.MapID
			end
			if TargetCfgItem.UIMapID > 0 then
				UIMapID = TargetCfgItem.UIMapID
			end
		end
		if UIMapID == 0 then
			if MapID > 0 then
				UIMapID = MapUtil.GetUIMapID(MapID)
			else
				MapID = OwnerChapterVM.MapID
				if TargetVM.MapIDList and next(TargetVM.MapIDList) then
					local K = next(TargetVM.MapIDList)
					MapID = K
				end
				UIMapID = MapUtil.GetUIMapID(MapID)
			end
		end
		_G.WorldMapMgr:ShowWorldMapQuest(MapID, UIMapID, OwnerChapterVM.QuestID, nil, TargetID)
		_G.QuestMgr.QuestReport:ReportTaskLog(3, OwnerChapterVM.QuestID, OwnerChapterVM.ChapterID)
	end
end

function NewQuestLogTaskDetailsPanelView:OnClickButtonTrack()
	_G.NaviDecalMgr:SetNaviType(_G.NaviDecalMgr.EGuideType.Task)
	local CurrChapterID = QuestLogVM.CurrChapterVM.ChapterID
	QuestTrackVM:TrackQuest(CurrChapterID)
	_G.QuestMgr.QuestReport:ReportTaskLog(1, QuestLogVM.CurrChapterVM.QuestID, CurrChapterID)
end

function NewQuestLogTaskDetailsPanelView:OnClickButtonTrackStop()
	local QuestID = 0
	local ChapterID = 0
	if QuestTrackVM.CurrTrackQuestVM then
		QuestID = QuestTrackVM.CurrTrackQuestVM.QuestID
		ChapterID = QuestTrackVM.CurrTrackQuestVM.ChapterID
	end
	QuestTrackVM:TrackQuest(nil)
	_G.QuestMgr.QuestReport:ReportTaskLog(2, QuestID, ChapterID)
end

function NewQuestLogTaskDetailsPanelView:OnClickButtonGiveUp()
	local function ConfirmCallback()
		local ChapterID = QuestLogVM.CurrChapterVM.ChapterID
		if (ChapterID or 0) > 0 then
			_G.QuestMgr:SendGiveUpQuest({ChapterID})
		end
		_G.QuestMgr.QuestReport:ReportTaskLog(4, QuestLogVM.CurrChapterVM.QuestID, ChapterID, 1)
	end
	local function CancelCallback()
		_G.QuestMgr.QuestReport:ReportTaskLog(4, QuestLogVM.CurrChapterVM.QuestID, QuestLogVM.CurrChapterVM.ChapterID, 2)
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004),
		LSTR(390007), ConfirmCallback, CancelCallback, LSTR(10003), LSTR(10002))
end

function NewQuestLogTaskDetailsPanelView:OnClickButtonSwitchJob()
	_G.ProfMgr.ShowProfSwitchTab()
end

function NewQuestLogTaskDetailsPanelView:OnSwitchLog(bLogInProgress)
	UIUtil.SetIsVisible(self.RulePlace, bLogInProgress)
	UIUtil.SetIsVisible(self.TableViewTarget, bLogInProgress)
	UIUtil.SetIsVisible(self.BackPackSlot, bLogInProgress)
	UIUtil.SetIsVisible(self.BtnExecute, bLogInProgress)
end

local ShareTransTB = {
	[3] = {
		["Item"] = {
			Content = LSTR(390008),
			ClickItemCallback = function()
				if QuestLogVM.CurrChapterVM then
					local IsSuccess, CDTime = _G.ChatMgr:ShareTask(ChatDefine.ChatChannel.Team, QuestLogVM.CurrChapterVM.ChapterID)
					if IsSuccess then
						MsgTipsUtil.ShowTips(string.format(LSTR(390009), LSTR(390008)))
					else
						if CDTime then
							MsgTipsUtil.ShowTips(string.format(LSTR(390010), math.floor(CDTime)))
						end
					end
				else
					MsgTipsUtil.ShowTips(LSTR(390011))
				end
				UIViewMgr:HideView(UIViewID.CommStorageTipsView)
			end
		},

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Team)
		end
	},

	[2] = {
		["Item"] = {
			Content = LSTR(390012),
			ClickItemCallback = function()
				if QuestLogVM.CurrChapterVM then
					local IsSuccess, CDTime = _G.ChatMgr:ShareTask(ChatDefine.ChatChannel.Army, QuestLogVM.CurrChapterVM.ChapterID)
					if IsSuccess then
						MsgTipsUtil.ShowTips(string.format(LSTR(390009), LSTR(390012)))
					else
						if CDTime then
							MsgTipsUtil.ShowTips(string.format(LSTR(390010), math.floor(CDTime)))
						end
					end
				else
					MsgTipsUtil.ShowTips(LSTR(390011))
				end
				UIViewMgr:HideView(UIViewID.CommStorageTipsView)
			end
		},

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Army)
		end
	},

	[1] = {
		["Item"] = {
			Content = LSTR(390013),
			ClickItemCallback = function()
				if QuestLogVM.CurrChapterVM then
					local IsSuccess, CDTime = _G.ChatMgr:ShareTask(ChatDefine.ChatChannel.Newbie, QuestLogVM.CurrChapterVM.ChapterID)
					if IsSuccess then
						MsgTipsUtil.ShowTips(string.format(LSTR(390009), LSTR(390013)))
					else
						if CDTime then
							MsgTipsUtil.ShowTips(string.format(LSTR(390010), math.floor(CDTime)))
						end
					end
				else
					MsgTipsUtil.ShowTips(LSTR(390011))
				end
				UIViewMgr:HideView(UIViewID.CommStorageTipsView)
			end
		},

		["EnableCheck"] = function()
			return _G.ChatMgr:IsInChannel(ChatDefine.ChatChannel.Newbie)
		end
	},
}

function NewQuestLogTaskDetailsPanelView:OnClickButtonShare()

	if UIViewMgr:IsViewVisible(UIViewID.CommStorageTipsView) then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
		return
	end

	local TransData = {}

	for _, Sub in pairs(ShareTransTB) do
		if Sub["EnableCheck"]() then
			table.insert(TransData, Sub["Item"])
		end
	end

	if #TransData <= 0 then
		_G.FLOG_INFO("ShareBtn Len === 0")
		MsgTipsUtil.ShowTips(LSTR(390014))
		return
	end

	TipsUtil.ShowStorageBtnsTips(TransData, self.BtnShare, _G.UE.FVector2D(20, -10),_G.UE.FVector2D(0.5, 1), false)
end

function NewQuestLogTaskDetailsPanelView:OnRewardListItemClicked(Index, ItemVM, ItemView)
	if ItemVM and ItemView then
		ItemTipsUtil.ShowTipsByResID(ItemVM.ResID, ItemView)
	end
end

function NewQuestLogTaskDetailsPanelView:OnQuestStatusChanged(NewValue, OldValue)
	if NewValue == nil then return end

	UIUtil.SetIsVisible(self.PanelSeal, NewValue == QuestDefine.CHAPTER_STATUS.FINISHED)
end

function NewQuestLogTaskDetailsPanelView:OnQuestSubmitTimeChanged(NewValue, OldValue)
	if NewValue == nil then return end

	local TimeSecond = NewValue // 1000 -- 原时间为毫秒，/1000取成秒
    local TimeString = TimeUtil.GetTimeFormat("%Y/%m/%d", TimeSecond)
	if TimeString then
		local Text = LocalizationUtil.LocalizeStringDate(TimeString)
		self.TextTime:SetText(Text)
	end
end

function NewQuestLogTaskDetailsPanelView:OnEventUpdateQuestTrack(Param)
	local CurChapterID = QuestLogVM.CurrChapterVM.ChapterID
	local IsTrackCurChapter = CurChapterID == QuestTrackVM.CurrTrackChapterID
	self.ToggleButtonTrack:SetChecked(IsTrackCurChapter, false)
end

function NewQuestLogTaskDetailsPanelView:SetFixText()
	self.BtnTrack:SetText(LSTR(390023))
	self.BtnStop:SetText(LSTR(390024))
	self.TextRuleTipsTitle:SetText(LSTR(390015))
	self.RichTextTips:SetText(LSTR(390025))
end

return NewQuestLogTaskDetailsPanelView
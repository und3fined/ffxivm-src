---
--- Author: usakizhang
--- DateTime: 2025-02-28 16:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsCeremonyCelebrationPanelVM = require("Game/Ops/VM/OpsCeremony/OpsCeremonyCelebrationPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityCfg = require("TableCfg/ActivityCfg")
local DataReportUtil = require("Utils/DataReportUtil")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local JumpUtil = require("Utils/JumpUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
---@class OpsCeremonyCelebrationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field BtnInfo USizeBox
---@field BtnParties UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field IconTime UFImage
---@field ImgLock UFImage
---@field InforBtn CommInforBtnView
---@field PanelParties UFCanvasPanel
---@field PanelTask UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field PanelTimeText UFHorizontalBox
---@field RedDot CommonRedDotView
---@field RichTextDescribe URichTextBox
---@field RichTextTime URichTextBox
---@field TableViewParties UTableView
---@field TableViewTaskSlot UTableView
---@field TextBtn UFTextBlock
---@field TextReward UFTextBlock
---@field TextTabParties UFTextBlock
---@field TextTabTask UFTextBlock
---@field TextTaskDescribe UFTextBlock
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnParties UToggleButton
---@field ToggleBtnTask UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCeremonyCelebrationPanelView = LuaClass(UIView, true)

function OpsCeremonyCelebrationPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.BtnInfo = nil
	--self.BtnParties = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.IconTime = nil
	--self.ImgLock = nil
	--self.InforBtn = nil
	--self.PanelParties = nil
	--self.PanelTask = nil
	--self.PanelTime = nil
	--self.PanelTimeText = nil
	--self.RedDot = nil
	--self.RichTextDescribe = nil
	--self.RichTextTime = nil
	--self.TableViewParties = nil
	--self.TableViewTaskSlot = nil
	--self.TextBtn = nil
	--self.TextReward = nil
	--self.TextTabParties = nil
	--self.TextTabTask = nil
	--self.TextTaskDescribe = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--self.ToggleBtnParties = nil
	--self.ToggleBtnTask = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCeremonyCelebrationPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCeremonyCelebrationPanelView:OnInit()
	self.ViewModel = OpsCeremonyCelebrationPanelVM.New()
	self.RewardListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTaskSlot)
	self.RewardListAdapter:SetOnClickedCallback(self.TableViewRewardClicked)
	self.PartiesLiatAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewParties)
	self.Binders = {
		--- 庆典任务页签
		{"TaskTabSelected", UIBinderSetIsChecked.New(self, self.ToggleBtnTask)},
		{"TaskTabSelected", UIBinderSetIsVisible.New(self, self.PanelTask)},
		{"TaskDescribeText", UIBinderSetText.New(self, self.TextTaskDescribe)},
		{"RewardVMList", UIBinderUpdateBindableList.New(self, self.RewardListAdapter)},
		{"RewardText", UIBinderSetText.New(self, self.TextReward)},

		---庆典排队页签
		{"PartiesTabSelected", UIBinderSetIsChecked.New(self, self.ToggleBtnParties)},
		{"PartiesTabSelected", UIBinderSetIsVisible.New(self, self.PanelParties)},
		{"PartiesDescribeText", UIBinderSetText.New(self, self.RichTextDescribe)},
		{"PartiesTimeText", UIBinderSetText.New(self, self.RichTextTime)},
		{"PartiesVMList", UIBinderUpdateBindableList.New(self, self.PartiesLiatAdapter)},
		{"PartiesIsLock", UIBinderSetIsVisible.New(self, self.BtnParties, false, true)},
		{"PartiesIsLock", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{ "RedDotName", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNameChanged) },
		{ "RedDotStyle", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotStyleChanged) },
		--- 公共
		{"ButtonText", UIBinderSetText.New(self, self.TextBtn)},
		{"TimeText", UIBinderSetText.New(self, self.TextTime)},
		{"Info", UIBinderSetText.New(self, self.TextMissionTips)},
	}
	self.InforBtn:SetCheckClickedCallback(self, self.OnInforBtnClick)
end

function OpsCeremonyCelebrationPanelView:OnDestroy()

end

function OpsCeremonyCelebrationPanelView:OnShow()
	---设置文字
	self.TextTitle:SetText(LSTR(1580004))---"跨越时空的庆典"
	self.TextTabTask:SetText(LSTR(1580014))---"庆典任务"
	self.TextTabParties:SetText(LSTR(1580015))---"庆典派对"
	---设置HelpInfo
	local Cfg = ActivityCfg:FindCfgByKey(OpsCeremonyDefine.CelebrationActivityID)
	if Cfg then
		self.InforBtn:SetHelpInfoID(Cfg.ChinaActivityHelpInfoID)
	end
	if self.Params == nil then
		return
	end
	if self.Params.Node == nil then
		return
	end

	self.ViewModel:Update(self.Params)
	if self.ViewModel.PartiesIsLock then
		UIUtil.SetIsVisible(self.ToggleBtnParties, true, false)
	else
		UIUtil.SetIsVisible(self.ToggleBtnParties, true, true)
	end
end

function OpsCeremonyCelebrationPanelView:OnHide()

end

function OpsCeremonyCelebrationPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.ToggleBtnTask, self.OnClickTaskTab)
	UIUtil.AddOnClickedEvent(self,  self.ToggleBtnParties, self.OnClickPartiesTab)
	UIUtil.AddOnClickedEvent(self,  self.BtnGo, self.OnClickBtnGo)
	UIUtil.AddOnClickedEvent(self,  self.BtnParties, self.OnClickBtnParties)
end

function OpsCeremonyCelebrationPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MapFollowAdd, self.Hide)
end

function OpsCeremonyCelebrationPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function OpsCeremonyCelebrationPanelView:TableViewRewardClicked(_, ItemData, ItemView)
	if ItemData.ItemID ~= nil then
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
	end
end

function OpsCeremonyCelebrationPanelView:OnClickTaskTab()
	if self.ViewModel ~= nil then
		self.ViewModel:SetTaskTabSelected()
	end
end

function OpsCeremonyCelebrationPanelView:OnClickPartiesTab()
	if self.ViewModel ~= nil then
		self.ViewModel:SetPartiesTabSelected()
	end
end

function OpsCeremonyCelebrationPanelView:OnClickBtnParties()
	_G.MsgTipsUtil.ShowTips(LSTR(1580026)) --"完成首环任务后解锁"
end

function OpsCeremonyCelebrationPanelView:OnClickBtnGo()
	local ViewModel = self.ViewModel
	if not ViewModel then
		return
	end
	--- 跳转至任务
	if ViewModel.TaskTabSelected then
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(OpsCeremonyDefine.NodeIDDefine.Celebration)
		if ActivityNode then
			DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.CelebrationActivityID), tostring(OpsSeasonActivityDefine.CelebrationActionType.ClickedGoTo1))
			_G.OpsActivityMgr:Jump(ActivityNode.JumpType, ActivityNode.JumpParam)
		end
	--- 跳转至指定坐标
	elseif ViewModel.PartiesTabSelected then
		DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.CelebrationActivityID), tostring(OpsSeasonActivityDefine.CelebrationActionType.ClickedGoTo2))
		_G.WorldMapMgr:OpenMapFromChatHyperlink(OpsCeremonyDefine.CelebrationMapID, _G.UE.FVector2D(OpsCeremonyDefine.CelebrationStartPos.x, OpsCeremonyDefine.CelebrationStartPos.y))
	end
end

function OpsCeremonyCelebrationPanelView:OnRedDotNameChanged(RedDotName)
	self.RedDot:SetRedDotNameByString(RedDotName)
end

function OpsCeremonyCelebrationPanelView:OnRedDotStyleChanged(RedDotStyle)
	if RedDotStyle then
		self.RedDot:SetStyle(RedDotStyle)
	end
end
function OpsCeremonyCelebrationPanelView:OnInforBtnClick()
	DataReportUtil.ReportActivityFlowData("CeremonyActionTypeClickFlow", tostring(OpsCeremonyDefine.CelebrationActivityID), tostring(OpsSeasonActivityDefine.CelebrationActionType.ClickedInfoBtn))
end

return OpsCeremonyCelebrationPanelView
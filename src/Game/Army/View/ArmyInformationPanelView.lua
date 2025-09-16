---
--- Author: Administrator
--- DateTime: 2025-01-21 20:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GroupActivityDataCfg = require("TableCfg/GroupActivityDataCfg")
local GroupRecruitProfCfg = require("TableCfg/GroupRecruitProfCfg")
local GroupActivityTimeCfg = require("TableCfg/GroupActivityTimeCfg")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local ArmyDefine = require("Game/Army/ArmyDefine")

local UIViewMgr
local UIViewID
local ArmyMainVM
local ArmyInformationPanelVM

---@class ArmyInformationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEdit CommBtnLView
---@field BtnReport UFButton
---@field BtnView CommBtnLView
---@field CommInforBtn CommInforBtnView
---@field CommonRedDot_UIBP CommonRedDotView
---@field FTextBlock_4 UFTextBlock
---@field ImgArmyIcon UFImage
---@field ImgArmyIcon_1 UFImage
---@field ImgArmyIcon_2 UFImage
---@field ProgressBarRelations UProgressBar
---@field RichTextBoxArmy02 URichTextBox
---@field RichTextBoxArmy03 URichTextBox
---@field TableViewActivity UTableView
---@field TableViewJob UTableView
---@field TextActivity UFTextBlock
---@field TextActivityTime UFTextBlock
---@field TextArmy UFTextBlock
---@field TextArmyName UFTextBlock
---@field TextCreateDate UFTextBlock
---@field TextDate UFTextBlock
---@field TextFriendlyRelations UFTextBlock
---@field TextGade_2 UFTextBlock
---@field TextMainActivity UFTextBlock
---@field TextNoticeTitle UFTextBlock
---@field TextRecruit UFTextBlock
---@field TextRecruitJob UFTextBlock
---@field TextRecruitState UFTextBlock
---@field TextRecruitState01 UFTextBlock
---@field TextRelations UFTextBlock
---@field TextRelationsState UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInformationPanelView = LuaClass(UIView, true)

function ArmyInformationPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEdit = nil
	--self.BtnReport = nil
	--self.BtnView = nil
	--self.CommInforBtn = nil
	--self.CommonRedDot_UIBP = nil
	--self.FTextBlock_4 = nil
	--self.ImgArmyIcon = nil
	--self.ImgArmyIcon_1 = nil
	--self.ImgArmyIcon_2 = nil
	--self.ProgressBarRelations = nil
	--self.RichTextBoxArmy02 = nil
	--self.RichTextBoxArmy03 = nil
	--self.TableViewActivity = nil
	--self.TableViewJob = nil
	--self.TextActivity = nil
	--self.TextActivityTime = nil
	--self.TextArmy = nil
	--self.TextArmyName = nil
	--self.TextCreateDate = nil
	--self.TextDate = nil
	--self.TextFriendlyRelations = nil
	--self.TextGade_2 = nil
	--self.TextMainActivity = nil
	--self.TextNoticeTitle = nil
	--self.TextRecruit = nil
	--self.TextRecruitJob = nil
	--self.TextRecruitState = nil
	--self.TextRecruitState01 = nil
	--self.TextRelations = nil
	--self.TextRelationsState = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInformationPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnEdit)
	self:AddSubView(self.BtnView)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommonRedDot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInformationPanelView:OnInit()
	UIViewMgr = _G.UIViewMgr
    UIViewID = _G.UIViewID
    ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
    ArmyInformationPanelVM = ArmyMainVM:GetArmyInformationPanelVM()
	---活动列表
	self.TableViewActivityAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity)
	self.TableViewActivityAdapter:SetOnClickedCallback(self.OnActivityItemClicked)
	---职业列表
	self.TableViewJobAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewJob)
	self.TableViewJobAdapter:SetOnClickedCallback(self.OnJobItemClicked)
	self.Binders = 
	{
		{"ActivityList", UIBinderUpdateBindableList.New(self, self.TableViewActivityAdapter)},
		{"JobList", UIBinderUpdateBindableList.New(self, self.TableViewJobAdapter)},
		{"IsRecurit", UIBinderValueChangedCallback.New(self, nil, self.OnIsRecuritChange)},
		{"RecruitSlogan", UIBinderSetText.New(self, self.FTextBlock_4)},
		{"ActivityTimeType", UIBinderValueChangedCallback.New(self, nil, self.OnActivityTimeTypeChange)},
		{"CreateTimeText", UIBinderSetText.New(self, self.TextDate)},
		{"ReputationProgressValue", UIBinderSetPercent.New(self, self.ProgressBarRelations) },
		{"ReputationStr", UIBinderSetText.New(self, self.TextRelationsState)},
		{"ReputationColor", UIBinderSetColorAndOpacity.New(self, self.TextRelationsState)},
		{"CurGrandCompanyName", UIBinderSetText.New(self, self.TextArmyName)},
		{"CurGrandCompanyIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyIcon)},
		{"OtherGrandCompanyName1", UIBinderSetText.New(self, self.RichTextBoxArmy02)},
		{"OtherGrandCompanyIcon1", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyIcon_1)},
		{"OtherGrandCompanyName2", UIBinderSetText.New(self, self.RichTextBoxArmy03)},
		{"OtherGrandCompanyIcon2", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyIcon_2)},
		{"IsShowEditBtn", UIBinderSetIsVisible.New(self, self.BtnEdit)},

	}
end

function ArmyInformationPanelView:OnDestroy()

end

function ArmyInformationPanelView:OnShow()
	---默认文本设置
	---LSTR 招募
	self.TextRecruit:SetText(LSTR(910388))
	---LSTR 招募状态
	self.TextRecruitState:SetText(LSTR(910298))
	---LSTR 招募职业
	self.TextRecruitJob:SetText(LSTR(910375))
	---LSTR 招募标语
	self.TextNoticeTitle:SetText(LSTR(910136))
	---LSTR 活动
	self.TextActivity:SetText(LSTR(910389))
	---LSTR 活动时间
	self.TextGade_2:SetText(LSTR(910372))
	---LSTR 主要活动
	self.TextMainActivity:SetText(LSTR(910373))
	---LSTR 友好关系
	self.TextFriendlyRelations:SetText(LSTR(910390))
	---LSTR 当前关系
	self.TextRelations:SetText(LSTR(910391))
	---LSTR 其他联防军
	self.TextArmy:SetText(LSTR(910392))
	---LSTR 创建时间
	self.TextCreateDate:SetText(LSTR(910374))
	---LSTR 预览情报
	self.BtnView:SetText(LSTR(910394))
	---LSTR 编辑情报
	self.BtnEdit:SetText(LSTR(910395))
end

function ArmyInformationPanelView:OnHide()

end

function ArmyInformationPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnEdit, self.OnClickedEdit)
    UIUtil.AddOnClickedEvent(self, self.BtnView, self.OnClickedPreview)
	UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickedReport)
end

function ArmyInformationPanelView:OnRegisterGameEvent()

end

function ArmyInformationPanelView:OnRegisterBinder()
    if nil == ArmyInformationPanelVM then
        _G.FLOG_ERROR("ArmyInformationPanelView:OnRegisterBinder ArmyInformationPanelVM is nil")
        return
    end
    self:RegisterBinders(ArmyInformationPanelVM, self.Binders)
end

---活动item点击
function ArmyInformationPanelView:OnActivityItemClicked(Index, ItemData, ItemView)
	local ID = ItemData.ID
	local Cfg = GroupActivityDataCfg:FindCfgByKey(ID)
	if Cfg then
		local TipsText = Cfg.TipsText
		if TipsText then
			TipsUtil.ShowInfoTips(TipsText, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0))
		end
	end
end

---职业item点击
function ArmyInformationPanelView:OnJobItemClicked(Index, ItemData, ItemView)
	local ID = ItemData.ID
	local Cfg = GroupRecruitProfCfg:FindCfgByKey(ID)
	if Cfg then
		local TipsText = Cfg.TipsText
		if TipsText then
			TipsUtil.ShowInfoTips(TipsText, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0))
		end
	end
end

---招募状态设置
function ArmyInformationPanelView:OnIsRecuritChange(IsRecurit)
	if IsRecurit then
		---LSTR:开放招募
		self.TextRecruitState01:SetText(LSTR(910393))
	else
		---LSTR:停止招募
		self.TextRecruitState01:SetText(LSTR(910049))
	end
end

---活动时间设置
function ArmyInformationPanelView:OnActivityTimeTypeChange(ActivityTimeType)
	local CfgType = ActivityTimeType
	if ActivityTimeType == 0 or ActivityTimeType == nil then
		CfgType = 1 --默认为1
	end
	local Cfg = GroupActivityTimeCfg:FindCfgByKey(CfgType)
	if Cfg then
		self.TextActivityTime:SetText(Cfg.Text)
	end
end

---预览情报
function ArmyInformationPanelView:OnClickedPreview()
	local InformationData
	if ArmyInformationPanelVM then
		InformationData = ArmyInformationPanelVM:GetInformationData()
	end
	if InformationData then
		local Params = {
			PanelBaseInfo = InformationData,
            Info = {
				IsHideBtn = true,
				ArmyID = _G.ArmyMgr:GetArmyID(),
			},
		}
		_G.ArmyMgr:OpenArmyJoinInfoPanelByLocalData(Params)
	end

end

---编辑情报
function ArmyInformationPanelView:OnClickedEdit()
	--local Params
	if ArmyInformationPanelVM then
		ArmyInformationPanelVM:UpdateEditWinVMCurData()
		UIViewMgr:ShowView(UIViewID.ArmyEditInformationWin)
		--- 隐藏编辑招募提醒红点
		_G.RedDotMgr:DelRedDotByID(ArmyDefine.ArmyRedDotID.ArmyInformationEditRemind)
	end
end

function ArmyInformationPanelView:OnClickedReport()
	local RoleID = _G.ArmyMgr:GetLeaderRoleID()
	local GroupID = _G.ArmyMgr:GetArmyID()
	local GroupName = _G.ArmyMgr:GetArmyName()
	local Abbreviation = _G.ArmyMgr:GetArmyAlias()
	local RecruitmentSlogan = ""
	if ArmyInformationPanelVM then
		RecruitmentSlogan = ArmyInformationPanelVM:GetRecruitSlogan()
	end
	local Params = {
        ReporteeRoleID = RoleID,
        GroupID = GroupID,
        GroupName = GroupName,
		ReportContentList = {
			Abbreviation = Abbreviation,
			RecruitmentSlogan = RecruitmentSlogan,
		},
    }
	--- Params.ReportContentList  = { "Abbreviation" = "部队简称文本", "RecruitmentSlogan" = "招募标语文本"}
	_G.ReportMgr:OpenViewByArmyList(Params)
end

function ArmyInformationPanelView:IsForceGC()
	return true
end

return ArmyInformationPanelView
---
--- Author: v_hggzhang
--- DateTime: 2022-11-09 09:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local PWorldCfg = require("TableCfg/PworldCfg")
local SceneCombatCfg = require("TableCfg/SceneCombatCfg")
local TeamMgr = require("Game/Team/TeamMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require ("Utils/MajorUtil")
local MsgTipsID = require("Define/MsgTipsID")

local function GetTargetChapterBackgroudImage(TargetID)
	local QuestTargetCfg = require("TableCfg/QuestTargetCfg")
	local TargetCfg = QuestTargetCfg:FindCfgByKey(TargetID)
	if TargetCfg then
		local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
		local ChapterCfg = QuestChapterCfg:FindCfgByKey(TargetCfg.ChapterID)
		return ChapterCfg and ChapterCfg.LogImage or nil
	end
end

local EPWorldLv = {
	Normal = 1,
	Easy = 2,
	Easiest = 3
}

local UIViewModel = require("UI/UIViewModel")
local PWorldMainlinePanelVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR
function PWorldMainlinePanelVM:Ctor()
	self.Icon = ""
	self.Name = ""
	self.Desc = LSTR(1320089)
	self.EquipMaxLv = ""
	self.Lv = ""
	self.PWorldLvIdx = 0
	self.HasFailedRecord = false
	self.PreviewImg = ""
	self.InteractiveIDs = {}
	self.CurInteractID = 0
end

function PWorldMainlinePanelVM:UpdVM(Data)
	self.Data = Data
	self.InteractiveIDs[EPWorldLv.Normal] = Data.NormalID
	self.InteractiveIDs[EPWorldLv.Easy] = Data.EasyID
	self.InteractiveIDs[EPWorldLv.Easiest] = Data.EasiestID

	local LvText = LSTR(1320087)
	local Cfg = self:FindPWorldCfg(Data.NormalID)
	if Cfg then
		local CombatCfg = SceneCombatCfg:FindCfgByKey(Cfg.ID) or {}
		if CombatCfg then
			self.Lv = string.sformat(LSTR(1320090), (CombatCfg.SyncMaxLv or ""))   .. LvText
			self.EquipMaxLv = string.sformat(LSTR(1320091), (CombatCfg.EquipLv or ""))  .. LvText
		end
	end

	self.PreviewImg = GetTargetChapterBackgroudImage(Data.FromTargetID)
	self.Name = Cfg and Cfg.PWorldName or ""
	self.Icon = Cfg and Cfg.PWorldIcon or ""

	local CounterID = Cfg and Cfg.FailureCounterID or 0
	local FailedCnt = tonumber(_G.CounterMgr:GetCounterCurrValue(CounterID)) or 0
	self.HasFailedRecord = FailedCnt > 0
	self:SetPWorldLvIdx(EPWorldLv.Normal)
end

function PWorldMainlinePanelVM:SetPWorldLvIdx(Idx)
	self.PWorldLvIdx = Idx
	self.CurInteractID = self.InteractiveIDs[Idx]
end

--- @return PWorldCfg
function PWorldMainlinePanelVM:FindPWorldCfg(ID)
	local Cfg = nil
	local ICfg = require("TableCfg/InteractivedescCfg"):FindCfgByKey(ID)
	local FuncCfg = require("TableCfg/FuncCfg"):FindCfgByKey(ICfg and ICfg.FuncID or nil)
	if FuncCfg and FuncCfg.Func[1] and FuncCfg.Func[1].Value[1] then
		local TCfg = require("TableCfg/TransCfg"):FindCfgByKey(FuncCfg.Func[1].Value[1])
		Cfg = PWorldCfg:FindCfgByKey(TCfg and TCfg.SceneID or nil)
	end

	return Cfg
end

---@class PWorldMainlinePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnGoTo CommBtnLView
---@field ImgPworldBkg UFImage
---@field PanelFailed UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextClass UFTextBlock
---@field TextEasiest UFTextBlock
---@field TextEasy UFTextBlock
---@field TextLevel UFTextBlock
---@field TextNormal UFTextBlock
---@field TextPworldName UFTextBlock
---@field TextSelectDifficult UFTextBlock
---@field TextSummary UFTextBlock
---@field ToggleBtnEasiest UToggleButton
---@field ToggleBtnEasy UToggleButton
---@field ToggleBtnNormal UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimToggleBtnEasiestChecked UWidgetAnimation
---@field AnimToggleBtnEasiestUnchecked UWidgetAnimation
---@field AnimToggleBtnEasyChecked UWidgetAnimation
---@field AnimToggleBtnEasyUnchecked UWidgetAnimation
---@field AnimToggleBtnNormalChecked UWidgetAnimation
---@field AnimToggleBtnNormalUnchecked UWidgetAnimation
---@field BackupAnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMainlinePanelView = LuaClass(UIView, true)

function PWorldMainlinePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnGoTo = nil
	--self.ImgPworldBkg = nil
	--self.PanelFailed = nil
	--self.PopUpBG = nil
	--self.TextClass = nil
	--self.TextEasiest = nil
	--self.TextEasy = nil
	--self.TextLevel = nil
	--self.TextNormal = nil
	--self.TextPworldName = nil
	--self.TextSelectDifficult = nil
	--self.TextSummary = nil
	--self.ToggleBtnEasiest = nil
	--self.ToggleBtnEasy = nil
	--self.ToggleBtnNormal = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimToggleBtnEasiestChecked = nil
	--self.AnimToggleBtnEasiestUnchecked = nil
	--self.AnimToggleBtnEasyChecked = nil
	--self.AnimToggleBtnEasyUnchecked = nil
	--self.AnimToggleBtnNormalChecked = nil
	--self.AnimToggleBtnNormalUnchecked = nil
	--self.BackupAnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMainlinePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnGoTo)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMainlinePanelView:OnInit()
	self.VM = PWorldMainlinePanelVM.New()
	self.Binders = {
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPworldIcon) },
		{ "PreviewImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgPworldBkg) },
		{ "HasFailedRecord", UIBinderSetIsVisible.New(self, self.PanelFailed) },
		{ "PWorldLvIdx", UIBinderValueChangedCallback.New(self, nil, function(_, Index)
			self.ToggleBtnNormal:SetChecked(Index == EPWorldLv.Normal)
			self.ToggleBtnEasy:SetChecked(Index == EPWorldLv.Easy)
			self.ToggleBtnEasiest:SetChecked(Index == EPWorldLv.Easiest)
		end) },
		{ "Name", UIBinderSetText.New(self, self.TextPworldName) },
		{ "Desc", UIBinderSetText.New(self, self.TextSummary) },
		{ "EquipMaxLv", UIBinderSetText.New(self, self.TextClass) },
		{ "Lv", UIBinderSetText.New(self, self.TextLevel) },
	}

	self.TextSelectDifficult:SetText(_G.LSTR(1320193))
	self.TextNormal:SetText(_G.LSTR(1320194))
	self.TextEasy:SetText(_G.LSTR(1320195))
	self.TextEasiest:SetText(_G.LSTR(1320196))
	self.BtnCancel:SetText(_G.LSTR(1320197))
	self.BtnGoTo:SetText(_G.LSTR(1320198))
end

function PWorldMainlinePanelView:OnShow()
	self.VM:UpdVM(self.Params)
	self.bEnterPWorld = false

	local AudioUtil = require("Utils/AudioUtil")
	AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_copy_enter.Play_UI_copy_enter'")
end

function PWorldMainlinePanelView:OnHide()
	if not self.bEnterPWorld then
		-- 任务流程会用接口打开单人本界面，如果玩家不进入副本，通知后台回退目标
		_G.QuestMgr:CheckNeedRevertTarget()
	end
	_G.NpcDialogMgr:EndInteraction()
end

function PWorldMainlinePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnNormal, function()
		self.VM:SetPWorldLvIdx(EPWorldLv.Normal)
	end)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnEasy, function()
		self.VM:SetPWorldLvIdx(EPWorldLv.Easy)
	end)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnEasiest, function()
		self.VM:SetPWorldLvIdx(EPWorldLv.Easiest)
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnGoTo.Button, function()
		-- 死亡状态下不支持操作
		if MajorUtil.IsMajorDead() == true then
			_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.DeadStateCantControls)
			return
		end
		
		local bFlag
		if TeamMgr:IsInTeam() then	
			MsgTipsUtil.ShowTips(LSTR(1320092))
		elseif _G.PWorldMatchMgr:IsMatching() then
			MsgTipsUtil.ShowTips(LSTR(1320093))
		else
			_G.FLOG_INFO("PWorldMainlinePanelView enter single pworld by %s", self.VM.CurInteractID)
			_G.PWorldMgr:EnterSinglePWorld(self.VM.CurInteractID)
			bFlag = true
		end

		if not bFlag then
			self:Hide()
		end
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, function()
		_G.UIViewMgr:HideView(_G.UIViewID.PWorldMainlinePanel)
		_G.InteractiveMgr:DelayShowEntrance(0.3)
	end)
end

function PWorldMainlinePanelView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function PWorldMainlinePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PWorldMapEnter, self.OnPWorldMapEnter)
end

function PWorldMainlinePanelView:OnPWorldMapEnter()
	_G.FLOG_INFO("Hide PWorldMainlinePanelView for map enter!")
	self.bEnterPWorld = true
	self:Hide()
end

return PWorldMainlinePanelView
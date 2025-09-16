---
--- Author: chaooren
--- DateTime: 2022-06-24 14:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillUtil = require("Utils/SkillUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local EventID = require("Define/EventID")
local UIDefine = require("Define/UIDefine")
local SkillSystemVM = require("Game/Skill/SkillSystem/SkillSystemVM")
local SkillMainCfg = require("TableCfg/SkillMainCfg")

local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetViewParams = require("Binder/UIBinderSetViewParams")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetText = require("Binder/UIBinderSetText")

local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ObjectMgr = require("Object/ObjectMgr")
local ProfMgr = require("Game/Profession/ProfMgr")
local SkillCustomMgr = require("Game/Skill/SkillCustomMgr")
local SkillLogicMgr = require("Game/Skill/SkillLogicMgr")
local EObjectGC = _G.UE.EObjectGC
local EMapType = SkillUtil.MapType

local RoleInitCfg = require("TableCfg/RoleInitCfg")
local SkillSystemConfig = require("Game/Skill/SkillSystem/SkillSystemConfig")
local MsgTipsID = require("Define/MsgTipsID")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

local SkillSystemMgr = _G.SkillSystemMgr
local CommBtnColorType <const> = UIDefine.CommBtnColorType

local LSTR                       <const> = LSTR
local TextID_EnterCustomSkill    <const> = 170102
local TextID_SaveCustomSkill     <const> = 170103
local TextID_LeaveCustomSkill    <const> = 170108
local TipsID_DisableCombatCustom <const> = 106044

local TabIndex_PVE      <const> = 1
local TabIndex_PVP      <const> = 2
local ProfClassType_PVP <const> = 22

local TabIndex_MapType_Map = {
	[TabIndex_PVE] = EMapType.PVE,
	[TabIndex_PVP] = EMapType.PVP
}

-- 优先级从高到低排列
local EPageTextType = {
	SkillDetails = 2,
	CustomPanel  = 1,
}

local function GetTabIndexByMapType(InMapType)
	for Index, MapType in pairs(TabIndex_MapType_Map) do
		if MapType == InMapType then
			return Index
		end
	end
	return 1
end



---@class SkillMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field BtnBlank UFButton
---@field BtnMask UFButton
---@field BtnSkillSetting CommBtnMView
---@field CloseBtn CommonCloseBtnView
---@field CommTabs CommTabsView
---@field CustomBtnPanel SkillCustomBtnPanelView
---@field DetailPanel UFCanvasPanel
---@field ImgMask UFImage
---@field InitiatPage UFCanvasPanel
---@field JobSkillDetailSlot UFCanvasPanel
---@field MapTypeTabs CommTabsView
---@field PassivePage_1 UFCanvasPanel
---@field SkillJobSkillSelectItem_UIBP SkillJobSkillSelectItemView
---@field SkillTouchEvent_UIBP SkillTouchEventView
---@field TableViewSkillDetails UTableView
---@field TableView_Passive UTableView
---@field UltimateAbility SkillUltimateAbilityItemView
---@field AnimIn UWidgetAnimation
---@field AnimJobSkillDetailIn UWidgetAnimation
---@field AnimSkillDetailIn UWidgetAnimation
---@field AnimSwitchTab UWidgetAnimation
---@field JobSkillDetailSize Vector2D
---@field JobSkillDetailPosition Vector2D
---@field SkillPanelOffset Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillMainPanelView = LuaClass(UIView, true)

function SkillMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.BtnBlank = nil
	--self.BtnMask = nil
	--self.BtnSkillSetting = nil
	--self.CloseBtn = nil
	--self.CommTabs = nil
	--self.CustomBtnPanel = nil
	--self.DetailPanel = nil
	--self.ImgMask = nil
	--self.InitiatPage = nil
	--self.JobSkillDetailSlot = nil
	--self.MapTypeTabs = nil
	--self.PassivePage_1 = nil
	--self.SkillJobSkillSelectItem_UIBP = nil
	--self.SkillTouchEvent_UIBP = nil
	--self.TableViewSkillDetails = nil
	--self.TableView_Passive = nil
	--self.UltimateAbility = nil
	--self.AnimIn = nil
	--self.AnimJobSkillDetailIn = nil
	--self.AnimSkillDetailIn = nil
	--self.AnimSwitchTab = nil
	--self.JobSkillDetailSize = nil
	--self.JobSkillDetailPosition = nil
	--self.SkillPanelOffset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.EquipmentMainVM = nil
end

function SkillMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	self:AddSubView(self.BtnSkillSetting)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.CustomBtnPanel)
	self:AddSubView(self.MapTypeTabs)
	self:AddSubView(self.SkillJobSkillSelectItem_UIBP)
	self:AddSubView(self.SkillTouchEvent_UIBP)
	self:AddSubView(self.UltimateAbility)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end


local OnTab1Change_common = nil
local OnTab3Change_common = nil
local OnTab2Change_common = nil

function SkillMainPanelView:OnInit()
	self.CommTabs.ParamShowRedDot = false  -- 手动控制显隐
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_Passive, nil, true)
	self.AdapterTableView:SetOnClickedCallback(self.OnPassiveTableViewClicked)
	self.AdapterSkillDetailsTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillDetails)
	self.SkillSystemVM = SkillSystemVM.New(self.InitiatPage, self)

	self.PageTextTypeTextMap = {}
end

function SkillMainPanelView:OnLoad()
	-- PVE/PVP文本
	local MapTypeTabs = self.MapTypeTabs
	local ListData = {
		{
			Name = LSTR(170110)  -- 常规
		},
		{
			Name = LSTR(170111)  -- 对战
		}

	}
	MapTypeTabs:UpdateItems(ListData)

	SkillSystemMgr:OnLoad()
	self.SkillSystemVM:OnInit()
end

function SkillMainPanelView:OnUnload()
	self.SkillSystemVM:OnShutdown()
	SkillSystemMgr:OnUnload()
end

function SkillMainPanelView:OnShow()
	local VM = self.SkillSystemVM
	rawset(VM, "SkillPanelOffset", self.SkillPanelOffset)
	local ProfID = self:GetSelectProf()
	local Params = self.Params
	local MapType = nil
	if Params and next(Params) then
		VM.IndependentView = Params.IndependentView
		MapType = Params.MapType
		if Params.IndependentView then
			UILevelMgr:SwitchLevelStreaming(false)
		end
	else
		VM.IndependentView = false
	end
	SkillSystemMgr:Enter(VM, ProfID, MapType)
	self.SkillSystemVM:OnBegin({
		ProfID,
		MajorUtil.GetMajorRaceID() or 0
	})
	_G.HUDMgr:SetIsDrawHUD(false)

	if self.CachedTabLabelList then
		VM.TabLabelList = nil
		VM.TabLabelList = self.CachedTabLabelList
	end

	self:RegisterMapTypeTabsRedDot()
	_G.EffectUtil.SetForceDisableCache(true)	--技能系统期间禁用特效缓存
end

function SkillMainPanelView:OnHide()
	self.SkillSystemVM:OnEnd()
	SkillSystemMgr:Leave()
	-- self.InitiatPage:ClearChildren()
	self.bMapTypeInited = false
	_G.HUDMgr:SetIsDrawHUD(true)
	self:UpdateMainDetail(false)
	self.ShadowedViewList = nil

	self.SkillTouchEvent_UIBP:Detach()

	if self.Params and self.Params.IndependentView then
		UILevelMgr:SwitchLevelStreaming(true)
	end

	table.clear(self.PageTextTypeTextMap)
	_G.EffectUtil.SetForceDisableCache(false)
end

function SkillMainPanelView:OnDestroy()
	local VM = self.SkillSystemVM
	if VM then
		local SubView = VM.SubView
		if SubView then
			_G.UIViewMgr:RecycleView(SubView)
			VM.SubView = nil
		end
	end
	rawset(VM, "ParentView", nil)
	self.SkillSystemVM = nil
end

function SkillMainPanelView:OnActive()
    self.SkillSystemVM:OnActive()
	SkillSystemMgr:ResetProfCamera()
end

function SkillMainPanelView:OnInactive()
    self.SkillSystemVM:OnInactive()
end

function SkillMainPanelView:OnRegisterUIEvent()
	-- UIUtil.AddOnStateChangedEvent(self, self.Tab_PVE, self.OnPVETabChange)
	-- UIUtil.AddOnStateChangedEvent(self, self.Tab_PVP, self.OnPVPTabChange)
	UIUtil.AddOnClickedEvent(self, self.BackBtn.Button, self.OnBackBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnBlank, self.OnBtnBlankClick)
	UIUtil.AddOnClickedEvent(self, self.BtnSkillSetting, self.OnBtnCustomClick)
	UIUtil.AddOnClickedEvent(self, self.BtnMask, self.OnBtnMaskClick)
	-- UIUtil.AddOnClickedEvent(self, self.UltimateAbility.Btn, self.OnLimitBtnClick)
	self.CommTabs:SetCallBack(self, self.OnCommTabIndexChanged)
	self.MapTypeTabs:SetCallBack(self, self.OnMapTypeChanged)
	self.CloseBtn:SetCallback(self, self.OnCloseBtnClicked)
end

function SkillMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PlayerPrepareCastSkill, self.OnPlayerPrepareCastSkill)
	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	--self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
	self:RegisterGameEvent(EventID.SkillStart, self.OnGameEventSkillStart)
	self:RegisterGameEvent(EventID.SkillEnd, self.OnGameEventSkillEnd)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	--self:RegisterGameEvent(_G.EventID.MonsterLoadAvatar, self.OnMonsterLoadAvatar)
	self:RegisterGameEvent(EventID.SkillSystemReplaceChange, self.OnSkillSystemReplaceChange)
	self:RegisterGameEvent(EventID.SkillSystemDetailsChange, self.OnSkillSystemDetailsChange)
	self:RegisterGameEvent(EventID.PreShowPersonInfo, self.OnPreShowPersonInfo)
	self:RegisterGameEvent(EventID.SkillSystemProfRedDotChange, self.OnSkillSystemProfRedDotChange)
	self:RegisterGameEvent(EventID.SkillEditingIndexSwap, self.OnCustomIndexChanged)
	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnAppEnterBackground)
	self:RegisterGameEvent(EventID.HideUI, self.OnViewHide)
end

function SkillMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "bShowDetail", UIBinderSetIsVisible.New(self, self.DetailPanel) },
		{ "bShowCloseButton", UIBinderSetIsVisible.New(self, self.CloseBtn) },
		{ "bShowSkillDetail", UIBinderSetIsVisible.New(self, self.TableViewSkillDetails, false, true) },
		{ "bShowSkillDetail", UIBinderValueChangedCallback.New(self, nil, self.OnShowSkillDetailChanged)},
		-- 1 - 主动技能面板; 2 - 被动技能面板; 3 - 额外技能面板
		{ "CurrentLabel", UIBinderValueChangedCallback.New(self, nil, self.OnCurrentLabelChanged) },
		{ "bInitiatTabVisible", UIBinderSetIsVisible.New(self, self.InitiatPage) },
		{ "bInitiatTabVisible", UIBinderValueChangedCallback.New(self, nil, self.OnInitiatTabVisibleChanged) },
		{ "bPassiveTabVisible", UIBinderSetIsVisible.New(self, self.PassivePage_1) },
		{ "bLimitSkillVisible", UIBinderSetIsVisible.New(self, self.UltimateAbility, false, true) },
		{ "PassiveSkillList", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },
		{ "SkillDetailsList", UIBinderUpdateBindableList.New(self, self.AdapterSkillDetailsTableView) },
		{ "JobSkillDetailData", UIBinderSetViewParams.New(self, self.SkillJobSkillSelectItem_UIBP) },
		{ "bShowSpectrum", UIBinderSetIsVisible.New(self, self.SkillJobSkillSelectItem_UIBP) },
		{ "SpectrumDetailWidget", UIBinderValueChangedCallback.New(self, nil, self.UpdateSpectrumDetail)},
		{ "bSpectrumSelected", UIBinderSetIsVisible.New(self, self.JobSkillDetailSlot)},
		{ "bShowDetail", UIBinderValueChangedCallback.New(self, nil, self.UpdateMainDetail)},
		{ "bSpectrumSelected", UIBinderValueChangedCallback.New(self, nil, self.OnSpectrumSelected)},
		{ "ProfFlags", UIBinderValueChangedCallback.New(self, nil, self.OnProfTypeChanged)},
		--{ "bMakeProf", UIBinderValueChangedCallback.New(self, nil, self.OnMakeProfChanged)},
		{ "CasterEntityID", UIBinderValueChangedCallback.New(self, nil, self.OnCasterChanged)},
		--{ "bMakeProf", UIBinderSetIsVisible.New(self, self.TypeToggleBtn, true) },
		{ "TabLabelList", UIBinderValueChangedCallback.New(self, nil, self.OnTabLabelListChanged) },
		{ "bShowMapTypeTabs", UIBinderSetIsVisible.New(self, self.MapTypeTabs) },
		{ "bShowCustomSkill", UIBinderSetIsVisible.New(self, self.BtnSkillSetting, false, true) },
		{ "bInCustomSkillState", UIBinderValueChangedCallback.New(self, nil, self.OnCustomSkillStateChanged) },
		{ "CustomBtnText", UIBinderSetText.New(self, self.BtnSkillSetting) },
	}

	self:RegisterBinders(self.SkillSystemVM, Binders)
end

function SkillMainPanelView:PreInitTab()
	local VM = self.SkillSystemVM
	if VM then
		VM.bShowCustomSkill = false
	end
end

function SkillMainPanelView:OnCommTabIndexChanged(Index)
	self.CommTabSelectedIndex = Index
	self:PlayAnimation(self.AnimSwitchTab)
	self:PreInitTab()
	if Index == 1 then
		self:OnInitiatTabChange()
	elseif Index == 3 then
		self:OnPassiveTabChange()
	elseif Index == 2 then
		self:OnExtraTabChange()
	end
end

function SkillMainPanelView:ResetMapTypeTabs()
	self.bMapTypeInited = false
	self.MapTypeTabs:SetSelectedIndex(TabIndex_PVE)
	self.bMapTypeInited = true
end

function SkillMainPanelView:OnMapTypeChanged(Index)
	local VM = self.SkillSystemVM
	if not self.bMapTypeInited or not VM then
		return
	end

	if Index == TabIndex_PVP then
		local ProfID = VM.ProfID  -- ProfUtil.GetAdvancedProf(VM.ProfID)
		local bSupportPVP = ProfMgr.CheckProfClass(ProfID, ProfClassType_PVP)
		if not bSupportPVP then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.ProfPVPUnable)
			self:RegisterTimer(self.ResetMapTypeTabs, 0, 0, 1)
			return
		end
	end

	local Params = self.Params
	Params.MapType = TabIndex_MapType_Map[Index]

	self:OnBackBtnClick()
	self:HideView(nil, true)
	self:ShowView(Params)
end

function SkillMainPanelView:InitMapTypeSelectedIndex()
	if _G.DemoMajorType == 1 then
		return
	end
	local MapType = SkillSystemMgr:GetCurrentMapType()
	local TabIndex = GetTabIndexByMapType(MapType)
	self.MapTypeTabs:SetSelectedIndex(TabIndex)
	self.bMapTypeInited = true
end

function SkillMainPanelView:OnCasterChanged(CasterEntityID)
	-- 策划不希望角色能够拖动
end

function SkillMainPanelView:OnGameEventVisionEnter(Params)
	-- VisionEnter事件是Post的, 这里加上保护性的判断
	if SkillSystemMgr.bIsActive then
		self.SkillSystemVM:OnGameEventVisionEnter(Params)
	end
end

function SkillMainPanelView:OnGameEventVisionLeave(Params)

end

function SkillMainPanelView:OnAssembleAllEnd(Params)
	self.SkillSystemVM:OnAssembleAllEnd(Params)
end

function SkillMainPanelView:OnMonsterLoadAvatar(Params)
	self.SkillSystemVM:OnMonsterLoadAvatar(Params)
end

function SkillMainPanelView:OnGameEventSkillStart(Params)
	local VM = self.SkillSystemVM
	if not VM then
		return
	end

	if VM.CasterEntityID == Params.ULongParam1 then
		VM:OnGameEventSkillStart(Params)
		local NewMainSkill = VM.SubView
		if not NewMainSkill then
			return
		end
		if NewMainSkill.AdapterSimulateReplace then
			NewMainSkill.AdapterSimulateReplace:CancelSelected()
		end
	end
end

function SkillMainPanelView:OnGameEventSkillEnd(Params)
	local EntityID = Params.ULongParam1
	self.SkillSystemVM:OnGameEventSkillEnd(Params)
end

function SkillMainPanelView:GetSelectProf()
	local ProfID = _G.EquipmentMgr:GetPreviewProfID()
	if ProfID then
		return ProfID
	end
	return MajorUtil.GetMajorProfID()
end

function SkillMainPanelView:OnSelectedProfChange(NewProfID)
	-- self.SkillSystemVM:OnSelectedProfChange(NewProfID)
	-- self.AdapterTableView:CancelSelected()
	local Params = self.Params
	self:HideView(nil, true)
	Params.MapType = nil
	self:ShowView(Params)
end

function SkillMainPanelView:UpdateMainDetail(bVisible, OldValue)
	if self.EquipmentMainView then
		if bVisible then
			self.EquipmentMainView:PlayAnimation(self.EquipmentMainView.AnimLeftOut)
		elseif nil ~= OldValue then
			self.EquipmentMainView:PlayAnimation(self.EquipmentMainView.AnimLeftIn)
		end
	end
	if bVisible == false then
		self:SetPageText(false, EPageTextType.SkillDetails)
	end
	UIUtil.SetIsVisible(self.BackBtn, bVisible, true)
end

local ReplaceShadowMap <const> = SkillSystemConfig.ReplaceShadowMap
local ReplaceShadowOpacity <const> = 0.2
function SkillMainPanelView:SetReplaceShadow(Index, bEnable)
	if not bEnable then
		local ShadowedViewList = self.ShadowedViewList
		if not ShadowedViewList then
			return
		end
		for _, View in pairs(ShadowedViewList) do
			View:SetRenderOpacity(1)
		end
		self.ShadowedViewList = nil
	else
		if self.ShadowedViewList then
			self:SetReplaceShadow(nil ,false)
		end

		local ViewPathList = ReplaceShadowMap[Index or 0]
		if not ViewPathList then
			return
		end

		local RootView = {
			SkillMainPanel = self,
			NewMainSkill = self.SkillSystemVM.SubView,
		}
		local ShadowedViewList = {}

		for i = 1, #ViewPathList do
			local CurView = RootView
			for ViewName in string.gmatch(ViewPathList[i], "([^.]+)") do
				CurView = CurView[ViewName]
				if not CurView then
					break
				end
			end

			if CurView then
				CurView:SetRenderOpacity(ReplaceShadowOpacity)
				table.insert(ShadowedViewList, CurView)
			end
		end
		self.ShadowedViewList = ShadowedViewList
	end
end

function SkillMainPanelView:OnPlayerPrepareCastSkill(Params)
	local Index = Params.Index
	-- self:SetReplaceShadow(Index, false)
	--用于清除状态，不处理逻辑
	if Index == -1 then
		return
	end
	local SkillID = Params.SkillID
	local VM = self.SkillSystemVM
	if not VM then
		return
	end
	VM:SetSkillDetailVisible(true, SkillID, Index, false, false, Params.bShowMultiSkill)
end

function SkillMainPanelView:OnPVETabChange()
	local bCheck = self.Tab_PVE:GetIsChecked()
	self.Tab_PVP:SetChecked(not bCheck, false)
	self.SkillSystemVM:PostSkillListChange(self:GetSelectProf(), true)
end

function SkillMainPanelView:OnPVPTabChange()
	local bCheck = self.Tab_PVP:GetIsChecked()
	self.Tab_PVE:SetChecked(not bCheck, false)
	self.SkillSystemVM:PostSkillListChange(self:GetSelectProf(), false)
end

function SkillMainPanelView:OnBackBtnClick()
	self:FoldUpChildPanels()
end

function SkillMainPanelView:FoldUpChildPanels()
	local VM = self.SkillSystemVM
	VM:SetDetailVisible(false)
	VM:ClearSkillSelectedStatus()
	VM:HideMultiChoicePanel()
	SkillSystemMgr:PreLeave()
	EventMgr:SendEvent(EventID.SkillSystemClickBlank)
	-- _G.EventMgr:SendEvent(EventID.ExitDemoSkill)
	-- --todo	--这里最好改成事件的形式
end

function SkillMainPanelView:OnBtnBlankClick()
	EventMgr:PostEvent(EventID.SkillSystemClickBlank)
end

function SkillMainPanelView:OnCloseBtnClicked()
	local VM = self.SkillSystemVM
	local OnCloseBtnClicked_Root = function()
		local ParentView = self.ParentView
		if not ParentView then
			if VM.IndependentView then
				self:Hide()
			else
				FLOG_ERROR("[SkillCustom] Try to close but ParentView is nil.")
			end	
			return
		end
		-- ParentView:Hide()
		self:OnBtnCustomClick(true)
	end

	local VM = self.SkillSystemVM
	if not VM or not VM.bInCustomSkillState or not self.bAnyCustomIndexChanged then
		OnCloseBtnClicked_Root()
		return
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(
		self,
		LSTR(170108),  -- "退出设置"
		LSTR(170107),  -- "是否保存"
		function()
			self:SaveCustomSkillSettings()
			OnCloseBtnClicked_Root()
		end,
		OnCloseBtnClicked_Root,
		LSTR(1240008),  -- "不保存"
		LSTR(1240007)   -- "保存"
	)
end

function SkillMainPanelView:SaveCustomSkillSettings()
	if self.bAnyCustomIndexChanged then
		FLOG_INFO("SaveCustomSkillSettings...")
		SkillCustomMgr:SaveEditingIndexMap()
		SkillLogicMgr:ReqSkillList()
	end
end

function SkillMainPanelView:OnCustomSkillStateChanged(bInCustomSkillState, bLastState)
	if bInCustomSkillState == nil then
		return
	end

	local VM = self.SkillSystemVM
	if not VM then
		return
	end

	self:FoldUpChildPanels()
	self.bAnyCustomIndexChanged = false
	self.BtnSkillSetting:UpdateImage(CommBtnColorType.Normal)

	UIUtil.SetIsVisible(self.ImgMask, bInCustomSkillState)
	UIUtil.SetIsVisible(self.BtnMask, bInCustomSkillState, true)
	UIUtil.SetIsVisible(self.CustomBtnPanel, bInCustomSkillState)
	if bInCustomSkillState then
		self:SetPageText(true, EPageTextType.CustomPanel, LSTR(170114))  -- "技能编辑"
		VM.CustomBtnText = LSTR(TextID_LeaveCustomSkill)
		self.CustomBtnPanel:Init(VM.CasterEntityID, SkillSystemMgr:GetCurrentMapType())
	else
		self:SetPageText(false, EPageTextType.CustomPanel)
		VM.CustomBtnText = LSTR(TextID_EnterCustomSkill)
	end

	if not VM.IndependentView then
		VM.bShowCloseButton = bInCustomSkillState
	end	

	local NewMainSkill = VM.SubView
	if NewMainSkill and NewMainSkill.bSubViewReady then
		UIUtil.SetIsVisible(NewMainSkill, not bInCustomSkillState)
	end
end

function SkillMainPanelView:OnCustomIndexChanged()
	if not self.bAnyCustomIndexChanged then
		self.bAnyCustomIndexChanged = true
		self.BtnSkillSetting:SetText(LSTR(TextID_SaveCustomSkill))
		self.BtnSkillSetting:UpdateImage(CommBtnColorType.Recommend)
	end
end

function SkillMainPanelView:OnBtnCustomClick(bNotSave)
	local VM = self.SkillSystemVM
	local StateComp = MajorUtil.GetMajorStateComponent()
	if not VM or not StateComp then
		return
	end

	local bState = not VM.bInCustomSkillState
	if bState == false then  -- 保存状态
		if bNotSave ~= true then
			self:SaveCustomSkillSettings()
		end
	else  -- 进入状态
		if StateComp:IsInCombatNetState() then
			-- 战斗状态不允许进入自定义模式
			MsgTipsUtil.ShowTipsByID(TipsID_DisableCombatCustom)
			return
		end

		-- 有按下的技能时, 不能进入设置态, 避免NewMainSkill中的View不响应Up事件
		if SkillSystemMgr.PressedButtonIndex then
			return
		end
	end

	VM.bInCustomSkillState = bState
end

function SkillMainPanelView:OnBtnMaskClick()
	local VM = self.SkillSystemVM
	VM:SetDetailVisible(false)
	EventMgr:SendEvent(EventID.SkillCustomUnselected)
end

local LimitSkill3Index = SkillCommonDefine.SkillButtonIndexRange.Limit_End + 1  -- 3档极限技在SkillList中的下标

function SkillMainPanelView:OnLimitBtnClick()
	local ProfID = self:GetSelectProf()
	-- # TODO - 如果支持PVP, 这里需要修改
	local BaseSkillList = SkillUtil.GetSkillList(SkillUtil.MapType.PVE, ProfID)
	if BaseSkillList then
		local LimitSkill3ID = BaseSkillList.SkillList[LimitSkill3Index].ID
		if LimitSkill3ID > 0 then
			local VM = self.SkillSystemVM
			VM:SetSkillDetailVisible(true, LimitSkill3ID, LimitSkill3Index, false, true)
			local bJoyStick = SkillMainCfg:FindValue(LimitSkill3ID, "IsEnableSkillJoyStick")
			SkillUtil.PlayerCastSkillFinal(VM.CasterEntityID, nil, LimitSkill3ID, LimitSkill3ID, LimitSkill3Index, bJoyStick)
		end
	end
end

function SkillMainPanelView:OnInitiatTabChange()
	if OnTab1Change_common then
		OnTab1Change_common(self)
	end
end

function SkillMainPanelView:OnPassiveTabChange()
	if OnTab3Change_common then
		OnTab3Change_common(self)
	end
end

function SkillMainPanelView:OnExtraTabChange()
	if OnTab2Change_common then
		OnTab2Change_common(self)
	end
end

function SkillMainPanelView:OnPassiveTableViewClicked(Index, ItemData, _)
	local bPassiveSkill = self.SkillSystemVM:IsCurrentLabelPassive()
	self.SkillSystemVM:SetSkillDetailVisible(true, ItemData.SkillID, Index, bPassiveSkill, false)
end


function SkillMainPanelView:UpdateSpectrumDetail(Widget)
	self.JobSkillDetailSlot:ClearChildren()
	if Widget then
		self.JobSkillDetailSlot:AddChildToCanvas(Widget)
		local JobSkillDetailPosition = self.JobSkillDetailPosition:Copy()
		if not self.bCombat then
			JobSkillDetailPosition.Y = JobSkillDetailPosition.Y + 100
		end
		UIUtil.CanvasSlotSetSize(Widget, self.JobSkillDetailSize)
		UIUtil.CanvasSlotSetPosition(Widget, JobSkillDetailPosition)
		Widget:ShowView()
	else
		-- local TextBlock = _G.NewObject(_G.UE.UFTextBlock.StaticClass(), self)
		-- TextBlock:SetText(LSTR("配置错了吧小伙子，快去SkillSystemConfig（DataAsset）里看看吧"))
		-- self.JobSkillDetailSlot:AddChildToCanvas(TextBlock)
	end
end

function SkillMainPanelView:OnSpectrumSelected(bSelected)
	self:PlayAnimation(self.AnimJobSkillDetailIn)
	if bSelected then
		self.AdapterTableView:CancelSelected()
		local ProfFlags = self.SkillSystemVM.ProfFlags
		if ProfFlags.bCombatProf then
			self:SetPageText(true, EPageTextType.SkillDetails, LSTR(170100))  -- "量谱详情"
		elseif ProfFlags.bMakeProf then
			self:SetPageText(true, EPageTextType.SkillDetails, LSTR(170112))  -- "特征值详情"
		elseif ProfFlags.bProductionProf then
			self:SetPageText(true, EPageTextType.SkillDetails, LSTR(170113))  -- "技能效果详情"
		else
			FLOG_ERROR("[SkillMainPanelView:OnSpectrumSelected] Cannot find proper text.")
		end
	end
end

local function SetSkillExpandPos(AnchorWidget, SkillExpand)
	local WidgetSize = UIUtil.CanvasSlotGetSize(AnchorWidget)
	local Pos = UIUtil.CanvasSlotGetPosition(AnchorWidget)

	Pos.X = Pos.X + WidgetSize.X / 2
	Pos.Y = Pos.Y + WidgetSize.Y

	UIUtil.CanvasSlotSetPosition(SkillExpand, Pos)
end

function SkillMainPanelView:OnSkillSystemReplaceChange(Params)
	local ButtonIndex = Params.ButtonIndex
	local bShow = Params.bShow
	self:SetReplaceShadow(Params.OriginalButtonIndex, bShow)

	if not Params.bTableView then
		return
	end
	local VM = self.SkillSystemVM
	if not VM then
		return
	end

	---@type NewMainSkillView
	local NewMainSkill = VM.SubView
	if not NewMainSkill then
		return
	end
	---@type SkillExpandItemView
	local SkillExpand = NewMainSkill.SkillExpand
	if not SkillExpand then
		return
	end

	local ButtonView = NewMainSkill.SkillSystemMap[ButtonIndex]
	if ButtonView and bShow then
		SetSkillExpandPos(ButtonView, SkillExpand)
	end
	UIUtil.SetIsVisible(SkillExpand, bShow)

	local SimulateReplaceList = NewMainSkill.SimulateReplaceList
	if bShow and SimulateReplaceList then
		SkillExpand.ButtonIndex = ButtonIndex
		SimulateReplaceList:Clear()
		local SkillList = _G.SkillLogicMgr:GetPlayerSeriesList(VM.CasterEntityID, ButtonIndex)
		for _, SkillID in ipairs(SkillList) do
			SimulateReplaceList:AddByValue(SkillID)
		end
	elseif NewMainSkill.AdapterSimulateReplace then
		NewMainSkill.AdapterSimulateReplace:CancelSelected()
	end
end

function SkillMainPanelView:OnSkillSystemDetailsChange(Params)
	local ButtonIndex = Params.ButtonIndex
	local VM = self.SkillSystemVM
	if VM then
		VM:SetSkillDetailVisible(true, Params.SkillID, ButtonIndex, false, false)

		_G.EventMgr:SendEvent(EventID.SkillSystemUnselectButton, ButtonIndex)
	end
end

function SkillMainPanelView:OnPreShowPersonInfo()
	SkillSystemMgr:ClearAllSkillSystemEffectWithoutFade()
end

function SkillMainPanelView:OnProfTypeChanged(NewValue, _)
	if NewValue == nil then return end
	local bProductionProf = NewValue.bProductionProf    --大地使者
    local bMakeProf = NewValue.bMakeProf     --能工巧匠
	local ProfID = NewValue.ProfID

	local bCombat = not bMakeProf and not bProductionProf
	self.bCombat = bCombat

	if bCombat then
		OnTab1Change_common = self.OnInitiatTabChange_Combat
		if SkillSystemMgr:IsCurrentMapPVE() then
			OnTab3Change_common = self.OnExtraTabChange_Combat
		else
			OnTab3Change_common = self.OnPassiveTabChange_Combat
		end
		OnTab2Change_common = self.OnPassiveTabChange_Combat
		UIUtil.SetIsVisible(self.SkillTouchEvent_UIBP, false)

		self:InitMapTypeSelectedIndex()
	else
		OnTab1Change_common = self.OnInitiatTabChange_MakeProf
		OnTab3Change_common = self.OnExtraTabChange_MakeProf
		OnTab2Change_common = self.OnPassiveTabChange_MakeProf
		UIUtil.SetIsVisible(self.SkillTouchEvent_UIBP, true, true)

		local VM = self.SkillSystemVM
		if VM then
			VM.bShowMapTypeTabs = false
		end
	end

	-- if bMakeProf then
	-- 	OnInitiatTabChange_common = self.OnInitiatTabChange_MakeProf
	-- 	OnPassiveTabChange_common = self.OnPassiveTabChange_MakeProf
	-- elseif bProductionProf then	--大地使者也用这套
	-- 	OnInitiatTabChange_common = self.OnInitiatTabChange_MakeProf
	-- 	OnPassiveTabChange_common = self.OnPassiveTabChange_MakeProf
	-- else
	-- 	OnInitiatTabChange_common = self.OnInitiatTabChange_Combat
	-- 	OnPassiveTabChange_common = self.OnPassiveTabChange_Combat
	-- end

	self.CommTabs:SetSelectedIndex(1)
end

function SkillMainPanelView:OnShowSkillDetailChanged(bShow)
	self:PlayAnimation(self.AnimSkillDetailIn)
	if bShow then
		self:SetPageText(true,  EPageTextType.SkillDetails, _G.LSTR(170101))  -- 技能详情
	end
end

function SkillMainPanelView:SetPageText(bVisible, Type, InText)
	local PageTextTypeTextMap = self.PageTextTypeTextMap
	PageTextTypeTextMap[Type] = bVisible and InText or nil

	local CurPriority = 0
	local CurText = nil
	for Priority, Text in pairs(PageTextTypeTextMap) do
		if CurPriority < Priority then
			CurPriority = Priority
			CurText = Text			
		end
	end

	if self.EquipmentMainVM then
		self.EquipmentMainVM.bHasSubtitle = CurText and true or false
		if CurText then
			self.EquipmentMainVM.Subtitle = CurText
		end
	end
end

local CommTabItemStructPath = "/Game/UI/BP/Common/Tab/CommTabItem.CommTabItem"

local CommTabIndexRedDotMap = {
	"RedDotSlot", "RedDotSlot2", "RedDotSlot3"
}

local LocalStrID = require("Game/Skill/SkillSystem/SkillSystemConfig").LocalStrID
local LstrActive = _G.LSTR(LocalStrID.Active)
local LstrPassive = _G.LSTR(LocalStrID.Passive)
local SkillSystemRedDotNode = require("Game/Skill/SkillSystem/SkillSystemRedDotNode")
local SkillSystemRedDotUtil = require("Game/Skill/SkillSystem/SkillSystemRedDotUtil")
local ENodeType = SkillSystemRedDotNode.ENodeType
local ETabType = SkillSystemRedDotNode.ETabType

function SkillMainPanelView:OnTabLabelListChanged(TabLabelList, _)
	if not SkillSystemMgr.bIsActive then
		self.CachedTabLabelList = TabLabelList
		return
	end
	if not TabLabelList then
		return
	end

	self.CachedTabLabelList = nil
	local CommTabs = self.CommTabs

	local ListData = {}
	for Index, TabLabel in pairs(TabLabelList) do
		local CommTabItem = {}
		CommTabItem.Name = TabLabel
		table.insert(ListData, CommTabItem)

		local RedDotSlot = CommTabs[CommTabIndexRedDotMap[Index]]
		if TabLabel == LstrActive then
			SkillSystemMgr:RegisterRedDotWidget(ENodeType.Tab, ETabType.Active, RedDotSlot)
		elseif TabLabel == LstrPassive then
			SkillSystemMgr:RegisterRedDotWidget(ENodeType.Tab, ETabType.Passive, RedDotSlot)
		end
	end

	CommTabs:UpdateItems(ListData)

	local FVector2D = _G.UE.FVector2D
	if #TabLabelList == 3 then
		UIUtil.CanvasSlotSetSize(CommTabs, FVector2D(458, 68))
	else
		UIUtil.CanvasSlotSetSize(CommTabs, FVector2D(308, 68))
	end
end

--登录演示场景需支持断线重连
--暂时先这么写，等以后有了好方法再改吧
function SkillMainPanelView:LoginDemoSkillReConnect()
	--手动调用隐藏和显示，完整走一遍技能系统流程
	UIUtil.SetIsVisible(self, false)
	local VM = self.SkillSystemVM
	if VM then
		--存在第三种情况，技能系统实体存在，但因断线重连还未被视野模块创建
		--此时既不能直接获取实体，又不需要向后台请求实体创建，因此此处改成-1，后续逻辑走进入视野事件
		if VM.DelayToHideEntity > 0 then
			TimerMgr:CancelTimer(VM.DelayToHideEntity)
			VM.DelayToHideEntity = -1
		end
	end
	UIUtil.SetIsVisible(self, true)
end

local CombatLabelVisibleMap = {
	[LocalStrID.Active] = { true,  false, false },
	[LocalStrID.Passive] = { false, true,  false },
	[LocalStrID.LimitSkill]   = { false, false, true },
}

function SkillMainPanelView:OnCurrentLabelChanged(CurrentLabel)
	local VM = self.SkillSystemVM
	if not VM or not VM.ProfFlags or CurrentLabel == 0 then
		return
	end
	local bCombatProf = VM.ProfFlags.bCombatProf
	if bCombatProf then
		VM.bInitiatTabVisible, VM.bPassiveTabVisible, VM.bLimitSkillVisible =
			table.unpack(CombatLabelVisibleMap[CurrentLabel])
	else
		VM.bInitiatTabVisible, VM.bPassiveTabVisible, VM.bLimitSkillVisible = false, true, false
	end
end

function SkillMainPanelView:OnInitiatTabVisibleChanged(bVisible)
	-- 清理Chant残留
	local VM = self.SkillSystemVM
	if not bVisible or not VM then
		return
	end
	local View = VM.SubView
	if View then
		View.Chant:Clear()
	end
end

-- 目前PVP没红点, 虽然红点树有预留PVP相关逻辑, 下面这块的显隐都是只考虑PVE那个Tab的
function SkillMainPanelView:RegisterMapTypeTabsRedDot()
	local RedDotSlot = self.MapTypeTabs[CommTabIndexRedDotMap[GetTabIndexByMapType(EMapType.PVE)]]
	-- SkillSystemMgr:RegisterRedDotWidget(ENodeType.Label, 0, RedDotSlot)
	local RedDotNum = SkillSystemRedDotUtil.GetRedDotNum(EMapType.PVE, SkillSystemMgr.ProfID)
	RedDotSlot:SetRedDotNumByNumber(RedDotNum)
	UIUtil.SetIsVisible(RedDotSlot, RedDotNum > 0)
end

function SkillMainPanelView:OnSkillSystemProfRedDotChange(Params)
	local RedDotSlot = self.MapTypeTabs[CommTabIndexRedDotMap[GetTabIndexByMapType(EMapType.PVE)]]
	UIUtil.SetIsVisible(RedDotSlot,Params.bRedDotVisible)
end

function SkillMainPanelView:OnAppEnterBackground()
	SkillSystemMgr:ClearAllSkillSystemEffectWithoutFade()
end

function SkillMainPanelView:OnViewHide(ViewID)
	-- 解决OnActive 1帧延迟的问题, 暂时没有比较优雅的办法
	if (ViewID == UIViewID.PersonInfoMainPanel or ViewID == UIViewID.CurrencySummary) and self.SkillSystemVM then
		self.SkillSystemVM:OnActive()
	end
end

------------------------------战斗职业-----------------------------------------
function SkillMainPanelView:OnInitiatTabChange_Combat()
	local VM = self.SkillSystemVM
	VM.CurrentLabel = LocalStrID.Active

	local IndependentView = false
	local Params = self.Params
	if Params then
		IndependentView = Params.IndependentView
	end

	local ProfID = VM.ProfID
	local ProfUnlocked = true
	local MajorRoleDetail = ActorMgr:GetMajorRoleDetail()
	if ProfID and (nil == MajorRoleDetail or nil == MajorRoleDetail.Prof.ProfList[ProfID]) then
		ProfUnlocked = false
	end
	if DemoMajorType == 0 and not IndependentView and ProfUnlocked then
		VM.bShowCustomSkill = true
	end
	VM.bInCustomSkillState = false
	self.AdapterTableView:CancelSelected()
end

function SkillMainPanelView:OnPassiveTabChange_Combat()
	self.SkillSystemVM:ClearSkillSelectedStatus()
	self.SkillSystemVM.CurrentLabel = LocalStrID.Passive
end

function SkillMainPanelView:OnExtraTabChange_Combat()
	self.SkillSystemVM:ClearSkillSelectedStatus()
	self.SkillSystemVM.CurrentLabel = LocalStrID.LimitSkill
end

------------------------------能工巧匠-----------------------------------------
function SkillMainPanelView:OnInitiatTabChange_MakeProf()
	self.AdapterTableView:CancelSelected()
	self.SkillSystemVM:SwitchSkillPage_MakeProf(1)
end

function SkillMainPanelView:OnPassiveTabChange_MakeProf()
	self.AdapterTableView:CancelSelected()
	self.SkillSystemVM:SwitchSkillPage_MakeProf(2)
end

function SkillMainPanelView:OnExtraTabChange_MakeProf()
	self.AdapterTableView:CancelSelected()
	self.SkillSystemVM:SwitchSkillPage_MakeProf(3)
end

return SkillMainPanelView
--
-- Author: anypkvcai
-- Date: 2020-09-12 16:00:08
-- Description:
--

--chaooren 2021-02-23 Buff显示

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIViewID = require("Define/UIViewID")

-- local AdjustValue = 0.5
local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ScoreMgr = require("Game/Score/ScoreMgr")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local LevelExpCfgList = LevelExpCfg:FindAllCfg("true")

local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local UIAdapterTableViewEx = require("Game/Buff/UIAdapterTableViewEx")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

local HPBarLikeAnimProxyFactory = require("Game/Main/HPBarLikeAnimProxyFactory")
local ProSkillDefine = require("Game/Main/ProSkill/ProSkillDefine")
local ProSkillUtil = require("Utils/ProSkillUtil")
local SkillUtil = require("Utils/SkillUtil")

local MainProSkillMgr = _G.MainProSkillMgr ---@type MainProSkillMgr

local MajorMPBarConfig =
{
	MP = { FillImage = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Major_Bar_MP_png.UI_Main_Major_Bar_MP_png'" },
	MK = { FillImage = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Major_Bar_CP_png.UI_Main_Major_Bar_CP_png'" },
	GP = { FillImage = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Major_Bar_PP_png.UI_Main_Major_Bar_PP_png'" },
	LB = { FillImage = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Major_Bar_PP_png.UI_Main_Major_Bar_PP_png'" },
	LB_Full = { FillImage = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Major_Bar_Limit_png.UI_Main_Major_Bar_Limit_png'" },
}

---@class MainMajorInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuffMore UFButton
---@field BtnSwitch UFButton
---@field BuffMore UFCanvasPanel
---@field BuffPanel UFCanvasPanel
---@field EFF_Glow_046 UFImage
---@field EFF_ProBarHP_Blue UFImage
---@field EFF_ProBarHP_Yellow UFImage
---@field EFF_ProBarMP_Blue UFImage
---@field EFF_ProBarMP_Yellow UFImage
---@field ImgSwitch UFImage
---@field LBYellowPower UFImage
---@field MajorBuff MainBuffPanelView
---@field PlayerExp UFCanvasPanel
---@field PlayerInfo UFCanvasPanel
---@field PlayerJobSlot CommPlayerJobSlotView
---@field ProBarExp UProgressBar
---@field ProBarHP UProgressBar
---@field ProBarMP UProgressBar
---@field TableViewBuff UTableView
---@field TextBuffMore UFTextBlock
---@field TextHP UFTextBlock
---@field TextMP UFTextBlock
---@field AnimHPBlue UWidgetAnimation
---@field AnimHPYellow UWidgetAnimation
---@field AnimMPBlue UWidgetAnimation
---@field AnimMPYellow UWidgetAnimation
---@field AnimPlayerExpLightAdd UWidgetAnimation
---@field AnimPlayerExpLightSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainMajorInfoPanelView = LuaClass(UIView, true)

function MainMajorInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuffMore = nil
	--self.BtnSwitch = nil
	--self.BuffMore = nil
	--self.BuffPanel = nil
	--self.EFF_Glow_046 = nil
	--self.EFF_ProBarHP_Blue = nil
	--self.EFF_ProBarHP_Yellow = nil
	--self.EFF_ProBarMP_Blue = nil
	--self.EFF_ProBarMP_Yellow = nil
	--self.ImgSwitch = nil
	--self.LBYellowPower = nil
	--self.MajorBuff = nil
	--self.PlayerExp = nil
	--self.PlayerInfo = nil
	--self.PlayerJobSlot = nil
	--self.ProBarExp = nil
	--self.ProBarHP = nil
	--self.ProBarMP = nil
	--self.TableViewBuff = nil
	--self.TextBuffMore = nil
	--self.TextHP = nil
	--self.TextMP = nil
	--self.AnimHPBlue = nil
	--self.AnimHPYellow = nil
	--self.AnimMPBlue = nil
	--self.AnimMPYellow = nil
	--self.AnimPlayerExpLightAdd = nil
	--self.AnimPlayerExpLightSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainMajorInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MajorBuff)
	self:AddSubView(self.PlayerJobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainMajorInfoPanelView:OnInit()
	self.TextBuffMore:SetText("...")

	self.HpBarAnimProxy = HPBarLikeAnimProxyFactory.CreateMatProxy(self, self.ProBarHP, self.AnimHPBlue, self.AnimHPYellow, 
		self.EFF_ProBarHP_Blue, self.EFF_ProBarHP_Yellow)
	self.MpBarAnimProxy = HPBarLikeAnimProxyFactory.CreateMatProxy(self, self.ProBarMP, self.AnimMPBlue, self.AnimMPYellow, 
		self.EFF_ProBarMP_Blue, self.EFF_ProBarMP_Yellow)

	self.ExpBarAnimProxy = HPBarLikeAnimProxyFactory.CreateExpProxy(self, self.ProBarExp, self.AnimPlayerExpLightAdd, self.AnimPlayerExpLightSubtract, 
		self.EFF_Glow_046, self.EFF_Glow_046)

    self.AdapterBuff = UIAdapterTableViewEx.CreateAdapter(self, self.TableViewBuff, self.OnBuffSelect, true)
	self.AdapterBuff:UpdateSettings(10, function(_, IsLimited) UIUtil.SetIsVisible(self.BuffMore, IsLimited) end, false)

	self.AdapterBuffDetails = UIAdapterTableViewEx.CreateAdapter(self, self.MajorBuff.MainBuffTips.TableViewBuff, self.OnBuffDetailsSelect, true)
	self.AdapterBuffDetails:UpdateSettings(999, function(IsEmpty, _) if IsEmpty then self:HideBuffDetails() end end, true)

	self.MajorRoleVM = nil
	self.MajorActorVM = nil

	self.RoleBinders = {
		{ "PWorldLevel", 		UIBinderSetText.New(self, self.PlayerJobSlot.Text_PlayerLevel) },
		{ "Prof", 				UIBinderSetProfIcon.New(self, self.PlayerJobSlot.Icon_Prof) },
		{ "BtnSwitchVisible",   UIBinderSetIsVisible.New(self, self.BtnSwitch, nil, true)},
	}

	self.ActorBinders = {
		{ "CurHP", 				UIBinderValueChangedCallback.New(self, nil, self.OnMajorHPChange) },
		{ "MaxHP", 				UIBinderValueChangedCallback.New(self, nil, self.OnMajorHPChange) },

		{ "CurMP", 				UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorMP) },
		{ "MaxMP", 				UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorMP) },

		{ "CurGP", 				UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorGP) },
		{ "MaxGP", 				UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorGP) },

		{ "CurMK", 				UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorMK) },
		{ "MaxMK", 				UIBinderValueChangedCallback.New(self, nil, self.UpdateMajorMK) },

		{ "BufferVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterBuff) },
		{ "BufferVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterBuffDetails) },
	}

	-- self.BuffBinders = {
	-- 	{ "BuffList", 						UIBinderUpdateBindableList.New(self, self.TableViewAdapterBuff) },
	-- 	{ "IsMajorBuffDetailVisiable", 	UIBinderSetIsVisible.New(self, self.MajorBuff.MainBuffTips)},
	-- 	{ "IsMajorBuffDetailVisiable", 	UIBinderSetIsVisible.New(self, self.BuffPanel, true)},
	-- 	{ "MainSelectedIdx",            UIBinderSetSelectedIndex.New(self, self.TableViewAdapterBuff)},
	-- }
end

function MainMajorInfoPanelView:OnDestroy()
end

---CurrIsInPVPWorld loiafeng: 临时判断
local function CurrIsInPVPWorld()
	return _G.PWorldMgr:CurrIsInPVPColosseum() or _G.PWorldMgr:CurrIsWolvesDenPierStage()
end

function MainMajorInfoPanelView:OnShow()
	UIUtil.SetIsVisible(self.MajorBuff, true)
	UIUtil.SetIsVisible(self.MajorBuff.MainBuffTips, true)
	self:HideBuffDetails()

	self:UpdateMajorExp()
	if CurrIsInPVPWorld() then
		-- PVP 场景需要在这里初始化一下
		self:InitMajorMPBar()
	end
end

function MainMajorInfoPanelView:OnHide()
	self:HideBuffDetails()
	self.MajorRoleVM = nil
	self.MajorActorVM = nil
end

function MainMajorInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBuffMore, function()
		-- MajorBuffVM:SetMainSelectedIdx(MajorBuffVM:GetBuffLen())
		-- MajorBuffVM:SetIsMajorBuffDetailVisiable(true)
		self.AdapterBuff:SelectLastItem()
	end)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.OnSwitchClicked)
end

function MainMajorInfoPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MajorExpUpdate, self.UpdateMajorExp)
    self:RegisterGameEvent(_G.EventID.ActorVMCreate, self.OnGameEventActorVMCreate)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.InitMajorMPBar)
	self:RegisterGameEvent(_G.EventID.SkillSpectrumUpdate, self.OnGameEventSkillSpectrumUpdate)
end

function MainMajorInfoPanelView:OnRegisterTimer()

end

function MainMajorInfoPanelView:OnRegisterBinder()
	self.MajorRoleVM = _G.RoleInfoMgr:FindRoleVM(MajorUtil.GetMajorRoleID())
	self:RegisterBinders(self.MajorRoleVM, self.RoleBinders)

	self.MajorActorVM = _G.ActorMgr:FindActorVM(MajorUtil.GetMajorEntityID())
	-- 在这个时机Major的ActorVM可能还不存在
	if nil ~= self.MajorActorVM then
		self:RegisterBinders(self.MajorActorVM, self.ActorBinders)
	end

	-- self:RegisterBinders(MajorBuffVM , self.BuffBinders)
end

function MainMajorInfoPanelView:OnMajorHPChange()
	local MaxHP = 10000
	local CurHP = 9999

	local Pct = MaxHP > 0 and CurHP / MaxHP or 0
	self.HpBarAnimProxy:Upd(Pct)
	self.ProBarHP:SetPercent(Pct)
	self.TextHP:SetText(tostring(CurHP))
end

--region MP Bar

local function GetMajorPVPSpectrumID()
	local ProfID = MajorUtil.GetMajorProfID()
	return ProSkillUtil.GetProfSpectrumID(ProfID, SkillUtil.MapType.PVP)
end

function MainMajorInfoPanelView:OnGameEventSkillSpectrumUpdate(Params)
	if nil ~= Params and Params.SpectrumID == GetMajorPVPSpectrumID() then
		self:UpdateMajorLB()
	end
end

function MainMajorInfoPanelView:InitMajorMPBar()
	if MajorUtil.IsCrafterProf() then
		self:UpdateMajorMK()
	elseif MajorUtil.IsGpProf() then
		self:UpdateMajorGP()
	elseif CurrIsInPVPWorld() then
		self:UpdateMajorLB()
	else
		self:UpdateMajorMP()
	end
end

function MainMajorInfoPanelView:UpdateMajorMP()
	local ActorVM = self.MajorActorVM
	if nil ~= ActorVM and not MajorUtil.IsGpProf() and not MajorUtil.IsCrafterProf() and not CurrIsInPVPWorld() then
		self:UpdateMPBar(ActorVM:GetCurMP(), ActorVM:GetMaxMP())
		self:SetMPBarConfig(MajorMPBarConfig.MP)
	end
end

-- 采集力
function MainMajorInfoPanelView:UpdateMajorGP()
	local ActorVM = self.MajorActorVM
	if nil ~= ActorVM and MajorUtil.IsGpProf() then
		self:UpdateMPBar(ActorVM:GetCurGP(), ActorVM:GetMaxGP())
		self:SetMPBarConfig(MajorMPBarConfig.GP)
	end
end

-- 制作力
function MainMajorInfoPanelView:UpdateMajorMK()
	local ActorVM = self.MajorActorVM
	if nil ~= ActorVM and MajorUtil.IsCrafterProf()then
		self:UpdateMPBar(ActorVM:GetCurMK(), ActorVM:GetMaxMK())
		self:SetMPBarConfig(MajorMPBarConfig.MK)
	end
end

-- PVP
function MainMajorInfoPanelView:UpdateMajorLB()
	if CurrIsInPVPWorld() and not MajorUtil.IsGpProf() and not MajorUtil.IsCrafterProf() then
		local SpectrumID = GetMajorPVPSpectrumID()
		local CurValue = MainProSkillMgr:GetCurrentResource(SpectrumID) or 0
		local MaxValue = MainProSkillMgr:GetSpectrumMaxValue(SpectrumID) or 0
		self:UpdateMPBar(CurValue, MaxValue, true)
		if CurValue >= MaxValue then
			self:SetMPBarConfig(MajorMPBarConfig.LB_Full)
		else
			self:SetMPBarConfig(MajorMPBarConfig.LB)
		end
	end
end

function MainMajorInfoPanelView:SetMPBarConfig(Cfg)
	if self.CurrMPBarConfig ~= Cfg then
		self.CurrMPBarConfig = Cfg
		UIUtil.ProgressBarSetFillImage(self.ProBarMP, Cfg.FillImage)
		if self.LBYellowPower then  -- CrafterMainPanelView复用了这个函数，里头没有这个控件
			UIUtil.SetIsVisible(self.LBYellowPower, self.CurrMPBarConfig == MajorMPBarConfig.LB_Full)
		end
	end
end

function MainMajorInfoPanelView:UpdateMPBar(CurVal, MaxVal, bTextPercent)
	local Pct = MaxVal > 0 and CurVal / MaxVal or 0
	self.MpBarAnimProxy:Upd(Pct)
	self.ProBarMP:SetPercent(Pct)
	if bTextPercent then
		self.TextMP:SetText(string.format("%.0f%%", Pct * 100))
	else
		self.TextMP:SetText(tostring(CurVal))
	end
end

--endregion

---@param ActorVM ActorVM
function MainMajorInfoPanelView:OnGameEventActorVMCreate(ActorVM)
	if MajorUtil.IsMajorByRoleID(ActorVM.RoleID) then
		self.MajorActorVM = ActorVM
		self:RegisterBinders(ActorVM, self.ActorBinders)
	end
end

---经验值更新
function MainMajorInfoPanelView:UpdateMajorExp(Params)
	local CurExp = Params and Params.ULongParam3 or ScoreMgr:GetExpScoreValue()

	local function DoUpdateExp()
		local LevelCfg = LevelExpCfg:FindCfgByKey(MajorUtil.GetTrueMajorLevel())
		if LevelCfg == nil then
			self.ExpBarAnimProxy:Upd(1)
			self.ProBarExp:SetPercent(1)
		else
			local MaxExp = LevelCfg.NextExp
			local Pct = CurExp < MaxExp and CurExp / MaxExp or 1
			self.ExpBarAnimProxy:Upd(Pct)
			self.ProBarExp:SetPercent(Pct)
		end
	end

	if MajorUtil.IsGatherProf() then
		local IsGathering = _G.GatherMgr:IsGatherState()
		if IsGathering and not _G.CollectionMgr.OnShowGatheringJobSkillPanel then
			self.UpdateExp =  _G.TimerMgr:AddTimer(nil, DoUpdateExp, 1, 1, 1)
		else
			DoUpdateExp()
			_G.CollectionMgr.OnShowGatheringJobSkillPanel = nil
			if self.UpdateExp ~= nil then
				_G.TimerMgr:CancelTimer(self.UpdateExp)
			end
		end
	else
		DoUpdateExp()
	end
end

function MainMajorInfoPanelView:OnAnimationFinished(Animation)
	if self.HpBarAnimProxy then
		self.HpBarAnimProxy:OnContextAnimStop(Animation)
	end

	if self.MpBarAnimProxy then
		self.MpBarAnimProxy:OnContextAnimStop(Animation)
	end

	if self.ExpBarAnimProxy then
		self.ExpBarAnimProxy:OnContextAnimStop(Animation)
	end
end

function MainMajorInfoPanelView:OnSwitchClicked()
	if _G.UIViewMgr:IsViewVisible(UIViewID.CrafterMainPanel) or _G.UIViewMgr:IsViewVisible(UIViewID.GatheringJobSkillPanel) then
        MsgTipsUtil.ShowTips(LSTR(500007))  -- 当前无法切换职业
		return 
	end

	if _G.TreasureHuntMgr:GetRoleIsDigging(MajorUtil.GetMajorRoleID()) then
		MsgTipsUtil.ShowTips(LSTR(500007))  -- 当前无法切换职业
		_G.EventMgr:SendEvent(EventID.TreasureHuntBreakAnim)
		return
	end

	_G.ProfMgr.ShowProfSwitchTab()
end

--region BuffUI

function MainMajorInfoPanelView:OnBuffSelect(Idx, ItemVM)
	self:ShowBuffDetails(ItemVM)
end

function MainMajorInfoPanelView:OnBuffDetailsSelect(Idx, ItemVM)
	self.MajorBuff.MainBuffTips.MajorBuffInfoTips:ChangeVMAndUpdate(ItemVM)
end

function MainMajorInfoPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	if not self.AdapterBuffDetails:GetSelectedIndex() then return end

	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if not UIUtil.IsUnderLocation(self.MajorBuff.MainBuffTips.MajorBuffInfoTips, MousePosition) and
    not UIUtil.IsUnderLocation(self.MajorBuff.MainBuffTips.TableViewBuff, MousePosition) then
		self:HideBuffDetails()
    end
end

function MainMajorInfoPanelView:ShowBuffDetails(ItemVM)
	if not ItemVM then return end

	UIUtil.SetIsVisible(self.BuffPanel, false)
	UIUtil.SetIsVisible(self.MajorBuff.MainBuffTips, true)
	self.AdapterBuffDetails:SetSelectedItem(ItemVM)
	local DisplayIndex = self.AdapterBuffDetails:GetItemDataDisplayIndex(ItemVM)
	self.AdapterBuffDetails:ScrollIndexIntoView(DisplayIndex)
	
	if _G.TouringBandMgr:IsCurTouringBandValid() then
		_G.EventMgr:SendEvent(_G.EventID.MainPanelShowBuffTips, true)
	end
end

function MainMajorInfoPanelView:HideBuffDetails()
	UIUtil.SetIsVisible(self.BuffPanel, true)
	UIUtil.SetIsVisible(self.MajorBuff.MainBuffTips, false)
	self.AdapterBuff:CancelSelected()
	self.AdapterBuffDetails:CancelSelected()
	self.MajorBuff.MainBuffTips.MajorBuffInfoTips:ChangeVMAndUpdate(nil)
	
	if _G.TouringBandMgr:IsCurTouringBandValid() then
		_G.EventMgr:SendEvent(_G.EventID.MainPanelShowBuffTips, false)
	end
end

--endregion

return MainMajorInfoPanelView
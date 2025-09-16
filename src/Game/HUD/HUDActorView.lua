---
--- Author: anypkvcai
--- DateTime: 2021-07-07 15:58
--- Description:
---




local LuaClass = require("Core/LuaClass")
local BinderRegister = require("Register/BinderRegister")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CommonUtil = require("Utils/CommonUtil")
local ActorUIUtil = require("Utils/ActorUIUtil")

local UHUDMgr

---@class HUDActorView
local HUDActorView = LuaClass()

---Ctor
function HUDActorView:Ctor()
	UHUDMgr = _G.UE.UHUDMgr:Get()
	self.Object = nil
	self.Binders = nil
	self.BinderRegister = BinderRegister.New()
	self:InitBinders()
end
function HUDActorView:InitView(Object, ViewModel, EntityID)
	if nil == Object then
		return
	end
	if nil == ViewModel then
		return
	end

	self.VM = ViewModel

	self:InitObject(Object)

	self:RegisterBinders(ViewModel)

	self:UpdateLayout()

	self.EntityID = EntityID
end

function HUDActorView:DestroyView()
	local _ <close> = CommonUtil.MakeProfileTag("HUDActorView:DestroyView")

	self.BinderRegister:UnRegisterAll()

	self.Object = nil

	self.LayoutName = nil
	self.TextureInteractiveTargetL = nil
	self.TextureInteractiveTargetR = nil
	self.TextureProf = nil
	self.TextureOnlineStatus = nil
	self.TextName = nil
	self.TextArmyShortName = nil

	self.LayoutHP = nil
	self.TextureHP = nil
	self.TextureHPBG = nil
	self.TextureHPShadow = nil

	self.LayoutSpectrum = nil
	self.TextureSpectrum = nil
	self.TextureSpectrumBg = nil

	self.LayoutTarget = nil
	self.TextureSelectShadow = nil

	self.LayoutState = nil
	self.TextureState = nil
	self.TextureSecondState = nil
	self.TextureFateMonster = nil

	self.TextEmotionInfo = nil
	self.TextureEmotion = nil
	self.TextEmotionTarget = nil
	self.TextEmotionPrefix = nil

	self.LayoutTopTitle = nil
	self.TextTopTitle = nil
	self.LayoutBelowTitle = nil
	self.TextBelowTitle = nil

	self.LayoutTargetMark = nil
	self.TextureTargetMark = nil

	self.LayoutCombatState = nil
	self.TextureCombatStateBg = nil
	self.TextureCombatStateIcon = nil
	self.TextCombatState = nil

	self.LayoutCombatStateProBar = nil
	self.TextureCombatStateProBarBg = nil
	self.TextureCombatStateProBar = nil

	self:ClearEmotionTimer()
end

function HUDActorView:InitBinders()
	-- _G.UE.FProfileTag.StaticBegin("HUDActorView:InitBinders")
	self.Binders = {
		{ "IsDraw", UIBinderValueChangedCallback.New(self, self.Object, self.OnIsDrawChanged), },
		{ "EidMountPoint", UIBinderValueChangedCallback.New(self, self.Object, self.OnEidMountPointChanged), },
		{ "OffsetY", UIBinderValueChangedCallback.New(self, self.Object, self.OnOffsetYChanged), },

		{ "IsInteractiveTarget", UIBinderValueChangedCallback.New(self, nil, self.OnInteractiveTargetVisibleChanged), },
		{ "OnlineStatusIcon", UIBinderValueChangedCallback.New(self, self.TextureOnlineStatus, self.SetOnlineStatusIcon), },
		{ "ProfIcon", UIBinderValueChangedCallback.New(self, self.TextureProf, self.SetProfIcon), },
		{ "ProfIconOffsetX", UIBinderValueChangedCallback.New(self, self.TextureProf, self.SetProfIconOffsetX), },

		{ "Name", UIBinderValueChangedCallback.New(self, self.TextName, self.OnNameChange) },
		{ "NameColor", UIBinderValueChangedCallback.New(self, self.TextName, self.OnNameColorChanged) },
		{ "NameOutlineColor", UIBinderValueChangedCallback.New(self, self.TextName, self.OnNameOutlineColorChanged) },
		{ "NameVisible", UIBinderValueChangedCallback.New(self, self.LayoutName, self.OnNameVisibleChanged), },

		{ "ArmyShortName", UIBinderValueChangedCallback.New(self, self.TextArmyShortName, self.OnArmyShortNameChanged), },

		{ "MonsterTypeIcon", UIBinderValueChangedCallback.New(self, self.TextureFateMonster, self.OnMonsterTypeIconChanged), },

		{ "SpectrumAmount", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumAmountChanged), },
		{ "SpectrumColor", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumColorChanged), },
		{ "SpectrumVisible", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumVisibleChanged), },
		{ "SpectrumAsset", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumAssetChanged), },
		{ "SpectrumBgAsset", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumBgAssetChanged), },
		{ "SpectrumTextureSize", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumTextureSizeChanged), },
		{ "SpectrumPadding", UIBinderValueChangedCallback.New(self, self.Object, self.OnSpectrumPaddingChanged), },

		{ "HPFillAmount", UIBinderValueChangedCallback.New(self, self.TextureHP, self.OnHPFillAmountChanged), },
		{ "HPBarVisible", UIBinderValueChangedCallback.New(self, self.LayoutHP, self.OnHPBarVisibleChanged), },
		{ "HPBarFillColor", UIBinderValueChangedCallback.New(self, self.TextureHP, self.OnHPBarFillColorChanged), },
		{ "HPBarBgColor", UIBinderValueChangedCallback.New(self, self.TextureHPBG, self.OnHPBarBgColorChanged), },
		{ "HPBarShadowColor", UIBinderValueChangedCallback.New(self, self.TextureHPShadow, self.OnHPBarShadowColorChanged), },

		{ "SelectVisible", UIBinderValueChangedCallback.New(self, self.LayoutTarget, self.OnSelectVisibleChanged), },
		{ "SelectArrowColor", UIBinderValueChangedCallback.New(self, self.TextureSelectShadow, self.OnSelectArrowColorChanged), },

		{ "StateIconAsset", UIBinderValueChangedCallback.New(self, self.LayoutState, self.OnStateIconAssetChanged), },
		{ "SecondStateIconAsset", UIBinderValueChangedCallback.New(self, self.LayoutState, self.OnSecondStateIconAssetChanged), },
		{ "StateVisible", UIBinderValueChangedCallback.New(self, self.LayoutState, self.OnStateVisibleChanged), },

		{ "TopTitleVisible", UIBinderValueChangedCallback.New(self, self.LayoutTopTitle, self.OnTopTitleVisibleChanged), },
		{ "TopTitleText", UIBinderValueChangedCallback.New(self, self.TextTopTitle, self.OnTextTopTitleChanged), },
		{ "BelowTitleVisible", UIBinderValueChangedCallback.New(self, self.LayoutBelowTitle, self.OnBelowTitleVisibleChanged), },
		{ "BelowTitleText", UIBinderValueChangedCallback.New(self, self.TextBelowTitle, self.OnTextBelowTitleChanged), },

		{ "TargetMarkIcon", UIBinderValueChangedCallback.New(self, self.TextureTargetMark, self.OnTargetMarkIconChanged), },

		{ "CombatStateID", UIBinderValueChangedCallback.New(self, nil, self.OnCombatStateIDChanged), },
	}

	-- _G.UE.FProfileTag.StaticEnd()
end

function HUDActorView:InitObject(Object)
	self.Object = Object

	self.LayoutName = Object:FindWidget("LayoutName")
	self.TextureInteractiveTargetL = Object:FindWidget("TextureInteractiveTargetL")  -- 交互物UI 左侧交互箭头
	self.TextureInteractiveTargetR = Object:FindWidget("TextureInteractiveTargetR")  -- 交互物UI 右侧交互箭头
	self.TextureProf = Object:FindWidget("TextureProf")  -- 玩家UI 职业图标
	self.TextureOnlineStatus = Object:FindWidget("TextureOnlineStatus")  -- 玩家UI 在线状态图标
	self.TextName = Object:FindWidget("TextName")
	self.TextArmyShortName = Object:FindWidget("TextArmyShortName")  -- 玩家UI 部队简称

	self.LayoutHP = Object:FindWidget("LayoutHP")
	self.TextureHP = Object:FindWidget("TextureHP")
	self.TextureHPBG = Object:FindWidget("TextureHPBG")
	self.TextureHPShadow = Object:FindWidget("TextureHPShadow")

	self.LayoutSpectrum = Object:FindWidget("LayoutSpectrum")
	self.TextureSpectrum = Object:FindWidget("TextureSpectrum")
	self.TextureSpectrumBg = Object:FindWidget("TextureSpectrumBg")

	self.LayoutTarget = Object:FindWidget("LayoutTarget")
	self.TextureSelectShadow = Object:FindWidget("TextureSelectShadow")

	self.LayoutState = Object:FindWidget("LayoutState")
	self.TextureState = Object:FindWidget("TextureState")
	self.TextureSecondState = Object:FindWidget("TextureSecondState")

	self.TextureFateMonster = Object:FindWidget("TextureFateMonster")
	--self.LayoutQuest = Object:FindWidget("LayoutQuest")
	--self.TextureQuest = Object:FindWidget("TextureQuest")

	self.LayoutTopTitle = Object:FindWidget("LayoutTopTitle")
	self.TextTopTitle = Object:FindWidget("TextTopTitle")
	self.LayoutBelowTitle = Object:FindWidget("LayoutBelowTitle")
	self.TextBelowTitle = Object:FindWidget("TextBelowTitle")

	self.LayoutTargetMark = Object:FindWidget("LayoutTargetMark")
	self.TextureTargetMark = Object:FindWidget("TextureTargetMark")
	
	self.LayoutCombatState = Object:FindWidget("LayoutCombatState")
	self.TextureCombatStateBg = Object:FindWidget("TextureCombatStateBg")
	self.TextureCombatStateIcon = Object:FindWidget("TextureCombatStateIcon")
	self.TextCombatState = Object:FindWidget("TextCombatState")

	self.LayoutCombatStateProBar = Object:FindWidget("LayoutCombatStateProBar")
	self.TextureCombatStateProBarBg = Object:FindWidget("TextureCombatStateProBarBg")
	self.TextureCombatStateProBar = Object:FindWidget("TextureCombatStateProBar")
end


function HUDActorView:OnTopTitleVisibleChanged(NewValue, OldValue)
	if nil == self.LayoutTopTitle or self.VM == nil then
		return
	end
	local ViewMode = self.VM
	NewValue = ViewMode.TopTitleVisible and ViewMode.NameVisible
	UHUDMgr:SetVisible(self.LayoutTopTitle, NewValue)
	self:UpdateLayout()
end

function HUDActorView:OnTextTopTitleChanged(NewValue, OldValue)
	if nil ~= self.TextTopTitle then
		UHUDMgr:SetText(self.TextTopTitle, NewValue)
		if nil ~= OldValue then
			self:UpdateLayout()
		end
	end
end

function HUDActorView:OnBelowTitleVisibleChanged(NewValue, OldValue)
	if nil == self.LayoutBelowTitle or self.VM == nil then
		return
	end
	local ViewMode = self.VM
	NewValue = ViewMode.BelowTitleVisible and ViewMode.NameVisible
	UHUDMgr:SetVisible(self.LayoutBelowTitle, NewValue)
	self:UpdateLayout()
end

function HUDActorView:OnTextBelowTitleChanged(NewValue, OldValue)
	if nil ~= self.TextBelowTitle then
		UHUDMgr:SetText(self.TextBelowTitle, NewValue)
		if nil ~= OldValue then
			self:UpdateLayout()
		end
	end
end

function HUDActorView:OnTargetMarkIconChanged(NewValue, OldValue)
	if nil == self.LayoutTargetMark or nil == self.TextureTargetMark then
		return
	end

	if string.isnilorempty(NewValue) then
		UHUDMgr:SetVisible(self.LayoutTargetMark, false)

		if nil ~= OldValue then
			self:UpdateLayout()
		end
	else
		UHUDMgr:SetVisible(self.LayoutTargetMark, true)
		UHUDMgr:SetTextureFromAssetPath(self.TextureTargetMark, NewValue)

		if string.isnilorempty(OldValue) then
			self:UpdateLayout()
		end
	end
end

function HUDActorView:RegisterBinders(ViewModel)
	self.BinderRegister:RegisterBinders(ViewModel, self.Binders)
end

function HUDActorView:ClearEmotionTimer()
	if nil ~= self.EmotionTimer then
		_G.TimerMgr:CancelTimer(self.EmotionTimer)
		self.EmotionTimer = nil
	end
end

function HUDActorView:OnNameChange(NewValue, OldValue)
	if nil ~= self.TextName then
		UHUDMgr:SetText(self.TextName, NewValue)
		if nil ~= OldValue then
			self:UpdateLayout()
		end
	end
end

function HUDActorView:OnNameColorChanged(NewValue, OldValue)
	if nil ~= self.TextName then
		UHUDMgr:SetColorHex(self.TextName, NewValue)
	end
	if nil ~= self.TextBelowTitle then
		UHUDMgr:SetColorHex(self.TextBelowTitle, NewValue)
	end
	if nil ~= self.TextTopTitle then
		UHUDMgr:SetColorHex(self.TextTopTitle, NewValue)
	end
	if nil ~= self.TextArmyShortName then
		UHUDMgr:SetColorHex(self.TextArmyShortName, NewValue)
	end
end

function HUDActorView:OnNameOutlineColorChanged(NewValue, OldValue)
	if nil ~= self.TextName then
		UHUDMgr:SetTextOutlineColorHex(self.TextName, NewValue)
	end
	if nil ~= self.TextBelowTitle then
		UHUDMgr:SetTextOutlineColorHex(self.TextBelowTitle, NewValue)
	end
	if nil ~= self.TextTopTitle then
		UHUDMgr:SetTextOutlineColorHex(self.TextTopTitle, NewValue)
	end
	if nil ~= self.TextArmyShortName then
		UHUDMgr:SetTextOutlineColorHex(self.TextArmyShortName, NewValue)
	end
end

function HUDActorView:OnNameVisibleChanged(NewValue, OldValue)
	if nil == self.LayoutName then
		return
	end
	UHUDMgr:SetVisible(self.LayoutName, NewValue)

	self:OnTopTitleVisibleChanged(NewValue, OldValue)
	self:OnBelowTitleVisibleChanged(NewValue, OldValue)
end

function HUDActorView:OnIsDrawChanged(NewValue, OldValue)
	if nil ~= self.Object then
		self.Object:SetIsDraw(NewValue)
	end
end

function HUDActorView:OnEidMountPointChanged(NewValue, OldValue)
	if nil ~= self.Object then
		-- 坐骑相关的Eid变化，不启用平滑插值
		local IsMountEID = string.match(tostring(NewValue), "^EID_UI_NAME_MNT") or
			string.match(tostring(OldValue), "^EID_UI_NAME_MNT")
		self.Object:SetEidMountPoint(NewValue, not IsMountEID)
	end
end

function HUDActorView:OnOffsetYChanged(NewValue, OldValue)
	if nil ~= self.Object then
		self.Object:SetOffset(0, NewValue)  -- loiafeng: 暂时不支持修改X轴偏移
	end
end

---@param IconPath string
function HUDActorView:SetOnlineStatusIcon(Icon)
	if nil ~= self.TextureOnlineStatus then
		if not string.isnilorempty(Icon) then
			UHUDMgr:SetVisible(self.TextureOnlineStatus, true)
			UHUDMgr:SetTextureFromAssetPath(self.TextureOnlineStatus, Icon)
		else
			UHUDMgr:SetVisible(self.TextureOnlineStatus, false)
		end

		self:UpdateLayout()
	end
end

---@param IconPath string
function HUDActorView:SetProfIcon(Icon)
	if nil ~= self.TextureProf then
		if not string.isnilorempty(Icon) then
			UHUDMgr:SetVisible(self.TextureProf, true)
			UHUDMgr:SetTextureFromAssetPath(self.TextureProf, Icon)
		else
			UHUDMgr:SetVisible(self.TextureProf, false)
		end

		self:UpdateLayout()
	end
end

---@param OffsetX number
function HUDActorView:SetProfIconOffsetX(OffsetX)
	if nil ~= self.TextureProf then
		self.TextureProf:SetWidgetPosition(OffsetX or 0, 0)
	end
end

--[[
function HUDActorView:OnRacerIndexAssetChanged(NewValue, OldValue)
	self:SetOnlineStatusIcon(NewValue)
end
]]--

function HUDActorView:OnMonsterTypeIconChanged(NewValue, OldValue)
	if nil ~= self.TextureFateMonster then
		if NewValue ~= nil then
			UHUDMgr:SetVisible(self.TextureFateMonster, true)
			UHUDMgr:SetTextureFromAssetPath(self.TextureFateMonster, NewValue)
		else
			UHUDMgr:SetVisible(self.TextureFateMonster, false)
		end
	end

	if nil ~= OldValue then
		self:UpdateLayout()
	end
end

function HUDActorView:OnSpectrumAmountChanged(NewValue, OldValue)
	if nil ~= self.TextureSpectrum then
		UHUDMgr:SetFillAmountX(self.TextureSpectrum, NewValue)
	end
end

function HUDActorView:OnSpectrumVisibleChanged(NewValue, OldValue)
	if nil ~= self.LayoutSpectrum then
		UHUDMgr:SetVisible(self.LayoutSpectrum, NewValue)
	end

	if nil ~= OldValue then
		self:UpdateLayout()
	end
end

function HUDActorView:OnSpectrumColorChanged(NewValue, OldValue)
	if nil ~= self.TextureSpectrum then
		UHUDMgr:SetColorHex(self.TextureSpectrum, NewValue)
	end
end

function HUDActorView:OnSpectrumAssetChanged(NewValue, OldValue)
	if nil ~= self.TextureSpectrum then
		UHUDMgr:SetTextureFromAssetPathSync(self.TextureSpectrum, NewValue)
	end
end

function HUDActorView:OnSpectrumBgAssetChanged(NewValue, OldValue)
	if nil ~= self.TextureSpectrumBg then
		UHUDMgr:SetTextureFromAssetPathSync(self.TextureSpectrumBg, NewValue)
	end
end

function HUDActorView:OnSpectrumTextureSizeChanged(NewValue, OldValue)
	if nil ~= NewValue then
		UHUDMgr:SetTextureSize(self.TextureSpectrum, NewValue)
		UHUDMgr:SetTextureSize(self.TextureSpectrumBg, NewValue)
	end
end

function HUDActorView:OnSpectrumPaddingChanged(NewValue, OldValue)
	if nil ~= NewValue then
		UHUDMgr:SetPadding(self.LayoutSpectrum, NewValue)
	end
end

function HUDActorView:OnHPFillAmountChanged(NewValue, OldValue)
	if nil ~= self.TextureHP then
		UHUDMgr:SetFillAmountX(self.TextureHP, NewValue)
	end
end

function HUDActorView:OnHPBarVisibleChanged(NewValue, OldValue)
	if nil ~= self.LayoutHP then
		UHUDMgr:SetVisible(self.LayoutHP, NewValue)
	end

	if nil ~= OldValue then
		self:UpdateLayout()
	end
end

function HUDActorView:OnHPBarFillColorChanged(NewValue, OldValue)
	if nil ~= self.TextureHP then
		UHUDMgr:SetColorHex(self.TextureHP, NewValue)
	end
end

function HUDActorView:OnHPBarBgColorChanged(NewValue, OldValue)
	if nil ~= self.TextureHPBG then
		UHUDMgr:SetColorHex(self.TextureHPBG, NewValue)
	end
end

function HUDActorView:OnHPBarShadowColorChanged(NewValue, OldValue)
	if nil ~= self.TextureHPShadow then
		UHUDMgr:SetColorHex(self.TextureHPShadow, NewValue)
	end
end

function HUDActorView:OnSelectVisibleChanged(NewValue, OldValue)
	if nil ~= self.LayoutTarget then
		UHUDMgr:SetVisible(self.LayoutTarget, NewValue)
	end

	self:UpdateLayout()
end

function HUDActorView:OnSelectArrowColorChanged(NewValue, OldValue)
	if nil ~= self.TextureSelectShadow then
		UHUDMgr:SetColorHex(self.TextureSelectShadow, NewValue)
	end
end

function HUDActorView:OnStateVisibleChanged(NewValue, OldValue)
	if nil == self.LayoutState then
		return
	end

	UHUDMgr:SetVisible(self.LayoutState, NewValue)
end

function HUDActorView:OnStateIconAssetChanged(NewValue, OldValue)
	if nil == self.TextureState then
		return
	end

	if not string.isnilorempty(NewValue) then
		UHUDMgr:SetVisible(self.TextureState, true)
		UHUDMgr:SetTextureFromAssetPath(self.TextureState, NewValue)
		self:UpdateLayout()
		--self.Object:PlayAnimation("AnimationStateLoop", true, 1.0) --cbt2取消HUD动画
		--self.Object:PlayAnimation("TouringBandIn", false, 1.0)
	else
		--self.Object:StopAnimation("AnimationStateLoop")
		UHUDMgr:SetVisible(self.TextureState, false)
	end
end

function HUDActorView:OnSecondStateIconAssetChanged(NewValue, OldValue)
	if nil == self.TextureSecondState then
		return
	end

	if not string.isnilorempty(NewValue) then
		UHUDMgr:SetVisible(self.TextureSecondState, true)
		UHUDMgr:SetTextureFromAssetPath(self.TextureSecondState, NewValue)
		self:UpdateLayout()
	else
		UHUDMgr:SetVisible(self.TextureSecondState, false)
	end
end

function HUDActorView:OnArmyShortNameChanged(NewValue, OldValue)
	if nil == self.TextArmyShortName then
		return
	end

	UHUDMgr:SetVisible(self.TextArmyShortName, false)
end

function HUDActorView:OnInteractiveTargetVisibleChanged(NewValue, OldValue)
	if nil ~= self.TextureInteractiveTargetL then
		UHUDMgr:SetVisible(self.TextureInteractiveTargetL, NewValue)
	end

	if nil ~= self.TextureInteractiveTargetR then
		UHUDMgr:SetVisible(self.TextureInteractiveTargetR, NewValue)
	end

	self:UpdateLayout()
end

function HUDActorView:OnCombatStateIDChanged(NewValue, OldValue)
	if nil == self.LayoutCombatState or nil == self.LayoutCombatStateProBar then
		return
	end

	local HUDCombatStateCfg = ActorUIUtil.GetHUDCombatStateConfig(NewValue)

	UHUDMgr:SetVisible(self.LayoutCombatState, nil ~= HUDCombatStateCfg)
	UHUDMgr:SetVisible(self.LayoutCombatStateProBar, nil ~= HUDCombatStateCfg)

	if nil ~= HUDCombatStateCfg then
		UHUDMgr:SetColorHex(self.TextureCombatStateBg, HUDCombatStateCfg.TextureBgColor)
		UHUDMgr:SetTextureFromAssetPath(self.TextureCombatStateIcon, HUDCombatStateCfg.Icon)

		UHUDMgr:SetText(self.TextCombatState, HUDCombatStateCfg.Text)
		UHUDMgr:SetColorHex(self.TextCombatState, HUDCombatStateCfg.TextColor)
		UHUDMgr:SetTextOutlineColorHex(self.TextCombatState, HUDCombatStateCfg.TextOutlineColor)

		UHUDMgr:SetColorHex(self.TextureCombatStateProBarBg, HUDCombatStateCfg.ProBarBgColor)
		UHUDMgr:SetColorHex(self.TextureCombatStateProBar, HUDCombatStateCfg.ProBarColor)
	end

	self:UpdateLayout()
end

function HUDActorView:UpdateLayout()
	local Object = self.Object
	if nil ~= Object then
		Object:UpdateLayout()
	end
end

function HUDActorView:PlayAnimCombatStateProBar(Rate)
	local Object = self.Object
	if nil ~= Object then
		Object:PlayAnimation("AnimCombatStateProBar", false, Rate)
	end
end

function HUDActorView:PlayAnimTouringBandIn(Rate)
	local Object = self.Object
	if nil ~= Object then
		self.Object:PlayAnimation("TouringBandIn", false, Rate)
	end
end

return HUDActorView
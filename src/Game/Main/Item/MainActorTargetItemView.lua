--
-- Author: anypkvcai
-- Date: 2020-12-01 16:45:31
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local ActorUtil = require("Utils/ActorUtil")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local EObjCfg = require("TableCfg/EobjCfg")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ProtoRes = require("Protocol/ProtoRes")
local HPBarLikeAnimProxyFactory = require("Game/Main/HPBarLikeAnimProxyFactory")
local ActorUIUtil = require("Utils/ActorUIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local SelectTargetBase = require ("Game/Skill/SelectTarget/SelectTargetBase")

local EActorType = _G.UE.EActorType

---@class MainActorTargetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSwitchTarget UFButton
---@field EFF_Glow_046 UFImage
---@field ImgEmpty UFImage
---@field ImgTargetBg UImage
---@field ImgTargetFrame UImage
---@field PanelDirect UFCanvasPanel
---@field PanelProbarTarget UFCanvasPanel
---@field PanelTarget UFCanvasPanel
---@field ProBarTarget UProgressBar
---@field TextTarget UFTextBlock
---@field AnimDirectLoop UWidgetAnimation
---@field AnimDirectStop UWidgetAnimation
---@field AnimLightAdd UWidgetAnimation
---@field AnimLightSubtract UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainActorTargetItemView = LuaClass(UIView, true)

function MainActorTargetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSwitchTarget = nil
	--self.EFF_Glow_046 = nil
	--self.ImgEmpty = nil
	--self.ImgTargetBg = nil
	--self.ImgTargetFrame = nil
	--self.PanelDirect = nil
	--self.PanelProbarTarget = nil
	--self.PanelTarget = nil
	--self.ProBarTarget = nil
	--self.TextTarget = nil
	--self.AnimDirectLoop = nil
	--self.AnimDirectStop = nil
	--self.AnimLightAdd = nil
	--self.AnimLightSubtract = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.EntityID = 0
	self.TargetID = 0

    self.IsShowing = false
    self.IsShowHPBar = false

    self.IsFullHP = true

	self.TargetUIType = 0
    self.TargetType = 0
	self.TargetVM = nil ---@type ActorVM
end

function MainActorTargetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainActorTargetItemView:OnInit()
	self.HpAnimProxy = HPBarLikeAnimProxyFactory.CreateShapeProxy(self, self.ProBarTarget, self.AnimLightAdd, self.AnimLightSubtract, 
		self.EFF_Glow_046, self.EFF_Glow_046)

	self.InfoBinders = {
		{"CurHP", UIBinderValueChangedCallback.New(self, nil, self.OnActorHPChange)},
		{"MaxHP", UIBinderValueChangedCallback.New(self, nil, self.OnActorHPChange)},
	}
end

function MainActorTargetItemView:OnDestroy()
end

function MainActorTargetItemView:OnShow()
	UIUtil.SetIsVisible(self.PanelTarget, false)
	self:UpdateUI(0)
	self:PlayAnimation(self.AnimDirectLoop, 0, 0)
end

function MainActorTargetItemView:OnHide()
	self:StopAnimation(self.AnimDirectLoop)
end

function MainActorTargetItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitchTarget, self.OnClickedBtnSwitchTarget)
end

function MainActorTargetItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TargetChangeActor, self.OnGameEventTargetChangeActor)
    self:RegisterGameEvent(EventID.TeamIdentityChanged, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.FriendAdd, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.FriendRemoved, self.OnGameEventRoleIdentityChanged)
	self:RegisterGameEvent(EventID.VisionUpdateFirstAttacker, self.OnGameEventVisionUpdateFirstAttacker)

	self:RegisterGameEvent(EventID.ActorUIColorConfigChanged, self.OnGameEventActorUIColorConfigChanged)
end

function MainActorTargetItemView:OnRegisterTimer()
end

function MainActorTargetItemView:OnRegisterBinder()
end

function MainActorTargetItemView:OnAnimationFinished(Animation)
	if self.HpAnimProxy then
		self.HpAnimProxy:OnContextAnimStop(Animation)
	end
end

function MainActorTargetItemView:UpdateUI(EntityID, forceUpdate)
	self.EntityID = EntityID or 0
	self:UpdateTargetInfo(forceUpdate)
end

function MainActorTargetItemView:OnGameEventTargetChangeActor(Params)
	local EntityID = Params.EntityID
	if self.EntityID == EntityID then
		self:UpdateTargetInfo()
	elseif self.TargetID == EntityID and self.TargetType == EActorType.Monster and Params.IsStateChange then
		self:UpdateColor()
	end
end

function MainActorTargetItemView:OnGameEventRoleIdentityChanged(RoleIDs)
    if not self.IsShowing then return end

    local RoleID = ActorUtil.GetRoleIDByEntityID(self.TargetID) or 0
    if RoleID <= 0 then return end

    for _, UpdatedRoleID in ipairs(RoleIDs) do
        if UpdatedRoleID == RoleID then
            self:UpdateColor()
            return
        end
    end
end

function MainActorTargetItemView:OnGameEventVisionUpdateFirstAttacker(Params)
	if not self.IsShowing then return end

    if self.TargetID == Params.ULongParam1 then
		self:UpdateColor()
	end
end

function MainActorTargetItemView:OnGameEventActorUIColorConfigChanged(Params)
	if not self.IsShowing then return end

	local ActorUIType = Params and Params.ActorUIType
	if nil == ActorUIType then return end

    if self.TargetUIType == ActorUIType then
        self:UpdateColor(true)
    end
end

function MainActorTargetItemView:UpdateTargetInfo(forceUpdate)
	local TargetID = _G.TargetMgr:GetTarget(self.EntityID)
	if not forceUpdate and TargetID == self.TargetID then return end

	if self.TargetVM ~= nil then
		self:UnRegisterBinders(self.TargetVM, self.InfoBinders)
	end

	self.TargetID = TargetID
	self.TargetVM = nil
	self.TargetUIType = 0
	self.TargetType = 0

    self.IsShowing = false
    self.IsShowHPBar = false

    self.IsFullHP = true

	local ActorType = TargetID > 0 and ActorUtil.GetActorType(TargetID) or EActorType.MaxType
	if EActorType.MaxType == ActorType then
		UIUtil.SetIsVisible(self.PanelTarget, false)
		return
	end

	self.TargetType = ActorType
    self.IsShowing = true
	self.HpAnimProxy:Reset()

    local ActorName = ActorUtil.GetChangeRoleNameOrNil(TargetID) or ActorUtil.GetActorName(TargetID)
	if EActorType.Monster == ActorType then
		if ActorUtil.GetActorSubType(TargetID) == _G.UE.EActorSubType.Buddy then
			local OwnerID = ActorUtil.GetActorOwner(TargetID)
			if ActorUtil.IsMajor(OwnerID) then
				ActorName = _G.BuddyMgr:GetBuddyName() or ActorName
			else
				local AttrComp = ActorUtil.GetActorAttributeComponent(OwnerID)
				ActorName = (AttrComp or {}).BuddyName or ActorName
			end
		else
			ActorName = _G.SelectMonsterMgr:GetMonsterNameHasTagStr(ActorUtil.GetActorResID(TargetID), TargetID, ActorName)
		end
	end

	self.TextTarget:SetText(ActorName)

	if EActorType.Major == ActorType or EActorType.Player == ActorType or EActorType.Monster == ActorType then
		UIUtil.SetIsVisible(self.PanelProbarTarget, true)
		self.IsShowHPBar = true

        local ActorVM = _G.ActorMgr:FindActorVM(TargetID)
		if ActorVM then
			self.TargetVM = ActorVM
			self:RegisterBinders(ActorVM, self.InfoBinders)
		end
	else
		UIUtil.SetIsVisible(self.PanelTarget, true)
		UIUtil.SetIsVisible(self.PanelProbarTarget, false)
		self.IsShowHPBar = false
	end

	self:UpdateColor()
end

function MainActorTargetItemView:UpdateColor(ForceColorConfig)
	if not self.IsShowing then return end

	local TargetID = self.TargetID
    local ActorUIType = ActorUIUtil.GetActorUIType(TargetID)
    if not ForceColorConfig and self.TargetUIType == ActorUIType then return end

    self.TargetUIType = ActorUIType
    local ColorConfig = ActorUIUtil.GetUIColorFromUIType(ActorUIType)
    if nil == ColorConfig then return end

	UIUtil.TextBlockSetColorAndOpacityHex(self.TextTarget, ColorConfig.Text)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTarget, ColorConfig.TextOutline)

	if self.IsShowHPBar then
		UIUtil.SetColorAndOpacityHex(self.ImgTargetBg, ColorConfig.HPBarShadow)
		UIUtil.SetColorAndOpacityHex(self.ImgTargetFrame, ColorConfig.HPBarOutline)
		UIUtil.ProgressBarSetFillColorAndOpacityHex(self.ProBarTarget, ColorConfig.HPBarFill)
		UIUtil.SetColorAndOpacityHex(self.ImgEmpty, ColorConfig.HPBarBackground)
	end
end

function MainActorTargetItemView:OnActorHPChange()
    local CurHP = self.TargetVM:GetCurHP()
    local MaxHP = self.TargetVM:GetMaxHP()

    local Percent = MaxHP > 0 and CurHP / MaxHP or 0
    self.HpAnimProxy:Upd(Percent)
    self.ProBarTarget:SetPercent(Percent)

    local NewIsFullHP = Percent >= 1
    local IsFullHPChanged = self.IsFullHP ~= NewIsFullHP
    self.IsFullHP = NewIsFullHP

	UIUtil.SetIsVisible(self.PanelTarget, Percent > 0)

    -- 怪物需要在特定血量更新颜色
    if self.TargetType == EActorType.Monster and IsFullHPChanged then
        self:UpdateColor()
    end
end

function MainActorTargetItemView:OnClickedBtnSwitchTarget()
	if 0 == self.TargetID or self.EntityID == self.TargetID then return end

	local TargetActor = ActorUtil.GetActorByEntityID(self.TargetID)
    if SelectTargetBase:IsCanBeSelect(TargetActor, false) then
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.ULongParam1 = self.TargetID
		_G.EventMgr:SendCppEvent(_G.EventID.ManualSelectTarget, EventParams)
	end
end

return MainActorTargetItemView
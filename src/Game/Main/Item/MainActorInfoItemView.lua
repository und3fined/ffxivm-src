--
-- Author: anypkvcai
-- Date: 2020-12-01 16:43:31
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local ActorUtil = require("Utils/ActorUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local EObjCfg = require("TableCfg/EobjCfg")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ProtoRes = require("Protocol/ProtoRes")
local HPBarLikeAnimProxyFactory = require("Game/Main/HPBarLikeAnimProxyFactory")
local UIAdapterTableViewEx = require("Game/Buff/UIAdapterTableViewEx")
local ActorUIUtil = require("Utils/ActorUIUtil")
local MainTargetBuffsVM = require("Game/Buff/VM/MainTargetBuffsVM")

local MonsterCfg = require("TableCfg/MonsterCfg")
local TargetmarkCfg = require("TableCfg/TargetmarkCfg")

local EActorType = _G.UE.EActorType

---@class MainActorInfoItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPlayer UFButton
---@field BuffInfoPanel UFHorizontalBox
---@field EFF_Glow_046 UFImage
---@field FButtonOpenBuffDetail UFButton
---@field ImageTargetMark UFImage
---@field ImgActorBg UImage
---@field ImgActorFrame UImage
---@field ImgEmpty UFImage
---@field ImgSigns UFImage
---@field PanelActor UFCanvasPanel
---@field PanelHUD UCanvasPanel
---@field PanelName UFCanvasPanel
---@field ProBarActor UProgressBar
---@field ProbarNoHud UProgressBar
---@field TableViewBuff UTableView
---@field TextLevel UFTextBlock
---@field TextMore UFTextBlock
---@field TextPercent UFTextBlock
---@field TextTargetName UFTextBlock
---@field AnimLightAdd UWidgetAnimation
---@field AnimLightSubtract UWidgetAnimation
---@field AnimLowLoop UWidgetAnimation
---@field AnimLowLoopStop UWidgetAnimation
---@field HPMinX int
---@field HPMaxX int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainActorInfoItemView = LuaClass(UIView, true)

function MainActorInfoItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPlayer = nil
	--self.BuffInfoPanel = nil
	--self.EFF_Glow_046 = nil
	--self.FButtonOpenBuffDetail = nil
	--self.ImageTargetMark = nil
	--self.ImgActorBg = nil
	--self.ImgActorFrame = nil
	--self.ImgEmpty = nil
	--self.ImgSigns = nil
	--self.PanelActor = nil
	--self.PanelHUD = nil
	--self.PanelName = nil
	--self.ProBarActor = nil
	--self.ProbarNoHud = nil
	--self.TableViewBuff = nil
	--self.TextLevel = nil
	--self.TextMore = nil
	--self.TextPercent = nil
	--self.TextTargetName = nil
	--self.AnimLightAdd = nil
	--self.AnimLightSubtract = nil
	--self.AnimLowLoop = nil
	--self.AnimLowLoopStop = nil
	--self.HPMinX = nil
	--self.HPMaxX = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.EntityID = 0

    self.IsShowing = false
    self.NormalHPBar = true

    self.IsFullHP = true
    self.IsLowHP = false
    self.IsEmptyHP = false

    self.ActorUIType = 0
    self.ActorType = 0
    self.ActorVM = nil ---@type ActorVM
end

function MainActorInfoItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainActorInfoItemView:OnInit()
    self.TextMore:SetText("...")

    self.HpAnimProxy = HPBarLikeAnimProxyFactory.CreateShapeProxy(self, self.ProBarActor, self.AnimLightAdd,
        self.AnimLightSubtract, self.EFF_Glow_046, self.EFF_Glow_046)

    -- self.AdapterBuffer = UIAdapterTableViewEx.CreateAdapter(self, self.TableViewBuff, function(_, Idx, ItemVM)
    --         if Idx > 0 then MainTargetBuffsVM:SetSelectedIndex(Idx) end
    --     end, true, false)

    -- self.AdapterBuffer:UpdateSettings(6, function(_, IsLimited)
    --         UIUtil.SetIsVisible(self.TextMore, IsLimited)
    --     end, true)

    -- self.BuffListBinders = {
    --     {"BuffList", UIBinderUpdateBindableList.New(self, self.AdapterBuffer)},
    -- }

    self.InfoBinders = {
        {"CurHP", UIBinderValueChangedCallback.New(self, nil, self.OnActorHPChange)},
        {"MaxHP", UIBinderValueChangedCallback.New(self, nil, self.OnActorHPChange)},
        {"Level", UIBinderValueChangedCallback.New(self, nil, self.OnActorLevelChange)},
    }
end

function MainActorInfoItemView:OnDestroy()
end

function MainActorInfoItemView:OnShow()
    self:UpdateUI(0)
end

function MainActorInfoItemView:OnHide()
end

function MainActorInfoItemView:OnRegisterUIEvent()
    -- UIUtil.AddOnClickedEvent(self, self.FButtonOpenBuffDetail, function()
    --     if MainTargetBuffsVM:GetBuffNum() > 0 then
    --         MainTargetBuffsVM:SetSelectedIndex(1)
    --     end
    -- end)

    UIUtil.AddOnClickedEvent(self, self.BtnPlayer, function()
        local RoleID = (_G.ActorMgr:FindActorVM(self.EntityID or 0) or {}).RoleID
        if RoleID then
            _G.PersonInfoMgr:ShowPersonalSimpleInfoView(RoleID)
        end
    end)
end

function MainActorInfoItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.TeamIdentityChanged, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.FriendAdd, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.FriendRemoved, self.OnGameEventRoleIdentityChanged)
    self:RegisterGameEvent(EventID.TargetChangeActor, self.OnGameEventTargetChangeActor)
    self:RegisterGameEvent(EventID.VisionUpdateFirstAttacker, self.OnGameEventVisionUpdateFirstAttacker)

    self:RegisterGameEvent(EventID.GatherAttrChange, self.OnGatherAttrChange)
    self:RegisterGameEvent(EventID.GatheringJobShowBarView, self.OnGatheringJobShowBarViewEvent)

	self:RegisterGameEvent(EventID.ActorUIColorConfigChanged, self.OnGameEventActorUIColorConfigChanged)
    self:RegisterGameEvent(EventID.TeamTargetMarkStateChanged, self.OnGameEventTeamTargetMarkStateChanged)
end

function MainActorInfoItemView:OnRegisterTimer()
end

function MainActorInfoItemView:OnRegisterBinder()
    -- local _ <close> = CommonUtil.MakeProfileTag("RegisterBinders")
    -- self:RegisterBinders(MainTargetBuffsVM, self.BuffListBinders)
end

function MainActorInfoItemView:UpdateUI(EntityID)
    local _ <close> = CommonUtil.MakeProfileTag("MainActorInfoItemView_UpdateUI")
    self.EntityID = EntityID or 0

    if self.ActorVM then
        self:UnRegisterBinders(self.ActorVM, self.InfoBinders)
    end

    self.ActorVM = nil
    self.IsShowing = false
    self.IsFullHP = true
    self.IsLowHP = false
    self.IsEmptyHP = false
    self.ActorUIType = 0
    self.ActorType = 0
    self.NormalHPBar = true

    if not EntityID or EntityID <= 0 then
        UIUtil.SetIsVisible(self.PanelActor, false)
        return
    end

    local ActorType = ActorUtil.GetActorType(EntityID)
    if EActorType.Gather == ActorType then
        UIUtil.SetIsVisible(self.PanelActor, false)
        return
    end
    
    local ActorResID = ActorUtil.GetActorResID(EntityID)
    if EActorType.EObj == ActorType then
        local Cfg = EObjCfg:FindCfgByKey(ActorResID)
        if Cfg and Cfg.IsShowNameBoard == 0 then
            UIUtil.SetIsVisible(self.PanelActor, false)
            return
        end
    end

    self.IsShowing = true
	self.HpAnimProxy:Reset()

    self.ActorType = ActorType

    if EActorType.Major == ActorType or EActorType.Player == ActorType or EActorType.Monster == ActorType then
        self:SwitchHPBar(true)
        local ActorVM = _G.ActorMgr:FindActorVM(EntityID)
        self.ActorVM = ActorVM
        self:RegisterBinders(ActorVM, self.InfoBinders)
        self:UpdateActorName()

    elseif EActorType.Gather == ActorType then
        -- self:SwitchHPBar(true)
        -- self:UpdateGatherNameAndLevel()
        -- self:UpdateGatherHP()

    else
        UIUtil.SetIsVisible(self.TextLevel, false)
        UIUtil.SetIsVisible(self.TextPercent, false)
        self:SwitchHPBar(false)
        self:UpdateActorName()
    end

    self:UpdatePanelVisible()
    self:UpdateTargetMarkState()
    self:UpdateColor()

    if EActorType.Major == ActorType or EActorType.Player == ActorType then
        UIUtil.SetIsVisible(self.BtnPlayer, true, true)
    else
        UIUtil.SetIsVisible(self.BtnPlayer, false)
    end
end

function MainActorInfoItemView:OnAnimationFinished(Animation)
    if self.HpAnimProxy then
        self.HpAnimProxy:OnContextAnimStop(Animation)
    end
end

function MainActorInfoItemView:OnGameEventRoleIdentityChanged(RoleIDs)
    if not self.IsShowing then return end

    local RoleID = ActorUtil.GetRoleIDByEntityID(self.EntityID) or 0
    if RoleID <= 0 then return end

    for _, UpdatedRoleID in ipairs(RoleIDs) do
        if UpdatedRoleID == RoleID then
            self:UpdateColor()
            return
        end
    end
end

function MainActorInfoItemView:OnGameEventTargetChangeActor(Params)
    if not self.IsShowing then return end

    if self.EntityID ~= Params.EntityID then return end
    if self.ActorType == EActorType.Monster and Params.IsStateChange then
        self:UpdateColor()
    end
end

function MainActorInfoItemView:OnGameEventVisionUpdateFirstAttacker(Params)
    if not self.IsShowing then return end

    if self.EntityID ~= Params.ULongParam1 then return end
    self:UpdateColor()
end

function MainActorInfoItemView:OnGatherAttrChange(Params)
    if not self.IsShowing then return end

    if self.EntityID ~= Params.ULongParam1 then return end
    self:UpdateGatherHP()
end

function MainActorInfoItemView:OnGatheringJobShowBarViewEvent(Params)
    if not self.IsShowing then return end

    self:UpdatePanelVisible()
end

function MainActorInfoItemView:OnGameEventActorUIColorConfigChanged(Params)
	if not self.IsShowing then return end

	local ActorUIType = Params and Params.ActorUIType
	if nil == ActorUIType then return end

    if self.ActorUIType == ActorUIType then
        self:UpdateColor(true)
    end
end

function MainActorInfoItemView:OnGameEventTeamTargetMarkStateChanged(Params)
    if not self.IsShowing then return end

    local EntityID = Params and Params.EntityID
    if EntityID ~= self.EntityID then return end

    self:UpdateTargetMarkState(Params.IconID)
end

function MainActorInfoItemView:SwitchHPBar(IsNorm)
    self.NormalHPBar = IsNorm
    UIUtil.SetIsVisible(self.PanelHUD, IsNorm)
    UIUtil.SetIsVisible(self.ProbarNoHud, not IsNorm)
end

function MainActorInfoItemView:UpdateColor(ForceColorConfig)
    local EntityID = self.EntityID
    local ActorUIType = ActorUIUtil.GetActorUIType(EntityID)
    if not ForceColorConfig and self.ActorUIType == ActorUIType then return end

    self.ActorUIType = ActorUIType
    local ColorConfig = ActorUIUtil.GetUIColorFromUIType(ActorUIType)
    if nil == ColorConfig then
        return
    end

    local TextColor = ColorConfig.Text
    local OutlineColor = ColorConfig.TextOutline

    UIUtil.TextBlockSetColorAndOpacityHex(self.TextTargetName, TextColor)
    UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextTargetName, OutlineColor)

    UIUtil.TextBlockSetColorAndOpacityHex(self.TextLevel, TextColor)
    UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextLevel, OutlineColor)

    if self.NormalHPBar then
        UIUtil.TextBlockSetColorAndOpacityHex(self.TextPercent, TextColor)
        UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextPercent, OutlineColor)
        -- 对于血量低于20的敌对怪物，需要特殊处理
        if ActorUIType == ProtoRes.ActorUIType.ActorUITypeMonster3 and self.IsLowHP then
            UIUtil.SetColorAndOpacityHex(self.ImgActorBg, "861925ff")
            UIUtil.SetColorAndOpacityHex(self.ImgActorFrame, "871926ff")
            UIUtil.ProgressBarSetFillColorAndOpacityHex(self.ProBarActor, ColorConfig.HPBarFill)
            UIUtil.SetColorAndOpacityHex(self.ImgEmpty, 0, 0, 0, 0)
            self:PlayAnimation(self.AnimLowLoop, 0, 0, nil, 1)
        else
            UIUtil.SetColorAndOpacityHex(self.ImgActorBg, ColorConfig.HPBarShadow)
            UIUtil.SetColorAndOpacityHex(self.ImgActorFrame, ColorConfig.HPBarOutline)
            UIUtil.ProgressBarSetFillColorAndOpacityHex(self.ProBarActor, ColorConfig.HPBarFill)
            UIUtil.SetColorAndOpacityHex(self.ImgEmpty, ColorConfig.HPBarBackground)
            self:StopAnimation(self.AnimLowLoop)
            self:PlayAnimation(self.AnimLowLoopStop)
        end
    else
        UIUtil.ProgressBarSetFillColorAndOpacityHex(self.ProbarNoHud, ColorConfig.HPBarOutline)
        UIUtil.ProgressBarSetBackgroundColorAndOpacityHex(self.ProbarNoHud, ColorConfig.HPBarShadow)
    end

    local _ <close> = CommonUtil.MakeProfileTag("UpdateDecalColor")
    _G.UE.USelectEffectMgr:Get():UpdateDecalColor(EntityID, ColorConfig.ActorDecal, true)
end

---@param StateID number|nil 不传入则通过SignsMgr查询
function MainActorInfoItemView:UpdateTargetMarkState(StateID)
    StateID = StateID or _G.SignsMgr:GetMarkingByEntityID(self.EntityID)
	if StateID == 0 then
        UIUtil.SetIsVisible(self.ImgSigns, false)
	else
        UIUtil.SetIsVisible(self.ImgSigns, true)
        local IconPath = TargetmarkCfg:FindValue(StateID, "IconPath") or ""
        UIUtil.ImageSetBrushFromAssetPath(self.ImgSigns, IconPath)
	end
    --TODO(loiafeng): 移除这个控件
    UIUtil.SetIsVisible(self.ImageTargetMark, false)
end

function MainActorInfoItemView:UpdateActorHP(CurHP, MaxHP)
    local Percent = MaxHP > 0 and CurHP / MaxHP or 0
    self.HpAnimProxy:Upd(Percent)
    self.ProBarActor:SetPercent(Percent)

    local NewIsFullHP = Percent >= 1
    local IsFullHPChanged = self.IsFullHP ~= NewIsFullHP
    self.IsFullHP = NewIsFullHP

    -- 当怪物血量越过20%的界限时，需要更新颜色
    local NewIsLowHP = Percent <= 0.2
    local IsLowHPChanged = self.IsLowHP ~= NewIsLowHP
    self.IsLowHP = NewIsLowHP

    local NewIsEmptyHP = Percent <= 0
    local IsEmptyHPChanged = self.IsEmptyHP ~= NewIsEmptyHP
    self.IsEmptyHP = NewIsEmptyHP

    if not NewIsFullHP then
        -- 血量小于1%时，以0.1%为单位显示
        if Percent > 0.01 then
            self.TextPercent:SetText(string.format("%s%%", math.floor(Percent * 100)))
        else
            local Value = math.max(math.floor(Percent * 1000), 1)
            self.TextPercent:SetText(string.format("0.%s%%", Value))
        end
    end

    return IsFullHPChanged, IsLowHPChanged, IsEmptyHPChanged
end

function MainActorInfoItemView:OnActorHPChange()
    local CurHP = self.ActorVM:GetCurHP()
    local MaxHP = self.ActorVM:GetMaxHP()

    local IsFullHPChanged, IsLowHPChanged, IsEmptyHPChanged = self:UpdateActorHP(CurHP, MaxHP)

    -- 满血显示等级，不满血显示血量百分比
    UIUtil.SetIsVisible(self.TextLevel, self.IsFullHP and (self.ActorVM.Level or 0) > 0)
    UIUtil.SetIsVisible(self.TextPercent, not self.IsFullHP)

    -- 怪物需要在特定血量更新颜色
    if self.ActorType == EActorType.Monster and (IsFullHPChanged or IsLowHPChanged) then
        self:UpdateColor(IsLowHPChanged)
    end

    -- 需要在特定血量更新可视性
    if IsEmptyHPChanged then
        self:UpdatePanelVisible()
    end
end

function MainActorInfoItemView:UpdateGatherHP()
	local AttrComp = ActorUtil.GetActorAttributeComponent(self.EntityID)
    if not AttrComp then return end

    local CurHP = AttrComp.PickTimesLeft
    local MaxHP = _G.GatherMgr:GetMaxGatherCount(AttrComp.ResID, AttrComp.ListID)
    
    local IsFullHPChanged, IsLowHPChanged, IsEmptyHPChanged = self:UpdateActorHP(CurHP, MaxHP)

    -- 满血显示等级，不满血显示血量百分比
    UIUtil.SetIsVisible(self.TextLevel, self.IsFullHP and (self.ActorVM.Level or 0) > 0)
    UIUtil.SetIsVisible(self.TextPercent, not self.IsFullHP)

    -- 需要在特定血量更新可视性
    if IsEmptyHPChanged then
        self:UpdatePanelVisible()
    end
end

function MainActorInfoItemView:OnActorLevelChange(NewValue)
    -- 这里不用更新Visible，由HP更新就好
    local _ <close> = CommonUtil.MakeProfileTag("MainActorInfoItemView_OnActorLevelChange")
    if self.ActorType == EActorType.Monster and MonsterCfg:FindValue(ActorUtil.GetActorResID(self.EntityID), "IsHideLevel") ~= 0 then
        self.TextLevel:SetText(string.format(_G.LSTR(500001)))  -- ??级
    else
        self.TextLevel:SetText(string.format(_G.LSTR(500002), NewValue or 0))  -- %d级
    end
end

---Name and Level
function MainActorInfoItemView:UpdateGatherNameAndLevel()
    local ActorName = ActorUtil.GetChangeRoleNameOrNil(self.EntityID) or ActorUtil.GetActorName(self.EntityID)
    local StrTable = string.split(ActorName, " ")
    if StrTable and #StrTable >= 2 then
        -- 这里不用更新Level的Visible，由HP更新就好
        self.TextLevel:SetText(StrTable[1])
        self.TextTargetName:SetText(StrTable[2])
    else
        self.TextLevel:SetText("")
        self.TextTargetName:SetText(ActorName)
    end
end

function MainActorInfoItemView:UpdateActorName()
    local _ <close> = CommonUtil.MakeProfileTag("MainActorInfoItemView_UpdateActorName")
    local EntityID = self.EntityID

    local ActorName = ActorUtil.GetChangeRoleNameOrNil(EntityID) or ActorUtil.GetActorName(EntityID)
	if EActorType.Monster == ActorUtil.GetActorType(EntityID) then
		if ActorUtil.GetActorSubType(EntityID) == _G.UE.EActorSubType.Buddy then
			local OwnerID = ActorUtil.GetActorOwner(EntityID)
			if ActorUtil.IsMajor(OwnerID) then
				ActorName = _G.BuddyMgr:GetBuddyName() or ActorName
			else
				local AttrComp = ActorUtil.GetActorAttributeComponent(OwnerID)
				ActorName = (AttrComp or {}).BuddyName or ActorName
			end
		else
			ActorName = _G.SelectMonsterMgr:GetMonsterNameHasTagStr(ActorUtil.GetActorResID(EntityID), EntityID, ActorName)
		end
	end

    self.TextTargetName:SetText(ActorName)
end

function MainActorInfoItemView:UpdatePanelVisible()
    if self.IsEmptyHP or (EActorType.Gather == self.ActorType and
    _G.UIViewMgr:IsViewVisible(_G.UIViewID.GatheringJobPanel)) then  -- 使用制造界面血条
        UIUtil.SetIsVisible(self.PanelActor, false)
    else
        UIUtil.SetIsVisible(self.PanelActor, true)
    end
end

return MainActorInfoItemView

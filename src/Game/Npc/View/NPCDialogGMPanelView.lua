--- Author: zimuyi & MichaelYang
---
--- DateTime: 2024-03-18 18:47
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local NpcDialogSkeletonGroupCfg = require("TableCfg/NpcDialogSkeletonGroupCfg")
local NpcDialogCameraCfg = require("TableCfg/NpcDialogCameraCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ActorUtil = require("Utils/ActorUtil")

local NPCDefine = require("Game/Npc/NpcDefine")
local NPCDialogGMConfig = require("Game/Npc/NPCDialogGMConfig")
local NpcDialogGMPanelVM = require("Game/Npc/VM/NpcDialogGMPanelVM")

local LSTR = _G.LSTR
local CameraFocusType = ProtoRes.CameraFocusTypeEnum
local DialogTargetType = NPCDefine.DialogTargetType

---@class NPCDialogGMPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnApplyCameraID CommBtnSView
---@field BtnClose CommonCloseBtnView
---@field BtnEnd CommBtnSView
---@field BtnFold UToggleButton
---@field BtnStart CommBtnSView
---@field DropDownDialogTarget CommDropDownListView
---@field DropDownType CommDropDownListView
---@field EditableTextNPCEID UFGMEditableText
---@field EditableTextPlayerEID UFGMEditableText
---@field SpinBoxCameraID USpinBox
---@field SpinBoxDistance USpinBox
---@field SpinBoxFOV USpinBox
---@field SpinBoxPitch USpinBox
---@field SpinBoxRoll USpinBox
---@field SpinBoxX USpinBox
---@field SpinBoxY USpinBox
---@field SpinBoxYaw USpinBox
---@field SpinBoxZ USpinBox
---@field TextCamDistance UFTextBlock
---@field TextCamOffset UFTextBlock
---@field TextCamRotation UFTextBlock
---@field TextCamType UFTextBlock
---@field TextDialogTarget UFTextBlock
---@field TextFOV UFTextBlock
---@field TextNPCEID UFTextBlock
---@field TextOffsetX UFTextBlock
---@field TextOffsetY UFTextBlock
---@field TextOffsetZ UFTextBlock
---@field TextPitch UFTextBlock
---@field TextPlayerEID UFTextBlock
---@field TextRoll UFTextBlock
---@field TextTitle UFTextBlock
---@field TextViewID UFTextBlock
---@field TextYaw UFTextBlock
---@field TxtIsDebugging UFTextBlock
---@field AnimDebugging UWidgetAnimation
---@field AnimFold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCDialogGMPanelView = LuaClass(UIView, true)

function NPCDialogGMPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnClose = nil
    -- self.BtnEnd = nil
    -- self.BtnFold = nil
    -- self.BtnStart = nil
	-- self.DropDownDialogTarget = nil
    -- self.DropDownType = nil
    -- self.EditableTextNPCEID = nil
    -- self.EditableTextPlayerEID = nil
    -- self.SpinBoxDistance = nil
    -- self.SpinBoxPitch = nil
    -- self.SpinBoxRoll = nil
    -- self.SpinBoxX = nil
    -- self.SpinBoxY = nil
    -- self.SpinBoxYaw = nil
    -- self.SpinBoxZ = nil
    -- self.TxtIsDebugging = nil
    -- self.AnimDebugging = nil
    -- self.AnimFold = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCDialogGMPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnClose)
    self:AddSubView(self.BtnEnd)
    self:AddSubView(self.BtnStart)
    self:AddSubView(self.DropDownDialogTarget)
    self:AddSubView(self.DropDownType)
    self:AddSubView(self.BtnApplyCameraID)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCDialogGMPanelView:OnInit()
    self.ViewModel = NpcDialogGMPanelVM.New()
    self.Binders = {
        {
            "bIsDebugging",
            UIBinderSetIsVisible.New(self, self.TxtIsDebugging)
        },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
		{ "TextCamType", UIBinderSetText.New(self, self.TextCamType) },
		{ "TextDialogTarget", UIBinderSetText.New(self, self.TextDialogTarget) },
		{ "TextPlayerEID", UIBinderSetText.New(self, self.TextPlayerEID) },
		{ "TextNPCEID", UIBinderSetText.New(self, self.TextNPCEID) },
		{ "TextCamDistance", UIBinderSetText.New(self, self.TextCamDistance) },
		{ "TextCamRotation", UIBinderSetText.New(self, self.TextCamRotation) },
		{ "TextCamOffset", UIBinderSetText.New(self, self.TextCamOffset) },
		{ "TextFOV", UIBinderSetText.New(self, self.TextFOV) },
		{ "TextViewID", UIBinderSetText.New(self, self.TextViewID) },
		{ "TextDebugging", UIBinderSetText.New(self, self.TxtIsDebugging) },
		{ "TextPitch", UIBinderSetText.New(self, self.TextPitch) },
		{ "TextYaw", UIBinderSetText.New(self, self.TextYaw) },
		{ "TextRoll", UIBinderSetText.New(self, self.TextRoll) },
		{ "TextOffsetX", UIBinderSetText.New(self, self.TextOffsetX) },
		{ "TextOffsetY", UIBinderSetText.New(self, self.TextOffsetY) },
		{ "TextOffsetZ", UIBinderSetText.New(self, self.TextOffsetZ) },
    }

    self.RawRotation = nil
end

function NPCDialogGMPanelView:OnDestroy()
end

function NPCDialogGMPanelView:OnShow()
    self:InitDropDownByNameMap(self.DropDownType, NPCDialogGMConfig.CameraFocusTypeNameMap, CameraFocusType.Closeup)
	self:InitDropDownByNameMap(self.DropDownDialogTarget, NPCDialogGMConfig.DialogTargetTypeNameMap, DialogTargetType.DialogNPC)
    if self.ViewModel.bIsDebugging then
        self:PlayAnimation(self.AnimDebugging, 0, 0)
    end

	self.BtnApplyCameraID:SetBtnName(LSTR(1520011))
	self.BtnStart:SetBtnName(LSTR(1520012))
	self.BtnEnd:SetBtnName(LSTR(1520013))
    self.BtnClose:SetCallback(self, self.OnClickBtnClose)
end

function NPCDialogGMPanelView:OnClickBtnClose()
    self:OnEndClicked()
    _G.UIViewMgr:HideView(self.ViewID)
end

function NPCDialogGMPanelView:OnHide()
end

function NPCDialogGMPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnStartClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnEnd, self.OnEndClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnApplyCameraID, self.OnBtnApplyCameraIDClicked)

    UIUtil.AddOnSelectionChangedEvent(self, self.DropDownType, self.OnViewTypeChanged)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownDialogTarget, self.OnDialogTargetChanged)

    UIUtil.AddOnTextCommittedEvent(self, self.EditableTextPlayerEID, self.RefreshViewChecked)
    UIUtil.AddOnTextCommittedEvent(self, self.EditableTextNPCEID, self.RefreshViewChecked)

    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxDistance, self.OnDistanceChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxPitch, self.OnRotationChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxYaw, self.OnRotationChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxRoll, self.OnRotationChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxX, self.OnOffsetChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxY, self.OnOffsetChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxZ, self.OnOffsetChanged)
    UIUtil.AddOnValueChangedEvent(self, self.SpinBoxFOV, self.OnFOVChanged)

    UIUtil.AddOnStateChangedEvent(self, self.BtnFold, self.OnFoldClicked)
end

function NPCDialogGMPanelView:OnRegisterGameEvent()
end

-- 点击了应用 CameraID 的按钮
function NPCDialogGMPanelView:OnBtnApplyCameraIDClicked()
    if (_G.NpcDialogMgr.LastDialog == nil) then
        return
    end

    local TargetID = math.floor(self.SpinBoxCameraID:GetValue()) or 0
    local TableData = NpcDialogCameraCfg:FindCfgByKey(TargetID)
    if (TableData ~= nil) then
        self.SpinBoxDistance:SetValue(TableData.Distance)
        self.SpinBoxPitch:SetValue(TableData.Pitch)
        self.SpinBoxYaw:SetValue(TableData.Yaw)
        self.SpinBoxRoll:SetValue(TableData.Roll)
        self.SpinBoxX:SetValue(TableData.OffsetX)
        self.SpinBoxY:SetValue(TableData.OffsetY)
        self.SpinBoxZ:SetValue(TableData.OffsetZ)
        self.EditableTextPlayerEID:SetText(TableData.PlayerEID)
        self.EditableTextNPCEID:SetText(TableData.NPCEID)
        if (TableData.FOV ~= nil and TableData.FOV > 0) then
            self.SpinBoxFOV:SetValue(TableData.FOV)
        end
        self.DropDownType:SetDropDownIndex(TableData.CameraFocusType)
        local bNeedNpc = TableData.CameraFocusType ~= CameraFocusType.MajorBack

        if (bNeedNpc) then
            local NPCID = _G.NpcDialogMgr.LastDialog.NpcEntityID
            local NPC = ActorUtil.GetActorByEntityID(NPCID)
            if (NPC == nil) then
                MsgTipsUtil.ShowTips("无法找到NPC，请检查")
                return
            end
            local SearchStr = string.format('SkeletonName = "%s"', NPC:GetAvatarComponent():GetAttachTypeIgnoreChangeRole())
            local NPCSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(SearchStr)
            if (NPCSkeletonGroupCfgData == nil) then
                MsgTipsUtil.ShowTips("错误，无法获取Npc的 NpcDialogSkeletonGroupCfg 数据，请检查")
                return
            end

            local Major = MajorUtil.GetMajor()
            local TempStrOne = string.format('SkeletonName = "%s"', Major:GetAvatarComponent():GetAttachTypeIgnoreChangeRole())
            local PlayerSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(TempStrOne)
            if (PlayerSkeletonGroupCfgData == nil) then
                MsgTipsUtil.ShowTips("错误，无法获取玩家的 NpcDialogSkeletonGroupCfg 数据，请检查")
                return
            end

            local NotMatchPlayer = TableData.PlayerSkeletonGroup > 0 and PlayerSkeletonGroupCfgData.PlayerSkeletonGroup ~= TableData.PlayerSkeletonGroup
            local NotMatchNpc = TableData.NPCSkeletonGroup > 0 and NPCSkeletonGroupCfgData.NPCSkeletonGroup ~= TableData.NPCSkeletonGroup

            if (NotMatchNpc) then
                MsgTipsUtil.ShowTips(LSTR("镜头配置与当前 Npc 骨骼不匹配，表格NPCSkeletonGroup:" .. TableData.NPCSkeletonGroup))
            end

            if (TableData.CameraFocusType ~= CameraFocusType.Closeup and NotMatchPlayer) then
                MsgTipsUtil.ShowTips(LSTR("镜头配置与当前 玩家 骨骼不匹配，表格PlayerSkeletonGroup:" .. TableData.PlayerSkeletonGroup))
            end
        else
            local Major = MajorUtil.GetMajor()
            local TempStrOne = string.format('SkeletonName = "%s"', Major:GetAvatarComponent():GetAttachTypeIgnoreChangeRole())
            local PlayerSkeletonGroupCfgData = NpcDialogSkeletonGroupCfg:FindCfg(TempStrOne)
            if (PlayerSkeletonGroupCfgData == nil) then
                MsgTipsUtil.ShowTips("错误，无法获取玩家的 NpcDialogSkeletonGroupCfg 数据，请检查")
                return
            end

            local NotMatchPlayer = TableData.PlayerSkeletonGroup > 0 and PlayerSkeletonGroupCfgData.PlayerSkeletonGroup ~= TableData.PlayerSkeletonGroup

            if (TableData.CameraFocusType ~= CameraFocusType.Closeup and NotMatchPlayer) then
                MsgTipsUtil.ShowTips(LSTR("镜头配置与当前 玩家 骨骼不匹配，表格PlayerSkeletonGroup:" .. TableData.PlayerSkeletonGroup))
            end
        end
    else
        MsgTipsUtil.ShowTips("找不到Npc镜头表格数据,ID是：" .. TargetID)
    end

    self:InternalStartConfig()
end

function NPCDialogGMPanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function NPCDialogGMPanelView:OnStartClicked()
    self:InternalStartConfig()
end

function NPCDialogGMPanelView:InternalStartConfig()
    local bCanStart = self:RefreshView()
    if not bCanStart then
        return
    end
    self.ViewModel.bIsDebugging = true
    self:PlayAnimation(self.AnimDebugging, 0, 0)

    -- 这里隐藏一下自己
    if (self.ViewModel.ViewType == CameraFocusType.Closeup) then
        local UActorManager = _G.UE.UActorManager.Get()
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        UActorManager:HideActor(MajorEntityID, true)
    end
end

function NPCDialogGMPanelView:OnEndClicked()
    _G.UE.UCameraMgr.Get():ResumeCamera(0)
    self.ViewModel.bIsDebugging = false
    self:StopAnimation(self.AnimDebugging)

    -- 这里显示一下自己
    local UActorManager = _G.UE.UActorManager.Get()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    UActorManager:HideActor(MajorEntityID, false)
end

function NPCDialogGMPanelView:OnFoldClicked(ToggleButton, ButtonState)
    local bHidePanel = ButtonState == _G.UE.EToggleButtonState.Checked
    if bHidePanel then
        self:PlayAnimation(self.AnimFold)
    else
        self:PlayAnimationReverse(self.AnimFold)
    end
end

function NPCDialogGMPanelView:OnViewTypeChanged(ViewType)
    self.ViewModel.ViewType = ViewType
    self:RefreshViewChecked()

    local UActorManager = _G.UE.UActorManager.Get()
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    if (self.ViewModel.bIsDebugging) then
        -- 这里隐藏一下自己
        if (self.ViewModel.ViewType == CameraFocusType.Closeup) then
            UActorManager:HideActor(MajorEntityID, true)
        else
            -- 这里显示一下自己
            UActorManager:HideActor(MajorEntityID, false)
        end
    end
end

function NPCDialogGMPanelView:OnDialogTargetChanged(TargetType)
	self.ViewModel.DialogTargetType = TargetType
    self:RefreshViewChecked()
end

function NPCDialogGMPanelView:OnDistanceChanged(_, Distance)
    if not self.ViewModel.bIsDebugging or not _G.LuaCameraMgr:HasExtraCamera() then
        return
    end
    _G.LuaCameraMgr:GetExtraCamera():SetViewDistance(Distance, false)
end

function NPCDialogGMPanelView:OnFOVChanged(_, FOV)
    if not self.ViewModel.bIsDebugging or not _G.LuaCameraMgr:HasExtraCamera() then
        return
    end
    _G.LuaCameraMgr:GetExtraCamera():SetFOVY(FOV, false)
end

function NPCDialogGMPanelView:OnRotationChanged(_, Value)
    if not self.ViewModel.bIsDebugging or not _G.LuaCameraMgr:HasExtraCamera() or nil == self.RawRotation then
        return
    end
    _G.LuaCameraMgr:GetExtraCamera():Rotate(self.RawRotation + self:GetExtraRotation(), false)
end

function NPCDialogGMPanelView:OnOffsetChanged(_, Value)
    if not self.ViewModel.bIsDebugging or not _G.LuaCameraMgr:HasExtraCamera() then
        return
    end
    _G.LuaCameraMgr:GetExtraCamera():SetSocketOffset(self:GetSocketOffset(), false)
end

function NPCDialogGMPanelView:InitDropDownByNameMap(Widget, NameMap, InSelectedIndex)
	local DropDownTypeList = {}
    for Index, Name in ipairs(NameMap) do
        DropDownTypeList[Index] = {}
        DropDownTypeList[Index].Name = Name
    end
    Widget:UpdateItems(DropDownTypeList, InSelectedIndex)
end

function NPCDialogGMPanelView:RefreshView()
    local TargetEntityID = 0
	local EntityIDCallback = NPCDialogGMConfig.DialogTargetEntityIDCallbackMap[self.ViewModel.DialogTargetType]
    if nil ~= EntityIDCallback then
        TargetEntityID = EntityIDCallback() or 0
    end
    local ViewParams = {
        ViewType = self.ViewModel.ViewType,
        PlayerEID = self.EditableTextPlayerEID:GetText(),
        NPCEID = self.EditableTextNPCEID:GetText(),
        ViewDistance = self.SpinBoxDistance:GetValue(),
        ExtraRotation = self:GetExtraRotation(),
        SocketOffset = self:GetSocketOffset(),
        FOV = self.SpinBoxFOV:GetValue(),
        InNpcEntityId = TargetEntityID
    }
    local NewViewParams = _G.LuaCameraMgr:ChangeViewByParams(ViewParams)
    if nil ~= NewViewParams then
        self.RawRotation = NewViewParams.RawRotation
    end
    return nil ~= NewViewParams
end

function NPCDialogGMPanelView:RefreshViewChecked()
    if not self.ViewModel.bIsDebugging then
        return
    end
    self:RefreshView()
end

function NPCDialogGMPanelView:GetExtraRotation()
    return _G.UE.FRotator(self.SpinBoxPitch:GetValue(), self.SpinBoxYaw:GetValue(), self.SpinBoxRoll:GetValue())
end

function NPCDialogGMPanelView:GetSocketOffset()
    return _G.UE.FVector(self.SpinBoxX:GetValue(), self.SpinBoxY:GetValue(), self.SpinBoxZ:GetValue())
end

return NPCDialogGMPanelView

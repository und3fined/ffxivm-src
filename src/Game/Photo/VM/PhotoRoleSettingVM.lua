local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")
local PhotoRoleSettingParentItemVM = require("Game/Photo/ItemVM/PhotoRoleSettingParentItemVM")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local UIBindableList = require("UI/UIBindableList")
local ActorUtil = require("Utils/ActorUtil")
local Json = require("Core/Json")
local PhotoTemplateUtil = require("Game/Photo/Util/PhotoTemplateUtil")

local PhotoRoleSettingVM = LuaClass(UIViewModel)

function PhotoRoleSettingVM:Ctor()
    self.CtrlTypeTree = UIBindableList.New(PhotoRoleSettingParentItemVM)

    self.CtrlTypeData = {
        {Type = PhotoDefine.RoleSettingType.Ctrl},
        {Type = PhotoDefine.RoleSettingType.UnCtrl},
        {Type = PhotoDefine.RoleSettingType.Camera},
    }

    self.IsRepeatLastCast = false
    self.IsCustomLookAt = false

    self.MajorAngleIdx = 0.5
    self.MajorAngle = 0

    self.SubUIIdx = 0

    self.ProbarIsVisibility = false
end

function PhotoRoleSettingVM:OnInit()
end

function PhotoRoleSettingVM:OnBegin()
end

function PhotoRoleSettingVM:OnEnd()
end

function PhotoRoleSettingVM:OnShutdown()
end

function PhotoRoleSettingVM:UpdateVM()
    self.CtrlTypeTree:UpdateByValues(self.CtrlTypeData)
end

function PhotoRoleSettingVM:ResetAllActorVisible()
    for _, ParentItem in pairs(self.CtrlTypeTree:GetItems() or {}) do
        ParentItem:SetEnableAll(true)
    end
end

function PhotoRoleSettingVM:SetIsRepeatLastCast(V)
    self.IsRepeatLastCast = V
end

function PhotoRoleSettingVM:SetIsCustomLookAt(V)
    self.IsCustomLookAt = V
    local NPCList = PhotoActorUtil.GetNPCs()
    for _, NPC in pairs(NPCList) do
        if V then
            ActorUtil.SetCharacterLookAtCamera(NPC, _G.UE.ELookAtType.HeadAndEye)
        else
            ActorUtil.SetCharacterLookAtCamera(NPC, _G.UE.ELookAtType.None)
        end
    end
end

function PhotoRoleSettingVM:GetTLogData()
    local T = {}
    local L1 = self.CtrlTypeTree:GetItems()
    for _, L1 in pairs(L1) do
        for _, Item in pairs(L1:AdapterOnGetChildren()) do
            table.insert(T, {
                Name = Item.Name,
                IsOn = Item.IsOpen
            })
        end
    end

    return Json.encode(T)
end

function PhotoRoleSettingVM:SetMajorAngleIdx(V, bIgRot)
    if not _G.PhotoMgr:IsCurSeltMajor() then
        local T = self.MajorAngleIdx
        self.MajorAngleIdx = nil
        self.MajorAngleIdx = T
        return
    end

    self.MajorAngleIdx = V
    local MajorAngle = V * 360 - 180
    local Major = PhotoActorUtil.GetMajor()
    local CurRotation = Major:K2_GetActorRotation()
    local AnimComp = Major:GetAnimationComponent()
    local OriYaw = CurRotation.Yaw - self.MajorAngle
    self.MajorAngle = math.floor(MajorAngle + 0.5)
    if AnimComp and not bIgRot then
        local TargetR = _G.UE.FRotator(CurRotation.Pitch, OriYaw + self.MajorAngle, CurRotation.Roll)
        AnimComp:ForceSetRotation(TargetR, 0, TargetR)
        _G.FLOG_INFO('[Photo][PhotoRoleSettingVM] Spin = ' .. tostring(OriYaw + self.MajorAngle))
    end

    -- Major:FSetRotationForServer(_G.UE.FRotator(R.Pitch, OriYaw + self.MajorAngle, R.Roll))
end

function PhotoRoleSettingVM:ResetMajorAngleIdx()
    self:SetMajorAngleIdx(0.5, false)
    self:SetIsRepeatLastCast(false)
    self:SetIsCustomLookAt(false)
end

function PhotoRoleSettingVM:SetSubUIIdx(V)
    self.SubUIIdx = V
end

function PhotoRoleSettingVM:TemplateSave(InTemplate)
    local Major = PhotoActorUtil.GetMajor()
    local R = Major:K2_GetActorRotation()
    PhotoTemplateUtil.SetActSettings(InTemplate, R.Yaw)
end

function PhotoRoleSettingVM:TemplateApply(InTemplate)
    local Info = PhotoTemplateUtil.GetActSettings(InTemplate)
    if Info then
        local Spin = Info.Spin
        if Spin then
            local Major = PhotoActorUtil.GetMajor()
            local R = Major:K2_GetActorRotation()
            local AnimComp = Major:GetAnimationComponent()
            AnimComp:ForceSetRotation(_G.UE.FRotator(R.Pitch, Spin, R.Roll), 0)
        end
    end
end

return PhotoRoleSettingVM
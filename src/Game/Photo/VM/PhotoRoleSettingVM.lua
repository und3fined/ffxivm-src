local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PhotoRoleSettingVM = LuaClass(UIViewModel)
local PhotoActorUtil = require("Game/Photo/Util/PhotoActorUtil")

local PhotoRoleSettingParentItemVM = require("Game/Photo/ItemVM/PhotoRoleSettingParentItemVM")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local UIBindableList = require("UI/UIBindableList")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local Json = require("Core/Json")

-- local ItemVM = require("Game/Item/ItemVM")

local LSTR = _G.LSTR

local PWorldQuestMgr
local PWorldMgr
local PWorldTeamMgr


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
end

function PhotoRoleSettingVM:OnInit()
end

function PhotoRoleSettingVM:OnBegin()
    -- PWorldQuestMgr = _G.PWorldQuestMgr
    -- PWorldMgr = _G.PWorldMgr
    -- PWorldTeamMgr = _G.PWorldTeamMgr
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
    local ActorUtil = require("Utils/ActorUtil")
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

-- local LastShowTime = nil
-- local function ShowTips(Content)
--     if LastShowTime then
--         local Now = TimeUtil.GetLocalTime()
--         if Now - LastShowTime <= 5 then
--             return
--         end
--     end

--     MsgTipsUtil.ShowTips(Content)
--     LastShowTime = TimeUtil.GetLocalTime()
-- end

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
    local R = Major:K2_GetActorRotation()
    local AnimComp = Major:GetAnimationComponent()

    -- local Actor = ActorUtil.GetActorByEntityID(_G.PhotoMgr.SeltEntID)
    -- if not Actor then
    --     return
    -- end

    -- local R = Actor:K2_GetActorRotation() 
    -- local AnimComp = Actor:GetAnimationComponent()

    local OriYaw = R.Yaw - self.MajorAngle
    self.MajorAngle = math.floor(MajorAngle + 0.5)


    if AnimComp and not bIgRot then
        AnimComp:ForceSetRotation(_G.UE.FRotator(R.Pitch, OriYaw + self.MajorAngle, R.Roll), 0)
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

return PhotoRoleSettingVM

local EffectUtil = require("Utils/EffectUtil")
local SettingsUtils = require("Game/Settings/SettingsUtils")

local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local EquipmentMainVM = require("Game/Equipment/VM/EquipmentMainVM")
local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local ProtoCS = require ("Protocol/ProtoCS")
local SaveKey = require("Define/SaveKey")
local CameraSettingsMgr = require("Game/CameraSettings/CameraSettingsMgr")
local CameraSettingsDefine = require("Game/CameraSettings/CameraSettingsDefine")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local ClientSetupKey = ProtoCS.ClientSetupKey
local GroupType = CameraSettingsDefine.GroupType
local ViewDistancePropType = CameraSettingsDefine.ViewDistancePropType
local FOVPropType = CameraSettingsDefine.FOVPropType
local ReboundPropType = CameraSettingsDefine.ReboundPropType
local RotatePropType = CameraSettingsDefine.RotatePropType
local SurroundPropType = CameraSettingsDefine.SurroundPropType
local TargetOffsetPropType = CameraSettingsDefine.TargetOffsetPropType
local AnimDefines = require("Game/Anim/AnimDefines")
local DataReportUtil = require("Utils/DataReportUtil")
--角色设置

local SettingsTabRole = {}

function SettingsTabRole:OnInit()
    self.StartTickTime = 0
    self.TimerID = nil
    self.bEnterIdleState = nil
end

function SettingsTabRole:OnBegin()
    --角色外观
    self.ShowWeaponIdx= 1
    self.ShowHeadIdx = 1
    self.SwitchHelmetIdx = 2
    self.bIsAutoDropWeapon = true
    self.HideWeaponTime = 5
    --角色动作
    self.ResetToIdleTime = 5
    self.bIsAutoResetPose = true
    self.JoystickControlType = 1
    --召唤物缩放
    self.SummonScale = 1;
    --相机设置
    self.ViewDis = 1;
    self.ViewDisScaleSpeed = 1;
    self.FOV = 1;
    self.CameraRotateSpeed = 1;
    self.CameraSurround = 1;
	self.CameraHeightOffset = 0
    --跳跃副摇杆
    self.EnableSpecialJump = 1
end

function SettingsTabRole:OnEnd()

end

function SettingsTabRole:OnShutdown()

end

----------------------------------  角色外观 -----------------------------------------------

--- 自动收回武器时间
function SettingsTabRole:SetResetToHoldWeaponIdleTime( Value, IsSave )
    if Value <= 1 then Value = 2 end
    if Value > 5 then Value = 5 end
    self.HideWeaponTime = Value
    _G.EmotionMgr.HideWeaponTime = self.HideWeaponTime
    if IsSave then
        _G.EmotionMgr:SetAutoFoldWeapon()
    end
end

--- 自动收回武器（Value = 1 启用）
function SettingsTabRole:SetRandomSwitchHoldWeaponPose( Value, IsSave )
    self.bIsAutoDropWeapon = Value == 1
    _G.EmotionMgr.AutoDropWeapon = self.bIsAutoDropWeapon and "1" or "0"
    if IsSave then
        _G.EmotionMgr:SetAutoFoldWeapon()
    end
end

---回收武器时显示主手装备及副手装备
function SettingsTabRole:GetShowWeapon()
    return self.ShowWeaponIdx
end

-- Idx：1 启用  2：禁用
function SettingsTabRole:SetShowWeapon( Value, IsSave )
    self.ShowWeaponIdx = Value
    EquipmentMainVM:SetIsShowWeapon(Value == 1, IsSave)

    return true
end

---显示自己的头部装备
function SettingsTabRole:GetShowHead()
    return self.ShowHeadIdx
end

-- Idx：1 启用  2：禁用
function SettingsTabRole:SetShowHead( Value, IsSave )
    self.ShowHeadIdx = Value
    EquipmentMainVM:HideHead(Value == 2, IsSave)

    return true
end

---调整自己的头部装备（仅限部分装备）   比如眼镜开关
function SettingsTabRole:GetHelmetGimmickOn()
    return self.SwitchHelmetIdx
end

-- Idx：1 启用  2：禁用
function SettingsTabRole:SetHelmetGimmickOn( Value, IsSave )
    self.SwitchHelmetIdx = Value
    EquipmentMainVM:SwitchHelmet(Value == 1, IsSave)
    
    return true
end

--- 显示情感动作气泡（Value = 1 显示   2 = 关闭）
function SettingsTabRole:SetNeedShowTips( Value, IsSave )
    self.bIsNeedShowTips = Value == 1
    _G.EmotionMgr.bIsNeedShowTips = self.bIsNeedShowTips
end

-- 显示宠物名字 1：启用  2：禁用
function SettingsTabRole:SetShowCompanionNameplate(Value, bIsSave)
	_G.CompanionMgr:SetHUDVisibilityOfAllCompanions(Value == 1, _G.UE.EHideReason.Settings)
end

function SettingsTabRole:SetShowOtherCompanions(Value, _)
	_G.UE.UCompanionComponent.SetOtherCompanionsHidden(Value == 2)
end

---------------------------------- 角色动作  -----------------------------------------------
--进出待机状态的事件通知
function SettingsTabRole:OnPlayerEnterIdleState(Params)
 
end

---------------------------------- 其他角色  -----------------------------------------------
-- 制作时是否屏蔽其他角色
function SettingsTabRole:SetCrafterHideOtherPlayers(Value, IsSave)
    _G.CrafterMgr:SetShouldHideOtherPlayer(Value, IsSave)
end

--放松等待时间
function SettingsTabRole:SetResetToIdleTime( Value, IsSave )
    self.ResetToIdleTime = Value < 2 and 2 or Value
    _G.EmotionMgr.ResetToIdleTime = self.ResetToIdleTime
    if IsSave then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        local PlayerAnimInst, PlayerAnimParam = EmotionAnimUtils.GetPlayerAnimParam(MajorEntityID)
        if PlayerAnimInst == nil then
            FLOG_ERROR("SettingsTabRole:SetResetToIdleTime Major not found!")
        else
            -- 更新参数并上报
            PlayerAnimParam[EmotionDefines.IdlePropertyNames[EmotionDefines.IdlePoseType.IDLE_TO_REST_TIME]] = self.ResetToIdleTime
	        PlayerAnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
            _G.EmotionMgr:UpdateIdleAnimParams()
        end
    end
end

--自动随机改变姿势  -- Value：1 启用  2：禁用
function SettingsTabRole:SetRandomSwitchPose( Value, IsSave )
    self.bIsAutoResetPose = Value == 1
    _G.EmotionMgr.AutoResetPose = self.bIsAutoResetPose
    if IsSave then
        _G.EmotionMgr:SetOpenAutoPose()
     end
end

--角色脚印特效
function SettingsTabRole:SetFootstepEffect(Value, IsSave)
    Value = SettingsUtils.GetDropDownListNumValue(Value, 1)
    if IsSave then
        _G.UE.USaveMgr.SetInt(SaveKey.FootstepEffect, Value, true)

        local FieldName = SettingsUtils.CurSetingCfg.SaveKey
        self[FieldName] = Value
    end

    local VisionActorList = _G.UE.UActorManager:Get():GetAllActors()
	local ActorCnt = VisionActorList:Length()
    for i = 1, ActorCnt, 1 do
		local BaseCharacter = VisionActorList:Get(i)
		if BaseCharacter ~= nil then
            BaseCharacter:SetFootstepEffectState(Value)
        end
	end

    --SettingsUtils不用再SetInt了
    return true
end

function SettingsTabRole:SetJoystickControlType(Value, IsSave, IsLoginInit, IsBySelect)
    self.JoystickControlType = Value
    _G.UE.AMajorController.SetJoystickControlType(tonumber(Value))

    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "3", "1")
    end
end

function SettingsTabRole:GetJoystickControlType()
    return self.JoystickControlType
end
function SettingsTabRole:SetSummonScale(Value)
    _G.SummonMgr:SetSummonScale(Value)
    self.SummonScale = Value
end
function SettingsTabRole:SetViewDisDisplay(Value)
    
end

function SettingsTabRole:SetViewDis(Value)
    CameraSettingsMgr:SetCameraProperty(GroupType.ViewDistance,ViewDistancePropType.CurrentValue,Value)
    self.ViewDis = Value
end
function SettingsTabRole:SetViewDisScaleSpeed(Value)
    CameraSettingsMgr:SetCameraProperty(GroupType.ViewDistance,ViewDistancePropType.ZoomSpeed,Value)
    _G.UE.USaveMgr.SetInt(SaveKey.ViewDisScaleSpeed, Value, true)
    self.ViewDisScaleSpeed = Value
end
function SettingsTabRole:SetFOV(Value)
    CameraSettingsMgr:SetCameraProperty(GroupType.FOV,FOVPropType.DefaultValue,Value)
    _G.UE.USaveMgr.SetInt(SaveKey.FOV, Value, true)
    self.FOV = Value
end 
function SettingsTabRole:SetCameraRotateSpeed(Value)
    CameraSettingsMgr:SetCameraProperty(GroupType.Rotate,RotatePropType.RotateVelocity,Value)
    _G.UE.USaveMgr.SetInt(SaveKey.CameraRotateSpeed, Value, true)
    self.CameraRotateSpeed = Value
end
function SettingsTabRole:SetCameraSurround(Value)
    CameraSettingsMgr:SetCameraProperty(GroupType.Surround,SurroundPropType.Switch,Value==1)
    _G.UE.USaveMgr.SetInt(SaveKey.CameraSurround, Value, true)
    self.CameraSurround = Value
end

function SettingsTabRole:SetCameraHeightOffset(Value)
    CameraSettingsMgr:SetCameraProperty(GroupType.TargetOffset, TargetOffsetPropType.DefaultOffsetZ, Value)
    _G.UE.USaveMgr.SetInt(SaveKey.CameraHeightOffset, Value, true)
	self.CameraHeightOffset = Value
end

-- 1开启，2关闭，默认值为2
function SettingsTabRole:GetEnableSpecialJump()
    return self.EnableSpecialJump
end

-- 1开启，2关闭，默认值为2
function SettingsTabRole:SetEnableSpecialJump(Value)
    _G.UE.USaveMgr.SetInt(SaveKey.EnableSpecialJump, Value, true)
    self.EnableSpecialJump = Value
end

function SettingsTabRole:GetDefaultLevelIndex()
     --0~4   -1:没配置
    local DefaultLevel = _G.UE.USettingUtil.GetDefaultQualityLevel()
    FLOG_INFO("##Setting Get Default QualityLevel %d", DefaultLevel)
    
    if DefaultLevel < 0 then
        DefaultLevel = 0
    end

    return DefaultLevel
end

function SettingsTabRole:GetDefaultAnimBudgetLevelIndex()
    return self:GetDefaultLevelIndex() + 1
end

function SettingsTabRole:SetAnimBudgetLevel(Value)
    _G.UE.USaveMgr.SetInt(SaveKey.AnimBudgetLevel, Value, false)
    CommonUtil.ConsoleCommand(string.format("a.Budget.MinQuality %f", AnimDefines.AnimBudgetLevels[Value] 
        or AnimDefines.AnimBudgetLevels.Defualt))
end

function SettingsTabRole:SetAutoGenAttack(Value)
    _G.SkillLogicMgr.bAutoGenSkillAttack = Value == 1
end

return SettingsTabRole
local LuaClass = require("Core/LuaClass")
local LoadingStateBase = require("Game/PWorld/MapLoadingState/LoadingStateBase")
local MajorUtil = require("Utils/MajorUtil")

--进入地图结束
local EnterMapFinishState = LuaClass(LoadingStateBase, true)

function EnterMapFinishState:Ctor()
end

function EnterMapFinishState:EnterState()
    local _ <close> = _G.CommonUtil.MakeProfileTag("EnterMapFinishState:EnterState")

    _G.PWorldMgr:NotifyEnterMapFinish()

    _G.CommonUtil.DisableShowJoyStick(false)

    local PWorldTableCfg = _G.PWorldMgr:GetCurrPWorldTableCfg()
    if PWorldTableCfg and PWorldTableCfg.MainPanelUIType ~= _G.LoginMapType.HairCut and PWorldTableCfg.MainPanelUIType ~= _G.LoginMapType.Fantasia then
        --恢复虚拟摇杆
        _G.CommonUtil.ShowJoyStick()
    end

    _G.PWorldMgr:SetMapTravelStatusEnterMapFinish()

    local CurrTime = _G.TimeUtil.GetServerTime()
    _G.FLOG_INFO("[LoadWorld cost time record] PWorldMgr EnterMapFinishState:EnterState CurrTime=%d", CurrTime)

    --处理完所有流程后再隐藏Loading
    _G.WorldMsgMgr:OnEnterMapFinish()

    -- 提审版本资源下载弹窗提示
    _G.PWorldMgr:ShowDownloadResMsgBox()

    local LoadWorldReason = _G.PWorldMgr:GetLoadWorldReason()
    --ncut切完地图后重置
    if (LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal) then
        _G.PWorldMgr:SetLoadWorldReason(_G.UE.ELoadWorldReason.Normal)
    end

    local bChangeMap = _G.PWorldMgr:IsChangeMap()
    --同地图传送loading结束后 重置角色镜头到初始化状态
    if (not bChangeMap) then
        local Major = MajorUtil.GetMajor()
        if (Major ~= nil and not Major:IsInRide()) then
            Major:GetCameraControllComponent():ResetSpringArmToDefault()
        end
    end
end

function EnterMapFinishState:ExitState()
end

return EnterMapFinishState

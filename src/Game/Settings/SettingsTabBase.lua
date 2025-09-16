-- local ProtoCS = require("Protocol/ProtoCS")
-- local GlobalCfg = require("TableCfg/GlobalCfg")
-- local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")
local SettingsCfg = require("TableCfg/SettingsCfg")
local SettingsUtils = require("Game/Settings/SettingsUtils")

local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local MajorUtil = require("Utils/MajorUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local MainPanelVM = require("Game/Main/MainPanelVM")
local DataReportUtil = require("Utils/DataReportUtil")

local MsgBoxUtil
local LSTR

local SettingsTabBase = {}

function SettingsTabBase:OnInit()

end

function SettingsTabBase:OnBegin()
    MsgBoxUtil = _G.MsgBoxUtil
    LSTR = _G.LSTR

    -- 示例：最大帧率
    --  SaveKey字段配置的是MaxFps，self.SaveKey保存的是最大帧率，不是数组的索引值；  Save的才是索引

    -- 示例：遭受敌对性质技能时自动选中目标 
    --  SaveKey字段配置的是MajorAutoSelectTarget，是索引
end

function SettingsTabBase:OnEnd()

end

function SettingsTabBase:OnShutdown()

end

--如果用这种方式，OnMajorNeedSelectAttacker内self是SettingMgr
-- function SettingsTabBase:OnRegisterGameEvent(ParentMgr)
--     ParentMgr:RegisterGameEvent(_G.EventID.MajorNeedSelectAttacker, self.OnMajorNeedSelectAttacker)
-- end

--遭受敌对性质技能时自动选中目标
function SettingsTabBase:OnMajorNeedSelectAttacker(Params)
    if Params and Params.ULongParam1 then
        -- 1：启用 2：禁用
        if self.MajorAutoSelectTarget == 1 then
            local SeltActor = _G.UE.USelectEffectMgr:Get():GetCurrSelectedTarget()
            if not SeltActor then
                FLOG_INFO("Setting Mahor Auto SelectAttacker")
                _G.SwitchTarget:SwitchToTarget(Params.ULongParam1, true)
            end
        end
    end
end

---------------------------------------------------------------------------------
---自动跳过进地图时看过一次的过场动画
function SettingsTabBase:SetAutoSkipCutScene(Value, IsSave, IsLoginInit, IsBySelect)
    _G.StoryMgr.Setting.SetAutoSkipCutScene(Value == 2, IsSave)

    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "9", "1")
    end
end

---自动跳过任务剧情动画（包括单人本过场）
function SettingsTabBase:GetAutoSkipQuestSequence()
    return _G.StoryMgr.Setting.GetAutoSkipQuestSequence() and 2 or 1
end

---自动跳过任务剧情动画（包括单人本过场）
function SettingsTabBase:SetAutoSkipQuestSequence(Value, IsSave, IsLoginInit, IsBySelect)
    _G.StoryMgr.Setting.SetAutoSkipQuestSequence(Value == 2, IsSave)

    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "10", "1")
    end
end

function SettingsTabBase:GetCurServerDesc( )
    local ret = string.format(LSTR(110024), LoginNewVM:GetCurWorldName() or "")
    return ret
end

function SettingsTabBase:ReturnToLogin( )
    if _G.PWorldVoteMgr and _G.PWorldVoteMgr:IsVoteEnterScenePending() then
        MsgTipsUtil.ShowTipsByID(146073)
        return
    end

    local function OkBtnCallback()
        _G.HotelMgr:CheckNeedPlaySeq(true)

        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "1", "1")
	end

    local function CancelCallBack()
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "1", "0")
    end

    local Tips = _G.LSTR(110002)
    if _G.PWorldMgr and _G.PWorldMgr:CurrIsInDungeon() and not _G.PWorldMgr:CurrIsInSingleDungeon() then
        Tips = LSTR(110035)
    end
    if MajorUtil.IsMajorCombat() then
        local ExParams = { RightBtnCD = 20,
            -- ["LeftTime"] = 20,
            -- ["LeftTimeStrFmt"] = LSTR(110017),
            -- ["bRightBtnBeginCountDown"] = true,
            CloseClickCB = CancelCallBack,
        }
        
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), Tips, OkBtnCallback, CancelCallBack, nil, nil, ExParams)
    else
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), Tips, OkBtnCallback, CancelCallBack, nil, nil, {CloseClickCB = CancelCallBack})
    end
end

function SettingsTabBase:GetCurRoleDesc( )
    local ret = string.format(LSTR(110034), MajorUtil.GetMajorName() or "")
    return ret
end

function SettingsTabBase:ReturnToSelectRoleView( )
    if _G.PWorldVoteMgr and _G.PWorldVoteMgr:IsVoteEnterScenePending() then
        MsgTipsUtil.ShowTipsByID(146073)
        return
    end

    local function OkBtnCallback()
        _G.HotelMgr:CheckNeedPlaySeq(false)
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "2", "1")
	end

    local function CancelCallBack()
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "2", "0")
    end

    local Tips = _G.LSTR(110003)
    if _G.PWorldMgr and _G.PWorldMgr:CurrIsInDungeon() and not _G.PWorldMgr:CurrIsInSingleDungeon() then
        Tips = LSTR(110035)
    end
    if MajorUtil.IsMajorCombat() then
        local ExParams = { RightBtnCD = 20,
            -- ["LeftTime"] = 20,
            -- ["LeftTimeStrFmt"] = LSTR(110017),
            -- ["bRightBtnBeginCountDown"] = true,
            CloseClickCB = CancelCallBack,
        }
        
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), Tips, OkBtnCallback, nil, nil, nil, ExParams)
    else
        MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), Tips, OkBtnCallback, nil, nil, nil, {CloseClickCB = CancelCallBack})
    end
end

---自动离开时间
function SettingsTabBase:GetAutoLeaveTime()
    return _G.OnlineStatusMgr:GetAutoLeaveTime()
end

--Value是index，不是离开时间
function SettingsTabBase:SetAutoLeaveTime(Value, IsSave)
    --默认十分钟
    local AutoLeaveTime = SettingsUtils.GetDropDownListNumValue(Value, 600)   
    _G.OnlineStatusMgr:SetAutoLeaveTime(AutoLeaveTime)
end

--- 场景中是否显示其他玩家的 断线重连 状态
function SettingsTabBase:GetShowElectrocardiogramInVision()
    return _G.OnlineStatusMgr:GetShowElectrocardiogramInVision() and 1 or 2
end

function SettingsTabBase:SetShowElectrocardiogramInVision(Value, IsSave)
    _G.OnlineStatusMgr:SetShowElectrocardiogramInVision(Value == 1)
end

--- 副本中是否显示其他玩家的 断线重连 状态
function SettingsTabBase:GetShowElectrocardiogramInPWorldTeam()
    return _G.OnlineStatusMgr:GetShowElectrocardiogramInPWorldTeam() and 1 or 2
end

function SettingsTabBase:SetShowElectrocardiogramInPWorldTeam(Value, IsSave)
    _G.OnlineStatusMgr:SetShowElectrocardiogramInPWorldTeam(Value == 1)
end

---遭受敌对性质技能时自动选中目标
function SettingsTabBase:SetAutoSelectCaster(Value, IsSave, IsLoginInit, IsBySelect)
    --不用额外干啥了，已经自动记录过了
    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "5", "1")
    end
end

--选中目标时开启边缘高亮效果
function SettingsTabBase:SetShowSelectOutline(Value, IsSave, IsLoginInit, IsBySelect)
    --不用额外干啥了，已经自动记录过了
end

--显示目标线
function SettingsTabBase:SetShowTargetLine(Value, IsSave, IsLoginInit, IsBySelect)
    --不用额外干啥了，已经自动记录过了
    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "6", "1")
    end
end

--显示联系线
function SettingsTabBase:SetShowRelevanceLine(Value, IsSave, IsLoginInit, IsBySelect)
    --不用额外干啥了，已经自动记录过了
    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "7", "1")
    end
end

--震屏
function SettingsTabBase:SetCameraShake(Value, IsSave)
    if Value ~= nil then
        _G.UE.UCameraMgr:Get():SetCanCameraShake(Value > 1)
        _G.UE.UCameraMgr:Get():SetCameraShakeGrade(Value)
    end
end

--场景标记
function SettingsTabBase:SetTeamSceneMarker(Value, IsSave)
    _G.SignsMgr:SetIsEnableSceneMarker(Value == 1)
end

--目标标记
function SettingsTabBase:SetTeamTargetMarker(Value, IsSave)
    _G.SignsMgr:SetIsEnableTargetMarker(Value == 1)
end

--战斗开始倒计时
function SettingsTabBase:SetTeamCountDown(Value, IsSave)
    _G.SignsMgr:SetIsEnableCountDown(Value == 1)
end

--SetSwitchTargetType
function SettingsTabBase:SetSwitchTargetType(Value, IsSave, IsLoginInit, IsBySelect)
    _G.SwitchTarget:SetSwitchType(Value)
    if IsBySelect then
        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "8", "1")
    end
end

--摇杆是否维持跑步状态
function SettingsTabBase:SetMaxSpeedConstState(Value, IsSave)
    if Value == 1 then
        _G.UE.AMajorController:OpenSpeedConst()
	else
        _G.UE.AMajorController:CloseSpeedConst()
	end
end

--地图自动寻路
function SettingsTabBase:SetAutoPathMoveState(Value, IsSave, IsLoginInit, IsBySelect)
    _G.AutoPathMoveMgr:SetAutoPathMoveEnable(Value == 1)
    if IsBySelect then
        DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.SettingsAutoPathMove), tostring(Value == 1))
    end
end

--主界面右下角时间栏
function SettingsTabBase:SetMainPanelIsTimeBarVisible(Value, IsSave)
    MainPanelVM:SetTimeBarVisible(1 == Value)
end

--主界面仇恨列表
function SettingsTabBase:SetMainPanelIsEnmityPanelVisible(Value, IsSave)
    MainPanelVM:SetEnmityPanelVisible(1 == Value)
end

--主界面仇恨列表
function SettingsTabBase:SetMemberFlyTextVisible(Value, IsSave)
    _G.HUDMgr:SetMemberFlyTextVisible(1 == Value)
end

--省电模式
function SettingsTabBase:SetPowerSavingMode(Value, IsSave)
    local EnterTime = SettingsUtils.GetDropDownListNumValue(Value, 0)
    _G.PowerSavingMgr:SetEnable(EnterTime)
end

return SettingsTabBase
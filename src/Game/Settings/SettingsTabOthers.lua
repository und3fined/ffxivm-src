
local SettingsUtils = require("Game/Settings/SettingsUtils")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local PworldCfg = require("TableCfg/PworldCfg")
local MsgTipsID = require("Define/MsgTipsID")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")
local UIDefine = require("Define/UIDefine")
local AccountUtil = require("Utils/AccountUtil")
local OperationUtil = require("Utils/OperationUtil")
local CommBtnColorType = UIDefine.CommBtnColorType

local LSTR = _G.LSTR
--其他设置

local SettingsTabOthers = {}

function SettingsTabOthers:OnInit()
    self.UploadLogTimer = nil
end

function SettingsTabOthers:OnBegin()
end

function SettingsTabOthers:OnEnd()

end

function SettingsTabOthers:OnShutdown()

end

----------------------------------  其他设置 -----------------------------------------------
---其他页签：脱离卡死
function SettingsTabOthers:SendLeaveReq()

    local CurrPWorldResID = PWorldMgr:GetCurrPWorldResID()
    local CanLeave = PworldCfg:FindValue(CurrPWorldResID, "CanLeaveStuck")

    if CanLeave == 0 then
        _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldLeaveStuck, nil)
        -- _G.MsgTipsUtil.ShowTips("当前副本不支持脱离卡死")
        return
    end
    local Params = { LeftBtnStyle = CommBtnColorType.Normal, RightBtnStyle = CommBtnColorType.Normal }
    local CdTimeText = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_MOVE_RESET_TIME, "Value")[1] or "0"
    local HintText = string.format(_G.LSTR(110001), CdTimeText) 
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(10004), HintText,
                                function()
                                        local MsgID = ProtoCS.CS_CMD.CS_CMD_MOVE
                                        local SubMsgID = ProtoCS.CS_SUBMSGID_MOVE.CS_SUB_CMD_MOVE_RESET
                                        local MsgBody = { SubCmd = SubMsgID }
                                        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
                                        --设置面板中的脱离卡死功能使用上报
                                        DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.SettingsLeave), tostring(CurrPWorldResID))
                                        DataReportUtil.ReportSettingClickFlowData("SetUpClickFlow", "1", "4", "1")

                                        _G.UIViewMgr:HideView(UIViewID.Settings)
                                        _G.UIViewMgr:HideView(UIViewID.Main2ndPanel)
                                end, nil, _G.LSTR(10003), _G.LSTR(10002), Params)
end

----------------------------------   -----------------------------------------------

function SettingsTabOthers:UpLoadLog()
    _G.UE.ULogMgr.SetEnableCharaterTickLogOnceTime(true)
    _G.InteractiveMgr:SetEnablePrintCheckLog(true)
    if not self.UploadLogTimer then
        self.UploadLogTimer = _G.TimerMgr:AddTimer(self, function()
            _G.UE.ULogMgr.SetEnableCharaterTickLogOnceTime(false)
            _G.InteractiveMgr:SetEnablePrintCheckLog(false)
            if self.UploadLogTimer then
                _G.TimerMgr:CancelTimer(self.UploadLogTimer)
                self.UploadLogTimer = nil
            end
            _G.LevelRecordMgr:UpLoadLog()
        end, 0.1, 0, 1)
    end
end

function SettingsTabOthers:OpenFeedback(Value)
    OperationUtil.OpenFeedback()
end

function SettingsTabOthers:OpenCDKeyEchangeView()
    _G.UIViewMgr:ShowView(UIViewID.CDKeyExchangeView)
end

function SettingsTabOthers:DeleteAccount()
    --AccountUtil.DeleteAccount()
    local function Callback()
        _G.LoginMgr.IsAccountCancellation = true
        _G.LoginMgr:ReturnToLogin(true)
    end

    -- 470133 账号注销
    -- 470150 是否要开始账号注销流程？点击确认将会退出游戏至登录界面，并开始检查是否符合注销条件。
    -- 10002 确认
    -- 10003 取消
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(470133), LSTR(470150), Callback, nil, LSTR(10003), LSTR(10002))
end

function SettingsTabOthers:SetShowSkillTips(Value, _)
    SkillTipsMgr.bDisableMajorTips = Value == 2
end

function SettingsTabOthers:OpenGameBot()
    OperationUtil.OpenGameBot("yinsihegui")
end

return SettingsTabOthers
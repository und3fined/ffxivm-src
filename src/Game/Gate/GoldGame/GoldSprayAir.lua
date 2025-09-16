--[[
Author: lightpaw_Leo, michaelyang_lightpaw
Date: 2023-10-17 14:35:12
Description: 喷风幸存者小游戏
--]]
local LuaClass = require("Core/LuaClass")
local GoldGameNewBase = require("Game/Gate/GoldGame/GoldGameNewBase")
local AnyWayWindBlowsCfg = require("TableCfg/AnyWayWindBlowsCfg")
local ProtoCS = require("Protocol/ProtoCS")

local LSTR = _G.LSTR

-- 常量定义
local MAX_STAGE = 5
local COUNTDOWN_RED_TIME = 10
local DEFAULT_COINS = 100
local AVOID_TEXT_FORMAT = LSTR(1270001) -- "规避成功：%s/%s"
local GOLD_TEXT_FORMAT = LSTR(1270002) -- "当前获得的金碟币：%s"

---@class GoldSprayAir
local GoldSprayAir = LuaClass(GoldGameNewBase)

function GoldSprayAir:Ctor()
end

---@param InGameVM    Type GoldSauserVM
---@param InGameState Type ProtoCS.GoldSauserEntertainState
---@return  Type Description
function GoldSprayAir:OnRefreshInfoWhenStateChange(InGameMgr, InGameVM, InGameState)
    if (InGameState == ProtoCS.GoldSauserEntertainState.GoldSauserEntertainState_SignUp) then
        InGameVM.bShowPanelAvoid = false
        InGameVM.bShowPanelGet = false
        InGameVM.bActivityDescVisible = true
        InGameVM.bShowPanelCountdown = true
    else
        InGameVM.bShowPanelAvoid = true
        InGameVM.bShowPanelGet = true
        InGameVM.bActivityDescVisible = false
        InGameVM.bShowPanelCountdown = false
    end

    self:UpdateDisplayText(InGameVM, 0, 0)
end

-- 弹出倒计时的时间，需要的话，覆写一下，返回大于0的时间即可
function GoldSprayAir:OnGetTimeCountDownRedTime()
    return COUNTDOWN_RED_TIME
end

-- 子类用，服务器推送数据变化，目前是喷风和快刀在用
function GoldSprayAir:OnNetUpdateGameData(InMsgData, InGameMgr, InGameVM)
    local Stage = InMsgData.Stage
    local Cfg = AnyWayWindBlowsCfg:FindCfgByKey(Stage)

    if not Cfg then
        _G.FLOG_ERROR("AnyWayWindBlowsCfg 配置缺失, Stage=%s", Stage)
        self:UpdateDisplayText(InGameVM, Stage, DEFAULT_COINS)
        return
    end

    self:UpdateDisplayText(InGameVM, Stage, Cfg.Coins)
end

-- 统一更新显示文本
function GoldSprayAir:UpdateDisplayText(InGameVM, InStage, InCoins)
    InGameVM.AvoidText = string.format(AVOID_TEXT_FORMAT, InStage, MAX_STAGE)
    InGameVM.GoldText = string.format(GOLD_TEXT_FORMAT, InCoins)
end

return GoldSprayAir

--[[
Author: v_hggzhang <v_hggzhang@tencent.com>
Date: 2024-09-18 09:51:02
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-10-14 11:04:16
FilePath: \Script\Game\PWorld\Entrance\PWorldEntDefine.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode
local MsgTipsID = require("Define/MsgTipsID")
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

local Define = {
    RandMatchMaxCnt = 1,
    NormMatchMaxCnt = 5,
    PVPMatchMaxCnt = 2,
    MatchRankUpdInv = 15,

    RewardType = {
        Norm = 1,
        FewFunc = 2,
        DailyRandom = 3,
        FirstPass = 4,
        Weekly = 5,
    },

    SneceModeName = MakeLSTRDict({
        [MakeLSTRAttrKey(SceneMode.SceneModeNormal)] = 1320071,
        [MakeLSTRAttrKey(SceneMode.SceneModeChallenge)] = 1320072,
        [MakeLSTRAttrKey(SceneMode.SceneModeUnlimited)] = 1320073,
        [MakeLSTRAttrKey(SceneMode.SceneModeExplore)] = 1320074,
    }, true),

    MatchTestRlt = {
        Pass = 1,
        RandMatchOverflow = MsgTipsID.PWorldMatchRandMatchOverflow,
        NormMatchOverflow = MsgTipsID.PWorldMatchNormMatchOverflow,
        PoolTypeFromRandToNorm = MsgTipsID.PWorldMatchPoolTypeFromRandToNorm,
        PoolTypeFromNormToRand = MsgTipsID.PWorldMatchPoolTypeFromNormToRand,
        ChocoboMatchOverflow = MsgTipsID.PWorldMatchChocoboMatchOverflow,
        PoolTypePVPMutex = MsgTipsID.PWorldMatchPoolTypePVPMutex,
        PVPMatchOverflow = MsgTipsID.PWorldPVPMatchOverflow,
    },

    JoinErrorCode = {
        CodeMatchProfMismatchCondition = 146020,
        CodeMatchTeammetaPunishment = 146022,
        CodeMatchTeammetaLvNotEnough = 146023,
        CodeMatchChocoboTeamRestriction = 304002,
    },

    PublishInv = function()
        local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_MATCH_PUNISHMENT_TIME, "Value")
        if Cfg then
            return Cfg[1] or 60
        end

        return 60
    end,

    EntType = {
        DailyRandom = 1,
        Maze = 2,
        Annihilate = 3,
        LargeTask = 4,
    },
    
    ChocoboRandomTrackBannerImagePath = "Texture2D'/Game/UI/Texture/PWorld/Banner/UI_PWorld_Banner_PWorldList_LXNJSSJSD.UI_PWorld_Banner_PWorldList_LXNJSSJSD'",
    ChocoboRandomTrackDetailsImagePath = "Texture2D'/Game/UI/Texture/PWorld/BG/Details/UI_PWorld_BG_Details_LXNJSSJSD.UI_PWorld_BG_Details_LXNJSSJSD'",
    ChocoboRandomTrackMatchImagePath = "Texture2D'/Game/UI/Texture/PWorld/BG/Match/UI_PWorld_BG_Match_LXNJSSJSD.UI_PWorld_BG_Match_LXNJSSJSD'",
}

return Define
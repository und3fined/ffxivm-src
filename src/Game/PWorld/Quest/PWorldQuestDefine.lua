--[[
Author: jususchen jususchen@tencent.com
Date: 2024-05-20 17:56:27
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-06-13 14:40:22
FilePath: \Script\Game\PWorld\Quest\PWorldQuestDefine.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local ProtoCommon = require("Protocol/ProtoCommon")
local SceneMode = ProtoCommon.SceneMode
local LSTR = _G.LSTR
local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

local ClientSceneMode =
{
    SceneModeChocboRank = 998, --陆行鸟段位赛
    SceneModeChocoboRoom = 999, --陆行鸟开房间模式
}

local M = {
    -- GiveUpInv = 10,
    -- ExitInv = 10,
    -- VoteExileInv = 10,

    TestPworldID = 1211008,

    -- PWorldVoteMember.Status = 2;   // 状态： 0-未投票 1-赞成 2-反对
    OpDef = {
        InValid     = -1,
        Nil         = 0,
        Accept      = 1,
        Reject      = 2,
    },

    -- 副本开启模式
    --enum SceneMode {
    --    SceneModeNormal = 0 [(org.xresloader.enum_alias) = "常规"];         // 常规
    --    SceneModeChallenge = 1 [(org.xresloader.enum_alias) = "挑战"];      // 挑战
    --    SceneModeUnlimited = 2 [(org.xresloader.enum_alias) = "解除限制"];  // 解除限制
    --    SceneModeExplore = 3 [(org.xresloader.enum_alias) = "自由探索"];    // 自由探索
    --    SceneModeStory = 4 [(org.xresloader.enum_alias) = "剧情辅助"];      // 剧情辅助
    --}
    --  注意：该枚举在上述枚举 "SceneMode"（前后台共用枚举）的基础上添加前台自己的枚举，
    --  已有枚举满足不了前台需求，但是对于后台来说都一样，不方便添加枚举，eg：对于后台来说开房间类型就是常规类型
    ClientSceneMode = ClientSceneMode,
    
    -- 副本选项
    TaskIdx2Type = {
        [1] = SceneMode.SceneModeNormal,
        [2] = SceneMode.SceneModeChallenge,
        [3] = SceneMode.SceneModeUnlimited,
        [4] = ClientSceneMode.SceneModeChocboRank,
        [5] = ClientSceneMode.SceneModeChocoboRoom,
    },
    TaskType2Idx = {
        SceneModeNormal = 1,
        SceneModeChallenge = 2,
        SceneModeUnlimited = 3,
        SceneModeChocboRank = 4,
        SceneModeChocoboRoom = 5,
    },

    SceneModeIconDef = {
        [SceneMode.SceneModeChallenge] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_TZ_png.UI_PWorld_Icon_Style_TZ_png",
        [SceneMode.SceneModeUnlimited] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_JCXZ_png.UI_PWorld_Icon_Style_JCXZ_png",
        [SceneMode.SceneModeExplore] = "/Game/UI/Atlas/Team/Frames/UI_Team_Search_Icon_ZYTS_png.UI_Team_Search_Icon_ZYTS_png",
        [SceneMode.SceneModeNormal] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_CG_png.UI_PWorld_Icon_Style_CG_png",
        [ClientSceneMode.SceneModeChocboRank] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_DWS_png.UI_PWorld_Icon_Style_DWS_png",
        [ClientSceneMode.SceneModeChocoboRoom] = "/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_Style_FJDJ_png.UI_PWorld_Icon_Style_FJDJ_png",
    },

    SceneModeNameDef = MakeLSTRDict({
        [MakeLSTRAttrKey(SceneMode.SceneModeNormal)] = 1320071,
        [MakeLSTRAttrKey(SceneMode.SceneModeChallenge)] = 1320072,
        [MakeLSTRAttrKey(SceneMode.SceneModeUnlimited)] = 1320073,
        [MakeLSTRAttrKey(SceneMode.SceneModeExplore)] = 1320074,
        [MakeLSTRAttrKey(ClientSceneMode.SceneModeChocboRank)] = 1320101,
        [MakeLSTRAttrKey(ClientSceneMode.SceneModeChocoboRoom)] = 1320102,
    }, true),

    GiveUpInv = function()
        local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SCENE_GIVEUP_CD, "Value")
        if Cfg then
            return Cfg[1] or 30
        end

        return 30
    end,

    ExitInv = function()
        local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SCENE_GIVEUP_CD, "Value")
        if Cfg then
            return Cfg[1] or 30
        end

        return 30
    end,

    VoteExileInv = function()
        local Cfg = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SCENE_VOTE_KICK_CD, "Value")
        if Cfg then
            return Cfg[1] or 30
        end

        return 30
    end,
}

function M.Init()
    
end

return M
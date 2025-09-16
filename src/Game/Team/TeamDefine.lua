--[[
Author: jususchen jususchen@tencent.com
Date: 2025-03-03 19:13:15
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-05 11:20:20
FilePath: \Script\Game\Team\TeamDefine.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")
local FUNCTION_TYPE = ProtoCommon.function_type
local LSTR = _G.LSTR
local MakeLSTRAttrKey = require("Common/StringTools").MakeLSTRAttrKey
local MakeLSTRDict = require("Common/StringTools").MakeLSTRDict

local ProfChgEffect = "VfxBlueprint'/Game/Assets/Effect/Particles/PlayerCommon/VBP/BP_classchng_sp1t.BP_classchng_sp1t_C'"
local ProfChgSound = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Scholar/Play_SE_Vfx_Etc_JobChange.Play_SE_Vfx_Etc_JobChange'"

local MaxMemberNum = 8

local ModuleType = {
    Team    = 1, --队伍
    Recruit = 2, --招募
}

local ModuleList = {
    MakeLSTRDict({
        Type = ModuleType.Team,
        [MakeLSTRAttrKey("Name")] = 1300038,
        IconPath = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_Team_png.UI_Team_Icon_Team_png'"
    }),
    MakeLSTRDict({
        Type = ModuleType.Recruit,
        [MakeLSTRAttrKey("Name")] = 1300039,
        ModuleID = ProtoCommon.ModuleID.ModuleIDTeamRecruit,
        IconPath = "PaperSprite'/Game/UI/Atlas/Team/Frames/UI_Team_Icon_Recruit_png.UI_Team_Icon_Recruit_png'"
    }),
}

local TeamMemberEmptyItemBg = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_PlayerBg_Lock.UI_Team_Image_PlayerBg_Lock'"
local TeamMemberItemBgEnum = {
    [FUNCTION_TYPE.FUNCTION_TYPE_GUARD]      = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_PlayerBg_Blue.UI_Team_Image_PlayerBg_Blue'",     --防护
    [FUNCTION_TYPE.FUNCTION_TYPE_ATTACK]     = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_PlayerBg_Red.UI_Team_Image_PlayerBg_Red'",   --进攻
    [FUNCTION_TYPE.FUNCTION_TYPE_RECOVER]    = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_PlayerBg_Green.UI_Team_Image_PlayerBg_Green'",     --回复
    [FUNCTION_TYPE.FUNCTION_TYPE_PRODUCTION] = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_PlayerBg_Grey.UI_Team_Image_PlayerBg_Grey'",   --制造
    [FUNCTION_TYPE.FUNCTION_TYPE_GATHER]     = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_PlayerBg_Grey.UI_Team_Image_PlayerBg_Grey'",   --采集
}

local InviteItemType = {
    All     = 1,
    Nearby  = 2,
    Friend  = 3,
    Tribe   = 4,
}

local InviteFilterTypes = {
    MakeLSTRDict({
        Type = InviteItemType.All,
        [MakeLSTRAttrKey("Name")] = 1300040,
    }),
    MakeLSTRDict({
        Type = InviteItemType.Nearby,
        [MakeLSTRAttrKey("Name")] = 1300041,
    }),
    MakeLSTRDict({
        Type = InviteItemType.Friend,
		[MakeLSTRAttrKey("Name")] = 1300042,
    }),
    MakeLSTRDict({
        Type = InviteItemType.Tribe,
		[MakeLSTRAttrKey("Name")] = 1300043,
    }),
} 

---@deprecated
local ParentInviteItemConfig = {
    MakeLSTRDict({
        Type = InviteItemType.Nearby,
        [MakeLSTRAttrKey("Name")] = 1300041,
        IsAutoExpand = true,
        Children = { }
    }),
	MakeLSTRDict({
        Type = InviteItemType.Friend,
        [MakeLSTRAttrKey("Name")] = 1300042,
        IsAutoExpand = true,
        Children = { }
    }),
	MakeLSTRDict({
        Type = InviteItemType.Tribe,
        [MakeLSTRAttrKey("Name")] = 1300043,
        IsAutoExpand = true,
        Children = { }
    }),
}

local InviteItemBgEnum = {
    [FUNCTION_TYPE.FUNCTION_TYPE_GUARD]      = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_TankBg.UI_Team_Image_TankBg'",     --防护
    [FUNCTION_TYPE.FUNCTION_TYPE_ATTACK]     = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_FightBg.UI_Team_Image_FightBg'",   --进攻
    [FUNCTION_TYPE.FUNCTION_TYPE_RECOVER]    = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_HealBg.UI_Team_Image_HealBg'",     --回复
    [FUNCTION_TYPE.FUNCTION_TYPE_PRODUCTION] = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_ProduceBg.UI_Team_Image_ProduceBg'",   --制造
    [FUNCTION_TYPE.FUNCTION_TYPE_GATHER]     = "Texture2D'/Game/UI/Texture/Team/UI_Team_Image_ProduceBg.UI_Team_Image_ProduceBg'",   --采集
}

local TeamAttrAddClassType = {
    ProtoCommon.class_type.CLASS_TYPE_TANK,
    ProtoCommon.class_type.CLASS_TYPE_NEAR,
    ProtoCommon.class_type.CLASS_TYPE_FAR,
    ProtoCommon.class_type.CLASS_TYPE_MAGIC,
    ProtoCommon.class_type.CLASS_TYPE_HEALTH,
}

local ViewsToUpdateTeamPos = {
    UIViewID.WorldMapPanel,
}

local TeamPosUpdateInterval = 2 --seconds

local VoteType = {
    BEST_PLAYER     =   1,      --最佳队员
    EXPEL_PLAYER    =   2,      --驱逐队员
    TASK_GIVEUP     =   3,      --放弃任务
}

local InviteReuseType = {
    INVITE = 1,
    SHARE = 2,
}

local TeamDefine = {
    ProfChgEffect           = ProfChgEffect,
    ProfChgSound            = ProfChgSound,
    MaxMemberNum            = MaxMemberNum,
    ModuleType              = ModuleType,
    ModuleList              = ModuleList,
    TeamMemberEmptyItemBg   = TeamMemberEmptyItemBg,
    TeamMemberItemBgEnum    = TeamMemberItemBgEnum,
    InviteItemType          = InviteItemType,
    InviteFilterTypes       = InviteFilterTypes,
    ParentInviteItemConfig  = ParentInviteItemConfig,
    InviteItemBgEnum        = InviteItemBgEnum,
    TeamAttrAddClassType    = TeamAttrAddClassType,
    ViewsToUpdateTeamPos    = ViewsToUpdateTeamPos,
    TeamPosUpdateInterval   = TeamPosUpdateInterval,
    VoteType                = VoteType,
    InviteReuseType         = table.makeconst(InviteReuseType),
}

return TeamDefine
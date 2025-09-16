--
-- Author: sammrli
-- Date: 2024-4-4
-- Description:陆行鸟运输定义
--

local ProtoRes = require("Protocol/ProtoRes")
local ChocoboTransportCfg = require("TableCfg/ChocoboTransportCfg")

local ENUM_CHOCOBO_TRANSPORT_GLOBAL_TYPE = ProtoRes.ENUM_CHOCOBO_TRANSPORT_GLOBAL_TYPE

local ChocoboTransportDefine =
{
    NEAR_RANGE = 200, --运输靠近Npc下坐骑距离(厘米)
    NPC_WELCOME_RANGE = 500, --陆行鸟Npc打招呼距离(厘米)
    TIME_LINE_WELCOME_HAD_TRACK_QUEST = 697,
    TIME_LINE_WELCOME_NO_HAD_TRACK_QUEST = 764,
    TIME_LINE_LEAVE_WITH_CHOCOBO = 705,
    TIME_LINE_CHOCOBO_LEAVE = 966,
    TIME_LINE_CHOCOBO_START = 966,
    TIME_LINE_CHOCOBO_SPEED_UP_LIST = {
        [1] = { ID=4063, Rate = 1.2, BlendInTime = 0.1, BlendOutTime = 0.1},
        [2] = { ID=4059, Rate = 1.4, BlendInTime = 0.1, BlendOutTime = 0.1},
    }, --加速动作
    TIME_LINE_CHOCOBO_NORMAL_MOVE = 4059,
    LATER_PLAY_ANIMATION = 0.1, --抵达后多久开始播放抵达动画
    LEAVE_ANIMATION_DURTION_TIME = 3.0, --陆行鸟抵达终点播放动画持续时间
    START_ANIMATION_DURTION_TIME = 3.0, --陆行鸟出发前播放动画持续时间
    ICON_STATUS = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061534_png.UI_Icon_061534_png'", --状态图标
    ICON_HUD = "PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Activation_png.UI_ChocoboTransport_Icon_BirdRoom_Activation_png'", --头顶图标
    ICON_UNBOOK_HUD = "PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Normal_png.UI_ChocoboTransport_Icon_BirdRoom_Normal_png'", --未登记头顶图标
    ICON_ACTIVE_MARKER = "PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Activation_png.UI_ChocoboTransport_Icon_BirdRoom_Activation_png'", --陆行鸟栏地图标记激活图标
    ICON_UNACTIVE_MARKER = "PaperSprite'/Game/UI/Atlas/ChocoboTransport/Frames/UI_ChocoboTransport_Icon_BirdRoom_Normal_png.UI_ChocoboTransport_Icon_BirdRoom_Normal_png'", --陆行鸟栏地图标记未激活图标
    BUFFER_ID_TRANSPORTING = 9117,  --运输中buffer
    BUFFER_ID_SPEED_UP = 6051,      --加速buffer
    BOOK_SUCCESS_SOUND = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_Zingle_Unlock.Play_Zingle_Unlock'", --登记成功音效
    ACCELERATION_SKILL_SOUND = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/etc/SE_Vfx_Etc_CR_Abi_Dash/Play_SE_Vfx_Etc_CR_Abi_Dash.Play_SE_Vfx_Etc_CR_Abi_Dash'", --使用加速音效
    ARRIVING_SOUND = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_GamePrompt.Play_FM_GamePrompt'", --抵达音效
    SPEED_VFX_PATH = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/Common/VBP/BP_croth_dush0c.BP_croth_dush0c'", --加速特效
    MOUNT_RES_ID = 3, --陆行鸟ID
    USE_CLIENT_MOUNT = false, --使用客户端坐骑(如果服务器不想控制改为客户端控制)
    ACCE_SKILL_SPEED_MULTIPLE = 1.25, --加速技能速度倍率
    TIME_ACCE_SKILL_CD = 30, --加速技能CD
    TIME_ACCE_SKILL_DURTION = 10, --加速技能持续时间
    TIME_JUMP_SKILL_CD = 1.1, --跳跃技能CD
    TICK_INTERVAL = 0.0333, --tick一次时间间隔
    CAN_TRANSPORT_MIN_DISTANCE = 5000, --允许运输最小距离
    DEFAULT_FINISH_SAFE_DISTANCE = 500, --运输到目的地的默认安全距离（避免和目的地重合）
    TRANSFER_LINE_SAFE_DISTANCE = 2000, --运输到传送带的安全距离
    FIND_PATH_CACHE = false, --寻路缓存
    MAX_STEP_HEIGHT = 60, --陆行鸟运输的步高
    BOOK_SUCCESS_TIP_ID = 306206, --登记成功TipID
    START_TRANSPORT_TIP_ID = 306207, --开始运输TipID
    WEAK_NETWORK_TIP_ID = 306208, --弱网TipID
    CANNOT_ARRIVE_TIP_ID = 306209, --不可抵达TipID
    CHECK_BLOCK_SECOND = 3,  --判定为被阻挡时间
    DEFAULT_ACCELERATION_SKILL_ID = 60028, --默认加速技能ID
    QUEST_TRANSFER_OFFSET_X = -60, 	-- 任务运输需要偏移

    TargetChocoboFeeNeverMindTipSelect = 0, --陆行鸟运输Qte本次登录不再提示
}

function ChocoboTransportDefine:LoadCfg()
    local AllCfgItem = ChocoboTransportCfg:FindAllCfg()
    for _, CfgItem in ipairs(AllCfgItem) do
        if CfgItem.ID == ENUM_CHOCOBO_TRANSPORT_GLOBAL_TYPE.ENUM_CHOCOBO_TRANSPORT_GLOBAL_ACC_CD then
            self.TIME_ACCE_SKILL_CD = CfgItem.Param
        elseif CfgItem.ID == ENUM_CHOCOBO_TRANSPORT_GLOBAL_TYPE.ENUM_CHOCOBO_TRANSPORT_GLOBAL_ACC_RATIO then
            self.ACCE_SKILL_SPEED_MULTIPLE = CfgItem.Param
        elseif CfgItem.ID == ENUM_CHOCOBO_TRANSPORT_GLOBAL_TYPE.ENUM_CHOCOBO_TRANSPORT_GLOBAL_ACC_TIME then
            self.TIME_ACCE_SKILL_DURTION = CfgItem.Param
        end
    end
end

return ChocoboTransportDefine
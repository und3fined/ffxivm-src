local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
-- local InteractivedescCfg = require("TableCfg/InteractivedescCfg")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local FunctionItemFactory = require("Game/Interactive/FunctionItemFactory")
local ProtoRes = require("Protocol/ProtoRes")
local LifeSkillConfig = require("Game/Skill/LifeSkillConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfg = require("TableCfg/ItemCfg")
local EffectUtil = require("Utils/EffectUtil")
local AudioUtil = require("Utils/AudioUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewID = require("Define/UIViewID")
local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local MsgTipsID = require("Define/MsgTipsID")
local MathUtil = require("Utils/MathUtil")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local MainPanelVM = require("Game/Main/MainPanelVM")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

-- local AnimDefines = require("Game/Anim/AnimDefines")
local RecipetoolAnimCfg = require("TableCfg/RecipetoolAnimatiomCfg")
local LifeskillEffectCfg = require("TableCfg/LifeskillEffectCfg")
local MapCfg = require("TableCfg/MapCfg")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local LifeSkillConditionCfg = require("TableCfg/LifeSkillConditionCfg")

--收藏品玩法相关的尽量放到CollectionMgr了，尽量和常规采集分离
local CollectionMgr = require("Game/Gather/CollectionMgr")
local RPNGenerator = require ("Game/Skill/SelectTarget/RPNGenerator")

local MsgBoxUtil = require("Utils/MsgBoxUtil")
local EntranceGather = require("Game/Interactive/EntranceItem/EntranceGather")

local GatheringJobPanelVM = require("Game/GatheringJob/GatheringJobPanelVM")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local MainPanelVM = require("Game/Main/MainPanelVM")

local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local GatherActionID = 22

local MountVM = require("Game/Mount/VM/MountVM")
local FLOG_WARNING = _G.FLOG_WARNING
local CS_CMD = ProtoCS.CS_CMD
local CS_SUB_CMD = ProtoCS.CS_LIFE_SKILL_CMD
local GATHERPOINTTYPE = ProtoRes.GATHER_POINT_TYPE
local LSTR = _G.LSTR
local GatherActorType = _G.MapEditorActorConfig.Gather.ActorType

local GatherMgr = LuaClass(MgrBase)
--对外接口在下面，内部接口/事件响应/网络消息响应在上面

GatherMgr.DelayResultDisplayTime = 0.5

local EndActionTime = 1
local InputRangeCheckValue = 0.25

--一级交互的配置
GatherMgr.GatherInteractiveConfig = {
    [1] = {Icon = "Texture2D'/Game/Assets/Icon/Job/UI_Icon_Job_MIN.UI_Icon_Job_MIN'"},
    [2] = {Icon = "Texture2D'/Game/Assets/Icon/Job/UI_Icon_Job_MIN.UI_Icon_Job_MIN'"},
    [3] = {Icon = "Texture2D'/Game/Assets/Icon/Job/UI_Icon_Job_BTN.UI_Icon_Job_BTN'"},
    [4] = {Icon = "Texture2D'/Game/Assets/Icon/Job/UI_Icon_Job_BTN.UI_Icon_Job_BTN'"}
    -- [1] = "采掘",
    -- [2] = "碎石",
    -- [3] = "采伐",
    -- [4] = "割草",
    -- GATHER_POINT_TYPE_MINE = 1 [(org.xresloader.enum_alias) = "采掘"];
    -- GATHER_POINT_TYPE_STONE = 2 [(org.xresloader.enum_alias) = "碎石"];
    -- GATHER_POINT_TYPE_WOOD = 3 [(org.xresloader.enum_alias) = "采伐"];
    -- GATHER_POINT_TYPE_GRASS = 4 [(org.xresloader.enum_alias) = "割草"];
}

--主副武器
GatherMgr.GatherTypeIconConfig = {
    [1] = {Icon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_StonePickaxe_Normal_png.UI_GatheringJob_Btn_StonePickaxe_Normal_png'"
        , DisableIcon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_StonePickaxe_Disabled_png.UI_GatheringJob_Btn_StonePickaxe_Disabled_png'"},
    [2] = {Icon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Hammer_Normal_png.UI_GatheringJob_Btn_Hammer_Normal_png'"
        , DisableIcon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Hammer_Disabled_png.UI_GatheringJob_Btn_Hammer_Disabled_png'"},
    [3] = {Icon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Axe_Normal_png.UI_GatheringJob_Btn_Axe_Normal_png'"
        , DisableIcon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Axe_Disabled_png.UI_GatheringJob_Btn_Axe_Disabled_png'"},
    [4] = {Icon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Sickle_Normal_png.UI_GatheringJob_Btn_Sickle_Normal_png'"
        , DisableIcon = "PaperSprite'/Game/UI/Atlas/GatheringJob/Frames/UI_GatheringJob_Btn_Sickle_Disabled_png.UI_GatheringJob_Btn_Sickle_Disabled_png'"},
}

GatherMgr.GatherTypeName = {
    [1] = LSTR(160036), --"采掘"
    [2] = LSTR(160037), --"碎石"
    [3] = LSTR(160038), --"采伐"
    [4] = LSTR(160039) --"割草"
}

--每个职业的配置
GatherMgr.ProfConfig = {
    --采矿工
    [ProtoCommon.prof_type.PROF_TYPE_MINER] = {
        --普攻按钮ICON替换为采集笔记GatherMgr.MNoteRtrPath
        NoteRtrPath = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900170.UI_Icon_900170'",
        RedRedNoteRtrPath = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900157.UI_Icon_900157'",
        NormalSkillIcon = "Texture2D'/Game/Assets/Icon/002000/UI_Icon_002070.UI_Icon_002070'",
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_MINE,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_MINE,
        --1：成功 2：miss 3：收藏品 4：优质采集
        MainSkillEffect = {
            --挖掘
            --[1] = "ParticleSystem'/Game/Assets/Effect/Particles/Crafter/GAT/PS_gat_smt_ok.PS_gat_smt_ok'",
            [1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_smt_ok.BP_gat_smt_ok'",
            [2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_smt_ng.BP_gat_smt_ng'",
            [3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_smt_re.BP_gat_smt_re'",
            [4] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_smt_rg.BP_gat_smt_rg'"
        },
        --1：成功 2：miss 3：隐藏解除 4：优质采集
        MainSkillSound = {
            --挖掘
            [1] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Pecker_success_P.Play_SE_VFX_Live_Mining_Pecker_success_P'",
            [2] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Pecker_fail_P.Play_SE_VFX_Live_Mining_Pecker_fail_P'",
            [3] = "",
            [4] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Pecker_successHQ_P.Play_SE_VFX_Live_Mining_Pecker_successHQ_P'"
        },
        --1：成功 2：miss 3：收藏品 4：优质采集
        SecondSkillEffect = {
            --碎石
            [1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_ok.BP_gat_sst_ok'",
            [2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_ng.BP_gat_sst_ng'",
            [3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_re.BP_gat_sst_re'",
            [4] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_rg.BP_gat_sst_rg'"
            --[1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_ok.BP_gat_sst_ok'",
            --[2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_ng.BP_gat_sst_ng'",
            --[3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_re.BP_gat_sst_re'",
            --[4] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_sst_rg.BP_gat_sst_rg'"
        },
        --1：成功 2：miss 3：隐藏解除 4：优质采集
        SecondSkillSound = {
            --碎石
            [1] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Hummer_success_P.Play_SE_VFX_Live_Mining_Hummer_success_P'",
            [2] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Hummer_fail_P.Play_SE_VFX_Live_Mining_Hummer_fail_P'",
            [3] = "",
            [4] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Hummer_successHQ_P.Play_SE_VFX_Live_Mining_Hummer_successHQ_P'"
        },
        --采集收藏品的技能：1常规，2提纯,慎重提纯价值提升触发时,3大胆提纯价值提升触发时
        CollectionEffect = {
            [1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MIN/VBP/BP_MIN_S_1.BP_MIN_S_1'",
            [2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MIN/VBP/BP_MIN_S_2.BP_MIN_S_2'",
            [3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MIN/VBP/BP_MIN_S_3.BP_MIN_S_3'",
        },
        --采集收藏品的3个提纯技能音效：1常规，2价值提升生效 （还没做好，先用这两个路径代替，做好之后要换掉）
        CollectionSound = {
            [1] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/live/SE_VFX_Live_Gather_Masterpiece_c/Play_SE_VFX_Live_Gather_Masterpiece_c.Play_SE_VFX_Live_Gather_Masterpiece_c'",
            [2] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/live/SE_VFX_Live_Gather_Masterpiece_Cri_c/Play_SE_VFX_Live_Gather_Masterpiece_Cri_c.Play_SE_VFX_Live_Gather_Masterpiece_Cri_c'"
        }
    },
    --园艺工
    [ProtoCommon.prof_type.PROF_TYPE_BOTANIST] = {
        NoteRtrPath = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900171.UI_Icon_900171'",
        NormalSkillIcon = "Texture2D'/Game/Assets/Icon/002000/UI_Icon_002072.UI_Icon_002072'",
        RedRedNoteRtrPath = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900155.UI_Icon_900155'",
        MainWeapon = ProtoRes.EquipmentType.EQUIP_MAIN_GARDEN,
        SecondWeapon = ProtoRes.EquipmentType.EQUIP_SECONDARY_GARDEN,
        --1：成功 2：miss 3：收藏品 4：优质采集
        MainSkillEffect = {
            [1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_emt_ok.BP_gat_emt_ok'",
            [2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_emt_ng.BP_gat_emt_ng'",
            [3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_emt_re.BP_gat_emt_re'",
            [4] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_emt_rg.BP_gat_emt_rg'"
        },
        --1：成功 2：miss 3：隐藏解除 4：优质采集
        MainSkillSound = {
            --伐木
            [1] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Felling_success_P.Play_SE_VFX_Live_Felling_success_P'",
            [2] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Felling_fail_P.Play_SE_VFX_Live_Felling_fail_P'",
            [3] = "",
            [4] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Felling_successHQ_P.Play_SE_VFX_Live_Felling_successHQ_P'"
        },
        --1：成功 2：miss 3：收藏品 4：优质采集
        SecondSkillEffect = {
            [1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_est_ok.BP_gat_est_ok'",
            [2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_est_ng.BP_gat_est_ng'",
            [3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_est_re.BP_gat_est_re'",
            [4] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/GAT/VBP/BP_gat_est_rg.BP_gat_est_rg'"
        },
        --1：成功 2：miss 3：隐藏解除 4：优质采集
        SecondSkillSound = {
            --割草
            [1] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mowing_success_P.Play_SE_VFX_Live_Mowing_success_P'",
            [2] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mowing_fail_P.Play_SE_VFX_Live_Mowing_fail_P'",
            [3] = "",
            [4] = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mowing_successHQ_P.Play_SE_VFX_Live_Mowing_successHQ_P'"
        },
        --采集收藏品的技能：1常规，2提纯,慎重提纯价值提升触发时,3大胆提纯价值提升触发时
        CollectionEffect = {
            [1] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MIN/VBP/BP_MIN_S_1.BP_MIN_S_1'",
            [2] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MIN/VBP/BP_MIN_S_2.BP_MIN_S_2'",
            [3] = "VfxBlueprint'/Game/Assets/Effect/Particles/Crafter/MIN/VBP/BP_MIN_S_3.BP_MIN_S_3'",
        },
        --采集收藏品的3个提纯技能音效：1常规，2价值提升生效
        CollectionSound = {
            [1] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/live/SE_VFX_Live_Gather_Masterpiece_c/Play_SE_VFX_Live_Gather_Masterpiece_c.Play_SE_VFX_Live_Gather_Masterpiece_c'",
            [2] = "AkAudioEvent'/Game/WwiseAudio/Events/sound/vfx/live/SE_VFX_Live_Gather_Masterpiece_Cri_c/Play_SE_VFX_Live_Gather_Masterpiece_Cri_c.Play_SE_VFX_Live_Gather_Masterpiece_Cri_c'"
        }
    }
}

function GatherMgr:OnInit()
    -- [GatherType, {list}] 按类型存储采集物list  (废弃)
    self.GatherItemList = {}

    --当前激活的采集点,点击了的一级交互UI（的ID）
    self.CurActiveEntityID = 0
    --当前采集点的地图编辑ID
    self.CurGatherListID = 0
    --交互入口
    self.CurGatherEntranceItem = nil
    -- self.CurActiveItemView = nil

    -- [GatherType, true/false]     true:触发EnterInteractionRange false/nil:触发LeaveInteractionRange
    self.GatherEntranceShow = {}

    self.LastRegisterGatherProfID = 0

    --LifeSkillPullPrivateGathersRsp 记录服务器下发的私有采集物的采集数据（现在主要是没刷新出来的，采集次数不满的）
    --从服务器拉取下来的都是没刷出来的
    self.PrivateGathers = nil

    self.UpdateNearestGatherPointParams = {}
    self.MiniMapGatherMap = {} --按ListId存储采集点的MapPickItem数据

    -- [ListID, TotalPickCount] 记录最大可采集次数：包括地面特效、技能增加的
    self.TotalPickCountMap = {}
    self.CurMapID = 0

    self.CurHighProductionCastCount = 0
    self.CacheDurationMap = {}

    self.TimeLimitListID = 0
end

function GatherMgr:OnBegin()
    self.EffectNodeMap = {}
    self.SkillEffectIDMap = {}
end

function GatherMgr:OnEnd()
    -- self:StopRefreshTimer()
    self.CurHighProductionCastCount = 0
    _G.ActorMgr:ResetToolMap()

    if self.LastRegisterGatherProfID and self.LastRegisterGatherProfID > 0 then
        LifeSkillConfig.UnRegisterCastSkillCallback(self.LastRegisterGatherProfID)
    end

    if self.SkillEffectIDMap then
        for _, value in pairs(self.SkillEffectIDMap) do
            EffectUtil.StopVfx(value)
            --EffectUtil.BreakEffect(value)
        end
    end
    self.SkillEffectIDMap = {}
    
    --重置状态
    self.IsRealGathering = false
    self.bLoginGetInfo = false
    self:MajorOnExitGatherState()

    if self.EffectNodeMap then
        for _, EffectNode in pairs(self.EffectNodeMap) do
            if EffectNode and EffectNode.DelayResultDisplayTimerID then
                _G.TimerMgr:CancelTimer(EffectNode.DelayResultDisplayTimerID)
            end
        end
        
        self.EffectNodeMap = {}
    end

    self.CacheDurationMap = {}
end

function GatherMgr:OnShutdown()
    self.GatherItemList = {}
    self.CurActiveEntityID = 0
    self.CurGatherListID = 0
    self.CurGatherEntranceItem = nil
    -- self.CurActiveItemView = nil
    self.LastRegisterGatherProfID = 0

    self.PrivateGathers = nil
    self.CurMapID = 0

    self.UpdateNearestGatherPointParams = {}
    self.MiniMapGatherMap = {} --按ListId存储采集点的MapPickItem数据
    self.TotalPickCountMap = {}

    self.GatherJobPanelParams = nil
    self.bGameGetInfo = nil
end

function GatherMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_GATHER_CMD, self.OnNetMsgGather)
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_LIFE_SKILL,
        CS_SUB_CMD.LIFE_SKILL_PRIVATE_GATHER_CMD,
        self.OnNetMsgUpdatePrivateGather
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_LIFE_SKILL,
        CS_SUB_CMD.LIFE_SKILL_PULL_PRIVATE_GATHERS_CMD,
        self.OnNetMsgPullPrivateGatherData
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_LIFE_SKILL,
        CS_SUB_CMD.LIFE_SKILL_GATHER_START_CMD,
        self.OnNetMsgEnterGatherState
    )
    self:RegisterGameNetMsg(
        CS_CMD.CS_CMD_LIFE_SKILL,
        CS_SUB_CMD.LIFE_SKILL_GATHER_END_CMD,
        self.OnNetMsgExitGatherState
    )
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_GATHER_GET_CMD, self.OnNetMsgGetGatherData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LIFE_SKILL, CS_SUB_CMD.LIFE_SKILL_ACTION_CMD, self.OnLifeSkillAction)
end

------------------------ private 接口 begin ----------------------------
---
-- function GatherMgr:StartRefreshTimer(Interval)
--     Interval = Interval or 1

--     if not self.RefreshTimer then
--         self.RefreshTimer = self:RegisterTimer(self.RefreshPrivateGather, 0, Interval, 0)
--     end
-- end

-- function GatherMgr:StopRefreshTimer()
--     if self.RefreshTimer then
--         TimerMgr:CancelTimer(self.RefreshTimer)
--     end
-- end

function GatherMgr:OnCastLifeSkill(Params)
    Params.ULongParam2 = self.CurGatherListID
    if not self.CurActiveEntityID then
        local EntityID = _G.ClientVisionMgr:GetEntityIDByMapEditorID(self.CurGatherListID, GatherActorType)
        self.CurActiveEntityID = EntityID
    end

    --local IsGoToCollect = false
    local CurActiveGatherNoteCfg
    local curGatherItem = _G.CollectionMgr:GetGatherItem()
    if curGatherItem then
        Params.IntParam4 = curGatherItem.ResID --63000079（产出物ID）
        CurActiveGatherNoteCfg = GatherNoteCfg:FindCfgByItemID(curGatherItem.ResID)
    end

    --if Params.ULongParam1 == 0 and not IsGoToCollect then
    if Params.ULongParam1 == 0 then
        local MajorEntityID = MajorUtil.GetMajorEntityID()
        local EffectNode = {EntityID = MajorEntityID, Msg = nil, IsSkill = true, SkillID = Params.IntParam1} --skillid=30101
        --先缓存，等技能G6的采集技能特效事件触发了，再播放技能结果的特效
        if CurActiveGatherNoteCfg and CurActiveGatherNoteCfg.IsCollection == 1 then
            _G.CollectionMgr.EffectNodeMap[MajorEntityID] = EffectNode
        else
            self.EffectNodeMap[MajorEntityID] = EffectNode
        end
    end
    
    if self:IsHighProductionSkill(Params.IntParam1) then
        self.CurHighProductionCastCount = self.CurHighProductionCastCount + 1
    end

    return true
end

function GatherMgr:EnterCollectionState()
    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_ACTION_CMD

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    local Action = {}
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    self.LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
    if self.LogicData == nil then
        FLOG_ERROR("EnterCollectionState, but Major LogicData is nil")
        return false
    end
    local SkillID = self.LogicData:GetBtnSkillID(0)
    Action.LifeSkillID = SkillID
    Action.SubLifeSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, MajorEntityID)

    local Gather = {}
    local GatherActor = ActorUtil.GetActorByEntityID(self.CurActiveEntityID)
    if GatherActor and GatherActor:IsClientActor() then
        Gather.EntityID = _G.ClientVisionMgr:GetMapEditorIDByEntityID(self.CurActiveEntityID)
    end
    local curGatherItem = _G.CollectionMgr:GetGatherItem()
    if curGatherItem then
        Gather.GatherItemID = curGatherItem.ResID --63000079（产出物ID）
    end
    Action.Gather = Gather
    MsgBody.Action = Action

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GatherMgr:OnLifeSkillAction(MsgBody)
    if MsgBody.ErrorCode then
        if self.IsSimpleGather then
            FLOG_INFO("GatherMgr IsSimpleGather Error")
            GatheringJobPanelVM:BreakSimpleGather()
        end
    end
end

--技能结果的回包
function GatherMgr:OnNetMsgGather(MsgBody)
    local MsgType = MsgBody.Gather.Type
    --test
    -- MsgType = ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_COMMON
    FLOG_INFO("GatherMgr OnNetMsgGatherSkill %d skill:%d MsgType:%d", MsgBody.ObjID, MsgBody.LifeSkillID, MsgType)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    
    if MsgBody.ObjID == MajorEntityID and self.IsSimpleGather then
        GatheringJobPanelVM:OnSkillRsp()
    end

    local EffectNode = self.EffectNodeMap[MsgBody.ObjID]
    if EffectNode then
        local SkillID = MsgBody.LifeSkillID
        if SkillID == EffectNode.SkillID then
            if EffectNode.IsSkillEnd or EffectNode.IsDoneSkillEffectEvent then
                --如果技能表现已经结束了，则不进行特效表现了;  直接进行结果表现
                self:DoGatherResult(MsgBody)
                self.EffectNodeMap[MsgBody.ObjID] = nil
            else
                --技能还在进行中
                --先缓存，等技能表现结束的时候再播放技能结果的特效
                EffectNode.Msg = MsgBody
                self.EffectNodeMap[MsgBody.ObjID] = EffectNode
            end
        end
    else
        --主角：没找到这种情况应该是不存在的：cast的时候有，skillend只是标记
        --第三方同步过来的
        if MsgBody.ObjID ~= MajorEntityID then
            self.EffectNodeMap[MsgBody.ObjID] = {Msg = MsgBody, IsSkill = true, SkillID = MsgBody.LifeSkillID}
        end
    end
end

function GatherMgr:DoGatherResult(MsgBody)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if not MsgBody or MsgBody.ObjID ~= MajorEntityID then
        return
    end

    local MsgType = MsgBody.Gather.Type
    if MsgType == ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_MISS then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherMiss)

        -- self:UpdatePrivateGathers(MsgBody)   MsgBody.Gather
        return
    elseif MsgType == ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_COMMON then
    elseif MsgType == ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_HQ then
    else
        return
    end

    local ChainTimes = MsgBody.Gather.ChainTimes
    if ChainTimes > 0 then
        FLOG_INFO("Interactive gather chainttimes: %d", ChainTimes)
        MsgTipsUtil.ShowGatherChainTips(LSTR(160040) .. ChainTimes) --"连锁 "
    else
        FLOG_ERROR("Interactive no Chaininfo")
    end

    local Item = MsgBody.Gather.item
    local resID = Item.ResID
    local Cfg = ItemCfg:FindCfgByKey(resID)
    if Cfg then
        FLOG_INFO("Interactive GetItem: %d %s x%d", resID, ItemCfg:GetItemName(resID), Item.Count)
        if MsgType == ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_HQ then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherRltHQItemInfo, nil, ItemCfg:GetItemName(resID), Item.Count)
        else
            MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherRltItemInfo, nil, ItemCfg:GetItemName(resID), Item.Count)
        end
    else
        FLOG_ERROR("Interactive item:%d need config", resID)
    end

    -- self:UpdatePrivateGathers(MsgBody)
end

--------------------------------------------私有采集物处理 begin----------------------------
--每次采集后的回包LifeSkillPrivateGatherRsp
--刷新私有采集物的数据：剩余次数、刷新时间、id相关、
--稀有采集点 消失/刷出来都是这个消息
function GatherMgr:OnNetMsgUpdatePrivateGather(MsgBody)
    if not MsgBody then
        FLOG_ERROR("GatherMgr:OnNetMsgUpdatePrivateGather MsgBody is nil")
        return
    end

    if _G.CollectionMgr.LastTimeSkill then
        MsgBody.bImmediately = true
        _G.CollectionMgr.UpdatePrivateGatherMsg = MsgBody
        return
    end

    FLOG_WARNING("GatherMgr:OnNetMsgUpdatePrivateGather(MsgBody)")
    self:UpdatePrivateGathers(MsgBody)

    local MsgPrivateGatherItem = MsgBody.PrivateGatherItem
    local MapEditorID = MsgPrivateGatherItem.PrivateGather.ID
    local OnePrivateGather = self:FindPrivateGather(MapEditorID, self.CurMapID)
    -- local RefreshedGather = MsgPrivateGatherItem.RefreshedGather
    local RefreshedGatherID = MsgPrivateGatherItem.RefreshGatherPointID

    if OnePrivateGather and OnePrivateGather.PickCountLeft > 0 then
        if MsgBody and MsgPrivateGatherItem and MsgPrivateGatherItem.GatherItemList then
            local FunctionList = self:GenFunctionList(MsgPrivateGatherItem.GatherItemList)
            if #FunctionList > 0 then
                local function DelaySetItems()
                    GatheringJobPanelVM:SetFunctionItems(FunctionList)
    
                    if self.IsSimpleGather and self.SimpleGatherFunctionItem then
                        local CurGatherNoteItemResID = self.SimpleGatherFunctionItem.ResID
                        for index = 1, #FunctionList do
                            if FunctionList[index].ResID == CurGatherNoteItemResID then
                                GatheringJobPanelVM.SimpleGatherItemVM:UpdateVM(FunctionList[index])
                                break
                            end
                        end
                    end
                    -- _G.InteractiveMgr:UpdateGatherFunctionList(FunctionList)
                end
                
                _G.TimerMgr:AddTimer(nil, DelaySetItems, 1, 1, 1)
            end
        end

        if OnePrivateGather.ID == RefreshedGatherID then
            return
        end
    else
        -- -- InteractiveMgr:ExitInteractive()
        -- InteractiveMgr:ShowEntrances()
        --在采集状态，并且点完提纯没有点收藏
        -- if _G.CollectionMgr.IsCollectionState and _G.CollectionMgr.SkillIndex ~= -1  then
        --     MsgTipsUtil.ShowTipsByID(MsgTipsID.NoLeftCount)
        --     FLOG_ERROR(" MsgTipsUtil.ShowTipsByID(MsgTipsID.NoLeftCount)")
        -- end
    end

    -- 采集完这个采集点，可能会刷新另外一个采集点（进入视野）
    if RefreshedGatherID and RefreshedGatherID > 0 then
        local _, GathersTable, index = self:FindPrivateGather(RefreshedGatherID, self.CurMapID)

        if GathersTable then
            table.remove(GathersTable, index)
        end

        --当前如果有actor，则刷新属性，以及更新ui
        --是当前地图的，所以不用再额外check了
        FLOG_INFO("Interactive refeshed ListID:%d to db config", RefreshedGatherID)

        local RefreshResID = 0
        local RefreshPos = nil

        local RefreshedEntityID =
            ClientVisionMgr:GetEntityIDByMapEditorID(RefreshedGatherID, GatherActorType)
        local RefreshedGatherActor = ActorUtil.GetActorByEntityID(RefreshedEntityID)
        if RefreshedGatherActor then
            -- RefreshPos = RefreshedGatherActor:FGetLocation(_G.UE.EXLocationType.ServerLoc)
            --     + _G.PWorldMgr:GetWorldOriginLocation()

            local RefreshedAttrComp = RefreshedGatherActor:GetAttributeComponent()
            if RefreshedAttrComp then
                RefreshResID = RefreshedAttrComp.ResID
                RefreshedAttrComp.PickTimesLeft = self:GetMaxGatherCount(RefreshResID)
                FLOG_INFO("Interactive refeshed PickCountLeft:%d", RefreshedAttrComp.PickTimesLeft)

                self:OnGatherAttrChange(RefreshedEntityID, RefreshedAttrComp.PickTimesLeft)
            end
        else
            local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(RefreshedGatherID, "Gather")
            if MapEditorData then
                RefreshResID = MapEditorData.ResID
                RefreshPos = self:GetGatherPointPos(MapEditorData, nil)
                local Params = {
                    ListID = MapEditorData.ListId,
                    ResID = RefreshResID,
                    Pos = RefreshPos,
                    IsTimeLimit = self:IsTimeLimitGather(RefreshResID)
                }

                local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
                if CurMapEditCfg and self:GatherCanPick(MapEditorData, CurMapEditCfg.MapID) then
                    FLOG_INFO("Gather AddMiniMapGatherPoint %d bLimit:%s", MapEditorData.ListId, tostring(Params.IsTimeLimit))
                    _G.ClientVisionMgr:ClientActorEnterVision(MapEditorData, _G.UE.EActorType.Gather)

                    if Params.IsTimeLimit then
                        self.TimeLimitListID = MapEditorData.ListId
                        self.TimeLimitParams = {
                            ListID = self.TimeLimitListID,
                            ResID = RefreshResID,
                            Pos = self:GetGatherPointPos(MapEditorData, nil),
                            IsTimeLimit = self:IsTimeLimitGather(RefreshResID)
                        }
                        _G.EventMgr:SendEvent(_G.EventID.AddMiniMapTimeLimitGatherPoint, Params)
                        FLOG_WARNING("Gather IsTimeLimit %d ListID:%d", RefreshResID, MapEditorData.ListId)
                        self:ShowGatherAreaTips(RefreshPos, RefreshResID)
                    else
                        _G.EventMgr:SendEvent(_G.EventID.AddMiniMapGatherPoint, Params)
                    end
                end
            end
        end
    end
end

--LifeSkillPrivateGatherRsp回包后的处理
function GatherMgr:UpdatePrivateGathers(MsgBody)
    if not MsgBody or not MsgBody.PrivateGatherItem then
        FLOG_ERROR("GatherMgr PrivateGatherItem is nil")
        return
    end

    -- if MsgBody.Gather.BelongType == ProtoRes.BELONG_TYPE.BELONG_TYPE_INDEPEND then
    -- local MapEditorID = MsgBody.PrivateGatherItem.PrivateGather.ID
    -- self:DoUpdateGatherInfo(MapEditorID, MsgBody.PrivateGatherItem.PrivateGather.PickCountLeft
    --     , MsgBody.PrivateGatherItem.PrivateGather.TotalPickCount)

    local MapEditorID = MsgBody.PrivateGatherItem.PrivateGather.ID
    local OnePrivateGather = self:FindPrivateGather(MapEditorID, self.CurMapID)

    local ResID = 0
    local EntityID = ClientVisionMgr:GetEntityIDByMapEditorID(MapEditorID, GatherActorType)

    local AttrComp = nil
    local GatherActor = ActorUtil.GetActorByEntityID(EntityID)
    if GatherActor then
        AttrComp = GatherActor:GetAttributeComponent()
        if AttrComp then
            ResID = AttrComp.ResID
        end
    end

    self.TotalPickCountMap[MapEditorID] = MsgBody.PrivateGatherItem.PrivateGather.TotalPickCount
    if not OnePrivateGather then
        local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(MapEditorID, "Gather")
        if MapEditorData then
            ResID = MapEditorData.ResID
            -- local Params = {
            --     ListID = MapEditorData.ListId,
            --     ResID = MapEditorData.ResID,
            --     Pos = self:GetGatherPointPos(MapEditorData, nil)
            -- }
        end

        local Cfg = GatherPointCfg:FindCfgByKey(ResID)
        if Cfg then
            OnePrivateGather = {}
            OnePrivateGather.ID = MsgBody.PrivateGatherItem.PrivateGather.ID
            OnePrivateGather.MapID = self.CurMapID
            OnePrivateGather.PickCountLeft = MsgBody.PrivateGatherItem.PrivateGather.PickCountLeft
            -- OnePrivateGather.NextRefreshTime = MsgBody.PrivateGatherItem.PrivateGather.NextRefreshTime

            FLOG_INFO(
                "Interactive(insert) PickCountLeft:%d, Total:%d",
                OnePrivateGather.PickCountLeft,
                MsgBody.PrivateGatherItem.PrivateGather.TotalPickCount
            )

            self.PrivateGathers = self.PrivateGathers or {}
            self.PrivateGathers.CommonGathers = self.PrivateGathers.CommonGathers or {}

            --现在不区分普通、稀有、传说，只有普通的一种
            if self.PrivateGathers.CommonGathers then
                table.insert(self.PrivateGathers.CommonGathers, OnePrivateGather)
            end
        end
    end

    -- if not GatherActor or not AttrComp then
    --     return
    -- end

    if OnePrivateGather then
        OnePrivateGather.PickCountLeft = MsgBody.PrivateGatherItem.PrivateGather.PickCountLeft
        -- OnePrivateGather.NextRefreshTime = MsgBody.PrivateGatherItem.PrivateGather.NextRefreshTime
        -- FLOG_INFO("Interactive PickCountLeft:%d, NextRefreshTime:%d", OnePrivateGather.PickCountLeft, OnePrivateGather.NextRefreshTime)
        FLOG_INFO(
            "Interactive PickCountLeft:%d Total:%d",
            OnePrivateGather.PickCountLeft,
            MsgBody.PrivateGatherItem.PrivateGather.TotalPickCount
        )

        --会导致收藏品界面上方的耐久条在技能结束前，收到消息后就刷新了
        -- if _G.CollectionMgr.IsCollectionState then
        --     _G.GatheringJobSkillPanelVM:OnRefreshProBar(OnePrivateGather.PickCountLeft)
        -- end

        if AttrComp then
            AttrComp.PickTimesLeft = OnePrivateGather.PickCountLeft
        end

        if OnePrivateGather.PickCountLeft <= 0 then
            if self.UpdateNearestGatherPointParams and self.UpdateNearestGatherPointParams.ListID == MapEditorID then
                self.UpdateNearestGatherPointParams.bShow = false
                _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)
            end
            -- self:SendExitGatherState()
            self.TotalPickCountMap[MapEditorID] = nil
            FLOG_INFO("Gather RemoveMiniMapGatherPoint %d", MapEditorID)
            -- _G.ClientVisionMgr:ClientActorLeaveVision(MapEditorID, GatherActorType)
            if MsgBody.bImmediately ~= nil and MsgBody.bImmediately == true then
                self:DelayGatherLeaveVision(MapEditorID, true)
            else
                self:DelayGatherLeaveVision(MapEditorID)
            end

            local IsTimeLimit = self:IsTimeLimitGather(ResID)
            if IsTimeLimit then
                self.TimeLimitListID = 0
                local Content = ""
                local MajorProfID = MajorUtil.GetMajorProfID()
                if MajorProfID == ProtoCommon.prof_type.PROF_TYPE_MINER then
                    Content = LSTR(160041) --"目前没有感知到限时良材或草场"
                elseif MajorProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST then
                    Content = LSTR(160042) --"目前没有感知到限时矿脉或石场"
                end

                _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapTimeLimitGatherPoint, {ListID = MapEditorID, ResID = ResID})
                -- MsgTipsUtil.ShowAreaTips(Content, 3)

                local function DelayShowTips()
                    FLOG_WARNING("Gather %s", Content)
                    MsgTipsUtil.ShowTips(Content)
                end

                _G.TimerMgr:AddTimer(nil, DelayShowTips, 3, 1, 1)
            else
                _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapGatherPoint, {ListID = MapEditorID, ResID = ResID})
            end
        else
            self:OnGatherAttrChange(EntityID, OnePrivateGather.PickCountLeft)
        end
    end
end

function GatherMgr:OnGatherAttrChange(EntityID, PickCountLeft, bImmediately)
    -- FLOG_INFO("Gather EntityID:%d, PickCountLeft:%d", EntityID, PickCountLeft)
    self.CacheDurationMap = self.CacheDurationMap or {}
    if self.CurActiveEntityID and EntityID == self.CurActiveEntityID and not bImmediately then
        local CurLeftCnt = self.CacheDurationMap[self.CurActiveEntityID]
        if CurLeftCnt and CurLeftCnt < PickCountLeft then
            self:DoGatherAttrChange(EntityID, PickCountLeft)
        end
    else
        self:DoGatherAttrChange(EntityID, PickCountLeft)
    end

    if self.CurActiveEntityID then
        self.CacheDurationMap[self.CurActiveEntityID] = PickCountLeft
    end
end

function GatherMgr:DoGatherAttrChange(EntityID, PickCountLeft)
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.IntParam1 = PickCountLeft
    EventParams.ULongParam1 = EntityID
    EventMgr:SendEvent(EventID.GatherAttrChange, EventParams)

    self:OnDurationChange(EntityID, PickCountLeft)
end

function GatherMgr:GetLeftTimes()
    local AttrCmp = ActorUtil.GetActorAttributeComponent(self.CurActiveEntityID)
    if AttrCmp then
        return AttrCmp.PickTimesLeft
    end
    return 0
end

function GatherMgr:RefreshSkillState()
    local function DelayRefresh()
        local AttrCmp = ActorUtil.GetActorAttributeComponent(self.CurActiveEntityID)
        if AttrCmp then
            local PickTimesLeft = AttrCmp.PickTimesLeft
            self:DoGatherAttrChange(AttrCmp.EntityID, PickTimesLeft)
        end
    end
    _G.TimerMgr:AddTimer(nil, DelayRefresh, 1, 0, 1)
end

--public接口
function GatherMgr:FindPrivateGather(MapEditorID, MapID)
    if self.PrivateGathers and self.PrivateGathers.CommonGathers then
        local OnePrivateGather = nil

        --现在只有普通的
        for i = 1, #self.PrivateGathers.CommonGathers do
            OnePrivateGather = self.PrivateGathers.CommonGathers[i]
            if OnePrivateGather.ID == MapEditorID then
                if not OnePrivateGather.MapID or OnePrivateGather.MapID == MapID then
                    return OnePrivateGather, self.PrivateGathers.CommonGathers, i
                end
            end
        end
    end

    return nil
end

function GatherMgr:IsRefreshed(ListId, MapID)
    local OnePrivateGather = self:FindPrivateGather(ListId, MapID)
    if OnePrivateGather then
        if OnePrivateGather.PickCountLeft <= 0 then
            return false
        end
    end

    return true
end

--------------------------------------------私有采集物处理 End----------------------------

function GatherMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PreEnterInteractionRange, self.OnGameEventPreEnterInteractionRange)
    self:RegisterGameEvent(EventID.PreLeaveInteractionRange, self.OnGameEventPreLeaveInteractionRange)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnEventActorLeaveVision)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
    self:RegisterGameEvent(EventID.MajorProfSwitch, self.OnEventMajorProfSwitch)
    --暂时不用管GatherAttrChange的数据变化，当可采集次数变为0，服务器会leaveview，会走ActorDestroyed，然后刷新二级交互

    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)

    self:RegisterGameEvent(EventID.MajorAddBuffLife, self.OnMajorAddBuffLife)
    self:RegisterGameEvent(EventID.MajorUpdateBuffLife, self.OnMajorUpdateBuffLife)
    self:RegisterGameEvent(EventID.MajorRemoveBuffLife, self.OnMajorRemoveBuffLife)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.GatherSkillEffect, self.OnSkillEffect)

	self:RegisterGameEvent(EventID.Attr_Change_GP, self.OnGameEventActorGPChange)
end

function GatherMgr:OnGameEventLoginRes(Param)
    local bReconnect = Param and Param.bReconnect
    if (bReconnect) then
        if not MajorUtil.IsGatherProf() then
            return
        end

        FLOG_INFO("GatherMgr bReconnect")
        self.bLoginGetInfo = false
        -- if self.bGameGetInfo == nil then
        --     self:GetInfo()
        -- end
        self.bGameGetInfo = true   --局内断线重连的Get
        self:MajorOnExitGatherState()
        -- self:SendPullGatherInfo()

        -- if self.CurGatherEntranceItem then
        --     -- self.IsMoveExit = false
        --     -- self:SendExitGatherState(true)
        --     -- local GatherID = self.CurGatherEntranceItem.ResID
        --     -- self:ExitGatherState(MajorUtil.GetMajorEntityID(), GatherID)
        --     self:SendReconnectGetInfo()
        -- else
        --     FLOG_ERROR("GatherMgr Reconnect Error")
        -- end
    else
        self.bLoginGetInfo = true
        self:SendReconnectGetInfo()
    end
end

function GatherMgr:OnPWorldEnter(Params)
    self.MiniMapGatherMap = {}
    self.TotalPickCountMap = {}
    local ProfID = MajorUtil.GetMajorProfID()
    if ProfID == ProtoCommon.prof_type.PROF_TYPE_MINER or ProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST then
        self:SendPullGatherInfo()
    end

    local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if CurMapEditCfg then
        self.CurMapID = CurMapEditCfg.MapID
    end
end

function GatherMgr:SendReconnectGetInfo()
    if MajorUtil.IsGatherProf() then
        FLOG_INFO("GatherMgr sendmsg to Get ReconnectInfo")

        local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
        local SubMsgID = CS_SUB_CMD.LIFE_SKILL_GATHER_GET_CMD

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID

        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

function GatherMgr:SendPullGatherInfo()
    if MajorUtil.IsGatherProf() then
        self.TimeLimitListID = 0
        FLOG_INFO("GatherMgr sendmsg to Pull private gather data")

        local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
        local SubMsgID = CS_SUB_CMD.LIFE_SKILL_PULL_PRIVATE_GATHERS_CMD

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID

        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end
end

--当前采集的采集点消失了，要退出采集状态
function GatherMgr:OnEventActorLeaveVision(Params)
    local EntityID = Params.ULongParam1
    if (Params.IntParam1 ~= _G.UE.EActorType.Gather) then
        return
    end

    if self.CacheDurationMap and self.CacheDurationMap[EntityID] then
        self.CacheDurationMap[EntityID] = nil
    end

    if EntityID == self.CurActiveEntityID then
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.IntParam1 = _G.UE.EActorType.Gather
        EventParams.ULongParam1 = EntityID
        _G.EventMgr:SendEvent(_G.EventID.LeaveInteractionRange, EventParams)
    end
end

function GatherMgr:OnNetMsgPullPrivateGatherData(MsgBody)
    FLOG_WARNING("GatherMgr receive msg : Pull private gather data")
    _G.ClientVisionMgr:EnableTick(true)

    --干掉之前的采集点
    self:RemoveAllMiniMap()

    --现在每次切图回来，会将采集次数没满的重置满；拉取回来的都是没有刷新的，等待服务器刷新
    self.PrivateGathers = MsgBody.PrivateGathers
    self.TimeLimitParams = nil
    if self.PrivateGathers and self.PrivateGathers.CommonGathers then
        local Cnt = #self.PrivateGathers.CommonGathers
        FLOG_WARNING("GatherMgr %d Points Cann't Refresh", Cnt)

        for index = 1, Cnt do
            local GatherInfo = self.PrivateGathers.CommonGathers[index]
            if GatherInfo.PickCountLeft > 0 then
                local MapEditorData = _G.ClientVisionMgr:GetEditorDataByEditorID(GatherInfo.ID, "Gather")
                -- if GatherInfo.ID == 4164385 then
                --     FLOG_WARNING("GatherMgr error")
                -- end

                if MapEditorData then
                    local RefreshResID = MapEditorData.ResID
                    local IsTimeLimit = self:IsTimeLimitGather(RefreshResID)
                    if IsTimeLimit then
                        FLOG_WARNING("Gather IsTimeLimit %d ListID:%d, left:%d", RefreshResID, GatherInfo.ID, GatherInfo.PickCountLeft)

                        self.TimeLimitListID = MapEditorData.ListId
                        self.TimeLimitParams = {
                            ListID = MapEditorData.ListId,
                            ResID = RefreshResID,
                            Pos = self:GetGatherPointPos(MapEditorData, nil),
                            IsTimeLimit = self:IsTimeLimitGather(RefreshResID)
                        }
                    -- else
                    --     FLOG_WARNING("Gather not limit %d ListID:%d, left:%d", RefreshResID, GatherInfo.ID, GatherInfo.PickCountLeft)
                    end
                end
            end
        end
    end

    local function DelayUpdateMiniMap()
        FLOG_INFO("GatherMgr SendEvent UpdateGatherPoints to minimap")
        -- _G.EventMgr:SendEvent(_G.EventID.UpdateGatherPoints)

        if self.TimeLimitParams then
            --UpdateGatherPoints后，小地图会GetAll，但是限时采集点在小地图视野外，getall的时候就没有限时的了，所以还是要触发
            _G.EventMgr:SendEvent(_G.EventID.AddMiniMapGatherPoint, self.TimeLimitParams)
            self:ShowGatherAreaTips(self.TimeLimitParams.Pos, self.TimeLimitParams.ResID)
        end

        if self.bLoginGetInfo then
            -- if self:RestoreGatherEntranceItem(self.GatherPointMsgInfo) then
            --     local StateCmp = MajorUtil.GetMajorStateComponent()
            --     if StateCmp then
            --         StateCmp:UpdateInteractData(self.CurGatherEntranceItem.ResID, ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_GATHER)
            --     end

            --     self:RestoreGatherState(self.GatherPointMsgInfo, self.CurGatherEntranceItem.ResID)
            --     self.CurGatherEntranceItem:Click()
            -- else
            --     FLOG_ERROR("Gather RestoreGatherEntranceItem Failed, so exit gatherstate")
            --     self:SendExitGatherState()
            -- end

            -- self.GatherPointMsgInfo = nil
            -- self.bLoginGetInfo = nil
        end
    end
    local IsMainShow = _G.UIViewMgr:IsViewVisible(UIViewID.MainPanel)
    local Delay = IsMainShow and 0.2 or 1.2
    self:RegisterTimer(DelayUpdateMiniMap, Delay, 1, 1)
end

function GatherMgr:RemoveAllMiniMap()
    local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if CurMapEditCfg then
        local bRemoveTimeLimit = false
        for ListID, PickItem in pairs(self.MiniMapGatherMap) do
            -- FLOG_INFO("Gather RemoveMiniMapGatherPoint %d", ListID)
            if self.TimeLimitListID == ListID then
                bRemoveTimeLimit = true
                _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapTimeLimitGatherPoint, {ListID = ListID, ResID = PickItem.ResID})
            else
                _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapGatherPoint, {ListID = ListID, ResID = PickItem.ResID})
            end
        end
        
        if not bRemoveTimeLimit and self.TimeLimitParams and self.TimeLimitParams.ListID > 0 then
            _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapTimeLimitGatherPoint, self.TimeLimitParams)
        end
    end

    self.MiniMapGatherMap = {}
end

-- function GatherMgr:DoUpdateMiniMap()
--     FLOG_INFO("GatherMgr SendEvent UpdateGatherPoints to minimap")
--     _G.EventMgr:SendEvent(_G.EventID.UpdateGatherPoints)
-- end

--多个入口，所以Params可能不一致
function GatherMgr:OnMajorCreate(Params, bSwitchProf)
    if self.LastRegisterGatherProfID and self.LastRegisterGatherProfID > 0 then
        LifeSkillConfig.UnRegisterCastSkillCallback(self.LastRegisterGatherProfID)
    end

    local MajorProfID = MajorUtil.GetMajorProfID()
    if self:IsGatherProf(MajorProfID) then
        if bSwitchProf then
            _G.ClientVisionMgr:EnableTick(false)
        end

        self.LastRegisterGatherProfID = MajorProfID

        LifeSkillConfig.RegisterCastSkillCallback(MajorProfID, self, self.OnCastLifeSkill)

        self:RegisterGameEvent(EventID.SkillStart, self.OnSkillStart)
        self:RegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)

        self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
        self:RegisterGameEvent(EventID.SkillGameEventGetReward, self.OnSkillGameEventGetReward)
    else
        if bSwitchProf then
            _G.ClientVisionMgr:EnableTick(true)
        end
        self:UnRegisterGameEvent(EventID.SkillStart, self.OnSkillStart)
        self:UnRegisterGameEvent(EventID.SkillEnd, self.OnSkillEnd)
        self:UnRegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
        self:UnRegisterGameEvent(EventID.SkillGameEventGetReward, self.OnSkillGameEventGetReward)
        -- self:UnRegisterGameEvent(EventID.GatherSkillEffect, self.OnSkillEffect)
    end
    FLOG_INFO("Interactive GatherMgr:OnMajorCreate profID: " .. self.LastRegisterGatherProfID)

    _G.MainPanelVM:SetVisibleIconBook()

    --OnGameEventLoginRes 缓存下来，滞后到这里再处理
    if self.bGameGetInfo then
        self.bGameGetInfo = false

        self:GetInfo()
    end
end

function GatherMgr:GetInfo()
    -- self:SendPullGatherInfo()

    if self.CurGatherEntranceItem then
        self:SendReconnectGetInfo()
    else
        FLOG_ERROR("GatherMgr Reconnect Error")
    end
end

function GatherMgr:OnSkillGameEventGetReward()
    if MajorUtil.IsGatherProf() then
        FLOG_INFO("GatherMgr SkillGameEvent to get skill reward")

        local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
        local SubMsgID = CS_SUB_CMD.LIFE_SKILL_GATHER_GET_REWARD

        local MsgBody = {}
        MsgBody.Cmd = SubMsgID

        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
        self.GotSkillReward = true
    end
end

function GatherMgr:OnAssembleAllEnd(Params)
	local EntityID = Params.ULongParam1
	if EntityID == MajorUtil.GetMajorEntityID() then
        if self.bLoginGetInfo then
            if self.GatherPointMsgInfo then
                -- self:SendReconnectGetInfo()
                if self:RestoreGatherEntranceItem(self.GatherPointMsgInfo) then
                    local StateCmp = MajorUtil.GetMajorStateComponent()
                    if StateCmp then
                        StateCmp:UpdateInteractData(self.CurGatherEntranceItem.ResID, ProtoCommon.INTERACT_TYPE.INTERACT_TYPE_GATHER)
                    end

                    self.CurGatherEntranceItem:Click()
                    self:RestoreGatherState(self.GatherPointMsgInfo, self.CurGatherEntranceItem.ResID)
                else
                    FLOG_ERROR("Gather RestoreGatherEntranceItem Failed, so exit gatherstate")
                    self:SendExitGatherState()
                end
            end

            self.bLoginGetInfo = nil
            self.GatherPointMsgInfo = nil
        end
	end
end

function GatherMgr:OnEventMajorProfSwitch(Params)
    local ProfID = MajorUtil.GetMajorProfID()
    FLOG_INFO("Interactive GatherMgr:OnMajorCreate LastProfID: %d, SwitchTo: %d", self.LastRegisterGatherProfID, ProfID)
    self:OnMajorCreate(Params, true)

    if self.GatherDisCoverBuffID then
        self.UpdateNearestGatherPointParams = self.UpdateNearestGatherPointParams or {}
        self.UpdateNearestGatherPointParams.bShow = false

        FLOG_INFO("Major GatherDiscover remove %d When ProfSwitch", self.UpdateNearestGatherPointParams.ListID or -1)
        _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)

        self.UpdateNearestGatherPointParams = {}
        self.GatherDisCoverBuffID = 0
    end

    if ProfID == ProtoCommon.prof_type.PROF_TYPE_MINER or ProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST then
        self:SendPullGatherInfo()
        for ListID, _ in pairs(self.MiniMapGatherMap) do
            _G.ClientVisionMgr:ClientActorLeaveVision(ListID, GatherActorType)
        end
    else
        self:RemoveAllMiniMap()

        _G.ClientVisionMgr:EnableTick(true)
    end
end

function GatherMgr:OnSkillStart(Params)
    local EntityID = Params.ULongParam1
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if EntityID ~= MajorUtil.GetMajorEntityID() then
        return
    end

    self.IsMajorSkilling = true
    self.GotSkillReward = false

    _G.SkillLogicMgr:SetSkillButtonEnable(
        MajorEntityID,
        SkillBtnState.GatherSkillCasting,
        self,
        function()
            return false
        end
    )
end

function GatherMgr:OnSkillEnd(Params)
    -- local SkillID = Params.IntParam2
    local EntityID = Params.ULongParam1

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        EffectNode.IsSkillEnd = true
        if EffectNode.Msg then
            FLOG_INFO("====GatherMgr OnSkillEnd, DoGatherResult")
            self:DoGatherResult(EffectNode.Msg)
            self.EffectNodeMap[EntityID] = nil
        end
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    -- local GatherActor = ActorUtil.GetActorByEntityID(self.CurActiveEntityID)
    if MajorEntityID == EntityID then
        FLOG_INFO("GatherMgr OnSkillEnd")
        self.IsMajorSkilling = false

        if not self.GotSkillReward then
            self:OnSkillGameEventGetReward()
        end

        if self.IsMoveExit then
            local CurDuration = self.CurActiveEntityID and self.CacheDurationMap[self.CurActiveEntityID]
            if CurDuration then
                self:DoGatherAttrChange(self.CurActiveEntityID, CurDuration)
            end
            self:SendExitGatherState()
        end

        _G.SkillLogicMgr:SetSkillButtonEnable(
            MajorEntityID,
            SkillBtnState.GatherSkillCasting,
            self,
            function()
                return true
            end
        )
    end
end

function GatherMgr:OnSkillEffect(Params)
    FLOG_INFO("GatherMgr OnSkillEffect")
    local EntityID = Params.ULongParam1

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        EffectNode.IsDoneSkillEffectEvent = true

        local ProfID = ActorUtil.GetActorProfID(EntityID)
        -- local MajorProfID = MajorUtil.GetMajorProfID()
        local GatherToolID = _G.ActorMgr:GetTool(EntityID)
        local Config = self.ProfConfig[ProfID]
        if not Config then
            return
        end

        if EntityID == MajorUtil.GetMajorEntityID() then
            local CurDuration = self.CacheDurationMap[self.CurActiveEntityID] or 0
            if CurDuration then
                self:DoGatherAttrChange(self.CurActiveEntityID, CurDuration)
            end
        end

        --1：成功 2：miss 3：收藏品 4：优质采集
        local SkillEffectList = Config.MainSkillEffect
        local SoundList = Config.MainSkillSound
        if Config.SecondWeapon == GatherToolID then
            SkillEffectList = Config.SecondSkillEffect
            SoundList = Config.SecondSkillSound
        end

        local ListID = 0
        --播放技能成功、失败的特效
        local SkillEffectPath = SkillEffectList[1]
        local SoundPath = SoundList[1]

        if EffectNode.Msg then
            if EffectNode.Msg.Gather.Type == ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_MISS then
                SkillEffectPath = SkillEffectList[2]
                SoundPath = SoundList[2]
            elseif EffectNode.Msg.Gather.Type == ProtoCS.LifeSkillGatherType.LIFE_SKILL_GATHER_TYPE_HQ then
                SkillEffectPath = SkillEffectList[4]
                SoundPath = SoundList[4]
            end

            ListID = EffectNode.Msg.Gather.ListID
        end

        local CurEffectID = self.SkillEffectIDMap[EntityID]
        if CurEffectID then
            EffectUtil.StopVfx(CurEffectID)
            --EffectUtil.BreakEffect(CurEffectID)
        end

        if EffectNode.Msg then
            --, OnSkillEffectOver)
            FLOG_INFO("=========GatherMgr OnSkillEffectEvent to Play SkillRltEff %d", EffectNode.Msg.Gather.Type)
            AudioUtil.LoadAndPlaySoundEvent(EntityID, SoundPath)
            self:PlayEffect(EntityID, SkillEffectPath, self.SkillEffectIDMap, nil, ListID)
        else
            FLOG_WARNING("=========GatherMgr OnSkillEffectEvent, bug Msg is nil")
        end

        --技能特效结束后的处理
        local function OnSkillEffectOver()
            --如果有记录结果，则进行结果的表现
            EffectNode = self.EffectNodeMap[EntityID]
            if not EffectNode then
                return
            end

            if EffectNode.Msg then
                FLOG_INFO("====GatherMgr OnSkillEffectOver, to play Result Effect")
                GatherMgr:DoGatherResult(EffectNode.Msg)
                self.EffectNodeMap[EntityID] = nil
            else
                FLOG_INFO("====GatherMgr OnSkillEffectOver, but msg is nil")
            end
            EffectNode.DelayResultDisplayTimerID = nil
        end

        EffectNode.DelayResultDisplayTimerID =
            _G.TimerMgr:AddTimer(nil, OnSkillEffectOver, self.DelayResultDisplayTime, 1, 1)
    end
end

--EntityID 技能施法者
function GatherMgr:PlayEffect(EntityID, EffectPath, EffectIDMap, CompleteCallBack, ListID)
    local CasterActor = ActorUtil.GetActorByEntityID(EntityID)
    if not CasterActor then
        return
    end

    local TargetEffectID = EffectIDMap[EntityID]
    if TargetEffectID then
        -- FLOG_INFO("Crafter BreakEffect %d", TargetEffectID)
        EffectUtil.StopVfx(TargetEffectID)
        --EffectUtil.BreakEffect(TargetEffectID)
    end

    local VfxParameter = _G.UE.FVfxParameter()
    VfxParameter.VfxRequireData.EffectPath = CommonUtil.ParseBPPath(EffectPath)
    local MajorID = MajorUtil.GetMajorEntityID()

    local EffectPos = nil
    local GatherInfo = _G.ClientVisionMgr:GetActorMapEditInfo(ListID, _G.UE.EActorType.Gather, CasterActor)
    if GatherInfo then
        EffectPos = _G.UE.FVector(GatherInfo.Point.X, GatherInfo.Point.Y, GatherInfo.Point.Z) -
                        _G.UE.UWorldMgr.Get():GetOriginLocation()
    elseif MajorID == EntityID then
        local GatherActor = ActorUtil.GetActorByEntityID(self.CurActiveEntityID)
        if GatherActor then
            EffectPos = GatherActor:FGetActorLocation()
        else
            FLOG_ERROR("GatherMgr:PlayEffect Error, major not find gather by entityid")
        end
    else
        FLOG_ERROR("GatherMgr:PlayEffect Error, 3p not find gather by listid")
        return
    end

    VfxParameter.LODMethod = 2
    local MyTransform = _G.UE.FTransform()
    MyTransform:SetLocation(EffectPos)
    VfxParameter.VfxRequireData.VfxTransform = MyTransform
    local LODLevel = 0
    if MajorID ~= EntityID then
        LODLevel = EffectUtil.GetPlayerEffectLOD()
    else
        LODLevel = EffectUtil.GetMajorEffectLOD()
    end

    VfxParameter.LODLevel = LODLevel
    if CompleteCallBack then
        VfxParameter.OnVfxEnd = CommonUtil.GetDelegatePair(CompleteCallBack, true)
    end
    TargetEffectID = EffectUtil.PlayVfx(VfxParameter)
    --FXParam.LODLevel = LODLevel
    --TargetEffectID = EffectUtil.PlayEffect(FXParam, CompleteCallBack)
    EffectIDMap[EntityID] = TargetEffectID
end

function GatherMgr:OnGameEventPreEnterInteractionRange(Params)
    if Params.IntParam1 ~= _G.UE.EActorType.Gather then
        return
    end

    --预判下，这样降低绝大多数人的读db
    if not MajorUtil.IsGatherProf() then
        return
    end

    local Cfg = GatherPointCfg:FindCfgByKey(Params.ULongParam2)
    if not Cfg then
        FLOG_ERROR("Interactive GatherPointCfg id: %d need Cofig", Params.ULongParam2)
        return
    end

    --职业不符的采集物 不会产生交互项
    if not self:IsCanGatherByProf(Cfg.GatherType, MajorUtil.GetMajorProfID()) then
        return
    end

    FLOG_INFO("Interactive PreEnter: " .. Params.ULongParam1)

    _G.EventMgr:SendEvent(_G.EventID.EnterInteractionRange, Params)
end

function GatherMgr:OnGameEventPreLeaveInteractionRange(Params)
    if Params.IntParam1 ~= _G.UE.EActorType.Gather then
        return
    end

    local Cfg = GatherPointCfg:FindCfgByKey(Params.ULongParam2)
    if not Cfg then
        FLOG_ERROR("Interactive GatherPointCfg id: %d need Cofig", Params.ULongParam2)
        return
    end

    FLOG_INFO("Interactive goaway PreLeave " .. Params.ULongParam1)

    _G.EventMgr:SendEvent(_G.EventID.LeaveInteractionRange, Params)
    -- self:OnGatherLeave(Cfg, Params)
end

------------------------ private 接口 end ----------------------------

------------------------ public 接口 begin ----------------------------
---
function GatherMgr:IsGatherProf(ProfID)
    if ProfID == ProtoCommon.prof_type.PROF_TYPE_MINER or ProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST then
        return true
    end

    return false
end

--原来是一级交互是矿场，二级交互是周围多个采集物Actor
--所以需要激活某一个采集物Actor进行采集
function GatherMgr:SwitchActiveGatherItem(EntityID)
    if self.CurActiveEntityID and self.CurActiveEntityID > 0 then
        FLOG_INFO("Interactive SwitchActiveGather %d and DeActive:%d", EntityID, self.CurActiveEntityID)
        _G.EventMgr:SendEvent(_G.EventID.DeActiveGatherItemView, self.CurActiveEntityID)
    else
        FLOG_INFO("Interactive SwitchActiveGather %d", EntityID)
    end

    self.CurActiveEntityID = EntityID

    _G.EventMgr:SendEvent(_G.EventID.ActiveGatherItemView, EntityID)

    MajorUtil.LookAtActor(EntityID)
end

--StartTime>0或EndTime>0表示稀有采集点，稀有采集点这个时间段会刷新，离开的时候采集点消失，一天内只能刷新一次，采集点的收藏品是后台按概率下发
function GatherMgr:IsRareGather()
    if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
        if self.CurGatherEntranceItem.Cfg.IsUnknownLoc == 1 then
            return true
        end
    end

    return false
end

--展示1个采集点的产出物列表
function GatherMgr:GenFunctionList(GatherItemList)
    if not self.CurGatherEntranceItem then
        return
    end

    local FunctionList = {}
    local GatherEntityID = self.CurGatherEntranceItem.EntityID
    local InteractiveID = self.CurGatherEntranceItem.Cfg.InteractiveID

    local function AddFunction(ResID, index, InsertPos)
        local FunctionUnit =
            FunctionItemFactory:CreateInteractiveDescFunc(
            {FuncValue = InteractiveID, EntityID = GatherEntityID, ResID = ResID, ItemNoteInfo = GatherItemList[index]}
        )

        if FunctionUnit then
            FunctionUnit.EntryWidgetIndex = 1

            if InsertPos then
                table.insert(FunctionList, InsertPos, FunctionUnit)
            else
                table.insert(FunctionList, FunctionUnit)
            end
        end
    end

    local TreasureMapID = nil
    local TreasureMapIdx = nil
    for index = 1, #GatherItemList do
        local ResID = GatherItemList[index].ItemID
        local NoteCfg = GatherNoteCfg:FindCfgByItemID(ResID)
        if not NoteCfg then
            TreasureMapID = ResID
            TreasureMapIdx = index
        else
            AddFunction(ResID, index)
        end
    end

    if TreasureMapID and TreasureMapIdx then
        AddFunction(TreasureMapID, TreasureMapIdx, 1)
    end

    if #FunctionList == 0 then
        FLOG_WARNING("Interactive OnGenFunctionList failed, listsize = 0")
    end

    return FunctionList
end

function GatherMgr:GatherCanPick(MapPickItem, MapID, IsIgnoreTimeLimit)
    if MapPickItem.bFutureVersion then
        return false, false
    end
    
    local bReadDB = false
    if self.PrivateGathers then
        local OnePrivateGather = self:FindPrivateGather(MapPickItem.ListId, MapID)
        if OnePrivateGather then
            if OnePrivateGather.PickCountLeft <= 0 then
                return false, bReadDB
            end
        end
    end

    local Cfg = nil
    if not MapPickItem.Level or not MapPickItem.GatherType then
        Cfg = GatherPointCfg:FindCfgByKey(MapPickItem.ResID)
        bReadDB = true
        if Cfg then
            MapPickItem.Level = Cfg.GatherLevel
            MapPickItem.GatherType = Cfg.GatherType
        else
            return false, bReadDB
        end
    end

    if not self:IsCanGather(MapPickItem.GatherType, MajorUtil.GetMajorProfID(), MapPickItem.Level) then
        return false, bReadDB
    end

    if IsIgnoreTimeLimit and self.TimeLimitListID == MapPickItem.ListId then
        return false, false
        -- Cfg = GatherPointCfg:FindCfgByKey(MapPickItem.ResID)
        -- if Cfg and Cfg.IsUnknownLoc == 1 then
        --     return false, true
        -- end
    end

    return true, bReadDB
end

--进入采集状态
function GatherMgr:SendEnterGatherState(GatherEntranceItem)
    local IsAutoPathMovingState = _G.AutoPathMoveMgr:IsAutoPathMovingState()
    if IsAutoPathMovingState then
        _G.AutoPathMoveMgr:StopAutoPathMoving()

        local function DelayEnter()
            self:DoEnterGatherState(GatherEntranceItem)
        end

        _G.TimerMgr:AddTimer(nil, DelayEnter, 0.03, 1, 1)
    else
        self:DoEnterGatherState(GatherEntranceItem)
    end
end

function GatherMgr:DoEnterGatherState(GatherEntranceItem)
    -- 通用状态检测
    if CommonStateUtil.CheckBehavior(GatherActionID, true) == false then
        return false
    end

    local EntityID = GatherEntranceItem.EntityID
    if not EntityID then
        FLOG_ERROR("GatherMgr:SendEnterGatherState EntityID is nil")
        return
    end

    --产出物集合
    local ListID = _G.ClientVisionMgr:GetMapEditorIDByEntityID(EntityID)
    if not ListID then
        FLOG_ERROR("GatherMgr:SendEnterGatherState ListID is nil")
        return
    end

    self.CurGatherEntranceItem = GatherEntranceItem
    self.CurGatherListID = ListID
    self:SwitchActiveGatherItem(EntityID)

    _G.EventMgr:SendEvent(_G.EventID.ForceFightPanel)
    FLOG_INFO("GatherMgr Major SendEnterGatherState ListID:%d, EntityID:%d", ListID, EntityID)

    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_GATHER_START_CMD

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.GatherStart = {ListID = ListID}
    --TargetResID = GatherEntranceItem.ResID,

    --正常登录客户端后，如果是采集状态中的话，模拟采集点交互的时候，不用额外再发进入采集状态的请求
    if not self.bLoginGetInfo then
        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end

    _G.SwitchTarget:ManualSwitchToTarget(EntityID, nil, true)
end

function GatherMgr:GetCurGatherPointTypeName()
    if self.CurGatherEntranceItem then
        return self.GatherTypeName[self.CurGatherEntranceItem.GatherType]
    end

    return "None"
end

local function ChangeCalculateVelocityRange(bChange)
    local MajorController = MajorUtil.GetMajorController()
    if MajorController then
        MajorController:SetCalculateVelocityRange(bChange)
    end
    print("Gather CalculateVelocityRange " .. (bChange and "true" or "false"))
end

local function ChangeVelocityRangeCheck(Value)
    Value = Value or 2
    local MajorController = MajorUtil.GetMajorController()
    if MajorController then
        MajorController:SetVelocityRangeCheck(Value)
    end

    print("Gather RangeCheck " .. tostring(Value))
end

function GatherMgr:DoUpdateGatherInfo(ListID, PickTimesLeft, TotalPickCount)
    local MapEditorID = ListID
    local OnePrivateGather = self:FindPrivateGather(MapEditorID, self.CurMapID)

    local EntityID = _G.ClientVisionMgr:GetEntityIDByMapEditorID(MapEditorID, GatherActorType)
    local GatherActor = ActorUtil.GetActorByEntityID(EntityID)
    if not GatherActor then
        return
    end

    local AttrComp = GatherActor:GetAttributeComponent()
    if not AttrComp then
        return
    end

    self.TotalPickCountMap[ListID] = TotalPickCount
    if not OnePrivateGather then
        local Cfg = GatherPointCfg:FindCfgByKey(AttrComp.ResID)
        if Cfg then
            OnePrivateGather = {}
            OnePrivateGather.ID = ListID
            OnePrivateGather.MapID = self.CurMapID
            OnePrivateGather.PickCountLeft = PickTimesLeft
            -- OnePrivateGather.NextRefreshTime = MsgBody.PrivateGatherItem.PrivateGather.NextRefreshTime

            FLOG_INFO("Interactive(insert) PickCountLeft:%d", OnePrivateGather.PickCountLeft)

            self.PrivateGathers = self.PrivateGathers or {}
            self.PrivateGathers.CommonGathers = self.PrivateGathers.CommonGathers or {}

            --现在不区分普通、稀有、传说，只有普通的一种
            if self.PrivateGathers.CommonGathers then
                table.insert(self.PrivateGathers.CommonGathers, OnePrivateGather)
            end
        end
    end

    if OnePrivateGather then
        OnePrivateGather.PickCountLeft = PickTimesLeft
        FLOG_INFO("Interactive PickCountLeft:%d Total:%d", OnePrivateGather.PickCountLeft, TotalPickCount)

        AttrComp.PickTimesLeft = OnePrivateGather.PickCountLeft

        if OnePrivateGather.PickCountLeft <= 0 then
            if self.UpdateNearestGatherPointParams and self.UpdateNearestGatherPointParams.ListID == MapEditorID then
                self.UpdateNearestGatherPointParams.bShow = false
                _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)
            end

            FLOG_INFO("Gather RemoveMiniMapGatherPoint %d Total:%d", MapEditorID, TotalPickCount)
            self.TotalPickCountMap[MapEditorID] = nil

            if ListID == self.TimeLimitListID then
                _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapTimeLimitGatherPoint, {ListID = MapEditorID, ResID = AttrComp.ResID})
            else
                _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapGatherPoint, {ListID = MapEditorID, ResID = AttrComp.ResID})
            end
            -- _G.ClientVisionMgr:ClientActorLeaveVision(MapEditorID, GatherActorType)
            self:DelayGatherLeaveVision(MapEditorID)
        else
            self:OnGatherAttrChange(EntityID, OnePrivateGather.PickCountLeft, true)
        end
    end
end

function GatherMgr:DelayGatherLeaveVision(MapEditorID, bImmediately)
    local function DoLeaveVision()
        _G.ClientVisionMgr:ClientActorLeaveVision(MapEditorID, GatherActorType)
        _G.InteractiveMgr:ShowEntrances()
        self:SendExitGatherState()
    end

    local Delay = bImmediately and 0 or 2
    _G.TimerMgr:AddTimer(nil, DoLeaveVision, Delay, 1, 1)
end

--断线重连拉取的数据
function GatherMgr:OnNetMsgGetGatherData(MsgBody)
    _G.ClientVisionMgr:EnableTick(true)

    self.bGameGetInfo = nil

    --_G.UIViewMgr:HideView(UIViewID.GatheringJobSkillPanel)
    local GatherPoint = MsgBody.GatherPoint
    if self.bLoginGetInfo then
        --刚登录，但是服务器已经退出采集状态了，这个时候可以忽略后面的流程
        --重置bLoginGetInfo = false
        if GatherPoint and GatherPoint.ListID == 0 then
            self.bLoginGetInfo = false
            self:MajorOnExitGatherState()
            return
        end

        self.CurHighProductionCastCount = GatherPoint and self:GetHighProductionCastSkill(GatherPoint.SkillUseCount) or 0
        self.GatherPointMsgInfo = GatherPoint
        return
    end

    if GatherPoint and GatherPoint.ListID == self.CurGatherListID then
        --正常登录获取的数据，先记录下，等采集点actor都刷过了之后再处理
        
        self.CurHighProductionCastCount = self:GetHighProductionCastSkill(GatherPoint.SkillUseCount) or 0

        if self.CurGatherEntranceItem then
            local EntityID = _G.ClientVisionMgr:GetEntityIDByMapEditorID(GatherPoint.ListID, GatherActorType)
            self.CurActiveEntityID = EntityID
            
            _G.InteractiveMgr.CurInteractEntityID = EntityID
            self:RestoreGatherState(GatherPoint, self.CurGatherEntranceItem.ResID)
            FLOG_INFO("GatherMgr Get GatherData CurActiveEntityID:%d, ListID:%d", EntityID, GatherPoint.ListID)
        end
    else
        --断线重连后，采集状态是属于退出状态的
        if not GatherPoint or GatherPoint and GatherPoint.ListID == 0 then
            FLOG_INFO("GatherMgr Get GatherData ExitGatherState")
            _G.FishMgr:StartMoveAndTurnChange(EndActionTime, false)  --这里可以兜底

            self.IsMoveExit = false
            self:SendExitGatherState(true)
            local GatherID = self.CurGatherEntranceItem.ResID
            self:ExitGatherState(MajorUtil.GetMajorEntityID(), GatherID)
        end
    end
    
    _G.CollectionMgr:OnNetMsgGetGatherData()
end

function GatherMgr:RestoreGatherEntranceItem(GatherPoint)
    if GatherPoint then
        local EntityID = _G.ClientVisionMgr:GetEntityIDByMapEditorID(GatherPoint.ListID, GatherActorType)
        local GatherActor = ActorUtil.GetActorByEntityID(EntityID)
        if GatherActor then
            local ResID = GatherActor:GetActorResID()
            self.CurGatherListID = GatherPoint.ListID
            self.CurActiveEntityID = EntityID
            self.CurGatherEntranceItem = EntranceGather.New()
            local EntranceParams = {
                IntParam1 = _G.UE.EActorType.Gather,
                ULongParam1 = EntityID,
                ULongParam2 = ResID,
            }
            self.CurGatherEntranceItem:Init(EntranceParams)

            return true
        else
            FLOG_ERROR("GatherMgr RestoreGatherEntranceItem GatherActor is nil")
        end
    end

    return false
end

function GatherMgr:RestoreGatherState(GatherPoint, ResID)
    FLOG_INFO("GatherMgr MajorNet Get GatherData Total:%d", GatherPoint.TotalPickCount)
    self:DoUpdateGatherInfo(GatherPoint.ListID, GatherPoint.PickCountLeft, GatherPoint.TotalPickCount)

    local FunctionList = self:GenFunctionList(GatherPoint.GatherItemList)
    if #FunctionList > 0 and ResID and ResID > 0 then
        self:EnterGatherState(MajorUtil.GetMajorEntityID(), ResID)

        local BonusID = 0
        local Cfg = GatherPointCfg:FindCfgByKey(ResID)
        if Cfg then
            BonusID = Cfg.Bonus
        end

        self:CancelDelayHidePanelTimer()
        self:ShowGatherPanel({FuncList = FunctionList, BonusMap = GatherPoint.BonusState, FixBonusID = BonusID})
        -- local BonusState = {}
        -- BonusState[1] = true
        -- BonusState[2] = false
        -- GatherPoint.BonusState = BonusState
        -- _G.UIViewMgr:ShowView(UIViewID.GatheringJobPanel,          )

        self:RefreshSkillState()

        for _, BonusValidVal in pairs(GatherPoint.BonusState) do
            if BonusValidVal > 0 then
                --采集点播放特效
                --todo
                return
            end
        end
    end
end

function GatherMgr:ShowGatherPanel(Params)
    local bGatheringPanelShow = _G.UIViewMgr:IsViewVisible(UIViewID.GatheringJobPanel)
    if not bGatheringPanelShow then
        self.TopLeftUIVisible = MainPanelVM:GetTopLeftMainTeamPanelVisible()
        if self.TopLeftUIVisible then
            MainPanelVM:SetTopLeftMainTeamPanelVisible(false)
        end
        
        MainPanelVM:SetEmotionVisible(false)
        MainPanelVM:SetPhotoVisible(false)
        MountVM:SetMountCallBtnVisible(false)

        self.TopRightUIVisible = MainPanelVM:GetPanelTopRightVisible()
        if self.TopRightUIVisible then
            MainPanelVM:SetPanelTopRightVisible(false)
        end
    end

    self.GatherJobPanelParams = Params
    -- local BonusState = {}
    -- BonusState[1] = true
    -- BonusState[2] = false
    -- GatherPoint.BonusState = BonusState
    Params.bAnimIn = true
    _G.UIViewMgr:ShowView(UIViewID.GatheringJobPanel, Params)
    Params.bAnimIn = false

    --触发新手引导采集状态
    local function OnGatherTutorial(Params)
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.GatheringStatus--新手引导触发类型
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnGatherTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--更新产出物列表，进行二级列表的展示
function GatherMgr:OnNetMsgEnterGatherState(MsgBody)
	if MsgBody.ErrorCode then
        _G.EventMgr:SendEvent(_G.EventID.DeActiveGatherItemView, self.CurActiveEntityID)
        return
    end

    --_G.UIViewMgr:HideView(UIViewID.GatheringJobSkillPanel)
    local GatherStart = MsgBody.GatherStart
    if GatherStart and GatherStart.ListID == self.CurGatherListID then
        FLOG_INFO("GatherMgr MajorNet Enter GatherState Total:%d", GatherStart.TotalPickCount)
        -- local Tmp = GatherStart.GatherItemList[3]
        --         Tmp.CommonSkillUp = false
        --         Tmp.ItemID = 66905011
        --         Tmp.HQSkillUp = false
        --         Tmp.CommonGatherRate = 10000
        --         Tmp.HQGatherRate = 0
        -- Tmp.FirstGather = false
        self.IsGathering = true
        self:DoUpdateGatherInfo(GatherStart.ListID, GatherStart.PickCountLeft, GatherStart.TotalPickCount)

        local FunctionList = self:GenFunctionList(GatherStart.GatherItemList)
        if #FunctionList > 0 then
            local BonusID = 0
            if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
                BonusID = self.CurGatherEntranceItem.Cfg.Bonus
            end

            -- local BonusState = {}
            -- BonusState[1] = true
            -- BonusState[2] = false
            -- GatherStart.BonusState = BonusState

            self:ShowGatherPanel({FuncList = FunctionList, BonusMap = GatherStart.BonusState, FixBonusID = BonusID})

            for _, BonusValidVal in pairs(GatherStart.BonusState) do
                if BonusValidVal > 0 then
                    --采集点播放特效
                    --todo
                    return
                end
            end
        -- _G.InteractiveMgr:SetFunctionList(FunctionList)
        end
    -- else
    --     FLOG_ERROR("GatherMgr MajorNet Enter GatherState Error")
    --     --Test：todo to del pcw
    --     if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
    --         local GatherItemList = {{}, {}, {}}
    --         GatherItemList[1].ItemID = 63000080
    --         GatherItemList[1].FirstGather = true
    --         GatherItemList[1].CommonSkillUp = true
    --         GatherItemList[2].ItemID = 62400129
    --         GatherItemList[2].HQSkillUp = true
    --         GatherItemList[3].ItemID = 62400130
    --         for index = 1, 3 do
    --             GatherItemList[index].CommonGatherRate = 5025
    --             GatherItemList[index].HQGatherRate = 302
    --         end

    --         local FunctionList = self:GenFunctionList(GatherItemList)
    --         if #FunctionList > 0 then
    --             _G.InteractiveMgr:SetFunctionList(FunctionList)
    --         end
    --     end
    end
end

--离开采集状态
function GatherMgr:SendExitGatherState(NotSendMsg)
    if not MajorUtil.IsGatherProf() then
        return
    end

    if not self.IsGathering then
        FLOG_WARNING("GatherMgr don't need SendExitGatherState")
        return
    end

    self.IsRealGathering = false
    _G.EventMgr:SendEvent(_G.EventID.DeActiveGatherItemView, self.CurActiveEntityID)
    _G.EventMgr:SendEvent(_G.EventID.ForcePeacePanel)

    if NotSendMsg then
        return
    end

    if _G.CollectionMgr.IsCollectionState then
        _G.CollectionMgr:DoExitCollectionStateReq()
    end

    FLOG_INFO("GatherMgr Major SendExitGatherState")

    local MsgID = CS_CMD.CS_CMD_LIFE_SKILL
    local SubMsgID = CS_SUB_CMD.LIFE_SKILL_GATHER_END_CMD

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    -- MsgBody.GatherEnd = {}

    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function GatherMgr:OnNetMsgExitGatherState(MsgBody)

end

--获取采集物的AnimID
function GatherMgr:GetGatherToolAnimID(GatherID)
    local Cfg = GatherPointCfg:FindCfgByKey(GatherID)
    if Cfg == nil then
        FLOG_ERROR("[AnimMgr:GetGatherToolAnimID ] ID %d is invalid ", GatherID)
        return
    end

    local ToolID = Cfg.GatherTool
    if not ToolID then
        FLOG_ERROR("AnimMgr Gather(%d)'s Tool is error", GatherID)
        return
    end

    local AnimCfg = RecipetoolAnimCfg:FindCfgByKey(ToolID)
    if AnimCfg == nil then
        FLOG_ERROR("[AnimMgr ToolID(%d)'s AnimID is invalid ", ToolID)
        return
    end

    return AnimCfg.AnimID
end

function GatherMgr:CancelDelayHidePanelTimer()
    if self.DelayHidePanelTimerID then
        _G.TimerMgr:CancelTimer(self.DelayHidePanelTimerID)
        self.DelayHidePanelTimerID = nil
    end
end

function GatherMgr:EnterGatherState(EntityID, GatherID, CallBack)
    self:ShowGatherWeapon(EntityID, GatherID)

    if EntityID == MajorUtil.GetMajorEntityID() then
        self:CancelDelayHidePanelTimer()
    
        -- 通用状态进入采集状态
        CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_PICKUP, true)

        FLOG_INFO("GatherMgr Major Enter GatherState")
        self.IsGathering = true
        self.IsRealGathering = true

        _G.EventMgr:SendEvent(_G.EventID.EnterGatherState)

        ChangeVelocityRangeCheck(InputRangeCheckValue)
        self:RegisterGameEvent(_G.EventID.InputRangeChange, self.OnInputRangeChange)
        _G.FishMgr:StartMoveAndTurnChange(0, true)
        ChangeCalculateVelocityRange(true)
        self.IsMoveExit = false
        MountVM:SetMountCallBtnVisible(false)
        MainPanelVM:SetEmotionVisible(false)
        MainPanelVM:SetPhotoVisible(false)
        
        _G.SkillLogicMgr:SetSkillButtonEnable(
            EntityID,
            SkillBtnState.GatherStateCannotDiscover,
            self,
            function(_, Index, SkillID)
                if self:IsDiscoverSkill(SkillID) then
                    return false
                end

                return
            end
        )

        if _G.SingBarMgr:GetMajorIsSinging() then
            _G.SingBarMgr:OnMajorSingOver(EntityID, true, true)
        end
            
        _G.NaviDecalMgr:SetNavPathHiddenInGame(true)
        _G.NaviDecalMgr:DisableTick(true)
        _G.BuoyMgr:ShowAllBuoys(false)

    else
        _G.EventMgr:SendEvent(_G.EventID.OthersEnterGatherState,EntityID)
    end

    local AnimID = self:GetGatherToolAnimID(GatherID)
    if not AnimID then
        return
    end

    _G.AnimMgr:PlayEnterAnim(EntityID, AnimID, CallBack)
end

function GatherMgr:ExitGatherState(EntityID, GatherID)
    local MajorEntityID = MajorUtil.GetMajorEntityID()

    if not self.IsGathering and EntityID == MajorEntityID then
        return
    end

    -- 清除选中
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.ULongParam1 = 0
    _G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)

    local EffectNode = self.EffectNodeMap[EntityID]
    if EffectNode then
        if EffectNode.DelayResultDisplayTimerID then
            _G.TimerMgr:CancelTimer(EffectNode.DelayResultDisplayTimerID)
        end

        self.EffectNodeMap[EntityID] = nil
    end

    if EntityID == MajorEntityID then
        self.CurHighProductionCastCount = 0
        self.CurActiveEntityID = 0

        CommonStateUtil.SetIsInState(ProtoCommon.CommStatID.COMM_STAT_PICKUP, false)

        FLOG_INFO("GatherMgr Major Exit GatherState")
        ChangeVelocityRangeCheck()
        self:UnRegisterGameEvent(_G.EventID.InputRangeChange, self.OnInputRangeChange)
        _G.FishMgr:StartMoveAndTurnChange(EndActionTime, false)
        ChangeCalculateVelocityRange(false)

        self.IsRealGathering = false
        self:DelayHidePanel(EndActionTime)
        FLOG_INFO("GatherMgr:ExitGatherState GatherMgr:DelayHidePanel")
        self.IsMoveExit = false

        _G.EventMgr:SendEvent(_G.EventID.ExitGatherState)
        
        _G.SkillLogicMgr:SetSkillButtonEnable(
            MajorEntityID,
            SkillBtnState.GatherStateCannotDiscover,
            self,
            function(_, Index, SkillID)
                if self:IsDiscoverSkill(SkillID) then
                    return true
                end
                
                return
            end
        )
    else
        _G.EventMgr:SendEvent(_G.EventID.OthersExitGatherState,EntityID)			--其他人退出采集状态
    end

    self:HideGatherWeapon(EntityID, GatherID)

    local AnimID = self:GetGatherToolAnimID(GatherID)
    if not AnimID then
        return
    end

    _G.AnimMgr:PlayExitAnim(EntityID, AnimID,function()
    _G.EventMgr:SendEvent(_G.EventID.CrafterAllExitAllState,EntityID)
    end)
end

function GatherMgr:DelayHidePanel(DelayTime)
    if not self.IsGathering then
        return
    end
        
    local bGatheringJobPaneShow = _G.UIViewMgr:IsViewVisible(UIViewID.GatheringJobPanel)
    local bGatheringJobSkillPanel = _G.UIViewMgr:IsViewVisible(UIViewID.GatheringJobSkillPanel)

    local function DoDelayHidePanel()
        -- FLOG_WARNING("pcw do DelayHidePanel")
        if bGatheringJobPaneShow then
            FLOG_INFO("GatherMgr:DelayHidePanel HideView(UIViewID.GatheringJobPanel)")
            local Params = {bAnimOut = true}
            _G.UIViewMgr:HideView(UIViewID.GatheringJobPanel, nil, Params)
        end

        if bGatheringJobSkillPanel then
            _G.UIViewMgr:HideView(UIViewID.GatheringJobSkillPanel, true)
        end

        -- if self.IsMoveExit then
            self:BackToInteractiveEntrance()
        -- end

        _G.NaviDecalMgr:SetNavPathHiddenInGame(false)
        _G.NaviDecalMgr:DisableTick(false)
        _G.BuoyMgr:ShowAllBuoys(true)

        self.DelayHidePanelTimerID = nil
        MountVM:SetMountCallBtnVisible(true)
        MainPanelVM:SetEmotionVisible(true)
        MainPanelVM:SetPhotoVisible(true)
    end

    if DelayTime then
        self:CancelDelayHidePanelTimer()
        self.DelayHidePanelTimerID = _G.TimerMgr:AddTimer(nil, DoDelayHidePanel, DelayTime, 0, 1)
    else
        DoDelayHidePanel()
    end
end

function GatherMgr:BackToInteractiveEntrance()
    InteractiveMgr:ShowEntrances()
    InteractiveMgr:ExitInteractive()
end

function GatherMgr:OnInputRangeChange(Params)
    if self.IsGathering and not self.IsMoveExit then
        self:TryExitGatherState(self, self.DoMoveExitGatherState)
    end
end

function GatherMgr:TryExitGatherState(UIView, CallBack)
    --判断该采集点是否有收藏品
    local HaveCollection = false
    local GatherItems = GatheringJobPanelVM:GetFunctionItems()
    if GatherItems ~= nil and #GatherItems > 0 then
        for _, value in pairs(GatherItems) do
            if value.IsCollection then
                HaveCollection = true
            end
        end
    end

    if self:IsRareGather() then
        MsgBoxUtil.ShowMsgBoxTwoOp(
            self,
            LSTR(10004), --"提 示"
            LSTR(160043), --'确定要中止采集吗？\n<span color="#DC5868FF">此采集地点将会消失</>'
            CallBack,
            nil,
            LSTR(160055), --"否"
            LSTR(190059) --"是"
        )
    elseif HaveCollection then
        --退出带有收藏品的采集点时，弹出一个通用2次确认框
        MsgBoxUtil.MessageBox(
        LSTR(160044), --160044"退出采集会清除收藏品的收藏价值，确定退出吗？"
        LSTR(10002), --"确定"
        LSTR(10003), --"取 消"
        CallBack,
        function()
        end,
        false
    )
    else
        CallBack(UIView)
    end
end

function GatherMgr:DoMoveExitGatherState()
    if self == nil then
        self = GatherMgr
    end
    local bTipsed = false
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local EffectNode = self.EffectNodeMap[MajorEntityID]
    if not EffectNode or EffectNode.IsSkillEnd then
        self:SendExitGatherState()
    else
        bTipsed = true
        MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherStoping)
    end

    if self.IsSimpleGather then
        --等本次采集结束，再中断简易采集
        if not bTipsed then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherStoping)
        end

        GatheringJobPanelVM:BreakSimpleGather()
    end

    self.IsMoveExit = true
    FLOG_WARNING("GatherMgr:OnInputRangeChange IsMoveExit = true")
end

function GatherMgr:ShowGatherWeapon(EntityID, GatherID)
    local GatherConfig = GatherPointCfg:FindCfgByKey(GatherID)
    if GatherConfig then
        if EntityID == MajorUtil.GetMajorEntityID() then
            self.IsGathering = true
        end

        local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
        local ProfID = nil
        if nil ~= AttributeComponent then
            ProfID = AttributeComponent.ProfID
        end

        local ToolID = GatherConfig.GatherTool
        if ProfID and self.ProfConfig[ProfID] and ToolID then
            FLOG_INFO("GatherMgr ShowWeapon %d %d", ToolID, EntityID)
            print(EntityID)

            _G.ActorMgr:SetToolMap(EntityID, ToolID)

        -- local IsMainWeapon = ToolID == ProfConfig[ProfID].MainWeapon
        -- if IsMainWeapon then
        --     _G.UE.UActorUtil.AddHideAvatarPart(ProfConfig[ProfID].SecondWeapon, false)
        -- else
        --     _G.UE.UActorUtil.AddHideAvatarPart(ProfConfig[ProfID].MainWeapon, false)
        -- end

        -- --只update1次
        -- _G.UE.UActorUtil.RemoveHideAvatarPart(ToolID, true)
        end
    end
end

--本地玩家 退出采集状态的数据清理
function GatherMgr:MajorOnExitGatherState()
    self.IsGathering = false
    self.CurHighProductionCastCount = 0
    self.SimpleGatherFunctionItem = nil
    self:OnSimpleGatherStateChange(false)

    GatheringJobPanelVM:EndSimpleGather()

    local CurDuration = self.CacheDurationMap and self.CacheDurationMap[self.CurActiveEntityID] or 0
    self:OnGatherAttrChange(self.CurActiveEntityID, CurDuration, true)
end

function GatherMgr:MajorOnExitSimpleGatherState()
    self:OnSimpleGatherStateChange(false)
end

function GatherMgr:IsGatherState()
    return self.IsGathering
end

--常规采集的时候，点关闭按钮，当做MoveExit
function GatherMgr:SetIsMoveExit(NotSendMsg)
    if self.IsGathering then
        self.IsMoveExit = true

        local MajorEntityID = MajorUtil.GetMajorEntityID()
        local EffectNode = self.EffectNodeMap[MajorEntityID]
        if (not EffectNode or EffectNode.IsSkillEnd) and not NotSendMsg then
            self:SendExitGatherState()
            return
        end

        MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherStoping)
    end
end

function GatherMgr:GetIsMoveExit()
    return self.IsMoveExit
end

function GatherMgr:GetIsSimpleGather()
    return self.IsSimpleGather
end

function GatherMgr:HideGatherWeapon(EntityID, GatherID)
    local GatherConfig = GatherPointCfg:FindCfgByKey(GatherID)
    if GatherConfig then
        if EntityID == MajorUtil.GetMajorEntityID() then
            --本地玩家 退出采集状态的数据清理
            self:MajorOnExitGatherState()
        end

        --恢复武器的显示
        --只update1次
        local AttributeComponent = ActorUtil.GetActorAttributeComponent(EntityID)
        local ProfID = nil
        if nil ~= AttributeComponent then
            ProfID = AttributeComponent.ProfID
        end

        local ToolID = GatherConfig.GatherTool
        if ProfID and self.ProfConfig[ProfID] and ToolID then
            FLOG_INFO("GatherMgr HideWeapon")
            _G.ActorMgr:SetToolMap(EntityID, nil)

        -- _G.UE.UActorUtil.RemoveHideAvatarPart(ProfConfig[ProfID].MainWeapon, false)
        -- _G.UE.UActorUtil.RemoveHideAvatarPart(ProfConfig[ProfID].SecondWeapon, true)
        end
    end
end

function GatherMgr:IsCanGather(GatherType, ProfID, GatherLevel)
    if not self:IsCanGatherByProf(GatherType, ProfID) then
        return false
    end

    if GatherLevel then
        if MajorUtil.GetMajorLevel() < GatherLevel - 9 then
            return false
        end
    end

    return true
end

function GatherMgr:IsCanGatherByProf(GatherType, ProfID)
    if
        ProfID == ProtoCommon.prof_type.PROF_TYPE_MINER and
            (GatherType == GATHERPOINTTYPE.GATHER_POINT_TYPE_MINE or
                GatherType == GATHERPOINTTYPE.GATHER_POINT_TYPE_STONE)
     then
        return true
    elseif
        ProfID == ProtoCommon.prof_type.PROF_TYPE_BOTANIST and
            (GatherType == GATHERPOINTTYPE.GATHER_POINT_TYPE_WOOD or
                GatherType == GATHERPOINTTYPE.GATHER_POINT_TYPE_GRASS)
     then
        return true
    end

    return false
end

function GatherMgr:GetMaxGatherCount(ResID, ListID)
    local MaxHp = 4

    if ListID then
        local TotalCount = self.TotalPickCountMap[ListID]
        if TotalCount and TotalCount >= MaxHp then
            return TotalCount
        end
    end

    local Cfg = GatherPointCfg:FindCfgByKey(ResID)
    if Cfg then
        MaxHp = Cfg.GatherCount
    end

    return MaxHp
end

function GatherMgr:GatherSkillPreCheck(ResID)
    local Major = MajorUtil:GetMajor()
    if Major then
        local NoteCfg = GatherNoteCfg:FindCfgByItemID(ResID)
        if NoteCfg then
            local MajorAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gathering)
            if NoteCfg.MinAcquisition > MajorAttr then
                MsgTipsUtil.ShowTipsByID(MsgTipsID.GatheringNotEnough)
            else
                local CurInsightAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_perception)
                if CurInsightAttr < NoteCfg.MinInsight then
                    return false
                end

                if not _G.GatherMgr.IsGathering then
                    MsgTipsUtil.ShowTipsByID(MsgTipsID.GatherNotInState)
                else
                    return true
                end
            end
        else
            return true
        end
    end

    return false
end

function GatherMgr:SimpleGatherItem(FunctionItem)
    FLOG_INFO("Interactive SimpleGatherItem %s DoClick", FunctionItem.DisplayName)
    if not self.IsSimpleGather then
        return -1
    end

    if not self:GatherSkillPreCheck(FunctionItem.ResID) then
        return -1
    end

    _G.SkillLogicMgr:CastMainAttackSkill()

    self.SimpleGatherFunctionItem = FunctionItem
    GatheringJobPanelVM.SimpleGatherItemVM:UpdateVM(FunctionItem)

    return 1
end

function GatherMgr:GetCurActiveGatherDuration()
    local CurDuration = 0
    if self.CurActiveEntityID then
        CurDuration = self.CacheDurationMap[self.CurActiveEntityID] or 0
    end

    return CurDuration
end

function GatherMgr:SetGatherItemID(ItemResID)
    self.GatherItemResID = ItemResID
end

function GatherMgr:GetGatherItemID()
    return self.GatherItemResID
end

function GatherMgr:OnGatherItemClick(FunctionItem)
    FLOG_INFO("Interactive GatherItem %s DoClick", FunctionItem.DisplayName)
    if self.IsSimpleGather then
        return 3 --正在简易采集中
    end

    if not self.IsRealGathering then
        -- FLOG_WARNING("GatherMgr SendExitState msg not receive, so IsGathering is true")
        return
    end

    self.IsSimpleGather = false
    if GatheringJobPanelVM.CheckState == _G.UE.EToggleButtonState.Checked then
        self:OnSimpleGatherStateChange(true)
    end

    if not self:GatherSkillPreCheck(FunctionItem.ResID) then
        self.IsSimpleGather = false
        return -1
    end

    --如果是收藏品,并且未进入收藏状态时
    local NoteCfg = GatherNoteCfg:FindCfgByItemID(FunctionItem.ResID)
    if NoteCfg and NoteCfg.IsCollection == 1 and not _G.CollectionMgr.IsCollectionState then
        FLOG_WARNING("EnterCollectionState()")
        self:EnterCollectionState()
        self:OnSimpleGatherStateChange(false)
        return
    end

    --正常采集
    if not self.IsSimpleGather then
        FLOG_INFO("Interactive Function Click CastSkill")
        local SkillRlt = _G.SkillLogicMgr:CastMainAttackSkill() --普攻,发完消息后，服务器会判定是否是收藏品，如果是就会回收藏品的消息，CollectionMgr接收

        return 1, SkillRlt
    end
    -- else --简易采集
        self.SimpleGatherFunctionItem = FunctionItem
        GatheringJobPanelVM.SimpleGatherItemVM:UpdateVM(FunctionItem)
        GatheringJobPanelVM:BeginSimpleGather()
        --当数值改变后，会回调GatheringJobMaterialItemView:OnBeginSimpleGather（）--计时连续普攻
        return 2
    -- end

    -- return -1 --出问题了，无法采集
end

function GatherMgr:GetGatherPointPos(PickItem, WorldOriginPos)
    if WorldOriginPos == nil then
        WorldOriginPos = _G.PWorldMgr:GetWorldOriginLocation()
    end

    local LocVec = _G.UE.FVector(PickItem.Point.X, PickItem.Point.Y, PickItem.Point.Z)
    LocVec = LocVec + WorldOriginPos

    return LocVec
end

--获取某个地图某个采集点的坐标列表
function GatherMgr:GetGatherPoints(MapID, GatherPointID)
    local PosList = {}

    local Cfg = GatherPointCfg:FindCfgByKey(GatherPointID)
    if not Cfg then
        FLOG_WARNING("GatherMgr GetGatherPoints, but not in GatherPointCfg")
        return PosList
    end

    local MapEditCfg
    local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    local WorldOriginPos = _G.UE.FVector(0, 0, 0)
    if CurMapEditCfg and CurMapEditCfg.MapID == MapID then
        MapEditCfg = CurMapEditCfg
        WorldOriginPos = _G.PWorldMgr:GetWorldOriginLocation()
    else
        MapEditCfg = _G.MapEditDataMgr:GetMapEditCfgByMapIDEx(MapID)
    end

    if MapEditCfg then
        for index = 1, #MapEditCfg.PickItemList do
            local PickItem = MapEditCfg.PickItemList[index]
            if PickItem.ResID == GatherPointID then
                local LocVec = self:GetGatherPointPos(PickItem, WorldOriginPos)
                table.insert(PosList, LocVec)
            end
        end
    end

    return PosList
end

function GatherMgr:GetAllGatherPoints()
    local WorldOriginPos = _G.UE.FVector(0, 0, 0)
    local GatherPointList = {}

    local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if CurMapEditCfg then
        WorldOriginPos = _G.PWorldMgr:GetWorldOriginLocation()

        --test begin
        local MajorActor = MajorUtil.GetMajor()
        if not MajorActor then
            return {}
        end

        if not MajorUtil.IsGatherProf() then
            return {}
        end

        local MajorPos = MajorActor:FGetActorLocation()
        local FVector = _G.UE.FVector
        --test end

        FLOG_INFO("Minimap GetAllGatherPoints")

        local bAddTimeLimit = false
        for ListID, PickItem in pairs(self.MiniMapGatherMap) do
            if self:GatherCanPick(PickItem, CurMapEditCfg.MapID) then
                local LocVec = self:GetGatherPointPos(PickItem, WorldOriginPos)

                local bTimeLimit = ListID == self.TimeLimitListID
                FLOG_INFO("GetAllGather listID:%d, Dist:%f bTimeLimit:%s", ListID, FVector.Dist(MajorPos, LocVec), tostring(bTimeLimit))
                if bTimeLimit then
                    bAddTimeLimit = true
                end

                --小地图主动调的，就不触发AddMiniMapTimeLimitGatherPoint这个事件了
                table.insert(GatherPointList, {ListID = ListID, ResID = PickItem.ResID, Pos = LocVec, IsTimeLimit = bTimeLimit})
            end
        end
        
        --有可能限时采集点不在小地图视野，不在self.MiniMapGatherMap，所以需要这样
        if not bAddTimeLimit and self.TimeLimitParams and self.TimeLimitParams.ListID > 0 then
            table.insert(GatherPointList, self.TimeLimitParams)
        end
    end

    return GatherPointList
end

--这些不区分能不能采集
function GatherMgr:GatherEnterMiniMap(MapPickItem)
    local ListID = MapPickItem.ListId
    if MapPickItem.bFutureVersion or self.MiniMapGatherMap[ListID] then
        return
    end

	if MapPickItem.bFutureVersion == nil then
        local ResID = MapPickItem.ResID
		local Cfg = GatherPointCfg:FindCfgByKey(ResID)
		if Cfg then
			--if not _G.ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.Version) then 
            if not _G.GatheringLogMgr:BeIncludedInGameVersion(Cfg.Version) then --采集笔记版本控制的GM会更改版本号
				MapPickItem.bFutureVersion = true
                return
			else
				MapPickItem.bFutureVersion = false
			end
		end
	end

    self.MiniMapGatherMap[ListID] = MapPickItem

    local CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if CurMapEditCfg then
        if self:GatherCanPick(MapPickItem, CurMapEditCfg.MapID, true) then
            local Params = {ListID = ListID, ResID = MapPickItem.ResID, Pos = self:GetGatherPointPos(MapPickItem, nil)}
            FLOG_INFO("Gather AddMiniMapGatherPoint %d", ListID)
            _G.EventMgr:SendEvent(_G.EventID.AddMiniMapGatherPoint, Params)
        end
    end
end

function GatherMgr:IsTimeLimitGather(ResID)
    local Cfg = GatherPointCfg:FindCfgByKey(ResID)
    if Cfg and Cfg.IsUnknownLoc == 1 then
        return true
    end

    return false
end

function GatherMgr:GatherLeaveMiniMap(MapPickItem)
    local ListID = MapPickItem.ListId
    if self.MiniMapGatherMap[ListID] then
        self.MiniMapGatherMap[ListID] = nil
        
        if ListID == self.TimeLimitListID then  --限时采集点一直在小地图
            FLOG_INFO("Gather GatherLeaveMiniMap TimeLimit %d", ListID)
            return
        end

        FLOG_INFO("Gather RemoveMiniMapGatherPoint %d", ListID)
        _G.EventMgr:SendEvent(_G.EventID.RemoveMiniMapGatherPoint, {ListID = ListID, ResID = MapPickItem.ResID})
    end
end

--参数是 {ListID = MapEditorID, ResID = ResID, Pos = LocVec, bShow = true/false}
function GatherMgr:FindNearestGatherPoint()
    local AllGathers = _G.UE.UActorManager.Get():GetAllGathers()
    local MajorActor = MajorUtil.GetMajor()
    if not MajorActor then
        return nil
    end

    -- if self.UpdateNearestGatherPointParams then
    --     self.UpdateNearestGatherPointParams.bShow = false
    --     if self.UpdateNearestGatherPointParams.ListID then
    --         FLOG_INFO("Major GatherDiscover remove nearestgather")
    --         _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)
    --     end
    -- end

    local MajorPos = MajorActor:FGetActorLocation()

    local NearestGather = nil
    local Rlt = nil
    local FVector = _G.UE.FVector
    local Length = AllGathers:Length()
    if Length > 0 then
        local MinDist = 1999999999

        for i = 1, Length do
            local Gather = AllGathers:GetRef(i)
            local ResID = Gather:GetActorResID()
            if not self:IsTimeLimitGather(ResID) then
                local Dist = FVector.Dist(MajorPos, Gather:FGetActorLocation())
                if Dist < MinDist then
                    NearestGather = Gather
                    MinDist = Dist
                end
            end
        end

        if NearestGather then
            local NearestPos = NearestGather:FGetActorLocation()
            local AttrComp = NearestGather:GetAttributeComponent()
            if AttrComp then
                FLOG_INFO(
                    "Major GatherDiscover find %d success in vision, Dist:%f",
                    AttrComp.ListID,
                    FVector.Dist(MajorPos, NearestPos)
                )
                
                Rlt = {ListID = AttrComp.ListID, ResID = AttrComp.ResID, Pos = NearestPos, bShow = true}
            end
        end
    end

    if not Rlt then
        local PickItem = _G.ClientVisionMgr:FindNearestGatherPointOutVision()
        if PickItem then
            local OriginLocation = _G.UE.UWorldMgr.Get():GetOriginLocation()
            local LocVec = self:GetGatherPointPos(PickItem, OriginLocation)
            FLOG_INFO(
                "Major GatherDiscover find %d success out vision, read db cnt:%d, Dist:%f",
                PickItem.ListId,
                _G.ClientVisionMgr.CheckGatherPointCnt,
                FVector.Dist(MajorPos, LocVec)
            )

            Rlt = {ListID = PickItem.ListId, ResID = PickItem.ResID, Pos = LocVec, bShow = true}
        end
    end

    return Rlt
end

function GatherMgr:GetNearestGatherPointInfo()
    return self.UpdateNearestGatherPointParams
end

function GatherMgr:OnMajorAddBuffLife(BuffInfo)
    local BuffID = BuffInfo.BuffID
    local BuffCfg = LifeskillEffectCfg:FindCfgByKey(BuffID)
    if BuffCfg and BuffCfg.Effect then
        for index = 1, #BuffCfg.Effect do
            if BuffCfg.Effect[index].type == ProtoRes.LIFESKILL_EFFECT_TYPE.LIFESKILL_EFFECT_TYPE_MAP_DISCOVER then
                self.UpdateNearestGatherPointParams = self:FindNearestGatherPoint()
                self.GatherDisCoverBuffID = BuffID

                if self.UpdateNearestGatherPointParams then
                    self.UpdateNearestGatherPointParams.bShow = true
                    FLOG_INFO("Major GatherDiscover success")
                    _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)
                    self:SetNearestGatherPointTip()
                else
                    FLOG_INFO("Major GatherDiscover failed")
                    MsgTipsUtil.ShowTipsByID(MsgTipsID.CurMapNoGatherPoint)
                end

                break
            elseif BuffCfg.Effect[index].type == ProtoRes.LIFESKILL_EFFECT_TYPE.LIFESKILL_EFFECT_TYPE_GATHERING_NUM then
                self.IsGatheringAddItemNum = true
                self:RefreshGatherAddItemNumSkill(MajorUtil.GetMajorEntityID())
                break
            end
        end
    end
end

function GatherMgr:OnMajorUpdateBuffLife(BuffInfo)
    local BuffID = BuffInfo.BuffID
    if self.GatherDisCoverBuffID and BuffID and self.GatherDisCoverBuffID == BuffID then
        local Params = self:FindNearestGatherPoint()
        if not Params then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.CurMapNoGatherPoint)
            FLOG_WARNING("Gather FindNearestGatherPoint is nil")
            return
        end

        if self.UpdateNearestGatherPointParams and self.UpdateNearestGatherPointParams.ListID
            and self.UpdateNearestGatherPointParams.ListID ~= Params.ListID then
            self.UpdateNearestGatherPointParams.bShow = false

            FLOG_INFO("Major GatherDiscover remove nearestgather")
            _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)
        end

        self.UpdateNearestGatherPointParams = Params
        _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, Params)

        if self.UpdateNearestGatherPointParams then
            self:SetNearestGatherPointTip()
        end
    end
end

function GatherMgr:GetDirDisTips(Point)
    local MajorActor = MajorUtil.GetMajor()
    local MajorPos = MajorActor:FGetActorLocation()
    local Xlen = Point.X - MajorPos.X
    local Ylen = MajorPos.Y - Point.Y
    --Distance
    local Distance = math.sqrt(Xlen * Xlen + Ylen * Ylen)
    local DisContent = tostring(math.floor(Distance / 100))
    --Direct
    local Angle = MathUtil.GetAngle(Xlen, Ylen)
    local CalDeg = Angle
    local OffsetDir = 360 / 16
    if CalDeg < OffsetDir then
        CalDeg = Angle + 360
    end
    local DegMinus = CalDeg - OffsetDir
    local DirContentIndex = math.floor(DegMinus / (360 / 8)) + 1
    local DirContent = AetherCurrentDefine.EightDirectContent[DirContentIndex] or ""

    return DirContent, DisContent
end

function GatherMgr:ShowGatherAreaTips(Point, ResID)
    local DirContent, DisContent = self:GetDirDisTips(Point)

    --Name
    local Cfg = GatherPointCfg:FindCfgByKey(ResID)
    if Cfg == nil then
        FLOG_ERROR(" GatherMgr:SetNearestGatherPointTip Cfg is nil")
        return
    end

    local Name = string.split(Cfg.Name, " ")
    local Content = ""
    if Cfg.IsUnknownLoc == 1 then
        Content = string.format(LSTR(160045), DirContent, DisContent, Name[1], Name[2]) --'<span color="#FFECB3FF">在%s%s米处发现了%s%s</>'
    else
        Content = string.format(LSTR(160046), DirContent, DisContent, Name[1], Name[2]) --'<span color="#FFECB3FF">在%s%s米处发现了%s的%s</>'
    end
    FLOG_WARNING("Gather %s", Content)
    -- MsgTipsUtil.ShowAreaTips(Content, 3)
    MsgTipsUtil.ShowTips(Content)
end

function GatherMgr:SetNearestGatherPointTip()
    local Point = self.UpdateNearestGatherPointParams.Pos
    self:ShowGatherAreaTips(Point, self.UpdateNearestGatherPointParams.ResID)
end

function GatherMgr:GMFindNearestGather()
    self.UpdateNearestGatherPointParams = self:FindNearestGatherPoint()

    if self.UpdateNearestGatherPointParams then
        -- FLOG_INFO("Major GatherDiscover success")
        _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)
    else
        FLOG_INFO("Major GatherDiscover failed")
    end
end

--也有可能勘察到的采集点，没等buff移除，就被主角采集完消失了。。。
function GatherMgr:OnMajorRemoveBuffLife(BuffInfo)
    local BuffID = BuffInfo.BuffID
    if BuffID == self.GatherDisCoverBuffID then
        self.UpdateNearestGatherPointParams = self.UpdateNearestGatherPointParams or {}
        self.UpdateNearestGatherPointParams.bShow = false

        FLOG_INFO("Major GatherDiscover remove %d", self.UpdateNearestGatherPointParams.ListID or -1)
        _G.EventMgr:SendEvent(_G.EventID.UpdateNearestGatherPoint, self.UpdateNearestGatherPointParams)

        self.UpdateNearestGatherPointParams = {}
    elseif self.IsGatheringAddItemNum then
        self.IsGatheringAddItemNum = false
        self:RefreshGatherAddItemNumSkill(MajorUtil.GetMajorEntityID())
    end
end

function GatherMgr:IsHighProductionSkill(SkillID)
    --采矿、园艺的高产技能
    if SkillID == 30105 or SkillID == 30205 then
        return true
    end

    return false
end

function GatherMgr:IsAddItemNumSkill(SkillID)
    --采矿、园艺的莫非王土的技能
    if SkillID == 30102 or SkillID == 30202 then
        return true
    end

    return false
end

function GatherMgr:GetHighProductionCastSkill(SkillUseCount)
    if not SkillUseCount then
        return 0
    end
    
    return SkillUseCount[30105] or SkillUseCount[30205]
end

function GatherMgr:IsDiscoverSkill(SkillID)
    --采矿、园艺的勘探采集点的技能
    if SkillID == 30106 or SkillID == 30206 then
        return true
    end

    return false
end

local function SignCompute(CompareA, CompareB, Sign)
    if CompareA == nil or CompareB == nil or Sign == nil then
        return false
    end
    local SignEnum = ProtoRes.condition_sign
    if Sign == SignEnum.CONDITION_SIGN_NULL then
        return true
    elseif Sign == SignEnum.CONDITION_SIGN_EQ then
        return CompareA == CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_LT then
        return CompareA < CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_LE then
        return CompareA <= CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_GT then
        return CompareA > CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_GE then
        return CompareA >= CompareB
    elseif Sign == SignEnum.CONDITION_SIGN_NE then
        return CompareA ~= CompareB
    end

    return false
end

local function GatherSkillCondition(Executor, _, ConditionID)
    local Cfg = LifeSkillConditionCfg:FindCfgByKey(ConditionID)
    if Cfg == nil or Executor == nil then
        return false
    end

    local Condition = ProtoRes.lifeskill_condition_type

    local Type = Cfg.Type
    local Param1 = Cfg.Param1
    local Param2 = Cfg.Param2
    local Sign = Cfg.Sign

    if Type == Condition.LIFESKILL_CONDITION_INVALID then
    elseif Type == Condition.LIFESKILL_CONDITION_SKILL_USE_LIMIT then	--生活技能次数限制
		local CastCount = _G.GatherMgr.CurHighProductionCastCount
        return SignCompute(CastCount, Param2, Sign)
    elseif Type == Condition.LIFESKILL_CONDITION_EFFECT_EXIST then	--存在状态
        local bContainBuff = _G.LifeSkillBuffMgr:IsMajorContainBuff(Param1)
        local ContainBuffInt = bContainBuff and 1 or 0
        return SignCompute(ContainBuffInt, Param2, Sign)
    end

    return true
end

function GatherMgr:OnDurationChange(EntityID, Duration)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if EntityID ~= self.CurActiveEntityID then
        return
    end
    -- FLOG_WARNING("pcw OnDurationChange")

    _G.SkillLogicMgr:SetSkillButtonEnable(
        MajorEntityID,
        SkillBtnState.GatherDurationMax,
        nil,
        function(_, SkillID)
            if not self:IsHighProductionSkill(SkillID) then
                return
            end

            if not self.IsGathering then
                return true
            end

            --耐久是满的话，是不能释放的
            --IsHighProductionSkill的技能才会回调； InitSkillMap的时候已经初始化Flag了
            if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
                -- local CanCast = true            
                -- local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
                -- if (ConditionStr ~= "" and ConditionStr ~= nil) then
                --     CanCast = RPNGenerator:ExecuteRPNBoolExpression(ConditionStr, self, nil, GatherSkillCondition)
                -- end

                local _, ListID = ActorUtil.GetInteractionObjInfo(EntityID)
                local TotalCount = self.TotalPickCountMap[ListID]
                -- if CanCast and 
                if TotalCount and TotalCount > Duration then
                    return true
                end

                -- if CanCast and 
                if self.CurGatherEntranceItem.Cfg.GatherCount > Duration then
                    return true
                end
            end

            return false
        end
    )

    _G.SkillLogicMgr:SetSkillButtonEnable(
        MajorEntityID,
        SkillBtnState.GatherHighProduceCnt,
        nil,
        function(_, SkillID)
            if not self:IsHighProductionSkill(SkillID) then
                return
            end
            
            if not self.IsGathering then
                -- FLOG_WARNING("pcw OnDurationChange cnt not gathring")
                return true
            end

            --耐久是满的话，是不能释放的
            --IsHighProductionSkill的技能才会回调； InitSkillMap的时候已经初始化Flag了
            if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
                local CanCast = true            
                local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
                if (ConditionStr ~= "" and ConditionStr ~= nil) then
                    CanCast = RPNGenerator:ExecuteRPNBoolExpression(ConditionStr, self, nil, GatherSkillCondition)
                end

                -- FLOG_WARNING("pcw OnDurationChange:%s", tostring(CanCast))
                if CanCast then
                    return true
                end
            end

            return false
        end
    )
    _G.GatheringJobSkillPanelVM:OnDurationChange(Duration)
end

function GatherMgr:OnGameEventActorGPChange(Params)
	if Params ~= nil then
		local EntityID = Params.ULongParam1
        if MajorUtil.IsMajor(EntityID) and MajorUtil.IsGatherProf() then
            self:RefreshGatherAddItemNumSkill(EntityID)
        end
    end
end

function GatherMgr:RefreshGatherAddItemNumSkill(EntityID)
    _G.SkillLogicMgr:SetSkillButtonEnable(
        EntityID,
        SkillBtnState.GatherAddItemNum,
        nil,
        function(_, SkillID)
            if not self:IsAddItemNumSkill(SkillID) then
                return
            end

            if not self.IsGathering then
                -- FLOG_WARNING("pcw OnDurationChange cnt not gathring")
                return true
            end

            --耐久是满的话，是不能释放的
            --IsHighProductionSkill的技能才会回调； InitSkillMap的时候已经初始化Flag了
            if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
                local CanCast = true            
                local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
                if (ConditionStr ~= "" and ConditionStr ~= nil) then
                    CanCast = RPNGenerator:ExecuteRPNBoolExpression(ConditionStr, self, nil, GatherSkillCondition)
                end

                -- FLOG_WARNING("pcw OnDurationChange:%s", tostring(CanCast))
                if CanCast then
                    return true
                end
            end

            return false
        end
    )
end

function GatherMgr:CheckHighProductionCastCount(SkillID)
    if not self.IsGathering then
        return false
    end

    if self.CurGatherEntranceItem and self.CurGatherEntranceItem.Cfg then
        local CanCast = true            
        local ConditionStr = SkillMainCfg:FindValue(SkillID, "LifeSkillCondition")
        if (ConditionStr ~= "" and ConditionStr ~= nil) then
            CanCast = RPNGenerator:ExecuteRPNBoolExpression(ConditionStr, self, nil, GatherSkillCondition)
        end

        if CanCast then
            return true
        end
    end

    return false
end

function GatherMgr:OnSimpleGatherStateChange(IsSimpleGather)
    self.IsSimpleGather = IsSimpleGather
    FLOG_INFO("Gather OnSimpleGatherStateChange: %s", tostring(IsSimpleGather))

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    _G.SkillLogicMgr:SetSkillButtonEnable(
        MajorEntityID,
        SkillBtnState.SimpleGathering,
        nil,
        function(_, SkillID)
            if IsSimpleGather then
                return false
            end

            return true
        end,
        nil,
        nil
    )
end

function GatherMgr:NavigateToMap(GatherID)
    local Cfg = GatherPointCfg:FindCfgByKey(GatherID)
    if Cfg == nil then return end

    local MapID = Cfg.MapID
    if MapID == nil then return end
    _G.WorldMapMgr:ShowWorldMap(MapID)
end

return GatherMgr

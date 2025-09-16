--
-- Author: sammrli
-- Date: 2023-12-28 10:16:50
-- Description:主界面配置
--

local GlobalCfg = require("TableCfg/GlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local EVisibility = {
    Visible = 1,
    Collapsed = 2,
    Hidden = 3,
    SelfHitTestInvisible = 4,
}

---隐藏配置
local HideConfigList = {}

---显示配置
--配置特殊副本主界面元素的显隐
local ShowConfigList = {}

---@class MainPanelConfig
local MainPanelConfig = {
    EVisibility = EVisibility,
}

function MainPanelConfig:Init()
    if self.IsInit then
        return
    end
    self.IsInit = true
    local TargetWorldID = nil
    local GlobalCfgItem = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GlobalCfgNewbieSceneID)
    if GlobalCfgItem then
        TargetWorldID = GlobalCfgItem.Value[1]
    else
        TargetWorldID = 1003017
    end
    local IsGMOpen = _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_GM)
    HideConfigList[TargetWorldID] = {
        --要与部件同名作索引
        ---@type MainPanelView
        MainLBottomPanel = EVisibility.Hidden,
        PWorldStagePanel = EVisibility.Hidden,
        MainFunctionList = EVisibility.Hidden,
        ButtonSkip = IsGMOpen and EVisibility.Visible or EVisibility.Hidden,
        MainTeamPanel = {
            ---@type MainTeamPanelView
            ToggleBtnPackUp = EVisibility.Hidden,
            ToggleBtnTeam = EVisibility.Hidden,
            ImgTabBase = EVisibility.Hidden,
            ImgTabFrame = EVisibility.Hidden,
            ImgTabBase_Small = EVisibility.SelfHitTestInvisible,
            ImgTabFrame_Small = EVisibility.SelfHitTestInvisible,
        }
    }
    ShowConfigList[TargetWorldID] = {
        --要与部件同名作索引
        ---@type MainPanelView
        MainLBottomPanel = EVisibility.SelfHitTestInvisible,
        MainFunctionList = EVisibility.SelfHitTestInvisible,
        ButtonSkip = EVisibility.Hidden,
        MainTeamPanel = {
            ---@type MainTeamPanelView
            ToggleBtnPackUp = EVisibility.Visible,
            ToggleBtnTeam = EVisibility.Visible,
            ImgTabBase = EVisibility.SelfHitTestInvisible,
            ImgTabFrame = EVisibility.SelfHitTestInvisible,
            ImgTabBase_Small = EVisibility.Hidden,
            ImgTabFrame_Small = EVisibility.Hidden,
        }
    }
end

---获取隐藏配置
function MainPanelConfig:GetHideConfig(WorldID)
    if not self.IsInit then
        self:Init()
    end
    return HideConfigList[WorldID]
end

---获取显示配置
function MainPanelConfig:GetShowConfig(WorldID)
    if not self.IsInit then
        self:Init()
    end
    return ShowConfigList[WorldID]
end

MainPanelConfig.TopRightInfoType = {
    None = 0,
    PWorldStage = 1, -- 副本进度
    FateStageInfo = 2, -- Fate信息
    PlayStyleInfo = 3, -- 机遇临门游戏信息
    JumboInfo = 4, -- 仙彩信息
    MagicCardTourneyInfo = 5, -- 幻卡大赛提醒
    MysterMerchantTask = 6,  -- 神秘商人任务信息
    ExclusiveBattleQuest = 7, -- 专属道具任务
}

MainPanelConfig.LifeProfEntranceType = {
    None = 0,

    CraftingLog = 1,  -- 制作笔记
    GatheringLog = 2,  -- 采集笔记
    FishNotes = 3,  -- 钓鱼笔记
    LeveQuest = 4,  -- 理符
    Collection = 5,  -- 收藏品
}

return MainPanelConfig
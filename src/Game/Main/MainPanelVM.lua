---
--- Author: anypkvcai
--- DateTime: 2021-04-10 17:43
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local prof_type = ProtoCommon.prof_type
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local WarningSkillCDItemVM = require("Game/PWorld/Warning/WarningSkillCDItemVM")
local UIBindableList = require("UI/UIBindableList")

local AllIconBookPath = {
	[prof_type.PROF_TYPE_MINER] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900157.UI_Icon_900157'",	-- 采矿工
	[prof_type.PROF_TYPE_BOTANIST] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900155.UI_Icon_900155'",	-- 园艺工
	[prof_type.PROF_TYPE_FISHER] = "Texture2D'/Game/Assets/Icon/900000/UI_Icon_900156.UI_Icon_900156'",	-- 捕鱼人
}
local ProtoRes = require("Protocol/ProtoRes")
local ModuleType = ProtoRes.module_type

---@class MainPanelVM : UIViewModel
local MainPanelVM = LuaClass(UIViewModel)

---Ctor
---@field OpenID number
---@field WorldID number
function MainPanelVM:Ctor()
    self.PanelTopRightVisible = true --右上角功能区显隐（包含小地图）
    self.MiniMapPanelVisible = true --小地图 或 中地图

    self.FunctionVisible = true --功能按钮
    self.AdventureVisible = true
    self.ShopVisible = true

    self.CurrTopRightInfoType = MainPanelConfig.TopRightInfoType.None
    self.PWorldStageVisible = false --副本进度
    self.FateStageInfoVisible = false --Fate信息
    self.PlayStyleInfoVisible = false --机遇临门游戏信息
    self.JumboInfoVisible = false -- 仙彩信息
    self.MagicCardTourneyInfoVisible = false -- 是否显示幻卡大赛提醒
    self.MysterMerchantTaskVisible = false  --是否显示神秘商人任务信息
    self.TeachingLevelVisible = false

    self.QuestTrackVisible = true --任务追踪
    self.TopLeftMainTeamPanelVisible = true --任务、组队的panel
    --self.TeamPanelVisible = true --显示队员信息 或 队伍伤害

    local bControlPanelAttrExist = false
    local bControlPanelVisible = true
    rawset(self, "bControlPanelAttrExist", bControlPanelAttrExist)
    rawset(self, "bControlPanelVisible", bControlPanelVisible)
    self.ControlPanelVisible = bControlPanelAttrExist and bControlPanelVisible --跑跳攻击

    self.ProBarVisible = false --进度槽
    self.ProBar02Visible = false --进度槽

    self.IsFightState = false -- 是否显示战斗技能
    -- self.TutorialVisible = true --

    self.EmotionVisible = true              --绑定view的表情按钮
    self.EmontionMainPanelVisible = true    --记录主界面的表情按钮visible的状态（为了各个业务方便才用了2个接口）
    self.PhotoVisible = true                --绑定view的拍照按钮
    self.PhotoMainPanelVisible = true       --记录主界面的表情按钮visible的状态（为了各个业务方便才用了2个接口）

    self.RideVisible = true

    self.ChatInfoVisible = false --聊天信息界面是否显示
    self.PersonChatHeadTipsPlayer = nil -- 发来新私聊消息的玩家RoleID

    -- 硬直测试版
    self.IsTestVersion = false

    --大地使者职业笔记快捷入口是否显示
    self.NotesVisible = false
    self.IconBook = ""

    self.bIsNeedShowMountPanel = false
    self.IsMountPanelVisible = false

    self.IsShowMainLBottomPanel = true

    self.IsReadingInfoVisible = false
    self.ReadingInfoSkillName = ""
    self.ReadingInfoPercent = 0
    -- 专属道具任务UI
    self.ExclusiveBattleQuestVisible = false

    self.IsTimeBarVisible = false
    self.IsEnmityPanelVisible = false
    self.WarningSkillCDItemListVisibile = false

    self.WarningSkillCDItemList = UIBindableList.New(WarningSkillCDItemVM)
end

function MainPanelVM:OnInit()
end

--RoleLife的，这个时候LoginMgr:IsModuleSwitchOn已经是有效的
function MainPanelVM:OnBegin()
    self.EmontionMainPanelVisible = _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_MOTION)
    self.EmotionVisible = self.EmontionMainPanelVisible
    self.PhotoMainPanelVisible = _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_PHOTO) or true   --临时开放，为了showcase
    self.PhotoVisible = self.PhotoMainPanelVisible
end

function MainPanelVM:OnEnd()
end

function MainPanelVM:OnShutdown()
end

function MainPanelVM:SetMiniMapPanelVisible(Visible)
    self.MiniMapPanelVisible = Visible
end

function MainPanelVM:GetMiniMapPanelVisible()
    return self.MiniMapPanelVisible
end

function MainPanelVM:SetWarningSkillCDItemListVisibile(Visible)
    self.WarningSkillCDItemListVisibile = Visible
end

function MainPanelVM:SetTopLeftMainTeamPanelVisible(Visible)
    self.TopLeftMainTeamPanelVisible = Visible
end

function MainPanelVM:GetTopLeftMainTeamPanelVisible()
    return self.TopLeftMainTeamPanelVisible
end

function MainPanelVM:Clear()
    self.WarningSkillCDItemList:Clear(false)
end

function MainPanelVM:UpdateWaringItems(Items)
    if self.WarningSkillCDItemList ~= nil then
        local number = table.length(Items)
        local length = self.WarningSkillCDItemList:Length()
        local offset = number - length

        if offset ~= 0 then
            if offset > 0 then
                local index = 1
                for _,Item in ipairs(Items) do
                    if index > length then
                        self.WarningSkillCDItemList:AddByValue(Item)
                    end
                    index = index + 1

                end
            else
                offset = _G.math.abs(offset)
                local index = 1

                while true do
                    self.WarningSkillCDItemList:RemoveAt(self.WarningSkillCDItemList:Length())

                    index = index + 1

                    if index >= offset then
                        break
                    end
                end
            end

            return true
        end
    end

    return false
end

---ShowTopRightInfoPanel
---@param Type MainPanelConfig.TopRightInfoType
function MainPanelVM:ShowTopRightInfoPanel(Type)
    self.CurrTopRightInfoType = Type

    self.PWorldStageVisible = Type == MainPanelConfig.TopRightInfoType.PWorldStage
    self.FateStageInfoVisible = Type == MainPanelConfig.TopRightInfoType.FateStageInfo
    self.PlayStyleInfoVisible = Type == MainPanelConfig.TopRightInfoType.PlayStyleInfo
    self.JumboInfoVisible = Type == MainPanelConfig.TopRightInfoType.JumboInfo
    self.MagicCardTourneyInfoVisible = Type == MainPanelConfig.TopRightInfoType.MagicCardTourneyInfo
    self.MysterMerchantTaskVisible = Type == MainPanelConfig.TopRightInfoType.MysterMerchantTask
    self.ExclusiveBattleQuestVisible = Type == MainPanelConfig.TopRightInfoType.ExclusiveBattleQuest

    self:SetFunctionVisible(false, Type)
end

---HideTopRightInfoPanel
---@param Type MainPanelConfig.TopRightInfoType
function MainPanelVM:HideTopRightInfoPanel(Type)
    if self.CurrTopRightInfoType == Type then
        self:SetFunctionVisible(true, Type)

        self.CurrTopRightInfoType = MainPanelConfig.TopRightInfoType.None

        self.PWorldStageVisible = false
        self.FateStageInfoVisible = false
        self.PlayStyleInfoVisible = false
        self.JumboInfoVisible = false
        self.MagicCardTourneyInfoVisible = false
        self.MysterMerchantTaskVisible = false
        self.ExclusiveBattleQuestVisible = false
    end
end

---HideTopRightInfoPanel
---@param Type MainPanelConfig.TopRightInfoType
function MainPanelVM:SetTopRightInfoPanelVisible(Visible, Type)
    if Visible then
        self:ShowTopRightInfoPanel(Type)
    else
        self:HideTopRightInfoPanel(Type)
    end
end

---SetFunctionVisible
---@param Reason MainPanelConfig.TopRightInfoType
function MainPanelVM:SetFunctionVisible(Visible, Reason)
    Reason = Reason or MainPanelConfig.TopRightInfoType.None
    if Reason == self.CurrTopRightInfoType or Reason == MainPanelConfig.TopRightInfoType.None then
        self.FunctionVisible = Visible
    end
end

-------------------------------------------------
---TopRightInfoPanel Interface Begin

function MainPanelVM:SetPWorldStageVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.PWorldStage)
end

function MainPanelVM:GetPWorldStageVisible()
    return self.PWorldStageVisible
end

function MainPanelVM:SetPlayStyleInfoVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.PlayStyleInfo)
end

function MainPanelVM:SetJumbpInfoVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.JumboInfo)
end

function MainPanelVM:SetFateStageVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.FateStageInfo)
end

function MainPanelVM:GetFateStageVisible()
    return self.FateStageInfoVisible
end

function MainPanelVM:SetMagicCardTourneyInfoVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.MagicCardTourneyInfo)
end

function MainPanelVM:GetMagicCardTourneyInfoVisible()
    return self.MagicCardTourneyInfoVisible
end

function MainPanelVM:SetMysterMerchantTaskVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.MysterMerchantTask)
end

function MainPanelVM:GetMysterMerchantTaskVisible()
    return self.MysterMerchantTaskVisible
end

---
-------------------------------------------------

function MainPanelVM:SetPanelTopRightVisible(Visible)
    self.PanelTopRightVisible = Visible
end

function MainPanelVM:GetPanelTopRightVisible()
    return self.PanelTopRightVisible
end

function MainPanelVM:SetControlPanelVisible(Visible)
    rawset(self, "bControlPanelVisible", Visible)
    self.ControlPanelVisible = Visible and rawget(self, "bControlPanelAttrExist")
end

function MainPanelVM:SetControlPanelAttrExist(bExist)
    rawset(self, "bControlPanelAttrExist", bExist)
    EventMgr:PostEvent(EventID.ControlPanelAttrExistChange, bExist)
    self.ControlPanelVisible = bExist and rawget(self, "bControlPanelVisible")
end

function MainPanelVM:GetControlPanelAttrExist()
    return rawget(self, "bControlPanelAttrExist")
end

function MainPanelVM:SetRideVisible(Visible)
    self.RideVisible = Visible
end

function MainPanelVM:GetQuestTrackVisible()
    return self.QuestTrackVisible
end

function MainPanelVM:SetPWorldProBarVisible(Visible)
    self.ProBarVisible = Visible
end

function MainPanelVM:GetPWorldProBarVisible()
    return self.ProBarVisible
end

function MainPanelVM:GetPWorldProBar02Visible()
    return self.ProBar02Visible
end

--function MainPanelVM:SetTeamPanelVisible(Visible)
--    self.TeamPanelVisible = Visible
--end

--function MainPanelVM:GetTeamPanelVisible()
--    return self.TeamPanelVisible
--end

function MainPanelVM:SetChatInfoVisible(IsVisible)
    self.ChatInfoVisible = IsVisible
end

function MainPanelVM:SetPersonChatHeadTipsPlayer(RoleID)
    self.PersonChatHeadTipsPlayer = RoleID
end

function MainPanelVM:SetIsFightState(IsFightState)
    self.IsFightState = IsFightState
    self:SetVisibleIconBook()
    -- if not IsFightState then
    --     CommonUtil.StartTGPATaskCheck()
    -- else
    --     CommonUtil.StopTGPATaskCheck()
    -- end
end

function MainPanelVM:SetVisibleIconBook()
	local ProfID = MajorUtil.GetMajorProfID()
	if ProfID then
		local ProfIconBookPath = AllIconBookPath[ProfID]
		if ProfIconBookPath then
			self.IconBook = ProfIconBookPath
            -- 捕鱼人职业按钮需要常驻
            if MajorUtil.IsFishingProf() then
                self.NotesVisible = true
            else
                self.NotesVisible = not self.IsFightState
            end
            return
		end
	end
    self.NotesVisible = false
end

function MainPanelVM:SetTeachingLevelVisible(IsVisible)
    self.TeachingLevelVisible = IsVisible
end

--主界面调用
function MainPanelVM:SetMainPanelEmotionVisible(IsVisible)
    if _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_MOTION) then
        self.EmontionMainPanelVisible = IsVisible
    else
        self.EmontionMainPanelVisible = false
    end
    
    self.EmotionVisible = self.EmontionMainPanelVisible
end

--上层各个业务逻辑调用 （为了各个业务方便才用了2个接口）
function MainPanelVM:SetEmotionVisible(IsVisible)
    if self.EmontionMainPanelVisible then
        self.EmotionVisible = IsVisible
    end
end

--主界面调用
function MainPanelVM:SetMainPanelPhotoVisible(IsVisible)
    if _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_PHOTO) or true then   --临时打开，为了showcase
        self.PhotoMainPanelVisible = IsVisible
    else
        self.PhotoMainPanelVisible = false
    end
    
    self.PhotoVisible = self.PhotoMainPanelVisible
end

--上层各个业务逻辑调用 （为了各个业务方便才用了2个接口）
function MainPanelVM:SetPhotoVisible(IsVisible)
    if self.PhotoMainPanelVisible then
        self.PhotoVisible = IsVisible
    end
end

function MainPanelVM:GetIsPhotoVisible()
    return self.PhotoVisible
end

--- 新手引导过程中 按钮显示控制
-- function MainPanelVM:SetTutorialVisible(IsVisible)
--     self.TutorialVisible = IsVisible

--     if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDAdventure) then
--         self.AdventureVisible = IsVisible
--     else
--         self.AdventureVisible = false
--     end

--     if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMall) then
--         self.ShopVisible = IsVisible
--     else
--         self.ShopVisible = false
--     end

--     if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMount) then
--         self.RideVisible = IsVisible
--     else
--         self.RideVisible = false
--     end

-- end

-- function MainPanelVM:GetTutorialVisible()
--     return self.TutorialVisible
-- end

local function RecursionSetSubViewsVisible(UIView, Config)
    if not UIView or not Config then
        return
    end
    for key, Val in pairs(Config) do
        local SubView = UIView[key]
        if SubView then
            if type(Val) == "table" then
                RecursionSetSubViewsVisible(SubView, Val)
            else
                if Val == MainPanelConfig.EVisibility.Visible then
                    UIUtil.SetIsVisible(SubView, true, true)
                elseif Val == MainPanelConfig.EVisibility.Hidden then
                    UIUtil.SetIsVisible(SubView, false)
                elseif Val == MainPanelConfig.EVisibility.SelfHitTestInvisible then
                    UIUtil.SetIsVisible(SubView, true)
                else
                    UIUtil.SetIsVisible(SubView, false, false, true)
                end
            end
        end
    end
end

---根据配置隐藏SubView
function MainPanelVM:SetSubViewsHideByConfig(UIView)
    local WorldID = _G.PWorldMgr:GetCurrPWorldResID()
    local ShowConfig = MainPanelConfig:GetHideConfig(WorldID)
    if ShowConfig then
        RecursionSetSubViewsVisible(UIView, ShowConfig)
    end
end

---根据配置显示SubView
function MainPanelVM:SetSubViewsShowByConfig(UIView, LeaveWorldResID)
    if not LeaveWorldResID then
        LeaveWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    end
    local ShowConfig = MainPanelConfig:GetShowConfig(LeaveWorldResID)
    if ShowConfig then
        RecursionSetSubViewsVisible(UIView, ShowConfig)
    end
end

---OnTestVersionChanged  @硬直测试开关变更
function MainPanelVM:OnTestVersionChanged(IsTestVersion)
    self.IsTestVersion = IsTestVersion
end

function MainPanelVM:SetExclusiveBattleQuestVisible(Visible)
    self:SetTopRightInfoPanelVisible(Visible, MainPanelConfig.TopRightInfoType.ExclusiveBattleQuest)
end

function MainPanelVM:GetExclusiveBattleQuestVisible()
    return self.ExclusiveBattleQuestVisible
end

function MainPanelVM:SetTimeBarVisible(IsVisible)
    self.IsTimeBarVisible = IsVisible
end

function MainPanelVM:SetEnmityPanelVisible(IsVisible)
    self.IsEnmityPanelVisible = IsVisible
end

function MainPanelVM:SetPackupToggleChecked(bCheckded)
    self.bPackupToggleChecked = bCheckded
end

function MainPanelVM:SetOnPVPMap(bOnPVPMap)
    self.bOnPVPMap = bOnPVPMap
end

return MainPanelVM

--
-- Author: loiafeng
-- Date: 2024-04-26 09:47:47
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")

local LoadingDefine = require("Game/Loading/LoadingDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local DialogueUtil = require("Utils/DialogueUtil")

local LevelExpCfg = require("TableCfg/LevelExpCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local QuestCfg = require("TableCfg/QuestCfg")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local FishCfg = require("TableCfg/FishCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")

local ActorMgr  ---@type ActorMgr

---@class LoadingVM : UIViewModel
local LoadingVM = LuaClass(UIViewModel)

function LoadingVM:Ctor()
    self.DisplayName = nil
    self.RegionName = nil

    self.UIType = nil  ---@type ProtoRes.LoadingUIType

    self.TextLabel  = nil
    self.TextTitle = nil
    self.TextBody = nil

    self.ProBarType = nil  ---@type ProtoRes.LoadingProBarType

    self.MainImage = nil
    self.LandscapeImage = nil

    -- 满级生产职业列表
    self.CrafterProfList = UIBindableList.New()
    -- 满级战斗职业列表
    self.CombatProfList = UIBindableList.New()
end

function LoadingVM:OnInit()
    ActorMgr = _G.ActorMgr
end

function LoadingVM:OnBegin()
    self.MaxLevel = LevelExpCfg:GetMaxLevel()
end

function LoadingVM:OnEnd()
end

function LoadingVM:OnShutdown()
end

function LoadingVM:UpdateName(Display, Region)
    self.DisplayName = Display
    self.RegionName = Region
end

local function GetImageAndText(ContentCfg)
    local LoadingType = ContentCfg.LoadingType
    local Image = ContentCfg.ImagePath
    local Text = ContentCfg.TextBody

    local Params = ContentCfg.Params
    if ProtoRes.LoadingType.LOADING_SINGLE_DUNGEON == LoadingType then  -- 单人本
        -- Params[1]: 任务章节ID
        -- Params[2]: 任务ID
        if Params[1] and Params[2] then
            Image = QuestChapterCfg:FindValue(Params[1], "LogImage")
            local TaskDesc = DialogueUtil.ParseLabel(QuestCfg:FindValue(Params[2], "TaskDesc"))
            Text = string.gsub(TaskDesc, "<[^>]*>", "")  -- 去除标签
        end
    elseif ProtoRes.LoadingType.LOADING_TEAM_DUNGEON == LoadingType then  -- 多人本
        -- Params[1]: 副本ID
        if Params[1] then
            Image = SceneEnterCfg:FindValue(Params[1], "BG")
            Text = SceneEnterCfg:FindValue(Params[1], "Summary")
        end
    elseif ProtoRes.LoadingType.LOADING_FISH == LoadingType then  -- 鱼类
        -- Params[1]: 渔场ID
        -- Params[2]: 鱼ID
        if Params[2] then
            local ItemID = FishCfg:FindValue(Params[2], "ItemID") or 0
            local IconID = ItemCfg:FindValue(ItemID, "IconID") or 0
            Image = IconID > 0 and ItemCfg.GetIconPath(IconID) or nil
            Text = FishCfg:FindValue(Params[2], "Description")
        end
    elseif ProtoRes.LoadingType.LOADING_LANDSCAPE == LoadingType then  -- 风景
        -- Params[1]: 探索笔记ID
        if Params[1] then
            Image = DiscoverNoteCfg:FindValue(Params[1], "RecordImg")
            Text = DiscoverNoteCfg:FindValue(Params[1], "ImpText")
        end
    end

    return Image, Text
end

function LoadingVM:UpdateContent(ContentCfg)
    if nil == ContentCfg then return false end

    self.LoadingType = ContentCfg.LoadingType
    self.UIType = ContentCfg.UIType
    self.ProBarType = ContentCfg.ProBarType

    self.TextLabel  = ContentCfg.TextLabel
    self.TextTitle = ContentCfg.TextTitle

    self.LandscapeImage = LoadingDefine.LandscapeImageMap[ContentCfg.LoadingType]

    self.MainImage, self.TextBody = GetImageAndText(ContentCfg)

    if string.isnilorempty(self.MainImage) or string.isnilorempty(self.TextBody) then
        FLOG_ERROR("LoadingVM.UpdateContent: Invalid Image or Text. ContentID: " .. ContentCfg.ID)
        return false
    end

    return true
end

function LoadingVM:UpdateProf()
    local RoleDetail = ActorMgr:GetMajorRoleDetail()
    if nil == RoleDetail then
        return
    end
    local ProfList = (RoleDetail.Prof or {}).ProfList
    if nil == ProfList then
        return
    end

    self.CrafterProfList:EmptyItems()  -- 没有使用ViewModel，不能使用Clear
    self.CombatProfList:EmptyItems()

    local MaxLevelProfs = {}
    for _, ProfInfo in pairs(ProfList) do
        if ProfInfo.Level >= self.MaxLevel then
            local AdvanceProfID = RoleInitCfg:FindProfAdvanceProf(ProfInfo.ProfID) or 0
            if 0 == AdvanceProfID or ((ProfList[AdvanceProfID] or {}).Level or 0) < self.MaxLevel then
                table.insert(MaxLevelProfs, ProfInfo.ProfID)
            end
        end
    end

    table.sort(MaxLevelProfs, function(lhs, rhs) return lhs < rhs end)

    for _, ID in ipairs(MaxLevelProfs) do
        local Value = { ProfID = ID }
        if ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT == RoleInitCfg:FindProfSpecialization(ID) then
            self.CombatProfList:Add(Value)
        elseif ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION == RoleInitCfg:FindProfSpecialization(ID) then
            self.CrafterProfList:Add(Value)
        end
    end
end

return LoadingVM
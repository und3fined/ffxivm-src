local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local SkillTipsUtil = require("Utils/SkillTipsUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local SkillUtil = require("Utils/SkillUtil")
local CommSkillTipsItemVM = require("Game/Common/Tips/VM/CommSkillTipsItemVM")
local UIBindableList = require("UI/UIBindableList")

local SkillNameDefaultColor <const> = "#FFFFFFFF"
local MountSkillNameDefaultColor  <const> = "#D1BA8EFF"
local ChocoboRaceSkillNameDefaultColor  <const> = "#9A6B2DFF"
local LocalStrID <const> = require("Game/Skill/SkillSystem/SkillSystemConfig").LocalStrID
local SkillTipsType <const> = SkillCommonDefine.SkillTipsType
local SkillTipsContentType <const> = SkillCommonDefine.SkillTipsContentType
local PROF_TYPE_FISHER <const> = ProtoCommon.prof_type.PROF_TYPE_FISHER
local FLOG_ERROR <const> = FLOG_ERROR
local LSTR <const> = LSTR
local TextNotAchieved

local TagParams = {
    ProfFlags = {
        bMakeProf = false,
        bProductionProf = false,
        bFisherProf = false,
    },
    CurrentLabel = nil,
    bPassiveSkill = false,
    bLimitSkill = false,
    Class = nil,
    Tag = nil,
    ActionType = nil,
}

local DividerLine <const> = {
    Type = SkillTipsContentType.DividerLine,
}

local SkillDesc <const> = {
    Type = SkillTipsContentType.TextBlock,
    Text = "",
}



---@class CommSkillTipsVM : UIViewModel
local CommSkillTipsVM = LuaClass(UIViewModel)


function CommSkillTipsVM:Ctor()
    self.SkillName = ""
    self.SkillNameColor = ""
    self.ContentList = UIBindableList.New(CommSkillTipsItemVM)
    self.SkillTagList = nil
    self.bUpdateFinished = true
    if not TextNotAchieved then
        -- 未达成
        TextNotAchieved = string.format("<span color=\"#C05153FF\">%s</>", LSTR(170063))
    end
end

function CommSkillTipsVM:OnInit()
end

function CommSkillTipsVM:UpdateSkillName(Cfg)
    self.SkillName = Cfg.SkillName
    self.SkillNameColor = SkillNameDefaultColor
end

function CommSkillTipsVM:UpdateTags(Cfg, Params)
    local ProfID = Params.ProfID
    local ProfFlags = TagParams.ProfFlags
    ProfFlags.bProductionProf = ProfUtil.IsGpProf(ProfID)
    ProfFlags.bMakeProf = ProfUtil.IsCrafterProf(ProfID)
    ProfFlags.bFisherProf = ProfID == PROF_TYPE_FISHER
    TagParams.Class = Cfg.Class
    TagParams.Tag = Cfg.Tag
    TagParams.ActionType = Cfg.ActionType
    TagParams.bPassiveSkill = Params.bIsPassiveSkill
    TagParams.bLimitSkill = Params.bIsLimitSkill
    TagParams.CurrentLabel =
        Params.bIsLimitSkill and LocalStrID.LimitSkill or
        (Params.bIsPassiveSkill and LocalStrID.Passive or LocalStrID.Active)

    self.SkillTagList = SkillTipsUtil.GetSkillTagList(TagParams)
end

local function GetAttrText(AttrInfo)
    return string.format("%s: %s", AttrInfo.Title, AttrInfo.Text)
end

function CommSkillTipsVM:UpdateAttrList(Cfg, Type, ContentList)
    local AttrList = SkillTipsUtil.GetSkillAttrList(Cfg, Type)
    if not AttrList then
        return
    end

    local CurrentAttrItem
    for i = 1, #AttrList do
        local AttrText = GetAttrText(AttrList[i])
        if i % 2 == 1 then
            CurrentAttrItem = {
                Type = SkillTipsContentType.AttrItem,
                TextLeft = AttrText,
                TextRight = "",
            }
            table.insert(ContentList, CurrentAttrItem)
        else
            CurrentAttrItem.TextRight = AttrText
        end
    end
end

function CommSkillTipsVM:UpdateSkillLearnInfo(Params, ContentList)
    if Params.bIsPvpSkill then
        return
    end
    table.insert(ContentList, DividerLine)
    local ProfID = Params.ProfID
    local _, LearnLevel, bAdvancedProfUse = SkillUtil.GetSkillLearnValid(
        Params.SkillID, Params.ProfID, Params.Level)

    local LearnLevelText = LSTR(170054) .. " " .. string.format(LSTR(170061), LearnLevel)  -- 学习等级: %d级
    if LearnLevel > Params.Level then
        LearnLevelText = LearnLevelText .. TextNotAchieved
    end
    table.insert(ContentList, {
        Type = SkillTipsContentType.TextBlock,
        Text = LearnLevelText,
    })

    local AdvancedProfID = ProfUtil.GetAdvancedProf(ProfID)
    if bAdvancedProfUse and not Params.bIsPvpSkill then
        -- 学习条件: 转职为xxx
        local AdvancedProfText = string.format(
            LSTR(170055),
            ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, AdvancedProfID) or ""
        )
        -- 现在这里只考虑没转职, 不考虑职业没解锁的情况
        if AdvancedProfID ~= ProfID then
            AdvancedProfText = AdvancedProfText .. TextNotAchieved
        end
        table.insert(ContentList, {
            Type = SkillTipsContentType.TextBlock,
            Text = AdvancedProfText,
        })
    end
end

function CommSkillTipsVM:UpdateContent(Cfg, Params)
    local ContentList = {}

    self:UpdateAttrList(Cfg, Params.Type, ContentList)
    table.insert(ContentList, DividerLine)
    local DescText = Cfg.Desc
    if DescText and DescText ~= "" then
        SkillDesc.Text = DescText
        table.insert(ContentList, SkillDesc)
    end
    self:UpdateSkillLearnInfo(Params, ContentList)

    self.ContentList:UpdateByValues(ContentList)
end

function CommSkillTipsVM:UpdateVM_Mount(MountParams)
    if not MountParams then
        return
    end
    self.SkillName = MountParams.SkillName
    self.SkillNameColor = MountParams.NameColor or MountSkillNameDefaultColor

    local SkillTagList = {}
    for _, v in pairs(MountParams.SkillTag or SkillTagList) do
        table.insert(SkillTagList, {Tag = v, bIsMountActionItem = true})
    end
    self.SkillTagList = SkillTagList

    local ContentList = {}
    for _, v in pairs(MountParams.SkillInfoList or ContentList) do
        table.insert(ContentList, {
            Type = SkillTipsContentType.TextBlock,
            Text = v,
        })
    end
    self.ContentList:UpdateByValues(ContentList)
end

function CommSkillTipsVM:UpdateVM_ChocoboRace(ChocoboRaceParams)
    if not ChocoboRaceParams then
        return
    end
    self.SkillName = ChocoboRaceParams.SkillName
    self.SkillNameColor = ChocoboRaceSkillNameDefaultColor
    self.SkillTagList = ChocoboRaceParams.SkillTagList or {}

    local ContentList = {}
    for _, v in pairs(ChocoboRaceParams.SkillInfoList or ContentList) do
        table.insert(ContentList, {
            Type = SkillTipsContentType.TextBlock,
            Text = v,
        })
    end
    self.ContentList:UpdateByValues(ContentList)
end

local function ConditionalYield(bSync)
    if not bSync then
        return coroutine.yield()
    end
end

function CommSkillTipsVM:UpdateVM(Params, bSync)
    self.bUpdateFinished = false
    if Params.Type == SkillTipsType.Mount then
        self:UpdateVM_Mount(Params.MountParams)
    elseif Params.Type == SkillTipsType.ChocoboRace then
        self:UpdateVM_ChocoboRace(Params.ChocoboRaceParams)
    else
        local SkillID = Params.SkillID
        local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
        if not Cfg then
            FLOG_ERROR("[CommSkillTipsVM] Cannot find main cfg of skill %d", SkillID)
        else
            self:UpdateSkillName(Cfg)
            self:UpdateTags(Cfg, Params)
            ConditionalYield(bSync)
            self:UpdateContent(Cfg, Params)
            ConditionalYield(bSync)
        end
    end
    self.bUpdateFinished = true
end

return CommSkillTipsVM
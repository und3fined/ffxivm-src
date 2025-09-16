--- Author: v_vvxinchen
--- DateTime: 2023-12-08 17:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local SkillUtil = require("Utils/SkillUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MajorUtil = require("Utils/MajorUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AttrDefCfg = require("TableCfg/AttrDefCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local attr_type = require("Protocol/ProtoCommon").attr_type
local LSTR = _G.LSTR


---@class GatheringJobSkillTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img02 UFImage
---@field ImgLine01 UFImage
---@field PanelContent01 UFCanvasPanel
---@field PanelContent02 UFCanvasPanel
---@field PanelContent03 UFCanvasPanel
---@field PanelJobSkillTips UFCanvasPanel
---@field RichTextDiscribe URichTextBox
---@field TableViewLabel UTableView
---@field TextDeplete01 UFTextBlock
---@field TextDeplete02 URichTextBox
---@field TextLevel01 UFTextBlock
---@field TextLevel02 URichTextBox
---@field TextNotAchieved UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringJobSkillTipsView = LuaClass(UIView, true)

function GatheringJobSkillTipsView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Img02 = nil
	--self.ImgLine01 = nil
	--self.PanelContent01 = nil
	--self.PanelContent02 = nil
	--self.PanelContent03 = nil
	--self.PanelJobSkillTips = nil
	--self.RichTextDiscribe = nil
	--self.TableViewLabel = nil
	--self.TextDeplete01 = nil
	--self.TextDeplete02 = nil
	--self.TextLevel01 = nil
	--self.TextLevel02 = nil
	--self.TextNotAchieved = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringJobSkillTipsView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringJobSkillTipsView:OnInit()
    self.TableViewAdapterTag = UIAdapterTableView.CreateAdapter(self, self.TableViewLabel)
end

function GatheringJobSkillTipsView:OnDestroy()
end

function GatheringJobSkillTipsView:OnShow()
    self.TextDeplete01:SetText(LSTR(160023)) --"消耗"
	self.TextDeplete02:SetText(LSTR(160024)) --"--采集力"
	self.TextLevel01:SetText(LSTR(160025)) --"学习等级"
    self.TextNotAchieved:SetText(LSTR(170063))  -- 未达成
end

function GatheringJobSkillTipsView:OnHide()
end

function GatheringJobSkillTipsView:OnRegisterUIEvent()
end

function GatheringJobSkillTipsView:OnRegisterGameEvent()
end

function GatheringJobSkillTipsView:OnRegisterBinder()
end

function GatheringJobSkillTipsView:UPdateSkillInfo(SkillID, ProfID)
    if ProfID == nil then
        ProfID = MajorUtil.GetMajorProfID()
    end
    UIUtil.SetIsVisible(self.TableViewLabel, true)
    local LearnedLevel = SkillUtil.GetSkillLearnLevel(SkillID, ProfID)
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if Cfg then
        self.TextTitle:SetText(Cfg.SkillName)

        --标签
        local Tags = {}
        if SkillID == 30110 then
            table.insert(Tags, {TagType = 2, TagName = LSTR(170002)}) --"被动"
        else
            table.insert(Tags, {TagType = 1, TagName = LSTR(170001)}) --"主动"
        end
        table.insert(Tags, {TagType = 3, TagName = LSTR(160048)}) --"采集"
        self.TableViewAdapterTag:UpdateAll(Tags)

        --消耗
        local CostUnit = nil
        local AttrName = ""
        local Cost = 0
        local len = #Cfg.CostList
        if len == 0 then
            self.TextDeplete02:SetText("— —")
        else
            for index = 1, len do
                CostUnit = Cfg.CostList[index]
                Cost = CostUnit.AssetCost
                if not Cost or Cost == 0 then
                    self.TextDeplete02:SetText("— —")
                else
                    if CostUnit.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_ATTR then --属性
                        if CostUnit.AssetId == attr_type.attr_gp then                            
                             AttrName = ProtoEnumAlias.GetAlias(ProtoRes.CONDITION_TYPE, ProtoRes.CONDITION_TYPE.CONDITION_TYPE_GATHER_POWER)
                        else
                            AttrName = AttrDefCfg:GetAttrNameByID(CostUnit.AssetId)
                        end
                        self.TextDeplete02:SetText(string.format("%d%s", Cost, AttrName))
                    elseif CostUnit.AssetType == ProtoRes.skill_cost_type.SKILL_COST_TYPE_DURABILITY then --耐久
                        self.TextDeplete02:SetText(string.format(LSTR(150073), Cost)) --"%d耐久"
                    end
                end
            end
        end
        

        -- 描述
        self.RichTextDiscribe:SetText(Cfg.Desc)

        --学习等级
        local ProfID = MajorUtil.GetMajorProfID()
        local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID)
        self.TextLevel02:SetText(string.format(LSTR(180034), LearnedLevel)) --"%d级"
        if LearnedLevel <= MajorLevel then
            UIUtil.SetIsVisible(self.TextNotAchieved, false)
        else
            UIUtil.SetIsVisible(self.TextNotAchieved, true)
        end
    end
end



return GatheringJobSkillTipsView

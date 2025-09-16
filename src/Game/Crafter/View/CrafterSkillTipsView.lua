---
--- Author: chriswang
--- DateTime: 2023-09-06 16:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local SkillTipsUtil = require("Utils/SkillTipsUtil")
local EventID = require("Define/EventID")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
-- local PassiveskillCfg = require("TableCfg/PassiveskillCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ProtoRes = require("Protocol/ProtoRes")

local LocalStrID = require("Game/Skill/SkillSystem/SkillSystemConfig").LocalStrID
local LSTR = _G.LSTR
local SkillTipsType_Crafter <const> = require("Game/Skill/SkillCommonDefine").SkillTipsType.Crafter

---@class CrafterSkillTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EfficiencyPanel UFCanvasPanel
---@field ImgLine1 UFImage
---@field ImgLine2 UFImage
---@field RichText_Line01 URichTextBox
---@field SkillTipsPanel UFCanvasPanel
---@field TableViewCDCost UTableView
---@field TableViewTag UTableView
---@field TableViewText2 UTableView
---@field TextEfficiency UFTextBlock
---@field TextEfficiencyTag UFTextBlock
---@field TextLevel UFTextBlock
---@field TextNotAchieved UFTextBlock
---@field TextStudy UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSkillTipsView = LuaClass(UIView, true)

function CrafterSkillTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EfficiencyPanel = nil
	--self.ImgLine1 = nil
	--self.ImgLine2 = nil
	--self.RichText_Line01 = nil
	--self.SkillTipsPanel = nil
	--self.TableViewCDCost = nil
	--self.TableViewTag = nil
	--self.TableViewText2 = nil
	--self.TextEfficiency = nil
	--self.TextEfficiencyTag = nil
	--self.TextLevel = nil
	--self.TextNotAchieved = nil
	--self.TextStudy = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSkillTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSkillTipsView:OnInit()
	self.TableViewAdapterTag = UIAdapterTableView.CreateAdapter(self, self.TableViewTag)
	self.TableViewAdapterCDCost = UIAdapterTableView.CreateAdapter(self, self.TableViewCDCost)
	self.TextEfficiencyTag:SetText(LSTR(150008))  -- 制作效率
	self.TextStudy:SetText(LSTR(170064))  -- 学习等级
	self.TextNotAchieved:SetText(LSTR(170063))  -- 未达成
end

function CrafterSkillTipsView:OnDestroy()

end

function CrafterSkillTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local SkillID = Params.SkillID
	local LearnedLevel = Params.LearnedLevel or 0
	local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
	if Cfg then
		self.TextTitle:SetText(Cfg.SkillName)

		local ActionType = Cfg.ActionType
		local Tags = SkillTipsUtil.GetSkillTagList({
			ProfFlags = {
				bMakeProf = MajorUtil.IsCrafterProf(),
				bProductionProf = MajorUtil.IsGatherProf(),
				bFisherProf = MajorUtil.IsFishingProf(),
			},
			CurrentLabel = LocalStrID.Active,
			ActionType = ActionType,
			bPassiveSkill = false,
			bLimitSkill = true,
			Class = Cfg.Class,
			Tag = Cfg.Tag,
		})

		self.TableViewAdapterTag:UpdateAll(Tags)

		local CDCost = SkillTipsUtil.GetSkillAttrList(Cfg, SkillTipsType_Crafter)
		self.TableViewAdapterCDCost:UpdateAll(CDCost)

		-- 加工/制作效率和描述
		local EActionType = ProtoRes.LIFESKILL_ACTION_TYPE
		local EfficiencyName
		
		if ActionType == EActionType.LIFESKILL_ACTION_TYPE_CRAFT then
			EfficiencyName = LSTR(150074)  -- 制作效率
		elseif ActionType == EActionType.LIFESKILL_ACTION_TYPE_CONTROL then
			EfficiencyName = LSTR(150075)  -- 加工效率
		end

		local Efficiency = Cfg.Efficiency
		if EfficiencyName and Efficiency > 0 then
			UIUtil.SetIsVisible(self.EfficiencyPanel, true)
			self.TextEfficiencyTag:SetText(EfficiencyName)
			self.TextEfficiency:SetText(tostring(Efficiency))
		else
			UIUtil.SetIsVisible(self.EfficiencyPanel, false)
		end

		local Desc = Cfg.Desc
		if Desc and Desc ~= "" then
			UIUtil.SetIsVisible(self.RichText_Line01, true)
			self.RichText_Line01:SetText(Desc)
		else
			UIUtil.SetIsVisible(self.RichText_Line01, false)
		end

		if UIUtil.IsVisible(self.EfficiencyPanel) or UIUtil.IsVisible(self.RichText_Line01) then
			UIUtil.SetIsVisible(self.ImgLine1, true)
		else
			UIUtil.SetIsVisible(self.ImgLine1, false)
		end

		local ProfID = MajorUtil.GetMajorProfID()
		local MajorLevel = MajorUtil.GetMajorLevelByProf(ProfID)
		self.TextLevel:SetText(string.format(LSTR("%d级"), LearnedLevel))
		if LearnedLevel <= MajorLevel then
			UIUtil.SetIsVisible(self.TextNotAchieved, false)
		else
			UIUtil.SetIsVisible(self.TextNotAchieved, true)
		end
	end

end

function CrafterSkillTipsView:OnHide()

end

function CrafterSkillTipsView:OnRegisterUIEvent()

end

function CrafterSkillTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.HideUI, self.OnHideViewEvent)
end

function CrafterSkillTipsView:OnRegisterBinder()

end

function CrafterSkillTipsView:OnHideViewEvent(Params)
    local ViewID = Params
    if ViewID == UIViewID.CrafterMainPanel then
		self:Hide()
    end
end

return CrafterSkillTipsView
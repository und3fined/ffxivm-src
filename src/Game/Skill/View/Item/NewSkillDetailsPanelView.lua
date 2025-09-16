---
--- Author: henghaoli
--- DateTime: 2024-06-21 16:18
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetViewParams = require("Binder/UIBinderSetViewParams")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local SkillDetailsVM = require("Game/Skill/View/SkillDetailsVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SkillTipsUtil = require("Utils/SkillTipsUtil")

---@class NewSkillDetailsPanelView : SkillDetailsPanelView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AppendImage UFImage
---@field BtnMore UFButton
---@field CommonRedDot CommonRedDotView
---@field CommonRedDot01 CommonRedDotView
---@field FHorizontalAdvanced UFHorizontalBox
---@field FHorizontalSkill UFHorizontalBox
---@field FHorizontalStudy UFHorizontalBox
---@field IconCollapse UFImage
---@field IconExpand UFImage
---@field IconSkill UFImage
---@field ImgArrow1 UFImage
---@field ImgArrow2 UFImage
---@field ImgArrow3 UFImage
---@field ImgArrow4 UFImage
---@field ImgArrow5 UFImage
---@field ImgLine2 UFImage
---@field Img_Add UFImage
---@field PanelMore UFCanvasPanel
---@field RichTextDetail URichTextBox
---@field Skill1 SkillDetailsSelectItemView
---@field Skill2 SkillDetailsSelectItemView
---@field Skill3 SkillDetailsSelectItemView
---@field Skill4 SkillDetailsSelectItemView
---@field Skill5 SkillDetailsSelectItemView
---@field Skill6 SkillDetailsSelectItemView
---@field TableViewCrafter UTableView
---@field TableViewTag UTableView
---@field TextAdvancedProfNotAchieved UFTextBlock
---@field TextLevel UFTextBlock
---@field TextLowLevelSkill UFTextBlock
---@field TextName UFTextBlock
---@field TextNotAchieved UFTextBlock
---@field TextStudy UFTextBlock
---@field TextStudy_1 UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewSkillDetailsPanelView = LuaClass(UIView, true)

function NewSkillDetailsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AppendImage = nil
	--self.BtnMore = nil
	--self.CommonRedDot = nil
	--self.CommonRedDot01 = nil
	--self.FHorizontalAdvanced = nil
	--self.FHorizontalSkill = nil
	--self.FHorizontalStudy = nil
	--self.IconCollapse = nil
	--self.IconExpand = nil
	--self.IconSkill = nil
	--self.ImgArrow1 = nil
	--self.ImgArrow2 = nil
	--self.ImgArrow3 = nil
	--self.ImgArrow4 = nil
	--self.ImgArrow5 = nil
	--self.ImgLine2 = nil
	--self.Img_Add = nil
	--self.PanelMore = nil
	--self.RichTextDetail = nil
	--self.Skill1 = nil
	--self.Skill2 = nil
	--self.Skill3 = nil
	--self.Skill4 = nil
	--self.Skill5 = nil
	--self.Skill6 = nil
	--self.TableViewCrafter = nil
	--self.TableViewTag = nil
	--self.TextAdvancedProfNotAchieved = nil
	--self.TextLevel = nil
	--self.TextLowLevelSkill = nil
	--self.TextName = nil
	--self.TextNotAchieved = nil
	--self.TextStudy = nil
	--self.TextStudy_1 = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewSkillDetailsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonRedDot01)
	self:AddSubView(self.Skill1)
	self:AddSubView(self.Skill2)
	self:AddSubView(self.Skill3)
	self:AddSubView(self.Skill4)
	self:AddSubView(self.Skill5)
	self:AddSubView(self.Skill6)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewSkillDetailsPanelView:OnInit()
	self.TableViewAdapterTag = UIAdapterTableView.CreateAdapter(self, self.TableViewTag)
	self.TableViewAdapterCostList = UIAdapterTableView.CreateAdapter(self, self.TableViewCrafter)
	self.SkillDetailsVM = SkillDetailsVM.New()

	local LSTR = _G.LSTR
	local Binders = {
		{ "SkillName", UIBinderSetText.New(self, self.TextName) },
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.IconSkill) },
		{ "LearnLevel", UIBinderSetTextFormat.New(self, self.TextLevel, LSTR(170061)) },  -- %d级
		{ "bShowLearnLevel", UIBinderSetIsVisible.New(self, self.FHorizontalStudy) },
		{ "bShowAdvancedProfPanel", UIBinderSetIsVisible.New(self, self.FHorizontalAdvanced) },
		{ "bIsAdvancedProf", UIBinderSetIsVisible.New(self, self.TextAdvancedProfNotAchieved, true) },
		{ "AdvancedProfText", UIBinderSetTextFormat.New(self, self.TextStudy_1, LSTR(170055)) },  -- "学习条件: 转职为"
		{ "Desc", UIBinderSetText.New(self, self.RichTextDetail) },
		--{ "SkillType", UIBinderSetText.New(self, self.Text_SkillType) },
		{ "bLearned", UIBinderSetIsVisible.New(self, self.TextNotAchieved, true) },
		{ "AppendImage", UIBinderSetBrushFromAssetPath.New(self, self.AppendImage, true) },
		{ "bAppendImageVisible", UIBinderSetIsVisible.New(self, self.AppendImage) },
		{ "bPanelMoreVisible", UIBinderSetIsVisible.New(self, self.PanelMore) },
		{ "bPanelMoreVisible", UIBinderSetIsVisible.New(self, self.ImgLine2 ) },
		{ "bPanelMoreExpanded", UIBinderSetIsVisible.New(self, self.IconCollapse, false) },
		{ "bPanelMoreExpanded", UIBinderSetIsVisible.New(self, self.IconExpand, true) },
		{ "ExpandText", UIBinderSetText.New(self, self.TextLowLevelSkill) },
		{ "bShowSeriesPanel", UIBinderSetIsVisible.New(self, self.FHorizontalSkill) },
		{ "RedDotNum", UIBinderValueChangedCallback.New(self, nil, self.OnRedDotNumChanged) },
		{ "AttrList", UIBinderUpdateBindableList.New(self, self.TableViewAdapterCostList) },
		{ "bShowAttrList", UIBinderSetIsVisible.New(self, self.TableViewCrafter) },
	}

	for i = 1, SkillDetailsVM.SeriesDetailNum do
		table.insert(Binders, { string.format("SeriesDetailVM%d", i), UIBinderSetViewParams.New(self, self[string.format("Skill%d", i)]) })
		table.insert(Binders, { string.format("SeriesDetailShow%d", i), UIBinderSetIsVisible.New(self, self[string.format("Skill%d", i)]) })
		if i > 1 then
			table.insert(Binders, { string.format("SeriesDetailShow%d", i), UIBinderSetIsVisible.New(self, self[string.format("ImgArrow%d", i - 1)]) })
		end
	end
	self.Binders = Binders

	self.TextStudy:SetText(LSTR(170054))  -- 学习等级
	-- self.TextStudy_1:SetText(LSTR(170055))  -- 学习条件: 转职为

	local LocalStrID_Unachieved <const> = 170063
	self.TextNotAchieved:SetText(LSTR(LocalStrID_Unachieved))
	self.TextAdvancedProfNotAchieved:SetText(LSTR(LocalStrID_Unachieved))
end

function NewSkillDetailsPanelView:OnDestroy()

end

function NewSkillDetailsPanelView:OnShow()
	self.SkillDetailsVM:OnBegin()
	local Data = self.Params.Data
	if Data then
		self:UpdateSkill(Data)
	end
end

function NewSkillDetailsPanelView:OnHide()
	self.SkillDetailsVM:OnEnd()
end

function NewSkillDetailsPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnBtnMoreClicked)
end

function NewSkillDetailsPanelView:OnRegisterGameEvent()

end

function NewSkillDetailsPanelView:OnRegisterBinder()
	self:RegisterBinders(self.SkillDetailsVM, self.Binders)
end

function NewSkillDetailsPanelView:UpdateSkill(Params)
	local VM = self.SkillDetailsVM
	if VM then
		VM:UpdateVM(Params)
		local SkillMainPanelView = self.ParentView.ParentView
		if Params and Params.bPanelMoreVisible and SkillMainPanelView then
			local bExpanded = rawget(SkillMainPanelView.SkillSystemVM, "bPanelMoreExpanded")
			VM.bPanelMoreExpanded = bExpanded
			_G.SkillSystemMgr:RegisterAdvancedPanelRedDotWidget(Params.Index, self.CommonRedDot)
		end
	end
	if not Params or not next(Params) then
		return
	end
	if Params.SkillID and not self:IsAnimationPlaying(self.AnimIn) then
		self:PlayAnimIn()
	end

	local Tags = SkillTipsUtil.GetSkillTagList(Params)
	self.TableViewAdapterTag:UpdateAll(Tags)
end

function NewSkillDetailsPanelView:OnBtnMoreClicked()
	local VM = self.SkillDetailsVM
	if VM then
		local bExpanded = not VM.bPanelMoreExpanded
		VM.bPanelMoreExpanded = bExpanded
		local SkillMainPanelView = self.ParentView.ParentView
		if SkillMainPanelView then
			rawset(SkillMainPanelView.SkillSystemVM, "bPanelMoreExpanded", bExpanded)
			SkillMainPanelView.AdapterSkillDetailsTableView:ClearChildren()
			SkillMainPanelView.AdapterSkillDetailsTableView:UpdateChildren()
		end
		_G.SkillSystemMgr:UpdateAdvancedPanelCheckState(VM.Index)
	end
end

function NewSkillDetailsPanelView:OnRedDotNumChanged(NewValue)
	if NewValue ~= nil then
		UIUtil.SetIsVisible(self.CommonRedDot01, NewValue > 0)
		self.CommonRedDot01:SetRedDotNumByNumber(NewValue)
	end
end

return NewSkillDetailsPanelView
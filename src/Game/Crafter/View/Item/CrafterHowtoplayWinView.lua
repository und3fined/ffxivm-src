---
--- Author: henghaoli
--- DateTime: 2024-03-14 10:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local SkillSystemConfig = require("Game/Skill/SkillSystem/SkillSystemConfig")

local SkillSystemConfigPath = SkillSystemConfig.SkillSystemConfigPath

---@class CrafterHowtoplayWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Alchemist USizeBox
---@field AlchemistItem SkillAlchemistItemView
---@field ArmorerDetails USizeBox
---@field ArmorerDetailsItem SkillArmorerDetailsItemView
---@field BlacksmithDetails USizeBox
---@field BlacksmithDetailsItem SkillBlacksmithDetailsItemView
---@field CarpenterDetails USizeBox
---@field CarpenterDetailsItem SkillCarpenterDetailsItemView
---@field CobblerDetails USizeBox
---@field CobblerDetailsItem SkillCobblerDetailsItemView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field Cook USizeBox
---@field CookItem SkillCookItemView
---@field GoldEngravingDetails USizeBox
---@field GoldEngravingDetailsItem SkilGoldEngravingDetailsItemView
---@field MinerDetails USizeBox
---@field MinerDetailsItem SkillMinerDetailsItemView
---@field TextTitle UFTextBlock
---@field WeaverDetails USizeBox
---@field WeaverDetailsItem SkillWeaverDetailsItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterHowtoplayWinView = LuaClass(UIView, true)

function CrafterHowtoplayWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Alchemist = nil
	--self.AlchemistItem = nil
	--self.ArmorerDetails = nil
	--self.ArmorerDetailsItem = nil
	--self.BlacksmithDetails = nil
	--self.BlacksmithDetailsItem = nil
	--self.CarpenterDetails = nil
	--self.CarpenterDetailsItem = nil
	--self.CobblerDetails = nil
	--self.CobblerDetailsItem = nil
	--self.Comm2FrameM_UIBP = nil
	--self.Cook = nil
	--self.CookItem = nil
	--self.GoldEngravingDetails = nil
	--self.GoldEngravingDetailsItem = nil
	--self.MinerDetails = nil
	--self.MinerDetailsItem = nil
	--self.TextTitle = nil
	--self.WeaverDetails = nil
	--self.WeaverDetailsItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterHowtoplayWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AlchemistItem)
	self:AddSubView(self.ArmorerDetailsItem)
	self:AddSubView(self.BlacksmithDetailsItem)
	self:AddSubView(self.CarpenterDetailsItem)
	self:AddSubView(self.CobblerDetailsItem)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CookItem)
	self:AddSubView(self.GoldEngravingDetailsItem)
	self:AddSubView(self.MinerDetailsItem)
	self:AddSubView(self.WeaverDetailsItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterHowtoplayWinView:OnInit()
	self.Comm2FrameM_UIBP.FText_Title:SetText(_G.LSTR(150012))  -- 玩法详情
end

function CrafterHowtoplayWinView:OnDestroy()

end

local GetObjectName = function(ObjectPath)
	local PathSplit = string.split(ObjectPath, "/")
	local LastPart = PathSplit[#PathSplit]
	
	PathSplit = string.split(LastPart, ".")
	return PathSplit[1]
end

function CrafterHowtoplayWinView:OnShow()
	-- 控制不同职业的显隐
	local ProfID = MajorUtil.GetMajorProfID()
	local SkillSystemDA = _G.ObjectMgr:LoadObjectSync(SkillSystemConfigPath)

	if nil == SkillSystemDA then
		return
	end

	local ProfSkillDataAdvance = SkillSystemDA:GetProfSkillData(ProfID, MajorUtil.GetMajorRaceID())
	if nil == ProfSkillDataAdvance then
		return
	end

	local JobSkillDetail = ProfSkillDataAdvance.JobSkillDetail:ToString()
	local DetailName = GetObjectName(JobSkillDetail)
	local Margin = _G.UE.FMargin()
	Margin.Top = -50

	local SubViews = self.SubViews
	for _, SubView in pairs(SubViews) do
		if SubView ~= self.Comm2FrameM_UIBP then
			local ParentWidget = SubView:GetParent()
			if GetObjectName(SubView:GetClass():GetOuter():GetName()) == DetailName then
				-- 标题适配
				local TextTitle = SubView.TextTitle
				local Text = TextTitle:GetText()
				self.TextTitle:SetText(Text)
				UIUtil.SetIsVisible(TextTitle, false)

				-- 滚动框适配
				local Scroll = SubView.Scroll
				UIUtil.CanvasSlotSetOffsets(Scroll:GetParent(), Margin)
				UIUtil.SetIsVisible(Scroll, true, false)

				-- 可视性适配
				UIUtil.SetIsVisible(SubView, true, true)
				UIUtil.SetIsVisible(ParentWidget, true, true)
			else
				UIUtil.SetIsVisible(SubView, false)
				UIUtil.SetIsVisible(ParentWidget, false)
			end
		end
	end


	UIUtil.SetInputMode_UIOnly()
end

function CrafterHowtoplayWinView:OnHide()
	UIUtil.SetInputMode_GameAndUI()
end

function CrafterHowtoplayWinView:OnRegisterUIEvent()

end

function CrafterHowtoplayWinView:OnRegisterGameEvent()

end

function CrafterHowtoplayWinView:OnRegisterBinder()

end

local Handled = _G.UE.UWidgetBlueprintLibrary.Handled()

function CrafterHowtoplayWinView:OnMouseButtonDown(_, _)
	return Handled
end

return CrafterHowtoplayWinView
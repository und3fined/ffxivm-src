---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:阶段提示UI
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")

---@class CardsTourneyTipsNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FButton_0 UFButton
---@field ImgTrophy UFImage
---@field PanelCard01 UFCanvasPanel
---@field PanelCard02 UFCanvasPanel
---@field TextDiscribe UFTextBlock
---@field TextNode UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsTourneyTipsNewView = LuaClass(UIView, true)

function CardsTourneyTipsNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FButton_0 = nil
	--self.ImgTrophy = nil
	--self.PanelCard01 = nil
	--self.PanelCard02 = nil
	--self.TextDiscribe = nil
	--self.TextNode = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsTourneyTipsNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsTourneyTipsNewView:OnInit()
	self.HideDelay = 3
	-- self.Binders = {
	-- 	{"CurStageName", UIBinderSetText.New(self, self.TextNode)},
	-- }
end

function CardsTourneyTipsNewView:OnDestroy()

end

function CardsTourneyTipsNewView:OnShow()
	if self.Params then
		local IsAutoHide = self.Params.IsAutoHide
		if IsAutoHide then
			self:RegisterTimer(self.Hide, self.HideDelay)
		end
	end
	self:UpdateStageDesc()
end

function CardsTourneyTipsNewView:OnHide()
	_G.MagicCardTourneyMgr:OnReadyTourney()
end

function CardsTourneyTipsNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton_0, self.OnDetailBtnClicked)
end

function CardsTourneyTipsNewView:OnRegisterGameEvent()

end

function CardsTourneyTipsNewView:OnRegisterBinder()
	-- if TourneyVM then
	-- 	self:RegisterBinders(TourneyVM, self.Binders)
	-- end
end

function CardsTourneyTipsNewView:UpdateStageDesc()
	if TourneyVM == nil then
		return
	end

	if TourneyVM.TourneyInfo == nil then
		return
	end

	local CurStageIndex = TourneyVM.CurStageIndex
	local NewStageIndex = CurStageIndex
	local ChoiceList = TourneyVM.TourneyInfo.EffectChoiceList
	local SelectedEffectList = TourneyVM.TourneyInfo.SelectedEffectList
	
	if ChoiceList and #ChoiceList > 0 and #SelectedEffectList > 0 then
		NewStageIndex =  CurStageIndex + 1 -- 选择阶段效果时进入新阶段
	end
	
    local NewStageName = TourneyVMUtils.GetStageNameByIndex(NewStageIndex)
	self.TextNode:SetText(NewStageName)

	local AwardInfo = TourneyVMUtils.GetMagicCardTourneyScoreAward(NewStageIndex)
	if AwardInfo == nil then
		return
	end
	local DescText = string.format(TourneyDefine.StageDescText,AwardInfo.Win, AwardInfo.Lose)
	self.TextDiscribe:SetText(DescText)
end

function CardsTourneyTipsNewView:OnDetailBtnClicked()
	MagicCardTourneyMgr:ShowTourneyDetailView()
end

return CardsTourneyTipsNewView
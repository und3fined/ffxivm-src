---
--- Author: Administrator
--- DateTime: 2024-04-18 19:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local NpcDialogHistoryVM = require("Game/Interactive/View/New/NpcDialogueHistoryVM")
local StoryDefine = require("Game/Story/StoryDefine")
local CommonUtil = require("Utils/CommonUtil")

---@class NPCPlotReviewDialogueItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconContinue UFImage
---@field PanelIconSound UFCanvasPanel
---@field PanelName UFHorizontalBox
---@field PanelTag UFCanvasPanel
---@field PlayAudio UFButton
---@field TextMain UFTextBlock
---@field TextName UFTextBlock
---@field TextTag UFTextBlock
---@field TextTips UFTextBlock
---@field AnimSoundPlayingLoop UWidgetAnimation
---@field AnimSoundPlayingLoopStop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCPlotReviewDialogueItemView = LuaClass(UIView, true)

function NPCPlotReviewDialogueItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconContinue = nil
	--self.PanelIconSound = nil
	--self.PanelName = nil
	--self.PanelTag = nil
	--self.PlayAudio = nil
	--self.TextMain = nil
	--self.TextName = nil
	--self.TextTag = nil
	--self.TextTips = nil
	--self.AnimSoundPlayingLoop = nil
	--self.AnimSoundPlayingLoopStop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCPlotReviewDialogueItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCPlotReviewDialogueItemView:OnShow()
	local Stab = self.Params
	if self.Params.Data and next(self.Params.Data) then
		self:SetTitileAndContent() 
	end
	self.TextTag:SetText(LSTR(1280009))
end

function NPCPlotReviewDialogueItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.PlayAudio, self.OnClickButtonPlayAudio)
end

function NPCPlotReviewDialogueItemView:OnClickButtonPlayAudio()
	if (self.ParentView == nil) or (self.ParentView.ParentView == nil) then return end
	local PanelView = self.ParentView.ParentView

	local StoppedItemIndex = PanelView:StopPrevAudio()
	local ItemData = self.Params.Data

	if ItemData and (StoppedItemIndex ~= ItemData.Index) then
		self:PlayAudioAnim()
		PanelView:PlayItemAudio(ItemData)
	end
end

function NPCPlotReviewDialogueItemView:SetTitileAndContent()
	local DialogueUtil = require("Utils/DialogueUtil")
	local ConvertedContent = DialogueUtil.ParseLabel(self.Params.Data.Content)
	ConvertedContent = CommonUtil.GetTextFromStringWithSpecialCharacter(ConvertedContent)
	local RichTextSplitter = _G.UE.FRichTextSplitter.Create(ConvertedContent)
	if self.Params.Data.ContentType == StoryDefine.ContentType.NpcContent then
		UIUtil.SetIsVisible(self.PanelTag, false) 
		UIUtil.SetIsVisible(self.PanelName, true)
		local bNoSound = (self.Params.Data.SoundPath == nil)
		UIUtil.SetIsVisible(self.PanelIconSound, not bNoSound)
		UIUtil.SetIsVisible(self.TextMain, true)
		UIUtil.SetIsVisible(self.TextTips, false)
	elseif self.Params.Data.ContentType == StoryDefine.ContentType.Choice then
		UIUtil.SetIsVisible(self.PanelTag, true) 
		UIUtil.SetIsVisible(self.PanelName, false)
		UIUtil.SetIsVisible(self.TextMain, true)
		UIUtil.SetIsVisible(self.TextTips, false)
	elseif self.Params.Data.ContentType == StoryDefine.ContentType.OnlyContent then
		UIUtil.SetIsVisible(self.PanelTag, false) 
		UIUtil.SetIsVisible(self.PanelName, false)
		UIUtil.SetIsVisible(self.TextTips, true)
		UIUtil.SetIsVisible(self.TextMain, false)
		self.TextTips:SetText(RichTextSplitter:RichTextSub(RichTextSplitter:RichTextLen()))
	end
	self.TextMain:SetText(RichTextSplitter:RichTextSub(RichTextSplitter:RichTextLen()))
	self.TextName:SetText(self.Params.Data.Name)
	UIUtil.SetIsVisible(self.PanelContinue, self.Params.Data.bNew) 
	if self.Params.Data.bNew then
		self:PlayAnimation(self.AnimContinueLoop, 0 , 0)
	end
end

function NPCPlotReviewDialogueItemView:PlayAudioAnim()
	self:StopAnimation(self.AnimSoundPlayingLoopStop)
	self:PlayAnimation(self.AnimSoundPlayingLoop, 0, 0, nil, 1.0, true)
end

function NPCPlotReviewDialogueItemView:PlayAudioAnimStop()
	self:StopAnimation(self.AnimSoundPlayingLoop)
	self:PlayAnimation(self.AnimSoundPlayingLoopStop, 0, 0, nil, 1.0, true)
end

return NPCPlotReviewDialogueItemView
---
--- Author: Administrator
--- DateTime: 2025-03-18 16:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")



---@class MusicAtlasRevertListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field PanelNormal UFCanvasPanel
---@field PanelPlaying UFCanvasPanel
---@field RichTextName URichTextBox
---@field TextNumber UFTextBlock
---@field TextPlayingName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicAtlasRevertListItemView = LuaClass(UIView, true)

function MusicAtlasRevertListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.PanelNormal = nil
	--self.PanelPlaying = nil
	--self.RichTextName = nil
	--self.TextNumber = nil
	--self.TextPlayingName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicAtlasRevertListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicAtlasRevertListItemView:OnInit()
	self.Binders = {	
		{ "Number", UIBinderSetText.New(self, self.TextNumber) },
		{ "NormalName", UIBinderSetText.New(self, self.RichTextName) },
		{ "PlayingName", UIBinderSetText.New(self, self.TextPlayingName) },
		{ "PanelPlayingVisible", UIBinderSetIsVisible.New(self, self.PanelPlaying) },	
		{ "PanelNormalVisible", UIBinderSetIsVisible.New(self, self.PanelNormal) },			
	}
end

function MusicAtlasRevertListItemView:OnDestroy()

end

function MusicAtlasRevertListItemView:OnShow()

end

function MusicAtlasRevertListItemView:OnHide()

end

function MusicAtlasRevertListItemView:OnRegisterUIEvent()

end

function MusicAtlasRevertListItemView:OnRegisterGameEvent()

end

function MusicAtlasRevertListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end


function MusicAtlasRevertListItemView:OnSelectChanged(NewValue)
	self.ViewModel:SetSelectState(NewValue)
end

return MusicAtlasRevertListItemView
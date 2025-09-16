---
--- Author: Administrator
--- DateTime: 2023-12-08 11:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")


---@class MusicPlayerSidebarListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HorizontalContent UFHorizontalBox
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field MI_DX_SequencePause_MusicPlayer_1 UFImage
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicPlayerSidebarListItemView = LuaClass(UIView, true)

function MusicPlayerSidebarListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HorizontalContent = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.MI_DX_SequencePause_MusicPlayer_1 = nil
	--self.TextName = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicPlayerSidebarListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicPlayerSidebarListItemView:OnInit()
	self.Binders = {
		{ "NumText", UIBinderSetText.New(self, self.TextNum) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ImgPlayingVisible", UIBinderSetIsVisible.New(self, self.MI_DX_SequencePause_MusicPlayer_1) },
		{ "TextNumVisible", UIBinderSetIsVisible.New(self, self.TextNum) },
		{ "TextNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
		{ "ImgSelectVisible", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		
	}
end

function MusicPlayerSidebarListItemView:OnDestroy()

end

function MusicPlayerSidebarListItemView:OnShow()

end

function MusicPlayerSidebarListItemView:OnHide()

end

function MusicPlayerSidebarListItemView:OnRegisterUIEvent()

end

function MusicPlayerSidebarListItemView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.RightListChose, self.UpdateItemState)
end

function MusicPlayerSidebarListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function MusicPlayerSidebarListItemView:OnSelectChanged(NewValue)
	self.ViewModel:UpdateItemState(NewValue)
	--UIUtil.SetIsVisible(self.ImgSelect, NewValue)
	-- UIUtil.SetIsVisible(self.TextNum, not NewValue)
	-- UIUtil.SetIsVisible(self.ImgPlaying, NewValue)
	-- local RightChoseID = MusicPlayerMgr.RighListChoseMusicID
	-- local CurID = self.ViewModel.MusicID

	-- if NewValue then
	-- 	UIUtil.TextBlockSetColorAndOpacityHex(self.TextName,TextColor[1])
	-- else
	-- 	UIUtil.TextBlockSetColorAndOpacityHex(self.TextName,TextColor[2])
	-- end

	-- if RightChoseID ~= CurID then
	-- 	UIUtil.SetIsVisible(self.TextNum, true)
	-- 	UIUtil.SetIsVisible(self.ImgPlaying, false)
	-- 	UIUtil.TextBlockSetColorAndOpacityHex(self.TextName,TextColor[2])
	-- end
end

return MusicPlayerSidebarListItemView
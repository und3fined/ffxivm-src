---
--- Author: Administrator
--- DateTime: 2023-12-08 11:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")

---@class MusicPlayerListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnDelete UFButton
---@field BtnSwitch UFButton
---@field ImgSelect UFImage
---@field ImgSelect2 UFImage
---@field ImgSelect_BG UFImage
---@field ImgSelect_Top UFImage
---@field MI_DX_SequencePause_MusicPlayer_1 UFImage
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MusicPlayerListItemView = LuaClass(UIView, true)

function MusicPlayerListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnDelete = nil
	--self.BtnSwitch = nil
	--self.ImgSelect = nil
	--self.ImgSelect2 = nil
	--self.ImgSelect_BG = nil
	--self.ImgSelect_Top = nil
	--self.MI_DX_SequencePause_MusicPlayer_1 = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MusicPlayerListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MusicPlayerListItemView:OnInit()
	self.Binders = {
		{ "NumText", UIBinderSetText.New(self, self.TextNum) },
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "TextNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
		{ "TextNumColor", UIBinderSetColorAndOpacityHex.New(self, self.TextNum) },
		{ "BtnSwitchVisible", UIBinderSetIsVisible.New(self, self.BtnSwitch, false, true) },
		{ "BtnDeleteVisible", UIBinderSetIsVisible.New(self, self.BtnDelete, false, true) },
		{ "BtnAddVisible", UIBinderSetIsVisible.New(self, self.BtnAdd, false, true) },
		{ "ImgSelectVisible1", UIBinderSetIsVisible.New(self, self.ImgSelect1) },
		{ "ImgSelectVisible2", UIBinderSetIsVisible.New(self, self.ImgSelect2) },
		{ "ImgPlayingVisible", UIBinderSetIsVisible.New(self, self.MI_DX_SequencePause_MusicPlayer_1) },
		{ "TextNumVisible", UIBinderSetIsVisible.New(self, self.TextNum) },
		
	}
end

function MusicPlayerListItemView:OnDestroy()

end

function MusicPlayerListItemView:OnShow()
	-- UIUtil.SetIsVisible(self.BtnSwitch, false, true)
	-- UIUtil.SetIsVisible(self.BtnDelete, false, true)
	-- UIUtil.SetIsVisible(self.BtnAdd, false, true)
end

function MusicPlayerListItemView:OnHide()

end

function MusicPlayerListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSwitch, self.ClickBtnSwitch)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.ClickBtnDelete)
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.ClickBtnAdd)
end

function MusicPlayerListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MainChosedByRight, self.MainChosedByRightClick)
	self:RegisterGameEvent(EventID.LeftChosed, self.UpdateItemBtnState)
	self:RegisterGameEvent(EventID.UpdateMusicItemState, self.UpdateCurPlayingItem)
end

function MusicPlayerListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end
	local ViewModel = Params.Data
	if nil == ViewModel then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function MusicPlayerListItemView:MainChosedByRightClick(Index, IsAdd)
	if self.ViewModel.CurIndex == Index and IsAdd then
		self.ViewModel:AddMusicForEditMusicInfo()
		EventMgr:SendEvent(EventID.UpdateEditMusicInfo)
	elseif self.ViewModel.CurIndex == Index and not IsAdd and MusicPlayerMgr.IsChoseLeft then
		self.ViewModel:SwithMusicForEditMusicInfo()
		EventMgr:SendEvent(EventID.UpdateEditMusicInfo)
	end
end

function MusicPlayerListItemView:ClickBtnSwitch()
	self.ViewModel:SwithMusicForEditMusicInfo()
	EventMgr:SendEvent(EventID.UpdateEditMusicInfo)
end

function MusicPlayerListItemView:ClickBtnDelete()
	self.ViewModel:DeleteMusicForEditMusicInfo()
	EventMgr:SendEvent(EventID.UpdateEditMusicInfo)
end

function MusicPlayerListItemView:ClickBtnAdd()
	self.ViewModel:AddMusicForEditMusicInfo()
	EventMgr:SendEvent(EventID.UpdateEditMusicInfo)
end

function MusicPlayerListItemView:UpdateItemBtnState()
	self.ViewModel:UpdateItemBtnState()
end

function MusicPlayerListItemView:UpdateCurPlayingItem()
	self.ViewModel:UpdateCurPlayingItem()
end

function MusicPlayerListItemView:OnSelectChanged(NewValue)
	-- if NewValue then
	-- 	if not MusicPlayerMgr.IsChoseLeft then
	-- 		self:PlayAnimation(self.AnimSelect)
	-- 	elseif MusicPlayerMgr.IsChoseLeft and not self.ViewModel.IsNil then
	-- 		self:PlayAnimation(self.AnimSelect)
	-- 	end
	-- end

	self.ViewModel:UpdateItemState(NewValue)
	self.ViewModel:UpdateItemBtnState()
	-- UIUtil.SetIsVisible(self.ImgSelect, NewValue)
	-- if NewValue and not MusicPlayerMgr.EditState then
	-- 	UIUtil.SetIsVisible(self.TextNum, not NewValue)
	-- 	UIUtil.SetIsVisible(self.ImgPlaying, NewValue)
	-- 	UIUtil.TextBlockSetColorAndOpacityHex(self.TextName,TextColor[1])
	-- else
	-- 	UIUtil.TextBlockSetColorAndOpacityHex(self.TextName,TextColor[2])
	-- end
end

return MusicPlayerListItemView
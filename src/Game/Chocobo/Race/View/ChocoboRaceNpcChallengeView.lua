---
--- Author: Administrator
--- DateTime: 2024-11-08 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChocoboRaceNpcChallengeVM = require("Game/Chocobo/Race/VM/ChocoboRaceNpcChallengeVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIViewID = require("Define/UIViewID")
local CommBtnSView = require("Game/Common/Btn/CommBtnSView")

---@class ChocoboRaceNpcChallengeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoLevel01 CommBtnSView
---@field BtnGoLevel02 CommBtnSView
---@field BtnGoLevel03 CommBtnSView
---@field BtnToggle02 UFButton
---@field ChocoboAvatar ChocoboRaceAvatarItemView
---@field CloseBtn CommonCloseBtnView
---@field FButton_0 UFButton
---@field FCanvasCardPanel UFCanvasPanel
---@field ImgTrophy UFImage
---@field PanelQuickChocobo UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextChocoboLevel UFTextBlock
---@field TextChocoboName UFTextBlock
---@field TextContent UFTextBlock
---@field TextContent_1 UFTextBlock
---@field TextContent_2 UFTextBlock
---@field TextDiscribe UFTextBlock
---@field TextNode UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboRaceNpcChallengeView = LuaClass(UIView, true)

function ChocoboRaceNpcChallengeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoLevel01 = nil
	--self.BtnGoLevel02 = nil
	--self.BtnGoLevel03 = nil
	--self.BtnToggle02 = nil
	--self.ChocoboAvatar = nil
	--self.CloseBtn = nil
	--self.FButton_0 = nil
	--self.FCanvasCardPanel = nil
	--self.ImgTrophy = nil
	--self.PanelQuickChocobo = nil
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.TextChocoboLevel = nil
	--self.TextChocoboName = nil
	--self.TextContent = nil
	--self.TextContent_1 = nil
	--self.TextContent_2 = nil
	--self.TextDiscribe = nil
	--self.TextNode = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboRaceNpcChallengeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoLevel01)
	self:AddSubView(self.BtnGoLevel02)
	self:AddSubView(self.BtnGoLevel03)
	self:AddSubView(self.ChocoboAvatar)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboRaceNpcChallengeView:OnInit()
	self.ViewModel = ChocoboRaceNpcChallengeVM.New()
end

function ChocoboRaceNpcChallengeView:OnDestroy()

end

function ChocoboRaceNpcChallengeView:OnShow()
	self.PopUpBG:SetHideOnClick(false)
	local Level = (self.Params or {}).Level or 0
	self.BtnGoLevel01:SetIsEnabled(Level >= 1)
	self.BtnGoLevel02:SetIsEnabled(Level >= 2)
	self.BtnGoLevel03:SetIsEnabled(Level >= 3)
	self:InitConstInfo()
end

function ChocoboRaceNpcChallengeView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	-- LSTR string: 第一关
	self.TextContent:SetText(_G.LSTR(430002))
	-- LSTR string: 第二关
	self.TextContent_1:SetText(_G.LSTR(430003))
	-- LSTR string: 第三关
	self.TextContent_2:SetText(_G.LSTR(430004))
	-- LSTR string: 挑战
	self.BtnGoLevel01:SetText(_G.LSTR(430005))
	-- LSTR string: 挑战
	self.BtnGoLevel02:SetText(_G.LSTR(430005))
	-- LSTR string: 挑战
	self.BtnGoLevel03:SetText(_G.LSTR(430005))
end

function ChocoboRaceNpcChallengeView:OnHide()

end

function ChocoboRaceNpcChallengeView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnToggle02, function()
		_G.UIViewMgr:ShowView(UIViewID.ChocoboExchangeRacerPageView)
	end)
	UIUtil.AddOnClickedEvent(self, self.BtnGoLevel01, self.OnClickGoLevelBtn01)
	UIUtil.AddOnClickedEvent(self, self.BtnGoLevel02, self.OnClickGoLevelBtn02)
	UIUtil.AddOnClickedEvent(self, self.BtnGoLevel03, self.OnClickGoLevelBtn03)
end

function ChocoboRaceNpcChallengeView:OnRegisterGameEvent()
	
end

function ChocoboRaceNpcChallengeView:OnRegisterBinder()
	self.ChocoboInfoBinders = {
		{ "Level",                   		UIBinderSetText.New(self, self.TextChocoboLevel) },
		{ "Name",                   		UIBinderSetText.New(self, self.TextChocoboName) },
		{ "Color", 							UIBinderSetColorAndOpacity.New(self, self.ChocoboAvatar.ImgColor) },
	}

	self.ChocoboPanelBinders = {
		{ "CurRaceEntryID", UIBinderValueChangedCallback.New(self, nil, self.OnChocoboRaceEntryIDValueChanged) },
	}
	self:RegisterBinders(_G.ChocoboMainVM, self.ChocoboPanelBinders)
end

function ChocoboRaceNpcChallengeView:OnChocoboRaceEntryIDValueChanged(NewValue, OldValue)
	if nil ~= OldValue and 0 ~= OldValue then
		local ViewModel = _G.ChocoboMainVM:FindChocoboVM(OldValue)
		if nil ~= ViewModel then
			self:UnRegisterBinders(ViewModel, self.ChocoboInfoBinders)
		end
	end

	if nil ~= NewValue and 0 ~= NewValue then
		local ViewModel = _G.ChocoboMainVM:FindChocoboVM(NewValue)
		if nil ~= ViewModel then
			self.ViewModel = ViewModel
			self:RegisterBinders(self.ViewModel, self.ChocoboInfoBinders)
		end
	end
end

function ChocoboRaceNpcChallengeView:OnClickGoLevelBtn01()
	_G.ChocoboRaceMgr:ReqRaceNpcChallenge((self.Params or {}).NpcID, 1)
end

function ChocoboRaceNpcChallengeView:OnClickGoLevelBtn02()
	_G.ChocoboRaceMgr:ReqRaceNpcChallenge((self.Params or {}).NpcID, 2)
end

function ChocoboRaceNpcChallengeView:OnClickGoLevelBtn03()
	_G.ChocoboRaceMgr:ReqRaceNpcChallenge((self.Params or {}).NpcID, 3)
end

return ChocoboRaceNpcChallengeView
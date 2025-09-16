---
--- Author: anypkvcai
--- DateTime: 2020-12-31 15:58
--- Description:
---
---
local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local LSTR = _G.LSTR

---@class PWorldTeamConfirmMembItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Img_Head UImage
---@field Img_Leader UImage
---@field Img_ProIcon UImage
---@field LevelNum UTextBlock
---@field MemberDetail UCanvasPanel
---@field Text_PlayerName UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeamConfirmMembItemView = LuaClass(UIView, true)

function PWorldTeamConfirmMembItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.Img_Head = nil
	self.Img_Leader = nil
	self.Img_ProIcon = nil
	self.LevelNum = nil
	self.MemberDetail = nil
	self.Text_PlayerName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeamConfirmMembItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeamConfirmMembItemView:OnInit()

end

function PWorldTeamConfirmMembItemView:OnDestroy()

end

function PWorldTeamConfirmMembItemView:OnShow()

end

function PWorldTeamConfirmMembItemView:OnHide()

end

function PWorldTeamConfirmMembItemView:OnRegisterUIEvent()

end

function PWorldTeamConfirmMembItemView:OnRegisterGameEvent()
	--self:RegisterGameEvent(EventID.TeamVoteNotify, self.OnGameEventTeamVoteNotify)
end

function PWorldTeamConfirmMembItemView:OnRegisterTimer()

end

function PWorldTeamConfirmMembItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then return end

	local Data = Params.Data
	if nil == Data then return end

	do
		local Binders = {
			{ "IsCaptain", UIBinderSetIsVisible.New(self, self.ImgLeader) },
			{ "ReadyRenderOpacity", UIBinderSetRenderOpacity.New(self, self.MemberDetail) },
			{ "NameColor", UIBinderSetColorAndOpacityHex.New(self, self.PlayerName) },
		}

		local ViewModel = Data
		self:RegisterBinders(ViewModel, Binders)
	end

	do
		local Binders = {
			{ "Prof", UIBinderSetProfIcon.New(self, self.Img_ProIcon) },
			{ "Name", UIBinderSetText.New(self, self.Text_PlayerName) },
			{ "Level", UIBinderSetTextFormat.New(self, self.LevelNum, "%d") },
			{ "HeadIcon", UIBinderSetBrushFromAssetPath.New(self, self.Img_Head) },
		}

		local ViewModel = _G.RoleInfoMgr:FindRoleVM(Data.RoleID)
		self:RegisterBinders(ViewModel, Binders)
	end
end

return PWorldTeamConfirmMembItemView
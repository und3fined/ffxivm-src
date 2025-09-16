---
--- Author: v_hggzhang
--- DateTime: 2023-04-23 15:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ProtoCS = require ("Protocol/ProtoCS")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetProfFuncIcon = require("Binder/UIBinderSetProfFuncIcon")
local UIBinderSetProfFuncName = require("Binder/UIBinderSetProfFuncName")
local UIBinderSetSelectedItem = require("Binder/UIBinderSetSelectedItem")
local UIBinderSetCheckedIndex = require("Binder/UIBinderSetCheckedIndex")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class PWorldTeamConfirmItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ChocoboAvatar ChocoboRaceAvatarItemView
---@field ImgAlready UFImage
---@field ImgItemBar UFImage
---@field ImgLeader UFImage
---@field ImgNoRewards UFImage
---@field ImgReadyBar UFImage
---@field ImgUnknow UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field OtherPanel UFCanvasPanel
---@field PanelReady UFCanvasPanel
---@field TextAlready UFTextBlock
---@field TextChocoboLevel UFTextBlock
---@field TextPlayerName UFTextBlock
---@field TextWaiting UFTextBlock
---@field AnimChangeJob UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimReadyIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldTeamConfirmItemView = LuaClass(UIView, true)

function PWorldTeamConfirmItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ChocoboAvatar = nil
	--self.ImgAlready = nil
	--self.ImgItemBar = nil
	--self.ImgLeader = nil
	--self.ImgNoRewards = nil
	--self.ImgReadyBar = nil
	--self.ImgUnknow = nil
	--self.JobSlot = nil
	--self.OtherPanel = nil
	--self.PanelReady = nil
	--self.TextAlready = nil
	--self.TextChocoboLevel = nil
	--self.TextPlayerName = nil
	--self.TextWaiting = nil
	--self.AnimChangeJob = nil
	--self.AnimIn = nil
	--self.AnimReadyIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldTeamConfirmItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ChocoboAvatar)
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldTeamConfirmItemView:OnInit()
	self.Binders = {
		{ "HasReady", 	UIBinderSetIsVisible.New(self, self.PanelReady) },
		{ "HasReady", 	UIBinderSetIsVisible.New(self, self.TextAlready) },
		{ "HasReady", 	UIBinderSetIsVisible.New(self, self.TextWaiting, true) },
		{ "HasReady", 	UIBinderValueChangedCallback.New(self, nil, function (_, V)
			if V then
				self:PlayAnimation(self.AnimReadyIn)
			end
			UIUtil.ImageSetBrushFromAssetPath(self.ImgUnknow, V and
				"PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_MateWin_Player03_png.UI_PWorld_Icon_MateWin_Player03_png'" or
				"PaperSprite'/Game/UI/Atlas/PWorld/Frames/UI_PWorld_Icon_MateWin_Player02_png.UI_PWorld_Icon_MateWin_Player02_png'")
		end) },

		{ "IsTeamMateOrMajor", UIBinderSetIsVisible.New(self, self.ImgUnknow, true) },
		{ "IsTeamMateOrMajor", UIBinderSetIsVisible.New(self, self.OtherPanel, true) },
		{ "IsTeamMateOrMajor", UIBinderSetIsVisible.New(self, self.TextPlayerName) },
		{ "IsShowJobSlot", UIBinderSetIsVisible.New(self, self.JobSlot) },
		{ "IsShowChocoboLevel", UIBinderSetIsVisible.New(self, self.ChocoboAvatar) },
		{ "IsShowChocoboLevel", UIBinderSetIsVisible.New(self, self.TextChocoboLevel) },
		
		{ "ShowCapIcon", 	   UIBinderSetIsVisible.New(self, self.ImgLeader) },
		{ "PollType", 	UIBinderValueChangedCallback.New(self, nil, self.OnPollTypeChange)},

		{ "bGetWeeklyReward", UIBinderSetIsVisible.New(self, self.ImgNoRewards)},
		{ "ReadyColor", UIBinderSetColorAndOpacityHex.New(self, self.TextPlayerName) },
		{ "ReadyColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgUnknow) },
		{ "ReadyColor", UIBinderSetColorAndOpacityHex.New(self, self.TextChocoboLevel) },
	}

	self.LevelBinder = UIBinderSetText.New(self, self.JobSlot.TextLevel)
	self.ProfIconBinder = UIBinderSetProfIcon.New(self, self.JobSlot.ImgJob)
	self.ProfAnimBinder = UIBinderValueChangedCallback.New(self, nil, function()
		self:PlayAnimation(self.AnimChangeJob)
	end)
	self.NameBinderKV = { "Name", 		UIBinderSetText.New(self, self.TextPlayerName) }
	self.TeamProfBinders = {
		{ "SyncProf", 		self.ProfIconBinder },
		{ "SyncProf", 		self.ProfAnimBinder },
		{ "SyncLevel", 		self.LevelBinder },
	}

	self.ChocoboBinders =
	{
		{ "Name", 		UIBinderSetText.New(self, self.TextPlayerName) },
		{ "Level", 		UIBinderSetText.New(self, self.TextChocoboLevel) },
		{ "Color", 		UIBinderSetColorAndOpacity.New(self, self.ChocoboAvatar.ImgColor) },
	}

	self.CardTourneyBinders = {
		{ "SyncLevel", 		self.LevelBinder },
	}
	self.TextWaiting:SetText(_G.LSTR(1320153))
	self.TextAlready:SetText(_G.LSTR(1320154))
end

function PWorldTeamConfirmItemView:OnRegisterBinder()
	if not (self.Params and self.Params.Data) then
		return
	end

	self.VM = self.Params.Data
	self:RegisterBinders(self.VM, self.Binders)
end

function PWorldTeamConfirmItemView:OnPollTypeChange(NewValue, OldValue)
	local function RegisterRoleBinders()
		if self.VM.IsTeamMateOrMajor then
			self:RegisterBinders(self.VM, self.TeamProfBinders)
			if self.VM.RoleVM then
				self:RegisterBinders(self.VM.RoleVM, {self.NameBinderKV,})
			end
		end
	end

	if NewValue == ProtoCS.PollType.PollType_EnterScene then
		RegisterRoleBinders()
	elseif NewValue == ProtoCS.PollType.PollType_Chocobo then
		local ChocoboVM = _G.ChocoboMgr:FindRoleChocoboVM(self.VM.RoleID)
		if ChocoboVM and self.VM.IsTeamMateOrMajor then
			self:RegisterBinders(ChocoboVM, self.ChocoboBinders)
		end
	elseif NewValue == ProtoCS.PollType.PoolType_Tournament then
		RegisterRoleBinders()
		local MajorUtil = require("Utils/MajorUtil")
		local Level = MajorUtil.GetMajorLevel() or ""
		self.JobSlot.TextLevel:SetText(Level)
	end
end

return PWorldTeamConfirmItemView
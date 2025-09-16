---
--- Author: peterxie
--- DateTime:
--- Description: 战场日志
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIconSimple2nd = require("Binder/UIBinderSetProfIconSimple2nd")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class PVPColosseumBattleLogItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EffectEventBg UFImage
---@field ImgCommandBg UFImage
---@field ImgCryatal3 UFImage
---@field ImgCryatal4 UFImage
---@field ImgEventBg UFImage
---@field ImgEventIcon UFImage
---@field ImgJob1 UFImage
---@field ImgJob2 UFImage
---@field ImgJob3 UFImage
---@field ImgJob4 UFImage
---@field ImgJobBg1 UFImage
---@field ImgJobBg2 UFImage
---@field ImgJobBg3 UFImage
---@field ImgJobBg4 UFImage
---@field ImgKill1 UFImage
---@field ImgKill2 UFImage
---@field ImgKill3 UFImage
---@field ImgKill4 UFImage
---@field PanelCommand UFCanvasPanel
---@field PanelEvent UFCanvasPanel
---@field PanelKO UFCanvasPanel
---@field PanelRoot UFCanvasPanel
---@field RichTextContent URichTextBox
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextNum4 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumBattleLogItemView = LuaClass(UIView, true)

function PVPColosseumBattleLogItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EffectEventBg = nil
	--self.ImgCommandBg = nil
	--self.ImgCryatal3 = nil
	--self.ImgCryatal4 = nil
	--self.ImgEventBg = nil
	--self.ImgEventIcon = nil
	--self.ImgJob1 = nil
	--self.ImgJob2 = nil
	--self.ImgJob3 = nil
	--self.ImgJob4 = nil
	--self.ImgJobBg1 = nil
	--self.ImgJobBg2 = nil
	--self.ImgJobBg3 = nil
	--self.ImgJobBg4 = nil
	--self.ImgKill1 = nil
	--self.ImgKill2 = nil
	--self.ImgKill3 = nil
	--self.ImgKill4 = nil
	--self.PanelCommand = nil
	--self.PanelEvent = nil
	--self.PanelKO = nil
	--self.PanelRoot = nil
	--self.RichTextContent = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextNum4 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumBattleLogItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumBattleLogItemView:OnInit()
	self.BattleLogBinders =
	{
		--{ "Visible", UIBinderSetIsVisible.New(self, self.PanelRoot) },
		{ "VisibleEvent", UIBinderSetIsVisible.New(self, self.PanelEvent) },
		{ "VisibleKO", UIBinderSetIsVisible.New(self, self.PanelKO) },
		{ "VisibleCommand", UIBinderSetIsVisible.New(self, self.PanelCommand) },

		{ "Event_Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEventIcon) },
		{ "Event_Str", UIBinderSetText.New(self, self.RichTextContent) },
		{ "Event_Bg", UIBinderSetBrushFromAssetPath.New(self, self.ImgEventBg) },
		{ "Event_BgEffect", UIBinderSetIsVisible.New(self, self.EffectEventBg) },

		{ "KO_Name", UIBinderSetText.New(self, self.TextName) },
		{ "KO_Count", UIBinderSetText.New(self, self.TextNum) },
		{ "KO_ProfBg1", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg1) },
		{ "KO_ProfBg2", UIBinderSetBrushFromAssetPath.New(self, self.ImgJobBg2) },
		{ "KO_ProfID1", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob1) },
		{ "KO_ProfID2", UIBinderSetProfIconSimple2nd.New(self, self.ImgJob2) },

		{ "LogID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedLogID) },
	}
end

function PVPColosseumBattleLogItemView:OnDestroy()

end

function PVPColosseumBattleLogItemView:OnShow()

end

function PVPColosseumBattleLogItemView:OnHide()

end

function PVPColosseumBattleLogItemView:OnRegisterUIEvent()

end

function PVPColosseumBattleLogItemView:OnRegisterGameEvent()

end

function PVPColosseumBattleLogItemView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.BattleLogBinders)
	end
end

function PVPColosseumBattleLogItemView:SetViewModel(BattleLogVM)
	self.ViewModel = BattleLogVM
end

function PVPColosseumBattleLogItemView:OnValueChangedLogID(Value)
	local BattleLogVM = self.ViewModel ---@type BattleLogVM

	if BattleLogVM.Visible then
		if BattleLogVM.CopyShow then
			--self:PlayAnimation(self.AnimIn)
		else
			self:PlayAnimation(self.AnimIn)
		end
	else
		self:PlayAnimation(self.AnimOut)
	end
end

return PVPColosseumBattleLogItemView
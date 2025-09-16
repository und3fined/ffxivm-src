---
--- Author: daniel
--- DateTime: 2023-03-15 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")

---@class ArmyMemberClassEditPlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSetting1 UFButton
---@field BtnSetting2 UFButton
---@field ImgPlayerIcon1 UFImage
---@field ImgPlayerIcon2 UFImage
---@field PanelPlayer1 UFCanvasPanel
---@field PanelPlayer2 UFCanvasPanel
---@field TextPlayerName1 UFTextBlock
---@field TextPlayerName2 UFTextBlock
---@field ToggleBtn1 UToggleButton
---@field ToggleBtn2 UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyMemberClassEditPlayerItemView = LuaClass(UIView, true)

function ArmyMemberClassEditPlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSetting1 = nil
	--self.BtnSetting2 = nil
	--self.ImgPlayerIcon1 = nil
	--self.ImgPlayerIcon2 = nil
	--self.PanelPlayer1 = nil
	--self.PanelPlayer2 = nil
	--self.TextPlayerName1 = nil
	--self.TextPlayerName2 = nil
	--self.ToggleBtn1 = nil
	--self.ToggleBtn2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditPlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyMemberClassEditPlayerItemView:OnInit()
	self.Binders = {
		{"ImgPlayerIcon1", UIBinderSetBrushFromAssetPath.New(self, self.ImgPlayerIcon1)},
		{"Player1Name", UIBinderSetText.New(self, self.TextPlayerName1)},
		{"ImgPlayerIcon2", UIBinderSetBrushFromAssetPath.New(self, self.ImgPlayerIcon2)},
		{"Player2Name", UIBinderSetText.New(self, self.TextPlayerName2)},
		{"bPlayer2Item", UIBinderSetIsVisible.New(self, self.PanelPlayer2)},
		{"bSetting1", UIBinderSetIsVisible.New(self, self.BtnSetting1, false, true)},
		{"bSetting2", UIBinderSetIsVisible.New(self, self.BtnSetting2, false, true)},
		-- {"Player1Opacity", UIBinderSetRenderOpacity.New(self, self.PanelPlayer1)},
		-- {"Player2Opacity", UIBinderSetRenderOpacity.New(self, self.PanelPlayer1)},
	}
end

function ArmyMemberClassEditPlayerItemView:OnDestroy()

end

function ArmyMemberClassEditPlayerItemView:OnShow()

end

function ArmyMemberClassEditPlayerItemView:OnHide()

end

function ArmyMemberClassEditPlayerItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSetting1, self.OnClickedItem, 1)
	UIUtil.AddOnClickedEvent(self, self.BtnSetting2, self.OnClickedItem, 2)
end

function ArmyMemberClassEditPlayerItemView:OnRegisterGameEvent()

end

function ArmyMemberClassEditPlayerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end


function ArmyMemberClassEditPlayerItemView:OnClickedItem(Index)
	local Params = self.Params
	if nil == Params then
		return
	end
	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	Adapter:OnItemClicked(self, Index)
end

return ArmyMemberClassEditPlayerItemView
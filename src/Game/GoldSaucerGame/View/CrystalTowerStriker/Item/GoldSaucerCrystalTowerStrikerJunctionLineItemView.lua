---
--- Author: Administrator
--- DateTime: 2024-03-08 19:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class GoldSaucerCrystalTowerStrikerJunctionLineItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFFRedLine UFCanvasPanel
---@field EFFYellowLine UFCanvasPanel
---@field ImgLineRad_1 UFImage
---@field ImgLineYellow UFImage
---@field MI_DX_Common_CrystalTowerStriker_2 UFImage
---@field MI_DX_Common_CrystalTowerStriker_3 UFImage
---@field MI_DX_Common_CrystalTowerStriker_4 UFImage
---@field MI_DX_Common_CrystalTowerStriker_5 UFImage
---@field AnimRedIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerCrystalTowerStrikerJunctionLineItemView = LuaClass(UIView, true)

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFFRedLine = nil
	--self.EFFYellowLine = nil
	--self.ImgLineRad_1 = nil
	--self.ImgLineYellow = nil
	--self.MI_DX_Common_CrystalTowerStriker_2 = nil
	--self.MI_DX_Common_CrystalTowerStriker_3 = nil
	--self.MI_DX_Common_CrystalTowerStriker_4 = nil
	--self.MI_DX_Common_CrystalTowerStriker_5 = nil
	--self.AnimRedIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnInit()

	self.Binders = {
		{"bNotInEndRound", UIBinderSetIsVisible.New(self, self.EFFYellowLine)},
		{"bInEndRound", UIBinderSetIsVisible.New(self, self.EFFRedLine)},
		{"bNotInEndRound", UIBinderSetIsVisible.New(self, self.TableView_34)},
	}
end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnDestroy()

end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnShow()

end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnHide()

end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnRegisterUIEvent()

end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnRegisterGameEvent()

end

function GoldSaucerCrystalTowerStrikerJunctionLineItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	self:RegisterBinders(ViewModel, self.Binders)

end

return GoldSaucerCrystalTowerStrikerJunctionLineItemView
---
--- Author: janezli
--- DateTime: 2024-10-26 16:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommonThroughFrameSView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck1 CommBtnLView
---@field BtnCheck2 CommBtnLView
---@field BtnClose2 CommBtnLView
---@field BtnLeft3 CommBtnLView
---@field BtnMid3 CommBtnLView
---@field BtnRight3 CommBtnLView
---@field NamedSlotChild UNamedSlot
---@field Panel1Btn UFCanvasPanel
---@field Panel2Btn UFCanvasPanel
---@field Panel3Btn UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextCloseTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field CommTitle bool
---@field Title text
---@field Number of buttons CommThroughFrameBtn
---@field bAutoPlayAnimIn bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonThroughFrameSView = LuaClass(UIView, true)

function CommonThroughFrameSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck1 = nil
	--self.BtnCheck2 = nil
	--self.BtnClose2 = nil
	--self.BtnLeft3 = nil
	--self.BtnMid3 = nil
	--self.BtnRight3 = nil
	--self.NamedSlotChild = nil
	--self.Panel1Btn = nil
	--self.Panel2Btn = nil
	--self.Panel3Btn = nil
	--self.PanelTitle = nil
	--self.PopUpBG = nil
	--self.TextCloseTips = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.CommTitle = nil
	--self.Title = nil
	--self.Number of buttons = nil
	--self.bAutoPlayAnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonThroughFrameSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCheck1)
	self:AddSubView(self.BtnCheck2)
	self:AddSubView(self.BtnClose2)
	self:AddSubView(self.BtnLeft3)
	self:AddSubView(self.BtnMid3)
	self:AddSubView(self.BtnRight3)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonThroughFrameSView:OnInit()

end

function CommonThroughFrameSView:OnDestroy()

end

function CommonThroughFrameSView:OnShow()

end

function CommonThroughFrameSView:OnHide()

end

function CommonThroughFrameSView:OnRegisterUIEvent()

end

function CommonThroughFrameSView:OnRegisterGameEvent()

end

function CommonThroughFrameSView:OnRegisterBinder()

end

return CommonThroughFrameSView
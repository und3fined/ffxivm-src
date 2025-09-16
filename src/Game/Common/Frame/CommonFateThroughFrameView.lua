---
--- Author: Michaelyang_lightpaw
--- DateTime: 2025-03-03 20:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommonFateThroughFrameView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck1 CommBtnLView
---@field BtnCheck2 CommBtnLView
---@field BtnClose2 CommBtnLView
---@field BtnLeft3 CommBtnLView
---@field BtnMid3 CommBtnLView
---@field BtnRight3 CommBtnLView
---@field CommonPlaySound_Success CommonPlaySoundView
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
---@field Comm title bool
---@field Title text
---@field Number of buttons CommThroughFrameBtn
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonFateThroughFrameView = LuaClass(UIView, true)

function CommonFateThroughFrameView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnCheck1 = nil
    --self.BtnCheck2 = nil
    --self.BtnClose2 = nil
    --self.BtnLeft3 = nil
    --self.BtnMid3 = nil
    --self.BtnRight3 = nil
    --self.CommonPlaySound_Success = nil
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
    --self.Comm title = nil
    --self.Title = nil
    --self.Number of buttons = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonFateThroughFrameView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnCheck1)
    self:AddSubView(self.BtnCheck2)
    self:AddSubView(self.BtnClose2)
    self:AddSubView(self.BtnLeft3)
    self:AddSubView(self.BtnMid3)
    self:AddSubView(self.BtnRight3)
    self:AddSubView(self.CommonPlaySound_Success)
    self:AddSubView(self.PopUpBG)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonFateThroughFrameView:OnInit()
end

function CommonFateThroughFrameView:OnDestroy()
end

function CommonFateThroughFrameView:OnShow()
end

function CommonFateThroughFrameView:OnHide()
end

function CommonFateThroughFrameView:OnRegisterUIEvent()
end

function CommonFateThroughFrameView:OnRegisterGameEvent()
end

function CommonFateThroughFrameView:OnRegisterBinder()
end

return CommonFateThroughFrameView

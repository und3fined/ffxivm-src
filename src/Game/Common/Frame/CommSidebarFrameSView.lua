---
--- Author: Administrator
--- DateTime: 2024-09-05 15:04
--- Description:
---

local CommSidebarFrameBaseView = require("Game/Common/Frame/CommSidebarFrameBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommSidebarFrameSView : CommSidebarFrameBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field CommonTitle CommonTitleView
---@field FHorizontalTitle UFHorizontalBox
---@field ImgBgMask1 UFImage
---@field ImgBgMask2 UFImage
---@field ImgBkg UFImage
---@field ImgPattern UFImage
---@field ImgState UFImage
---@field NamedSlotChild UNamedSlot
---@field PanelTop UFCanvasPanel
---@field Sidebar UFCanvasPanel
---@field SizeBox USizeBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field IsHorizontalTitleShow bool
---@field IsImageStateShow bool
---@field IsBtnCloseShow bool
---@field IsBtnBackShow bool
---@field SizeType CommonSideBarSize
---@field CustomSideBarSize float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSidebarFrameSView = LuaClass(CommSidebarFrameBaseView, true)

function CommSidebarFrameSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.CommonTitle = nil
	--self.FHorizontalTitle = nil
	--self.ImgBgMask1 = nil
	--self.ImgBgMask2 = nil
	--self.ImgBkg = nil
	--self.ImgPattern = nil
	--self.ImgState = nil
	--self.NamedSlotChild = nil
	--self.PanelTop = nil
	--self.Sidebar = nil
	--self.SizeBox = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.HpInfoShow = nil
	--self.HelpInfoID = nil
	--self.IsHorizontalTitleShow = nil
	--self.IsImageStateShow = nil
	--self.IsBtnCloseShow = nil
	--self.IsBtnBackShow = nil
	--self.SizeType = nil
	--self.CustomSideBarSize = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSidebarFrameSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSidebarFrameSView:OnInit()

end

function CommSidebarFrameSView:OnDestroy()

end

function CommSidebarFrameSView:OnShow()

end

function CommSidebarFrameSView:OnHide()

end

function CommSidebarFrameSView:OnRegisterUIEvent()

end

function CommSidebarFrameSView:OnRegisterGameEvent()

end

function CommSidebarFrameSView:OnRegisterBinder()

end

function CommSidebarFrameSView:AddBackClick(Owner, BackBtnCallBack)
	self.BtnBack:AddBackClick(Owner, BackBtnCallBack)
end

return CommSidebarFrameSView
---
--- Author: Administrator
--- DateTime: 2024-09-05 15:04
--- Description:
---
local CommSidebarFrameBaseView = require("Game/Common/Frame/CommSidebarFrameBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommSidebarTabFrameView : CommSidebarFrameBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field CommonTitle CommonTitleView
---@field FHorizontalTitle UFHorizontalBox
---@field ImgBkg UFImage
---@field ImgPattern UFImage
---@field ImgTabBkg UFImage
---@field ImgTitleBg UFImage
---@field NamedSlotChild UNamedSlot
---@field PanelTop UFCanvasPanel
---@field Sidebar UFCanvasPanel
---@field AnimChatToNarrow UWidgetAnimation
---@field AnimChatToWide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field IsHorizontalTitleShow bool
---@field IsBtnCloseShow bool
---@field IsBtnBackShow bool
---@field TabBkgSize float
---@field SizeType CommonSideBarTabSize
---@field CustomSideBarSize float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSidebarTabFrameView = LuaClass(CommSidebarFrameBaseView, true)

function CommSidebarTabFrameView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.CommonTitle = nil
	--self.FHorizontalTitle = nil
	--self.ImgBkg = nil
	--self.ImgPattern = nil
	--self.ImgTabBkg = nil
	--self.ImgTitleBg = nil
	--self.NamedSlotChild = nil
	--self.PanelTop = nil
	--self.Sidebar = nil
	--self.AnimChatToNarrow = nil
	--self.AnimChatToWide = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.IsHorizontalTitleShow = nil
	--self.IsBtnCloseShow = nil
	--self.IsBtnBackShow = nil
	--self.TabBkgSize = nil
	--self.SizeType = nil
	--self.CustomSideBarSize = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSidebarTabFrameView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSidebarTabFrameView:ShowNamedSlotChild2(IsShow)
	UIUtil.SetIsVisible(self.NamedSlotChild2, IsShow)
end

function CommSidebarTabFrameView:OnInit()

end

function CommSidebarTabFrameView:OnDestroy()

end

function CommSidebarTabFrameView:OnShow()

end

function CommSidebarTabFrameView:OnHide()

end

function CommSidebarTabFrameView:OnRegisterUIEvent()

end

function CommSidebarTabFrameView:OnRegisterGameEvent()

end

function CommSidebarTabFrameView:OnRegisterBinder()

end

function CommSidebarTabFrameView:PlayAnimationChatWide()
	self:PlayAnimation(self.AnimChatToWide)
end

function CommSidebarTabFrameView:PlayAnimationChatNarrow()
	self:PlayAnimation(self.AnimChatToNarrow)
end

function CommSidebarTabFrameView:SetImgTabVisible(bVisible)
	UIUtil.SetIsVisible(self.ImgTabBkg, bVisible)
end

return CommSidebarTabFrameView
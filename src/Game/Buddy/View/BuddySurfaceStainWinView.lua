---
--- Author: Administrator
--- DateTime: 2023-11-30 14:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BuddySurfaceStainVM = require("Game/Buddy/VM/BuddySurfaceStainVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

local BuddyMgr
local LSTR

---@class BuddySurfaceStainWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnYes CommBtnLView
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field RichTextColor01 URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceStainWinView = LuaClass(UIView, true)

function BuddySurfaceStainWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnYes = nil
	--self.Comm2FrameS_UIBP = nil
	--self.RichTextColor01 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceStainWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnYes)
	self:AddSubView(self.Comm2FrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceStainWinView:OnInit()
	BuddyMgr = _G.BuddyMgr
	LSTR = _G.LSTR
	self.ViewModel = BuddySurfaceStainVM
	self.Binders = {
		{ "ColorNameText", UIBinderSetText.New(self, self.RichTextColor01) },
		
	}
end

function BuddySurfaceStainWinView:OnDestroy()

end

function BuddySurfaceStainWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local TargetColorID = Params.TargetColorID
	self.ViewModel:UpdateVM(TargetColorID)
end

function BuddySurfaceStainWinView:OnHide()

end

function BuddySurfaceStainWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClickedCancelBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnYes.Button, self.OnClickedYesBtn)
end

function BuddySurfaceStainWinView:OnRegisterGameEvent()

end

function BuddySurfaceStainWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)

	self.Comm2FrameS_UIBP:SetTitleText(LSTR(10004))
	self.BtnCancel:SetText(LSTR(10003))
	self.BtnYes:SetText(LSTR(10002))
	
end

function BuddySurfaceStainWinView:OnClickedCancelBtn()
	self:Hide()
end

function BuddySurfaceStainWinView:OnClickedYesBtn()
	local Params = self.Params
	if nil == Params then
		return
	end

	local TargetColorID = Params.TargetColorID
	local DyeLists = Params.DyeLists
	local DyeType = Params.DyeType
	BuddyMgr:ReqDyeColor(BuddyMgr.SurfaceViewCurID, DyeType, TargetColorID, DyeLists)
	self:Hide()
end

return BuddySurfaceStainWinView
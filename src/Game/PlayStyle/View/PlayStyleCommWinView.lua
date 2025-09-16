---
--- Author: Administrator
--- DateTime: 2023-10-07 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PlayStyleCommWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNo UFButton
---@field BtnYes UFButton
---@field PlayStyleCommFrameS_UIBP PlayStyleCommFrameSView
---@field RichText URichTextBox
---@field TextNo UFTextBlock
---@field TextTes UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleCommWinView = LuaClass(UIView, true)

function PlayStyleCommWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNo = nil
	--self.BtnYes = nil
	--self.PlayStyleCommFrameS_UIBP = nil
	--self.RichText = nil
	--self.TextNo = nil
	--self.TextYes = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleCommWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayStyleCommFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleCommWinView:OnInit()

end

function PlayStyleCommWinView:OnDestroy()

end

function PlayStyleCommWinView:OnShow()
	local Params = self.Params
	self.RichText:SetText(Params.Content)
	if Params.Title ~= nil then
		self.PlayStyleCommFrameS_UIBP.RichTextBox_Title:SetText(Params.Title)
	end
	self.View = Params.View
	self.ConfirmCallBack = Params.ConfirmCallBack
	self.CancelCallBack = Params.CancelCallBack
	self.ConfirmParams = Params.ConfirmParams
	self.CancleParams = Params.CancelParams
	self.CloseCallBack = Params.CloseCallBack

	if (Params.TextYes ~= nil) then
		self.TextYes:SetText(Params.TextYes)
	else
		self.TextYes:SetText(LSTR(10027)) -- 是
	end

	if (Params.TextNo ~= nil) then
		self.TextNo:SetText(Params.TextNo)
	else
		self.TextNo:SetText(LSTR(10028)) -- 否
	end

	if (Params.CloseCallBack ~= nil) then
		self.PlayStyleCommFrameS_UIBP:SetCloseCallback(Params.CloseCallBack)
	end
end

function PlayStyleCommWinView:OnHide()

end

function PlayStyleCommWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnYes, self.OnBtnYesClick)
	UIUtil.AddOnClickedEvent(self, self.BtnNo, self.OnBtnNoClick)
end

function PlayStyleCommWinView:OnRegisterGameEvent()

end

function PlayStyleCommWinView:OnRegisterBinder()

end

function PlayStyleCommWinView:OnBtnYesClick()
	if self.ConfirmCallBack ~= nil then
		self.ConfirmCallBack(self.View, self.ConfirmParams)
	end
	self:Hide()
end

function PlayStyleCommWinView:OnBtnNoClick()
	if self.CancelCallBack ~= nil then
		self.CancelCallBack(self.View, self.CancleParams)
	end
	self:Hide()
end

return PlayStyleCommWinView
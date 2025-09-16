---
--- Author: Administrator
--- DateTime: 2024-12-27 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local LSTR = _G.LSTR
local FLinearColor = _G.UE.FLinearColor
---@class OpsDesertFinePanelPlanWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnConfirm CommBtnMView
---@field BtnConfirm2 CommBtnLView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field CommInputBox CommInputBoxView
---@field IconEdit UFImage
---@field ImgLine1 UFImage
---@field ImgLine2 UFImage
---@field ImgMask UFImage
---@field PanelPlanBGWhite UFCanvasPanel
---@field PanelPlanBGYellow UFCanvasPanel
---@field RichText1 URichTextBox
---@field RichText2 URichTextBox
---@field RichText3 URichTextBox
---@field RichTextHint URichTextBox
---@field TextScheme1 UFTextBlock
---@field TextScheme2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsDesertFinePanelPlanWinView = LuaClass(UIView, true)

function OpsDesertFinePanelPlanWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnConfirm = nil
	--self.BtnConfirm2 = nil
	--self.Comm2FrameL_UIBP = nil
	--self.CommInputBox = nil
	--self.IconEdit = nil
	--self.ImgLine1 = nil
	--self.ImgLine2 = nil
	--self.ImgMask = nil
	--self.PanelPlanBGWhite = nil
	--self.PanelPlanBGYellow = nil
	--self.RichText1 = nil
	--self.RichText2 = nil
	--self.RichText3 = nil
	--self.RichTextHint = nil
	--self.TextScheme1 = nil
	--self.TextScheme2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsDesertFinePanelPlanWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.BtnConfirm2)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.CommInputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsDesertFinePanelPlanWinView:OnInit()
	self.CommInputBox:SetCallback(self, self.OnTextChangedName)
end

function OpsDesertFinePanelPlanWinView:OnDestroy()

end

function OpsDesertFinePanelPlanWinView:OnShow()
	self.BtnConfirm:SetIsEnabled(false, false)
	if self.Params == nil then
		return
	end
	
	UIUtil.SetIsVisible(self.PanelPlanBGWhite, self.Params.Mask == true)
	if self.Params.Mask == true then
		UIUtil.SetIsVisible(self.PanelPlanBGYellow, false)
	end

	local ColorStr = self.Params.Mask == true and "#696969" or "#d5d5d5"
	local TitleColorStr = self.Params.Mask == true and "#828282" or "#ffeebb"
	local LinearColor = FLinearColor.FromHex(ColorStr)
	self.RichText2:SetColorAndOpacity(LinearColor)
	self.RichText3:SetColorAndOpacity(LinearColor)

	LinearColor = FLinearColor.FromHex(TitleColorStr)
	self.TextScheme2:SetColorAndOpacity(LinearColor)

	if not string.isnilorempty(self.Params.CouponCode) then
		self.CommInputBox:SetText(self.Params.CouponCode)
	end
	
end

function OpsDesertFinePanelPlanWinView:OnHide()

end

function OpsDesertFinePanelPlanWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickConfirmBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm2, self.OnClickConfirm2Btn)
end

function OpsDesertFinePanelPlanWinView:OnClickConfirmBtn()
	if self.Params == nil then
		return
	end
	if self.Params.ShareBuyNodeID == nil then
		return
	end
	local CouponCode = self.CommInputBox:GetText()
	_G.JudgeSearchMgr:QueryTextIsLegal(CouponCode, function( IsLegal )
		if not IsLegal then
			_G.MsgTipsUtil.ShowTips(LSTR(10057)) 
			self.CommInputBox:SetText("")
		else
			local ProtoCS = require("Protocol/ProtoCS")
			local Data = {Code = CouponCode}
			_G.OpsActivityMgr:SendActivityNodeOperate(self.Params.ShareBuyNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypeShardBuyInput,{ShardBuyInput = Data})
			--self:Hide()
		end
	end)

end

function OpsDesertFinePanelPlanWinView:OnClickConfirm2Btn()
	self:Hide()
end

function OpsDesertFinePanelPlanWinView:OnRegisterGameEvent()
end

function OpsDesertFinePanelPlanWinView:OnRegisterBinder()
	self.Comm2FrameL_UIBP:SetTitleText(LSTR(1470001))
	local Path = "PaperSprite'/Game/Assets/Icon/900000/UI_Icon_900153.UI_Icon_900153'"
	local IconText = RichTextUtil.GetTexture(Path, 40, 40, -6) or ""
	self.RichTextHint:SetText(string.format("%s%s%s", LSTR(1470002), IconText, LSTR(1470025)))


	self.TextScheme1:SetText(LSTR(1470003))
	self.RichText1:SetText(LSTR(1470004))
	self.TextScheme2:SetText(LSTR(1470005))

	IconText = RichTextUtil.GetTexture(Path, 30, 30, -6) or ""
	self.RichText2:SetText(string.format("%s%s%s", LSTR(1470006), IconText, LSTR(1470026)))
	self.RichText3:SetText(LSTR(1470007))
	self.CommInputBox:SetHintText(LSTR(1470015))
	self.BtnConfirm:SetButtonText(LSTR(10002))
	self.BtnConfirm2:SetButtonText(LSTR(1470008))

	local LinearColor = FLinearColor.FromHex("#d5d5d5")
	self.RichText1:SetColorAndOpacity(LinearColor)
	self.RichText2:SetColorAndOpacity(LinearColor)
	self.RichText3:SetColorAndOpacity(LinearColor)

	LinearColor = FLinearColor.FromHex("#ffeebb")
	self.TextScheme1:SetColorAndOpacity(LinearColor)
	self.TextScheme2:SetColorAndOpacity(LinearColor)

	UIUtil.SetIsVisible(self.PanelPlanBGWhite, false)
	UIUtil.SetIsVisible(self.PanelPlanBGYellow, true)
end

function OpsDesertFinePanelPlanWinView:OnTextChangedName(Text)
	if self.Params and self.Params.Mask == true then
		return
	end
	
	if string.isnilorempty(Text) then
		self.BtnConfirm:SetIsEnabled(false, false)
	else
		self.BtnConfirm:SetIsEnabled(true, true)
	end
	
end

return OpsDesertFinePanelPlanWinView
---
--- Author: Administrator
--- DateTime: 2025-01-03 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsDesertFineShareCouponCodeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommBtnL_UIBP CommBtnLView
---@field RichTextInfo URichTextBox
---@field TextCouponCode UFTextBlock
---@field TextHint UFTextBlock
---@field TextMyExclusive UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsDesertFineShareCouponCodeWinView = LuaClass(UIView, true)

function OpsDesertFineShareCouponCodeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.CommBtnL_UIBP = nil
	--self.RichTextInfo = nil
	--self.TextCouponCode = nil
	--self.TextHint = nil
	--self.TextMyExclusive = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsDesertFineShareCouponCodeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.CommBtnL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsDesertFineShareCouponCodeWinView:OnInit()

end

function OpsDesertFineShareCouponCodeWinView:OnDestroy()

end

function OpsDesertFineShareCouponCodeWinView:OnShow()
	if self.Params == nil then
		return
	end
	local NodeData = _G.OpsActivityMgr:GetActivtyNodeInfo(self.Params.ActivityID or self.Params.JumpData[1])
	if NodeData == nil or NodeData.NodeList == nil then
		return 
	end
	local TotalNum = 0
	local UseNum = 0
	self.CouponCode = ""
	for _, Node in ipairs(NodeData.NodeList) do
		local NodeID  = Node.Head.NodeID
		local Extra = Node.Extra
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
		if ActivityNode then
			if ActivityNode.NodeType == ActivityNodeType.ActivityNodeTypeShareBuy then
				local ShareBuy = Extra.ShareBuy or {}
				self.CouponCode = ShareBuy.CouponCode or ""
				TotalNum = ActivityNode.Params[5]
				UseNum = ShareBuy.UsedTimes
				break
			end
		end
	end

	self.TextCouponCode:SetText(self.CouponCode)
	local CouponUseInfo = string.format("%s%d/%d", LSTR(1470019), UseNum, TotalNum)
	self.TextHint:SetText(CouponUseInfo)
	self.CommBtnL_UIBP:SetIsEnabled(TotalNum > UseNum)
end

function OpsDesertFineShareCouponCodeWinView:OnHide()

end

function OpsDesertFineShareCouponCodeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnL_UIBP, self.OnClickCopyBtn)
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.ButtonClose, self.OnClickCloseBtn)
end

function OpsDesertFineShareCouponCodeWinView:OnRegisterGameEvent()

end

function OpsDesertFineShareCouponCodeWinView:OnRegisterBinder()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(1470012))
	self.RichTextInfo:SetText(LSTR(1470017))
	self.TextMyExclusive:SetText(LSTR(1470018))
	self.CommBtnL_UIBP:SetButtonText(LSTR(1470020))

end

function OpsDesertFineShareCouponCodeWinView:OnClickCloseBtn()
	self:Hide()
end

function OpsDesertFineShareCouponCodeWinView:OnClickCopyBtn()
	if self.CouponCode == nil then
		return
	end
	CommonUtil.ClipboardCopy(self.CouponCode)
    _G.MsgTipsUtil.ShowTips(LSTR(1470021))
	self:Hide()
end

return OpsDesertFineShareCouponCodeWinView
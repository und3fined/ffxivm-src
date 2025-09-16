---
--- Author: Administrator
--- DateTime: 2024-03-01 20:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LSTR = _G.LSTR

---@class RechargingVoucherWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnOK CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field RichTextDiscribe URichTextBox
---@field RichTextTips URichTextBox
---@field Slot1 CommBackpackSlotView
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingVoucherWinView = LuaClass(UIView, true)

function RechargingVoucherWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnOK = nil
	--self.Comm2FrameM_UIBP = nil
	--self.RichTextDiscribe = nil
	--self.RichTextTips = nil
	--self.Slot1 = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingVoucherWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOK)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.Slot1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingVoucherWinView:OnShow()
	self:RefreshItemAndText()
	self.Slot1:SetClickButtonCallback(self, self.OnClickCoinItem,self.Slot1)
end

---注册UI事件
function RechargingVoucherWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOk, self.OnClickedConfirm)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickedChannel)
end
-------------------------------View刷新S-------------------------
function RechargingVoucherWinView:RefreshItemAndText()
	local ItemUtil = require("Utils/ItemUtil")
	local ProtoRes = require("Protocol/ProtoRes")
	local GlobalCfg = require("TableCfg/RechargeParamCfg") 
	local VoucherCfg = GlobalCfg:FindCfgByKey(ProtoRes.recharge_param_cfg_id.RECHARGE_PRAMETER_VOUCHERSID)
	if VoucherCfg and next(VoucherCfg) then
		local VoucherItemID = tonumber(VoucherCfg.Value[1])
		self.VoucherItemID = VoucherItemID
		local IconPath
		local IconID = ItemUtil.GetItemIcon(VoucherItemID)
		local ItemName = ItemUtil.GetItemName(VoucherItemID)
		if IconID then
			IconPath =  UIUtil.GetIconPath(IconID)
		end
		if nil ~= IconPath then
			UIUtil.ImageSetBrushFromAssetPath(self.Slot1.FImg_Icon, IconPath)
		end
		self.TextName:SetText(ItemName)
	end

	local VoucherNum = self.Params.CostInfo
	if VoucherNum then
		local LocalizeText = string.format(LSTR("您背包中有足够的代金券可使用，是否使用<span color=\"#D1906DFF\">代金券*%d</>进行支付？"), VoucherNum)
		self.RichTextDiscribe:SetText(LocalizeText)
	end
end
-------------------------------View刷新E-------------------------
-------------------------------事件S------------------------------
---确认按钮
function RechargingVoucherWinView:OnClickedConfirm()
	--消耗优惠券直购
	self:GetCoinOrItemByVoucher(tostring(self.Params.ProductID))
end

---取消按钮
function RechargingVoucherWinView:OnClickedChannel()
	local MsgTipsUtil = require("Utils/MsgTipsUtil")
	MsgTipsUtil.ShowTips(LSTR("交易取消"))
	self:Hide()
end

---代金券购买
---@param ProductID number
function RechargingVoucherWinView:GetCoinOrItemByVoucher(ProductID)
	local ProtoCS = require("Protocol/ProtoCS")
	local ProtoRes = require("Protocol/ProtoRes")
	local CommonUtil = require("Utils/CommonUtil")
	local GameNetworkMgr = require("Network/GameNetworkMgr")
	--登录信息
	local LoginRet = _G.UE.FAccountLoginRetData()
	_G.UE.UAccountMgr.Get():GetLoginRet(LoginRet)
	--这里取一下登录平台,默认安卓方便测试账号测试
	local Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	if CommonUtil.GetPlatformName() == "Android" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_ANDROID
	elseif CommonUtil.GetPlatformName() == "IOS" then
		Platform = ProtoRes.DevicePlatform.DEVICE_PLATFORM_IOS
	end

	local CS_CMD = ProtoCS.CS_CMD
	local CS_PAY_CMD = ProtoCS.CS_PAY_CMD

	local MsgID = CS_CMD.CS_CMD_PAY
	local SubMsgID = CS_PAY_CMD.CS_CMD_PAY_DISTRIBUTE_COUPON
	local MsgBody = {
		Cmd = SubMsgID,
		DistributeCoupon = {
			Platform = Platform,
			ProductID = ProductID
		}
	}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
	self:Hide()
end

function RechargingVoucherWinView:OnClickCoinItem(TargetItemView)
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	ItemTipsUtil.ShowTipsByResID(self.VoucherItemID, TargetItemView)
end
-----------------------------------事件E---------------------------------
return RechargingVoucherWinView
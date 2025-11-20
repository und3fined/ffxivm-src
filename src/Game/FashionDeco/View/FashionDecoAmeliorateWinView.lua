---
--- Author: rock
--- DateTime: 2025-09-02 16:27
--- Description: 配饰改良-二级界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local FashionDecoAmeliorateWinVM = require("Game/FashionDeco/VM/FashionDecoAmeliorateWinVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoCS = require ("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local FashionDecoAmeliorateCfg = require("TableCfg/FashionDecoAmeliorateCfg")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local CS_CMD = ProtoCS.CS_CMD
local PERFORM_CMD = ProtoCS.PerformCmd

---@class FashionDecoAmeliorateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnShowTips UFButton
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgItemIcon1 UFImage
---@field ImgItemIcon2 UFImage
---@field ItemIcon UFImage
---@field RichTextTips URichTextBox
---@field TextItemName1 UFTextBlock
---@field TextItemName2 UFTextBlock
---@field TextItemName2_1 UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoAmeliorateWinView = LuaClass(UIView, true)

function FashionDecoAmeliorateWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnShowTips = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgItemIcon1 = nil
	--self.ImgItemIcon2 = nil
	--self.ItemIcon = nil
	--self.RichTextTips = nil
	--self.TextItemName1 = nil
	--self.TextItemName2 = nil
	--self.TextItemName2_1 = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoAmeliorateWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoAmeliorateWinView:OnInit()
	self.ViewModel = FashionDecoAmeliorateWinVM.New()
end

function FashionDecoAmeliorateWinView:OnDestroy()

end

function FashionDecoAmeliorateWinView:OnShow()
	self:InitStaticText()
	
	if self.Params and self.Params.SelectWingId then
		local SelectWingId = self.Params.SelectWingId
		local LastUpgradeWingId = self.Params.LastUpgradeWingId
		if SelectWingId and LastUpgradeWingId then
			self.ViewModel:SetData(SelectWingId, LastUpgradeWingId)
		end
	end
end

function FashionDecoAmeliorateWinView:OnHide()

end

function FashionDecoAmeliorateWinView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.ButtonClose, self.OnCloseBtnOnClicked)
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Btn2Right, self.OnClickedBtnSure)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Ben2Left, self.OnClickedBtnCancel)

	UIUtil.AddOnClickedEvent(self, self.BtnShowTips, self.OnCostItemClick)
end

function FashionDecoAmeliorateWinView:OnRegisterGameEvent()

end

function FashionDecoAmeliorateWinView:OnRegisterBinder()
	local Binders = {
		{ "TextItemName1", UIBinderSetText.New(self, self.TextItemName1) },
		{ "TextItemName2", UIBinderSetText.New(self, self.TextItemName2) },
		{ "TextItemName3", UIBinderSetText.New(self, self.TextItemName2_1) },
		{ "TextNumber", UIBinderSetText.New(self, self.TextQuantity) },

		{ "ImgItemIcon1", UIBinderSetBrushFromAssetPath.New(self, self.ImgItemIcon1) },
		{ "ImgItemIcon2", UIBinderSetBrushFromAssetPath.New(self, self.ImgItemIcon2) },
		{ "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.ItemIcon) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function FashionDecoAmeliorateWinView:InitStaticText()
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(1030032))
	self.RichTextTips:SetText(LSTR(1030029))
	self.Comm2FrameM_UIBP.Btn2Right:SetBtnName(LSTR(1030025))
    self.Comm2FrameM_UIBP.Ben2Left:SetBtnName(LSTR(1030028))
end

function FashionDecoAmeliorateWinView:OnClickedBtnSure()
	local FASHION_DECORTTE_SUB = ProtoCS.Role.FashionDecorate
	local FASHION_DECORTTE_SUB_ID = FASHION_DECORTTE_SUB.CsFashionDecorateCmd

	local MsgID = ProtoCS.CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateImprove
    -- local MsgBody = {
    --     Cmd = SubMsgID,
    --     Improve ={
    --         ID = self.ViewModel.SelectAmeliorateWingId
    --     }
    -- }
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Improve = {ID = self.ViewModel.SelectAmeliorateWingId}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    self:Hide()
end

function FashionDecoAmeliorateWinView:OnClickedBtnCancel()
    self:Hide()
end

--材料物品的tips
function FashionDecoAmeliorateWinView:OnCostItemClick()
	local Cfg = FashionDecoAmeliorateCfg:FindCfgByKey(self.ViewModel.SelectAmeliorateWingId)
	if Cfg then
		ItemTipsUtil.ShowTipsByResID(Cfg.CostID, self.BtnShowTips)
	end
end


return FashionDecoAmeliorateWinView
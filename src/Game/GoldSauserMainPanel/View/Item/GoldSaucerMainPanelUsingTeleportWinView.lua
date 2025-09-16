---
--- Author: Administrator
--- DateTime: 2024-09-09 17:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local ProtoCS = require("Protocol/ProtoCS")

local TeleportTicketItemResID = GoldSauserMainPanelDefine.TeleportTicketItemResID -- 金碟游乐场传送网使用券表格配置id
local LSTR = _G.LSTR

---@class GoldSaucerMainPanelUsingTeleportWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnNormal UFButton
---@field BtnReccmmend UFButton
---@field Comm58Slot CommBackpack58SlotView
---@field TextCancel UFTextBlock
---@field TextConfirm UFTextBlock
---@field TextConsumption UFTextBlock
---@field TextCrystal UFTextBlock
---@field TextHint UFTextBlock
---@field TextQuantity UFTextBlock
---@field WinBG PlayStyleCommFrameSView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSaucerMainPanelUsingTeleportWinView = LuaClass(UIView, true)

function GoldSaucerMainPanelUsingTeleportWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnNormal = nil
	--self.BtnReccmmend = nil
	--self.Comm58Slot = nil
	--self.TextCancel = nil
	--self.TextConfirm = nil
	--self.TextConsumption = nil
	--self.TextCrystal = nil
	--self.TextHint = nil
	--self.TextQuantity = nil
	--self.WinBG = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelUsingTeleportWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm58Slot)
	self:AddSubView(self.WinBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSaucerMainPanelUsingTeleportWinView:InitConstStringInfo()
	self.TextCancel:SetText(LSTR(350048))
	self.TextConfirm:SetText(LSTR(350049))
	self.TextHint:SetText(LSTR(350050))
	self.TextConsumption:SetText(LSTR(350051))
	self.TextCrystal:SetText(LSTR(350052))
end

function GoldSaucerMainPanelUsingTeleportWinView:InitSubViewConstStringInfo()
	self.WinBG:SetTitle(LSTR(350047))
end

function GoldSaucerMainPanelUsingTeleportWinView:OnInit()
	self.TicketItemVM = ItemVM.New()
	self:InitConstStringInfo()
end

function GoldSaucerMainPanelUsingTeleportWinView:OnDestroy()
	self.TicketItemVM = nil
end

function GoldSaucerMainPanelUsingTeleportWinView:OnShow()
	local ItemWidget = self.Comm58Slot
	local TicketItemVM = self.TicketItemVM
	if ItemWidget and TicketItemVM then
		local ItemVM = ItemUtil.CreateItem(TeleportTicketItemResID)
		TicketItemVM:UpdateVM(ItemVM)
		TicketItemVM.NumVisible = false
		--TicketItemVM.ItemLevel = ""
		TicketItemVM.IconChooseVisible = false
		TicketItemVM.IconReceivedVisible = false
		ItemWidget:SetClickButtonCallback(ItemWidget, function(View)
			ItemTipsUtil.ShowTipsByResID(TeleportTicketItemResID, View)
		end)
		ItemWidget:SetItemLevelVisibility(false)
	end

	local ItemNum = _G.BagMgr:GetItemNum(TeleportTicketItemResID) or 0
	self.TextQuantity:SetText(string.format("%s/1", ItemNum))
	self:InitSubViewConstStringInfo()
end

function GoldSaucerMainPanelUsingTeleportWinView:OnHide()

end

function GoldSaucerMainPanelUsingTeleportWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReccmmend, self.OnBtnReccmmendClick)
	UIUtil.AddOnClickedEvent(self, self.BtnNormal, self.OnBtnNormalClick)
	
end

function GoldSaucerMainPanelUsingTeleportWinView:OnRegisterGameEvent()

end

function GoldSaucerMainPanelUsingTeleportWinView:OnRegisterBinder()
	self.Comm58Slot:SetParams({Data = self.TicketItemVM})
end

function GoldSaucerMainPanelUsingTeleportWinView:OnBtnReccmmendClick()
	local Num = _G.BagMgr:GetItemNum(TeleportTicketItemResID)
    if Num == 0 then
        MsgTipsUtil.ShowTips(LSTR(350023))
        return
    end

	local Cfg = ItemCfg:FindCfgByKey(TeleportTicketItemResID)
	if Cfg then
		local GID = _G.BagMgr:GetItemGIDByResID(TeleportTicketItemResID)
		_G.BagMgr:SendMsgUseItemReq(GID, 1, 0, nil, ProtoCS.ITEM_USE_FROM.ITEM_USE_FROM_MAP)
    end
	self:Hide()
end

function GoldSaucerMainPanelUsingTeleportWinView:OnBtnNormalClick()
	self:Hide()
end

return GoldSaucerMainPanelUsingTeleportWinView
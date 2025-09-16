--
-- Author: anypkvcai
-- Date: 2022-04-19 15:43
-- Description:
--



local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local BagMgr = require("Game/Bag/BagMgr")
local ItemUtil = require("Utils/ItemUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local TipsUtil = require("Utils/TipsUtil")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local UUIUtil = _G.UE.UUIUtil
local FVector2D = _G.UE.FVector2D
local LSTR = _G.LSTR

---@class ItemTipsUtil
local ItemTipsUtil = {
}

ItemTipsUtil.GetAccessOffset =
{
[ItemDefine.ItemSource.Bag] = {-2970.0, 0.0},
[ItemDefine.ItemSource.BagDepot] = {-1680.0, 0.0},
[ItemDefine.ItemSource.Shop] = {-2970.0, 0.0},
[ItemDefine.ItemSource.Glamours] = {-2970.0, 0.0},
}

---ShowTipsByGID
---@param GID number @背包里物品的GID
---@param ItemView UWidget
---@param Source number @ItemSource
---@param Index number
---@param Offset table @{X = 0, Y = 0}
---@param HideCallback function
function ItemTipsUtil.ShowTipsByGID(GID, ItemView, Offset, HideCallback)
	local Item = BagMgr:FindItem(GID)

	ItemTipsUtil.ShowTipsByItem(Item, ItemView, Offset, HideCallback)
end

---ShowTipsByResID
---@param ResID number
---@param ItemView UWidget
---@param Offset table @{X = 0, Y = 0}
---@param HideCallback function
---@param OnClickedToGetBtnCallback function 获取按钮点击的回调函数
function ItemTipsUtil.ShowTipsByResID(ResID, ItemView, Offset, HideCallback, CustomBottomMargin, OnClickedToGetBtnCallback)
	local Item = ItemUtil.CreateItem(ResID, 0)
	ItemTipsUtil.ShowTipsByItem(Item, ItemView, Offset, HideCallback, CustomBottomMargin, OnClickedToGetBtnCallback)
end

---ShowTipsByItem
---@param Item common.Item
---@param ItemView UWidget
---@param Source number @ItemSource
---@param Index number
---@param Offset table @{X = 0, Y = 0}
---@param HideCallback function
---@param OnClickedToGetBtnCallback function 获取按钮点击的回调函数
function ItemTipsUtil.ShowTipsByItem(Item, ItemView, Offset, HideCallback, CustomBottomMargin, OnClickedToGetBtnCallback)
	if nil == Item then
		return
	end
	if ItemUtil.ItemIsScore(Item.ResID) then
		ItemTipsUtil.CurrencyTips(Item.ResID, false, ItemView, Offset, HideCallback)
		return
	end

	local ViewID = UIViewID.ItemTips
	local Params = { ItemData = Item, ItemView = ItemView, Offset = Offset, HideCallback = HideCallback, CustomBottomMargin = CustomBottomMargin, OnClickedToGetBtnCallback = OnClickedToGetBtnCallback}
	UIViewMgr:ShowView(ViewID, Params)
end

function ItemTipsUtil.CurrencyTips(ScoreID, IsTopBar, ItemView, Offset, HideCallback, IsHidePanelOwn)
	local ViewID = UIViewID.CurrencyTips
	local Params = { ItemData = ScoreID, IsTopBar = IsTopBar,ItemView = ItemView, Offset = Offset, HideCallback = HideCallback, IsHidePanelOwn = IsHidePanelOwn}
	UIViewMgr:ShowView(ViewID, Params)
end

function ItemTipsUtil.AdjustTopBarTipsPosition(InTipsWidget, InTargetWidget, InOffset)
	if nil == InTipsWidget then
		return
	end
	if nil == InTargetWidget then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	local TargetWidgetSize = UUIUtil.GetLocalSize(InTargetWidget)
	local TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)

	local TargetWidgetPosition = {}

	local TargetAbsolutePos = UIUtil.GetWidgetAbsolutePosition(InTargetWidget)
	local WidgetPixelPosition = UIUtil.AbsoluteToViewport(TargetAbsolutePos)
	TargetWidgetPosition.X = WidgetPixelPosition.X * ScreenSize.X / ViewportSize.X
	TargetWidgetPosition.Y = WidgetPixelPosition.Y * ScreenSize.Y / ViewportSize.Y


	local Position = _G.UE.FVector2D(0, 0)
	local Alignment = FVector2D(0, 0)

	if TargetWidgetPosition.X + TargetWidgetSize.X / 2 <= ScreenSize.X / 2 then
		Position.X = TargetWidgetPosition.X + TargetWidgetSize.X

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X + InOffset.X
		end
	else
		Position.X = TargetWidgetPosition.X
		Alignment.X = 1

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X - InOffset.X
		end
	end

	Position.Y = TargetWidgetPosition.Y + TargetWidgetSize.Y

	if nil ~= InOffset and nil ~= InOffset.Y then
		Position.Y = Position.Y + InOffset.Y
	end

	local BottomMargin = 30

	if ScreenSize.Y - BottomMargin - Position.Y < TipsWidgetSize.Y then
		Position.Y = ScreenSize.Y - BottomMargin - TipsWidgetSize.Y
	end

	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	if nil == Slot then
		return
	end

	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end


function ItemTipsUtil.AdjustTipsPosition(InTipsWidget, InTargetWidget, InOffset, CustomBottomMargin)
	if nil == InTipsWidget then
		return
	end
	if nil == InTargetWidget then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	local TargetWidgetSize = UUIUtil.GetLocalSize(InTargetWidget) 
	local Scale = InTargetWidget.RenderTransform and InTargetWidget.RenderTransform.Scale or 1
	TargetWidgetSize = TargetWidgetSize * Scale
	local TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)

	local TargetAbsolutePos = UIUtil.GetWidgetAbsolutePosition(InTargetWidget)
	local WidgetPixelPosition = UIUtil.AbsoluteToViewport(TargetAbsolutePos)
	WidgetPixelPosition.X = WidgetPixelPosition.X * ScreenSize.X / ViewportSize.X
	WidgetPixelPosition.Y = WidgetPixelPosition.Y * ScreenSize.Y / ViewportSize.Y
	
	
	local Position = _G.UE.FVector2D(0, 0)
	local Alignment = FVector2D(0, 0)
	local Margin = 10
	
	if WidgetPixelPosition.X + TargetWidgetSize.X / 2 <= ScreenSize.X / 2 then
		Position.X = WidgetPixelPosition.X + TargetWidgetSize.X + Margin
		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X + InOffset.X
		end
	else
		Position.X = WidgetPixelPosition.X - Margin
		Alignment.X = 1

		if nil ~= InOffset and nil ~= InOffset.X then
			Position.X = Position.X - InOffset.X
		end
	end
	
	Position.Y = WidgetPixelPosition.Y - Margin

	if nil ~= InOffset and nil ~= InOffset.Y then
		Position.Y = Position.Y + InOffset.Y
	end

	local BottomMargin = CustomBottomMargin or 30

	if ScreenSize.Y - BottomMargin - Position.Y < TipsWidgetSize.Y then
		Position.Y = ScreenSize.Y - BottomMargin - TipsWidgetSize.Y
	end

	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	if nil == Slot then
		return
	end

	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end

function ItemTipsUtil.AdjustTipsPositionByPos(InTipsWidget, WidgetPixelPosition, CustomBottomMargin) 
	if nil == InTipsWidget then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	local TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)

	WidgetPixelPosition.X = WidgetPixelPosition.X * ScreenSize.X / ViewportSize.X
	WidgetPixelPosition.Y = WidgetPixelPosition.Y * ScreenSize.Y / ViewportSize.Y
	
	
	local Position = _G.UE.FVector2D(0, 0)
	local Alignment = FVector2D(0, 0)
	local Margin = 10
	
	if WidgetPixelPosition.X / 2 <= ScreenSize.X / 2 then
		Position.X = WidgetPixelPosition.X  + Margin
		
	else
		Position.X = WidgetPixelPosition.X - Margin
		Alignment.X = 1

	end
	
	Position.Y = WidgetPixelPosition.Y - Margin

	local BottomMargin = CustomBottomMargin or 30

	if ScreenSize.Y - BottomMargin - Position.Y < TipsWidgetSize.Y then
		Position.Y = ScreenSize.Y - BottomMargin - TipsWidgetSize.Y
	end

	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	if nil == Slot then
		return
	end

	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end

function ItemTipsUtil.AdjustSecondaryTipsPosition(SecondaryTipsWidget, ForbidRangeWidget, InTargetWidget)
	if nil == SecondaryTipsWidget then
		return
	end

	if nil == InTargetWidget then
		return
	end

	local Margin = 10

	local TipsWidgetSize = UUIUtil.GetLocalSize(InTargetWidget)
	local TipsWidgetPosition = UIUtil.GetWidgetPosition(InTargetWidget)

	if nil ~= ForbidRangeWidget then
		TipsWidgetSize = UUIUtil.GetLocalSize(ForbidRangeWidget)
		TipsWidgetPosition = UIUtil.GetWidgetPosition(ForbidRangeWidget)
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local TargetWidgetPosition = UIUtil.GetWidgetPosition(InTargetWidget)
	local SecondaryTipWidgetSize = UIUtil.CanvasSlotGetSize(SecondaryTipsWidget)


	local Position = _G.UE.FVector2D(0, 0)
	local Alignment = FVector2D(0, 0)

	if TipsWidgetPosition.X + TipsWidgetSize.X + SecondaryTipWidgetSize.X <= ScreenSize.X then
		Position.X = TipsWidgetPosition.X + TipsWidgetSize.X + Margin
	else
		Position.X = TipsWidgetPosition.X - Margin
		Alignment.X = 1
	end

	Position.Y = TargetWidgetPosition.Y
	local BottomMargin = 12

	if ScreenSize.Y - BottomMargin - Position.Y < SecondaryTipWidgetSize.Y then
		Position.Y = ScreenSize.Y - BottomMargin - SecondaryTipWidgetSize.Y
	end

	local Slot = UIUtil.SlotAsCanvasSlot(SecondaryTipsWidget)
	if nil == Slot then
		return
	end

	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0, 0)
	Anchor.Maximum = _G.UE.FVector2D(0, 0)

	Slot:SetAnchors(Anchor)
	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end

function ItemTipsUtil.HideCurrentItemTips()
	if UIViewMgr:IsViewVisible(UIViewID.ItemTips) then
		UIViewMgr:HideView(UIViewID.ItemTips)
	end

	if UIViewMgr:IsViewVisible(UIViewID.BagItemTips) then
		UIViewMgr:HideView(UIViewID.BagItemTips)
	end
end


function ItemTipsUtil.OnClickedBindBtn(ItemTipsVM, Params)
	if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
		if ItemTipsVM.ShowBindTips then
			UIViewMgr:HideView(UIViewID.ItemTipsStatus)
			return
		end
	else
		UIViewMgr:ShowView(UIViewID.ItemTipsStatus, Params)
	end

	ItemTipsVM:SetShowOnlyTips(false)
	ItemTipsVM:SetShowImproveTips(false)
	ItemTipsVM:SetShowBindTips(true)
end

function ItemTipsUtil.OnClickedImproveBtn(ItemTipsVM, Params)
	if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
		if ItemTipsVM.ShowBindTips then
			UIViewMgr:HideView(UIViewID.ItemTipsStatus)
			return
		end
	else
		UIViewMgr:ShowView(UIViewID.ItemTipsStatus, Params)
	end

	ItemTipsVM:SetShowOnlyTips(false)
	ItemTipsVM:SetShowBindTips(false)
	ItemTipsVM:SetShowImproveTips(true)
end

function ItemTipsUtil.OnClickedOnlyBtn(ItemTipsVM, Params)
	if UIViewMgr:IsViewVisible(UIViewID.ItemTipsStatus) then
		if ItemTipsVM.ShowOnlyTips then
			UIViewMgr:HideView(UIViewID.ItemTipsStatus)
			return
		end
	else
		UIViewMgr:ShowView(UIViewID.ItemTipsStatus, Params)
	end

	ItemTipsVM:SetShowBindTips(false)
	ItemTipsVM:SetShowImproveTips(false)
	ItemTipsVM:SetShowOnlyTips(true)
end

function ItemTipsUtil.OnClickedToGetBtn(Params)
	if UIViewMgr:IsViewVisible(UIViewID.CommGetWayTipsView) then
		UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
	else
		local Offset = Params.Offset or _G.UE.FVector2D(0,0)
		local Alignment = Params.Alignment or _G.UE.FVector2D(0,0)
		TipsUtil.ShowGetWayTips(Params.ViewModel,  Params.ForbidRangeWidget, Params.InTagetView, Offset, Alignment, Params.HidePopUpBG, Params.ClickedParams, Params.ParentViewID, Params.AdjustTips)
	end

end

function ItemTipsUtil.GetItemCfgBuyPrice(Cfg)
	if Cfg == nil then
		return LSTR(1020006), false
	end

	if Cfg.IsMarketable and Cfg.GoldCoinPrice > 0 then
        return ItemUtil.GetItemNumText(Cfg.GoldCoinPrice), true
    end

	return LSTR(1020006),false
end

function ItemTipsUtil.GetItemCfgSellPrice(Cfg)
	if Cfg == nil then
		return LSTR(1020007), false
	end

	if Cfg.IsRecoverable and Cfg.RecoverNum > 0 then
        return ItemUtil.GetItemNumText(Cfg.RecoverNum), true
    end

	return LSTR(1020007), false
end


return ItemTipsUtil
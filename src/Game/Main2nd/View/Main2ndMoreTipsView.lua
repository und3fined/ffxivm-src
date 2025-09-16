---
--- Author: saintzhao
--- DateTime: 2024-11-28 13:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local OperationUtil = require("Utils/OperationUtil")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")

---@class Main2ndMoreTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TableViewEntrance UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndMoreTipsView = LuaClass(UIView, true)

local TableItems
local MoreMenuType = Main2ndPanelDefine.MoreMenuType

function Main2ndMoreTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.TableViewEntrance = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndMoreTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndMoreTipsView:OnInit()
	TableItems = {}
	local MenuItems = OperationUtil.GetOperationMenuItems()
	for _, Info in ipairs(MenuItems) do
		table.insert(TableItems, Info)
	end
	_G.FLOG_INFO("Main2ndMoreTipsView:OnInit, TableItems:%d", #TableItems)
	self.TableViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEntrance)
end

function Main2ndMoreTipsView:OnDestroy()
	TableItems = nil
end

function Main2ndMoreTipsView:OnShow()
	self.TableViewMenuAdapter:UpdateAll(TableItems)

	--local Params = self.Params
	--local Slot = UIUtil.SlotAsCanvasSlot(self.PanelTips)
	--local ItemsNum = #TableItems
	--if nil ~= Params and nil ~= Slot and ItemsNum > 0 then
	--	local Offset = 16 * 1
	--	local ScreenSize = UIUtil.GetScreenSize()
	--	local ViewportSize = UIUtil.GetViewportSize()
	--	local TargetAbsolutePos = UIUtil.GetWidgetAbsolutePosition(Params.InWidget)
	--	--_G.FLOG_INFO("Main2ndMoreTipsView:OnShow, EntrySpacing:%f", Params.EntrySpacing)
	--
	--	-- local InWidgetSize = UIUtil.GetWidgetSize(Params.InWidget)
	--	-- _G.FLOG_INFO("Main2ndMoreTipsView:OnShow, ScreenSize:(%f, %f), ViewportSize:(%f, %f), TargetAbsolutePos:(%f, %f), InWidgetSize:(%f, %f)",
	--	-- 	ScreenSize.X, ScreenSize.Y, ViewportSize.X, ViewportSize.Y,
	--	-- 	TargetAbsolutePos.X, TargetAbsolutePos.Y, InWidgetSize.X, InWidgetSize.Y)
	--
	--	-- local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute( _G.UE.FVector2D(0, 0), false)
	--	-- local TipsAbsolute = UIUtil.AbsoluteToLocal(self.PanelTips, TargetAbsolutePos)
	--	-- FLOG_INFO("Main2ndMoreTipsView:OnShow, WindowAbsolute:(%f, %f), TipsAbsolute:(%f, %f)",
	--	-- WindowAbsolute.X, WindowAbsolute.Y, TipsAbsolute.X, TipsAbsolute.Y)
	--
	--	-- TargetAbsolutePos.X = (TargetAbsolutePos.X - (InWidgetSize.X * ItemsNum + 3 * (ItemsNum + 1) + Offset)) * ScreenSize.X / ViewportSize.X
	--	-- TargetAbsolutePos.Y = (TargetAbsolutePos.Y - (InWidgetSize.Y + Offset)) * ScreenSize.Y / ViewportSize.Y
	--
	--	-- TargetAbsolutePos.X = (TargetAbsolutePos.X * ScreenSize.X / ViewportSize.X - (InWidgetSize.X + 3) * ItemsNum - Offset)
	--	-- local ScaleY = ScreenSize.Y / ViewportSize.Y
	--	-- local PositionY = TargetAbsolutePos.Y * ScaleY
	--	-- if PositionY + InWidgetSize.Y * ScaleY > ScreenSize.Y then
	--	-- 	PositionY = ScreenSize.Y - InWidgetSize.Y * ScaleY
	--	-- end
	--	-- TargetAbsolutePos.Y = PositionY + Offset * ScaleY
	--	--FLOG_INFO("Main2ndMoreTipsView:OnShow, TargetAbsolutePos:(%f, %f)", TargetAbsolutePos.X, TargetAbsolutePos.Y)
	--
	--
	--	local CurWidgetSize = UIUtil.GetWidgetSize(self.TableViewEntrance)
	--	-- _G.FLOG_INFO("Main2ndMoreTipsView:OnShow, ScreenSize:(%f, %f), ViewportSize:(%f, %f), TargetAbsolutePos:(%f, %f), CurWidgetSize:(%f, %f)",
	--	-- 	ScreenSize.X, ScreenSize.Y, ViewportSize.X, ViewportSize.Y,
	--	-- 	TargetAbsolutePos.X, TargetAbsolutePos.Y, CurWidgetSize.X, CurWidgetSize.Y)
	--	TargetAbsolutePos.X = TargetAbsolutePos.X * ScreenSize.X / ViewportSize.X  - Offset - CurWidgetSize.X
	--	TargetAbsolutePos.Y = ScreenSize.Y - CurWidgetSize.Y - Offset
	--
	--	Slot:SetPosition(TargetAbsolutePos)
	--end

	self.PopUpBG:SetCallback(self, self.OnClickedHidePopUpBg)
end

function Main2ndMoreTipsView:OnHide()

end

function Main2ndMoreTipsView:OnRegisterUIEvent()

end

function Main2ndMoreTipsView:OnRegisterGameEvent()

end

function Main2ndMoreTipsView:OnRegisterBinder()

end

function Main2ndMoreTipsView:OnClickedHidePopUpBg()
	self:Hide()
end

return Main2ndMoreTipsView
---
--- Author: v_vvxinchen
--- DateTime: 2025-07-16 14:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

---@class OpsSkiTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelGetWayTips UFCanvasPanel
---@field TableViewList UTableView
---@field TextGetWay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkiTipsView = LuaClass(UIView, true)

function OpsSkiTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelGetWayTips = nil
	--self.TableViewList = nil
	--self.TextGetWay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkiTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsSkiTipsView:OnInit()
	self.TextGetWay:SetText(_G.LSTR(100165))--"套餐内容"
	self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
	self.CommonPopUpBG:SetCallback(self, self.OnClickedCallback)
end

function OpsSkiTipsView:OnDestroy()

end

function OpsSkiTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local InTagetView = Params.InTagetView
	local ForbidRangeWidget = Params.ForbidRangeWidget
	if InTagetView ~= nil then
		ItemTipsUtil.AdjustSecondaryTipsPosition(self.PanelGetWayTips, ForbidRangeWidget, InTagetView)
		if ForbidRangeWidget == nil then
			if Params.AdjustTips == nil then
				local Pos = UIUtil.CanvasSlotGetPosition(self.PanelGetWayTips)
				UIUtil.CanvasSlotSetPosition(self.PanelGetWayTips, Pos + Params.Offset)
				UIUtil.CanvasSlotSetAlignment(self.PanelGetWayTips, Params.Alignment)
			else
				-- 延迟才能获取大小
				TipsUtil.AdjustTipsPosition(self.PanelGetWayTips, InTagetView, Params.Offset, Params.Alignment)
			end
		end
	end
	local DataList = Params.DataList or {}
	self.TableViewListAdapter:UpdateAll(DataList)
end

function OpsSkiTipsView:OnHide()
	UIViewMgr:HideView(UIViewID.ItemTips)
end

function OpsSkiTipsView:OnClickedCallback()
	UIViewMgr:HideView(UIViewID.CommGetWayTipsView)
end

function OpsSkiTipsView:OnRegisterUIEvent()

end

function OpsSkiTipsView:OnRegisterGameEvent()

end

function OpsSkiTipsView:OnRegisterBinder()

end
return OpsSkiTipsView
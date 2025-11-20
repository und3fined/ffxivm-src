---
--- Author: Administrator
--- DateTime: 2025-04-07 21:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class CommonBorderRedDotPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelBorderRedDot UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonBorderRedDotPanelView = LuaClass(UIView, true)

function CommonBorderRedDotPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelBorderRedDot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonBorderRedDotPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonBorderRedDotPanelView:OnInit()
	self.BorderRedDotMap = {}
	self.ExternalBorderRedDotMap = {}
end

function CommonBorderRedDotPanelView:OnDestroy()

end

function CommonBorderRedDotPanelView:OnShow()

end

function CommonBorderRedDotPanelView:OnHide()

end

function CommonBorderRedDotPanelView:OnRegisterUIEvent()

end

function CommonBorderRedDotPanelView:OnRegisterGameEvent()

end

function CommonBorderRedDotPanelView:OnRegisterBinder()

end

function CommonBorderRedDotPanelView:HideRedDotByListKey(ListKey)
	if self.BorderRedDotMap and self.BorderRedDotMap[ListKey] then
		for _, Type in pairs(RedDotDefine.ListRedDotPosType) do
			if self.BorderRedDotMap[ListKey][Type] then
				self:DelBorderRedDotView(self.BorderRedDotMap[ListKey][Type])
			end
		end
		self.BorderRedDotMap[ListKey] = nil
	end
end

function CommonBorderRedDotPanelView:UpdateRedDotByListKey(ListKey)
	local BorderRedDotData = _G.RedDotMgr:GetListRedDotDataByListKey(ListKey)
	if BorderRedDotData and BorderRedDotData.TriggerView then
		local TriggerView = BorderRedDotData.TriggerView
		local TriggerWidget = BorderRedDotData.TriggerWidget
		if TriggerView.Object:IsValid() then
			local ListRedDotType = BorderRedDotData.ListRedDotType
			local MiniType = ListRedDotType.Mini
			local MaxType = ListRedDotType.Max
			if BorderRedDotData.MiniShow then
				self:AddBorderRedDotView(ListKey, TriggerWidget, BorderRedDotData.Offset, MiniType)
			else
				if self.BorderRedDotMap[ListKey] and self.BorderRedDotMap[ListKey][MiniType] then
					self:DelBorderRedDotView(self.BorderRedDotMap[ListKey][MiniType])
					self.BorderRedDotMap[ListKey][MiniType] = nil
				end
			end
			if BorderRedDotData.MaxShow then
				self:AddBorderRedDotView(ListKey, TriggerWidget, BorderRedDotData.Offset, MaxType)
			else
				if self.BorderRedDotMap[ListKey] and self.BorderRedDotMap[ListKey][MaxType] then
					self:DelBorderRedDotView(self.BorderRedDotMap[ListKey][MaxType])
					self.BorderRedDotMap[ListKey][MaxType] = nil
				end
			end
		else
			self:HideRedDotByListKey(ListKey)
		end
	end
end

function CommonBorderRedDotPanelView:AddBorderRedDotView(ListKey, TriggerWidget, Offset, Type)
	if self.BorderRedDotMap == nil then
		self.BorderRedDotMap = {}
	end
	if self.BorderRedDotMap[ListKey] == nil then
		self.BorderRedDotMap[ListKey] = {}
	end
	if self.BorderRedDotMap[ListKey][Type] then
		---已有红点view
		return
	end
    self.BorderRedDotMap[ListKey][Type] = self:CreateBorderRedDotView(ListKey, TriggerWidget, Offset, Type)
end


function CommonBorderRedDotPanelView:AddBorderRedDotViewExternalInterface(ListName, TriggerWidget, Offset, Type)
	if self.ExternalBorderRedDotMap == nil then
		self.ExternalBorderRedDotMap = {}
	end
	if self.ExternalBorderRedDotMap[ListName] == nil then
		self.ExternalBorderRedDotMap[ListName] = {}
	end
	if self.ExternalBorderRedDotMap[ListName][Type] then
		---已有红点view
		return
	end
    self.ExternalBorderRedDotMap[ListName][Type] = self:CreateBorderRedDotView(ListName, TriggerWidget, Offset, Type)
end

function CommonBorderRedDotPanelView:CreateBorderRedDotView(Key, TriggerWidget, Offset, Type)
	local PanelWidget = self.PanelBorderRedDot
	local BorderRedDotPath = RedDotDefine.BorderRedDotPath
    local BorderRedDotView = UIViewMgr:CreateViewByName(BorderRedDotPath, nil, self, true, true)
    PanelWidget:AddChildToCanvas(BorderRedDotView)
    local Anchor = _G.UE.FAnchors()
    Anchor.Minimum = _G.UE.FVector2D(0, 0)
    Anchor.Maximum = _G.UE.FVector2D(1, 1)
    UIUtil.CanvasSlotSetAnchors(BorderRedDotView, Anchor)
    UIUtil.CanvasSlotSetSize(BorderRedDotView, _G.UE.FVector2D(0, 0))
	BorderRedDotView:SetPos(TriggerWidget, Offset, Type)
    return BorderRedDotView
end


function CommonBorderRedDotPanelView:DelBorderRedDotView(View)
    local PanelWidget = self.PanelBorderRedDot
    if View then
        PanelWidget:RemoveChild(View)
        UIViewMgr:RecycleView(View)
    end
end

function CommonBorderRedDotPanelView:HideAllRedDotExternalInterface(ListName)
	if self.ExternalBorderRedDotMap and self.ExternalBorderRedDotMap[ListName] then
		for _, Type in pairs(RedDotDefine.ListRedDotPosType) do
			if self.ExternalBorderRedDotMap[ListName][Type] then
				self:DelBorderRedDotView(self.ExternalBorderRedDotMap[ListName][Type])
			end
		end
		self.ExternalBorderRedDotMap[ListName] = nil
	end
end

function CommonBorderRedDotPanelView:HideRedDotExternalInterface(ListName, Type)
	if self.ExternalBorderRedDotMap and self.ExternalBorderRedDotMap[ListName] then
		if self.ExternalBorderRedDotMap[ListName][Type] then
			self:DelBorderRedDotView(self.ExternalBorderRedDotMap[ListName][Type])
		end
		self.ExternalBorderRedDotMap[ListName][Type] = nil
	end
end

return CommonBorderRedDotPanelView
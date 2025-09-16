---
--- Author: Administrator
--- DateTime: 2025-02-25 15:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local EventID = _G.EventID

---@class OpsAcitivitySeasonPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActvityPanel UFCanvasPanel
---@field CloseBtn CommonCloseBtnView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsAcitivitySeasonPanelView = LuaClass(UIView, true)

function OpsAcitivitySeasonPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActvityPanel = nil
	--self.CloseBtn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsAcitivitySeasonPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsAcitivitySeasonPanelView:OnInit()
	
end

function OpsAcitivitySeasonPanelView:OnDestroy()

end

function OpsAcitivitySeasonPanelView:OnShow()
	if self.Params == nil then
		return
	end
	if self.Params.ActivityData == nil then
		return
	end
	_G.OpsSeasonActivityMgr:SendQuerySeasonActivitys()
	self:SetSeasonActivity(self.Params.ActivityData)
end

function OpsAcitivitySeasonPanelView:OnHide()
	self:HideSeasonActivity()
end

function OpsAcitivitySeasonPanelView:OnRegisterUIEvent()

end

function OpsAcitivitySeasonPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapFollowAdd, self.Hide)
	self:RegisterGameEvent(EventID.CrystalTransferReq, self.Hide)
end

function OpsAcitivitySeasonPanelView:OnRegisterBinder()

end

function OpsAcitivitySeasonPanelView:SetSeasonActivity(ActivityData)
	local function OnLoadComplete(Widget)
		if _G.UE.UCommonUtil.IsObjectValid(self.ActvityPanel) then
			self:HideSeasonActivity()
			if Widget then
				self.ActvityPanel:AddChildToCanvas(Widget)
				local Anchor = _G.UE.FAnchors()
				Anchor.Minimum = _G.UE.FVector2D(0, 0)
				Anchor.Maximum = _G.UE.FVector2D(1, 1)
				UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
				UIUtil.CanvasSlotSetPosition(Widget, _G.UE.FVector2D(0, 0))
				local Offset = UIUtil.CanvasSlotGetOffsets(self.ActvityPanel)
				UIUtil.CanvasSlotSetOffsets(Widget, Offset)
				UIUtil.CanvasSlotSetAlignment(Widget, _G.UE.FVector2D(0, 0))
				self:AddSubView(Widget)
				self.SeasonActivtiyWidget = Widget
			end
		else
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end

	WidgetPoolMgr:CreateWidgetAsyncByName(ActivityData:GetBPName(), nil, OnLoadComplete, true, true, ActivityData)
	
end

function OpsAcitivitySeasonPanelView:HideSeasonActivity()
	if self.SeasonActivtiyWidget == nil then
		return
	end
	
	self.SeasonActivtiyWidget:HideView()
	self:RemoveSubView(self.SeasonActivtiyWidget)
	self.ActvityPanel:ClearChildren()
	WidgetPoolMgr:RecycleWidget(self.SeasonActivtiyWidget)
	self.SeasonActivtiyWidget = nil
end

return OpsAcitivitySeasonPanelView
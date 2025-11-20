---
--- Author: Administrator
--- DateTime: 2025-06-16 11:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local ProtoRes = require("Protocol/ProtoRes")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
---@class OpsCommMoneySlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommMoneyBar CommMoneyBarView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCommMoneySlotView = LuaClass(UIView, true)

function OpsCommMoneySlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommMoneyBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCommMoneySlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommMoneyBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCommMoneySlotView:OnInit()

end

function OpsCommMoneySlotView:OnDestroy()

end

function OpsCommMoneySlotView:OnShow()
	if self.ShowMysteryMoneySlot then
		self:SetOpsMysteryShopCommMoney()
		return
	end
	if self.Params == nil or self.Params.NodeList == nil then
		return
	end
	local MoneyNode, MoneyNodeCfg = self:GetMoneyCommonNodeInfo()
	UIUtil.SetIsVisible(self.CommMoneyBar, MoneyNode ~= nil and MoneyNodeCfg ~= nil)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money1, false)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money2, false)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money3, false)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money4, false)

	if MoneyNode and  MoneyNodeCfg then
		local Index = 1
		for i = 2, MoneyNodeCfg.ParamNum, 2 do
			local MoneyID = MoneyNodeCfg.Params[i]
			local UIViewID = MoneyNodeCfg.Params[i+1] or 0
			local bLinkToView = UIViewID > 0
			if MoneyID > 0 then
				local NodeName = string.format("Money%d", Index)
				if self.CommMoneyBar[NodeName] then
					self.CommMoneyBar[NodeName]:UpdateView(MoneyID, bLinkToView, UIViewID, true)
					UIUtil.SetIsVisible(self.CommMoneyBar[NodeName], true)
				end
			end
			Index = Index + 1
		end
	end
end

function OpsCommMoneySlotView:GetMoneyCommonNodeInfo()
	if self.Params == nil then
		return
	end

    local NodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypePureShow)
	for _, Node in ipairs(NodeList) do
		local NodeID  = Node.Head.NodeID
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
		if NodeCfg.Params[1] == OpsActivityDefine.ActivityPureShowType.ActivityPureShowMoney then
			return Node, NodeCfg
		end
	end

    return
end

function OpsCommMoneySlotView:SetOpsMysteryShopCommMoney()
	UIUtil.SetIsVisible(self.CommMoneyBar.Money1, true)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money2, true)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money3, false)
	UIUtil.SetIsVisible(self.CommMoneyBar.Money4, false)
	self.CommMoneyBar.Money1:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, _G.UIViewID.RechargingMainPanel, true)
	self.CommMoneyBar.Money2:UpdateView(SCORE_TYPE.SCORE_TYPE_GOLD_CODE, false, nil, true)
end


function OpsCommMoneySlotView:OnHide()

end

function OpsCommMoneySlotView:OnRegisterUIEvent()

end

function OpsCommMoneySlotView:OnRegisterGameEvent()

end

function OpsCommMoneySlotView:OnRegisterBinder()

end

return OpsCommMoneySlotView
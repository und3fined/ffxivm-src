---
--- Author: v_zanchang
--- DateTime: 2023-02-15 10:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIViewMgr = require("UI/UIViewMgr")
local CommonUtil = require("Utils/CommonUtil")
local FLOG_ERROR = _G.FLOG_ERROR

---@class CommDropTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CanvasPanel_63 UCanvasPanel
---@field CommDropItem_UIBP_1 CommDropItemView
---@field CommDropItem_UIBP_2 CommDropItemView
---@field CommDropItem_UIBP_3 CommDropItemView
---@field CommDropItem_UIBP_4 CommDropItemView
---@field CommDropItem_UIBP_5 CommDropItemView
---@field FCanvasPanel UFCanvasPanel
---@field FCanvasPanel_31 UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommDropTipsView = LuaClass(UIView, true)

local DropTable = {}
local LastTickTime = 0
local TimeID = 0
local DisappearPosition = 400
local DropTime = 4

function CommDropTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CanvasPanel_63 = nil
	--self.CommDropItem_UIBP_1 = nil
	--self.CommDropItem_UIBP_2 = nil
	--self.CommDropItem_UIBP_3 = nil
	--self.CommDropItem_UIBP_4 = nil
	--self.CommDropItem_UIBP_5 = nil
	--self.FCanvasPanel = nil
	--self.FCanvasPanel_31 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommDropTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommDropTipsView:OnInit()
	self.ItemLayout = UIUtil.CanvasSlotGetLayout(self.CommDropItem_UIBP)
	self.FadePosition = 300
end

function CommDropTipsView:OnDestroy()

end

function CommDropTipsView:OnShow()

end

function CommDropTipsView:OnHide()
	_G.LootMgr:CancelWait()
	self:ClearItem()
end

function CommDropTipsView:ClearItem()
	local ItemLen = self.FCanvasPanel:GetChildrenCount()
	for i = 1, ItemLen do
		local View = self.FCanvasPanel:GetChildAt(i)
		if View then
			self.FCanvasPanel:RemoveChild(View)
			UIViewMgr:RecycleView(View)
		end
	end
end

function CommDropTipsView:OnGameEventPWorldExit()
	_G.LootMgr:CancelWait()
	self:ClearItem()
end

function CommDropTipsView:OnRegisterUIEvent()

end

function CommDropTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.DealLootItem, self.AddLootItem)
	self:RegisterGameEvent(_G.EventID.DealLootList, self.AddLootList)
	self:RegisterGameEvent(_G.EventID.PWorldExit, self.OnGameEventPWorldExit)
end

function CommDropTipsView:OnRegisterBinder()

end

function CommDropTipsView:AddLootItem(LootItem)
	if LootItem == nil then
		return
	end
	
	local SingleItemView = UIViewMgr:CloneView(self.CommDropItem_UIBP, self, true)--UIViewMgr:CreateViewByName("Common/Tips/CommDropItem_UIBP", nil, self, true, false)
	if SingleItemView == nil or not CommonUtil.IsObjectValid(SingleItemView) then
		return
	end
	self.FCanvasPanel:AddChild(SingleItemView)
	local Params = { LootItem = LootItem, View = self}
	SingleItemView:ShowView(Params)
	-- View.IsShowView = false
	local Drop = {}
	Drop.View = SingleItemView
	Drop.Position = 0
	Drop.DropVelocity = DisappearPosition / DropTime
	Drop.Index = LootItem.Index
	Drop.ExperienceTime = 0
	table.insert(DropTable, Drop)
	SingleItemView:PlayDropAni(self.AnimDrop)

	if TimeID == 0 then
		LastTickTime = TimeUtil.GetLocalTimeMS()
		TimeID = self:RegisterTimer(self.PlayDropAnimationTimer, 0, 0, 0)
		UIUtil.SetIsVisible(SingleItemView.Object, true)
	end

end

function CommDropTipsView:AddLootList(LootList)
	--self:UpdateDropVelocity()
	for Index, LootItem in ipairs(LootList) do
		local View = UIViewMgr:CloneView(self.CommDropItem_UIBP, self, true)--UIViewMgr:CreateViewByName("Common/Tips/CommDropItem_UIBP", nil, self, true, false)
		if View == nil or not CommonUtil.IsObjectValid(View) then
			FLOG_ERROR("CommDropTipsView.AddLootList CloneView Error")
			return
		end
		self.FCanvasPanel:AddChild(View)
		local Drop = {}
		Drop.View = View
		--Drop.Position = 0
		--Drop.DropVelocity = DisappearPosition / DropTime
		Drop.Index = LootItem.Index
		--Drop.ExperienceTime = 0
		local Params = { LootItem = LootItem, View = self, OnItemAnimationFinished = self.OnItemAnimationFinished }
		View:ShowView(Params)
		--Drop.ExperienceTime = (Index - 1) * 75.0 / Drop.DropVelocity
		table.insert(DropTable, Drop)
		-- print("AddIndex = " .. tostring(#DropTable))
		print(Index)
		--View.Object:SetRenderTranslation(_G.UE.FVector2D(0, Index - 1 * 70))
		View:PlayDropAni(self.AnimDrop)

		if TimeID == 0 then
			LastTickTime = TimeUtil.GetLocalTimeMS()
			TimeID = self:RegisterTimer(self.PlayDropAnimationTimer,0,0,0)
			UIUtil.SetIsVisible(View.Object, true)
		end
	end
end

function CommDropTipsView:UpdateDropVelocity()
	if #DropTable > 0 then
		local DropOverLapNum = 0
		--local TopDrop = DropTable[#DropTable]
		local BaseVelocity = DisappearPosition / DropTime
		-- if TopDrop.ExperienceTime <= 0.5 then
		for Index, Drop in ipairs(DropTable) do
			DropOverLapNum = DropOverLapNum + 1
			-- Drop.DropVelocity = Drop.DropVelocity * 1.1
			local FirstDropIndex = #DropTable - Index + 1
			Drop.DropVelocity = BaseVelocity * (1.08 + FirstDropIndex * 0.35) --根据掉落数量增加掉落速率
			if Drop.DropVelocity > (DisappearPosition / DropTime) * 2.5 then --不能大于基本速度的2.5倍
				Drop.DropVelocity = (DisappearPosition / DropTime) * 2.5
			end
			if Drop.ExperienceTime <= 0.5 then
				Drop.ExperienceTime = Drop.ExperienceTime + (0.1 * FirstDropIndex)
			end
			-- print(tostring(Index) .. "->>"..tostring(Drop.DropVelocity))
		end
		-- end
		-- local VelAddCoefficient = 
		-- if TopDrop.ExperienceTime <= 0.5 then
		-- 	for Index, Drop in ipairs(DropTable) do
		-- 		Drop.DropVelocity = Drop.DropVelocity * 1.1 * Index
		-- 	end
		-- end
	end
end

function CommDropTipsView:PlayDropAnimationTimer(Params)
	if #DropTable == 0 then
		self:UnRegisterTimer(TimeID)
		TimeID = 0
		return
	end
	local CurrentTickTime = TimeUtil.GetLocalTimeMS()
	if LastTickTime == 0 then
		LastTickTime = CurrentTickTime
	end

	for Index, Drop in ipairs(DropTable) do
		table.remove(DropTable, Index)
		local DorpTimeID
		local function DelayGo2()
			self:PlayDropAnimation(Drop.View)
			self:UnRegisterTimer(DorpTimeID)
		end

		DorpTimeID = self:RegisterTimer(DelayGo2, 1, 0, 1)
		--self.DelayTimerID2 = _G.TimerMgr:AddTimer(nil, DelayGo2, 1)
		-- if Drop.Position >= DisappearPosition then
		-- 	table.remove(DropTable, Index)
		-- 	-- print("RemoveIndex = " .. tostring(#DropTable))
		-- end
	end
	-- for _, Drop in ipairs(DropTable) do
	-- 	local DropPosition = Drop.ExperienceTime * Drop.DropVelocity --掉落速度*掉落时间 = 掉落位置
	-- 	Drop.Position = DropPosition
	-- 	self:PlayDropAnimation(Drop.View, DropPosition)
	-- 	Drop.ExperienceTime = Drop.ExperienceTime + (CurrentTickTime - LastTickTime) / 1000
	-- 	-- print("CommDropTipsView->" .. tostring(Drop.Index).. ",DropPosition="..(tostring(Drop.DropVelocity )))
	-- 	-- print("CommDropTipsView->" .. tostring(Drop.Index).. "="..(tostring(Drop.ExperienceTime)))
	-- end
	LastTickTime = CurrentTickTime
end

function CommDropTipsView:PlayDropAnimation(View, Position)
	-- View.DropItem01:SetRenderOpacity(1)
	-- if Position >= self.FadePosition then
	-- 	local Opacity = 1 - (Position - self.FadePosition) / (DisappearPosition - self.FadePosition)
	-- 	if Opacity >= 0 then
	-- 		View.DropItem01:SetRenderOpacity(Opacity)
	-- 	else
	-- 		View.DropItem01:SetRenderOpacity(0)
	-- 	end
	-- end

	-- View.Object:SetRenderTranslation(_G.UE.FVector2D(0, Position))
	-- if Position >= DisappearPosition then
	-- 	self:OnDropAnimationFinished(View)
	-- end
	self:OnDropAnimationFinished(View)
end

function CommDropTipsView:OnDropAnimationFinished(View)
	if self.FCanvasPanel == nil or View == nil then
		return
	end

	if CommonUtil.IsObjectValid(View) then
		self.FCanvasPanel:RemoveChild(View)
		UIViewMgr:RecycleView(View)
	end
	-- for Index, Drop in ipairs(DropTable) do
	-- 	if Drop.View == View then
	-- 		table.remove(DropTable, Index)
	-- 		break
	-- 	end
	-- end
	-- print("self.RemainlimitNum++ " .. tostring(self.RemainlimitNum ))
end

return CommDropTipsView
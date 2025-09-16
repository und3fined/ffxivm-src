---
--- Author: chriswang
--- DateTime: 2023-04-27 15:04
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local EventID = require("Define/EventID")

---@class NPCUsedItemSingBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ItemSlot CommBackpackSlotView
---@field ProgressSingBar UProgressBar
---@field SingBarName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCUsedItemSingBarView = LuaClass(UIView, true)

function NPCUsedItemSingBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ItemSlot = nil
	--self.ProgressSingBar = nil
	--self.SingBarName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCUsedItemSingBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ItemSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCUsedItemSingBarView:OnInit()
	self.ViewListToSetInvisible = {}
	local Config = self:GetConfig()
	if nil ~= Config and nil ~= Config.ListToSetInvisible then
		for _, ViewID in ipairs(Config.ListToSetInvisible) do
			table.insert(self.ViewListToSetInvisible, ViewID)
		end
	end
end

function NPCUsedItemSingBarView:OnDestroy()

end

function NPCUsedItemSingBarView:OnShow()
	local Params = self.Params
	if nil == Params then
		UIUtil.SetIsVisible(self.ItemSlot, false)
		return
	end
	_G.InteractiveMgr:SetMajorIsinging(true)
	local Cfg = ItemCfg:FindCfgByKey(Params.ResID)
	if Cfg then
		UIUtil.SetIsVisible(self.ItemSlot, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ItemSlot.FImg_Icon, UIUtil.GetIconPath(Cfg.IconID))
	else
		UIUtil.SetIsVisible(self.ItemSlot, false)
	end

	if nil ~= Params.HideOtherUIType then
		if Params.HideOtherUIType == "1" then
			local IsExist = false
			for _, ViewID in ipairs(self.ViewListToSetInvisible) do
				if ViewID == _G.UIViewID.MainPanel then
					IsExist = true
					break
				end
			end
			if not IsExist then
				table.insert(self.ViewListToSetInvisible, _G.UIViewID.MainPanel)
			end
		else
			self:RemoveMainPanelFromList()
		end
	end
end

function NPCUsedItemSingBarView:RemoveMainPanelFromList()
	for Index, ViewID in ipairs(self.ViewListToSetInvisible) do
		if ViewID == _G.UIViewID.MainPanel then
			table.remove(self.ViewListToSetInvisible, Index)
			break
		end
	end
end

function NPCUsedItemSingBarView:GetViewListToSetInvisible()
	return self.ViewListToSetInvisible
end

function NPCUsedItemSingBarView:OnHide()
	self:CloseSingTimer()
	_G.InteractiveMgr:SetMajorIsinging(false)
	self:RemoveMainPanelFromList()
end

function NPCUsedItemSingBarView:CloseSingTimer()
	if self.SingTimerID then
		TimerMgr:CancelTimer(self.SingTimerID)
		self.SingTimerID = nil
	end
end

function NPCUsedItemSingBarView:OnRegisterUIEvent()

end

function NPCUsedItemSingBarView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorSingBarBreak, self.OnMajorSingBarBreak)
end

function NPCUsedItemSingBarView:OnRegisterBinder()

end

function NPCUsedItemSingBarView:UpdateProcessBar()
	local PassTime = TimeUtil.GetLocalTimeMS() - self.BeginTime
	if PassTime >= self.SingTime then
		self:CloseSingTimer()
		self:Hide()

		FLOG_INFO("NPCUsedItemSingBarView:UpdateProcessBar, OnMajorSingOver: " .. tostring(PassTime / self.SingTime) .. " time: " .. TimeUtil.GetLocalTimeMS())

		--正常结束
		_G.SingBarMgr:OnMajorSingOver(MajorUtil.GetMajorEntityID(), false)
		return
	end

	local Percent = PassTime / self.SingTime
	if Percent > 0.99 then
		Percent = 1
	end

	-- FLOG_INFO("SingBar percent: " .. tostring(Percent) .. " time: " .. TimeUtil.GetLocalTimeMS() .. " passTime: " .. PassTime .. "Sing: " .. self.SingTime)
	self.ProgressSingBar:SetPercent(Percent)
	_G.InteractiveMgr:SetMajorIsinging(true)
end

--参数是ms
--时间加长一点点
function NPCUsedItemSingBarView:BeginSingBar(SingTime, SingName, ShowSingTimeCountDown)
	self.SingTime = SingTime + _G.SingBarMgr.SingLifeAddTime

	if SingName then
		self.SingBarName:SetText(SingName)
	end

	self:CloseSingTimer()
	if not self.SingTimerID then
		self.SingTimerID = TimerMgr:AddTimer(self, self.UpdateProcessBar, 0, 0.02, 0)
	end

	self.ProgressSingBar:SetPercent(0)

	FLOG_INFO("SingBar BeginSingBar time: " .. TimeUtil.GetLocalTimeMS() .. " singTime: " .. SingTime)
	self.BeginTime = TimeUtil.GetLocalTimeMS()
end

--对于打断，则调用专有接口
function NPCUsedItemSingBarView:BreakSingBar()
	self:CloseSingTimer()
	self:Hide()
end

function NPCUsedItemSingBarView:OnMajorSingBarBreak()
	self:BreakSingBar()
end

return NPCUsedItemSingBarView
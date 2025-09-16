---
--- Author: sammrli
--- DateTime: 2024-04-07 20:30
--- Description:陆行鸟运输提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")
local AudioUtil = require("Utils/AudioUtil")

local ChocoboTransportDefine = require("Game/Chocobo/Transport/ChocoboTransportDefine")
local LSTR = _G.LSTR
local EventMgr = _G.EventMgr

---@class ChocoboTransportTipPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EndTip ChocoboTransportEndTipsItemView
---@field TextTip UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportTipPanelView = LuaClass(UIView, true)

function ChocoboTransportTipPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EndTip = nil
	--self.TextTip = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportTipPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.EndTip)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportTipPanelView:OnInit()
	local PreContent = LSTR(580003) --580003=寻路中
	self.SysbolList = {
		PreContent..".",
		PreContent.."..",
		PreContent.."..."
	}
	self.SysbolNum = #self.SysbolList
	self.TimeIndex = 0
end

function ChocoboTransportTipPanelView:OnDestroy()

end

function ChocoboTransportTipPanelView:OnShow()
	self.IsCloseTimeStart = false

	local Params = self.Params
	local OffsetX = 0

	if Params ~= nil then
		local bQuestTrans = Params.bQuestTrans
		if bQuestTrans then
			local PreContent = LSTR(580008) -- 正在前往任务目的地
			self.SysbolList = {
				PreContent..".",
				PreContent.."..",
				PreContent.."..."
			}
			self.SysbolNum = #self.SysbolList
			self.TimeIndex = 0
			OffsetX = ChocoboTransportDefine.QUEST_TRANSFER_OFFSET_X
		end
	end

	self.EndTip:SetText(LSTR(580012)) --580012("抵达终点")

	UIUtil.SetIsVisible(self.EndTip, false)
	UIUtil.SetIsVisible(self.TextTip, true)
	self.TextTip:SetText(self.SysbolList[1])

	local NeedVec = _G.UE.FVector2D(OffsetX, UIUtil.CanvasSlotGetPosition(self.TextTip).Y)
	UIUtil.CanvasSlotSetPosition(self.TextTip, NeedVec)

	self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
end

function ChocoboTransportTipPanelView:OnHide()

end

function ChocoboTransportTipPanelView:OnRegisterUIEvent()

end

function ChocoboTransportTipPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChocoboTransportFinish, self.OnGameEventChocoboTransportFinish)
	self:RegisterGameEvent(EventID.ChocoboTransportArriving, self.OnGameEventChocoboTransportArriving)
end

function ChocoboTransportTipPanelView:OnRegisterBinder()

end

function ChocoboTransportTipPanelView:OnTimer()
	self.TimeIndex = self.TimeIndex + 1
	local Index = math.fmod(math.floor(self.TimeIndex * 0.1), self.SysbolNum) + 1
	self.TextTip:SetText(self.SysbolList[Index])

	--通知位置更新
	EventMgr:SendEvent(EventID.UpdateChocoboTransportPosition)
end

function ChocoboTransportTipPanelView:OnGameEventChocoboTransportFinish()
	if self.IsCloseTimeStart then --关闭倒计时中
		return
	end
	self:Hide()
end

function ChocoboTransportTipPanelView:OnGameEventChocoboTransportArriving()
	UIUtil.SetIsVisible(self.EndTip, true)
	UIUtil.SetIsVisible(self.TextTip, false)
	self:UnRegisterAllTimer()

	local IsRun = not _G.ChocoboTransportMgr:IsFlyMode()
	if IsRun then
		self.EndTip:PlayRunAnimation()
	else
		self.EndTip:PlayFlyAnimation()
	end

	--play sound
	AudioUtil.LoadAndPlayUISound(ChocoboTransportDefine.ARRIVING_SOUND)

	self.IsCloseTimeStart = true
	self:RegisterTimer(self.OnTimeClose, 3)
end

function ChocoboTransportTipPanelView:OnTimeClose()
	self:Hide()
end

return ChocoboTransportTipPanelView
---
--- Author: Administrator
--- DateTime: 2025-02-06 11:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")

local SystemTipBPName = "InfoTips/CommonTipsItem_UIBP.CommonTipsItem_UIBP"

local DefaultFVector2D = _G.UE.FVector2D(0, 0)

local UnitInTime = 0.23
local UnitInOffset = 140

local UnitInOpaTime = 0.23

local UnitMoveOffset = 82
local UnitMoveTime = 0.2

local UnitOutOpaTime = 0.23

local UnitOutTime = 0.23
local UnitOutOffset = 70

local DefaultShowTime = 3

local ShowTimeLimit = 60
local ShowQueueLimit = 80

---@class ActiveSysteamErrorTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Tip1 UFCanvasPanel
---@field Tip10 UFCanvasPanel
---@field Tip2 UFCanvasPanel
---@field Tip3 UFCanvasPanel
---@field Tip4 UFCanvasPanel
---@field Tip5 UFCanvasPanel
---@field Tip6 UFCanvasPanel
---@field Tip7 UFCanvasPanel
---@field Tip8 UFCanvasPanel
---@field Tip9 UFCanvasPanel
---@field AllowShowNum int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ActiveSysteamErrorTipsView = LuaClass(UIView, true)

function ActiveSysteamErrorTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Tip1 = nil
	--self.Tip10 = nil
	--self.Tip2 = nil
	--self.Tip3 = nil
	--self.Tip4 = nil
	--self.Tip5 = nil
	--self.Tip6 = nil
	--self.Tip7 = nil
	--self.Tip8 = nil
	--self.Tip9 = nil
	--self.AllowShowNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ActiveSysteamErrorTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ActiveSysteamErrorTipsView:OnInit()
	
end

function ActiveSysteamErrorTipsView:OnDestroy()

end

function ActiveSysteamErrorTipsView:OnShow()
	self:Reset()
	self.TickInterval = 0.05
	self.Timer = self:RegisterTimer(self.OnTick, 0, self.TickInterval, 0)
	self.TickTimestamp = TimeUtil.GetLocalTime()

	local SliderMode = _G.MsgTipsUtil.GetSliderMode()
	self.AllowShowNum = SliderMode.DisplayNum ~= nil and SliderMode.DisplayNum or self.AllowShowNum
	UnitMoveOffset = SliderMode.MoveSpacing ~= nil and SliderMode.MoveSpacing or UnitMoveOffset
end

function ActiveSysteamErrorTipsView:Reset()
	self.AllTipsData = { }
	self.ShowTipsNameList = {}
	self.TipsQueue = {}
	self.DupeatQueue = {}

	for i = 1, 100 do
		local TipName = "Tip" .. tostring(i)
		if self[TipName] == nil then
			break
		end
		self[TipName]:ClearChildren()
		UIUtil.SetIsVisible(self[TipName], false)
		UIUtil.CanvasSlotSetPosition( self[TipName], DefaultFVector2D)
		-- TargetOffsetTop = 0, UnitOffset = 0, OffsetCount = 0, TargetOpacity = 0, UnitOpacity = 0, OpacityCount = 0 
		table.insert(self.AllTipsData, { TipName = TipName, IsShow = false, TargetIndex = 0, BPName = "", ItemView = nil, TotalShowTime = 0, CutShowTime = 0, Trajectory = {}})
	end
end

function ActiveSysteamErrorTipsView:OnHide()
	self.TipsQueue = {}
	for i = 1, #self.AllTipsData do
		local ItemTip = self.AllTipsData[i]
		if ItemTip.IsShow then
			self:RemoveTip(ItemTip)
		end
	end
	self.AllTipsData = {}
	self.ShowTipsNameList = {}
	self.DupeatQueue = {}
end

function ActiveSysteamErrorTipsView:OnRegisterUIEvent()
end

function ActiveSysteamErrorTipsView:OnRegisterGameEvent()

end

function ActiveSysteamErrorTipsView:OnRegisterBinder()

end

function ActiveSysteamErrorTipsView:OnTick()
	self.TickTimestamp = TimeUtil.GetLocalTime()
	self:RemoveDupeat()
	for i = 1, #self.AllTipsData do
		local TipsData = self.AllTipsData[i]
		if TipsData.IsShow then 
			if TipsData.Trajectory[1] then
				local TipView = self[TipsData.TipName]
				local Trajectory = TipsData.Trajectory[1]
				local OffsetCount = Trajectory.OffsetCount or 0
				if OffsetCount > 1 then
					local Offset = UIUtil.CanvasSlotGetOffsets(TipView)
					Offset.Top = Offset.Top + Trajectory.UnitOffset
					UIUtil.CanvasSlotSetOffsets(TipView, Offset)
					Trajectory.OffsetCount = Trajectory.OffsetCount - 1
				elseif OffsetCount == 1 then
					local Offset = UIUtil.CanvasSlotGetOffsets(TipView)
					Offset.Top = Trajectory.TargetOffsetTop
					UIUtil.CanvasSlotSetOffsets(TipView, Offset)
					Trajectory.OffsetCount = Trajectory.OffsetCount - 1
				end

				local OpacityCount = Trajectory.OpacityCount or 0
				if OpacityCount > 1 then
					local Opacity = TipView:GetRenderOpacity()
					Opacity = Opacity + Trajectory.UnitOpacity
					UIUtil.SetRenderOpacity(TipView, Opacity)
					Trajectory.OpacityCount = Trajectory.OpacityCount - 1
				elseif OpacityCount == 1 then
					local Opacity = TipView:GetRenderOpacity()
					Opacity = Trajectory.TargetOpacity
					UIUtil.SetRenderOpacity(TipView, Opacity)
					Trajectory.OpacityCount = Trajectory.OpacityCount - 1
				end
				if (Trajectory.OpacityCount or 0) <= 0 and (Trajectory.OffsetCount or 0) <= 0 then
					table.remove(TipsData.Trajectory, 1)
					if #TipsData.Trajectory <= 0 then
						if TipsData.TargetIndex <= 0 or TipsData.TotalShowTime <= 0 then
							self:RemoveTip(TipsData)
						end
					end
				end
			else
				TipsData.CutShowTime = TipsData.CutShowTime + self.TickInterval
				if TipsData.CutShowTime >= TipsData.TotalShowTime and TipsData.TotalShowTime > 0 then
					TipsData.TotalShowTime = 0
					self:AddTipCloseTrajectory(TipsData)
				end
				if TipsData.CutShowTime > ShowTimeLimit then
					self:RemoveTip(TipsData)
					_G.FLOG_WARNING("ActiveSystemErrorTipsView: ShowTimeLimit!!!")
				end
			end
		end
	end
end

function ActiveSysteamErrorTipsView:AddTipCloseTrajectory(TipsData)
	if TipsData.TargetIndex == 1 then
		local NewTrajectory = {}
		--这里不要设置 TargetIndex  TargetIndex的0和1 用来区分是否需要整体向上轮播
		local TargetOffset = 0
		NewTrajectory.TargetOffsetTop = TargetOffset
		NewTrajectory.OffsetCount = math.floor(UnitOutTime / self.TickInterval)
		NewTrajectory.UnitOffset = -1.0 * UnitOutOffset / NewTrajectory.OffsetCount
		
		NewTrajectory.TargetOpacity = 0.0
		NewTrajectory.OpacityCount = math.floor(UnitOutOpaTime / self.TickInterval)
		NewTrajectory.UnitOpacity = - 1.0 / NewTrajectory.OpacityCount
			
		table.insert(TipsData.Trajectory, NewTrajectory)
	else
		local NewTrajectory = {}
		NewTrajectory.TargetOpacity = 0.0
		NewTrajectory.OpacityCount = math.floor(UnitOutOpaTime / self.TickInterval)
		NewTrajectory.UnitOpacity = - 1.0 / NewTrajectory.OpacityCount
		table.insert(TipsData.Trajectory, NewTrajectory)
	end
end

function ActiveSysteamErrorTipsView:AllShowTipsTopOffset(StartIndex)
	for i = 1, #self.AllTipsData do
		local ItemTip = self.AllTipsData[i]
		if ItemTip.IsShow and ItemTip.TargetIndex >= StartIndex then
			if ItemTip.TotalShowTime <= 0 and ItemTip.Trajectory[1] and ItemTip.TargetIndex > 1 then
				local NewTrajectory1 = ItemTip.Trajectory[1]
				if (NewTrajectory1.OpacityCount or 0) ~= 0 then
					local NewTrajectory1 = ItemTip.Trajectory[1]
					NewTrajectory1.OffsetCount = NewTrajectory1.OpacityCount
					NewTrajectory1.UnitOffset = -1.0 * UnitMoveOffset / NewTrajectory1.OffsetCount
				end
			else
				ItemTip.TargetIndex = ItemTip.TargetIndex - 1 < 0 and 0 or ItemTip.TargetIndex - 1
				local NewTrajectory = {}
				local TargetOffset = (ItemTip.TargetIndex - 1) * UnitMoveOffset
				NewTrajectory.TargetOffsetTop = TargetOffset
				NewTrajectory.OffsetCount = math.floor(UnitMoveTime / self.TickInterval)
				NewTrajectory.UnitOffset = -1.0 * UnitMoveOffset / NewTrajectory.OffsetCount
				if ItemTip.TargetIndex <= 0 then
					NewTrajectory.TargetOpacity = 0.0
					NewTrajectory.OpacityCount = math.floor(UnitOutOpaTime / self.TickInterval)
					NewTrajectory.UnitOpacity = - 1.0 / NewTrajectory.OpacityCount
				end
				table.insert(ItemTip.Trajectory, NewTrajectory)
			end
		end
	end
end

function ActiveSysteamErrorTipsView:ActivelyHide()
	if #self.TipsQueue > 0 then
		return 
	end

	for i = 1, #self.AllTipsData do
		if self.AllTipsData[i].IsShow then
			return 
		end
	end

	self:Hide()
end

function ActiveSysteamErrorTipsView:RemoveTip(TipsData)
	TipsData.IsShow = false
	TipsData.Trajectory = {}
	self[TipsData.TipName]:RemoveChild(TipsData.ItemView)
	_G.UIViewMgr:RecycleView(TipsData.ItemView)
	TipsData.ItemView = nil
	TipsData.BPName = ""
	table.remove_item(self.ShowTipsNameList, TipsData.TipName)
	if TipsData.TargetIndex > 0 then
		self:AllShowTipsTopOffset(TipsData.TargetIndex )
	end
	TipsData.TargetIndex = 0

	if #self.TipsQueue > 0 then
		local Tips = self.TipsQueue[1]
		self:AddTips(Tips.BPName, Tips.Params, true)
	end
end

function ActiveSysteamErrorTipsView:GetAddLocationIndex()
	local MaxIndex = 0
	for i = 1, #self.AllTipsData do
		local ItemTip = self.AllTipsData[i]
		if ItemTip.IsShow and ItemTip.TargetIndex then
			if ItemTip.TargetIndex > MaxIndex then 
				MaxIndex = ItemTip.TargetIndex
			end
		end
	end
	return MaxIndex + 1
end


function ActiveSysteamErrorTipsView:AddTips(BPName, Params, IsQueue)
	if not IsQueue and #self.TipsQueue > 0 then
		table.insert(self.TipsQueue, {BPName = BPName, Params = Params })
		self:PrintQueueCountLog()
		return
	end
	
	local ShowNum = self:GetAddLocationIndex()
	if ShowNum > self.AllowShowNum or #self.ShowTipsNameList >= self.AllowShowNum then
		if not IsQueue then
			table.insert(self.TipsQueue, {BPName = BPName, Params = Params })
			if ShowNum > self.AllowShowNum then
				self:AllShowTipsTopOffset(1)
			end
			self:PrintQueueCountLog()
		end
		return 
	end
	if IsQueue then
		table.remove(self.TipsQueue, 1)
	end
	ShowNum = ShowNum > self.AllowShowNum and self.AllowShowNum or ShowNum
	local ReadyTipData
	for i = 1, #self.AllTipsData do
		if not self.AllTipsData[i].IsShow then
			ReadyTipData = self.AllTipsData[i]
			break
		end
	end
	if nil == ReadyTipData then
		_G.FLOG_WARNING("ActiveSystemErrorTipsView:AddTips error")
		return
	end

	ReadyTipData.TargetIndex = ShowNum
	local TargetOffset = (ReadyTipData.TargetIndex - 1) * UnitMoveOffset
	local StartOffset = TargetOffset + UnitInOffset
	local Margin = _G.UE.FMargin()
	Margin.Top = StartOffset
	Margin.Left = 0
	Margin.Right = 0
	Margin.Bottom = 0
	UIUtil.CanvasSlotSetOffsets(self[ReadyTipData.TipName], Margin)
	UIUtil.SetRenderOpacity(self[ReadyTipData.TipName], 0)
	UIUtil.SetIsVisible(self[ReadyTipData.TipName], true)
	ReadyTipData.IsShow = true 
	ReadyTipData.TotalShowTime = Params.ShowTime
	ReadyTipData.CutShowTime = 0
	Params.ShowTime = 1000000
	
	local NewTrajectory = {}
	NewTrajectory.TargetOffsetTop = TargetOffset
	NewTrajectory.OffsetCount = math.floor(UnitInTime / self.TickInterval)
	NewTrajectory.UnitOffset = (TargetOffset - StartOffset) / NewTrajectory.OffsetCount
	NewTrajectory.TargetOpacity = 1.0
	NewTrajectory.OpacityCount = math.floor(UnitInOpaTime / self.TickInterval)
	NewTrajectory.UnitOpacity = 1.0 / NewTrajectory.OpacityCount
	table.insert(ReadyTipData.Trajectory, NewTrajectory )

	local ItemView = _G.UIViewMgr:CreateViewByName(BPName, nil, self, true, true, Params)
	self[ReadyTipData.TipName]:AddChildToCanvas(ItemView)
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0, 0)
	Anchor.Maximum = _G.UE.FVector2D(1, 1)
	Margin = _G.UE.FMargin()
	Margin.Top = 0
	Margin.Left = 0
	Margin.Right = 0
	Margin.Bottom = 0
	UIUtil.CanvasSlotSetAlignment(ItemView, _G.UE.FVector2D(0, 0))
	UIUtil.CanvasSlotSetAnchors(ItemView, Anchor)
	UIUtil.CanvasSlotSetOffsets(ItemView, Margin)
	UIUtil.SetRenderOpacity(ItemView, 1.0)
	UIUtil.SetIsVisible(ItemView, true)

	ReadyTipData.ItemView = ItemView
	ReadyTipData.BPName = BPName
	table.insert(self.ShowTipsNameList, ReadyTipData.TipName)

	if #self.TipsQueue > 0 then
		self:AllShowTipsTopOffset(1)
	end
end

------------------ Dupeat
function ActiveSysteamErrorTipsView:RemoveDupeat()
	local CutTime = TimeUtil.GetLocalTimeMS()
	for i = #self.DupeatQueue, 1, -1 do
		local TipsInfo = self.DupeatQueue[i]
		if TipsInfo ~= nil then
			if CutTime - TipsInfo.NewAddTime >= TipsInfo.ValidTime then
				table.remove(self.DupeatQueue, i)
			end
		end
	end
end

function ActiveSysteamErrorTipsView:QueryDupeat(BPName, Params)
	local Content = Params.Content or ""
	for i = 1, #self.DupeatQueue do
		local TipInfo = self.DupeatQueue[i] or {}
		if TipInfo.Type == BPName and TipInfo.Content == Content then
			return true
		end
	end
end

function ActiveSysteamErrorTipsView:AddDupeatQueue(BPName, Params, ValidTime)
	local NewTip = { Type = BPName, Content = Params.Content, NewAddTime = TimeUtil.GetLocalTimeMS(), ValidTime = ValidTime }
	table.insert(self.DupeatQueue, NewTip)
end

-------------- Interface
--- 检查是Tick是否在正常运作
---@return bool true@正常 false@不正常
function ActiveSysteamErrorTipsView:CheckNormalOperation()
	return (TimeUtil.GetLocalTime() - self.TickTimestamp) <= 3
end

-- 判断当前正在显示的提示 和 队列中的提示 存不存在系统提示
function ActiveSysteamErrorTipsView:ExistSysTipDisplayedOrQueueing()
	for i = 1, #self.TipsQueue do
		local QueueTip = self.TipsQueue[i] or {}
		if QueueTip.BPName == SystemTipBPName then
			return true
		end
	end
	for i = 1, #self.AllTipsData do
		if self.AllTipsData[i].IsShow then
			local ShowTip = self.AllTipsData[i] or {}
			if ShowTip.BPName == SystemTipBPName then 
				return true
			end
		end
	end
	return false
end

function ActiveSysteamErrorTipsView:AddErrorTip(Params)
	local BPName = "InfoTips/ErrorTips_UIBP.ErrorTips_UIBP"
	Params.ShowTime = Params.ShowTime or DefaultShowTime
	if self:QueryDupeat(BPName, Params) then
		return 
	end
	self:AddTips(BPName, Params)
	self:AddDupeatQueue(BPName, Params, 2000)
end

function ActiveSysteamErrorTipsView:AddSystemTip(Params)
	local BPName = SystemTipBPName
	Params.ShowTime = Params.ShowTime or DefaultShowTime
	if self:QueryDupeat(BPName, Params) then
		return 
	end
	self:AddTips(BPName, Params)
	self:AddDupeatQueue(BPName, Params, 2000)
end

function ActiveSysteamErrorTipsView:AddActiveTip(Params)
	Params.ShowTime = Params.ShowTime or DefaultShowTime
	self:AddTips("InfoTips/ActiveTips_UIBP.ActiveTips_UIBP", Params)
end

function ActiveSysteamErrorTipsView:AddPVPColosseumTeamTip(Params)
	Params.ShowTime = Params.ShowTime or DefaultShowTime
	self:AddTips("InfoTips/PVPColosseumTeamTips_UIBP.PVPColosseumTeamTips_UIBP", Params)
end

function ActiveSysteamErrorTipsView:AddPVPColosseumKillTipsView(Params)
	Params.ShowTime = Params.ShowTime or DefaultShowTime
	self:AddTips("InfoTips/PVPColosseumKillTips_UIBP.PVPColosseumKillTips_UIBP", Params)
end

function ActiveSysteamErrorTipsView:AddFootPrintTipsView(Params)
	Params.ShowTime = Params.ShowTime or DefaultShowTime
	self:AddTips("FootPrint/FootPrintTips_UIBP.FootPrintTips_UIBP", Params)
end

function ActiveSysteamErrorTipsView:RefreshDisplayNumOrMoveSpacing(DisplayNum, MoveSpacing)
	if DisplayNum ~= nil then
		self.AllowShowNum = DisplayNum
	end
	if MoveSpacing ~= nil then
		UnitMoveOffset = MoveSpacing
	end
end


-------------- Log
function ActiveSysteamErrorTipsView:PrintQueueCountLog()
	local QueueCount = #(self.TipsQueue or {})
	if QueueCount == 10 or QueueCount == ShowQueueLimit or QueueCount == 30 then
		_G.FLOG_WARNING("ActiveSystemErrorTipsView: Current QueueCount:" .. tostring(QueueCount)
		..  "    DupeatQueueCount:" .. tostring(#(self.DupeatQueue or {})))
	end
	if QueueCount == ShowQueueLimit then
		self:Hide()
	end
end


return ActiveSysteamErrorTipsView
---
--- Author: haialexzhou
--- DateTime: 2021-08-26 16:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PWorldCfgTable = require("TableCfg/PworldCfg")
local PworldWarningCfgTable = require("TableCfg/PworldWarningCfg")
local FMath = _G.UE.UMathUtil

local DefaultIconPath = "Texture2D'/Game/Assets/Icon/Skill/Warning/UI_Icon_Skill_Warning_FBTSJZ.UI_Icon_Skill_Warning_FBTSJZ'"
--默认预警时长 毫秒
local DefaultMaxWarningTime = 15000
--默认显示名称时间
local DefaultShowNameTime = 5000

---@class WarningBossCDPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CDDot WarningBossCDItemView
---@field CDPanel UFCanvasPanel
---@field FImg_Bar_L UFImage
---@field FImg_Line10s_L UFImage
---@field FImg_Line5s_L UFImage
---@field Name UVerticalBox
---@field RichText_0s_L URichTextBox
---@field RichText_10S_L URichTextBox
---@field RichText_5s_L URichTextBox
---@field RichText_SkillName URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WarningBossCDPanelView = LuaClass(UIView, true)

function WarningBossCDPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CDDot = nil
	--self.CDPanel = nil
	--self.FImg_Bar_L = nil
	--self.FImg_Line10s_L = nil
	--self.FImg_Line5s_L = nil
	--self.Name = nil
	--self.RichText_0s_L = nil
	--self.RichText_10S_L = nil
	--self.RichText_5s_L = nil
	--self.RichText_SkillName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WarningBossCDPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CDDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WarningBossCDPanelView:InitPos()
	
end

function WarningBossCDPanelView:OnInit()
	self.WidgetCloneItem = self.CDDot
	self.WidgetCloneParent = self.CDPanel

	local PWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
	local WarningTime = PWorldCfgTable:FindValue(PWorldResID, "WarningTime")
	
	--当前副本预警时长
	self.WarningMaxTimeMS = WarningTime > 0 and (WarningTime * 1000) or DefaultMaxWarningTime

	self.WarningWidgetPoolInitCnt = 3
	--缓存处理
	self.UsedWarningWidgetPool = {}
	self.UnUsedWarningWidgetPool = {}
	for i = 1, self.WarningWidgetPoolInitCnt, 1 do
		local WarningWidget = self:CloneWidget(self.WidgetCloneItem, self.WidgetCloneParent)
		table.insert(self.UnUsedWarningWidgetPool, WarningWidget)
	end

	local Line10sPos = UIUtil.CanvasSlotGetPosition(self.FImg_Line10s_L)
	local Line5sPos = UIUtil.CanvasSlotGetPosition(self.FImg_Line5s_L)
	local PixelForSecond = (Line10sPos.X - Line5sPos.X) / 5
	--right move to left
	self.EndPos = UIUtil.CanvasSlotGetPosition(self.WidgetCloneItem)
	
	local CDDotSize = UIUtil.CanvasSlotGetSize(self.WidgetCloneItem)
	local ItemSizeX = CDDotSize and CDDotSize.X or 0
	self.StartPos = _G.UE.FVector2D(self.EndPos.X + PixelForSecond * WarningTime + ItemSizeX, self.EndPos.Y)
end

local function DestroyWidgetPool(WarningWidgetPool)
	if (WarningWidgetPool == nil) then
		return
	end
	for _ , Widget in pairs(WarningWidgetPool) do
		if nil ~= Widget then
			Widget:HideView()
			Widget:DestroyView()
		end
	end
end

function WarningBossCDPanelView:OnDestroy()
	DestroyWidgetPool(self.UnUsedWarningWidgetPool)
	DestroyWidgetPool(self.UsedWarningWidgetPool)
	self.UnUsedWarningWidgetPool = nil
	self.UsedWarningWidgetPool = nil
	self.IconPathCache = nil
end

--从缓存池中取
function WarningBossCDPanelView:GetUnUsedWarningWidget()
	local WarningWidget = nil
	if (#self.UnUsedWarningWidgetPool > 0) then
		WarningWidget = self.UnUsedWarningWidgetPool[1]
		table.remove(self.UnUsedWarningWidgetPool, 1)
	else
		WarningWidget = self:CloneWidget(self.WidgetCloneItem, self.WidgetCloneParent)
    end
	
    return WarningWidget
end

function WarningBossCDPanelView:GetUsedWarningWidget(WarningID)
	for _, Value in ipairs(self.UsedWarningWidgetPool) do
		if (Value.WarningID == WarningID) then
			return Value
		end
	end
	return nil
end

--回收
function WarningBossCDPanelView:RecycleWarningWidget(WarningWidget)
    if (nil == WarningWidget) then
        return
    end
	WarningWidget.bIsInit = false
	WarningWidget.WarningID = nil
	WarningWidget:UpdateState(_G.PWorldWarningMgr.ReadyState.DEFAULT)

	UIUtil.SetIsVisible(WarningWidget, false)
	_G.TableTools.RemoveTableElement(self.UsedWarningWidgetPool, WarningWidget)
	table.insert(self.UnUsedWarningWidgetPool, WarningWidget)
	if (#self.UnUsedWarningWidgetPool > self.WarningWidgetPoolInitCnt) then
		_G.TableTools.RemoveTableElements(self.UnUsedWarningWidgetPool, self.WarningWidgetPoolInitCnt)
	end
end

function WarningBossCDPanelView:GetWarningWidget(WarningID, WarningIconID)
	local WarningWidget = self:GetUsedWarningWidget(WarningID)
	if (WarningWidget == nil) then
		WarningWidget = self:GetUnUsedWarningWidget()
		if (WarningWidget ~= nil) then
			WarningWidget.WarningID = WarningID
			local IconPath = self:GetWarningWidgetIcon(WarningIconID)
			WarningWidget:SetIcon(IconPath)
			UIUtil.SetIsVisible(WarningWidget, true)
			table.insert(self.UsedWarningWidgetPool, WarningWidget)
		end
		
		--print("GetWarningWidget WarningID=" .. WarningWidget.WarningID)
	end
	return WarningWidget
end

function WarningBossCDPanelView:GetWarningWidgetIcon(IconID)
	if (IconID == 0) then
		return DefaultIconPath
	end

	if (self.IconPathCache == nil) then
		self.IconPathCache = {}
	end
	local IconPath = self.IconPathCache[IconID]
	if (IconPath == nil) then
		IconPath = PworldWarningCfgTable:FindValue(IconID, "Icon")
		self.IconPathCache[IconID] = IconPath
	end

	if (IconPath == nil) then
		IconPath = DefaultIconPath
	end

	return IconPath
end


function WarningBossCDPanelView:OnShow()
	UIUtil.SetIsVisible(self.CDDot, false)
	UIUtil.SetIsVisible(self.FImg_Bar_L, true)
	self:HideName()
end

function WarningBossCDPanelView:CloneWidget(Widget, ParentWidget)
	local CloneWidget = _G.UIViewMgr:CloneView(Widget, nil, true, true, Widget.EntityID)
	CloneWidget.ViewID = Widget.ViewID
	UIUtil.SetIsVisible(CloneWidget, false)
	ParentWidget:AddChildToCanvas(CloneWidget)

	local OriginAlignment = UIUtil.CanvasSlotGetAlignment(Widget)
	UIUtil.CanvasSlotSetAlignment(CloneWidget, OriginAlignment)

	local OriginSize = UIUtil.CanvasSlotGetSize(Widget)
	UIUtil.CanvasSlotSetSize(CloneWidget, OriginSize)

	return CloneWidget
end

function WarningBossCDPanelView:Tick(_, InDeltaTime)
	local WarningDataList = _G.PWorldWarningMgr.WarningDataList
	if (WarningDataList == nil or #WarningDataList == 0) then
		if (_G.UIViewMgr:IsViewVisible(self.ViewID)) then
			_G.UIViewMgr:HideView(self.ViewID)
		end
		
		return
	end
	
	local WarningDataCnt = #WarningDataList
	for i = WarningDataCnt, 1, -1 do
		--起到continue作用
		while true do
			local WarningData = WarningDataList[i]
			--ExecState 用于记录预警执行状态，避免后台下发del的时候客户端还没执行完成
			if (WarningData == nil or WarningData.ExecState == _G.PWorldWarningMgr.ExecState.FINISH_EXEC) then
				break
			end
			local NowTimeMS = _G.TimeUtil.GetServerTimeMS()
			local MoveTimeMS = WarningData.ExecTime - NowTimeMS
			--print("WarningData=" .. _G.table_to_string(WarningData) .. "; ExecTime=" .. WarningData.ExecTime .. "; MoveTimeMS=" .. MoveTimeMS .. "; WarningMaxTimeMS=" .. self.WarningMaxTimeMS)
			if (MoveTimeMS > self.WarningMaxTimeMS) then
				break
			end
			
			local WarningWidget = self:GetWarningWidget(WarningData.WarningID, WarningData.Param)
			if (WarningWidget == nil) then
				break
			end

			if (not WarningWidget.bIsInit) then
				WarningWidget.bIsInit = true
				WarningWidget.TotalMoveTimeMS = MoveTimeMS > 0 and MoveTimeMS or 1
				WarningWidget.StartPos =  FMath.V2DLerp(self.StartPos, self.EndPos, math.abs(self.WarningMaxTimeMS - WarningWidget.TotalMoveTimeMS) / self.WarningMaxTimeMS)
				WarningWidget.EndPos = self.EndPos
				WarningWidget.TotalDeltaTimeMS = 0
				if (WarningWidget.TotalMoveTimeMS > DefaultShowNameTime) then
					--显示名称
					WarningWidget.ShowNameRatio = (WarningWidget.TotalMoveTimeMS - DefaultShowNameTime) / WarningWidget.TotalMoveTimeMS
				else
					WarningWidget.ShowNameRatio = 0
				end
				WarningWidget.AlreadyTime = nil

				WarningData.ExecState = _G.PWorldWarningMgr.ExecState.EXECTUING
			end

			--print("WarningWidget.bIsInit=" .. tostring(WarningWidget.bIsInit) .. "; WarningWidget.AlreadyTime=" .. tostring(WarningWidget.AlreadyTime) .. "; WarningData.WarningID=" .. tostring(WarningData.WarningID) .. "; NowTimeMS=" .. NowTimeMS)
			if (WarningWidget.AlreadyTime == nil) then
				WarningWidget.TotalDeltaTimeMS = WarningWidget.TotalDeltaTimeMS + InDeltaTime * 1000
				local Ratio = WarningWidget.TotalDeltaTimeMS / WarningWidget.TotalMoveTimeMS;
				local NewPos = FMath.V2DLerp(WarningWidget.StartPos, WarningWidget.EndPos, Ratio)
				if (Ratio >= 1.0 and NewPos ~= WarningWidget.EndPos) then
					NewPos = WarningWidget.EndPos
				end
				--print("NewPos.X=" .. NewPos.X .. "; Ratio=" .. Ratio)
				UIUtil.CanvasSlotSetPosition(WarningWidget, NewPos)
				
				--到达目的地
				if (Ratio >= 1.0) then
					WarningWidget.AlreadyTime = NowTimeMS
					self:HideName()
					WarningWidget:UpdateState(_G.PWorldWarningMgr.ReadyState.ALREADY)
					--print("NewPos.X=" .. NewPos.X .. "; EndPos.X=" .. WarningWidget.EndPos.X)
				elseif (Ratio >= WarningWidget.ShowNameRatio and not self.bNameIsShowing) then
					--显示名称
					self:ShowName(WarningData.Name)
					WarningWidget:UpdateState(_G.PWorldWarningMgr.ReadyState.SHOWNAME)
				end
			else
				--到达目标点后停留1秒
				if (NowTimeMS - WarningWidget.AlreadyTime >= 1000) then
					--print("RecycleWarningWidget WarningID = " .. WarningWidget.WarningID)
					WarningData.ExecState = _G.PWorldWarningMgr.ExecState.FINISH_EXEC
					self:RecycleWarningWidget(WarningWidget)
					
					--后台下发Del的时候正在EXECTUING
					table.remove(WarningDataList, i)
				end
			end

			--这个break别手贱删了！！！！
			break
		end
	end

	--有数据，但是都超过了副本最大预警时长，先隐藏UI
	if (#self.UsedWarningWidgetPool > 0) then
		UIUtil.SetIsVisible(self.CDPanel, true)
	else
		UIUtil.SetIsVisible(self.CDPanel, false)
	end
end

function WarningBossCDPanelView:ShowName(NameContent)
	UIUtil.SetIsVisible(self.Name, true)
	self.RichText_SkillName:SetText(NameContent)
	self.bNameIsShowing = true
end

function WarningBossCDPanelView:HideName()
	UIUtil.SetIsVisible(self.Name, false)
	self.bNameIsShowing = false
end

function WarningBossCDPanelView:OnHide()

end

function WarningBossCDPanelView:OnRegisterUIEvent()
	
end

function WarningBossCDPanelView:OnRegisterGameEvent()

end

function WarningBossCDPanelView:OnRegisterTimer()

end

function WarningBossCDPanelView:OnRegisterBinder()

end


return WarningBossCDPanelView
---
--- Author: sammrli
--- DateTime: 2023-05-20 23:44
--- Description:玩法验证工具（旧:野外测试工具）
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local FieldTestTabItemVM = require("Game/Test/FieldTest/ViewModel/FieldTestTabItemVM")
local NpcCfg = require("TableCfg/NpcCfg")
local EventID = require("Define/EventID")
local MonsterCfg = require("TableCfg/MonsterCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr

local table_to_string = _G.table_to_string
local GMMgr = _G.GMMgr
local TimerMgr = _G.TimerMgr
local UE = _G.UE

---@class FieldTestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BImg UImage
---@field BtnDrag UFButton
---@field BtnMini UFButton
---@field CommonCloseBtn CommonCloseBtnView
---@field MovePanel UFCanvasPanel
---@field SelectedTip UFImage
---@field SubPanel1 FieldTestSubPanelView
---@field SubPanel10 FieldTestSubPanelView
---@field SubPanel11 FieldTestSubPanelView
---@field SubPanel12 FieldTestSubPanelView
---@field SubPanel2 FieldTestSubPanelView
---@field SubPanel3 FieldTestSubPanelView
---@field SubPanel4 FieldTestSubPanelView
---@field SubPanel5 FieldTestSubPanelView
---@field SubPanel6 FieldTestSubPanelView
---@field SubPanel7 FieldTestSubPanelView
---@field SubPanel8 FieldTestSubPanelView
---@field SubPanel9 FieldTestSubPanelView
---@field TabList UTableView
---@field TextDrag UFTextBlock
---@field TextMinimize UFTextBlock
---@field TextShowResID UFTextBlock
---@field ToggleShow UToggleButton
---@field IsDrag bool
---@field MovePanelSlot CanvasPanelSlot
---@field Offset Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FieldTestPanelView = LuaClass(UIView, true)

function FieldTestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BImg = nil
	--self.BtnDrag = nil
	--self.BtnMini = nil
	--self.CommonCloseBtn = nil
	--self.MovePanel = nil
	--self.SelectedTip = nil
	--self.SubPanel1 = nil
	--self.SubPanel10 = nil
	--self.SubPanel11 = nil
	--self.SubPanel12 = nil
	--self.SubPanel2 = nil
	--self.SubPanel3 = nil
	--self.SubPanel4 = nil
	--self.SubPanel5 = nil
	--self.SubPanel6 = nil
	--self.SubPanel7 = nil
	--self.SubPanel8 = nil
	--self.SubPanel9 = nil
	--self.TabList = nil
	--self.TextDrag = nil
	--self.TextMinimize = nil
	--self.TextShowResID = nil
	--self.ToggleShow = nil
	--self.IsDrag = nil
	--self.MovePanelSlot = nil
	--self.Offset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.SubPanelViews = {}
	self.SubPanelID = 0
	self.SelectedEntityID = 0
	self.SoundSelectedID = ""
	self.WeatherSelectedID = -1
	self.Box = nil
	self.Cylinder = nil
	self.HUDMap = {}
	self.MonsterProfileNameCache = {}
end

function FieldTestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonCloseBtn)
	self:AddSubView(self.SubPanel1)
	self:AddSubView(self.SubPanel10)
	self:AddSubView(self.SubPanel11)
	self:AddSubView(self.SubPanel12)
	self:AddSubView(self.SubPanel2)
	self:AddSubView(self.SubPanel3)
	self:AddSubView(self.SubPanel4)
	self:AddSubView(self.SubPanel5)
	self:AddSubView(self.SubPanel6)
	self:AddSubView(self.SubPanel7)
	self:AddSubView(self.SubPanel8)
	self:AddSubView(self.SubPanel9)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FieldTestPanelView:OnInit()
	self.AdapterTabList = UIAdapterTableView.CreateAdapter(self, self.TabList)
	self.TabVMList = UIBindableList.New(FieldTestTabItemVM)
	self.TabVMList:AddByValue({Key = 1, Name = "NPC", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 2, Name = "怪物", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 3, Name = "采集物", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 4, Name = "FATE", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 5, Name = "音效", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 6, Name = "天气", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 7, Name = "陆行鸟", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 8, Name = "传送带", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 9, Name = "钓场", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 10, Name = "风脉泉", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 11, Name = "探索笔记", PanelView = self, CallBack = self.OnSelectedTabIndex})
	self.TabVMList:AddByValue({Key = 12, Name = "野外宝箱", PanelView = self, CallBack = self.OnSelectedTabIndex})

	for i=1, 12 do
		local SubView =	self[string.format("SubPanel%d", i)]
		if SubView then
			SubView:OnShowChocoboView(false)
			if i == 7 then
				SubView:OnShowChocoboView(true)
			end
			table.insert(self.SubPanelViews, SubView)
			SubView.ParentView = self
			--UIUtil.SetIsVisible(SubView, i == 1)
			UIUtil.CanvasSlotSetPosition(SubView, i == 1 and UE.FVector2D(200, 0) or UE.FVector2D(-10000, -10000))
		end
	end

	self.DPIScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
	self.SelectedTipSlot = self.SelectedTip.Slot
end

function FieldTestPanelView:OnDestroy()
	self.AdapterTabList:OnDestroy()
	self.AdapterTabList = nil
	self.TabVMList = nil
	if self.UpdateTimerID then
		TimerMgr:CancelTimer(self.UpdateTimerID)
		self.UpdateTimerID = nil
	end
	if self.HUDMap then
		for i=1, #self.HUDMap do
			local HUD = self.HUDMap[i]
			HUD:RemoveFromParent()
		end
	end
end

function FieldTestPanelView:OnShow()
	self.TextDrag:SetText(_G.LSTR(1440003)) --拖拽
	self.TextMinimize:SetText(_G.LSTR(1440004)) --最小化
	self.TextShowResID:SetText(_G.LSTR(1440030)) --显示隐藏
	self.AdapterTabList:UpdateAll(self.TabVMList)
	self.AdapterTabList:SetSelectedIndex(1)
	-- self:UpdateSubView(1)
	self.SubPanelID = 1

	self.UpdateTimerID = self:RegisterTimer(self.OnUpdateTime, 0, 0.05, 0)

	_G.FieldTestMgr:GetNpcMonsterResByGM()

	local GatherDataList = _G.FieldTestMgr:GetGatherDataList()
	self.SubPanel3:SetDataList(GatherDataList)

	local FateDataList = _G.FieldTestMgr:GetFateDataList()
	self.SubPanel4:SetDataList(FateDataList)

	local SoundEffDataList = _G.FieldTestMgr:GetSoundEffDataList()
	self.SubPanel5:SetDataList(SoundEffDataList)

	local WeatherDataList = _G.FieldTestMgr:GetWeatherDataList()
	self.SubPanel6:SetDataList(WeatherDataList)
	
	local ChocoboNPCDataList = _G.FieldTestMgr:GetChocoboNPCDataList()
	local MapTaskList = _G.FieldTestMgr:GetMapTaskList()
	self.SubPanel7:SetDataList(ChocoboNPCDataList)
	self.SubPanel7:SetChocoboDataList(MapTaskList)
	
	-- 处理编辑器数据
	local ExitRangeDataList, FishLocationDataList = _G.FieldTestMgr:GetMapEditDataList()
	self.SubPanel8:SetDataList(ExitRangeDataList)
	self.SubPanel9:SetDataList(FishLocationDataList)

	local AetherDataList = _G.FieldTestMgr:GetAetherDataList()
	self.SubPanel10:SetDataList(AetherDataList)

	local DiscoverDataList = _G.FieldTestMgr:GetDiscoverDataList()
	self.SubPanel11:SetDataList(DiscoverDataList)

	local WildBoxDataList = _G.FieldTestMgr:GetWildBoxDataList()
	self.SubPanel12:SetDataList(WildBoxDataList)

	for i=1, #self.SubPanelViews do
		self.SubPanelViews[i]:UpdateProblemDataList(i)
	end

	self.LastMapResID = _G.PWorldMgr:GetCurrMapResID()
end

function FieldTestPanelView:OnHide()
	-- if self.UpdateTimerID then
	-- 	TimerMgr:CancelTimer(self.UpdateTimerID)
	-- 	self.UpdateTimerID = nil
	-- end

	if self.HUDMap then
		for i=1, #self.HUDMap do
			local HUD = self.HUDMap[i]
			UIUtil.SetIsVisible(HUD, false)
		end
	end
end

function FieldTestPanelView:OnRegisterUIEvent()
	--ToggleButton, ButtonState
	-- UIUtil.AddOnStateChangedEvent(self, self.ToggleNPC, self.OnToggleNPCChange)
	-- UIUtil.AddOnStateChangedEvent(self, self.ToggleMonster, self.OnToggleMonsterChange)
	-- UIUtil.AddOnStateChangedEvent(self, self.ToggleGather, self.OnToggleGatherChange)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleShow, self.OnToggleShowChange)
	UIUtil.AddOnClickedEvent(self, self.BtnMini, self.OnMinimizeClicked)
end

function FieldTestPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.GMReceiveRes, self.OnGMReceiveRes)
	self:RegisterGameEvent(EventID.ManualSelectTarget, self.OnManualSelectTarget)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnMapEnter)
end

function FieldTestPanelView:OnRegisterBinder()
end

function FieldTestPanelView:OnUpdateTime()
	--be selected mark
	if self.SelectedEntityID > 0 and self.SelectedTipSlot then
		local Character = ActorUtil.GetActorByEntityID(self.SelectedEntityID)
		if Character then
			local ScreenLocation = UE.FVector2D(0, 0)
			UIUtil.ProjectWorldLocationToScreen(Character:GetUINamePlateLocation("EID_UI_NAMEPLATE"), ScreenLocation)

			local Position = ScreenLocation / self.DPIScale
			Position.Y = Position.Y - 50
			self.SelectedTipSlot:SetPosition(Position)
		else
			self.SelectedTipSlot:SetPosition(UE.FVector2D(0, -1000))
		end
	end
	--HUD
	local Major = MajorUtil.GetMajor()
	if Major == nil then return end
	local MajorLocation = Major:FGetActorLocation()
	local HUDIndex = 0
	local HUD = nil
	if self.IsShowNPCID and self.NpcDataList then
		for _,Data in pairs(self.NpcDataList) do
			HUD, HUDIndex = self:DrawHUD(Data, MajorLocation, HUDIndex)
			if HUD then
				HUD:SetText1("")
				HUD:SetText2(Data.ID)
			end
		end
	end

	if self.IsShowMonsterID and self.MonsterDataList then
		for _,Data in pairs(self.MonsterDataList) do
			if Data.Children then
				for _,ChildData in pairs(Data.Children) do
					HUD, HUDIndex = self:DrawHUD(ChildData, MajorLocation, HUDIndex)
					if HUD then
						HUD:SetText1(ChildData.ID)
						HUD:SetText2(self:GetMonsterProfileName(ChildData.ID))
					end
				end
			else
				HUD, HUDIndex = self:DrawHUD(Data, MajorLocation, HUDIndex)
				if HUD then
					HUD:SetText1(Data.ID)
					HUD:SetText2(self:GetMonsterProfileName(Data.ID))
				end
			end
		end
	end

	if self.IsShowSoundEffID and self.SoundEffDataList  then
		if self.SoundSelectedID ~= "" then
			AudioUtil.SetEnvSoundDebugDrawList({self.SoundSelectedID})
			_G.UE.UEnvSoundMgr.Get():SetShouldDrawDebugShape(true)
		end
	else
		_G.UE.UEnvSoundMgr.Get():SetShouldDrawDebugShape(false)
	end

	if self.WeatherSelectedID >= 0 then
		if self.IsShowWeatherID and self.WeatherDataList then
			_G.UE.UEnvMgr:Get():SetShouldDrawDebugShape(self.WeatherSelectedID, true)
		else
			_G.UE.UEnvMgr:Get():SetShouldDrawDebugShape(self.WeatherSelectedID, false)
		end
	end

	local PWorldDynDataMgr = _G.PWorldMgr.GetPWorldDynDataMgr()
    if PWorldDynDataMgr == nil then
        return
    end

	local MapDynDatas = PWorldDynDataMgr.MapDynDatas
    if MapDynDatas == nil then
        return
    end

	if self.IsShowExitRange or self.IsShowFishLocation then
		if nil ~= self.Box then
			local Location = _G.UE.FVector(self.Box.Center.X, self.Box.Center.Y, self.Box.Center.Z)
			local Extent = _G.UE.FVector(self.Box.Extent.X, self.Box.Extent.Y, self.Box.Extent.Z)
			local Rotator = _G.UE.FRotator(self.Box.Rotator.Y, self.Box.Rotator.Z, self.Box.Rotator.X)
			_G.UE.UKismetSystemLibrary.DrawDebugBox(_G.FWORLD(), Location, Extent, _G.UE.FLinearColor(0, 1, 0, 1), Rotator)
		end
		if nil ~= self.Cylinder then
			local Start = _G.UE.FVector(self.Cylinder.Start.X, self.Cylinder.Start.Y, self.Cylinder.Start.Z)
			local End = Start + _G.UE.FVector(0, 0, self.Cylinder.Height)
			_G.UE.UKismetSystemLibrary.DrawDebugCylinder(_G.FWORLD(), Start, End, self.Cylinder.Radius, 20, _G.UE.FLinearColor(0, 1, 0, 1))
		end
	end

	local StartIndex = HUDIndex + 1
	if StartIndex <= #self.HUDMap then
		for i=StartIndex,#self.HUDMap do
			UIUtil.SetIsVisible(self.HUDMap[i], false)
		end
	end
end

function FieldTestPanelView:GetMonsterProfileName(ID)
	local ProfileName = self.MonsterProfileNameCache[ID]
	if not ProfileName then
		local Monster = MonsterCfg:FindCfgByKey(ID)
		if Monster then
			ProfileName = Monster.ProfileName
			self.MonsterProfileNameCache[ID] = ProfileName
		end
	end
	return ProfileName or ""
end

function FieldTestPanelView:DrawHUD(Data, MajorLocation, HUDIndex)
	if Data.EntityID then
		local Actor = ActorUtil.GetActorByEntityID(Data.EntityID)
		if Actor then
			local ActorLocation = Actor:FGetActorLocation()
			local Dist = MajorLocation:Dist2D(ActorLocation)
			if Dist < 3000 then
				HUDIndex = HUDIndex + 1
				local ScreenLocation = UE.FVector2D(0, 0)
				UIUtil.ProjectWorldLocationToScreen(Actor:GetUINamePlateLocation("EID_UI_NAMEPLATE"), ScreenLocation)

				local Position = ScreenLocation / self.DPIScale
				Position.Y = Position.Y - 120
				local HUD = self.HUDMap[HUDIndex]
				if not HUD then
					--create new hud
					HUD = self:CreateHUD()
					self.HUDMap[HUDIndex] = HUD
				end
				UIUtil.SetIsVisible(HUD, true)
				UIUtil.CanvasSlotSetPosition(HUD.Root, Position)
				return HUD, HUDIndex
			end
		end
	end
	return nil, HUDIndex
end

function FieldTestPanelView:OnSelectedTabIndex(Index)
	if Index then
		for i=1, #self.SubPanelViews do
			self.AdapterTabList:SetSelectedIndex(Index)
			local SubView = self.SubPanelViews[i]
			--UIUtil.SetIsVisible(SubView, i == Index)
			UIUtil.CanvasSlotSetPosition(SubView, i == Index and UE.FVector2D(200, 0) or UE.FVector2D(-10000, -10000))
			--[[
			if i == Index then
				self:UpdateSubView(Index)
			end
			]]
		end

		self.SubPanelID = Index

		UIUtil.SetIsVisible(self.ToggleShow, not (Index == 3 or Index == 4), true)
		self:OnChangeIsShowObject()
		
	end
end

-- function FieldTestPanelView:UpdateSubView(Index)
-- 	---@type FieldTestSubPanelView
-- 	local SubView = self.SubPanelViews[Index]
-- 	if not SubView then
-- 		return
-- 	end

-- 	if Index == 1 then
-- 		--GMMgr:ReqGM1("cell cell entities")
-- 		if self.NpcDataList then
-- 			SubView:SetDataList(self.NpcDataList)
-- 		end
-- 	elseif Index == 2 then
-- 		--GMMgr:ReqGM1("cell cell entities")
-- 		if self.MonsterDataList then
-- 			SubView:SetDataList(self.MonsterDataList)
-- 		end
-- 	elseif Index == 3 then

-- 	elseif Index == 4 then
-- 		if self.FateDataList then
-- 			SubView:SetDataList(self.FateDataList)
-- 		end
-- 	elseif Index == 5 then
-- 		--ToDo 更新音效数据
-- 		if self.SoundEffDataList then
-- 			SubView:SetDataList(self.SoundEffDataList)
-- 		end
-- 	elseif Index == 6 then
-- 		if self.WeatherDataList then
-- 			SubView:SetDataList(self.WeatherDataList)
-- 		end
-- 	elseif Index == 7 then
-- 		if self.ChocoboNPCDataList then
-- 			SubView:SetDataList(self.ChocoboNPCDataList)
-- 		end
-- 		if self.MapTaskList then
-- 			SubView:SetChocoboDataList(self.MapTaskList)
-- 		end
-- 	elseif Index == 8 then
-- 		if self.ExitRangeDataList then
-- 			SubView:SetDataList(self.ExitRangeDataList)
-- 		end
-- 	elseif Index == 9 then
-- 		if self.FishLocationDataList then
-- 			SubView:SetDataList(self.FishLocationDataList)
-- 		end
-- 	elseif Index == 10 then
-- 		if self.AetherDataList then
-- 			SubView:SetDataList(self.AetherDataList)
-- 		end
-- 	end

-- end

function FieldTestPanelView:OnGMReceiveRes()
	if self.Subpanel1 then
		self.NpcDataList = _G.FieldTestMgr.NpcDataList
		self.SubPanel1:SetDataList(self.NpcDataList)
	end

	if self.SubPanel2 then
		self.MonsterDataList = _G.FieldTestMgr.MonsterDataList
		self.SubPanel2:SetDataList(self.MonsterDataList)
	end
end

function FieldTestPanelView:FindIndex(List, EntityID)
	local Index = 0
	local Items = List.Items
	local ParentIndex = 0
	for i = 1, #Items do
		Index = Index + 1
		ParentIndex = ParentIndex + 1
		if Items[i].EntityID == EntityID then
			return Index, ParentIndex
		end

		local Children = Items[i].ChildrenVM
		if Children then
			for j=1, #Children do
				Index = Index + 1
				if Children[j].EntityID == EntityID then
					return Index, ParentIndex
				end
			end
		end
	end
	return nil, nil
end

function FieldTestPanelView:OnManualSelectTarget(Params)
	if Params and Params.ULongParam1 then
		local Entity = Params.ULongParam1
		if self:SelectTarget(1, self.Subpanel1, Entity) then
			return
		end
		self:SelectTarget(2, self.Subpanel2, Entity)
	end
end

function FieldTestPanelView:OnMapEnter(Params)
	if Params and Params.CurrMapResID ~= self.LastMapResID then
		self:Hide()
	end
end

function FieldTestPanelView:OnToggleNPCChange(ToggleButton, ButtonState)
	self.IsShowNPCID = UIUtil.IsToggleButtonChecked(ButtonState)
end

function FieldTestPanelView:OnToggleMonsterChange(ToggleButton, ButtonState)
	self.IsShowMonsterID = UIUtil.IsToggleButtonChecked(ButtonState)
end

function FieldTestPanelView:OnToggleGatherChange(ToggleButton, ButtonState)
end

function FieldTestPanelView:OnToggleShowChange(ToggleButton, ButtonState)
	self:OnChangeIsShowObject()
end

function FieldTestPanelView:OnChangeIsShowObject()
	if self.SubPanelID == 0 then
		return
	end
	local ButtonState = self.ToggleShow:GetCheckedState()
	local IsShow = UIUtil.IsToggleButtonChecked(ButtonState)
	local PanelID = self.SubPanelID

	if PanelID == 1 then
		self.IsShowNPCID = IsShow
	elseif PanelID == 2 then
		self.IsShowMonsterID = IsShow
	elseif PanelID == 3 then
	elseif PanelID == 4 then
	elseif PanelID == 5 then
		self.IsShowSoundEffID = IsShow
	elseif PanelID == 6 then
		self.IsShowWeatherID = IsShow
	elseif PanelID == 7 then
		
	elseif PanelID == 8 then
		self.IsShowExitRange = IsShow
	elseif PanelID == 9 then
		self.IsShowFishLocation = IsShow
	end
end

function FieldTestPanelView:SelectTarget(No, SubPanel, Entity)
	if SubPanel.ItemVMList then
		local index, ParentIndex = self:FindIndex(SubPanel.ItemVMList, Entity)
		if index then
			self:OnSelectedTabIndex(No)
			--self:UpdateSubView(No)
			SubPanel:SetSelectedItem(index)
			SubPanel.AdapterItemList:ScrollToIndex(ParentIndex)
            -- 显示完信息之后取消选中，不然NPC会被GM传走
            _G.UE.USelectEffectMgr:Get():UnSelectActor(Entity)
			return true
		end
	end
	return false
end

-- 点击最小化FieldTest界面
function FieldTestPanelView:OnMinimizeClicked()
    UIViewMgr:ShowView(UIViewID.FieldTestMinimizationView)
	UIUtil.SetIsVisible(self.MovePanel, false)
end

-- 点击最大化FieldTest界面
function FieldTestPanelView:ShowMovePanel()
	UIUtil.SetIsVisible(self.MovePanel, true)
end

return FieldTestPanelView
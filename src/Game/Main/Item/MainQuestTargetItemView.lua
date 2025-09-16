---
--- Author: lydianwang
--- DateTime: 2023-02-20 15:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MapCfg = require("TableCfg/MapCfg")
local EventID = require("Define/EventID")

local MapUtil = require("Game/Map/MapUtil")
local ColorUtil = require("Utils/ColorUtil")
local RichTextUtil = require("Utils/RichTextUtil")

local QuestHelper = require("Game/Quest/QuestHelper")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local ProtoCS = require("Protocol/ProtoCS")
local TARGET_STATUS = ProtoCS.CS_QUEST_NODE_STATUS

local EToggleButtonState = _G.UE.EToggleButtonState

---@class MainQuestTargetItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFault UFButton
---@field BtnMap UFButton
---@field BtnPlace UFButton
---@field IconToggleButton UToggleButton
---@field QuestFault UFCanvasPanel
---@field QuestPlace UFCanvasPanel
---@field QuestSlot UFCanvasPanel
---@field RichTextMap URichTextBox
---@field RichTextTitle URichTextBox
---@field TableViewSlot UTableView
---@field TaskSpanCoordinate UFCanvasPanel
---@field TextFault UFTextBlock
---@field TextPlace UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimTrack UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainQuestTargetItemView = LuaClass(UIView, true)

function MainQuestTargetItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFault = nil
	--self.BtnMap = nil
	--self.BtnPlace = nil
	--self.IconToggleButton = nil
	--self.QuestFault = nil
	--self.QuestPlace = nil
	--self.QuestSlot = nil
	--self.RichTextMap = nil
	--self.RichTextTitle = nil
	--self.TableViewSlot = nil
	--self.TaskSpanCoordinate = nil
	--self.TextFault = nil
	--self.TextPlace = nil
	--self.AnimIn = nil
	--self.AnimTrack = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainQuestTargetItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainQuestTargetItemView:OnInit()
	self.ItemsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.ShowTargetID = nil
end

function MainQuestTargetItemView:OnDestroy()

end

function MainQuestTargetItemView:OnShow()

end

function MainQuestTargetItemView:OnHide()

end

function MainQuestTargetItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPlace, self.OnClickedBtnPlace)
	UIUtil.AddOnClickedEvent(self, self.BtnFault, self.OnClickedBtnPlace)
	UIUtil.AddOnClickedEvent(self, self.BtnMap, self.OnClickedBtnPlace)
end

function MainQuestTargetItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnterWorld)
end

function MainQuestTargetItemView:OnRegisterBinder()
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end

	local TargetBinders = {
		{ "Count", UIBinderValueChangedCallback.New(self, nil, self.OnCountChanged) },
		{ "MapIDList", UIBinderValueChangedCallback.New(self, nil, self.OnMapChanged) },
		{ "FaultTolerantDesc", UIBinderValueChangedCallback.New(self, nil, self.OnFaultTolerantStateChanged) },
		{ "ItemVMList", UIBinderUpdateBindableList.New(self, self.ItemsAdapter)},
		-- { "CountdownStr", UIBinderSetIsVisible.New(self, self.TimeLimit, false, true) },
		-- { "CountdownStr", UIBinderSetText.New(self, self.Text_Time) },
		--临时
		{ "CountdownStr", UIBinderValueChangedCallback.New(self, nil, self.TempOnCDChanged) },
	}
	self:RegisterBinders(TargetVM, TargetBinders)

	if TargetVM.OwnerChapterVM then
		local ChapterVMBinders = {
			{ "bTracking", UIBinderValueChangedCallback.New(self, nil, self.OnChapterTrackingChanged) },
			{ "TrackTargetID", UIBinderValueChangedCallback.New(self, nil, self.OnTargetTrackingChanged) },
		}
		self:RegisterBinders(TargetVM.OwnerChapterVM, ChapterVMBinders)
	end
end

function MainQuestTargetItemView:OnCountChanged(_)
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end

	local bShowItemView = TargetVM.IsShowItemView
	local CountText = ""
	if TargetVM.MaxCount and TargetVM.Count then
		local bShowNumber = (TargetVM.MaxCount > 1) and (TargetVM.Count < TargetVM.MaxCount)
		if bShowNumber or bShowItemView then
			CountText = string.format(" %d/%d", TargetVM.Count, TargetVM.MaxCount)
		end
	end

	local SpecialRuleSymbol = "" -- 目前直接放图片，正式版改成特殊符号
	if TargetVM.OwnerChapterVM then
		local SpecialRule = TargetVM.OwnerChapterVM.SpecialRule
		if SpecialRule ~= nil then
			if SpecialRule.bProfFixed then
				local IconPath = "Texture2D'/Game/UI/Texture/NewMain/UI_Main_Quest_Icon_limitation.UI_Main_Quest_Icon_limitation'"
				SpecialRuleSymbol = RichTextUtil.GetTexture(IconPath, 32, 32, -6) or ""
			end
		end
	end

	local TargetDesc = ColorUtil.ParseItemNameSceneStyle(TargetVM.Desc)
	self.RichTextTitle:SetText(string.format("%s%s%s", SpecialRuleSymbol, TargetDesc, CountText))

	local bFinished = (TargetVM.Status == TARGET_STATUS.CS_QUEST_NODE_STATUS_FINISHED)

	self.IconToggleButton:SetChecked(bFinished, false)
	UIUtil.SetOpacity(self.RichTextTitle, bFinished and 0.5 or 1)

	self:UpdateTrackingChanged()

	if self.ShowTargetID ~= TargetVM.TargetID then
		self:PlayAnimation(self.AnimIn)
	end
	self.ShowTargetID = TargetVM.TargetID
end

function MainQuestTargetItemView:OnChapterTrackingChanged(NewValue)
	--self:UpdateTrackingChanged()
end

function MainQuestTargetItemView:OnTargetTrackingChanged(_)
	self:UpdateTrackingChanged(true)
end

function MainQuestTargetItemView:UpdateTrackingChanged(IsPlayAnim)
	if not self.Params or not self.Params.Data then
		self.IconToggleButton:SetCheckedState(0, false)
		return
	end
	local TargetVM = self.Params.Data

	local OldState = self.IconToggleButton:GetCheckedState()
	if OldState == EToggleButtonState.Checked then -- 已完成的目标不改图标
		self:StopAnimation(self.AnimTrack)
		return
	end

	local OwnerChapterVM = TargetVM.OwnerChapterVM
	if OwnerChapterVM then
		local NearestTarget = false
		local bTracking = OwnerChapterVM.bTracking
		local TrackTargetID = OwnerChapterVM.TrackTargetID

		if OwnerChapterVM.TargetVMList:Length() <= 1 then
			NearestTarget = true
		else
			if not TrackTargetID then
				NearestTarget = true
			else
				if TargetVM.TargetID < 1000 and TargetVM.GroupedTargetIDList then
					for _,Val in ipairs(TargetVM.GroupedTargetIDList) do
						if Val == TrackTargetID then
							NearestTarget = true
							break
						end
					end
				else
					NearestTarget = TrackTargetID == TargetVM.TargetID
				end
			end
		end

		local ShowLocked = bTracking and NearestTarget
		local NewState = ShowLocked and EToggleButtonState.Locked or EToggleButtonState.Unchecked
		self.IconToggleButton:SetCheckedState(NewState, false)

		if IsPlayAnim then
			if self.IsHadChanged and ShowLocked then
				self:PlayAnimTrack()
			else
				self.IsHadChanged = true
			end
		end
	end
end

function MainQuestTargetItemView:OnMapChanged(MapIDList)
	if (MapIDList == nil) or (next(MapIDList) == nil) then
		self:SetMapName(nil)
		return
	end

	--[[
	local CurMapID = _G.PWorldMgr:GetCurrMapResID()

	for MapID, _ in pairs(MapIDList) do
		if MapID == CurMapID then
			self:SetMapName(nil)
			return
		end
	end
	]]

	self:SetMapName(next(MapIDList))
end

function MainQuestTargetItemView:OnFaultTolerantStateChanged(Desc)
	if Desc then
		--UIUtil.SetIsVisible(self.QuestPlace, false) --强制隐藏地点
		UIUtil.SetIsVisible(self.QuestFault, true)
		self.TextFault:SetText(Desc)
	else
		UIUtil.SetIsVisible(self.QuestFault, false)
	end
end

function MainQuestTargetItemView:SetMapName(MapID)
	self.MapID = MapID
	if MapID == nil then
		--UIUtil.SetIsVisible(self.QuestPlace, false)
		UIUtil.SetIsVisible(self.TaskSpanCoordinate, false)
		return
	end

	local MapName = MapCfg:FindValue(MapID, "DisplayName")
	--self.TextPlace:SetText(MapName)
	--UIUtil.SetIsVisible(self.QuestPlace, true)
	self.RichTextMap:SetText(MapName)
	UIUtil.SetIsVisible(self.TaskSpanCoordinate, true)
end

function MainQuestTargetItemView:OnClickedBtnPlace()
	if nil == self.Params then
		return
	end
	local TargetVM = self.Params.Data
	if TargetVM and TargetVM.OwnerChapterVM then
		local MapID = 0
		local UIMapID = 0
		local QuestID = TargetVM.OwnerChapterVM.QuestID
		local TargetID = TargetVM.TargetID
		if TargetID < 1000 then
			if TargetVM.GroupedTargetIDList and #TargetVM.GroupedTargetIDList > 0 then
				TargetID = TargetVM.GroupedTargetIDList[1]
			end
		end
		local TargetCfgItem = QuestHelper.GetTargetCfgItem(QuestID, TargetID)
		if TargetCfgItem then
			if TargetCfgItem.MapID > 0 then
				MapID = TargetCfgItem.MapID
			end
			if TargetCfgItem.UIMapID > 0 then
				UIMapID = TargetCfgItem.UIMapID
			end
		end
		if UIMapID == 0 then
			if MapID > 0 then
				UIMapID = MapUtil.GetUIMapID(MapID)
			else
				MapID = TargetVM.OwnerChapterVM.MapID
				if TargetVM.MapIDList and next(TargetVM.MapIDList) then
					local K = next(TargetVM.MapIDList)
					MapID = K
				end
				UIMapID = MapUtil.GetUIMapID(MapID)
			end
		end
		_G.QuestMgr.QuestReport:RecordCrossTask(QuestID, TargetVM.OwnerChapterVM.ChapterID, TargetVM.OwnerChapterVM.GenreID)
		_G.QuestMgr.QuestReport:ReportTaskTracking(QuestID, TargetVM.OwnerChapterVM.ChapterID, TargetVM.OwnerChapterVM.GenreID)
		_G.WorldMapMgr:ShowWorldMapTrackQuest(MapID, UIMapID, QuestID, TargetID)
	end
end

function MainQuestTargetItemView:TempOnCDChanged(NewValue)
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end
	if nil == TargetVM.OwnerChapterVM then return end
	TargetVM.OwnerChapterVM.TempCountdownStr = NewValue
end

function MainQuestTargetItemView:PlayAnimTrack()
	self:PlayAnimation(self.AnimTrack)
end

function MainQuestTargetItemView:OnGameEventEnterWorld(EventParams)
	if nil == self.Params then return end
	local TargetVM = self.Params.Data
	if nil == TargetVM then return end
	if nil == EventParams then return end
	if nil == TargetVM.MapIDList then return end

	--[[
	-- 重新刷新地图定位按钮,同地图内不同副本切换UI不会走Show逻辑
	local CurrMapResID = EventParams.CurrMapResID
	for MapID, _ in pairs(TargetVM.MapIDList) do
		if MapID == CurrMapResID then
			self:SetMapName(nil)
			return
		end
	end
	]]

	self:SetMapName(next(TargetVM.MapIDList))
end

return MainQuestTargetItemView
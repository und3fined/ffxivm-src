---
--- Author: Leo
--- DateTime: 2023-04-10 09:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GatheringLogVM = require("Game/GatheringLog/GatheringLogVM")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local EventID = require("Define/EventID")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local MajorUtil = require("Utils/MajorUtil")
local HorBarIndex = GatheringLogDefine.HorBarIndex

---@class GatheringLogListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAddFavor UFButton
---@field BtnAlarmClock UFButton
---@field BtnClock UFButton
---@field BtnFavor UFButton
---@field BtnItem UFButton
---@field ImgAC UFImage
---@field ImgACDisabled UFImage
---@field ImgACSet UFImage
---@field ImgAFFalse UFImage
---@field ImgAFTrue UFImage
---@field ImgAlarmClock UFImage
---@field ImgBg UFImage
---@field ImgBgSelect UFImage
---@field ImgCraftStar1 UFImage
---@field ImgCraftStar2 UFImage
---@field ImgCraftStar3 UFImage
---@field ImgCraftStar4 UFImage
---@field ImgCraftStar5 UFImage
---@field ImgFavor UFImage
---@field RedDot2 CommonRedDot2View
---@field RichTextName URichTextBox
---@field SlotItem CatheringLog96SlotView
---@field TextLevel UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogListItemView = LuaClass(UIView, true)

function GatheringLogListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAddFavor = nil
	--self.BtnAlarmClock = nil
	--self.BtnClock = nil
	--self.BtnFavor = nil
	--self.BtnItem = nil
	--self.ImgAC = nil
	--self.ImgACDisabled = nil
	--self.ImgACSet = nil
	--self.ImgAFFalse = nil
	--self.ImgAFTrue = nil
	--self.ImgAlarmClock = nil
	--self.ImgBg = nil
	--self.ImgBgSelect = nil
	--self.ImgCraftStar1 = nil
	--self.ImgCraftStar2 = nil
	--self.ImgCraftStar3 = nil
	--self.ImgCraftStar4 = nil
	--self.ImgCraftStar5 = nil
	--self.ImgFavor = nil
	--self.RedDot2 = nil
	--self.RichTextName = nil
	--self.SlotItem = nil
	--self.TextLevel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	self:AddSubView(self.SlotItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogListItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.RichTextName) },
		{ "GatheringGradeText", UIBinderSetText.New(self, self.TextLevel) },
		{ "bShowStarOne", UIBinderSetIsVisible.New(self, self.ImgCraftStar1) },
		{ "bShowStarTwo", UIBinderSetIsVisible.New(self, self.ImgCraftStar2) },
		{ "bShowStarThree", UIBinderSetIsVisible.New(self, self.ImgCraftStar3) },
		{ "bHidden", UIBinderSetIsVisible.New(self, self.ImgCraftStar4) },
		{ "bHidden", UIBinderSetIsVisible.New(self, self.ImgCraftStar5) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.ImgBgSelect) },
		{ "bSetClock", UIBinderSetIsVisible.New(self, self.ImgAlarmClock) },
		{ "bSetFavor", UIBinderSetIsVisible.New(self, self.ImgFavor) },
		{ "ID", UIBinderValueChangedCallback.New(self, nil, self.UpdateRedDot) },
	}
end

function GatheringLogListItemView:OnDestroy()

end

function GatheringLogListItemView:OnShow()
	
end

function GatheringLogListItemView:UpdateRedDot()
	if self.Params == nil then
		return
	end
	local Data = self.Params.Data
	if Data.ID == nil then
		return
	end
	local RedDotName = GatheringLogMgr.GatherItemRedDotNameList[Data.ID]
	if RedDotName then
		self.RedDot2:SetRedDotNameByString(RedDotName)
	else
		self.RedDot2:SetRedDotNameByString("")
	end	

	if Data.bSelect then
		self:DelRedDot()
	end
end

function GatheringLogListItemView:OnHide()

end

function GatheringLogListItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnBtnItemClick)
	UIUtil.AddOnClickedEvent(self, self.BtnFavor, self.OnBtnAddFavorClick)
    UIUtil.AddOnClickedEvent(self, self.BtnClock, self.OnBtnAlarmClockItemClick)
	
end

function GatheringLogListItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.UpdateGatherItemRedDot, self.UpdateRedDot)
end

function GatheringLogListItemView:DelRedDot()
	local Data = self.Params.Data	
	if Data.ID == nil then
		return
	end	
	local RedDotName = GatheringLogMgr.GatherItemRedDotNameList[Data.ID]
	if RedDotName then
		local RedDot = _G.RedDotMgr:FindRedDotNodeByName(RedDotName)
		local isDel = _G.RedDotMgr:DelRedDotByName(RedDotName)
		if isDel then
			GatheringLogMgr.GatherItemRedDotNameList[Data.ID] = nil
			local ParentRedDot = RedDot.ParentRedDotNode
			if ParentRedDot.SubRedDotList == nil or #ParentRedDot.SubRedDotList == 0 then
				_G.RedDotMgr:DelRedDotByName(ParentRedDot.RedDotName)
				local HorNode = ParentRedDot.ParentRedDotNode
				local HorIndex = HorNode.HorIndex
				if HorIndex == nil or HorIndex == 1 then
					GatheringLogMgr:SendMsgRemoveDropNewData(Data.GatheringJob, ParentRedDot.DropDownIndex)
				elseif HorIndex == 2 then
					local ReadVersion = nil
					if ParentRedDot.DropDownIndex == GatheringLogDefine.SpecialType.SpecialTypeCollection then
						ReadVersion = MajorUtil.GetMajorLevelByProf(Data.GatheringJob)
						--GatheringLogMgr:SendMsgRemoveDropNewData(Data.GatheringJob, nil, ParentRedDot.DropDownIndex, ReadVersion,true)
						GatheringLogMgr:SendMsgRemoveDropNewData(Data.GatheringJob, 100)
						GatheringLogMgr.SpecialDropRedDotLists[Data.GatheringJob][3] = nil
                        GatheringLogMgr:SpecialRedDotDataUpdate(Data.GatheringJob)
					else
						ReadVersion = GatheringLogMgr.GameVersionNum
						if GatheringLogMgr.UseLineageProf[Data.GatheringJob][1] then
							GatheringLogMgr:SendMsgRemoveDropNewData(Data.GatheringJob, nil, ParentRedDot.DropDownIndex, ReadVersion,true,1)
						end
						if GatheringLogMgr.UseLineageProf[Data.GatheringJob][2] then
							GatheringLogMgr:SendMsgRemoveDropNewData(Data.GatheringJob, nil, ParentRedDot.DropDownIndex, ReadVersion,true,2)
						end
					end
				end
			end
		end
	end
end

function GatheringLogListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.SlotItem:SetParams({Data = ViewModel})
end

---@type 当选中采集物
function GatheringLogListItemView:OnBtnItemClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	local LastFilterState = GatheringLogMgr.LastFilterState
	local GatherID = LastFilterState.GatherID
	local ID = ViewModel.ID
	if _G.GatheringLogMgr.SearchState == 0 and ID ~= GatherID then
		GatheringLogVM:UpdateSelectItemTab(ID)
		LastFilterState.GatherID = ID
	elseif _G.GatheringLogMgr.SearchState ~= 0 and ID ~= LastFilterState.IDofSearchItem then
		GatheringLogVM:UpdateSelectItemTab(ID)
		LastFilterState.IDofSearchItem = ID
	end
end

---@type 当点击收藏按钮
function GatheringLogListItemView:OnBtnAddFavorClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local LastFilterState = GatheringLogMgr.LastFilterState
	if LastFilterState.HorTabsIndex ~= HorBarIndex.CollectionIndex then
		return 
	end

	local SelfNoteType = GatheringLogDefine.GatheringLogNoteType
	if not ViewModel.bSetFavor then
        GatheringLogMgr:SendMsgMarkOrNotinfo(SelfNoteType, ViewModel.ID)
    else
        GatheringLogMgr:SendMsgCancelMark(SelfNoteType, ViewModel.ID)
    end
end

---@type 当点击闹钟按钮
function GatheringLogListItemView:OnBtnAlarmClockItemClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	local LastFilterState = GatheringLogMgr.LastFilterState
	if LastFilterState.HorTabsIndex ~= HorBarIndex.ClockIndex then
		return 
	end

	if ViewModel.bUseClock then
		local SelfNoteType = GatheringLogDefine.GatheringLogNoteType
		if not ViewModel.bSetClock then
			GatheringLogMgr:SendMsgAfterClockUpdate(SelfNoteType, ViewModel.ID)
		else
			GatheringLogMgr:SendMsgCancelClock(SelfNoteType, ViewModel.ID)
		end
	end
end

return GatheringLogListItemView
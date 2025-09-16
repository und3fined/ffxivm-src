--
-- Author: anypkvcai
-- Date: 2020-09-12 15:59:41
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local Switcher = require("Utils/ActionSwitcher")
local EventID = require("Define/EventID")
local MajorBuffVM = require("Game/Buff/VM/MajorBuffVM")
local MainTargetBuffsVM = require("Game/Buff/VM/MainTargetBuffsVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableViewEx = require("Game/Buff/UIAdapterTableViewEx")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EActorType = _G.UE.EActorType

---@class MainActorInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActorBuffDetail ActorBuffDetailView
---@field MainActorInfoItem MainActorInfoItemView
---@field MainActorTargetItem MainActorTargetItemView
---@field MainActorWarningItem MainActorWarningItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainActorInfoPanelView = LuaClass(UIView, true)

function MainActorInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActorBuffDetail = nil
	--self.MainActorInfoItem = nil
	--self.MainActorTargetItem = nil
	--self.MainActorWarningItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.EntityID = 0
end

function MainActorInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActorBuffDetail)
	self:AddSubView(self.MainActorInfoItem)
	self:AddSubView(self.MainActorTargetItem)
	self:AddSubView(self.MainActorWarningItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainActorInfoPanelView:OnInit()
	self.AdapterBuff = UIAdapterTableViewEx.CreateAdapter(self, self.MainActorInfoItem.TableViewBuff, self.OnBuffSelect, true)
	self.AdapterBuff:UpdateSettings(6, function(_, IsLimited) UIUtil.SetIsVisible(self.MainActorInfoItem.TextMore, IsLimited) end, false)

	self.AdapterBuffDetails = UIAdapterTableViewEx.CreateAdapter(self, self.ActorBuffDetail.TableViewActor, self.OnBuffDetailsSelect, true)
	self.AdapterBuffDetails:UpdateSettings(999, function(IsEmpty, _) if IsEmpty then self:HideBuffDetails() end end, true)

	self.ActorBinders = {
		{ "BufferVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterBuff) },
		{ "BufferVMList", 		UIBinderUpdateBindableList.New(self, self.AdapterBuffDetails) },
	}

	self.ActorVM = nil  ---@type ActorVM
end

function MainActorInfoPanelView:OnDestroy()
end

function MainActorInfoPanelView:OnShow()
	self:HideBuffDetails()
end

function MainActorInfoPanelView:OnHide()
	self:HideBuffDetails()
end

function MainActorInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.MainActorInfoItem.FButtonOpenBuffDetail, function()
        self.AdapterBuff:SelectFirstItem()
    end)
end

function MainActorInfoPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.SelectTarget,self.OnGameEventSelectTarget)
	-- self:RegisterGameEvent(EventID.UnSelectTarget, self.OnGameEventUnSelectTarget)
	self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
	-- self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
	-- self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventCharacterDead)
	self:RegisterGameEvent(EventID.Attr_Change_ChangeRoleId, self.OnGameEventChangeRoleIDChanged)
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)

	self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventActorDead)
	self:RegisterGameEvent(EventID.OtherCharacterDead, self.OnGameEventActorDead)
	self:RegisterGameEvent(EventID.ActorRevive, self.OnGameEventActorRevive)
end

function MainActorInfoPanelView:OnRegisterTimer()
end

function MainActorInfoPanelView:OnRegisterBinder()
	-- self:RegisterBinders(MainTargetBuffsVM, self.BuffDetailBinders)
end

function MainActorInfoPanelView:OnGameEventTargetChangeMajor(TargetID)
	local EntityID = TargetID
	if nil ~= EntityID and EntityID > 0 then
		local ActorType = ActorUtil.GetActorType(EntityID)
		if (ActorType == EActorType.Major or ActorType == EActorType.Player or ActorType == EActorType.Monster) 
				and ActorUtil.IsDeadState(EntityID) then
			-- 目标死亡不显示目标信息
			EntityID = 0
		end
	end
	self:UpdateTargetInternal(EntityID)
end

function MainActorInfoPanelView:OnGameEventChangeRoleIDChanged(Params)
	local EntityID = Params.ULongParam1
	local ChangeRoleID = Params.IntParam1
	if self.MainActorInfoItem.EntityID == EntityID then
		self.MainActorInfoItem:UpdateUI(EntityID)
	end

	if self.MainActorTargetItem.TargetID == EntityID then
		self.MainActorTargetItem:UpdateUI(self.EntityID, true)
	end
end

function MainActorInfoPanelView:OnGameEventActorDead(Params)
	local EntityID = Params and Params.ULongParam1 or MajorUtil.GetMajorEntityID()
	if EntityID == self.EntityID then
		self:UpdateTargetInternal(0)
	end
end

function MainActorInfoPanelView:OnGameEventActorRevive(Params)
	local EntityID = Params.ULongParam1
	if EntityID == _G.TargetMgr:GetMajorSelectedTarget() then
		self:UpdateTargetInternal(EntityID)
	end
end

function MainActorInfoPanelView:UpdateTargetInternal(EntityID)
	self.EntityID = EntityID

	self.MainActorInfoItem:UpdateUI(EntityID)

	if self.ActorVM then
		self:UnRegisterBinders(self.ActorVM, self.ActorBinders)
	end
	self.ActorVM = _G.ActorMgr:FindActorVM(EntityID)

	if self.ActorVM then
		self:RegisterBinders(self.ActorVM, self.ActorBinders)
	end

	self.MainActorTargetItem:UpdateUI(EntityID)
end

function MainActorInfoPanelView:EnableMoveView(Size)
	-- self.MainUIMoveControl:EnableView(Size)
end

--region BuffUI

function MainActorInfoPanelView:OnBuffSelect(Idx, ItemVM)
	self:ShowBuffDetails(ItemVM)
end

function MainActorInfoPanelView:OnBuffDetailsSelect(Idx, ItemVM)
	self.ActorBuffDetail.BuffInfoTips:ChangeVMAndUpdate(ItemVM)
end

function MainActorInfoPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	if not self.AdapterBuffDetails:GetSelectedIndex() then return end

	local MousePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if not UIUtil.IsUnderLocation(self.ActorBuffDetail.BuffInfoTips, MousePosition) and
    not UIUtil.IsUnderLocation(self.ActorBuffDetail.TableViewActor, MousePosition) then
		self:HideBuffDetails()
    end
end

function MainActorInfoPanelView:ShowBuffDetails(ItemVM)
	if not ItemVM then return end

	UIUtil.SetIsVisible(self.MainActorInfoItem.BuffInfoPanel, false)
	UIUtil.SetIsVisible(self.ActorBuffDetail, true)
	self.AdapterBuffDetails:SetSelectedItem(ItemVM)
	local DisplayIndex = self.AdapterBuffDetails:GetItemDataDisplayIndex(ItemVM)
	self.AdapterBuffDetails:ScrollIndexIntoView(DisplayIndex)
end

function MainActorInfoPanelView:HideBuffDetails()
	UIUtil.SetIsVisible(self.MainActorInfoItem.BuffInfoPanel, true)
	UIUtil.SetIsVisible(self.ActorBuffDetail, false)
	self.AdapterBuff:CancelSelected()
	self.AdapterBuffDetails:CancelSelected()
	self.ActorBuffDetail.BuffInfoTips:ChangeVMAndUpdate(nil)
end

--endregion

return MainActorInfoPanelView
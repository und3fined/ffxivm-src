---
--- Author: chriswang
--- DateTime: 2024-07-16 14:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MajorUtil = require("Utils/MajorUtil")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local GatherDrugSkillPanelVM = require("Game/GatheringJob/GatherDrugSkillPanelVM")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local UIBinderCanvasSlotSetPosition =  require("Binder/UIBinderCanvasSlotSetPosition")
local UIBinderSetIsVisible =  require("Binder/UIBinderSetIsVisible")
local MainControlPanelVM = require("Game/Main/VM/MainControlPanelVM")
local EventID = require("Define/EventID")

local SkillHandleSkillPositionMap <const> = SettingsHandleDefine.SkillHandleSkillPositionMap
local HandleFunctionSkill <const> = SettingsHandleDefine.HandleCustomActionType.FunctionSkill

local HandleSkillType = SettingsHandleDefine.HandleSkillType
---@class GatherDrugSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SkillDrugBtn SkillDrugBtnView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatherDrugSkillPanelView = LuaClass(UIView, true)

function GatherDrugSkillPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SkillDrugBtn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatherDrugSkillPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillDrugBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local DefaultSkillDrugPosition = {X = -676, Y = -170}

function GatherDrugSkillPanelView:OnInit()
	self.GatherDrugSkillPanelVM = GatherDrugSkillPanelVM.New()
	_G.SkillHandleMgr.GatherDrugSkillPanelVM = self.GatherDrugSkillPanelVM
end

function GatherDrugSkillPanelView:OnDestroy()

end

function GatherDrugSkillPanelView:OnShow()
	self.EntityID = MajorUtil.GetMajorEntityID()

	local LogicData = _G.SkillLogicMgr:GetMajorSkillLogicData()
	if LogicData == nil then
		return
	end

	self.SkillDrugBtn.bEnablePress = true
	self.GatherDrugSkillPanelVM:UpdateSkillDrugPosition()
end

function GatherDrugSkillPanelView:OnHide()

end

function GatherDrugSkillPanelView:OnRegisterUIEvent()

end

function GatherDrugSkillPanelView:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.GameHandleMode, self.OnGameHandleModeMotify)
	-- self:RegisterGameEvent(EventID.OnUpdateHandleCusAction, self.OnUpdateSkillDrugPosition)
	self:RegisterGameEvent(EventID.SimulatedTouchStartClick, self.OnSimulatedTouchStartClick)
	self:RegisterGameEvent(EventID.SimulatedTouchEndClick, self.OnSimulatedTouchEndClick)
end

function GatherDrugSkillPanelView:OnRegisterBinder()
	self:PostSkillEntityChange()
	local GatherDrugSkillPanelBinders = {
		{"IsInHandleMode", UIBinderValueChangedCallback.New(self, nil, self.OnHandleModeChanged)},
		{"CurInputAction", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateSkillDrugPosition)},
		{"CurPosition", UIBinderCanvasSlotSetPosition.New(self, self.SkillDrugBtn)},
		{"bSkillDrug", UIBinderSetIsVisible.New(self, self.SkillDrugBtn, false, true)}
	}
	self:RegisterBinders(self.GatherDrugSkillPanelVM, GatherDrugSkillPanelBinders)
end

function GatherDrugSkillPanelView:PostSkillEntityChange()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID == 0 then
        MajorEntityID = _G.PWorldMgr.MajorEntityID
    end
	local SubViews = self.SubViews
    for _, value in ipairs(SubViews) do
        if value["OnEntityIDUpdate"] ~= nil then
            value:OnEntityIDUpdate(MajorEntityID, true)
        end
    end
end

function GatherDrugSkillPanelView:OnUpdateSkillDrugPosition(InputAction)
	if self.GatherDrugSkillPanelVM.IsInHandleMode then
		if InputAction and SkillHandleSkillPositionMap[InputAction] then
			self.GatherDrugSkillPanelVM:SetCurPosition(SkillHandleSkillPositionMap[InputAction])
			self.GatherDrugSkillPanelVM.bSkillDrug = true
		else
			self.GatherDrugSkillPanelVM.bSkillDrug = false
		end
	else
		self.GatherDrugSkillPanelVM:SetCurPosition(DefaultSkillDrugPosition)
		self.GatherDrugSkillPanelVM.bSkillDrug = true
	end
end

function GatherDrugSkillPanelView:OnHandleModeChanged()
	self:OnUpdateSkillDrugPosition(_G.SkillHandleMgr.FunctionSkillInputAction)
end

local ZeroVector2D = _G.UE.FVector2D(0,0)
local function GetWidgetScreenPosition(Widget)
	if not Widget then return end
	local ScreenPosition = UIUtil.LocalToAbsolute(Widget, ZeroVector2D)
	if ScreenPosition.X ~= 0 and ScreenPosition.Y ~= 0 then
		local WidgetSize = UIUtil.GetAbsoluteSize(Widget)
		ScreenPosition.X = ScreenPosition.X + WidgetSize.X / 2
		ScreenPosition.Y = ScreenPosition.Y + WidgetSize.Y / 2
		return ScreenPosition
	end
end

function GatherDrugSkillPanelView:OnSimulatedTouchStartClick(Params)
	local IsGpProf = MajorUtil.IsGpProf()
	if not IsGpProf or not Params or Params.Index ~= HandleSkillType.FunctionSkill then return end
		local ScreenPosition = GetWidgetScreenPosition(self.SkillDrugBtn)
		if ScreenPosition then
			EventMgr:SendEvent(EventID.SimulatedTouchStartClickConfirm, ScreenPosition)
			self.bSimulatedPressed = true
		end
end

function GatherDrugSkillPanelView:OnSimulatedTouchEndClick(Params)
	local IsGpProf = MajorUtil.IsGpProf()
	if not IsGpProf or not Params or Params.Index ~= HandleSkillType.FunctionSkill then return end
	if self.bSimulatedPressed then
		local ScreenPosition = GetWidgetScreenPosition(self.SkillDrugBtn)
		if not ScreenPosition then
			ScreenPosition = ZeroVector2D
		end
		EventMgr:SendEvent(EventID.SimulatedTouchEndClickConfirm, ScreenPosition)
		self.bSimulatedPressed = false
	end
end


return GatherDrugSkillPanelView
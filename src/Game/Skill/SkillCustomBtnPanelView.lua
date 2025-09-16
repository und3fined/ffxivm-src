---
--- Author: henghaoli
--- DateTime: 2025-03-15 11:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillUtil = require("Utils/SkillUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local SkillLogicMgr = require("Game/Skill/SkillLogicMgr")
local SkillCustomMgr = require("Game/Skill/SkillCustomMgr")
local SkillCustomDefine = require("Game/Skill/SkillCustomDefine")
local EventID = require("Define/EventID")

local LSTR         <const> = LSTR
local EMapType     <const> = SkillUtil.MapType
local EButtonState <const> = SkillCustomDefine.EButtonState



---@class SkillCustomBtnPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Able1 SkillCustomBtnItemView
---@field Able10 SkillCustomBtnItemView
---@field Able11 SkillCustomBtnItemView
---@field Able12 SkillCustomBtnItemView
---@field Able2 SkillCustomBtnItemView
---@field Able3 SkillCustomBtnItemView
---@field Able4 SkillCustomBtnItemView
---@field Able5 SkillCustomBtnItemView
---@field Able6 SkillCustomBtnItemView
---@field Able7 SkillCustomBtnItemView
---@field Able8 SkillCustomBtnItemView
---@field Able9 SkillCustomBtnItemView
---@field AbleDrag SkillCustomBtnItemView
---@field BtnReorganization CommBtnMView
---@field GenAttackBtn SkillCustomGenAttackBtnView
---@field PanelAble UFCanvasPanel
---@field PanelAble2 UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field Root UFCanvasPanel
---@field TextHint UFTextBlock
---@field AnimIn1 UWidgetAnimation
---@field AnimIn1PVP UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCustomBtnPanelView = LuaClass(UIView, true)

function SkillCustomBtnPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Able1 = nil
	--self.Able10 = nil
	--self.Able11 = nil
	--self.Able12 = nil
	--self.Able2 = nil
	--self.Able3 = nil
	--self.Able4 = nil
	--self.Able5 = nil
	--self.Able6 = nil
	--self.Able7 = nil
	--self.Able8 = nil
	--self.Able9 = nil
	--self.AbleDrag = nil
	--self.BtnReorganization = nil
	--self.GenAttackBtn = nil
	--self.PanelAble = nil
	--self.PanelAble2 = nil
	--self.PanelSkill = nil
	--self.Root = nil
	--self.TextHint = nil
	--self.AnimIn1 = nil
	--self.AnimIn1PVP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCustomBtnPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Able1)
	self:AddSubView(self.Able10)
	self:AddSubView(self.Able11)
	self:AddSubView(self.Able12)
	self:AddSubView(self.Able2)
	self:AddSubView(self.Able3)
	self:AddSubView(self.Able4)
	self:AddSubView(self.Able5)
	self:AddSubView(self.Able6)
	self:AddSubView(self.Able7)
	self:AddSubView(self.Able8)
	self:AddSubView(self.Able9)
	self:AddSubView(self.AbleDrag)
	self:AddSubView(self.BtnReorganization)
	self:AddSubView(self.GenAttackBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCustomBtnPanelView:OnInit()
	self.BtnReorganization:SetText(LSTR(170104))  -- "恢复默认"
	self.TextHint:SetText(LSTR(170105))           -- "点击或拖动技能进行栏位编辑"
end

function SkillCustomBtnPanelView:OnDestroy()

end

function SkillCustomBtnPanelView:OnShow()
	SkillCustomMgr:Enter()
end

function SkillCustomBtnPanelView:OnHide()
	SkillCustomMgr:Leave()
end

function SkillCustomBtnPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReorganization, self.OnBtnRestoreClicked)
end

function SkillCustomBtnPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillCustomUnselected, self.OnSkillCustomUnselected)
	self:RegisterGameEvent(EventID.SkillEditingIndexSwap, self.OnSkillEditingIndexSwap)
end

function SkillCustomBtnPanelView:OnRegisterBinder()

end

function SkillCustomBtnPanelView:InitIndexViewMap()
	local IndexViewMap = {}
	for _, View in pairs(self.SubViews) do
		local ButtonIndex = View.ButtonIndex
		if ButtonIndex and ButtonIndex >= 0 then
			IndexViewMap[ButtonIndex] = View
		end
	end
	self.IndexViewMap = IndexViewMap
end

function SkillCustomBtnPanelView:Init(EntityID, MapType)
	-- 替换ButtonIndex
	for _, View in pairs(self.SubViews) do
		local InitButtonIndex = View.InitButtonIndex
		if InitButtonIndex then
			InitButtonIndex(View)
		end
	end
	self:InitIndexViewMap()

	-- 更新PVP/PVE布局
	if MapType == EMapType.PVP then
		self:PlayAnimationToEndTime(self.AnimIn1PVP)
	else
		self:PlayAnimationToEndTime(self.AnimIn1)
	end

	self.EntityID = EntityID
	local LogicData = SkillLogicMgr:GetSkillLogicData(EntityID)
	if not LogicData then
		FLOG_ERROR("[SkillCustomBtnPanelView:Init] Cannot find LogicData.")
		return
	end

	-- 初始化技能图标
	for _, View in pairs(self.SubViews) do
		local ButtonIndex = View.ButtonIndex
		if ButtonIndex then
			local bCanShow = View:OnSkillReplace(LogicData, MapType)
			UIUtil.SetIsVisible(View, bCanShow, true)
		end
	end
end

function SkillCustomBtnPanelView:RestoreToDefault()
	SkillCustomMgr:RestoreToDefault()
end

function SkillCustomBtnPanelView:OnBtnRestoreClicked()
	MsgBoxUtil.ShowMsgBoxTwoOp(
		self,
		LSTR(170104),  -- "恢复默认"
		LSTR(170106),  -- "是否确认恢复"
		self.RestoreToDefault,
		nil,
		LSTR(10003),  -- "取 消"
		LSTR(10002)   -- "确 认"
	)
end

function SkillCustomBtnPanelView:OnSkillCustomUnselected()
	local Index = SkillCustomMgr.CurrentSelectedIndex
	if Index then
		local View = self.IndexViewMap[Index]
		if View then
			View:Unselect()
		end
	end
end

function SkillCustomBtnPanelView:DragBegin(ButtonIndex, SkillID)
	local CurrentSelectedIndex = SkillCustomMgr.CurrentSelectedIndex
	if CurrentSelectedIndex and CurrentSelectedIndex ~= ButtonIndex then
		local View = self.IndexViewMap[CurrentSelectedIndex]
		if View then
			View:Unselect()
		end
	end

	local AbleDrag = self.AbleDrag
	UIUtil.SetIsVisible(AbleDrag, true)
	AbleDrag:SetSkillID(SkillID)
	AbleDrag.VM.ButtonState = EButtonState.Dragging
end

function SkillCustomBtnPanelView:DragEnd()
	UIUtil.SetIsVisible(self.AbleDrag, false)
end

local KIL <const> = UE.UKismetInputLibrary
local SBL <const> = UE.USlateBlueprintLibrary

function SkillCustomBtnPanelView:DragMove(MouseEvent)
    local MousePos = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local PanelGeo = self.PanelSkill:GetCachedGeometry()
	if MousePos and PanelGeo then
		local LocalPos = SBL.AbsoluteToLocal(PanelGeo, MousePos)
		UIUtil.CanvasSlotSetPosition(self.AbleDrag, LocalPos)
	end
end

function SkillCustomBtnPanelView:OnSkillEditingIndexSwap(IndexA, IndexB, OriginalIndexA, OriginalIndexB)
	local IndexViewMap = self.IndexViewMap
	local ViewA = IndexViewMap[IndexA]
	local ViewB = IndexViewMap[IndexB]

	local SkillID_A = ViewA.BtnSkillID
	local SkillID_B = ViewB.BtnSkillID

	ViewA.ButtonIndex = IndexB
	ViewA:SetSkillID(SkillID_B)
	IndexViewMap[IndexA] = ViewB
	ViewA:Unselect()

	ViewB.ButtonIndex = IndexA
	ViewB:SetSkillID(SkillID_A)
	IndexViewMap[IndexB] = ViewA
	ViewB:Unselect()
end

return SkillCustomBtnPanelView
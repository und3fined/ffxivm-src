---
--- Author: Administrator
--- DateTime: 2024-03-05 11:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CrafterWeaverVM = require("Game/Crafter/Weaver/CrafterWeaverVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")

local TimerMgr = _G.TimerMgr

local StateUpdateAnimTime = 0.53

---@class CrafterLeatherworkerMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CrafterLeatherworker CrafterLeatherworkerItemView
---@field ImgNeedleBg UFImage
---@field LeatherworkerPanel UFCanvasPanel
---@field LeatherworkerSkill1 CrafterSkillItemView
---@field LeatherworkerSkill2 CrafterSkillItemView
---@field LeatherworkerSkill3 CrafterSkillItemView
---@field NeedlePanel UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field TextTips UFTextBlock
---@field WeaverBottleDropEnter WeaverBottleDropEnterPanelView
---@field WeaverNeedle CrafterWeaverNeedleItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterLeatherworkerMainPanelView = LuaClass(UIView, true)

function CrafterLeatherworkerMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CrafterLeatherworker = nil
	--self.ImgNeedleBg = nil
	--self.LeatherworkerPanel = nil
	--self.LeatherworkerSkill1 = nil
	--self.LeatherworkerSkill2 = nil
	--self.LeatherworkerSkill3 = nil
	--self.NeedlePanel = nil
	--self.PanelSkill = nil
	--self.TextTips = nil
	--self.WeaverBottleDropEnter = nil
	--self.WeaverNeedle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterLeatherworkerMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CrafterLeatherworker)
	self:AddSubView(self.LeatherworkerSkill1)
	self:AddSubView(self.LeatherworkerSkill2)
	self:AddSubView(self.LeatherworkerSkill3)
	self:AddSubView(self.WeaverBottleDropEnter)
	self:AddSubView(self.WeaverNeedle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterLeatherworkerMainPanelView:OnInit()
	self.LeatherVM = CrafterWeaverVM.New()
	self.StepNum = 1
	self.BeginIndex = 1
	self.EndIndex = 3
	self.StateUpdateTimer = nil
	self.Binder = {
		{"bWeaverBottleDropEnter", UIBinderSetIsVisible.New(self, self.WeaverBottleDropEnter, false, true)},
		{"bWeaverNeedleItemVisable", UIBinderSetIsVisible.New(self, self.WeaverNeedle, false, true)},
	}
end

function CrafterLeatherworkerMainPanelView:OnDestroy()

end

function CrafterLeatherworkerMainPanelView:OnShow()
	self:InitCircleStates()
	-- 需求发生变更，暂时隐藏该UI
	UIUtil.SetIsVisible(self.NeedlePanel,false)
end

function CrafterLeatherworkerMainPanelView:OnHide()
	self:HideStateAnim()
	if self.StateUpdateTimer then
		TimerMgr:CancelTimer(self.StateUpdateTimer)
	end
	--解决断线重连的针线UI问题，强制取消拖拽
	-- self.WeaverNeedle:CancelDragEvent()
end

function CrafterLeatherworkerMainPanelView:OnRegisterUIEvent()

end

function CrafterLeatherworkerMainPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillCostUpdate, self.OnCrafterSkillCostUpdate)
end

function CrafterLeatherworkerMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.LeatherVM, self.Binder)
end

function CrafterLeatherworkerMainPanelView:OnEventCrafterSkillRsp(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local Data = MsgBody.CrafterSkill
			if nil == Data then
				FLOG_ERROR("Crafter CrafterLeatherworkerMainPanelView CrafterSkillRsp Data is nil")
				return
			end
			local LeatherStates = Data.Weaver
			if nil == LeatherStates then
				FLOG_ERROR("Crafter CrafterLeatherworkerMainPanelView CrafterSkillRsp WeaverStates is nil")
				return
			end
			self.StepNum = 1
			local Success = Data.Success
			local LastIndex = LeatherStates.PreIndex or self.LeatherVM.LastIndex
			local Step = LeatherStates.Index - LastIndex 
			local ChangeStates = {}
			self:CheckStateChange(LeatherStates,ChangeStates)
			if self.StateUpdateTimer then
				self:UnRegisterTimer(self.StateUpdateTimer)
			end
			if Step > 0 then
				self.StateUpdateTimer =  self:RegisterTimer( self.UpdateCrafterWeaverState, 0, StateUpdateAnimTime, Step,{WeaverStates = LeatherStates , MaxStep = Step, Success = Success})
			elseif LeatherStates.Index == 0 or Step == 0 then
				-- 重置下标或者发生断线重连,该情况下无法用Step计算步数,需要特殊处理，默认Step为1
				self.StepNum = 0
				self:UpdateCrafterWeaverState({WeaverStates = LeatherStates , MaxStep = 0, Success = Success})
			elseif Success == false then
				-- 技能释放失败
			else
				FLOG_ERROR("Crafter CrafterLeatherworkerMainPanelView CrafterSkillRsp WeaverStates index error")
				self:PrintRemoteWeavers(LeatherStates.Balls,LeatherStates.Index)
			end
			for _, value in ipairs(ChangeStates) do
				self:StateChangeAnim(value)
			end
		end
	end
end

function CrafterLeatherworkerMainPanelView:CheckStateChange(WeaverStates,ChangeStates)
	local LastWeaverStates = self.LeatherVM.LastWeaverStates
	for i = 1,7,1 do
		if LastWeaverStates[i] ~= WeaverStates.Balls[i] then
			ChangeStates[#ChangeStates + 1] = i
		end
	end
end

function CrafterLeatherworkerMainPanelView:UpdateCrafterWeaverState(Params)
	local WeaverStates = Params.WeaverStates
	local Success = Params.Success
	local Step = self.StepNum
	local MaxStep = Params.MaxStep
	local LastWeaverStates = self.LeatherVM.LastWeaverStates
	local LastBallState = LastWeaverStates[1] and LastWeaverStates[1] or 1
	local CurWeaverStates = {}
	for i = 1,7,1 do
		CurWeaverStates[i] = WeaverStates.Balls[i + Step]
	end
	local States = {Balls = CurWeaverStates , Index = WeaverStates.Index}
	self.LeatherVM:UpdateCircleItemList(States)
	self.CrafterLeatherworker:OnCrafterWeaverStateUpdate(States)
	-- 这里由于同步问题所以先隐藏特效，等待序列的推进动画播放结束后再播放光特效动画，不然无法保证球状态改变，光特效改变和序列推进是同步的
	self:HideStateAnim()
	if MaxStep == Step then
		self:RegisterTimer(self.ActivateAnim,StateUpdateAnimTime,0.1,1)
	end
	if Success then
		self.CrafterLeatherworker:OnWeaverStateMoveAnim(LastBallState)
	end
	self.StepNum = self.StepNum + 1
end

-- 针线拖拽状态改变
function CrafterLeatherworkerMainPanelView:ChangeDragState(IsInDrag)
	self.LeatherVM:OnDragStateChange(IsInDrag)
end

-- 初始化状态球序列
function CrafterLeatherworkerMainPanelView:InitCircleStates()
	local Data = self.Params

	if nil == Data then
		FLOG_ERROR("Crafter CrafterLeatherworkerMainPanelView StartMakeRsp Data is nil")
		self.LeatherVM:InitCircleItemList(nil)
		return
	end

	local WeaverStates = Data.Weaver

	if nil == WeaverStates then
		FLOG_ERROR("Crafter CrafterLeatherworkerMainPanelView StartMakeRsp WeaverStates is nil")
		self.LeatherVM:InitCircleItemList(nil)
		return
	end

	self.LeatherVM:InitCircleItemList(WeaverStates)
	self.CrafterLeatherworker:OnCrafterWeaverStateUpdate(WeaverStates)
	self:ActivateAnim()
end

function CrafterLeatherworkerMainPanelView:HideStateAnim()
	self.CrafterLeatherworker:OnStateHideAnim()
end

function CrafterLeatherworkerMainPanelView:ActivateAnim()
	self.CrafterLeatherworker:OnStateAnim()
end

function CrafterLeatherworkerMainPanelView:StateChangeAnim(index)
	self.CrafterLeatherworker:OnStateChangeAnim(index)
end

function CrafterLeatherworkerMainPanelView:PrintRemoteWeavers(WeaverStates,index)
	local str = "[CrafterLeatherworkerMainPanelView]:RemoteWeavers:"
	for i = 1 , 7 , 1 do
		if WeaverStates[i] then
			str = string.format("%s %d",str,WeaverStates[i])
		end
	end
	str = string.format("%s index = %d",str,index)
	print(str)
end

-- 处理断线重连
function CrafterLeatherworkerMainPanelView:OnCrafterReconnectionRsp(CrafterGet)
	local WeaverStates = CrafterGet.Weaver
	self.LeatherVM:InitCircleItemList(WeaverStates)
end

function CrafterLeatherworkerMainPanelView:OnCrafterSkillCDUpdate(Params)
	local BeginIndex = self.BeginIndex
	local EndIndex = self.EndIndex
	for Index = BeginIndex, EndIndex do
		self["LeatherworkerSkill" .. tostring(Index)]:OnCrafterSkillCDUpdate(Params)
	end
end

function CrafterLeatherworkerMainPanelView:OnCrafterSkillCostUpdate(Params)
	local BeginIndex = self.BeginIndex
	local EndIndex = self.EndIndex
	for Index = BeginIndex, EndIndex do
		self["LeatherworkerSkill" .. tostring(Index)]:OnCrafterSkillCostUpdate(Params)
	end
end

-- 断线重连测试
-- function CrafterLeatherworkerMainPanelView:TestReconnect()
-- 	_G.NetworkStateMgr:TestReconnect()
-- end


return CrafterLeatherworkerMainPanelView
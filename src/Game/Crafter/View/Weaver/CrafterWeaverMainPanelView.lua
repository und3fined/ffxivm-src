---
--- Author: Administrator
--- DateTime: 2023-12-14 16:42
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

---@class CrafterWeaverMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CrafterWeaver CrafterWeaverItemView
---@field ImgNeedleBg UFImage
---@field NeedlePanel UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field TextTips UFTextBlock
---@field WeaverBottleDropEnter WeaverBottleDropEnterPanelView
---@field WeaverNeedle CrafterWeaverNeedleItemView
---@field WeaverPanel UFCanvasPanel
---@field WeaverSkill1 CrafterSkillItemView
---@field WeaverSkill2 CrafterSkillItemView
---@field WeaverSkill3 CrafterSkillItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterWeaverMainPanelView = LuaClass(UIView, true)

function CrafterWeaverMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CrafterWeaver = nil
	--self.ImgNeedleBg = nil
	--self.NeedlePanel = nil
	--self.PanelSkill = nil
	--self.TextTips = nil
	--self.WeaverBottleDropEnter = nil
	--self.WeaverNeedle = nil
	--self.WeaverPanel = nil
	--self.WeaverSkill1 = nil
	--self.WeaverSkill2 = nil
	--self.WeaverSkill3 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterWeaverMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CrafterWeaver)
	self:AddSubView(self.WeaverBottleDropEnter)
	self:AddSubView(self.WeaverNeedle)
	self:AddSubView(self.WeaverSkill1)
	self:AddSubView(self.WeaverSkill2)
	self:AddSubView(self.WeaverSkill3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterWeaverMainPanelView:OnInit()
	self.WeaverVM = CrafterWeaverVM.New()
	self.StepNum = 1
	self.BeginIndex = 1
	self.EndIndex = 3
	self.StateUpdateTimer = nil
	self.Binders = {
		{"bWeaverBottleDropEnter", UIBinderSetIsVisible.New(self, self.WeaverBottleDropEnter, false, true)},
		{"bWeaverNeedleItemVisable", UIBinderSetIsVisible.New(self, self.WeaverNeedle, false, true)},
	}
end

function CrafterWeaverMainPanelView:OnDestroy()

end

function CrafterWeaverMainPanelView:OnShow()
	self:InitCircleStates()
	-- 需求发生变更，暂时隐藏该UI
	UIUtil.SetIsVisible(self.NeedlePanel,false)
end

function CrafterWeaverMainPanelView:OnHide()
	self:HideStateAnim()
	if self.StateUpdateTimer then
		TimerMgr:CancelTimer(self.StateUpdateTimer)
	end
	--解决断线重连的针线UI问题，强制取消拖拽
	-- self.WeaverNeedle:CancelDragEvent()
end

function CrafterWeaverMainPanelView:OnRegisterUIEvent()

end

function CrafterWeaverMainPanelView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
	self:RegisterGameEvent(EventID.CrafterSkillCDUpdate, self.OnCrafterSkillCDUpdate)
	self:RegisterGameEvent(EventID.CrafterSkillCostUpdate, self.OnCrafterSkillCostUpdate)
end

function CrafterWeaverMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.WeaverVM, self.Binders)
end

function CrafterWeaverMainPanelView:OnEventCrafterSkillRsp(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		if MajorEntityID == MsgBody.ObjID then
			local Data = MsgBody.CrafterSkill
			if nil == Data then
				FLOG_ERROR("Crafter CrafterWeaverMainPanelView CrafterSkillRsp Data is nil")
				return
			end
			local WeaverStates = Data.Weaver
			if nil == WeaverStates then
				FLOG_ERROR("Crafter CrafterWeaverMainPanelView CrafterSkillRsp WeaverStates is nil")
				return
			end
			self.StepNum = 1
			local Success = Data.Success
			local LastIndex = WeaverStates.PreIndex or self.WeaverVM.LastIndex
			local Step = WeaverStates.Index - LastIndex 
			local ChangeStates = {}
			self:CheckStateChange(WeaverStates,ChangeStates)
			if self.StateUpdateTimer then
				self:UnRegisterTimer(self.StateUpdateTimer)
			end
			if Step > 0 then
				self.StateUpdateTimer = self:RegisterTimer(self.UpdateCrafterWeaverState,0,StateUpdateAnimTime,Step,{WeaverStates = WeaverStates , MaxStep = Step, Success = Success})
			elseif WeaverStates.Index == 0 or Step == 0 then
				-- 重置下标或者发生断线重连,该情况下无法用Step计算步数,需要特殊处理，默认Step为1
				self.StepNum = 0
				self:UpdateCrafterWeaverState({WeaverStates = WeaverStates , MaxStep = 0, Success = Success})
			elseif Success == false then
				-- 技能释放失败
			else
				FLOG_ERROR("Crafter CrafterWeaverMainPanelView CrafterSkillRsp WeaverStates index error")
				self:PrintRemoteWeavers(WeaverStates.Balls,WeaverStates.Index)
			end
			for _, value in ipairs(ChangeStates) do
				self:StateChangeAnim(value)
			end
		end
	end
end

function CrafterWeaverMainPanelView:CheckStateChange(WeaverStates,ChangeStates)
	local LastWeaverStates = self.WeaverVM.LastWeaverStates
	for i = 1,7,1 do
		if LastWeaverStates[i] ~= WeaverStates.Balls[i] then
			ChangeStates[#ChangeStates + 1] = i
		end
	end
end

function CrafterWeaverMainPanelView:UpdateCrafterWeaverState(Params)
	local WeaverStates = Params.WeaverStates
	local Success = Params.Success
	local Step = self.StepNum
	local MaxStep = Params.MaxStep
	local LastWeaverStates = self.WeaverVM.LastWeaverStates
	local LastBallState = LastWeaverStates[1] and LastWeaverStates[1] or 1
	local CurWeaverStates = {}
	for i = 1,7,1 do
		CurWeaverStates[i] = WeaverStates.Balls[i + Step]
	end
	local States = {Balls = CurWeaverStates , Index = WeaverStates.Index}
	self.WeaverVM:UpdateCircleItemList(States)
	self.CrafterWeaver:OnCrafterWeaverStateUpdate(States)
	-- 这里由于同步问题所以先隐藏特效，等待序列的推进动画播放结束后再播放光特效动画，不然无法保证球状态改变，光特效改变和序列推进是同步的
	self:HideStateAnim()
	if MaxStep == Step then
		self:RegisterTimer(self.ActivateAnim,StateUpdateAnimTime,0.1,1)
	end
	if Success then
		self.CrafterWeaver:OnWeaverStateMoveAnim(LastBallState)
	end
	self.StepNum = self.StepNum + 1
end

-- 针线拖拽状态改变
function CrafterWeaverMainPanelView:ChangeDragState(IsInDrag)
	self.WeaverVM:OnDragStateChange(IsInDrag)
end

-- 初始化状态球序列
function CrafterWeaverMainPanelView:InitCircleStates()
	local Data = self.Params

	if nil == Data then
		FLOG_ERROR("Crafter CrafterWeaverMainPanelView StartMakeRsp Data is nil")
		self.WeaverVM:InitCircleItemList(nil)
		return
	end

	local WeaverStates = Data.Weaver

	if nil == WeaverStates then
		FLOG_ERROR("Crafter CrafterWeaverMainPanelView StartMakeRsp WeaverStates is nil")
		self.WeaverVM:InitCircleItemList(nil)
		return
	end

	self.WeaverVM:InitCircleItemList(WeaverStates)
	self.CrafterWeaver:OnCrafterWeaverStateUpdate(WeaverStates)
	self:ActivateAnim()
end

function CrafterWeaverMainPanelView:HideStateAnim()
	self.CrafterWeaver:OnStateHideAnim()
end

function CrafterWeaverMainPanelView:ActivateAnim()
	self.CrafterWeaver:OnStateAnim()
end

function CrafterWeaverMainPanelView:StateChangeAnim(index)
	self.CrafterWeaver:OnStateChangeAnim(index)
end

-- 处理断线重连
function CrafterWeaverMainPanelView:OnCrafterReconnectionRsp(CrafterGet)
	local WeaverStates = CrafterGet.Weaver
	self.WeaverVM:InitCircleItemList(WeaverStates)
	self.CrafterWeaver:OnCrafterWeaverStateUpdate(WeaverStates)
end

function CrafterWeaverMainPanelView:OnCrafterSkillCDUpdate(Params)
	local BeginIndex = self.BeginIndex
	local EndIndex = self.EndIndex
	for Index = BeginIndex, EndIndex do
		self["WeaverSkill" .. tostring(Index)]:OnCrafterSkillCDUpdate(Params)
	end
end

function CrafterWeaverMainPanelView:OnCrafterSkillCostUpdate(Params)
	local BeginIndex = self.BeginIndex
	local EndIndex = self.EndIndex
	for Index = BeginIndex, EndIndex do
		self["WeaverSkill" .. tostring(Index)]:OnCrafterSkillCostUpdate(Params)
	end
end

function CrafterWeaverMainPanelView:PrintLocalWeavers(WeaverStates)
	local str = "LZQ_check:LocalWeavers:"
	for i = 1 , 7 , 1 do
		if WeaverStates[i] then
			str = string.format("%s %d",str,WeaverStates[i])
		end
	end
	print(str)
end

function CrafterWeaverMainPanelView:PrintRemoteWeavers(WeaverStates,index)
	local str = "[CrafterWeaverMainPanelView]:RemoteWeavers:"
	for i = 1 , 7 , 1 do
		if WeaverStates[i] then
			str = string.format("%s %d",str,WeaverStates[i])
		end
	end
	str = string.format("%s index = %d",str,index)
	print(str)
end

-- 断线重连测试
-- function CrafterWeaverMainPanelView:TestReconnect()
-- 	_G.NetworkStateMgr:TestReconnect()
-- end

return CrafterWeaverMainPanelView
---
--- Author: Administrator
--- DateTime: 2023-12-29 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local EventID = require("Define/EventID")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local RedDotBaseName = GoldSauserMainPanelDefine.RedDotBaseName
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

---@class GoldSauserMainPanelBaseItemView : UIView
local GoldSauserMainPanelBaseItemView = LuaClass(UIView, true)


function GoldSauserMainPanelBaseItemView:Ctor()

end

function GoldSauserMainPanelBaseItemView:OnRegisterSubView()

end

function GoldSauserMainPanelBaseItemView:OnInit()

end

function GoldSauserMainPanelBaseItemView:OnDestroy()

end

function GoldSauserMainPanelBaseItemView:SetItemVM(ItemVM)
	self.ItemVM = ItemVM
	self:SetTheRedDotName()
end

function GoldSauserMainPanelBaseItemView:OnShow()
	self:ClearLockAndFlashPanel()
	self:UpdateViewContentDependOtherModuleSevInfo()
end

function GoldSauserMainPanelBaseItemView:SetCallBackFunc(FuncOwner, InCallBackFunc)
	self.FuncOwner = FuncOwner
    self.CallBackFunc = InCallBackFunc
end

function GoldSauserMainPanelBaseItemView:OnHide()

end

function GoldSauserMainPanelBaseItemView:OnRegisterUIEvent()

end

function GoldSauserMainPanelBaseItemView:OnBtnClicked()
	local ItemVM = self.ItemVM
	if not ItemVM or not ItemVM.GetBtnID or not ItemVM.GetGameType then
		MsgTipsUtil.ShowTips(LSTR(350020))
		return
	end
	if self.FuncOwner and self.CallBackFunc then
		self.CallBackFunc(self.FuncOwner, ItemVM:GetBtnID(), ItemVM:GetGameType())
	end
end

function GoldSauserMainPanelBaseItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ExcuteAsyncInfoFromOtherModule, self.OnUpdateEntranceSpecialState)
end

function GoldSauserMainPanelBaseItemView:OnRegisterBinder()
	if self.Binders then
		local Binders = {
			{ "State", UIBinderValueChangedCallback.New(self, nil, self.OnItemStateChanged)},
			--{ "IsEventAward", UIBinderValueChangedCallback.New(self, nil, self.OnItemHighlightParamChanged)},
			{ "IsGameNoFinish", UIBinderValueChangedCallback.New(self, nil, self.OnItemHighlightParamChanged)},
			{ "IsGameAward", UIBinderValueChangedCallback.New(self, nil, self.OnItemHighlightParamChanged)},
			{ "IsHighlight", UIBinderValueChangedCallback.New(self, nil, self.OnItemIsHighlightChanged)},
			{ "EventAwardRedDotVisible", UIBinderValueChangedCallback.New(self, nil, self.OnEventAwardRedDotVisibleChanged)},
		}
		for _, Binder in pairs(Binders) do
			table.insert(self.Binders, Binder)
		end
	else
		self.Binders = {
			{ "State", UIBinderValueChangedCallback.New(self, nil, self.OnItemStateChanged)},
			--{ "IsEventAward", UIBinderValueChangedCallback.New(self, nil, self.OnItemHighlightParamChanged)},
			{ "IsGameNoFinish", UIBinderValueChangedCallback.New(self, nil, self.OnItemHighlightParamChanged)},
			{ "IsGameAward", UIBinderValueChangedCallback.New(self, nil, self.OnItemHighlightParamChanged)},
			{ "IsHighlight", UIBinderValueChangedCallback.New(self, nil, self.OnItemIsHighlightChanged)},
			{ "EventAwardRedDotVisible", UIBinderValueChangedCallback.New(self, nil, self.OnEventAwardRedDotVisibleChanged)},
		}
	end
	if self.ItemVM then
		self:RegisterBinders(self.ItemVM, self.Binders)
	end

	self:BindExtraParams()
end

--- 金碟主界面状态变化效果设定
---@param InState GoldSauserMainPanelDefine.MainPanelItemState
function GoldSauserMainPanelBaseItemView:OnItemStateChanged(InState)
	-- 是否选中，控制选中状态UI显隐
	local bSelectedShow = InState == GoldSauserMainPanelDefine.MainPanelItemState.Selected
	self:SetItemSelectedState(bSelectedShow)

	-- 是否高亮，控制带查看状态显隐, 特效与选中特效区分，可同时存在
	local bHighlightShow = InState == GoldSauserMainPanelDefine.MainPanelItemState.Highlight
	self:SetItemHighLightState(bHighlightShow)
end

function GoldSauserMainPanelBaseItemView:OnItemHighlightParamChanged(HighlightParam)
	local EntranceVM = self.ItemVM
	if not EntranceVM then
		return
	end

	local BtnID = EntranceVM.BtnID
	if not BtnID then
		return
	end

	if not GoldSauserMainPanelMgr:IsGameUnlock(BtnID) then -- 未解锁功能，不进行高亮提示
		return
	end
	
	if HighlightParam then
		self.ItemVM:SetIsHighlight(true)
	else
		if not self.ItemVM:GetIsGameNoFinish() and not self.ItemVM:GetIsGameAward() then
			self.ItemVM:SetIsHighlight(false)
		end
	end
end

function GoldSauserMainPanelBaseItemView:OnItemIsHighlightChanged(IsHighlight)
	if IsHighlight then
		if self.ItemVM:GetState() == GoldSauserMainPanelDefine.MainPanelItemState.Default then
			self.ItemVM:SetState(GoldSauserMainPanelDefine.MainPanelItemState.Highlight)
		end
	else
		if self.ItemVM:GetState() == GoldSauserMainPanelDefine.MainPanelItemState.Highlight then
			self.ItemVM:SetState(GoldSauserMainPanelDefine.MainPanelItemState.Default)
		end
	end
end

function GoldSauserMainPanelBaseItemView:OnEventAwardRedDotVisibleChanged(bVisible)
	local RedDotWidget = self:GetTheRedDotWidget()
	if not RedDotWidget then
		return
	end
	RedDotWidget:SetRedDotUIIsShow(bVisible)
end

function GoldSauserMainPanelBaseItemView:OnUpdateEntranceSpecialState(GameID)
	local ViewModel = self.ItemVM
	if not ViewModel then
		return
	end
	local Id = ViewModel.BtnID
	if not Id then
		return
	end

	if GameID ~= Id then
		return
	end

	self:UpdateViewContentDependOtherModuleSevInfo()
end

--- 基类方法，可被子类重写(蓝图结构差异)
function GoldSauserMainPanelBaseItemView:GetTheSelectedPanel()
	return self.PanelFocus
end

function GoldSauserMainPanelBaseItemView:GetTheHighlightPanel()
	return self.PanelTobeViewed
end

function GoldSauserMainPanelBaseItemView:GetTheHighlightIcon()
	return self.IconTobeViewed
end

function GoldSauserMainPanelBaseItemView:GetTheRedDotWidget()
	return self.RedDot
end

function GoldSauserMainPanelBaseItemView:GetTheAnimClick()
	return self.AnimClick
end

function GoldSauserMainPanelBaseItemView:GetTheAnimOwner()
	return self
end

function GoldSauserMainPanelBaseItemView:BindExtraParams()
	
end

--- 基类方法，可被子类重写(蓝图结构差异) end ---

--- 设置Item的UI表现
function GoldSauserMainPanelBaseItemView:SetItemSelectedState(bSelected)
	local SelectedPanel = self:GetTheSelectedPanel()
	if not SelectedPanel then
		return
	end
	UIUtil.SetIsVisible(SelectedPanel, bSelected)

	if bSelected then
		local AnimClick = self:GetTheAnimClick()
		local AnimOwner = self:GetTheAnimOwner()
		if AnimClick and AnimOwner then
			AnimOwner:PlayAnimation(AnimClick)
		end
	end
end

function GoldSauserMainPanelBaseItemView:SetItemHighLightState(bHighlight)
	local HighlightPanel = self:GetTheHighlightPanel()
	if not HighlightPanel then
		return
	end
	UIUtil.SetIsVisible(HighlightPanel, bHighlight)
	local HighlightIcon = self:GetTheHighlightIcon()
	if not HighlightIcon then
		return
	end
	UIUtil.SetIsVisible(HighlightIcon, bHighlight)
end

function GoldSauserMainPanelBaseItemView:SetTheRedDotName()
	local RedDotWidget = self:GetTheRedDotWidget()
	if not RedDotWidget then
		return
	end
	RedDotWidget:SetIsCustomizeRedDot(true)
end

function GoldSauserMainPanelBaseItemView:UpdateViewContentDependOtherModuleSevInfo()
	local ViewModel = self.ItemVM
	if not ViewModel then
		self:LockTheEntranceForModuleNotOpen()
		return
	end
	local Id = ViewModel.BtnID
	if not Id then
		self:LockTheEntranceForModuleNotOpen()
		return
	end
	local MsgUpdated = GoldSauserMainPanelMgr:GetTheMsgUpdateState(Id)
	if not MsgUpdated then
		return
	end
	self:InitEntranceStateNotAlwaysExist(Id)
	GoldSauserMainPanelMgr:SetTheMsgUpdateState(Id, false) -- 整个界面刷新流程的最后位置，重置Flag
end

function GoldSauserMainPanelBaseItemView:ClearLockAndFlashPanel()
	local PanelLock = self.PanelLock
	if PanelLock then
		UIUtil.SetIsVisible(PanelLock, false)
	end

	local PanelFlash = self.PanelFlash
	if PanelFlash then
		UIUtil.SetIsVisible(PanelFlash, false)
	end
end

function GoldSauserMainPanelBaseItemView:InitEntranceStateNotAlwaysExist(Id)
	local bLocked = GoldSauserMainPanelMgr:IsGameEntranceLocked(Id)
	local PanelLock = self.PanelLock
	if PanelLock then
		UIUtil.SetIsVisible(PanelLock, bLocked)
		self.ItemVM.IsEntranceLocked = bLocked
	end

	local PanelFlash = self.PanelFlash
	if PanelFlash then
		UIUtil.SetIsVisible(PanelFlash, not bLocked)
		if not bLocked then
			local _, EndTimeStamp =  GoldSauserMainPanelMgr:GetGameTimeLimitInfo(Id)
			local bEnd = TimeUtil.GetServerTimeMS() >= EndTimeStamp
			UIUtil.SetIsVisible(PanelFlash, not bEnd)
			if not self:IsAnimationPlaying(self.AnimIn) then
				self:PlayAnimIn()
			end
		end
	end
end

--- 针对未配置的内容或者出错的内容直接显示上锁状态
function GoldSauserMainPanelBaseItemView:LockTheEntranceForModuleNotOpen()
	local PanelLock = self.PanelLock
	if PanelLock then
		UIUtil.SetIsVisible(PanelLock, true)
	end

	local PanelFocus = self:GetTheSelectedPanel()
	if PanelFocus then
		UIUtil.SetIsVisible(PanelFocus, false)
	end
end

return GoldSauserMainPanelBaseItemView
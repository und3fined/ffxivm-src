---
--- Author: Administrator
--- DateTime: 2024-01-18 20:52
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

local FishMainPanelVM = require("Game/Fish/FishMainPanelVM")
local FishVM = require("Game/Fish/FishVM")


local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local UKismetInputLibrary = UE.UKismetInputLibrary

local BtnLockTime = 3

---@class FishMainPanelNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Panel FishNewPanelItemView
---@field Schedule FishNewTimeItemView
---@field SkillSitBtn SkillSitBtnView
---@field ThingTips FishNewThingTipsItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishMainPanelNewView = LuaClass(UIView, true)

local SitBtnHideDelay = 3 --second

function FishMainPanelNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Panel = nil
	--self.Schedule = nil
	--self.SkillSitBtn = nil
	--self.ThingTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishMainPanelNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Panel)
	self:AddSubView(self.Schedule)
	self:AddSubView(self.SkillSitBtn)
	self:AddSubView(self.ThingTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishMainPanelNewView:OnInit()
	self.FishMainPanelVM = FishMainPanelVM.New()
	self.ShowTimer = nil
	self.FishID = 0
	self.FishCount = 0
	self.FishCollectionValue = 0
	self.FishSize = 0
	self.SitBtnHideTimer = 0
	self.bSitBtnLock = false
	self.AreaID = 0
	self.Binder = {
		{ "bBiteTimerPanel",UIBinderSetIsVisible.New(self, self.Schedule, false, true)},
		{ "bFishThingTips",UIBinderSetIsVisible.New(self, self.ThingTips, false, true)},
		{ "bFishAreaPanel",UIBinderSetIsVisible.New(self, self.Panel, false, true)},
	}
end

function FishMainPanelNewView:OnDestroy()

end

function FishMainPanelNewView:OnShow()
	local Params = self.Params
	if Params and Params.AreaID and Params.AreaID ~= 0 then
		self:OnEnterFishArea(Params.AreaID)
	else
		self:OnExitFishArea()
	end
	self:ChangeBtnSitShowState(false)
end

function FishMainPanelNewView:OnHide()
	-- Hide时计时器UI没有卸载处理，手动卸载
	self.Schedule:HideClearData()
	self.Panel:ClearFishReleaseData()
end


function FishMainPanelNewView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.SkillSitBtn.BtnSit, self.OnClickBtnSit)
end

function FishMainPanelNewView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FishDrop, self.OnFishDrop)
	self:RegisterGameEvent(EventID.FishLiftStart, self.OnFishLiftStart)
	self:RegisterGameEvent(EventID.FishLift, self.OnFishLift)
	self:RegisterGameEvent(EventID.FishEnd, self.OnFishEnd)
	self:RegisterGameEvent(EventID.EnterFishArea, self.OnEnterFishArea)
	self:RegisterGameEvent(EventID.ExitFishArea, self.OnExitFishArea)
	self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventtargetChange)

	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function FishMainPanelNewView:OnRegisterBinder()
	self:RegisterBinders(self.FishMainPanelVM,self.Binder)
end

function FishMainPanelNewView:SetFishAreaID(FishAreaID)
	self.AreaID = FishAreaID
	-- 这里需要重新设置Params，因为如果修改捕鱼UI层级会重新ShowView，根据Params设置渔场信息
	rawset(self, "Params", {AreaID = FishAreaID})
	FishVM:SetFishAreaID(FishAreaID)
	self.Panel:SetFishAreaID(FishAreaID)
	self.Panel:ClearFishReleaseData()
end

function FishMainPanelNewView:OnFishDrop(Params)
	local Time = Params.BiteTime
	self.FishMainPanelVM:OnFishDrop()
	self.Schedule:OnFishDrop(Time)
end

function FishMainPanelNewView:OnFishLift(Params)
	local FishID = Params.FishID
	local FishCount = Params.FishCount or 0
	local FishSize = Params.FishSize
	local FishValue = Params.FishValue
	self.FishID = FishID
	self.FishCount = FishCount
	self.FishCollectionValue = FishValue
	self.FishSize = FishSize
	self:OnGetFishItem()
end

function FishMainPanelNewView:OnFishLiftStart()
	self.Schedule:OnFishLift()
end

function FishMainPanelNewView:OnFishEnd(bQuit)
	self.Schedule:OnFishEnd()
	self.FishMainPanelVM:OnFishEnd()
end

function FishMainPanelNewView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UIViewMgr = _G.UIViewMgr
	local UIViewID = _G.UIViewID
	if UIViewMgr:IsViewVisible(UIViewID.FishReleaseTipsPanel) then
		local View = UIViewMgr:FindVisibleView(UIViewID.FishReleaseTipsPanel)
		local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
		if UIUtil.IsUnderLocation(View.PanelTips, MousePosition) == false and
		UIUtil.IsUnderLocation(self.Panel, MousePosition) == false then
		    self.Panel:SetTableViewIntemUnClicked()
			UIViewMgr:HideView(UIViewID.FishReleaseTipsPanel,false)
	    end
	end
end

function FishMainPanelNewView:StorageReleaseFishData(FishID)
	self.Panel:StorageReleaseFishData(FishID)
end

function FishMainPanelNewView:OnEnterFishArea(AreaID)
	self.Panel:PlayShowAnimation(true)
	self:SetFishAreaID(AreaID)
end

function FishMainPanelNewView:OnExitFishArea(_)
	rawset(self, "Params", nil)
	self.Params = nil
	self.Panel:OnExitFishArea()
	self.Panel:PlayShowAnimation(false)
end

function FishMainPanelNewView:DelayOnSitBtnHide()
	UIUtil.SetIsVisible(self.SkillSitBtn, false)
end

function FishMainPanelNewView:DelayOnFishLift()
	local FishID = self.FishID 
	local FishCount = self.FishCount
	self.Panel:OnFishLift(FishID,FishCount)
end

function FishMainPanelNewView:OnClickBtnSit()
	if not self.bSitBtnLock then
		_G.FishMgr:SendMajorSitChange()
		-- 这里设置一个按钮的内置CD防止玩家连点
		self.bSitBtnLock = true
		self:RegisterTimer(self.UnLockBtnSit,BtnLockTime,1,1)
	end
end

function FishMainPanelNewView:OnGetFishItem()
	local FishID = self.FishID
	local FishCount = self.FishCount
	local FishSize = self.FishSize
	local FishValue = self.FishCollectionValue
	self.FishMainPanelVM:OnFishLift()
	local IsNew = self.Panel:FishIsNew(FishID)
	self.ThingTips:OnFishLift(FishID,FishCount,FishSize,FishValue,IsNew)
end

-- 捕鱼坐按钮的显隐规则修改，现在只有在钓鱼状态下才显示该按钮，退出钓鱼状态则不显示
function FishMainPanelNewView:ChangeBtnSitShowState(bShow)
	UIUtil.SetIsVisible(self.SkillSitBtn, bShow, true)
end

-- 渔场Ui和选中的UI冲突，这里暂时处理一下，最好还是在设计上处理这个问题
function FishMainPanelNewView:OnGameEventtargetChange(TargetID)
	if TargetID == 0 then
		self.FishMainPanelVM:SetFishAreaPanel(true)
	else
		self.FishMainPanelVM:SetFishAreaPanel(false)
	end
end

function FishMainPanelNewView:UnLockBtnSit()
	self.bSitBtnLock = false
end

return FishMainPanelNewView
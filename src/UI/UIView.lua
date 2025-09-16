--
-- Author: anypkvcai
-- Date: 2020-08-05 15:43:32
-- Description: 界面的基类
-- 	子类可重写On开头的函数（工具生成的模板里已经自动添加了On开头的函数）
-- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=336458657

local LuaClass = require("Core/LuaClass")
local UIShowType = require("UI/UIShowType")
local ObjectGCType = require("Define/ObjectGCType")
local UILayer = require("UI/UILayer")
local UIEventRegister = require("Register/UIEventRegister")
local GameEventRegister = require("Register/GameEventRegister")
local TimerRegister = require("Register/TimerRegister")
local BinderRegister = require("Register/BinderRegister")
local LuaUEObject = require("Core/LuaUEObject")
local LogMgr = require("Log/LogMgr")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

local ESlateVisibility = _G.UE.ESlateVisibility
local FLOG_ERROR = LogMgr.Error
local FLOG_WARNING = LogMgr.Warning

---@class UIView : UUserWidget
---@field Params any                @显示UI时传入的参数，OnInit和OnRegisterUIEvent函数中参数还未赋值
---@field ViewID UIViewID
---@field Config UIViewConfig
---@field ShowType UIShowType
---@field GCType ObjectGCType
---@field Layer UILayer
---@field UIEventRegister UIEventRegister
---@field GameEventRegister GameEventRegister
---@field TimerRegister TimerRegister
---@field BinderRegister BinderRegister
---@field ViewModel UIViewModel
---@field SubViews table<UIView>
---@field IsInitView boolean
---@field IsShowView boolean
local UIView = LuaClass(LuaUEObject)

function UIView:Ctor()
	rawset(self, "Params", nil)
	rawset(self, "bInheritedParams", true)
	rawset(self, "ViewID", 0)
	rawset(self, "Config", nil)
	rawset(self, "ShowType", UIShowType.Normal)
	rawset(self, "GCType", ObjectGCType.LRU)
	rawset(self, "Layer", UILayer.Normal)
	rawset(self, "ParentView", nil)
	rawset(self, "SubViews", nil)
	rawset(self, "IsInitView", false)
	rawset(self, "IsShowView", false)
	rawset(self, "IsLoadView", false)
	rawget(self, "bInPool", false)

	rawset(self, "HideDelayTimer", 0)        --延迟隐藏时showview需取消隐藏操作
	rawset(self, "IsExcutePlayAnimIn", false) --是否执行过
	rawset(self, "IsExcutePlayAnimLoop", false) --是否执行过
	rawset(self, "IsForceImmediatelyHide", false)

	rawset(self, "UIEventRegister", nil)
	rawset(self, "GameEventRegister", nil)
	rawset(self, "TimerRegister", nil)
	rawset(self, "BinderRegister", nil)
end

---InitView
---@param ViewID UIViewID
---@param Config UIViewConfig
function UIView:InitView(ViewID, Config)
	if rawget(self, "IsInitView") then
		return
	end

	rawset(self, "ViewID", ViewID)
	rawset(self, "Config", Config)
	rawset(self, "ShowType", Config and Config.ShowType or UIShowType.Normal)
	rawset(self, "GCType", Config and Config.GCType or self.GCType or ObjectGCType.LRU)
	rawset(self, "Layer", Config and Config.Layer or UILayer.Normal)
	rawset(self, "bInheritedParams", true)
	rawset(self, "SubViews", {})

	self:OnRegisterSubView()

	self:OnInit()

	self:InitSubView()

	self:OnRegisterUIEvent()

	rawset(self, "IsInitView", true)

	self:OnPostInit()
end

---DestroyView
function UIView:DestroyView(Params)
	if not rawget(self, "IsInitView") then
		return
	end

	self:DestroySubView(Params)

	self:UnRegisterAllUIEvent()
	self:UnRegisterAllGameEvent()
	self:UnRegisterAllTimer()
	self:UnRegisterAllBinder()

	self:OnDestroy(Params)

	self.ParentView = nil
	self.SubViews = nil
	self.Params = nil

	self.ViewID = nil

	if self:GetIsInPool() then
		WidgetPoolMgr:PrepareRecycleWidget(self)
	end

	rawset(self, "IsInitView", false)
end

---ShowView
---@param Params any
function UIView:ShowView(Params)
	if rawget(self, "IsShowView") then
		return
	end

	local ObjectName = self:GetClassName()
	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:ShowView_%s", ObjectName))

	rawset(self, "IsShowView", true)
	rawset(self, "IsHiding", false)

	--TODO 调试用
	rawset(self, "ObjectName", self:GetClassName())
	rawset(self, "AncestorName", self:GetAncestorClassName() or self.ObjectName)

	-- self.Params = table.pack(...)
	if rawget(self, "bInheritedParams") then
		rawset(self, "Params", Params)
	end

	--self:OnRegisterNetMsg()
	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:ShowView_OnRegisterGame_%s", ObjectName))
		self:OnRegisterGameEvent()
		self:OnRegisterTimer()
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:ShowView_OnRegisterBinder_%s", ObjectName))
		self:OnRegisterBinder()
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:ShowView_OnShow_%s", ObjectName))
		self:OnShow()
	end

	if not self:GetIsShowView() then
		FLOG_WARNING("UIView:ShowView View is hidden, traceback=%s", debug.traceback())
		return
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:ShowView_OnSubShow_%s", ObjectName))
		self:ShowSubView()
	end

	self:PlayAnimIn()
	self:PlayAnimLoop()
	self:SetFontForAllTextWidgetInLua()
	self:PostShowView()
end

function UIView:GetAncestorClassName()
	local ParentView = rawget(self, "ParentView")

	while ParentView do
		if nil == ParentView.ParentView then
			return ParentView:GetClassName()
		end

		ParentView = ParentView.ParentView
	end
end

---AbortHidingView
---@private
function UIView:AbortHidingView()
	if self:CancelHideDelayTimer() then
		rawset(self, "IsHiding", false)
		if nil ~= self.PlayAllAnimationsToEnd then
			self:PlayAllAnimationsToEnd()
		end
	end
end

function UIView:CancelHideDelayTimer()
	local HideDelayTimer = rawget(self, "HideDelayTimer")
	if nil ~= HideDelayTimer and HideDelayTimer > 0 then
		self:UnRegisterTimer(HideDelayTimer)
		rawset(self, "HideDelayTimer", 0)
		return true
	end

	return false
end

---HideView
function UIView:HideView(Params, bImmediatelyHide)
	if not rawget(self, "IsShowView") then
		return
	end

	local ObjectName = self:GetClassName()

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideView_%s", ObjectName))

	do 
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideView_Subview_%s", ObjectName))

		self:HideSubView(Params, bImmediatelyHide)
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideView_UnRegister_%s", ObjectName))
	self:UnRegisterAllGameEvent()
	self:UnRegisterAllTimer()

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideView_UnRegisterBinder_%s", ObjectName))
		self:UnRegisterAllBinder()
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideView_OnHide_%s", ObjectName))
		self:OnHide(Params)
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideView_Anim_%s", ObjectName))
	if nil ~= self.PlayAllAnimationsToEnd then
		self:PlayAllAnimationsToEnd()
	end

	if not bImmediatelyHide then
		self:PlayAnimOut()
	end

	rawset(self, "IsShowView", false)
end

---ActiveView
function UIView:ActiveView()
	--self:OnActive()
	local OnActive = self.OnActive
	if nil ~= OnActive then
		OnActive(self)
	end

	self:ActiveSubView()

	--self:OnPostActive()
	local OnPostActive = self.OnPostActive
	if nil ~= OnPostActive then
		OnPostActive(self)
	end
end

--function UIView:OnPostActive()
--
--end

---InactiveView
function UIView:InactiveView()
	self:InactiveSubView()

	--self:OnInactive()
	local OnInactive = self.OnInactive
	if nil ~= OnInactive then
		OnInactive(self)
	end
end

---LoadView @加载时调用
function UIView:LoadView()
	if rawget(self, "IsLoadView") then
		return
	end

	rawset(self, "IsLoadView", true)

	self:OnLoad()

	self:LoadSubView()
end

---UnloadView @卸载时调用
function UIView:UnloadView()
	if not rawget(self, "IsLoadView") then
		return
	end

	rawset(self, "IsLoadView", false)

	self:UnloadSubView()

	self:OnUnload()
end

---UpdateView 界面已经显示 再次调用ShowView时更新界面
---@param Params any
function UIView:UpdateView(Params)
	if rawget(self, "bInheritedParams") then
		rawset(self, "Params", Params)
	end

	self:UnRegisterAllBinder()
	self:OnHide()

	self:UpdateSubView()

	self:OnRegisterBinder()
	self:OnShow()
end

---UpdateSubView
function UIView:UpdateSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		FLOG_WARNING("UIView:UpdateSubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local Fun = v.UpdateView
			if nil == Fun then
				FLOG_ERROR("UIView:UpdateSubView UpdateView is nil, SubViews=%s", tostring(v))
			else
				Fun(v)
			end
		end
	end
end

---SetParentView
---@param ParentView UIView
---@private
function UIView:SetParentView(ParentView)
	rawset(self, "ParentView", ParentView)
end

---RemoveFromParentView
function UIView:RemoveFromParentView()
	local ParentView = rawget(self, "ParentView")
	if nil == ParentView then
		return
	end

	ParentView:RemoveSubView(self)

	self.ParentView = nil
end

---IsValid 判断View是否有效
---@return boolean
function UIView:IsValid()
	local Object = rawget(self, "Object")
	return nil ~= Object and CommonUtil.IsObjectValid(Object)
end

---AddSubView
---@param View UIView
function UIView:AddSubView(View)
	if nil == View then
		FLOG_WARNING("UIView:AddSubView View is nil traceback=%s", debug.traceback())
		return
	end

	if table.find_item(self.SubViews, View) then
		return
	end

	if not View:IsValid() then
		--FLOG_WARNING("UIView:AddSubView View is not valid, traceback=%s", debug.traceback())
		return
	end

	View:SetParentView(self)

	if nil == self.SubViews then
		return
	end
	
	table.insert(self.SubViews, View)
end

---RemoveSubView
---@param View UIView
function UIView:RemoveSubView(View)
	if nil == View then
		FLOG_WARNING("UIView:RemoveSubView View is nil traceback=%s", debug.traceback())
		return
	end

	local SubViews = self.SubViews
	if nil == SubViews then
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v == View then
			View:SetParentView(nil)
			table.remove(SubViews, i)
			return
		end
	end
end

---InitSubView
function UIView:InitSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		FLOG_WARNING("UIView:InitSubView SubViews is nil")
		return
	end

	local ViewID = rawget(self, "ViewID")
	for i = 1, #SubViews do
		local v = SubViews[i]
		local Fun = v.InitView
		if nil == Fun then
			FLOG_ERROR("UIView:InitSubView InitView is nil, SubViews=%s", tostring(v))
			FLOG_WARNING(debug.traceback())
		else
			Fun(v, ViewID)
		end
	end
end

---DestroySubView
function UIView:DestroySubView(Params)
	local SubViews = self.SubViews
	if nil == SubViews then
		--FLOG_WARNING("UIView:DestroySubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		local Fun = v.DestroyView
		if nil == Fun then
			FLOG_ERROR("UIView:DestroySubView DestroyView is nil, SubViews=%s", tostring(v))
			FLOG_WARNING(debug.traceback())
		else
			Fun(v, Params)
		end
	end
end

---ShowSubView
function UIView:ShowSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		FLOG_WARNING("UIView:ShowSubView SubViews is nil")
		return
	end

	local Params = rawget(self, "Params")
	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local ClassName = v:GetClassName()
			local Fun = v.ShowView
			if nil == Fun then
				FLOG_ERROR("UIView:ShowSubView ShowView is nil, SubViews=%s", tostring(v))
				FLOG_WARNING(debug.traceback())
			else
				local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:ShowSubView_%s", ClassName))
				Fun(v, Params)
			end
		else
			if nil == v.Params then
				v.Params = Params
			end
		end
	end
end

---HideSubView
function UIView:HideSubView(Params, bImmediatelyHide)
	local SubViews = self.SubViews
	if nil == SubViews then
		--FLOG_WARNING("UIView:HideSubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		local ClassName = v:GetClassName()
		local Fun = v.HideView
		if nil == Fun then
			FLOG_ERROR("UIView:HideSubView HideView is nil, SubViews=%s", tostring(v))
			FLOG_WARNING(debug.traceback())
		else
			local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:HideSubView()_%s", ClassName))
			Fun(v, Params, bImmediatelyHide)
		end
	end
end

---ActiveSubView
function UIView:ActiveSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		FLOG_WARNING("UIView:ActiveSubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local Fun = v.ActiveView
			if nil == Fun then
				FLOG_ERROR("UIView:ActiveSubView ActiveView is nil, SubViews=%s", tostring(v))
			else
				Fun(v)
			end
		end
	end
end

---InactiveSubView
function UIView:InactiveSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		FLOG_WARNING("UIView:InactiveSubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local Fun = v.InactiveView
			if nil == Fun then
				FLOG_ERROR("UIView:InactiveSubView InactiveView is nil, SubViews=%s", tostring(v))
			else
				Fun(v)
			end
		end
	end
end

---LoadSubView
function UIView:LoadSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		--FLOG_WARNING("UIView:LoadSubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local Fun = v.LoadView
			if nil == Fun then
				FLOG_ERROR("UIView:LoadSubView LoadView is nil, SubViews=%s", tostring(v))
			else
				Fun(v)
			end
		end
	end
end

---UnloadSubView
function UIView:UnloadSubView()
	local SubViews = self.SubViews
	if nil == SubViews then
		FLOG_WARNING("UIView:UnloadSubView SubViews is nil")
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		local Fun = v.UnloadView
		if nil == Fun then
			FLOG_ERROR("UIView:UnloadSubView UnloadView is nil, SubViews=%s", tostring(v))
		else
			Fun(v)
		end
	end
end

---SetVisibility @建议统一调用UIUtil.SetIsVisible
---@param Visibility ESlateVisibility
---@private
function UIView:SetVisibility(Visibility)
	--if Visibility ~= ESlateVisibility.SelfHitTestInvisible and Visibility ~= ESlateVisibility.Collapsed then
	--	FLOG_WARNING("UIView:SetVisibility Visibility Error")
	--	return
	--end

	local bVisible = UIUtil.CheckVisible(Visibility)

	if rawget(self, "IsInitView") then
		if bVisible then
			self.Object:SetVisibility(Visibility)
			self:AbortHidingView()
			self:LoadView()
			self:ShowView(self.Params)
		else
			local function Callback()
				self.Object:SetVisibility(Visibility)
			end
			--local Params = { IsRegenerateTableViewEntries = true }
			self:ExecuteHideView(Callback, false)
		end
	else
		self.Object:SetVisibility(Visibility)
	end
end

---SetVisible 只设置可见性
---@param bVisible boolean
function UIView:SetVisible(bVisible, IsHitTestVisible, IsHidden)
	local Object = self.Object
	if nil == Object or not Object:IsValid() then
		return
	end

	if bVisible then
		local Visibility = IsHitTestVisible and ESlateVisibility.Visible or ESlateVisibility.SelfHitTestInvisible
		Object:SetVisibility(Visibility)
	else
		local Visibility = IsHidden and ESlateVisibility.Hidden or ESlateVisibility.Collapsed
		Object:SetVisibility(Visibility)
	end
end

---SetVisibleEnum
---@param Visibility ESlateVisibility
function UIView:SetVisibleEnum(Visibility)
	self.Object:SetVisibility(Visibility)
end

---IsVisible
---@return boolean
function UIView:IsVisible()
	return UIUtil.IsVisible(self.Object)
end

---Hide             @关闭自己
function UIView:Hide()
	_G.UIViewMgr:HideView(self.ViewID)
end

---RegisterUIEvent
---@param Widget UUserWidget
---@param EventName string
---@param Callback function
---@param Params any
function UIView:RegisterUIEvent(Widget, EventName, Callback, Params)
	local Register = rawget(self, "UIEventRegister")
	if nil == Register then
		Register = UIEventRegister.New()
		rawset(self, "UIEventRegister", Register)
	end

	Register:Register(self, Callback, EventName, Widget, Params)
end

---UnRegisterAllUIEvent
function UIView:UnRegisterAllUIEvent()
	local Register = rawget(self, "UIEventRegister")
	if nil ~= Register then
		Register:UnRegisterAll()
	end
end

---RegisterGameEvent
---@param EventID EventID
---@param Callback function
function UIView:RegisterGameEvent(EventID, Callback)
	if not self:GetIsShowView() then
		FLOG_WARNING("UIView:RegisterGameEvent View is not shown traceback=%s", debug.traceback())
		--return
	end

	local Register = rawget(self, "GameEventRegister")
	if nil == Register then
		Register = GameEventRegister.New()
		rawset(self, "GameEventRegister", Register)
	end

	Register:Register(EventID, self, Callback)
end

---UnRegisterGameEvent
---@param EventID EventID
---@param Callback function
function UIView:UnRegisterGameEvent(EventID, Callback)
	local Register = rawget(self, "GameEventRegister")
	if nil ~= Register then
		Register:UnRegister(EventID, self, Callback)
	end
end

---UnRegisterAllGameEvent
function UIView:UnRegisterAllGameEvent()
	local Register = rawget(self, "GameEventRegister")
	if nil ~= Register then
		Register:UnRegisterAll()
	end
end

---RegisterTimer
---@param Callback function     @Callback function
---@param Delay number           @Delay time
---@param Interval number        @Interval interval 执行一次回调间隔的时间
---@param LoopNumber number      @循环次数 默认执行1次 >0时为最多执行次数 <=0时一直执行
---@param Params any          @会在Callback函数里传递回去
---@return number               @TimerID
function UIView:RegisterTimer(Callback, Delay, Interval, LoopNumber, Params)
	--if not self:GetIsShowView() then
	--	FLOG_WARNING("UIView:RegisterTimer View is not shown traceback=%s", debug.traceback())
	--	return
	--end

	local Register = rawget(self, "TimerRegister")
	if nil == Register then
		Register = TimerRegister.New()
		rawset(self, "TimerRegister", Register)
	end

	return Register:Register(self, Callback, Delay, Interval, LoopNumber, Params)
end

---UnRegisterTimer
---@param TimerID number        @TimerID
function UIView:UnRegisterTimer(TimerID)
	local Register = rawget(self, "TimerRegister")
	if nil ~= Register then
		Register:UnRegister(TimerID)
	end
end

---UnRegisterAllTimer
function UIView:UnRegisterAllTimer()
	local Register = rawget(self, "TimerRegister")
	if nil ~= Register then
		Register:UnRegisterAll()
	end
end

---GetOrCreateBinderRegister
---@return BinderRegister
function UIView:GetOrCreateBinderRegister()
	local Register = rawget(self, "BinderRegister")
	if nil == Register then
		Register = BinderRegister.New()
		rawset(self, "BinderRegister", Register)
	end

	return Register
end

---RegisterBinder
---@param ViewModel UIViewModel
---@param PropertyName string
---@param Binder UIBinder
---@deprecated @建议使用RegisterBinders
function UIView:RegisterBinder(ViewModel, PropertyName, Binder)
	if not self:GetIsShowView() then
		FLOG_WARNING("UIView:RegisterBinder View is not shown traceback=%s", debug.traceback())
		--return
	end

	local Register = self:GetOrCreateBinderRegister()
	if nil == Register then
		return
	end

	Register:Register(ViewModel, PropertyName, Binder)
end

---RegisterBinders
---@param ViewModel UIViewModel
---@param Binders table<string,UIBinder>
function UIView:RegisterBinders(ViewModel, Binders)
	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:RegisterBinders_%s 0", self:GetClassName()))

	if not self:GetIsShowView() then
		FLOG_WARNING("UIView:RegisterBinders View is not shown traceback=%s", debug.traceback())
		--return
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:RegisterBinders_%s 1", self:GetClassName()))
	local Register = self:GetOrCreateBinderRegister()
	if nil == Register then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("UIView:RegisterBinders_%s 2", self:GetClassName()))
	Register:RegisterBinders(ViewModel, Binders)
end

---RegisterMultiBinders
---@param MultiBinders table<UIViewModel,table<UIBinder>>
function UIView:RegisterMultiBinders(MultiBinders)
	if not self:GetIsShowView() then
		FLOG_WARNING("UIView:RegisterMultiBinders View is not shown traceback=%s", debug.traceback())
		--return
	end

	local Register = self:GetOrCreateBinderRegister()
	if nil == Register then
		return
	end

	Register:RegisterMultiBinders(MultiBinders)
end

---UnRegisterBinder
---@param ViewModel UIViewModel
---@param PropertyName string
---@param Binder UIBinder
function UIView:UnRegisterBinder(ViewModel, PropertyName, Binder)
	local Register = rawget(self, "BinderRegister")
	if nil ~= Register then
		Register:UnRegister(ViewModel, PropertyName, Binder)
	end
end

---UnRegisterBinders
---@param ViewModel UIViewModel
---@param Binders table<string,UIBinder>
function UIView:UnRegisterBinders(ViewModel, Binders)
	local Register = rawget(self, "BinderRegister")
	if nil ~= Register then
		Register:UnRegisterBinders(ViewModel, Binders)
	end
end

---UnRegisterAllBinder
function UIView:UnRegisterAllBinder()
	local Register = rawget(self, "BinderRegister")
	if nil ~= Register then
		Register:UnRegisterAll()
	end
end

---OnRegisterSubView            @注册View的SubView时会调用
function UIView:OnRegisterSubView()

end

---OnInit                   @初始化View时会调用 OnInit时 self.Params是nil 显示UI的时候才赋值
function UIView:OnInit()

end

function UIView:OnPostInit()
end

---OnDestroy                @销毁View时会调用
function UIView:OnDestroy()

end

---OnShow                   @显示View时会调用
function UIView:OnShow()

end

---OnHide                   @隐藏View时 如果需要播放隐藏动画时 播放完隐藏动画才会调用
function UIView:OnHide()

end

---OnActive                 @由于互斥规则，被其他View或层级隐藏后 再显示时会调用（正常显示View不会调用）
--function UIView:OnActive()
--end

---OnInactive               @由于互斥规则，被其他View或层级隐藏时会调用（正常隐藏View不会调用）
--function UIView:OnInactive()
--
--end

---OnLoad                 @UIViewMgr:ShowView完成时会调用一次
function UIView:OnLoad()

end

---OnUnload               @UIViewMgr:HideView完成时会调用一次
function UIView:OnUnload()

end

-----OnRegisterNetMsg         @注册网络事件
--function UIView:OnRegisterNetMsg()
--
--end

---OnRegisterUIEvent        @注册UMG控件事件 OnRegisterUIEvent self.Params是nil 显示UI的时候才赋值
function UIView:OnRegisterUIEvent()

end

---OnRegisterGameEvent      @注册Game事件
function UIView:OnRegisterGameEvent()

end

---OnRegisterTimer          @注册Timer
function UIView:OnRegisterTimer()

end

---OnRegisterBinder   @注册Binder
function UIView:OnRegisterBinder()

end

function UIView:PlayAnimIn()
	local _ <close> = CommonUtil.MakeProfileTag(string.format("PlayAnimIn_%s", self:GetClassName()))

	do
		local Animation = self:GetAnimOut()
		if nil ~= Animation and self:IsAnimationPlaying(Animation) then
			local EndTime = Animation:GetEndTime()
			self:PlayAnimationTimeRangeToEndTime(Animation, EndTime)
		end
	end

	do
		self.IsExcutePlayAnimIn = true
		local Animation = self:GetAnimIn()
		if nil ~= Animation then
			self:PlayAnimation(Animation)
		end
	end
end

function UIView:PlayAnimation(Animation, ...)
	local StartAtTime, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState = ...
	if nil == StartAtTime then
		StartAtTime = 0
	end
	if nil == NumLoopsToPlay then
		NumLoopsToPlay = 1
	end
	if nil == PlayMode then
		PlayMode = 0
	end
	if nil == PlaybackSpeed then
		PlaybackSpeed = 1
	end
	if nil == bRestoreState then
		bRestoreState = false
	end

	local Fun = self.PlayAnimWithPropertyStruct
	if nil ~= Fun then
		do
			Fun(self, Animation, StartAtTime, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
		end
	else
		self.PlayAnimationWithBaseMethod(self, Animation, StartAtTime, NumLoopsToPlay, PlayMode, PlaybackSpeed, bRestoreState)
		FLOG_ERROR("UIView:PlayAnimation Error: PlayAnimWithPropertyStruct is nil")
	end
end

function UIView:PlayAnimToEnd(Animation)
	local EndTime = Animation:GetEndTime()
    self:PlayAnimationTimeRangeToEndTime(Animation, EndTime)
end

function UIView:CheckPlayAnimIn()
	if not self.IsExcutePlayAnimIn then
		self:PlayAnimIn()
	end
	if not self.IsExcutePlayAnimLoop then
		self:PlayAnimLoop()
	end
end

function UIView:PlayAnimOut()
	do
		local Animation = self:GetAnimIn()
		if nil ~= Animation and self:IsAnimationPlaying(Animation) then
			local EndTime = Animation:GetEndTime()
			self:PlayAnimationTimeRangeToEndTime(Animation, EndTime)
		end
	end
	do
		self.IsExcutePlayAnimIn = false
		local Animation = self:GetAnimOut()
		if nil ~= Animation then
			self:PlayAnimation(Animation)
		end
	end
end

function UIView:PlayAnimOutRecursively()
	self:PlayAnimOut()
	local SubViews = self.SubViews
	if nil == SubViews then
		return
	end

	for i = 1, #SubViews do
		local SubView = SubViews[i]
		SubView:PlayAnimOutRecursively()
	end
end

function UIView:PlayAnimLoop()
	local _ <close> = CommonUtil.MakeProfileTag(string.format("PlayAnimLoop_%s", self:GetClassName()))

	do
		self.IsExcutePlayAnimLoop = true
		local Animation = self:GetAnimLoop()
		if nil ~= Animation then
			self:PlayAnimation(Animation, 0, 0)
		end
	end
end

function UIView:StopAnimLoop()
	do
		self.IsExcutePlayAnimLoop = false
		local Animation = self:GetAnimLoop()
		if nil ~= Animation and self:IsAnimationPlaying(Animation) then
			--self:StopAnimation(Animation)
			local EndTime = Animation:GetEndTime()
			--重新设置播放模式
			self:PlayAnimation(Animation, 0, 1)
			--重新设置播放起始时间
			self:PlayAnimationTimeRangeToEndTime(Animation, EndTime)
		end
	end
end

function UIView:GetAnimIn()
	return self.AnimIn
end

function UIView:GetAnimOut()
	return self.AnimOut
end

function UIView:GetAnimLoop()
	return self.AnimLoop
end

function UIView:GetSelectionChangedAnim(WidgetName)
	local AnimationName = "Anim" .. WidgetName .. "SelectionChanged"
	return self[AnimationName]
end

function UIView:GetAnimInTime()
	local MaxTime = 0

	local Animation = self:GetAnimIn()
	if nil ~= Animation then
		MaxTime = Animation:GetEndTime()
	end

	return MaxTime
end

---GetAnimOutTime
function UIView:GetAnimOutTime()
	local MaxTime = 0

	local Animation = self:GetAnimOut()
	if nil ~= Animation then
		MaxTime = Animation:GetEndTime()
	end

	local SubViews = self.SubViews
	if nil == SubViews then
		return MaxTime
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() and nil ~= v.GetAnimOutTime then
			local Time = v:GetAnimOutTime()
			if Time > MaxTime then
				MaxTime = Time
			end
		end
	end

	return MaxTime
end

---GetHideViewDelayTime
function UIView:GetHideViewDelayTime()
	return self:GetAnimOutTime()
end

---OnHideFinished
---@param Callback function
function UIView:OnHideFinished(Callback)
	rawset(self, "IsHiding", false)

	if nil ~= Callback then
		Callback()
	end
end

---ExecuteHideView
---@param Callback function
---@param bImmediatelyHide boolean  @是否立即隐藏 为true时不播放AnimOut动画
function UIView:ExecuteHideView(Callback, bImmediatelyHide, Params)
	if rawget(self, "IsHiding") then
		return
	end

	if not rawget(self, "IsShowView") then
		if nil ~= Callback then
			Callback()
		end
		return
	end

	rawset(self, "IsHiding", true)

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("HideView_%s", self:GetClassName()))
		self:HideView(Params, bImmediatelyHide)
	end

	if bImmediatelyHide or rawget(self, "IsForceImmediatelyHide") then
		self:OnHideFinished(Callback)
	else
		local Time = self:GetHideViewDelayTime()
		if Time > 0 then
			self:CancelHideDelayTimer()
			self.HideDelayTimer = self:RegisterTimer(self.OnHideFinished, Time, nil, nil, Callback)
		else
			self:OnHideFinished(Callback)
		end
	end
end

function UIView:SetForceImmediatelyHide(IsForce)
	rawset(self, "IsForceImmediatelyHide", IsForce)
end

---SetParams
---@param Params any
function UIView:SetParams(Params)
	rawset(self, "Params", Params)
	rawset(self, "bInheritedParams", false)
end

---GetParams
function UIView:GetParams()
	return rawget(self, "Params")
end

---IsInputModeUIOnly
---@return boolean
function UIView:IsInputModeUIOnly()
	local Config = rawget(self, "Config")
	if nil == Config then
		return false
	end

	return Config.bInputModeUIOnly
end

---IsCantControlCamera
---@return boolean
function UIView:IsCantControlCamera()
	local Config = rawget(self, "Config")
	if nil == Config then
		return true
	end

	return Config.bCantControlCamera
end

---IsEnableUpdateView
function UIView:IsEnableUpdateView()
	local Config = rawget(self, "Config")
	if nil == Config then
		return false
	end

	return Config.bEnableUpdateView
end

---IsEnableChangeLayer
function UIView:IsEnableChangeLayer()
	local Config = rawget(self, "Config")
	if nil == Config then
		return false
	end

	return Config.bEnableChangeLayer
end

function UIView:IsIgnoreInReconnect()
	local Config = rawget(self, "Config")
	if nil == Config then
		return false
	end

	return Config.bIgnoreInReconnect
end

---GetViewID
---@return UIViewID
function UIView:GetViewID()
	return rawget(self, "ViewID")
end

---GetConfig
function UIView:GetConfig()
	return rawget(self, "Config")
end

---SetGCType
---@param Type ObjectGCType
function UIView:SetGCType(Type)
	rawset(self, "GCType", Type or ObjectGCType.LRU)
end

---GetGCType
---@return ObjectGCType
function UIView:GetGCType()
	return rawget(self, "GCType")
end

---SetBPName
---@param BPName string
function UIView:SetBPName(BPName)
	rawset(self, "BPName", BPName)
end

---GetBPName
---@return string
function UIView:GetBPName()
	return rawget(self, "BPName")
end

---SetIsInPool
---@param bInPool boolean
function UIView:SetIsInPool(bInPool)
	rawset(self, "bInPool", bInPool)
end

---GetIsInPool
---@return boolean
function UIView:GetIsInPool()
	return rawget(self, "bInPool")
end

---SetHideDelayTimer
---@param TimerID number
function UIView:SetHideDelayTimer(TimerID)
	rawset(self, "HideDelayTimer", TimerID)
end

---GetHideDelayTimer
---@return number
function UIView:GetHideDelayTimer()
	return rawget(self, "HideDelayTimer")
end

---GetIsInitView
---@return boolean
function UIView:GetIsInitView()
	return rawget(self, "IsInitView")
end

---GetIsShowView
---@return boolean
function UIView:GetIsShowView()
	return rawget(self, "IsShowView")
end

---GetIsLoadView
---@return boolean
function UIView:GetIsLoadView()
	return rawget(self, "IsLoadView")
end

---GetShowType
---@return string
function UIView:GetShowType()
	return rawget(self, "ShowType")
end

---GetLayer
---@return number
function UIView:GetLayer()
	return rawget(self, "Layer")
end

---SetLayer
---@param Layer number
function UIView:SetLayer(Layer)
	rawset(self, "Layer", Layer)
end

---GetIsHiding
---@return boolean
function UIView:GetIsHiding()
	return rawget(self, "IsHiding")
end

---GetZOrder
---@return number
function UIView:GetZOrder()
	return self.ZOrder
end

---SetZOrder
---@param ZOrder number
function UIView:SetZOrder(ZOrder)
	self.ZOrder = ZOrder
end

function UIView:GetViewListToSetVisible()
	local Config = self:GetConfig()
	if nil == Config then
		return false
	end

	return Config.ListToSetVisible
end

function UIView:GetViewListToSetInvisible()
	local Config = self:GetConfig()
	if nil == Config then
		return false
	end

	return Config.ListToSetInvisible
end

--[[
---ReRegisterUIEvent 新版UnLua切图后 自动反注册了UI事件后续可能会修改 这里先重新注册
---@deprecated 废弃
function UIView:ReRegisterUIEvent()
	self:UnRegisterAllUIEvent()
	self:OnRegisterUIEvent()

	local SubViews = self.SubViews
	if nil == SubViews then
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		local Fun = v.ReRegisterUIEvent
		if nil ~= Fun then
			Fun(v, self.ViewID)
		end
	end
end
--]]

---TriggerEvent @触发控件事件，目前只是给新手引导使用
---@param Widget UWidget
---@param EventName string
---@param Params any
function UIView:TriggerEvent(Widget, EventName, Params, ...)
	local Register = rawget(self, "UIEventRegister")
	if nil ~= Register then
		Register:TriggerEvent(Widget, EventName, Params, ...)
	end
end

---IsForceGC
function UIView:IsForceGC()
	local Config = rawget(self, "Config")
	if nil == Config then
		return false
	end

	return Config.bForceGC and self.GCType == ObjectGCType.LRU
end

function UIView:GetClassName()
	local Object = self.Object
	if nil ~= Object and Object:IsValid() then
		return Object:GetClass():GetName()
	end

	return "Unknown"
end
--ShowView在结尾没有发现类似收尾触发一些特殊业务逻辑的函数，故增加此函数
function UIView:PostShowView()
end

function UIView:SetFontForAllTextWidgetInLua()

	---检查是否有全局替换艾欧泽亚字体的设置
	if _G.UIViewMgr.bUseAozyFont then
		--- 将字体设置为Aozy字体
		local Fun = self.SetFontForAllTextWidget
		if nil ~= Fun then
			do
				local AozyFontPath = "Font'/Game/UI/Fonts/HingashiExtended_no_number_Font.HingashiExtended_no_number_Font'"
				Fun(self, AozyFontPath)
			end
		end
		---不替换回来，比较麻烦，设置字体功能仅内部使用，重启后即可恢复
	end

	---检查是否有全局替换为Main_Font字体的设置
	if _G.UIViewMgr.bUseMainFont then
		--- 将字体设置为自定义字体
		local Fun = self.SetFontForAllTextWidget
		if nil ~= Fun then
			do
				local CustomFontPath = "Font'/Game/UI/Fonts/Main_Font.Main_Font'"
				Fun(self, CustomFontPath)
			end
		end
	end
	---Font'/Game/UI/Fonts/Main_Font.Main_Font'
end
--[[
---ReleaseView @临时调用释放UE对象 解决内存泄露问题 等新版UnLua再修改
function UIView:Release()
	--_G.UE.UCommonUtil.ReleaseLuaObject(self.Object)
end

function UIView:ReleaseView()
	if nil == self.SubViews then
		return
	end

	for _, v in ipairs(self.SubViews) do
		local Fun = v.ReleaseView
		if nil == Fun then
			FLOG_ERROR("UIView:DestroySubView ReleaseView is nil, SubViews=%s", tostring(v))
		else
			Fun(v)
		end
	end

	self:Release()

	self.SubViews = nil
end
--]]

return UIView

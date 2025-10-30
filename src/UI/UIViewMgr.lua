--
-- Author: anypkvcai
-- Date: 2020-08-05 15:43:40
-- Description: UIView管理类
-- 	负责UIView创建、销毁、显示、隐藏、层级管理等
-- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=336458846

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UILayer = require("UI/UILayer")
local UIViewStateMgr = require("UI/UIViewStateMgr")
local UIViewConfig = require("Define/UIViewConfig")
local DeviceAdapterCfg = require("TableCfg/DeviceAdapterCfg")
local ObjectMgr = require("Object/ObjectMgr")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local CommonDefine = require("Define/CommonDefine")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local AsyncViewHelper = require("UI/AsyncViewHelper")
local SlatePreTick = require("Game/Skill/SlatePreTick")

local FLOG_INFO = _G.FLOG_INFO
--local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_ERROR = _G.FLOG_ERROR

---@class UIViewMgr : MgrBase
---@field RootView UIView
---@field VisibleViews table<UIViewID, UIView>
---@field PopupViews table<UIViewID, UIView>
---@field BPNameToViewID table<string, UIViewID>
---@field VisibleLayerBit number
---@field RestoreLayerBit number
local UIViewMgr = LuaClass(MgrBase)

function UIViewMgr:OnInit()
	self.RootView = nil
	self.ClickFeedbackView = nil
	self.WaterMarkView = nil
	self.HUDView = nil
	self.NetworkWaitingView = nil
	self.VisibleViews = {}
	self.BPNameToViewID = {}

	self.VisibleLayerBit = UILayer.All
	self.RestoreLayerBit = nil

	-- UIview中的字体是否全局替换为艾欧泽亚字体，仅英文环境下生效
	self.bUseAozyFont = false
	-- UIview中的字体是否全局替换为MainFont，仅英文环境下生效
	self.bUseMainFont = false
	CommonUtil.PreviewGameLocalization()
end

function UIViewMgr:OnBegin()
	self:InitRootView()
	self:InitClickFeedbackView()
	self:InitHUDView()
	self:InitNetworkWaitingView()
	--begin：原来在OnPostInit中的内容

	--_G.UE.UUIMgr.Get():InitEmulatorInfo()
	_G.UE.UUIMgr.Get():InitKeyboardListen()

	_G.UE.UCrashSightMgr.Get():CloseCrashReport()

	self:InitDeviceAdapter()
	--end

	if nil ~= self.RootView then
		_G.UE.UUIMgr.Get():SetRootView(self.RootView.Object)
	end

	UIViewStateMgr:Clear()

	if CommonUtil.IsShipping() then
		CommonUtil.ConsoleCommand("disableallscreenmessages")
	end
	--self:PreLoadFont()
end

function UIViewMgr:OnEnd()
	self:HideAllUI()

	_G.UE.UUIMgr.Get():SetRootView(nil)

	if nil ~= self.RootView then
		self.RootView:RemoveFromViewport()
		self.RootView:RemoveView(UILayer.Network, self.NetworkWaitingView)
		self.NetworkWaitingView = nil
		self.RootView = nil
	end

	if nil ~= self.ClickFeedbackView then
		self.ClickFeedbackView:RemoveFromViewport()
		self.ClickFeedbackView = nil
	end

	if nil ~= self.WaterMarkView then
		self.WaterMarkView:RemoveFromViewport()
		self.WaterMarkView = nil
	end

	if nil ~= self.HUDView then
		self.HUDView:RemoveFromViewport()
		self.HUDView = nil
	end

	WidgetPoolMgr:ReleaseAllWidgets()
	AsyncViewHelper:ClearAll()
	UIViewStateMgr:Clear()
end

function UIViewMgr:OnShutdown()
	self.VisibleViews = nil
	self.BPNameToViewID = nil
end

function UIViewMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnGameEventAvatarAssembleAllEnd)
	self:RegisterGameEvent(EventID.ObjectLoadNoCacheImage, self.OnGameEventObjectLoadNoCacheImage)
	self:RegisterGameEvent(EventID.CorePreLoadWorld, self.OnWorldPreLoad)
	self:RegisterGameEvent(EventID.CorePostLoadWorld, self.OnWorldPostLoad)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)			-- 退出副本

	if CommonUtil.IsWithEditor() then
		self:RegisterGameEvent(EventID.LevelScriptActorBeginPlay, self.OnEventLevelScriptActorBeginPlay)
	end
end

function UIViewMgr:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 10, 0)
end

function UIViewMgr:OnTimer()
	WidgetPoolMgr:ReleaseExpiredWidgets()
end

function UIViewMgr:GetWorld()
	return _G.UE.ULuaMgr:GetCurrentWorld()
end

---PreLoadWidgetByName
---@param BPName string
---@param GCType ObjectGCType 默认用的Hold
---@param Num number
----@return boolean
function UIViewMgr:PreLoadWidgetByName(BPName, GCType, Num)
	return WidgetPoolMgr:PreLoadWidgetByName(BPName, GCType, Num)
end

---PreLoadWidgetByViewID
---@param ViewID UIViewID
---@param GCType ObjectGCType 默认用的Hold
---@param Num number
----@return boolean
function UIViewMgr:PreLoadWidgetByViewID(ViewID, GCType, Num)
	return WidgetPoolMgr:PreLoadWidgetByViewID(ViewID, GCType, Num)
end

---CreateView @动态创建子蓝图 一般用不到ViewID和UIViewConfig中的参数时 可以用CreateViewByName函数通过BPName来创建
---要手动调用AddChild、AddChildToCanvas等函数添加到UMG的父窗口
---调用RemoveChild等函数从UMG的父窗口删除View时, 要调用UIViewMgr:RecycleView
---@param ViewID UIViewID
---@param ParentView UIView @ParentView并不是UMG的父窗口，只是把View添加到Lua层的的SubView里，这样ParentView销毁时才会调用View的反注册、销毁等函数
---@param IsAutoInitWidget boolean | nil @nil表示用默认值 false
---@param IsAutoShowWidget boolean | nil @nil表示用默认值 false
---@param Params any
---@return UIView
function UIViewMgr:CreateView(ViewID, ParentView, IsAutoInitWidget, IsAutoShowWidget, Params)
	local NewView = WidgetPoolMgr:CreateWidgetSyncByViewID(ViewID, IsAutoInitWidget, IsAutoShowWidget, Params)
	if nil == NewView then
		FLOG_ERROR("UIViewMgr:CreateView failed, ViewID=%d", ViewID)
		return
	end

	if nil ~= ParentView then
		ParentView:AddSubView(NewView)
	end

	return NewView
end

---CreateViewByName @动态创建子蓝图
---要手动调用AddChild、AddChildToCanvas等函数添加到UMG的父窗口
---调用RemoveChild等函数从UMG的父窗口删除View时, 要调用UIViewMgr:RecycleView
---@param BPName string @和ViewConfig里一样 从Content/UI/BP这层开始
---@param GCType ObjectGCType | nil @nil表示用默认值 ObjectGCType.LRU
---@param ParentView UIView @ParentView并不是UMG的父窗口，只是把View添加到Lua层的的SubView里，这样ParentView销毁时才会调用View的反注册、销毁等函数
---@param IsAutoInitWidget boolean | nil @nil表示用默认值 false
---@param IsAutoShowWidget boolean | nil @nil表示用默认值 false
---@param Params any
---@return UIView
function UIViewMgr:CreateViewByName(BPName, GCType, ParentView, IsAutoInitWidget, IsAutoShowWidget, Params)
	local NewView = WidgetPoolMgr:CreateWidgetSyncByName(BPName, GCType, IsAutoInitWidget, IsAutoShowWidget, Params)

	if nil == NewView then
		FLOG_ERROR("UIViewMgr:CreateView failed, BPName=%s", BPName)
		return
	end

	if nil ~= ParentView then
		ParentView:AddSubView(NewView)
	end

	return NewView
end

---CloneView @一般不建议使用 可以使用 CreateView 或 CreateViewByName 创建蓝图
---要手动调用AddChild、AddChildToCanvas等函数添加到UMG的父窗口
---调用RemoveChild等函数从UMG的父窗口删除View时, 要调用UIViewMgr:RecycleView
---@param View UIView
---@param ParentView UIView @ParentView并不是UMG的父窗口，只是把View添加到Lua层的的SubView里，这样ParentView销毁时才会调用View的反注册、销毁等函数
---@param IsAutoInitWidget boolean | nil @nil表示用默认值 false
---@param IsAutoShowWidget boolean | nil @nil表示用默认值 false
---@param Params any
---@deprecated
function UIViewMgr:CloneView(View, ParentView, IsAutoInitWidget, IsAutoShowWidget, Params)
	if nil == View then
		FLOG_ERROR("UIViewMgr:CloneView View is nil")
		return
	end

	local Class = View:GetClass()
	if nil == Class then
		FLOG_ERROR("UIViewMgr:CloneView GetClass failed, Name=%s", View:GetName())
		return
	end

	local Outer = Class:GetOuter()
	if nil == Outer then
		FLOG_ERROR("UIViewMgr:CloneView GetOuter failed, Name=%s", View:GetName())
		return
	end

	local BPName = string.gsub(Outer:GetName(), "/Game/UI/BP/", "")
	local NewView = WidgetPoolMgr:CreateWidgetSyncByName(BPName, View:GetGCType(), IsAutoInitWidget, IsAutoShowWidget, Params)

	if nil == NewView then
		FLOG_ERROR("UIViewMgr:CloneView CreateWidgetSyncByName failed, Name=%s", View:GetName())
		return
	end

	if nil ~= ParentView then
		ParentView:AddSubView(NewView)
	end

	return NewView
end

---RecycleWidget
---@param View UIView
function UIViewMgr:RecycleView(View)
	WidgetPoolMgr:RecycleWidget(View)
end

---ShowView                 @显示UI：可传入参数, 如果界面本来是显示的只修改层级 这时需要修改数据可以通过VM更新或调用函数处理
---@param ViewID UIViewID
---@param Params any
---@param Callback function @需要异步加载时需要传入Callback，加载完成会通过回调返回UIView
---@return UIView @同步加载会返回UIView， 异步加载返回 nil
function UIViewMgr:ShowView(ViewID, Params, Callback)
	local ViewName = UIViewID:IDToName(ViewID)
	if CommonDefine.bShowUIViewLog then
		local LuaMem = collectgarbage("count") / 1024
		FLOG_INFO("UIViewMgr:ShowView, ViewID=%d, ViewName=%s, LuaMem=%.2fM", ViewID, ViewName, LuaMem)
	end
	if nil == self.RootView then
		FLOG_ERROR("UIViewMgr:ShowView RootView is nil, ViewID=%d", ViewID)
		return
	end

	local View = self.VisibleViews[ViewID]
	if nil ~= View then
		if View:GetIsHiding() then
			View:AbortHidingView()
			self:ShowViewInternal(View, Params)
			UIViewStateMgr:OnShowView(View)
			self:OnViewChanged()
		elseif View:IsEnableUpdateView() then
			View:UpdateView(Params)
		end

		if nil ~= Callback then
			Callback(View)
		end

		if View:IsEnableChangeLayer() then
			self:ChangeLayer(ViewID, View:GetLayer())
		end

		return View
	end

	local Config = self:FindConfig(ViewID)
	if nil == Config then
		FLOG_ERROR("UIViewMgr:ShowView can't find UIViewConfig, ViewID=%d", ViewID)
		return
	end

	if nil ~= AsyncViewHelper:FindViewInfo(ViewID) then
		return
	end

	if Config.bAsyncLoad then
		self:ShowViewAsync(ViewID, Params, Callback, ViewName)
	else
		return self:ShowViewSync(ViewID, Params, ViewName)
	end
end

---ShowViewSync
---@param ViewID UIViewID
---@param Params any
---@private
function UIViewMgr:ShowViewSync(ViewID, Params, ViewName)
	local View
	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("ShowViewSync_%s_Create", ViewName))
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(ViewID, true)
	end
	if nil == View then
		FLOG_ERROR("UIViewMgr:ShowViewSync failed, ViewName=%s", ViewName)
		return
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("ShowViewSync_%s_Add", ViewName))
		self.RootView:AddView(View.Layer, View)
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("ShowViewSync_%s_Show", ViewName))
		self:ShowViewInternal(View, Params)
	end

	UIViewStateMgr:OnShowView(View)

	self:OnViewChanged()

	return View
end

function UIViewMgr:OnAsyncLoadFinished()
	local RootView = self.RootView
	local ViewInfos = AsyncViewHelper:PopFinishedViewInfos()
	for i = 1, #ViewInfos do
		local Info = ViewInfos[i]
		local View = Info.View
		RootView:AddView(View.Layer, View)

		self:ShowViewInternal(View, Info.Params)

		UIViewStateMgr:OnShowView(View)

		local Callback = Info.Callback
		if nil ~= Callback then
			Callback(View)
		end
	end

	self:OnViewChanged()
end

---ShowViewAsync                 @异步显示UI：可传入参数表，供UI显示用
---@param ViewID UIViewID
---@param Params any
---@param Callback function
function UIViewMgr:ShowViewAsync(ViewID, Params, Callback, ViewName)
	if CommonDefine.bShowUIViewLog then
		FLOG_INFO("UIViewMgr:ShowViewAsync, ViewID=%d, ViewName=%s", ViewID, ViewName)
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("ShowViewAsync_%s", ViewName))

	local function CreateCallback(View)
		if nil == View then
			FLOG_ERROR("UIViewMgr:ShowViewAsync failed, ViewName=%s", ViewName)
			return
		end

		AsyncViewHelper:OnAsyncLoadFinished(View)
		self:OnAsyncLoadFinished()
	end

	AsyncViewHelper:AddAsyncLoadingView(ViewID, Params, Callback)
	WidgetPoolMgr:CreateWidgetAsyncByViewID(ViewID, CreateCallback, true)
end

---@param View UIView
function UIViewMgr:ShowViewInternal(View, Params)
	if nil == View then
		return
	end

	local ViewID = View.ViewID
	self.VisibleViews[ViewID] = View

	View:SetVisible(true)
	do
		local _ <close> = CommonUtil.MakeProfileTag(string.format("ShowView_%s", View.Object:GetClass():GetName()))
		View:ShowView(Params, true)
	end

	_G.EventMgr:PostEvent(EventID.ShowUI, ViewID)
	_G.EventMgr:SendEvent(_G.EventID.TutorialShowView, ViewID)
end

---HideView @隐藏是不会立即调用DestroyView相关函数，会根据GC类型，最终销毁时才会调用
---@param ViewID UIViewID
---@param bImmediatelyHide @是否立即隐藏 为true时不播放AnimOut动画
---@param Params any
function UIViewMgr:HideView(ViewID, bImmediatelyHide, Params)
	if not ViewID then
		FLOG_ERROR("UIViewMgr:HideView ViewID is nil")
		return
	end

	if AsyncViewHelper:OnHideView(ViewID) then
		return
	end

	local View = self.VisibleViews[ViewID]
	if nil == View or View:GetIsHiding() then
		return
	end

	local ViewName = UIViewID:IDToName(ViewID)
	local _ <close> = CommonUtil.MakeProfileTag(string.format("HideView_%s", ViewName))

	UIViewStateMgr:OnHideView(View)

	self:OnViewChanged()

	local function Callback()
		self.VisibleViews[ViewID] = nil

		self.RootView:RemoveView(View.Layer, View)

		WidgetPoolMgr:RecycleWidget(View, true)
		--if View.GCType == ObjectGCType.Hold then
		--	View:SetVisible(false)
		--	self.InvisibleViews[ViewID] = View
		--else
		--	View:DestroyView()
		--	--[[
		--	-- unlua v2.2.3 内存管理方式改了 这里不用调用
		--	if nil ~= View.SetIsNeedReleaseLua then
		--		View:SetIsNeedReleaseLua(true)
		--	end
		--	--]]
		--	self.RootView:RemoveView(View.Layer, View)
		--	self:UnLoadClass(ViewID)
		--end
	end

	View:ExecuteHideView(Callback, bImmediatelyHide, Params)

	if CommonDefine.bShowUIViewLog then
		local LuaMem = collectgarbage("count") / 1024
		FLOG_INFO("UIViewMgr:HideView, ViewID=%d, ViewName=%s, LuaMem=%.2fM", ViewID, ViewName, LuaMem)
	end
	_G.EventMgr:PostEvent(EventID.HideUI, ViewID)
	_G.EventMgr:SendEvent(_G.EventID.TutorialHideView, ViewID)
end

---HideView @按照UILayer来关闭界面，隐藏是不会立即调用DestroyView相关函数，会根据GC类型，最终销毁时才会调用
---@param LayerBitSet number 例：UILayer.Normal | UILayer.AboveNormal 或者 ~(UILayer.Low | UILayer.AboveLow)
---@param bImmediatelyHide @是否立即隐藏 为true时不播放AnimOut动画
function UIViewMgr:HideViewByUILayer(LayerBitSet, bImmediatelyHide, Params)
	FLOG_INFO("UIViewMgr:HideViewByUILayer")
	for ViewID, View in pairs(self.VisibleViews) do
		if View.Layer & LayerBitSet ~= 0x00 then
			self:HideView(ViewID, bImmediatelyHide, Params)
		end
	end
end

---IsViewVisible
---@param ViewID UIViewID                @UI是否处于显示状态
function UIViewMgr:IsViewVisible(ViewID)
	return nil ~= self:FindVisibleView(ViewID)
end

---FindView                @查找View
---@param ViewID UIViewID
---@deprecated 使用FindVisibleView
function UIViewMgr:FindView(ViewID)
	return self:FindVisibleView(ViewID)
end

---FindVisibleView                @查找View
---@param ViewID UIViewID
function UIViewMgr:FindVisibleView(ViewID)
	local View = self.VisibleViews[ViewID]
	if nil ~= View and not View:GetIsHiding() then
		return View
	end
end

---ShowSubView
---@param SubView UIView
---@param Params any
function UIViewMgr:ShowSubView(SubView, Params)
	SubView:SetParams(Params)
	UIUtil.SetIsVisible(SubView, true)
end

---HideSubView
---@param SubView UIView
function UIViewMgr:HideSubView(SubView)
	UIUtil.SetIsVisible(SubView, false)
end

---InitRootView
function UIViewMgr:InitRootView()
	local View = self.RootView

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.RootView, true, true)
		if nil == View then
			FLOG_ERROR("UIViewMgr:InitRootView Error")
			return
		end

		self.RootView = View
	end

	if not View:IsInViewport() then
		View:AddToViewport(0)
	end
end

function UIViewMgr:InitClickFeedbackView()
	local View = self.ClickFeedbackView

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.ClickFeedbackView, true, true)
		if nil == View then
			FLOG_ERROR("UIViewMgr:InitClickFeedbackView Error")
			return
		end

		self.ClickFeedbackView = View
	end

	if not View:IsInViewport() then
		View:AddToViewport(10)
	end
end

function UIViewMgr:InitWaterMarkView(ID)
	local View = self.WaterMarkView
	local Params = { Data = ID }

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.WaterMark, true, true, Params)
		if nil == View then
			FLOG_ERROR("UIViewMgr:InitWaterMarkView Error")
			return
		end

		self.WaterMarkView = View
	else
		View.Params = Params
		View:SetID()
	end

	if not View:IsInViewport() then
		View:AddToViewport(0)
	end
end

function UIViewMgr:InitHUDView()
	local View = self.HUDView

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.HUDView, true, true)
		if nil == View then
			FLOG_ERROR("UIViewMgr:InitHUDView Error")
			return
		end

		self.HUDView = View
	end

	if not View:IsInViewport() then
		View:AddToViewport(0)
	end
end

function UIViewMgr:InitNetworkWaitingView()
	local RootView = self.RootView
	if nil == RootView then
		return
	end

	local View = self.NetworkWaitingView

	if nil == View then
		View = WidgetPoolMgr:CreateWidgetSyncByViewID(UIViewID.NetworkWaiting, true, true)
		if nil == View then
			FLOG_ERROR("UIViewMgr:InitNetworkWaitingView Error")
			return
		end

		self.NetworkWaitingView = View
	end

	RootView:AddView(UILayer.Network, View)
end

---InitDeviceAdapter
function UIViewMgr:InitDeviceAdapter()
	if _G.UE.UUIMgr.Get():IsWithEmulator() then
		FLOG_INFO("UIViewMgr:InitDeviceAdapter IsWithEmulator")
		_G.UE.UFSafeZone.SetIsNotch(false)
		return
	end

	if CommonUtil.IsWithEditor() then
		FLOG_INFO("UIViewMgr:InitDeviceAdapter IsWithEditor")
		_G.UE.UFSafeZone.SetIsNotch(false)
		return
	end

	local Cfg = self:GetDeviceAdapterCfg()
	if nil ~= Cfg and Cfg.NotchMargin then
		FLOG_INFO("UIViewMgr:InitDeviceAdapter NotchMargin=%s", Cfg.NotchMargin)

		local Margin = { 0, 0, 0, 0 }
		local Index = 1

		local UKismetSystemLibrary = _G.UE.UKismetSystemLibrary
		local ScaleValue = UKismetSystemLibrary.GetConsoleVariableFloatValue("r.MobileContentScaleFactor")
		local DeviceProfileName = _G.UE.UConfigMgr:Get():GetActiveDeviceProfileName()
		DeviceProfileName = string.lower(DeviceProfileName)
		if string.find(DeviceProfileName, "iphone") then
				ScaleValue = ScaleValue * 0.65
		elseif string.find(DeviceProfileName, "ipad") then
				ScaleValue = ScaleValue * 0.87
		else
				ScaleValue = 1.32
		end
		FLOG_INFO("UIViewMgr:InitDeviceAdapter ScaleValue=%s", ScaleValue)

		for v in string.gmatch(Cfg.NotchMargin, "%d+") do
			--表里配置的是1334*750的设计分辨率 要转换成1920*1080的分辨率
			--Margin[Index] = tonumber(v) * 1.4

			--设计规范推荐的尺寸
			Margin[Index] = tonumber(v) * ScaleValue

			Index = Index + 1
		end

		_G.UE.UFSafeZone.SetIsNotch(true)
		_G.UE.UFSafeZone.SetNotchMargin(Margin[1], Margin[2], Margin[3], Margin[4])
	else
		_G.UE.UFSafeZone.SetIsNotch(false)
	end

	--check CPUBrand to Set  SFSafeZone EnableNotch
	self:CheckFSafeZoneEnableNotch()
end

---InitDeviceAdapter
function UIViewMgr:GetDeviceAdapterCfg()
	local Brand = _G.UE.UPlatformUtil.GetCPUBrand()
	local ProfileName = _G.UE.UPlatformUtil.GetDefaultDeviceProfileName()

	--Brand = "iPhone13,4"
	--ProfileName = "iPhone12ProMax"
	FLOG_INFO("UIViewMgr:GetDeviceAdapterCfg CPUBrand=%s ProfileName=%s", Brand, ProfileName)

	local Cfg = DeviceAdapterCfg:FindCfgByDeviceModel(string.lower(Brand))
	if nil ~= Cfg then
		return Cfg
	end

	return DeviceAdapterCfg:FindCfgByDeviceModel(string.lower(ProfileName))
end

---CheckFSafeZoneEnableNotch
function UIViewMgr:CheckFSafeZoneEnableNotch()
	local ScreenSize = UIUtil.GetScreenSize()
	if ScreenSize.X > 0 and ScreenSize.Y > 0 then
		local TempCV = ScreenSize.X / ScreenSize.Y
		if ScreenSize.X < ScreenSize.Y then
			TempCV = ScreenSize.Y / ScreenSize.X
		end
		FLOG_INFO("UIViewMgr:CheckFSafeZoneEnableNotch tempCV = %f",TempCV)
		if TempCV <= 4 / 3 then
			_G.UE.UFSafeZone.SeEnableNotch(false)
		end
	end
end

---GetBPPath
---@param BPName string
function UIViewMgr:GetBPPath(BPName)
	-- local Name = string.match(BPName, "(%w+)$")
	local Name = string.match(BPName, "([%w_]+)$")

	return string.format("Class'/Game/UI/BP/%s.%s_C'", BPName, Name)
end

-- function UIViewMgr:GetLuaPath(LuaName)
-- 	if nil == LuaName then return end
-- 	return string.format("Game/%s",LuaName)
-- end

---UnLoadClass
---@param ViewID UIViewID
function UIViewMgr:UnLoadClass(ViewID)
	local Config = self:FindConfig(ViewID)
	if nil == Config then
		FLOG_ERROR("UIViewMgr:UnLoadClass can't find UIViewConfig, ViewID=%d", ViewID)
		return
	end

	local Path = self:GetBPPath(Config.BPName)

	return ObjectMgr:UnLoadClass(Path, false)
end

function UIViewMgr:UpdateLayerBit(LayerBit)
	if self.VisibleLayerBit == LayerBit then
		return
	end

	self.RestoreLayerBit = self.VisibleLayerBit
	self.VisibleLayerBit = LayerBit

	if nil ~= self.RootView then
		self.RootView:ShowLayer(LayerBit)
	end
end

function UIViewMgr:IsLayerVisible(LayerBit)
	return (self.VisibleLayerBit & LayerBit) ~= 0
end

---ShowLayer                    @显示某些层,可用UILayer位组合
---@param LayerBit UILayer
function UIViewMgr:ShowLayer(LayerBit)
	FLOG_INFO("UIViewMgr:ShowLayer %d", LayerBit)
	self:UpdateLayerBit(LayerBit)
end

---ShowAllLayer
function UIViewMgr:ShowAllLayer()
	FLOG_INFO("UIViewMgr:ShowAllLayer")
	if self.VisibleLayerBit == UILayer.All then
		return
	end
	self:UpdateLayerBit(UILayer.All)
end

---HideAllLayer
function UIViewMgr:HideAllLayer()
	FLOG_INFO("UIViewMgr:HideAllLayer")
	self:UpdateLayerBit(0)
end

---RestoreLayer 恢复上次隐藏或显示层之前的层
function UIViewMgr:RestoreLayer()
	local LayerBit = self.RestoreLayerBit
	if nil == LayerBit then
		return
	end

	FLOG_INFO("UIViewMgr:RestoreLayer %d", LayerBit)

	self.VisibleLayerBit = LayerBit
	self.RestoreLayerBit = nil

	if nil ~= self.RootView then
		self.RootView:ShowLayer(LayerBit)
	end
end

function UIViewMgr:HideAllUI()
	FLOG_INFO("UIViewMgr:HideAllUI")
	AsyncViewHelper:ClearAll()
	UIViewStateMgr:Clear()

	for k, _ in pairs(self.VisibleViews) do
		self:HideView(k, true)
	end
end

---HideAllUIInReconnect @重连的时候关闭除Loading外的其他Layer层, 配置bIgnoreInReconnect可以避免在重连时被关闭
function UIViewMgr:HideAllUIInReconnect()
	FLOG_INFO("UIViewMgr:HideAllUIInReconnect")
	for k, v in pairs(self.VisibleViews) do
		if (v:GetLayer() ~= UILayer.Loading) and not v:IsIgnoreInReconnect() then
			self:HideView(k, true)
		end
	end
end


---HideAllUIByLayer @显示某些层,可用UILayer位组合， 默认是 Normal 层
---@param LayerBit UILayer
function UIViewMgr:HideAllUIByLayer(LayerBit)
	FLOG_INFO("UIViewMgr:HideAllUIByLayer")
	if not LayerBit then
		LayerBit = UILayer.Normal
	end

	for k, v in pairs(self.VisibleViews) do
		if (v:GetLayer() & LayerBit) ~= 0 then
			self:HideView(k, true)
		end
	end
end

---HideAllUIByLayer @隐藏LayerBit层以上的UI
---@param LayerBit UILayer
function UIViewMgr:HideAllUIOverLayer(LayerBit)
	FLOG_INFO("UIViewMgr:HideAllUIOverLayer")
	if not LayerBit then
		LayerBit = UILayer.Normal
	end

	for k, v in pairs(self.VisibleViews) do
		if v:GetLayer() > LayerBit and(k<UIViewID.LoadingDefault or k>UIViewID.LoadingOther)  then
			self:HideView(k, true)
		end
	end
end

---OnWorldPreLoad
function UIViewMgr:OnWorldPreLoad(Params)
	FLOG_INFO("UIViewMgr:OnWorldPreLoad")

	AsyncViewHelper:ClearAll()

	UIViewStateMgr:OnWorldPreLoad()

	local HideList = {}

	for k, _ in pairs(self.VisibleViews) do
		local Config = self:FindConfig(k)
		if nil ~= Config and not Config.DontHideWhenLoadMap then
			table.insert(HideList, k)
		end
	end

	for i = 1, #HideList do
		self:HideView(HideList[i], true)
	end

	self:ShowLayer(UILayer.Loading) -- 切图时只显示Loading层

	--WidgetPoolMgr:ReleaseAllWidgetsExceptHold()
end

---OnWorldPostLoad
function UIViewMgr:OnWorldPostLoad(Params)
	FLOG_INFO("UIViewMgr:OnWorldPostLoad")

	self:InitRootView()
	self:InitClickFeedbackView()
	self:InitHUDView()
	self:InitNetworkWaitingView()

	local LoginMgr = require("Game/Login/LoginMgr")

	if LoginMgr.EnableWaterMark then

		if LoginMgr.RoleID ~= nil then
			local RoleID = LoginMgr.RoleID
			self:InitWaterMarkView(RoleID)
		end
	end

	self:ShowAllLayer()
	UIUtil.SetInputMode_GameAndUI()
	MajorUtil.SetCanControlCamera(true)
	UE4.UIRecordMgr:Get():InitRootView(self.RootView,self.ClickFeedbackView)
end

function UIViewMgr:OnGameEventAvatarAssembleAllEnd(Params)
	if not Params.BoolParam1 then
		return
	end

	--FLOG_INFO("UIViewMgr:OnGameEventAvatarAssembleAllEnd")

	UIViewStateMgr:OnAddAvatarNum()
end

function UIViewMgr:OnGameEventObjectLoadNoCacheImage()
	--FLOG_INFO("UIViewMgr:OnGameEventObjectLoadNoCacheImage")
	UIViewStateMgr:OnAddImageNum()
end

function UIViewMgr:OnEventLevelScriptActorBeginPlay()
	if nil ~= self.RootView and self.RootView:IsInViewport() then
		return
	end

	FLOG_INFO("UIViewMgr:OnEventLevelScriptActorBeginPlay")

	self:InitRootView()
	self:InitClickFeedbackView()
	self:InitHUDView()
	self:InitNetworkWaitingView()
	self:ShowAllLayer()
	UIUtil.SetInputMode_GameAndUI()
	MajorUtil.SetCanControlCamera(true)
end

function UIViewMgr:OnGameEventPWorldExit()
	CommonUtil.HideVirtualKeyboard()
end

---FindConfig
---@param ViewID UIViewID
function UIViewMgr:FindConfig(ViewID)
	return UIViewConfig[ViewID]
end

---GetViewIDByName
---@param BPName string
function UIViewMgr:GetViewIDByName(BPName)
	if nil ~= self.BPNameToViewID[BPName] then
		return self.BPNameToViewID[BPName]
	end

	for k, v in pairs(UIViewConfig) do
		if v.BPName == BPName then
			self.BPNameToViewID[BPName] = k
			return k
		end
	end

	self.BPNameToViewID[BPName] = 0

	return 0
end

function UIViewMgr:OnAsyncCanvasPanelChildCreate(InParent, InChild)
	if nil == InParent or nil == InChild then
		return
	end

	InParent:AddSubView(InChild)

	if InParent:GetIsInitView() then
		InChild:InitView(InParent.ViewID, InParent.Config)
	end

	if InParent:GetIsLoadView() then
		InChild:LoadView()
	end

	if InParent:GetIsShowView() then
		InChild:ShowView(InParent.Params, true)
	end
end

---UpdateState
---@private
function UIViewMgr:UpdateState()
	self.bUpdateState = false

	local _ <close> = CommonUtil.MakeProfileTag("UIViewMgr:UpdateState")
	UIViewStateMgr:UpdateState()

end

---OnViewChanged
---@private
function UIViewMgr:OnViewChanged()
	if not self.bUpdateState then
		self.bUpdateState = true
		SlatePreTick.RegisterSlatePreTickSingle(self, self.UpdateState)
	end
end

---ChangeLayer @从旧层级移除调用RemoveChild的时候 UE会调用ReleaseSlateResources 导致一些子对象被释放了 只能先隐藏在重新显示
---@param ViewID UIViewID
---@param Layer UILayer
function UIViewMgr:ChangeLayer(ViewID, Layer)
	local View = self:FindView(ViewID)
	if nil == View then
		return
	end

	local RootView = self.RootView
	if nil == RootView then
		return
	end

	local TopView = RootView:GetTopView(Layer)
	if View == TopView then
		return
	end

	RootView:RemoveView(View.Layer, View)
	UIViewStateMgr:OnHideView(View)

	View:HideView()
	View:ShowView(View:GetParams())
	View:SetLayer(Layer)

	RootView:AddView(Layer, View)
	UIViewStateMgr:OnShowView(View)

	self:OnViewChanged()
end

function UIViewMgr:ReleaseAllPoolWidgets()
	WidgetPoolMgr:ReleaseAllWidgets()
end

function UIViewMgr:DumpPoolWidgets()
	WidgetPoolMgr:DumpWidgets()
end

function UIViewMgr:HideAllUIExceptRevive()
	FLOG_INFO("UIViewMgr:HideAllUIExceptRevive")
	local HideList = {}

	AsyncViewHelper:ClearAll()

	for k, _ in pairs(self.VisibleViews) do
		local Config = self:FindConfig(k)
		if nil ~= Config and not Config.DontHideWhenRevive then
			table.insert(HideList, k)
		end
	end

	for i = 1, #HideList do
		self:HideView(HideList[i], true)
	end
end

--------------------------------------------------------------------------------------------------------------------------------------
---虚拟键盘

function UIViewMgr:OnVirtualKeyboardShown(Params)
	local KeyboardHeight = 0

	if Params and Params.IntParam1 and Params.IntParam2 then
		if Params.IntParam1 > 0 and Params.IntParam2 > 0 then
			local ScreenSize = UIUtil.GetScreenSize()
			KeyboardHeight = (Params.IntParam2 - Params.IntParam1) / Params.IntParam2 * ScreenSize.Y

			if CommonUtil.GetPlatformName() == "Android" then
				--android 有个默认白条高128
				KeyboardHeight = KeyboardHeight + 128
			end
		end
	end
	_G.EventMgr:SendEvent(EventID.VirtualKeyboardShown, KeyboardHeight)
end

function UIViewMgr:OnVirtualKeyboardHidden()
	_G.EventMgr:SendEvent(EventID.VirtualKeyboardHidden)
end

function UIViewMgr:OnVirtualKeyboardReturn()
	_G.EventMgr:SendEvent(EventID.VirtualKeyboardReturn)
end

---显示虚拟键盘扩展UI
---@param View UIView @调用者对象，如果需要响应“完成”回调，需要定义OnTextCommitted函数
---@param TextInput UEditableText @输入文本
function UIViewMgr:ShowVirtualKeyboardExUI(View,TextInput)
	if CommonUtil.IsAndroidPlatform() then
		self:ShowView(UIViewID.CommInputCommitButton, { View = View, TextInput = TextInput})
	end
	--elseif CommonUtil.IsIOSPlatform() then
	--	self:ShowView(UIViewID.CommonVirtualKeyboardExIOS, { View = View, TextInput = TextInput, MaxLength = MaxLength })
	--end
end

---隐藏虚拟键盘扩展UI
function UIViewMgr:HideVirtualKeyboardExUI()
	if CommonUtil.IsAndroidPlatform() then
		self:HideView(UIViewID.CommInputCommitButton)
	end
	--elseif CommonUtil.IsIOSPlatform() then
	--	self:HideView(UIViewID.CommonVirtualKeyboardExIOS)
	--end
end

--- 设置是否全局使用艾欧泽亚字体
-- @param bUse 是否使用
function UIViewMgr:SetUseAzerothFont(bUseAozyFont)
	self.bUseAozyFont = bUseAozyFont
	self.bUseMainFont = not bUseAozyFont
	--- 重设了字体设置，刷新RootView下的所有UI
	self.RootView:RreshAllLayer()
end

--- 设置是否全局使用MainFont
-- @param bUse 是否使用
function UIViewMgr:SetUseMainFont(bUseMainFont)
	self.bUseMainFont = bUseMainFont
	self.bUseAozyFont = not bUseMainFont
	--- 重设了字体设置，刷新RootView下的所有UI
	self.RootView:RreshAllLayer()
end
--------------------------------------------------------------------------------------------------------------------------------------

--[[
function UIViewMgr:PreLoadFont()
	local _ <close> = CommonUtil.MakeProfileTag("PreLoadFont")

	--预加载公共字体 缓存功能未开启 先在这里预加载
	local FontPaths = {
		"Font'/Game/UI/Fonts/HingashiExtended_Font.HingashiExtended_Font'",
		"Font'/Game/UI/Fonts/Main_Font.Main_Font'",
		"Font'/Game/UI/Fonts/MiedingerMediumW00-Regular_Font.MiedingerMediumW00-Regular_Font'",
		"Font'/Game/UI/Fonts/Title_Font.Title_Font'",
		"Font'/Game/UI/Fonts/TrumpGothicPro-Medium_Font.TrumpGothicPro-Medium_Font'",
		"Font'/Game/UI/Fonts/XIVJupiterCondensedSCOsF-Re_Font.XIVJupiterCondensedSCOsF-Re_Font'",
	}

	local ObjectGCType = require("Define/ObjectGCType")

	for _, v in ipairs(FontPaths) do
		_G.UE.UObjectMgr.PreLoadObject(v, ObjectGCType.Hold)
	end
end
--]]

return UIViewMgr

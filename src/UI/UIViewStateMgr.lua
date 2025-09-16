--
-- Author: anypkvcai
-- Date: 2024-08-12 18:59
-- Description:
--

local UILayer = require("UI/UILayer")
local ObjectMgr = require("Object/ObjectMgr")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIViewState = require("UI/UIViewState")

local AvatarNumToGC = 5
local ImageNumToGC = 300

local UIViewStateMgr = {
	AvatarNum = 0,
	ImageNum = 0,
	FullScreenNum = 0,
	UniqueViewID = nil,
	ViewStates = {}
}

function UIViewStateMgr:Clear()
	self.AvatarNum = 0
	self.ImageNum = 0
	self.FullScreenNum = 0

	self.UniqueViewID = nil

	self.LayerBit = UILayer.All

	self.ViewStates = {}
end

function UIViewStateMgr:OnWorldPreLoad()
	self.AvatarNum = 0
	self.ImageNum = 0
end

function UIViewStateMgr:OnAddAvatarNum()
	local Num = self.AvatarNum
	Num = Num + 1
	if Num >= AvatarNumToGC then
		self.AvatarNum = 0
		ObjectMgr:CollectGarbage(true)
	else
		self.AvatarNum = Num
	end
end

function UIViewStateMgr:OnAddImageNum()
	local Num = self.ImageNum
	Num = Num + 1
	if Num >= ImageNumToGC then
		self.ImageNum = 0
		ObjectMgr:CollectGarbage(true)
	else
		self.ImageNum = Num
	end
end

function UIViewStateMgr:OnShowView(View)
	if table.find_item(self.ViewStates, View, "View") then
		_G.FLOG_ERROR("UIViewStateMgr:OnShowView Error Name=%s", View.BPName)
		return
	end

	if not View:GetIsShowView() then
		return
	end

	local Config = View:GetConfig()
	if nil == Config then
		return
	end

	if Config.bUnique then
		local UniqueViewID = self.UniqueViewID
		if nil ~= UniqueViewID then
			_G.UIViewMgr:HideView(UniqueViewID)
		end
		self.UniqueViewID = View:GetViewID()
	end

	local ListToHideOnShow = Config.ListToHideOnShow
	if nil ~= ListToHideOnShow then
		for i = 1, #ListToHideOnShow do
			_G.UIViewMgr:HideView(ListToHideOnShow[i], true)
		end
	end

	local State = self:CreateState(View)
	table.insert(self.ViewStates, State)
	if State:GetVisible() then
		self:OnStateChanged(State, true)
	end
end

function UIViewStateMgr:OnHideView(View)
	local State = table.remove_item(self.ViewStates, View, "View")
	if nil == State then
		return
	end

	if self.UniqueViewID == View:GetViewID() then
		self.UniqueViewID = nil
	end

	local Config = View:GetConfig()
	if nil == Config then
		return
	end

	local ListToHideOnHide = Config.ListToHideOnHide
	if nil ~= ListToHideOnHide then
		for i = 1, #ListToHideOnHide do
			_G.UIViewMgr:HideView(ListToHideOnHide[i], true)
		end
	end

	self:OnStateChanged(State, false)
end

---CheckInputModeUIOnly
---@return boolean
---@private
function UIViewStateMgr:CheckInputModeUIOnly()
	local ViewStates = self.ViewStates

	for i = 1, #ViewStates do
		local v = ViewStates[i]
		if v:GetVisible() and v.View:IsInputModeUIOnly() then
			--新手引导界面这里特殊处理
			if v.View.ViewID == _G.UIViewID.TutorialGestureMainPanel then
				if v.View.InputModeUIOnly then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

---UpdateInputMode
---@private
function UIViewStateMgr:UpdateInputMode()
	local bInputModeUIOnly = self:CheckInputModeUIOnly()
	if bInputModeUIOnly then
		UIUtil.SetInputMode_UIOnly()
		CommonUtil.HideJoyStick()
	else
		if  _G.QuestMgr.isUnlockProf then
			return
		end
		UIUtil.SetInputMode_GameAndUI()
		CommonUtil.ShowJoyStick()
	end
end

---CheckCanControlCamera
---@return boolean
---@private
function UIViewStateMgr:CheckCanControlCamera()
	local ViewStates = self.ViewStates

	for i = 1, #ViewStates do
		local v = ViewStates[i]
		if v:GetVisible() and v.View:IsCantControlCamera() then
			return false
		end
	end

	return true
end

---UpdateCanControlCamera
---@private
function UIViewStateMgr:UpdateCanControlCamera()
	local bCanControlCamera = self:CheckCanControlCamera()
	if bCanControlCamera then
		--CommonUtil.ShowJoyStick()
		MajorUtil.SetCanControlCamera(true)
	else
		--CommonUtil.HideJoyStick()
		MajorUtil.SetCanControlCamera(false)
	end
end

---CheckFullscreen
---@return boolean
---@private
function UIViewStateMgr:CheckFullscreen()
	local ViewStates = self.ViewStates

	for i = 1, #ViewStates do
		local v = ViewStates[i]
		if v:GetVisible() and nil ~= v.View.GetIsFullScreen and v.View:GetIsFullScreen() then
			return true
		end
	end

	return false
end

function UIViewStateMgr:UpdateFullscreen()
	local bFullScreen = self:CheckFullscreen()
	if bFullScreen then
		--local CommonUtil = require("Utils/CommonUtil")
		--CommonUtil.ConsoleCommand("r.Mobile.PauseSceneRendering 1")
		--r.Mobile.PauseSceneRendering 1
		--print("RootView:UpdateFullscreen SceneRenderingPause true")
		_G.UE.UKismetRenderingLibrary.SceneRenderingPause(true)
	else
		--local CommonUtil = require("Utils/CommonUtil")
		--CommonUtil.ConsoleCommand("r.Mobile.PauseSceneRendering 0")
		--r.Mobile.PauseSceneRendering 0
		--print("RootView:UpdateFullscreen SceneRenderingPause false")
		_G.UE.UKismetRenderingLibrary.SceneRenderingPause(false)
	end

	--print("UIViewStateMgr:UpdateFullscreen", bFullScreen)
end

function UIViewStateMgr:OnStateChanged(State, bShow)
	--print("UIViewStateMgr:OnStateChanged", State.View.BPName, bShow)

	local ViewStates = self.ViewStates

	if bShow then
		for i = 1, #ViewStates do
			local v = ViewStates[i]
			if v ~= State then
				v:OnViewShow(State.View)
				local bVisible = v:CalculateVisible()
				if bVisible ~= v:GetVisible() then
					v:SetVisible(bVisible)
					self:OnStateChanged(v, bVisible)
				end
			end
		end
	else
		for i = 1, #ViewStates do
			local v = ViewStates[i]
			if v ~= State then
				v:OnViewHide(State.View)
				local bVisible = v:CalculateVisible()
				if bVisible ~= v:GetVisible() then
					v:SetVisible(bVisible)
					self:OnStateChanged(v, bVisible)
				end
			end
		end
	end
end

function UIViewStateMgr:CreateState(View)
	local State = UIViewState.New(View)

	local ViewStates = self.ViewStates

	for i = 1, #ViewStates do
		local v = ViewStates[i]
		State:UpdateState(v.View)
	end

	State:SetVisible(State:CalculateVisible())

	return State
end

--[[
local function SortPredicate(Left, Right)
	local LeftLayer = Left:GetLayer()
	local RightLayer = Right:GetLayer()

	if LeftLayer ~= RightLayer then
		return LeftLayer < RightLayer
	end

	local LeftZOrder = Left:GetZOrder()
	local RightZOrder = Right:GetZOrder()

	if LeftZOrder ~= RightZOrder then
		return LeftZOrder < RightZOrder
	end

	return false
end


function UIViewStateMgr:SortViews()
	table.sort(self.Views, SortPredicate)
end
--]]

function UIViewStateMgr:UpdateVisibility()
	local ViewStates = self.ViewStates

	for i = 1, #ViewStates do
		local v = ViewStates[i]

		if v ~= nil then
			local bVisible = v:GetVisible()
			local View = v.View
			if View:IsValid() then
				if bVisible ~= View:IsVisible() then
					View:SetVisible(bVisible)
					if bVisible then
						--print("UIViewStateMgr:UpdateVisibility ActiveView", View.BPName)
						View:ActiveView()
					else
						--print("UIViewStateMgr:UpdateVisibility InactiveView", View.BPName)
						View:InactiveView()
					end
				end
			else
				-- TODO 临时定位bug 后面要删掉
				local Msg = string.format("UIViewStateMgr: Object is Invalid, ObjectName=%s AncestorName=%s", View.ObjectName, View.AncestorName)
				_G.FLOG_WARNING(Msg)
				CommonUtil.ReportCustomError(Msg, "UIViewStateMgr: Object is Invalid", debug.traceback(), false)
			end
		end
	end
end

function UIViewStateMgr:UpdateState()
	--_G.UE.FProfileTag.StaticBegin("UIViewStateMgr:SortViews")
	--self:SortViews()
	--_G.UE.FProfileTag.StaticEnd()

	do
		local _ <close> = CommonUtil.MakeProfileTag("UIViewStateMgr:UpdateVisibility")
		self:UpdateVisibility()
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("UIViewStateMgr:UpdateInputMode")
		self:UpdateInputMode()
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("UIViewStateMgr:UpdateCanControlCamera")
		self:UpdateCanControlCamera()
	end

	--[[
	-- ShadowCache和暂停渲染冲突， 引擎暂时关闭暂停渲染功能
	do
		local _ <close> = CommonUtil.MakeProfileTag("UIViewStateMgr:UpdateFullscreen")
		self:UpdateFullscreen()
	end
	--]]
end

return UIViewStateMgr

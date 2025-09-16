---
--- Author: chriswang
--- DateTime: 2023-10-17 10:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIViewID = require("Define/UIViewID")


local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

--@ViewModel
local LoginRoleMainPanelVM = require("Game/LoginRole/LoginRoleMainPanelVM")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR
---@class LoginCreateMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLogin UFButton
---@field BtnStart UFButton
---@field ButtonDownloadPak UButton
---@field ImgWait UFImage
---@field LoginRoleBackPage LoginCreateBackPageView
---@field MorePage LoginCreateMorePageView
---@field PanelInfo UFCanvasPanel
---@field PanelRole UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field PanelWait UFCanvasPanel
---@field TableViewRole UTableView
---@field TextAddrInfo UFTextBlock
---@field TextAddress UFTextBlock
---@field TextBDInfo UFTextBlock
---@field TextBirthday UFTextBlock
---@field TextGod UFTextBlock
---@field TextGodInfo UFTextBlock
---@field TextGodTitle UFTextBlock
---@field TextLogin UFTextBlock
---@field TextLoginTime UFTextBlock
---@field TextNum UFTextBlock
---@field TextPeople UFTextBlock
---@field TextRace UFTextBlock
---@field TextRaceInfo UFTextBlock
---@field TextRole UFTextBlock
---@field TextRoleInfo UFTextBlock
---@field TextStart UFTextBlock
---@field TextTribe UFTextBlock
---@field TextTribeInfo UFTextBlock
---@field TextWait UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateMainPanelView = LuaClass(UIView, true)

function LoginCreateMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLogin = nil
	--self.BtnStart = nil
	--self.ButtonDownloadPak = nil
	--self.ImgWait = nil
	--self.LoginRoleBackPage = nil
	--self.MorePage = nil
	--self.PanelInfo = nil
	--self.PanelRole = nil
	--self.PanelTime = nil
	--self.PanelWait = nil
	--self.TableViewRole = nil
	--self.TextAddrInfo = nil
	--self.TextAddress = nil
	--self.TextBDInfo = nil
	--self.TextBirthday = nil
	--self.TextGod = nil
	--self.TextGodInfo = nil
	--self.TextGodTitle = nil
	--self.TextLogin = nil
	--self.TextLoginTime = nil
	--self.TextNum = nil
	--self.TextPeople = nil
	--self.TextRace = nil
	--self.TextRaceInfo = nil
	--self.TextRole = nil
	--self.TextRoleInfo = nil
	--self.TextStart = nil
	--self.TextTribe = nil
	--self.TextTribeInfo = nil
	--self.TextWait = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginRoleBackPage)
	self:AddSubView(self.MorePage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateMainPanelView:OnInit()
	-- self.IsGaze = true
    self.ViewModel = LoginRoleMainPanelVM
	self.AdapterRoleTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewRole, self.OnRoleSelectChange, true)

end

function LoginCreateMainPanelView:OnDestroy()

end

function LoginCreateMainPanelView:OnShow()
	self.LoginRoleBackPage.TextTitle:SetText(LSTR(980043))
	self.ViewModel:OnShow()
	self.AdapterRoleTableView:SetSelectedIndex(self.ViewModel.CurSelectRoleIdx)

	-- if _G.WorldMsgMgr.IsShowLoadingView then
	-- 	_G.WorldMsgMgr:HideLoadingView()
	-- end
	
	UIUtil.SetIsVisible(self.LoginRoleBackPage.TextSubtile, false)
	UIUtil.SetIsVisible(self.MorePage.BtnTieUpHair, false)
	UIUtil.SetIsVisible(self.MorePage.BtnShare, false)
	UIUtil.SetIsVisible(self.MorePage.BtnMore, false)
	UIUtil.SetIsVisible(self.MorePage.BtnHideUI, false)
	_G.LoginUIMgr.IsFixPageClickBtnMore = false
	UIUtil.SetIsVisible(self.MorePage.PanelMoreTips, false)
	
	self.TextStart:SetText(LSTR(980048))	--开始游戏
	self.TextRace:SetText(LSTR(980049))	--种族
	self.TextTribe:SetText(LSTR(980050))	--部族
	self.TextBirthday:SetText(LSTR(980051))	--创建日
	self.TextGod:SetText(LSTR(980052))	--守护神
	self.TextRole:SetText(LSTR(980053))	--职业
	self.TextAddress:SetText(LSTR(980054))	--所在地
	self.TextServerBack:SetText(LSTR(980116))	--返回原始服务器
	
	if _G.LoginMgr:HasRoleCount() < 4 and _G.LoginUIMgr.LoginReConnectMgr:HaveNotFinishCreate() then
		local TipContent = string.format(LSTR(980086))--是否继续未完成的创建角色流程？
		local function OkCallBack()
			self:Hide()
			_G.LoginUIMgr:DoShowCreateRoleView(nil, nil, true)
		end
		
		local function CancelCallBack()
			_G.LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
		end

		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(980022), TipContent, OkCallBack
		    , CancelCallBack, LSTR(980087), LSTR(980088)
			, {CloseClickCB = CancelCallBack})--取 消--确 认
	end
end

function LoginCreateMainPanelView:OnHide()
	_G.NetworkImplMgr:StopWaiting()
end

function LoginCreateMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LoginRoleBackPage.BtnBack, self.OnBackBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnStartBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnServer, self.OnOriginServerClick)
	-- UIUtil.AddOnClickedEvent(self, self.MorePage.BtnGaze, self.OnBtnGazeClick)
	-- UIUtil.AddOnClickedEvent(self, self.MorePage.BtnSetting, self.OnBtnSettingsClick)
	-- UIUtil.AddOnClickedEvent(self, self.MorePage.BtnAction, self.OnBtnActionClick)

end

function LoginCreateMainPanelView:OnRegisterGameEvent()

end

function LoginCreateMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "RoleList", UIBinderUpdateBindableList.New(self, self.AdapterRoleTableView) },
		{ "RaceName", UIBinderSetText.New(self, self.TextRaceInfo) },
		{ "TribeName", UIBinderSetText.New(self, self.TextTribeInfo) },
		{ "Birthday", UIBinderSetText.New(self, self.TextBDInfo) },
		{ "GodName", UIBinderSetText.New(self, self.TextGodInfo) },
		{ "TitleName", UIBinderSetText.New(self, self.TextGodTitle) },
		{ "ProfName", UIBinderSetText.New(self, self.TextRoleInfo) },
		{ "AddrInfo", UIBinderSetText.New(self, self.TextAddrInfo) },
		{ "PanelServerVisible", UIBinderSetIsVisible.New(self, self.PanelServer) },
		{ "OriginalServer", UIBinderSetText.New(self, self.TextOriginalServer) },
		{ "CurServer", UIBinderSetText.New(self, self.TextCurrentServer) },
	}
	
	self:RegisterBinders(self.ViewModel, Binders)

end

function LoginCreateMainPanelView:OnBackBtnClick()
	print("LoginCreateMainPanelView:OnClickButtonBack")

	_G.LoginUIMgr:HideRoleRender2DView()
	self:Hide()
	_G.LuaCameraMgr:UpdateAmbientOcclusionParam(false)

	_G.UIViewMgr:ShowView(_G.LoginMgr:GetLoginMainViewId())
	_G.LoginMgr:ShowBackLoginAnim()

	_G.LifeMgrModule.ShutdownAccountLife()
end

--开始游戏		当前服务器
function LoginCreateMainPanelView:OnStartBtnClick()
	self.ViewModel:OnStartBtnClick()

	--_G.NetworkImplMgr:StartWaiting()
end

--开始游戏		返回原始服务器
function LoginCreateMainPanelView:OnOriginServerClick()
	self.ViewModel:OnStartBtnClick(true)

	_G.NetworkImplMgr:StartWaiting()
end

-- --预览
-- function LoginCreateMainPanelView:OnBtnActionClick()
-- 	-- MsgTipsUtil.ShowTips(LSTR(980026))
-- end

--注视
-- function LoginCreateMainPanelView:OnBtnGazeClick()
-- 	local Actor = _G.LoginUIMgr:GetUIComplexCharacter()
-- 	if not Actor then
-- 		return
-- 	end

-- 	if self.IsGaze then
-- 		self.IsGaze = false
-- 		self.MorePage.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
-- 	else
-- 		self.IsGaze = true
-- 		self.MorePage.BtnGaze:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
-- 	end

-- 	Actor:UseAnimLookAt(self.IsGaze)
-- end

-- function LoginCreateMainPanelView:OnBtnSettingsClick()
-- 	MsgTipsUtil.ShowTips(LSTR(980026))
-- end


function LoginCreateMainPanelView:OnRoleSelectChange(Index, ItemData, ItemView, IsByClick)
	local RoleList = self.ViewModel.RoleList
	if Index >= 1 and #RoleList >= Index then
		local RoleSimple = RoleList[Index]

		if RoleSimple.RoleID then
			if IsByClick and RoleSimple.RoleID == self.ViewModel.CurSelectRoleID then
				return
			end
			
			FLOG_INFO("Login SelectRoleName : %s index:%d RoleID:%d", RoleSimple.Name, Index, RoleSimple.RoleID)
			self.ViewModel:SelectRole(Index)
		else
			FLOG_INFO("Login Show Create Role Index：%d", Index)
			_G.LoginUIMgr:HideSelectRoleView()
			_G.LoginUIMgr:ShowCreateRoleView()
		end
	end
end

return LoginCreateMainPanelView
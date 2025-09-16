---
--- Author: chriswang
--- DateTime: 2023-10-17 14:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

--@ViewModel
local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")
local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")

local ProfUtil = require("Game/Profession/ProfUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local LoginConfig = require("Define/LoginConfig")
local MaxRaceCount = 6

---@class LoginCreateRaceGenderPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RaceInfo LoginCreateRaceInfoPanelView
---@field TableView UTableView
---@field ToggleBtnFemale UToggleButton
---@field ToggleBtnMale UToggleButton
---@field AnimBtnFemale UWidgetAnimation
---@field AnimBtnMale UWidgetAnimation
---@field AnimInCode UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateRaceGenderPageView = LuaClass(UIView, true)

function LoginCreateRaceGenderPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RaceInfo = nil
	--self.TableView = nil
	--self.ToggleBtnFemale = nil
	--self.ToggleBtnMale = nil
	--self.AnimBtnFemale = nil
	--self.AnimBtnMale = nil
	--self.AnimInCode = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateRaceGenderPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RaceInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateRaceGenderPageView:OnInit()
	self.ViewModel = LoginRoleRaceGenderVM--.New()	方便记录数据，不过得在UIViewModelConfig中配置，否则无法绑定view

	self.ViewModel:InitRaceList()
	self.AdapterRaceTableView = UIAdapterTableView.CreateAdapter(self, self.TableView, self.OnRaceTableViewSelectChange, true)
end

function LoginCreateRaceGenderPageView:OnDestroy()

end

function LoginCreateRaceGenderPageView:OnShow()
	if _G.LoginUIMgr.bFirstShowRaceGenderView then
		self:PlayAnimation(self.AnimInCode)
		_G.LoginUIMgr.bFirstShowRaceGenderView = false
	else
		self:PlayAnimation(self.AnimInCode, self.AnimInCode:GetEndTime())
	end

	-- local RaceList = self.ViewModel.RaceList
	-- for index = 1, MaxRaceCount do
	-- 	self["TribeItem0" .. index]:SetInfo(index, RaceList[index])
	-- 	FLOG_INFO("Login RaceGenderPageView : %s index:%d", RaceList[index].RaceName, index)
	-- end

	self.AdapterRaceTableView:ScrollToTop()
	--默认选择人族
	self.AdapterRaceTableView:SetSelectedIndex(self.ViewModel.CurrentSelectIndex)

	-- --默认选择人族
	-- self:OnRaceTableViewSelectChange(self.ViewModel.CurrentSelectIndex, nil, true)
	LoginRoleProfVM:PreLoadProfIcons()
end

function LoginCreateRaceGenderPageView:OnHide()
	-- self:UnSelectLastSelect()
end

function LoginCreateRaceGenderPageView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnMale, self.OnToggleMaleBtnClick)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnFemale, self.OnToggleFemaleBtnClick)

end

function LoginCreateRaceGenderPageView:OnRegisterGameEvent()

end

function LoginCreateRaceGenderPageView:OnRegisterBinder()
	local Binders = {
		{ "RaceName", UIBinderSetText.New(self, self.RaceInfo.TextRace) },
		{ "RaceDesc", UIBinderSetText.New(self, self.RaceInfo.TextInfo) },
        {"RaceDescLogo", UIBinderSetBrushFromAssetPath.New(self, self.RaceInfo.ImgLogo)},
		{ "RaceNameList", UIBinderUpdateBindableList.New(self, self.AdapterRaceTableView) },
		{ "SelectRaceIndex", UIBinderValueChangedCallback.New(self, nil, self.OnSelectRaceIndex) },

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCreateRaceGenderPageView:UnSelectLastSelect()
	-- if self.ViewModel.LastSelectIndex > 0 then
	-- 	local ToggleBtnRace = self["TribeItem0" .. self.ViewModel.LastSelectIndex]
	-- 	if ToggleBtnRace then
	-- 		ToggleBtnRace:UnSelect()
	-- 	end
	-- end
end

function LoginCreateRaceGenderPageView:OnSelectRaceIndex(Info)
	if Info then
		local Index = Info.Idx
		if Index and Index > 0 then
			self.bReadAvatarRecord = Info.bReadAvatarRecord
			self.bAvatarChgIdx = true
			self.AdapterRaceTableView:SetSelectedIndex(Index)
			self.bReadAvatarRecord = nil
			self.bAvatarChgIdx = false
			-- self:OnRaceTableViewSelectChange(Index, Info.bReadAvatarRecord)
		end
	end
end

function LoginCreateRaceGenderPageView:OnRaceTableViewSelectChangeByClick(Index)
	local function DoSelectRace()
		self:OnRaceTableViewSelectChange(Index, nil)
	end

	local function DoCancel()
		--点了当前种族再取消，不反选当前种族
		if self.ViewModel.LastSelectIndex == Index then
			return
		end
		--反选点了的其他种族
		local CurToggleBtnRace = self["TribeItem0" .. Index]
		if CurToggleBtnRace then
			CurToggleBtnRace.ToggleBtnRace:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		end
	end

	local RaceList = self.ViewModel.RaceList
	if Index >= 1 and #RaceList >= Index then
		--这里用于Check的部族、性别都不是最终的
		--得OnRaceTableViewSelectChange的GetGenderByRaceID按概率决定
		local TribeID = RaceList[Index].Tribe
		_G.LoginAvatarMgr:CheckUpdateRoleFacePreset(TribeID
			, RaceList[Index].Gender, DoSelectRace, DoCancel)
	end
end

--选择不同种族
function LoginCreateRaceGenderPageView:OnRaceTableViewSelectChange(Index, ItemData, ItemView, IsByClick)
	--Index, bReadAvatarRecord, bOnShow)
	local RaceList = self.ViewModel.RaceList
	FLOG_INFO("Login SelectRace index:%d", Index)
	if Index >= 1 and #RaceList >= Index then
		local RaceCfg = RaceList[Index]
		if self.bAvatarChgIdx and self.ViewModel.CurrentRaceCfg then
			RaceCfg = self.ViewModel.CurrentRaceCfg
		end

		FLOG_INFO("Login SelectRace : %s index:%d, Tribe:%s, Gender:%d"
			, RaceCfg.RaceName, Index, RaceCfg.TribeName, RaceCfg.Gender)
		-- self.ViewModel.RaceID =
		local RaceID = RaceCfg.RaceID
		self.ViewModel.RaceDescLogo = RaceCfg.RaceDescLogo
		--随机一个性别，并模型选择--------现在性别不随机了，按上次选择的性别来确定；如果没有，就是当前种族现有的性别
		local Gender, GenderTyps = self.ViewModel:GetGenderByRaceID(RaceID)

		--种族描述回滚到顶部
		-- self.RaceInfo.ScrollBox_0:ScrollToStart()

		--选择不同种族，会随机一个性别，并进行展示
		--数据从LoginRoleRaceGenderVM中取
		if self.ViewModel.LastSelectIndex ~= Index then
			LoginRoleRaceGenderVM.bUseCfgTribe = true
			FLOG_INFO("Login SelectRace ReCreate")

			_G.LoginUIMgr.LoginReConnectMgr:SaveValue("RaceID", RaceID, true)	--不用保存到文件
			_G.LoginUIMgr.LoginReConnectMgr:SaveValue("TribID",  RaceCfg.Tribe, true)	--不用保存到文件
			_G.LoginUIMgr.LoginReConnectMgr:SaveValue("Gender", Gender)		--2个都保存后，再保存到文件
			_G.LoginUIMgr:SetFeedbackAnimType(3)
			if not IsByClick then
			else
				_G.LoginUIMgr:ClearRoleWearSuit()
			end

			if not self.bReadAvatarRecord then
				_G.LoginUIMgr:CreateRenderActor()
				-- _G.LoginUIMgr:ChangeGender()
			end

			_G.LoginUIMgr:ClearRoleSuitTryOn()

			-- self:UnSelectLastSelect()
		end

		_G.ObjectMgr:CollectGarbage(false)
		self.RaceInfo:PlayAnimation(self.RaceInfo.AnimIn)

		-- local CurToggleBtnRace = self["TribeItem0" .. Index]
		-- if CurToggleBtnRace then
		-- 	CurToggleBtnRace:Select()
		-- end
		self.ViewModel.CurrentSelectIndex = Index
		self.ViewModel.LastSelectIndex = Index
		if not GenderTyps then
			return
		end

		-- local Cache_Map = _G.UE.EObjectGC.NoCache
		-- local PreLoadIdx = (Index - 1) * 2 + 1
		-- local function PreLoadRes(Idx)
		-- 	if Idx >= 1 and Idx <= #LoginConfig.ProLoadPathSecondTrib then
		-- 		local Paths = LoginConfig.ProLoadPathSecondTrib[Idx]
		-- 		local PathsNum = #Paths
		-- 		for i = 1, PathsNum do
		-- 			_G.ObjectMgr:LoadObjectAsync(Paths[i], Cache_Map)
		-- 		end
		-- 	end
		-- end
		-- if GenderTyps & ProtoCommon.role_gender.GENDER_MALE ~= 0 then
		-- 	PreLoadRes(PreLoadIdx)
		-- 	-- FLOG_INFO("Login OnStartResourceLoad :%d", PreLoadIdx)
		-- end

		-- if GenderTyps & ProtoCommon.role_gender.GENDER_FEMALE ~= 0 then
		-- 	PreLoadRes(PreLoadIdx + 1)
		-- 	-- FLOG_INFO("Login OnStartResourceLoad :%d", PreLoadIdx + 1)
		-- end

		--如果只有1个性别，则隐藏另外一个
		if GenderTyps & ProtoCommon.role_gender.GENDER_MALE ~= 0 then
			UIUtil.SetIsVisible(self.ToggleBtnMale, true, true)

			if Gender == ProtoCommon.role_gender.GENDER_MALE then
				self.ToggleBtnMale:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
			else
				self.ToggleBtnMale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
			end
		else
			UIUtil.SetIsVisible(self.ToggleBtnMale, false)
			self.ToggleBtnMale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		end

		if GenderTyps & ProtoCommon.role_gender.GENDER_FEMALE ~= 0 then
			UIUtil.SetIsVisible(self.ToggleBtnFemale, true, true)

			if Gender == ProtoCommon.role_gender.GENDER_FEMALE then
				self.ToggleBtnFemale:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
			else
				self.ToggleBtnFemale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
			end
		else
			UIUtil.SetIsVisible(self.ToggleBtnFemale, false)
		end
	end
end

function LoginCreateRaceGenderPageView:OnToggleMaleBtnClick(ToggleButton, ButtonState)
	local function DoToggleMale()
		local IsSuccess = LoginRoleRaceGenderVM:ChangeGender(ProtoCommon.role_gender.GENDER_MALE)

		local TipList = {}
		table.insert(TipList, {ID = 1, SortPriority = 21})
		table.insert(TipList, {ID = 2, SortPriority = 11})
		table.sort(TipList, function(a, b)
			return a.SortPriority < b.SortPriority
		end)
		if IsSuccess then
			self.ToggleBtnMale:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
			self.ToggleBtnFemale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)

			_G.LoginUIMgr:ClearRoleWearSuit()
			_G.LoginUIMgr:CreateRenderActor()
			-- _G.LoginUIMgr:ChangeGender()
			_G.LoginUIMgr:ClearRoleSuitTryOn()

			self:PlayAnimation(self.AnimBtnMale)
			_G.LoginUIMgr:SetFeedbackAnimType(3)
			_G.LoginUIMgr.LoginReConnectMgr:SaveValue("Gender", ProtoCommon.role_gender.GENDER_MALE)
			_G.ObjectMgr:CollectGarbage(false)
		end
	end
	local function DoCancel()
		--取消时，要把点击的按钮高亮取消
		self.ToggleBtnMale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end

	_G.LoginAvatarMgr:CheckUpdateRoleFacePreset(LoginRoleRaceGenderVM:GetTribeID()
		, ProtoCommon.role_gender.GENDER_MALE, DoToggleMale, DoCancel)
end

function LoginCreateRaceGenderPageView:OnToggleFemaleBtnClick(ToggleButton, ButtonState)
	local function DoToggleFemale()
		local IsSuccess = LoginRoleRaceGenderVM:ChangeGender(ProtoCommon.role_gender.GENDER_FEMALE)
		if IsSuccess then
			self.ToggleBtnFemale:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
			self.ToggleBtnMale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)

			_G.LoginUIMgr:ClearRoleWearSuit()
			_G.LoginUIMgr:CreateRenderActor()
			-- _G.LoginUIMgr:ChangeGender()
			_G.LoginUIMgr:ClearRoleSuitTryOn()

			self:PlayAnimation(self.AnimBtnFemale)
			_G.LoginUIMgr:SetFeedbackAnimType(3)
			
			_G.LoginUIMgr.LoginReConnectMgr:SaveValue("Gender", ProtoCommon.role_gender.GENDER_FEMALE)
			_G.ObjectMgr:CollectGarbage(false)
		end
	end
	local function DoCancel()
		--取消时，要把点击的按钮高亮取消
		self.ToggleBtnFemale:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end

	_G.LoginAvatarMgr:CheckUpdateRoleFacePreset(LoginRoleRaceGenderVM:GetTribeID()
		, ProtoCommon.role_gender.GENDER_FEMALE, DoToggleFemale, DoCancel)
end

return LoginCreateRaceGenderPageView
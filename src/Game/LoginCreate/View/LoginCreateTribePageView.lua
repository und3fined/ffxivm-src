---
--- Author: chriswang
--- DateTime: 2023-10-20 09:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

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
local LoginRoleTribePageVM = require("Game/LoginRole/LoginRoleTribePageVM")

---@class LoginCreateTribePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RaceInfo LoginCreateRaceInfoPanelView
---@field TribeItem01 LoginCreateTribeItemView
---@field TribeItem02 LoginCreateTribeItemView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateTribePageView = LuaClass(UIView, true)

function LoginCreateTribePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RaceInfo = nil
	--self.TribeItem01 = nil
	--self.TribeItem02 = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateTribePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RaceInfo)
	self:AddSubView(self.TribeItem01)
	self:AddSubView(self.TribeItem02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateTribePageView:OnInit()
	self.ViewModel = LoginRoleTribePageVM--.New()	方便记录数据，不过得在UIViewModelConfig中配置，否则无法绑定view
end

function LoginCreateTribePageView:OnDestroy()

end

function LoginCreateTribePageView:OnShow()
	--默认选择第一步随机到的那个种族
	self.ViewModel:FilterAllCfgByRaceIDAndGender()
	self.ViewModel.NeedReCreateActor = false

	--设置种族图标
	local TribeList = self.ViewModel.RaceListByRaceAndGender
	if TribeList and #TribeList >= 2 then
		for index = 1, 2 do
			self.ViewModel["TribeIcon" .. index] = TribeList[index].TribeIcon
		end
	end

	self:OnTribeTableViewSelectChange(self.ViewModel.CurrentSelectIndex)
end

function LoginCreateTribePageView:OnHide()

end

function LoginCreateTribePageView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.TribeItem01.ToggleBtnTribe, self.OnBtnTribeClick, 1)
	UIUtil.AddOnStateChangedEvent(self, self.TribeItem02.ToggleBtnTribe, self.OnBtnTribeClick, 2)
end

function LoginCreateTribePageView:OnRegisterGameEvent()

end

function LoginCreateTribePageView:OnRegisterBinder()
	local Binders = {
		{ "TribeName", UIBinderSetText.New(self, self.RaceInfo.TextRace) },
		{ "TribeDesc", UIBinderSetText.New(self, self.RaceInfo.TextInfo) },
        {"RaceDescLogo", UIBinderSetBrushFromAssetPath.New(self, self.RaceInfo.ImgLogo)},
        {"TribeIcon1", UIBinderSetBrushFromAssetPath.New(self, self.TribeItem01.ImgIcon)},
        {"TribeIcon2", UIBinderSetBrushFromAssetPath.New(self, self.TribeItem02.ImgIcon)},
		-- { "TribeNameList", UIBinderUpdateBindableList.New(self, self.AdapterTribeTableView) },
		{ "RefreshUI", UIBinderValueChangedCallback.New(self, nil, self.OnRefreshUI) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCreateTribePageView:OnRefreshUI(bRefresh)
	if bRefresh then
		--设置种族图标
		local TribeList = self.ViewModel.RaceListByRaceAndGender
		if TribeList then
			for index = 1, 2 do
				self.ViewModel["TribeIcon" .. index] = TribeList[index].TribeIcon
			end
		end

		self.ViewModel.NeedReCreateActor = false	--这里不用重新刷新actor
		self:OnTribeTableViewSelectChange(self.ViewModel.CurrentSelectIndex)
		self.ViewModel.NeedReCreateActor = true
	end
end

--选择不同种族
function LoginCreateTribePageView:OnTribeTableViewSelectChange(Index, bByClick)
	local TribeList = self.ViewModel.RaceListByRaceAndGender
	FLOG_INFO("Login SelectTribe index:%d", Index)
	if Index >= 1 and #TribeList >= Index then
		local SelectTribeID = TribeList[Index].Tribe

		local function DoSelectTribe()
			if self.ViewModel.NeedReCreateActor or SelectTribeID ~= self.ViewModel.TribeID then
				FLOG_INFO("Login SelectTribe : %s index:%d", TribeList[Index].TribeName, Index)
				self.ViewModel:SelectTribe(Index)
				_G.LoginUIMgr:ChangeTribe(SelectTribeID)

			end
			
			_G.LoginUIMgr.LoginReConnectMgr:SaveValue("TribID", SelectTribeID)

			if Index == 1 then
				self.TribeItem01.ToggleBtnTribe:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
				self.TribeItem02.ToggleBtnTribe:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
				self.TribeItem01:StopAllAnimations()
				self.TribeItem01:PlayAnimation(self.TribeItem01.AimChecked)

				self.TribeItem02:StopAllAnimations()
				self.TribeItem02:PlayAnimation(self.TribeItem02.AnimUnchecked)
			else
				self.TribeItem01.ToggleBtnTribe:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
				self.TribeItem02.ToggleBtnTribe:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
				self.TribeItem01:StopAllAnimations()
				self.TribeItem01:PlayAnimation(self.TribeItem01.AnimUnchecked)
				self.TribeItem02:StopAllAnimations()
				self.TribeItem02:PlayAnimation(self.TribeItem02.AimChecked)
			end
			
			_G.ObjectMgr:CollectGarbage(false)
		end

		local function DoCancel()
			--反选
			if Index ~= 1 then
				self.TribeItem02.ToggleBtnTribe:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
			else
				self.TribeItem01.ToggleBtnTribe:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
			end
		end

		if bByClick then
			_G.LoginAvatarMgr:CheckUpdateRoleFacePreset(SelectTribeID, TribeList[Index].Gender, DoSelectTribe, DoCancel)
		else
			DoSelectTribe()
		end
	end
end

function LoginCreateTribePageView:OnBtnTribeClick(Index)
	if self.ViewModel.CurrentSelectIndex == Index then
		return
	end

	self.ViewModel.NeedReCreateActor = true
	self:OnTribeTableViewSelectChange(Index, true)
	self.ViewModel.NeedReCreateActor = false
	self.RaceInfo:PlayAnimation(self.RaceInfo.AnimIn)
end

return LoginCreateTribePageView
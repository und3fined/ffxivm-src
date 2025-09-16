---
--- Author: chriswang
--- DateTime: 2023-10-17 15:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RaceCfg = require("TableCfg/RaceCfg")
local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")

---@class LoginCreateRaceTribeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgPrefixNormal UFImage
---@field ImgPrefixSelect UFImage
---@field ToggleBtnRace UToggleButton
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateRaceTribeItemView = LuaClass(UIView, true)

function LoginCreateRaceTribeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgPrefixNormal = nil
	--self.ImgPrefixSelect = nil
	--self.ToggleBtnRace = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateRaceTribeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateRaceTribeItemView:OnInit()

end

function LoginCreateRaceTribeItemView:OnDestroy()

end

function LoginCreateRaceTribeItemView:OnShow()
	if self.Params and self.Params.Data then
		self.RaceCfg = self.Params.Data
	
		if self.RaceCfg then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgPrefixSelect, self.RaceCfg.RaceIconSelected)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgPrefixNormal, self.RaceCfg.RaceIcon)
		end
	end

end

function LoginCreateRaceTribeItemView:SetInfo(Index, RaceCfg)
	self.Index = Index
	self.RaceCfg = RaceCfg

	if RaceCfg then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPrefixSelect, RaceCfg.RaceIconSelected)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPrefixNormal, RaceCfg.RaceIcon)
	end
end

function LoginCreateRaceTribeItemView:OnHide()

end

function LoginCreateRaceTribeItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnRace, self.OnToggleBtnRaceClick)

end

function LoginCreateRaceTribeItemView:OnRegisterGameEvent()

end

function LoginCreateRaceTribeItemView:OnRegisterBinder()

end

function LoginCreateRaceTribeItemView:OnToggleBtnRaceClick(ToggleButton, ButtonState)
	-- if self.ParentView then
	-- 	self.ParentView:OnRaceTableViewSelectChangeByClick(self.Index)
	-- end

	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end
	
	self:UnSelect()
	
	local function DoSelectRace()
		self:Select()
		Adapter:OnItemClicked(self, Params.Index)
	end

	local function DoCancel()
		-- --点了当前种族再取消，不反选当前种族
		-- if self.ViewModel.LastSelectIndex == Index then
		-- 	return
		-- end
		-- --反选点了的其他种族
		-- local CurToggleBtnRace = self["TribeItem0" .. Index]
		-- if CurToggleBtnRace then
		-- 	CurToggleBtnRace.ToggleBtnRace:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		-- end
	end

	local Index = Params.Index
	local RaceList = LoginRoleRaceGenderVM.RaceList
	if Index >= 1 and #RaceList >= Index then
		--这里用于Check的部族、性别都不是最终的
		--得OnRaceTableViewSelectChange的GetGenderByRaceID按概率决定
		local TribeID = RaceList[Index].Tribe
		_G.LoginAvatarMgr:CheckUpdateRoleFacePreset(TribeID
			, RaceList[Index].Gender, DoSelectRace, DoCancel, true)
	end

	-- Adapter:OnItemClicked(self, Params.Index)
end

function LoginCreateRaceTribeItemView:Select()
	-- FLOG_INFO("Logintribe OnSelectChanged  Checked %d", self.Params.Index)
	self:StopAllAnimations()
	self.ToggleBtnRace:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	self:PlayAnimation(self.AnimChecked)
end

function LoginCreateRaceTribeItemView:UnSelect()
	-- FLOG_INFO("Logintribe OnSelectChanged  UnChecked %d", self.Params.Index)
	-- self:StopAnimation(self.AnimChecked)
	self:StopAllAnimations()
	self.ToggleBtnRace:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	self:PlayAnimation(self.AnimUnchecked)
end

function LoginCreateRaceTribeItemView:OnSelectChanged(IsSelected)
	self:StopAllAnimations()
	if IsSelected then
		-- FLOG_INFO("======Logintribe RaceTribeItemView  Checked %d", self.Params.Index)
		self:PlayAnimation(self.AnimChecked)
		self.ToggleBtnRace:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	else
		-- FLOG_INFO("======Logintribe RaceTribeItemView  UnChecked %d", self.Params.Index)
		self:PlayAnimation(self.AnimUnchecked)
		self.ToggleBtnRace:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	end
end

return LoginCreateRaceTribeItemView
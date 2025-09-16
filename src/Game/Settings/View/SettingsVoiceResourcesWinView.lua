---
--- Author: chriswang
--- DateTime: 2024-07-26 11:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

--@ViewModel
local SettingsVoiceResVM = require("Game/Settings/VM/SettingsVoiceResVM")

local SettingsDefine = require("Game/Settings/SettingsDefine")
local LanguageType = SettingsDefine.LanguageType
local AudioUtil = require("Utils/AudioUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LSTR = _G.LSTR

---@class SettingsVoiceResourcesWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnConfirm CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsVoiceResourcesWinView = LuaClass(UIView, true)

function SettingsVoiceResourcesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnConfirm = nil
	--self.Comm2FrameM_UIBP = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsVoiceResourcesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsVoiceResourcesWinView:OnInit()
	self.ViewModel = SettingsVoiceResVM
	self.AdapterTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnTableViewSelectChange, true)

end

function SettingsVoiceResourcesWinView:OnDestroy()

end

function SettingsVoiceResourcesWinView:OnShow()
	self.ViewModel:RefreshLanguageList(true)

	self.AdapterTableView:ScrollToTop()
	self.AdapterTableView:SetSelectedIndex(self.ViewModel.CurrentSelectIndex)

	self.Comm2FrameM_UIBP:SetTitleText(LSTR(110013))	--语音资源管理
	self.BtnConfirm:SetBtnName(LSTR(110032))
	self.BtnCancel:SetBtnName(LSTR(110021))
	-- Self是 SettingsItemView
	-- {ViewObj = self, CallBack = self.OnCustomUIClose, Value = Value}
	if self.Params then
	end
end

function SettingsVoiceResourcesWinView:OnHide()
	self.CurSelectItemViewData = nil
end

function SettingsVoiceResourcesWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm.Button, self.OnConfirmBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnBtnCancelBtnClick)

end

function SettingsVoiceResourcesWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OnVoicePkgDownLoad, self.OnVoicePkgDownLoad)

end

function SettingsVoiceResourcesWinView:OnRegisterBinder()
	local Binders = {
		{ "LanguageList", UIBinderUpdateBindableList.New(self, self.AdapterTableView) },

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function SettingsVoiceResourcesWinView:OnTableViewSelectChange(Index, ItemData, ItemView, IsByClick)
	-- local RaceList = self.ViewModel.RaceList
	FLOG_INFO("========= SettingsVoiceResourcesWinView index:%d", Index)
	self.ViewModel.CurrentSelectIndex = Index
	if ItemView then
		local Data = self.ViewModel:GetCurSelectData()--ItemView.Params.Data
		if Data.IsUsing then
			self.BtnConfirm:SetBtnName(LSTR(110032))
			self.BtnCancel:SetBtnName(LSTR(110021))
		elseif Data.IsExist then
			self.BtnConfirm:SetBtnName(LSTR(110032))
			self.BtnCancel:SetBtnName(LSTR(110019))
		elseif not Data.IsExist then
			self.BtnConfirm:SetBtnName(LSTR(110016))
			self.BtnCancel:SetBtnName(LSTR(110021))
		end

		-- self.CurSelectItemViewData = Data
	else
		self.BtnConfirm:SetBtnName(LSTR(110032))
		self.BtnCancel:SetBtnName(LSTR(110021))
	end
end

function SettingsVoiceResourcesWinView:OnConfirmBtnClick()
	-- Self是 SettingsItemView
	-- {ViewObj = self, CallBack = self.OnCustomUIClose, Value = Value}
	self.CurSelectItemViewData = self.ViewModel:GetCurSelectData()
	if self.CurSelectItemViewData then
		local CurName = self.CurSelectItemViewData.LanguageName
		local SelectValue = LanguageType[CurName] or 1
		if self.CurSelectItemViewData.IsUsing then
			self.Params.CallBack(self.Params.ViewObj, SelectValue)
			FLOG_INFO("setting OnConfirmBtnClick Select1 %s - %d", CurName, SelectValue)
			self:Hide()
		elseif self.CurSelectItemViewData.IsExist then
			local function OkBtnback()
				self.Params.CallBack(self.Params.ViewObj, SelectValue)
				FLOG_INFO("setting OnConfirmBtnClick Select2 %s - %d", CurName, SelectValue)
				self:Hide()
				CommonUtil.QuitGame()
			end
			
			local function CanceBtnlback()
			end
			
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), LSTR(110018)
				, OkBtnback, CanceBtnlback)
		else
			-- FLOG_INFO("self.Params.ViewObj :%s", tostring(self.Params.ViewObj))
			-- FLOG_INFO("self.Params.ViewObj ItemVM :%s", tostring(self.Params.ViewObj.ItemVM))
			-- FLOG_INFO("self.Params.ViewObj ItemVM.SettingCfg :%s", tostring(self.Params.ViewObj.ItemVM.SettingCfg))
			-- if self.Params.ViewObj and self.Params.ViewObj.ItemVM.SettingCfg then
			-- 	self.CurSelectItemViewData.SaveKey = self.Params.ViewObj.ItemVM.SettingCfg.SaveKey
			-- end
			_G.UIViewMgr:ShowView(_G.UIViewID.SettingsPkgDownLoadPanel, self.CurSelectItemViewData)
		end
	end
end

function SettingsVoiceResourcesWinView:OnVoicePkgDownLoad()
	FLOG_INFO("		=======setting OnVoicePkgDownLoad=====")
	-- self.ViewModel:RefreshLanguageList()
	self.AdapterTableView:SetSelectedIndex(self.ViewModel.CurrentSelectIndex)

	self.BtnConfirm:SetBtnName(LSTR(110032))
	self.BtnCancel:SetBtnName(LSTR(110019))
end

function SettingsVoiceResourcesWinView:OnBtnCancelBtnClick()
	self.CurSelectItemViewData = self.ViewModel:GetCurSelectData()
	if self.CurSelectItemViewData then
		if self.CurSelectItemViewData.IsExist then	--删除
			if self.CurSelectItemViewData.IsUsing then
				self:Hide()
				return
			end
			-- if self.CurSelectItemViewData.IsDefault == 1 then
			-- 	if not self.CurSelectItemViewData.IsUsing then
			-- 		_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), LSTR(110038))
			-- 	else
			-- 		self:Hide()
			-- 	end

			-- 	return
			-- end

			if true then
				_G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(110026), LSTR(110020))
				return
			end

			-- self:Hide()
			local TipContent = string.format(LSTR(110033), self.CurSelectItemViewData.Text)
			
			local function OkBtnCallback()
				local FilesInfo = _G.UE.UVersionMgr.Get():GetL10nInfo(_G.UE.EGameL10nType.Voices, self.CurSelectItemViewData.LanguageType)
				if FilesInfo then			
					local FileCnt = FilesInfo.L10Ns:Length()
					local Dir = _G.UE.UPufferMgr.Get():GetPufferDownloadDir()
					for i = 1, FileCnt, 1 do
						local FileInfo = FilesInfo.L10Ns:Get(i)
						if string.find(FileInfo.Name, "pak") then
							FLOG_INFO("setting to del Voice Pak:%s dir:%s", FileInfo.Name, Dir)
							local PakPath = string.format("%s/%s", Dir, FileInfo.Name)
							local Rlt = _G.UE.UVersionMgr.Get():UnMountPak(PakPath)
							FLOG_INFO("UnMountPak Rlt:%s", tostring(Rlt))
							Rlt = _G.UE.UPathMgr.DeleteFile(PakPath)
							FLOG_INFO("DeleteFile Rlt:%s", tostring(Rlt))
						else
							local PakPath = string.format("%s%s", Dir, FileInfo.Name)
							FLOG_INFO("setting to del Voice file:%s dir:%s", FileInfo.Name, Dir)
							local Rlt = _G.UE.UPathMgr.DeleteFile(PakPath)
							FLOG_INFO("DeleteFile Rlt:%s", tostring(Rlt))
						end
					end
					
					self:Hide()
				end
			end
			
			local function CanceBtnlback()
			end

			_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(110026), TipContent, OkBtnCallback, CanceBtnlback)
		else
			self:Hide()
		end
	else
		self:Hide()
	end
end

return SettingsVoiceResourcesWinView
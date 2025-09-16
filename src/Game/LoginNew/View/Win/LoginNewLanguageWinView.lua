---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:59
--- Description:
---

local UIView = require("UI/UIView")
local CommonUtil = require("Utils/CommonUtil")
local LoginLanguageVM = require("Game/LoginNew/VM/LoginLanguageVM")
local LuaClass = require("Core/LuaClass")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginStrID = LoginNewDefine.LoginStrID

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local ObjectPoolMgr = _G.ObjectPoolMgr

local LSTR = _G.LSTR

---@class LoginNewLanguageWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnConfirm CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewLanguageWinView = LuaClass(UIView, true)

function LoginNewLanguageWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnConfirm = nil
	--self.Comm2FrameM_UIBP = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewLanguageWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnConfirm)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewLanguageWinView:OnInit()
	self.Comm2FrameM_UIBP.FText_Title:SetText(LSTR(LoginStrID.ChooseLanguage))
	self.BtnConfirm.TextContent:SetText(LSTR(LoginStrID.ConfirmBtnStr))

	--self.LanguageVM = LoginLanguageVM.New()
	---@type LoginLanguageVM
	self.LanguageVM = ObjectPoolMgr:AllocObject(LoginLanguageVM)
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChanged,true)

	self.Binders = {
		{ "LanguageList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
	}
end

function LoginNewLanguageWinView:OnDestroy()

end

function LoginNewLanguageWinView:OnShow()
	self.LanguageVM:UpdateLanguageList()
	--self.TableViewAdapter:UpdateAll(LanguageListData)

	self.TableViewAdapter:SetSelectedIndex(self:GetCurrentCulture())
end

function LoginNewLanguageWinView:OnHide()

end

function LoginNewLanguageWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)
end

function LoginNewLanguageWinView:OnRegisterGameEvent()

end

function LoginNewLanguageWinView:OnRegisterBinder()
	self:RegisterBinders(self.LanguageVM, self.Binders)
end

function LoginNewLanguageWinView:OnClickBtnConfirm()
	if self:GetCurrentCulture() == self.LanguageVM.LanguageIndex then
		self:Hide()
		return
	end

	local function Callback()
		self:SetCurrentCulture(self.LanguageVM.LanguageIndex)
	end
	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(LoginStrID.TipsTitle), LSTR(LoginStrID.LangSwitchContent), Callback, nil, LSTR(LoginStrID.CancelBtnStr), LSTR(LoginStrID.ConfirmBtnStr))
end

function LoginNewLanguageWinView:OnSelectChanged(Index, ItemData, ItemView)
	--FLOG_INFO("[LoginNewLanguageWinView:OnSelectChanged] Index:%d", Index)
	self.LanguageVM.LanguageIndex = Index
end

function LoginNewLanguageWinView:GetCurrentCulture()
	local CurCultureName = CommonUtil.GetCurrentCultureName()
	if string.isnilorempty(CurCultureName) then
		return 1
	end

	return SettingsDefine.LanguageType[CurCultureName] or 1
end

function LoginNewLanguageWinView:SetCurrentCulture(CultureIdx)
	if nil == CultureIdx then
		return
	end

	local Languages = table.invert(SettingsDefine.LanguageType)
	local InCultureName = Languages[CultureIdx]
	if string.isnilorempty(InCultureName) then
		return
	end

	CommonUtil.SetCurrentCulture(InCultureName, true)
	CommonUtil.QuitGame()
end

return LoginNewLanguageWinView
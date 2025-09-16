---
--- Author: jamiyang
--- DateTime: 2023-11-16 10:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetText = require("Binder/UIBinderSetText")
-- ViewModel
local LoginCreateSaveWinVM = require("Game/LoginCreate/LoginCreateSaveWinVM")
local LoginCreateSaveVM = require("Game/LoginCreate/LoginCreateSaveVM")

---@class LoginCreateSaveWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnConfirm CommBtnLView
---@field PanelBtns UFHorizontalBox
---@field SpacerMid USpacer
---@field TableViewSave UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY

---@param Params table	@通过外部参数传入
---@field Params.IsSaved bool @上传/下载

local LoginCreateSaveWinView = LuaClass(UIView, true)

function LoginCreateSaveWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnConfirm = nil
	--self.PanelBtns = nil
	--self.SpacerMid = nil
	--self.TableViewSave = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateSaveWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnConfirm)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateSaveWinView:OnInit()
	self.ViewModel = LoginCreateSaveWinVM.New()
	self.SaveTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewSave, self.OnSaveTableViewSelectChange, false)
end

function LoginCreateSaveWinView:OnDestroy()

end

function LoginCreateSaveWinView:OnShow()
	-- 弹框标题
	local Title = self.Params.IsSaved and _G.LSTR(980020) or _G.LSTR(980021)
	self.BG:SetTitleText(Title)
	-- 存档状态
	LoginCreateSaveVM.bSaved = self.Params.IsSaved
	LoginCreateSaveVM.bCommited = not self.Params.IsSaved
	-- 初始化数据
	self.ViewModel:InitViewData()
	self.BtnCancel:SetText(_G.LSTR(980087)) --"取消"
end

function LoginCreateSaveWinView:OnHide()
	LoginCreateSaveVM.SaveList = {}
end

function LoginCreateSaveWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnConfirm, self.OnClickBtnConfirm)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickBtnCancel)
end

function LoginCreateSaveWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LoginCreateFaceSave, self.OnSaveListChange)
end

function LoginCreateSaveWinView:OnRegisterBinder()
	local Binders = {
		{"ListSaveTableVM", UIBinderUpdateBindableList.New(self, self.SaveTableView) }, -- 存档数据
		{"bBtnConfirmEnable", UIBinderSetIsEnabled.New(self, self.BtnConfirm)}, -- 确定按钮状态
		{"TextBtnConfirm", UIBinderSetText.New(self, self.BtnConfirm.TextContent)},
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCreateSaveWinView:OnSaveListChange()
	self.ViewModel:SetSaveList()

	-- 存档默认选择空存档，无空存档选第一个
	if self.ViewModel.bFirstGetList then
		local ServerNum = table.size(LoginCreateSaveVM.SaveList)
		local  SelectIndex = 1
		if LoginCreateSaveVM.bSaved and ServerNum < 5 then
			SelectIndex = ServerNum + 1
		end
		self.SaveTableView:SetSelectedIndex(SelectIndex)
		self.SaveTableView:ScrollToIndex(SelectIndex)
		self.ViewModel.bFirstGetList = false
	else
		self.SaveTableView:SetSelectedIndex(self.ViewModel.SaveTableIndex)
	end
end

function LoginCreateSaveWinView:OnClickBtnConfirm()
	self.ViewModel:DoConfirmRole()
	--self.SaveTableView:CancelSelected()
end

function LoginCreateSaveWinView:OnClickBtnCancel()
	UIViewMgr:HideView(UIViewID.LoginCreateSaveWin)
end

function LoginCreateSaveWinView:OnSaveTableViewSelectChange(Index)
	self.ViewModel:UpdateSaveTableSelected(Index)
end

return LoginCreateSaveWinView
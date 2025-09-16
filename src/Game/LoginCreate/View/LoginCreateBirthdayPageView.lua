---
--- Author: chriswang
--- DateTime: 2023-10-20 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

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
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

--@ViewModel
local LoginRoleBirthdayVM = require("Game/LoginRole/LoginRoleBirthdayVM")
local LoginReConnectMgr = require("Game/LoginRole/LoginReConnectMgr")

local UKismetInputLibrary = UE.UKismetInputLibrary

---@class LoginCreateBirthdayPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field PopUpBG CommonPopUpBGView
---@field TableViewDate UTableView
---@field TableViewMonth UTableView
---@field TextActualDate UFTextBlock
---@field TextContent UFTextBlock
---@field TextDate UFTextBlock
---@field TextMonth UFTextBlock
---@field ToggleBtnMonth UToggleButton
---@field AnimBtnMonthClick UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateBirthdayPageView = LuaClass(UIView, true)

function LoginCreateBirthdayPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.PopUpBG = nil
	--self.TableViewDate = nil
	--self.TableViewMonth = nil
	--self.TextActualDate = nil
	--self.TextContent = nil
	--self.TextDate = nil
	--self.TextMonth = nil
	--self.ToggleBtnMonth = nil
	--self.AnimBtnMonthClick = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateBirthdayPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	-- self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateBirthdayPageView:OnInit()
	self.ViewModel = LoginRoleBirthdayVM--.New()	方便记录数据，不过得在UIViewModelConfig中配置，否则无法绑定view
	self.AdapterTableViewDate = UIAdapterTableView.CreateAdapter(self, self.TableViewDate, self.OnTableViewDateSelectChange, true)

	self.AdapterTableViewMonth = UIAdapterTableView.CreateAdapter(self, self.TableViewMonth, self.OnTableViewMonthSelectChange, true)
end

function LoginCreateBirthdayPageView:OnDestroy()

end

function LoginCreateBirthdayPageView:OnShow()
	self.ViewModel:InitCalendarList()
	self.AdapterTableViewMonth:SetSelectedIndex(self.ViewModel.SelectMonthIndex)
	self.AdapterTableViewDate:SetSelectedIndex(self.ViewModel.SelectDayIndex)

	self.TextContent:SetText(_G.LSTR(980047))
end

function LoginCreateBirthdayPageView:OnHide()

end

function LoginCreateBirthdayPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnBtnLeftClick)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnBtnRightClick)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnMonth, self.OnToggleBtnMonthClick)
end

function LoginCreateBirthdayPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function LoginCreateBirthdayPageView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelMonthList, MousePosition) == false
		and UIUtil.IsUnderLocation(self.ToggleBtnMonth, MousePosition) == false then
		self:OnSelectMonth()
	end
end

function LoginCreateBirthdayPageView:OnRegisterBinder()
	local Binders = {
		{ "TextMonthStr", UIBinderSetText.New(self, self.TextMonth) },
		{ "TextDateStr", UIBinderSetText.New(self, self.TextDate) },
		{ "TextActualDateStr", UIBinderSetText.New(self, self.TextActualDate) },
		{ "DateList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewDate) },
		{ "MonthList", UIBinderUpdateBindableList.New(self, self.AdapterTableViewMonth) },
		{ "SelectMonthIndex", UIBinderSetSelectedIndex.New(self, self.AdapterTableViewMonth) },
		{ "SelectDayIndex", UIBinderSetSelectedIndex.New(self, self.AdapterTableViewDate) },

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

--选日期
function LoginCreateBirthdayPageView:OnTableViewDateSelectChange(Index, ItemData, ItemView)
	self.ViewModel:SelectDate(Index)
end

--选月份
function LoginCreateBirthdayPageView:OnTableViewMonthSelectChange(Index, ItemData, ItemView)
	if self.ViewModel.SelectMonthIndex ~= Index then
		self:PlayAnimation(self.AnimBtnMonthClick)
	end
	
	self.ViewModel:SelectMonth(Index)

	--收起下拉列表
	self:OnSelectMonth()
end

--左切换月
function LoginCreateBirthdayPageView:OnBtnLeftClick()
	-- self.ToggleBtnMonth:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)

	local CurIndex = self.ViewModel.SelectMonthIndex
	if CurIndex == 1 then
		self.ViewModel:SelectMonth(12)
	else
		self.ViewModel:SelectMonth(CurIndex - 1)
	end

	self:PlayAnimation(self.AnimBtnMonthClick)
end

--右切换月
function LoginCreateBirthdayPageView:OnBtnRightClick()
	-- self.ToggleBtnMonth:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)

	local CurIndex = self.ViewModel.SelectMonthIndex
	if CurIndex == 12 then
		self.ViewModel:SelectMonth(1)
	else
		self.ViewModel:SelectMonth(CurIndex + 1)
	end
	
	self:PlayAnimation(self.AnimBtnMonthClick)
end

function LoginCreateBirthdayPageView:OnToggleBtnMonthClick(ToggleButton, ButtonState)
	local bOpen = ButtonState == _G.UE.EToggleButtonState.Checked
	if bOpen then
		self.ToggleBtnMonth:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		-- UIUtil.SetIsVisible(self.TableViewDate, false, false)
	else
		self:OnSelectMonth()
	end
end

--收起下拉列表
function LoginCreateBirthdayPageView:OnSelectMonth()
	self.ToggleBtnMonth:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	-- UIUtil.SetIsVisible(self.TableViewDate, true, true)
end

return LoginCreateBirthdayPageView
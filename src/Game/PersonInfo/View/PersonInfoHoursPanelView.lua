---
--- Author: xingcaicao
--- DateTime: 2023-04-21 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LSTR 
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

---@class PersonInfoHoursPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnSave CommBtnLView
---@field FrameL Comm2FrameLView
---@field TableViewRestDayL UTableView
---@field TableViewRestDayR UTableView
---@field TableViewWeekdayL UTableView
---@field TableViewWeekdayR UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoHoursPanelView = LuaClass(UIView, true)

function PersonInfoHoursPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnSave = nil
	--self.FrameL = nil
	--self.TableViewRestDayL = nil
	--self.TableViewRestDayR = nil
	--self.TableViewWeekdayL = nil
	--self.TableViewWeekdayR = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoHoursPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.FrameL)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoHoursPanelView:OnInit()
	LSTR = _G.LSTR
	self.TableAdapterWeekdayL = UIAdapterTableView.CreateAdapter(self, self.TableViewWeekdayL)
	self.TableAdapterWeekdayR = UIAdapterTableView.CreateAdapter(self, self.TableViewWeekdayR)

	self.TableAdapterRestDayL = UIAdapterTableView.CreateAdapter(self, self.TableViewRestDayL)
	self.TableAdapterRestDayR = UIAdapterTableView.CreateAdapter(self, self.TableViewRestDayR)

	self.Binders = {
		{ "HourTogKey1", 	UIBinderSetIsChecked.New(self, self.CommSingleBox.ToggleButton) },
		{ "HourTogKey2", 	UIBinderSetIsChecked.New(self, self.CommSingleBox2.ToggleButton) },
		{ "HourTogKey3", 	UIBinderSetIsChecked.New(self, self.CommSingleBox3.ToggleButton) },
		{ "HourTogKey4", 	UIBinderSetIsChecked.New(self, self.CommSingleBox4.ToggleButton) },

		{ "ActiveHoursSet", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedActiveHoursSet) },
		{ "ActiveHourTempSet", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedTempSet) },
	}

	self:InitLSTR()
end

function PersonInfoHoursPanelView:InitLSTR()
	self.FrameL.FText_Title:SetText(LSTR(620064))
	self.TextWeekday:SetText(LSTR(620050))
	self.TextRestDay:SetText(LSTR(620051))

	self.TextTime:SetText(LSTR(620062))
	self.TextTime2:SetText(LSTR(620063))
	self.TextTime3:SetText(LSTR(620062))
	self.TextTime4:SetText(LSTR(620063))


	self.BtnSave:SetText(LSTR(10002))
	self.BtnCancel:SetText(LSTR(10003))

	for i = 0, 23 do
		local idx = 620070 + i
		self["Text" .. i]:SetText(LSTR(idx))
		self["TextRest" .. i]:SetText(LSTR(idx))
	end
end

function PersonInfoHoursPanelView:OnDestroy()

end

function PersonInfoHoursPanelView:OnShow()
	local Data = {}

	for i = 1, 48 do
		table.insert(Data, { ID = i, IsSet = true })

		if i == 12 then
			self.TableAdapterWeekdayL:UpdateAll(Data)
		elseif i == 24 then 
			self.TableAdapterWeekdayR:UpdateAll(Data)
		elseif i == 36 then 
			self.TableAdapterRestDayL:UpdateAll(Data)
		elseif i == 48 then 
			self.TableAdapterRestDayR:UpdateAll(Data)
		end

		if i % 12 == 0 then
			Data = {}
		end
	end

	self.BtnSave:SetIsEnabled(false)
end

function PersonInfoHoursPanelView:OnHide()
    PersonInfoVM.HoursItemPressed = false
	PersonInfoVM.ActiveHourTempSet = 0 
end

function PersonInfoHoursPanelView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox.ToggleButton, self.OnClickTog1)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox2.ToggleButton, self.OnClickTog2)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox3.ToggleButton, self.OnClickTog3)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox4.ToggleButton, self.OnClickTog4)



	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
end

function PersonInfoHoursPanelView:OnRegisterGameEvent()

end

function PersonInfoHoursPanelView:OnRegisterBinder()
	self:RegisterBinders(PersonInfoVM, self.Binders)
end

function PersonInfoHoursPanelView:OnValueChangedActiveHoursSet(Set)
	PersonInfoVM.ActiveHourTempSet = Set
end

function PersonInfoHoursPanelView:OnValueChangedTempSet(Set)
	if nil == Set then
		self.BtnSave:SetIsEnabled(false)
		return
	end

	self.BtnSave:SetIsEnabled(Set ~= PersonInfoVM.ActiveHoursSet)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function PersonInfoHoursPanelView:OnClickButtonSave()
	local StrHoursBitValue = tostring(PersonInfoVM.ActiveHourTempSet)
	if nil == StrHoursBitValue then
		return
	end

	self.BtnSave:SetIsEnabled(false)
	_G.ClientSetupMgr:SetActiveHours(StrHoursBitValue)

	self:OnClickButtonCancel()
end

function PersonInfoHoursPanelView:OnClickButtonCancel()
	self:Hide()
end

function PersonInfoHoursPanelView:OnClickTog1(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked
	PersonInfoVM:UpdateActiveHoursTempSetGroup(1, IsShow)
end

function PersonInfoHoursPanelView:OnClickTog2(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked
	PersonInfoVM:UpdateActiveHoursTempSetGroup(2, IsShow)
end

function PersonInfoHoursPanelView:OnClickTog3(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked
	PersonInfoVM:UpdateActiveHoursTempSetGroup(3, IsShow)
end

function PersonInfoHoursPanelView:OnClickTog4(ToggleButton, ButtonState)
	local IsShow = ButtonState == _G.UE.EToggleButtonState.Checked
	PersonInfoVM:UpdateActiveHoursTempSetGroup(4, IsShow)
end

return PersonInfoHoursPanelView
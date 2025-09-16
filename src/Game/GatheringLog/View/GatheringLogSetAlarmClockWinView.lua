---
--- Author: Leo
--- DateTime: 2023-03-29 10:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local GatheringLogMgr = require("Game/GatheringLog/GatheringLogMgr")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local GatheringLogVM = require("Game/GatheringLog/GatheringLogVM")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR

---@class GatheringLogSetAlarmClockWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnSaveSettings CommBtnLView
---@field CheckBox1M CommCheckBoxView
---@field CheckBox3M CommCheckBoxView
---@field CheckBox5M CommCheckBoxView
---@field SingleBoxMS CommSingleBoxView
---@field SingleBoxNV CommSingleBoxView
---@field SingleBoxSN CommSingleBoxView
---@field SingleBoxWP CommSingleBoxView
---@field SingleBoxWS CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringLogSetAlarmClockWinView = LuaClass(UIView, true)

function GatheringLogSetAlarmClockWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSaveSettings = nil
	--self.CheckBox1M = nil
	--self.CheckBox3M = nil
	--self.CheckBox5M = nil
	--self.SingleBoxMS = nil
	--self.SingleBoxNV = nil
	--self.SingleBoxSN = nil
	--self.SingleBoxWP = nil
	--self.SingleBoxWS = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringLogSetAlarmClockWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSaveSettings)
	self:AddSubView(self.CheckBox1M)
	self:AddSubView(self.CheckBox3M)
	self:AddSubView(self.CheckBox5M)
	self:AddSubView(self.SingleBoxMS)
	self:AddSubView(self.SingleBoxNV)
	self:AddSubView(self.SingleBoxSN)
	self:AddSubView(self.SingleBoxWP)
	self:AddSubView(self.SingleBoxWS)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringLogSetAlarmClockWinView:OnInit()
	self.Binders = {
		{"MSCheckState", UIBinderSetCheckedState.New(self, self.SingleBoxMS.ToggleButton)},
		{"WSCheckState", UIBinderSetCheckedState.New(self, self.SingleBoxWS.ToggleButton)},
		{"WPCheckState", UIBinderSetCheckedState.New(self, self.SingleBoxWP.ToggleButton)},
		{"CheckState1M", UIBinderSetCheckedState.New(self, self.CheckBox1M.ToggleButton)},
		{"CheckState3M", UIBinderSetCheckedState.New(self, self.CheckBox3M.ToggleButton)},
		{"CheckState5M", UIBinderSetCheckedState.New(self, self.CheckBox5M.ToggleButton)},
		{"NVCheckState", UIBinderSetCheckedState.New(self, self.SingleBoxNV.ToggleButton)},
		{"SNCheckState", UIBinderSetCheckedState.New(self, self.SingleBoxSN.ToggleButton)},
	}

end

function GatheringLogSetAlarmClockWinView:OnDestroy()

end

function GatheringLogSetAlarmClockWinView:OnShow()
	self.BG:SetTitleText(LSTR(70056))--闹钟设置
	self.BtnCancel:SetText(LSTR(10003)) --取消
	self.BtnSaveSettings:SetText(LSTR(10011))--保存
	self.CheckBox1M:SetText(LSTR(70051))--开始前1分钟
	self.CheckBox3M:SetText(LSTR(70052))--开始前3分钟
	self.CheckBox5M:SetText(LSTR(70053))--开始前5分钟
	self.SingleBoxMS:SetText(LSTR(70048))--在主界面显示提醒
	self.SingleBoxNV:SetText(LSTR(70054))--开启提示音
	self.SingleBoxSN:SetText(LSTR(70055))--处于副本时不再提示
	self.SingleBoxWP:SetText(LSTR(70050))--提前提醒
	self.SingleBoxWS:SetText(LSTR(70049))--准点提醒
	--初始化界面是在GatheringLogMainPanelView:OnShow()->UpdateClockSetting()->GatheringLogVM:SetClockSetting
end

function GatheringLogSetAlarmClockWinView:OnHide()

end

function GatheringLogSetAlarmClockWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnCancelBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnSaveSettings.Button, self.OnSaveBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BG.ButtonClose, self.OnBtnCloseClick)

	UIUtil.AddOnClickedEvent(self, self.SingleBoxMS.ToggleButton, self.OnBtnSingleBoxMSClick)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxWS.ToggleButton, self.OnBtnSingleBoxWSClick)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxWP.ToggleButton, self.OnBtnSingleBoxWPClick)
	UIUtil.AddOnClickedEvent(self, self.CheckBox1M.ToggleButton, self.OnBtnCheckBox1MClick)
	UIUtil.AddOnClickedEvent(self, self.CheckBox3M.ToggleButton, self.OnBtnCheckBox3MClick)
	UIUtil.AddOnClickedEvent(self, self.CheckBox5M.ToggleButton, self.OnBtnCheckBox5MClick)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxNV.ToggleButton, self.OnBtnSingleBoxNVClick)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxSN.ToggleButton, self.OnBtnSingleBoxSNClick)
end

function GatheringLogSetAlarmClockWinView:OnRegisterGameEvent()
end

function GatheringLogSetAlarmClockWinView:OnRegisterBinder()
	self:RegisterBinders(GatheringLogVM, self.Binders)
end

---@type 点击开启主界面提醒
function GatheringLogSetAlarmClockWinView:OnBtnSingleBoxMSClick()
	if not self.SingleBoxMS:GetChecked() then
		self.SingleBoxMS:SetChecked(false)
	else
		self.SingleBoxMS:SetChecked(true)
	end
end

---@type 点击窗口期开始提醒
function GatheringLogSetAlarmClockWinView:OnBtnSingleBoxWSClick()
	if not self.SingleBoxWS:GetChecked() then
		self.SingleBoxWS:SetChecked(false)
	else
		self.SingleBoxWS:SetChecked(true)
	end
end

---@type 点击窗口期提前提醒
function GatheringLogSetAlarmClockWinView:OnBtnSingleBoxWPClick()
	if not self.SingleBoxWP:GetChecked() then
		self.SingleBoxWP:SetChecked(false)
	else
		self.SingleBoxWP:SetChecked(true)
	end

	if not self.SingleBoxWP:GetChecked() then
		--不设置提前提醒
		--颜色置为灰色
		self.CheckBox1M:UpdateColor(false)
		self.CheckBox3M:UpdateColor(false)
		self.CheckBox5M:UpdateColor(false)
		--UIUtil.SetIsVisible(self.PanelWinPreTime, false)
		self.CheckBox1M:SetChecked(false)
        self.CheckBox3M:SetChecked(false)
        self.CheckBox5M:SetChecked(false)
		self.CheckBox1M:SetClickable(false)
		self.CheckBox3M:SetClickable(false)
		self.CheckBox5M:SetClickable(false)
	else
		--设置提前提醒
		self.CheckBox1M:UpdateColor(true)
		self.CheckBox3M:UpdateColor(true)
		self.CheckBox5M:UpdateColor(true)
		self.CheckBox1M:SetClickable(true)
		self.CheckBox3M:SetClickable(true)
		self.CheckBox5M:SetClickable(true)

		UIUtil.SetIsVisible(self.PanelWinPreTime, true)
        self.CheckBox1M:SetChecked(true)
        self.CheckBox3M:SetChecked(false)
        self.CheckBox5M:SetChecked(false)
        self.CheckBox3M:UpdateColor(true)
        self.CheckBox5M:UpdateColor(true)
	end
end

---@type 点击窗口期提前提醒的1分钟
function GatheringLogSetAlarmClockWinView:OnBtnCheckBox1MClick()
	if not self.SingleBoxWP:GetChecked() then
		return
	end
	if not self.CheckBox1M:GetChecked() then
		--就算再次点击也不消失
		self.CheckBox1M:SetChecked(true)
	else
		self.ChoiceTipTime = 1
		self.CheckBox1M:SetChecked(true)
		self.CheckBox3M:SetChecked(false)
		self.CheckBox5M:SetChecked(false)
		self.CheckBox3M:UpdateColor(true)
		self.CheckBox5M:UpdateColor(true)
	end
end

---@type 点击窗口期提前提醒的3分钟
function GatheringLogSetAlarmClockWinView:OnBtnCheckBox3MClick()
	if not self.SingleBoxWP:GetChecked() then
		return
	end
	if not self.CheckBox3M:GetChecked() then
		--就算再次点击也不消失
		self.CheckBox3M:SetChecked(true)
	else
		self.ChoiceTipTime = 3
		self.CheckBox3M:SetChecked(true)
		self.CheckBox1M:SetChecked(false)
		self.CheckBox5M:SetChecked(false)
		self.CheckBox1M:UpdateColor(true)
		self.CheckBox5M:UpdateColor(true)
	end
end

---@type 点击窗口期提前提醒的5分钟
function GatheringLogSetAlarmClockWinView:OnBtnCheckBox5MClick()
	if not self.SingleBoxWP:GetChecked() then
		return
	end
	if not self.CheckBox5M:GetChecked() then
		--就算再次点击也不消失
		self.CheckBox5M:SetChecked(true)
	else
		self.ChoiceTipTime = 5
		self.CheckBox5M:SetChecked(true)
		self.CheckBox3M:SetChecked(false)
		self.CheckBox1M:SetChecked(false)
		self.CheckBox3M:UpdateColor(true)
		self.CheckBox1M:UpdateColor(true)
	end
end

---@type 点击开启提示音
function GatheringLogSetAlarmClockWinView:OnBtnSingleBoxNVClick()
	if not self.SingleBoxNV:GetChecked() then
		self.SingleBoxNV:SetChecked(false)
	else
		self.SingleBoxNV:SetChecked(true)
	end
end

---@type 点击处于封闭任务时不提醒
function GatheringLogSetAlarmClockWinView:OnBtnSingleBoxSNClick()
	if not self.SingleBoxSN:GetChecked() then
		self.SingleBoxSN:SetChecked(false)
	else
		self.SingleBoxSN:SetChecked(true)
	end
end

---@type 点击取消
function GatheringLogSetAlarmClockWinView:OnCancelBtnClick()
	UIViewMgr:HideView(self.ViewID)
end

---@type 点击关闭按钮
function GatheringLogSetAlarmClockWinView:OnBtnCloseClick()
	UIViewMgr:HideView(self.ViewID)
end

---@type 点击保存按钮
function GatheringLogSetAlarmClockWinView:OnSaveBtnClick()
	if  self.SingleBoxMS:GetChecked() then
		GatheringLogVM.MSCheckState = EToggleButtonState.Checked
	else
		GatheringLogVM.MSCheckState = EToggleButtonState.UnChecked
	end

	if self.SingleBoxWS:GetChecked() then
		GatheringLogVM.WSCheckState = EToggleButtonState.Checked
	else
		GatheringLogVM.WSCheckState = EToggleButtonState.UnChecked
	end

	if self.SingleBoxWP:GetChecked() then
		GatheringLogVM.WPCheckState = EToggleButtonState.Checked
	else
		GatheringLogVM.WPCheckState = EToggleButtonState.UnChecked
		GatheringLogVM.CheckState1M = EToggleButtonState.Locked
		GatheringLogVM.CheckState3M = EToggleButtonState.Locked
		GatheringLogVM.CheckState5M = EToggleButtonState.Locked

	end

	if  self.SingleBoxWP:GetChecked() then
		if  self.CheckBox1M:GetChecked() then
			GatheringLogVM.CheckState1M = EToggleButtonState.Checked
		else
			GatheringLogVM.CheckState1M = EToggleButtonState.UnChecked
		end

		if self.CheckBox3M:GetChecked() then
			GatheringLogVM.CheckState3M = EToggleButtonState.Checked
		else
			GatheringLogVM.CheckState3M = EToggleButtonState.UnChecked
		end

		if self.CheckBox5M:GetChecked() then
			GatheringLogVM.CheckState5M = EToggleButtonState.Checked
		else
			GatheringLogVM.CheckState5M = EToggleButtonState.UnChecked
		end
	end

	if  self.SingleBoxNV:GetChecked() then
		GatheringLogVM.NVCheckState = EToggleButtonState.Checked
	else
		GatheringLogVM.NVCheckState = EToggleButtonState.UnChecked
	end

	if  self.SingleBoxSN:GetChecked() then
		GatheringLogVM.SNCheckState = EToggleButtonState.Checked
	else
		GatheringLogVM.SNCheckState = EToggleButtonState.UnChecked
	end

	local ClockSetting = GatheringLogVM:GetClockSetting()
	ClockSetting.IsFirstSet = false
	local SelfNoteType = GatheringLogDefine.GatheringLogNoteType
	GatheringLogMgr:SendMsgClockSettinginfo(SelfNoteType, ClockSetting)
	UIViewMgr:HideView(self.ViewID)

	local GatherID = GatheringLogMgr.LastFilterState.GatherID
	local ItemData = GatheringLogVM:GetItemDataByID(GatherID)
	if ItemData ~= nil then
		local Itemvm = GatheringLogVM:GetItemVMByItemID(ItemData.ItemID)
		local SelfNoteType = GatheringLogDefine.GatheringLogNoteType
		--订阅列表更新，添加或删除(采集闹钟和钓鱼闹钟通用)
		if Itemvm ~= nil and not Itemvm.bSetClock then
			--没有设置闹钟的时候才发，如果已经设置了还发消息，就会取消闹钟
			GatheringLogMgr:SendMsgAfterClockUpdate(SelfNoteType, Itemvm.ID)
		end
	end
end

return GatheringLogSetAlarmClockWinView
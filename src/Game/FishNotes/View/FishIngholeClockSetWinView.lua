---
--- Author: Carl
--- DateTime: 2023-08-15 19:33
--- Description:钓鱼笔记闹钟提醒设置
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ClockSettingVM = require("Game/FishNotes/FishNotesClockSetWindVM")
local FishNoteMgr = require("Game/FishNotes/FishNotesMgr")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LSTR = _G.LSTR

---@class FishIngholeClockSetWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnSaveSettings CommBtnLView
---@field CheckBox1M CommCheckBoxView
---@field CheckBox3M CommCheckBoxView
---@field CheckBox5M CommCheckBoxView
---@field PanelWinPreTime UFCanvasPanel
---@field SingleBoxMS CommSingleBoxView
---@field SingleBoxNV CommSingleBoxView
---@field SingleBoxSN CommSingleBoxView
---@field SingleBoxWP CommSingleBoxView
---@field SingleBoxWS CommSingleBoxView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeClockSetWinView = LuaClass(UIView, true)

function FishIngholeClockSetWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnSaveSettings = nil
	--self.CheckBox1M = nil
	--self.CheckBox3M = nil
	--self.CheckBox5M = nil
	--self.PanelWinPreTime = nil
	--self.SingleBoxMS = nil
	--self.SingleBoxNV = nil
	--self.SingleBoxSN = nil
	--self.SingleBoxWP = nil
	--self.SingleBoxWS = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeClockSetWinView:OnRegisterSubView()
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

function FishIngholeClockSetWinView:OnInit() 
	self.ComingNotifyCheckBoxs = {
		[1] = self.CheckBox1M.ToggleButton,
		[3] = self.CheckBox3M.ToggleButton,
		[5] = self.CheckBox5M.ToggleButton,
	}

	self.Binders = {
		{"Trigger",UIBinderSetIsChecked.New(self,self.SingleBoxMS.ToggleButton)}, --主界面提醒
		{"Trigger",UIBinderValueChangedCallback.New(self, nil, self.OnChangeSingleBoxMS)},
		{"CloseNotify",UIBinderSetIsChecked.New(self,self.SingleBoxSN.ToggleButton)}, --封闭条件下提醒
		{"StartNotify",UIBinderSetIsChecked.New(self,self.SingleBoxWS.ToggleButton)}, --窗口期提醒
		{"IsComingNotify",UIBinderSetIsChecked.New(self,self.SingleBoxWP.ToggleButton)}, --提前提醒
		{"IsComingNotify",UIBinderValueChangedCallback.New(self, nil, self.OnChangeSingleBoxWP)},
		{"ComingNotify",UIBinderValueChangedCallback.New(self, nil, self.OnComingNotify)},
		{"IsNotifySound",UIBinderSetIsChecked.New(self,self.SingleBoxNV.ToggleButton)}, --声音提醒
	}
end

function FishIngholeClockSetWinView:OnDestroy()
	self.PrevSelectCheckBox = nil
	self.ComingNotifyCheckBoxs = nil
end

function FishIngholeClockSetWinView:OnShow()
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
	_G.FishNotesClockSetWindVM:UpdateVM(_G.FishNotesMgr:GetFishNoteClockSetting())
	self.PrevSelectCheckBox = self.ComingNotifyCheckBoxs[ClockSettingVM.ComingNotify]
	self.BtnSaveSettings:SetIsDisabledState(true, true)
	self.bChanged = false
end

function FishIngholeClockSetWinView:OnHide()

end

function FishIngholeClockSetWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.SingleBoxMS.ToggleButton, self.OnBtnClickedSingleBoxMS)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxSN.ToggleButton, self.OnBtnClickedSingleBoxSN)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxWS.ToggleButton, self.OnBtnClickedSingleBoxWS)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxWP.ToggleButton, self.OnBtnClickedSingleBoxWP)
	UIUtil.AddOnClickedEvent(self, self.CheckBox1M.ToggleButton, self.OnBtnClickedCheckBox1M)
	UIUtil.AddOnClickedEvent(self, self.CheckBox3M.ToggleButton, self.OnBtnClickedCheckBox3M)
	UIUtil.AddOnClickedEvent(self, self.CheckBox5M.ToggleButton, self.OnBtnClickedCheckBox5M)
	UIUtil.AddOnClickedEvent(self, self.SingleBoxNV.ToggleButton, self.OnBtnClickedSingleBoxNV)
	UIUtil.AddOnClickedEvent(self,self.BtnCancel.Button,self.OnBtnClickedCancel)
	UIUtil.AddOnClickedEvent(self,self.BtnSaveSettings.Button,self.OnBtnClickedSaveSetting)
	UIUtil.AddOnClickedEvent(self,self.BG.ButtonClose,self.OnBtnClickedCancel)
end

function FishIngholeClockSetWinView:OnRegisterGameEvent()

end

function FishIngholeClockSetWinView:OnRegisterBinder()
	if ClockSettingVM == nil then
		return
	end
	self:RegisterBinders(ClockSettingVM,self.Binders)
end

---@type 主题界面提醒开关
function FishIngholeClockSetWinView:OnBtnClickedSingleBoxMS()
	if ClockSettingVM == nil then
		return
	end
	ClockSettingVM:ChangeClockTrigger()
	self.BtnSaveSettings:SetIsRecommendState(true)
	self.bChanged = true
end

function FishIngholeClockSetWinView:OnChangeSingleBoxMS(Trigger)
	self.SingleBoxWS.ToggleButton:SetIsEnabled(Trigger)
	self.SingleBoxSN.ToggleButton:SetIsEnabled(Trigger)
	self.SingleBoxWP.ToggleButton:SetIsEnabled(Trigger)
	self.SingleBoxNV.ToggleButton:SetIsEnabled(Trigger)

	

	if Trigger == false then
		ClockSettingVM.StartNotify = false
		ClockSettingVM.IsComingNotify = false
		ClockSettingVM.IsNotifySound = false
		ClockSettingVM.CloseNotify = false

		self.SingleBoxNV:UpdateColor(false)
		self.SingleBoxSN:UpdateColor(false)
		self.SingleBoxWP:UpdateColor(false)
		self.SingleBoxWS:UpdateColor(false)
	end
end

---@type 封闭条件下提醒开关
function FishIngholeClockSetWinView:OnBtnClickedSingleBoxSN()
	if ClockSettingVM == nil then
		return
	end
	ClockSettingVM:ChangeCloseNotify()
	self.BtnSaveSettings:SetIsRecommendState(true)
	self.bChanged = true
end

---@type 窗口期提醒开关
function FishIngholeClockSetWinView:OnBtnClickedSingleBoxWS()
	if ClockSettingVM == nil then
		return
	end
	ClockSettingVM:ChangeStartNotify()
	self.BtnSaveSettings:SetIsRecommendState(true)
	self.bChanged = true
end

---@type 提前提醒开关
function FishIngholeClockSetWinView:OnBtnClickedSingleBoxWP()
	if ClockSettingVM == nil then
		return
	end
	ClockSettingVM:ChangeIsComingNotify()
	self.BtnSaveSettings:SetIsRecommendState(true)
	self.bChanged = true
end

function FishIngholeClockSetWinView:OnChangeSingleBoxWP(bChecked)
	if not bChecked then
		--不设置提前提醒
		--颜色置为灰色
		self.CheckBox1M:UpdateColor(false)
		self.CheckBox3M:UpdateColor(false)
		self.CheckBox5M:UpdateColor(false)
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
		self:OnBtnClickedCheckBox1M()
	end
end

function FishIngholeClockSetWinView:OnComingNotify(NotifyTime)
	local Boxs = {["1"] = self.CheckBox1M, ["3"] = self.CheckBox3M, ["5"] = self.CheckBox5M}
	local IsComingNotify = _G.FishNotesClockSetWindVM.IsComingNotify
	for index, value in pairs(Boxs) do
		if IsComingNotify and tonumber(index) == NotifyTime then
			value:SetChecked(true)
		else
			value:SetChecked(false)
		end
	end
end

---@type 提前提醒时间1秒
function FishIngholeClockSetWinView:OnBtnClickedCheckBox1M()
	self:SelectComingNotifyTime(1)
end

---@type 提前提醒时间3秒
function FishIngholeClockSetWinView:OnBtnClickedCheckBox3M()
	self:SelectComingNotifyTime(3)
end

---@type 提前提醒时间5秒
function FishIngholeClockSetWinView:OnBtnClickedCheckBox5M()
	self:SelectComingNotifyTime(5)
end

---@type 选择提前通知时间
---@param ComingNotifyTime 提前通知时间
function FishIngholeClockSetWinView:SelectComingNotifyTime(ComingNotifyTime)
	if ClockSettingVM == nil then
		return
	end
	if ClockSettingVM.ComingNotify ~= ComingNotifyTime then
		self.BtnSaveSettings:SetIsRecommendState(true)
		self.bChanged = true
	end

	if self.PrevSelectCheckBox then
		if self.PrevSelectCheckBox == self.ComingNotifyCheckBoxs[ComingNotifyTime] then
			self.PrevSelectCheckBox:SetChecked(true)
			return
		end
		self.PrevSelectCheckBox:SetChecked(false)
	end
	ClockSettingVM:ChangeComingNotifyValue(ComingNotifyTime)
	self.PrevSelectCheckBox = self.ComingNotifyCheckBoxs[ComingNotifyTime]
end

---@type 声音提醒开关
function FishIngholeClockSetWinView:OnBtnClickedSingleBoxNV()
	if ClockSettingVM == nil then
		return
	end
	ClockSettingVM:ChangeIsNotifySound()
	self.BtnSaveSettings:SetIsRecommendState(true)
	self.bChanged = true
end

---@type 取消闹钟设置并关闭界面
function FishIngholeClockSetWinView:OnBtnClickedCancel()
	_G.UIViewMgr:HideView(self.ViewID)
end

---@type 保存闹钟设置
function FishIngholeClockSetWinView:OnBtnClickedSaveSetting()
	if self.bChanged == false then
		return
	end
    local NoteType = FishNotesDefine.FishNoteType
    local Setting = ClockSettingVM:GetLastClockSetting()
    FishNoteMgr:SendMsgClockSettinginfo(NoteType,Setting)

	_G.UIViewMgr:HideView(self.ViewID)
end

return FishIngholeClockSetWinView
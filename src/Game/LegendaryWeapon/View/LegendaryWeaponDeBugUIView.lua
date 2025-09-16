---
--- Author: Administrator
--- DateTime: 2024-04-22 14:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LegendaryWeaponMainPanelVM = require("Game/LegendaryWeapon/VM/LegendaryWeaponMainPanelVM")
local ItemCfg = require("TableCfg/ItemCfg")

---@class LegendaryWeaponDeBugUIView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold_1 UToggleButton
---@field Button_1 UButton
---@field Button_137 UButton
---@field Button_138 UButton
---@field Button_144 UButton
---@field Button_2 UButton
---@field Button_3 UButton
---@field Button_4 UButton
---@field Button_5 UButton
---@field Button_7 UButton
---@field Button_79 UButton
---@field Button_851 UButton
---@field Button_Kai UButton
---@field Character3D UHorizontalBox
---@field CharacterLocation UHorizontalBox
---@field CheckBox_74 UCheckBox
---@field CheckBox_75 UCheckBox
---@field ComboBoxString_1 UComboBoxString
---@field ComboBoxString_2 UComboBoxString
---@field ComboBoxString_3 UComboBoxString
---@field LX UEditableTextBox
---@field LX_1 UEditableTextBox
---@field LX_2 UEditableTextBox
---@field LX_3 UEditableTextBox
---@field LX_4 UEditableTextBox
---@field LX_5 UEditableTextBox
---@field LY UEditableTextBox
---@field LY_1 UEditableTextBox
---@field LY_2 UEditableTextBox
---@field LZ UEditableTextBox
---@field LZ_1 UEditableTextBox
---@field LZ_2 UEditableTextBox
---@field PanelBG1 UFCanvasPanel
---@field RX UEditableTextBox
---@field RX_1 UEditableTextBox
---@field RY UEditableTextBox
---@field RY_1 UEditableTextBox
---@field RZ UEditableTextBox
---@field RZ_1 UEditableTextBox
---@field Slider_106 USlider
---@field Slider_541 USlider
---@field SubWeaponLocation UHorizontalBox
---@field SubWeaponRotation UHorizontalBox
---@field TextBlock UTextBlock
---@field TextBlock_1 UTextBlock
---@field TextBlock_10 UTextBlock
---@field TextBlock_11 UTextBlock
---@field TextBlock_12 UTextBlock
---@field TextBlock_13 UTextBlock
---@field TextBlock_14 UTextBlock
---@field TextBlock_15 UTextBlock
---@field TextBlock_16 UTextBlock
---@field TextBlock_17 UTextBlock
---@field TextBlock_18 UTextBlock
---@field TextBlock_19 UTextBlock
---@field TextBlock_2 UTextBlock
---@field TextBlock_20 UTextBlock
---@field TextBlock_21 UTextBlock
---@field TextBlock_22 UTextBlock
---@field TextBlock_23 UTextBlock
---@field TextBlock_24 UTextBlock
---@field TextBlock_25 UTextBlock
---@field TextBlock_26 UTextBlock
---@field TextBlock_27 UTextBlock
---@field TextBlock_28 UTextBlock
---@field TextBlock_29 UTextBlock
---@field TextBlock_3 UTextBlock
---@field TextBlock_30 UTextBlock
---@field TextBlock_31 UTextBlock
---@field TextBlock_32 UTextBlock
---@field TextBlock_33 UTextBlock
---@field TextBlock_34 UTextBlock
---@field TextBlock_35 UTextBlock
---@field TextBlock_36 UTextBlock
---@field TextBlock_37 UTextBlock
---@field TextBlock_38 UTextBlock
---@field TextBlock_39 UTextBlock
---@field TextBlock_4 UTextBlock
---@field TextBlock_40 UTextBlock
---@field TextBlock_42 UTextBlock
---@field TextBlock_5 UTextBlock
---@field TextBlock_6 UTextBlock
---@field TextBlock_7 UTextBlock
---@field TextBlock_73 UTextBlock
---@field TextBlock_8 UTextBlock
---@field TextBlock_9 UTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle_1 UFTextBlock
---@field VerticalBox_19 UVerticalBox
---@field VerticalBox_2 UVerticalBox
---@field VerticalBox_77 UVerticalBox
---@field VerticalBox_845 UVerticalBox
---@field Weapon3D UHorizontalBox
---@field WeaponLocation UHorizontalBox
---@field WeaponRotation UHorizontalBox
---@field WeaponSpeed UHorizontalBox
---@field AnimFold UWidgetAnimation
---@field Weapon1 Actor
---@field Weapon2 Actor
---@field WeaponSystem Actor
---@field CharacterActor Actor
---@field CameraFOV float
---@field GlobalVersiong string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LegendaryWeaponDeBugUIView = LuaClass(UIView, true)

function LegendaryWeaponDeBugUIView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold_1 = nil
	--self.Button_1 = nil
	--self.Button_137 = nil
	--self.Button_138 = nil
	--self.Button_144 = nil
	--self.Button_2 = nil
	--self.Button_3 = nil
	--self.Button_4 = nil
	--self.Button_5 = nil
	--self.Button_7 = nil
	--self.Button_79 = nil
	--self.Button_851 = nil
	--self.Button_Kai = nil
	--self.Character3D = nil
	--self.CharacterLocation = nil
	--self.CheckBox_74 = nil
	--self.CheckBox_75 = nil
	--self.ComboBoxString_1 = nil
	--self.ComboBoxString_2 = nil
	--self.ComboBoxString_3 = nil
	--self.LX = nil
	--self.LX_1 = nil
	--self.LX_2 = nil
	--self.LX_3 = nil
	--self.LX_4 = nil
	--self.LX_5 = nil
	--self.LY = nil
	--self.LY_1 = nil
	--self.LY_2 = nil
	--self.LZ = nil
	--self.LZ_1 = nil
	--self.LZ_2 = nil
	--self.PanelBG1 = nil
	--self.RX = nil
	--self.RX_1 = nil
	--self.RY = nil
	--self.RY_1 = nil
	--self.RZ = nil
	--self.RZ_1 = nil
	--self.Slider_106 = nil
	--self.Slider_541 = nil
	--self.SubWeaponLocation = nil
	--self.SubWeaponRotation = nil
	--self.TextBlock = nil
	--self.TextBlock_1 = nil
	--self.TextBlock_10 = nil
	--self.TextBlock_11 = nil
	--self.TextBlock_12 = nil
	--self.TextBlock_13 = nil
	--self.TextBlock_14 = nil
	--self.TextBlock_15 = nil
	--self.TextBlock_16 = nil
	--self.TextBlock_17 = nil
	--self.TextBlock_18 = nil
	--self.TextBlock_19 = nil
	--self.TextBlock_2 = nil
	--self.TextBlock_20 = nil
	--self.TextBlock_21 = nil
	--self.TextBlock_22 = nil
	--self.TextBlock_23 = nil
	--self.TextBlock_24 = nil
	--self.TextBlock_25 = nil
	--self.TextBlock_26 = nil
	--self.TextBlock_27 = nil
	--self.TextBlock_28 = nil
	--self.TextBlock_29 = nil
	--self.TextBlock_3 = nil
	--self.TextBlock_30 = nil
	--self.TextBlock_31 = nil
	--self.TextBlock_32 = nil
	--self.TextBlock_33 = nil
	--self.TextBlock_34 = nil
	--self.TextBlock_35 = nil
	--self.TextBlock_36 = nil
	--self.TextBlock_37 = nil
	--self.TextBlock_38 = nil
	--self.TextBlock_39 = nil
	--self.TextBlock_4 = nil
	--self.TextBlock_40 = nil
	--self.TextBlock_42 = nil
	--self.TextBlock_5 = nil
	--self.TextBlock_6 = nil
	--self.TextBlock_7 = nil
	--self.TextBlock_73 = nil
	--self.TextBlock_8 = nil
	--self.TextBlock_9 = nil
	--self.TextSubTitle = nil
	--self.TextTitle_1 = nil
	--self.VerticalBox_19 = nil
	--self.VerticalBox_2 = nil
	--self.VerticalBox_77 = nil
	--self.VerticalBox_845 = nil
	--self.Weapon3D = nil
	--self.WeaponLocation = nil
	--self.WeaponRotation = nil
	--self.WeaponSpeed = nil
	--self.AnimFold = nil
	--self.Weapon1 = nil
	--self.Weapon2 = nil
	--self.WeaponSystem = nil
	--self.CharacterActor = nil
	--self.CameraFOV = nil
	--self.GlobalVersiong = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LegendaryWeaponDeBugUIView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

--此为调试工具，这里大部分功能均实现在蓝图
function LegendaryWeaponDeBugUIView:OnInit()

	FLOG_INFO("[LegendaryWeapon] 被激活了测试工具 ")

	self.viewModel = LegendaryWeaponMainPanelVM
end

function LegendaryWeaponDeBugUIView:OnRegisterBinder()
	self.Binders = {
		{"IsShowWeaponModel", UIBinderValueChangedCallback.New(self, nil, self.SetShowWeaponModel) },
		{"SelectWeaponID", UIBinderValueChangedCallback.New(self, nil, self.SetSelectWeaponID) },
	}
	self:RegisterBinders(self.viewModel, self.Binders)
end

function LegendaryWeaponDeBugUIView:SetShowWeaponModel(IsShowWeapon)
	if IsShowWeapon == true then
		UIUtil.SetIsVisible(self.Weapon3D, true)
		UIUtil.SetIsVisible(self.WeaponSpeed, true)
		UIUtil.SetIsVisible(self.WeaponLocation, self.viewModel.SelectWeaponID ~= 0)
		UIUtil.SetIsVisible(self.WeaponRotation, self.viewModel.SelectWeaponID ~= 0)
		UIUtil.SetIsVisible(self.SubWeaponLocation, self.viewModel.SelectSubWeaponID ~= 0)
		UIUtil.SetIsVisible(self.SubWeaponRotation, self.viewModel.SelectSubWeaponID ~= 0)
		UIUtil.SetIsVisible(self.Character3D, false)
		UIUtil.SetIsVisible(self.CharacterLocation, false)
	else
		UIUtil.SetIsVisible(self.Character3D, true)
		UIUtil.SetIsVisible(self.CharacterLocation, true)
		UIUtil.SetIsVisible(self.Weapon3D, false)
		UIUtil.SetIsVisible(self.WeaponSpeed, false)
		UIUtil.SetIsVisible(self.WeaponLocation, false)
		UIUtil.SetIsVisible(self.WeaponRotation, false)
		UIUtil.SetIsVisible(self.SubWeaponLocation, false)
		UIUtil.SetIsVisible(self.SubWeaponRotation, false)
	end
end

function LegendaryWeaponDeBugUIView:SetSelectWeaponID(WeaponID)
	if WeaponID ~= 0 then
		self:SetShowWeaponModel(self.viewModel.IsShowWeaponModel)
		self:UpdateDeBug()
	end
end

function LegendaryWeaponDeBugUIView:UpdateDeBug()
	if self.viewModel.BP_SceneActor then
		self:SetWeapon1(self.viewModel.BP_SceneActor.WeaponBaseChar)
		self:SetWeapon2(self.viewModel.BP_SceneActor.SubWeaponBaseChar)
		self:SetWeaponSystem(self.viewModel.BP_SceneActor)
		self:SetCharacterActor(self.viewModel.Render2DActor)
		local Neme = ItemCfg:GetItemName(self.viewModel.SelectWeaponID)
		self.TextSubTitle:SetText(Neme)
	end
end

--- 注册按钮事件，功能均需配合蓝图实现，因此你不必理解命名序号有什么用  (*^_^*)
function LegendaryWeaponDeBugUIView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Button_138, self.OnClickAddButton)
	UIUtil.AddOnClickedEvent(self, self.Button_4, self.OnClickPlayCompletion)
	UIUtil.AddOnClickedEvent(self, self.Button_144, self.OnClickOpenVersion)
	UIUtil.AddOnClickedEvent(self, self.Button_7, self.OnClickRefreshData)
	UIUtil.AddOnClickedEvent(self, self.Button_Kai, self.OnClickKai)

	UIUtil.AddOnValueChangedEvent(self, self.Slider_106, self.SetFieldOfView)
	UIUtil.AddOnSelectionChangedEvent(self, self.ComboBoxString_3, self.OnVersionSelectedChanged)
	UIUtil.AddOnStateChangedEvent(self, self.BtnFold_1, self.OnFoldClicked)
end

--- 自动添加材料
function LegendaryWeaponDeBugUIView:OnClickAddButton()
	print("====== [ 传奇武器 DeBug ]:  OnClickAddButton")
	local WeaponCfg = self.viewModel.ProfInfo and self.viewModel.ProfInfo.WeaponCfg or nil
	if WeaponCfg == nil then return end
	local ItemID = 50272190
    local Number = 1
	local AddItemTab = {}
	for _, ConsumeItem in pairs(WeaponCfg.ConsumeItems) do
		ItemID = ConsumeItem.ResID
       	Number = ConsumeItem.Num
		if ItemID ~= nil and Number ~= 0 then
			table.insert(AddItemTab, string.format("role bag add %d %d", ItemID, Number))
		end
	end

	for _, SpecialItem in pairs(WeaponCfg.SpecialItems) do
		ItemID = SpecialItem.ResID
       	Number = SpecialItem.Num
		if ItemID ~= nil and Number ~= 0 then
			table.insert(AddItemTab, string.format("role bag add %d %d", ItemID, Number))
		end
	end

	local delayTime = 0.0
	local step = 0.2
	for i = 1, #(AddItemTab) do
		local CmdContent = AddItemTab[i]
		local DelayCallBack = function()
			_G.GMMgr:ReqGM1(CmdContent)
		end
		if(delayTime ~= 0) then
			_G.TimerMgr:AddTimer(self, DelayCallBack, delayTime, 0.2, 1, nil)
		else
			_G.GMMgr:ReqGM1(CmdContent)
		end
		delayTime = delayTime + step
	end
end

--- 播放制作动画
function LegendaryWeaponDeBugUIView:OnClickPlayCompletion()
	local vm = self.viewModel
	if vm and vm.ProfInfo then
		-- 强化动画(场景)
		_G.LegendaryWeaponMgr:StartPlay(vm.ProfInfo.Prof, vm.SelectID)
		if self.AnimFold then
			self:PlayAnimation(self.AnimFold, 0, 1, 0, 3)
			self.bIsStartPlay = true
		end
	end
end

function LegendaryWeaponDeBugUIView:SetFieldOfView(Params)
	self.viewModel.CameraFOV = self.CameraFOV
end

function LegendaryWeaponDeBugUIView:OnClickKai()
	_G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, {OpenSource = 9})
end

--- 解锁全部版本
function LegendaryWeaponDeBugUIView:OnClickOpenVersion()
	print("===== [ 传奇武器 DeBug ]:  解锁全部版本 999")
	_G.LegendaryWeaponMgr.GlobalVersions = {9,9,9}
	_G.LegendaryWeaponMgr:GetVersions()
	_G.MsgTipsUtil.ShowTips(LSTR("已解锁全部传奇武器"))
	_G.UIViewMgr:HideView(_G.UIViewID.LegendaryWeaponPanel)
	_G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, {OpenSource = 9})
end

--- 解锁选择的章节
function LegendaryWeaponDeBugUIView:OnVersionSelectedChanged()
	print("===== [ 传奇武器 DeBug ]:  解锁选择的章节", self.ComboBoxString_3:GetSelectedIndex(), self.GlobalVersiong)
	local VersionString = self.GlobalVersiong
	local VersionString = string.split(VersionString, '.')
	local Topics = {}
	for i, Ver in ipairs(VersionString) do
		Topics[i] = tonumber(Ver)
	end
	_G.LegendaryWeaponMgr.GlobalVersions = Topics
	_G.LegendaryWeaponMgr:GetVersions()
	_G.UIViewMgr:HideView(_G.UIViewID.LegendaryWeaponPanel)
	_G.UIViewMgr:ShowView(UIViewID.LegendaryWeaponPanel, {OpenSource = 9})
end

function LegendaryWeaponDeBugUIView:OnClickRefreshData()
	self:SetSelectWeaponID(self.viewModel.SelectWeaponID)
end

function LegendaryWeaponDeBugUIView:OnFoldClicked(ToggleButton, ButtonState)
	if self.bIsStartPlay then
		self.bIsStartPlay = false
		self:PlayAnimationReverse(self.AnimFold)
		return
	end
	
	local bHidePanel = ButtonState == _G.UE.EToggleButtonState.Checked
	if bHidePanel then
		self:PlayAnimation(self.AnimFold)
	else
		self:PlayAnimationReverse(self.AnimFold)
	end
end

return LegendaryWeaponDeBugUIView
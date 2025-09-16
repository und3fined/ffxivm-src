---
--- Author: jamiyang
--- DateTime: 2023-10-08 15:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR
local LoginAvatarMgr = nil
local LoginUIMgr = nil

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderCanvasSlotSetSize = require("Binder/UIBinderCanvasSlotSetSize")

local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

--@ViewModel
local LoginCreateCustomizeVM = require("Game/LoginCreate/LoginCreateCustomizeVM")

---@class LoginCreateAppearanceCustomizePageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExpand LoginCreateExpandItemView
---@field Btn_Refresh UFButton
---@field Btn_RevertBackward UFButton
---@field Btn_RevertForward UFButton
---@field FVerticalBox UFVerticalBox
---@field FacePanel UFCanvasPanel
---@field PanelBtnNone LoginCreateTypeNoneItemView
---@field PanelColor UFCanvasPanel
---@field PanelFace UFCanvasPanel
---@field PanelHeight UFCanvasPanel
---@field PanelLooks UFCanvasPanel
---@field PanelPart_1 UFCanvasPanel
---@field PanelSelectList UFCanvasPanel
---@field PanelType UFCanvasPanel
---@field ProBarHeight UProgressBar
---@field ReversalPanel UFCanvasPanel
---@field SliderHeight USlider
---@field Spacer2 USpacer
---@field TableViewColor UTableView
---@field TableViewFace UTableView
---@field TableViewLooks UTableView
---@field TableViewType UTableView
---@field TableViewVice UTableView
---@field TableViewVoice UTableView
---@field TableViewWordItem UTableView
---@field TextHeight UFTextBlock
---@field TextPanel UFCanvasPanel
---@field TextPrecent UFTextBlock
---@field TextReversal UFTextBlock
---@field TextShortest UFTextBlock
---@field TextTallest UFTextBlock
---@field ToggleButton UToggleButton
---@field TypeSwitch LoginCreateTypeSwitchItemView
---@field TypeSwitch1 LoginCreateTypeSwitchItemView
---@field TypeSwitch2 LoginCreateTypeSwitch2ItemView
---@field TypeSwitch3 LoginCreateTypeSwitchItemView
---@field TypeSwitchProbar LoginCreateTypeSwitchItemView
---@field WordPanel UFCanvasPanel
---@field AnimColorIn UWidgetAnimation
---@field AnimFaceIn UWidgetAnimation
---@field AnimHeightIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimTypeIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreateAppearanceCustomizePageView = LuaClass(UIView, true)

function LoginCreateAppearanceCustomizePageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExpand = nil
	--self.Btn_Refresh = nil
	--self.Btn_RevertBackward = nil
	--self.Btn_RevertForward = nil
	--self.FVerticalBox = nil
	--self.FacePanel = nil
	--self.PanelBtnNone = nil
	--self.PanelColor = nil
	--self.PanelFace = nil
	--self.PanelHeight = nil
	--self.PanelLooks = nil
	--self.PanelPart_1 = nil
	--self.PanelSelectList = nil
	--self.PanelType = nil
	--self.ProBarHeight = nil
	--self.ReversalPanel = nil
	--self.SliderHeight = nil
	--self.Spacer2 = nil
	--self.TableViewColor = nil
	--self.TableViewFace = nil
	--self.TableViewLooks = nil
	--self.TableViewType = nil
	--self.TableViewVice = nil
	--self.TableViewVoice = nil
	--self.TableViewWordItem = nil
	--self.TextHeight = nil
	--self.TextPanel = nil
	--self.TextPrecent = nil
	--self.TextReversal = nil
	--self.TextShortest = nil
	--self.TextTallest = nil
	--self.ToggleButton = nil
	--self.TypeSwitch = nil
	--self.TypeSwitch1 = nil
	--self.TypeSwitch2 = nil
	--self.TypeSwitch3 = nil
	--self.TypeSwitchProbar = nil
	--self.WordPanel = nil
	--self.AnimColorIn = nil
	--self.AnimFaceIn = nil
	--self.AnimHeightIn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimTypeIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreateAppearanceCustomizePageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnExpand)
	self:AddSubView(self.PanelBtnNone)
	self:AddSubView(self.TypeSwitch)
	self:AddSubView(self.TypeSwitch1)
	self:AddSubView(self.TypeSwitch2)
	self:AddSubView(self.TypeSwitch3)
	self:AddSubView(self.TypeSwitchProbar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreateAppearanceCustomizePageView:OnInit()
	LoginAvatarMgr = _G.LoginAvatarMgr
	LoginUIMgr = _G.LoginUIMgr
	self.ViewModel = LoginCreateCustomizeVM

	self.MainBtnNames = {"ToggleBtnFace", "ToggleBtnEye", "ToggleBtnDecorate", 
						 "ToggleBtnHair", "ToggleBtnBody", "ToggleBtnVoice"}
	self.SubMenuTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewVice, self.OnSubMenuTableSelectChange, true, false)
	self.VoiceTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewVoice, self.OnVoiceTableSelectChange, true, false)

	self.FaceTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewFace, self.OnFaceTableSelectChange, true, false)

	self.ColorTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewColor, self.OnColorTableSelectChange, true, false)

	self.TypeTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewType, self.OnTypeTableSelectChange, true, false)

	self.WorldTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewWordItem, self.OnWorldTableSelectChange, true, true)

	self.LooksTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewLooks, self.OnLooksTableSelectChange, true, false)
	
	self.TextReversal:SetText(LSTR(980097)) -- "反转"

end

function LoginCreateAppearanceCustomizePageView:OnDestroy()

end

function LoginCreateAppearanceCustomizePageView:OnShow()
	--打开Mips等待，避免选择面妆时出现模糊
	_G.UE.UCommonUtil.OpenWaitForFaceTextureMips()
	LoginUIMgr:ResetHairBtnState() -- 束发状态
	LoginAvatarMgr:ModelMoveToLeft(false, false)
	self:OnShowStart()
end

function LoginCreateAppearanceCustomizePageView:OnShowStart()
	self.ViewModel:InitViewData()
	-- 默认打开第一个页签
	self.LooksTableView:ScrollToTop()
	self.LooksTableView:SetSelectedIndex(1)
	--self:OnClickBtnMenue(LoginAvatarMgr.CustomizeMainMenu.Face)
	self.TypeSwitch:SetTitleText(LSTR(980018), LSTR(980011))
	self.TypeSwitch3:SetTitleText(LSTR(980018), LSTR(980011))
end

function LoginCreateAppearanceCustomizePageView:OnHide()
	self.ViewModel:UnInitViewData()
	-- 恢复相机机位
	--LoginAvatarMgr:SetCameraFocus(0, true, false)
	--关闭Mips等待
	_G.UE.UCommonUtil.CloseWaitForFaceTextureMips()
end

function LoginCreateAppearanceCustomizePageView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnFace, 	   self.OnClickBtnMenue,  LoginAvatarMgr.CustomizeMainMenu.Face)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnEye, 	   self.OnClickBtnMenue,  LoginAvatarMgr.CustomizeMainMenu.Eye)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnDecorate, self.OnClickBtnMenue,  LoginAvatarMgr.CustomizeMainMenu.Decorate)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnHair, 	   self.OnClickBtnMenue,  LoginAvatarMgr.CustomizeMainMenu.Hair)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnBody, 	   self.OnClickBtnMenue,  LoginAvatarMgr.CustomizeMainMenu.Body)
	-- UIUtil.AddOnClickedEvent(self, self.ToggleBtnVoice,    self.OnClickBtnMenue,  LoginAvatarMgr.CustomizeMainMenu.Voice)

	UIUtil.AddOnClickedEvent(self, self.BtnExpand.BtnStretch, self.OnClickedStretch)

	UIUtil.AddOnValueChangedEvent(self, self.SliderHeight, self.OnSliderValueChange)
	UIUtil.AddOnMouseCaptureEndEvent(self, self.SliderHeight, self.OnSliderMouseCaptureEnd)

	--UIUtil.AddOnClickedEvent(self, self.TypeSwitch.ToggleBtn1, self.OnClickedTypeSwitch, true)
	UIUtil.AddOnClickedEvent(self, self.TypeSwitch3.ToggleBtn2, self.OnClickedTypeSwitch, false) -- 图片选择列表上的切换框
	UIUtil.AddOnClickedEvent(self, self.TypeSwitch.ToggleBtn2, self.OnClickedTypeSwitch, false)
	UIUtil.AddOnClickedEvent(self, self.TypeSwitchProbar.ToggleBtn1, self.OnClickedTypeSwitch, true)

	UIUtil.AddOnClickedEvent(self, self.TypeSwitch1.ToggleBtn1, self.OnClickedTypeSwitchParam, true)
	UIUtil.AddOnClickedEvent(self, self.TypeSwitch1.ToggleBtn2, self.OnClickedTypeSwitchParam, false)
	UIUtil.AddOnClickedEvent(self, self.TypeSwitch2.ToggleBtn1, self.OnClickedTypeSwitchParam, true)
	UIUtil.AddOnClickedEvent(self, self.TypeSwitch2.ToggleBtn2, self.OnClickedTypeSwitchParam, false)


	UIUtil.AddOnClickedEvent(self, self.PanelBtnNone.BtnText, self.OnClickedBtnNone)

	UIUtil.AddOnClickedEvent(self, self.ToggleButton, self.OnBtnFlipClick)

	UIUtil.AddOnClickedEvent(self, self.Btn_Refresh, 	    self.OnClickRefresh)
	UIUtil.AddOnClickedEvent(self, self.Btn_RevertBackward, self.OnClickRevertBackward)
	UIUtil.AddOnClickedEvent(self, self.Btn_RevertForward,  self.OnClickRevertForward)
end

function LoginCreateAppearanceCustomizePageView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.LoginCreatFaceServerReset, self.OnLoginCreatFaceServerReset)

end

function LoginCreateAppearanceCustomizePageView:OnRegisterBinder()
	local Binders = {
		{ "bShowNormalMenue", UIBinderSetIsVisible.New(self, self.PanelSelectList, false, false) }, -- 选择菜单
		{ "bShowNormalMenue", UIBinderSetIsVisible.New(self, self.PanelLooks, false, false) }, -- 选择菜单
		{ "LooksCfgList", UIBinderUpdateBindableList.New(self, self.LooksTableView) }, -- 一级菜单
		{ "bVoiceMenue", UIBinderSetIsVisible.New(self, self.TableViewVice, true) }, -- 二级页签
		{ "bVoiceMenue", UIBinderSetIsVisible.New(self, self.TableViewVoice, false) }, -- 二级页签
		{ "ListSubMenuVM", UIBinderUpdateBindableList.New(self, self.SubMenuTableView) }, -- 二级页签列表
		{ "ListVoiceVM", UIBinderUpdateBindableList.New(self, self.VoiceTableView) }, -- 二级页签音效列表

		{ "ListFaceTableVM", UIBinderUpdateBindableList.New(self, self.FaceTableView) }, -- 图片选择列表
		{ "bShowPanelFace", UIBinderSetIsVisible.New(self, self.PanelFace) }, -- 图片选择列表显隐
		{ "bShowShortSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch3) }, -- 滑动条里的切换框
		{ "bShowFlip", UIBinderSetIsVisible.New(self, self.ReversalPanel) }, -- 反转选项显隐
		{ "bFlip", UIBinderSetIsChecked.New(self, self.ToggleButton, false) },
		--{ "FaceTableIndex", UIBinderSetSelectedIndex.New(self, self.FaceTableView)}, -- 选中项目
		{ "FaceTableSize", UIBinderCanvasSlotSetSize.New(self, self.TableViewFace, true)}, -- 图片选择列表大小

		{ "bShowPanelHeight", UIBinderSetIsVisible.New(self, self.PanelHeight) }, -- 滑动条显隐
		{ "bShowShortSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitchProbar) }, -- 滑动条里的切换框
		{ "bShowTextHeight", UIBinderSetIsVisible.New(self, self.TextHeight) }, -- 实际身高
		{ "ProBarPercent", UIBinderSetPercent.New(self, self.ProBarHeight) },
		{ "TextTallest", UIBinderSetText.New(self, self.TextTallest)},
		{ "TextShortest", UIBinderSetText.New(self, self.TextShortest)},
		{ "TextPrecent", UIBinderSetText.New(self, self.TextPrecent)},
		{ "TextHeight", UIBinderSetText.New(self, self.TextHeight)},

		{ "ListColorTableVM", UIBinderUpdateBindableList.New(self, self.ColorTableView) }, -- 色号选择列表
		{ "ListWorldTableVM", UIBinderUpdateBindableList.New(self, self.WorldTableView) },
		--{ "ListWorldTableVM", UIBinderValueChangedCallback.New(self, nil, self.OnWorldTableSelectChange) },
		{ "bShowPanelColor", UIBinderSetIsVisible.New(self, self.PanelColor) }, -- 色板显隐
		{ "bShowWordPanel", UIBinderSetIsVisible.New(self, self.WordPanel) }, -- 色板上种类多选框
		{ "bShowLongSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch2) }, -- 色板上展开后切换框
		{ "bShowShortSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch1) }, -- 色板上展开前切换框
		{ "bShowBtnNone", UIBinderSetIsVisible.New(self, self.PanelBtnNone) }, -- 色板上"无"选项
		{ "bExpanded", UIBinderSetIsVisible.New(self, self.Spacer2) },
		{ "bShowColorTable", UIBinderSetIsVisible.New(self, self.TableViewColor, false, true) },
		{ "bShowColorTable", UIBinderSetIsVisible.New(self, self.BtnExpand) },
		--{ "VerticalDifferSize", UIBinderCanvasSlotSetSize.New(self, self.VerticalDiffer, true)}, -- 色板展开大小
		--{ "ColorTableSize", UIBinderCanvasSlotSetSize.New(self, self.TableViewColor, true)}, -- 色板展开大小

		{ "bShowPanelType", UIBinderSetIsVisible.New(self, self.PanelType) }, -- 类型选择显隐
		{ "ListTypeTableVM", UIBinderUpdateBindableList.New(self, self.TypeTableView) }, -- 类型选择列表
		{ "bShowShortSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch) }, -- 类型选择里的切换框

		{ "FaceTableNum", UIBinderValueChangedCallback.New(self, nil, self.OnFaceTableNumChange) },

		{ "bParamNone", UIBinderValueChangedCallback.New(self, nil, self.OnParamNoneChange) }

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

-- 主菜单列表
function LoginCreateAppearanceCustomizePageView:OnLooksTableSelectChange(Index, ItemData, ItemView)
	self:OnClickBtnMenue(Index)
end

-- 菜单
function LoginCreateAppearanceCustomizePageView:OnClickBtnMenue(MenueType)
	-- 一级页签
	--for _, BtnName in ipairs(self.MainBtnNames) do
		--self[BtnName]:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
	--end
	--local BtnName = self.MainBtnNames[MenueType]
	--if BtnName ~= nil then
		--self[BtnName]:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	--end
	local MainTile = LoginAvatarMgr:GetMainMenuList()[MenueType]
	-- 二级页签
	if MenueType == LoginAvatarMgr.CustomizeMainMenu.Voice then
		-- 音效页签单独处理
		self.ViewModel:UpdateVoiceMenu()
		self.VoiceTableView:SetSelectedIndex(3)
	else
		self.ViewModel:SetMainType(MenueType)
		self.ViewModel:UpdateSubMenu(MainTile)
		self.SubMenuTableView:SetSelectedIndex(1)
	end
end

-- 所选二级页签发生变化
function LoginCreateAppearanceCustomizePageView:OnSubMenuTableSelectChange(Index, ItemData, ItemView)
	self:UpdateSubMenuTable(Index)
	self:PlayPanelAnim()
	LoginAvatarMgr:InitSpringArm()
end

-- 所选二级页签发生变化，数据变化
function LoginCreateAppearanceCustomizePageView:UpdateSubMenuTable(Index)
	self.ViewModel:UpdateSubMenuSelected(Index)
	-- 部分控件大小需要动态修改
	self:SetColorPanelSize()
	-- 切换框文字
	local Type = self.ViewModel.SubType
	if Type == LoginAvatarMgr.CustomizeSubType.EyeColor then
		self.TypeSwitch1:SetTitleText(LSTR(980015), LSTR(980008))
		self.TypeSwitch2:SetTitleText(LSTR(980015), LSTR(980008))
	elseif Type == LoginAvatarMgr.CustomizeSubType.HairColor then
		self.TypeSwitch1:SetTitleText(LSTR(980006), LSTR(980019))
		self.TypeSwitch2:SetTitleText(LSTR(980006), LSTR(980019))
	else
		self.TypeSwitch1:SetTitleText(LSTR(980029), LSTR(980030))
		self.TypeSwitch2:SetTitleText(LSTR(980029), LSTR(980030))
	end
	-- todo slider需要根据用户数据设置
	self.SliderHeight:SetValue(self.ViewModel.ProBarPercent)

	-- 数据状态映射
	if self.ViewModel.bShowPanelFace == true and self.ViewModel.FaceTableIndex ~= nil and self.ViewModel.bMultiSelect == false then
		self.FaceTableView:SetSelectedIndex(self.ViewModel.FaceTableIndex)
		self.FaceTableView:ScrollIndexIntoView(self.ViewModel.FaceTableIndex)
	elseif self.ViewModel.bShowPanelType == true then
		self.TypeTableView:SetSelectedIndex(self.ViewModel.TypeTableIndex)
	elseif self.ViewModel.bShowPanelColor == true and self.ViewModel.bParamNone == false then
		self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
	end
end

-- 所选二级页签音效发生变化
function LoginCreateAppearanceCustomizePageView:OnVoiceTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateVoiceSelected(Index)
	if self.ViewModel.bShowPanelType == true then
		self.TypeTableView:SetSelectedIndex(self.ViewModel.TypeTableIndex)
	end
end


-- 图片列表所选变化
function LoginCreateAppearanceCustomizePageView:OnFaceTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateFaceTableSelected(Index)
	self.FaceTableView:ScrollIndexIntoView(Index)
end

-- 色号所选列表发生变化
function LoginCreateAppearanceCustomizePageView:OnColorTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateColorTableSelected(Index)
	self.ColorTableView:ScrollIndexIntoView(Index)
end

-- 色板展开
function LoginCreateAppearanceCustomizePageView:OnClickedStretch()
	self.ViewModel:ExpandedStateChanged(not (self.ViewModel.bExpanded))
	self.BtnExpand:SetExpandState(self.ViewModel.bExpanded)
	-- 属性选择保持切换框
	local IsLeft = not (self.ViewModel.bOperateSub)
	self.TypeSwitch1:SetSwitchState(IsLeft)
	self.TypeSwitch2:SetSwitchState(IsLeft)
end

--- 色板上的多选框
function LoginCreateAppearanceCustomizePageView:OnWorldTableSelectChange(Index)
	self.ViewModel:UpdateWorldTableSelected(Index)
	if self.ViewModel.bShowPanelColor == true and self.ViewModel.bParamNone == false and self.ViewModel.ColorTableIndex ~= nil then
		self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
		self.ColorTableView:ScrollIndexIntoView(self.ViewModel.ColorTableIndex)
	end
end

--- 色板上无
function LoginCreateAppearanceCustomizePageView:OnClickedBtnNone()
	self.ColorTableView:CancelSelected()
	self.ViewModel:SetColorTypeNone()
end

-- 类型列表所选变化
function LoginCreateAppearanceCustomizePageView:OnTypeTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateTypeTableSelected(Index)
	self.TypeTableView:ScrollIndexIntoView(Index)
end

function LoginCreateAppearanceCustomizePageView:OnSliderValueChange()
	local PercentValue = self.SliderHeight:GetValue()
	self.ViewModel:UpdateSliderValue(PercentValue)
end

function LoginCreateAppearanceCustomizePageView:OnSliderMouseCaptureEnd()
	LoginAvatarMgr:UpdateFocusLocation()
	local PercentValue = self.SliderHeight:GetValue()
	self.ViewModel:RecordSliderValue(PercentValue)
end
-- 切换控件
function LoginCreateAppearanceCustomizePageView:OnClickedTypeSwitch(IsLeft)
	if IsLeft == false and self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Ear then
		self.ViewModel:UpdateSwitchSelected(IsLeft, "bShowPanelType", "bShowPanelHeight")
		self.TypeSwitchProbar:SetTitleText(LSTR(980018), LSTR(980011))
		self.TypeSwitchProbar:SetSwitchState(IsLeft)
		self.ViewModel:SetBodyType()
		self.SliderHeight:SetValue(self.ViewModel.ProBarPercent)
	elseif IsLeft == false and self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Tail then
		self.ViewModel:UpdateSwitchSelected(IsLeft, "bShowPanelFace", "bShowPanelHeight")
		self.TypeSwitchProbar:SetTitleText(LSTR(980018), LSTR(980011))
		self.TypeSwitchProbar:SetSwitchState(IsLeft)
		self.ViewModel:SetTailSize()
		self.SliderHeight:SetValue(self.ViewModel.ProBarPercent)
	elseif IsLeft == true and self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Tail then
		self.ViewModel:UpdateSwitchSelected(IsLeft, "bShowPanelFace", "bShowPanelHeight")
		self.TypeSwitch3:SetTitleText(LSTR(980018), LSTR(980011))
		self.TypeSwitch3:SetSwitchState(IsLeft)
		self.ViewModel:SelectTail()
		self.FaceTableView:SetSelectedIndex(self.ViewModel.FaceTableIndex)
	else
		self.ViewModel:UpdateSwitchSelected(IsLeft, "bShowPanelType", "bShowPanelHeight")
		self.TypeSwitch:SetSwitchState(IsLeft)
		self.ViewModel:SelectFacialFeature()
		self.TypeTableView:SetSelectedIndex(self.ViewModel.TypeTableIndex)
	end

	self:PlayPanelAnim()
end

-- 色板切换框
function LoginCreateAppearanceCustomizePageView:OnClickedTypeSwitchParam(IsLeft)
	self.ViewModel:UpdateParamSwitchSelected(IsLeft)
	self.TypeSwitch1:SetSwitchState(IsLeft)
	self.TypeSwitch2:SetSwitchState(IsLeft)
	-- 切换colorlist选中项
	local SelectIndex = self.ViewModel.ColorTableIndex
	if SelectIndex == 0 then
		self.ColorTableView:CancelSelected()
		self.ColorTableView:ScrollToTop()
	else
		self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
		self.ColorTableView:ScrollIndexIntoView(self.ViewModel.ColorTableIndex)
	end
	self:SetColorPanelSize()
	-- todo 无颜色选中状态
	--if self.ViewModel.bParamNone then
		--self.ColorTableView:CancelSelected()
	--end
end

-- 无颜色选中状态变化
function LoginCreateAppearanceCustomizePageView:OnParamNoneChange()
	if self.ViewModel.bParamNone then
	--else
		--self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
		if self.ViewModel.bExpanded and self.ViewModel.bShowColorTable == false then
			self.ViewModel:ExpandedStateChanged(false)
			self.BtnExpand:SetExpandState(false)
			self.ViewModel.bExpanded = false
		elseif self.ViewModel.bShowColorTable == true then
			self.ColorTableView:CancelSelected()
			self.ColorTableView:ScrollToTop()
		end
		
	end
end

-- 面妆反转选项
function LoginCreateAppearanceCustomizePageView:OnBtnFlipClick()
	self.ViewModel:SetDecalFlip()
end

-- 数据重置默认
function LoginCreateAppearanceCustomizePageView:OnClickRefresh()
	self:ResetTieUp()
	LoginAvatarMgr:SetRefreshHistory()
	LoginAvatarMgr:SetCurAvatarFace(self.ViewModel.DefaultCustomData)
	self:RefreshUIState()
end
-- 撤销
function LoginCreateAppearanceCustomizePageView:OnClickRevertBackward()
	self:ResetTieUp()
	local CurRecord = LoginAvatarMgr:UndoAvatar()
	self:ResetMenueSelect(CurRecord)
end
-- 恢复
function LoginCreateAppearanceCustomizePageView:OnClickRevertForward()
	self:ResetTieUp()
	local CurRecord = LoginAvatarMgr:RedoAvatar()
	self:ResetMenueSelect(CurRecord)
end
-- 数据回退后UI菜单更新
function LoginCreateAppearanceCustomizePageView:ResetMenueSelect(CurRecord)
	if CurRecord == nil or CurRecord.PartKey == nil then return end
	self.ViewModel.bExpanded = CurRecord.bExpanded
	self.ViewModel.bOperateSub = CurRecord.bOperateSub
	local bSameType = CurRecord.MainType == self.ViewModel.MainType and CurRecord.SubIndex == self.ViewModel.PreSelectSubIndex
	if CurRecord.PartKey == 0 or bSameType then
		-- 刷新当前界面
		self:RefreshUIState()
		return
	end
	--local bChangeExpand = self.ViewModel.bExpanded == CurRecord.bExpanded
	--local bChangeSub = self.ViewModel.bOperateSub == CurRecord.bOperateSub
	if CurRecord.MainType ~= self.ViewModel.MainType then
		self.LooksTableView:SetSelectedIndex(CurRecord.MainType)
	end
	if CurRecord.MainType == LoginAvatarMgr.CustomizeMainMenu.Voice then
		-- 音效页签单独处理
		self.ViewModel:UpdateVoiceMenu()
		self.VoiceTableView:SetSelectedIndex(CurRecord.SubIndex)
	else
		self.ViewModel:SetMainType(CurRecord.MainType)
		local MainTile = LoginAvatarMgr:GetMainMenuList()[CurRecord.MainType]
		self.ViewModel:UpdateSubMenu(MainTile)
		self.SubMenuTableView:SetSelectedIndex(CurRecord.SubIndex)
	end
	self:RefreshUIState()
	-- 色板处理
	-- if (self.ViewModel.bOperateSub == false or self.ViewModel.bShowWordPanel) and self.ViewModel.bShowSwitch == false then
	-- 	--self:UpdateSubMenuTable(self.ViewModel.PreSelectSubIndex)
	-- elseif self.ViewModel.bShowPanelColor then
	-- 	self:OnClickedTypeSwitchParam(not self.ViewModel.bOperateSub)
	-- 	-- 色板状态展开刷新
	-- 	self.ViewModel:ExpandedStateChanged(self.ViewModel.bExpanded)
	-- 	self.BtnExpand:SetExpandState(self.ViewModel.bExpanded)
	-- end
end
-- 束发和束发按钮恢复
function LoginCreateAppearanceCustomizePageView:ResetTieUp()
	if LoginAvatarMgr:GetTieUpHairState() == false then return end
	-- 束发恢复
	LoginAvatarMgr:SetTieUpHairState(false)
	--local LoginFixPageView = _G.UIViewMgr:FindView(_G.UIViewID.LoginFixPage)
	local LoginFixPageView = LoginUIMgr.FixPageView
	if LoginFixPageView and LoginFixPageView.MorePage then
		LoginFixPageView.MorePage:ResetHairBtn()
	end
end

-- 设置图片列表左右对齐OnFaceTableNumChange
function LoginCreateAppearanceCustomizePageView:OnFaceTableNumChange()
	if self.ViewModel.FaceTableNum < 3 then
		self.FaceTableView:SetTileAlignment(UE.EListItemAlignment.RightAligned)
	else
		self.FaceTableView:SetTileAlignment(UE.EListItemAlignment.LeftAligned)
	end
end

-- 刷新当前选中控件状态
function LoginCreateAppearanceCustomizePageView:RefreshUIState()
	-- 音效撤销
	if self.ViewModel.bVoiceMenue == true then
		self:OnVoiceTableSelectChange(self.ViewModel.PreSelectSubIndex)
		return
	end
	-- 其他撤销
	if (self.ViewModel.bOperateSub == false or self.ViewModel.bShowWordPanel) and self.ViewModel.bShowSwitch == false then
		self:UpdateSubMenuTable(self.ViewModel.PreSelectSubIndex)
	elseif self.ViewModel.bShowPanelColor then
		self:OnClickedTypeSwitchParam(not self.ViewModel.bOperateSub)
		-- 色板状态展开刷新
		self.ViewModel:ExpandedStateChanged(self.ViewModel.bExpanded)
		self.BtnExpand:SetExpandState(self.ViewModel.bExpanded)
	elseif self.ViewModel.bShowPanelHeight then
		self:OnClickedTypeSwitch(false)
	end
	self.ViewModel:UpdateExpandedAction()
end

-- 色板大小调整
function LoginCreateAppearanceCustomizePageView:SetColorPanelSize()
	local IsShowSwitch = self.ViewModel.bShowLongSwitch == true or self.ViewModel.bShowShortSwitch == true
	if self.ViewModel.bShowWordPanel then
		UIUtil.CanvasSlotSetSize(self.TableViewColor, _G.UE.FVector2D(0, 598))
	elseif self.ViewModel.bShowBtnNone and IsShowSwitch then
		UIUtil.CanvasSlotSetSize(self.TableViewColor, _G.UE.FVector2D(0, 578))
	elseif IsShowSwitch then
        UIUtil.CanvasSlotSetSize(self.TableViewColor, _G.UE.FVector2D(0, 637))
	else
		UIUtil.CanvasSlotSetSize(self.TableViewColor, _G.UE.FVector2D(0, 728))
    end
end

-- 后台捏脸数据替换
function LoginCreateAppearanceCustomizePageView:OnLoginCreatFaceServerReset(bTribeGender)
	if bTribeGender then
		self:OnShowStart()
	else
		self:RefreshUIState()
	end
end

-- UI动效
function LoginCreateAppearanceCustomizePageView:PlayPanelAnim()
	local PanelAnim = nil
	if self.ViewModel.bShowPanelFace then
		PanelAnim = self.AnimFaceIn
	elseif self.ViewModel.bShowPanelType then
		PanelAnim = self.AnimTypeIn
	elseif self.ViewModel.bShowPanelColor then
		PanelAnim = self.AnimColorIn
	elseif self.ViewModel.bShowPanelHeight then
		PanelAnim = self.AnimHeightIn
	end
	if PanelAnim ~= nil then
		self:PlayAnimation(PanelAnim)
	end
end

return LoginCreateAppearanceCustomizePageView
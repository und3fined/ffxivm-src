---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")
--local TimerMgr = _G.TimerMgr
local LSTR = _G.LSTR
local HaircutMgr = nil
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
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")


--@ViewModel
local HaircutMainVM = require("Game/Haircut/VM/HaircutMainVM")

---@class HaircutMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnApply CommBtnLView
---@field BtnClose CommonCloseBtnView
---@field BtnExpand HaircutExpandItemView
---@field BtnPreview UFButton
---@field Btn_RBundlehair UToggleButton
---@field Btn_Refresh UFButton
---@field Btn_RevertBackward UFButton
---@field Btn_RevertForward UFButton
---@field Btn_Watch UToggleButton
---@field CommTabs1 CommTabsView
---@field CommTabs2 CommTabsView
---@field CommonTitleNew CommonTitleView
---@field PanelBottomBtn UFCanvasPanel
---@field PanelBtnNone HaircutTypeNoneItemView
---@field PanelColor UFCanvasPanel
---@field PanelFace UFCanvasPanel
---@field PanelPart_1 UFCanvasPanel
---@field PanelSideTab UFCanvasPanel
---@field PanelTopBtn UFCanvasPanel
---@field PanelType UFCanvasPanel
---@field ReversalPanel UFCanvasPanel
---@field Spacer2 USpacer
---@field TableViewColor UTableView
---@field TableViewFace UTableView
---@field TableViewTextTab UTableView
---@field TableViewType UTableView
---@field TableViewWordItem UTableView
---@field TextPreview1 UFTextBlock
---@field TextReversal UFTextBlock
---@field TextUse URichTextBox
---@field ToggleButton UToggleButton
---@field TypeSwitch1New UFCanvasPanel
---@field TypeSwitch2New UFCanvasPanel
---@field Unlock HaircutUnlockItemView
---@field VerIconTabsNew CommVerIconTabsView
---@field WordPanel UFCanvasPanel
---@field AnimColorIn UWidgetAnimation
---@field AnimFaceIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimTypeIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutMainPanelView = LuaClass(UIView, true)

function HaircutMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnApply = nil
	--self.BtnClose = nil
	--self.BtnExpand = nil
	--self.BtnPreview = nil
	--self.Btn_RBundlehair = nil
	--self.Btn_Refresh = nil
	--self.Btn_RevertBackward = nil
	--self.Btn_RevertForward = nil
	--self.Btn_Watch = nil
	--self.CommTabs1 = nil
	--self.CommTabs2 = nil
	--self.CommonTitleNew = nil
	--self.PanelBottomBtn = nil
	--self.PanelBtnNone = nil
	--self.PanelColor = nil
	--self.PanelFace = nil
	--self.PanelPart_1 = nil
	--self.PanelSideTab = nil
	--self.PanelTopBtn = nil
	--self.PanelType = nil
	--self.ReversalPanel = nil
	--self.Spacer2 = nil
	--self.TableViewColor = nil
	--self.TableViewFace = nil
	--self.TableViewTextTab = nil
	--self.TableViewType = nil
	--self.TableViewWordItem = nil
	--self.TextPreview1 = nil
	--self.TextReversal = nil
	--self.TextUse = nil
	--self.ToggleButton = nil
	--self.TypeSwitch1New = nil
	--self.TypeSwitch2New = nil
	--self.Unlock = nil
	--self.VerIconTabsNew = nil
	--self.WordPanel = nil
	--self.AnimColorIn = nil
	--self.AnimFaceIn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimTypeIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnApply)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnExpand)
	self:AddSubView(self.CommTabs1)
	self:AddSubView(self.CommTabs2)
	self:AddSubView(self.CommonTitleNew)
	self:AddSubView(self.PanelBtnNone)
	self:AddSubView(self.Unlock)
	self:AddSubView(self.VerIconTabsNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutMainPanelView:OnInit()
	HaircutMgr = _G.HaircutMgr
    LoginAvatarMgr = _G.LoginAvatarMgr
    LoginUIMgr = _G.LoginUIMgr
	self.ViewModel = HaircutMainVM.New()

	--self.MainTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnMainTableSelectChange, true, true)
	self.SubMenuTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewTextTab, self.OnSubMenuTableSelectChange, true, false)

	self.FaceTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewFace, self.OnFaceTableSelectChange, true, false)
	self.ColorTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewColor, self.OnColorTableSelectChange, true, false)
	self.TypeTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewType, self.OnTypeTableSelectChange, true, false)
	self.WorldTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewWordItem, self.OnWorldTableSelectChange, true, true)

	-- 注释和束发
	self.IsGaze = false
	self.IsTieUpHair = false

	
	self.BgmPlayingID = 0
	self.TimerId = nil

	--self.TextTitle:SetText(LSTR(1250001)) --"美容"
	self.CommonTitleNew:SetTextTitleName(LSTR(1250001))
	self.TextReversal:SetText(LSTR(1250002)) --"反转"
	self.TextPreview1:SetText(LSTR(1250003)) --"当前服饰仅为预览"
	self.BtnApply.TextContent:SetText( LSTR(1250004)) --"完成美容"
end

function HaircutMainPanelView:OnDestroy()
	local RealLeaveHaircut = HaircutMgr.RealLeaveHaircut
	if RealLeaveHaircut then
		LoginUIMgr.LoginReConnectMgr:ExitCreateRole()
	end
end

function HaircutMainPanelView:OnActive()
	if self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
		HaircutMgr:SendMsgHairQuery()
	end
end

function HaircutMainPanelView:OnShow()
	self:SetComTabStyle()
	UIUtil.SetIsVisible(self.CommonTitleNew, true)
	self.CommonTitleNew:SetSubTitleIsVisible(true)
	self.CommonTitleNew:SetCommInforBtnIsVisible(false)
	_G.UE.UCommonUtil.OpenWaitForFaceTextureMips()
	CommonUtil.HideJoyStick()
	LoginAvatarMgr:ModelMoveToLeft(false, false)
	-- 音效
	HaircutMgr:PlayBGM(true)
	HaircutMgr.RealLeaveHaircut = false
	local function SetFaceCallback()
		local UIComplexCharacter = LoginUIMgr:GetUIComplexCharacter()
		if UIComplexCharacter ~= nil then
			self:OnActorFaceSet()
			--TimerMgr:CancelTimer(self.TimerId)
			if self.TimerId then
				self:UnRegisterTimer(self.TimerId)
				self.TimerId = nil
			end
		end
	end

	--self.TimerId = TimerMgr:AddTimer(nil, TempCallback, 0, 0, -1)
	if self.TimerId then
		self:UnRegisterTimer(self.TimerId)
		self.TimerId = nil
	end
	self.TimerId = self:RegisterTimer(SetFaceCallback, 0, 0.1, 0)

	self:RefreshBtnGaze()
end

function HaircutMainPanelView:OnAssembleAllEnd(Params)
	self:RefreshBtnGaze()
end

function HaircutMainPanelView:InitMainMenu()
	if self.ViewModel == nil then return end
	local ListData = self.ViewModel:GetMainMenuData()
	if ListData ~= nil and table.size(ListData) > 0 then
		self.VerIconTabsNew:UpdateItems(ListData, 1)
	end
	self.VerIconTabsNew:SetIsSwitchPanelVisible(false)
end

function HaircutMainPanelView:OnActorFaceSet()
	if self.IsHiding == true then return end
	--LoginAvatarMgr:SetCameraFocus(self.ViewModel.SubType, false, true)
	-- 捏脸数据初始化
	if _G.UE.UCommonUtil.IsObjectValid(self.Btn_Watch) then
		self.ViewModel:InitViewData()
		self:InitMainMenu()
		-- 注释和束发
		self.Btn_Watch:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		self.Btn_RBundlehair:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		local bFirstEnterHairCutMap = _G.LoginMapMgr.bFirstEnterHairCutMap
		local MainTile = ""
		--回复到上一操作信息界面
		MainTile = LoginUIMgr.LoginReConnectMgr:GetValue("HairCutSubMenu")
		local HairCutSubMenuSelect = LoginUIMgr.LoginReConnectMgr:GetValue("HairCutSubMenuSelect")
		local MainMenuList = LoginAvatarMgr:GetMainMenuList()
		local RecordIndex = 1
		if MainTile == MainMenuList[LoginAvatarMgr.CustomizeMainMenu.Decorate] then
			RecordIndex = 2
		end
		local HairCutColorIsLeft = LoginUIMgr.LoginReConnectMgr:GetValue("HairCutColorIsLeft") or true
		if MainTile ~= nil and HairCutSubMenuSelect ~= nil and RecordIndex ~= nil then
			--打开记录的页签
			--self.MainTableView:ScrollToTop()
			self.VerIconTabsNew:SetSelectedIndex(RecordIndex)
			self.SubMenuTableView:SetSelectedIndex(HairCutSubMenuSelect)
			-- if self:IsNeedColor(self.ViewModel.SubType) then
			-- 	self:OnClickedTypeSwitchParam(HairCutColorIsLeft)
			-- end
			self:RefreshUIState()
		else if not HaircutMgr.bReconnect then
			-- 默认打开第一个页签
			--self.MainTableView:ScrollToTop()
			self.VerIconTabsNew:SetSelectedIndex(1)
		else
			--打开记录的页签
			--self.MainTableView:ScrollToTop()
			self.VerIconTabsNew:SetSelectedIndex(HaircutMgr.RecordIndex)
			self.SubMenuTableView:SetSelectedIndex(HaircutMgr.HairCutSubMenuSelect)
			if self:IsNeedColor(self.ViewModel.SubType) then
				self:OnClickedTypeSwitchParam(HaircutMgr.HairCutColorIsLeft)
			end
		end
		end

	end
end
--判断是否有右边的调色板类的切换按钮 执行掉线重连恢复面板的逻辑
function HaircutMainPanelView:IsNeedColor(SubType)
	if SubType == nil then
		return false
	end
	return SubType ~= LoginAvatarMgr.CustomizeSubType.PupilSize and SubType~=LoginAvatarMgr.CustomizeSubType.FaceDecal 
			and SubType~=LoginAvatarMgr.CustomizeSubType.FaceScar and SubType~=LoginAvatarMgr.CustomizeSubType.Tattoo and SubType~=LoginAvatarMgr.CustomizeSubType.Hairdo
end
function HaircutMainPanelView:OnHide()
	self.ViewModel:UnInitViewData()
	_G.UE.UCommonUtil.CloseWaitForFaceTextureMips()
	-- 注释和束发
	-- self.IsGaze = false
	--self.IsTieUpHair = false

	--self.LastClickBtn = nil

	-- 音效
	-- HaircutMgr:PlayBGM(false)
	-- if self.TimerId > 0 then
	-- 	TimerMgr:CancelTimer(self.TimerId)
	-- end
end

function HaircutMainPanelView:OnRegisterUIEvent()

	--UIUtil.AddOnClickedEvent(self, self.BtnClose.Btn_Close, self.OnBtnClose)
	self.BtnClose:SetCallback(self, self.OnBtnClose)
	UIUtil.AddOnClickedEvent(self, self.BtnExpand.BtnStretch, self.OnClickedStretch)

	UIUtil.AddOnClickedEvent(self, self.CommTabs1.BtnItem, self.OnClickedTypeSwitchParam, true)
	UIUtil.AddOnClickedEvent(self, self.CommTabs1.BtnItem2, self.OnClickedTypeSwitchParam, false)
	UIUtil.AddOnClickedEvent(self, self.CommTabs2.BtnItem, self.OnClickedTypeSwitchParam, true)
	UIUtil.AddOnClickedEvent(self, self.CommTabs2.BtnItem2, self.OnClickedTypeSwitchParam, false)

	UIUtil.AddOnClickedEvent(self, self.PanelBtnNone.BtnText, self.OnClickedBtnNone)

	UIUtil.AddOnClickedEvent(self, self.ToggleButton, self.OnBtnFlipClick)

	UIUtil.AddOnClickedEvent(self, self.Btn_Refresh, 	    self.OnClickRefresh)
	UIUtil.AddOnClickedEvent(self, self.Btn_RevertBackward, self.OnClickRevertBackward)
	UIUtil.AddOnClickedEvent(self, self.Btn_RevertForward,  self.OnClickRevertForward)

	UIUtil.AddOnStateChangedEvent(self, self.Btn_Watch, self.OnToggleBtnGaze)				--注视
	UIUtil.AddOnStateChangedEvent(self, self.Btn_RBundlehair, self.OnToggleBtnTieUpHair)	--束发
	--UIUtil.AddOnStateChangedEvent(self, self.BtnPreview, self.OnToggleBtnAction)			--预览
	UIUtil.AddOnClickedEvent(self, self.BtnPreview,  self.OnToggleBtnAction)

	UIUtil.AddOnClickedEvent(self, self.Unlock.Btn.Button, self.OnClickedUnlock)  -- 解锁发型
	UIUtil.AddOnClickedEvent(self, self.Unlock.BackpackSlot.FBtn_Item, self.OnBtnTipsClick)

	UIUtil.AddOnClickedEvent(self, self.BtnApply.Button, self.OnClickedApply)  -- 保存修改

	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabsNew, self.OnMainTableSelectChange)
end

function HaircutMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.HairUnlockListChange, self.OnHairUnlockListChange)
	self:RegisterGameEvent(EventID.HairRoleQuery, self.OnHairRoleQuery)
	self:RegisterGameEvent(EventID.LoginUIActorFaceSet, self.OnActorFaceSet)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.DoLoginRes)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnBagUseItemSucc)
end

function HaircutMainPanelView:OnRegisterBinder()
	local Binders = {
		{ "bShowNormalMenue", UIBinderSetIsVisible.New(self, self.TableViewTextTab, false, true) }, -- 选择菜单
		{ "bShowNormalMenue", UIBinderSetIsVisible.New(self, self.PanelSideTab, false, true) }, -- 选择菜单
		{ "bShowNormalMenue", UIBinderSetIsVisible.New(self, self.VerIconTabsNew.TableViewTabs, false, true) },
		{ "bShowNormalMenue", UIBinderSetIsVisible.New(self, self.VerIconTabsNew.ImgTabBG, false, true) }, -- 选择菜单
		--{ "MainCfgList", UIBinderUpdateBindableList.New(self, self.MainTableView) }, -- 一级菜单
		{ "ListSubMenuVM", UIBinderUpdateBindableList.New(self, self.SubMenuTableView) }, -- 二级页签列表

		{ "ListFaceTableVM", UIBinderUpdateBindableList.New(self, self.FaceTableView) }, -- 图片选择列表
		{ "bShowPanelFace", UIBinderSetIsVisible.New(self, self.PanelFace) }, -- 图片选择列表显隐

		{ "SubTitleText", UIBinderSetText.New(self, self.CommonTitleNew.TextSubtitle)}, -- 子菜单标题显示

		{ "bShowFlip", UIBinderSetIsVisible.New(self, self.ReversalPanel) }, -- 反转选项显隐
		{ "bFlip", UIBinderSetIsChecked.New(self, self.ToggleButton, false) },

		{ "bShowHairText", UIBinderSetIsVisible.New(self, self.TextUse) }, -- 已解锁发型显示
		{ "bShowUnlock", UIBinderSetIsVisible.New(self, self.Unlock) }, -- 解锁功能
		{ "HairText", UIBinderSetText.New(self, self.TextUse)}, -- 发型介绍
		{ "bLockBtnEnable", UIBinderSetIsEnabled.New(self, self.Unlock.Btn, false, false)}, -- 解锁按钮
		{ "LockText", UIBinderSetText.New(self, self.Unlock.TextQuantity)}, -- 解锁道具显示
		{ "UnLockItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.Unlock.BackpackSlot.FImg_Icon, true) }, -- 消耗物品图标
		
		--{ "FaceTableSize", UIBinderCanvasSlotSetSize.New(self, self.TableViewFace, true)}, -- 图片选择列表大小

		{ "ListColorTableVM", UIBinderUpdateBindableList.New(self, self.ColorTableView) }, -- 色号选择列表
		{ "ListWorldTableVM", UIBinderUpdateBindableList.New(self, self.WorldTableView) },
		
		{ "bShowPanelColor", UIBinderSetIsVisible.New(self, self.PanelColor) }, -- 色板显隐
		{ "bShowWordPanel", UIBinderSetIsVisible.New(self, self.WordPanel) }, -- 色板上种类多选框
		{ "bShowLongSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch2New) }, -- 色板上展开后切换框
		{ "bShowShortSwitch", UIBinderSetIsVisible.New(self, self.TypeSwitch1New) }, -- 色板上展开前切换框
		{ "bShowBtnNone", UIBinderSetIsVisible.New(self, self.PanelBtnNone) }, -- 色板上"无"选项
		{ "bExpanded", UIBinderSetIsVisible.New(self, self.Spacer2) },
		{ "bShowColorTable", UIBinderSetIsVisible.New(self, self.TableViewColor, false, true) },
		{ "bShowColorTable", UIBinderSetIsVisible.New(self, self.BtnExpand) },
		
		{ "bShowPanelType", UIBinderSetIsVisible.New(self, self.PanelType) }, -- 类型选择显隐
		{ "ListTypeTableVM", UIBinderUpdateBindableList.New(self, self.TypeTableView) }, -- 类型选择列表

		{ "FaceTableNum", UIBinderValueChangedCallback.New(self, nil, self.OnFaceTableNumChange) },

		{ "bParamNone", UIBinderValueChangedCallback.New(self, nil, self.OnParamNoneChange) },

		{ "bShowSuitTips", UIBinderSetIsVisible.New(self, self.TextPreview1) },

		{ "bParamNone", UIBinderSetIsVisible.New(self, self.PanelBtnNone.ImgFocus) },

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function HaircutMainPanelView:OnBtnClose()
	local Callback = function()
		HaircutMgr:EndHaircut(false)
	end
	local Params = {
		WinType = HaircutMgr.HaircutWinType.Exist,
		SureCallback = Callback
	}
	UIViewMgr:ShowView(UIViewID.HaircutWin, Params)
end

-- 主菜单列表
function HaircutMainPanelView:OnMainTableSelectChange(Index, ItemData, ItemView)
	local MenueType = Index > 1 and LoginAvatarMgr.CustomizeMainMenu.Decorate or LoginAvatarMgr.CustomizeMainMenu.Hair
	local MainTile = LoginAvatarMgr:GetMainMenuList()[MenueType]
	-- 二级页签
	self.ViewModel:SetMainType(MenueType)
	self.ViewModel:UpdateSubMenu(MainTile)
	self.SubMenuTableView:SetSelectedIndex(1)

end

-- 所选二级页签发生变化
function HaircutMainPanelView:OnSubMenuTableSelectChange(Index, ItemData, ItemView)
	self:UpdateSubMenuTable(Index)
	-- 防止刚进入游戏就在理发屋的情况，后续会干掉
	local UnlockList = HaircutMgr:GetHairUnlockList()
    if self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Hairdo and UnlockList == nil then
		HaircutMgr:SendMsgHairQuery()
	end

	self:PlayPanelAnim()
	LoginAvatarMgr:InitSpringArm()
end


-- 所选二级页签发生变化，数据变化
function HaircutMainPanelView:UpdateSubMenuTable(Index)
	self.ViewModel:UpdateSubMenuSelected(Index)
	-- 部分控件大小需要动态修改
	--self:SetColorPanelSize()
	-- 切换框文字
	local Type = self.ViewModel.SubType
	if Type == LoginAvatarMgr.CustomizeSubType.EyeColor then
		--self.TypeSwitch1:SetTitleText(LSTR(1250010), LSTR(1250011)) -- "左""右"
		--self.TypeSwitch2:SetTitleText(LSTR(1250010), LSTR(1250011)) -- "左""右"
		self:SetSwitchText(true, LSTR(1250010), LSTR(1250011))
		self:SetSwitchText(false, LSTR(1250010), LSTR(1250011))
	elseif Type == LoginAvatarMgr.CustomizeSubType.HairColor then
		--self.TypeSwitch1:SetTitleText(LSTR(1250012), LSTR(1250013)) --"发色""挑染"
		--self.TypeSwitch2:SetTitleText(LSTR(1250012), LSTR(1250013)) --"发色""挑染"
		self:SetSwitchText(true, LSTR(1250012), LSTR(1250013))
		self:SetSwitchText(false, LSTR(1250012), LSTR(1250013))
	else
		-- self.TypeSwitch1:SetTitleText(LSTR(1250014), LSTR(1250015)) --"浓艳""清淡"
		-- self.TypeSwitch2:SetTitleText(LSTR(1250014), LSTR(1250015)) --"浓艳""清淡"
		self:SetSwitchText(true, LSTR(1250014), LSTR(1250015))
		self:SetSwitchText(false, LSTR(1250014), LSTR(1250015))
	end

	-- 数据状态映射
	if self.ViewModel.bShowPanelFace == true and self.ViewModel.FaceTableIndex ~= nil and self.ViewModel.bMultiSelect == false then
		self.FaceTableView:SetSelectedIndex(self.ViewModel.FaceTableIndex)
		self.FaceTableView:ScrollIndexIntoView(self.ViewModel.FaceTableIndex)
	elseif self.ViewModel.bShowPanelType == true and self.ViewModel.TypeTableIndex ~= nil then
		self.TypeTableView:SetSelectedIndex(self.ViewModel.TypeTableIndex)
		self.TypeTableView:ScrollIndexIntoView(self.ViewModel.TypeTableIndex)
	elseif self.ViewModel.bShowPanelColor == true and self.ViewModel.bParamNone == false and self.ViewModel.ColorTableIndex ~= nil then
		self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
		self.ColorTableView:ScrollIndexIntoView(self.ViewModel.ColorTableIndex)
	end
end
-- 图片列表所选变化
function HaircutMainPanelView:OnFaceTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateFaceTableSelected(Index)
	-- -- 解锁部分
	-- if self.ViewModel.bUseUnlock == true then
	-- 	self.Unlock.TextQuantity:SetText(self.ViewModel.LockText)
	-- end
end

-- 色号所选列表发生变化
function HaircutMainPanelView:OnColorTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateColorTableSelected(Index)
end

-- 色板展开
function HaircutMainPanelView:OnClickedStretch()
	self.ViewModel:ExpandedStateChanged(not (self.ViewModel.bExpanded))
	self.BtnExpand:SetExpandState(self.ViewModel.bExpanded)
	-- 属性选择保持切换框
	local IsLeft = not (self.ViewModel.bOperateSub)
	--self.TypeSwitch1:SetSwitchState(IsLeft)
	--self.TypeSwitch2:SetSwitchState(IsLeft)
	local SelectIndex = IsLeft and 1 or 2
	self.CommTabs1:SetSelectedIndex(SelectIndex)
	self.CommTabs2:SetSelectedIndex(SelectIndex)
end

--- 色板上的多选框
function HaircutMainPanelView:OnWorldTableSelectChange(Index)
	self.ViewModel:UpdateWorldTableSelected(Index)
	if self.ViewModel.bShowPanelColor == true and self.ViewModel.bParamNone == false and self.ViewModel.ColorTableIndex ~= nil then
		self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
		self.ColorTableView:ScrollIndexIntoView(self.ViewModel.ColorTableIndex)
	end
end

--- 色板上无
function HaircutMainPanelView:OnClickedBtnNone()
	self.ColorTableView:CancelSelected()
	self.ViewModel:SetColorTypeNone()
end

-- 类型列表所选变化
function HaircutMainPanelView:OnTypeTableSelectChange(Index, ItemData, ItemView)
	self.ViewModel:UpdateTypeTableSelected(Index)
end

-- 色板切换框
function HaircutMainPanelView:OnClickedTypeSwitchParam(IsLeft)
	self.ViewModel:UpdateParamSwitchSelected(IsLeft)
	--self.TypeSwitch1:SetSwitchState(IsLeft)
	--self.TypeSwitch2:SetSwitchState(IsLeft)
	local SelectIndex = IsLeft and 1 or 2
	self.CommTabs1:SetSelectedIndex(SelectIndex)
	self.CommTabs2:SetSelectedIndex(SelectIndex)
	-- 切换colorlist选中项
	local SelectIndex = self.ViewModel.ColorTableIndex
	if SelectIndex == 0 then
		self.ColorTableView:CancelSelected()
		self.ColorTableView:ScrollToTop()
	else
		self.ColorTableView:SetSelectedIndex(self.ViewModel.ColorTableIndex)
		self.ColorTableView:ScrollIndexIntoView(self.ViewModel.ColorTableIndex)
		--self.ColorTableView:ScrollToIndex(self.ViewModel.ColorTableIndex)
	end
	--self:SetColorPanelSize()
end

-- 无颜色选中状态变化
function HaircutMainPanelView:OnParamNoneChange()
	if self.ViewModel.bParamNone then
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
function HaircutMainPanelView:OnBtnFlipClick()
	self.ViewModel:SetDecalFlip()
end

-- 数据重置默认
function HaircutMainPanelView:OnClickRefresh()
	self:ResetTieUp()
	LoginAvatarMgr:SetRefreshHistory()
	LoginAvatarMgr:SetCurAvatarFace(self.ViewModel.DefaultCustomData)
	self:RefreshUIState()
end
-- 撤销
function HaircutMainPanelView:OnClickRevertBackward()
	self:ResetTieUp()
	local CurRecord = LoginAvatarMgr:UndoAvatar()
	self:ResetMenueSelect(CurRecord)
end
-- 恢复
function HaircutMainPanelView:OnClickRevertForward()
	self:ResetTieUp()
	local CurRecord = LoginAvatarMgr:RedoAvatar()
	self:ResetMenueSelect(CurRecord)
end
-- 数据回退后UI菜单更新
function HaircutMainPanelView:ResetMenueSelect(CurRecord)
	if CurRecord == nil or CurRecord.PartKey == nil then return end
	self.ViewModel.bExpanded = CurRecord.bExpanded
	self.ViewModel.bOperateSub = CurRecord.bOperateSub
	local bSameType = CurRecord.MainType == self.ViewModel.MainType and CurRecord.SubIndex == self.ViewModel.PreSelectSubIndex
	if CurRecord.PartKey == 0 or bSameType then
		-- 刷新当前界面
		self:RefreshUIState()
		return
	end
	if CurRecord.MainType ~= self.ViewModel.MainType then
		local MainIndex = CurRecord.MainType == LoginAvatarMgr.CustomizeMainMenu.Hair and 1 or 2
		self.VerIconTabsNew:SetSelectedIndex(MainIndex)
	end
	self.ViewModel:SetMainType(CurRecord.MainType)
	local MainTile = LoginAvatarMgr:GetMainMenuList()[CurRecord.MainType]
	self.ViewModel:UpdateSubMenu(MainTile)
	self.SubMenuTableView:SetSelectedIndex(CurRecord.SubIndex)
	self:RefreshUIState()
	-- 色板处理
	-- if self.ViewModel.bShowPanelColor then
	-- 	self:OnClickedTypeSwitchParam(not self.ViewModel.bOperateSub)
	-- 	-- 色板状态展开刷新
	-- 	self.ViewModel:ExpandedStateChanged(self.ViewModel.bExpanded)
	-- 	self.BtnExpand:SetExpandState(self.ViewModel.bExpanded)
	-- end
end
-- 束发和束发按钮恢复
function HaircutMainPanelView:ResetTieUp()
	if LoginAvatarMgr:GetTieUpHairState() == false then return end
	-- 束发恢复
	LoginAvatarMgr:SetTieUpHairState(false)
	self.Btn_RBundlehair:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	self.IsTieUpHair = false
end

-- 设置图片列表左右对齐OnFaceTableNumChange
function HaircutMainPanelView:OnFaceTableNumChange()
	if self.ViewModel.FaceTableNum < 3 then
		self.FaceTableView:SetTileAlignment(UE.EListItemAlignment.RightAligned)
	else
		self.FaceTableView:SetTileAlignment(UE.EListItemAlignment.LeftAligned)
	end
end

-- 刷新当前选中控件状态
function HaircutMainPanelView:RefreshUIState()
	-- 发型单独处理
	if self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
		self.ViewModel:UpdateTableSelect()
		self.FaceTableView:SetSelectedIndex(self.ViewModel.FaceTableIndex)
		self.FaceTableView:ScrollIndexIntoView(self.ViewModel.FaceTableIndex)
		return
	end
	--
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
function HaircutMainPanelView:SetColorPanelSize()
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

-- UI动效
function HaircutMainPanelView:PlayPanelAnim()
	local PanelAnim = nil
	if self.ViewModel.bShowPanelFace then
		PanelAnim = self.AnimFaceIn
	elseif self.ViewModel.bShowPanelType then
		PanelAnim = self.AnimTypeIn
	elseif self.ViewModel.bShowPanelColor then
		PanelAnim = self.AnimColorIn
	end
	if PanelAnim ~= nil then
		self:PlayAnimation(PanelAnim)
	end
end

-- 解锁发型更新
function HaircutMainPanelView:OnHairUnlockListChange()
	self.ViewModel:UpdateUnlockList()
	if self.ViewModel.FaceTableIndex ~= nil and self.ViewModel.bShowPanelFace then
		self.FaceTableView:SetSelectedIndex(self.ViewModel.FaceTableIndex)
		self.FaceTableView:ScrollIndexIntoView(self.ViewModel.FaceTableIndex)
	end
	--self.FaceTableView:ScrollToIndex(self.ViewModel.FaceTableIndex)
end

-- 获取角色信息并初始化捏脸数据
function HaircutMainPanelView:OnHairRoleQuery()
	self.ViewModel:UpdateRoleFace()
	-- 默认打开第一个页签
	--self.MainTableView:ScrollToTop()
	self.VerIconTabsNew:SetSelectedIndex(1)
end

-- 解锁道具tips
function HaircutMainPanelView:OnBtnTipsClick()
	ItemTipsUtil.ShowTipsByResID(self.ViewModel.UnLockItemID, self.Unlock.BackpackSlot)
end

-- 请求解锁发型
function HaircutMainPanelView:OnClickedUnlock()
	local HairLockID = self.ViewModel:GetUnlockHair()
	local HairType = self.ViewModel:GetUnlockType()
	if HairLockID ~= nil then
		local Callback = function()
			HaircutMgr:SendMsgHairUnlock(HairType)
		end
        local Params = {
            WinType =HaircutMgr.HaircutWinType.HairUnlock,
            ItemID = HairLockID,
			SureCallback = Callback
        }
        UIViewMgr:ShowView(UIViewID.HaircutWin, Params)
    end
end

-- 应用理发
function HaircutMainPanelView:OnClickedApply()
	local CurData = LoginAvatarMgr:GetCurAvatarFace()
	local DefaultData = self.ViewModel.DefaultCustomData
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
    if RoleSimple ~= nil then
        if RoleSimple.Avatar.Face ~= nil then
            DefaultData = RoleSimple.Avatar.Face
        end
    end
	local Params = {}
	if self.ViewModel.bUseUnlock then
		-- 未拥有发型保存时提示
		local HairLockID = self.ViewModel:GetUnlockHair()
		if HairLockID ~= nil then
			local Callback1 = function()
				self.ViewModel:ResetHair()
				self:RefreshUIState()
				self.FaceTableView:ScrollToIndex(self.ViewModel.FaceTableIndex)
			end
			Params = {
				WinType = HaircutMgr.HaircutWinType.HairNotOwn,
				ItemID = HairLockID,
				SureCallback = Callback1,
			}
		end
		
	elseif CurData ~= nil and DefaultData ~= nil and table.compare_table(CurData, DefaultData) == false then
		-- 修改后保存
		local Callback1 = function()
			HaircutMgr:SendMsgHaircutSet()
		end
		local Callback2 = function()
			--HaircutMgr:EndHaircut(false)
			UIViewMgr:HideView(UIViewID.HaircutWin)
		end
		Params = {
			WinType = HaircutMgr.HaircutWinType.Save,
			SureCallback = Callback1,
			CancleCallback = Callback2
		}
	else
		-- 未修改保存
		local Callback1 = function()
			HaircutMgr:EndHaircut(false)
		end
		Params = {
			WinType = HaircutMgr.HaircutWinType.UnModify,
			SureCallback = Callback1,
		}
	end
	UIViewMgr:ShowView(UIViewID.HaircutWin, Params)
end


--注视
function HaircutMainPanelView:OnToggleBtnGaze()
	local Actor = LoginUIMgr:GetUIComplexCharacter()
	if not Actor then
		return
	end

	if self.IsGaze then
		self.IsGaze = false
		self.Btn_Watch:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	else
		self.IsGaze = true
		self.Btn_Watch:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	end

	LoginUIMgr:OnGazeStateChg(self.IsGaze)

	ActorUtil.SetUILookAt(Actor, self.IsGaze, _G.UE.ELookAtType.ALL)
end

--束发
function HaircutMainPanelView:OnToggleBtnTieUpHair()
	if self.IsTieUpHair then
		self.IsTieUpHair = false
		self.Btn_RBundlehair:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	else
		self.IsTieUpHair = true
		self.Btn_RBundlehair:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	end

	LoginUIMgr:OnTieUpHairStateChg(self.IsTieUpHair)
	LoginAvatarMgr:TieUpHair(self.IsTieUpHair)
end

function HaircutMainPanelView:RefreshBtnGaze()
	local Actor = LoginUIMgr:GetUIComplexCharacter()
	if not Actor then
		return
	end
	LoginAvatarMgr:UpdateLookAtLimit()
	if self.IsGaze then
		self.Btn_Watch:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
	else
		self.Btn_Watch:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	end

	ActorUtil.SetUILookAt(Actor, self.IsGaze, _G.UE.ELookAtType.ALL)
end

--动作
function HaircutMainPanelView:OnToggleBtnAction()
	--self:ResetLastBtn()
	LoginUIMgr:OnShowPreviewPage()
	self:Hide()
	--UIViewMgr:HideView(UIViewID.HaircutMainPanel)
	--self:SetLastBtn(self.BtnPreview)
end

function HaircutMainPanelView:ResetLastBtn()
	if self.LastClickBtn then
		self.LastClickBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
	end
end

function HaircutMainPanelView:SetLastBtn(LastBtn)
	self.LastClickBtn = LastBtn
	self.LastClickBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked, false)
end
function HaircutMainPanelView:DoLoginRes()
	LoginRoleRaceGenderVM:ResSetCurrentRaceCfgByMajor()
	LoginAvatarMgr:SetRecoverFlag()
	LoginUIMgr:CreateRenderActor(true)
	
end

function HaircutMainPanelView:OnBagUseItemSucc(Params)
	if nil == Params then return end
	--Params.ResID
	if Params.ResID ~= nil and Params.ResID > 0 then
		if self.ViewModel.SubType == LoginAvatarMgr.CustomizeSubType.Hairdo
			and HaircutMgr:CheckIsHairItem(Params.ResID) then
			HaircutMgr:SendMsgHairQuery()
		end
	end
end

function HaircutMainPanelView:SetSwitchText(bShort, LeftText, RightText)
	local SwitchWight = bShort and self.CommTabs1 or self.CommTabs2
	if SwitchWight ~= nil then
		SwitchWight.TextTabName:SetText(LeftText)
		SwitchWight.TextTabName2:SetText(RightText)
		UIUtil.SetIsVisible(SwitchWight.TextTabName, true)
		UIUtil.SetIsVisible(SwitchWight.TextTabName2, true)
	end
end

function HaircutMainPanelView:SetComTabStyle()
	local bDarkMap = _G.LoginMapMgr:IsHaircutDefaultMap()
	local TableStyle = bDarkMap and 0 or 1
	self.CommTabs1:SetTabStyle(TableStyle)
	self.CommTabs2:SetTabStyle(TableStyle)
end
return HaircutMainPanelView
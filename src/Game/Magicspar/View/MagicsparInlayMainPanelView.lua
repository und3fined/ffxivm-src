---
--- Author: jamiyang
--- DateTime: 2023-04-03 11:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoCommon = require("Protocol/ProtoCommon")

local MagicsparInlayVM = require("Game/Magicspar/VM/MagicsparInlayMainPanelVM")
local MagicsparDefine = require("Game/Magicspar/MagicsparDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

--local MajorUtil = require("Utils/MajorUtil")
--local MsgBoxUtil = require("Utils/MsgBoxUtil")
local AudioUtil = require("Utils/AudioUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EquipmentMgr = _G.EquipmentMgr
local KIL = _G.UE.UKismetInputLibrary
local TimerMgr = _G.TimerMgr

---@class MagicsparInlayMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AttributeDisplay UFCanvasPanel
---@field BtnClick UFButton
---@field BtnExceed01 UFButton
---@field BtnExceed02 UFButton
---@field BtnExceed03 UFButton
---@field BtnExceed04 UFButton
---@field BtnExceedTipsBG UFButton
---@field BtnTipsBG UFButton
---@field Btn_BackAttribute CommBackBtnView
---@field Btn_BanInlay CommBtnXLView
---@field Btn_ClosePopup CommonCloseBtnView
---@field Btn_Inlay CommBtnXLView
---@field Btn_NormalInlay CommBtnXLView
---@field Btn_Remove CommBtnXLView
---@field Common_Render2D_UIBP CommonRender2DView
---@field EFF UFCanvasPanel
---@field FCanvasPanel_0 UFCanvasPanel
---@field FImage_142 UFImage
---@field FImg_IconEquip UFImage
---@field FImg_RateBkg UFImage
---@field FText_Lack UFTextBlock
---@field FVerticalBox_63 UFVerticalBox
---@field ImgExceed01 UFImage
---@field ImgExceed02 UFImage
---@field ImgExceed03 UFImage
---@field ImgExceed04 UFImage
---@field InforBtnNew CommInforBtnView
---@field InforCommItem MagicsparInforItemView
---@field InlayPanel UFCanvasPanel
---@field InlayPanel1 UFCanvasPanel
---@field InlayTips CommonTipsView
---@field MagicsparInlayTagSlot_UIBP_0 MagicsparInlayTagItemView
---@field MagicsparInlayTagSlot_UIBP_1 MagicsparInlayTagItemView
---@field MagicsparInlayTagSlot_UIBP_2 MagicsparInlayTagItemView
---@field MagicsparInlayTagSlot_UIBP_3 MagicsparInlayTagItemView
---@field MagicsparInlayTagSlot_UIBP_4 MagicsparInlayTagItemView
---@field MagicsparTips MagicsparTipsView
---@field PanelExceedTips UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PopupBG CommonPopUpBGView
---@field RichText_Rate URichTextBox
---@field RichText_SuccessRate UFTextBlock
---@field SlotItem01 MagicsparInlaySlotItemView
---@field SlotItem02 MagicsparInlaySlotItemView
---@field SlotItem03 MagicsparInlaySlotItemView
---@field SlotItem04 MagicsparInlaySlotItemView
---@field SlotItem05 MagicsparInlaySlotItemView
---@field SlotItem06 MagicsparInlaySlotItemView
---@field SlotItem07 MagicsparInlaySlotItemView
---@field SlotItem08 MagicsparInlaySlotItemView
---@field SlotItem09 MagicsparInlaySlotItemView
---@field SlotItem10 MagicsparInlaySlotItemView
---@field SoltEmptyTips UFCanvasPanel
---@field TableView_Magicspar UTableView
---@field TableView_Slot UTableView
---@field TextExceed UFTextBlock
---@field TextTipsDescription UFTextBlock
---@field Text_Attack UFTextBlock
---@field Text_AttackNum URichTextBox
---@field Text_AttributeTitle UFTextBlock
---@field Text_Belief UFTextBlock
---@field Text_BeliefNum URichTextBox
---@field Text_Crit UFTextBlock
---@field Text_CritNum URichTextBox
---@field Text_Haste UFTextBlock
---@field Text_HasteNum URichTextBox
---@field ToogleGroupInlay UToggleGroup
---@field icon2 UFImage
---@field icon_Pre UFImage
---@field AnimIn UWidgetAnimation
---@field AnimLose UWidgetAnimation
---@field AnimPreview UWidgetAnimation
---@field AnimPreviewOut UWidgetAnimation
---@field AnimSuccess UWidgetAnimation
---@field AnimTipsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparInlayMainPanelView = LuaClass(UIView, true)

function MagicsparInlayMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AttributeDisplay = nil
	--self.BtnClick = nil
	--self.BtnExceed01 = nil
	--self.BtnExceed02 = nil
	--self.BtnExceed03 = nil
	--self.BtnExceed04 = nil
	--self.BtnExceedTipsBG = nil
	--self.BtnTipsBG = nil
	--self.Btn_BackAttribute = nil
	--self.Btn_BanInlay = nil
	--self.Btn_ClosePopup = nil
	--self.Btn_Inlay = nil
	--self.Btn_NormalInlay = nil
	--self.Btn_Remove = nil
	--self.Common_Render2D_UIBP = nil
	--self.EFF = nil
	--self.FCanvasPanel_0 = nil
	--self.FImage_142 = nil
	--self.FImg_IconEquip = nil
	--self.FImg_RateBkg = nil
	--self.FText_Lack = nil
	--self.FVerticalBox_63 = nil
	--self.ImgExceed01 = nil
	--self.ImgExceed02 = nil
	--self.ImgExceed03 = nil
	--self.ImgExceed04 = nil
	--self.InforBtnNew = nil
	--self.InforCommItem = nil
	--self.InlayPanel = nil
	--self.InlayPanel1 = nil
	--self.InlayTips = nil
	--self.MagicsparInlayTagSlot_UIBP_0 = nil
	--self.MagicsparInlayTagSlot_UIBP_1 = nil
	--self.MagicsparInlayTagSlot_UIBP_2 = nil
	--self.MagicsparInlayTagSlot_UIBP_3 = nil
	--self.MagicsparInlayTagSlot_UIBP_4 = nil
	--self.MagicsparTips = nil
	--self.PanelExceedTips = nil
	--self.PanelTips = nil
	--self.PopupBG = nil
	--self.RichText_Rate = nil
	--self.RichText_SuccessRate = nil
	--self.SlotItem01 = nil
	--self.SlotItem02 = nil
	--self.SlotItem03 = nil
	--self.SlotItem04 = nil
	--self.SlotItem05 = nil
	--self.SlotItem06 = nil
	--self.SlotItem07 = nil
	--self.SlotItem08 = nil
	--self.SlotItem09 = nil
	--self.SlotItem10 = nil
	--self.SoltEmptyTips = nil
	--self.TableView_Magicspar = nil
	--self.TableView_Slot = nil
	--self.TextExceed = nil
	--self.TextTipsDescription = nil
	--self.Text_Attack = nil
	--self.Text_AttackNum = nil
	--self.Text_AttributeTitle = nil
	--self.Text_Belief = nil
	--self.Text_BeliefNum = nil
	--self.Text_Crit = nil
	--self.Text_CritNum = nil
	--self.Text_Haste = nil
	--self.Text_HasteNum = nil
	--self.ToogleGroupInlay = nil
	--self.icon2 = nil
	--self.icon_Pre = nil
	--self.AnimIn = nil
	--self.AnimLose = nil
	--self.AnimPreview = nil
	--self.AnimPreviewOut = nil
	--self.AnimSuccess = nil
	--self.AnimTipsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparInlayMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn_BackAttribute)
	self:AddSubView(self.Btn_BanInlay)
	self:AddSubView(self.Btn_ClosePopup)
	self:AddSubView(self.Btn_Inlay)
	self:AddSubView(self.Btn_NormalInlay)
	self:AddSubView(self.Btn_Remove)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.InforBtnNew)
	self:AddSubView(self.InforCommItem)
	self:AddSubView(self.InlayTips)
	self:AddSubView(self.MagicsparInlayTagSlot_UIBP_0)
	self:AddSubView(self.MagicsparInlayTagSlot_UIBP_1)
	self:AddSubView(self.MagicsparInlayTagSlot_UIBP_2)
	self:AddSubView(self.MagicsparInlayTagSlot_UIBP_3)
	self:AddSubView(self.MagicsparInlayTagSlot_UIBP_4)
	self:AddSubView(self.MagicsparTips)
	self:AddSubView(self.PopupBG)
	self:AddSubView(self.SlotItem01)
	self:AddSubView(self.SlotItem02)
	self:AddSubView(self.SlotItem03)
	self:AddSubView(self.SlotItem04)
	self:AddSubView(self.SlotItem05)
	self:AddSubView(self.SlotItem06)
	self:AddSubView(self.SlotItem07)
	self:AddSubView(self.SlotItem08)
	self:AddSubView(self.SlotItem09)
	self:AddSubView(self.SlotItem10)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparInlayMainPanelView:OnInit()
	self.ViewModel = MagicsparInlayVM.New()
	self.AdapterSlotTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_Slot)
	self.AdapterItemTableView = UIAdapterTableView.CreateAdapter(self, self.TableView_Magicspar, self.OnMagicsparSelect, false)
	self.Btn_BackAttribute:AddBackClick(self, self.OnSelectBackClick)
	--self.Btn_ClosePopup:SetCallback(self, self.HideModel)
	-- 屏幕选中
	--self.Common_Render2D_UIBP:SetClick(self, self.OnSingleClick, nil)
	self.RotateStartTime = 5.0
	self.RotateEndTime = 6.5
	self.LastSelectedSlot = 1
	self.LastEndTime = self.RotateStartTime
	self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
	self.RenderActor = nil
	self.InlayStateList = nil
	self.InlayIconPathList = nil
	self.bAnimationPlaying = false
	self.PlayingTime = 0.0
	self.TriggerCount = 3

	self.bNormalReplace = false
	--self.MajorActor = nil
	self.Text_AttributeTitle:SetText(_G.LSTR(1060001)) -- "魔晶石镶嵌"
	self.FText_Lack:SetText(_G.LSTR(1060020)) -- "缺少魔晶石"
	self.RichText_SuccessRate:SetText(_G.LSTR(1060021)) --"成功率"
	self.TextTipsDescription:SetText(_G.LSTR(1060022)) --"角色战斗职业所有穿戴装备所镶嵌的战斗类魔晶石属性具备上限，该上限会随着版本迭代逐步提升。超过上限的魔晶石属性将不会生效。"
	self.Text_Belief:SetText(_G.LSTR(1060023)) -- "信念"
	self.Text_Attack:SetText(_G.LSTR(1060024)) -- "直击"
	self.Text_Haste:SetText(_G.LSTR(1060025)) -- "急速"
	self.Text_Crit:SetText(_G.LSTR(1060026))  -- "暴击"

	self.UpdateTimerID = nil
end

function MagicsparInlayMainPanelView:OnDestroy()

end

function MagicsparInlayMainPanelView:OnShow()
	_G.HUDMgr:SetIsDrawHUD(false)
	self.LastEndTime = self.RotateStartTime
	self.ViewModel.bRateUse = false
	self.ActorSeqPlayer = nil
	self:LoadMagicModel()
	self.TriggerCount = 3
	self.Btn_BanInlay.Button.ClickInterval = MagicsparDefine.BanBtnClickInterval
	_G.LightMgr:EnableUIWeather(27, false)
end

function MagicsparInlayMainPanelView:OnHide()
	--self.Common_Render2D_UIBP:SwitchOtherLights(true)
	--self.Common_Render2D_UIBP:ReleaseActor()
	--self:PlayAnimation(self.AnimOut)
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	_G.HUDMgr:SetIsDrawHUD(true)
	--_G.FLOG_ERROR("MagicsparInlayMainPanelView:OnHide()")
	_G.LightMgr:DisableUIWeather()
end

function MagicsparInlayMainPanelView:HideModel()
	self.Common_Render2D_UIBP:ShowRenderActor(false)
	self.Common_Render2D_UIBP:SwitchOtherLights(true)
	--self.Common_Render2D_UIBP:ReleaseActor()
	_G.UIViewMgr:HideView(_G.UIViewID.MagicsparInlayMainPanel)
end
function MagicsparInlayMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn_Inlay.Button, self.OnInlayClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_NormalInlay.Button, self.OnNormalInlayClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_BanInlay.Button, self.OnBanInlayClick)
	UIUtil.AddOnClickedEvent(self, self.Btn_Remove.Button, self.OnRemoveClick)
	-- UIUtil.AddOnClickedEvent(self, self.InforBtn, self.OnInforBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnTipsBG, self.OnBtnTipsBGClick)
	UIUtil.AddOnClickedEvent(self, self.BtnExceed01, self.OnBtnExceed, 1)
	UIUtil.AddOnClickedEvent(self, self.BtnExceed02, self.OnBtnExceed, 2)
	UIUtil.AddOnClickedEvent(self, self.BtnExceed03, self.OnBtnExceed, 3)
	UIUtil.AddOnClickedEvent(self, self.BtnExceed04, self.OnBtnExceed, 4)
	UIUtil.AddOnClickedEvent(self, self.BtnExceedTipsBG, self.OnBtnTipsBGClick)
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnSingleClick)
end

function MagicsparInlayMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MagicsparInlaySucc, self.OnInlaySucc)
	self:RegisterGameEvent(_G.EventID.MagicsparUnInlaySucc, self.OnUnInlaySucc)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(_G.EventID.MagicsparSwitchEquip, self.OnMagicsparSwitchEquip)
	self:RegisterGameEvent(_G.EventID.ShopPlayOutAni,  self.MagicsparCloseShop)
	self:RegisterGameEvent(_G.EventID.MagicsparInlayRefresh,  self.MagicsparCloseShop)
end

function MagicsparInlayMainPanelView:OnRegisterBinder()
	local Binders = {
		--{ "Title", UIBinderSetText.New(self, self.Text_MagicsparInlay) },
		{ "EquipmentIconPath", UIBinderSetBrushFromAssetPath.New(self, self.FImg_IconEquip) },
		{ "SelectSlotIconPath", UIBinderSetBrushFromAssetPath.New(self, self.icon2) },
		{ "SelectSlotIconPath", UIBinderSetBrushFromAssetPath.New(self, self.EFF_SweepMask_Inst_4) },
		{ "PreViewIconPath", UIBinderSetBrushFromAssetPath.New(self, self.icon_Pre) },
		{ "CurSelect", UIBinderValueChangedCallback.New(self, nil, self.OnSlotSelectChange) },
		{ "lstMagicsparInlayStatusItemVM", UIBinderUpdateBindableList.New(self, self.AdapterSlotTableView) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.TableView_Magicspar, false) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.InlayPanel, false) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.TableView_Slot, true, true) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Btn_BackAttribute, false) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Btn_Inlay, true) },
		{ "bSelectNomal", UIBinderSetIsVisible.New(self, self.Btn_NormalInlay, false) },
		{ "bSelectNomal", UIBinderSetIsVisible.New(self, self.Btn_BanInlay, true) },
		{ "lstMagicsparInlayRecomItemVM", UIBinderUpdateBindableList.New(self, self.AdapterItemTableView) },
		--{ "bMagicsparItemEmpty", UIBinderSetIsVisible.New(self, self.SoltEmptyTips) },
		{ "CurRatio", UIBinderSetTextFormat.New(self, self.RichText_Rate, "%d%%") },
		{ "bListSelectUse", UIBinderSetIsVisible.New(self, self.Btn_Remove, false) },
		{ "bListSelectUse", UIBinderSetIsVisible.New(self, self.InlayPanel1, true) },
		{ "bRateUse", UIBinderSetIsVisible.New(self, self.RichText_SuccessRate, false) },
		{ "bRateUse", UIBinderSetIsVisible.New(self, self.RichText_Rate, false) },
		{ "bRateUse", UIBinderSetIsVisible.New(self, self.FImg_RateBkg, false) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.Btn_ClosePopup, true) },
		{ "bSelect", UIBinderSetIsVisible.New(self, self.ToogleGroupInlay, false) },
		{ "bShowMagicValue", UIBinderSetIsVisible.New(self, self.InforBtnNew, nil, true)},
		{ "bShowMagicValue", UIBinderSetIsVisible.New(self, self.FVerticalBox_63, false) },
		{ "bShowMagicValue", UIBinderSetIsVisible.New(self, self.FImage_142, false) },
		--{ "bShowInform", UIBinderSetIsVisible.New(self, self.PanelTips, false) },
		{ "bShowInform", UIBinderSetIsVisible.New(self, self.BtnTipsBG, nil, true) },
		{ "bShowExceed", UIBinderSetIsVisible.New(self, self.BtnExceedTipsBG, nil, true) },

		{ "BeliefNumText", UIBinderSetText.New(self, self.Text_BeliefNum)},
		{ "AttackNumText", UIBinderSetText.New(self, self.Text_AttackNum)},
		{ "HasteNumText", UIBinderSetText.New(self, self.Text_HasteNum)},
		{ "CritNumText", UIBinderSetText.New(self, self.Text_CritNum)},
		{ "bWarningBelief", UIBinderSetIsVisible.New(self, self.BtnExceed01, nil, true) },
		{ "bWarningAttack", UIBinderSetIsVisible.New(self, self.BtnExceed02, nil, true) },
		{ "bWarningHaste", UIBinderSetIsVisible.New(self, self.BtnExceed03, nil, true) },
		{ "bWarningCrit", UIBinderSetIsVisible.New(self, self.BtnExceed04, nil, true) },
		{ "ExceedText", UIBinderSetText.New(self, self.TextExceed)},
		-- 倒计时button
		{ "RemoveButtonText", UIBinderSetText.New(self, self.Btn_Remove)},
		{ "StartButtonText", UIBinderSetText.New(self, self.Btn_Inlay)},
		{ "NormalButtonText", UIBinderSetText.New(self, self.Btn_NormalInlay)},
		{ "BanButtonText", UIBinderSetText.New(self, self.Btn_BanInlay)},

		-- 获取途径
		{ "bMagicsparItemEmpty", UIBinderSetIsVisible.New(self, self.MagicsparTips, false) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

-- 关闭商店
function MagicsparInlayMainPanelView:MagicsparCloseShop()
	if self.ViewModel == nil then
		_G.FLOG_WARNING("MagicsparCloseShop ViewModel == nil")
		return
	end
	self:UpdateUI()
	if self.ViewModel and self.ViewModel.bSelect then
		self:UpdateSelectedSlot()
	end
	self.ViewModel.bMagicsparItemEmpty = self.ViewModel.bMagicsparItemEmpty and self.ViewModel.bSelect
end

-- 切装备后数据更新
function MagicsparInlayMainPanelView:OnMagicsparSwitchEquip(Params)
	if self.Params == nil or Params == nil or self.ViewModel == nil then
		_G.FLOG_WARNING("OnMagicsparSwitchEquip Params == nil")
		return
	end
	self.Params.GID = Params.GID
	self.ViewModel.bListSelectUse = false
	self:UpdateUI()
	if self.RenderActor ~= nil then
		self.RenderActor:SetEquipIcon(self.ViewModel.EquipmentIconPath)
	end
	if self.ViewModel and self.ViewModel.bSelect then
		self:UpdateSelectedSlot()
	end
	self.ViewModel.bMagicsparItemEmpty = self.ViewModel.bMagicsparItemEmpty and self.ViewModel.bSelect
end

function MagicsparInlayMainPanelView:UpdateUI()
	if self.Params == nil then
		_G.FLOG_ERROR("self.Params == nil")
		return
	end
	self.Tag = self.Params.Tag
	local Item, Part = EquipmentMgr:GetItemByGID(self.Params.GID)
	if Item == nil then
		_G.FLOG_ERROR("self.Params.GID == nil")
		return
	end
	self.Item = Item
	-- Item里的EquipPart后台数据对饰品没做区分，这里单独处理
    if Part ~= nil then
		self.Item.Attr.Equip.Part = Part
	end
	self.ViewModel:InitMagicsparByGID(self.Params.GID, self.Item)
	-- if self.ViewModel.EquipmentCfg then
	-- 	self.MagicsparTips:UpdateTipsData(self.ViewModel.EquipmentCfg.MateID)
	-- end
	self.InforCommItem:InitItem(self.Item.ResID, self.Params.GID)
	self.InforCommItem.EquipSlot.ViewModel.bShowProgress = false
	self.ViewModel.EquipmentIconPath = self.InforCommItem.EquipSlot.ViewModel.IconPath
	self:UpdateInlayAllSlot()
	-- 背包和未装备的单独处理
	if EquipmentMgr:IsEquiped(self.Params.GID) == false then
		self.ViewModel.bShowMagicValue = false
		self.Tag = "Bag"
	else
		self.ViewModel.bShowMagicValue = true
	end
	self.ViewModel:UpdateAllMagicText()
end

function MagicsparInlayMainPanelView:OnMagicsparSelect(Index, ItemData, ItemView)
	local MagicsparInlayRecomItemVM = ItemData
	self.MagicsparItemSelectIndex = Index
	self.SelectGemResID = MagicsparInlayRecomItemVM.ResID
	self.ViewModel.bListSelectUse = MagicsparInlayRecomItemVM.bUse
	self.ViewModel.bRateUse = (not self.ViewModel.bListSelectUse) and self.ViewModel.bSelect
	--self.ViewModel:UpdateMagicText(Index)
	--设置预览
	local bStartPreview = self.ViewModel.bMagicsparItemEmpty == false and
	                      self.InlayStateList[self.ViewModel.CurSelect] == 0 and
						  self.bAnimationPlaying == false  and
						  self.ViewModel.bSelect == true
	if bStartPreview then
		self:SetPreviewState(self.ViewModel.CurSelect, true)
	end
end

-- 获取鼠标点击事件的屏幕坐标
function MagicsparInlayMainPanelView:OnPreprocessedMouseButtonDown(MouseEvent)
	local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local CurPos = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
	local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
	self.LastMousePos = CurPos*DPIScale
	--_G.FLOG_ERROR("OnTouchStarted")
end

-- 添加预览状态
function MagicsparInlayMainPanelView:SetPreviewState(Index, bPreview)
	-- 去掉预览状态
	if 1 then return end -- 临时处理方法，后续效果可能还需要调整
	local StoneIconPath = nil
	local Opacity = 1.0
	local Displace = 0.0
	local DisSpeed = 0.0
	if bPreview == true then
		-- 设置UMG预览魔晶石图标
		StoneIconPath = self.ViewModel:GetStoneIconPath(self.SelectGemResID)
		Opacity = 0.4
		Displace = 4.0
		DisSpeed = 0.5
	else
		if self.InlayIconPathList == nil then return end
		StoneIconPath = self.InlayIconPathList[Index]
	end
	-- 设置魔晶石插槽模型贴图
	if self.RenderActor ~= nil and StoneIconPath ~= nil then
		self.RenderActor:SetSlotIcon(Index, StoneIconPath, Opacity, Displace, DisSpeed)
	end
end

function MagicsparInlayMainPanelView:OnInlayClick()
	--local function OnSequenceFinished()
		--self.Common_Render2D_UIBP:PlayActorSequenceByTime(4.0, 8.0, 0.5, true, nil)
	--end
	--self:OnInlaySlotClick(1)
	self:InitSelectedSlot()
	--self.ViewModel:UpdateMagicText(self.ViewModel.CurSelect)

	--self:PlayActorSequenceByTime(3.0, 4.0, 1.6, false, false, self:SetEffectToSceen())
	--播放音效
	self:SetMagicAudioState(2, true)
	local function AudioCallFunction()
		self:SetMagicAudioState(2, false)
	end
    -- 进入过渡动画
	--self.RenderActor:SetInlayStatusChangeAnimation(true, 1)
	self:PlayActorSequenceByTime(1, 1.0, 2.0, 1.0, false, false, AudioCallFunction)
	self:PlayActorAnimRotate(false, 1)
	-- 间隔一段时间
	--self.DelayTimerID = _G.TimerMgr:AddTimer(self, self.SetEffectToSceen, 0.7, 1.0, 1)
end

function MagicsparInlayMainPanelView:InitSelectedSlot()
	-- 初始选中状态
	self.ViewModel.bSelect = true
	self.ViewModel.CurSelect = 1
	self.LastSelectedSlot = 1
	self.LastEndTime = self.RotateStartTime
	self:UpdateSelectedSlot()
end

function MagicsparInlayMainPanelView:UpdateSelectedSlot()
	self:OnInlaySlotClick(self.ViewModel.CurSelect)
	self:UpdateTagSlot(self.ViewModel.CurSelect)
	self:SetSlotSelect(self.ViewModel.CurSelect, true)
end

function MagicsparInlayMainPanelView:OnNormalInlayClick()
	-- 旋转状态无法生效
	if self.bAnimationPlaying == true then return end
	-- 普通镶嵌
	if self.ViewModel.bMagicsparItemEmpty == true then
		MsgTipsUtil.ShowTips(_G.LSTR(1060006)) --"没有可镶嵌的魔晶石"
		return
	end
	if self.Item == nil then return end
    local GemInfo = self.Item.Attr.Equip.GemInfo.CarryList
	local ResID = GemInfo[self.ViewModel.CurSelect]
	if ResID ~= nil and ResID > 0 then
		self.bNormalReplace = true
	else
		self.bNormalReplace = false
	end
	EquipmentMgr:SendEquipInlay(self.SelectGemResID, self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.ViewModel.EquipmentInUse)
end

function MagicsparInlayMainPanelView:OnBanInlayClick()
	-- 旋转状态无法生效
	if self.bAnimationPlaying == true then return end
	-- 禁忌镶嵌
	if self.ViewModel.bMagicsparItemEmpty == true then
		MsgTipsUtil.ShowTips(_G.LSTR(1060006))--"没有可镶嵌的魔晶石"
		return
	end
	if self.Item == nil then return end
    local GemInfo = self.Item.Attr.Equip.GemInfo.CarryList
	local ResID = GemInfo[self.ViewModel.CurSelect]
	if ResID ~= nil and ResID > 0 then
		self.ShowTipsTag = 1
		--local Title = nil
		--MsgBoxUtil.ShowMsgBoxTwoOp(self, Title,
		--self.OnTipsSure)
		local Content = _G.LSTR(1060009) --"是否确认禁忌镶嵌魔晶石？\n会自动卸下当前魔晶石，\n卸下后，重新镶嵌魔晶石有一定成功率"--, self.ViewModel.CurRatio
		UIViewMgr:ShowView(UIViewID.MagicsparInlayTips, {self, self.OnTipsSure, Content})
	else
		EquipmentMgr:SendEquipInlay(self.SelectGemResID, self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.ViewModel.EquipmentInUse)
	end
end

function MagicsparInlayMainPanelView:OnTipsSure()
	if (self.ShowTipsTag == 1) then
		EquipmentMgr:SendEquipInlay(self.SelectGemResID, self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.ViewModel.EquipmentInUse)
	elseif (self.ShowTipsTag == 2) then
		EquipmentMgr:SendEquipUnInlay(self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.Tag)
	end
end

function MagicsparInlayMainPanelView:OnRemoveClick()
	-- 旋转状态无法生效
	if self.bAnimationPlaying == true then return end
	if self.ViewModel.MagicsparInlayCfg.Hole[self.ViewModel.CurSelect].Type == ProtoCommon.hole_type.HOLE_TYPE_NORMAL then
		EquipmentMgr:SendEquipUnInlay(self.Params.GID, self.ViewModel.EquipmentPart, self.ViewModel.CurSelect, self.Tag)
	else
		self.ShowTipsTag = 2
		local Title = _G.LSTR(1060008)--"卸下魔晶石"
		local Content = _G.LSTR(1060010)--"确认卸下禁忌魔晶石吗？\n重新镶嵌有几率失败"
		UIViewMgr:ShowView(UIViewID.MagicsparInlayTips, {self, self.OnTipsSure, Content, Title})
	end
end

function MagicsparInlayMainPanelView:OnSelectBackClick()
	-- 应策划要求，先回到初始槽位，再播过场动画
	-- 再应策划要求，取消过渡逻辑
	--local Index = self.ViewModel.CurSelect
	--local function AnimCallBack()
		--播放音效
	    self:SetMagicAudioState(2, true)
	    local function AudioCallFunction()
			self:SetMagicAudioState(2, false)
	    end
		-- 倒播对应的动画
		--self.RenderActor:SetInlayStatusChangeAnimation(false, 1)
		self:PlayActorSequenceByTime(1, 3.0, 4.0, 1.0, false, false, AudioCallFunction)
		self:PlayActorAnimRotate(true, 1)
	--end
	--if Index == 3 then
		--AnimCallBack()
	--else
		--self:PlayRotationAnimation(3, AnimCallBack)
	--end
	-- 回到初始状态
	self:BackState()
end

function MagicsparInlayMainPanelView:BackState()
	if self.ViewModel.CurSelect == nil then return end
	self:SetPreviewState(self.ViewModel.CurSelect, false)
	local TagView = self["MagicsparInlayTagSlot_UIBP_"..(self.ViewModel.CurSelect-1)]
	TagView:SetSelectState(false)
	self:SetSlotSelect(self.ViewModel.CurSelect, false)
	self.ViewModel:UpSelectSlot()
	self.LastSelectedSlot = 1
	self.LastEndTime = self.RotateStartTime
	self.ViewModel.bRateUse = false
	self.ViewModel.CurSelect = 1
	--self.ViewModel:UpdateMagicText(self.ViewModel.CurSelect)
	self:ClearTimer()
end

-- 选中魔晶石槽位发生变化
function MagicsparInlayMainPanelView:OnSlotSelectChange(NewValue, OldValue)
	-- TODO 把魔晶石从NewValue逆时针转动到椭圆中心
	--if NewValue ~= nil and NewValue ~= self.AnimToIndex then
		--self:MoveMagicspar(NewValue)
	--end
	if self.ViewModel.bSelect == false then return end
	self:SetSlotSelect(NewValue, true)
	self:SetSlotSelect(OldValue, false)
	self:OnInlaySlotClick(NewValue)
	-- 更新TagSlot
	self:UpdateTagSlot(NewValue)
	self:UpdateTagSlot(OldValue)
	--关闭预览
	-- if self.InlayStateList ~= nil and self.InlayStateList[self.ViewModel.CurSelect] == 1 then
	-- 	self:SetPreviewState(OldValue, false)
	-- else
	-- 	self:SetPreviewState(OldValue, false)
	-- end
	-- 处理空列表
	if self.ViewModel.bMagicsparItemEmpty then
		self.ViewModel.bListSelectUse = false
	end
end

function MagicsparInlayMainPanelView:OnInlaySucc(Params)
	UIViewMgr:HideView(UIViewID.MagicsparSucceedTips, true)
	self:SetEffectToSceen()
	if (Params.GID == self.Params.GID) then
		self.ViewModel.SelectSlotIconPath = self.ViewModel:GetStoneIconPath(self.SelectGemResID)
		local bSucc = Params.ResID ~= nil and Params.ResID > 0
		local Index = self.ViewModel.CurSelect
		if bSucc then
			--self:OnSelectBackClick()
			--self:BackState()
			self.ViewModel:SelectSlot(self.ViewModel.CurSelect)
			self:OnInlaySlotClick(Index)
			-- 播放镶嵌成功的动画
			self:PlayAnimation(self.AnimSuccess)
			--MsgTipsUtil.ShowTips(LSTR(1060004))"镶嵌成功"
			UIViewMgr:ShowView(UIViewID.MagicsparSucceedTips)
			-- 控制按钮保护期
			--self.UpdateTimerID = TimerMgr:AddTimer(self, self.SetButtonText, 0, 1.0, 4, nil, "MagicsparInlayMainPanelView:OnInlaySucc")
			self.UpdateTimerID = self:RegisterTimer(self.SetButtonText, 0, 1.0, 4)
			if self.bNormalReplace then
				MsgTipsUtil.ShowTips(LSTR(1060007))--"成功卸下魔晶石"
				self.bNormalReplace = false
			end
		else
			--self:OnInlaySlotClick(self.ViewModel.CurSelect, true)
			self:OnInlaySlotClick(Index, true)
			-- 播放镶嵌失败的动画
			self:PlayAnimation(self.AnimLose)
			MsgTipsUtil.ShowTips(LSTR(1060005))--"镶嵌失败，魔晶石消失了"
		end
		self.bTableKeep = true
		self:UpdateUI()
		self.bTableKeep = false
		-- 更新数值面板
		--self.ViewModel:UpdateAllMagicText()
		-- 保持选中
	end
end

function MagicsparInlayMainPanelView:OnUnInlaySucc(Params)
	if (Params.GID == self.Params.GID) then
		MsgTipsUtil.ShowTips(LSTR(1060007))--"成功卸下魔晶石"
		self:UpdateUI()
		--self:OnInlaySlotClick(self.ViewModel.CurSelect)
		-- 更新数值面板
		--self.ViewModel:UpdateAllMagicText()
		--音效
		AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_ORIGINAL/Gem/Play_UI_Gem_unload.Play_UI_Gem_unload")
	end
end

-- 按钮状态
function MagicsparInlayMainPanelView:OperateButton(bEnable)
	self.Btn_Remove:SetIsEnabled(bEnable)
	self.Btn_NormalInlay:SetIsEnabled(bEnable)
	self.Btn_BanInlay:SetIsEnabled(bEnable)
end

-- 按钮倒计时
function MagicsparInlayMainPanelView:SetButtonText()
	if self.TriggerCount == 0 then
		self:ClearTimer()
	else
		self.Btn_Remove:SetIsEnabled(false)
		self.ViewModel.RemoveButtonText =  string.format(_G.LSTR(1060015), self.TriggerCount) --"卸下（%ds）"
		self.TriggerCount = self.TriggerCount -1
	end
end

function MagicsparInlayMainPanelView:ClearTimer()
	-- 清除
	self.ViewModel.RemoveButtonText =  _G.LSTR(1060016) --"卸下"
	self.Btn_Remove:SetIsEnabled(true)
	self.TriggerCount = 3
	if self.UpdateTimerID ~= nil then
		--TimerMgr:CancelTimer(self.UpdateTimerID)
		self:UnRegisterTimer(self.UpdateTimerID)
		self.UpdateTimerID = nil
	end
end

function MagicsparInlayMainPanelView:SetSlotSelect(Index, bSelect)
	if Index == nil then return end
	local InlaySlotItem = self.InforCommItem["InlaySlotItem"..Index]
	InlaySlotItem.ViewModel.bSelect = bSelect
	--local SlotView = self["SlotItem0"..Index]
	--SlotView.ViewModel.bSelect = bSelect
end

function MagicsparInlayMainPanelView:UpdateInlayAllSlot()
	local lst = self.InforCommItem.ViewModel.Item.Attr.Equip.GemInfo.CarryList
	local iNomalCount = self.InforCommItem.ViewModel.MagicsparInlayCfg.NomalCount
	local iBanCount = self.InforCommItem.ViewModel.MagicsparInlayCfg.BanCount
	self.InlayStateList = {}
	self.InlayIconPathList = {}
	for i = 1, iNomalCount do
		self:UpdateInlaySlot(i, lst[i], true)
	end
	for i = 1, iBanCount do
		self:UpdateInlaySlot(iNomalCount + i, lst[iNomalCount + i], false)
	end
end


function MagicsparInlayMainPanelView:UpdateInlaySlot(Index, ResID, bNomal)
	--local SlotView = self["SlotItem0"..Index]
	--SlotView:InitSlot(ResID, Index, bNomal, function ()
		--self:OnInlaySlotClick(Index)
	--end)
	-- 初始化TagSlot状态
	local TagView = self["MagicsparInlayTagSlot_UIBP_"..(Index-1)]
	TagView:SetIcon(bNomal)
	--self:UpdateTagSlot(Index)
	-- 设置魔晶石图标
	self:SetMagicSlotTexture(Index, ResID)
	-- 设置选中插槽
	self:OnInlaySlotClick(Index, self.bTableKeep)
end

function MagicsparInlayMainPanelView:SetMagicSlotTexture(Index, ResID)
	if self.RenderActor == nil then return end
	local StoneIconPath = self.ViewModel:GetStoneIconPath(ResID)
	self.InlayStateList[Index] = 1
	local Opacity = 1.0
	if StoneIconPath == nil then
		StoneIconPath = "Texture2D'/Game/UI/Texture/Magicspar/UI_Magicspar_Slot_Img_Inlay.UI_Magicspar_Slot_Img_Inlay'"
		self.InlayStateList[Index] = 0
		Opacity = 0.0
		-- 加号显示特效
		self.RenderActor:SetSlotIcon(Index, StoneIconPath, Opacity, 0.0, 0.0, false)
	else
		-- 隐藏加号特效
		self.RenderActor:SetSlotIcon(Index, StoneIconPath, Opacity, 0.0, 0.0, true)
	end
	self.InlayIconPathList[Index] = StoneIconPath
end

function MagicsparInlayMainPanelView:UpdateTagSlot(Index)
	if Index == nil then return end
	local TagView = self["MagicsparInlayTagSlot_UIBP_"..(Index-1)]
	if Index == self.ViewModel.CurSelect then
		TagView:SetSelectState(true)
	else
		TagView:SetSelectState(false)
	end
end

function MagicsparInlayMainPanelView:OnInlaySlotClick(Index, bKeep)
	-- TODO
	--if self.bAnimation == true and Index ~= self.ViewModel.CurSelect then
	if Index ~= self.ViewModel.CurSelect then
		return
	end

	self.ViewModel:SelectSlot(Index)
	--if self.ViewModel.bSelect == false then
		--第一次选中
		--self:SetMagicsparOvalPosOrigin(Index)
	--end
	local CurIndex = self.MagicsparItemSelectIndex
	local InlayRecomItemVM = self.ViewModel.lstMagicsparInlayRecomItemVM
	if InlayRecomItemVM ~= nil then
		for ItemIndex, ItemVM in ipairs(InlayRecomItemVM) do
			if ItemVM.ResID == self.SelectGemResID then
				CurIndex = ItemIndex
			end
		end
	end

	if self.ViewModel.bMagicsparItemEmpty == false then
		--self.AdapterItemTableView:SetSelectedIndex(1)
		if bKeep == true and CurIndex > 1 and InlayRecomItemVM[CurIndex] ~= nil then
			self.AdapterItemTableView:SetSelectedIndex(CurIndex)
		else
			self.AdapterItemTableView:SetSelectedIndex(1)
		end
	else
		self.AdapterItemTableView:ScrollToTop()
	end
	--if bKeep == true then
		--if CurIndex <= #self.ViewModel.lstMagicsparInlayRecomItemVM then
			--self.AdapterItemTableView:SetSelectedIndex(CurIndex)
		--else
			--self.AdapterItemTableView:SetSelectedIndex(#self.ViewModel.lstMagicsparInlayRecomItemVM)
		--end
	--else
		--self.AdapterItemTableView:ScrollToTop()
	--end
	if self.ViewModel.EquipmentCfg then
		self.MagicsparTips:UpdateTipsData(self.ViewModel.EquipmentCfg.MateID, self.ViewModel.bSelectNomal)
	end
end

-- drop
function MagicsparInlayMainPanelView:SetMagicsparOvalPosOrigin(Index)
	self.CurOvalIndex = 3
	self.AnimToIndex = 3
	self:MoveMagicspar(Index)


	--self:SetMagicsparOvalPosByList(self.AnimCurAngle)
	self.bAnimation = false
	self.CurOvalIndex = Index
end
-- drop
function MagicsparInlayMainPanelView:MoveMagicspar(ToIndex)
	-- TODO设置魔晶石旋转
end

function MagicsparInlayMainPanelView:OnInforBtnClick()
	self.ViewModel.bShowInform = not self.ViewModel.bShowInform
	if self.ViewModel.bShowInform then
		self:PlayAnimation(self.AnimTipsIn)
	end
end

function MagicsparInlayMainPanelView:OnBtnTipsBGClick()
	self.ViewModel.bShowInform = false
	self.ViewModel.bShowExceed = false
end

function MagicsparInlayMainPanelView:OnBtnExceed(AttrIndex)
	self.ViewModel.bShowExceed = true
	self.ViewModel:UpdateExceedInform(AttrIndex)
	self:PlayAnimation(self.AnimTipsIn)
end

-- 加载魔晶石镶嵌三维模型
function MagicsparInlayMainPanelView:LoadMagicModel()
	--local RenderActorPath = "Blueprint'/Game/UMG/3DUI/MJS/BP/BP_MJS_MAIN.BP_MJS_MAIN_C'"
	local CallBack = function(bSucc)
        if (bSucc) then
			self.Common_Render2D_UIBP:ChangeUIState(false)
			self.Common_Render2D_UIBP:SetModelLocation(0, 0, 0)
			self.Common_Render2D_UIBP:SwitchOtherLights(false)
            --self:SetModelSpringArmToDefault()
			self.RenderActor = self.Common_Render2D_UIBP.RenderActor;
			self:SetActorCameraFOV()
			-- 模型加载后的动画和图标更新
			self:UpdateUI()
			if self.RenderActor ~= nil then
				self.RenderActor:SetEquipIcon(self.ViewModel.EquipmentIconPath)
				self:PlayActorSequenceByTime(0, 0.0, 5.0, 1.6, false, false, nil)
			end
			-- 一些状态更新
			self.ViewModel.bSelect = false
			self.ViewModel.bListSelectUse = false
			self.ViewModel.bMagicsparItemEmpty = self.ViewModel.bMagicsparItemEmpty and self.ViewModel.bSelect
        end
    end
    self.Common_Render2D_UIBP:CreateSimpleRenderActor(MagicsparDefine.RenderActorPath, false, CallBack)
end

-- 处理点击选中事件
function MagicsparInlayMainPanelView:OnSingleClick()
	-- 添加空白处关闭信息tips
	self.ViewModel.bShowInform = false
	self.ViewModel.bShowExceed = false
	--if self.ViewModel.bSelect == false then return end
	-- 通过射线进行查询选中的魔晶石插槽
	local SelectedIndex = self:GetSelectedMagicIndex()
	--_G.FLOG_ERROR("MAGGIC Idex (%d,%d)", self.LastSelectedSlot, SelectedIndex)
	if SelectedIndex > 5 then
		return
	end
	if self.ViewModel.bSelect == true then
		--self:PlayRotationAnimation(SelectedIndex, nil, true)
		self:PlayActorAnimRotate(false, SelectedIndex)
		self.LastSelectedSlot = SelectedIndex
		self.ViewModel.CurSelect = SelectedIndex
		--print("aaa   self.ViewModel.bSelect=", self.ViewModel.bSelect)

	else
		-- 过场动画和旋转动画一起
		if SelectedIndex == 1 then
			self:OnInlayClick()
		else
			-- 播放音效
			self:SetMagicAudioState(2, true)
			self.bPlayRotation = false
				--self:PlayRotationAnimation(SelectedIndex, nil, false)
			local function CallBack()
				-- 过场音效停止
				self:SetMagicAudioState(2, false)
				self:PlayActorAnimRotate(false, SelectedIndex)
				--print("aaa   self.ViewModel.bSelect=", self.ViewModel.bSelect)

				-- 判断下次开始时间
				--local GapTime = (self.RotateEndTime - self.RotateStartTime) / 5.0
				--self.LastEndTime = self.RotateStartTime + GapTime*(SelectedIndex)
			end
			-- 过渡动画
			--self.RenderActor:SetInlayStatusChangeAnimation(true, SelectedIndex)
			self:PlayActorSequenceByTime(1, 1.0, 2.0, 1.0, false, false, CallBack)
			self:PlayActorAnimRotate(false, SelectedIndex)
			self.ViewModel.bSelect = true
			self.LastSelectedSlot = SelectedIndex
			self.ViewModel.CurSelect = SelectedIndex
			self.bPlayRotation = false
			--self.ViewModel.bSelect = true
			--self.LastSelectedSlot = SelectedIndex
			--self.ViewModel.CurSelect = SelectedIndex
		end
	end
end
-- 按照顺时针控制旋转动画播放
function MagicsparInlayMainPanelView:PlayRotationAnimationPositive(SelectedIndex, AdditionalCallback, bPlay)
	local GapTime = (self.RotateEndTime - self.RotateStartTime) / 5.0
	local PlayTime = 0
	if  SelectedIndex - self.LastSelectedSlot< 0 then
		PlayTime = (SelectedIndex - self.LastSelectedSlot + 5)*GapTime
	else
		PlayTime = (SelectedIndex - self.LastSelectedSlot)*GapTime
	end
	if PlayTime < 0.1 then
		return
	end
	-- 从上次停止处开始播
	local PlayRate = 1.0
	local StartRate = 1.4
	local EndRate = 0.3
	self.bAnimationPlaying = true
	self.PlayingTime = PlayTime
	--播放音效
	self:SetMagicAudioState(1, true)
	local function PreviewCallback()
		self.bAnimationPlaying = false
		if self.InlayStateList ~= nil and self.InlayStateList[self.ViewModel.CurSelect] == 0 and self.ViewModel.bMagicsparItemEmpty == false then
			self:SetPreviewState(self.ViewModel.CurSelect, true)
		end
		self:SetMagicAudioState(1, false)
		-- 附加的回调
		if AdditionalCallback ~= nil then
			AdditionalCallback()
		end
		-- 按钮恢复
		self:OperateButton(true)
	end
	-- 按钮置灰
	if self.LastSelectedSlot ~= SelectedIndex then
		self:OperateButton(false)
	end
	if self.RotateEndTime - self.LastEndTime < 0.1 then
		if bPlay then
			self:PlayActorSequenceByTime(2, self.RotateStartTime, self.RotateStartTime + PlayTime, PlayRate, false, false, PreviewCallback)
			-- 动态控制播放速率
			--self:SetSequenceRate(self.RotateStartTime, self.RotateStartTime + PlayTime, StartRate, EndRate)
		end
		self.LastEndTime = self.RotateStartTime + PlayTime
	elseif self.LastEndTime + PlayTime > self.RotateEndTime then
		-- 循环播放片段
		local NowEndTime = self.RotateStartTime + self.LastEndTime + PlayTime - self.RotateEndTime
		local InterRate = StartRate + (EndRate - StartRate) * (self.RotateEndTime - self.LastEndTime) / PlayTime
		local function OnSequenceFinished()
			self:PlayActorSequenceByTime(2, self.RotateStartTime, NowEndTime, PlayRate, false, false, PreviewCallback)
			-- 动态控制播放速率
		    --self:SetSequenceRate(self.RotateStartTime, NowEndTime, InterRate, EndRate)
		end
		if bPlay then
			self:PlayActorSequenceByTime(2, self.LastEndTime, self.RotateEndTime, PlayRate, false, false, OnSequenceFinished)
			-- 动态控制播放速率
			self:SetSequenceRate(self.LastEndTime, self.RotateEndTime, StartRate, InterRate)
		end
		self.LastEndTime = NowEndTime
	else
		if bPlay then
			-- 因为浮点导致的丢帧问题+0.001，建议控制帧率使用帧数而非时间
			self:PlayActorSequenceByTime(2, self.LastEndTime + 0.001, self.LastEndTime + PlayTime, PlayRate, false, false, PreviewCallback)
			-- 动态控制播放速率
			--self:SetSequenceRate(self.LastEndTime, self.LastEndTime + PlayTime, StartRate, EndRate)
		end
		self.LastEndTime = self.LastEndTime + PlayTime
	end
	self.LastSelectedSlot = SelectedIndex
	-- 设置选中序号
	self.ViewModel.CurSelect = SelectedIndex
	--if SelectedIndex < 3 then
		--self.ViewModel.CurSelect = SelectedIndex + 3
	--else
		--self.ViewModel.CurSelect = SelectedIndex - 2
	--end
end

-- 逆时针控制旋转动画播放
function MagicsparInlayMainPanelView:PlayRotationAnimationReverse(SelectedIndex, AdditionalCallback, bPlay)
	local GapTime = (self.RotateEndTime - self.RotateStartTime) / 5.0
	local PlayTime = 0
	if  SelectedIndex - self.LastSelectedSlot > 0 then
		PlayTime = (SelectedIndex - self.LastSelectedSlot - 5)*GapTime
	else
		PlayTime = (SelectedIndex - self.LastSelectedSlot)*GapTime
	end
	if math.abs(PlayTime) < 0.1 then
		return
	end
	-- 从上次停止处开始播
	local PlayRate = 1.0
	local StartRate = 1.4
	local EndRate = 0.3
	self.bAnimationPlaying = true
	self.PlayingTime = PlayTime
	--播放音效
	self:SetMagicAudioState(1, true)
	local function PreviewCallback()
		self.bAnimationPlaying = false
		if self.InlayStateList ~= nil and self.InlayStateList[self.ViewModel.CurSelect] == 0 and self.ViewModel.bMagicsparItemEmpty == false then
			self:SetPreviewState(self.ViewModel.CurSelect, true)
		end
		self:SetMagicAudioState(1, false)
		-- 附加的回调
		if AdditionalCallback ~= nil then
			AdditionalCallback()
			-- 按钮恢复
			self:OperateButton(true)
		end
	end
	-- 按钮置灰
	if self.LastSelectedSlot ~= SelectedIndex then
		self:OperateButton(false)
	end
	if math.abs(self.LastEndTime - self.RotateStartTime) < 0.1 then
		if bPlay then
			self:PlayActorSequenceByTime(2, self.RotateEndTime + PlayTime + 0.001, self.RotateEndTime, PlayRate, true, false, PreviewCallback)
			-- 动态控制播放速率
			--self:SetSequenceRate(self.RotateStartTime, self.RotateStartTime - PlayTime, StartRate, EndRate)
		end
		self.LastEndTime = self.RotateEndTime + PlayTime
	elseif self.LastEndTime + PlayTime < self.RotateStartTime then
		-- 循环播放片段
		local NowEndTime = self.RotateEndTime -(self.RotateStartTime - (self.LastEndTime + PlayTime))
		local InterRate = StartRate + (EndRate - StartRate) * (self.RotateEndTime - self.LastEndTime) / PlayTime*(-1)
		local function OnSequenceFinished()
			self:PlayActorSequenceByTime(2, NowEndTime + 0.001, self.RotateEndTime, PlayRate, true, false, PreviewCallback)
			-- 动态控制播放速率
		    --self:SetSequenceRate(self.RotateStartTime, NowEndTime, InterRate, EndRate)
		end
		if bPlay then
			self:PlayActorSequenceByTime(2, self.RotateStartTime, self.LastEndTime, PlayRate, true, false, OnSequenceFinished)
		end
		-- 动态控制播放速率
		--self:SetSequenceRate(self.LastEndTime, self.RotateEndTime, StartRate, InterRate)
		self.LastEndTime = NowEndTime
	else
		if bPlay then
			-- 因为浮点导致的丢帧问题+0.001，建议控制帧率使用帧数而非时间
			self:PlayActorSequenceByTime(2, self.LastEndTime + PlayTime +0.001, self.LastEndTime, PlayRate, true, false, PreviewCallback)
			-- 动态控制播放速率
			--self:SetSequenceRate(self.LastEndTime, self.LastEndTime + PlayTime, StartRate, EndRate)
		end
		self.LastEndTime = self.LastEndTime + PlayTime
	end
	self.LastSelectedSlot = SelectedIndex
	-- 设置选中序号
	self.ViewModel.CurSelect = SelectedIndex
	--if SelectedIndex < 3 then
		--self.ViewModel.CurSelect = SelectedIndex + 3
	--else
		--self.ViewModel.CurSelect = SelectedIndex - 2
	--end
end

-- 就近旋转
function MagicsparInlayMainPanelView:PlayRotationAnimation(SelectedIndex, AdditionalCallback, bPlay)
	local GapNum = SelectedIndex - self.LastSelectedSlot
	if (GapNum < 0 and math.abs(GapNum) < GapNum + 5) or (GapNum > 0 and math.abs(GapNum-5) < GapNum) then
		self:PlayRotationAnimationReverse(SelectedIndex, AdditionalCallback, bPlay)
	else
		self:PlayRotationAnimationPositive(SelectedIndex, AdditionalCallback, bPlay)
	end

end

-- 动效的大小和位置屏幕适配
function MagicsparInlayMainPanelView:SetEffectToSceen()
	--local RenderActor = self.Common_Render2D_UIBP.RenderActor;
	local RenderActor = self.RenderActor;
	if RenderActor == nil then return end
	-- Todo
	local WorldPos = RenderActor:GetSlotWorldPosition(self.ViewModel.CurSelect)
	local ScreenPos = _G.UE.FVector2D(0, 0)
	UIUtil.ProjectWorldLocationToScreen(WorldPos, ScreenPos) -- -_G.UE.FVector(0,0,50000)
	local LocalPosition = _G.UE.FVector2D(0, 0)
    _G.UE.UUIUtil.ScreenToWidgetLocal(self, ScreenPos, LocalPosition, false)
    --_G.UE.UKismetSystemLibrary.DrawDebugLine(FWORLD(), CurLocation, Pos, _G.UE.FLinearColor(1, 1, 1, 1), 0.06, 0.5)
	--LocalPosition = LocalPosition - _G.UE.FVector2D(851.341797, 571.013428)
	--ScreenPos = ScreenPos - _G.UE.FVector2D(851.341797, 571.013428)
	--_G.FLOG_ERROR("MAGGIC (%d,%d)", ScreenPos.x, ScreenPos.y)
	--self.EFF.Slot:SetPosition(ScreenPos/self.DPIScale)
	--local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPos)
	--UIUtil.CanvasSlotSetPosition(self.EFF, ViewportPosition/self.DPIScale)
	LocalPosition.x = LocalPosition.x - 48 -- * 1920 / 2340
	--UIUtil.CanvasSlotSetPosition(self.EFF, LocalPosition)
	self.EFF.Slot:SetPosition(LocalPosition)
end

-- 控制背景音效
-- @Type 1为Audio_01，2为Audio_01和Audio_02
function MagicsparInlayMainPanelView:SetMagicAudioState(Type, bPlay)
	if self.RenderActor == nil then return end
	if bPlay == true then
		self.RenderActor:PlayMagicAudio(Type)
	else
		self.RenderActor:StopMagicAudio(Type)
	end
end

-- 新版控制旋转动画
function MagicsparInlayMainPanelView:PlayActorAnimRotate(bBack, SelectedIndex)
	if self.RenderActor == nil then
        return
    end
	local function FinishedCallback()
		-- 按钮恢复
		self:OperateButton(true)
		self:ClearTimer()
	end
	local SeqPlayer = self.RenderActor:GetSequencePlayer(2)
	if SeqPlayer ~= nil then
		self.RenderActor:PlayAnimRotate(bBack, SelectedIndex)
		-- 按钮置灰
		if self.LastSelectedSlot ~= SelectedIndex then
			self:OperateButton(false)
		end
		SeqPlayer.OnFinished:Add(self.RenderActor, FinishedCallback)
	end
end

-- 控制动画播放时间和顺序
function MagicsparInlayMainPanelView:PlayActorSequenceByTime(SeqIndex, StartTime, EndTime, PlayRate, bReverse, bLoop, FinishedCallback)
    --_G.FLOG_ERROR("MAGGIC (%f, %f)", StartTime, EndTime)
    if self.RenderActor == nil or math.abs(EndTime - StartTime) < 0.1 then
        return
    end
    local ActorComponent = self.RenderActor:GetComponentByClass(_G.UE.UActorSequenceComponent)
    if ActorComponent ~= nil then
        if self.ActorSeqPlayer ~= nil then
			self.ActorSeqPlayer:Stop()
		end
		-- SeqIndex: 0为原来的ActorSequence，1为ActorSequenceInlay，2为ActorSequenceRotate
        local SeqPlayer = self.RenderActor:GetSequencePlayer(SeqIndex)
        self.ActorSeqPlayer = SeqPlayer
		if SeqPlayer == nil then
			FLOG_ERROR("SequencePlayer is nil")
			return
		end
        --SeqPlayer:Stop()
        SeqPlayer:SetPlayRate(PlayRate)
        SeqPlayer:SetPlaybackRange(StartTime, EndTime);
        --SeqPlayer:SetTimeRange(StartTime, EndTime - StartTime);
		SeqPlayer.OnFinished:Clear()
        if FinishedCallback ~= nil then
            SeqPlayer.OnFinished:Add(self.RenderActor, FinishedCallback)
        --else
            --SeqPlayer.OnFinished:Clear()
        end
        if bLoop == true then
            SeqPlayer:PlayLooping(-1)
        elseif bReverse  == true then
            SeqPlayer:PlayReverse()
        else
            SeqPlayer:Play()
        end
    end
end

--动态改变播放速率
function MagicsparInlayMainPanelView:SetSequenceRate(InStartTime, nEndTime, InStartRate, InEndRate)
    if self.RenderActor == nil then
        return
    end
    local SeqPlayer = self.ActorSeqPlayer
    if SeqPlayer ~= nil then
        self.RenderActor:SetSequenceChangedRate(SeqPlayer, InStartTime, nEndTime, InStartRate, InEndRate)
    end
end

function MagicsparInlayMainPanelView:GetSelectedMagicIndex()
    -- 获取选中的魔晶石
    local MagicIndex = 9999
    if self.RenderActor ~= nil then
        MagicIndex = self.RenderActor:GetQueryMeshIndex(self.LastMousePos)
    end
    return MagicIndex
end

function MagicsparInlayMainPanelView:SetActorCameraFOV()
    if self.RenderActor == nil then
        return
    end
    local FOV = self.RenderActor:GetFOV()
    self.Common_Render2D_UIBP:SetCameraFOV(FOV)
end

return MagicsparInlayMainPanelView
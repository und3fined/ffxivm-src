---
--- Author: Administrator
--- DateTime: 2023-11-30 14:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local BuddySurfaceVM = require("Game/Buddy/VM/BuddySurfaceVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetColorAndOpacity = require("Binder/UIBinderSetColorAndOpacity")
local ChocoboDyeStuffCfg = require("TableCfg/ChocoboDyeStuffCfg")
local BagMgr = require("Game/Bag/BagMgr")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ChocoboModelShowCfg = require("TableCfg/ChocoboModelShowCfg")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ChocoboArmorPos = ProtoCS.ChocoboArmorPos
local BuddyDefine = require("Game/Buddy/BuddyDefine")

local UIViewMgr
local UIViewID
local EquipmentMgr
local BuddyMgr
local ChocoboShowModelMgr
local LSTR

---@class BuddySurfaceArmorPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AmountSlider CommAmountSliderView
---@field BtnArchive UFButton
---@field BtnBack CommBackBtnView
---@field BtnClose CommonCloseBtnView
---@field BtnHasten CommBtnLView
---@field BtnHelp02 CommInforBtnView
---@field BtnInvalidTips CommInforBtnView
---@field BtnMessageBoard UFButton
---@field BtnStain CommBtnLView
---@field BtnStain02 CommBtnLView
---@field BtnUnLoad CommBtnLView
---@field BtnWear CommBtnLView
---@field ButtonGoGet UFButton
---@field ChocoboAvatarItem_UIBP ChocoboAvatarItemView
---@field CommGesture_UIBP CommGestureView
---@field CommVerIconTabs CommVerIconTabsView
---@field CommonTitle CommonTitleView
---@field HorizontalAvatar UFHorizontalBox
---@field HorizontalColor2 UFHorizontalBox
---@field ImageRole UFImage
---@field ImgArrow01 UFImage
---@field ImgArrow02 UFImage
---@field ImgColor UFImage
---@field ImgColor01 UFImage
---@field ImgColor02 UFImage
---@field ImgColor03 UFImage
---@field ImgColor04 UFImage
---@field ImgColor05 UFImage
---@field ImgColor06 UFImage
---@field ImgColor2 UFImage
---@field ImgColorType01 UFImage
---@field ImgColorType02 UFImage
---@field ImgColorType03 UFImage
---@field ImgLine01 UFImage
---@field Panel01 UFCanvasPanel
---@field Panel02 UFCanvasPanel
---@field Panel03 UFCanvasPanel
---@field PanelArrow UFCanvasPanel
---@field PanelColorChange UFCanvasPanel
---@field PanelColorContent UFCanvasPanel
---@field PanelGetway UFCanvasPanel
---@field PanelHasten UFCanvasPanel
---@field PanelItem UFCanvasPanel
---@field PanelItem02 UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field TableView01 UTableView
---@field TableView02 UTableView
---@field TableView03 UTableView
---@field TableViewColorList UTableView
---@field TableViewRecommend UTableView
---@field TableViewRecommend_1 UTableView
---@field TableViewTab UTableView
---@field TextAbout UFTextBlock
---@field TextAdd01 UFTextBlock
---@field TextAdd02 UFTextBlock
---@field TextAdd03 UFTextBlock
---@field TextAmount UFTextBlock
---@field TextChocoboName UFTextBlock
---@field TextColorName UFTextBlock
---@field TextColorName02 UFTextBlock
---@field TextColorNumber01 UFTextBlock
---@field TextColorNumber02 UFTextBlock
---@field TextColorNumber03 UFTextBlock
---@field TextColorNumber04 UFTextBlock
---@field TextColorNumber05 UFTextBlock
---@field TextColorNumber06 UFTextBlock
---@field TextColorType UFTextBlock
---@field TextGoGet UFTextBlock
---@field TextLock UFTextBlock
---@field TextName UFTextBlock
---@field TextRecommend UFTextBlock
---@field TextRecommend_1 UFTextBlock
---@field TextRest UFTextBlock
---@field TextTime UFTextBlock
---@field ToggleBtnArmor UToggleButton
---@field ToggleBtnMount UToggleButton
---@field VerticalBtn UFVerticalBox
---@field VerticalColorChange01 UFVerticalBox
---@field VerticalColorChange02 UFVerticalBox
---@field AnimColorChangeArrowLoop UWidgetAnimation
---@field AnimColorChangeIn UWidgetAnimation
---@field AnimColorChangeOut UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceArmorPanelView = LuaClass(UIView, true)

function BuddySurfaceArmorPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AmountSlider = nil
	--self.BtnArchive = nil
	--self.BtnBack = nil
	--self.BtnClose = nil
	--self.BtnHasten = nil
	--self.BtnHelp02 = nil
	--self.BtnInvalidTips = nil
	--self.BtnMessageBoard = nil
	--self.BtnStain = nil
	--self.BtnStain02 = nil
	--self.BtnUnLoad = nil
	--self.BtnWear = nil
	--self.ButtonGoGet = nil
	--self.ChocoboAvatarItem_UIBP = nil
	--self.CommGesture_UIBP = nil
	--self.CommVerIconTabs = nil
	--self.CommonTitle = nil
	--self.HorizontalAvatar = nil
	--self.HorizontalColor2 = nil
	--self.ImageRole = nil
	--self.ImgArrow01 = nil
	--self.ImgArrow02 = nil
	--self.ImgColor = nil
	--self.ImgColor01 = nil
	--self.ImgColor02 = nil
	--self.ImgColor03 = nil
	--self.ImgColor04 = nil
	--self.ImgColor05 = nil
	--self.ImgColor06 = nil
	--self.ImgColor2 = nil
	--self.ImgColorType01 = nil
	--self.ImgColorType02 = nil
	--self.ImgColorType03 = nil
	--self.ImgLine01 = nil
	--self.Panel01 = nil
	--self.Panel02 = nil
	--self.Panel03 = nil
	--self.PanelArrow = nil
	--self.PanelColorChange = nil
	--self.PanelColorContent = nil
	--self.PanelGetway = nil
	--self.PanelHasten = nil
	--self.PanelItem = nil
	--self.PanelItem02 = nil
	--self.PanelRight = nil
	--self.TableView01 = nil
	--self.TableView02 = nil
	--self.TableView03 = nil
	--self.TableViewColorList = nil
	--self.TableViewRecommend = nil
	--self.TableViewRecommend_1 = nil
	--self.TableViewTab = nil
	--self.TextAbout = nil
	--self.TextAdd01 = nil
	--self.TextAdd02 = nil
	--self.TextAdd03 = nil
	--self.TextAmount = nil
	--self.TextChocoboName = nil
	--self.TextColorName = nil
	--self.TextColorName02 = nil
	--self.TextColorNumber01 = nil
	--self.TextColorNumber02 = nil
	--self.TextColorNumber03 = nil
	--self.TextColorNumber04 = nil
	--self.TextColorNumber05 = nil
	--self.TextColorNumber06 = nil
	--self.TextColorType = nil
	--self.TextGoGet = nil
	--self.TextLock = nil
	--self.TextName = nil
	--self.TextRecommend = nil
	--self.TextRecommend_1 = nil
	--self.TextRest = nil
	--self.TextTime = nil
	--self.ToggleBtnArmor = nil
	--self.ToggleBtnMount = nil
	--self.VerticalBtn = nil
	--self.VerticalColorChange01 = nil
	--self.VerticalColorChange02 = nil
	--self.AnimColorChangeArrowLoop = nil
	--self.AnimColorChangeIn = nil
	--self.AnimColorChangeOut = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceArmorPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AmountSlider)
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnHasten)
	self:AddSubView(self.BtnHelp02)
	self:AddSubView(self.BtnInvalidTips)
	self:AddSubView(self.BtnStain)
	self:AddSubView(self.BtnStain02)
	self:AddSubView(self.BtnUnLoad)
	self:AddSubView(self.BtnWear)
	self:AddSubView(self.ChocoboAvatarItem_UIBP)
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.CommVerIconTabs)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceArmorPanelView:OnInit()
	UIViewMgr = _G.UIViewMgr
	UIViewID = _G.UIViewID
	EquipmentMgr = _G.EquipmentMgr
	BuddyMgr = _G.BuddyMgr
	ChocoboShowModelMgr = _G.ChocoboShowModelMgr
	LSTR = _G.LSTR

	self.ViewModel = BuddySurfaceVM

	--self.TableViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TabsItem.TableViewList)
	--self.TableViewMenuAdapter:SetOnClickedCallback(self.OnMenuItemClicked)

	self.SubViewMenuAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab)
	self.SubViewMenuAdapter:SetOnClickedCallback(self.OnSubMenuItemClicked)

	self.TableViewEquipmentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView01)
	self.TableViewEquipmentAdapter:SetOnClickedCallback(self.OnEquipmentItemClicked)

	self.TableViewDyeItemAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView02)
	self.TableViewDyeItemAdapter:SetOnClickedCallback(self.OnDyeItemClicked)

	self.TableViewDyeColorTypeAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewColorList)
	self.TableViewDyeColorTypeAdapter:SetOnClickedCallback(self.OnDyeColorTypeClicked)

	self.TableViewDyeColorAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView03)
	self.TableViewDyeColorAdapter:SetOnClickedCallback(self.OnDyeColorClicked)

	self.FastDyeFruitAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRecommend)
	self.FastDyeFruitAdapter:SetOnClickedCallback(self.OnDyeFruitClicked)

	self.NormalDyeFruitAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRecommend_1)
	self.NormalDyeFruitAdapter:SetOnClickedCallback(self.OnDyeFruitClicked)

	self.Binders = {
		{ "EquipmentPageVisible", UIBinderSetIsVisible.New(self, self.Panel01) },
		{ "NormalDyePageVisible", UIBinderSetIsVisible.New(self, self.Panel02) },
		{ "FastDyePageVisible", UIBinderSetIsVisible.New(self, self.Panel03) },
		{ "DyeCDPageVisible", UIBinderSetIsVisible.New(self, self.PanelHasten) },

		{ "ShowArmorBtnVisible", UIBinderSetIsVisible.New(self, self.ToggleBtnArmor, false, true) },
	
		{ "DyeDescPanelVisible", UIBinderSetIsVisible.New(self, self.PanelColorChange) },
		--{ "SubTitleText", UIBinderSetText.New(self, self.TextSubtitle) },
		{ "EquipmentText", UIBinderSetText.New(self, self.TextName) },

		{ "CDTimeText", UIBinderSetText.New(self, self.TextTime) },

		--{ "TabPageVMList", UIBinderUpdateBindableList.New(self, self.TableViewMenuAdapter) },
		{ "SubTabVMList", UIBinderUpdateBindableList.New(self, self.SubViewMenuAdapter) },

		{ "EquipmentItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewEquipmentAdapter) },
		{ "UnLoadBtnVisible", UIBinderSetIsVisible.New(self, self.BtnUnLoad) },
		{ "WearBtnVisible", UIBinderSetIsVisible.New(self, self.BtnWear) },
		{ "WearBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnWear) },

		{ "DyeItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewDyeItemAdapter) },
		{ "DyeColorVMList", UIBinderUpdateBindableList.New(self, self.TableViewDyeColorAdapter) },

		{ "DyeColorTypeVMList", UIBinderUpdateBindableList.New(self, self.TableViewDyeColorTypeAdapter) },

		{ "FastDyeItemListVisible", UIBinderSetIsVisible.New(self, self.PanelItem) },
		{ "FastDyeFruitItemVMList", UIBinderUpdateBindableList.New(self, self.FastDyeFruitAdapter) },

		{ "NormalDyeItemList02Visible", UIBinderSetIsVisible.New(self, self.PanelItem02) },
		{ "NormalDyeFruitItemVMList", UIBinderUpdateBindableList.New(self, self.NormalDyeFruitAdapter) },

		{ "MountState", UIBinderSetCheckedState.New(self, self.ToggleBtnMount) },
		{ "ArmorState", UIBinderSetCheckedState.New(self, self.ToggleBtnArmor) },
		
		{ "DyeTargetNodeVisible", UIBinderSetIsVisible.New(self, self.PanelArrow) },
		{ "DyeTargetNodeVisible", UIBinderSetIsVisible.New(self, self.VerticalColorChange02) },

		{ "TargetColorAboutVisible", UIBinderSetIsVisible.New(self, self.TextAbout) },
		{ "TargetColorValidVisible", UIBinderSetIsVisible.New(self, self.ImgColor2) },
		{ "TargetColorInvalidVisible", UIBinderSetIsVisible.New(self, self.BtnInvalidTips) },

		{ "NormalDyeItemList01Visible", UIBinderSetIsVisible.New(self, self.PanelColorContent) },
		{ "NormalDyeUnselectedVisible", UIBinderSetIsVisible.New(self, self.AmountSlider) },
		{ "NormalDyeUnselectedVisible", UIBinderSetIsVisible.New(self, self.TextAmount) },
		{ "NormalDyeUnselectedVisible", UIBinderSetIsVisible.New(self, self.ImgLine01) },

		{ "StainBtnVisible", UIBinderSetIsVisible.New(self, self.BtnStain) },
		{ "StainBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnStain) },

		{ "CurColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgColor) },
		{ "CurColorNameText", UIBinderSetText.New(self, self.TextColorName) },
		{ "CurColorRText", UIBinderSetTextFormat.New(self, self.TextColorNumber01, "%d") },
		{ "CurColorGText", UIBinderSetTextFormat.New(self, self.TextColorNumber02, "%d") },
		{ "CurColorBText", UIBinderSetTextFormat.New(self, self.TextColorNumber03, "%d") },

		{ "TargetColor", UIBinderSetColorAndOpacityHex.New(self, self.ImgColor2) },
		{ "TargetColorNameText", UIBinderSetText.New(self, self.TextColorName02) },
		{ "TargetColorRText", UIBinderSetTextFormat.New(self, self.TextColorNumber04, "%d") },
		{ "TargetColorGText", UIBinderSetTextFormat.New(self, self.TextColorNumber05, "%d") },
		{ "TargetColorBText", UIBinderSetTextFormat.New(self, self.TextColorNumber06, "%d") },

		{ "TargetColorR", UIBinderSetColorAndOpacityHex.New(self, self.TextColorNumber04) },
		{ "TargetColorG", UIBinderSetColorAndOpacityHex.New(self, self.TextColorNumber05) },
		{ "TargetColorB", UIBinderSetColorAndOpacityHex.New(self, self.TextColorNumber06) },


		{ "DyeItemNameText", UIBinderSetText.New(self, self.TextColorType) },
		{ "DyeItemRText", UIBinderSetTextFormat.New(self, self.TextAdd01, "%d") },
		{ "DyeItemGText", UIBinderSetTextFormat.New(self, self.TextAdd02, "%d") },
		{ "DyeItemBText", UIBinderSetTextFormat.New(self, self.TextAdd03, "%d") },
		{ "DyeItemAmountText", UIBinderSetTextFormat.New(self, self.TextAmount, "%d") },

		
		{ "BtnStain02Visible", UIBinderSetIsVisible.New(self, self.BtnStain02) },

		{ "LockFastDyeText", UIBinderSetText.New(self, self.TextLock) },
		{ "FastStainBtnEnabled", UIBinderSetIsEnabled.New(self, self.BtnStain02, false, true) },
		{ "FastDyeTipsText", UIBinderSetText.New(self, self.TextRecommend) },
		{ "FastDyeTipsColor", UIBinderSetColorAndOpacityHex.New(self, self.TextRecommend) },
		
		{ "IsShowChocoboName", UIBinderSetIsVisible.New(self, self.ChocoboAvatarItem_UIBP) },
		{ "IsShowChocoboName", UIBinderSetIsVisible.New(self, self.TextChocoboName) },
		--{ "TitleText", UIBinderSetText.New(self, self.TextTitleName) },

	}

end

function BuddySurfaceArmorPanelView:OnDestroy()

end

function BuddySurfaceArmorPanelView:OnShow()
	--_G.UE.FProfileTag.StaticBegin("BuddySurfaceArmorPanelView:OnShow")
	if self.Params ~= nil then
		BuddyMgr.SurfaceViewCurID = self.Params.ID

		if BuddyMgr.SurfaceViewCurID > 0 then
			self.CommonTitle:SetTextTitleName(_G.LSTR(1000012))
		else
			self.CommonTitle:SetTextTitleName(_G.LSTR(1000013))
		end

		self.ViewModel:UpdateChocoboInfo(BuddyMgr.SurfaceViewCurID)
		if self.Params.FromViewID == UIViewID.ChocoboMainPanelView or
				self.Params.FromViewID == UIViewID.ChocoboCodexArmorPanelView then
			if self.BtnBack ~= nil then
				self.BtnBack:AddBackClick(self, self.OnClickedBtnBack)
				UIUtil.SetIsVisible(self.BtnBack, true)
				UIUtil.SetIsVisible(self.BtnClose, false)
			end
		end
	end
	self.ViewModel:SetArmorChecked()
	self.ViewModel:SetMountUnchecked()
	self:ShowPlayerBuddyActor()

	--self.ViewModel:InitPageMenu()

	self.CommVerIconTabs:UpdateItems(BuddyDefine.SurfaceArmorMenu, BuddySurfaceVM.MenuType.Equipment)

	self.CommonTitle:SetTextSubtitle(_G.LSTR(1000015))
	self.ViewModel:ShowEquipmentPage()
	self.CommonTitle.CommInforBtn:SetHelpInfoID(11025)

	local CfgList = ChocoboDyeStuffCfg:FindAllCfg()
	if #CfgList > 0 then
		local Num = BagMgr:GetItemNum(CfgList[1].ItemID)
		self.AmountSlider:SetSliderValueMaxMin(Num, 0)
		self.AmountSlider:SetValueChangedCallback(function (v)
			self:OnValueChangedAmountCountSlider(v)
		end)

		self.ViewModel.DyeItemAmountText = 0
	end

	self.ViewModel.StainBtnEnabled = false

	self:PlayAnimation(self.AnimColorChangeArrowLoop, 0, 0)
	--_G.UE.FProfileTag.StaticEnd()
	_G.LightMgr:EnableUIWeather(ChocoboDefine.BuddyLightID)
end

function BuddySurfaceArmorPanelView:GetTabMenuList()
	local ItemList = {}

	table.insert(ItemList, {IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Mate_Normal.UI_Icon_Tab_Partner_Mate_Normal'", SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Mate_Select.UI_Icon_Tab_Partner_Mate_Select'"})
	--table.insert(ItemList, {IconPath = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Stain_Normal.UI_Icon_Tab_Partner_Stain_Normal'", SelectIcon = "Texture2D'/Game/UI/Texture/Icon/Tab/UI_Icon_Tab_Partner_Stain_Select.UI_Icon_Tab_Partner_Stain_Select'"})

	return ItemList
end

function BuddySurfaceArmorPanelView:OnActive()
	self:ShowPlayerBuddyActor()
end

function BuddySurfaceArmorPanelView:OnHide()
	_G.LightMgr:DisableUIWeather()
	local bHideModel = true
	if self.Params ~= nil and self.Params.FromViewID ~= nil then
		if self.Params.FromViewID == UIViewID.ChocoboMainPanelView or
				self.Params.FromViewID == UIViewID.ChocoboCodexArmorPanelView then
			bHideModel = false
		end
	end

	if bHideModel then
		ChocoboShowModelMgr:OnHide()
	end
	
	BuddyMgr.SurfaceViewCurID = nil
	self.CurColorID = nil
end

function BuddySurfaceArmorPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMount, self.OnClickBtnMount)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnArmor, self.OnClickBtnArmor)
	UIUtil.AddOnClickedEvent(self, self.ButtonGoGet, self.OnClickedToGetBtn)

	UIUtil.AddOnClickedEvent(self, self.BtnStain.Button, self.OnClickedDyeNoramlBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnStain02.Button, self.OnClickedDyeFastBtn)

	UIUtil.AddOnClickedEvent(self, self.BtnHasten.Button, self.OnClickedBtnAccelerate)
	UIUtil.AddOnClickedEvent(self, self.BtnWear.Button, self.OnClickedBtnWear)
	UIUtil.AddOnClickedEvent(self, self.BtnUnLoad.Button, self.OnClickedBtnUnLoad)
	UIUtil.AddOnClickedEvent(self, self.BtnArchive, self.OnClickedBtnArchive)

	UIUtil.AddOnSelectionChangedEvent(self, self.CommVerIconTabs, self.OnMenuItemClicked)

end

function BuddySurfaceArmorPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BuddyCDOnTime, self.OnUpdateBuddyCDOnTime)
	self:RegisterGameEvent(EventID.BuddyDyeUpdate, self.OnUpdateBuddyDyeUpdate)
	self:RegisterGameEvent(EventID.BuddyEquipmentUpdate, self.OnUpdateBuddyEquipmentUpdate)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateItemUpdate)
end

function BuddySurfaceArmorPanelView:OnRegisterBinder()
	-- SetText 放在 RegisterBinders 之前，防止Text被VM赋值之后，又被SetText修改
	--self.TextTitleName:SetText(LSTR(1000013))
	self.TextAbout:SetText(LSTR(1000053))
	self.BtnUnLoad:SetText(LSTR(1000054))
	self.BtnWear:SetText(LSTR(1000055))
	self.TextGoGet:SetText(LSTR(1000056))
	self.BtnStain:SetText(LSTR(1000057))
	self.TextRecommend_1:SetText(LSTR(1000058))
	self.TextLock:SetText(LSTR(1000059))
	self.BtnStain02:SetText(LSTR(1000057))
	self.TextRecommend:SetText(LSTR(1000018))
	self.BtnHasten:SetText(LSTR(1000011))
	self.TextRest:SetText(LSTR(1000060))
	
	self:RegisterBinders(self.ViewModel, self.Binders)
	
	local ChocoboBinders = {
		{ "Color", UIBinderSetColorAndOpacity.New(self, self.ChocoboAvatarItem_UIBP.ImgColor) },
		{ "Name", UIBinderSetText.New(self, self.TextChocoboName) },
	}
	
	local ChocoboID = self.Params.ID
	if ChocoboID > 0 then
		local VM = _G.ChocoboMgr:GetChocoboVM(ChocoboID)
		if VM ~= nil then
			self:RegisterBinders(VM, ChocoboBinders)
		end
	end
end


function BuddySurfaceArmorPanelView:OnClickBtnMount()
	self.ViewModel:UpdateMountState()
	if self.ModeNeedRefresh == true then
		self.ModeNeedRefresh = false
		self:UpdateUIBuddyModel()
	end
end

function BuddySurfaceArmorPanelView:OnClickBtnArmor()
	self.ViewModel:UpdateArmorState()
	if BuddyMgr:SurfaceBInDyeCD() then
		self:UpdateUIBuddyModel()
		return
	end
	self:UpdateBuddyModelByColor(self.ViewModel.DyeTargetColorID)
end

function BuddySurfaceArmorPanelView:OnClickedToGetBtn()
	local Params = {ViewModel = self.ViewModel, ForbidRangeWidget = self.PanelGetway, InTagetView = self.PanelGetway}
	ItemTipsUtil.OnClickedToGetBtn(Params)
end


-- 初始化三维展示模型
function BuddySurfaceArmorPanelView:ShowPlayerBuddyActor()
	local CallBack = function(View)
		ChocoboShowModelMgr:ShowMajor(false)
		ChocoboShowModelMgr:ResetChocoboModelScale()
		ChocoboShowModelMgr:SetModelDefaultPos()
		ChocoboShowModelMgr:EnableRotator(true)
		if View then
			View.ModeNeedRefresh = true
			View:UpdateUIBuddyModel()
			ChocoboShowModelMgr:BindCommGesture(View.CommGesture_UIBP)
		end
	end

	ChocoboShowModelMgr:SetUIType(ProtoRes.CHOCOBO_MODE_SHOW_UI_TYPE.CHOCOBO_MODE_SHOW_UITYPE_BUDDY)
	ChocoboShowModelMgr:SetImageRole(self.ImageRole)
	if ChocoboShowModelMgr:IsCreateFinish() then
		CallBack(self)
	else
		ChocoboShowModelMgr:CreateModel(self, CallBack)
		ChocoboShowModelMgr:ShowMajor(false)
	end
end

function BuddySurfaceArmorPanelView:UpdateUIBuddyModel()
	-- 更新装备
	local Head = 0
	local Body = 0
	local Feet = 0
	local Armor = BuddyMgr:GetSurfaceArmor()
	if Armor ~= nil and self.ViewModel:BArmorChecked() then
		Head = Armor.Head
		Body = Armor.Body
		Feet = Armor.Feet
	end
	ChocoboShowModelMgr:SetChocoboArmorByPos(Head, Body,Feet)
	
	-- 更新颜色
	local ColorID = 0
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		ColorID = BuddyColor.RGB
	end
	
	ChocoboShowModelMgr:SetChocoboColor(ColorID)
	
	-- 更新模型
	ChocoboShowModelMgr:UpdateUIChocoboModel()
end

function BuddySurfaceArmorPanelView:UpdateBuddyModelByColor(ColorID)
	local Head = 0
	local Body = 0
	local Feet = 0
	local Armor = BuddyMgr:GetSurfaceArmor()
	if Armor ~= nil and self.ViewModel:BArmorChecked() then
		Head = Armor.Head
		Body = Armor.Body
		Feet = Armor.Feet
	end
	ChocoboShowModelMgr:SetChocoboArmorByPos(Head, Body,Feet)

	ChocoboShowModelMgr:SetChocoboColor(ColorID)
	ChocoboShowModelMgr:UpdateUIChocoboModel()
end

function BuddySurfaceArmorPanelView:UpdateBuddyModelByArmor(Head, Body, Feet)
	ChocoboShowModelMgr:SetChocoboArmorByPos(Head, Body,Feet)

	-- 更新颜色
	local ColorID = 0
	local BuddyColor = BuddyMgr:GetSurfaceColor()
	if BuddyColor then
		ColorID = BuddyColor.RGB
	end
	
	ChocoboShowModelMgr:SetChocoboColor(ColorID)
	ChocoboShowModelMgr:UpdateUIChocoboModel()
end

function BuddySurfaceArmorPanelView:OnClickedDyeNoramlBtn()
	UIViewMgr:ShowView(UIViewID.BuddySurfaceStainWin, {DyeType = self.ViewModel.DyeType, TargetColorID = self.ViewModel.DyeTargetColorID, DyeLists = self.ViewModel.DyeLists})
end

function BuddySurfaceArmorPanelView:OnClickedDyeFastBtn()
	if BuddyMgr:SurfaceBInDyeCD() == true then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(1000038))
		return
	end
	BuddyMgr:ReqDyeColor(BuddyMgr.SurfaceViewCurID, self.ViewModel.DyeType, self.ViewModel.DyeTargetColorID, self.ViewModel.DyeLists)
end

function BuddySurfaceArmorPanelView:OnClickedBtnAccelerate()
	UIViewMgr:ShowView(UIViewID.BuddyUseAccelerateWin)
end

function BuddySurfaceArmorPanelView:OnClickedBtnWear()
	BuddyMgr:ReqArmor(BuddyMgr.SurfaceViewCurID, self.ViewModel.EquipmentID)
end

function BuddySurfaceArmorPanelView:OnClickedBtnUnLoad()
	if self.ViewModel.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Head then
		BuddyMgr:ReqArmor(BuddyMgr.SurfaceViewCurID, 0, ChocoboArmorPos.ChocoboArmorPosHead)
	elseif self.ViewModel.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Body then
		BuddyMgr:ReqArmor(BuddyMgr.SurfaceViewCurID, 0, ChocoboArmorPos.ChocoboArmorPosBody)
	elseif self.ViewModel.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Leg then
		BuddyMgr:ReqArmor(BuddyMgr.SurfaceViewCurID, 0, ChocoboArmorPos.ChocoboArmorPosLeg)
	end
end

function BuddySurfaceArmorPanelView:OnClickedBtnArchive()
	if UIViewMgr:IsViewVisible(UIViewID.ChocoboCodexArmorPanelView) then
		self:Hide()
	end
	_G.ChocoboCodexArmorMgr:OpenChocoboCodexArmorPanel()
end

function BuddySurfaceArmorPanelView:OnMenuItemClicked(Index, ItemData, ItemView)
	if self.ViewModel.TabPageIndex == Index then
		return
	end

	if Index == BuddySurfaceVM.MenuType.Equipment then
		self.CommonTitle:SetTextSubtitle(_G.LSTR(1000015))
	elseif Index == BuddySurfaceVM.MenuType.Dye then
		self.CommonTitle:SetTextSubtitle(_G.LSTR(1000016))
	end

	self.ViewModel:UpdateCurTabPage(Index)

	if self.ViewModel.TabPageIndex == BuddySurfaceVM.MenuType.Dye then
		self:PlayAnimation(self.AnimColorChangeIn)
		self.ViewModel.ArmorState = _G.UE.EToggleButtonState.Unchecked
		self.CommonTitle.CommInforBtn:SetHelpInfoID(11024)
		self.TableViewEquipmentAdapter:ReleaseAllItem(true)
	else
		self:PlayAnimation(self.AnimColorChangeOut)
		self.ViewModel:SetArmorChecked()
		self.CommonTitle.CommInforBtn:SetHelpInfoID(11025)
		self.TableViewDyeColorAdapter:ReleaseAllItem(true)
	end

	self:OnUpdateNormalDyeUI()

end

function BuddySurfaceArmorPanelView:OnSubMenuItemClicked(Index, ItemData, ItemView)
	self.ViewModel:UpdateSubTabPage(Index)
	self.TableViewEquipmentAdapter:ScrollToTop()
	self:OnUpdateNormalDyeUI()
end

function BuddySurfaceArmorPanelView:GetDefaultCameraOffset()
	local RaceID = MajorUtil.GetMajorRaceID()
	local Cfg = ChocoboModelShowCfg:FindCfgByRaceIDAndUIType(RaceID, ProtoRes.CHOCOBO_MODE_SHOW_UI_TYPE.CHOCOBO_MODE_SHOW_UITYPE_BUDDY)
	if Cfg ~= nil and Cfg[1] ~= nil then
		return Cfg[1].Offset
	end
	return _G.UE.FVector(0, 0, 0)
end

function BuddySurfaceArmorPanelView:OnUpdateNormalDyeUI()
	self:UpdateUIBuddyModel()
end

function BuddySurfaceArmorPanelView:OnEquipmentItemClicked(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ResID == nil then
		return
	end
	self.ViewModel:SelectedEquipmentItem(ItemData.ResID)

	local Head = 0
	local Body = 0
	local Feet = 0
	local Armor = BuddyMgr:GetSurfaceArmor()
	if Armor ~= nil and self.ViewModel:BArmorChecked() then
		Head = Armor.Head
		Body = Armor.Body
		Feet = Armor.Feet
	end
	if self.ViewModel.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Head then
		Head = ItemData.ResID
	elseif self.ViewModel.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Body then
		Body = ItemData.ResID
	elseif self.ViewModel.SubTabIndex == BuddySurfaceVM.EquipmentMenuType.Leg then
		Feet = ItemData.ResID
	end

	self:UpdateBuddyModelByArmor(Head, Body, Feet)
end

function BuddySurfaceArmorPanelView:OnDyeItemClicked(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ResID == nil then
		return
	end

	self:SetCurDyeItem(ItemData.ResID)
end


function BuddySurfaceArmorPanelView:SetCurDyeItem(ResID)
	self.ViewModel:SelectedDyeItem(ResID)

	if BuddyMgr:SurfaceBInDyeCD() then
		return
	end

	local Num = BagMgr:GetItemNum(ResID)
	self.AmountSlider:SetSliderValueMaxMin(Num, 0)
	local Amount = self.ViewModel:GetNormalDyeItemNum(ResID)
	self.AmountSlider:SetSliderValue(Amount)
end

function BuddySurfaceArmorPanelView:OnDyeColorTypeClicked(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.Type == nil then
		return
	end
	self.ViewModel:SetDyeColorTypeState(ItemData.Type)
end

function BuddySurfaceArmorPanelView:OnDyeColorClicked(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.IsValid == false then
		return
	end
	self.ViewModel:SetDyeColorItem(ItemData.ColorID)

	self:UpdateBuddyModelByColor(self.ViewModel.DyeTargetColorID)
end


function BuddySurfaceArmorPanelView:OnValueChangedAmountCountSlider(Value)
	self.ViewModel:SetDyeItemAmount(Value)
	if self.CurColorID ~= self.ViewModel.DyeTargetColorID then
		self.CurColorID = self.ViewModel.DyeTargetColorID
		self:UpdateBuddyModelByColor(self.ViewModel.DyeTargetColorID)
	end
end

function BuddySurfaceArmorPanelView:OnUpdateBuddyCDOnTime()
	self.ViewModel:SetCDOnTime()
end

function BuddySurfaceArmorPanelView:OnUpdateItemUpdate()
	self:OnUpdateBuddyEquipmentUpdate()
	self:OnUpdateBuddyDyeUpdate()
end

function BuddySurfaceArmorPanelView:OnUpdateBuddyDyeUpdate()
	if self.ViewModel.TabPageIndex == BuddySurfaceVM.MenuType.Dye then
		self.ViewModel:UpdateDyePanel()
		if self.ViewModel.SubTabIndex == BuddySurfaceVM.DyeMenuType.Normal then
			local Num = BagMgr:GetItemNum(self.ViewModel.DyeItemID)
			self.AmountSlider:SetSliderValueMaxMin(Num, 0)
			self.ViewModel.DyeItemAmountText = 0
			self.ViewModel.StainBtnEnabled = false
		end
		self:UpdateUIBuddyModel()
		self:PlayAnimation(self.AnimColorChangeIn)
	end
	
end

function BuddySurfaceArmorPanelView:OnUpdateBuddyEquipmentUpdate()
	if self.ViewModel.TabPageIndex == BuddySurfaceVM.MenuType.Equipment then
		local SelectedEquipmentItemID = self.ViewModel.EquipmentID
		self.ViewModel:UpdateEquipmentPanel()
		self.ViewModel:SelectedEquipmentItem(SelectedEquipmentItemID)
	end
	self:UpdateUIBuddyModel()
end

function BuddySurfaceArmorPanelView:OnDyeFruitClicked(Index, ItemData, ItemView)
	if ItemData == nil or ItemData.ResID == nil then
		return
	end

	ItemTipsUtil.ShowTipsByResID(ItemData.ResID , ItemView)
end

function BuddySurfaceArmorPanelView:OnClickedBtnBack(FromViewID)
	self:Hide()
end

return BuddySurfaceArmorPanelView
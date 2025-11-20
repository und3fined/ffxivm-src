---
--- Author: Administrator
--- DateTime: 2025-07-07 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class StoreMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnExtend UFButton
---@field BtnRecharge UFButton
---@field Btn_ChangePos UFButton
---@field CommInforBtn CommInforBtnView
---@field CommTabs CommTabsView
---@field CommonBkg CommonBkg01View
---@field CommonRedDot CommonRedDotView
---@field Common_Render2D_UIBP CommonRender2DView
---@field FCanvasPanel UFCanvasPanel
---@field FTextBlock_65 UFTextBlock
---@field GoodsExpandPage StoreGoodsExpandPageView
---@field HorizontalGoods1 UFHorizontalBox
---@field HorizontalPrice UFHorizontalBox
---@field ImgBgmOff UFImage
---@field ImgBgmOn UFImage
---@field ImgBkg UFImage
---@field ImgBuySelect UFImage
---@field ImgDressOff UFImage
---@field ImgDressOn UFImage
---@field ImgGiftSelect UFImage
---@field ImgHatOff UFImage
---@field ImgHatOn UFImage
---@field ImgHatStyleOff UFImage
---@field ImgHatStyleOn UFImage
---@field ImgMoney UFImage
---@field ImgMusicOff UFImage
---@field ImgMusicOn UFImage
---@field ImgPoseOff UImage
---@field ImgPoseOn UImage
---@field ImgRideDown UFImage
---@field ImgRideUp UFImage
---@field PanelClothingPage UFVerticalBox
---@field PanelGoods UFCanvasPanel
---@field PanelInfoBtns UFCanvasPanel
---@field PanelMountPage UFVerticalBox
---@field PanelOriginal UFCanvasPanel
---@field PanelOwn UFCanvasPanel
---@field PanelRecharge UFCanvasPanel
---@field PanelSheetMusicPage UFVerticalBox
---@field PanelTabList UFCanvasPanel
---@field PanelWeaponPage UFVerticalBox
---@field PropsPage StorePropsPageView
---@field SlotCrystral CommMoneySlotView
---@field SpacerForBtnBuy USpacer
---@field SpacerForEquipAction USpacer
---@field TableViewEmoAct UTableView
---@field TableViewEquip UTableView
---@field TableViewGoods UTableView
---@field TableViewMenu UTableView
---@field TableViewMountAction UTableView
---@field TableViewSort UTableView
---@field TextBuy UFTextBlock
---@field TextCurrentPrice UFTextBlock
---@field TextDyeTips UFTextBlock
---@field TextItemName UFTextBlock
---@field TextOriginalPrice UFTextBlock
---@field TextOwn UFTextBlock
---@field TextRecharge UFTextBlock
---@field TextStore UFTextBlock
---@field TextSwitchBuy UFTextBlock
---@field TextSwitchGift UFTextBlock
---@field ToggleBtnBuy UToggleButton
---@field ToggleBtnDress UToggleButton
---@field ToggleBtnGift UToggleButton
---@field ToggleBtnHat UToggleButton
---@field ToggleBtnHatStyle UToggleButton
---@field ToggleBtnMountBgm UToggleButton
---@field ToggleBtnPose UToggleButton
---@field ToggleBtnRide UToggleButton
---@field ToggleBtnSheetMusic UToggleButton
---@field ToggleBtnUIArrange UToggleButton
---@field ToggleGroupSwitch UToggleGroup
---@field AnimFullScreenIn UWidgetAnimation
---@field AnimFullScreenOut UWidgetAnimation
---@field AnimGoodsUpdate UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimPanelDyeIn UWidgetAnimation
---@field AnimPanelGoodsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreMainPanelView = LuaClass(UIView, true)

function StoreMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnClose = nil
	--self.BtnExtend = nil
	--self.BtnRecharge = nil
	--self.Btn_ChangePos = nil
	--self.CommInforBtn = nil
	--self.CommTabs = nil
	--self.CommonBkg = nil
	--self.CommonRedDot = nil
	--self.Common_Render2D_UIBP = nil
	--self.FCanvasPanel = nil
	--self.FTextBlock_65 = nil
	--self.GoodsExpandPage = nil
	--self.HorizontalGoods1 = nil
	--self.HorizontalPrice = nil
	--self.ImgBgmOff = nil
	--self.ImgBgmOn = nil
	--self.ImgBkg = nil
	--self.ImgBuySelect = nil
	--self.ImgDressOff = nil
	--self.ImgDressOn = nil
	--self.ImgGiftSelect = nil
	--self.ImgHatOff = nil
	--self.ImgHatOn = nil
	--self.ImgHatStyleOff = nil
	--self.ImgHatStyleOn = nil
	--self.ImgMoney = nil
	--self.ImgMusicOff = nil
	--self.ImgMusicOn = nil
	--self.ImgPoseOff = nil
	--self.ImgPoseOn = nil
	--self.ImgRideDown = nil
	--self.ImgRideUp = nil
	--self.PanelClothingPage = nil
	--self.PanelGoods = nil
	--self.PanelInfoBtns = nil
	--self.PanelMountPage = nil
	--self.PanelOriginal = nil
	--self.PanelOwn = nil
	--self.PanelRecharge = nil
	--self.PanelSheetMusicPage = nil
	--self.PanelTabList = nil
	--self.PanelWeaponPage = nil
	--self.PropsPage = nil
	--self.SlotCrystral = nil
	--self.SpacerForBtnBuy = nil
	--self.SpacerForEquipAction = nil
	--self.TableViewEmoAct = nil
	--self.TableViewEquip = nil
	--self.TableViewGoods = nil
	--self.TableViewMenu = nil
	--self.TableViewMountAction = nil
	--self.TableViewSort = nil
	--self.TextBuy = nil
	--self.TextCurrentPrice = nil
	--self.TextDyeTips = nil
	--self.TextItemName = nil
	--self.TextOriginalPrice = nil
	--self.TextOwn = nil
	--self.TextRecharge = nil
	--self.TextStore = nil
	--self.TextSwitchBuy = nil
	--self.TextSwitchGift = nil
	--self.ToggleBtnBuy = nil
	--self.ToggleBtnDress = nil
	--self.ToggleBtnGift = nil
	--self.ToggleBtnHat = nil
	--self.ToggleBtnHatStyle = nil
	--self.ToggleBtnMountBgm = nil
	--self.ToggleBtnPose = nil
	--self.ToggleBtnRide = nil
	--self.ToggleBtnSheetMusic = nil
	--self.ToggleBtnUIArrange = nil
	--self.ToggleGroupSwitch = nil
	--self.AnimFullScreenIn = nil
	--self.AnimFullScreenOut = nil
	--self.AnimGoodsUpdate = nil
	--self.AnimIn = nil
	--self.AnimPanelDyeIn = nil
	--self.AnimPanelGoodsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.Common_Render2D_UIBP)
	self:AddSubView(self.GoodsExpandPage)
	self:AddSubView(self.PropsPage)
	self:AddSubView(self.SlotCrystral)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreMainPanelView:OnInit()

end

function StoreMainPanelView:OnDestroy()

end

function StoreMainPanelView:OnShow()

end

function StoreMainPanelView:OnHide()

end

function StoreMainPanelView:OnRegisterUIEvent()

end

function StoreMainPanelView:OnRegisterGameEvent()

end

function StoreMainPanelView:OnRegisterBinder()

end

return StoreMainPanelView
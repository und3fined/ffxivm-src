---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 10:01
--- Description:
---

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local AnimMgr = require("Game/Anim/AnimMgr")
local BgmCfg = require("TableCfg/BgmCfg")
local CameraUtil = require("Game/Common/Camera/CameraUtil")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local UIViewMgr = require("UI/UIViewMgr")
local JumpUtil = require("Utils/JumpUtil")
local UIViewID = require("Define/UIViewID")
local RideCfg = require("TableCfg/RideCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local UIDefine = require("Define/UIDefine")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local StoreCfg = require("TableCfg/StoreCfg")
local CommonUtil = require("Utils/CommonUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local StoreDefine = require("Game/Store/StoreDefine")
local SkillTipsMgr = require("Game/Skill/SkillTipsMgr")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local DataReportUtil = require("Utils/DataReportUtil")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local MountCustomMadeVM = require("Game/Mount/VM/MountCustomMadeVM")
local MountMgr = require("Game/Mount/MountMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local StoreBuyWinVM = require("Game/Store/VM/StoreBuyWinVM")
local StoreUtil = require("Game/Store/StoreUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetTextFormatForScore = require("Binder/UIBinderSetTextFormatForScore")

-- local FLOG_INFO = _G.FLOG_INFO
local LSTR = _G.LSTR
local UE = _G.UE

local CommBtnColorType = UIDefine.CommBtnColorType
local Store_Label_Type = ProtoRes.Store_Label_Type
local StoreMall = ProtoRes.StoreMall
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local Render2DConfig = StoreDefine.StoreRender2DConfig
local CompanionPopATLPath = "normal/idle_inactive1"
local ShowActorType =
{
	None = 0,
	Human = 1,
	Mount = 2,
	Companion = 3,
}

local RenderActorCreateCallbackType =
{
	ViewMount = 1,
	RideMount = 2,
	ViewCompanion = 3,
}

-- 待机动作类型
local IdlePoseType =
{
	Default = 1, -- 默认姿势
	Show = 2, -- 展示用姿势
	Combat = 3, -- 战斗姿势
}

local HideBuyBtnConfig =
{
	[StoreMall.STORE_MALL_PROPS] = true
}
local MysterBoxMaxBoughtCount = 6

---@class StoreNewMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnLView
---@field BtnBuyRedDot CommonRedDotView
---@field BtnClose CommonCloseBtnView
---@field BtnEquipment UToggleButton
---@field BtnExpand UFButton
---@field BtnFullScreen UToggleButton
---@field BtnHand UToggleButton
---@field BtnHat UToggleButton
---@field BtnInfo USizeBox
---@field BtnMusic UToggleButton
---@field BtnOrgan UToggleButton
---@field BtnPose UToggleButton
---@field BtnSpacing USpacer
---@field BtnSwitch UToggleButton
---@field BtnSwitchPosture UFButton
---@field BtnTag1 UFButton
---@field BtnTag2 UFButton
---@field Btn_Video UFButton
---@field CommInforBtn CommInforBtnView
---@field CommMenu CommMenuView
---@field CommTab USizeBox
---@field CommTabs CommTabsView
---@field CommodityExpandPanel StoreCommodityExpandPanelView
---@field CommonTitle CommonTitleView
---@field IconVideco UFImage
---@field InforBtn CommInforBtnView
---@field Money StoreMoneyItemUBPView
---@field Money1 CommMoneySlotView
---@field PaneVideo_Full UFCanvasPanel
---@field PanelBtnBuy UFHorizontalBox
---@field PanelCommodity UFHorizontalBox
---@field PanelCommodityFold UFCanvasPanel
---@field PanelDownload UFCanvasPanel
---@field PanelDyeing UFHorizontalBox
---@field PanelInfo UFCanvasPanel
---@field PanelInteract UFCanvasPanel
---@field PanelPoster UFCanvasPanel
---@field PanelPreview UFCanvasPanel
---@field PanelRoleBtn UFVerticalBox
---@field PanelTag UFCanvasPanel
---@field PanelVideo UFCanvasPanel
---@field RichTextBoxBlindBoxHint URichTextBox
---@field StoreRender2D StoreRender2DView
---@field TableViewCommodity UTableView
---@field TableViewMountsAction UTableView
---@field TableViewPoster UTableView
---@field TableViewPreview UTableView
---@field TableViewProps UTableView
---@field TableViewSlot UTableView
---@field TextDownload UFTextBlock
---@field TextDyeing UFTextBlock
---@field TextHint UFTextBlock
---@field TextName UFTextBlock
---@field TextPreview UFTextBlock
---@field TextType UFTextBlock
---@field TextUnavailable UFTextBlock
---@field UMGVideoPlayer_UIBP UMGVideoPlayerView
---@field UMGVideoPlayer_UIBP_Full UMGVideoPlayerView
---@field AnimCommodityFold UWidgetAnimation
---@field AnimCommodityFoldFullScreenIn UWidgetAnimation
---@field AnimCommodityFoldFullScreenOut UWidgetAnimation
---@field AnimCommodityIn UWidgetAnimation
---@field AnimCommodityUnfold UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimInfoIn UWidgetAnimation
---@field AnimPosterFullScreenIn UWidgetAnimation
---@field AnimPosterFullScreenOut UWidgetAnimation
---@field AnimPreviewRoleAppearanceFalse UWidgetAnimation
---@field AnimPreviewRoleAppearanceTrue UWidgetAnimation
---@field AnimTableViewPropsIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewMainPanelView = LuaClass(UIView, true)

function StoreNewMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnBuyRedDot = nil
	--self.BtnClose = nil
	--self.BtnEquipment = nil
	--self.BtnExpand = nil
	--self.BtnFullScreen = nil
	--self.BtnHand = nil
	--self.BtnHat = nil
	--self.BtnInfo = nil
	--self.BtnMusic = nil
	--self.BtnOrgan = nil
	--self.BtnPose = nil
	--self.BtnSpacing = nil
	--self.BtnSwitch = nil
	--self.BtnSwitchPosture = nil
	--self.BtnTag1 = nil
	--self.BtnTag2 = nil
	--self.Btn_Video = nil
	--self.CommInforBtn = nil
	--self.CommMenu = nil
	--self.CommTab = nil
	--self.CommTabs = nil
	--self.CommodityExpandPanel = nil
	--self.CommonTitle = nil
	--self.IconVideco = nil
	--self.InforBtn = nil
	--self.Money = nil
	--self.Money1 = nil
	--self.PaneVideo_Full = nil
	--self.PanelBtnBuy = nil
	--self.PanelCommodity = nil
	--self.PanelCommodityFold = nil
	--self.PanelDownload = nil
	--self.PanelDyeing = nil
	--self.PanelInfo = nil
	--self.PanelInteract = nil
	--self.PanelPoster = nil
	--self.PanelPreview = nil
	--self.PanelRoleBtn = nil
	--self.PanelTag = nil
	--self.PanelVideo = nil
	--self.RichTextBoxBlindBoxHint = nil
	--self.StoreRender2D = nil
	--self.TableViewCommodity = nil
	--self.TableViewMountsAction = nil
	--self.TableViewPoster = nil
	--self.TableViewPreview = nil
	--self.TableViewProps = nil
	--self.TableViewSlot = nil
	--self.TextDownload = nil
	--self.TextDyeing = nil
	--self.TextHint = nil
	--self.TextName = nil
	--self.TextPreview = nil
	--self.TextType = nil
	--self.TextUnavailable = nil
	--self.UMGVideoPlayer_UIBP = nil
	--self.UMGVideoPlayer_UIBP_Full = nil
	--self.AnimCommodityFold = nil
	--self.AnimCommodityFoldFullScreenIn = nil
	--self.AnimCommodityFoldFullScreenOut = nil
	--self.AnimCommodityIn = nil
	--self.AnimCommodityUnfold = nil
	--self.AnimIn = nil
	--self.AnimInfoIn = nil
	--self.AnimPosterFullScreenIn = nil
	--self.AnimPosterFullScreenOut = nil
	--self.AnimPreviewRoleAppearanceFalse = nil
	--self.AnimPreviewRoleAppearanceTrue = nil
	--self.AnimTableViewPropsIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnBuyRedDot)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.CommodityExpandPanel)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.Money)
	self:AddSubView(self.Money1)
	self:AddSubView(self.StoreRender2D)
	self:AddSubView(self.UMGVideoPlayer_UIBP)
	self:AddSubView(self.UMGVideoPlayer_UIBP_Full)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewMainPanelView:OnInit()
	self.CommRender2D = self.StoreRender2D:GetCommonRender2D()

	self.EquipTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnEquipPartSelectChanged, true, false)
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCommodity, self.OnGoodListSelectChanged, false, false)
	self.PropsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewProps, self.OnPropsListSelectChanged, true, false)
	self.PosterTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPoster, self.OnPosterSelectChanged, true, false)
	self.MountActionTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMountsAction, self.OnMountActionselectChanged, true, false)
	self.PreviewTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPreview, self.OnPreviewSelectChanged, true, false, true)
	self.CameraFocusCfgMap = CameraFocusCfgMap.New()
	self.Binders = {
		{ "EquipPartList", 				UIBinderUpdateBindableList.New(self, self.EquipTableViewAdapter) },
		--{ "EquipPartList", 				UIBinderUpdateBindableList.New(self, self.PreviewTableViewAdapter) },
		{ "GoodList", 					UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
		{ "GoodList", 					UIBinderUpdateBindableList.New(self, self.PosterTableViewAdapter) },
		{ "PropsList", 					UIBinderUpdateBindableList.New(self, self.PropsTableViewAdapter) },
		{ "MountActionList", 			UIBinderUpdateBindableList.New(self, self.MountActionTableViewAdapter) },
		{ "TittleText", 				UIBinderSetText.New(self, self.CommonTitle.TextTitleName) },
		{ "ProductName", 				UIBinderSetText.New(self, self.TextName) },
		{ "DyeTipsText", 				UIBinderSetText.New(self, self.TextDyeing) },				--- 染色
		{ "UnavailableText", 			UIBinderSetText.New(self, self.TextUnavailable) },			--- 当前性别不可用
		
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelPoster) },
		{ "GoodsExpandPageVisible", 	UIBinderSetIsVisible.New(self, self.PanelCommodity, true) },
		{ "PanelBuyVisible", 			UIBinderSetIsVisible.New(self, self.PanelBtnBuy) },
		{ "PanelBuyVisible", 			UIBinderSetIsVisible.New(self, self.PanelInfo) },
		{ "GoodsExpandPageVisible", 	UIBinderSetIsVisible.New(self, self.CommodityExpandPanel) },
		{ "PanelPropsVisible", 			UIBinderSetIsVisible.New(self, self.TableViewProps) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelCommodityFold, true) },
		{ "DyeCommonInforBtnVisible", 	UIBinderSetIsVisible.New(self, self.BtnInfo) },
		{ "bDyeInforPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelDyeing) },

		--- 购买按钮panel
		{ "BuyBtnText", 				UIBinderSetText.New(self, self.BtnBuy.TextContent) },

		{ "bIsAllCameraState", 			UIBinderSetIsChecked.New(self, self.BtnSwitch) },
		{ "bIsFullScreen", 				UIBinderSetIsChecked.New(self, self.BtnFullScreen) },
		{ "bIsShowHat", 				UIBinderSetIsChecked.New(self, self.BtnHat) },
		{ "bIsShowHatStyle", 			UIBinderSetIsChecked.New(self, self.BtnOrgan) },
		{ "bIsShowRawAvatar", 			UIBinderSetIsChecked.New(self, self.BtnEquipment) },
		{ "bIsShowRawAvatar",           UIBinderValueChangedCallback.New(self, nil, self.OnShowRawAvatarChanged) },
		{ "bIsPlayMountBgm", 			UIBinderSetIsChecked.New(self, self.BtnMusic) },
		{ "bIsShowBtnPose", 			UIBinderSetIsChecked.New(self, self.BtnPose, nil, true) },

		{ "ClothingPagePanelVisible", 	UIBinderSetIsVisible.New(self, self.BtnSwitch, nil, true) },
		{ "ClothingPagePanelVisible", 	UIBinderSetIsVisible.New(self, self.BtnHat, nil, true) },
		{ "ClothingPagePanelVisible", 	UIBinderSetIsVisible.New(self, self.BtnOrgan, nil, true) },
		{ "ClothingPagePanelVisible", 	UIBinderSetIsVisible.New(self, self.BtnEquipment, nil, true) },
		{ "ClothingPagePanelVisible", 	UIBinderSetIsVisible.New(self, self.BtnSwitchPosture, nil, true) },
		{ "MountPagePanelVisible", 		UIBinderSetIsVisible.New(self, self.BtnMusic, nil, true) },
		{ "MountPagePanelVisible", 		UIBinderSetIsVisible.New(self, self.TableViewMountsAction) },
		{ "EquipParVisible", 			UIBinderSetIsVisible.New(self, self.TableViewSlot) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelPreview) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelVideo) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.CommTabs, true) },

		{ "TabSelecteType",             UIBinderValueChangedCallback.New(self, nil, self.OnSelectedTabTypeChanged) },
		{ "GoodsExpandPageVisible",     UIBinderValueChangedCallback.New(self, nil, self.OnGoodsExpandPageVisibleChanged) },
		{ "DyeCommonInforID",           UIBinderValueChangedCallback.New(self, nil, self.OnDyeCommonInforIDChanged) },
		{ "bIsShowHat",                 UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatChanged) },
		{ "bIsShowHatStyle",            UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatStyleChanged) },
		{ "bTagPanelVisible", 			UIBinderSetIsVisible.New(self, self.PanelTag) },
	}

	self.PriceBinders =
	{
		{ "BuyPrice", UIBinderSetTextFormatForScore.New(self, self.Money.TextPrice) },
		{ "RawPrice", UIBinderSetTextFormatForScore.New(self, self.Money.TextOriginalPrice) },
		{ "bShowRawPrice", UIBinderSetIsVisible.New(self, self.Money.PanelOriginalPrice) },
		{ "bShowCoupons", UIBinderSetIsVisible.New(self, self.Money.IconCoupons) },
		{ "BuyPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Money.TextPrice) },
	}
	self.PriceVM = StoreMgr:GetMainPriceVM()

	StoreMgr:GetGiftAllLimit()
	self.IsNeedChangedYOffSet = true
	self.IdlePoseNum = 0
	self.SelectedGoodID = 0
	self.IsNeedGotoMadePanel = false
	self.TextPreview:SetText(LSTR(StoreDefine.LSTRTextKey.PrizePreview))
	self.AttachType = MajorUtil.GetMajorAvatarComponent():GetAttachTypeIgnoreChangeRole()
	-- self.NPCEntityID = StoreMgr:CreatNPCAndGetNPCModelEntityID(self.AttachType)
	self.CurrentModelGender = MajorUtil:GetMajorGender()
	self.IsSwitchedMount = false
	self.PreviewEquipIndex = 1
	self.CurrentShowActorType = ShowActorType.Human
	self.CompanionActor = nil -- 仅为宠物角色的引用，其生命周期由StoreRender2D管理
	self.CompanionCreateCallback = nil
	self.RawSpringArmRotation = nil
	self.AssembleAllEndCallbacks = {} -- 模型加载完后的回调，暂时只有时装展示用
	self.RenderActorCreateCallback = {} -- RenderActor加载完后的回调

	self.Money1.RedDot:SetRedDotIDByID(18)
	self.BtnBuyRedDot:SetIsCustomizeRedDot(true)
	_G.StoreMgr:InitMsteryBoxData(true)
end

function StoreNewMainPanelView:OnDestroy()

end

function StoreNewMainPanelView:OnShow()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
		return
	end
	if RechargingMgr:ShouldShowShopkeeper() then
		RechargingMgr:PreloadScene()
	end
	_G.HUDMgr:SetIsDrawHUD(false)
	_G.LightMgr:EnableUIWeather(2)

	-- 提前请求好友数据，赠礼界面使用
	FriendMgr:SendGetFriendListMsg()

	-- 设置角色原始外观数据
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil ~= RoleSimple then
		self.StoreRender2D:SetRawAvatar(RoleSimple.Avatar)
	end

	self.CommonTitle:SetSubTitleIsVisible(false)
	StoreMgr:InitProductDataByReq()
	_G.HaircutMgr:SendMsgHairQuery()
	self:OnCheckPreViewState()

	-- TLOG上报
	StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.OpenStore, StoreMainVM:GetCurrentMainTabType())

	-- 最后检查跳转，避免被前面的修改所影响
	if nil ~= StoreMainVM.JumpToCategoryIndex then
		self:JumpToGoods()
	end
end

function StoreNewMainPanelView:PostShowView()
	--视频组件全先置为静音
	self.UMGVideoPlayer_UIBP:SetPreviewMode(true)
	self.UMGVideoPlayer_UIBP:SetPlayMovieEndCallBack(self, self.PlayMovieEnd)
	self.UMGVideoPlayer_UIBP_Full:SetPlayMovieEndCallBack(self, self.PlayMovieEnd)
end

function StoreNewMainPanelView:OnCheckPreViewState()
	local IsPreView = false
	self.CommonTitle:SetCommInforBtnIsVisible(not IsPreView)
	UIUtil.SetIsVisible(self.Money1, not IsPreView, true)
	UIUtil.SetIsVisible(self.TextHint, not IsPreView)
	--- 左下区域内
	UIUtil.SetIsVisible(self.TextUnavailable, not IsPreView)
	UIUtil.SetIsVisible(self.TextDyeing, not IsPreView)
	UIUtil.SetIsVisible(self.PanelCommodityFold, false)
	--- 功能按钮
	UIUtil.SetIsVisible(self.BtnFullScreen, not IsPreView, true)
	UIUtil.SetIsVisible(self.BtnHand, IsPreView, true)
	UIUtil.SetIsVisible(self.BtnPose, IsPreView, true)
	UIUtil.SetIsVisible(self.CommMenu, not IsPreView)
	UIUtil.SetIsVisible(self.PanelBtnBuy, not IsPreView)
	UIUtil.SetIsVisible(self.PaneVideo_Full, false)
	self.CommTabs.DefaultSelectByShow = false

	local EntityID = MajorUtil.GetMajorEntityID()
	--- 一些需要赋值的控件，放到这里初始化，预览状态避免不必要的操作
	StoreMgr:UpdateCouponData()
	StoreMainVM:UpdateCouponData()
	---										950005  购买
	self.CommTabs:UpdateItems({{Name = LSTR(950005)}, {Name = LSTR(StoreDefine.LSTRTextKey.GiftTittleText)}}, 1)
	UIUtil.SetIsVisible(self.CommodityExpandPanel, false)		--- 检查控件状态  展开-道具 等
	self.TextHint:SetText(LSTR(StoreDefine.LSTRTextKey.TittleHintText))
	self.Money1:UpdateView(SCORE_TYPE.SCORE_TYPE_STAMPS, true, UIViewID.StoreNewMainPanel, true)
	self:CreateRenderActor(EntityID, nil ~= StoreMainVM.JumpToGoodsID)
end

function StoreNewMainPanelView:OnShowRawAvatarChanged()
	self.StoreRender2D:SetRawEquipsVisible(StoreMainVM.bIsShowRawAvatar)
end

--- 点击装备部位
function StoreNewMainPanelView:OnEquipPartSelectChanged(Index, ItemData, ItemView, bIsByClick)
	if ItemView ~= nil and ItemView.IsClickBtnView then
		if not ItemData.SelectBtnState then
			self.StoreRender2D:TakeOffAppear(ItemData.Part, true)
		else
			--- 预览时隐藏其他相同部位装备
			local EquipPartList = StoreMainVM.EquipPartList.Items
			for _, value in ipairs(EquipPartList) do
				if value.Part == ItemData.Part then
					value.SelectBtnState = true
					value.IsMask = true
				end
			end
			self.StoreRender2D:WearAppearance(ItemData)
		end
		ItemData.SelectBtnState = not ItemData.SelectBtnState
		ItemData.IsMask = ItemData.SelectBtnState or ItemData.bOwned
		ItemView.IsClickBtnView = false
	else
		--- 切换部位镜头
		self:FocusView(ItemData.Part)
		if ItemData.Part == ProtoCommon.equip_part.EQUIP_PART_BODY_HAIR then
			if StoreMainVM.TabSelecteType == StoreMall.STORE_MALL_MYSTERYBOX then
				UIUtil.SetIsVisible(self.TextType, true)
				self.TextType:SetText(ItemData.Name)
			end
		end
		self.StoreRender2D:WearAppearance(ItemData)
		self.PreviewEquipIndex = Index
		StoreMainVM.bIsAllCameraState = false
		-- ItemData.IsMask = ItemData.bOwned
		if ItemData.SelectBtnState then
			--- 预览时隐藏其他相同部位装备
			local EquipPartList = StoreMainVM.EquipPartList.Items
			for _, value in ipairs(EquipPartList) do
				if value.Part == ItemData.Part then
					value.SelectBtnState = true
					value.IsMask = true
				end
			end
		end
		ItemData.SelectBtnState = false	--- 切换时强制显示
		if StoreMainVM.CurrentSelectedTabType ~= StoreMall.STORE_MALL_MYSTERYBOX then
			ItemData.IsMask = false
		end
		StoreMainVM:ChangeEquipPart(nil, false)
		StoreMainVM:ChangeEquipPart(Index, true)
	end

	if bIsByClick then
		StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.PreviewBodyPart, StoreMainVM:GetCurrentMainTabType(),
			nil, StoreMainVM:GetCurrentGoodsID(), ItemData.Part)
	end
end

--- 选中商品
function StoreNewMainPanelView:OnGoodListSelectChanged(Index, ItemData, ItemView, bIsByClick)
	StoreMainVM.bIsAllCameraState = true		--- 切换商品时重置按钮状态
	StoreMainVM:ChangeEquipPart(nil, false)
	-- StoreMainVM.bUseCoupon = true
	StoreMainVM:ChangeGood(Index)
	ItemData.bSelected = true
	self.PreviewEquipIndex = 1
	local bCurrentTabIsPet = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_PET
	if bCurrentTabIsPet then
		self:UpdateCompanionModel(ItemData)
	end
	do
		StoreMainVM.CurrentSelectedItem = self.GoodsTableViewAdapter:GetItemDataByIndex(Index)
		local bCurrentTabIsMount = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MOUNT
		self:OnInitBtnState(ItemData)
		StoreMainVM:InitBuyView()
		StoreMainVM:UpdateCouponData()
		StoreMainVM:CacheSelectedGoodsForCategory(StoreMainVM.TabSelecteIndex, ItemData.GoodID)
		if not bCurrentTabIsMount and not bCurrentTabIsPet then
			if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
				self.StoreRender2D:WearSuit({})
			else
				if ItemData.GenderLimit == 0 or ItemData.GenderLimit == self.CurrentModelGender then
					-- if self.SelectedGoodID ~= ItemData.GoodID then
					self:WearSuit()
					-- end
				else
					-- self:OnUpdateNPCModel() -- 异性服装逻辑待重构
				end
			end
			if self:IsViewFirstPartByDefault(ItemData.GoodID) then
				self.EquipTableViewAdapter:SetSelectedIndex(1)	--- 单件时默认选中部位
			else
				if StoreMainVM.CurrentSelectedTabType ~= StoreMall.STORE_MALL_MOUNT then
					self:CheckFocusFullBody()
				end
			end
		end
		self:OnShowMount(bCurrentTabIsMount)
		self.IsNeedGotoMadePanel = false
		if bCurrentTabIsMount and ItemData.IsOwned and self.MountID and _G.MountMgr:IsCustomMadeEnabled(self.MountID) then
			StoreMainVM.BuyBtnText = LSTR(950054)	--- 个性定制
			self.IsNeedGotoMadePanel = true

			-- 个性定制红点
			if self.BtnBuyRedDot.ItemVM == nil then
				self.BtnBuyRedDot:InitData()
			end
			self.BtnBuyRedDot:SetRedDotUIIsShow(MountCustomMadeVM:MountIsNew(self.MountID))

			self.BtnBuy:SetIsRecommendState(true)
		else
			local IsOwned = ItemData.StateTextVisible and ItemData.GoodStateText == LSTR(StoreDefine.SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER])
			if IsOwned then
				self.BtnBuy:SetIsDoneState(true)
			else
				self.BtnBuy:SetIsRecommendState(true)
			end

			StoreMainVM.BuyBtnText = IsOwned and LSTR(StoreDefine.SecondScreenType.Owned) or LSTR(StoreDefine.StoreModeText[StoreMainVM.CurrentStoreMode])
		end
	end
	self:PlayStagePose(ItemData.GoodID)
	self.SelectedGoodID = ItemData.GoodID
	UIUtil.SetIsVisible(self.BtnBuy.Button, true, true) -- 保证按钮可点击
	UIUtil.SetIsVisible(self.BtnTag1, StoreMainVM.ImgTag1Visible, true)
	UIUtil.SetIsVisible(self.BtnTag2, StoreMainVM.ImgTag2Visible, true)
	UIUtil.ButtonSetBrush(self.BtnTag1, StoreMainVM.ImgTag1Path)
	UIUtil.ButtonSetBrush(self.BtnTag2, StoreMainVM.ImgTag2Path)
	UIUtil.SetIsVisible(self.Money, StoreMainVM.JumpID == 0 and not ItemData.IsOwned, nil, true)
	self:UpdateVideoWidget(ItemData.VideoPath)
	if bIsByClick then
		if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
			StoreUtil.ReportPurchaseClickFlow(ItemData.GoodID, StoreDefine.PurchaseOperationType.SelectGoods)
		else
			StoreUtil.ReportGiftClickFlow(ItemData.GoodID, StoreDefine.GiftOperationType.SelectGoods)
		end
	end
end

-- 是否默认选中第一个部位
function StoreNewMainPanelView:IsViewFirstPartByDefault(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData then
		return false
	end
	local DefaultCameraIndex = GoodsCfgData.DefaultViewType
	if DefaultCameraIndex == ProtoRes.StoreViewType.StoreViewTypeFullBody then
		return false
	elseif DefaultCameraIndex == ProtoRes.StoreViewType.StoreViewTypePart then
		return true
	end
	return nil ~= StoreMainVM.EquipPartList and StoreMainVM.EquipPartList:Length() == 1
end

--- 选中道具
function StoreNewMainPanelView:OnPropsListSelectChanged(Index, ItemData, ItemView, bIsByClick)
	StoreMainVM:OnClickProps(Index)
	StoreMainVM:InitMultiBuyView()
	if nil == ItemData then
		return
	end
	if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		_G.UIViewMgr:ShowView(_G.UIViewID.StoreBuyPropsWin)
	else
		_G.UIViewMgr:ShowView(_G.UIViewID.StoreGiftChooseFriendWin, {GoodsID = ItemData.GoodsId})
	end
	if bIsByClick then
		if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
			StoreUtil.ReportPurchaseClickFlow(ItemData.GoodsId, StoreDefine.PurchaseOperationType.SelectGoods)
		else
			StoreUtil.ReportGiftClickFlow(ItemData.GoodsId, StoreDefine.GiftOperationType.SelectGoods)
		end
	end
end

--- 选中推荐页道具
function StoreNewMainPanelView:OnPosterSelectChanged(Index, ItemData, ItemView, bIsByClick)
	local Items = ItemData.Items
	local PreviewItems = {}
	for i = 1, #Items do
		if Items[i].ID > 0 then
			table.insert(PreviewItems, Items[i])
		end
	end
	ItemData.bSelected = true
	local IsHairBox = ItemData.Type == StoreMall.STORE_MALL_MYSTERYBOX and ItemData.Type ~= nil
	UIUtil.SetIsVisible(self.PanelPreview, #PreviewItems > 1 and not IsHairBox)
	-- UIUtil.SetIsVisible(self.TableViewSlot, #PreviewItems > 1 or IsHairBox)
	StoreMainVM.EquipParVisible = #PreviewItems > 1 or IsHairBox
	self.PreviewTableViewAdapter:UpdateAll(PreviewItems)
	self:OnInitBtnState(ItemData)
	StoreMainVM:ChangeGood(Index)
	StoreMainVM:InitBuyView()
	StoreMainVM:CacheSelectedGoodsForCategory(StoreMainVM.TabSelecteIndex, ItemData.GoodID)
	UIUtil.SetIsVisible(self.Money, StoreMainVM.JumpID == 0 and not ItemData.IsOwned, nil, true)
	self:UpdateVideoWidget(ItemData.VideoPath)
	self.PreviewTableViewAdapter:SetSelectedIndex(1)
	if IsHairBox then
		if StoreMainVM.bIsShowHat then
			self:OnChangedToggleBtnHat()
		end

		StoreMainVM.bIsShowRawAvatar = true
		self.StoreRender2D:SetRawEquipsVisible(StoreMainVM.bIsShowRawAvatar)
		self.StoreRender2D:WearSuit({})
		self:WearSuit()
		self:OnSelectEquipList()
		self.RichTextBoxBlindBoxHint:SetText(ItemData.IsOwned and "" or string.format(ItemData.Desc, MysterBoxMaxBoughtCount - StoreMgr:GetMysterBoxBoughtCountByID(ItemData.MysterID)))
	else
		self.RichTextBoxBlindBoxHint:SetText("")
	end
	--- 950086  奇遇盲盒按钮文本：购买一次
	local IsOwned = ItemData.IsOwned
	local GoodsID = ItemData.GoodID
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	local BtnText = ""
	if nil ~= GoodsCfgData then
		BtnText = GoodsCfgData.BtnText
	end
	StoreMainVM.BuyBtnText = IsOwned and LSTR(StoreDefine.SecondScreenType.Owned) or ItemData.Type == StoreMall.STORE_MALL_MYSTERYBOX and LSTR(950086) or
		BtnText ~= "" and BtnText or LSTR(StoreDefine.StoreModeText[StoreDefine.StoreMode.Buy])
	self.BtnBuy:SetColorType(IsOwned and CommBtnColorType.Done or CommBtnColorType.Recommend)
	UIUtil.SetIsVisible(self.BtnBuy.Button, true, not IsOwned)
	if bIsByClick then
		if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
			StoreUtil.ReportPurchaseClickFlow(GoodsID, StoreDefine.PurchaseOperationType.SelectGoods)
		else
			StoreUtil.ReportGiftClickFlow(GoodsID, StoreDefine.GiftOperationType.SelectGoods)
		end
	end
end

--- 切换大奖预览
function StoreNewMainPanelView:ChangedPreview(TempCfg)
	if nil == TempCfg then
		return
	end

	StoreMainVM.ClothingPagePanelVisible = TempCfg.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION
	StoreMainVM.EquipParVisible = TempCfg.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION
	StoreMainVM.MountPagePanelVisible = TempCfg.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_MOUNT
	local NewShowActorType = ShowActorType.Human
	if StoreMainVM.MountPagePanelVisible then
		NewShowActorType = ShowActorType.Mount
		local TempItemCfg = ItemCfg:FindCfgByKey(TempCfg.Items[1].ID)
		if TempItemCfg ~= nil then
			local Func = FuncCfg:FindCfgByKey(TempItemCfg.UseFunc)
			if Func ~= nil then
				local MountID = Func.Func[1].Value[1]
				if MountID ~= nil then
					self:OnUpdateMontSkillList(MountID)
					self.MountID = MountID
					if StoreMainVM.bIsPlayMountBgm then
						self:PlayMountBGM(MountID)
					end
					self:RideMount(MountID)
				end
			end
		end
	else
		self:StopMountBGM()
		if TempCfg.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION then
			StoreMainVM:UpdateEquipPartList(TempCfg)
			if self:IsViewFirstPartByDefault(TempCfg.ID) then
				self.EquipTableViewAdapter:SetSelectedIndex(1)	--- 单件时默认选中部位
			else
				self:CheckFocusFullBody()
			end
			self:WearSuit()
		elseif TempCfg.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_PET then
			NewShowActorType = ShowActorType.Companion
			self:UpdateCompanionModel(TempCfg)
		end
	end
	self:UpdateCurrentShowActorType(NewShowActorType)
	if TempCfg.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION then
		self:PlayStagePose(TempCfg.ID)
	end
	self:UpdateVideoWidget(TempCfg.VideoPath)
end

--- 坐骑技能
function StoreNewMainPanelView:OnMountActionselectChanged(Index, ItemData, ItemView, bIsByClick)
end

--- 大奖预览
function StoreNewMainPanelView:OnPreviewSelectChanged(Index, ItemData, ItemView, bIsByClick)
	local GoodsCfgData = StoreCfg:FindCfgByKey(ItemData.ID)
	if nil ~= GoodsCfgData then
		self:ChangedPreview(GoodsCfgData)
	end
end

--- 切换菜单
function StoreNewMainPanelView:OnMenuTreeViewTabsSelectChanged(Index, ItemData, ItemView, MainKey, SubKey, bIsByClick)
	local OldTabType = StoreMainVM.TabSelecteType
	self.RichTextBoxBlindBoxHint:SetText("")
	UIUtil.SetIsVisible(self.TextType, false)
	StoreMainVM:ChangeTab(MainKey, SubKey)
	-- 与TabSelecteType更新相关的逻辑如果不依赖商品列表更新，可以放到OnSelectedTabTypeChanged中
	do
		if StoreMainVM.TabSelecteType == StoreMall.STORE_MALL_MOUNT then
			self.IsSwitchedMount = true
		end
		--- 道具/推荐/奇遇盲盒  隐藏物品tableview
		UIUtil.SetIsVisible(self.PanelCommodityFold, StoreMainVM.TabSelecteType ~= StoreMall.STORE_MALL_PROPS and StoreMainVM.TabSelecteType ~= StoreMall.STORE_MALL_RECOMMEND and StoreMainVM.TabSelecteType ~= StoreMall.STORE_MALL_MYSTERYBOX)
		UIUtil.SetIsVisible(self.InforBtn, StoreMainVM.TabSelecteType == StoreMall.STORE_MALL_MYSTERYBOX, true)
		if StoreMainVM.TabSelecteType == StoreMall.STORE_MALL_MYSTERYBOX then
			self:UpdateVideoWidget()
			UIUtil.SetIsVisible(self.BtnSwitch, true, true)
			UIUtil.SetIsVisible(self.BtnHat, true, true)
			if StoreMainVM.bIsShowHat then
				self:OnChangedToggleBtnHat()
			end

			self.CommRender2D:HideWeapon(true)
			StoreMainVM.bIsShowRawAvatar = true
			self:StopMountBGM()
			self.IsNeedGotoMadePanel = false
		else
			UIUtil.SetIsVisible(self.BtnSwitch, StoreMainVM.ClothingPagePanelVisible, true)
			UIUtil.SetIsVisible(self.BtnHat, StoreMainVM.ClothingPagePanelVisible, true)
		end
	end

	--这里恢复被动画拉走的UI组件
	if nil ~= StoreMainVM.TabSelecteType then
		self.PanelBtnBuy:SetRenderOpacity(HideBuyBtnConfig[StoreMainVM.TabSelecteType] and 0 or 1.0)
		UIUtil.SetIsVisible(self.PanelBtnBuy, not HideBuyBtnConfig[StoreMainVM.TabSelecteType])
	end
	if StoreMainVM.PanelBuyVisible then
		self:PlayAnimation(self.AnimInfoIn)
	else
		self:StopAnimation(self.AnimInfoIn)
		self:PlayAnimation(self.AnimInfoIn, 0, 1, UE.EUMGSequencePlayMode.Reverse, 1.0, false)
	end
	self:PlayAnimation(StoreMgr:CheckMallTypeByIndex(MainKey,
					   StoreMall.STORE_MALL_PROPS) and self.AnimTableViewPropsIn or self.AnimCommodityIn)
	if bIsByClick and nil ~= OldTabType and OldTabType ~= StoreMainVM.TabSelecteType then
		StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.SwitchTab, StoreMainVM.TabSelecteType, OldTabType)
	end
end

-- 商品大类切换
function StoreNewMainPanelView:OnSelectedTabTypeChanged(NewTabType)
	-- 切换展示角色
	local NewShowActorType = ShowActorType.None
	if NewTabType == StoreMall.STORE_MALL_PET then
		NewShowActorType = ShowActorType.Companion
	elseif NewTabType == StoreMall.STORE_MALL_MOUNT then
		NewShowActorType = ShowActorType.Mount
	elseif NewTabType == StoreMall.STORE_MALL_RECOMMEND or NewTabType == StoreMall.STORE_MALL_CLOTHING or
		NewTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		NewShowActorType = ShowActorType.Human
	end
	self:UpdateCurrentShowActorType(NewShowActorType)

	-- 全屏按钮显隐
	UIUtil.SetIsVisible(self.BtnFullScreen, NewTabType ~= StoreMall.STORE_MALL_PROPS, true)
end

function StoreNewMainPanelView:OnGoodsExpandPageVisibleChanged(bVisible)
	if nil ~= self.CommRender2D.ChildActor then
		self.CommRender2D.ChildActor:SetActorVisibility(not bVisible, UE.EHideReason.Disable)
	end
	if nil ~= self.CompanionActor then
		self.CompanionActor:SetActorVisibility(not bVisible, UE.EHideReason.Disable)
	end
end

function StoreNewMainPanelView:OnDyeCommonInforIDChanged(InforID)
	self.CommInforBtn:SetHelpInfoID(InforID)
end

function StoreNewMainPanelView:OnIsShowHatChanged(bIsShowHat)
	self.CommRender2D:HideHead(not bIsShowHat)
	if bIsShowHat then
		self.CommRender2D:SwitchHelmet(StoreMainVM.bIsShowHatStyle)
	end
end

function StoreNewMainPanelView:OnIsShowHatStyleChanged(bIsShowHatStyle)
	-- if self.bBtnHatStyleDisabled then StoreMainVM.bIsShowHatStyle = false end    --- 禁用头部装饰功能  暂时不做
	self.CommRender2D:SwitchHelmet(not bIsShowHatStyle)
end

function StoreNewMainPanelView:OnClickBenExpand()
	local bExpandPageVisible = not StoreMainVM.GoodsExpandPageVisible
	self:OnRefreshGoodsSelected()
	if not bExpandPageVisible then
		StoreMainVM.PanelGoodsVisible = true
		self:OnGoodsExpandPageVisibleChanged(false) --提前一点执行早点显示角色
		self:PlayAnimation(self.AnimCommodityFold)
		self:RegisterTimer(function() StoreMainVM.GoodsExpandPageVisible = false end, self.AnimCommodityFold:GetEndTime())
	else
		StoreMainVM.GoodsExpandPageVisible = true
		self:PlayAnimation(self.AnimCommodityUnfold)
		self:RegisterTimer(function() StoreMainVM.PanelGoodsVisible = false end, self.AnimCommodityUnfold:GetEndTime())
	end
	local _, SelectedIndex = self.GoodsTableViewAdapter:GetItemDataByPredicate(
		function(VM) return VM.GoodID == StoreMainVM:GetCurrentGoodsID() end)
	SelectedIndex = SelectedIndex or 1
	self.GoodsTableViewAdapter:ScrollToIndex(SelectedIndex % 2 == 0 and SelectedIndex - 1 or SelectedIndex)
end

---@type 点击充值
function StoreNewMainPanelView:OnClickRecharge()
	RechargingMgr:ShowMainPanel()
end

function StoreNewMainPanelView:OnHide()
	self:StopMountBGM()
	_G.HUDMgr:SetIsDrawHUD(true)
	self.BtnHand:SetIsChecked(true)
	RechargingMgr:DestroyScene()
	self:OnInitBtnState()
	StoreMainVM.bIsPlayMountBgm = true
	StoreMainVM.JumpToCategoryIndex = nil
	StoreMainVM.TabSelecteIndex = 1
	StoreMainVM.SelectedGoods = {}
	StoreMainVM.GoodFilterDataList = nil
	StoreMainVM.bIsFullScreen = false
	StoreMainVM.GoodsExpandPageVisible = false
	StoreMainVM.CurrentSelectedTabType = ProtoRes.StoreMall.STORE_MALL_INVALID
	self.SelectedGoodID = 0
	_G.LightMgr:DisableUIWeather()
	if self.BackgroundActor then
		CommonUtil.DestroyActor(self.BackgroundActor)
    end
    self.BackgroundActor = nil
	self.RenderActorCreateCallback = {}
	_G.StoreMgr:UnRegisterAllTimer()
end

function StoreNewMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnMenuTreeViewTabsSelectChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnExpand, self.OnClickBenExpand)
	UIUtil.AddOnClickedEvent(self, self.CommodityExpandPanel.BtnExpand, self.OnClickBenExpand)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickBuy)
	UIUtil.AddOnClickedEvent(self, self.BtnSwitchPosture, self.OnClickBtnSwitchPosture)
	UIUtil.AddOnClickedEvent(self, self.BtnTag1, self.OnClickBtnTag1)
	UIUtil.AddOnClickedEvent(self, self.BtnTag2, self.OnClickBtnTag2)
	UIUtil.AddOnClickedEvent(self, self.Btn_Video, self.OnClickBtn_Video)
	UIUtil.AddOnClickedEvent(self, self.UMGVideoPlayer_UIBP_Full.CloseButton, self.OnClick_Full_Close)
	self.CommTabs:SetCallBack(self, self.OnChangedPurchaseMethod)
	self.InforBtn:SetCallback(self, self.OnClickInforBtn)

	UIUtil.AddOnStateChangedEvent(self, self.BtnFullScreen, self.OnChangedToggleBtnFullScreen)
	UIUtil.AddOnStateChangedEvent(self, self.BtnSwitch, self.OnChangedToggleBtnSwitch)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHat, self.OnChangedToggleBtnHat)
	UIUtil.AddOnStateChangedEvent(self, self.BtnOrgan, self.OnChangedToggleBtnOrgan)
	UIUtil.AddOnStateChangedEvent(self, self.BtnEquipment, self.OnChangedToggleBtnEquipment)
	UIUtil.AddOnStateChangedEvent(self, self.BtnMusic, self.OnChangedToggleBtnMusic)
	UIUtil.AddOnStateChangedEvent(self, self.BtnPose, self.OnChangedBtnPose)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHand, self.OnChangedBtnHand)
	
	self.CommRender2D:SetClick(self, self.OnRender2DClicked)
end

function StoreNewMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.StoreRefreshGoods, self.OnRefreshGoods)
	self:RegisterGameEvent(EventID.StoreRefreshGoodsSelected, self.OnRefreshGoodsSelected)
	self:RegisterGameEvent(EventID.StoreUpdateTabListByTimer, self.OnStoreUpdateTabListByTimer)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.CompanionCreate, self.OnCompanionCreated)
	self:RegisterGameEvent(EventID.StoreUpdateBlindText, self.OnStoreUpdateBlindText)
	self:RegisterGameEvent(EventID.UpdateScore, self.OnScoreUpdate)
	self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function StoreNewMainPanelView:OnRegisterBinder()
	self:RegisterBinders(StoreMainVM, self.Binders)
	self:RegisterBinders(self.PriceVM, self.PriceBinders)
end

function StoreNewMainPanelView:OnRefreshGoods()
	StoreMainVM:UpdateProductList()
end

function StoreNewMainPanelView:OnAssembleAllEnd(Params)
	local bIsStoreActorAssembled = false
	if Params.ULongParam1 == self.StoreRender2D.CompanionEntityID then
		bIsStoreActorAssembled = true
		local AvatarComp = ActorUtil.GetActorAvatarComponent(self.StoreRender2D.CompanionEntityID)
		if nil ~= AvatarComp then
			AvatarComp:SetForcedLODForAll(1)
		end
		self.StoreRender2D:InitCompanionTransform()
		AnimMgr:PlayActionTimeLine(self.StoreRender2D.CompanionEntityID, CompanionPopATLPath)
		-- 假阴影捕捉角色更新
		if self.CurrentShowActorType == ShowActorType.Companion then
			self.StoreRender2D:UpdateShadowTarget(self.StoreRender2D:GetCompanion())
		end
	end

	if Params.ULongParam1 == ActorUtil.GetActorEntityID(self.CommRender2D.ChildActor) then
		bIsStoreActorAssembled = true
		if self.bFirstAvatarAssemble then
			self.CommRender2D.ChildActor:StartFadeIn(0.7, true)
			self.bFirstAvatarAssemble = false
		end
		if self.CurrentShowActorType == ShowActorType.Mount then
			self.CommRender2D:SetRideMeshComponent()
			self.StoreRender2D:InitMountTransform()
			if nil ~= self.CommRender2D.ChildActor then
				self.CommRender2D.ChildActor:GetAnimationComponent():SetSitBlendOutTime(0)
			end
		else
			self.CommRender2D:UpdateAllLights()
			if next(self.AssembleAllEndCallbacks) then
				for _, Callback in ipairs(self.AssembleAllEndCallbacks) do
					Callback()
				end
				self.AssembleAllEndCallbacks = {}
			end
		end
	end

	if bIsStoreActorAssembled then
		self:CheckActorsVisibility()
		self:CheckShadowType()
	end
end

function StoreNewMainPanelView:OnCompanionCreated(Params)
	if self.StoreRender2D.CompanionEntityID ~= Params.ULongParam1 then
		return
	end
	local CompanionActor = self.StoreRender2D:GetCompanion()
	if nil ~= CompanionActor then
		self.CompanionActor = CompanionActor
		self:CheckActorsVisibility()
		self:CheckInteractTarget()
	end
end

--- 刷新盲盒购买后n次获得所有奖励
function StoreNewMainPanelView:OnStoreUpdateBlindText(Params)
	local MysteryboxCfg = require("TableCfg/MysteryboxCfg")
	local BlindBoxID = Params.BlindBoxID
	local DrawCount = Params.DrawCount
	local ItemData = MysteryboxCfg:FindCfgByKey(BlindBoxID)
	if not ItemData then return end

	if StoreMainVM.GoodSelecteIndex and StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex] then
		local GoodData = StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex]
		if not GoodData or not GoodData.Cfg or GoodData.Cfg.ID ~= BlindBoxID then return end

		if MysterBoxMaxBoughtCount - DrawCount > 0 then
			self.RichTextBoxBlindBoxHint:SetText(string.format(ItemData.Desc, MysterBoxMaxBoughtCount - DrawCount))
		else
			self.RichTextBoxBlindBoxHint:SetText("")
		end
	end
end

function StoreNewMainPanelView:OnScoreUpdate(Params)
	if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		return
	end
	local GoodsCfgData = StoreMainVM:GetCurrentGoodsCfgData()
	local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
	if nil ~= MainPriceVM then
		MainPriceVM:UpdatePriceData(GoodsCfgData, self.CurrentStoreMode == StoreDefine.StoreMode.Buy, true)
	end
end

function StoreNewMainPanelView:OnGameEventAppEnterBackground(Params)
	FLOG_INFO("StoreNewMainPanelView:OnGameEventAppEnterBackground")
	if self.UMGVideoPlayer_UIBP then
		self.UMGVideoPlayer_UIBP:OnPause()
	end
	if self.UMGVideoPlayer_UIBP_Full then
		self.UMGVideoPlayer_UIBP_Full:OnPause()
	end
end

function StoreNewMainPanelView:OnGameEventAppEnterForeground(Params)
	FLOG_INFO("StoreNewMainPanelView:OnGameEventAppEnterForeground")
	--商城没有暂停
	if self.UMGVideoPlayer_UIBP then
		self.UMGVideoPlayer_UIBP:OnResume()
	end
	if self.UMGVideoPlayer_UIBP_Full then
		self.UMGVideoPlayer_UIBP_Full:OnResume()
	end
end

function StoreNewMainPanelView:OnRefreshGoodsSelected()
	if StoreMainVM.bPendingJumpToGoods then
		if self:JumpToGoods() then
			return
		end
	end
	local SelectedGoods = StoreMainVM.JumpToGoodsID or StoreMainVM.SelectedGoods[StoreMainVM:GetCurrentMainTabType()]
	local _, Index = self.GoodsTableViewAdapter:GetItemDataByPredicate(
		function(VM) return VM.GoodID == SelectedGoods end)
	Index = Index or 1
	if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_RECOMMEND or StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		self.PosterTableViewAdapter:CancelSelected()
		self.PosterTableViewAdapter:SetSelectedIndex(Index)
		-- TableView异步加载时ScrollToIndex存在问题，通过延迟调用临时解决，待系统侧修复后复原
		self:RegisterTimer(function() self.PosterTableViewAdapter:ScrollToIndex(Index) end, 0.01)
	else
		self.GoodsTableViewAdapter:SetSelectedIndex(0) -- 保证列表更新后正常选中
		self.GoodsTableViewAdapter:SetSelectedIndex(Index)
		self:RegisterTimer(function() self.GoodsTableViewAdapter:ScrollToIndex(Index) end, 0.01)
	end
end

function StoreNewMainPanelView:OnStoreUpdateTabListByTimer()
	self.CommMenu:UpdateItems(StoreMainVM.TabList, false)

	if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		local GoodData
		if StoreMainVM.GoodSelecteIndex and StoreMainVM.GoodFilterDataList and StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex] then
			GoodData = StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex]
		end

		local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
		if MainPriceVM and GoodData.Cfg then
			MainPriceVM:UpdatePriceData(GoodData.Cfg, false, false)
			UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
			StoreMainVM:UpdateGoodList(StoreMainVM.GoodFilterDataList)
		end
	end
end

--- 获取途径跳转
function StoreNewMainPanelView:JumpToGoods()
	if nil == StoreMainVM.JumpToCategoryIndex then
		return false
	end

	-- 默认切换到购买模式
	-- _G.StoreMainVM:OnChangedPurchaseMethod(StoreDefine.StoreMode.Buy + 1)
	if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
		self.CommTabs:SetSelectedIndex(StoreDefine.StoreMode.Buy + 1)
	end
	local MenuKey = _G.StoreMainVM:GetDefaultMenuKey(_G.StoreMainVM.JumpToCategoryIndex)
	self.CommMenu:SetSelectedKey(MenuKey, true)

	local bJumpSucceeded = false
	if StoreMgr:CheckMallTypeByIndex(StoreMainVM.JumpToCategoryIndex, StoreMall.STORE_MALL_PROPS) then
		local Predicate = function(VM)
			return VM.GoodsId == StoreMainVM.JumpToGoodsID
		end
		local _, Index = self.PropsTableViewAdapter:GetItemDataByPredicate(Predicate)
		bJumpSucceeded = nil ~= Index
		if bJumpSucceeded then
			-- TableView异步加载时ScrollToIndex存在问题，通过延迟调用临时解决，待系统侧修复后复原
			self:RegisterTimer(function() self.PropsTableViewAdapter:ScrollToIndex(Index) end, 0.1)
			if StoreMainVM.bIsOpenBuyWinPanel then
				self.PropsTableViewAdapter:SetSelectedIndex(Index)
			end
		end
	else
		local TableViewAdapter = StoreMainVM.PosterPanelVisible and self.PosterTableViewAdapter or self.GoodsTableViewAdapter
		local Predicate = function(VM)
			return VM.GoodID == StoreMainVM.JumpToGoodsID
		end
		local _, Index = TableViewAdapter:GetItemDataByPredicate(Predicate)
		bJumpSucceeded = nil ~= Index
		if bJumpSucceeded then
			-- TableView异步加载时ScrollToIndex存在问题，通过延迟调用临时解决，待系统侧修复后复原
			self:RegisterTimer(function() TableViewAdapter:ScrollToIndex(Index) end, 0.1)
			TableViewAdapter:SetSelectedIndex(0)
			TableViewAdapter:SetSelectedIndex(Index)
			if StoreMainVM.bIsOpenBuyWinPanel then
				self:OnClickBuy()
			end
		end
	end

	if bJumpSucceeded then
		-- 跳转成功后清空跳转数据
		StoreMainVM.JumpToCategoryIndex = nil
		StoreMainVM.JumpToGoodsID = nil
		StoreMainVM.bIsOpenBuyWinPanel = true
		StoreMainVM.bPendingJumpToGoods = false
	else
		-- 商品列表尚未刷新，待异步刷新后再跳转到商品
		StoreMainVM.bPendingJumpToGoods = true
	end

	return bJumpSucceeded
end

function StoreNewMainPanelView:OnChangedToggleBtnFullScreen(ToggleGroup, ToggleButton, BtnState)
	local State = BtnState == _G.UE.EToggleButtonState.Unchecked
	StoreMainVM.bIsFullScreen = State
	local AnimIn = (StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_RECOMMEND or StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX) and self.AnimPosterFullScreenIn or self.AnimCommodityFoldFullScreenIn
	local AnimOut = (StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_RECOMMEND or StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX) and self.AnimPosterFullScreenOut or self.AnimCommodityFoldFullScreenOut
	self:PlayAnimation(State and AnimIn or AnimOut)
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickFullScreen)
end

--- 全/半身视角切换
function StoreNewMainPanelView:OnChangedToggleBtnSwitch(ToggleGroup, ToggleButton, BtnState)
	StoreMainVM.bIsAllCameraState = BtnState == _G.UE.EToggleButtonState.Unchecked
	if not StoreMainVM.bIsAllCameraState then
		--- 上一次选中的部位镜头
		-- self.EquipTableViewAdapter:SetSelectedIndex(self.PreviewEquipIndex)
		local TempEquipItem = self.EquipTableViewAdapter:GetItemDataByIndex(self.PreviewEquipIndex)
		StoreMainVM:ChangeEquipPart(self.PreviewEquipIndex, true)
		self:FocusView(TempEquipItem.Part)
	else
		--- 全身镜头
		self.StoreRender2D:ResetView(true)
	end
	-- self.CommRender2D:EnableZoom(false)
	self.IsNeedChangedYOffSet = true
end

--- 头盔显隐  默认显示
function StoreNewMainPanelView:OnChangedToggleBtnHat(ToggleButton, BtnState)
	StoreMainVM.bIsShowHat = not StoreMainVM.bIsShowHat
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickHelmetHide)
end

--- 头部装备特殊效果
function StoreNewMainPanelView:OnChangedToggleBtnOrgan(ToggleButton, BtnState)
	StoreMainVM.bIsShowHatStyle = not StoreMainVM.bIsShowHatStyle
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickHelmetGimmick)
end

--- 素体
function StoreNewMainPanelView:OnChangedToggleBtnEquipment(ToggleButton, BtnState)
	StoreMainVM.bIsShowRawAvatar = not StoreMainVM.bIsShowRawAvatar
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickRawEquipment)
end

--- 坐骑BGM播放/停止
function StoreNewMainPanelView:OnChangedToggleBtnMusic(ToggleButton, BtnState)
	StoreMainVM.bIsPlayMountBgm = not StoreMainVM.bIsPlayMountBgm
	if StoreMainVM.bIsPlayMountBgm then
		if nil ~= StoreMainVM.CurrentSelectedItem then
			self:PlayMountBGM(self.MountID)
		end
	else
		self:StopMountBGM()
	end
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickMountBGM)
end

--- 武器拔出/收起状态   默认收起
function StoreNewMainPanelView:OnChangedBtnPose(ToggleGroup, ToggleButton, BtnState)
	StoreMainVM.bIsShowBtnPose = BtnState ~= _G.UE.EToggleButtonState.Unchecked
	self.CommRender2D:HoldOnWeapon(not StoreMainVM.bIsShowBtnPose)
end

function StoreNewMainPanelView:OnChangedBtnHand(ToggleGroup, ToggleButton, BtnState)
	self.CommRender2D:HideWeapon(BtnState ~= _G.UE.EToggleButtonState.Unchecked)
end

--- 点击购买
function StoreNewMainPanelView:OnClickBuy()
	local GoodsCfgData = StoreMainVM.SkipTempData
	local bIsJump = StoreMainVM.JumpID ~= 0 or (nil ~= GoodsCfgData and GoodsCfgData.ProductType ==
		ProtoRes.StoreRecommendType.STORE_RECOMMEND_TYPE_PURCHASE) -- 待拆推荐表
	if nil ~= StoreMainVM.SkipTempData and nil ~= StoreMainVM.SkipTempData.LabelMain and
		StoreMainVM.SkipTempData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_RECOMMEND then
		if nil ~= StoreMainVM.SkipTempData.Items[1] then -- 待拆推荐表
			GoodsCfgData = StoreCfg:FindCfgByKey(StoreMainVM.SkipTempData.Items[1].ID)
		end
	end
	if bIsJump then
		if StoreMainVM.JumpID ~= 0 then
			JumpUtil.JumpTo(StoreMainVM.JumpID, true)
		elseif nil ~= GoodsCfgData then
			StoreMgr:JumpToGoods(nil, GoodsCfgData.ID, true)
		end
		StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.RecommendJump, StoreMainVM:GetCurrentMainTabType(),
			nil, StoreMainVM:GetCurrentGoodsID())
	else
		if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
			if self.IsNeedGotoMadePanel then
				if not MountMgr:IsMountOwned(self.MountID) then
					MsgTipsUtil.ShowTipsByID(157046)
					return
				end
				_G.MountMgr:JumpToCustomMadePanel(self.MountID)
				if self.BtnBuyRedDot.ItemVM == nil then
					self.BtnBuyRedDot:InitData()
				end
				self.BtnBuyRedDot:SetRedDotUIIsShow(MountCustomMadeVM:MountIsNew(self.MountID))
				DataReportUtil.ReportCustomizeUIFlowData(1, self.MountID, self.TextName:GetText(),"","",3)
			elseif StoreMainVM:GetGoodSelectIndex() ~= 0 then
				if nil ~= GoodsCfgData then
					if StoreMainVM.CurrentSelectedTabType ~= ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
						StoreBuyWinVM:UpdateByGoodsID(GoodsCfgData.ID)
					else
						StoreBuyWinVM:UpdateByMysteryBoxData(GoodsCfgData)
					end
				end
				UIViewMgr:ShowView(UIViewID.StoreNewBuyWinPanel)
				if nil ~= StoreMainVM.CurrentSelectedItem then
					StoreUtil.ReportPurchaseClickFlow(StoreMainVM.CurrentSelectedItem.GoodID,
						StoreDefine.PurchaseOperationType.ClickMainPanelBuyButton)
				end
			end
		else
			if StoreMainVM.CurrentSelectedItem ~= nil then
				UIViewMgr:ShowView(UIViewID.StoreGiftChooseFriendWin, {GoodsID = StoreMainVM.CurrentSelectedItem.GoodID})
				StoreUtil.ReportGiftClickFlow(StoreMainVM.CurrentSelectedItem.GoodID,
					StoreDefine.GiftOperationType.ClickMainPanelGiftButton)
			end
		end
	end
end

--- 切换情感动作
function StoreNewMainPanelView:OnClickBtnSwitchPosture()
	if StoreMainVM.CurrentSelectedTabType ~= StoreMall.STORE_MALL_WEAPON or not StoreMainVM.bIsShowBtnPose then
		self:SwitchIdlePose(IdlePoseType.Show)
	else
		self:SwitchIdlePose(IdlePoseType.Combat)
	end
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickPoseChange)
end

function StoreNewMainPanelView:OnClickBtnTag1()
	HelpInfoUtil.ShowHelpInfo({HelpInfoID = StoreMainVM.Tag1InfoID, BtnInfor = self.BtnTag1}, true)
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickTag1)
end

function StoreNewMainPanelView:OnClickBtnTag2()
	HelpInfoUtil.ShowHelpInfo({HelpInfoID = StoreMainVM.Tag2InfoID, BtnInfor = self.BtnTag2})
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickTag2)
end

--- 点击小图片打开大窗口播放视频
function StoreNewMainPanelView:OnClickBtn_Video()
	UIUtil.SetIsVisible(self.PaneVideo_Full, true)
	UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP, false)
	UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP_Full, true, true)
	self.UMGVideoPlayer_UIBP_Full:ShowAllUI()
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickVideo)
	self.UMGVideoPlayer_UIBP_Full:OnSliderValueChange(nil, 0)
end

function StoreNewMainPanelView:PlayMovieEnd()
	self.UMGVideoPlayer_UIBP:OnResume()
	self.UMGVideoPlayer_UIBP_Full:OnResume()
end

--- 点击大窗口关闭按钮
function StoreNewMainPanelView:OnClick_Full_Close()
	UIUtil.SetIsVisible(self.PaneVideo_Full, false)
	UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP, true)
end

function StoreNewMainPanelView:UpdateVideoWidget(VideoPath)
	local IsHaveVideo = not string.isnilorempty(VideoPath)
	if IsHaveVideo then
		self.UMGVideoPlayer_UIBP:SetVideoPath(VideoPath)
		self.UMGVideoPlayer_UIBP:InitVideoPlayer()
		self.UMGVideoPlayer_UIBP_Full:SetVideoPath(VideoPath)
		self.UMGVideoPlayer_UIBP_Full:InitVideoPlayer()
	end
	UIUtil.SetIsVisible(self.PanelVideo, IsHaveVideo)
	UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP, IsHaveVideo)
end

-- 切换待机动作
function StoreNewMainPanelView:SwitchIdlePose(PoseType)
	PoseType = PoseType or 1
	local Render2DCharcter = self.CommRender2D.ChildActor
	if nil == Render2DCharcter then
		return
	end
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	local AnimInst = AnimComp:GetPlayerAnimInstance()
	if nil == AnimInst then
		return
	end
	local PlayerAnimParam = AnimInst:GetPlayerAnimParam()
	self.IdlePoseNum = PoseType == IdlePoseType.Default and 0 or (self.IdlePoseNum + 1) % 6
	if PoseType ~= IdlePoseType.Combat then
		AnimComp.IsInEmote = false
		PlayerAnimParam.bIgnoreRestTime = true
		PlayerAnimParam.bCanRest = true
		PlayerAnimParam.NormalIdleType = self.IdlePoseNum
		AnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
	else
		PlayerAnimParam.bIgnoreRestTime = false
		PlayerAnimParam.IdleToRestTime = 0.02
		AnimInst:UpdatePlayerAnimParam(PlayerAnimParam)
		AnimComp.IsInEmote = not AnimComp.IsInEmote
	end
end

--- 播放亮相动作
function StoreNewMainPanelView:PlayStagePose(GoodID)
	if GoodID == nil then return end
	local TempItemCfgData = StoreMgr:GetProductDataByID(GoodID)
	if TempItemCfgData == nil then return end
	local CfgAnimPath = TempItemCfgData.Cfg.AnimPath
	if string.isnilorempty(CfgAnimPath) then return end
	local AnimPath = AnimMgr:GetActionTimeLinePath(CfgAnimPath)
	local Render2DCharcter = self.CommRender2D.ChildActor
	if nil == Render2DCharcter then
		self:AddAssembleAllEndCallback(function() self:PlayStagePose(GoodID) end)
		return
	end
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		self:AddAssembleAllEndCallback(function() self:PlayStagePose(GoodID) end)
		return
	end
	AnimComp:PlayAnimation(AnimPath)
end

function StoreNewMainPanelView:StopStagePose()
	local Render2DCharcter = self.CommRender2D.ChildActor
	if nil == Render2DCharcter then
		return
	end
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	AnimComp:StopAnimation()
end

---@type 切换购买状态
function StoreNewMainPanelView:OnChangedPurchaseMethod(Index)
	-- 切换购买模式并计算对应页签下标
	StoreMainVM:ChangePurchaseMethod(Index - 1)
	if StoreMainVM.TabSelecteIndex ~= 0 then
		self:OnMenuTreeViewTabsSelectChanged(nil, nil, nil, StoreMainVM.TabSelecteIndex, nil, false)
	end

	-- 重置页签列表与选中页签
	self.CommMenu:UpdateItems(StoreMainVM.TabList, false)
	local MenuKey = StoreMainVM:GetDefaultMenuKey(StoreMainVM.TabSelecteIndex)
	self.CommMenu:SetSelectedKey(MenuKey, true)
end

--- 奇遇盲盒Tips
function StoreNewMainPanelView:OnClickInforBtn()
	UIViewMgr:ShowView(UIViewID.StoreNewBlindBoxDescription)
end

--region 坐骑独有
--- 坐骑BGM
function StoreNewMainPanelView:PlayMountBGM(MountID)
	if MountID == nil then
		return
	end
	local TempRideCfg = RideCfg:FindCfgByKey(MountID)
	if TempRideCfg ~= nil then
		local TempBgmCfg = BgmCfg:FindCfgByKey(TempRideCfg.MountBgm)
		if TempBgmCfg ~= nil then
			self.CurrentMountBGMID = TempRideCfg.MountBgm
			self:StopMountBGM()
			self.PlayingID = UE.UAudioMgr.Get():PlayBGM(tonumber(self.CurrentMountBGMID), UE.EBGMChannel.Mount)
		end
	end
end

function StoreNewMainPanelView:StopMountBGM()
	if nil ~= self.PlayingID then
		UE.UAudioMgr.Get():StopBGM(self.PlayingID)
		self.PlayingID = nil
	end
end

--- 坐骑情感动作List
function StoreNewMainPanelView:OnUpdateMontSkillList(MountID)
	local TempActionList = {}
	local TempRideCfg = RideCfg:FindCfgByKey(MountID)
	if TempRideCfg ~= nil then
		for i = 1, #TempRideCfg.PlayAction do
			if TempRideCfg.PlayAction[i] ~= 0 then
				local MountSkillData = {}
				MountSkillData.MountID = MountID
				MountSkillData.SkillID = TempRideCfg.PlayAction[i]
				MountSkillData.Index = i
				table.insert(TempActionList, MountSkillData)
			end
		end
		StoreMainVM:UpdateMountActionList(TempActionList)
		StoreMainVM.MountPagePanelVisible = true
	end
end

--endregion

function StoreNewMainPanelView:OnInitBtnState(ItemData)
	local bShowRawAvatar = false
	if ItemData ~= nil then
		bShowRawAvatar = ItemData.IsBringEquip == 1
	end
	StoreMainVM.bIsShowHat = true
	StoreMainVM.bIsShowHatStyle = false
	StoreMainVM.bIsShowRawAvatar = bShowRawAvatar
	StoreMainVM.bIsShowBtnPose = false
	StoreMainVM.bIsOnRide = true
	StoreMainVM.bIsAllCameraState = true
	-- StoreMainVM.bIsPlayMountBgm = true
end

----------------Render2D相关------------------

function StoreNewMainPanelView:CreateCompanion(CompanionID)
	local Location = nil ~= self.CommRender2D.RenderActor and self.CommRender2D.RenderActor:K2_GetActorLocation() or
		ModelDefine.DefaultLocation
	local Rotation = nil ~= self.CommRender2D.RenderActor and self.CommRender2D.RenderActor:K2_GetActorRotation() or
		ModelDefine.DefaultRotation
	self.StoreRender2D:CreateCompanion(CompanionID, {Location = Location,
		Rotation = Rotation})
end

function StoreNewMainPanelView:UpdateCompanionModel(ItemData)
	if nil == ItemData.Items or nil == ItemData.Items[1] then
		return
	end
	local TempItemCfg = ItemCfg:FindCfgByKey(ItemData.Items[1].ID)
	if nil == TempItemCfg then
		return
	end
	local UseFunc = TempItemCfg.UseFunc
	local Func = FuncCfg:FindCfgByKey(UseFunc)
	local CompanionID = Func.Func[1].Value[1]
	if self.CompanionActor then
		self.CompanionActor:SwitchRole(CompanionID)
	else
		self:CreateCompanion(CompanionID)
	end
end

function StoreNewMainPanelView:CreateRenderActor(EntityID, bSyncLoad)
	local Callback = function()
		self.CommRender2D:HideWeapon(true)
		self.RawSpringArmRotation = self.CommRender2D:GetSpringArmRotation()
		self.bFirstAvatarAssemble = true
		if not table.is_nil_empty(self.RenderActorCreateCallback) then
			for _, Callback in pairs(self.RenderActorCreateCallback) do
				Callback()
			end
		end
	end
	self.StoreRender2D:CreateRenderActor({EntityID = EntityID, Callback = Callback, bSyncLoad = bSyncLoad})
end

function StoreNewMainPanelView:OnShowMount(IsShowMount)
	StoreMainVM.MountPagePanelVisible = IsShowMount
	if IsShowMount then
		if nil == StoreMainVM.EquipPartList then
			return
		end
		--- 点击坐骑标签
		local ItemData = StoreMainVM.EquipPartList.Items[1]
		local Cfg = nil
		if nil ~= ItemData then
			Cfg = ItemCfg:FindCfgByKey(ItemData.ResID)
		end
		if Cfg ~= nil then
			local Func = FuncCfg:FindCfgByKey(Cfg.UseFunc)
			if Func ~= nil then
				local MountID = Func.Func[1].Value[1]
				if MountID ~= nil then
					if StoreMainVM.bIsPlayMountBgm then
						self:PlayMountBGM(MountID)
					end
					self:OnUpdateMontSkillList(MountID)
					self.MountID = MountID
					StoreMainVM.CurrentSelectedItem.MountID = MountID
					self:RideMount(MountID)
				end
			end
		end
	else
		self:StopMountBGM()
	end
end

--- 预览装备列表
function StoreNewMainPanelView:WearSuit()
	-- if self.IsHidePlayer then 
	-- 	return
	-- end
	--- 盲盒逻辑：不显示遮罩，这里拦截一下
	if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then 
		return
	end
	local EquipPartList = StoreMainVM.EquipPartList.Items
	local Gender = MajorUtil.GetMajorGender()
	local IsMale = Gender == ProtoCommon.role_gender.GENDER_MALE

	local SuitData = {}
	local Start, End, Step
	if IsMale then
		Start, End, Step = #EquipPartList, 1, -1  -- 倒序遍历
	else  
		Start, End, Step = 1, #EquipPartList, 1  -- 正序遍历
	end
	for i = Start, End, Step do
		local TempItemData = EquipPartList[i]
		local IsCanPreView = true

		-- 确定内层循环的起始和结束值
		local KStart, KEnd, KStep
		if IsMale then
			KStart, KEnd, KStep = #EquipPartList, i + 1, -1
		else
			KStart, KEnd, KStep = 1, i - 1, 1
		end

		for k = KStart, KEnd, KStep do
			if EquipPartList[k].Part == TempItemData.Part then
				EquipPartList[i].SelectBtnState = true
				EquipPartList[i].IsMask = true
				IsCanPreView = false
				break
			end
		end

		if IsCanPreView then
			--- 当前选中头部装备是否可调整特殊效果
			--- 禁用头部装饰功能  暂时不做
			-- if TempItemData.Part == EquipmentPartList.EQUIP_PART_HEAD then
			-- 	self:OnCheckBtnHatStyleDisabled(TempItemData.ResID)
			-- end
			table.insert(SuitData, TempItemData)
			StoreMainVM.EquipPartList.Items[i].bSelected = true
		end
	end
	self.StoreRender2D:WearSuit(SuitData)
end

function StoreNewMainPanelView:OnSelectEquipList()
	local Index = 1
	for i = 1, #StoreMainVM.EquipPartList.Items do
		local ItemData = StoreMainVM.EquipPartList.Items[i]
		if not ItemData.bOwned then
			Index = i
			break
		end
	end
	self.EquipTableViewAdapter:SetSelectedIndex(Index)
end

--- 禁用头部装饰功能  暂时不做
-- function StoreNewMainPanelView:OnCheckBtnHatStyleDisabled(ResID)
-- 	self.bBtnHatStyleDisabled = not EquipmentMgr:IsEquipHasGimmick(ResID)
-- end

-- 展示对应部位镜头
function StoreNewMainPanelView:FocusView(Part)
	self.StoreRender2D:FocusView(Part)
	self:StopStagePose()
	self:SwitchIdlePose(IdlePoseType.Default)
end

function StoreNewMainPanelView:ViewCompanion()
	if nil == self.CommRender2D.RenderActor then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.ViewCompanion, function() self:ViewCompanion() end)
		return
	end
	self.CommRender2D:EndCameraFocusScreenLocation()
	self.CommRender2D:SetFOVY(Render2DConfig.CompanionFOVY, true)
	self.CommRender2D:SetSpringArmDistance(Render2DConfig.CompanionViewDistance, true)
	local ViewportPos = self:GetViewportPosOfModel()
	local FOV = self.CommRender2D.FOVTarget or self.CommRender2D:GetFOV()
	local OffsetY = self.StoreRender2D.GetCameraOffsetY(ViewportPos, FOV,
		Render2DConfig.CompanionViewDistance + Render2DConfig.CompanionSpringArmLocation.X)
	self.CommRender2D:SetSpringArmLocation(Render2DConfig.CompanionSpringArmLocation.X, -OffsetY,
		Render2DConfig.CompanionSpringArmLocation.Z, true)
	self:ResetSpringArmRotation(true)
	self.CommRender2D:EnablePitch(false)
	self.CommRender2D:EnableZoom(false)
end

function StoreNewMainPanelView:ViewMount()
	if nil == self.CommRender2D.RenderActor then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.ViewMount, function() self:ViewMount() end)
		return
	end

	self.CommRender2D:EndCameraFocusScreenLocation()
	self.CommRender2D:SetFOVY(CameraUtil.FOVXToFOVY(Render2DConfig.MountFOVX, 16 / 9), true)
	-- self.CommRender2D:SetSpringArmDistance(Render2DConfig.MountViewDistance * UE.UCameraMgr.Get():GetRatioScale() + 100, true)
	local MountViewDistance = Render2DConfig.MountViewDistance + 100
	self.CommRender2D:SetSpringArmDistance(MountViewDistance, true)
	local ViewportPos = self:GetViewportPosOfModel()
	local FOV = self.CommRender2D.FOVTarget or self.CommRender2D:GetFOV()
	local OffsetY = self.StoreRender2D.GetCameraOffsetY(ViewportPos, FOV,
		MountViewDistance + Render2DConfig.MountSpringArmLocation.X)
	self.CommRender2D:SetSpringArmLocation(Render2DConfig.MountSpringArmLocation.X, -OffsetY,
		Render2DConfig.MountSpringArmLocation.Z, true)
	self:ResetSpringArmRotation(true)
	self.CommRender2D:EnablePitch(false)
	self.CommRender2D:EnableZoom(false)
end

function StoreNewMainPanelView:ResetSpringArmRotation(bInterp)
	if nil == self.RawSpringArmRotation then
		return
	end
	self.CommRender2D:SetSpringArmRotation(self.RawSpringArmRotation.Pitch, self.RawSpringArmRotation.Yaw,
		self.RawSpringArmRotation.Roll, bInterp)
end

--- 切换到全身镜头
function StoreNewMainPanelView:FocusFullBody()
	--- 选中道具或宠物时不切换镜头
	if (StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_PROPS) or (StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_PET) then
		return
	end
	self.StoreRender2D:ResetView(true, self:GetViewportPosOfModel())
end

function StoreNewMainPanelView:CheckFocusFullBody()
	local Character = self.CommRender2D:GetCharacter()
	if nil ~= Character and Character:IsMeshLoaded() then
		self:FocusFullBody()
	else
		self:AddAssembleAllEndCallback( function() self:FocusFullBody() end)
	end
end

function StoreNewMainPanelView:CheckEnableZoom()
	if self.EnableZoomTimerID ~= nil then
		self:UnRegisterTimer(self.EnableZoomTimerID)
		self.EnableZoomTimerID = nil
	end
	self.EnableZoomTimerID = self:RegisterTimer(
		function()
			self.CommRender2D:EnableZoom(true)
			self.EnableZoomTimerID = nil
		end, 0.5, 0, 1)
end

function StoreNewMainPanelView:HidePlayer()
	local SelectedTabIsMount = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MOUNT or self.IsNeedHidePlayer
	local SelectedTabIsProps = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_PROPS
	local GoodsExpandIsVisible = UIUtil.IsVisible(self.GoodsExpandPage)
	local IsHidePlayer = false
	if SelectedTabIsMount then
		IsHidePlayer = StoreMainVM.bIsOnRide
	elseif SelectedTabIsProps then
		IsHidePlayer = true
	else
		IsHidePlayer = GoodsExpandIsVisible
	end
	self.IsHidePlayer = IsHidePlayer
	self.CommRender2D:HidePlayer(IsHidePlayer)
end

function StoreNewMainPanelView:OnUpdateNPCModel()
	if StoreMgr:CheckMallTypeByIndex(StoreMainVM.TabSelecteIndex, StoreMall.STORE_MALL_MYSTERYBOX) then
		return
	end
	self.CommRender2D:ReleaseActor()
	if MajorUtil:GetMajorGender() == self.CurrentModelGender then
		self:CreateRenderActor(self.NPCEntityID)
	else
		self:CreateRenderActor(MajorUtil.GetMajorEntityID())
	end
	self:WearSuit()
	self.CurrentModelGender = self.CurrentModelGender == ProtoCommon.role_gender.GENDER_MALE and ProtoCommon.role_gender.GENDER_FEMALE or ProtoCommon.role_gender.GENDER_MALE
end

function StoreNewMainPanelView:UpdateCurrentShowActorType(InCurrentShowActorType)
	self.CurrentShowActorType = InCurrentShowActorType
	self:OnShowActorTypeChanged()
end

function StoreNewMainPanelView:OnShowActorTypeChanged()
	-- 角色与模型可见性更新
	self:CheckActorsVisibility()

	-- 角色与模型Transform更新
	self:CheckActorsTransform()

	-- 镜头更新
	if self.CurrentShowActorType == ShowActorType.Companion then
		self:ViewCompanion()
	elseif self.CurrentShowActorType == ShowActorType.Mount then
		self:ViewMount()
	end

	-- 交互对象更新
	self:CheckInteractTarget()
end

function StoreNewMainPanelView:CheckActorsVisibility()
	-- Actor层面可见性
	local bShowCompanion = self.CurrentShowActorType == ShowActorType.Companion
	local bShowMount = self.CurrentShowActorType == ShowActorType.Mount
	local bShowNothing = self.CurrentShowActorType == ShowActorType.None
	if nil ~= self.CommRender2D.ChildActor then
		self.CommRender2D.ChildActor:SetActorVisibility(not bShowCompanion and not bShowNothing, UE.EHideReason.LoginMap)
	end
	if nil ~= self.CompanionActor then
		self.CompanionActor:SetActorVisibility(bShowCompanion, UE.EHideReason.LoginMap)
	end

	-- 模型层面可见性
	self.CommRender2D:HidePlayer(bShowMount)
	if not bShowMount then
		self.CommRender2D:TakeOffRideAvatar()
	end
end

function StoreNewMainPanelView:CheckActorsTransform()
	local Character = self.CommRender2D.ChildActor
	if nil ~= Character then
		Character:SetScaleFactor(1, true)
		self.CommRender2D:SetModelLocation(0, 0, Character:GetCapsuleHalfHeight(), false) -- 胶囊体贴地
	end
end

function StoreNewMainPanelView:CheckInteractTarget()
	-- 更新旋转对象
	local ViewingActor = self.CurrentShowActorType == ShowActorType.Companion and self.CompanionActor or
		self.CommRender2D.ChildActor
	if nil ~= ViewingActor then
		local SkeletalMeshComp = ViewingActor:GetComponentByClass(UE.USkeletalMeshComponent)
		if nil ~= SkeletalMeshComp then
			self.CommRender2D:UpdateSkeletalMeshComp(SkeletalMeshComp)
		end
	end

	-- 坐骑旋转开关
	self.CommRender2D.bOnUIRide = self.CurrentShowActorType == ShowActorType.Mount
end

function StoreNewMainPanelView:CheckShadowType()
	local ShadowType = ActorUtil.ShadowType.Role
	if self.CurrentShowActorType == ShowActorType.Mount then
		ShadowType = ActorUtil.ShadowType.StoreMount
	elseif self.CurrentShowActorType == ShowActorType.Human then
		ShadowType = ActorUtil.ShadowType.StoreRole
	else
		ShadowType = ActorUtil.ShadowType.StoreCompanion
	end
	self.StoreRender2D:SwitchShadowType(ShadowType)
end

function StoreNewMainPanelView:OnRender2DClicked(View)
	local MouseX = self.CommRender2D.StartPosX
	local MouseY = self.CommRender2D.StartPosY
	local TouchPosition = UE.FVector2D(MouseX, MouseY)
	if UIUtil.IsUnderLocation(self.PanelInteract, TouchPosition) then
		self.StoreRender2D:TryPlayInteractTimeline()
	end
end

function StoreNewMainPanelView:AddAssembleAllEndCallback(Callback)
	table.insert(self.AssembleAllEndCallbacks, Callback)
end

function StoreNewMainPanelView:AddRenderActorCreateCallback(CallbackType, Callback)
	self.RenderActorCreateCallback[CallbackType] = Callback
end

----------------Render2D相关end------------------

--region 坐骑模型相关

function StoreNewMainPanelView:RideMount(MountID)
	if nil == self.CommRender2D.RenderActor then
		self:AddRenderActorCreateCallback(RenderActorCreateCallbackType.RideMount, function() self:RideMount(MountID) end)
		return
	end
	self.CommRender2D:SetUIRideCharacter(MountID)
end

--enregion

--region UI控件相关

function StoreNewMainPanelView:GetViewportPosOfModel()
	local WidgetHalfSize = UIUtil.GetWidgetSize(self.PanelInteract) * 0.5
	local _, ViewportTopLeft = UIUtil.AbsoluteToViewport(UIUtil.GetWidgetAbsoluteTopLeft(self.PanelInteract))
	return ViewportTopLeft + WidgetHalfSize
end

--endregion


--region TLOG上报

---@param BrowseOperationType StoreDefine.BrowseOperationType
function StoreNewMainPanelView.ReportBrowseFlow(BrowseOperationType)
	StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.Browse, StoreMainVM:GetCurrentMainTabType(), nil,
		StoreMainVM:GetCurrentGoodsID(), BrowseOperationType)
end

--endregion

return StoreNewMainPanelView
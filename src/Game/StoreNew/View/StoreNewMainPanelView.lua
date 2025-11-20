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
local StoreRecommendCfg = require("TableCfg/StoreRecommendCfg")
local CommonUtil = require("Utils/CommonUtil")
local StoreMgr = require("Game/Store/StoreMgr")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local ModelDefine = require("Game/Model/Define/ModelDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local CameraFocusCfgMap = require("Game/Equipment/VM/CameraFocusCfgMap")
local DataReportUtil = require("Utils/DataReportUtil")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
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
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecorateSkillCfg = require("TableCfg/FashionDecorateSkillCfg")
local ObjectGCType = require("Define/ObjectGCType")
local AnimationUtil = require("Utils/AnimationUtil")

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
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

local AssembleAllEndCallbackType =
{
	View = 1, -- 相机相关
	StagePose = 2, -- 亮相动作
	IdlePose = 3, -- 待机动作
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
	[StoreMall.STORE_MALL_PROPS] = true,
	[StoreMall.STORE_MALL_MYSTERYBOX] = true
}

local BuyBtnType = {
	Buy = 1,
	CutHair = 2,
	GoWardrobe = 3
}
---@class StoreNewMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BtnBuy CommBtnLView
---@field BtnBuyRedDot CommonRedDotView
---@field BtnClose CommonCloseBtnView
---@field BtnEquipment UToggleButton
---@field BtnExpand UFButton
---@field BtnFly UToggleButton
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
---@field CommEmpty CommBackpackEmptyView
---@field CommInforBtn CommInforBtnView
---@field CommMenu CommMenuView
---@field CommTab USizeBox
---@field CommTabs CommTabsView
---@field CommodityExpandPanel StoreCommodityExpandPanelView
---@field CommonTitle CommonTitleView
---@field FVerticalBox_1 UFVerticalBox
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
---@field PanelUI UFCanvasPanel
---@field PanelVideo UFCanvasPanel
---@field RichTextBoxBlindBoxHint URichTextBox
---@field StoreFiterTips StoreFiterTipsView
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
---@field ToggleBtnFilter UToggleButton
---@field UMGVideoPlayer_UIBP UMGVideoPlayerView
---@field UMGVideoPlayer_UIBP_Full UMGVideoPlayerView
---@field AnimCommodityFold UWidgetAnimation
---@field AnimCommodityFoldFullScreenIn UWidgetAnimation
---@field AnimCommodityFoldFullScreenOut UWidgetAnimation
---@field AnimCommodityIn UWidgetAnimation
---@field AnimCommodityUnfold UWidgetAnimation
---@field AnimCommonBGHide UWidgetAnimation
---@field AnimCommonBGShow UWidgetAnimation
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
	--self.Bkg = nil
	--self.BtnBuy = nil
	--self.BtnBuyRedDot = nil
	--self.BtnClose = nil
	--self.BtnEquipment = nil
	--self.BtnExpand = nil
	--self.BtnFly = nil
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
	--self.CommEmpty = nil
	--self.CommInforBtn = nil
	--self.CommMenu = nil
	--self.CommTab = nil
	--self.CommTabs = nil
	--self.CommodityExpandPanel = nil
	--self.CommonTitle = nil
	--self.FVerticalBox_1 = nil
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
	--self.PanelUI = nil
	--self.PanelVideo = nil
	--self.RichTextBoxBlindBoxHint = nil
	--self.StoreFiterTips = nil
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
	--self.ToggleBtnFilter = nil
	--self.UMGVideoPlayer_UIBP = nil
	--self.UMGVideoPlayer_UIBP_Full = nil
	--self.AnimCommodityFold = nil
	--self.AnimCommodityFoldFullScreenIn = nil
	--self.AnimCommodityFoldFullScreenOut = nil
	--self.AnimCommodityIn = nil
	--self.AnimCommodityUnfold = nil
	--self.AnimCommonBGHide = nil
	--self.AnimCommonBGShow = nil
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
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnBuyRedDot)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.CommodityExpandPanel)
	self:AddSubView(self.CommonTitle)
	--self:AddSubView(self.InforBtn)
	self:AddSubView(self.Money)
	self:AddSubView(self.Money1)
	self:AddSubView(self.StoreFiterTips)
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
		{ "GoodsExpandPageVisible", 	UIBinderSetIsVisible.New(self, self.CommodityExpandPanel) },
		{ "PanelPropsVisible", 			UIBinderSetIsVisible.New(self, self.TableViewProps) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelCommodityFold, true) },
		{ "DyeCommonInforBtnVisible", 	UIBinderSetIsVisible.New(self, self.BtnInfo) },
		{ "bDyeInforPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelDyeing) },
		{ "bIsFilterListShow", 			UIBinderSetIsVisible.New(self, self.StoreFiterTips) },
		{ "bShowMainEmptyPanel", 		UIBinderSetIsVisible.New(self, self.CommEmpty) },

		--- 购买按钮panel
		{ "BuyBtnText", 				UIBinderSetText.New(self, self.BtnBuy.TextContent) },

		{ "bIsAllCameraState", 			UIBinderSetIsChecked.New(self, self.BtnSwitch) },
		{ "bIsFullScreen", 				UIBinderSetIsChecked.New(self, self.BtnFullScreen) },
		{ "bIsShowHat", 				UIBinderSetIsChecked.New(self, self.BtnHat) },
		{ "bIsShowHatStyle", 			UIBinderSetIsChecked.New(self, self.BtnOrgan) },
		{ "bIsShowRawAvatar", 			UIBinderSetIsChecked.New(self, self.BtnEquipment) },
		{ "bIsShowRawAvatar",           UIBinderValueChangedCallback.New(self, nil, self.OnShowRawAvatarChanged) },
		{ "bIsPlayMountBgm", 			UIBinderSetIsChecked.New(self, self.BtnMusic) },
		{ "bIsPlayFlyState", 			UIBinderSetIsChecked.New(self, self.BtnFly) },
		{ "bIsShowBtnPose", 			UIBinderSetIsChecked.New(self, self.BtnPose, nil, true) },
		{ "bIsFilterListShow", 			UIBinderSetIsChecked.New(self, self.ToggleBtnFilter) },

		{ "BtnSwitchVisible", 	UIBinderSetIsVisible.New(self, self.BtnSwitch, nil, true) },
		{ "BtnHatVisible", 	UIBinderSetIsVisible.New(self, self.BtnHat, nil, true) },
		{ "BtnOrganVisible", 	UIBinderSetIsVisible.New(self, self.BtnOrgan, nil, true) },
		{ "BtnEquipmentVisible", 	UIBinderSetIsVisible.New(self, self.BtnEquipment, nil, true) },
		{ "BtnSwitchPostureVisible", 	UIBinderSetIsVisible.New(self, self.BtnSwitchPosture, nil, true) },
		{ "BtnFlyVisible", 				UIBinderSetIsVisible.New(self, self.BtnFly, nil, true) },
		{ "MountPagePanelVisible", 		UIBinderSetIsVisible.New(self, self.BtnMusic, nil, true) },
		{ "MountPagePanelVisible", 		UIBinderSetIsVisible.New(self, self.TableViewMountsAction) },
		{ "EquipParVisible", 			UIBinderSetIsVisible.New(self, self.TableViewSlot) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelPreview) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.PanelVideo) },
		{ "PosterPanelVisible", 		UIBinderSetIsVisible.New(self, self.CommTabs, true) },

		{ "bIsFilter",             		UIBinderValueChangedCallback.New(self, nil, self.OnIsFilterChanged) },
		{ "TabSelecteType",             UIBinderValueChangedCallback.New(self, nil, self.OnSelectedTabTypeChanged) },
		{ "GoodsExpandPageVisible",     UIBinderValueChangedCallback.New(self, nil, self.OnGoodsExpandPageVisibleChanged) },
		{ "DyeCommonInforID",           UIBinderValueChangedCallback.New(self, nil, self.OnDyeCommonInforIDChanged) },
		{ "bIsShowHat",                 UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatChanged) },
		{ "bIsShowHatStyle",            UIBinderValueChangedCallback.New(self, nil, self.OnIsShowHatStyleChanged) },
		{ "PanelBuyVisible", 			UIBinderValueChangedCallback.New(self, nil, self.OnPanelBuyVisibleChanged) },
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
	self.IsNeedGotoMadePanel = false
	self.TextPreview:SetText(LSTR(StoreDefine.LSTRTextKey.PrizePreview))
	self.DefaultModelGender = nil
	self.CurrentModelGender = nil
	self.IsSwitchedMount = false
	self.IsSwitchedMysterBox = false
	self.PreviewEquipIndex = 1
	self.CurrentShowActorType = ShowActorType.Human
	self.CompanionActor = nil -- 仅为宠物角色的引用，其生命周期由StoreRender2D管理
	self.CompanionCreateCallback = nil
	self.RawSpringArmRotation = nil
	self.AssembleAllEndCallbacks = {} -- 模型加载完后的回调，暂时只有时装展示用
	self.RenderActorCreateCallback = {} -- RenderActor加载完后的回调
	self.CurrentDecorationType = nil

	self.Money1.RedDot:SetRedDotIDByID(18)
	self.BtnBuyRedDot:SetIsCustomizeRedDot(true)

	self.MysteryBoxWidget = nil

	self.ActionPlayList = {}
end

function StoreNewMainPanelView:OnDestroy()

end

function StoreNewMainPanelView:OnShow()
	if not _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_MALL, true) then
		return
	end
	--设置等待理发数据状态
	self.WaitCutHairData = true
	_G.EffectUtil.SetForceDisableCache(true)
	if RechargingMgr:ShouldShowShopkeeper() then
		RechargingMgr:PreloadScene()
	end
	_G.HUDMgr:SetIsDrawHUD(false)
	_G.LightMgr:EnableUIWeather(2)

	-- 提前请求好友数据，赠礼界面使用
	FriendMgr:SendGetFriendListMsg()
	self:CreatMysteryBoxWidget()

	-- 设置角色原始外观数据
	self.DefaultModelGender = MajorUtil.GetMajorGender()
	self.CurrentModelGender = self.DefaultModelGender
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if nil ~= RoleSimple then
		self.StoreRender2D:SetRawAvatar(RoleSimple.Avatar)
	end

	self.CommEmpty:SetTipsContent(LSTR(950097))
	self.CommonTitle:SetSubTitleIsVisible(false)
	StoreMgr:InitProductDataByReq()
	_G.HaircutMgr:SendMsgHairQuery()
	self:OnCheckPreViewState()

	-- TLOG上报
	StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.OpenStore, StoreMainVM:GetCurrentMainTabType())

	-- 最后检查跳转，避免被前面的修改所影响
	if nil ~= StoreMainVM.JumpToCategoryIndex then
		if nil ~= StoreMainVM.JumpToGoodsID then
			self:JumpToGoods()
		else
			self:JumpToCategory(StoreMainVM.JumpToCategoryIndex)
		end
	end


	UIUtil.SetIsVisible(self.MysteryBoxWidget, false)
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
		ItemData.IsMask = ItemData.bOwned
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
		ItemData.IsMask = false
		StoreMainVM:ChangeEquipPart(nil, false)
		StoreMainVM:ChangeEquipPart(Index, true)
	end

	if bIsByClick then
		StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.PreviewBodyPart, StoreMainVM:GetCurrentMainTabType(),
			nil, StoreMainVM:GetCurrentGoodsID(), ItemData.Part)
	end
end

function StoreNewMainPanelView:CheckGoodsItemType(GoodsData)
	if not GoodsData or not next(GoodsData) then return end
	local ItemPackage = GoodsData.Items

	local IsMixPakage = false
	local IsAllCoiffure = true
	local NeedCheckSuit = true
	local LocalSuitID = 0
	local SuitID = 0
	local AllSuitCfg = ClosetSuitCfg:FindAllCfg()
	local SuitIDTable = {}
	if ItemPackage and next(ItemPackage) then
		for _, Item in pairs(ItemPackage) do
			local Cfg = ItemCfg:FindCfgByKey(Item.ID)
			if Cfg then
				--先判断包中有没有发型，是发型的话，后续不用判断套装
				if Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE then
					NeedCheckSuit = false
				else
					--如果不是发型，且参数改变，则直接return 为不许要检查，是混合包
					if not NeedCheckSuit then
						IsAllCoiffure = false
						IsMixPakage = true
						return IsMixPakage, IsAllCoiffure, SuitID
					end
				end
				--如果需要检查套装，则开始检查套装，如果不属于同一个套装则直接return0
				if NeedCheckSuit then
					--ID为0的时候赋新ID
					IsAllCoiffure = false
					for _, Data in pairs(AllSuitCfg) do
						for _, AppID in pairs(Data.AppItems) do
							if Cfg.EquipmentID == AppID then
								if LocalSuitID == 0 then
									LocalSuitID = Data.ID
									table.insert(SuitIDTable, LocalSuitID)
								else
									if LocalSuitID ~= Data.ID then
										LocalSuitID = Data.ID
										table.insert(SuitIDTable, LocalSuitID)
									end
								end
							end
						end
					end
				end
			end
		end
		if SuitIDTable and next(SuitIDTable) then
			if #SuitIDTable > 1 then
				--必须提出来重新遍历一次，目前没想到什么好办法
				for _, value in pairs(SuitIDTable) do
					local SuitCfg = ClosetSuitCfg:FindCfgByKey(value)
					local SuitCheckTag = true
					for _,Item in pairs(ItemPackage) do
						local data = ItemCfg:FindCfgByKey(Item.ID)
						if data then
							local EquipmentID = data.EquipmentID
							local CheckTag = false
							for _, AppID in pairs(SuitCfg.AppItems) do
								if AppID == EquipmentID then
									CheckTag = true
								end
							end
							--只要有一件不在套装内，则不是这个套装
							if not CheckTag then
								SuitCheckTag = false
							end
						end
					end
					if SuitCheckTag then
						SuitID = value
					end
				end
			else
				SuitID = SuitIDTable[1]
			end
		end
	end
	return IsMixPakage, IsAllCoiffure, SuitID
end

--- 选中商品
function StoreNewMainPanelView:OnGoodListSelectChanged(Index, ItemData, ItemView, bIsByClick)
	StoreMainVM:ChangeEquipPart(nil, false)
	StoreMainVM:ChangeGood(Index)
	ItemData.bSelected = true
	StoreMainVM.CurrentSelectedItem = self.GoodsTableViewAdapter:GetItemDataByIndex(Index)
	StoreMainVM:InitBuyView()
	StoreMainVM:UpdateCouponData()
	StoreMainVM:CacheSelectedGoodsForCategory(StoreMainVM.TabSelecteIndex, ItemData.GoodID)

	-- 公共显示内容更新
	self:UpdatePreviewGoods(ItemData.GoodID)

	-- 购买按钮更新
	local bCurrentTabIsMount = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MOUNT
	self.IsNeedGotoMadePanel = false
	if bCurrentTabIsMount and ItemData.IsOwned and self.MountID and _G.MountMgr:IsCustomMadeEnabled(self.MountID) then
		StoreMainVM.BuyBtnText = LSTR(950054)	--- 个性定制
		self.IsNeedGotoMadePanel = true
		-- 个性定制红点
		if self.BtnBuyRedDot.ItemVM == nil then
			self.BtnBuyRedDot:InitData()
		end
		self.BtnBuyRedDot:SetRedDotUIIsShow(MountCustomMadeVM:MountIsNew(self.MountID))
		self.BuyBtnType = BuyBtnType.Buy
		self.BtnBuy:SetIsRecommendState(true)
	else
		self:RefreshBuyButton(ItemData, ItemData)
	end
	UIUtil.SetIsVisible(self.BtnBuy.Button, true, true) -- 保证按钮可点击

	-- 其他UI控件更新
	UIUtil.SetIsVisible(self.BtnTag1, StoreMainVM.ImgTag1Visible, true)
	UIUtil.SetIsVisible(self.BtnTag2, StoreMainVM.ImgTag2Visible, true)
	UIUtil.ButtonSetBrush(self.BtnTag1, StoreMainVM.ImgTag1Path)
	UIUtil.ButtonSetBrush(self.BtnTag2, StoreMainVM.ImgTag2Path)
	UIUtil.SetIsVisible(self.Money, StoreMainVM.JumpID == 0 and not ItemData.IsOwned, nil, true)

	--TLOG上报
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
	if nil == ItemData then
		return
	end
	local GoodsData = {Cfg = StoreCfg:FindCfgByKey(ItemData.GoodsId)}
	StoreMainVM:InitMultiBuyView(GoodsData)
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
	-- 推荐页商品从推荐商品表读取子商品信息
	if #PreviewItems == 0 then
		local RecommendGoodsCfgData = StoreRecommendCfg:FindCfgByKey(ItemData.GoodID)
		if nil ~= RecommendGoodsCfgData then
			for _, ID in ipairs(RecommendGoodsCfgData.GoodsIDs) do
				table.insert(PreviewItems, {ID = ID})
			end
		end
	end
	ItemData.bSelected = true
	local IsHairBox = ItemData.Type == StoreMall.STORE_MALL_MYSTERYBOX and ItemData.Type ~= nil
	-- UIUtil.SetIsVisible(self.TableViewSlot, #PreviewItems > 1 or IsHairBox)
	StoreMainVM.EquipParVisible = #PreviewItems > 1
	self.PreviewTableViewAdapter:UpdateAll(PreviewItems)
	StoreMainVM:ChangeGood(Index)
	StoreMainVM.CurrentSelectedItem = self.GoodsTableViewAdapter:GetItemDataByIndex(Index)
	StoreMainVM:InitBuyView()
	StoreMainVM:CacheSelectedGoodsForCategory(StoreMainVM.TabSelecteIndex, ItemData.GoodID)
	UIUtil.SetIsVisible(self.Money, StoreMainVM.JumpID == 0 and not ItemData.IsOwned, nil, true)
	self.PreviewTableViewAdapter:SetSelectedIndex(1)
	if IsHairBox then
		if StoreMainVM.bIsShowHat then
			self:OnChangedToggleBtnHat()
		end
		self.StoreRender2D:WearSuit({})
		self:WearSuit()
	end
	local IsOwned = ItemData.IsOwned
	local GoodsID = ItemData.GoodID
	local RecommendGoodsCfgData = StoreRecommendCfg:FindCfgByKey(GoodsID)
	if RecommendGoodsCfgData and RecommendGoodsCfgData.ProductType == ProtoRes.StoreRecommendType.STORE_RECOMMEND_TYPE_PURCHASE then
		local GoodsId = RecommendGoodsCfgData.GoodsIDs[1]
		local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsId)
		self:RefreshBuyButton(ItemData, GoodsCfgData)
	else
		self.BuyBtnType = BuyBtnType.Buy
		self.BtnBuy:SetIsRecommendState(true)
		StoreMainVM.BuyBtnText = LSTR(StoreDefine.StoreModeText[StoreMainVM.CurrentStoreMode])
	end
	UIUtil.SetIsVisible(self.BtnBuy.Button, true, true)
	if bIsByClick then
		if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Buy then
			StoreUtil.ReportPurchaseClickFlow(GoodsID, StoreDefine.PurchaseOperationType.SelectGoods)
		else
			StoreUtil.ReportGiftClickFlow(GoodsID, StoreDefine.GiftOperationType.SelectGoods)
		end
	end
end

function StoreNewMainPanelView:RefreshBuyButton(ViewData, GoodsData)
	local IsOwned = ViewData.StateTextVisible and ViewData.GoodStateText == LSTR(StoreDefine.SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER])
	if IsOwned then
		local IsMixPakage, IsAllCoiffure, SuitID = self:CheckGoodsItemType(GoodsData)
		--如果是混合包
		if IsMixPakage then
			self.BuyBtnType = BuyBtnType.Buy
			self.BtnBuy:SetIsDoneState(true)
			StoreMainVM.BuyBtnText = LSTR(StoreDefine.SecondScreenType.Owned)
		else
			--发型
			if IsAllCoiffure then
				self.BuyBtnType = BuyBtnType.CutHair
				StoreMainVM.BuyBtnText = LSTR(StoreDefine.SecondScreenType.GoCutHair)
				self.BtnBuy:SetIsRecommendState(true)
			else
				if SuitID ~= 0 then
					self.HoldSuitID = SuitID
					self.BuyBtnType = BuyBtnType.GoWardrobe
					StoreMainVM.BuyBtnText = LSTR(StoreDefine.SecondScreenType.GoWardrobe)
					self.BtnBuy:SetIsRecommendState(true)
				else
					self.BuyBtnType = BuyBtnType.Buy
					self.BtnBuy:SetIsDoneState(true)
					StoreMainVM.BuyBtnText = LSTR(StoreDefine.SecondScreenType.Owned)
				end
			end
		end
	else
		self.BuyBtnType = BuyBtnType.Buy
		self.BtnBuy:SetIsRecommendState(true)
		StoreMainVM.BuyBtnText = LSTR(StoreDefine.StoreModeText[StoreMainVM.CurrentStoreMode])
	end
end

--- 坐骑技能
function StoreNewMainPanelView:OnMountActionselectChanged(Index, ItemData, ItemView, bIsByClick)
end

--- 大奖预览
function StoreNewMainPanelView:OnPreviewSelectChanged(Index, ItemData, ItemView, bIsByClick)
	self:UpdatePreviewGoods(ItemData.ID)
end

--- 切换菜单
function StoreNewMainPanelView:OnMenuTreeViewTabsSelectChanged(Index, ItemData, ItemView, MainKey, SubKey, bIsByClick)
	local OldTabType = StoreMainVM.TabSelecteType
	UIUtil.SetIsVisible(self.TextType, false)

	--- 坐骑飞行状态却换成其他的时候，在更新模型之前把飞行模式设置回去，不然模型是歪的
	self:OnChangedBtnFly(nil, nil, _G.UE.EToggleButtonState.Unchecked)
	StoreMainVM:ChangeTab(MainKey, SubKey)
	-- 与TabSelecteType更新相关的逻辑如果不依赖商品列表更新，可以放到OnSelectedTabTypeChanged中
	do
		if StoreMainVM.TabSelecteType == StoreMall.STORE_MALL_MOUNT then
			self.IsSwitchedMount = true
		end
		--- 道具/推荐  隐藏物品tableview
		UIUtil.SetIsVisible(self.PanelCommodityFold, StoreMainVM.TabSelecteType ~= StoreMall.STORE_MALL_PROPS and StoreMainVM.TabSelecteType ~= StoreMall.STORE_MALL_RECOMMEND)
		if StoreMainVM.TabSelecteType == StoreMall.STORE_MALL_MYSTERYBOX then
			self.IsSwitchedMysterBox = true
			self:ChangeToMysterBoxPanel(true)
		else
			if self.IsSwitchedMysterBox then
				--- 从盲盒切回来，恢复一下控件
				self:ChangeToMysterBoxPanel(false)
				self.IsSwitchedMysterBox = false
			end
			UIUtil.SetIsVisible(self.BtnSwitch, StoreMainVM.BtnSwitchVisible, true)
			UIUtil.SetIsVisible(self.BtnEquipment, StoreMainVM.BtnEquipmentVisible, true)
		end
	end

	--这里恢复被动画拉走的UI组件
	if nil ~= StoreMainVM.TabSelecteType then
		self.PanelBtnBuy:SetRenderOpacity(HideBuyBtnConfig[StoreMainVM.TabSelecteType] and 0 or 1.0)
		UIUtil.SetIsVisible(self.PanelBtnBuy, not HideBuyBtnConfig[StoreMainVM.TabSelecteType])
	end
	self:PlayAnimation(StoreMgr:CheckMallTypeByIndex(MainKey,
					   StoreMall.STORE_MALL_PROPS) and self.AnimTableViewPropsIn or self.AnimCommodityIn)
	if bIsByClick and nil ~= OldTabType and OldTabType ~= StoreMainVM.TabSelecteType then
		StoreUtil.ReportInterfaceFlow(StoreDefine.InterfaceOperationType.SwitchTab, StoreMainVM.TabSelecteType, OldTabType)
	end
	
	local CategoryData = _G.StoreMgr:GetCategoryData(MainKey)
	if CategoryData and next(CategoryData) then
		UIUtil.SetIsVisible(self.ToggleBtnFilter, CategoryData.IsDisplayHaveFilter == 1, true)
		if not (CategoryData.IsDisplayHaveFilter == 1) then
			StoreMainVM:SetSecondScreen(false)
		else
			StoreMainVM:SetSecondScreen(StoreMainVM.bIsFilter)
		end
	end
	StoreMainVM.bIsFilterListShow = false
end

-- 筛选变换
function StoreNewMainPanelView:OnIsFilterChanged(FilterType)
	--if FilterType == StoreMainVM.bIsFilter then return end
	StoreMainVM.bIsFilterListShow = false
	StoreMainVM:SetSecondScreen(FilterType)
end
-- 商品大类切换
function StoreNewMainPanelView:OnSelectedTabTypeChanged(NewTabType)
	-- 切换展示角色
	local NewShowActorType = ShowActorType.None
	if NewTabType == StoreMall.STORE_MALL_PET then
		NewShowActorType = ShowActorType.Companion
	elseif NewTabType == StoreMall.STORE_MALL_MOUNT or (NewTabType == StoreMall.STORE_MALL_MYSTERYBOX and _G.StoreMysteryBoxVM:GetIsMountType()) then
		NewShowActorType = ShowActorType.Mount
	elseif NewTabType == StoreMall.STORE_MALL_RECOMMEND or NewTabType == StoreMall.STORE_MALL_CLOTHING or NewTabType == StoreMall.STORE_MALL_ORNAMENT or
		(NewTabType == StoreMall.STORE_MALL_MYSTERYBOX and _G.StoreMysteryBoxVM:GetIsHumanType()) or NewTabType == StoreMall.STORE_MALL_ACTINGTEXTBOOK then
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
	self.StoreRender2D:HideHelmet(not bIsShowHat)
	if bIsShowHat then
		self.StoreRender2D:SwitchHelmet(StoreMainVM.bIsShowHatStyle)
	end
end

function StoreNewMainPanelView:OnIsShowHatStyleChanged(bIsShowHatStyle)
	-- if self.bBtnHatStyleDisabled then StoreMainVM.bIsShowHatStyle = false end    --- 禁用头部装饰功能  暂时不做
	self.StoreRender2D:SwitchHelmet(bIsShowHatStyle)
end

function StoreNewMainPanelView:OnPanelBuyVisibleChanged(bVisible)
	if nil ~= self.PanelInfoHideTimer then
		self:UnRegisterTimer(self.PanelInfoHideTimer)
		self.PanelInfoHideTimer = nil
	end
	if bVisible then
		UIUtil.SetIsVisible(self.PanelInfo, true)
	else
		self.PanelInfoHideTimer = self:RegisterTimer(function() UIUtil.SetIsVisible(self.PanelInfo, false) end,
				self.AnimInfoIn:GetEndTime() + 0.01)
	end
	self:StopAnimation(self.AnimInfoIn)
	self:PlayAnimation(self.AnimInfoIn, 0, 1,
		bVisible and UE.EUMGSequencePlayMode.Forward or UE.EUMGSequencePlayMode.Reverse)
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
	self.WaitCutHairData = true
	_G.EffectUtil.SetForceDisableCache(false)
	self:StopMountBGM()
	_G.HUDMgr:SetIsDrawHUD(true)
	self.BtnHand:SetIsChecked(true)
	RechargingMgr:DestroyScene()
	self:InitBtnState()
	StoreMainVM.bIsFilter = false
	StoreMainVM.bIsFilterListShow = false
	StoreMainVM.bIsPlayMountBgm = true
	StoreMainVM.JumpToCategoryIndex = nil
	StoreMainVM.TabSelecteIndex = 1
	StoreMainVM.SelectedGoods = {}
	StoreMainVM.GoodFilterDataList = nil
	StoreMainVM.bIsFullScreen = false
	StoreMainVM.GoodsExpandPageVisible = false
	StoreMainVM.bSecondScreen = false
	self.CurrentDecorationType = nil
	StoreMainVM.CurrentSelectedTabType = ProtoRes.StoreMall.STORE_MALL_INVALID
	_G.LightMgr:DisableUIWeather()
	if self.BackgroundActor then
		CommonUtil.DestroyActor(self.BackgroundActor)
    end
    self.BackgroundActor = nil
	self.CompanionActor = nil
	self.RenderActorCreateCallback = {}
	self.AssembleAllEndCallbacks = {}
	_G.StoreMgr:UnRegisterAllTimer()
	self:ClearJumpData()
	_G.UIViewMgr:HideView(_G.UIViewID.StoreBlindBoxPanel_UIBP)
	self.ActionPlayList = {}
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

	UIUtil.AddOnStateChangedEvent(self, self.BtnFullScreen, self.OnChangedToggleBtnFullScreen)
	UIUtil.AddOnStateChangedEvent(self, self.BtnSwitch, self.OnChangedToggleBtnSwitch)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHat, self.OnChangedToggleBtnHat)
	UIUtil.AddOnStateChangedEvent(self, self.BtnOrgan, self.OnChangedToggleBtnOrgan)
	UIUtil.AddOnStateChangedEvent(self, self.BtnEquipment, self.OnChangedToggleBtnEquipment)
	UIUtil.AddOnStateChangedEvent(self, self.BtnMusic, self.OnChangedToggleBtnMusic)
	UIUtil.AddOnStateChangedEvent(self, self.BtnPose, self.OnChangedBtnPose)
	UIUtil.AddOnStateChangedEvent(self, self.BtnHand, self.OnChangedBtnHand)
	UIUtil.AddOnStateChangedEvent(self, self.BtnFly, self.OnChangedBtnFly)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnFilter, self.OnChangedToggleBtnFilter)
	
	
	self.CommRender2D:SetClick(self, self.OnRender2DClicked)
end

function StoreNewMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.StoreRefreshGoods, self.OnRefreshGoods)
	self:RegisterGameEvent(EventID.StoreRefreshGoodsSelected, self.OnRefreshGoodsSelected)
	self:RegisterGameEvent(EventID.StoreUpdateTabListByTimer, self.OnStoreUpdateTabListByTimer)
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.CompanionCreate, self.OnCompanionCreated)
	self:RegisterGameEvent(EventID.UpdateScore, self.OnScoreUpdate)
	self:RegisterGameEvent(EventID.CounterUpdate, self.OnCounterUpdate)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
	self:RegisterGameEvent(EventID.HairUnlockListChange, self.OnHairUnlockListChange)
	self:RegisterGameEvent(EventID.StorePlaySkillEvent, self.PlayFashionSkill)
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
			if self.CurrentShowActorType == ShowActorType.Human then
				self.CommRender2D.ChildActor:StartFadeIn(0.7, true)
			end
			self.bFirstAvatarAssemble = false
		end
		if self.CurrentShowActorType == ShowActorType.Mount then
			self:OnMountAssembleAllEnd()
		else
			self.CommRender2D:UpdateAllLights()
			if not table.is_nil_empty(self.AssembleAllEndCallbacks) then
				for _, Callback in pairs(self.AssembleAllEndCallbacks) do
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

function StoreNewMainPanelView:OnMountAssembleAllEnd()
	self.CommRender2D:SetRideMeshComponent()
	self.StoreRender2D:InitMountTransform()
	if nil ~= self.CommRender2D.ChildActor then
		local AnimComp = self.CommRender2D.ChildActor:GetAnimationComponent()
		if nil ~= AnimComp then
			AnimComp:SetSitBlendOutTime(0)
		end
		local RideCfgData = RideCfg:FindCfgByKey(self.MountID)
		if nil ~= RideCfgData then
			local RideComponent = self.CommRender2D.ChildActor:GetRideComponent()
			if nil ~= RideComponent then
				if RideCfgData.HideParts == 1 then
					RideComponent:HideRod()
				else
					RideComponent:ShowRod()
				end
			end
		end
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

function StoreNewMainPanelView:OnCounterUpdate(Params)
	local bIsStoreCounterUpdated = false
	for Key, _ in pairs(Params.UpdatedCounters) do
		if nil ~= StoreMgr.LimitCounterMap[Key] then
			bIsStoreCounterUpdated = true
			break
		end
	end
	if bIsStoreCounterUpdated then
		StoreMainVM:RefreshProductsInfo()
	end
end

function StoreNewMainPanelView:OnHairUnlockListChange()
	self.WaitCutHairData = false
end

function StoreNewMainPanelView:OnBagUpdate(Params)
	if nil == Params then
		return
	end
	-- 优惠券变动，商品列表全量刷新
	local CouponIDs = {}
	if nil == StoreMgr.CouponCfg then
		StoreMgr:InitData()
	end
	for _, CouponCfgData in ipairs(StoreMgr.CouponCfg) do
		CouponIDs[CouponCfgData.ID] = true
	end
	local bCouponsUpdated = false
	for _, Item in ipairs(Params) do
		if nil ~= CouponIDs[Item.PstItem.ResID] then
			bCouponsUpdated = true
			break
		end
	end
	if bCouponsUpdated then
		--- 刷新优惠券数据
		StoreMgr:UpdateCouponData()
		StoreMainVM:UpdateCouponData()
		StoreMainVM:RefreshProductsInfo()
		FLOG_INFO("[StoreMgr:OnBagUpdate] Update product list.")
		return -- 全列表刷新过，无需再单独刷新，直接返回
	end

	-- 当前购买的商品信息刷新
	local GoodsID = StoreMainVM:GetCurrentGoodsID()
	if nil == GoodsID then
		return
	end
	local bHasItem = false
	for _, Item in ipairs(Params) do
		bHasItem = StoreMgr.HasItem(GoodsID, Item.PstItem.ResID)
		if bHasItem then
			break
		end
	end

	if bHasItem then
		StoreMainVM:UpdateSingleGoods(GoodsID)
		FLOG_INFO("[StoreMgr:OnBagUpdate] Bag update goods " .. tostring(GoodsID))
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
	if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		return
	end
	if StoreMainVM.bPendingJumpToGoods then
		if self:JumpToGoods() then
			return
		end
	end
	local SelectedGoods = StoreMainVM.JumpToGoodsID or StoreMainVM.SelectedGoods[StoreMainVM:GetCurrentMainTabType()]
	local _, Index = self.GoodsTableViewAdapter:GetItemDataByPredicate(
		function(VM) return VM.GoodID == SelectedGoods end)
	Index = Index or 1
	if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_RECOMMEND then
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

	-- if StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
	-- 	local GoodData
	-- 	if StoreMainVM.GoodSelecteIndex and StoreMainVM.GoodFilterDataList and StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex] then
	-- 		GoodData = StoreMainVM.GoodFilterDataList[StoreMainVM.GoodSelecteIndex]
	-- 	end

	-- 	local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
	-- 	if MainPriceVM and GoodData.Cfg then
	-- 		MainPriceVM:UpdatePriceData(GoodData.Cfg, false, false)
	-- 		UIViewMgr:HideView(UIViewID.StoreNewBuyWinPanel)
	-- 		StoreMainVM:UpdateGoodList(StoreMainVM.GoodFilterDataList)
	-- 	end
	-- end
end

function StoreNewMainPanelView:PlayFashionSkill(InFashionDecorateID, ActionID)
	local Actor = self.StoreRender2D.CommRender2D.ChildActor
	local AvatarPartType = _G.UE.EAvatarPartType.Ornament_Wing
    if Actor then
		local InEntityID = self.StoreRender2D.CommRender2D.ChildActor:GetActorEntityID()
        local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InFashionDecorateID)
        if itemCurrentSelectedCfg ~= nil then
            local itemSkillcfg = FashionDecorateSkillCfg:FindCfgByKey(ActionID)
            if itemSkillcfg ~= nil then
                local UseAnimName = AnimMgr:GetActionTimeLinePath(itemSkillcfg.HumanActiontimeline)
                local UseAnim = _G.ObjectMgr:LoadObjectSync(UseAnimName, ObjectGCType.LRU)
                local AnimComp =  ActorUtil.GetActorAnimationComponent(InEntityID)
				if AnimComp then
					AnimationUtil.PlayAnyAsMontage(InEntityID, UseAnim, "WholeBody", nil, nil, "")
                	AnimComp:PlayAnimation(AnimMgr:GetActionTimeLinePath(itemSkillcfg.OtherActiontimeline), 1.0,0.25,0.25,true, AvatarPartType,true,true)
				end
            end
        end

    end
end

-- 跳转到分类
function StoreNewMainPanelView:JumpToCategory(CategoryIndex)
	if nil == CategoryIndex then
		FLOG_ERROR("[StoreNewMainPanelView:JumpToCategory] Jump to category index is nil")
		return
	end
	-- 默认切换到购买模式
	if StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
		self.CommTabs:SetSelectedIndex(StoreDefine.StoreMode.Buy + 1)
	end
	local MenuKey = _G.StoreMainVM:GetDefaultMenuKey(CategoryIndex)
	if MenuKey == 0 then
		MsgTipsUtil.ShowTipsByID(138006) -- 分类不存在
	end
	self.CommMenu:SetSelectedKey(MenuKey, true)
end

-- 跳转到商品
function StoreNewMainPanelView:JumpToGoods()
	if nil == StoreMainVM.JumpToCategoryIndex then
		return false
	end

	self:JumpToCategory(_G.StoreMainVM.JumpToCategoryIndex)

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
		if StoreMainVM.bIsJumpMysteryBox then
			TableViewAdapter = self.MysteryBoxWidget.GoodsTableViewAdapter
			self.MysteryBoxWidget:OnRegisterBinder()
		end
		local Predicate = function(VM)
			-- return not StoreMainVM.bIsJumpMysteryBox and VM.GoodID == StoreMainVM.JumpToGoodsID or asdasd --预留盲盒数据
			return VM.GoodID == StoreMainVM.JumpToGoodsID
		end
		local _, Index = TableViewAdapter:GetItemDataByPredicate(Predicate)
		bJumpSucceeded = nil ~= Index
		if StoreMainVM.bIsJumpMysteryBox then
			_G.StoreMysteryBoxVM.JumpToIndex = Index
		end
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

	if bJumpSucceeded and not StoreMainVM.bIsJumpMysteryBox then
		-- 跳转成功后清空跳转数据,如果是盲盒，就先不清，因为界面打开的晚，打开之后再清空
		self:ClearJumpData()
	else
		-- 商品列表尚未刷新，待异步刷新后再跳转到商品
		StoreMainVM.bPendingJumpToGoods = true
	end

	return bJumpSucceeded
end

function StoreNewMainPanelView:ClearJumpData()
	StoreMainVM.JumpToCategoryIndex = nil
	StoreMainVM.JumpToGoodsID = nil
	StoreMainVM.bIsOpenBuyWinPanel = true
	StoreMainVM.bPendingJumpToGoods = false
end

function StoreNewMainPanelView:OnChangedToggleBtnFullScreen(ToggleGroup, ToggleButton, BtnState)
	local State = BtnState == _G.UE.EToggleButtonState.Unchecked
	StoreMainVM.bIsFullScreen = State
	local AnimIn = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_RECOMMEND and self.AnimPosterFullScreenIn or self.AnimCommodityFoldFullScreenIn
	local AnimOut = StoreMainVM.CurrentSelectedTabType == StoreMall.STORE_MALL_RECOMMEND and self.AnimPosterFullScreenOut or self.AnimCommodityFoldFullScreenOut
	self:PlayAnimation(State and AnimIn or AnimOut)
	self.ReportBrowseFlow(StoreDefine.BrowseOperationType.ClickFullScreen)

	if self.MysteryBoxWidget ~= nil then
		UIUtil.SetIsVisible(self.MysteryBoxWidget.PanelPoster, not State)
		self.MysteryBoxWidget:PlayAnimation(State and self.MysteryBoxWidget.AnimPosterFullScreenIn or self.MysteryBoxWidget.AnimPosterFullScreenOut)
	end
end

function StoreNewMainPanelView:OnChangedToggleBtnFilter(ToggleGroup, ToggleButton, BtnState)
	local State = BtnState == _G.UE.EToggleButtonState.Unchecked
	StoreMainVM.bIsFilterListShow = State
end

--- 全/半身视角切换
function StoreNewMainPanelView:OnChangedToggleBtnSwitch(ToggleGroup, ToggleButton, BtnState)
	StoreMainVM.bIsAllCameraState = BtnState == _G.UE.EToggleButtonState.Unchecked
	if not StoreMainVM.bIsAllCameraState then
		--- 上一次选中的部位镜头
		-- self.EquipTableViewAdapter:SetSelectedIndex(self.PreviewEquipIndex)
		local TempEquipItem, PreviewIndex
		if UIUtil.IsVisible(self.MysteryBoxWidget) then
			TempEquipItem = self.MysteryBoxWidget.EquipTableViewAdapter:GetItemDataByIndex(self.MysteryBoxWidget.PreviewIndex)
			PreviewIndex = self.MysteryBoxWidget.PreviewIndex
		else
			TempEquipItem = self.EquipTableViewAdapter:GetItemDataByIndex(self.PreviewEquipIndex)
			PreviewIndex = self.PreviewEquipIndex
		end
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
	if self.DefaultModelGender ~= self.CurrentModelGender then
		-- 异性角色禁止原装备显示
		MsgTipsUtil.ShowTipsByID(138007)
		StoreMainVM.bIsShowRawAvatar = false
		self.BtnEquipment:SetChecked(false) -- UToggleButton::SlateOnToggleButtonClicked会默认切换按钮状态，这里强制给他切走
		return
	end
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

--- 切换坐骑飞行状态
function StoreNewMainPanelView:OnChangedBtnFly(ToggleGroup, ToggleButton, BtnState)
	local bFly = BtnState ~= _G.UE.EToggleButtonState.Unchecked
	StoreMainVM.bIsPlayFlyState = not bFly
	local UIComplexCharacter = self.CommRender2D:GetUIComplexCharacter()
	if _G.StoreMysteryBoxVM.CurBoxType == ProtoRes.SpecialMysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_MOUNT_SKIN then
		if UIComplexCharacter ~= nil then
			UIComplexCharacter:SwitchFly(bFly, false)
		end
	end
end

--- 点击购买
function StoreNewMainPanelView:OnClickBuy()
	if self.BuyBtnType == BuyBtnType.Buy then
		local GoodsCfgData = StoreMainVM.SkipTempData
		if self.WaitCutHairData then
			return
		end
		local RecommendGoodsCfgData = StoreMgr.GetRecommendGoodsCfgData(GoodsCfgData)
		local bIsJump = StoreMainVM.JumpID ~= 0 or (nil ~= RecommendGoodsCfgData and RecommendGoodsCfgData.ProductType ==
			ProtoRes.StoreRecommendType.STORE_RECOMMEND_TYPE_PURCHASE)
		if bIsJump then
			if StoreMainVM.JumpID ~= 0 then
				FLOG_INFO("[StoreNewMainPanelView:OnClickBuy] Jump to " .. tostring(StoreMainVM.JumpID))
				JumpUtil.JumpTo(StoreMainVM.JumpID, true)
			elseif nil ~= RecommendGoodsCfgData and nil ~= RecommendGoodsCfgData.GoodsIDs[1] then
				FLOG_INFO("[StoreNewMainPanelView:OnClickBuy] Jump to goods " .. tostring(RecommendGoodsCfgData.GoodsIDs[1]))
				StoreMgr:JumpToGoods(nil, RecommendGoodsCfgData.GoodsIDs[1], true)
			else
				FLOG_ERROR("[StoreNewMainPanelView:OnClickBuy] Jump failed.")
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
						StoreBuyWinVM:UpdateByGoodsID(GoodsCfgData.ID)
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
	elseif self.BuyBtnType == BuyBtnType.CutHair then
		if _G.PWorldMgr:CurrIsInDungeon() then
			_G.MsgTipsUtil.ShowTipsByID(198011)		--- 当前场景无法前往旅馆
		else
			--- 点击前往理发，跳转到地图选中旅馆
        	local IsUnLock = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBarberShop)
			if IsUnLock then
				--- 已解锁，打开地图选中乌尔达哈旅馆
				_G.WorldMapMgr:ShowWorldMapFixPoint(12001, 706)
			else
				--- 未解锁弹窗
				_G.HaircutMgr:OnBeauticiansNotUnlock()
			end
		end
	elseif self.BuyBtnType == BuyBtnType.GoWardrobe then
		if _G.PWorldMgr:CurrIsInDungeon() then
			_G.MsgTipsUtil.ShowTipsByID(1080013)		--- 当前场景无法进入衣橱界面
		else
			UIViewMgr:ShowView(UIViewID.WardrobeMainPanel, {SuitID = self.HoldSuitID})
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
	else
		self.UMGVideoPlayer_UIBP:OnPause()
		self.UMGVideoPlayer_UIBP_Full:OnPause()
	end
	UIUtil.SetIsVisible(self.PanelVideo, IsHaveVideo)
	UIUtil.SetIsVisible(self.UMGVideoPlayer_UIBP, IsHaveVideo)
end

-- 切换待机动作
function StoreNewMainPanelView:SwitchIdlePose(PoseType)
	PoseType = PoseType or 1
	local Render2DCharcter = self.CommRender2D.ChildActor
	local FailCallback = function()
		self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.IdlePose, function() self:SwitchIdlePose(PoseType) end)
	end
	if nil == Render2DCharcter then
		FailCallback()
		return
	end
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	local AnimInst = AnimComp:GetPlayerAnimInstance()
	if nil == AnimInst then
		FailCallback()
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
	if nil == Render2DCharcter or not Render2DCharcter:IsMeshLoaded() then
		self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.StagePose, function() self:PlayStagePose(GoodID) end)
		return
	end
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	AnimComp:PlayAnimation(AnimPath)
end

--- 播放TimeLine
function StoreNewMainPanelView:PlayOrStopEnterAnim(AnimPath, bStop)
	if AnimPath == nil then return end
	local Render2DCharcter = self.CommRender2D.ChildActor
	local AnimComp = Render2DCharcter:GetAnimationComponent()
	if nil == AnimComp then
		return
	end
	if nil == Render2DCharcter or not Render2DCharcter:IsMeshLoaded() then
		if bStop then
			AnimComp:StopAnimation()
		else
			self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.StagePose, function() self:PlayOrStopEnterAnim(AnimPath, bStop) end)
		end
		return
	end
	if bStop then
		AnimComp:StopAnimation()
	else
		AnimComp:PlayAnimation(AnimPath)
	end
end

function StoreNewMainPanelView:StopStagePose()
	local Render2DCharcter = self.CommRender2D.ChildActor
	if nil == Render2DCharcter or not Render2DCharcter:IsMeshLoaded() then
		self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.StagePose, function() self:StopStagePose() end)
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
			self.PlayingID = UE.UAudioMgr.Get():PlayBGM(tonumber(self.CurrentMountBGMID), UE.EBGMChannel.UI)
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
				MountSkillData.Type = 1
				table.insert(TempActionList, MountSkillData)
			end
		end
		StoreMainVM:UpdateMountActionList(TempActionList)
		StoreMainVM.MountPagePanelVisible = true
	end
end

function StoreNewMainPanelView:OnUpdateFashionSkillList(Cfg)
	local TempActionList = {}
	if Cfg and next (Cfg) then
		for i = 1, #Cfg.Action do
			if Cfg.Action[i] ~= 0 then
				local FashionSkillData = {}
				FashionSkillData.SkillID = Cfg.Action[i]
				FashionSkillData.Index = i
				FashionSkillData.Type = 2
				FashionSkillData.ID = Cfg.ID
				table.insert(TempActionList, FashionSkillData)
			end
		end
	end
	StoreMainVM:UpdateMountActionList(TempActionList)
	StoreMainVM.MountPagePanelVisible = true
end

function StoreNewMainPanelView:InitBtnState(GoodsCfgData)
	local bShowRawAvatar = false
	local bShowHelmet = true
	if nil ~= GoodsCfgData then
		bShowRawAvatar = GoodsCfgData.IsBringEquip == 1 and (GoodsCfgData.GenderLimit == 0 or GoodsCfgData.GenderLimit == self.DefaultModelGender)
		bShowHelmet = GoodsCfgData.HideHelmet == 0
	end
	StoreMainVM.bIsShowHat = bShowHelmet
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
		Rotation = Rotation, bNoFadeInOut = true})
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
			self.RenderActorCreateCallback = {}
		end
	end
	self.StoreRender2D:CreateRenderActor({EntityID = EntityID, Callback = Callback, bSyncLoad = bSyncLoad})
end

-- 检查坐骑模型与BGM
function StoreNewMainPanelView:CheckMount(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	StoreMainVM.MountPagePanelVisible = nil ~= GoodsCfgData and GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_MOUNT
	if StoreMainVM.MountPagePanelVisible then
		local ItemData = GoodsCfgData.Items[1]
		if nil == ItemData then -- 默认坐骑类商品只包含一个坐骑物品，配其他物品是非法的（如搭售物品）
			return
		end
		--- 点击坐骑标签
		local ItemCfgData = ItemCfg:FindCfgByKey(ItemData.ID)
		if nil == ItemCfgData then
			return
		end
		local FuncCfgData = FuncCfg:FindCfgByKey(ItemCfgData.UseFunc)
		if nil == FuncCfgData then
			return
		end
		local MountID = FuncCfgData.Func[1].Value[1]
		if nil == MountID then
			return
		end
		if StoreMainVM.bIsPlayMountBgm then
			self:PlayMountBGM(MountID)
		end
		self:OnUpdateMontSkillList(MountID)
		self.MountID = MountID
		if nil ~= StoreMainVM.CurrentSelectedItem then
			StoreMainVM.CurrentSelectedItem.MountID = MountID
		end
		self:RideMount(MountID)
	else
		self:StopMountBGM()
	end
end

--- 预览装备列表
function StoreNewMainPanelView:WearSuit()
	-- if self.IsHidePlayer then 
	-- 	return
	-- end
	local EquipPartList = StoreMainVM.EquipPartList.Items
	local Gender = self.CurrentModelGender
	local IsMale = Gender == ProtoCommon.role_gender.GENDER_MALE

	local SuitData = {}
	local Start, End, Step
	Start, End, Step = 1, #EquipPartList, 1  -- 正序遍历
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

-- 预览商品时的公共显示内容更新（共用UI与3D场景）
function StoreNewMainPanelView:UpdatePreviewGoods(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	if nil == GoodsCfgData then
		return
	end

	-- 共用UI
	self:InitBtnState(GoodsCfgData)
	self:UpdateVideoWidget(GoodsCfgData.VideoPath)

	-- 3D场景
	self.PreviewEquipIndex = 1
	StoreMainVM:SetLeftButtonVisible(GoodsCfgData.LabelMain)
	StoreMainVM.EquipParVisible = GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION
	StoreMainVM.MountPagePanelVisible = GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_MOUNT
	self:CheckMount(GoodsCfgData.ID)
	self.StoreRender2D:StopEmotion()
	local NewShowActorType = ShowActorType.None
	if GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_MOUNT then
		NewShowActorType = ShowActorType.Mount
	elseif GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION then
		StoreMainVM:UpdateEquipPartList(GoodsCfgData)
		NewShowActorType = ShowActorType.Human
		self:CheckGenderModel(GoodsCfgData.GenderLimit)
		self:WearSuit()
		if self:IsViewFirstPartByDefault(GoodsCfgData.ID) then
			self.EquipTableViewAdapter:SetSelectedIndex(1)	--- 单件时默认选中部位
		else
			self:CheckFocusFullBody(GoodsCfgData.ID)
		end
	elseif GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_ACTINGTEXTBOOK then
		NewShowActorType = ShowActorType.Human
		self.StoreRender2D:WearSuit({})
		StoreMainVM.bIsShowRawAvatar = true
		self.StoreRender2D:PlayEmotion(EmotionMgr:GetEmotionIDByItemID(GoodsCfgData.Items[1].ID))
		self:CheckFocusFullBody(GoodsCfgData.ID)
	elseif GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_PET then
		NewShowActorType = ShowActorType.Companion
		self:UpdateCompanionModel(GoodsCfgData)
	elseif GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_ORNAMENT then
		NewShowActorType = ShowActorType.Human
		self.StoreRender2D:WearSuit({})
		StoreMainVM.bIsShowRawAvatar = true
		self:CheckFocusFullBody(GoodsCfgData.ID)
		local itemcfg = FashionDecorateCfg:FindCfgByKey(GoodsCfgData.SpecialID)
		if itemcfg.DecorationType == FashionDecoDefine.FashionDecoType.Umbrella then
			self:PlayOrStopEnterAnim("AnimMontage'/Game/Assets/Character/Action/ornament_sp/m6001/onm_sp02.onm_sp02'")
		else	
			self:PlayOrStopEnterAnim("AnimMontage'/Game/Assets/Character/Action/ornament_sp/m6001/onm_sp02.onm_sp02'", true)
		end
		self:OnUpdateFashionSkillList(itemcfg)
		if self.CurrentDecorationType then
			self.StoreRender2D:DeleteOrnamentData(self.CurrentDecorationType)
			self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.View,
			function()
				self.StoreRender2D:SetOrnamentCompData(itemcfg.DecorationType, GoodsCfgData.SpecialID) 
			end)
		else
			self.StoreRender2D:SetOrnamentCompData(itemcfg.DecorationType, GoodsCfgData.SpecialID)
		end
		self.CurrentDecorationType = itemcfg.DecorationType
		--self:OnUpdateSkillList(GoodsCfgData.SpecialID)
	end
	if GoodsCfgData.LabelMain ~= Store_Label_Type.STORE_LABEL_MAIN_ORNAMENT then
		if self.CurrentDecorationType then
			self.StoreRender2D:DeleteOrnamentData(self.CurrentDecorationType)
			self.CurrentDecorationType = nil
		end
	end
	if self.StoreRender2D.EmotionTimer and GoodsCfgData.LabelMain ~= Store_Label_Type.STORE_LABEL_MAIN_ACTINGTEXTBOOK then
		self.StoreRender2D:UnRegisterEmotionTimer()
	end
	self:UpdateCurrentShowActorType(NewShowActorType)
	if GoodsCfgData.LabelMain == Store_Label_Type.STORE_LABEL_MAIN_FASHION then
		self:PlayStagePose(GoodsCfgData.ID)
	else
		self:ResetToDefaultGenderModel()
	end

	StoreMainVM.ProductName = StoreUtil.GetGoodsName(GoodsCfgData.ID)
end

-- 展示对应部位镜头
function StoreNewMainPanelView:FocusView(Part)
	local Character = self.CommRender2D:GetCharacter()
	if nil ~= Character and Character:IsMeshLoaded() then
		self.StoreRender2D:FocusView(Part)
	else
		self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.View, function() self.StoreRender2D:FocusView(Part) end)
	end
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
	local OffsetY = CameraUtil.GetCameraOffsetY(ViewportPos.X, FOV,
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
	local OffsetY = CameraUtil.GetCameraOffsetY(ViewportPos.X, FOV,
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
function StoreNewMainPanelView:FocusFullBody(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	self.StoreRender2D:UpdateViewGroupID(GoodsCfgData and GoodsCfgData.ViewGroupID or 0)
	self.StoreRender2D:ResetView(true, self:GetViewportPosOfModel())
end

function StoreNewMainPanelView:CheckFocusFullBody(GoodsID)
	local Character = self.CommRender2D:GetCharacter()
	if nil ~= Character and not Character:IsMeshLoaded() then
		self:FocusFullBody(GoodsID)
	else
		self:AddAssembleAllEndCallback(AssembleAllEndCallbackType.View, function() self:FocusFullBody(GoodsID) end)
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

function StoreNewMainPanelView:CheckGenderModel(GenderLimit)
	if nil == GenderLimit or GenderLimit == 0 or GenderLimit == self.DefaultModelGender then
		self:ResetToDefaultGenderModel()
	else
		self:SwitchToOppositeGenderModel()
	end
end

function StoreNewMainPanelView:SwitchToOppositeGenderModel()
	if self.CurrentModelGender ~= self.DefaultModelGender then
		return
	end 
	self.CurrentModelGender = self.DefaultModelGender == ProtoCommon.role_gender.GENDER_MALE and ProtoCommon.role_gender.GENDER_FEMALE or
		ProtoCommon.role_gender.GENDER_MALE
	self.StoreRender2D:SwitchToPresetModel(MajorUtil.GetMajorRaceID(), self.CurrentModelGender)
end

function StoreNewMainPanelView:ResetToDefaultGenderModel()
	if self.CurrentModelGender == self.DefaultModelGender then
		return
	end
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	self.StoreRender2D:ResetToDefaultModel(RoleSimple)
	self.CurrentModelGender = self.DefaultModelGender
end

function StoreNewMainPanelView:UpdateCurrentShowActorType(InCurrentShowActorType)
	local OldShowActorType = self.CurrentShowActorType
	self.CurrentShowActorType = InCurrentShowActorType
	if OldShowActorType ~= self.CurrentShowActorType then
		self:OnShowActorTypeChanged()
	end
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

function StoreNewMainPanelView:AddAssembleAllEndCallback(CallbackType, Callback)
	if nil == CallbackType or nil == Callback then
		return
	end
	self.AssembleAllEndCallbacks[CallbackType] = Callback
end

function StoreNewMainPanelView:AddRenderActorCreateCallback(CallbackType, Callback)
	if nil == CallbackType or nil == Callback then
		return
	end
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
	self.CommRender2D:HidePlayer(true)
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

--- 切换盲盒界面
function StoreNewMainPanelView:ChangeToMysterBoxPanel(BlindBoxVisible)
	UIUtil.SetIsVisible(self.PanelCommodity, not BlindBoxVisible)
	UIUtil.SetIsVisible(self.PanelBtnBuy, not BlindBoxVisible)
	UIUtil.SetIsVisible(self.FVerticalBox_1, not BlindBoxVisible)
	self:UpdateVideoWidget()
	self.StoreRender2D:StopEmotion()
	if BlindBoxVisible then
		if self.CurrentDecorationType then
			self.StoreRender2D:DeleteOrnamentData(self.CurrentDecorationType)
			self.CurrentDecorationType = nil
		end
		StoreMainVM.bIsAllCameraState = false
		_G.StoreMysteryBoxMgr:InitMsteryBoxData(false)
		self.StoreRender2D:WearSuit({})
		if StoreMainVM.bIsShowHat then
			self:OnChangedToggleBtnHat()
		end
		self.CommRender2D:HideWeapon(true)
		self:StopMountBGM()
		self.IsNeedGotoMadePanel = false
	else
		local MountCharacter = self.CommRender2D.ChildActor
		if MountCharacter then
			_G.MountMgr:SetCustomMadeID(MountCharacter, _G.StoreMysteryBoxVM.CurMountID, 1)
		end
	end
	UIUtil.SetIsVisible(self.MysteryBoxWidget, BlindBoxVisible)
end

function StoreNewMainPanelView:CreatMysteryBoxWidget()
	local ObjectGCType = require("Define/ObjectGCType")
	local BPName = "StoreNew/StoreBlindBoxPanel_UIBP"
	local PageView = _G.UIViewMgr:CreateViewByName(BPName, ObjectGCType.NoCache, self, true, false)
	if not PageView then
		_G.FLOG_ERROR("EquipmentNewMainView:CreateViewByName failed, BPName=%s", BPName)
		return
	end
	PageView.SuperView = self
	self.PanelUI:AddChildToCanvas(PageView)
	self.MysteryBoxWidget = PageView
	local Anchor = _G.UE.FAnchors()
	Anchor.Minimum = _G.UE.FVector2D(0, 0)
	Anchor.Maximum = _G.UE.FVector2D(1, 1)
	UIUtil.CanvasSlotSetAnchors(PageView, Anchor)
	UIUtil.CanvasSlotSetPosition(PageView, _G.UE.FVector2D(0, 0))
	local Offset = UIUtil.CanvasSlotGetOffsets(self)
	UIUtil.CanvasSlotSetOffsets(PageView, Offset)
end

return StoreNewMainPanelView
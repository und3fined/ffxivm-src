
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local StoreDefine = require("Game/Store/StoreDefine")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local MysteryboxCfg = require("TableCfg/MysteryboxCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")

--- 盲盒最大购买次数  购买按钮下面显示
local MysterBoxMaxBoughtCount = 6
local LSTR = _G.LSTR
local MysteryBoxTypes = ProtoRes.SpecialMysteryBoxTypes
local StoreMysteryBoxVM = _G.StoreMysteryBoxVM
local ShowActorType =
{
	None = 0,
	Human = 1,
	Mount = 2,
	Companion = 3,
}
local GoToWear = 950104	--- 前往穿戴
local GoToBarber = 950105	--- 前往理发

local BtnBuyMode = {
	BUY = 1,
	Wear = 2,
	Barber = 3
}

---@class StoreBlindBoxPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnLView
---@field BtnBuyRedDot CommonRedDotView
---@field BtnInfo USizeBox
---@field BtnSpacing USpacer
---@field BtnTag1 UFButton
---@field BtnTag2 UFButton
---@field Btn_Video UFButton
---@field CommInforBtn CommInforBtnView
---@field IconVideco UFImage
---@field InforBtn CommInforBtnView
---@field Money StoreMoneyItemUBPView
---@field PanelBtnBuy UFHorizontalBox
---@field PanelCommodity UFHorizontalBox
---@field PanelDownload UFCanvasPanel
---@field PanelDyeing UFHorizontalBox
---@field PanelPoster UFCanvasPanel
---@field PanelPreview UFCanvasPanel
---@field PanelTag UFCanvasPanel
---@field PanelVideo UFCanvasPanel
---@field RichTextBoxBlindBoxHint URichTextBox
---@field TableViewPoster UTableView
---@field TableViewPreview UTableView
---@field TableViewSlot UTableView
---@field TextDownload UFTextBlock
---@field TextDyeing UFTextBlock
---@field TextName UFTextBlock
---@field TextPreview UFTextBlock
---@field TextType UFTextBlock
---@field TextUnavailable UFTextBlock
---@field UMGVideoPlayer_UIBP UMGVideoPlayerView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreBlindBoxPanelView = LuaClass(UIView, true)

function StoreBlindBoxPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnBuyRedDot = nil
	--self.BtnInfo = nil
	--self.BtnSpacing = nil
	--self.BtnTag1 = nil
	--self.BtnTag2 = nil
	--self.Btn_Video = nil
	--self.CommInforBtn = nil
	--self.IconVideco = nil
	--self.InforBtn = nil
	--self.Money = nil
	--self.PanelBtnBuy = nil
	--self.PanelCommodity = nil
	--self.PanelDownload = nil
	--self.PanelDyeing = nil
	--self.PanelPoster = nil
	--self.PanelPreview = nil
	--self.PanelTag = nil
	--self.PanelVideo = nil
	--self.RichTextBoxBlindBoxHint = nil
	--self.TableViewPoster = nil
	--self.TableViewPreview = nil
	--self.TableViewSlot = nil
	--self.TextDownload = nil
	--self.TextDyeing = nil
	--self.TextName = nil
	--self.TextPreview = nil
	--self.TextType = nil
	--self.TextUnavailable = nil
	--self.UMGVideoPlayer_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreBlindBoxPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnBuyRedDot)
	-- self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.Money)
	self:AddSubView(self.UMGVideoPlayer_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreBlindBoxPanelView:OnInit()
	self.GoodsTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPoster, self.OnGoodListSelectChanged, true, false)
	self.EquipTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot, self.OnContainedListSelectChanged, true, false)
	
	self.Binders = {
		{ "GoodsList", UIBinderUpdateBindableList.New(self, self.GoodsTableViewAdapter) },
		{ "ContainedItems", UIBinderUpdateBindableList.New(self, self.EquipTableViewAdapter) },
		{ "CurrentPriceText", UIBinderSetText.New(self, self.Money.TextPrice) },
		{ "OriginalPriceText", UIBinderSetText.New(self, self.Money.TextOriginalPrice) },
		{ "TextName", UIBinderSetText.New(self, self.TextName) },
		{ "OriginalPriceVisible", UIBinderSetIsVisible.New(self, self.Money.PanelOriginalPrice) },
		{ "CurBoxType",UIBinderValueChangedCallback.New(self, nil, self.OnSelectedTabTypeChanged) },
		{ "BuyPriceTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Money.TextPrice) },
	}
	self.BtnBuy.TextContent:SetText(LSTR(950086))

	self.BtnBuyMode = BtnBuyMode.BUY
	self.PreviewIndex = 1
end

function StoreBlindBoxPanelView:OnShow()
	UIUtil.SetIsVisible(self.Money.IconCoupons, false)
	if not _G.StoreMainVM.bPendingJumpToGoods then
		self.GoodsTableViewAdapter:SetSelectedIndex(1)
		self.GoodsTableViewAdapter:ScrollToIndex(1)
	else
		self.GoodsTableViewAdapter:SetSelectedIndex(StoreMysteryBoxVM.JumpToIndex)
		self.GoodsTableViewAdapter:ScrollToIndex(StoreMysteryBoxVM.JumpToIndex)
	end
	---蓝图配置第一次不生效，断点看获取的style是nil，代码设置一下
    self.InforBtn:SetButtonStyle(1)
	self.SuperView:ClearJumpData()
end

function StoreBlindBoxPanelView:OnSelectedTabTypeChanged(NewValue)

	local bIsMount_Skin = NewValue == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_MOUNT_SKIN
	local bIsHair = NewValue == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE
	if bIsMount_Skin then
		self.SuperView:UpdateCurrentShowActorType(ShowActorType.Mount)
		self.SuperView:RideMount(_G.StoreMysteryBoxVM.CurMountID)
	else
		self.SuperView:UpdateCurrentShowActorType(ShowActorType.Human)
	end
	_G.StoreMainVM.BtnFlyVisible = bIsMount_Skin and _G.StoreMysteryBoxVM.CurMountID ~= 0 and _G.StoreMysteryBoxVM.CurMountID == 1001
	UIUtil.SetIsVisible(self.SuperView.BtnSwitch, not bIsMount_Skin, true)
	UIUtil.SetIsVisible(self.SuperView.BtnEquipment, not bIsMount_Skin and not bIsHair, true)
	UIUtil.SetIsVisible(self.SuperView.BtnHat, bIsHair, true)
	self.PreviewIndex = 1
end

function StoreBlindBoxPanelView:OnDestroy()

end

--- 切换选中盲盒
function StoreBlindBoxPanelView:OnGoodListSelectChanged(Index, ItemData, ItemView, bIsByClick)
	self.SuperView.StoreRender2D:WearSuit({})
	StoreMysteryBoxVM:ChangeSelect(Index)
	_G.StoreMainVM.bIsShowRawAvatar = StoreMysteryBoxVM.CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE
	self:OnStoreUpdateBlindText({BlindBoxID = ItemData.BlindBoxID, DrawCount = _G.StoreMysteryBoxMgr:GetMysteryBoxBoughtCountByID(ItemData.BlindBoxID)})
	self:OnSelectEquipList()
	--- 暂时没有新购买蓝图，还用原来的VM
	local MainPriceVM = _G.StoreMgr:GetBuyPriceVM()
	MainPriceVM:UpdatePriceData(StoreMysteryBoxVM.CurBoxCfgData, false, false)
	MainPriceVM.bShowRawPrice = StoreMysteryBoxVM:GetCurBlindIsOnCountTime()
	local IsOwned = ItemData.IsOwned
	UIUtil.SetIsVisible(self.Money.PanelMoney, not IsOwned)
	self:UpdateBuyBtnState(IsOwned)
	self.PreviewIndex = Index
end

function StoreBlindBoxPanelView:UpdateBuyBtnState(IsOwned)
	if IsOwned then
		--- 改为前往理发、前往穿戴
		local CurBoxType = StoreMysteryBoxVM.CurBoxType
		local BtnText = CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_CLOTHING and GoToWear or CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE and GoToBarber or nil
		self.BtnBuyMode = CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_CLOTHING and BtnBuyMode.Wear or CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_HAIRSTYLE and BtnBuyMode.Barber or BtnBuyMode.BUY
		if BtnText == nil then
			self.BtnBuy:SetIsDoneState(true)
		else
			self.BtnBuy:SetIsRecommendState(true)
		end
		self.BtnBuy.TextContent:SetText(BtnText == nil and LSTR(StoreDefine.SecondScreenType.Owned) or LSTR(BtnText))	--- 购买一次
		UIUtil.SetIsVisible(self.Money.PanelMoney, false)
	else
		self.BtnBuyMode = BtnBuyMode.BUY
		self.BtnBuy:SetIsRecommendState(true)
		self.BtnBuy.TextContent:SetText(LSTR(950086))	--- 购买一次
	end
end

--- 点击左侧包含物品列表
function StoreBlindBoxPanelView:OnContainedListSelectChanged(Index, ItemData, ItemView, bIsByClick)
	StoreMysteryBoxVM:OnSelectChanged(Index)
	if StoreMysteryBoxVM.CurBoxType == MysteryBoxTypes.SPECIAL_MYSTERYBOXTYPE_MOUNT_SKIN then
		local MountCharacter = self.SuperView.CommRender2D.ChildActor
		if MountCharacter then
			local CustomMadeID = _G.StoreMysteryBoxMgr:GetCustomMadeIDByResID(ItemData.ID)
			_G.MountMgr:SetCustomMadeID(MountCharacter, StoreMysteryBoxVM.CurMountID, CustomMadeID)
		end
	else
		self.SuperView.StoreRender2D:WearAppearance(ItemData, true)
		self.SuperView:FocusView(ItemData.Part)
	end

	self.TextType:SetText(ItemData.ItemName)
end

function StoreBlindBoxPanelView:OnHide()
	_G.StoreMainVM.BtnFlyVisible = false
end

function StoreBlindBoxPanelView:OnSelectEquipList()
	local Index = 1
	for i = 1, #StoreMysteryBoxVM.ContainedItems.Items do
		local ItemData = StoreMysteryBoxVM.ContainedItems.Items[i]
		if not ItemData.bOwned then
			Index = i
			break
		end
	end
	self.EquipTableViewAdapter:SetSelectedIndex(Index)
end

function StoreBlindBoxPanelView:OnRegisterUIEvent()
	self.InforBtn:SetCallback(self, self.OnClickInforBtn)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickBuy)
end

function StoreBlindBoxPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.StoreUpdateBlindText, self.OnStoreUpdateBlindText)
end

--- 刷新盲盒购买后n次获得所有奖励
function StoreBlindBoxPanelView:OnStoreUpdateBlindText(Params)
	local BlindBoxID = Params.BlindBoxID
	local DrawCount = Params.DrawCount
	local ItemData = MysteryboxCfg:FindCfgByKey(BlindBoxID)
	if not ItemData then return end

	if MysterBoxMaxBoughtCount - DrawCount > 0 then
		self.RichTextBoxBlindBoxHint:SetText(string.format(ItemData.Desc, MysterBoxMaxBoughtCount - DrawCount))
	else
		self.RichTextBoxBlindBoxHint:SetText("")
	end

	--- 更新购买按钮
	self:UpdateBuyBtnState(_G.StoreMysteryBoxMgr:CheckGoodsIsOwned(StoreMysteryBoxVM.CurBoxCfgData))
end

function StoreBlindBoxPanelView:OnRegisterBinder()
	self:RegisterBinders(StoreMysteryBoxVM, self.Binders)
end

--- 奇遇盲盒Tips
function StoreBlindBoxPanelView:OnClickInforBtn()
	UIViewMgr:ShowView(_G.UIViewID.StoreNewBlindBoxDescription)
end

--- 点击购买
function StoreBlindBoxPanelView:OnClickBuy()
	if self.BtnBuyMode == BtnBuyMode.BUY then
		if _G.StoreMysteryBoxMgr:CheckBuyCond(StoreMysteryBoxVM.CurBoxCfgData) then
			UIViewMgr:ShowView(_G.UIViewID.StoreBlindBoxBuyWinPanel)
		end
	elseif self.BtnBuyMode == BtnBuyMode.Wear then
		--- 前往穿戴
		if _G.PWorldMgr:CurrIsInDungeon() then
			_G.MsgTipsUtil.ShowTipsByID(1080013)		--- 当前场景无法进入衣橱界面
		else
			--- 点击前往穿戴回调，目前盲盒没有套装，都是散件
			local TempItem = StoreMysteryBoxVM:GetContainedItemsItem(1)
			if TempItem ~= nil then
				local TempEquipmentCfg = EquipmentCfg:FindCfgByKey(TempItem.EquipmentID)
				if TempEquipmentCfg ~= nil then
					local AppearanceID = TempEquipmentCfg.AppearanceID
					local PartID = WardrobeUtil.GetPartByAppearanceID(AppearanceID)
					UIViewMgr:ShowView(UIViewID.WardrobeMainPanel, {PartID = PartID})
				end
			end
		end
	elseif self.BtnBuyMode == BtnBuyMode.Barber then
		--- 前往理发
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
	end
end

return StoreBlindBoxPanelView
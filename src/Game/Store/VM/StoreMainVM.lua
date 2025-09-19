---
---@author Lucas
---DateTime: 2023-04-28 11:51:00
---Description:

local LuaClass = require("Core/LuaClass")

local UIViewID = require("Define/UIViewID")
local UIViewModel = require("UI/UIViewModel")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBindableList = require("UI/UIBindableList")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewMgr = require("UI/UIViewMgr")
local ScoreMgr = require("Game/Score/ScoreMgr")
local BagMgr = require("Game/Bag/BagMgr")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local MathUtil = require("Utils/MathUtil")
local ScoreCfg = require("TableCfg/ScoreCfg")
local StoreGiftstyleCfg = require("TableCfg/StoreGiftstyleCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local StoreCouponCfg = require("TableCfg/StoreCouponCfg")
local MysteryboxCfg = require("TableCfg/MysteryboxCfg")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local CommercializationRandCfg = require("TableCfg/CommercializationRandCfg")

local UIDefine = require("Define/UIDefine")
local StoreDefine = require("Game/Store/StoreDefine")
local FriendDefine = require("Game/Social/Friend/FriendDefine")

local StoreCfg = require("TableCfg/StoreCfg")
local StoreMountActionItemVM = require("Game/Store/VM/ItemVM/StoreMountActionItemVM")
local StoreFilterVM = require("Game/Store/VM/ItemVM/StoreFilterVM")
local StoreGoodVM = require("Game/Store/VM/ItemVM/StoreGoodVM")
local StoreMysterBoxGoodsItemVM = require("Game/Store/VM/ItemVM/StoreMysterBoxGoodsItemVM")
local StoreEquipPartVM = require("Game/Store/VM/ItemVM/StoreEquipPartVM")
local StorePropsItemVM = require("Game/Store/VM/ItemVM/StorePropsItemVM")
local StoreDyeFilterVM = require("Game/Store/VM/ItemVM/StoreDyeFilterVM")
local StoreGiftFriendItemVM = require("Game/Store/VM/ItemVM/StoreGiftFriendItemVM")
local StoreGiftMailStyleItemVM = require("Game/Store/VM/ItemVM/StoreGiftMailStyleItemVM")
local StoreNotMatchTipsVM = require("Game/Store/VM/StoreNotMatchTipsVM")
local StoreGiftMailVM = require("Game/Store/VM/StoreGiftMailVM")
local StoreNewCouponItemVM = require("Game/Store/VM/ItemVM/StoreNewCouponItemVM")
local StoreNewCouponItemTittleVM = require("Game/Store/VM/ItemVM/StoreNewCouponItemTittleVM")
local ItemVM = require("Game/Item/ItemVM")
local ItemTipsVM = require("Game/Item/ItemTipsVM")
local FriendVM = require("Game/Social/Friend/FriendVM")
local StoreNewBlindBoxDescItemVM = require("Game/Store/VM/ItemVM/StoreNewBlindBoxDescItemVM")

local CommBtnColorType = UIDefine.CommBtnColorType
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local LSTR = _G.LSTR

local StoreMgr = _G.StoreMgr
local StoreMall = ProtoRes.StoreMall
local Store_CouponType = ProtoRes.Store_CouponType

---@class StoreMainVM: UIViewModel
---@field TabList table @商品一级类型列表
---@field MountActionList table @坐骑动作列表
---@field ProductName string @商品名称
---@field DyeTipsText boolean @染色提示文本
---@field DyeCommonInforBtnVisible boolean @染色提示通用帮助按钮显隐
---@field EquipPartList table @装备部位列表
---@field EquipParVisible boolean @装备部位是否显示
---@field FilterList table @商品二级类型列表
---@field GoodList table @商品列表
---@field PropsList table @道具列表
---@field PropsSortList table @道具筛选列表
---@field CurrentStoreMode table @当前商城模式 购买/赠送
---@field CurrentSelectedItem table @当前选中ItemData
---@field MultiBuyBg string @批量购买界面商品背景
---@field MultiBuyDesc string @批量购买界面商品描述
---@field MultiDisPanelVisible string @批量购买界面折扣显隐
---@field MultiDisText string @批量购买界面折扣text
---@field MultiBuyIcon string @批量购买界面商品图标
---@field MultiBuyName string @批量购买界面商品名字
---@field bMultiBuyPanelHQVisible string @批量购买界面商品HQPanel显隐
---@field MultiBuySubName string @批量购买界面商品类别
---@field MultiBuyPrice string @批量购买界面商品价格
---@field MultiBuyPriceText string @批量购买界面商品格式化价格
---@field MultiBuyPriceType string @批量购买界面商品价格类型
---@field MultiBuyPurchaseNumber string @批量购买界面商品购买数量
---@field MultiBuyQuantity string @批量购买界面商品可购买数量
---@field BuyGoodBg string @购买界面商品背景
---@field BuyGoodIcon string @购买界面商品图标
---@field bBuyGoodBgVisible boolean @购买界面商品背景是否显示
---@field bBuyGoodIconVisible boolean @购买界面商品图标是否显示
---@field BuyGoodSubName string @购买界面商品类别
---@field BuyGoodPrice string @购买界面商品价格
---@field BuyGoodPriceText string @购买界面商品价格
---@field PanelOriginalVisible string @购买界面商品折前价格显隐
---@field MainBackGroundPath string @模型背景
---@field ContainsItemList table @购买界面商品包含物品列表
---@field bMultiBuyPanelOriginalVisible table @多件购买界面原价显隐
---@field bMultiBuyOriginalPriceText table @多件购买见面原价Text
---@field TabSelecteIndex number @选中的商品一级类型索引
---@field GoodSelecteIndex number @选中的商品索引
---@field FilterSelecteIndex number @选中的商品二级类型索引
---@field GoodDataList table @当前商品数据列表
---@field GoodFilterDataList table @当前商品筛选过的列表
---@field FilterDataList table @当前商品筛选过的列表
---@field PropsSelecteIndex number @选中的染色索引
---@field QuantityPurchased number @已购买数量
---@field bSecondScreen boolean @是否二次筛选
---@field CommBGVisible boolean @通用蒙版是否显示
---@field MultiBuySlider CommSliderHorizontalView @多件购买界面拖动条控件
---@field MultiBuyConfirmBtn CommBtnLView @多件购买界面确认按钮控件
---@field ItemTipsVMData ItemTipsVM @物品提示界面数据
---@field MultiBuyLimitNum number @多件购买界面限制数量
---@field bMultiBuySliderEnabled boolean @多件购买界面滑动条Enabled
---@field IsOverPurchaseLimit boolean @多件购买界面是否超过购买限制
---@field bMultiBuyBuyForOther boolean @多件购买界面是否可赠送
---@field PanelBuyVisible boolean @购买按钮显隐
---@field PanelPriceVisible boolean @价格界面显隐
-- ---@field PanelGoodsVisible boolean @物品界面显隐
---@field PanelOwnVisible boolean @已拥有显隐
---@field MountActionListVisible boolean @坐骑情感动作显隐
---@field OriginalPriceText string @原价
---@field PriceType string @价格类型
---@field ClothingPagePanelVisible boolean @套装界面功能按钮
---@field WeaponPagePanelVisible boolean @武器界面功能按钮
---@field MountPagePanelVisible boolean @坐骑界面功能按钮
---@field SheetMusicPagePanelVisible boolean @---
---@field CurrentSelectedTabType ProtoRes.StoreMall @当前选择的标签类型 服装/武器/坐骑/道具
---@field bIsShowHat boolean @服装界面-头盔
---@field bIsShowHatStyle boolean @-头部
---@field bIsShowRawAvatar boolean @-素体
---@field bIsShowBtnPose boolean @武器界面-是否拔出武器
---@field bIsOnRide boolean @坐骑界面-是否骑乘坐骑
---@field bIsPlayMountBgm boolean @-是否播放坐骑BGM
---@field JumpToCategoryIndex number @获取途径跳转Tab ID
---@field JumpToItemID number	@获取途径跳转物品 ID
---@field PropsPanelVisibl boolean @道具界面
---@field GoodsPanelVisible boolean @物品收起界面
---@field DiscountPanelVisible boolean @折扣panel
---@field DeadlinePanelVisible boolean @限时panel
---@field OriginalPanelVisible boolean @限时panel

local StoreMainVM = LuaClass(UIViewModel)


function StoreMainVM:Ctor()
	self.TabList = {}
	self.MountActionList = UIBindableList.New(StoreMountActionItemVM)
    self.EquipPartList = UIBindableList.New(StoreEquipPartVM)
    self.FilterList = UIBindableList.New(StoreFilterVM)
    self.GoodList = UIBindableList.New(StoreGoodVM)
    self.PropsList = UIBindableList.New(StorePropsItemVM)
    self.ContainsItemList = UIBindableList.New(ItemVM, {IsCanBeSelected = true, IsShowNum = false, IsShowSelectStatus = false})
    self.PropsSortList = UIBindableList.New(StoreDyeFilterVM)
	self.SpecailTipsList = UIBindableList.New(StoreNotMatchTipsVM)
	self.FriendItemVMList = UIBindableList.New(StoreGiftFriendItemVM)
	self.StyleList = UIBindableList.New(StoreGiftMailStyleItemVM)
    self.ItemTipsVMData = ItemTipsVM.New()
	self.MysteryBosItemVMList = UIBindableList.New(StoreNewBlindBoxDescItemVM)
	
	self.TittleText = LSTR(StoreDefine.LSTRTextKey.StoreTittleText)

	self.PosterPanelVisible = false		--- 推荐页
    self.PanelGoodsVisible = true
    self.GoodsExpandPageVisible = false
    self.PanelPropsVisible = true
    self.PanelBuyVisible = false
    self.PanelPriceVisible = false
	self.PanelOwnVisible = false
	self.CouponNum = 0	--- 具体折扣多少数额
	self.CurCouponResID = 0	--- 选中的优惠券ID
	self.bUseCoupon = true	--- 是否使用优惠券
	self.UseCouponGID = 0	--- 当前选中的优惠券GID
	self.JumpID = 0
	self.TabSelecteType = 0
	--- 外部打开购买界面时需要显示的配置
	self.SkipTempData = nil


	self.BuyGoodBg = ""
    self.BuyGoodIcon = ""
    self.ProductName = ""
    self.BuyGoodSubName = ""
	self.BuyGoodPriceText = ""
    self.BuyGoodPrice = ""
    self.PanelOriginalVisible = false
	self.OriginalPriceText = ""
	self.MainBackGroundPath = ""
	self.DyeCommonInforBtnVisible = false
	self.DyeTipsText = ""
	self.bDyeInforPanelVisible = false
	self.UnavailableText = ""
    self.EquipParVisible = false
	self.ImgTag1Path = ""
	self.ImgTag2Path = ""
	self.ImgTag1Visible = false
	self.ImgTag2Visible = false
	self.bTagPanelVisible = false
	-- 0购买/1赠送
	self.CurrentStoreMode = 0
	self.BuyBtnText = LSTR(StoreDefine.StoreModeText[self.CurrentStoreMode])
	self.CurrentSelectedItem = nil
	self.CurrentselectedID = 0

	self.CommTipsBtnVisible = false
	self.CommTipsTextVisible = false
    self.MultiBuyBg = ""
    self.MultiBuyDesc = ""
	self.MultiDisPanelVisible = false
	self.MultiDisText = ""
    self.MultiBuyIcon = ""
    self.MultiBuyName = ""
	self.bMultiBuyPanelHQVisible = false
    self.MultiBuySubName = ""
    self.MultiBuyPrice = ""
    self.MultiBuyPriceText = ""
    self.MultiBuyPriceType = ""
    self.MultiBuyPurchaseNumber = 1
    self.MultiBuyQuantity = ""

	self.bIsAllCameraState = true
	self.bIsFullScreen = false
	self.bIsShowHat = true
	self.bIsShowHatStyle = false
	self.bIsShowRawAvatar = true
	self.bIsShowBtnPose = false
	self.bIsOnRide = true
	self.bIsPlayMountBgm = true
	self.DyeCommonInforID = -1

    self.bBuyGoodBgVisible = false
    self.bBuyGoodIconVisible = false

    self.bSecondScreen = false
	self.CommBGVisible = false

    self.GoodDataList = nil
    self.GoodFilterDataList = nil
    self.FilterDataList = nil

    self.MultiBuySlider = nil
    self.MultiBuyConfirmBtn = nil
	self.bMultiBuySliderEnabled = false
	self.IsOverPurchaseLimit = false
	self.bMultiBuyBuyForOther = false
	self.bMultiBuyPanelOriginalVisible = false
	self.bMultiBuyOriginalPriceText = ""
	
	self.QuantityPurchased = 1
    self.TabSelecteIndex = 1
    self.GoodSelecteIndex = 0
    self.FilterSelecteIndex = 0
    self.PropsSelecteIndex = 1
    self.MultiBuyLimitNum = 0

	self.MountActionListVisible = false

	self.SpecailTipsPanelVisible = false
	self.CommTipsPanelVisible = false


	self.ClothingPagePanelVisible = false
	self.WeaponPagePanelVisible = false
	self.MountPagePanelVisible = false
	self.SheetMusicPagePanelVisible = false
	self.CurrentSelectedTabType = nil

	self.JumpToCategoryIndex = nil
	self.JumpToItemID = 0
	self.bPendingJumpToGoods = false
	
	self.GoodsPanelVisible = false
	self.PropsPanelVisible = false

	--- 赠礼用
	self.DiscountPanelVisible = false
	self.DeadlinePanelVisible = false
	self.DiscountText = ""
	self.IsShowTimeSaleIcon = true	--- 是否限时限时的表钟图标  大于99天不显示
	self.TimeSaleText = ""
	self.OriginalPanelVisible = false
	self.PanelAmountVisible = false
	self.NormalTipsID = nil
	self.TargetRoleID = nil
	self.ToName = ""
	self.FromName = ""
	self.GiftPriceText = ""

	self.FriendList = {}
	self.FriendNum = 0
	self.SelectedStyleIndex = 1
	self.MultiBuyConfirmBtnImgType = CommBtnColorType.Normal
	self.GiftChooseImgBlackLucency = "0000008F"

	self.bIsOpenBuyWinPanel = true
	self.SelectedGoods = {} -- 不同主分类下选中的商品ID
end

function StoreMainVM:OnShutdown()
    -- self.TabList:Clear()
	self.TabList = {}
    self.EquipPartList:Clear()
    self.FilterList:Clear()
    self.GoodList:Clear()
    self.PropsList:Clear()
    self.ContainsItemList:Clear()
    self.PropsSortList:Clear()

    self.GoodDataList = nil
    self.GoodFilterDataList = nil
    self.FilterDataList = nil

    self.MultiBuySlider = nil
	self.SelectedGoods = {}

	self.GiftstyleCfg = nil
end

--- 更新选择优惠券界面的数据
function StoreMainVM:UpdateCouponData()
	StoreMgr:UpdateCouponValid()

	local CouponList = UIBindableList.New()
	local ValidList = {}
	local UnValidList = {}
	local Index = 1
	local TempCouponList = StoreMgr.CouponList
	for _, value in ipairs(TempCouponList) do
		local TempTable = value.IsValid and ValidList or UnValidList
		table.insert(TempTable, value)
	end
	--- 有效列表
	if #ValidList > 0 then
		local TempTittleVM = StoreNewCouponItemTittleVM.New()
		TempTittleVM:UpdateVM({TittleText = LSTR(StoreDefine.LSTRTextKey.ValidCouponText)})	--- 可用优惠券
		CouponList:Add(TempTittleVM)
		for _, value in ipairs(ValidList) do
			local TempItemVM = StoreNewCouponItemVM.New()
			TempItemVM:UpdateVM({Value = value, Index = Index, bCanSelect = true})
			CouponList:Add(TempItemVM)
			Index = Index + 1
		end
	end
	--- 无效列表
	if #UnValidList > 0 then
		local TempTittleVM = StoreNewCouponItemTittleVM.New()
		TempTittleVM:UpdateVM({TittleText = LSTR(StoreDefine.LSTRTextKey.UnValidCouponText)})	--- 不可用优惠券
		CouponList:Add(TempTittleVM)
		for _, value in ipairs(UnValidList) do
			local TempItemVM = StoreNewCouponItemVM.New()
			TempItemVM:UpdateVM({Value = value, Index = Index, bCanSelect = false})
			CouponList:Add(TempItemVM)
			Index = Index + 1
		end
	end
	self.CouponList = CouponList

end

function StoreMainVM:UpdateCouponChoose(Index, ResID, EnableState)
	if table.is_nil_empty(self.CouponList) then
		self:UpdateCouponData()
	end
	local Items = self.CouponList:GetItems()
	local Length = self.CouponList:Length()
	--- 初始化时选中第一个ResID相同的优惠券
	if Index == 0 and ResID ~= nil then
		for i = 1, Length do
			local Item = Items[i]
			if ResID == Item.ResID then
				Index = Item.Index
				break
			end
		end
	end
	for i = 1, Length do
		local Item = Items[i]
		if Item.SetCheckBosEnable then
			Item:SetCheckBosEnable(Index == Item.Index and EnableState)
		end
	end
end

--- 更新优惠券选中 --- 确认优惠券回调
function StoreMainVM:UpdateCouponsSelectedState(GoodsCfgData)
	self.CurCouponResID = 0
	self.UseCouponGID = 0
	local Items = self.CouponList:GetItems()
	local Length = self.CouponList:Length()
	for i = 1, Length do
		local Item = Items[i]
		if Item.CheckBoxEnable then
			self.CurCouponResID = Item.ResID
			self.UseCouponGID = Item.GID
		end
	end
	if nil == GoodsCfgData then
		if table.is_nil_empty(self.GoodFilterDataList) or self.GoodSelecteIndex == 0 then
			GoodsCfgData = self.SkipTempData
		else
			GoodsCfgData = self.GoodFilterDataList[self.GoodSelecteIndex].Cfg
		end
	end
	self.bUseCoupon = self.CurCouponResID > 0
	local PriceVM = _G.StoreMgr:GetBuyPriceVM()
	if nil ~= PriceVM then
		PriceVM:UpdatePriceData(GoodsCfgData)
	end
end

---@type 界面显示初始化
function StoreMainVM:InitData()
	self.TittleText = LSTR(StoreDefine.LSTRTextKey.StoreTittleText)

    self:UpdateTabList()
	if self.GiftstyleCfg == nil then
		local GiftstyleCfg = StoreGiftstyleCfg:FindAllCfg()
		self.GiftstyleCfg = GiftstyleCfg
	end
end

---@type 刷新页签列表
function StoreMainVM:UpdateTabList()
	local TabListData = {}			--- 购买用的TabList
	local GiftModeCategory = {}		--- 赠礼用的TabList
    local ProductCategory = StoreMgr:GetProductCategory()
	for _, Category in ipairs(ProductCategory) do
		local IsCanbeGift = false
		--- 商城3.0特殊Tab 发型盲盒 不读商城表  / 推荐页不检查列表内是否有商品
		-- Category.Type == StoreMall.STORE_MALL_MYSTERYBOX
		local TempProductList = StoreMgr:GetProductDataByCategory(Category, self.CurrentStoreMode)
		--- 主分类下没有商品时隐藏分类
		if #TempProductList > 0 or Category.Type == StoreMall.STORE_MALL_RECOMMEND then
			local Index = #TabListData + 1
			local Children = {}
			for index, value in ipairs(Category.SubCategory) do
				--- 子分类下没有商品时隐藏分类
				local TempDataList = StoreMgr:GetProductDataByLabelSub(TempProductList, value)
				if #TempDataList > 0 or index == 1 or Category.Type == StoreMall.STORE_MALL_RECOMMEND then
					local ItemData = {
						Key = Index * 10 + index,
						Name = value
					}
					table.insert(Children, ItemData)
				end
			end
			if #Children == 1 then
				Children = nil
			end
			local TempItemTab = {
				Name = Category.MainCategory,
				Key = Index,
				Children = Children,
				DisplayID = Category.DisplayID,
				IsDisplayHaveFilter = Category.IsDisplayHaveFilter == 1,
			}
			if Category.Type == StoreMall.STORE_MALL_MYSTERYBOX then
				TempItemTab.RedDotID = 19
			end
			if self.CurrentStoreMode == StoreDefine.StoreMode.Gift then
				if Category.Type ~= StoreMall.STORE_MALL_MYSTERYBOX then
					table.insert(TabListData, TempItemTab)
				end
			else
				table.insert(TabListData, TempItemTab)
			end
			for _, value in ipairs(TempProductList) do
				if value.Cfg.BuyForOther == 1 then
					IsCanbeGift = true
					break
				end
			end
			if IsCanbeGift or Category.Type == StoreMall.STORE_MALL_RECOMMEND then
				table.insert(GiftModeCategory, Category)
			end
		end
    end
	StoreMgr.GiftModeProductCategory = GiftModeCategory
	

	-- table.sort(TabListData, function(a,b) return a.DisplayID < b.DisplayID end ) -- StoreMgr.ProductCategory已排序，无需重复排序
	self.TabList = TabListData
end

--- 更新礼物风格列表
function StoreMainVM:UpdateStyleList()
	if true then return end
	local GiftstyleCfg = self.GiftstyleCfg
	if GiftstyleCfg == nil then
		return
	end
	local UnlockedStylelist = StoreMgr:GetUnlockedDecorativeStyleList()
	local ItemData = {}
	for i = 1, #GiftstyleCfg do
		local TempItem = {}
		TempItem.IconPath = GiftstyleCfg[i].IconPath
		TempItem.Islock = true
		table.insert(ItemData, TempItem)
	end
	self.StyleList:UpdateByValues(ItemData)
	for i = 1, #UnlockedStylelist do
		local StyleListItem = self.StyleList:Get(i)
		if StyleListItem ~= nil then
			StyleListItem.Islock = false
		end
	end
end

function StoreMainVM:UpdateFriendList()
	local FriendVMList = FriendVM.ShowingFriendEntryVMList
	if nil == FriendVMList then
		FLOG_ERROR("[StoreMainVM:UpdateFriendList] FriendVM.ShowingFriendEntryVMList is nil")
		return
	end
	local NewFriendVMList = {}
	for _, FriendItem in ipairs(FriendVMList.Items) do
		if not _G.FriendMgr:IsInBlackList(FriendItem.RoleID) then
			table.insert(NewFriendVMList, FriendItem)
			_G.RoleInfoMgr:QueryRoleSimple(FriendItem.RoleID, self.UpdateFriendDetail, self, false)
		end
	end
	self.FriendItemVMList:UpdateByValues(NewFriendVMList)
	self.FriendNum = #self.FriendItemVMList.Items
end

function StoreMainVM:UpdateFriendDetail(ViewModel)
	self.FriendList[ViewModel.RoleID] = ViewModel
end

---@type 刷新商品列表数据
---@param Index number @一级标签索引
function StoreMainVM:UpdateProductList()
    local Category = StoreMgr:GetProductCategory(self.TabSelecteIndex)
    self.GoodDataList = StoreMgr:GetProductDataByCategory(Category, self.CurrentStoreMode)
	
	local CurrentTabIndexIsProps = StoreMgr:CheckMallTypeByIndex(self.TabSelecteIndex, ProtoRes.StoreMall.STORE_MALL_PROPS)
	self.PanelAmountVisible = CurrentTabIndexIsProps
	

    self:ChangeFilter()
end

---@type 切换购买模式
---@param Index number @购买模式索引
function StoreMainVM:ChangePurchaseMethod(Index)
	self.CurrentStoreMode = Index
	self.BuyBtnText = LSTR(StoreDefine.StoreModeText[self.CurrentStoreMode])
	self:OnSwitchMode(Index)
end

---@type 切换标签
---@param Index number @一级标签索引
---@param SubIndex number @二级页签索引
function StoreMainVM:ChangeTab(Index, SubIndex)
    if Index == nil or Index == 0 then
        return
    end
    -- if self.TabSelecteIndex == Index then
    --     return
    -- end
	self.ProductName = ""

    self.PropsSortList:Clear()
    self.GoodList:Clear()

	local IsPropsPage = StoreMgr:CheckMallTypeByIndex(Index, ProtoRes.StoreMall.STORE_MALL_PROPS)
	local IsPosterPage = StoreMgr:CheckMallTypeByIndex(Index, ProtoRes.StoreMall.STORE_MALL_RECOMMEND)
	local IsHairMysterybox = StoreMgr:CheckMallTypeByIndex(Index, ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX)
	self.PosterPanelVisible = IsPosterPage or IsHairMysterybox
    self.PanelPropsVisible = IsPropsPage
	self.PanelGoodsVisible = not IsPropsPage and not IsPosterPage
	self.GoodsExpandPageVisible = false
	self.PanelBuyVisible = self.PanelGoodsVisible or self.PosterPanelVisible

	local Children = self.TabList[Index].Children

	local Category = StoreMgr:GetProductCategory(Index)
	if Category == nil then
		FLOG_ERROR("StoreMainVM:ChangeTab   Category is nil")
		return
	end

	if Category.SubCategory and next(Category.SubCategory) then
		if Children ~= nil and next(Children) then
			self.FilterDataList = Category.SubCategory
		end
	end
    self.FilterSelecteIndex = 1
	self.TabSelecteIndex = Index
	self.CurrentSelectedTabType = Category.Type
	--- 切换标签页先隐藏各界面功能按钮Panel并初始化按钮state
	--- 预览套装时隐藏武器
	self.ClothingPagePanelVisible = Category.Type == StoreMall.STORE_MALL_CLOTHING
	self.WeaponPagePanelVisible = false		--- 3.0没有武器界面
	self.MountPagePanelVisible = Category.Type == StoreMall.STORE_MALL_MOUNT
	self.SheetMusicPagePanelVisible = Category.Type == StoreMall.STORE_MALL_MOUNT
	self.EquipParVisible = Category.Type == StoreMall.STORE_MALL_CLOTHING
	self.TabSelecteType = Category.Type
	self.GoodList = UIBindableList.New(IsHairMysterybox and StoreMysterBoxGoodsItemVM or StoreGoodVM)

	-- 二级页签处理
	if nil ~= SubIndex then
		self.FilterSelecteIndex = math.floor(SubIndex % 10)
	end
	self:UpdateProductList()
end

---@type 获取当前商店信息
function StoreMainVM:GetCurrCategoryData()
    return StoreMgr:GetProductCategory(self.TabSelecteIndex)
end

---@type 设置筛选列表数据
---@param Index number @二级标签索引
---@param Flag boolean @是否二次筛选
function StoreMainVM:SetFilterDataList(Index, Flag)
    self.GoodFilterDataList = {}
    if Index == StoreDefine.DefaultFilterIndex then
        self.GoodFilterDataList = self.GoodDataList
    else
        for _, Product in ipairs(self.GoodDataList) do
            if nil ~= self.FilterDataList and Product.Cfg.LabelSub == self.FilterDataList[Index] then
				table.insert(self.GoodFilterDataList, Product)
            end
        end
    end
	table.sort(self.GoodFilterDataList, function(a, b)
		local IsCanA, CanNotReasonA = StoreMgr:IsCanBuy(a.Cfg.ID)
		local IsCanB, CanNotReasonB = StoreMgr:IsCanBuy(b.Cfg.ID)
		if _G.StoreMainVM.CurrentStoreMode == StoreDefine.StoreMode.Gift then
			return a.Cfg.DisplayID > b.Cfg.DisplayID
		else
			if IsCanA ~= IsCanB then
				return StoreMgr:IsCanBuy(a.Cfg.ID)
			else
				if CanNotReasonA ~= CanNotReasonB then
					return CanNotReasonA ~= LSTR(StoreDefine.SecondScreenType.SoldOut)
				else
					if self.CurrentSelectedTabType == StoreMall.STORE_MALL_WEAPON then
						local IsWearableA = self:CheckIsWearable(a.Cfg.ID)
						local IsWearableB = self:CheckIsWearable(b.Cfg.ID)
						if IsWearableA == IsWearableB then
							return a.Cfg.DisplayID > b.Cfg.DisplayID
						else
							return IsWearableA
						end
					elseif self.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
						local bOwnedA = StoreMgr:CheckGoodsIsOwned(a.Cfg)
						local bOwnedB = StoreMgr:CheckGoodsIsOwned(b.Cfg)
						local a_special = bOwnedA and a.Cfg.Bottom
						local b_special = bOwnedB and b.Cfg.Bottom

						-- 如果两个物品都是沉底的或都不是沉底的，则按ID排序
						if a_special == b_special then
							return a.Cfg.DisplayID > b.Cfg.DisplayID
						else
							-- 如果一个物品是沉底的而另一个不是，则非沉底的排在前面
							return not a_special
						end
					else
						return a.Cfg.DisplayID > b.Cfg.DisplayID
					end
				end
			end
		end
	end)

    if Flag then
        local FilterList = {}
        for _, Product in ipairs(self.GoodFilterDataList) do
            if not StoreMgr:CheckGoodsIsOwned(Product.Cfg) then
                table.insert(FilterList,Product)
            end
        end

        self.GoodFilterDataList = FilterList
    end
end

--- 检查当前ID是否可穿戴（同职业）
function StoreMainVM:CheckIsWearable(GoodID)
	local GoodsData = StoreMgr:GetProductDataByID(GoodID)
	local ResID = nil
	if nil ~= GoodsData and not table.is_nil_empty(GoodsData.Cfg.Items) then
		ResID = GoodsData.Cfg.Items[1].ID
	end
	if ResID == nil then
		FLOG_ERROR("CheckIsWearable Good.Items[1] is nil  GoodID is " .. GoodID)
	end
	local MajorProfID = MajorUtil.GetMajorProfID()
	local TempItemCfg = ItemCfg:FindCfgByKey(ResID)
	if TempItemCfg == nil then
		return false
	end
	local LimitProf = TempItemCfg.ProfLimit
	for _, value in ipairs(LimitProf) do
		if value == MajorProfID then
		end
			return true
	end

	return false
end

---@type 切换筛选的二级标签
---@param Index number @二级标签索引
function StoreMainVM:ChangeFilter()
    self:SetFilterDataList(self.FilterSelecteIndex, self.bSecondScreen)
    if StoreMgr:CheckMallTypeByIndex(self.TabSelecteIndex, ProtoRes.StoreMall.STORE_MALL_PROPS) then
        self:UpdatePropsList(self.GoodFilterDataList)
    else
        self:UpdateGoodList(self.GoodFilterDataList)
    end
end

---@type 设置二次筛选参数
---@param Flag boolean @是否二次筛选
function StoreMainVM:SetSecondScreen(Flag)
    self.bSecondScreen = Flag
    self:SetFilterDataList(self.FilterSelecteIndex, self.bSecondScreen)

    if StoreMgr:CheckMallTypeByIndex(self.TabSelecteIndex, ProtoRes.StoreMall.STORE_MALL_PROPS) then
        self:UpdatePropsList(self.GoodFilterDataList)
    else
        self:UpdateGoodList(self.GoodFilterDataList)
    end
end

---@type 刷新商品列表
---@param DataList table @商品数据列表
function StoreMainVM:UpdateGoodList(DataList)
    local RefreshData = {}
    for Index, Good in ipairs(DataList) do
        RefreshData[#RefreshData + 1] = {
            GoodData = Good,
            ItemIndex = Index,
        }
    end

    self.GoodList:UpdateByValues(RefreshData, nil)
    self.GoodSelecteIndex = 0
	_G.EventMgr:SendEvent(_G.EventID.StoreRefreshGoodsSelected)
	-- self:UpdateStyleList()
end

---@type 变更商品选中状态
---@param Index number @商品索引
function StoreMainVM:ChangeGood(Index)
	if nil == self.GoodFilterDataList then
		return
	end

    -- 提审使用的逻辑
    local GoodData = self.GoodFilterDataList[Index]
    if GoodData == nil then
        FLOG_WARNING("ChangeGood GoodData is nil")
        return
    end

	local Cfg = GoodData.Cfg
    self.GoodSelecteIndex = Index
	self.ImgTag1Path = Cfg.TagPath1
	self.ImgTag2Path = Cfg.TagPath2
	self.ImgTag1Visible = not string.isnilorempty(self.ImgTag1Path)
	self.ImgTag2Visible = not string.isnilorempty(self.ImgTag2Path)
	self.bTagPanelVisible = self.ImgTag1Visible or self.ImgTag2Visible
	self.Tag1InfoID = Cfg.TagInfoID1
	self.Tag2InfoID = Cfg.TagInfoID2
end

function StoreMainVM:UpdateMountActionList(ActionList)
	self.MountActionList:UpdateByValues(ActionList)
end

---@type 刷新包含物品列表
---@param GoodData table @商品数据
function StoreMainVM:UpdateEquipPartList(GoodData, BtnViewVisible)
    local ItemList = GoodData.Items
	
    local ItemData
    local RefreshData = {}
    for _, Item in ipairs(ItemList) do
		if Item.ID ~= 0 then
			ItemData = StoreMgr:GetItemCfg(Item.ID, BtnViewVisible) or StoreMgr:GetHairCfg(Item.ID, BtnViewVisible)
			if ItemData then
				RefreshData[#RefreshData + 1] = ItemData
			end
		end
    end
    self.EquipPartList:UpdateByValues(RefreshData, nil)
end

---@type 变更包含物品列表选中状态
---@param Index number @包含物品索引
function StoreMainVM:ChangeEquipPart(Index, IsSelect)
	if Index == nil then
		for i = 1, self.EquipPartList:Length() do
			self.EquipPartList.Items[i]:OnSelectedChange(IsSelect)
		end
	else
		self.EquipPartList.Items[Index]:OnSelectedChange(IsSelect)
	end
end

---@type 刷新染料列表
---@param DataList table @染料数据列表
function StoreMainVM:UpdatePropsList(DataList)
    local RefresData = {}
    for Index, PropsItem in ipairs(DataList) do
        RefresData[#RefresData + 1] = {
            PropsData = PropsItem,
            ItemIndex = Index,
        }
    end
    self.PropsList:UpdateByValues(RefresData, nil)
	if #RefresData ~= 0 then
		self.MainBackGroundPath = RefresData[1].PropsData.Background
	end
	_G.EventMgr:SendEvent(_G.EventID.StoreRefreshGoodsSelected)
end

-- 刷新单个商品数据
function StoreMainVM:UpdateSingleGoods(GoodsID)
	local GoodsCfgData = StoreCfg:FindCfgByKey(GoodsID)

	-- 刷新列表中商品数据
	if _G.StoreMgr:GetIsPropsByID(GoodsID) then
		local PropsVM = self.PropsList:Find(function(VM) return VM.GoodsId == GoodsID end)
		if nil ~= PropsVM then
			PropsVM:UpdateVM({ItemIndex = PropsVM.ItemIndex, PropsData = {Cfg = GoodsCfgData}})
		end
	else
		local GoodsVM = self.GoodList:Find(function(VM) return VM.GoodID == GoodsID end)
		if nil ~= GoodsVM then
			GoodsVM:UpdateVM({ItemIndex = GoodsVM.ItemIndex, GoodData = {Cfg = GoodsCfgData}})
		end
	end

	-- 更新商品为选中商品，需要更新商品详情
	if self:GetCurrentGoodsID() == GoodsID then
		_G.EventMgr:SendEvent(_G.EventID.StoreRefreshGoodsSelected)
	end
end

---@type 点击道具
function StoreMainVM:OnClickProps(Index)
    self.PropsSelecteIndex = Index
	self.CurrentSelectedItem = self.PropsList:Get(self.PropsSelecteIndex)
	self.CurrentselectedID = self.CurrentSelectedItem.PropID
	self.PropsPanelVisible = true
end

function StoreMainVM:UpdateGoodIcon()
	if self.CurrentSelectedItem and next(self.CurrentSelectedItem) then
		self.BuyGoodIcon = self.CurrentSelectedItem.GoodIcon
	end
end
---@type 初始化多件购买界面
function StoreMainVM:InitMultiBuyView(TempItemData)
    local PropsData
	if TempItemData == nil then
		PropsData = self.GoodFilterDataList[self.PropsSelecteIndex]
	else
		PropsData = TempItemData
	end
	if PropsData == nil then
		return
	end
    local PropsCfgData = PropsData.Cfg
	self.SkipTempData = PropsCfgData
    if PropsCfgData == nil and TempItemData == nil then
        FLOG_WARNING("StoreMainVM:InitMultiBuyView, GoodData is nil, TempItemData is nil")
        return
    end
    if PropsData == nil then
        UIViewMgr:HideView(UIViewID.StoreBuyPropsWin)
        return
    end
	self.CurrentselectedID = PropsCfgData.ID
    local PriceData = PropsCfgData.Price[StoreDefine.PriceDefaultIndex]
	if PriceData == nil or PriceData.Count == nil then
		return
	end
    local ScoreValue = ScoreMgr:GetScoreValueByID(PriceData.ID)

	local ItemCfgData = ItemCfg:FindCfgByKey(PropsCfgData.Items[1].ID)
    self.MultiBuyBg = PropsCfgData.PropQualityIconPath
    self.MultiBuyDesc = PropsCfgData.Desc
    self.MultiBuyIcon = StoreMgr.GetGoodIconPath(ItemCfgData and ItemCfgData.IconID or "")
    self.MultiBuyName = PropsCfgData.Name
    self.ProductName = PropsCfgData.Name
	if nil ~= ItemCfgData then
		self.bMultiBuyPanelHQVisible = ItemCfgData.IsHQ == 1
	else
		self.bMultiBuyPanelHQVisible = false
	end
    self.MultiBuySubName = PropsCfgData.LabelSub
    self.MultiBuyLimitNum = 0
	self.bMultiBuyBuyForOther = PropsCfgData.BuyForOther == 1
	self.MultiDisPanelVisible = false
	local Discount = PropsCfgData.Discount
	local IsOnTime = StoreMgr:IsDuringSaleTime(PropsCfgData)
	if IsOnTime and Discount ~= StoreDefine.DiscountMinValue and Discount ~= StoreDefine.DiscountMaxValue then
		if Discount > StoreDefine.DiscountMinValue and Discount < StoreDefine.DiscountMaxValue then
			self.MultiDisPanelVisible = PropsCfgData.ShowDiscount == 1
			self.MultiDisText = string.format(_G.LSTR(950042), Discount / 10)	--- "%d折"
			self.DiscountText = self.MultiDisText
			self.bMultiBuyPanelOriginalVisible = true
			self.OriginalPanelVisible = true
			self.OriginalPriceText = ScoreMgr.FormatScore(PropsCfgData.Price[1].Count)	--- 选择好友界面
			self.DiscountPanelVisible = true
			self.MultiBuyPrice = string.format("%d", math.floor(PropsCfgData.Price[1].Count * (Discount / StoreDefine.DiscountMaxValue)))
		end
	else
		self.MultiBuyPrice = PropsCfgData.Price[1].Count or 0
		self.bMultiBuyPanelOriginalVisible = false
		self.OriginalPanelVisible = false
		self.DiscountPanelVisible = false
	end
	--这里第一次检查价格
	self.MultiBuyPriceText = ScoreMgr.FormatScore(tonumber(self.MultiBuyPrice))
	--- 赠礼界面 限时
	if Discount ~= 0 and IsOnTime and PropsCfgData.ShowDiscount then
		self.DeadlinePanelVisible = StoreMgr:GetTimeInfo(PropsCfgData.DiscountDurationStart) ~= 0
		local DiscountEnd = StoreMgr:GetTimeInfo(PropsCfgData.DiscountDurationEnd)
		local IsShowTimeSaleIcon, ShowTime = StoreMgr:GetTimeLimit(DiscountEnd)
		if ShowTime ~= nil then
			self.IsShowTimeSaleIcon = IsShowTimeSaleIcon
			self.TimeSaleText = ShowTime
		end
    end

	self.BuyGoodPrice = self.MultiBuyPrice
	self.BuyGoodPriceText = ScoreMgr.FormatScore(tonumber(self.MultiBuyPrice))
	local TempScoreCfg = ScoreCfg:FindCfgByKey(PropsCfgData.Price[1].ID)
	if TempScoreCfg ~= nil then
		self.MultiBuyPriceType = TempScoreCfg.IconName
	end
	local RemainGoodsQuantity = StoreMgr:GetRemainQuantity(PropsCfgData.ID)
    self:SetPurchaseLimit(StoreMgr:GetCounterType(PropsCfgData.ID), RemainGoodsQuantity)
    local IsOverPurchaseLimit = RemainGoodsQuantity == 0
    if PriceData == nil or PriceData.Count == nil then
       return
    end
    self.bMultiBuyOriginalPriceText = tostring(PriceData.Count)

	local ItemPrice = 0
	if IsOnTime and PropsCfgData.Discount ~= StoreDefine.DiscountMinValue and PropsCfgData.Discount ~= StoreDefine.DiscountMaxValue then
		ItemPrice = PriceData.Count * PropsCfgData.Discount / StoreDefine.DiscountMaxValue
	else
		ItemPrice = PriceData.Count
	end
	self.IsOverPurchaseLimit = IsOverPurchaseLimit

	local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
	if ScoreValue < ItemPrice then
		MainPriceVM.BuyPriceTextColor = "AF4C58FF"
	else
		MainPriceVM.BuyPriceTextColor = "D5D5D5FF"
	end

	--价格不用管，只用管是否超过限购或者售罄
    if IsOverPurchaseLimit then
        self.bMultiBuySliderEnabled = false
		self.MultiBuyConfirmBtnImgType = CommBtnColorType.Disable
        self.MultiBuyPurchaseNumber = 1
		self.MultiBuyConfirmTextColor = "f3f3f399"
        return
	else
		self.MultiBuyConfirmBtnImgType = CommBtnColorType.Recommend
    end
	self.MultiBuyConfirmTextColor = "FFF9E1FF"
    self.bMultiBuySliderEnabled = true

    self.MultiBuyLimitNum = RemainGoodsQuantity < 0 and PropsCfgData.OnceLimitation or
		math.min(PropsCfgData.OnceLimitation, RemainGoodsQuantity)

	local IsCan, CanNotReason = _G.StoreMgr:IsCanBuy(PropsCfgData.ID)
	if not IsCan then
		--这里判断一下是否限购
		self.bMultiBuySliderEnabled = false
		self.MultiBuyConfirmBtnImgType = CommBtnColorType.Disable
		self.MultiBuyConfirmTextColor = "f3f3f399"
	end
    self:SetMultiQuantity(1)
end

---@type 获取多件购买商品ID
---@return number 商品ID
function StoreMainVM:GetMultiBuyItemID()
    local Result = nil
	local PropsCfgData
	if table.is_nil_empty(self.GoodFilterDataList) or self.GoodSelecteIndex == 0 then
		PropsCfgData = self.SkipTempData
	else
		PropsCfgData = self.GoodFilterDataList[self.GoodSelecteIndex].Cfg
	end
    if PropsCfgData then
        Result = PropsCfgData.Items[1].ID
    end

    return Result
end

---@type 设置多件购买界面物品信息
---@param RestrictionType number 限购类型
---@param Value number 当前可购买的数量
function StoreMainVM:SetPurchaseLimit(RestrictionType, Value)
    Value = Value or 0
    RestrictionType = RestrictionType or 0
    local PurchasedText = LSTR(StoreDefine.QuantityText[RestrictionType])
    self.MultiBuyQuantity = PurchasedText == nil and "" or string.format(PurchasedText, Value)
end

---@type 设置多件购买界面物品价格
function StoreMainVM:SetMultiComponentState(LimitNum, CurrentNum)
	local PropsData = self.GoodFilterDataList[self.PropsSelecteIndex]
    -- local Limit = self.MultiBuyLimitNum

    -- if Limit == 0 then
    --     FLOG_WARNING("StoreMainVM:SetMultiComponentState, Limit is 0")
    --     return
    -- end

    local PriceData = PropsData.Cfg.Price[StoreDefine.PriceDefaultIndex]
	local ScoreValue = ScoreMgr:GetScoreValueByID(PriceData.ID)
	local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
	if tonumber(self.MultiBuyPrice) > ScoreValue then
		MainPriceVM.BuyPriceTextColor = "AF4C58FF"
	else
		MainPriceVM.BuyPriceTextColor = "D5D5D5FF"
	end
	self.MultiBuyPriceText = ScoreMgr.FormatScore(tonumber(self.MultiBuyPrice))
end

function StoreMainVM:CheckNumAdd()
    local PropsData = self.GoodFilterDataList[self.PropsSelecteIndex]
	if PropsData == nil then
		return false
	end
	local CurrentNum = self.MultiBuyPurchaseNumber
	--- 当前数量小于批量购买上限
	return CurrentNum < PropsData.Cfg.OnceLimitation
end

function StoreMainVM:CheckNumSub()
	return self.MultiBuyPurchaseNumber > 1
end

function StoreMainVM:ChangeNumToLimit()
	local PropsData = self.GoodFilterDataList[self.PropsSelecteIndex]
	if PropsData == nil then
		return
	end
	local RestrictionCount = PropsData.Cfg.OnceLimitation
	self:SetMultiQuantity(RestrictionCount)
end

---@type 按钮改变购买数量
---@param Value number 变更数量
---@param Slider CommSliderHorizontalView 拖动条控件
function StoreMainVM:ChangeQuantity(Value)
    if self.MultiBuyLimitNum == 0 then
        return
    end

    self:SetMultiQuantity(self.QuantityPurchased + Value)
end

---@type 拖动条改变购买数量
---@param Value number 当前购买数量
function StoreMainVM:ChangeQuantityBySlider(Value)
    local PropsData = self.GoodFilterDataList[self.PropsSelecteIndex]
	if nil == PropsData or nil == PropsData.Cfg then
		return
	end
    local Limit = StoreMgr:GetRemainQuantity(PropsData.Cfg.ID)

    -- if Limit == 0 then
    --     FLOG_WARNING("StoreMainVM:ChangeQuantityBySlider, Limit is 0")
    --     return
    -- end

    Value = Value <= 1 and 1 or Value
    local PriceData = PropsData.Cfg.Price[StoreDefine.PriceDefaultIndex]
	local IsOnTime = StoreMgr:IsDuringSaleTime(PropsData.Cfg)

	if PriceData and PriceData.Count and PropsData.Cfg.Discount < StoreDefine.DiscountMaxValue and PropsData.Cfg.Discount > StoreDefine.DiscountMinValue and IsOnTime then
		self.MultiBuyPrice = string.format("%d", PriceData.Count * PropsData.Cfg.Discount / StoreDefine.DiscountMaxValue * Value)
		self.bMultiBuyOriginalPriceText = tostring(PriceData.Count * Value)
		self.OriginalPriceText = ScoreMgr.FormatScore(PriceData.Count * Value)
	else
		self.MultiBuyPrice = string.format("%d", PriceData.Count * Value)
    end
    self.QuantityPurchased = math.floor(Value)
	self.MultiBuyPurchaseNumber = Value
    self:SetMultiComponentState(Limit, Value)
	-- 购买价格更新
	local BuyPriceVM = _G.StoreMgr:GetBuyPriceVM()
	if nil ~= BuyPriceVM then
		BuyPriceVM:UpdatePriceData(PropsData.Cfg, false, false, Value)
	end
end

---@type 设置多件购买数量
---@param Value number 当前购买数量
---@param Slider CommSliderHorizontalView 拖动条控件
function StoreMainVM:SetMultiQuantity(Value)
    if type(Value) ~= "number" then
        FLOG_WARNING("StoreMainVM:SetMultiQuantity, Value is not number")
        return
    end

	local PropsCfgData
	if table.is_nil_empty(self.GoodFilterDataList) or self.GoodSelecteIndex == 0 then
		PropsCfgData = self.SkipTempData
	else
		PropsCfgData = self:GetCurrentGoodsCfgData()
	end
	if table.is_nil_empty(PropsCfgData) then
		FLOG_INFO("StoreMainVM:SetMultiQuantity PropsData is nil")
		return
	end
	local Limit = PropsCfgData.OnceLimitation

    if Value > Limit and Limit ~= 0 then
        Value = Limit
    end

    if Value <= 1 then
        Value = 1
    end

    self.QuantityPurchased = Value
    self.MultiBuyPurchaseNumber = Value
	
    local PriceData = PropsCfgData.Price[StoreDefine.PriceDefaultIndex]
	local IsOnTime = StoreMgr:IsDuringSaleTime(PropsCfgData)
	
    if PriceData and PriceData.Count and PropsCfgData.Discount < StoreDefine.DiscountMaxValue and PropsCfgData.Discount > StoreDefine.DiscountMinValue and IsOnTime then
		self.MultiBuyPrice = string.format("%d", PriceData.Count * PropsCfgData.Discount / StoreDefine.DiscountMaxValue * Value)
		self.bMultiBuyOriginalPriceText = tostring(PriceData.Count * Value)
		self.OriginalPriceText = ScoreMgr.FormatScore(PriceData.Count * Value)
	else
		self.MultiBuyPrice = string.format("%d", PriceData.Count * Value)
    end
	self.BuyGoodPrice = ScoreMgr.FormatScore(tonumber(self.MultiBuyPrice))

	-- 购买价格更新
	local BuyPriceVM = _G.StoreMgr:GetBuyPriceVM()
	if nil ~= BuyPriceVM then
		BuyPriceVM:UpdatePriceData(PropsCfgData, false, false, Value)
	end
	-- 赠礼价格更新
	local GiftPriceVM = _G.StoreMgr:GetGiftPriceVM()
	if nil ~= GiftPriceVM then
		GiftPriceVM:UpdatePriceData(PropsCfgData, false, false, Value)
	end
end

---@type 购买道具
function StoreMainVM:BuyProps(GoodsID)
    _G.LootMgr:SetDealyState(true)
    local PropsCfgData
	if nil ~= GoodsID then
		PropsCfgData = StoreCfg:FindCfgByKey(GoodsID)
	elseif table.is_nil_empty(self.GoodFilterDataList) or self.PropsSelecteIndex == 0 then
		PropsCfgData = self.SkipTempData
	else
		PropsCfgData = self.GoodFilterDataList[self.PropsSelecteIndex].Cfg
	end
	if nil == PropsCfgData then
		FLOG_ERROR("[StoreMainVM:BuyProps] PropsCfgData is nil")
		return
	end
    StoreMgr:SendMsgBuyGood(PropsCfgData.ID, self.QuantityPurchased)
end

---@type 是否持有足够的货币多件
function StoreMainVM:bAvailableBuyByMultiBuy(ItemData)
    if self.QuantityPurchased == 0 then
        MsgTipsUtil.ShowTipsByID(StoreDefine.InSelectedPurchased)
        return false
    end

    local PropsData
	if table.is_nil_empty(ItemData) then
		PropsData = ItemData
	elseif table.is_nil_empty(self.GoodFilterDataList) then
		PropsData = StoreMgr.ProductDataList[self.CurrentselectedID]
	else
		PropsData = self.GoodFilterDataList[self.PropsSelecteIndex]
	end

    if PropsData == nil then
        FLOG_WARNING("StoreMainVM:BuyProps, PropsData is nil")
        MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
        return false
    end
	
	local PropsCfgData = PropsData.Cfg

	local IsOnTime = StoreMgr:IsDuringSaleTime(PropsCfgData)

    local PriceData = PropsCfgData.Price[StoreDefine.PriceDefaultIndex]
    if PriceData and PriceData.Count then
		local ItemName = ItemCfg:GetItemName(PriceData.ID) or ""
		local ItemPrice = 0
		if IsOnTime and PropsCfgData.Discount ~= StoreDefine.DiscountMinValue and PropsCfgData.Discount ~= StoreDefine.DiscountMaxValue then
			ItemPrice = PriceData.Count * PropsCfgData.Discount / StoreDefine.DiscountMaxValue
		else
			ItemPrice = PriceData.Count
		end
        local ScoreValue = ScoreMgr:GetScoreValueByID(PriceData.ID)
		local BuyNum = tonumber(self.MultiBuyPurchaseNumber)
        if ScoreValue < ItemPrice * BuyNum then
			_G.MsgBoxUtil.ShowMsgBoxTwoOp(
				nil,
				LSTR(950032),	--- "代币不足"
				string.format(LSTR(950034), ItemName),	--- "%s不足，是否前往充值？"
				function()
					if _G.LoginMgr:CheckModuleSwitchOn(ProtoRes.module_type.MODULE_REBATE, true) then
						-- 打开充值界面
						_G.RechargingMgr:ShowMainPanel()
						_G.RechargingMgr:OnChangedMainPanelCloseBtnToBack(true)
					end
				end,
				nil,
				LSTR(950030),	--- "取消"
				LSTR(950033)	--- "确认"
			)
            return false
        end
    else
        FLOG_WARNING("StoreMainVM:BuyProps, Not find price")
        MsgTipsUtil.ShowTipsByID(StoreDefine.BuyError)
        return false
    end

    return true
end

---@type 获取当前选中的商品索引
function StoreMainVM:GetGoodSelectIndex()
    return self.GoodSelecteIndex or 0
end

---@type 初始化单件购买面板
function StoreMainVM:InitBuyView(TempItemData)
    local GoodData, GoodCfgData
	if TempItemData == nil then
		if nil ~= self.GoodFilterDataList then
			GoodData = self.GoodFilterDataList[self.GoodSelecteIndex]
		end
	else
		GoodData = TempItemData
	end
    if GoodData == nil and TempItemData == nil then
        FLOG_WARNING("StoreMainVM:InitBuyView, GoodData is nil, TempCfg is nil")
        return
    end
	GoodCfgData = GoodData.Cfg
	if self.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		self:UpdateMysteryBoxData(GoodCfgData.Items, GoodCfgData.PrizePoolID)
		local Items = {}
		for i = 1, #GoodCfgData.Items do
			local ID = GoodCfgData.Items[i].ID
			local IsOwned = _G.BagMgr:GetItemNum(ID) > 0 or _G.DepotVM:GetDepotItemNum(ID) > 0 or _G.MailMgr:GetGiftMailIDByGoodID(ID) ~= nil
			local TempItemCfg = ItemCfg:FindCfgByKey(ID)
			if nil ~= TempItemCfg and TempItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE then
				-- 如果在背包仓库邮件没找到，或许是已经解锁了
				if not IsOwned then
					IsOwned = _G.HaircutMgr.CheckHairUnlock(ID)
				end
			end
			if not IsOwned then
				table.insert(Items, GoodCfgData.Items[i])
			end
		end
		self:InitContainsItemList(Items)
	else
		self:InitContainsItemList(GoodCfgData.Items)
	end
	self.SkipTempData = GoodCfgData
	self.CurrentselectedID = GoodCfgData.ID
	if self.CurrentStoreMode == StoreDefine.StoreMode.Buy then
		if self.PanelGoodsVisible and StoreMgr:GetRemainQuantity(self.CurrentselectedID) ~= 0 then
			self.PanelBuyVisible = true
			self.PanelPriceVisible = true
		end
	else
		if self.PanelGoodsVisible then
			self.PanelBuyVisible = true
			self.PanelPriceVisible = true
		end
	end
	if StoreMgr:GetIsShowEquipList(GoodCfgData) then
		local IsBox = self.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX
		self:UpdateEquipPartList(GoodCfgData, not IsBox)
	end
	self.PropsPanelVisible = false
	self.ProductName = GoodCfgData.Name
	--- 活动跳转类型商品，不计算价格等信息
	if GoodCfgData.ProductType ~= nil and GoodCfgData.ProductType == ProtoRes.StoreRecommendType.STORE_RECOMMEND_TYPE_JUMP then
		self.BuyBtnText = GoodCfgData.BtnText
		self.JumpID = GoodCfgData.JumpID
		self.DyeTipsText = ""
	elseif self.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		self.BuyBtnText = LSTR(StoreDefine.StoreModeText[1])
		self.JumpID = 0
		local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
		if nil ~= MainPriceVM then
			MainPriceVM:UpdatePriceData(GoodCfgData, false, false)
		end
		self:UpdateCouponsSelectedState()
		self.DyeTipsText = ""
	else
		self.JumpID = 0
		self.BuyBtnText = LSTR(StoreDefine.StoreModeText[self.CurrentStoreMode])
		local TempDyeTipsType = GoodCfgData.DyeTipsType
		self.DyeTipsText = LSTR(StoreDefine.DyeTipsText[TempDyeTipsType])
		if TempDyeTipsType == ProtoRes.GoodsDyeType.GOODS_DYE_TYPE_Part then
			self.DyeCommonInforBtnVisible = true
			self.DyeCommonInforID = GoodCfgData.DyeInfoID
		else
			self.DyeCommonInforBtnVisible = false
		end
		--- 性别限制提示
		local GenderLimit = GoodCfgData.GenderLimit
		local MajorGender = MajorUtil.GetMajorGender()
		if GenderLimit == 0 or GenderLimit == nil or MajorGender == GenderLimit then
			self.UnavailableText = ""
		else
			self.UnavailableText = LSTR(StoreDefine.LSTRTextKey.CurGenderDisable)
		end

		local MainPriceVM = _G.StoreMgr:GetMainPriceVM()
		local PriceGoodsCfgData = GoodCfgData
		if GoodCfgData.LabelMain == ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_RECOMMEND then
			-- 推荐页商品实际价格以配置的第一商品为准
			PriceGoodsCfgData = StoreCfg:FindCfgByKey(GoodCfgData.Items[1].ID) or PriceGoodsCfgData -- 待拆推荐表
		end
		if nil ~= MainPriceVM then
			MainPriceVM:UpdatePriceData(PriceGoodsCfgData, self.CurrentStoreMode == StoreDefine.StoreMode.Buy, true)
		end
		local GiftPriceVM = _G.StoreMgr:GetGiftPriceVM()
		if nil ~= GiftPriceVM then
			GiftPriceVM:UpdatePriceData(PriceGoodsCfgData, false)
		end
	end

	-- 染色信息面板
	self.bDyeInforPanelVisible = self.DyeCommonInforBtnVisible or self.DyeTipsText ~= ""
end

--- 更新奇遇盲盒Tips列表
---@param Items table 包含物品
---@param PrizePoolID number 奖池ID  用来计算权重 概率
function StoreMainVM:UpdateMysteryBoxData(Items, PrizePoolID)
	if PrizePoolID == nil then
		return
	end
	local ItemsData = {}
	--- 权重List
	local DropWeightList = {}
	--- 拥有状态List
	local bIsOwnedList = {}
	--- 未拥有权重总和
	local AllDropWeight = 0
	local TempRandCfgList = CommercializationRandCfg:FindAllCfg(string.format("PrizePoolID=%d", PrizePoolID))
	for _, value in ipairs(TempRandCfgList) do
		if value.ProbMode == ProtoRes.PROBABILITY_TYPE.PROBABILITY_TYPE_WEIGHTED then
			DropWeightList[value.DropID] = value.DropWeight
			local MailID =  _G.MailMgr:GetGiftMailIDByGoodID(value.DropID)
			local bIsOwned = _G.HaircutMgr.CheckHairUnlock(value.DropID) or _G.BagMgr:GetItemNum(value.DropID) > 0 or _G.DepotVM:GetDepotItemNum(value.DropID) > 0 or MailID ~= nil
			if not bIsOwned then
				AllDropWeight = AllDropWeight + value.DropWeight
			end
			bIsOwnedList[value.DropID] = bIsOwned
		end
	end
	for index, value in ipairs(Items) do
		local ItemID = value.ID
		ItemsData[index] = {
			ID = ItemID,
			DropWeight = DropWeightList[ItemID],
			bIsOwned = bIsOwnedList[ItemID],
			AllDropWeight = AllDropWeight
		}
	end
	table.sort(ItemsData, function(a, b) if a.bIsOwned == b.bIsOwned then return false end return not a.bIsOwned end)

	self.MysteryBosItemVMList:UpdateByValues(ItemsData)
end

--- 旧蓝图代码，已弃用
-- ---@type 设置单件购买面板物品信息
-- ---@param Icon string 物品图标
-- ---@param Background string 物品背景
-- function StoreMainVM:SetBuyIcon(Icon, Background)
--     self.bBuyGoodBgVisible = false
--     self.bBuyGoodIconVisible = false

--     if type(Icon) == "string" and string.len(Icon) > 0 then
--         self.bBuyGoodIconVisible = true
--         self.BuyGoodIcon = Icon
--     end

--     if type(Background) == "string" and string.len(Background) > 0 then
--         self.bBuyGoodBgVisible = true
--         self.BuyGoodBg = Background
--     end
-- end

---@type 初始化单件商品包含的物品列表
---@param DataList table<number, table> 物品数据
function StoreMainVM:InitContainsItemList(DataList)
    if DataList == nil then
        FLOG_WARNING("StoreMainVM:InitContainsItemList, DataList is nil")
        return
    end

    local ItemList = {}
    for _, Item in ipairs(DataList) do
        if Item.ID ~= 0 then
            ItemList[#ItemList + 1] = {
				ResID = Item.ID,
                Num = Item.Num
            }
        end
    end
    self.ContainsItemList:UpdateByValues(ItemList, nil)
end

---@type 购买商品
function StoreMainVM:BuyGood(GoodsCfgData)
    _G.LootMgr:SetDealyState(true)
	local TempData
	if table.is_nil_empty(self.GoodFilterDataList) or self.GoodSelecteIndex == 0 then
		TempData = self.SkipTempData
	else
		TempData = self.GoodFilterDataList[self.GoodSelecteIndex].Cfg
	end
    -- local GoodData = self.GoodFilterDataList[self.GoodSelecteIndex]
	TempData = GoodsCfgData or TempData
	if self.CurrentSelectedTabType == StoreMall.STORE_MALL_MYSTERYBOX then
		StoreMgr:SendMsgBuyMysterBox(TempData.ID)
	else
    	StoreMgr:SendMsgBuyGood(TempData.ID, StoreDefine.MinBuyQuantity, self.UseCouponGID)
	end
end

---@type 初始化获取商品界面
function StoreMainVM:InitGetView()
    local Count = self.RewardData.Count
    local GoodData = StoreMgr:GetGoodCfg(self.RewardData.GoodsID)
    local Items
    local ItemID
    local ResultData = {}
    if GoodData then
        Items = GoodData.Items
        for _, Item in ipairs(Items) do
            ItemID = Item.ID
			ResultData[#ResultData + 1] = {ItemID = ItemID, Num = Count}
            if ItemID ~= 0 then
            end
        end
    end

    self.RewardList:UpdateByValues(ResultData, nil)

    -- local BagCapacity = BagMgr:GetBagLeftNum()
    -- if BagCapacity <= 0 then
    --     MsgTipsUtil.ShowTipsByID(StoreDefine.FullNotifiText)
    -- end
end

--- 切换购买/赠礼
---@param Index StoreDefine.StoreMode
function StoreMainVM:OnSwitchMode(Index)
	if Index == StoreDefine.StoreMode.Gift then
		if self.GoodDataList ~= nil then
			self.TabSelecteIndex = StoreMgr:GetGiftModeTabIndex(self.TabSelecteIndex)
			local GoodData = self.GoodDataList[self.GoodSelecteIndex]
			if GoodData == nil then
				FLOG_ERROR("StoreMainVM:OnSwitchMode   GoodData is nil")
				return
			end
		end
	else
		self.TabSelecteIndex = StoreMgr:GetBuyModeTabIndex(self.TabSelecteIndex)
	end
	self:UpdateTabList()
	-- self:ChangeTab(self.TabSelecteIndex) -- View会调用ChangeTab，无需在此处重复执行
end

--- 外部用 打开赠礼邮件页面
---@param IsExternal boolean 是否外部调用
---@param Params any 参数
function StoreMainVM:OnShowGiftMailPanel(IsExternal, Params)
	if IsExternal then
		StoreGiftMailVM:UpdateVM(Params)
	else
		self.ToName = Params.ToName
		self.TargetRoleID = Params.TargetRoleID
		self.FromName = MajorUtil.GetMajorName()
		if StoreMgr:GetResidueGiftNumber() > 0 then
			if StoreMgr:CheckDonorLevel() then
				if self:CheckDoneeLevel(Params.TargetRoleID) then
					if self:CheckFriendDuration(Params.TargetRoleID) then
						--- 打开赠言界面
						self.GiftChooseImgBlackLucency = "00000059"
						UIViewMgr:ShowView(UIViewID.StoreGiftMailWin, {GoodsID = Params.GoodID, bIsExternal = IsExternal})
					else
						local DurationTime = StoreMgr.FriendDuration
						_G.MsgBoxUtil.ShowMsgBoxOneOpRight(
							self,
							LSTR(950043),	--- "赠送失败"
							string.format(LSTR(950044), DurationTime)	--- 成为好友的时间不足%s无法赠送
						)
					end
				else
					local DoneeLevelLimit = StoreMgr.DoneeLevelLimit
					_G.MsgBoxUtil.ShowMsgBoxOneOpRight(
						self,
						LSTR(950043),	--- "赠送失败"
						string.format(LSTR(950045), DoneeLevelLimit)	--- 你的好友没有%d级以上的战斗职业，无法赠送
					)
				end
			else
				local DonorLevelLimit = StoreMgr.DonorLevelLimit
				_G.MsgBoxUtil.ShowMsgBoxOneOpRight(
					self,
					LSTR(950043),	--- "赠送失败"
					string.format(LSTR(950078), DonorLevelLimit)	--- 你没有%d级以上的战斗职业,无法赠送
				)
			end
		else
			_G.MsgBoxUtil.ShowMsgBoxOneOpRight(
				self,
				LSTR(950043),	--- "赠送失败"
				LSTR(950046)	--- "今日赠送次数已用完，请明日再试"
			)
		end
	end
end

--- 检查受赠方最高战斗职业等级
function StoreMainVM:CheckDoneeLevel(RoleID)
	local RoleVM = self.FriendList[RoleID]
	if RoleVM == nil or RoleVM.ProfSimpleDataList == nil then
		return false
	end
	local ProfList = RoleVM.ProfSimpleDataList
	for _, value in pairs(ProfList) do
		local ProfCfg = RoleInitCfg:FindCfgByKey(value.ProfID)
		if ProfCfg.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT and value.Level >= StoreMgr.DoneeLevelLimit  then
			return true
		end
	end
	return false
end

--- 检查好友持续时间
function StoreMainVM:CheckFriendDuration(RoleID)
	local TempFriendGroupList = FriendVM.GroupVMList
	if TempFriendGroupList == nil then
		FLOG_ERROR("StoreMainVM:CheckFriendDuration TempFriendGroupList is nil")
		return
	end
	for i = 1, #TempFriendGroupList.Items do
		local FriendGroupItem = TempFriendGroupList.Items[i]
		if FriendGroupItem ~= nil then
			local Items = FriendGroupItem.MemberVMList.Items
			for k = 1, #Items do
				if RoleID == Items[k].RoleID then
					local ServerTime = TimeUtil.GetServerLogicTime()
					local beFriendsTime = math.ceil((ServerTime - Items[k].Time) / 3600 / 24)
					if beFriendsTime >= StoreMgr.FriendDuration then
						return true
					end
				end
			end
		end
	end
	return false
end

--- 检查当前选中风格Index是否解锁
function StoreMainVM:CheckStyleIsUnlocked(Index)
	local UnLockedList = StoreMgr:GetUnlockedDecorativeStyleList()
	if UnLockedList == nil then
		return false
	end
	for i = 1, #self.StyleList.Items do
		self.StyleList.Items[i]:SetIsSelected(false)
	end
	self.StyleList.Items[Index]:SetIsSelected(true)
	for i = 1, #UnLockedList do
		if UnLockedList[i] == Index then
			self.SelectedStyleIndex = Index
			return true
		end
	end
	return false
end

-- 旧接口，获取时道具类商品时存在问题
function StoreMainVM:GetCurrentGoodCfgData()
	if table.is_nil_empty(self.GoodFilterDataList) or self.GoodSelecteIndex == 0 then
		return self.SkipTempData
	elseif nil ~= self.GoodFilterDataList[self.GoodSelecteIndex] then
		return self.GoodFilterDataList[self.GoodSelecteIndex].Cfg
	else
		return nil
	end
end

--region 菜单列表
function StoreMainVM:GetDefaultMenuKey(MenuIndex)
	if nil == self.TabList then
		return 0
	end
	local TabData = self.TabList[MenuIndex]
	if nil ~= TabData and nil ~= TabData.Children and next(TabData.Children) then
		-- 存在子菜单，返回第一个Key
		return TabData.Children[1].Key
	elseif nil ~= TabData then
		-- 不存在子菜单，返回母菜单Key
		return TabData.Key
	end
	return 0
end

function StoreMainVM:GetCurrentMainTabType()
	local CategoryIndex = self.JumpToCategoryIndex or self.TabSelecteIndex
	local Category = StoreMgr:GetProductCategory(CategoryIndex)
	if nil ~= Category then
		return Category.Type
	end
	return 0
end

--endregion

--region 选中商品

function StoreMainVM:GetCurrentGoodsID()
	local GoodsID = nil
	if nil ~= StoreMainVM.CurrentSelectedItem then
		GoodsID = StoreMainVM.CurrentSelectedItem.GoodID or StoreMainVM.CurrentSelectedItem.GoodsId -- 非道具：GoodID 道具：GoodsId
	end
	if nil ~= GoodsID then
		return GoodsID
	elseif nil ~= self.SkipTempData then
		return self.SkipTempData.ID
	end
	return 0
end

function StoreMainVM:GetCurrentGoodsCfgData()
	local GoodsID = self:GetCurrentGoodsID()
	if nil ~= GoodsID then
		return StoreCfg:FindCfgByKey(GoodsID)
	end
	return nil
end

-- 根据主类下标更新对应主类当前选中的商品
function StoreMainVM:CacheSelectedGoodsForCategory(CategoryIndex, GoodsID)
	local StoreCategory = StoreMgr:GetProductCategory(CategoryIndex)
	if nil ~= StoreCategory then
		StoreMainVM.SelectedGoods[StoreCategory.Type] = GoodsID
	end
end

--endregion

return StoreMainVM
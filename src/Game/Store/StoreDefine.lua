
local ProtoRes = require("Protocol/ProtoRes")
local LightDefine = require("Game/Light/LightDefine")

local DyeFilterMaxValue = 9
local DyeFilterTextName = "TextSort%d"
local DyeFilterBtnName = "BtnSort%d"
local DyeFilterSelectName = "ImgSelect%d"

--- 这里只存Key，用到的时候再去LSTR取值

--- 1.全部可染色
--- 2.全部不可染色
--- 3.部分可染色
local DyeTipsText = {
    [1] = 950001,	
    [2] = 950002,	
    [3] = 950003,	
}

local LSTRTextKey = {
	--- 全部
	AllFilterText = 950004,
	--- 取消
	CancleText = 950030,
	--- 商城
	StoreTittleText = 950048,
	--- 赠礼
	GiftTittleText = 950049,
	--- 外观预览
	PreviewTittleText = 950051,
	--- 适度娱乐，理性消费
	TittleHintText = 950052,
	--- 确认购买
	ConfirmPurchaseText = 950053,
	--- 当前性别不可用
	CurGenderDisable = 950055,
	--- 大奖预览
	PrizePreview = 950056,
	--- 可用优惠券
	ValidCouponText = 950060,
	--- 不可用优惠券
	UnValidCouponText = 950061,
	--- 水晶点
	StampsText = 950062,
	--- 满%d可用
	ThresholdForUse_d = 950063,
	--- %s前有效
	s_ValidBefore = 950064,
	--- 永久有效
	PermanentlyValid = 950065,
	--- 选择优惠券
	ChooseCoupons = 950066,
	--- 不使用优惠券
	NotUseCoupon = 950067,

}

local DefaultFilterIndex = 1

local ShowDefaultTabIndex = 1

local ExtendArrowAngle = {
    Close = -90,
    Open = 90,
}

local StoreMode = {
    Buy = 0,
    Gift = 1,
}

--- 1.购买
--- 2.赠送
local StoreModeText = {
	[0] = 950005,
	[1] = 950006

}
local TimeValue = {
    Day = 86400,
    Hour = 3600,
    Minute = 60,
}

local RestrictionTypeText = {}
RestrictionTypeText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = 950007	--- 每日限购: %d/%d
RestrictionTypeText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = 950008	--- 每周限购: %d/%d
RestrictionTypeText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = 950009	--- 每月限购: %d/%d
RestrictionTypeText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_YEAR] = 950010	--- 每年限购: %d/%d
RestrictionTypeText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = 950011--- 永久限购: %d/%d

local QuantityText = {}
QuantityText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = 950012		--- 本日剩余购买数量: %d
QuantityText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = 950013		--- 本周剩余购买数量: %d
QuantityText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = 950014		--- 本月剩余购买数量: %d
QuantityText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_YEAR] = 950015		--- 本年剩余购买数量: %d
QuantityText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = 950016	--- 永久剩余购买数量: %d

local SoldOutText = {}
SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_DAY] = 950017		--- 今日已售罄
SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_WEEK] = 950018		--- 本周已售罄
SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_MONTH] = 950019		--- 本月已售罄
SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_YEAR] = 950020		--- 今年已售罄
SoldOutText[ProtoRes.COUNTER_TYPE.COUNTER_TYPE_FOREVER] = 950022	--- 已拥有

-- local ItemQuality = {
--     "Texture2D'/Game/UI/Texture/Store/UI_Store_Quality_NQ_01.UI_Store_Quality_NQ_01'",
--     "Texture2D'/Game/UI/Texture/Store/UI_Store_Quality_NQ_02.UI_Store_Quality_NQ_02'",
--     "Texture2D'/Game/UI/Texture/Store/UI_Store_Quality_NQ_03.UI_Store_Quality_NQ_03'",
--     "Texture2D'/Game/UI/Texture/Store/UI_Store_Quality_NQ_04.UI_Store_Quality_NQ_04'",
-- }

local ItemQuality = {
    [ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_WHITE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_01.UI_Quality_Slot_NQ_01'",
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_GREEN] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_02.UI_Quality_Slot_NQ_02'",
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_BLUE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_03.UI_Quality_Slot_NQ_03'",
	[ProtoRes.ITEM_COLOR_TYPE.ITEM_COLOR_PURPLE] = "Texture2D'/Game/Assets/Icon/Quality/UI_Quality_Slot_NQ_04.UI_Quality_Slot_NQ_04'",
}

--- day = %d天
--- Hour = %d时
--- Minute = %d分
--- Second = %d秒
local TimeLimitText = {
    Day = 950023,
    Hour = 950024,
    Minute = 950025,
    Second = 950026,
}

--- Owned 已拥有
--- SoldOut 已售罄
local SecondScreenType = {
    Owned = 950022,
    SoldOut = 950021
}

-- TipsID
local BuyTipsText = {
    Owned = 157037,				--- LSTR("已拥有, 无法重复购买")
    SoldOut = 157036			--- LSTR("已售罄")
}

local PriceDefaultIndex = 1
local DiscountMinValue = 0
local DiscountMaxValue = 100
local PurchasedMinValue = 0
local LimitMinValue = 0
local EquipShowMinValue = 2
local ItemEmptyID = 0
local GoodsItemMinValue = 1

local EquipPartSign = {
    "PaperSprite'/Game/UI/Atlas/Store/Frames/UI_Store_Slot_Icon_Hat_png.UI_Store_Slot_Icon_Hat_png'",
    "PaperSprite'/Game/UI/Atlas/Store/Frames/UI_Store_Slot_Icon_Armor_png.UI_Store_Slot_Icon_Armor_png'",
    "PaperSprite'/Game/UI/Atlas/Store/Frames/UI_Store_Slot_Icon_Trousers_png.UI_Store_Slot_Icon_Trousers_png'",
    "PaperSprite'/Game/UI/Atlas/Store/Frames/UI_Store_Slot_Icon_Gloves_png.UI_Store_Slot_Icon_Gloves_png'",
    "PaperSprite'/Game/UI/Atlas/Store/Frames/UI_Store_Slot_Icon_Weapon_png.UI_Store_Slot_Icon_Weapon_png'",
    "PaperSprite'/Game/UI/Atlas/Store/Frames/UI_Store_Slot_Icon_Shoes_png.UI_Store_Slot_Icon_Shoes_png'"
}

local EquipPartEnum = {
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_MAIN_HAND] = 5,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_DEPUTY_HAND] = 5,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_HEAD] = 1,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_BODY] = 2,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ARM] = 4,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_LEG] = 3,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FOOT] = 6,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ERR] = 1,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_NECK] = 1,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FINESSE] = 4,
	[ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING] = 4,
}

local InsufficientCurrency = 157039				--- LSTR("货币不足, 无法购买")
local BuyError = 157040							--- LSTR("购买发生未知错误, 请稍后尝试")
local PurchasedOverrun = 157035					--- LSTR("数量超出范围")
local InSelectedPurchased = 157041				--- LSTR("未达到最低购买数量")
local MinBuyQuantity = 1
local FullNotifiText = 157042					--- LSTR("背包空间不足, 商品已发送至邮箱, 请及时领取")
local BuyTipTittleText = 950047			--- 商品购买

local PingTai_Position = {
	["HaiJing1"] 	= _G.UE.FVector(445, -200, -5),
	["HuangGong1"] 	= _G.UE.FVector(300, 0, -53),
	["XueJing1"] 	= _G.UE.FVector(25, -10, -50),
	["TianYuan1"] 	= _G.UE.FVector(445, -200, -125),
	["LinDi1"] 		= _G.UE.FVector(-5000, 300, -100),
}

local PingTai_Rotation = {
	["HaiJing1"] 	= _G.UE.FRotator(0, 120, 0),
	["HuangGong1"] 	= _G.UE.FRotator(0, 180, 0),
	["XueJing1"] 	= _G.UE.FRotator(0, 296, -5),
	["TianYuan1"] 	= _G.UE.FRotator(0, 0, 0),
	["LinDi1"] 		= _G.UE.FRotator(0, 0, 0),
}

local LightPath = {
	["c0101"] = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Store/Store_c0101.Store_c0101'",
	["c0901"] = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Store/Store_c0901.Store_c0901'",
	["c1001"] = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Store/Store_c0901.Store_c0901'",
	["c1101"] = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Store/Store_c1101.Store_c1101",
	["c1201"] = "LightPreset'/Game/UI/Render2D/LightPresets/Login/TODUI_Store/Store_c1101.Store_c1101",
}

--- 当前主角异性的模型 key为当前主角的
local StoreNPCID = {
	["c0201"] = 1001374, 	-- 人男
	["c0101"] = 1007089,	-- 人女
	["c0601"] = 1001308,	-- 精灵男
	["c0501"] = 1001309,	-- 精灵女
	["c1201"] = 1001976,	-- 拉拉菲尔男
	["c1101"] = 1001310,	-- 拉拉菲尔女
	["c0801"] = 1010448,	-- 猫魅男
	["c0701"] = 1010479,	-- 猫魅女
	["c1001"] = 1001023,	-- 鲁加男
	["c0901"] = 1006544,	-- 鲁加女
}

---缩放聚焦位置
local StoreCamera_EID_CMAKE = {
	StoreCamera_EID_CMAKE_All = 1,
	StoreCamera_EID_CMAKE_UPPER = 2,
}

local TimeSaleText = 950050

local StoreRender2DConfig =
{
	CompanionSpringArmLocation = _G.UE.FVector(0, -80, 95),
	CompanionViewDistance = 600,
	CompanionFOVY = 25,
	MountSpringArmLocation = _G.UE.FVector(100, -80, 116), -- 坐骑图鉴有10cm的z轴偏移配置在蓝图里
	MountViewDistance = 350,
	MountFOVX = 50,
}

--region TLOG

local InterfaceOperationType =
{
	OpenStore = 1, -- 打开商城
	SwitchTab = 2, -- 切换页签
	RecommendJump = 3, -- 推荐页跳转到其他界面
	Browse = 4, -- 四处浏览
	PreviewBodyPart = 5, -- 时装部位预览
}

local BrowseOperationType =
{
	ClickVideo = 1,
	ClickFullScreen = 2,
	ClickHelmetHide = 3,
	ClickHelmetGimmick = 4,
	ClickRawEquipment = 5,
	ClickPoseChange = 6,
	ClickMountBGM = 7,
	ClickTag1 = 8,
	ClickTag2 = 9,
}

local PurchaseOperationType =
{
	SelectGoods = 1, -- 选中商品
	ClickMainPanelBuyButton = 2, -- 主界面购买按钮点击
	ClickDetailBuyButton = 3, -- 购买详情页面购买按钮点击
}

local GiftOperationType =
{
	SelectGoods = 1, -- 选中商品
	ClickMainPanelGiftButton = 2, -- 主界面赠送按钮点击
	ClickFriendGiftButton = 3, -- 好友选择页面赠送按钮点击
	ClickMailGiftButton = 4, -- 赠礼信页面赠送按钮点击
}

local MailTabType =
{
	Main = 1, -- 主界面
	GiftInbox = 2, -- 赠礼收件
	GiftRecord = 3, -- 赠礼记录
}

--endregion TLOG

local StoreDefine = {
    DefaultFilterIndex = DefaultFilterIndex,
    ShowDefaultTabIndex = ShowDefaultTabIndex,
    
    DyeFilterMaxValue = DyeFilterMaxValue,
    DyeTipsText = DyeTipsText,
    DyeFilterTextName = DyeFilterTextName,
    DyeFilterBtnName = DyeFilterBtnName,
    DyeFilterSelectName = DyeFilterSelectName,

    ExtendArrowAngle = ExtendArrowAngle,
    StoreMode = StoreMode,
	StoreModeText = StoreModeText,
    RestrictionTypeText = RestrictionTypeText,
    SoldOutText = SoldOutText,

    PriceDefaultIndex = PriceDefaultIndex,
    DiscountMaxValue = DiscountMaxValue,
	DiscountMinValue = DiscountMinValue,
    PurchasedMinValue = PurchasedMinValue,
    LimitMinValue = LimitMinValue,

    ItemQuality = ItemQuality,
    TimeLimitText = TimeLimitText,
    EquipPartSign = EquipPartSign,
    EquipPartEnum = EquipPartEnum,
    EquipShowMinValue = EquipShowMinValue,
    ItemEmptyID = ItemEmptyID,

    QuantityText = QuantityText,
    MinBuyQuantity = MinBuyQuantity,
    GoodsItemMinValue = GoodsItemMinValue,
    FullNotifiText = FullNotifiText,
    SecondScreenType = SecondScreenType,
    TimeValue = TimeValue,
    BuyTipsText = BuyTipsText,
    InsufficientCurrency = InsufficientCurrency,
    BuyError = BuyError,
    PurchasedOverrun = PurchasedOverrun,
    InSelectedPurchased = InSelectedPurchased,
	BuyTipTittleText = BuyTipTittleText,
	LSTRTextKey = LSTRTextKey,
	PingTai_Position = PingTai_Position,
	PingTai_Rotation = PingTai_Rotation,
	LightPath = LightPath,
	StoreNPCID = StoreNPCID,
	StoreCamera_EID_CMAKE = StoreCamera_EID_CMAKE,
	TimeSaleText = TimeSaleText,

	StoreRender2DConfig = StoreRender2DConfig,

	InterfaceOperationType = InterfaceOperationType,
	BrowseOperationType = BrowseOperationType,
	PurchaseOperationType = PurchaseOperationType,
	GiftOperationType = GiftOperationType,
	MailTabType = MailTabType,
}

return StoreDefine
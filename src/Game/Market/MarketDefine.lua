
local StallItemColor = {
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Sell_01.UI_Quality_Market_Sell_01'",
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Sell_02.UI_Quality_Market_Sell_02'",
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Sell_03.UI_Quality_Market_Sell_03'",
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Sell_04.UI_Quality_Market_Sell_04'",
}

local SellItemColor = {
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Available_01.UI_Quality_Market_Available_01'",
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Available_02.UI_Quality_Market_Available_02'",
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Available_03.UI_Quality_Market_Available_03'",
    "Texture2D'/Game/UI/Texture/Market/UI_Quality_Market_Available_04.UI_Quality_Market_Available_04'",
}


local TypeQueryCountPerPage = 12
local TypeQueryCountMax = 128

local MarketRedDotID = 
{
	Menu			= 1    ,		--二级菜单
	Market          = 14001,		--二级菜单交易
	Stall 			= 14002,		--摊位
}

local MarketDefine = {
	TypeQueryCountPerPage = TypeQueryCountPerPage,
	StallItemColor = StallItemColor,
	SellItemColor = SellItemColor,
    MarketRedDotID = MarketRedDotID,
    TypeQueryCountMax = TypeQueryCountMax,
}

return MarketDefine
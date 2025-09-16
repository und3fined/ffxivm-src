local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR

local RewardType =
{
	None = 1,
	Crystas = 2,
	Items = 3,
}

local RewardTypeStrMap =
{
	[RewardType.None] = LSTR(940007),
	[RewardType.Crystas] = LSTR(940008),
	[RewardType.Items] = LSTR(940009),
}

local RewardState =
{
	NotReady = 1,
	Ready = 2,
	Exhausted = 3,
}

local RewardItemState =
{
	Locked = 1,
	Available = 2,
	Got = 3,
}

local RewardActionType =
{
	Welcome = 1,
	Recharge = 2,
}

local ShopkeeperInteractType =
{
	Head = 1,
	Body = 2,
}

local RechargingDefine =
{
	RewardType = RewardType,
	RewardTypeStrMap = RewardTypeStrMap,
	RewardState = RewardState,
	RewardItemState = RewardItemState,
	RewardActionType = RewardActionType,
	ShopkeeperInteractType = ShopkeeperInteractType,
	ExchangeRate = 100, -- 1人民币换100水晶点
	RewardTipsThreshold = 99, -- 奖励提示的金额阈值，单位为人民币，相差金额大于此值则不提示
	CrystaScoreID = ProtoRes.SCORE_TYPE.SCORE_TYPE_STAMPS, -- 积分表里水晶点的ID
	HelpTipsShowInterval = 86400, -- 充值帮助提示间隔（单位为秒），24小时显示一次
	RedDotID = 12,
}

return RechargingDefine
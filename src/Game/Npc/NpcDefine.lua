-- 这里废弃不用了 , 使用 ProtoRes.CameraFocusTypeEnum
local DialogViewType =
{
	Closeup = 1, -- NPC特写
	PlayerLeft = 2, -- 双人镜头玩家居左
	PlayerRight = 3, -- 双人镜头玩家居右
	MajorDefault = 4, -- 以玩家为焦点
}

local DialogTargetType =
{
	DialogNPC = 1,
	MagicCardOpponent = 2,
}

local NpcDefine =
{
	-- DialogViewType = DialogViewType -- 使用 ProtoRes.CameraFocusTypeEnum
	DialogTargetType = DialogTargetType,
}

return NpcDefine

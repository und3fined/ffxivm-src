local ProtoRes = require("Protocol/ProtoRes")

local NPCDefine = require("Game/Npc/NpcDefine")

local LSTR = _G.LSTR
local CameraFocusType = ProtoRes.CameraFocusTypeEnum
local DialogTargetType = NPCDefine.DialogTargetType

local CameraFocusTypeNameMap =
{
	[CameraFocusType.Closeup] = LSTR("NPC特写"),
	[CameraFocusType.TwoPeoplePlayerLeft] = LSTR("双人镜头玩家居左"),
	[CameraFocusType.TwoPeoplePlayerRight] = LSTR("双人镜头玩家居右"),
	[CameraFocusType.MajorBack] = LSTR("玩家背面")
}

local DialogTargetTypeNameMap =
{
	[DialogTargetType.DialogNPC] = LSTR("对话NPC"),
	[DialogTargetType.MagicCardOpponent] = LSTR("幻卡对手"),
}

local DialogTargetEntityIDCallbackMap =
{
	[DialogTargetType.DialogNPC] =
		function()
			if nil ~= _G.NpcDialogMgr and nil ~= _G.NpcDialogMgr.LastDialog then
				return _G.NpcDialogMgr.LastDialog.NpcEntityID
			end
		end,
	[DialogTargetType.MagicCardOpponent] =
		function() 
			if nil ~= _G.MagicCardMgr then
				return _G.MagicCardMgr:GetOpponentEntityID()
			end
		end,
}

local NPCDialogGMConfig =
{
	CameraFocusTypeNameMap = CameraFocusTypeNameMap,
	DialogTargetTypeNameMap = DialogTargetTypeNameMap,
	DialogTargetEntityIDCallbackMap = DialogTargetEntityIDCallbackMap,
}

return NPCDialogGMConfig
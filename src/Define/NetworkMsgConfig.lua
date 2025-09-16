--
-- Author: anypkvcai
-- Date: 2023-05-16 9:51
-- Description:
--



local ProtoCS = require("Protocol/ProtoCS")

local CS_CMD = ProtoCS.CS_CMD

---@class NetworkMsgConfig
local NetworkMsgConfig = {

	DefaultSendInterval = 100, -- 默认发送间隔，单位：毫秒
	DefaultSendTips = 1260041, -- 默认提示 您操作太频繁

	DefaultWaitResTime = 5000, -- 默认等待回包时间，单位：毫秒
	DefaultWaitTips = 1260042, -- 默认提示 无法连接到服务器，请稍后尝试
}

---@class MsgConfigs @table<MsgID, SubMsgID>
---@field ErrorCode @错误码相关配置
---@field ErrorCode.bErrorCode boolean @是否处理错误码, 客户端发送了消息，如果有异常服务器是统一用CS_CMD_ERR返回的，客户端已经统一做了处理，如果需要单独处理，需要配置bErrorCode为 true， 会分发到回包函数里， MsgBody里只有ErrorCode 参考：CS_CMD_LOGIN
---@field ErrorCode.bIgnoreTips boolean @是否跳过通用错误提示，默认不跳过
---@field SendMsg @发包相关配置 适用于不需要等服务器回包 但是需要限制发送频率的情况
---@field SendMsg.bResend boolean @丢包或断线时丢失的包 是否要重新发包，只有没收到包客户端会显示异常时才配置，一般是在登录或切图过程中 向服务器请求的数据的包， 玩家手动操作的发包不要配置 比如：购买，如果丢包让玩家手动重新购买，以免异常多次自动购买
---@field SendMsg.bSendLimit boolean @是否限制发包频率
---@field SendMsg.SendInterval number @发包间隔 默认时间：NetworkMsgConfig.DefaultSendTips
---@field SendMsg.bShowTips number @是否显示发包频率提示
---@field SendMsg.Tips number @发包频繁提示内容 默认提示内容：NetworkMsgConfig.DefaultSendTips
---@field ReceiveMsg @收包相关配置 适用于一些重要消息 需要等服务器回包才能继续操作的情况，比如：登录、商城购买等重要消息
---@field ReceiveMsg.bWaitForRes boolean @是否需要等待服务器回包 在回包之前不能有其他操作
---@field ReceiveMsg.WaitTime number @等待服务器回包的时间 默认时间：NetworkMsgConfig.DefaultWaitResTime
---@field ReceiveMsg.bDontShowTips number @是否不显示收包超时提示 默认有提示
---@field ReceiveMsg.Tips number @超时提示多语言ukey 默认提示：NetworkMsgConfig.DefaultWaitTips
---@field ReceiveMsg.bReturnToLogin boolean @回包超时是否返回登录
---@field ReceiveMsg.bReconnect boolean @回包超时是否断线重连
local MsgConfigs = {
	--[[
	[MsgID] = {
		[SubMsgID] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bSendLimit = true },
			ReceiveMsg = { bWaitForRes = true },
		},
	--]]

	--和 CS_CMD 定义的顺序保持一致

	[CS_CMD.CS_CMD_CHECK_NAME] = {
		[0] = {
			ErrorCode = { bErrorCode = true },
			-- ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_QUERY_ROLELIST] = {
		[0] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_QUERY_ROLESIMPLE] = {
		[0] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_REGISTER] = {
		[0] = {
			ErrorCode = { bErrorCode = true },
			-- SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_LOGIN] = {
		[0] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bResend = true, bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true, bReconnect = true, WaitTime = 5000 },
		}
	},

	[CS_CMD.CS_CMD_LOGOUT] = {
		[0] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_VISION] = {
		[ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MOVE] = {
		[ProtoCS.CS_SUBMSGID_MOVE.CS_SUB_CMD_MOVE_INFO_REQ] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_SUBMSGID_MOVE.CS_SUB_CMD_MOVE_RESET] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_PWORLD] = {
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_ENTER] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_MAP_DYN_DATA_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_READY] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_TRANS] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_SHARED_GROUP_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_VIDEO_BEGIN] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_VIDEO_END] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_QUERY_SCENE_MEMBER] = {
			SendMsg = { bResend = true },
		},

		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_ADD_MEMBERS] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_CANCEL_ADD_MEMBERS] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_VOTE_START] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_MVP_VOTE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_RELOGIN_DATA_RECOVER] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PWORLD_CMD.CS_PWORLD_CMD_SET_SELF_DATA] = {
			-- ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_COMBAT] = {
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_STAT_UPDATE] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_ALL_ATTRS] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_CAMP] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_CD_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_BUFF] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_PERDUE_SKILL] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_SKILLLIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_SPECTRUM] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_SKILL_REVISE] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SUBSCRIBE_ENMITY_CHANGES] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_GET_ENMITY_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_CHARGE_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_PERFORM_SKILL] = {
			SendMsg = { bResend = true },
		}
	},

	[CS_CMD.CS_CMD_ROLE_INFO] = {
		[0] = {
			SendMsg = { bResend = true },
		}
	},

	[CS_CMD.CS_CMD_TEAM] = {
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_LEAVE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_DESTROY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_INVITE_JOIN] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_ANSWER_INVITE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_SET_CAPTAIN] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_UPDATE_MEMBER] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_KICK_MEMBER] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_QUERY_TEAM] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CsSubCmdTeamQueryRoleInfo] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CsQueryTeamMemberData] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CS_SUB_CMD_TEAM_SET_SELF_DATA] = {
			-- ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_QUERY_ROLEDETAIL] = {
		[0] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MAP_AREA] = {
		[ProtoCS.CS_MAP_AREA_CMD.CS_MAP_AREA_CMD_ENTER] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_COMM_STAT] = {
		[ProtoCS.CS_COMM_STAT_CMD.CS_COMM_STAT_CMD_STATUS] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_REVIVE] = {
		[ProtoCS.CS_REVIVE_CMD.CS_REVIVE_CMD_CONFIRM] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_TARGET] = {

	},

	[CS_CMD.CS_CMD_NPC] = {

	},

	[CS_CMD.CS_CMD_ACTIVITY] = {

	},

	[CS_CMD.CS_CMD_SKILL] = {

	},

	[CS_CMD.CS_CMD_RENAME] = {
		[ProtoCS.RenameCmd.RenameCmdRename] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_FRIENDS] = {
		[ProtoCS.Friend.Friends.CS_SUBMSGID_FRIENDS.CS_SUB_CMD_FRIENDS_NEWGROUP] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.Friend.Friends.CS_SUBMSGID_FRIENDS.CS_SUB_CMD_FRIENDS_REMOVEGROUP] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.Friend.Friends.CS_SUBMSGID_FRIENDS.CS_SUB_CMD_FRIENDS_GET_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Friend.Friends.CS_SUBMSGID_FRIENDS.CS_SUB_CMD_FRIENDS_CONSORTLIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Friend.Friends.CS_SUBMSGID_FRIENDS.CS_SUB_CMD_FRIENDS_PULL_SETTING] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_WEATHER] = {
		[ProtoCS.WeatherCmd.WeatherCmdFuture] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_QUERY_HISTORY_NAME] = {

	},

	[CS_CMD.CS_CMD_QUERY_EQUIP_GEM] = {

	},

	[CS_CMD.CS_CMD_SUMMON_BEAST] = {

	},

	[CS_CMD.CS_CMD_PROF] = {
		[ProtoCS.ProfSubMsg.ProfSubMsgSwitch] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_EQUIPMENT] = {

	},

	[CS_CMD.CS_CMD_SCORE] = {
		[ProtoCS.CS_SCORE_CMD.SCORE_SELECT_CMD] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_SCORE_CMD.SCORE_ITERATION_CONVERT_CMD] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_BAG] = {
		[ProtoCS.CS_BAG_CMD.CS_CMD_BAG_INFO] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_BAG_CMD.CS_CMD_BAG_TRANS_DEPOT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_BAG_CMD.CS_CMD_BAG_USE_ITEM] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_BAG_CMD.CS_CMD_ITEM_CD_ALL] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MARKET] = {
		[ProtoCS.MarketOptCmd.MarketOptCmd_Money] = {
			SendMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_QueryGoods] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Buy] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Follow] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Sale] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Close] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_ListStalls] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_ReSale] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_BatchReSale] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_BatchClose] = {
			ReceiveMsg = { bWaitForRes = true },
		}
		
	},

	[CS_CMD.CS_CMD_QUEST] = {
		[ProtoCS.CS_QUEST_CMD.QUEST_LIST_CMD] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_QUEST_CMD.QUEST_GET_TRACK_CMD] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_QUEST_CMD.QUEST_TARGET_FINISH_CMD] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_LOOT] = {
		[0] = {
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_LIFE_SKILL] = {
		[ProtoCS.CS_LIFE_SKILL_CMD.LIFE_SKILL_ACTION_CMD] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_LIFE_SKILL_CMD.LIFE_SKILL_CRAFTER_START_MAKE] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_LIFE_SKILL_CMD.LIFE_SKILL_CRAFTER_RESULT] = {
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		},
		[ProtoCS.CS_LIFE_SKILL_CMD.LIFE_SKILL_GATHER_START_CMD] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_LIFE_SKILL_CMD.LIFE_SKILL_COLLECTION_CMD] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_LIFE_SKILL_CMD.LIFE_SKILL_CRAFTER_GET] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_EMOTION] = {
		[ProtoCS.EmotionSubMsg.EmotionSubMsgLeave] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.EmotionSubMsg.EmotionSubMsgQuery] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.EmotionSubMsg.EmotionSubMsgQueryStat] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_CHATC] = {
		[ProtoCS.CS_CHAT_CMD.CS_CHAT_CMD_MSG_PULL] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_CHAT_CMD.CS_CHAT_CMD_CHANNEL_HAVE_READ] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_CHAT_CMD.CS_CHAT_CMD_QUERY_MEMBER] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_CHAT_CMD.CS_CHAT_CMD_ACTIVE_ROLE] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_CHAT_CMD.CS_CHAT_CMD_QUERY_UNLOCK_GIF] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_CHAT_CMD.CS_CHAT_CMD_VANGUARD_INFO] = {
			SendMsg = { bResend = true },
		},
	},


	[CS_CMD.CS_CMD_TELEPORT_CRYSTAL] = {
		[ProtoCS.CS_SUBMSGID_TELEPORT_CRYSTAL.CRYSTAL_INFO] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_INTERAVIVE] = {
		[ProtoCS.CsInteractionCMD.CsInteractionCMDStart] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CsInteractionCMD.CsInteractionCMDEnd] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CsInteractionCMD.CsInteractionCMDBreak] = {
			SendMsg = { bResend = true },
		},
	},


	[CS_CMD.CS_CMD_COUNTER] = {
		[ProtoCS.CS_COUNTER_CMD.LIST] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_DEPOT] = {
		[ProtoCS.CS_DEPOT_CMD.CS_DEPOT_CMD_SIMPLE_INFO] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_DEPOT_CMD.CS_DEPOT_CMD_DETAIL_INFO] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_DEPOT_CMD.CS_DEPOT_CMD_TRANSFER] = {
			SendMsg = { bSendLimit = true },
			--ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_DEBUG] = {

	},

	[CS_CMD.CS_CMD_LINKSHELL] = {
		[ProtoCS.GroupChat.LinkShells.CS_SUBMSGID_LINKSHELL.CS_SUB_CMD_LINKSHELL_GETLIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.GroupChat.LinkShells.CS_SUBMSGID_LINKSHELL.CS_SUB_CMD_LINKSHELL_TRANSFERCREATE] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.GroupChat.LinkShells.CS_SUBMSGID_LINKSHELL.CS_SUB_CMD_LINKSHELL_SETMANAGE] = {
			ErrorCode = { bErrorCode = true },
		}
	},
	[CS_CMD.CS_CMD_MOUNT] = {
		[ProtoCS.MountCmd.MountCmdQuery] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_TEAM_RECRUIT] = {
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_QUERY_SELF] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_UPDATE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_QUERY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_GET_LIST] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_JOIN] = {
			ReceiveMsg = { bWaitForRes = true },
			ErrorCode =  { bErrorCode = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_INDEX] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_QUERY_RELATION] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Team.TeamRecruit.CS_SUBMSGID_TEAM_RECRUIT.CS_SUBMSGID_TEAM_RECRUIT_QUERY_RELATION_INFO] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_ROLL] = {
		[ProtoCS.CS_ROLL_CMD.RollQuery] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_ADVENTURE] = {
		[ProtoCS.CS_ADVENTURE_CMD.CS_ADVENTURE_CMD_CHALLENGE_LOG] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_ADVENTURE_CMD.CS_ADVENTURE_CMD_CHALLENGE_LOG_REWARD] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_QUERY_ROLE_ITEM_INFO] = {

	},

	[CS_CMD.CS_CMD_BONUS_STATE] = {
		[ProtoCS.BonusStateCmd.BonusStateCmdPull] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_ONLINE_STATUS] = {
		[ProtoCS.CSOnlineStatusCmd.CSOnlineStatusCmdQuery] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_CLIENT_REPORT] = {
		[ProtoCS.ReportType.ReportTypeBandListen] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MESSAGE_BOARD] = {

	},

	[CS_CMD.CS_CMD_PAY] = {
		[ProtoCS.CS_PAY_CMD.CS_CMD_PAY_DISTRIBUTE_COUPON] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_PAY_CMD.CS_CMD_PAY_QUERY_RECHARGE_AWARD] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_GUIDE] = {
		[ProtoCS.GuideOptCmd.GuideOptCmd_Status] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_Attestation] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_Condition] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_NewbieStatus] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_GuideNum] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_ReturneeStatus] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_AllStatus] = {
			SendMsg = { bResend = true },
		},	
		[ProtoCS.GuideOptCmd.GuideOptCmd_RspInviteJoinNewbieChannel] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.GuideOptCmd.GuideOptCmd_MoveOutNewbieChannel] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_MODULE_OPEN] = {

	},

	[CS_CMD.CS_CMD_HOPE] = {

	},

	[CS_CMD.CS_CMD_MATCH] = {
		[ProtoCS.CSSubMsgIDMatch.CSSubMsgIDMatch_CancelMatch] = {
		},
		[ProtoCS.CSSubMsgIDMatch.CSSubMsgIDMatch_GetMatchInfo] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CSSubMsgIDMatch.CSSubMsgIDMatch_Punishment] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CSSubMsgIDMatch.CSSubMsgIDMatch_Query] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CSSubMsgIDMatch.CSSubMsgIDMatch_Waiting] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_VOTE] = {
		[ProtoCS.VoteSubCmd.VoteSubCmd_Poll] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.VoteSubCmd.VoteSubCmd_Vote] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.VoteSubCmd.VoteSubCmd_Query] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_JUDGE_SEARCH_INPUT] = {
		[0] = {
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_BUDDY] = {
		[ProtoCS.BuddyCmd.BuddyCmdQuery] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdDyeColor] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_COMPANION] = {
		[ProtoCS.CompanionCmd.CompanionCmdQuery] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MALL_AND_STORE] = {
		[ProtoCS.CsMallAndStoreCmd.CS_MALL_AND_STORE_CMD_MALL_PURCHASE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsMallAndStoreCmd.CS_MALL_AND_STORE_CMD_MALL_GIFT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsMallAndStoreCmd.CS_MALL_AND_STORE_CMD_MALL_QUERY] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = false },
		},
		[ProtoCS.CsMallAndStoreCmd.CS_MALL_AND_STORE_CMD_STORE_QUERY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsMallAndStoreCmd.CS_MALL_AND_STORE_CMD_STORE_PURCHASE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsMallAndStoreCmd.CS_MALL_AND_STORE_CMD_QUERY_RESIDS] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_TITLE] = {
		[ProtoCS.TitleOptCmd.TOCTitle] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.TitleOptCmd.TOCTitleMsg] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.TitleOptCmd.TOCSet] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.TitleOptCmd.TOCCollect] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_CHOCOBO_TRANSFER] = {
		[ProtoCS.ChocoboTransferCmd.ChocoboTransferCmdQuery] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ChocoboTransferCmd.ChocoboTransferCmdEnd] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_PERFORM] = {
		[ProtoCS.PerformCmd.EnsembleCmdAskConfirm] = {
			ErrorCode = { bErrorCode = true },
		}
	},

	[CS_CMD.CS_CMD_CHOCOBO] = {
		[ProtoCS.ChocoboCmd.ChocoboCmdQuery] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdQuerySkillList] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdGetSuitCollected] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdQueryTitle] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdRent] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdFree] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdRentInfo] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdRentRefresh] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.ChocoboCmd.ChocoboCmdMatingReceive] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_CHOCOBO_RACE] = {

	},
	[CS_CMD.CS_CMD_FACE_DATA] = {

	},

	[CS_CMD.CS_CMD_MARKING] = {
		[ProtoCS.MarkingCmd.MarkingCmdTarget] = {
			SendMsg = { bSendLimit = true, SendInterval = 500, bShowTips = true},
		},
	},

	[CS_CMD.CS_CMD_ACHIEVEMENT] = {
		[ProtoCS.CsAchievementCmd.CS_ACHIEVEMENT_QUERY] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CsAchievementCmd.CS_ACHIEVEMENT_CLAIM] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsAchievementCmd.CS_ACHIEVEMENT_TARGET_LIST] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsAchievementCmd.CS_ACHIEVEMENT_LEVEL_AWARD] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_PERFORM_ACTION] = {

	},

	[CS_CMD.CS_CMD_LEGENDARY_WEAPON] = {
		[ProtoCS.CsLegendaryWeaponCmd.CS_LEGENDARY_WEAPON_CMD_QUERY] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_CLOSET] = {
		[ProtoCS.CsClosetCmd.CS_CLOSET_QUERY] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_UNLOCK] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_DYE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_DYE_RECOVERY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.Cs_CLOSET_REGION_DYE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_SUIT_SAVE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_CHOOSESUIT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_CLOTHING] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_UNCLOTHING] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_SUIT_LINK_PROF] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_SUIT_RENAME] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_SUIT_CLOTHING] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_CHARISM_REWARD] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_ACTIVE_STAIN] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_SUIT_ENLARGE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_COLLECT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_QUERY_UNLOCK] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CsClosetCmd.CS_CLOSET_RANDOM_PATTERN] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_LATENCY] = {

	},

	[CS_CMD.CS_CMD_CLIENT_OPERATION] = {

	},

	[CS_CMD.CS_CMD_SYS_NOTICE] = {

	},

	[CS_CMD.CS_CMD_NAVMESH] = {
		[ProtoCS.CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_BUNDLE] = {
			SendMsg = { bResend = true },
		}
	},

	[CS_CMD.CS_CMD_SEARCH] = {

	},

	[CS_CMD.CS_CMD_COLOSSEUM_COMBAT] = {
		[ProtoCS.CS_COLOSSEUM_COMBAT_CMD.CS_COLOSSEUM_COMBAT_CMD_BUNDLE] = {
			SendMsg = { bResend = true },
		}
	},

	[CS_CMD.CS_CMD_LOGIC_TIME] = {

	},

	[CS_CMD.CS_CMD_SAMPLE] = {
		[0] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_LOGIN_ENTER] = {
		[0] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true, bReconnect = true, WaitTime = 5000 },
		},
	},

	[CS_CMD.CS_CMD_RECONNECT] = {
		[0] = {
			ReceiveMsg = { bWaitForRes = true, bReconnect = true, WaitTime = 5000 },
			ErrorCode = { bErrorCode = true },
		}
	},

	[CS_CMD.CS_CMD_CLIENT_CFG] = {
		[ProtoCS.ClientSetupMsgID.ClientSetupMsgIDQuery] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.ClientSetupMsgID.ClientSetupMsgIDSet] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_CONFIG] = {
		[0] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_GM] = {

	},

	[CS_CMD.CS_ACE_GM] = {

	},

	[CS_CMD.CS_CMD_PRELOGIN] = {

	},

	[CS_CMD.CS_CMD_REDPOSITION] = {
		[ProtoCS.Profile.RedPosition.CsRedPositionCmd.CS_RED_POSITION_QUERY] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_PLAYPRIVACY] = {

	},

	[CS_CMD.CS_CMD_MIXNOTIFY] = {

	},

	[CS_CMD.CS_CMD_MEETTRADE] = {

	},

	[CS_CMD.CS_CMD_FANTASYCARD] = {
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_INFO] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_NPC] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_TOURNAMENT_RANK] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_AWARD_RECORD] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_NEW_MOVE] = {
			SendMsg = { bResend = false },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_VIEW_GROUP] = {
			SendMsg = { bResend = true },
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.FANTASY_CARD_OP.FANTASY_CARD_OP_ENTER] = {
			SendMsg = { bResend = true },
			ErrorCode = { bErrorCode = true },
		},
	},

	[CS_CMD.CS_CMD_MINI_CACTPOT] = {
		[ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_ENTER] = {
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		},
		[ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_VIEW] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_SCRATCH] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_FATE] = {
		[ProtoCS.CS_FATE_CMD.CS_FATE_CMD_UPDATE] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_FATE_CMD.CS_FATE_CMD_GET_STATS] = {
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		}
	},

	[CS_CMD.CS_CMD_FAIRY_COLOR] = {
		[ProtoCS.FairyColorGameCmd.QueryBase] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_GOLD_SAUSER] = {
		[ProtoCS.CS_GOLD_SAUSER_CMD.CS_GOLD_SAUSER_CMD_UPDATE] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GOLD_SAUSER_CMD.CS_GOLD_SAUSER_CMD_END] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GOLD_SAUSER_CMD.CS_GOLD_SAUSER_CMD_SIGNUP] = {
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		},
	},

	[CS_CMD.CS_CMD_FASHION_CHECK] = {
		[ProtoCS.Game.FashionCheck.Cmd.Update] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Game.FashionCheck.Cmd.Check] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_GOLD_SAUSER_MAIN] = {
		[ProtoCS.CS_GOLD_SAUSER_MAIN_CMD.CS_GOLD_SAUSER_MAIN_CMD_GET_EVENT] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GOLD_SAUSER_MAIN_CMD.CS_GOLD_SAUSER_MAIN_CMD_DATA_QUERY] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_BARBER_SHOP] = {
		[ProtoCS.Game.Barbershop.Cmd.SetFace] = {
			SendMsg = { bResend = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Game.Barbershop.Cmd.UnlockHair] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Game.Barbershop.Cmd.Update] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MATCH_CONFIRM] = {
		[ProtoCS.CS_MATCH_CONFIRM_CMD.CS_MATCH_CONFIRM_CMD_QUERY] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_WILD_BOX] = {
		[ProtoCS.Game.WildBox.Cmd.OpenBox] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MYSTER_MERCHANT] = {
		[ProtoCS.Game.MysteryMerchant.Cmd.QueryMerchantData] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Game.MysteryMerchant.Cmd.BuyMerchantGoods] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_PvPColosseum] = {
		[ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD.BTLMATERIALS] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD.INVITE_DUEL] = {
			SendMsg = { bSendLimit = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD.ACCEPT_DUEL] = {
			SendMsg = { bSendLimit = true },
			ReceiveMsg = { bWaitForRes = true },
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.Game.PvPColosseum.CS_PVPCOLOSSEUM_CMD.CANCLE_DUEL] = {
			SendMsg = { bSendLimit = true },
			ReceiveMsg = { bWaitForRes = true },
			ErrorCode = { bErrorCode = true },
		},
	},

	[CS_CMD.CS_CMD_TOURING_BAND] = {
		[ProtoCS.Game.TouringBand.Cmd.QueryCollection] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_QUESTIONNAIRE] = {
		[ProtoCS.Game.Questionnaire.Cmd.QueryQuestionnaire] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_ACTIVITY_SYSTEM] = {
		[ProtoCS.Game.Activity.Cmd.List] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Game.Activity.Cmd.ListByID] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Game.Activity.Cmd.Reward] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Game.Activity.Cmd.MultiReward] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_MONSTORHUNT] = {

	},

	[CS_CMD.CS_CMD_TRIBE] = {

	},

	[CS_CMD.CS_CMD_ZeroSceneRank] = {

	},

	[CS_CMD.CS_CMD_DIRECT_UPGRADE] = {

	},

	[CS_CMD.CS_CMD_LIGHT_JOURNEY] = {
		[ProtoCS.Game.TouringBand.Cmd.QueryBandMapData] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_WINDPULSE] = {
		[ProtoCS.CSWindPulseCmd.WindPulseDataSync] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_ALONE_TREE] = {
		[ProtoCS.CS_ALONE_TREE_CMD.CS_ALONE_TREE_ENTER] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		}
	},

	[CS_CMD.CS_CMD_FOG] = {
		[ProtoCS.CSExploreFogCmd.ExploreFogAreaIDListCmd] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MONTH_CARD] = {
		[ProtoCS.MonthCardCmd.MonthCardCmd_Status] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MonthCardCmd.MonthCardCmd_DailyReward] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_PERSONAL_HEADER] = {
		[ProtoCS.Role.Portrait.PersonalPortraitOptCmd.PersonalPortrait_GetResList] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Role.Portrait.PersonalPortraitOptCmd.PersonalPortrait_UpdateProfAppear] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_MUSIC] = {
		[ProtoCS.MusicOptCmd.MusicOptCmd_GET] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MusicOptCmd.MusicOptCmd_GetUnLockList] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MusicOptCmd.MusicOptCmd_GetRecordList] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MusicOptCmd.MusicOptCmd_RedUpdate] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_LEVE_QUEST] = {
		[ProtoCS.LeveQuest.LeveQuestCmd.LeveQuestBatchSubmit] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.LeveQuest.LeveQuestCmd.LeveQuestQuery] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.LeveQuest.LeveQuestCmd.LeveQuestAcceptTaskList] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.LeveQuest.LeveQuestCmd.LeveQuestBatchSubmit] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_ENTOURAGE] = {

	},

	[CS_CMD.CS_CMD_BASKETBALL] = { -- 怪物投篮
		[ProtoCS.CSMonsterBasketballCmd.CSMonsterBasketball_Enter] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		}
	},

	[CS_CMD.CS_CMD_BATTLE_PASS] = {
		[ProtoCS.BattlePass.BattlePassCmd.BattlePassCmdState] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.BattlePass.BattlePassCmd.BattlePassCmdLevel] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.BattlePass.BattlePassCmd.BattlePassCmdTask] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.BattlePass.BattlePassCmd.BattlePassCmdWeekSign] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_CRYSTAL_TOWER] = {    -- 强袭水晶塔
		[ProtoCS.CrystalTowerCmd.CrystalTowerCmdEnter] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		}
	},

	[CS_CMD.CS_CMD_GILGAMESH] = { -- 重击加美什
		[ProtoCS.CSGilgameshCmd.CSGilgameshCmdENTER] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true, WaitTime = 15000 },
		}
	},

	[CS_CMD.CS_CMD_PERSONAL_PIC] = {

	},

	[CS_CMD.CS_CMD_FANTASY_MEDICINE] = {
		[ProtoCS.FantasyMedicineCmd.FantasyMedicineCmdUse] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_PHOTOS] = {
		[ProtoCS.Role.Photos.PhotosOptCmd.PhotosSave] = {
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_GRAND_COMPANY] = {
		[ProtoCS.Role.GrandCompany.GrandCompanyCmd.GrandCompanyCmdState] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Role.GrandCompany.GrandCompanyCmd.GrandCompanyCmdFinishPrepareTask] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Role.GrandCompany.GrandCompanyCmd.GrandCompanyCmdMilitaryUpgrade] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Role.GrandCompany.GrandCompanyCmd.GrandCompanyCmdTransferCompany] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Role.GrandCompany.GrandCompanyCmd.GrandCompanyCmdJoinCompany] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Role.GrandCompany.GrandCompanyCmd.GrandCompanyCmdExchangeCompanySeal] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_EXCHANGE] = {

	},

	[CS_CMD.CS_CMD_MARKET] = {
		[ProtoCS.MarketOptCmd.MarketOptCmd_ListFollows] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Login] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Buy] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.MarketOptCmd.MarketOptCmd_Sale] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_HEAD_PORTRAIT] = {

	},

	[CS_CMD.CS_CMD_HEADER_FRAME] = {

	},

	[CS_CMD.CS_CMD_FAIRY_BLESSED] = {
		[ProtoCS.Game.FairyBlessed.CS_FAIRY_BLESSED_CMD.CS_FAIRY_BLESSED_CMD_GET] = {
			SendMsg = { bResend = true },
		}
	},

	[CS_CMD.CS_CMD_FASHION_DECORATE] = {
		[ProtoCS.Role.FashionDecorate.CsFashionDecorateCmd.CsFashionDecorateQuery] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_GROUP] = {
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_QUERY] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_QUERY_MEMBERS] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_QUERY_SELF_MEMBERS] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_QUERY_SELF] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_ACCEPT_INVITATION] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_ACCEPT_APPLY] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_REFUSE_APPLY] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_IGNORE_INVITATION] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SET_MEMBER_CATEGORY] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_MONEY_BAG_DEPOSIT] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_MONEY_BAG_WITHDRAW] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_CHECK_SENSITIVE_TEXT] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_CREATE] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_DISBAND] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_QUIT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_TRANSFER_LEADER] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_REFUSE_APPLY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SEND_INVITATION] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_KICK_MEMBER] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_STORE_DEPOSIT_ITEM] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_STORE_FETCH_ITEM] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_STORE_SET_STORE_NAME] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_EDIT_CATEGORY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_PETITION_GAIN] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_PETITION_EDIT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_PETITION_CANCEL] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SIGN_INVITE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_APPLY] = {
			ErrorCode = { bErrorCode = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_BONUS_STATE_BUY] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_BONUS_STATE_USE] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_BONUS_STATE_STOP] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_EDIT_INFO] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SIGN_AGREE] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SIGN_REFUSE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SIGN_CANCEL] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_GRAND_COMPANY_CHANGE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_PETITION_CANCEL_TOC] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_PROFILE_EDIT] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_GROUP_CMD.CS_CMD_GROUP_SIGN_REFUSE_TOC] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_NOTE] = {
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_MARK_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_HISTORY_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_QUERY_VERSION] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_CLOCK] = {
			SendMsg = { bResend = true },
			--ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_FISH_NOTE_BOOK_LIST] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_RED_POINT] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_FISH_GROUND_QUERY] = {
			SendMsg = { bResend = true },
		},
		-- [ProtoCS.CS_NOTE_CMD.CS_CMD_FISH_CLOCK_UPDATE] = {
		-- 	ReceiveMsg = { bWaitForRes = true },
		-- },
		-- [ProtoCS.CS_NOTE_CMD.CS_CMD_FISH_CLOCK_CANCEL] = {
		-- 	ReceiveMsg = { bWaitForRes = true },
		-- },
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_CLOCK_LIST_UPDATE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_CANCEL_CLOCK] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_CANCEL_MARK] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_NOTE_MARK] = {
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_GROUND_UNLOCK] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_NOTE_CMD.CS_CMD_SCENE_FINISH_LOG] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_COLLECT] = {
		[ProtoCS.CS_COLLECT_CMD.CS_CMD_COLLECT_RECORD] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.CS_COLLECT_CMD.CS_CMD_COLLECT_EXCHANGE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_MAIL] = {
		[ProtoCS.Mail.Mail.CmdMail.CmdGetMail] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Mail.Mail.CmdMail.CmdSetRead] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Mail.Mail.CmdMail.CmdReceiveAttachmentAward] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
		[ProtoCS.Mail.Mail.CmdMail.CmdDelMail] = {
			ErrorCode = { bErrorCode = true },
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_TREASURE_HUNT] = {
		[ProtoCS.Game.TreasureHunt.CmdTreasureHunt.TreasureHuntInfo] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.Game.TreasureHunt.CmdTreasureHunt.DigTreasure] = {
			ErrorCode = { bErrorCode = true },
		},
	},

	[CS_CMD.CS_CMD_MINI_CACTPOT] = {
		[ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_VIEW] = {
			SendMsg = { bResend = true },
		},
		[ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_SCRATCH] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_CATCH_BALL] = {
		[ProtoCS.CatchBallCmd.CatchBallStart] = {
			ErrorCode = { bErrorCode = true },
			SendMsg = { bSendLimit = true, SendInterval = 300 },
			ReceiveMsg = { bWaitForRes = true },
		}
	},

	[CS_CMD.CS_CMD_FOOT_PRINT] = {
		[ProtoCS.CmdFootprint.CmdFootRedPoint] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_SEARCH_NOTE] = {
		[ProtoCS.SearchNoteCmd.SearchNoteCmdQuery] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_LANTERN] = {
		[ProtoCS.Game.Lantern.CS_LANTERN_CMD.LANTERN_GETLIST] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_AREA_MAIL] = {

	},

	[CS_CMD.CS_CMD_AREA_CLEAN] = {

	},

	[CS_CMD.CS_CMD_CHOOSETREASURECHEST] = {
		[ProtoCS.Game.ChooseTreasureChest.CS_CHOOSETREASURECHEST_CMD.EXCHANGE] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_BLINDBOX] = {
		[ProtoCS.Game.BlindBox.CS_BLINDBOX_CMD.BUY] = {
			ReceiveMsg = { bWaitForRes = true },
		},
	},

	[CS_CMD.CS_CMD_AUTOFINDPATH] = {
		[ProtoCS.CS_AUTO_FINDPATH_CMD.CS_AUTO_FINDPATH_CMD_STOP] = {
			SendMsg = { bResend = true },
		},
	},

	[CS_CMD.CS_CMD_FOOT_MARK] = {
		[ProtoCS.CS_FOOT_MARK_CMD.CS_FOOT_MARK_CMD_PULL] = {
			SendMsg = { bResend = true },
		},
	},
}

function NetworkMsgConfig.GetMsgConfig(MsgID, SubMsgID)
	local Config = MsgConfigs[MsgID]
	if nil == Config then
		return
	end

	return Config[SubMsgID]
end

---GetErrorCodeConfig
---@param MsgID number
---@param SubMsgID number
function NetworkMsgConfig.GetErrorCodeConfig(MsgID, SubMsgID)
	local Config = NetworkMsgConfig.GetMsgConfig(MsgID, SubMsgID)
	if nil ~= Config then
		return Config.ErrorCode
	end
end

---GetSendMsgConfig
---@param MsgID number
---@param SubMsgID number
function NetworkMsgConfig.GetSendMsgConfig(MsgID, SubMsgID)
	local Config = NetworkMsgConfig.GetMsgConfig(MsgID, SubMsgID)
	if nil ~= Config then
		return Config.SendMsg
	end
end

---GetReceiveMsgConfig
---@param MsgID number
---@param SubMsgID number
function NetworkMsgConfig.GetReceiveMsgConfig(MsgID, SubMsgID)
	local Config = NetworkMsgConfig.GetMsgConfig(MsgID, SubMsgID)
	if nil ~= Config then
		return Config.ReceiveMsg
	end
end

return NetworkMsgConfig
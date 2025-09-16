local OperationChannelID = require("Define/OperationChannelID")

---@class OperationChannelFunctionConfig
local OperationChannelFunctionConfig = {
	[OperationChannelID.IOSChannel] = {
		IsEnableCustomerServiceCenter = true,			-- 客服中心
		IsEnableYouthGuardian = true,					-- 中控
		IsEnableTapFaceActivity = true,					-- 拍脸活动
		IsEnableInGameAnnouncement = true,				-- 游戏内公告
		IsEnableQRCodeForShare = true,					-- 分享二维码
		IsEnableWeChatLaunchPrivileges = true,			-- 微信启动特权
		IsEnableWeChatGameCenterEntrance = true,		-- 微信游戏中心入口
		IsEnableWeChatGameCommunityEntrance = true,		-- 微信游戏社区入口
		IsEnableWeChatPublicAccountEntrance = true,		-- 微信公众号入口
		IsEnableQQLaunchPrivileges = true,				-- 手Q启动特权
		IsEnableQQGameCenterEntrance = true,			-- 手Q游戏中心入口
		IsEnableQQGameCommunityEntrance = true,			-- 手Q游戏社区入口
		IsEnableAndrowsEntrance = true,					-- 应用报入口
		IsEnableTencentVideoEntrance = true,			-- 腾讯视频入口
		IsEnableXinYueEntrance = true,					-- 心悦入口
	},
}

return OperationChannelFunctionConfig

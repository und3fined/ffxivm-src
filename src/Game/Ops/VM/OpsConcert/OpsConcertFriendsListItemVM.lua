local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MSDKDefine = require("Define/MSDKDefine")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
---@class OpsConcertFriendsListItemVM : UIViewModel
local OpsConcertFriendsListItemVM = LuaClass(UIViewModel)
---Ctor
function OpsConcertFriendsListItemVM:Ctor()
    self.FriendName = nil
	self.GameName = nil
	self.OfflineTime = nil
	self.GameNameDeco = nil --由名字和离线时间组成
	self.Icon = nil
	self.HeadUrl = nil
	self.UserOpenID = nil
end

function OpsConcertFriendsListItemVM:UpdateVM(Params)
    if Params == nil then
		return
	end
	self.InviterCode = Params.InviterCode
	self.FriendName = Params.FriendName
	self.GameName = Params.GameName
	self.OfflineTime = LocalizationUtil.GetTimerForLowPrecision(TimeUtil.GetServerLogicTime() - Params.LoginTime, 30)
	self.GameNameDec = self.GameName .. " " .. self.OfflineTime
	if _G.LoginMgr.ChannelID == MSDKDefine.ChannelID.WeChat then
		self.Icon = "Texture2D'/Game/UI/Texture/Team/UI_Comm_Btn_WeChat.UI_Comm_Btn_WeChat'"
	elseif _G.LoginMgr.ChannelID == MSDKDefine.ChannelID.QQ then
		self.Icon = "Texture2D'/Game/UI/Texture/Team/UI_Comm_Btn_QQ.UI_Comm_Btn_QQ'"
	end
	self.HeadUrl = Params.HeadUrl
	self.UserOpenID = Params.UserOpenID
end

return OpsConcertFriendsListItemVM
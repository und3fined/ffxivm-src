local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ChatDefine = require("Game/Chat/ChatDefine")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

local NewbieMemberType = ChatDefine.NewbieMemberType
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify

local ChatNewbieMemberItemVM = LuaClass(UIViewModel)

function ChatNewbieMemberItemVM:Ctor()
    self.RoleID = 0
    self.Name = ''
    self.MapResName = ''
	self.OnlineStatusIcon = ""
    self.State = ''
    self.IsOnline = false 
    self.LoginTime = 0
    self.LogoutTime = 0
    self.ProfID = 0
    self.LevelDesc = ""

    self.MemberType = NewbieMemberType.All
end

function ChatNewbieMemberItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.RoleID == self.RoleID
end

function ChatNewbieMemberItemVM:UpdateVM(Value)
    self.RoleID = Value.RoleID 
    self.Name = Value.Name
    self.MapResName = Value.MapResName
    self.LoginTime = Value.LoginTime

    local IsOnline = Value.IsOnline
    self.IsOnline = IsOnline

    local LogoutTime = Value.LogoutTime
    self.LogoutTime = LogoutTime

    if IsOnline then
        self.State = self.MapResName
    else
        self.State = _G.TimeUtil.GetOfflineDesc(LogoutTime)
    end

	self.OnlineStatusIcon = Value.OnlineStatusIcon 

    self.ProfID = Value.Prof 
    self.LevelDesc = tostring(Value.Level or 0)

    local MemberType = NewbieMemberType.All
    local Identity = OnlineStatusUtil.QueryMentorRelatedIdentity(Value.Identity)
	if Identity == OnlineStatusIdentify.OnlineStatusIdentifyNewHand
		or Identity == OnlineStatusIdentify.OnlineStatusIdentifyReturner then -- 新人、回归者
        MemberType = NewbieMemberType.NewcomerAndReturner

	elseif Identity == OnlineStatusIdentify.OnlineStatusIdentifyMentor then -- 指导者
        MemberType = NewbieMemberType.Mentor
    end

    self.MemberType = MemberType
end

return ChatNewbieMemberItemVM
--@author wallencai(蔡文超)
--@date 2022-8-24

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ProtoCS = require("Protocol/ProtoCS")
local Json = require("Core/Json")
local CommPlayerDefine = require("Game/Common/Player/CommPlayerDefine")

local ClientSetupKey = ProtoCS.ClientSetupKey
local StateType = CommPlayerDefine.StateType

local FriendEntryVM = LuaClass(UIViewModel)

function FriendEntryVM:Ctor()
    self.RoleID = nil
    self.GroupID = nil
    self.Name = nil
    self.MapResName = nil
    self.State = nil
    self.StateType = StateType.None 
    self.Remark = nil
    self.Level = nil
    self.ProfID = 0
    self.LevelDesc = ""
    self.IsFriend = false
    self.IsFriendBeforeBlack = nil -- 拉黑之前是否是好友
    self.Signature = ""
    self.PlayStyleIDs = nil 
    self.LoginTime = 0
    self.LogoutTime = 0
    
    self.IsOnline = false 
    self.OnlineStatusIcon = "" -- 在线状态
    self.IsSortPriority = false -- 是否排序优先

	self.CurWorldID = 0 -- 玩家当前所在服务器ID

    self.LaunchType = 0
end

function FriendEntryVM:IsEqualVM(Value)
    return Value ~= nil and Value.RoleID == self.RoleID
end

function FriendEntryVM:UpdateVM(Value)
    self.GroupID = Value.GroupID
    self.RoleID = Value.RoleID
    self.Remark = Value.Remark
    self.Time = Value.Time
    self.IsFriend = Value.IsFriend
    self.IsFriendBeforeBlack = Value.IsFriendBeforeBlack
    self.IsSortPriority = false 

    RoleInfoMgr:QueryRoleSimple(self.RoleID, function(_, RoleVM)
        self:UpdateRoleInfo(RoleVM)
    end, nil, true)
end

--- 更新角色信息 
---@param Value RoleVM @角色数据
function FriendEntryVM:UpdateRoleInfo(Value)
    self.RoleID = Value.RoleID
    self.MapResName = Value.MapResName
    self.Name = Value.Name
    self.ProfID = Value.Prof 
    self.LoginTime = Value.LoginTime

    local IsOnline = Value.IsOnline
    self.IsOnline = IsOnline

    local LogoutTime = Value.LogoutTime
    self.LogoutTime = LogoutTime

    local Level = Value.Level
    self.Level = Level 
    self.LevelDesc = tostring(Level or 0)

    if IsOnline then
        local CurWorldID = Value.CurWorldID
        if CurWorldID and CurWorldID > 0 and CurWorldID ~= _G.PWorldMgr:GetCurrWorldID() then
            self.StateType = StateType.DiffServer
            self.State =  _G.LoginMgr:GetMapleNodeName(CurWorldID) 
        else
            self.StateType = StateType.None
            self.State = self.MapResName
        end

    else
        self.StateType = StateType.None
        self.State = _G.TimeUtil.GetOfflineDesc(LogoutTime)
    end

    -- 在线状态
    self.OnlineStatusIcon = Value.OnlineStatusIcon

    local Signature = ""
    local PlayStyleIDs = nil 
    local PersonSetInfos = Value.PersonSetInfos
    if PersonSetInfos then
        -- 签名
        Signature = PersonSetInfos[ClientSetupKey.PersonalSignature] or ""

        -- 游戏风格
        local StrSet = PersonSetInfos[ClientSetupKey.Playstyle]
        if not string.isnilorempty(StrSet) then
            PlayStyleIDs = Json.decode(StrSet)
        end
    end

    self.Signature = Signature
    self.PlayStyleIDs = PlayStyleIDs

    self.LaunchType = Value.LaunchType
end

--- 根据RoleID自动补全其他的信息
---@param RoleID any
function FriendEntryVM:UpdateByRoleID(RoleID)
    self.RoleID = RoleID

    RoleInfoMgr:QueryRoleSimple(self.RoleID, function(_, RoleVM)
        self:UpdateRoleInfo(RoleVM)
    end, nil, true)
end

--- 更新数据（好友申请） 
---@param Value csfriends.ConsortPerson @好友申请信息 
function FriendEntryVM:UpdateByConsortInfo(Value)
    -- 同时兼容ReqTime & Time
    if self.ReqTime ~= nil then -- ConsortPerson
        self.ReqTime = Value.ReqTime
    end

    if self.Time ~= nil then -- ConsortNtf
        self.ReqTime = Value.Time
    end

    self.Remark = Value.Remark

    self:UpdateByRoleID(Value.RoleID)
end

function FriendEntryVM:UpdateReqTime(NewTime)
    self.Time = NewTime
end

function FriendEntryVM:UpdateRemark(NewRemark)
    self.Remark = NewRemark
end

function FriendEntryVM:SetSortPriority(b)
    self.IsSortPriority = b == true
end

return FriendEntryVM
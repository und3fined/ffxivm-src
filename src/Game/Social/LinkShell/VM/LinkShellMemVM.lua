---@author: wallencai(蔡文超)
---Date: 2022-10-9

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local CommPlayerDefine = require("Game/Common/Player/CommPlayerDefine")

local LINKSHELL_IDENTIFY = LinkShellDefine.LINKSHELL_IDENTIFY
local StateType = CommPlayerDefine.StateType

---@field RoleID integer @角色ID
local LinkShellMemVM = LuaClass(UIViewModel)

function LinkShellMemVM:Ctor()
    self.RoleID = 0
    self.Time = 0
    self.Name = ''
    self.MapResName = ''
	self.OnlineStatusIcon = ""
    self.ReqRemark = nil
    self.State = ''
    self.StateType = StateType.None 
    self.IsCreator = false
    self.IsAdmin = false
    self.Identify = LINKSHELL_IDENTIFY.IDENTIFY_UNKNOWN
    self.IdentifyIcon = nil
    self.IsOnline = false 
    self.LoginTime = 0
    self.LogoutTime = 0
    self.ProfID = 0
    self.LevelDesc = ""
end

---更新数据（通讯贝成员）
---@param Value cslinkshells.LinkShellMember @服务器信息 
function LinkShellMemVM:UpdateByLinkShellMember(Value)
    self.RoleID = Value.RoleID
    self.Time = Value.JoinTime

    self:SetIdentiry(Value.Identify)
end

---更新数据（通讯贝申请加入成员）
---@param Value cslinkshells.ReqJoin @服务器信息 
function LinkShellMemVM:UpdateByReqJoin(Value)
    self.RoleID = Value.RoleID
    self.ReqTime = Value.Time
    self.ReqRemark = Value.Remark
end

function LinkShellMemVM:UpdateRoleInfo(Value)
    self.Name = Value.Name
    self.MapResName = Value.MapResName
    self.LoginTime = Value.LoginTime

    local IsOnline = Value.IsOnline
    self.IsOnline = IsOnline

    local LogoutTime = Value.LogoutTime
    self.LogoutTime = LogoutTime

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

	self.OnlineStatusIcon = Value.OnlineStatusIcon 

    self.ProfID = Value.Prof 
    self.LevelDesc = tostring(Value.Level or 0)
end

function LinkShellMemVM:SetIdentiry( Identify )
    self.Identify = Identify -- 身份
    self.IsCreator = Identify == LINKSHELL_IDENTIFY.CREATOR
    self.IsAdmin = self.IsCreator or Identify == LINKSHELL_IDENTIFY.MANAGER
    self.IdentifyIcon = LinkShellDefine.IdentifyIconConfig[self.Identify]
end

--- 设置返回的索引：1
function LinkShellMemVM:AdapterOnGetWidgetIndex()
    return 1
end

return LinkShellMemVM
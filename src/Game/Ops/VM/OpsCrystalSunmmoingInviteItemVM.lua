local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local LSTR = _G.LSTR
local OpsCrystalSunmmoingInviteItemVM = LuaClass(UIViewModel)

function OpsCrystalSunmmoingInviteItemVM:Ctor()
    
end

function OpsCrystalSunmmoingInviteItemVM:UpdateVM(InviteItem)
    self.HasInit = false
    self.IsEmptyRole = false
  --  self.BgVisible = InviteItem.RealIndex % 2 == 0
    if InviteItem.IsEmptyRole then
        self.IsEmptyRole = true
        self.IconColor = "#FFFFFF23"
        self.BtnIcon = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Add_png.UI_Comm_Btn_Add_png'"
        self.HasInit = true
        self.ShareParams = InviteItem.ShareParams
        self.NodeType = InviteItem.NodeType
        self.ShareRewardStatus = InviteItem.ShareRewardStatus
        self.InviteCode = InviteItem.InviteCode
        self.ActivityID = InviteItem.ActivityID
        self.JobIcon = "Texture2D'/Game/UI/Texture/Ops/OpsActivity/UI_OpsCrystalSummoning_Icon_JobSilhouette.UI_OpsCrystalSummoning_Icon_JobSilhouette'"
    else
        self.IconColor = "#ffffff"
        self.RoleID = InviteItem.RoleID
        local ProfInfo = RoleInitCfg:FindCfgByKey(InviteItem.ProfID) or {}
        self.JobIcon = ProfInfo.ProfIcon or ""
        self:UpdateRoleInfo(InviteItem)
    end
end

function OpsCrystalSunmmoingInviteItemVM:UpdateRoleInfo(Value)
    self.StateIcon = Value.OnlineStatusIcon
    self.LevelText = Value.Level
    self.RoleName = Value.Name
    self.OpenID = Value.OpenID
    self.GetInviteListNodeID = Value.GetInviteListNodeID
    local IsOnline = Value.IsOnline
    local NowTime = TimeUtil.GetServerLogicTime()
    self.LogoutTime = Value.LogoutTime
    if IsOnline then
        self.StateText = LSTR(100091)
    else
        self.StateText = TimeUtil.GetOfflineDesc(Value.LogoutTime)
    end
   
    if NowTime - self.LogoutTime > 86400 * 30 then
        self.CanBreakBind = true
        self.BtnIcon = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Unbind_png.UI_Comm_Btn_Unbind_png'"
    else
        self.CanBreakBind = false
        if _G.FriendMgr:IsFriend(self.RoleID) then
            self.BtnIcon = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Chat_png.UI_Comm_Btn_Chat_png'"
        else
            self.BtnIcon = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_AddFriends_png.UI_Comm_Btn_AddFriends_png'"
        end
    end

    self.HasInit = true
end

function OpsCrystalSunmmoingInviteItemVM:IsEqualVM(Value)
	return true
end

return OpsCrystalSunmmoingInviteItemVM
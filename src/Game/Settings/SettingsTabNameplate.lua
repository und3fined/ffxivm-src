local TitleDefine = require("Game/Title/TitleDefine")
local ActorUIUtil = require("Utils/ActorUIUtil")
local ProtoRes = require("Protocol/ProtoRes")

local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local ActorUIType = ProtoRes.ActorUIType
local HUDMgr

local SettingsTabNameplate = {}

function SettingsTabNameplate:OnInit()

end

function SettingsTabNameplate:OnBegin()
    HUDMgr = _G.HUDMgr

end

function SettingsTabNameplate:OnEnd()

end

function SettingsTabNameplate:OnShutdown()

end

---------------------------------------------------------------------------------
--->>> 角色名牌设置 
function SettingsTabNameplate:SetShowSelfTitle(Value)
    HUDMgr:UpdateAllActorTitleVisibility()
end

function SettingsTabNameplate:SetShowTeamMemberTitle(Value)
    HUDMgr:UpdateAllActorTitleVisibility()
end

function SettingsTabNameplate:SetShowBigTeamMemberTitle(Value)
    HUDMgr:UpdateAllActorTitleVisibility()
end

function SettingsTabNameplate:SetShowFriendTitle(Value)
    HUDMgr:UpdateAllActorTitleVisibility()
end

function SettingsTabNameplate:SetShowStrangerTitle(Value)
    HUDMgr:UpdateAllActorTitleVisibility()
end

---------------------------------------------------------------------------------
--->>> 角色铭牌颜色

local function SetActorUIColor(IsSave, ActorUIType, SetupKey, ColorID)
    if IsSave then
        _G.ClientSetupMgr:SendSetReq(SetupKey, tostring(ColorID))
    else
        -- 由ClientSetup同步
        _G.EventMgr:SendEvent(_G.EventID.ActorUIColorConfigChanged, {ActorUIType = ActorUIType, ColorID = ColorID})
    end
end

---Major
function SettingsTabNameplate:SetActorUIMajorColorID(ColorID, IsSave)
    SetActorUIColor(IsSave, ActorUIType.ActorUITypeMajor, ClientSetupID.ActorUIColorMajor, ColorID)
end

function SettingsTabNameplate:GetActorUIMajorColorID()
    return ActorUIUtil.GetUIColorID(ActorUIType.ActorUITypeMajor)
end

---TeamMember
function SettingsTabNameplate:SetActorUITeamMemberColorID(ColorID, IsSave)
    SetActorUIColor(IsSave, ActorUIType.ActorUITypeTeamMember, ClientSetupID.ActorUIColorTeamMember, ColorID)
end

function SettingsTabNameplate:GetActorUITeamMemberColorID()
    return ActorUIUtil.GetUIColorID(ActorUIType.ActorUITypeTeamMember)
end

---Friend
function SettingsTabNameplate:SetActorUIFriendColorID(ColorID, IsSave)
    SetActorUIColor(IsSave, ActorUIType.ActorUITypeFriend, ClientSetupID.ActorUIColorFriend, ColorID)
end

function SettingsTabNameplate:GetActorUIFriendColorID()
    return ActorUIUtil.GetUIColorID(ActorUIType.ActorUITypeFriend)
end

---Player
function SettingsTabNameplate:SetActorUIPlayerColorID(ColorID, IsSave)
    SetActorUIColor(IsSave, ActorUIType.ActorUITypePlayer, ClientSetupID.ActorUIColorPlayer, ColorID)
end

function SettingsTabNameplate:GetActorUIPlayerColorID()
    return ActorUIUtil.GetUIColorID(ActorUIType.ActorUITypePlayer)
end

---------------------------------------------------------------------------------
--->>> 铭牌是否显示名字

function SettingsTabNameplate:SetHUDNameVisible(IsVisible, IsSave)
    _G.HUDMgr:UpdateAllActorNameVisibility()
end

return SettingsTabNameplate
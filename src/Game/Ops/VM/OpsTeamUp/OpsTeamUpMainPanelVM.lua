local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local OpsTeamUpTeamMembersItemVM = require("Game/Ops/VM/OpsTeamUp/ItemVM/OpsTeamUpTeamMembersItemVM")
local OpsTeamUpDefine = require("Game/Ops/OpsTeamUp/OpsTeamUpDefine")
local MajorUtil = require("Utils/MajorUtil")

---@class OpsTeamUpMainPanelVM : UIViewModel
local OpsTeamUpMainPanelVM = LuaClass(UIViewModel)

function OpsTeamUpMainPanelVM:Ctor()
    self.Title = nil
    self.SubTitle = nil
    self.Info = nil
    self.TeamTile = nil
    self.TeamMemberItemVMList = UIBindableList.New(OpsTeamUpTeamMembersItemVM)
    self.MaxTeamMemberNum = 0
end

function OpsTeamUpMainPanelVM:OnInit()
    self:InitCfgData()
end

function OpsTeamUpMainPanelVM:OnReset()

end

function OpsTeamUpMainPanelVM:OnBegin()

end

function OpsTeamUpMainPanelVM:OnEnd()

end

function OpsTeamUpMainPanelVM:OnShutdown()

end

function OpsTeamUpMainPanelVM:InitCfgData()
    local ActivityCfgData =  _G.OpsTeamUpMgr:GetActivityCfgData()
    if ActivityCfgData then
        self.Title = ActivityCfgData.Title
        self.SubTitle = ActivityCfgData.SubTitle
        self.Info = ActivityCfgData.Info
        self.ClassifyID = ActivityCfgData.ClassifyID
    end
    local TeamNodeCfgData =  _G.OpsTeamUpMgr:GetCfgDataByNodeID(OpsTeamUpDefine.MemberNodeID)
    if TeamNodeCfgData then
        self.TeamTile = TeamNodeCfgData.NodeTitle
        self.MaxTeamMemberNum = TeamNodeCfgData.Params[1]
    end 
end

function OpsTeamUpMainPanelVM:UpdataTeamMember(Member)
    ---队员数据处理
    local ActivityRedDotName = _G.OpsActivityMgr:GetRedDotName(self.ClassifyID, OpsTeamUpDefine.TeamUpActivityID)
    local MembersVMData = {}
    local SelfAvatarUrl = _G.LoginMgr:GetAvatarUrl()
    local SelfNickName = _G.LoginMgr:GetNickName()
    for Index, MemberData in ipairs(Member) do
        local MemberVMData = {}
        local RedDotName
        local IsNeedShowRedDot
        ---排除自己
        if  MemberData.HeaderUrl == SelfAvatarUrl and MemberData.NickName == SelfNickName then
            ---红点处理
            RedDotName = string.format("%s/%s%s", ActivityRedDotName, MemberData.NickName, Index)
            IsNeedShowRedDot = not _G.RedDotMgr:GetIsSaveDelRedDotByName(RedDotName)
            if IsNeedShowRedDot then
                _G.RedDotMgr:AddRedDotByName(RedDotName, nil, true)
                if self.ShowRedDotList == nil then
                    self.ShowRedDotList = {}
                end
                table.insert(self.ShowRedDotList, RedDotName)
            end
        end
        MemberVMData = {
            RedDotName = RedDotName,
            HeaderUrl =  MemberData.HeaderUrl,
            NickName  = MemberData.NickName
        }
        table.insert(MembersVMData, MemberVMData)
    end
    local MemberNum =  #MembersVMData
    ---如果没有队伍，不下发任何id,手动填充自己
    if MemberNum == 0 then
        local MemberVMData = {
            HeaderUrl =  SelfAvatarUrl,
            NickName  = SelfNickName
        }
        table.insert(MembersVMData, MemberVMData)
        MemberNum = 1
    end
    if MemberNum < self.MaxTeamMemberNum then
        for i = MemberNum, self.MaxTeamMemberNum  do
            local  MemberVMData = {
                RoleID = 0,
            }
            table.insert(MembersVMData, MemberVMData)
        end
    end
    self.TeamMemberItemVMList:UpdateByValues(MembersVMData)
end

---红点清理
function OpsTeamUpMainPanelVM:ClearMemberRedDot()
    if self.ShowRedDotList then
        for _, RedDotName in ipairs(self.ShowRedDotList) do
            _G.RedDotMgr:DelRedDotByName(RedDotName)
        end
        self.ShowRedDotList = {}
    end
end

--要返回当前类
return OpsTeamUpMainPanelVM
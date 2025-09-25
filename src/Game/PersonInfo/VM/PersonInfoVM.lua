---
--- Author: xingcaicao
--- DateTime: 2023-04-11 15:58:45
--- Description: 个人信息/个人名片 ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local GameStyleCfg = require("TableCfg/GameStyleCfg")
local PersonInfoProfVM = require("Game/PersonInfo/VM/PersonInfoProfVM")
local PersonInfoBtnVM = require("Game/PersonInfo/VM/PersonInfoBtnVM")
local PersonInfoGameStyleVM = require("Game/PersonInfo/VM/PersonInfoGameStyleVM")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local ProtoCS = require("Protocol/ProtoCS")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local TeamMgr = require("Game/Team/TeamMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local HUDActorVM = require("Game/HUD/HUDActorVM")
local ActorUtil = require("Utils/ActorUtil")

local ProtoCS = require("Protocol/ProtoCS")
local RoleGroupState = ProtoCS.RoleGroupState

local LSTR = _G.LSTR
local ClientSetupKey = ProtoCS.ClientSetupKey
local ProfClassType = ProtoCommon.class_type
local ProfSpecializationType = ProtoCommon.specialization_type
local MaxPerferredProfCount = PersonInfoDefine.MaxPerferredProfCount
local MaxGameStyleCount = PersonInfoDefine.MaxGameStyleCount
local PopupBtnType = PersonInfoDefine.PopupBtnType
local PortraitInitSaveRedDotID = PersonInfoDefine.RedDotIDs.PortraitInitTips

---@class PersonInfoVM : UIViewModel
local Class = LuaClass(UIViewModel)

---Ctor
function Class:Ctor()

end
	
function Class:OnInit()
    self:Reset()
end

function Class:OnBegin()
end

function Class:OnEnd()

end

function Class:OnShutdown()
    self:Reset()
end

function Class:Reset()
    self.DataRef = 0
    self.IsShowPortraitInitSaveTips = true 

    self.GemMap = nil
    
    self:Clear()
end

function Class:Clear()
    self.DataRef = self.DataRef - 1

    if self.DataRef <= 0 then
        self.DataRef = 0
        self.RoleID = nil
        self.RoleVM = nil
        self.IsMajor = false
        self.StrPerferredProfSet = nil
        self.StrGameStyleSet = "[]" 
        self.StrGameStyleMyTempSet = "[]" 
        self.ActiveHoursSet = 0
        self.ActiveHourTempSet = 0

        self.HourTogKey1 = false
        self.HourTogKey2 = false
        self.HourTogKey3 = false
        self.HourTogKey4 = false

        self.CurSelectedHeadPortraitID = nil
        self.HoursItemPressed = false
        self.SignContent = nil 
        self.IsPerferredProfEmpty = true 
        self.ArmySimpleInfo = nil --公会简要信息(group.GroupSimpleInfo)
        self.ArmyLeaderRoleID = nil
        self.OnEquipList = {} -- map<int32, common.Item> @穿戴的装备列表
        self.IsShowFacade = false


        self.CurGameStyleVMList = self:ResetBindableList(self.CurGameStyleVMList, PersonInfoGameStyleVM)
        self.MyTempGameStyleVMList = self:ResetBindableList(self.MyTempGameStyleVMList, PersonInfoGameStyleVM)
        self.AllGameStyleVMList = self:ResetBindableList(self.AllGameStyleVMList, PersonInfoGameStyleVM)
        self.CurPerferredProfVMList = self:ResetBindableList(self.CurPerferredProfVMList, PersonInfoProfVM)
        self.PerferredProfSetSlotVMList = self:ResetBindableList(self.PerferredProfSetSlotVMList, PersonInfoProfVM)
        self.TankProfVMList = self:ResetBindableList(self.TankProfVMList, PersonInfoProfVM) ---防护职业
        self.HealthProfVMList = self:ResetBindableList(self.HealthProfVMList, PersonInfoProfVM) ---治疗职业
        self.AttackProfVMList = self:ResetBindableList(self.AttackProfVMList, PersonInfoProfVM) ---进攻职业
        self.EarthMessengerProfVMList = self:ResetBindableList(self.EarthMessengerProfVMList, PersonInfoProfVM) ---大地使者
        self.CarpenterProfVMList = self:ResetBindableList(self.CarpenterProfVMList, PersonInfoProfVM) ---能工巧匠
        self.CanConfirmPerfProf = false
        self.PerfProfCnt = 0

        self.CombatProfVMList = self:ResetBindableList(self.CombatProfVMList, PersonInfoProfVM) -- 战斗职业
        self.ProduceProfVMList = self:ResetBindableList(self.ProduceProfVMList, PersonInfoProfVM) -- 生产职业(能工巧匠)
        self.GatherProfVMList = self:ResetBindableList(self.GatherProfVMList, PersonInfoProfVM) -- 采集职业(大地使者)

        self.ResidentBtnVMList = self:ResetBindableList(self.ResidentBtnVMList, PersonInfoBtnVM) -- 常驻功能按钮
        self.NonResidentBtnVMList = self:ResetBindableList(self.NonResidentBtnVMList, PersonInfoBtnVM) -- 非常驻功能按钮
        self.BtnVMList = self:ResetBindableList(self.BtnVMList, PersonInfoBtnVM) 

        self.CurTabIdx = nil

        self.bIsShowWeapon = true
        self.bIsHoldWeapon = true
        self.bIsShowHead = false
    end
end

function Class:SetRoleID( RoleID )
    self.RoleID = RoleID
	self.IsMajor = MajorUtil.IsMajorByRoleID(self.RoleID)
end

function Class:UpdateRoleInfo( RoleVM )
    self.RoleVM = RoleVM
    self:SetRoleID(RoleVM.RoleID)
    self.DataRef = self.DataRef + 1

    local PersonSetInfos = RoleVM.PersonSetInfos
    if nil == PersonSetInfos or table.empty(PersonSetInfos) then
        self:UpdatePerferredProf()
        self:UpdateGameStyleVMList()
        return
    end

    --偏好职业
    local Info = PersonSetInfos[ClientSetupKey.PerferredProf]
    self:UpdatePerferredProf(RoleVM.ProfSimpleDataList, Info)

    --活跃时段
    Info = PersonSetInfos[ClientSetupKey.ActiveHours]
    if Info then
		self:UpdateActiveHoursSet(Info)
    end

    --游戏风格
    Info = PersonSetInfos[ClientSetupKey.Playstyle]
	self:UpdateGameStyleVMList(Info)

    --个性签名
    Info = PersonSetInfos[ClientSetupKey.PersonalSignature]
    if Info then
		self:UpdateSignContent(Info)
    end
end

---设置穿戴的装备列表
---@param EquipList map<int32, common.Item> @装备列表
function Class:SetOnEquipList( EquipList )
	self.OnEquipList = EquipList or {}
end

-------------------------------------------------------------------------------------------------------
---公会

function Class:SetArmySimpleInfo(RoleID, Info)
    if nil == RoleID or RoleID ~= self.RoleID then 
        return
    end

    Info = Info or {}

    self.ArmySimpleInfo = Info
    self.ArmyLeaderRoleID = (Info.Leader or {}).RoleID
end

-------------------------------------------------------------------------------------------------------
---职业偏好

function Class:TryInitPerferredProfSetInfo( )
    self:TryUpdatePerferredProf()
    if nil == self.RoleVM or self.PerferredProfSetSlotVMList:Length() > 0 then
        return
    end

    self:UpdatePerferredProf(self.RoleVM.ProfSimpleDataList)
end

function Class:MakePerferredProfData( Profs, StrSet )
    local Data = {} 
    local SetData = {}

    if not Profs then
        return Data, SetData
    end

    local PerferredProfIDList = {}
    if not string.isnilorempty(StrSet) then
        PerferredProfIDList = Json.decode(StrSet) or {}
    end

    --Key: ProfID, Value: Common.ProfDataSimple
    local MapProfData = table.indexValue("ProfID", Profs or {}) or {}

    for i = 1, MaxPerferredProfCount do
        local Info = { Empty = true}
        local ProfID = PerferredProfIDList[i]
        if ProfID then
            local ProfData = MapProfData[ProfID]
            if ProfData then
                Info.ProfID = ProfData.ProfID
                Info.Level = ProfData.Level
                Info.Icon = RoleInitCfg:FindRoleInitProfIconSimple(ProfID)
                Info.Empty = false
                Info.RoleVM = self.RoleVM
                table.insert(Data, Info)
            end
        end

        Info.IsJudgeShowSelectedIcon = false

        table.insert(SetData, Info)
    end

    return Data, SetData
end

function Class:TryUpdatePerferredProf()
    if self.Profs then
        self:UpdatePerferredProf( self.Profs, self.StrSet )
    end
end

function Class:UpdatePerferredProf( Profs, StrSet )
    self.Profs = Profs
    self.StrSet = StrSet
    
    local Data, SetData = self:MakePerferredProfData(Profs, StrSet)
    self.CurProfCnt = #Data
    self.ProfPerfData = Data

    local Cnt = #Data
    if Cnt < MaxPerferredProfCount then
        for i = Cnt, MaxPerferredProfCount do
            table.insert(Data, {Empty = true})
        end
    end

    self.CurPerferredProfVMList:UpdateByValues(Data) 
    self.PerferredProfSetSlotVMList:UpdateByValues(SetData) 

    self.CanConfirmPerfProf =  Cnt > 0
    self.PerfProfCnt = Cnt
    self.IsPerferredProfEmpty = table.empty(Data) 
    self.StrPerferredProfSet = StrSet 
end

function Class:UpdateAllClassProfVMList()
    local RoleVM = self.RoleVM
    if nil == RoleVM then
        return
    end

    --Key: ProfID, Value: Common.ProfData
    local MapProfData = table.indexValue("ProfID", RoleVM.ProfSimpleDataList or {})

    --防护职业
    self:UpdateProfVMList(ProfClassType.CLASS_TYPE_TANK, self.TankProfVMList, MapProfData)

    --治疗职业
    self:UpdateProfVMList(ProfClassType.CLASS_TYPE_HEALTH, self.HealthProfVMList, MapProfData)

    --大地使者
    self:UpdateProfVMList(ProfClassType.CLASS_TYPE_EARTHMESSENGER, self.EarthMessengerProfVMList, MapProfData)

    --能工巧匠
    self:UpdateProfVMList(ProfClassType.CLASS_TYPE_CARPENTER, self.CarpenterProfVMList, MapProfData)

    --进攻职业(近战 + 远程 + 魔法)
    self:UpdateAttackProfVMList(MapProfData)
end

function Class:UpdateProfVMList( ProfClass, ProfVMList, MapProfData)
    if nil == ProfClass or nil == ProfVMList then
        return
    end

    local CfgList = RoleInitCfg:GetOpenProfCfgListByClass(ProfClass)
    if nil == CfgList then
        ProfVMList:Clear()
        return
    end

    ProfVMList:UpdateByValues(self:GetProfVMListData(CfgList, MapProfData)) 
end

---更新进攻职业VMList(近战 + 远程 + 魔法)
function Class:UpdateAttackProfVMList( MapProfData )
    local CfgList = RoleInitCfg:GetAttackProfCfgList()
    if nil == CfgList then
        self.AttackProfVMList:Clear()
        return
    end

    self.AttackProfVMList:UpdateByValues(self:GetProfVMListData(CfgList, MapProfData)) 
end

function Class:GetProfVMListData( CfgList, MapProfData, MaxNum )
    local Ret = {}
    local N = 1

    local Base2Adv = {}
    local Adv2Base = {}

    for _, v in pairs(CfgList) do
        if v.AdvancedProf ~= nil and v.AdvancedProf > 0 then
            Base2Adv[v.Prof] = v.AdvancedProf
            Adv2Base[v.AdvancedProf] = v.Prof
        end
    end

    for _, v in pairs(CfgList) do
        local ProfID = v.Prof
        if ProfID then
            local Info = { 
                ProfID = ProfID,
                Icon   = v.SimpleIcon,
                Name   = v.ProfName,
                RoleVM = self.RoleVM --- 用于获取副本通关数据
            }

            local ProfData = MapProfData[ProfID]
            if ProfData then
                Info.Level = ProfData.Level
                Info.IsJudgeShowSelectedIcon = true
            end

            if nil == MaxNum or N < MaxNum then
                if Base2Adv[ProfID] then
                    local AdvProfID = Base2Adv[ProfID]
                    local AdvProfData = MapProfData[AdvProfID]
                    if not AdvProfData or AdvProfData.Level <= 0 then
                        table.insert(Ret, Info)
                    end
                elseif Adv2Base[ProfID] then
                    if ProfData and ProfData.Level > 0 then
                        table.insert(Ret, Info)
                    end
                else
                    table.insert(Ret, Info)
                end
            end

            N = N + 1
        end
    end

    return Ret
end

function Class:GetPerferredProf( ProfID )
    local Idx = self.CurPerferredProfVMList:GetItemIndexByPredicate(function(e) return e.ProfID == ProfID end)
    if Idx then
        return self.CurPerferredProfVMList:Get(Idx)
    end
end

function Class:AddPerferredProf( ProfID )

    if nil == ProfID then
        return
    end

    if self.PerferredProfSetSlotVMList:GetItemIndexByPredicate(function(e) return e.ProfID == ProfID end) then
        return
    end

    local CurProfCnt = 0

    for _, Item in pairs(self.PerferredProfSetSlotVMList:GetItems()) do
        if not Item.IsEmpty then
            CurProfCnt = CurProfCnt + 1
        end
    end

    if CurProfCnt >= MaxPerferredProfCount then
        MsgTipsUtil.ShowTips(LSTR(620005))
        return
    end

    local Data = {}
    
    local Items = self.PerferredProfSetSlotVMList:GetItems()

    for _, v in ipairs(Items) do
        table.insert(Data, v.ProfID)
    end

    table.insert(Data, ProfID)

    local Str = Json.encode(Data)

    local Tb, SetData = self:MakePerferredProfData(self.Profs, Str)
    self.PerferredProfSetSlotVMList:UpdateByValues(SetData) 
    self.CanConfirmPerfProf =  #Tb > 0
    self.PerfProfCnt = #Tb

    self:SetEditProfStr(Str)
    self.StrPerferredProfSet = Str

    -- if Str then 
    --     _G.ClientSetupMgr:SetPerferredProf(Str)
    -- end
end

function Class:SetEditProfStr(inStr)
    self.EditProfStr = inStr
end

function Class:DeletePerferredProf( ProfID )
    if nil == ProfID then
        return
    end

    local Data = {}
    local HaveChanged = false
    local Items = self.PerferredProfSetSlotVMList:GetItems()

    for _, v in ipairs(Items) do
        if v.ProfID ~= ProfID then
            table.insert(Data, v.ProfID)
        else
            HaveChanged = true
        end
    end

    if not HaveChanged then
        return
    end

    local Str = Json.encode(Data)

    local Tb, SetData = self:MakePerferredProfData(self.Profs, Str)
    self.PerferredProfSetSlotVMList:UpdateByValues(SetData) 
    self.CanConfirmPerfProf =  #Tb > 0
    self.PerfProfCnt = #Tb
    self:SetEditProfStr(Str)
    self.StrPerferredProfSet = Str

    -- if Str then 
    --     _G.ClientSetupMgr:SetPerferredProf(Str)
    -- end
end

function Class:ResetPerferredProf( Shut )
    _G.ClientSetupMgr:SetPerferredProf(Shut)
end

function Class:UpdateSimpleViewProfVMList()
    local RoleVM = self.RoleVM
    if nil == RoleVM or nil == RoleVM.ProfSimpleDataList then
        return
    end

    --Key: ProfID, Value: Common.ProfDataSimple
    local MapProfData = table.indexValue("ProfID", RoleVM.ProfSimpleDataList or {})

    --战斗职业
    local ProfVMList = self.CombatProfVMList
    if ProfVMList:Length() <= 0 then
        local CfgList = RoleInitCfg:GetOpenProfCfgListBySpecialization(ProfSpecializationType.SPECIALIZATION_TYPE_COMBAT)
        if CfgList then
            ProfVMList:UpdateByValues(self:GetProfVMListData(CfgList, MapProfData, 10)) 
        end
    end

    --生产职业（能工巧匠）
    ProfVMList = self.ProduceProfVMList
    if ProfVMList:Length() <= 0 then
        local CfgList = RoleInitCfg:GetOpenProfCfgListByClass(ProfClassType.CLASS_TYPE_CARPENTER)
        if CfgList then
            ProfVMList:UpdateByValues(self:GetProfVMListData(CfgList, MapProfData, 10)) 
        end
    end

    --采集职业（大地使者）
    ProfVMList = self.GatherProfVMList
    if ProfVMList:Length() <= 0 then
        local CfgList = RoleInitCfg:GetOpenProfCfgListByClass(ProfClassType.CLASS_TYPE_EARTHMESSENGER)
        if CfgList then
            ProfVMList:UpdateByValues(self:GetProfVMListData(CfgList, MapProfData, 10)) 
        end
    end
end

function Class:SimpleViewOnClickButtonFunction(BtnVM)
    if nil == BtnVM then
        return
    end

    local Type = BtnVM.ID
    if nil == Type then
        return
    end

    local RoleID = self.RoleID
    if nil == RoleID then
        return
    end

    local CBFunc = function()
        -- UIViewMgr:HideView(UIViewID.PersonInfoSimplePanel)
    end

    local IsHide = false
    local ReportType = nil
    local DataReportType = PersonInfoDefine.DataReportType

    local IsAdd = BtnVM.IsAdd
	if Type == PopupBtnType.Chat then -- 聊天
        UIViewMgr:HideView(UIViewID.PersonInfoSimplePanel)
		_G.ChatMgr:GoToPlayerChatView(RoleID)
    elseif Type == PopupBtnType.ArmyKick then
        _G.ArmyMgr:KickMember(RoleID)
        ReportType = DataReportType.ClickAmryRemove
    elseif Type == PopupBtnType.ArmyTransCap then
        _G.ArmyMgr:ArmyTransferLeader(RoleID)
        ReportType = DataReportType.ClickAmryTransCap
    elseif Type == PopupBtnType.TeamInvite then
        TeamMgr:InviteJoinTeam(RoleID)
        ReportType = DataReportType.ClickTeamInvite
	elseif Type == PopupBtnType.Friend then -- 加为好友/删除好友
        if IsAdd then
            FriendMgr:AddFriend(RoleID, FriendDefine.AddSource.PersonCard)
            ReportType = DataReportType.ClickAddFriend
        else
            FriendMgr:DeleteFriend(RoleID, (self.RoleVM or {}).Name, function() CBFunc() end)
            ReportType = DataReportType.ClickRemFriend
        end

	elseif Type == PopupBtnType.LinkShellInvite then -- 通讯贝邀请
        _G.LinkShellMgr:InviteJoin(RoleID)
        ReportType = DataReportType.ClickShallInvite

    elseif Type == PopupBtnType.ArmyInvite then -- 公会邀请
        if IsAdd then
            _G.ArmyMgr:SendArmyInviteMsgByPlayer(RoleID)
            ReportType = DataReportType.ClickAmryInvite
        else
            _G.ArmyMgr:OpenArmyQueryListByID(self.ArmySimpleInfo.ID)
            IsHide = true
        end

    elseif Type == PopupBtnType.NewbieChannel then -- 邀请加入新人频道/移除新人频道
        if IsAdd then
            _G.NewbieMgr:InviteJoinNewbieChannelReq(RoleID)
            ReportType = DataReportType.ClickChannelInvite
        ---屏蔽掉移除新人频道
        -- else
        --     _G.NewbieMgr:EvictNewbieChannel(self.RoleID)
        --     ReportType = DataReportType.ClickChannelRemove

        end
    elseif Type == PopupBtnType.BlackList then -- 加入黑名单/移出黑名单
        if IsAdd then
            FriendMgr:AddBlackList(RoleID, (self.RoleVM or {}).Name, function() CBFunc() end)
            ReportType = DataReportType.ClickAddBlackList
        else
            local IsFriendBeforeBlack = false
            local BlackInfo = FriendMgr:GetBlackPlayerInfo(RoleID)
            if BlackInfo then
                IsFriendBeforeBlack = BlackInfo.IsFriendBeforeBlack == true
            end
            ReportType = DataReportType.ClickRemBlackList
            FriendMgr:RemoveBlackList(self.RoleID, IsFriendBeforeBlack, function() CBFunc() end)
        end
    elseif Type == PopupBtnType.Report then -- 举  报
        --UIViewMgr:ShowView(UIViewID.ReportPlayerPanel, self.RoleVM)

        local Params = { ReporteeRoleID = (self.RoleVM or {}).RoleID }

        local PersonSetInfos = self.RoleVM.PersonSetInfos
        local Sign = ""
        if PersonSetInfos then
            -- 签名
            Sign = PersonSetInfos[ClientSetupKey.PersonalSignature]
        end
        local EntityID = ActorUtil.GetEntityIDByRoleID(self.RoleVM.RoleID)
        local BuddyEntityID = _G.BuddyMgr:GetBuddyByMaster(EntityID)
        local BuddyName = BuddyEntityID == nil and "" or HUDActorVM.GetActorName(BuddyEntityID, true)
        Params.ReportContentList = {
            Signature = Sign,
            PetID = BuddyEntityID,
            PetName = BuddyName,
        }
        _G.ReportMgr:OpenViewByPersonalInfo(Params)
        ReportType = DataReportType.ClickReport

    elseif Type == PopupBtnType.ArmySign then -- 签 署
        --UIViewMgr:ShowView(UIViewID.ReportPlayerPanel, self.RoleVM)
        _G.ArmyMgr:SendGroupSignInvite(RoleID)
    --- obsoleted function

    -- elseif Type == PopupBtnType.TransferCaptain then -- 转让队长
    --     if TeamMgr:CheckCanOpTeam(true) then
    --         TeamMgr:SendSetCaptainReq(TeamMgr.TeamID, RoleID)
    --     end

    -- elseif Type == PopupBtnType.RemoveTeam then -- 移出小队
    --     if TeamMgr:CheckCanOpTeam(true) then
    --         TeamMgr:SendKickMemberReq(TeamMgr.TeamID, RoleID)
    --     end

    -- elseif Type == PopupBtnType.DestroyTeam then -- 解散队伍
    --     if TeamMgr:CheckCanOpTeam(true) then
    --         self:DestroyTeam(RoleID, function() CBFunc() end)
    --         return
    --     end

    -- elseif Type == PopupBtnType.LeaveTeam then -- 退出队伍
    --     if TeamMgr:CheckCanOpTeam(true) then
    --         self:LeaveTeam(RoleID, function() CBFunc() end)
    --         return
    --     end

    elseif Type == PopupBtnType.RideInvite then -- 邀请骑乘/申请骑乘
        _G.MountMgr:SendMountApplyOn(RoleID)
        ReportType = DataReportType.ClickRideInvite

    elseif Type == PopupBtnType.MeetTrade then -- 面对面交易
        _G.MeetTradeMgr:SendMeetTradeRequest(RoleID)
	end

    if IsHide then
        UIViewMgr:HideView(UIViewID.PersonInfoSimplePanel)
    end

    if ReportType then
	    _G.PersonInfoMgr:ReportSystemFlowData(ReportType)
    end
end

function Class:DestroyTeam( RoleID, CBFunc )
    local strContent = LSTR(620030)
    MsgBoxUtil.ShowMsgBoxThreeOp(nil, LSTR(620038), strContent,
        function()
            TeamMgr:SendDestroyTeamReq(TeamMgr.TeamID)
            CBFunc()
        end, 
        function()
            TeamMgr:SendLeaveTeamReq(RoleID, TeamMgr.TeamID, ProtoCS.Team.Team.LEAVE_TEAM_REASON.LEAVE_TEAM_SELF)
            CBFunc()
        end, 
        nil, LSTR(620010), LSTR(620037), LSTR(620035))
end

function Class:LeaveTeam(RoleID, CBFunc)
    if TeamMgr:IsCaptain() then
        if _G.TeamRecruitVM.IsRecruiting then
            MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(620017), LSTR(620028), 
                function()
                    TeamMgr:SendDestroyTeamReq(TeamMgr.TeamID)
                    CBFunc()
                end, 
                nil, LSTR(620010), LSTR(620035))

        else
            self:DestroyTeam(RoleID, function() CBFunc() end)
        end

    else
        local strContent = LSTR(620030)
        MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(620038), strContent, 
            function()
                TeamMgr:SendLeaveTeamReq(RoleID, TeamMgr.TeamID, ProtoCS.Team.Team.LEAVE_TEAM_REASON.LEAVE_TEAM_SELF)
                CBFunc()
            end, 
            nil, LSTR(620010), LSTR(620027))
    end
end

-------------------------------------------------------------------------------------------------------
---游戏风格

function Class:UpdateGameStyleVMList( StrSet )
    local StyleIDList = {}
    if not string.isnilorempty(StrSet) then
        StyleIDList = Json.decode(StrSet) or {}
    end

    local Data = {}

    for k, v in ipairs(StyleIDList) do
		if k > MaxGameStyleCount then
			break
		end

        local Info = table.clone(GameStyleCfg:GetGameStyleCfg(v) or {})
        table.insert(Data, Info)
    end

    local Cnt = #Data

    for i = Cnt + 1, MaxGameStyleCount do
        table.insert(Data, {})
    end

    self.CurGameStyleVMList:UpdateByValues(Data)

    self.StrGameStyleSet = Json.encode(StyleIDList) 
end

function Class:UpdateMyTempGameStyle( ID, IsAdd )
    if nil == ID or nil == self.StrGameStyleMyTempSet then
        return true
    end

    local IDList = {}
    if self.StrGameStyleMyTempSet == "{}" then
        self.StrGameStyleMyTempSet = "[]"
    end

    if #self.StrGameStyleMyTempSet >= 2 then
        IDList = Json.decode(self.StrGameStyleMyTempSet)
        if nil == IDList then
            return true
        end
    end

    local Num = #IDList
    if IsAdd then
        if not table.contain(IDList, ID) then
            if Num >= MaxGameStyleCount then
                MsgTipsUtil.ShowTips(LSTR(620024))
                return false
            end

            table.insert(IDList, ID)
        end

    else
        if table.contain(IDList, ID) then
            table.remove_item(IDList, ID)
        end
    end

    if Num == #IDList then
        return true 
    end

    self.StrGameStyleMyTempSet = Json.encode(IDList, { empty_table_as_array = true })
    return true
end

function Class:SaveGameStyle()
    if string.isnilorempty(self.StrGameStyleMyTempSet) or self.StrGameStyleMyTempSet == self.StrGameStyleSet then
        return
    end

	_G.ClientSetupMgr:SetGameStyle(self.StrGameStyleMyTempSet)
end

-------------------------------------------------------------------------------------------------------
---活跃时间段

function Class:UpdateActiveHoursSet( StrSet )
    local Value = tonumber(StrSet)
    if nil == Value then
        return
    end

    self.ActiveHoursSet = Value

    self:UpdateHourTogKey(self.ActiveHoursSet)
end

function Class:UpdateActiveHoursTempSetGroup( Group, IsAdd )
    local Start = (Group - 1) * 12 + 1
    local End = Group * 12

    for i = Start, End do
        self:UpdateActiveHoursTempSet(i, IsAdd)
    end
end

function Class:UpdateActiveHoursTempSet( ID, IsAdd, bIgCheckAll )
    if nil == ID or nil == self.ActiveHourTempSet then
        return
    end
    
    local TempSet = self.ActiveHourTempSet
    if IsAdd then
        if (TempSet & (1 << ID)) == 0 then
            self.ActiveHourTempSet = TempSet + (1 << ID)
        end

    else
        if (TempSet & (1 << ID)) ~= 0 then
            self.ActiveHourTempSet = TempSet - (1 << ID)
        end
    end

    self:UpdateHourTogKey(self.ActiveHourTempSet)
end

function Class:UpdateHourTogKey(Set)
    local Start, End, Rlt
    for Idx = 1, 4 do
        Start = (Idx - 1) * 12 + 1
        End = Idx * 12
        Rlt = true
        for J = Start, End do
            local Flag = (Set >> J) & 1
            Rlt = Rlt and (Flag == 1)
        end

        self["HourTogKey" .. Idx] = Rlt
    end
end

-------------------------------------------------------------------------------------------------------
---个人签名

function Class:UpdateSignContent( StrSet )
    -- StrSet = string.isnilorempty(StrSet) and "[]" or StrSet 
    -- self.SignContent = (Json.decode(StrSet) or {}).Value
    self.SignContent = StrSet
end

function Class:SaveSignContent( Text )
    if nil == Text then
        return
    end

    -- Text = ""

    -- for i=1, 60 do
    --     Text = Text .. "a"
    -- end

    local Str = Text --Json.encode({ Value = Text })
    if Str then 
        _G.ClientSetupMgr:SetSignContent(Str)
    end
end

-------------------------------------------------------------------------------------------------------
--- 小红点

function Class:UpdatePortraitInitSaveTipsRedDot(b)
    self.IsShowPortraitInitSaveTips = b 
    RedDotMgr:SetRedDotNodeValueByID(PortraitInitSaveRedDotID, b and 1 or 0, false)
end

function Class:ClearPortraitInitSaveTips()
    if not self.IsMajor or not self.IsShowPortraitInitSaveTips then
        return
    end

    _G.ClientSetupMgr:SendSetReq(ClientSetupID.ShownPortraitInitSaveTips, "1")
end

return Class
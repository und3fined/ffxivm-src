local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local OpsCommTabChildItemVM = require("Game/Ops/VM/OpsCommTabChildItemVM")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local SaveKey = require("Define/SaveKey")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")
local OpsActivityMgr
local RedDotMgr
local USaveMgr
local QuestCfg = require("TableCfg/QuestCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local LSTR


---@class OpsSeasonActivityMgr : MgrBase
local OpsSeasonActivityMgr = LuaClass(MgrBase)

---OnInit
function OpsSeasonActivityMgr:OnInit()
   
end

---OnBegin
function OpsSeasonActivityMgr:OnBegin()
    OpsActivityMgr = _G.OpsActivityMgr
    RedDotMgr = _G.RedDotMgr
    USaveMgr = _G.UE.USaveMgr
    LSTR = _G.LSTR
    OpsSeasonActivityDefine.RedDotName = RedDotMgr:GetRedDotNameByID(OpsSeasonActivityDefine.RedDotID) or ""

    self:NodeReadSaveKeyData()

    self.OpenHalloweenAnimation = _G.UE.USaveMgr.GetInt(SaveKey.OpenHalloweenAnimation, 0, true) or 0
    self.OpenCeremonyAnimation = _G.UE.USaveMgr.GetInt(SaveKey.OpenLightCeremony, 0, true) or 0
end

function OpsSeasonActivityMgr:OnEnd()
end

function OpsSeasonActivityMgr:OnShutdown()
end

function OpsSeasonActivityMgr:OnRegisterNetMsg()
    
end

function OpsSeasonActivityMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateActivityRedDot)
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateActivityRedDot)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.UpdateActivityRedDot)
    self:RegisterGameEvent(EventID.InitQuest, self.UpdateActivityRedDot)
    self:RegisterGameEvent(EventID.FatPenguinBlessUpdatRedDot, self.UpdateFatPenguinBlessRedDot)
end

function OpsSeasonActivityMgr:GetSeasonActivity()
	if OpsActivityMgr.SeasonActivitys == nil then
		return
	end

    local SeasonActivityTab =  OpsActivityMgr.SeasonActivitys
	for i = 1, #SeasonActivityTab do
		local Activity = SeasonActivityTab[i].Activity
		if (Activity.FatherID == nil or Activity.FatherID == 0) and not string.isnilorempty(Activity.BPName) then
			return Activity
		end
	end
end

function OpsSeasonActivityMgr:SendQuerySeasonActivitys()
    if OpsActivityMgr.SeasonActivitys == nil then
		return
	end

    local ListByIDs = {}
    local SeasonActivityTab =  OpsActivityMgr.SeasonActivitys or {}
	for i = 1, #SeasonActivityTab do
		local Activity = SeasonActivityTab[i].Activity
        table.insert(ListByIDs, Activity.ActivityID)
	end
    OpsActivityMgr:SendQueryActivityListByID(ListByIDs)

end

function OpsSeasonActivityMgr:GetNewVersionContentActivity()
    if OpsActivityMgr.SeasonActivitys == nil then
		return
	end

    local SeasonActivityTab =  OpsActivityMgr.SeasonActivitys
	for i = 1, #SeasonActivityTab do
		local Activity = SeasonActivityTab[i].Activity
        if Activity.BPName == "Ops/OpsVersionNotice/OpsVersionNoticeContentPanel_UIBP" then
           return Activity
        end
	end
end

function OpsSeasonActivityMgr:GetChildrenActivityList(FatherID)
    local ChildrenActivity = {}
    if OpsActivityMgr.SeasonActivitys == nil then
		return ChildrenActivity
	end

    local SeasonActivityTab =  OpsActivityMgr.SeasonActivitys
	for i = 1, #SeasonActivityTab do
		local Activity = SeasonActivityTab[i].Activity
		if Activity.FatherID == FatherID then
			table.insert(ChildrenActivity, Activity)
		end
	end

    table.sort(ChildrenActivity, function(l, r) return l.ActivityID < r.ActivityID end)

    return ChildrenActivity
end

function OpsSeasonActivityMgr:ShowSeasonActivityUI()
    local Activity = self:GetSeasonActivity()
    if Activity == nil then
        return
    end

    local OpsCommTabChildItemVM = OpsCommTabChildItemVM.New()
    local Detail = OpsActivityMgr.ActivityNodeMap[Activity.ActivityID] or {}
    OpsCommTabChildItemVM:UpdateVM({Activity = Activity, Detail = Detail})
    _G.UIViewMgr:ShowView(_G.UIViewID.OpsSeasonActivityPanel, {ActivityData = OpsCommTabChildItemVM})
    ---季节活动按钮埋点点击上报
    DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityOpen), "1", Activity.ActivityID)
end

function OpsSeasonActivityMgr:HasOpenSeasonAni()
    local Activity = self:GetSeasonActivity()
    if Activity == nil then
        return false
    end

    if Activity.Title == LSTR(1560025) and self.OpenHalloweenAnimation == 0 then
        return true
    elseif Activity.ActivityID == OpsCeremonyDefine.ActivityID and self.OpenCeremonyAnimation == 0 then
        return true
    end

    return false
end

function OpsSeasonActivityMgr:IsShowNewContent()
    local Activity = self:GetSeasonActivity()
    if Activity == nil then
        return false
    end
    if Activity.BPName == "Ops/OpsVersionNotice/OpsVersionNoticeContentPanel_UIBP" then
        local LastVersion = _G.UE.USaveMgr.GetString(SaveKey.LastVersion, "", false)
        local CurrentVersion = _G.UE.UVersionMgr.GetGameVersion()
        if LastVersion ~= CurrentVersion then
            _G.UE.USaveMgr.SetString(SaveKey.LastVersion, CurrentVersion, false)
            return true
        else
            return false
        end
    end

    return false
end

function OpsSeasonActivityMgr:PlayOpenSeasonAni(CallBack)
    local Activity = self:GetSeasonActivity()
    if Activity == nil then
        return
    end

    if Activity.Title == LSTR(1560025) and self.OpenHalloweenAnimation == 0 then
        self:PlayHalloweenAni(CallBack)
        self.OpenHalloweenAnimation = 1
        USaveMgr.SetInt(SaveKey.OpenHalloweenAnimation, self.OpenHalloweenAnimation, true)
        return
    --- 光之盛典不用标题，防止文本表和活动表翻译大小写不一致
    elseif Activity.ActivityID == OpsCeremonyDefine.ActivityID and self.OpenCeremonyAnimation == 0 then
        self:PlayCeremonyAni(CallBack)
        self.OpenCeremonyAnimation = 1
        USaveMgr.SetInt(SaveKey.OpenLightCeremony, self.OpenCeremonyAnimation , true)
        return
    end
    return
end

function OpsSeasonActivityMgr:PlayHalloweenAni(CallBack)
    _G.UIViewMgr:ShowView(_G.UIViewID.OpsSeasonAnimView, {Ani = "Halloween", CallBack = CallBack})
end

function OpsSeasonActivityMgr:PlayCeremonyAni(CallBack)
    _G.UIViewMgr:ShowView(_G.UIViewID.OpsSeasonAnimView, {Ani = "Ceremony", CallBack = CallBack})
end

function OpsSeasonActivityMgr:ShowNewVersionContentUI()
    local Activity = self:GetNewVersionContentActivity()
    if Activity == nil then
        return
    end

    local OpsCommTabChildItemVM = OpsCommTabChildItemVM.New()
    local Detail = OpsActivityMgr.ActivityNodeMap[Activity.ActivityID] or {}
    OpsCommTabChildItemVM:UpdateVM({Activity = Activity, Detail = Detail})
    _G.UIViewMgr:ShowView(_G.UIViewID.OpsVersionNoticeContentPanelView, OpsCommTabChildItemVM)
end

function OpsSeasonActivityMgr:UpdateActivityRedDot()
    local Activity = self:GetSeasonActivity()
    if Activity == nil then
        return
    end

    if Activity.Title == LSTR(1560025) then
        local Detail = OpsActivityMgr.ActivityNodeMap[Activity.ActivityID] or {}
        self:UpdateHalloweenRedDot(Activity.ActivityID, Detail)
    end

    if Activity.ActivityID == 25012101 then
        local Detail = OpsActivityMgr.ActivityNodeMap[Activity.ActivityID] or {}
        self:UpdateLightCeremonyRedDot(Activity.ActivityID, Detail)
    end

    if Activity.BPName == "Ops/OpsVersionNotice/OpsVersionNoticeContentPanel_UIBP" then
        local Detail = OpsActivityMgr.ActivityNodeMap[Activity.ActivityID] or {}
        self:UpdatesVersionNoticeRedDot(Activity.ActivityID, Detail)
    end
    _G.EventMgr:SendEvent(EventID.SeasonActivityUpdatRedDot)
end

function OpsSeasonActivityMgr:SetSeasonActivityIcon()
    local Activity = self:GetSeasonActivity()
    if Activity == nil then
        return
    end

    MainFunctionDefine.SetConfigButtonIcon(MainFunctionDefine.ButtonType.SEASON_ACTIVITY, Activity.Icon)

end

function OpsSeasonActivityMgr:UpdatesVersionNoticeRedDot(ActivityID, Detail)
    local NodeList = Detail.NodeList or {}
    local IsShowRedDot = false
    for _, Node in ipairs(NodeList) do
        if self:HasRecordRedDotID(Node.Head.NodeID) == false then
           IsShowRedDot = true
           break
        end
    end
    if IsShowRedDot then
        RedDotMgr:AddRedDotByName(OpsSeasonActivityDefine.RedDotName)
    else
        RedDotMgr:DelRedDotByName(OpsSeasonActivityDefine.RedDotName)
    end
end

function OpsSeasonActivityMgr:UpdateLightCeremonyRedDot(ActivityID, Detail)
    local ChapterID = nil
    local NodeID = nil
    local NodeList = Detail.NodeList or {}
    local MysteriousVisitorIsFinish = false
    local PenguinWarsTaskIsFinish = false
    local CeremonyPartiesIsOpen = false
    local PenguinWarsRedDotInfoIsAdd = false
    local CeremonyRedDotInfoIsAdd = false
    --- 遍历的顺序不固定有,红点的增删放到最后
    for i = 1, #NodeList do
        local Node = NodeList[i]
        --- 异界访客任务完成信息
        if Node and Node.Head then
            if Node.Head.NodeID == OpsCeremonyDefine.NodeIDDefine.MysteriousVisitor then
                local ActivityNode = OpsActivityMgr.ActivityNodeMap[Node.ActivityID] or {}
                if Node and ActivityNode then
                    MysteriousVisitorIsFinish = Node.Head.Finished or Node.Extra.Progress == 1
                end
            end
            --- 迷失企鹅大作战任务完成信息
            if Node.Head.NodeID == OpsCeremonyDefine.NodeIDDefine.PenguinWars then
                local ActivityNode = OpsActivityMgr.ActivityNodeMap[Node.ActivityID] or {}
                if Node and ActivityNode then
                    PenguinWarsTaskIsFinish = Node.Head.Finished or Node.Extra.Progress == 1
                end
            end
            --- 派对庆典首环任务完成信息
            if Node.Head.NodeID == OpsCeremonyDefine.NodeIDDefine.Celebration2 then
                local ActivityNode = OpsActivityMgr.ActivityNodeMap[Node.ActivityID] or {}
                if Node and ActivityNode then
                    CeremonyPartiesIsOpen = Node.Head.Finished or Node.Extra.Progress.Value == 1
                end
            end
        end
    end

    --异界访客任务开启红点和每日红点
    --若未接取任务则每日刷新
    NodeID = OpsCeremonyDefine.NodeIDDefine.MysteriousVisitor
    if not self:CheckTaskIsTaken(OpsCeremonyDefine.TaskIDDefine.MysteriousVisitorTask) and self:DailyRedDot(OpsCeremonyDefine.NodeIDDefine.MysteriousVisitor) then
        RedDotMgr:AddRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
    else
        RedDotMgr:DelRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
    end

    ChapterID = OpsCeremonyDefine.TaskIDDefine.PenguinWarsTask
    NodeID = OpsCeremonyDefine.NodeIDDefine.PenguinWars
    --迷失企鹅大作战阶段一开启红点：前置任务完成且未接取任务时有首次点击红点
    if MysteriousVisitorIsFinish and not self:CheckTaskIsTaken(ChapterID) and self:HasRecordRedDotID(NodeID) == false then
        RedDotMgr:AddRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
        PenguinWarsRedDotInfoIsAdd = true
    else
        RedDotMgr:DelRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
    end

    NodeID = OpsCeremonyDefine.NodeIDDefine.PenguinWars2
    --迷失企鹅大作战阶段二开启红点：前置任务完成后有首次点击红点
    if not PenguinWarsRedDotInfoIsAdd then
        if PenguinWarsTaskIsFinish and self:HasRecordRedDotID(NodeID) == false then
            RedDotMgr:AddRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
        else
            RedDotMgr:DelRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
        end
    end

    --- 庆典派对阶段一红点：前置任务完成且未接取任务时有首次点击红点
    --- 还需要检查开启时间
    local CelebrationIsOpen = true
    local CelebrationActivity = ActivityCfg:FindCfgByKey(OpsCeremonyDefine.CelebrationActivityID)
    if CelebrationActivity then
        local StartTime = CelebrationActivity.ChinaActivityTime.StartTime
        local ActivityDataStamp = TimeUtil.GetTimeFromString(StartTime)
        if ActivityDataStamp > TimeUtil.GetServerLogicTime() then
            CelebrationIsOpen = false
        end
    end
    NodeID = OpsCeremonyDefine.NodeIDDefine.Celebration
    ChapterID = OpsCeremonyDefine.TaskIDDefine.CelebrationTask
    if MysteriousVisitorIsFinish and CelebrationIsOpen and not self:CheckTaskIsTaken(ChapterID) and self:HasRecordRedDotID(NodeID) == false then
        RedDotMgr:AddRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
        CeremonyRedDotInfoIsAdd = true
    else
        RedDotMgr:DelRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(NodeID)))
    end

    --- 庆典派对阶段二红点：首环任务完成后有首次点击红点
    --- 派对庆典阶段二开启红点:该活动节点用于标记派对庆典阶段二是否开启，除此之外无其他作用
    if not CeremonyRedDotInfoIsAdd then
        NodeID = OpsCeremonyDefine.NodeIDDefine.Celebration2
        if CeremonyPartiesIsOpen and CelebrationIsOpen and self:HasRecordRedDotID(NodeID) == false then
            RedDotMgr:AddRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(OpsCeremonyDefine.NodeIDDefine.Celebration) .. "/".. tostring(NodeID)))
        else
            RedDotMgr:DelRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(OpsCeremonyDefine.NodeIDDefine.Celebration) .. "/".. tostring(NodeID)))
        end
    end
end

function OpsSeasonActivityMgr:UpdateFatPenguinBlessRedDot(bShowRedDot)
    local NodeIDDefine = OpsCeremonyDefine.NodeIDDefine
    if bShowRedDot then
        RedDotMgr:AddRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.FatPenguin)))
    else
        RedDotMgr:DelRedDotByName(OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeIDDefine.FatPenguin)))
    end
end
function OpsSeasonActivityMgr:UpdateHalloweenRedDot(ActivityID, Detail)
    local NodeList = Detail.NodeList or {}

    -- 守护天节和奇妙舞会开启红点
    local WonderfulBallFinish = false
    local Node, ActivityNode = self:NodeByNodeTitle(NodeList, LSTR(1560001))
    if Node and ActivityNode then
        local Finished = Node.Head.Finished
        local ActivityRedDotName = OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(Node.Head.NodeID))
        if self:HasRecordRedDotID(Node.Head.NodeID) == false then
            RedDotMgr:AddRedDotByName(ActivityRedDotName)
        else
            RedDotMgr:DelRedDotByName(ActivityRedDotName)
        end
        WonderfulBallFinish = Finished
    end

    Node, ActivityNode = self:NodeByNodeTitle(NodeList, LSTR(1560003))
    if Node and ActivityNode then
        local Finished = Node.Head.Finished
        local ActivityRedDotName = OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(Node.Head.NodeID))
        --亡灵府邸闹鬼庄园 开启红点
        if self:HasRecordRedDotID(Node.Head.NodeID) == false and  Finished then
            RedDotMgr:AddRedDotByName(ActivityRedDotName)
        else
            RedDotMgr:DelRedDotByName(ActivityRedDotName)
        end

        if Finished then
            local ChildrenActivitys = self:GetChildrenActivityList(ActivityID) or {}
            for i = 1, #ChildrenActivitys do
                --亡灵府邸闹鬼庄园 奖励红点
                local RewardRedDotName = OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(Node.Head.NodeID).."/"..tostring(ChildrenActivitys[i].ActivityID))
                if OpsActivityMgr:RewardRedDot(ChildrenActivitys[i]) == true then
                    RedDotMgr:AddRedDotByName(RewardRedDotName)
                else
                    RedDotMgr:DelRedDotByName(RewardRedDotName)
                end
        
                --小游戏开启红点
                local StartTime = OpsActivityMgr:GetActivityStartTime(ChildrenActivitys[i])
                local Open = StartTime < TimeUtil.GetServerLogicTime()
                local OpenRedDotName = OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(Node.Head.NodeID).."/"..OpsSeasonActivityDefine.HalloweenMiniGame.."/"..tostring(ChildrenActivitys[i].ActivityID))
                if Open and self:HasRecordRedDotID(ChildrenActivitys[i].ActivityID) == false then
                    RedDotMgr:AddRedDotByName(OpenRedDotName)
                else
                    RedDotMgr:DelRedDotByName(OpenRedDotName)
                end
            end
        end
    end

    --守护天节和化妆舞会
    local MakeupBallFinish = false
    Node, ActivityNode = self:NodeByNodeTitle(NodeList, LSTR(1560004))
    if Node and ActivityNode then
        MakeupBallFinish = Node.Head.Finished
        local ActivityRedDotName = OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(Node.Head.NodeID))
        if self:HasRecordRedDotID(Node.Head.NodeID) == false and WonderfulBallFinish then
            RedDotMgr:AddRedDotByName(ActivityRedDotName)
        else
            RedDotMgr:DelRedDotByName(ActivityRedDotName)
        end
    end

    --神奇的化妆舞会
    Node, ActivityNode = self:NodeByNodeTitle(NodeList, LSTR(1560006))
    if Node and ActivityNode then
        local ActivityRedDotName = OpsSeasonActivityMgr:GetRedDotName(tostring(ActivityID).."/"..tostring(Node.Head.NodeID))
        if self:HasRecordRedDotID(Node.Head.NodeID) == false and MakeupBallFinish then
            RedDotMgr:AddRedDotByName(ActivityRedDotName)
        else
            RedDotMgr:DelRedDotByName(ActivityRedDotName)
        end
    end
end


function OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, NodeTitle)
    if NodeList == nil then
        return
    end
    for _, Node in ipairs(NodeList) do
        local NodeID  = Node.Head.NodeID
        local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
        if ActivityNode then
            if ActivityNode.NodeTitle == NodeTitle then
                return Node, ActivityNode
            end
        end
    end
end

function OpsSeasonActivityMgr:GetRedDotName(RedDotName)
	return OpsSeasonActivityDefine.RedDotName .. '/' .. RedDotName
end

function OpsSeasonActivityMgr:DailyRedDot(NodeID)
	if NodeID == nil then
		return false
	end
	local NodeIDClickedTime = self:GetLastClickedTime(NodeID)
	return NodeIDClickedTime == nil or not TimeUtil.GetIsCurDailyCycleTime(NodeIDClickedTime) 
end

function OpsSeasonActivityMgr:GetLastClickedTime(NodeID)
    if self.NodeRedDotList == nil then
        self.NodeRedDotList = {}
    end

    return self.NodeRedDotList[NodeID]
end

function OpsSeasonActivityMgr:NodeReadSaveKeyData()
	self.NodeRedDotList = {}
    local RedDotStr = USaveMgr.GetString(SaveKey.NodeRecordRedDot, "", true)
    local SplitStr = string.split(RedDotStr,",")
	for i = 1, #SplitStr, 2 do
		self.NodeRedDotList[tonumber(SplitStr[i])] = tonumber(SplitStr[i + 1])
	end
end

function OpsSeasonActivityMgr:RecordRedDotClicked(NodeID, TimeStamp)
	if self.NodeRedDotList == nil then
		self.NodeRedDotList = {}
	end
    if TimeStamp == nil then
        TimeStamp = 0
    end
    self.NodeRedDotList[NodeID] = TimeStamp

    self:UpdateActivityRedDot()

	self:NodeWriteSaveKeyData()
end

function OpsSeasonActivityMgr:HasRecordRedDotID(NodeID)
    if self.NodeRedDotList and nil ~= self.NodeRedDotList[NodeID] then
        return true
    end
    return false
end

function OpsSeasonActivityMgr:NodeWriteSaveKeyData()
    local RedDotStr
    for Key, Value in pairs(self.NodeRedDotList) do
		if string.isnilorempty(RedDotStr) then
			RedDotStr = string.format("%d,%d", Key, Value)
		else
			RedDotStr = string.format("%s,%d,%d", RedDotStr, Key, Value)
		end
    end

    USaveMgr.SetString(SaveKey.NodeRecordRedDot, RedDotStr, true)
end

function OpsSeasonActivityMgr:CheckTaskIsTaken(ChapterID)
    if not ChapterID then
        return false
    else
        --任务未接取时该VM是空
        return _G.QuestMainVM:GetChapterVM(ChapterID) ~= nil
    end
end

function OpsSeasonActivityMgr:GetTaskDesc(ChapterID)
	if ChapterID == nil then
		return ""
	end
	local NewCurrChapterVM = _G.QuestMainVM:GetChapterVM(ChapterID)
	---接取任务后才不为空，为空则返回任务第一阶段的描述
	if NewCurrChapterVM ~= nil then
		return NewCurrChapterVM.QuestHistoryDesc
	end
	local TaskData = QuestCfg:FindAllCfg(string.format("ChapterID=%d", ChapterID))
	if TaskData ~=nil and  #TaskData > 0 then
        table.sort(TaskData, function(l, r) return l.id < r.id end)
		return TaskData[1].TaskDesc
	else
		return ""
	end
end

--@param TimeInterval 活动开启的间隔时间
function OpsSeasonActivityMgr:GetNextActivityOpenTime(TimeInterval, StartTime)
    -- 获取当前时间
    local CurrentTime = TimeUtil.GetServerLogicTime()
    local CurrentDate = os.date("*t", CurrentTime)
    -- 计算当前时间距离00:00过去了多久
    local HoursFromDayStart = CurrentDate.hour
    local NextActivityHour
    -- 计算下一次活动时间
    if (HoursFromDayStart - StartTime) % TimeInterval == 0 then
        NextActivityHour = HoursFromDayStart + TimeInterval
    else
        NextActivityHour = math.ceil((HoursFromDayStart - StartTime) / TimeInterval) * TimeInterval + StartTime
    end
    -- 如果今天没有下一次活动了，返回明天第一次活动时间
    if NextActivityHour >= 24 then
        -- 调整到明天
        return string.format("%02d:00", StartTime)
    else
        return string.format("%02d:00", NextActivityHour)
    end
end

--得到活动时间数据 TODO 备注：服务器还没有开发大区id。目前返回china时间
function OpsSeasonActivityMgr:GetActivityTime(ActivityID)
	if ActivityID  == nil then
		return
	end
    local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
    if Cfg ~= nil then
        local StartTimeTable =self:GetDataTable(Cfg.ChinaActivityTime.StartTime)
        local EndTimeTable = self:GetDataTable(Cfg.ChinaActivityTime.EndTime)
        local StartDate = os.date("%Y/%m/%d", os.time(StartTimeTable))
        local EndDate = os.date("%Y/%m/%d", os.time(EndTimeTable))
        StartDate = LocalizationUtil.GetTimeForFixedFormat(StartDate)
        EndDate = LocalizationUtil.GetTimeForFixedFormat(EndDate, true)
        return _G.StringTools.Format("%s - %s", StartDate, EndDate)
    end
end

function OpsSeasonActivityMgr:GetDataTable(TimeText)
	local Year, Month, Day, Hour, Min, Sec = TimeText:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	return {year = Year, month = Month, day = Day, hour = Hour, min = Min, sec = Sec}
end
-------------------------------------------------------------------------------------------------------


--要返回当前类
return OpsSeasonActivityMgr

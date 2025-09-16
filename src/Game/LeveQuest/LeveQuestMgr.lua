--
--Author: ZhengJianChuan
--Date: 2023-12-25 10:24:27
--Description:
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local ItemUtil = require("Utils/ItemUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local LevequestCfg = require("TableCfg/LevequestCfg")
local LevequestGlobalCfg = require("TableCfg/LevequestGlobalCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local LeveQuestDefine = require("Game/LeveQuest/LeveQuestDefine")
local MapDefine = require("Game/Map/MapDefine")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local UIBindableList = require("UI/UIBindableList")
local MailSlotItemViewVM = require("Game/Mail/View/Item/MailSlotItemViewVM")
local SaveKey = require("Define/SaveKey")
local Json = require("Core/Json")

local USaveMgr = _G.UE.USaveMgr
local LSTR = _G.LSTR
local GameNetworkMgr = require("Network/GameNetworkMgr")
local EventMgr = require("Event/EventMgr")
local UIViewMgr = require("UI/UIViewMgr")
local FLOG_INFO = _G.FLOG_INFO

local LeveQuestParamID = ProtoRes.LeveQuestParamID
local ClientSetupKey = ProtoCS.ClientSetupKey
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.LeveQuest.LeveQuestCmd

---@class LeveQuestMgr : MgrBase
local LeveQuestMgr = LuaClass(MgrBase)

---OnInit
function LeveQuestMgr:OnInit()
	--只初始化自身模块的数据，不能引用其他的同级模块
    self.AcceptNum   = 0 -- 已接取的委托数量
    self.RestoreNum  = 0 -- 恢复的受理限额数量
    self.SubmitList  = {} -- 缴纳理符委托列表 
    self.CurQuestID  = nil -- 当前进行操作的id，接受委托，缴纳委托，放弃委托
    self.PaySingleOrMost = LeveQuestDefine.PayType.Most --交纳单人还是交纳多人
    self.CityNpcList = {}       --城市委托人
    self.CampsiteNpcList = {}   -- 营地委托人
    self.CareerRedDotTable =  {} -- 红点服务器数据
    self.AllCareerRedDot = {}   -- 红点管理器    
    self.InitFitlerList = {}
    
    self.RefreshTime = 0
    self.MarkedItemList = {} -- 标记物品, 一个职业对应一个任务的
    self.LeveQuestProfUnlockLevel = {} -- 理符委托任务交纳
end

---OnBegin
function LeveQuestMgr:OnBegin()
end

function LeveQuestMgr:OnEnd()
end

function LeveQuestMgr:OnShutdown()
end

function LeveQuestMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LEVE_QUEST, SUB_MSG_ID.LeveQuestQuery, self.OnGetLeveQuestData)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_LEVE_QUEST, SUB_MSG_ID.LeveQuestBatchSubmit, self.OnLeveQuestSubmitTaskRsp)
end

function LeveQuestMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnLeveQuestModuleOpen)
    self:RegisterGameEvent(EventID.BagUpdate, self.OnBagItemsUpdate)
    self:RegisterGameEvent(EventID.ClientSetupPost, self.ClientSetupPost)
    self:RegisterGameEvent(EventID.MajorProfActivate, self.MajorProfActivate) -- 激活
end

---@type 当激活时
function LeveQuestMgr:MajorProfActivate(Params)
    local ProfID = Params.ActiveProf.ProfID
    if not ProfUtil.IsProductionProf(ProfID) then
        return
    end

    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest) then
        return
    end

    LeveQuestMgr:AddCareerRedDot(ProfID, false)
end

function LeveQuestMgr:AddCareerRedDot(ProfID, IsLock)
    local RedDotName = nil
    local CareerRedDotTable = LeveQuestMgr:GetCareerRedDotTable()
    local IsOepn =  _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest) 
    if IsOepn and not IsLock then
        if CareerRedDotTable[tostring(ProfID)] == nil or (CareerRedDotTable[tostring(ProfID)] ~= nil and CareerRedDotTable[tostring(ProfID)] ~= "") then
            RedDotName = string.format("%s/%s", RedDotMgr:GetRedDotNameByID(LeveQuestDefine.RedDefines.TabList), self.AllCareerRedDot[tostring(ProfID)])
            if self.AllCareerRedDot[tostring(ProfID)] == nil then
                RedDotName = RedDotMgr:AddRedDotByParentRedDotID(LeveQuestDefine.RedDefines.TabList, nil, false)
                local RecordIndex = string.match(RedDotName, "/(%d+)$")
                self.AllCareerRedDot[tostring(ProfID)] = RecordIndex
                CareerRedDotTable[tostring(ProfID)] = RecordIndex
                LeveQuestMgr:SaveCareerRedDotTable(CareerRedDotTable)
            end
        end
    end
    return RedDotName
end

function LeveQuestMgr:DelCareerRedDot(ProfID)
    local RedDotName = string.format("%s/%s", RedDotMgr:GetRedDotNameByID(LeveQuestDefine.RedDefines.TabList), self.AllCareerRedDot[tostring(ProfID)])
    if self.AllCareerRedDot[tostring(ProfID)] ~= nil then
        local CareerRedDotTable = LeveQuestMgr:GetCareerRedDotTable()
        RedDotMgr:DelRedDotByName(RedDotName)
        self.AllCareerRedDot[tostring(ProfID)] = ""
        -- 玩家选中过的取消掉 
        CareerRedDotTable[tostring(ProfID)] = ""
        LeveQuestMgr:SaveCareerRedDotTable(CareerRedDotTable)
    end
end

-- 获取理符职业红点Name
function LeveQuestMgr:GetLeveQuestRedDotName(ProfID)
    return self.AllCareerRedDot[tostring(ProfID)]
end

function LeveQuestMgr:GetCareerRedDotTable()
    return self.CareerRedDotTable
end

function LeveQuestMgr:SaveCareerRedDotTable(NewStateTable)
    local SaveLeveRedDotTable = Json.encode(NewStateTable)
    local Params = {}
    Params.IntParam1 = ClientSetupID.LeveQuestProfRedDotList
    Params.StringParam1 = SaveLeveRedDotTable
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

function LeveQuestMgr:ClientSetupPost(EventParams)
    local Key = EventParams.IntParam1
	local Value = EventParams.StringParam1
	if Key == ClientSetupKey.CSKLeveQuestPayMethod then
        if Value == "" then -- Value == "" 
            self.PaySingleOrMost = LeveQuestDefine.PayType.Single
        else
            self.PaySingleOrMost = tonumber(Value)
        end

        EventMgr:SendEvent(EventID.LeveQuestInfoUpdate)
    elseif Key ==  ClientSetupID.LeveQuestProfRedDotList then
        -- 解析红点数据
        local List = Json.decode(Value)
        self.CareerRedDotTable = List
    elseif Key == ClientSetupID.LeveQuestProfUnlockLevel then
        -- 解析当前职业处于哪个等级段
        local List = Json.decode(Value)
        self.LeveQuestProfUnlockLevel = (type(List) == "table") and List or {}
	end
end

function LeveQuestMgr:GetProfUnlockLevel(ProfID)
    if self.LeveQuestProfUnlockLevel[tostring(ProfID)] ~=  nil then
        return self.LeveQuestProfUnlockLevel[tostring(ProfID)]
    end
    return 1
end

function LeveQuestMgr:SetProfUnlockLevel(ProfID, NewLevelStep)
    self.LeveQuestProfUnlockLevel[tostring(ProfID)] = NewLevelStep
    LeveQuestMgr:SendToServerProfUnlockLevel(self.LeveQuestProfUnlockLevel)
end

function LeveQuestMgr:SendToServerProfUnlockLevel(NewTable)
    local SaveLeveQuestProfUnlockLevel = Json.encode(NewTable)
    local Params = {}
    Params.IntParam1 = ClientSetupID.LeveQuestProfUnlockLevel
    Params.StringParam1 = SaveLeveQuestProfUnlockLevel
    _G.ClientSetupMgr:OnGameEventSet(Params)
end

function LeveQuestMgr:SendToServerSaveKey()
    local Params = {}
    Params.IntParam1 = ClientSetupKey.CSKLeveQuestPayMethod
    Params.StringParam1 = tostring(self.PaySingleOrMost)
    _G.EventMgr:SendEvent(EventID.ClientSetupSet, Params)
end

function LeveQuestMgr:SetPaySingleOrMost(bSingle)
    self.PaySingleOrMost = bSingle and  LeveQuestDefine.PayType.Single or LeveQuestDefine.PayType.Most
    LeveQuestMgr:SendToServerSaveKey() 
end

function LeveQuestMgr:GetPaySingleOrMost()
    return self.PaySingleOrMost
end

function LeveQuestMgr:GetRefreshTime()
    return self.RefreshTime
end

-- 获取职业标记ItemID
function LeveQuestMgr:GetMarkedItemByProfID(ProfID)
    if ProfID == nil then
        return
    end
    local ProfID = tostring(ProfID)
    return self.MarkedItemList[ProfID] and self.MarkedItemList[ProfID].ItemID
end

-- 是否职业标记
function LeveQuestMgr:IsProfMarkedItem(ProfID, LeveQuestID)
    local ProfID = tostring(ProfID)
    if self.MarkedItemList[ProfID] == nil then
        return false
    end

    return self.MarkedItemList[ProfID].ID and self.MarkedItemList[ProfID].ID == LeveQuestID
end

-- 设置职业标记
function LeveQuestMgr:SetProfMarkedItem(ProfID, LeveQuestID, ItemID) 
    local ProfID = tostring(ProfID)
    if self.MarkedItemList[ProfID] == nil then
        self.MarkedItemList[ProfID] = {}
    end
    self.MarkedItemList[ProfID] = {ID = LeveQuestID, ItemID = ItemID }
end

-- 清空当前职业标记
function LeveQuestMgr:ClearProfMarkedItem(ProfID)
    local ProfID = tostring(ProfID)
    self.MarkedItemList[ProfID] = nil
end

function LeveQuestMgr:OnGameEventLoginRes()
    self:LoadCfg()
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest) then
		self:SendGetLeveQuestData()
	end

    -- local QueryParams = {}
    -- QueryParams.ULongParam1 = MajorUtil.GetMajorRoleID()
    -- EventMgr:SendEvent(EventID.ClientSetupQueryAll, QueryParams)
end

function LeveQuestMgr:OnLeveQuestModuleOpen(ModuleID)
    if ModuleID == ProtoCommon.ModuleID.ModuleIDLeveQuest then
        self:LoadCfg()
		self:SendGetLeveQuestData()
	end
end

function LeveQuestMgr:OnBagItemsUpdate(UpdateItem)
    -- 遍历UpdateItem 查看submit的npclist 需要变动
    local _ <close> = CommonUtil.MakeProfileTag("LeveQuestMgr:OnBagItemsUpdate")
    --FLOG_INFO("LeveQuestMgr:OnBagItemsUpdate")
    local IsItemChanged = false

    if UpdateItem == nil then
        return 
    end
    
    for _, v in ipairs(UpdateItem) do
        local ResID = v.PstItem.ResID
        for _, v in ipairs(self.SubmitList) do
            local Cfg = LevequestCfg:FindCfgByKey(v.TaskID)
            if Cfg ~= nil then
                local RequireItem = Cfg.RequireItem
                if RequireItem ~= nil then
                    local RequireItemID = RequireItem.ID
                    local RequireItemSID = _G.BagMgr:GetItemNQHQItemID(RequireItem.ID)
                    if RequireItemID == ResID or (RequireItemSID ~= 0 and RequireItemSID)then
                        IsItemChanged = true
                        break
                    end
                end
            end
            
        end
    end

    if IsItemChanged then        
        local NpcIdList, RemoveList = self:GetMapNpcList()
        EventMgr:SendEvent(EventID.LeveQuestUpdateNPCHudIcon, NpcIdList)
        EventMgr:SendEvent(EventID.LeveQuestUpdateNPCHudIcon, RemoveList)
        
        for _, v in ipairs(NpcIdList) do            
            self:UpdateMiniMapIcon(v.NpcID)
        end

        for _, v in ipairs(RemoveList) do            
            self:RemoveMiniMapIcon(v.NpcID)
        end        
        -- 更新一下列表状态
        EventMgr:SendEvent(EventID.LeveQuestListUpdate)
    end
end


function LeveQuestMgr:SendGetLeveQuestData()
    local MsgID = CS_CMD.CS_CMD_LEVE_QUEST
    local SubMsgID = SUB_MSG_ID.LeveQuestQuery

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--委托任务基础信息
function LeveQuestMgr:OnGetLeveQuestData(MsgBody)
    if nil == MsgBody then
        return
    end

    local Data = MsgBody.Query
    self.RestoreNum = Data.RestoreNum
    self.RefreshTime = Data.NextRefreshTime

    EventMgr:SendEvent(EventID.LeveQuestInfoUpdate)
end

--理符委托提交任务
function LeveQuestMgr:SendLeveQuestSubmitTaskReq(QuestID, ItemID, ItemNum, GIDList)
    local MsgID = CS_CMD.CS_CMD_LEVE_QUEST
    local SubMsgID = SUB_MSG_ID.LeveQuestBatchSubmit

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    MsgBody.BatchSubmit = {TaskID = QuestID, ItemID = ItemID, Num = ItemNum , GIDs = GIDList}
    self.CurQuestID = QuestID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--提交委托回调
function LeveQuestMgr:OnLeveQuestSubmitTaskRsp(MsgBody)
    if nil == MsgBody then
        return
    end

    local Data = MsgBody.BatchSubmit

    local AwardList = Data.AwardList
    local QuestID = Data.TaskID
    local FinishNum = Data.FinishNum
    -- 奖励道具弹窗
    local Params = {}
	Params.ItemList = {}
    Params.Title = _G.LSTR(880010)

    local IsDouble = false
    local ExtraExp = 0

    for _, v in ipairs(AwardList) do
        if v.IsExtra then
            IsDouble = true
            local Cfg = LevequestCfg:FindCfgByKey(QuestID)
            if Cfg ~= nil then
                for _, value in ipairs(Cfg.RewardItems) do
                    if value.ID == ProtoRes.SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP then
                        ExtraExp = v.Count * (value.Rate / 100)
                    end
                end
            end
            break
        end
    end

    local ItemList = {}
    local TempList = {}
    for index, v in ipairs(AwardList) do
        if index <= 2 then
            table.insert(ItemList, { ResID = v.ResID, Num = v.Count})
        else
            table.insert(TempList, { ResID = v.ResID, Num = v.Count})
        end
	end

    local Cfg1 =  LevequestCfg:FindCfgByKey(QuestID)

    local function getIndex(ResID)
        for index, v in ipairs(Cfg1.ExtraItems) do
            if v.ID == ResID then
                return index
            end
        end
        return 1
    end

    table.sort(TempList, function (a, b)
        return getIndex(a.ResID) > getIndex(b.ResID)
    end)

    for _, v in ipairs(TempList) do
        table.insert(ItemList, v)
    end

    Params.ItemList = ItemList

    _G.LootMgr:SetDealyState(true)
    if #Params.ItemList > 0 then
        local VMList = UIBindableList.New(MailSlotItemViewVM)
    
        for _, V in ipairs(ItemList) do
            VMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
        end
        _G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(740015), ItemVMList = VMList })
    end	


    if IsDouble then
        MsgTipsUtil.ShowTips(string.format(LSTR(880011), ExtraExp))
    end


    EventMgr:SendEvent(EventID.LeveQuestReduceAnim, FinishNum)

    local SubmitList = self.SubmitList
    local RemoveList = {}
    local RemoveNpcIDList = {}
    for index, v in ipairs(SubmitList) do
        if v.TaskID == QuestID then
            v.Num = v.Num - FinishNum
        end
        local Cfg = LevequestCfg:FindCfgByKey(QuestID)
        if Cfg ~= nil then
            if v.Num <= 0 then
                table.insert(RemoveList, Cfg)
                table.remove(SubmitList, index)
                table.insert(RemoveNpcIDList, {NpcID = Cfg.PayNPC})
            end
            self:UpdateMiniMapIcon(Cfg.PayNPC)
        end
    end

    self.SubmitList = SubmitList

    for _, v in ipairs(RemoveList) do
        self:RemoveMiniMapIcon(v.PayNPC)
    end

    if self.RestoreNum - FinishNum <= 0 then
        self.RestoreNum = 0
    else
        self.RestoreNum = self.RestoreNum - FinishNum
    end

    EventMgr:SendEvent(EventID.LeveQuestListUpdate)
    EventMgr:SendEvent(EventID.LeveQuestInfoUpdate)

    local NpcIdList, RemoveList1 = self:GetMapNpcList()
    EventMgr:SendEvent(EventID.LeveQuestUpdateNPCHudIcon, NpcIdList)
    EventMgr:SendEvent(EventID.LeveQuestUpdateNPCHudIcon, RemoveNpcIDList)

end

------------------------------- 对外接口 -------------------------------
--- 返回已接取的委托数量
function LeveQuestMgr:GetAcceptNum()
    return self.AcceptNum
end

function LeveQuestMgr:GetAcceptTotalNum()
    local TotalAcceptCfg = LevequestGlobalCfg:FindCfgByKey(LeveQuestParamID.LeveQuestEntrustLimit)
    if TotalAcceptCfg  ~= nil then
        local TotalAcceptNum = TotalAcceptCfg.Value[1]
        return TotalAcceptNum
    end
    return 0
end

function LeveQuestMgr:GetResotreTotalNum()
    local TotalRestoreCfg = LevequestGlobalCfg:FindCfgByKey(LeveQuestParamID.LeveQuestAcceptLimit)
    if  TotalRestoreCfg ~= nil then
    local TotalRestoreNum = TotalRestoreCfg.Value[1]
    return TotalRestoreNum
    end

    return 0
end

--- 返回恢复的受理限额数量
function LeveQuestMgr:GetRestoreNum()
    return self.RestoreNum
end

---获取npc头顶图标
---@return string|nil
function LeveQuestMgr:GetNPCHudIcon(EntityID)
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest) then
        return nil
    end

    local Attr = ActorUtil.GetActorAttributeComponent(EntityID)
    local State = LeveQuestDefine.NpcHeadIconState
    if Attr then
        local NpcID = ActorUtil.GetActorResID(EntityID)
        
        -- 接取任务
        local Cfgs = self.CityNpcList
        if (#self.CityNpcList> 0) then            
            for _, cfg in ipairs(Cfgs) do
                if cfg.CityNPC == NpcID then
                    return State.AccpteLeveQuest
                end
            end            
        end
        
        -- 营地委托人接取任务
        local Cfgs = self.CampsiteNpcList
        if (#self.CampsiteNpcList> 0) then
            for _, cfg in ipairs(Cfgs) do
                if cfg.CampsiteNPC == NpcID then
                    return State.AccpteLeveQuest
                end
            end
        end
    end
    return nil
end

function LeveQuestMgr:IsEnoughItem(QuestCfg)
    local IsEnough = false
    return IsEnough
end

function LeveQuestMgr:LoadCfg()
    self.CityNpcList = LevequestCfg:FindAllCityNpcIDLeveQuest()
    self.CampsiteNpcList = LevequestCfg:FindAllCampsiteNpcIDLeveQuest()        

    local State = LeveQuestDefine.NpcHeadIconState
    local Cfg = self.CityNpcList
    for _, value in ipairs(Cfg) do
        if value.CityNPC ~= nil then                        
            if self.InitFitlerList[value.CityNPC] == nil then
                self.InitFitlerList[value.CityNPC] = {}
                table.insert(self.InitFitlerList[value.CityNPC], {NpcID = value.CityNPC, Type = LeveQuestDefine.ToggleIndex.Accept, IconPath = State.AccpteLeveQuest })
                
            end

        end
    end

    local Cfg = self.CampsiteNpcList
    for _, value in ipairs(Cfg) do
        if value.CampsiteNPC ~=  nil then
            if self.InitFitlerList[value.CampsiteNPC] == nil then
                self.InitFitlerList[value.CampsiteNPC] = {}
                table.insert(self.InitFitlerList[value.CampsiteNPC], {NpcID = value.CampsiteNPC, Type = LeveQuestDefine.ToggleIndex.Accept, IconPath = State.AccpteLeveQuest})
            end
        end
    end
end

function LeveQuestMgr:GetMapNpcList()
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest) then
        return {}, {}
    end        

    local fitlerList = {}

    for key, value in pairs(self.InitFitlerList) do
        fitlerList[key] = table.clone(value)
    end

    local NpcList = {}
    local State = LeveQuestDefine.NpcHeadIconState
    for _, value in ipairs(self.SubmitList) do        
        local Cfg = LevequestCfg:FindCfgByKey(value.TaskID)
        if Cfg ~= nil then
            local IsEnough = self:IsEnoughItem(Cfg) 
            local IconPath = IsEnough and State.SubmitLeveQuestEnough or nil
            if Cfg.PayNPC ~= nil then
                if fitlerList[Cfg.PayNPC] == nil then
                    fitlerList[Cfg.PayNPC] = {}
                end
                table.insert(fitlerList[Cfg.PayNPC], {NpcID = Cfg.PayNPC, Type = LeveQuestDefine.ToggleIndex.Submit, IconPath = IconPath, IsEnough = IsEnough})
            end
        end
    end

    -- 筛选npclist
    --Todo 筛选npclist，有相同的npcid， 优先Type = LeveQuestDefine.ToggleIndex.Submit。次优先LeveQuestDefine.ToggleIndex.Accept。如果相同的npcid IsEnough有一个ture，就是true。
    local updatedList = {}
    local removeList = {}  --需要移除的npcList

    for _, v in pairs(fitlerList) do
       if not (table.length(v) > 1) then
            if v[1].Type == LeveQuestDefine.ToggleIndex.Accept then
                table.insert(updatedList, v[1])
            elseif v[1].Type  ==LeveQuestDefine.ToggleIndex.Submit then
                if not v[1].IsEnough then
                    table.insert(removeList, {NpcID = v[1].NpcID})
                else
                    table.insert(updatedList, v[1])
                end
            end
       else
            local IsAllNotEnough = true
            local NotAccept = true
            for _, value in ipairs(v) do
                if value.Type == LeveQuestDefine.ToggleIndex.Submit then
                    if value.IsEnough then
                        IsAllNotEnough = false
                        table.insert(updatedList, value)
                        break
                    end
                end
            end

            for _, value in ipairs(v) do
                if value.Type == LeveQuestDefine.ToggleIndex.Accept then
                    NotAccept = false
                    table.insert(updatedList, value)
                    break
                end
            end

            if IsAllNotEnough and NotAccept then
                table.insert(removeList, {NpcID = v[1].NpcID})
            end
       end
    end

    return updatedList, removeList
end

function LeveQuestMgr:UpdateMiniMapIcon(NpcResID)
    local MapMarkerType = MapDefine.MapMarkerType
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.LeveQuest)
    local DefaultMarkerProvide = MarkerProviders[1]
    if DefaultMarkerProvide ~= nil then
        local Params = DefaultMarkerProvide:FindMarkerParamByNpcResID(NpcResID, false)
        if Params ~= nil then
            FLOG_INFO("刷新地图理符npc " .. Params.ID)
            EventMgr:SendEvent(EventID.LeveQuestMapUpdate, Params)
        end
    end
end

function LeveQuestMgr:RemoveMiniMapIcon(NpcResID)
    local MapMarkerType = MapDefine.MapMarkerType
    local MarkerProviders = _G.MapMarkerMgr:GetMarkerProviders(MapMarkerType.LeveQuest)
    local DefaultMarkerProvide = MarkerProviders[1]
    if DefaultMarkerProvide ~= nil then
        local Params = DefaultMarkerProvide:FindMarkerParamByNpcResID(NpcResID, true)
        if Params ~= nil then
            FLOG_INFO("移除地图理符npc " .. Params.ID)
            EventMgr:SendEvent(EventID.LeveQuestMapEnd, Params)
        end
    end
end

function LeveQuestMgr:GetLeveQuestStatus(NpcID)
    local NpcList = self:GetMapNpcList()
    for _, v in ipairs(NpcList) do
        if v.NpcID == NpcID then
            return true, v.Type
        end
    end

    return false, nil
end

function LeveQuestMgr:GetAllCareerData()
    local CareerList = LeveQuestDefine.TabList
    local AllCareerData = {}
    for index, profID in ipairs(CareerList) do
        local ProfListIndex = self:GetProfListIndex(profID)
        local ProfData = {}
        ProfData.ID = profID
        ProfData.IsLock = ProfListIndex == -1
        ProfData.Prof = profID
        ProfData.Index = index
        ProfData.Name = RoleInitCfg:FindRoleInitProfName(profID)
		ProfData.IconPath = ProfUtil.GetProfIconBySelected(profID, false)
		ProfData.SelectIcon = ProfUtil.GetProfIconBySelected(profID, true)
        ProfData.RedDotData = {}
        ProfData.RedDotData.RedDotName = LeveQuestMgr:AddCareerRedDot(profID,  ProfListIndex == -1)
        ProfData.RedDotType = RedDotDefine.RedDotStyle.TextStyle
        table.insert(AllCareerData, ProfData)
    end

    table.sort(
        AllCareerData, function (a, b)
            if a.IsLock ~= b.IsLock then
                return a.IsLock == false and b.IsLock == true
            end
            return LeveQuestDefine.CareerSortData[a.Prof] < LeveQuestDefine.CareerSortData[b.Prof]
        end
    )

    for index, v in ipairs(AllCareerData) do
        v.Index = index
    end

    return AllCareerData
end

function LeveQuestMgr:GetFirstCareer()
    local CareerData = self:GetAllCareerData()
    return CareerData[1].Prof
end

function LeveQuestMgr:GetFirstCareerIndex()
    local CareerData = self:GetAllCareerData()
    return CareerData[1].Index
end

function LeveQuestMgr:GetCareerLocked(ProfID)
    local CareerData = self:GetAllCareerData()
    for _, v in ipairs(CareerData) do
        if v.Prof == ProfID then
            return v.IsLock
        end
    end

    return false
end

function LeveQuestMgr:GetCareerIndex(ProfID)
    local CareerData = self:GetAllCareerData()
    for _, v in ipairs(CareerData) do
        if v.Prof == ProfID then
            return v.Index
        end
    end

    return -1
end

---已解锁职业详情
function LeveQuestMgr:GetProfListIndex(ProfID)
    local ProfList = _G.ActorMgr:GetMajorRoleDetail().Prof.ProfList
    for Index, v in pairs(ProfList) do
        if v.ProfID == ProfID then
            return Index
        end
    end
    return -1
end

-- 检查生成职业是否有开启（有一个职业就可以打开界面）
function LeveQuestMgr:CheckProfLockedStatus()
    local CareerList = LeveQuestDefine.TabList
    for _, profID in ipairs(CareerList) do
        local ProfListIndex = LeveQuestMgr:GetProfListIndex(profID)
        if  ProfListIndex ~= -1 then
            return true
        end
    end

    return false
end

-- 查找奖励物品
function LeveQuestMgr:GetCfgbyJumpItemID(ItemID)
    local CareerList = LeveQuestDefine.TabList
    local NeedCareerList = {}
    for _, profID in ipairs(CareerList) do
        local ProfListIndex = LeveQuestMgr:GetProfListIndex(profID)
        if  ProfListIndex ~= -1 then
            table.insert(NeedCareerList, profID)
        end
    end

    local CfgList = {}
    for _, profID in ipairs(NeedCareerList) do
        local Cfg = LevequestCfg:FindAllCfg(string.format("ProfType == %d", profID))
        for _, value in ipairs(Cfg) do
            for _, v in ipairs(value.ExtraItems) do
                if v.ID == ItemID then
                    table.insert(CfgList, value)
                end
            end
        end
    end

    local TempList = {}
    for _, v in ipairs(CfgList) do
        local Temp = {}
        local ItemID = v.RequireItem.ID
        local IsEnough = LeveQuestMgr:GetMostPayNum(v, ItemID) > 1
        if not ItemUtil.IsHQ(ItemID) then
			local Cfg = ItemCfg:FindCfgByKey(ItemID)
			if Cfg ~= nil then
				if Cfg.NQHQItemID ~= 0 and not IsEnough then
                    IsEnough = LeveQuestMgr:GetMostPayNum(v, Cfg.NQHQItemID) > 1
                end
            end
        end
        Temp.CanSubmit = IsEnough
        Temp.IsLevel = v.Level < LeveQuestMgr:GetProfCurLevel(v.ProfType)
        Temp.IsCurProfID = MajorUtil.GetMajorProfID() == v.ProfType
        Temp.ProfID = v.ProfType
        Temp.ID = v.ID
        Temp.Level = v.Level

        table.insert(TempList, Temp)
    end

    table.sort(TempList, function(a, b)
        if a.CanSubmit ~= b.CanSubmit then
            return a.CanSubmit
        end

        if a.IsLevel ~=  b.IsLevel then
            return a.IsLevel
        end

        if a.Level ~=  b.Level then
            return a.Level > b.Level
        end

        if a.IsCurProfID ~= b.IsCurProfID then
            return a.IsCurProfID
        end

        if a.ProfID ~= b.ProfID then
            return a.ProfID < b.ProfID
        end

        return a.ID < b.ID
    end)

    return #TempList > 0 and TempList[1] or nil

end


function LeveQuestMgr:GetMostPayNum(Cfg, ItemID)
	local NeededItem = Cfg.RequireItem
	local NeededItemNum = NeededItem.Num or 1
	local OwnNum = _G.LeveQuestMgr:GetCanPayItemNum(ItemID)
	local PayNum = math.floor(OwnNum/NeededItemNum)
	return PayNum
end

function LeveQuestMgr:GetMaxLevelProfID()
    local ProfList = LeveQuestDefine.TabList
    local MaxLevel = 0
    local MaxLevelProfID = 99
    local CareerData = LeveQuestDefine.CareerSortData
    for _, value in ipairs(ProfList) do
        local ProfLevel = MajorUtil.GetMajorLevelByProf(value)
        if ProfLevel ~= nil then
            if ProfLevel > MaxLevel then
                MaxLevel = ProfLevel
                MaxLevelProfID = value
            elseif ProfLevel == MaxLevel then
                if CareerData[value] < CareerData[MaxLevelProfID] then
                    MaxLevel = ProfLevel
                    MaxLevelProfID = value
                end
            end
        end
    end

    return MaxLevelProfID == 99 and self:GetFirstCareer() or MaxLevelProfID
end

function LeveQuestMgr:GetProfCurExp(ProfID)
    local ProfDetail = _G.ActorMgr:GetMajorRoleDetail()
    if not ProfDetail then return 0 end
    local ProfList = ProfDetail.Prof and ProfDetail.Prof.ProfList or {}

    for _ , value in pairs(ProfList) do
        if value.ProfID == ProfID then
            return value.Exp
        end
    end

    return 0
end

--更新职业经验变动
function LeveQuestMgr:SetProfCurExp(ProfID, NewExp)
    local ProfDetail = _G.ActorMgr:GetMajorRoleDetail()
    if not ProfDetail then return  end
    local ProfList = ProfDetail.Prof and ProfDetail.Prof.ProfList or {}

    for _ , value in pairs(ProfList) do
        if value.ProfID == ProfID then
            value.Exp = NewExp
        end
    end
end


function LeveQuestMgr:GetProfCurLevel(ProfID)
    local ProfDetail = _G.ActorMgr:GetMajorRoleDetail()
    if not ProfDetail then  return 0 end
    local ProfList = ProfDetail.Prof and ProfDetail.Prof.ProfList or {}

    for _ , value in pairs(ProfList) do
        if value.ProfID == ProfID then
            return value.Level
        end
    end

    return 0
end

--- 获取可以提交的道具数量
function LeveQuestMgr:GetCanPayItemNum(ItemResID)
    local ItemList = _G.BagMgr:FilterItemByCondition(function (Item)
		return Item.ResID == ItemResID
	end)
    local Num = 0
    local EquipGIDs = {} 
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    local ProfID = MajorUtil.GetMajorProfID()
    for key, value in pairs(RoleDetail.Prof.ProfList) do
        local  Equipscheme = value.EquipScheme
        if key ~= ProfID then
            for _, data in pairs(Equipscheme)do
                if not table.contain(EquipGIDs, data.GID) then
                    table.insert(EquipGIDs,  data.GID)
                end
            end
        end
    end

    local EquipmentList = RoleDetail.Equip.EquipList
    for _, data in pairs(EquipmentList)do
        if not table.contain(EquipGIDs, data.GID) then
            table.insert(EquipGIDs,  data.GID)
        end
    end

    for _, v in ipairs(ItemList) do
        local Item = _G.EquipmentMgr:GetItemByGID(v.GID)
        local NotEquip = not table.contain(EquipGIDs, v.GID)
        local OwnMojingStone = false
        if  Item and Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo and Item.Attr.Equip.GemInfo.CarryList then
            for _, value in pairs(Item.Attr.Equip.GemInfo.CarryList) do
                OwnMojingStone = true
                break
            end
        end
        if NotEquip and not OwnMojingStone then
            Num = Num + v.Num
        end
    end

    return Num
end

--- 获取可以提交的道具GIDList
function LeveQuestMgr:GetCanPayItemGIDs(ItemResID)
    local ItemList = _G.BagMgr:FilterItemByCondition(function (Item)
		return Item.ResID == ItemResID
	end)
    local GIDList = {}
    local EquipGIDs = {} 
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    local ProfID = MajorUtil.GetMajorProfID()
    for key, value in pairs(RoleDetail.Prof.ProfList) do
        local  Equipscheme = value.EquipScheme
        if ProfID ~= key then
            for _, data in pairs(Equipscheme)do
                if not table.contain(EquipGIDs, data.GID) then
                    table.insert(EquipGIDs,  data.GID)
                end
            end
        end
    end

    local EquipmentList = RoleDetail.Equip.EquipList
    for _, data in pairs(EquipmentList)do
        if not table.contain(EquipGIDs, data.GID) then
            table.insert(EquipGIDs,  data.GID)
        end
    end
    
    for _, v in ipairs(ItemList) do
        if not table.contain(EquipGIDs, v.GID) then
            local Item = _G.EquipmentMgr:GetItemByGID(v.GID)
            local NotEquip = not table.contain(EquipGIDs, v.GID)
            local OwnMojingStone = false
            if  Item and Item.Attr and Item.Attr.Equip and Item.Attr.Equip.GemInfo and Item.Attr.Equip.GemInfo.CarryList then
                for _, value in pairs(Item.Attr.Equip.GemInfo.CarryList) do
                    OwnMojingStone = true
                    break
                end
            end
            if NotEquip and not OwnMojingStone then
               table.insert(GIDList, v.GID)
            end
        end
    end

    return GIDList
end

-- 跳转路径进入理符
function LeveQuestMgr:OpenLeveQuestViewByItemID(ItemID)
    if not LeveQuestMgr:CheckProfLockedStatus() then
        return
    end
    UIViewMgr:ShowView(UIViewID.LeveQuestMainPanel, {JumpItemID = ItemID})
end

--要返回当前类
return LeveQuestMgr
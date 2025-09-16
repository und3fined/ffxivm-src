--
--Author: ds_yangyumian
--Date: 2024-05-30 14:00
--Description:
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local CompanysealCfg = require("TableCfg/CompanysealCfg")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local BagMgr = require("Game/Bag/BagMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ItemUtil = require("Utils/ItemUtil")
local CompanysealRankCfg = require("TableCfg/CompanysealRankCfg")
local CompanysealGlobalCfg = require("TableCfg/CompanysealGlobalCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local TimeUtil = require("Utils/TimeUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local NpcGrandcompanyCfg = require("TableCfg/NpcGrandcompanyCfg")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local InteractiveMainPanelVM = require("Game/Interactive/MainPanel/InteractiveMainPanelVM")
local EquipImproveCfg = require("TableCfg/EquipImproveCfg")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Role.GrandCompany.GrandCompanyCmd
local ExchangeSub = ProtoCS.Role.Exchange.ExchangeCmd
local CompanyTaskType = ProtoRes.CompanyTaskType
local LSTR = _G.LSTR
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local JionTipsMask = {
    "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_TheMaelstrom.T_DX_Mask_TheMaelstrom'", --黑涡团
    "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_TheOrderoftheTwinAdder.T_DX_Mask_TheOrderoftheTwinAdder'",--双蛇党
    "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_TheImmortalFlames.T_DX_Mask_TheImmortalFlames'", --恒辉队
}

local JionTipsIcon = {
    "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_TheMaelstrom.UI_InfoTips_Img_TheMaelstrom'", --黑涡团
    "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_TheOrderoftheTwinAdder.UI_InfoTips_Img_TheOrderoftheTwinAdder'",--双蛇党
    "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_TheImmortalFlames.UI_InfoTips_Img_TheImmortalFlames'", --恒辉队
}

local LogoIcon = {
    "Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheMaelstrom.UI_CompanySeal_Img_TheMaelstrom'",
    "Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheOrderoftheTwinAdder.UI_CompanySeal_Img_TheOrderoftheTwinAdder'",
    "Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheImmortalFlames.UI_CompanySeal_Img_TheImmortalFlames'"
}

local BGIcon = {
    "Texture2D'/Game/UI/Texture/CompanySeal/UI_BG_CompanySeal_TheMaelstrom.UI_BG_CompanySeal_TheMaelstrom'",
    "Texture2D'/Game/UI/Texture/CompanySeal/UI_BG_CompanySeal_TheOrderoftheTwinAdder.UI_BG_CompanySeal_TheOrderoftheTwinAdder'",
    "Texture2D'/Game/UI/Texture/CompanySeal/UI_BG_CompanySeal_TheImmortalFlames.UI_BG_CompanySeal_TheImmortalFlames'"
}


local DefineScore = {
    ProtoRes.SCORE_TYPE.SCORE_TYPE_MAELSTROM,       --黑涡团军票
    ProtoRes.SCORE_TYPE.SCORE_TYPE_TWINADDER,       --双蛇党军票
    ProtoRes.SCORE_TYPE.SCORE_TYPE_IMMORTALFLAMES,  --恒辉队军票
    ProtoRes.SCORE_TYPE.SCORE_TYPE_UPGRADE_EXP,  --经验
}

--职业排序规则
local OrderProfessData = {[30] = 1, [28] = 2, [29] = 3, [31] = 4, [33] = 5, [32] = 6, [34] = 7, [35] = 8, [36] = 9, [37] = 10, [38] = 11}

local SortRuler = {
    1, --可提交且HQ满足且倍数大于1
    2, --可提交且HQ满足
    3, --可提交
    4, --不可提交
    5, --未解锁
    6, --已提交
}

--加成军票获得的BUFFID
local DefineBuffID = {
    6,     --部队军票提高
    24,    --部队军票提高II
    42,    --部队军票提高III
    10006, --军用绩效指南
    10024, --军用绩效指南II
    10042, --军用绩效指南III
}

---@class CompanySealMgr : MgrBase
local CompanySealMgr = LuaClass(MgrBase)

---OnInit
function CompanySealMgr:OnInit()
    self.AllTaskList = {} --军需品和补给品任务
    self.TaskTabInfo = {}
    self.MilitaryLevel = 0   --军衔等级
    self.GrandCompanyID = 0  --阵营ID
    self.DataValidTime = nil   --刷新时间
    self.CurChoseTaskIndex = nil --当前选择任务下标
    self.CurChoseTaskID = nil    --当前选择任务ID
    self.CompanySealID = nil     --当前所属阵营军票ID
    self.CurChoseTaskItemID = nil  --选择提交的道具ID
    self.GetRewardList = {} --记录提交会获得的奖励
    self.RareTaskList = {} --稀有品任务
    self.RareChoesdList = {} --稀有品选中的
    self.RecordRareChoesd = {} --记录选中的
    self.RareChoseLimit = 20
    self.CurChosedTabIndex = 1
    self.CompanyRankList = {} -- 军衔等级信息
    self.CurOpenRankID = nil --当前打开晋升界面的阵营ID
    self.CurOpenTransferID = nil --当前打开调动界面的阵营ID
    self.GlobalInfo = {}  --公共信息
    self.CanChangedLevel = nil --可以转阵营的等级
    self.TransferTimeLimit = nil --转阵营时间限制
    self.ExchangeList = {} --选中的稀有品任务ID
    self.MilitaryLevelList = {} --各军队等级信息
    self.TransferTime = nil --转军队刷新时间
    self.TransferCost = nil --转换军队消耗积分
    self.ExchangeMilitaryRankMin = 0 --开启稀有品最低军衔等级
    self.ChosedRareCarryList = {} --选中稀有品中的魔晶石
    self.IsCanSelect = true --是否可以选择稀有品
    self.IsCanPromoted = true --是否可以点击晋升
    self.CurEquipList = {}  --当前装备集
end

---OnBegin
function CompanySealMgr:OnBegin()
    self:GetCompanySealGlobalInfo()
    self:GetCurGrandCompanyInfo()
end

function CompanySealMgr:OnEnd()

end

function CompanySealMgr:OnShutdown()

end

function CompanySealMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdPrepareTask, self.OnNetMsgPrepareTask)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdState, self.OnNetMsgGrandCompanyState)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdFinishPrepareTask, self.OnNetMsgFinishPrepareTask)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdMilitaryUpgrade, self.OnNetMsgMilitaryUpgrade)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdTransferCompany, self.OnNetMsgTransferCompany)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdJoinCompany, self.OnNetMsgJoinCompany)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GRAND_COMPANY, SUB_MSG_ID.GrandCompanyCmdExchangeCompanySeal, self.OnNetMsgExchangeCompanySeal)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_EXCHANGE, ExchangeSub.ExchangeCmdCommon, self.OnNetMsgExchange)
end

function CompanySealMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function CompanySealMgr:OnGameEventLoginRes(Params)
    if not Params.bReconnect then
        self:ClearOldRoleData()
    else
        self.AllTaskList = {}
    end
    
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCompanySeal) then
        self:SendMsgGrandCompanyState()
    end
end

function CompanySealMgr:ClearOldRoleData()
    self.AllTaskList = {}
    self.TaskTabInfo = {}
end

function CompanySealMgr:SendMsgTransferCompany()
    local MsgID = CS_CMD.CS_CMD_GRAND_COMPANY
    local SubMsgID = SUB_MSG_ID.GrandCompanyCmdTransferCompany

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.TransferCompany = {}
    MsgBody.TransferCompany.NewCompany = self.CurOpenTransferID
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CompanySealMgr:SendMsgExchange()
    local MsgID = CS_CMD.CS_CMD_EXCHANGE
    local ExchangeMsgID = ExchangeSub.ExchangeCmdCommon

	local MsgBody = {}
    MsgBody.Cmd = ExchangeMsgID
    MsgBody.CommonExchange  = {}
    MsgBody.CommonExchange.IDList = self.ExchangeList
	GameNetworkMgr:SendMsg(MsgID, ExchangeMsgID, MsgBody) 
end

function CompanySealMgr:SendMsgExchangeCompanySeal()
    local MsgID = CS_CMD.CS_CMD_GRAND_COMPANY
    local SubMsgID = SUB_MSG_ID.GrandCompanyCmdExchangeCompanySeal

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.ExchangeCompanySeal  = {}
    MsgBody.ExchangeCompanySeal.ItemID = self.RecordRareChoesd
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody) 
end

function CompanySealMgr:SendMsgFinishPrepareTask(IsHQ)
    local MsgID = CS_CMD.CS_CMD_GRAND_COMPANY
    local SubMsgID = SUB_MSG_ID.GrandCompanyCmdFinishPrepareTask

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.FinishPrepareTask = {}
    MsgBody.FinishPrepareTask.ID = self.CurChoseTaskID
    MsgBody.FinishPrepareTask.ItemID = self.CurChoseTaskItemID
    self.IsHQ = IsHQ
    self.CurHasSeal = _G.ScoreMgr:GetScoreValueByID(self.CompanySealID)
    _G.LootMgr:SetDealyState(true)
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CompanySealMgr:SendMsgGrandCompanyState()
    local MsgID = CS_CMD.CS_CMD_GRAND_COMPANY
    local SubMsgID = SUB_MSG_ID.GrandCompanyCmdState

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CompanySealMgr:SendMsgPrepareTask(Type)
    local MsgID = CS_CMD.CS_CMD_GRAND_COMPANY
    local SubMsgID = SUB_MSG_ID.GrandCompanyCmdPrepareTask

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.PrepareTask = {}
    MsgBody.PrepareTask.type = Type
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CompanySealMgr:SendMilitaryUpgrade()
    local MsgID = CS_CMD.CS_CMD_GRAND_COMPANY
    local SubMsgID = SUB_MSG_ID.GrandCompanyCmdMilitaryUpgrade

	local MsgBody = {}
    MsgBody.Cmd = SubMsgID 
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function CompanySealMgr:OnNetMsgJoinCompany(MsgBody)
    if MsgBody.JoinCompany.ID then
        self.GrandCompanyID = MsgBody.JoinCompany.ID
        self.MilitaryLevel = MsgBody.JoinCompany.MilitaryRank
        -- local Name = ProtoEnumAlias.GetAlias(ProtoRes.grand_company_type, self.GrandCompanyID)
        -- local Tips = string.format("%s%s", LSTR(1160016), Name) 
        -- FLOG_ERROR("加入的军队ID = %d", MsgBody.JoinCompany.ID)
        -- _G.MsgTipsUtil.ShowTips(Tips)
        local Data = {}
        Data.GrandCompanyID = self.GrandCompanyID
        Data.MilitaryLevel = self.MilitaryLevel
        self:ShowGrandCompanyTips(Data)
        --加入军队后需要把MilitaryLevelList重新请求更新一下
        self:SendMsgGrandCompanyState()
        EventMgr:SendEvent(EventID.CompanySealJionGrandCompany, self.GrandCompanyID)
    end
end

function CompanySealMgr:OnNetMsgTransferCompany(MsgBody)
    --FLOG_ERROR("OnNetMsgTransferCompany =%s", table_to_string(MsgBody))
    if MsgBody.TransferCompany then
        self.MilitaryLevel = MsgBody.TransferCompany.MilitaryRank
        self.GrandCompanyID = MsgBody.TransferCompany.ID
        -- local Name = ProtoEnumAlias.GetAlias(ProtoRes.grand_company_type, self.GrandCompanyID)
        -- local Tips = string.format("%s%s", LSTR(1160016), Name) 
        -- _G.MsgTipsUtil.ShowTips(Tips)
        UIViewMgr:HideView(UIViewID.CompanySealTransferWinView)
        self:IsEndInteraction()
        local Data = {}
        Data.GrandCompanyID = self.GrandCompanyID
        Data.MilitaryLevel = self.MilitaryLevel
        self:ShowGrandCompanyTips(Data)
        self:SendMsgGrandCompanyState()
        EventMgr:SendEvent(EventID.CompanySealJionGrandCompany, self.GrandCompanyID)
    end
end

function CompanySealMgr:OnNetMsgExchange(MsgBody)
    --FLOG_ERROR("OnNetMsgExchange =%s", table_to_string(MsgBody))
    self.RareTaskList = {}
    self.RecordRareChoesd = {}
    self.ExchangeList = {}
    self.ChosedRareCarryList = {}
    EventMgr:SendEvent(EventID.CompanySealUpdateRareView)  
end

function CompanySealMgr:OnNetMsgExchangeCompanySeal(MsgBody)
    --FLOG_ERROR("OnNetMsgExchange =%s", table_to_string(MsgBody))
    self.RareTaskList = {}
    self.RecordRareChoesd = {}
    self.ExchangeList = {}
    self.ChosedRareCarryList = {}
    self.IsCanSelect = false
    EventMgr:SendEvent(EventID.CompanySealUpdateRareView, true)
end

function CompanySealMgr:OnNetMsgFinishPrepareTask(MsgBody)
    --FLOG_ERROR("OnNetMsgFinishPrepareTask =%s", table_to_string(MsgBody))
    self:SetFinishTaskState(MsgBody.FinishPrepareTask.ID)
    local Temp = {}
    local Params = {}
    if MsgBody.FinishPrepareTask.ID then
        local RewardNum, RewardExp = self:GetTaskRewardNum(MsgBody.FinishPrepareTask.ID)
        for i = 1, 2 do
            local ItemID
            local GetNum
            if i == 1 then
                ItemID = DefineScore[4]
                GetNum = RewardExp or 0
            else
                ItemID = self.CompanySealID
                local MaxLimit = self:GetCurRankScoreMax(self.GrandCompanyID, self.MilitaryLevel)
                GetNum = RewardNum or 0
                if self.CurHasSeal + GetNum > MaxLimit then
                    GetNum = MaxLimit - self.CurHasSeal
                end
            end

            if GetNum > 0 then
                table.insert(Temp,
                {
                    ResID = ItemID,
                    Num = GetNum,
                })
            end
        end
        Params.ItemList = Temp
        Params.Title = LSTR(1160050)
        UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
    end
    -- if self.IsHQ then
    --     local ItemLevel = ItemCfg:FindCfgByKey(self.CurChoseTaskItemID).ItemLevel or 0
    --     EventMgr:SendEvent(EventID.CompanySealPlaySubHQItem, ItemLevel)
    -- end
end

function CompanySealMgr:GetTaskRewardNum(TaskID)
    local Num = 0
    local Exp = 0
    if self.AllTaskList[self.CurChosedTabIndex] then
        for Index, Info in pairs(self.AllTaskList[self.CurChosedTabIndex].TaskList) do
            if Info.ID == TaskID then
                if self.IsHQ then
                    Num = Info.CompanySeal * Info.Times * 2
                    Exp = Info.Exp * Info.Times * 2
                else
                    Num = Info.CompanySeal * Info.Times
                    Exp = Info.Exp * Info.Times
                end
            end
        end
    end

    return Num, Exp
end

function CompanySealMgr:OnNetMsgGrandCompanyState(MsgBody)
    --FLOG_ERROR("OnNetMsgGrandCompanyState = %s",table_to_string(MsgBody))
    if MsgBody.State then
        self.GrandCompanyID = MsgBody.State.ID
        self.MilitaryLevel = MsgBody.State.MilitaryRanks[self.GrandCompanyID] or 0
        self.MilitaryLevelList = MsgBody.State.MilitaryRanks
        self.TransferTime = MsgBody.State.TransferTime
        self.CompanySealID = DefineScore[self.GrandCompanyID]
        local RoleVM = MajorUtil.GetMajorRoleVM()
		if RoleVM then
			RoleVM:SeGrandCompInfo(self.GrandCompanyID, self.MilitaryLevel)
		end
    end
end

function CompanySealMgr:OnNetMsgPrepareTask(MsgBody)
    --todo需要注意刷新时间
    self:SetAllTaskInfo(MsgBody)
end

function CompanySealMgr:OnNetMsgMilitaryUpgrade(MsgBody)
    --FLOG_ERROR("OnNetMsgMilitaryUpgrade = %s",table_to_string(MsgBody))
    if MsgBody.MilitaryUpgrade then
        self:IsEndInteraction()
        self.MilitaryLevel = MsgBody.MilitaryUpgrade.MilitaryRank
        -- local Tips = LSTR(1160038) 
        -- _G.MsgTipsUtil.ShowTips(Tips)
        local Data = {}
        Data.GrandCompanyID = self.GrandCompanyID
        Data.MilitaryLevel = self.MilitaryLevel
        EventMgr:SendEvent(EventID.CompanySealPlayLvUPAni, Data)

        --UIViewMgr:HideView(UIViewID.CompanySealPromotionWinView)
        self:SendMsgGrandCompanyState()
        EventMgr:SendEvent(EventID.CompanySealRankUp, self.MilitaryLevel)
    end
end

--清除稀有品选中信息
function CompanySealMgr:ClearInfo()
    self.RecordRareChoesd = {}
	self.ExchangeList = {}
	self.ChosedRareCarryList = {}
    self:SetRareChoesdList()
end

function CompanySealMgr:ClearRareTaskList()
    self.RareTaskList = {}
end

function CompanySealMgr:SetFinishTaskState(TaskID)
    local TaskList = self.AllTaskList[self.CurChosedTabIndex].TaskList
    for i = 1, #TaskList do
        if TaskList[i].ID == TaskID then
            TaskList[i].State = SortRuler[6]
            TaskList[i].IsHQ = self.IsHQ
            break
        end
    end

    table.sort(TaskList, self.SortTaskList)
    EventMgr:SendEvent(EventID.CompanySealUpdateTaskInfo, TaskList)
end

function CompanySealMgr:SetAllTaskInfo(MsgBody)
    local List = {}
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    List.Type = MsgBody.PrepareTask.type
    self.DataValidTime = MsgBody.PrepareTask.DataValidTime
    List.TaskList = {}
    local MsgTaskList = MsgBody.PrepareTask.TaskList
    local TaskLen = #MsgBody.PrepareTask.TaskList
    for i = 1, TaskLen do
        local Info = CompanysealCfg:FindCfgByKey(MsgTaskList[i].ID)
        local Data = {}
        Data.ID = Info.ID
        Data.TaskType = Info.TaskType
        Data.CraftJobID = Info.CraftJobID
        Data.Level = Info.Level
        Data.NQItemID = Info.NQItemID
        Data.HQItemID = Info.HQItemID
        Data.ItemName = ItemUtil.GetItemName(Info.NQItemID)
        local HasNQItemNum, HasHQItemNum = self:GetEquipNum(Info.NQItemID, Info.HQItemID)
        Data.Num = Info.Num
        Data.Exp = Info.Exp
        Data.CompanySeal = Info.CompanySeal
        Data.Times = MsgTaskList[i].Times
        Data.Sort = OrderProfessData[Info.CraftJobID] or 0
        if RoleDetail then
            if RoleDetail.Prof.ProfList[Info.CraftJobID] ~= nil then
                Data.UnLock = true
            else
                Data.UnLock = false
            end
        else
            FLOG_ERROR("CompanySealMgr:SetAllTaskInfo RoleDetail = nil")
            Data.UnLock = false
        end
        local State = self:SetTaskState(MsgTaskList[i].State, Data.UnLock, HasNQItemNum, HasHQItemNum, Info.Num, Data.Times)
        Data.State = State
        table.insert(List.TaskList, Data)
    end
    self.AllTaskList[List.Type] = List
    table.sort(List.TaskList, self.SortTaskList)
    EventMgr:SendEvent(EventID.CompanySealUpdateTaskInfo, List.TaskList)
end

function CompanySealMgr:UpdateTaskState(List)
    local TaskList = List
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    for i = 1, #TaskList do
        local IsUnLock = false
        if RoleDetail.Prof.ProfList[TaskList[i].CraftJobID] ~= nil then
            IsUnLock = true
        else
            IsUnLock = false
        end
        local NQItemID = TaskList[i].NQItemID
        local HQItemID = TaskList[i].HQItemID
        local HasNQItemNum, HasHQItemNum = self:GetEquipNum(NQItemID, HQItemID)
        
    
        local IsFinish = (TaskList[i].State == SortRuler[6]) and 1 or 0
        local State = self:SetTaskState(IsFinish, IsUnLock, HasNQItemNum, HasHQItemNum, TaskList[i].Num, TaskList[i].Times)
        TaskList[i].State = State
    end
    table.sort(TaskList, self.SortTaskList)
end

function CompanySealMgr:GetEquipNum(NQItemID, HQItemID)
    local IsEquip = ItemUtil.CheckIsEquipmentByResID(NQItemID)
    if not IsEquip then
        local HasNQItemNum = BagMgr:GetItemNum(NQItemID)
		local HasHQItemNum = BagMgr:GetItemHQNum(NQItemID)
		return HasNQItemNum, HasHQItemNum
    else
        self:GetBagEquipList()   --重新更新一下equiplist
    end

    local Data = {}	
    for _, value in pairs(self.CurEquipList) do
        if value.ResID == NQItemID or value.ResID == HQItemID then
            local IsInScheme = value.Attr.Equip.IsInScheme
            local CarryList = value.Attr.Equip.GemInfo.CarryList
            local HasCarry = false
            for _, CarryInfo in pairs(CarryList) do
                if CarryInfo then
                    HasCarry = true
                    break
                end
            end

            if  not IsInScheme and not HasCarry then
                table.insert(Data, value.ResID)
            end
        end
    end

    local HasNQItemNum = 0
    local HasHQItemNum = 0
    for _, ResID in pairs(Data) do
        local IsHQ = ItemUtil.IsHQ(ResID)
        if IsHQ then
            HasHQItemNum = HasHQItemNum + 1
        else
            HasNQItemNum = HasNQItemNum + 1
        end
    end
    return HasNQItemNum, HasHQItemNum
end

function CompanySealMgr:GetCompanySealGlobalInfo()
    local ParamsID = {
        ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferMilitaryRankMin,
        ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferCD,
        ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferCost,
        ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamItemExchangeMilitaryRankMin,
        --ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferTips,
    }
    for i = 1, #ParamsID do
        local AllCfg = CompanysealGlobalCfg:FindCfgByKey(ParamsID[i])
        self.GlobalInfo[ParamsID[i]] = AllCfg
    end

    self.ExchangeMilitaryRankMin = self.GlobalInfo[ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamItemExchangeMilitaryRankMin].Value[1]
    self.TransferCost = self.GlobalInfo[ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferCost].Value[1]
    self.TransferTimeLimit = self.GlobalInfo[ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferCD].Value[1]
    self.CanChangedLevel = self.GlobalInfo[ProtoRes.GrandCompanyGlobalParamType.GrandCompanyGlobalParamTransferMilitaryRankMin].Value[1] or 6
end

function CompanySealMgr:GetAllTaskInfo(Index)
    --需要注意申请时机
    --self:SendMsgPrepareTask(Index)
    if self.AllTaskList[Index] == nil then
        self:SendMsgPrepareTask(Index)
    else
        local ServerTime = TimeUtil.GetServerTime()
        if ServerTime > self.DataValidTime then
            self:SendMsgPrepareTask(Index)
        else
            self:UpdateTaskState(self.AllTaskList[Index].TaskList)
            return self.AllTaskList[Index].TaskList
        end
    end
end

function CompanySealMgr:GetBagEquipList()
	local EquipList = BagMgr:FilterItemByCondition(function(Item)
		return ItemUtil.CheckIsEquipmentByResID(Item.ResID)
	end)
    self.CurEquipList = EquipList
    local Index = 1
    for i = 1, #EquipList do
        local EquipInfo = EquipmentCfg:FindCfgByEquipID(EquipList[i].ResID)
        --改良过的装备不可提交
        --local IsImprove = self:EquipIsImprove(EquipList[i].ResID)
        local IsInScheme = EquipList[i].Attr.Equip.IsInScheme

        local CarryList = EquipList[i].Attr.Equip.GemInfo.CarryList
        local HasCarry = false
        for _, value in pairs(CarryList) do
            if value then
                HasCarry = true
                break
            end
        end

        if EquipInfo then
            if EquipInfo.ExchangeCompanySealNum > 0 and not IsInScheme and not HasCarry then
                local ItemInfo = ItemCfg:FindCfgByKey(EquipList[i].ResID)
                EquipList[i].Index = Index
                EquipList[i].TargetItemNum = EquipInfo.ExchangeCompanySealNum
                EquipList[i].ItemLevel = ItemInfo.ItemLevel
                EquipList[i].ItemColor = ItemInfo.ItemColor
                self.RareTaskList[Index] = EquipList[i]
                Index = Index + 1
            end
        end
    end

    table.sort(self.RareTaskList, self.SortEquipList)

    for k, v in ipairs(self.RareTaskList) do
        v.Index = k
    end
end

function CompanySealMgr:GetTabInfo()
    local List = {}
    for _, V in pairs(CompanyTaskType) do
        if V ~= 0 then
            local Data = {}
            Data.Index = V
            Data.Key = V
            Data.Name = ProtoEnumAlias.GetAlias(CompanyTaskType, V)
            table.insert(List, Data)
        end
    end
    table.sort(List, self.SortTabList)
    return List
end

function CompanySealMgr:GetScoreInfo()
    return DefineScore[self.GrandCompanyID] or DefineScore[1]
end

function CompanySealMgr:GetScoreInfoByID(GrandCompanyID)
    return DefineScore[GrandCompanyID]
end

function CompanySealMgr:SetRareChoesdList()
    for i = 1, self.RareChoseLimit do
        if self.RareChoesdList[i]then
            self.RareChoesdList[i].Index = 0
            self.RareChoesdList[i].ItemID = nil
            self.RareChoesdList[i].EquipGID = 0
        else
            self.RareChoesdList[i] = {}
            self.RareChoesdList[i].IsRare = true
            self.RareChoesdList[i].Index = 0
            self.RareChoesdList[i].EquipGID = 0
        end
    end
end

function CompanySealMgr:SetTaskState(IsFinish, IsUnLock, HasNQItemNum, HasHQItemNum, NeedNum, Times)
    local State = 0

    if not IsUnLock then                                    --未解锁
        State = SortRuler[5]
        return State
    end

    if IsFinish == 0 and HasHQItemNum >= NeedNum  then      
        if Times > 1 then                                   --可提交且HQ满足且倍数大于1
            State = SortRuler[1]
        else
            State = SortRuler[2]                            --可提交且HQ满足
        end
    elseif IsFinish == 0 and HasNQItemNum >= NeedNum then   --可提交
        State = SortRuler[3]
    elseif IsFinish == 0 and HasNQItemNum < NeedNum or IsFinish == 0 and HasHQItemNum < NeedNum  then  --不可提交
        State = SortRuler[4]
    elseif IsFinish == 1 then                               --已提交
        State = SortRuler[6]
    end

    return State
end

function CompanySealMgr.SortTaskList(L, R)
    if L.State ~= R.State then
        return L.State < R.State
    elseif L.State == R.State then
        if L.Level ~= R.Level then
            return L.Level > R.Level
        else
            return L.Sort < R.Sort
        end
    end
end

function CompanySealMgr.SortTabList(L, R)
    if L.Index < R.Index then
        return true
    else
        return false
    end
end

function CompanySealMgr.SortEquipList(L, R)
    if L.ResID == 0 or R.ResID == 0 then
        return false
    end

    if L.ItemColor ~= R.ItemColor then
        return L.ItemColor < R.ItemColor
    end

    if L.ItemLevel ~= R.ItemLevel then
        return L.ItemLevel < R.ItemLevel
    end

    return L.ResID < R.ResID
end

function CompanySealMgr:DealNewTable(old)
	local NewTab = old
    local insertPos = 1
    local Len = #NewTab

    for i = 1, Len do
        if NewTab[i].Index ~= 0 then
            NewTab[insertPos] = NewTab[i]
            insertPos = insertPos + 1
        end
    end

    for i = insertPos, Len do
        NewTab[i] = {}
        NewTab[i].IsRare = true
    end

	CompanySealMgr.RareChoesdList = NewTab
end

function CompanySealMgr:GetCurGrandCompanyInfo()
    for _, v in pairs(ProtoRes.grand_company_type) do
        if v ~= 0 then
            local CompanyID = v
            local SearchCond = string.format("CompanyID == %d", CompanyID)
            local AllCfg = CompanysealRankCfg:FindAllCfg(SearchCond)
            self.CompanyRankList[CompanyID] = AllCfg
        end
    end
end

--筹备任务
function CompanySealMgr:OpenCompanyTaskView()
    if self.GrandCompanyID == 0 then
        local Tips = LSTR(1160030)
        _G.MsgTipsUtil.ShowTips(Tips)
        self:IsEndInteraction()
        return
    end
    UIViewMgr:ShowView(UIViewID.CompanySealMainPanelView)
end

--查看军衔 ID 1 黑涡团 2 双蛇党 3 恒辉队
function CompanySealMgr:OpenCompanyRankView(ID)
    local Data = {}
    Data.GrandCompanyID = ID
    self.CurOpenRankID = ID
    UIViewMgr:ShowView(UIViewID.CompanySealInfoPanelView, Data)
end

--军衔晋升界面
function CompanySealMgr:OpenPromotionView(bIgSetVis)
    if self.GrandCompanyID == 0 then
        local Tips = LSTR(1160030)
        _G.MsgTipsUtil.ShowTips(Tips)
        self:IsEndInteraction()
        return
    end
    local IsOpen, TaskName = self:CheckCurPromotionTask()
    if IsOpen then
        UIViewMgr:ShowView(UIViewID.CompanySealPromotionWinView)
    else
        local Content = string.format("%s<span color=\"#d1ba8e\">%s</>%s", LSTR(1160056), TaskName, LSTR(1160005))
        local function EenterInteractive()
            if not bIgSetVis then
                InteractiveMainPanelVM:SetFunctionVisible(true)
            end
        end
        _G.MsgBoxUtil.ShowMsgBoxOneOpRight(nil, LSTR(1160039), Content, EenterInteractive, LSTR(1160044))
    end
end

--打开军队调动界面
---@param ID number@NPC阵营ID
function CompanySealMgr:OpenCompanyTransferView(ID) 
    if ID == self.GrandCompanyID then
        self:IsEndInteraction()
        return
    end

    if self.GrandCompanyID == 0 then
        local Tips = LSTR(1160030)
        _G.MsgTipsUtil.ShowTips(Tips)
        self:IsEndInteraction()
        return
    end

    local Data = {}
    Data.GrandCompanyID = ID
    self.CurOpenTransferID = ID
    UIViewMgr:ShowView(UIViewID.CompanySealTransferWinView, Data)
end

--检查打开军衔晋升界面所需的任务是否完成
function CompanySealMgr:CheckCurPromotionTask()
    local IsOpen = false
    local TaskName = ""
    if self.GrandCompanyID ~= 0 then
        local CompanyRankList =  self.CompanyRankList[self.GrandCompanyID]
        if not CompanyRankList then
            FLOG_ERROR("CheckCurPromotionTask CompanyRankList = nil")
            print(self.GrandCompanyID)
            return false, TaskName
        end
        local CurLevel = self.MilitaryLevel or 1
        local NextLevel = math.min(CurLevel + 1, #CompanyRankList)
        local Task = CompanyRankList[NextLevel].PromotionTask
        if Task ~= 0 then
            TaskName = _G.QuestMgr:GetQuestName(Task)
            local PreTaskState = _G.QuestMgr:GetQuestStatus(Task)
            if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
                IsOpen = true
            end    
        else
            IsOpen = true
        end
    end

    return IsOpen, TaskName
end

--军队Tips
function CompanySealMgr:ShowGrandCompanyTips(List)
    local IsOnDirectUp = _G.ModuleOpenMgr:GetIsOnDirectUpState()
    if IsOnDirectUp then
        return
    end
    local CompanyRank = self.CompanyRankList[List.GrandCompanyID]
    local RankName = ""
    local RankIcon = ""
    if CompanyRank then
        local MilitaryLevelInfo = CompanyRank[List.MilitaryLevel]
        if MilitaryLevelInfo then
            RankIcon = MilitaryLevelInfo.Icon or ""
            RankName = MilitaryLevelInfo.RankName or ""
        end
    end
    local Params = { IsMentorTrigger = true, SysNotice = ProtoEnumAlias.GetAlias(ProtoRes.grand_company_type, self.GrandCompanyID), SubSysNotice = RankName,
    Icon = JionTipsIcon[List.GrandCompanyID],
    SubTitleIcon = true,
    IconSubTitle = RankIcon,
    IconMask = JionTipsMask[List.GrandCompanyID],}
    _G.MsgTipsUtil.ShowGrandCompanyTips(Params)
    -- _G.UIViewMgr:ShowView(UIViewID.InfoContentUnlockTips, Params) 
    local function DelaySetState()
     self.IsCanPromoted = true
     self:UnRegisterTimer(self.DelayTimerID)
	 self.DelayTimerID = nil
    end
    self.DelayTimerID = self:RegisterTimer(DelaySetState, 4, 0, 0)
end

function CompanySealMgr:GetAllCarryInfo(List)
    local Info = {}
    for GID, EquipInfo in pairs(List) do
        if #EquipInfo.CarryList > 0 then
            EquipInfo.GID = GID
            table.insert(Info, EquipInfo)
        end
    end

    return Info
end

--获取军队信息
---@return List
---@param List.GrandCompanyID 当前所属军队ID 0为未加入军队 1 黑涡团 2 双蛇党 3 恒辉队
---@param List.MilitaryLevelList 当前加入过的军队信息 list[1]= 黑涡团军衔等级 list[2]= 双蛇党军衔等级 list[3]= 恒辉队军衔等级 list[i]值为军队军衔等级 大于0说明加入了该军队
function CompanySealMgr:GetCompanySealInfo()
    local List = {}
    List.GrandCompanyID = self.GrandCompanyID or 0
    List.MilitaryLevelList = self.MilitaryLevelList or {}
    return List
end

function CompanySealMgr:GetGrandCompanyIDByScoreID(ScoreID)
	if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_MAELSTROM then						--- 黑涡团军票
		return ProtoRes.grand_company_type.GRAND_COMPANY_TYPE_Maelstrom
	elseif ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_TWINADDER then					--- 双蛇党军票
		return ProtoRes.grand_company_type.GRAND_COMPANY_TYPE_OrderOfTheTwinAdder
	elseif ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_IMMORTALFLAMES then					--- 恒辉队军票
		return ProtoRes.grand_company_type.GRAND_COMPANY_TYPE_ImmortalFlames
	end
    return ProtoRes.grand_company_type.GRAND_COMPANY_TYPE_None
end

--- 跳转表调用
function CompanySealMgr:IsOpenCompany()
    local CompoanySealInfo = self:GetCompanySealInfo()

    return CompoanySealInfo.GrandCompanyID ~= 0 
end

--- 是否是军队军票
function CompanySealMgr:IsCompanyScore(ID)
    for i = 1, 3, 1 do
        if DefineScore[i] == ID then
            return true
        end
    end
    
    return false
end

-- 查询是否拥有军票加成状态Buff
---@return boolen IsHasBuff
---@return number CurBuffID
function CompanySealMgr:HasCompanySealBuff()
    local CurBuffID = 0
    local IsHasBuff = false
    for i = 1, #DefineBuffID do
        if _G.BonusStateMgr:HasBonusStateMajor(DefineBuffID[i]) then
            IsHasBuff = true
            CurBuffID = DefineBuffID[i]
            return IsHasBuff, CurBuffID
        end
    end

    return IsHasBuff, CurBuffID
end

--获取当前军队军衔等级
function CompanySealMgr:GetGrandCompanyRank()
    return self.MilitaryLevel or 0
end

--获取当前军衔图标
---@param ID number@阵营ID
---@return string @图标路径
function CompanySealMgr:GetGrandCompanyRankIcon(ID, Lv)
    local Icon = ""
    if CompanySealMgr.CompanyRankList[ID] then
        Icon = CompanySealMgr.CompanyRankList[ID][Lv].Icon or ""
    end
    return Icon
end

function CompanySealMgr:GetSortRuler(State)
    return SortRuler[State]
end

function CompanySealMgr:GetGrandCompanyRankName()
    local GrandCompanyID = self.GrandCompanyID
    if GrandCompanyID == 0 then return "" end
    local GrandCompanyRank = self:GetGrandCompanyRank()
    if GrandCompanyRank == 0 then return "" end
    local CompanyInfo = self.CompanyRankList[GrandCompanyID]
    if CompanyInfo then
        local CompanyRankInfo = CompanyInfo[GrandCompanyRank]
        if CompanyRankInfo then
            return CompanyRankInfo.RankName
        end
    end
    return ""
end

function CompanySealMgr:GetMilitaryLeveByScoreID(ScoreID)
    local Rank = 1
    if ScoreID == DefineScore[1] then
        if self.MilitaryLevelList[1] ~= nil and self.MilitaryLevelList[1] > 0 then
            Rank = self.MilitaryLevelList[1]
        end
    elseif ScoreID == DefineScore[2] then
        if self.MilitaryLevelList[2] ~= nil and self.MilitaryLevelList[2] > 0 then
            Rank = self.MilitaryLevelList[2]
        end
    elseif ScoreID == DefineScore[3] then
        if self.MilitaryLevelList[3] ~= nil and self.MilitaryLevelList[3] > 0 then
            Rank = self.MilitaryLevelList[3]
        end
    end
    
    return Rank
end

function CompanySealMgr:GetMilitaryLvByGrandCompanyID(GrandCompanyID)
    local Rank = 1
    if self.MilitaryLevelList[GrandCompanyID] ~= nil and self.MilitaryLevelList[GrandCompanyID] > 0 then
        Rank = self.MilitaryLevelList[GrandCompanyID]
    end
    
    return Rank
end

---@return bool @用于判断稀有品提交时是否积分达上限 没达上限则可提交
function CompanySealMgr:GetCurSealIsMax()
    local ScoreID = self:GetScoreInfo()
	local CurHas = _G.ScoreMgr:GetScoreValueByID(ScoreID)
	local MaxLimit = self:GetCurRankScoreMax(self.GrandCompanyID, self.MilitaryLevel)
    if CurHas < MaxLimit then
        return true
    else
        return false
    end
end

--获取当前军衔等级积分上限
---@param GrandCompanyID number@阵营ID
---@param MilitaryLevel number@阵营等级
function CompanySealMgr:GetCurRankScoreMax(GrandCompanyID, MilitaryLevel)
    local MaxLimit = 0
    local CompanyRank = self.CompanyRankList[GrandCompanyID]
    if CompanyRank then
        local MilitaryLevelInfo = CompanyRank[MilitaryLevel]
        if MilitaryLevelInfo then
            MaxLimit = MilitaryLevelInfo.CompanySealMax or 0
        end
    end

    return MaxLimit
end

--获取军衔信息
---@param ID number@阵营ID
---@param Lv number@阵营等级
---@return List @List.RankName 军衔名字 @List.Icon 军衔图标路径
function CompanySealMgr:GetRankInfo(ID, Lv)
    local GrandCompanyInfo = {}
    local Level = Lv or 1
    local CompanyRank = self.CompanyRankList[ID]
    if CompanyRank then
        local MilitaryLevelInfo = CompanyRank[Level]
        if MilitaryLevelInfo then
            GrandCompanyInfo.Icon = MilitaryLevelInfo.Icon or ""
            GrandCompanyInfo.RankName = MilitaryLevelInfo.RankName or ""
        end
    end

    return GrandCompanyInfo
end

--判断NPC是否需要显示查看军衔信息
function CompanySealMgr:IsShowRankInfo()
    if self.GrandCompanyID and self.GrandCompanyID ~= 0 then
        return true
    else
        return false
    end
end

--判断NPC是否需要显示军队调动交互
function CompanySealMgr:IsShowTransfer(EntityID)
    local NpcID = ActorUtil.GetActorResID(EntityID)
    local NpcGrandcompanyInfo = NpcGrandcompanyCfg:FindCfgByKey(NpcID)
    if NpcGrandcompanyInfo then
        if self.GrandCompanyID ~= 0 and NpcGrandcompanyInfo.GrandCompanyID ~= self.GrandCompanyID then
            return true
        end
    end

    return false
end

--判断NPC是否需要显示军队筹备任务和军衔晋升
function CompanySealMgr:IsShowTaskAndPromotion(EntityID)
    local NpcID = ActorUtil.GetActorResID(EntityID)
    local NpcGrandcompanyInfo = NpcGrandcompanyCfg:FindCfgByKey(NpcID)
    if NpcGrandcompanyInfo then
        if self.GrandCompanyID ~= 0 and NpcGrandcompanyInfo.GrandCompanyID == self.GrandCompanyID then
            return true
        end
    end

    return false
end

function CompanySealMgr:EquipIsImprove(EquipID)
    local ImproveSearchCond = string.format("ImprovedID == %d", EquipID)
    local IsImprove = EquipImproveCfg:FindCfg(ImproveSearchCond)

    return IsImprove
end

--查询晋升状态
function CompanySealMgr:CheckPromotioState()
    local IsCanPromot = false
    local RankList = self.CompanyRankList[self.GrandCompanyID] or {}
    local CurLv = self.MilitaryLevel
    local NextLv = CurLv + 1

    if #RankList == 0 then
        return IsCanPromot
    end
    
    if NextLv > #RankList then
        return IsCanPromot
    end

    local IsFinish
    local CurHas = _G.ScoreMgr:GetScoreValueByID(self.CompanySealID)
    local PromotionTask = RankList[NextLv].PromotionTask
    local PromotionCompanySeal = RankList[NextLv].PromotionCompanySeal

    if PromotionTask ~= 0 then
		local PreTaskState = _G.QuestMgr:GetQuestStatus(PromotionTask)
		if PreTaskState == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
            IsFinish = true
		else
			IsFinish = false
        end

	else
		IsFinish = true
	end

    if IsFinish and CurHas >= PromotionCompanySeal and self.MilitaryLevel ~= 0 then
        IsCanPromot = true
    else
        IsCanPromot = false
    end

    return IsCanPromot
end

function CompanySealMgr:GetLockProfInfo(Prof)
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDJobQuest) then
        _G.AdventureCareerMgr:JumpToTargetProf(Prof)
        return
    end
    local CurChapterID = 0
    local ProfTask = _G.AdventureCareerMgr:GetCurProfTaskData(Prof)
    for _, TaskInfo in ipairs(ProfTask) do
        if TaskInfo.RewardType == 1 then
            CurChapterID = TaskInfo.ChapterID
            break
        end
    end

    if not CurChapterID or CurChapterID == 0 then
        FLOG_ERROR("GetLockProfInfo CurChapterID Error")
        return
    end

    local ChapterCfg = _G.AdventureCareerMgr:GetChapterCfgData(CurChapterID)
    local MapID = ChapterCfg.MapID
    if MapID == 12001 or MapID == 12002 then
        _G.AdventureCareerMgr:JumpChapterOnMap(CurChapterID)
    else
        _G.MsgTipsUtil.ShowTips(LSTR(1160071))--"冒险笔记尚未解锁，完成12级主线任务后可查看"
    end
end

function CompanySealMgr:GetRareTaskList()
    local List = table.clone(self.RareTaskList)
    local Len = #List

    if #List == 0 then
        return List
    end

    if Len < 15 then
        local Surplus = 15 - Len
        for i = 1, Surplus do
            local Data = {}
            Data.ResID = 0
            table.insert(List, Data)
        end
    else
        local Row = math.floor(Len / 3)
        local Remain = Len % 3
        local NeedAdd = (Remain == 0 and 0) or (3 - Remain)

        if NeedAdd > 0 then
            for i = 1, NeedAdd do
                local Data = {}
                Data.ResID = 0
                table.insert(List, Data)
            end
        end
    end

    return List
end


function CompanySealMgr:GetLogoPath(GrandCompanyID)
    return LogoIcon[GrandCompanyID]
end

function CompanySealMgr:GetBgPath(GrandCompanyID)
    return BGIcon[GrandCompanyID]
end


function CompanySealMgr:IsEndInteraction()
    local PersonInfoMainPanel = _G.UIViewMgr:FindView(UIViewID.PersonInfoMainPanel)
    if not PersonInfoMainPanel or _G.NpcDialogMgr:IsDialogPanelVisible() or _G.InteractiveMgr.bLockTimer then
        _G.NpcDialogMgr:EndInteraction()
    end
end


return CompanySealMgr
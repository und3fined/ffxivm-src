local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ScoreMgr = require("Game/Score/ScoreMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local SysnoticeCfg = require("TableCfg/SysnoticeCfg")
local MsgTipsID = require("Define/MsgTipsID")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local JumboCactpotDynaMgr = require("Game/JumboCactpot/JumboCactpotDynaMgr")
local JumboCactpotLottoryCeremonyMgr = require("Game/JumboCactpot/JumboCactpotLottoryCeremonyMgr")
local MainPanelVM = require("Game/Main/MainPanelVM")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local FairycolorgRankingCfg = require("TableCfg/FairycolorgRankingCfg")
local TimeUtil = require("Utils/TimeUtil")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local MajorUtil = require("Utils/MajorUtil")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local ItemUtil = require("Utils/ItemUtil")
local ItemGetaccesstypeCfg = require("TableCfg/ItemGetaccesstypeCfg")
local InteractiveMainPanelVM = require("Game/Interactive/MainPanel/InteractiveMainPanelVM")
local ScoreCfg = require("TableCfg/ScoreCfg")
local ArmyMgr = require("Game/Army/ArmyMgr")
local CommonDefine = require("Define/CommonDefine")
local LocalizationUtil = require("Utils/LocalizationUtil")
local NpcDialogMgr = _G.NpcDialogMgr
local ProtoCommon = require("Protocol/ProtoCommon")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local AudioUtil = require("Utils/AudioUtil")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

local AsyncReqModuleType = GoldSauserMainPanelDefine.AsyncReqModuleType
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local PWorldMgr = _G.PWorldMgr
local CS_CMD = ProtoCS.CS_CMD
local EventMgr = _G.EventMgr
local EventID = _G.EventID
-- local FairyColorState = ProtoCS.FairyColorState
local FairyColorStatus = ProtoCS.FairyColorStatus
local FairyColorPlayerStatus = ProtoCS.FairyColorPlayerStatus
local QueryType = {
    QueryCurState = 1,
    QueryPurNum = 2,
}
local WaitTime = 10
local JumboAreaID = 1100000
local OnDaySeconds = 86400



---@class JumboCactpotMgr : MgrBase
local JumboCactpotMgr = LuaClass(MgrBase)

function JumboCactpotMgr:OnInit()
    self.JDMapID = 12060
    self.JDResID = 1008204
    self.JumbState = FairyColorStatus.FairyColorStatusWait
    self.PlayerState = FairyColorPlayerStatus.FairyColorPlayerNotBuy
    self.MaxStage = 7 -- 最大第七阶段
    self.WinNumber = "1984"           -- 中奖号码
    self.BoughtNum = 0                      -- 购买人数
    self.CurrStage = 0                       -- 当前完成了第几阶段开启
    self.Term = 0                           -- 第几期
    self.PurchasedNumList = {}                  -- 购买过的号码
    self.LotteryTime = 0                    -- 开奖时间戳
    self.RemainPurchases = 3                -- 剩余购买次数
    self.NeedJdNum = 100                    -- 需要消耗的金碟币
    self.IntervalTime = 2                   -- 开奖动画播放间隔时间
    self.LoopCount = 6                      -- loop动画播放的次数
    self.DianSelectIndex = 0                -- 目前的中奖履历页签Index
    self.LastTerm = 1
    self.RecordItemsInfos = {}              -- 中奖履历主界面item信息
    self.RecordListItemInfos = {}           -- 中奖履历界面往期中奖名单item信息
    self.ExchangeItemInfos = {}             -- 奖励兑换界面item信息
    self.BuyersItemsInfos = {}              -- 购买人数界面item信息
    self.bEnterWrold = false                -- 是否已经进入时间，防止OnWorldReady事件重复调用
    self.bEnterWeakNetState = false         -- 判断是否进入了弱网，如果进入了弱网，下次打开页面加载数据
    self.MaxXCTicketNum = self.MaxValue ~= nil and self.MaxValue or 0
    self.OneTimeExNum = 0                   -- 记录这一次交换的仙彩券数量
    self.ExchangeNum = 0                    -- 兑换仙彩券的总数量
    self.RichBoughtNum = {}
    self.ResumSlideData = {}
    self.EntranceItem = {}                  -- 存有对话Npc的信息
    self.bIsBuy = false                     -- 这次打开界面是否进行了购买操作
    self.bInBuying = false                  -- 此次是否在购买过程中
    self.bPlayLottoryAnim = false
    -- self.bInOpenLotteryPro = false          -- 与兑奖Npc对话避免重复领奖
    self.bClickBtnWaitOpen = false
    self.CurStagePro = 0
    self.PurTerm = nil                      -- 购买的期数
    self.TipsIDtable = {
        [1] = MsgTipsID.JumbocactOpen1,
        [2] = MsgTipsID.JumbocactOpen2,
        [3] = MsgTipsID.JumbocactOpen3,
        [4] = MsgTipsID.JumbocactOpen4,
        [5] = MsgTipsID.JumbocactOpen5
    }
    local EntertainGameID = ProtoRes.Game.GameID
    self.ID = EntertainGameID.GameIDFairyColor -- 仙人仙彩的ID
    self.JdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) --持有的金碟币
    self.Consumption = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_BUY_CONSUME, "Value") -- 1010
    self.TableMaxPurNum = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_BUY_NUM, "Value")[1]--1009
    self.XCTickExMaxNum = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_EXCHANGE_LIMIT).Value[1] --仙彩券兑换上限数量 --1016
    self.CurCanXCTickExNum = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_EXCHANGE_LIMIT).Value[1] --1016
    self.WaitExchangeTime = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_OPEN_LOTTERY_FLOW_TIME).Value[1]-- 开奖仪式持续时间 1094
    self.XCTickNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS) --当前拥有仙彩券数量
    self.RewardRankData = FairycolorgRankingCfg:FindAllCfg()
end

function JumboCactpotMgr:OnBegin()
    local XCTicketID = 19000501
    local Cfg = ScoreCfg:FindCfgByKey(XCTicketID)
    self.MaxValue = Cfg.MaxValue
    self.MaxXCTicketNum = Cfg.MaxValue

    local CostJdCoinID = 1010   -- ID可以拿到需要花费金碟币数量
    local ColorGlobalCfg = GameGlobalCfg:FindCfgByKey(CostJdCoinID)
    if ColorGlobalCfg ~= nil then
        self.NeedJdNumList = ColorGlobalCfg.Value
    else
        _G.FLOG_ERROR("Not find jumb cost config")
    end
end

function JumboCactpotMgr:OnEnd()
end

function JumboCactpotMgr:OnShutdown()
    self.bExistBaseData = false             -- 用于控制只加载一次基础数据
    self.PurTerm = nil                      -- 购买的期数
    -- self.ExpiredNum = {}
end

function JumboCactpotMgr:OnRegisterGameEvent()
    --self:RegisterGameEvent(EventID.FinishDialog, self.OnFinishDialog)
    self:RegisterGameEvent(EventID.LeaveInteractionRange, self.OnGameEventLeaveInteractionRange)
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterAreaTrigger)
    self:RegisterGameEvent(EventID.AreaTriggerEndOverlap, self.OnLeaveAreaTrigger)
    self:RegisterGameEvent(EventID.UpdateScore, self.OnUpdateScoreValue)
    self:RegisterGameEvent(EventID.UpdateQuest, self.OnGameEventQuestUpdate)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function JumboCactpotMgr:OnRegisterNetMsg()
    local FairyColorGameCmd = ProtoCS.FairyColorGameCmd
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.PushReward, self.OnLottery) -- 开奖推送单独拉 
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.EndPlayDynamic, self.OnEndPlayDynamic)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.PushStage, self.OnNetMsgPushStage) -- 开奖推送单独拉

    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.QueryBase, self.OnBaseRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.BuyGuessNumber, self.OnONBuyRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.QueryLotteryResult, self.OnQueryRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.ExchangeReward, self.OnExchangeRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.QueryWinningList, self.OnListRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.QueryRewardBonus, self.OnRewardBonusRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.QueryProgress, self.OnQueryProgressRes)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, FairyColorGameCmd.ExchangeCoupons, self.OnXCTicketExchange)
end
-- 发送请求

function JumboCactpotMgr:OnSendNetMsg(MsgBody)
    local MsgID = CS_CMD.CS_CMD_FAIRY_COLOR

    _G.GameNetworkMgr:SendMsg(MsgID, MsgBody.Cmd, MsgBody)
end

function JumboCactpotMgr:SendReqBaseMsg(bNeedOpenViewOnWeakNet)
    self.bNeedOpenViewOnWeakNet = bNeedOpenViewOnWeakNet
    local MsgID = CS_CMD.CS_CMD_FAIRY_COLOR
    local SubMsgID = ProtoCS.FairyColorGameCmd.QueryBase
    local MsgBody = { Cmd = SubMsgID }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-------------------------------------------------协议回包------------------------------------------------------

---@type 基础数据
function JumboCactpotMgr:OnBaseRes(Msg)
    self:SetBaseData(Msg)
    self.QueryTimer = nil
    self:ExcuteCallBackIfExist()
    _G.GoldSauserMainPanelMgr:SetTheMsgUpdateState(GoldSauserGameClientType.GoldSauserGameTypeFairyColor, true)
    if self.bEnterWeakNetState and self.bNeedOpenViewOnWeakNet then -- 如果之前处于弱网且需要打开界面，则打开界面
        UIViewMgr:ShowView(UIViewID.JumboCactpotNewMainPanel)
        self.bEnterWeakNetState = false
        self:UnRegisterTimer(self.ConnectNetTimer)
        return
    end

    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if BaseInfo.CurrMapResID == self.JDMapID or BaseInfo.CurrMapResID == self.JDResID then
        local NeedStage = self.JumbState == FairyColorStatus.FairyColorStatusAfoot and self.LastStage or self.CurrStage
        JumboCactpotDynaMgr:UpdateDynItemByCurrStage(NeedStage, true)
        if self.JumbState == FairyColorStatus.FairyColorStatusAfoot then
            JumboCactpotDynaMgr:UpdateCenterPoleWhenCeremony(self.LastStage)
        end
    end

    self:UpdateJumboInfo()

    local BaseInfo = PWorldMgr.BaseInfo
    if BaseInfo.CurrMapResID == self.JDMapID then
        if self.ReconnectCallBack ~= nil and self.JumbState ~= FairyColorStatus.FairyColorStatusAfoot then
            self.ReconnectCallBack()
            self.ReconnectCallBack = nil
        end
    end
end

--- @type 设置基本数据
function JumboCactpotMgr:SetBaseData(Msg)
    -- self.ExpiredNum = {}    -- 用来记录过期的那一期所购买的号码
    self.bExistBaseData = true
    local QueryBase = Msg.QueryBase
    local ExchangeNum = QueryBase.PlayerData.ExchangeNum
    self.Term = QueryBase.Term -- 哪一期
    self.CurrStage = QueryBase.CurrStage -- 当前完成了第几阶段
    self.LastStage = QueryBase.LastStage
    self.ExchangeNum = ExchangeNum -- 已兑换仙彩券数量
    self.CurCanXCTickExNum = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_EXCHANGE_LIMIT).Value[1] --1016
    self.CurCanXCTickExNum = self.CurCanXCTickExNum - ExchangeNum  --判断剩余购买次数 
    self.AllPurchasesNum = self.TableMaxPurNum + self.ExchangeNum -- 可购买总次数
    self.LastTerm = QueryBase.Term - 1
    self.LotteryTime = Msg.QueryBase.LotteryTime
    self.WinNumber = Msg.QueryBase.Number
    self.JumbState = QueryBase.Status
    self.PlayerState = QueryBase.PlayerData.Status
    self:UpdateDataByState(Msg)
    self.bPlayLottoryAnim = not QueryBase.IsPlayEff
    local Index = #self.PurchasedNumList + 1
    if #self.NeedJdNumList >= Index then
        self.NeedJdNum = self.NeedJdNumList[Index]
    else
        self.NeedJdNum = 0
    end
    JumboCactpotVM.bBoughtMany = #self.PurchasedNumList > 1
end

function JumboCactpotMgr:UpdateDataByState(Msg)
    local JumbState = self.JumbState
    local PlayerState = self.PlayerState
    local Numbers = Msg.QueryBase.PlayerData.Numbers
    if PlayerState == FairyColorPlayerStatus.FairyColorPlayerNotBuy then
        self.RemainPurchases = self.AllPurchasesNum
        self.PurchasedNumList = {}
    elseif PlayerState == FairyColorPlayerStatus.FairyColorPlayerWait then
        if JumbState == FairyColorStatus.FairyColorStatusWait and #Numbers > 0 then
            self.PurTerm = Msg.QueryBase.Term    
        end
        self.RemainPurchases = self.AllPurchasesNum - #Numbers
        self.PurchasedNumList = Numbers
    elseif PlayerState == FairyColorPlayerStatus.FairyColorPlayerExchange then
        self.RemainPurchases = self.AllPurchasesNum
        self.PurchasedNumList = Numbers
        self.PushReward = self:ConstructPushReward(self.WinNumber)
    elseif PlayerState == FairyColorPlayerStatus.FairyColorPlayerExpired then
        self.RemainPurchases = self.AllPurchasesNum 
        self.PurchasedNumList = {} -- 当前游戏内过期号码不需要展示，默认过期状态不存储过期号码
    end

    if JumbState == FairyColorStatus.FairyColorStatusAfoot then
        self.PurTerm = #Numbers > 0 and Msg.QueryBase.Term - 1 or nil
        self.PushReward = self:ConstructPushReward(self.WinNumber)
    end
end


---@type 购买回报
function JumboCactpotMgr:OnONBuyRes()
    self.bEnterWeakNetState = false -- 收到回包判断没有弱网
    self.bInBuying = true
    self:UpdateBaseDataAfterBuy()
    self:UpdateJumboInfo()
    local PreContent = string.format("[%s]!", self.ParamTable)
    local NeedContent = RichTextUtil.GetText(tostring(PreContent), "#d1ba8e")
    local Content = string.format(LSTR(240005), NeedContent) -- 你已成功购买%s
    MsgTipsUtil.ShowTips(Content, nil, nil)
    MsgBoxUtil.CloseMsgBox()

    local RelatedNpcID = JumboCactpotDefine.RelatedNpcID.JumboDispenser
    _G.GoldSauserActivityMgr:CheckAndUpdateIconDissAppear(RelatedNpcID)
end

--- @type 在购买成功后更新基础数据
function JumboCactpotMgr:UpdateBaseDataAfterBuy()
    self.BuySum = self.BuySum + 1
    self.PlayerState = FairyColorPlayerStatus.FairyColorPlayerWait
    self:UpdataCurStagePro(self.BuySum)

    self.PurTerm = self.Term
    self.bIsBuy = true
    self.RemainPurchases = self.RemainPurchases - 1
    self.JdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    table.insert(self.PurchasedNumList, self.ParamTable)
    local Index = #self.PurchasedNumList + 1
    if #self.NeedJdNumList >= Index then
        self.NeedJdNum = self.NeedJdNumList[Index]
    else
        self.NeedJdNum = 0
    end

    EventMgr:SendEvent(EventID.JumboCactpotBuyCallBack)
    self:UpdateVMDataAfterBuy()
end

--- @type 更新购买数据后更新VM数据
function JumboCactpotMgr:UpdateVMDataAfterBuy()
    local ColorDefine = JumboCactpotDefine.ColorDefine
    JumboCactpotVM.NeedConsumptPrice = self.NeedJdNum
    JumboCactpotVM.PriceColor = self.JdCoinNum >= JumboCactpotVM.NeedConsumptPrice and ColorDefine.Black or ColorDefine.Red
    JumboCactpotVM.RemainPurchases = string.format("%s%s%s", self.RemainPurchases, "/", self.AllPurchasesNum)
    JumboCactpotVM.OwnJDNum = self.JdCoinNum
    -- 更新界面的彩票数量
    JumboCactpotVM.bBoughtMany = #self.PurchasedNumList > 1
    -- 过六次了后要出现还有多久开奖
    self:CheckShowWaitLottery()
end

---@type 奖励结果回包打开开奖页面
function JumboCactpotMgr:OnQueryRes(Msg)
    self.WinNumber = Msg.QueryLotteryResult.Number
    self.QueryLotteryResult = Msg.QueryLotteryResult

   
   --local function CallBack()
    if self.bPlayLottoryAnim then
        self:OnLotteryOpen()
    else
        self:ShowExchangeRewardPanel()
    end
    --end

    -- local DialogLibID = JumboCactpotDefine.DialogLibID
    -- NpcDialogMgr:PlayDialogLib(DialogLibID.CanExchangeReward, nil, false, CallBack)
end

function JumboCactpotMgr:ConstructPushReward(LotteryNumber)
    local PushReward = {}
    PushReward.NewTerm = self.Term
    PushReward.LastTerm = self.Term - 1
    PushReward.Number = LotteryNumber
    PushReward.ExtraValue = 0
    return PushReward
end

---@type 兑换奖励
function JumboCactpotMgr:OnExchangeRes(Msg)
    self.PurTerm = nil
    self.PlayerState = FairyColorPlayerStatus.FairyColorPlayerNotBuy

    local PushReward = self.PushReward
    if PushReward ~= nil then
        self:OnInit()
        self.Term = PushReward.NewTerm
        self.LastTerm = PushReward.LastTerm
    else
        self.PurchasedNumList = {}
    end
    self.PushReward = nil
    local TipsStr = string.format("%s%d", "兑换成功！\n恭喜获得金碟币", Msg.ExchangeReward.RewardNum)
    for i = 1, #Msg.ExchangeReward.Rewards do
        --local RewardCfg = ItemCfg:FindCfgByKey(Msg.ExchangeReward.Rewards[i].ResID)
        TipsStr = string.format("%s%s%s", TipsStr, "\n", ItemCfg:GetItemName(Msg.ExchangeReward.Rewards[i].ResID))
    end
    self.JdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    -- UIViewMgr:HideView(UIViewID.JumboCactpotGetRewardWin)
    -- UIViewMgr:HideView(UIViewID.JumboCactpotPlate)

    self:UpdateJumboInfo()
    local RelatedNpcID = JumboCactpotDefine.RelatedNpcID.JumboDispenser
    _G.GoldSauserActivityMgr:UpdateMiniMapIcon(RelatedNpcID)
end

--- @type 收到中奖履历回包打开中奖履历
function JumboCactpotMgr:OnListRes(Msg)
    local WinningList = Msg.WinningList
    local List = WinningList.List

    local function CallBack()
        local PreNeedList = {}
        for _, v1 in pairs(List) do
            local Elem = v1
            local RoleId = Elem.RoleId
            local OpenTime = Elem.OpenTime
            Elem.RoleList = self:GetNameColorAndSortID(RoleId)
            Elem.OpenTime = TimeUtil.GetTimeFormat("%Y.%m.%d", tonumber(OpenTime))
        end
        table.sort(List, self.SortByTerm)
        local Length = #List
        local MaxShowTermCount = 9
        if Length > MaxShowTermCount then
            for i = 1, MaxShowTermCount do
                PreNeedList[i] = List[i]
            end
        else
            PreNeedList = List
        end
        self:UpdateDianList(#PreNeedList)
        self.AllRewardResumeData = PreNeedList
        local NeedList = self:UpdateNeedList()
        JumboCactpotVM:UpdateList(JumboCactpotVM.ResumeMiddleList, NeedList)
        UIViewMgr:ShowView(UIViewID.JumboCactpotRewardResume)
    end

    local RoleIDList = {}
    for _, v in pairs(List) do
        local Elem = v
        if Elem.RoleId[1] ~= nil then
            for i = 1, #Elem.RoleId do
                table.insert(RoleIDList, Elem.RoleId[i])
            end
        end
     end
    _G.RoleInfoMgr:QueryRoleSimples(RoleIDList, CallBack, nil, false)
end

--- @type 更新需要出现的3个页签
function JumboCactpotMgr:UpdateNeedList()
    local NeedList = {}
    local DianSelectIndex = self.DianSelectIndex
    local AllRewardResumeData = self.AllRewardResumeData
    for i, v2 in pairs(AllRewardResumeData) do
        local Elem = v2
        if DianSelectIndex == 1 then
            if i >= 1 and i <= 3 then -- 只显示前三条
                table.insert(NeedList, Elem)
            end
        elseif DianSelectIndex == 2 then
            if i >= 4 and i <= 6 then -- 显示四到六条
                table.insert(NeedList, Elem)
            end
        elseif DianSelectIndex == 3 then
            if i >= 7 and i <= 9 then -- 显示六到9条
                table.insert(NeedList, Elem)
            end
        end
    end
    NeedList = self:UpdateEmpytPanel(NeedList)
    -- self.NeedList = NeedList
    return NeedList
end

--- @type 如果界面不满加上空界面
function JumboCactpotMgr:UpdateEmpytPanel(NeedList)
    local MaxIndex
    local Length = #NeedList
    if Length < 3 then
        MaxIndex = 3
    end
    if MaxIndex ~= nil then
        for i = 1, MaxIndex do
            local Elem = NeedList[i]
            if Elem ~= nil then
                Elem.bEmptyVisible = false
            else
                NeedList[i] = { bEmptyVisible = true}
            end
        end
    end
    return NeedList
end

--- @type 收到奖励加成回包
function JumboCactpotMgr:OnRewardBonusRes(Msg)
    local RewardBonus = Msg.RewardBonus
    self.StageList = RewardBonus.StageList
    self.BuySum = RewardBonus.BuySum
    local VMData = self:GetRewardBonusData()
    JumboCactpotVM.RewardBounsVM:UpdateVM(VMData)

    -- self:UpdataCurStagePro(RewardBonus.BuySum)
end

function JumboCactpotMgr:OnQueryProgressRes(Msg)
    if Msg == nil then
        return
    end
    local QueryProgress = Msg.QueryProgress
    self.BuySum = QueryProgress.BuySum
    self.MaxStageNum = QueryProgress.NextStageNum -- NextStageNum 虽然后端这个命名时Next实则是最大数量
    self:UpdataCurStagePro(self.BuySum)
end

--- @type 当仙彩券兑换后的回包CurCanXCTickExNum
function JumboCactpotMgr:OnXCTicketExchange(Msg)
    self.bEnterWeakNetState = false -- 收到回包判断没有弱网
    local OneTimeExNum = self.OneTimeExNum -- 这一次兑换的次数
    local ExchangeNum = Msg.ExchangeCoupons.ExchangeNum -- 兑换的总次数
    self.ExchangeNum = ExchangeNum -- 更新兑换了多少个仙彩券
    self.AllPurchasesNum = self.AllPurchasesNum + OneTimeExNum

    self.CurCanXCTickExNum = self.CurCanXCTickExNum - OneTimeExNum  --判断剩余购买次数
    self.RemainPurchases = self.RemainPurchases + OneTimeExNum
    JumboCactpotVM.RemainPurchases = string.format("%s%s%s", self.RemainPurchases, "/", self.AllPurchasesNum)
    self.XCTickNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS)
    JumboCactpotVM.XCTicksNum = string.format("%d/%d", self.XCTickNum, self.MaxXCTicketNum)

    local Content = string.format(LSTR(240006), OneTimeExNum) -- 购买次数+%s
    local ColorDefine = JumboCactpotDefine.ColorDefine
    local RichContent = RichTextUtil.GetText(Content, "#af4c58")
    MsgTipsUtil.ShowTips(Content)
    local RelatedNpcID = JumboCactpotDefine.RelatedNpcID.JumboDispenser
    _G.GoldSauserActivityMgr:UpdateMiniMapIcon(RelatedNpcID)
    self:UpdateJumboInfo()
end

-- 阶段推送
function JumboCactpotMgr:OnNetMsgPushStage(MsgBody)
    local PushStage = MsgBody.PushStage
    self.CurrStage = PushStage.CurrStage
    JumboCactpotDynaMgr:UpdateDynItemByCurrStage(self.CurrStage, false)
    EventMgr:SendEvent(EventID.JumboCactpotUpdateBouns)
end

--- @type 仙人仙彩开奖
function JumboCactpotMgr:OnLottery(Msg)
    self.bPlayLottoryAnim = true
    local PushReward = Msg.PushReward
    self.PushReward = PushReward
    self.LotteryTime = PushReward.LotteryTime
    self.JumbState = FairyColorStatus.FairyColorStatusAfoot -- 进入开奖中状态
    self.WinNumber = PushReward.Number
    JumboCactpotDynaMgr:SetWinNumber(PushReward.Number)
    JumboCactpotDynaMgr:UpdateCenterItemState(self.CurrStage, true)
    JumboCactpotLottoryCeremonyMgr:JumboCeremonyMgrReset()
    MsgTipsUtil.ShowTipsByID(MsgTipsID.JumbCountOnRaffleTip)
    JumboCactpotDynaMgr:UpdateCenterPoleWhenCeremony(self.CurrStage)
    self:UpdateJumboInfo()

    self:HideJumboPurPanel(LSTR(240007)) -- "抽奖即将开始, 快去参加抽奖吧!"
    local DelayShowCountDownTime = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_DELAY_SHOW_COUNTDOWN_TIP_TIME).Value[1]
    self:RegisterTimer(function() JumboCactpotLottoryCeremonyMgr:ShowCountTip(0, tonumber(DelayShowCountDownTime)) end, tonumber(DelayShowCountDownTime))

    if JumboCactpotLottoryCeremonyMgr:GetbEnterJumbArea() then
        self:RegisterTimer(function() MsgTipsUtil.ShowTipsByID(MsgTipsID.JumboLottoryTip) end, 5)   
    end

end

--- @type 开奖仪式结束可以领奖
function JumboCactpotMgr:OnEndPlayDynamic(MsgBody)
    if MsgBody == nil then
        return
    end
    local PushReward = self.PushReward
    self.JumbState = FairyColorStatus.FairyColorStatusWait    -- 恢复正常仙彩状态
    self:OnCanAward(PushReward)
    JumboCactpotDynaMgr:UpdateDynItemByCurrStage(0, false)
    JumboCactpotLottoryCeremonyMgr:JumboCeremonyMgrReset()

    self:UpdateJumboInfo()
end

--- @type 注册多少秒后可以领奖
function JumboCactpotMgr:OnCanAward(PushReward)
    if #self.PurchasedNumList > 0 then
        if MajorUtil.IsVisitWorld() or (self.PurTerm ~= nil and self.PurTerm >= PushReward.LastTerm) then -- 跨服状态直接显示领取奖励，会在二级菜单拦截。
            self.PlayerState = FairyColorPlayerStatus.FairyColorPlayerExchange
        else
            if self.PurTerm then
                -- 在线状态下经历多期开奖导致实际已为过期状态
                self.PlayerState = FairyColorPlayerStatus.FairyColorPlayerExpired
                self.PurchasedNumList = {} -- 清除身上的购买号码
            else
                FLOG_ERROR("JumboCactpotMgr:OnCanAward PurTerm is invalid")
            end
        end
    else
        self:OnInit()
    end


    self.Term = PushReward.NewTerm
    self.LastTerm = PushReward.LastTerm

    self:HideJumboPurPanel(LSTR(240008)) -- 新一期已经开始了, 快去参加新一期的彩票购买吧!
    _G.FLOG_INFO("Players are ready to claim their rewards")  
end

function JumboCactpotMgr:HideJumboPurPanel(TipConent)
    if UIViewMgr:IsViewVisible(UIViewID.JumboCactpotNewMainPanel) then
        MsgTipsUtil.ShowTips(TipConent)
        UIViewMgr:HideView(UIViewID.JumboCactpotNewMainPanel)
    end
end

-------------------------------------------------购买界面-------------------------------------------------------
function JumboCactpotMgr:OpenPanel()
    UIViewMgr:ShowView(UIViewID.JumboCactpotNewMainPanel)
end

--- @type 设置购买需要的金碟币
function JumboCactpotMgr:SetNeedConsumptPrice()
    local ColorDefine = JumboCactpotDefine.ColorDefine
    local PurchasedNumList = self.PurchasedNumList
    local PurchasedCount = #PurchasedNumList
    local JdCoinNum = self.JdCoinNum
    local Index = #self.PurchasedNumList + 1
    if #self.NeedJdNumList >= Index then
        self.NeedJdNum = self.NeedJdNumList[Index]
    else
        self.NeedJdNum = 0
    end
    JumboCactpotVM.NeedConsumptPrice = self.NeedJdNum
    JumboCactpotVM.PriceColor = JdCoinNum >= JumboCactpotVM.NeedConsumptPrice and ColorDefine.Black or ColorDefine.Red
end

--- @type 设置剩余购买次数
function JumboCactpotMgr:SetRemainPurChases()
    local PurchasedNumList = self.PurchasedNumList
    local PurchasedCount = #PurchasedNumList
    self.AllPurchasesNum = self.TableMaxPurNum + self.ExchangeNum
    local RemainPurchases = self.AllPurchasesNum - PurchasedCount
    self.RemainPurchases = RemainPurchases >= 0 and RemainPurchases or 0  --剩余购买次数 
    JumboCactpotVM.RemainPurchases = string.format("%s%s%s", self.RemainPurchases, "/", self.AllPurchasesNum)
end

--- @type 切换到剩余多少时间开奖界面
function JumboCactpotMgr:CheckShowWaitLottery()
    local bNoTime = #self.PurchasedNumList == 6
    JumboCactpotVM.bNoTime = bNoTime
    JumboCactpotVM.bReaminTime =  not JumboCactpotVM.bNoTime
    EventMgr:SendEvent(EventID.JumboCactpotChangeTogGroup, bNoTime)
    if bNoTime then
        self:SetLotteryTime()
    end
end

--- @type 更新剩余开奖时间
function JumboCactpotMgr:SetLotteryTime()
    self.RemainLotteryTimer = self:RegisterTimer(self.SetRemainTime, 0.5, 1, 0, nil)
end

--- @type 设置剩余开奖时间
function JumboCactpotMgr:SetRemainTime()
    local TimeDefine = JumboCactpotDefine.TimeDefine
    local RemainTime = JumboCactpotLottoryCeremonyMgr:GetRemainSecondTime()
    local RemainDay = math.floor(RemainTime / TimeDefine.OneDaySec)
    local LessthanOneDay = RemainTime % TimeDefine.OneDaySec
    local RemainHour = math.floor(LessthanOneDay / TimeDefine.OneHourSec)
    local LessthanOneHour = LessthanOneDay % TimeDefine.OneHourSec
    local RemainMin = math.ceil(LessthanOneHour / TimeDefine.OneMinSec)
    local Content = string.format(LSTR(240009), RemainDay, RemainHour, RemainMin) -- "%s天%s小时%s分钟后开奖"
    local RichContent = RichTextUtil.GetText(Content, JumboCactpotDefine.ColorDefine.Red)
    JumboCactpotVM.RemainLotteryTime = RichContent
end

--- @type 加载提示列表
function JumboCactpotMgr:UpdateDetailTipList()
    local TipData = {}
    local BaseCount = 3
    local BoughtNum = #self.PurchasedNumList
    local RemainBaseCount = BoughtNum >= BaseCount and 0 or BaseCount - BoughtNum
    local BaseCountText = string.format(LSTR(240010), RemainBaseCount) --  基础次数:       %d/3

    local CurCanXCTickExNum = self.CurCanXCTickExNum
    local XCExchangeText = string.format(LSTR(240011), CurCanXCTickExNum) -- 仙彩券兑换数量:      %d/3
    TipData[1] = BaseCountText
    TipData[2] = XCExchangeText
    JumboCactpotVM:UpdateList(JumboCactpotVM.TipsList, TipData)
end

--- @type 获取剩余次数详情列表信息
function JumboCactpotMgr:SetXCExchangeDetail()
    -- 设置仙彩券可使用信息。
    local XCTickExMaxNum = self.XCTickExMaxNum
    local CurCanXCTickExNum = self.CurCanXCTickExNum
    JumboCactpotVM.XCTickExchangeNums = string.format("%s%s%s", CurCanXCTickExNum, "/", XCTickExMaxNum)
end

--- @type 设置个人拥有的金碟币以及仙彩券
function JumboCactpotMgr:SetJDNAndXCTickNum()
    self.JdCoinNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
    JumboCactpotVM.OwnJDNum = tonumber(self.JdCoinNum)
    self.XCTickNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS)
    JumboCactpotVM.XCTicksNum = string.format("%d/%d", self.XCTickNum, self.MaxXCTicketNum)
end

--- @type 判断是否满足购买条件并弹出对应的提示
function JumboCactpotMgr:PurchaseLotteryTicket(InputItems)
    self.InputItems = InputItems

    for _, v in pairs(InputItems) do
        if v.number < 0 then
            MsgTipsUtil.ShowTips(LSTR(240012)) -- 请选择正确的号码
            return false
        end
    end
    
    self:SetJDNAndXCTickNum()
    local RemainPurchases = self.RemainPurchases
    if tonumber(self.JdCoinNum) >= tonumber(self.NeedJdNum) then
       if RemainPurchases > 0 then
        -- Show购买确认Tip
            -- self:ShowPurchaseTips()
            self:OnPurchasedCallBack()
            return true
       else
            -- 是否使用仙彩券兑换购买次数Tips
            self:CheckXCHasTickets()
       end
    else
        -- 金碟币获取Tips
        self:GetJDcoin()
        -- 获取成功后要购买
    end
    return false
end

--- @type 出现如何获取金碟币的提示
function JumboCactpotMgr:GetJDcoin()
    local ScoreType = ProtoRes.SCORE_TYPE
    local JDCoinID = ScoreType.SCORE_TYPE_KING_DEE
    local FunDesc = self:GetAccessByID(JDCoinID)
    local Content = string.format(LSTR(240013), FunDesc) -- 金碟币不足，请前往%s获取
                    -- 购买提示
    self:ShowCommTips(LSTR(240014), Content, self.OnGoGetJDCoinCallBack, nil, false)
end

--- @type 通过物品ID返回获取途径
function JumboCactpotMgr:GetAccessByID(ID)
    local AccessList = ItemUtil.GetItemAccess(ID)
    if AccessList == nil then
        _G.FLOG_INFO("access is not Config")
        return
    end
    local Access = AccessList[1]
    local AccessTypeCfg = ItemGetaccesstypeCfg:FindCfgByKey(Access)
    if AccessTypeCfg == nil then
        _G.FLOG_INFO("ItemGetaccesstypeCfg is not Config")
        return
    end
    local FunDesc = AccessTypeCfg.FunDesc
    return FunDesc
end

--- @type 展示双按钮提示
function JumboCactpotMgr:ShowCommTips(Title, Content, CallBack, CallBackParams, bShowTwoBtn, bSingleConfirmOrCancel)
    local Params = {
        Title = Title,
        Content = Content,
        CallBack = CallBack, --前往获取仙彩券
        CallBackParams = CallBackParams,
        bShowTwoBtn = bShowTwoBtn,
        bSingleConfirmOrCancel = bSingleConfirmOrCancel,
    }
    UIViewMgr:ShowView(UIViewID.JumboCactpotBuyTipsWin, Params)
end

--- @type 出现购买提示
function JumboCactpotMgr:ShowPurchaseTips()
    local InputItems = self.InputItems
    local Params = {
        JdCoinNum = self.NeedJdNum,
        InputItems = InputItems,
     }
    UIViewMgr:ShowView(UIViewID.JumboCactpotBuyWin, Params)
end

---@type 点击确认购买号码回调
function JumboCactpotMgr:OnPurchasedCallBack()
    -- 请求购买当前号码
    self.ParamTable = ""
    for i = 1, #self.InputItems do
        self.ParamTable = string.format("%s%d", self.ParamTable, self.InputItems[i].number)
    end
    local CurTerm = self.Term
    -- 购买请求
    local MsgID = ProtoCS.FairyColorGameCmd.BuyGuessNumber
    local MsgBody = {
        Cmd = MsgID,
        BuyGuessNumber = {
            Number = self.ParamTable,
            Term = CurTerm
        }
    }
    self:OnSendNetMsg(MsgBody)
    self.bEnterWeakNetState = true -- 收到回报则改为false
    -- if UIViewMgr:IsViewVisible(UIViewID.JumboCactpotNewMainPanel) then
    --     local View = UIViewMgr:FindVisibleView(UIViewID.JumboCactpotNewMainPanel)
    --     View:PlayAnimation(View.AnimAgain)
    --     View:PlayAnimation(View.AnimPurchased)
    -- end
end

--- @type 查看是否拥有仙彩券
function JumboCactpotMgr:CheckXCHasTickets()
    if tonumber(self.XCTickNum) > 0 then
        -- 是否前往兑换Tips
        local RichText = RichTextUtil.GetText(LSTR(240015), "#af4c58") -- 请前往使用仙彩券兑换购买次数
        local Content = string.format(LSTR(240016), RichText)           -- 购买次数不足，%s
        local function ShowExchangeXCTick()
            if self.ExchangeNum < self.XCTickExMaxNum then
                UIViewMgr:ShowView(UIViewID.JumboCactpotAddChance)
            else
                MsgTipsUtil.ShowActiveTips(LSTR(240017))                      -- 本周兑换次数已满3次，无法再次兑换
            end
        end
        self:ShowCommTips(LSTR(240014), Content, ShowExchangeXCTick, nil, true)
    else
        -- 获取仙彩券Tipss
        local ScoreType = ProtoRes.SCORE_TYPE
        local XCTicketID = ScoreType.SCORE_TYPE_FAIRY_COLOR_COUPONS
        local FunDesc = self:GetAccessByID(XCTicketID)
        local XCTicketText = RichTextUtil.GetText(LSTR(240018), "#af4c58") -- 【仙彩券】
        local PurCount = RichTextUtil.GetText(LSTR(240019), "#af4c58") -- 【购买次数】
        local Content = string.format(LSTR(240020), XCTicketText, PurCount, FunDesc) -- 可使用%s兑换%s，请前往%s获取
        self:ShowCommTips(LSTR(240014), Content, self.OnGoGetXCTicketCallBack, nil, false)
    end
end

--- @type 获取金碟币回调
function JumboCactpotMgr:OnGoGetJDCoinCallBack()
    -- 暂时不做
end

--- @type 获取仙彩券回调
function JumboCactpotMgr:OnGoGetXCTicketCallBack()
    -- 暂时不做
end

--- @type 点击增加购买次数
function JumboCactpotMgr:OnBtnAddPurCountClick()
    if self.ExchangeNum >= self.XCTickExMaxNum then
        MsgTipsUtil.ShowActiveTips(LSTR(240021)) -- 本周兑换次数已满3次，无法再次兑换
        return
    end

    if tonumber(self.XCTickNum) > 0 then  --拥有仙彩券时，
        UIViewMgr:ShowView(UIViewID.JumboCactpotAddChance)
    else
        -- 仙彩券不足
        local ColorDefine = JumboCactpotDefine.ColorDefine
        local ScoreType = ProtoRes.SCORE_TYPE
        local XCTicketID = ScoreType.SCORE_TYPE_FAIRY_COLOR_COUPONS
        local FunDesc = self:GetAccessByID(XCTicketID)
        -- local RichText = RichTextUtil.GetText(LSTR("【仙彩券】兑换【购买次数】"), ColorDefine.Red)
        local XCTicketText = RichTextUtil.GetText(LSTR(240018), ColorDefine.Red) -- 【仙彩券】
        local PurCount = RichTextUtil.GetText(LSTR(240019), ColorDefine.Red)    -- "【购买次数】"
        local Content = string.format(LSTR(240020), XCTicketText, PurCount, FunDesc) -- "可使用%s兑换%s，请前往%s获取"
        self:ShowCommTips(LSTR(240014), Content, nil, nil, false) -- 购买提示
    end
end

--- @type 使用仙彩券兑换购买次数
function JumboCactpotMgr:XCTicketExchangePurNum(Num)
    -- body
    local CurTerm = self.Term

    local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.ExchangeCoupons,
        ExchangeCoupons = { 
            ExchangeNum = Num,
            Term = CurTerm
        }
    }
    self.bEnterWeakNetState = true -- 收到回报则改为false
    JumboCactpotMgr:OnSendNetMsg(MsgBody)
end

---------------------------------------------------End----------------------------------------------------------
---------------------------------------------开奖界面--------------------------------------------------
---@type 设置购买号码单个数字为富文本
function JumboCactpotMgr:UpdateRichText(Num, Position)
    if Position == nil then
        Position = 0
    end
    local PurchasedNumList = table.deepcopy(self.PurchasedNumList)
    -- local LastNumbers = self.LastNumbers
    local RichBoughtNum = self.RichBoughtNum
    local NeedBoughNum = {}
    if #RichBoughtNum ~= 0 then
        NeedBoughNum = RichBoughtNum
    elseif self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExchange then --代表重新登陆但已经开奖了
        NeedBoughNum = PurchasedNumList
    elseif #RichBoughtNum == 0 then
        NeedBoughNum = PurchasedNumList
    end
    local ColorDefine = JumboCactpotDefine.ColorDefine
    local RichPurchasedNum = {}
    for i, v in pairs(NeedBoughNum) do
        local Elem = v
        local SingleNum = string.sub(Elem, Position, Position)
        local RichSubNum = ""
        if SingleNum == Num then  --- 判断已经是中将号码了
            -- 把该位置替换为富文本
            for j = 1, #Elem do
                if j == Position then
                    local RichNum = RichTextUtil.GetText(string.sub(Elem, j, j), ColorDefine.Red)
                    RichSubNum = string.format("%s%s", RichSubNum, RichNum)
                else
                    RichSubNum = string.format("%s%s", RichSubNum, string.sub(Elem, j, j))
                end
            end
        else
            RichSubNum = Elem
        end
        RichPurchasedNum[i] = RichSubNum
    end

    self.RichBoughtNum = RichPurchasedNum
    JumboCactpotVM:UpdateList(JumboCactpotVM.PlateBoughtList, RichPurchasedNum)
end

---@type 设置开奖动画间隔时间
function JumboCactpotMgr:UpdateIntervalTimeAndLoopCount()
    local LotteryNum = self.WinNumber
	local PurchasedNumList = self.PurchasedNumList
    for j = 1, #LotteryNum do
        local SingleLotteryNum = string.sub(LotteryNum, j, j)
        for i, v in pairs(PurchasedNumList) do
            local Elem = v
            local SingleNum = string.sub(Elem, i, i)
            if SingleNum == SingleLotteryNum then
                self.IntervalTime = 2
                self.LoopCount = 6
                return
            end
        end
    end
    self.LoopCount = 1
    self.IntervalTime = 0.5
end

---@type 判断是否获得了一等奖
function JumboCactpotMgr:IsFirstPrize()
    local LotteryNum = self.WinNumber
    -- local LastNumbers = self.LastNumbers
    -- if self.State == FairyColorState.StateExchange and #LastNumbers > 0 then
    --     self.PurchasedNumList = LastNumbers
    -- end
	local PurchasedNumList = self.PurchasedNumList

    for _, v in pairs(PurchasedNumList) do
        local Elem  = v
        if Elem == LotteryNum then
            return true
        end
    end
    return false
end

--------------------------------------------------End------------------------------------------------------------

-------------------------------------------------Npc交互--------------------------------------------------------
-- lua JumboCactpotMgr:Test()
function JumboCactpotMgr:Test()
    -- _G.UE.UAudioMgr.Get().SetRTPCValue(JumboCactpotDefine.JumboUIAudioPath.UISheelRotateRTPCName, 1, 0, nil)

    -- local ID =  EffectUtil.PlayEffect(FXParam)
end

function JumboCactpotMgr:GetDialogCallBack(DialogID)
    local function EndDialog()
        NpcDialogMgr:EndInteraction()
    end
    local function OpenLottery()
        self:OpenLottery(self.PurchasedNumList)
    end
    local CallBack
    local DialogLibID = JumboCactpotDefine.DialogLibID                             -- 剩余购买次数
    if DialogID == DialogLibID.CanExchangeReward then                               -- 可兑换
        CallBack = OpenLottery
    elseif DialogID == DialogLibID.StateAfoot then
        CallBack = EndDialog
    end
    return CallBack
end

--- @type 通过Npc对话打开开奖界面
function JumboCactpotMgr:OpenLottery(Numbers)
    local NumbersText = ""
    for i = 1, #Numbers do
        if NumbersText == "" then
            NumbersText = Numbers[i]
        else
            NumbersText = string.format("%s、%s",NumbersText, Numbers[i])
        end
    end
    -- if self.bInOpenLotteryPro then
    --     return
    -- end
    -- self.bInOpenLotteryPro = true
    local PushReward = self.PushReward
    local LastTerm = PushReward ~= nil and PushReward.LastTerm or self.LastTerm
    local MsgBody = {
    Cmd = ProtoCS.FairyColorGameCmd.QueryLotteryResult,
        QueryLotteryResult = { Term = LastTerm }
    }
    self:OnSendNetMsg(MsgBody)
end

--- @type 打开开奖界面
function JumboCactpotMgr:OnLotteryOpen()
    -- 打开开奖界面
    local PurchasedNumList = self.PurchasedNumList
    JumboCactpotVM:UpdateList(JumboCactpotVM.PlateBoughtList, PurchasedNumList)
    UIViewMgr:ShowView(UIViewID.JumboCactpotPlate)
end

--- @type 点击与Npc二级交互列表
function JumboCactpotMgr:OnJumbInteractive(ID, InteractivedescCfg)
    if MajorUtil.IsVisitWorld() then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.JumboWorldVisitTip) -- 跨服无法操作系统提示ID
        return
    end
    local InteractiveID = JumboCactpotDefine.InteractiveID
    local DialogLibID = JumboCactpotDefine.DialogLibID
    local NeedDialogLibID = 0
    local ID = InteractivedescCfg.ID
    if ID == InteractiveID.BuyJumbo then
        _G.NpcDialogMgr:EndInteraction()
        if self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExchange then
            MsgTipsUtil.ShowActiveTips(LSTR(240022), nil, nil, nil) -- 你有奖励未兑换
            return
        end
        if not self.bEnterWeakNetState then
            -- 没有弱网正常打开界面
            JumboCactpotMgr:OpenJumbPurPanel()
        else
            -- 弱网了重新拉数据
            self:SendReqBaseMsg(true)
            local function ConnetTimeOut()
                MsgTipsUtil.ShowTips(LSTR(240023)) -- 网络连接超时, 请检查网络
            end
            self.ConnectNetTimer = self:RegisterTimer(ConnetTimeOut, 5, 0, 1)
        end
        return
    elseif ID == InteractiveID.JumbDescription then
        NeedDialogLibID = DialogLibID.JumbDescription
        NpcDialogMgr:PlayDialogLib(NeedDialogLibID, nil, false, nil)
    elseif ID == InteractiveID.ExchangeReward then
       -- NeedDialogLibID = DialogLibID.BuyNumsRewardDesc
       _G.NpcDialogMgr:EndInteraction()
       self:OpenLottery(self.PurchasedNumList)
    end
end

function JumboCactpotMgr:OpenJumbPurPanel()
    local function ShowJumboTutorial()
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.UnlockGameplay--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.JumboCactpot
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowJumboTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)

    UIViewMgr:ShowView(UIViewID.JumboCactpotNewMainPanel)
end


--- @type 完成对话框时出现二级交互列表
function JumboCactpotMgr:OnFinishDialog(FinishDialogParams)
    if NpcDialogMgr:IsDialogPlaying() then
        return
    end
    local DialogLib = JumboCactpotDefine.DialogLibID
    if FinishDialogParams.DialogLibID == DialogLib.IsExpired then
        --self:ExpiredToNormalState()
    end
end

--- @type 离开Npc范围时事件
function JumboCactpotMgr:OnGameEventLeaveInteractionRange(Params)
    local NpcID = Params.ULongParam2
    local RelatedNpcID = JumboCactpotDefine.RelatedNpcID
    if NpcID ~= RelatedNpcID.JumboDispenser then
        return
    end
    InteractiveMainPanelVM:SetFunctionVisible(false)
    if not UIViewMgr:IsViewVisible(UIViewID.MainPanel) then
        _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
    end
end

--- @type 当加载完世界
function JumboCactpotMgr:OnPWorldEnter(Params)
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = Params.CurrMapResID
    -- print()
    if Params.CurrMapResID == self.JDMapID then
        if self.bEnterWrold then
            return
        end
        self.bEnterWrold = true
        --- 如果不存在基础数据则请求基础数据，如果存在就直接更新动态物件
        self:SendReqBaseMsg(false)
    end
end

function JumboCactpotMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    if LeaveMapResID == self.JDMapID then
        self.bEnterWrold = false
        self:ResetJumboInfo()
        self:OnLeaveAreaTrigger({AreaID = JumboAreaID})
        JumboCactpotLottoryCeremonyMgr.bEnterJumbArea = false
    end
end

--- @type 当任务更新时
function JumboCactpotMgr:OnGameEventQuestUpdate(Params)
    local Quests = Params.UpdatedRspQuests
    if table.is_nil_empty(Quests) then        
        return
    end
    local QuestIDList = _G.GoldSauserActivityMgr:GetQusetIDByNpcID(JumboCactpotDefine.RelatedNpcID.JumboDispenser)
    if QuestIDList == nil then
        return
    end
    local QuestID = QuestIDList[1]
    if QuestID == nil then
        return
    end
    if not _G.JumboCactpotLottoryCeremonyMgr:CheckIsInJumbArea(MajorUtil.GetMajorEntityID()) then
        return
    end

	for _, RspQuest in pairs(Quests) do		
		local RspQuestID = RspQuest.QuestID

		--指定的任务ID
		if (QuestID == RspQuestID and RspQuest.Status == QUEST_STATUS.CS_QUEST_STATUS_FINISHED) then
			-- self:EquipOnStrongest()
            self:OnEnterAreaTrigger({AreaID = JumboAreaID})
			break
		end
	end
end

-- @type 重连
function JumboCactpotMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    if bReconnect then
        local BaseInfo = PWorldMgr.BaseInfo
        if BaseInfo.CurrMapResID == self.JDMapID then
            self.ReconnectCallBack = function() 
                JumboCactpotDynaMgr:UpdateWheelOnReconnect()
                JumboCactpotLottoryCeremonyMgr:DestroyJumboMonster()
            end
            self:SendReqBaseMsg()
        end
    end
end

---@type 返回获得的最好的奖项
function JumboCactpotMgr:GetBestPrize()
    local LotteryNum = self.WinNumber
	local PurchasedNumList = self.PurchasedNumList
    local RewardTable = {}
    for _, v1 in pairs(PurchasedNumList) do
        local Elem  = v1
        if Elem == LotteryNum then
            return LSTR(240024) -- LSTR(一) 如果有一等奖直接返回
        else
            local Reward = 5  --默认是最次的五等奖
            for i = 1, #Elem do
                local SingleNum = string.sub(Elem, i, i)
                local SingLottoryNum = string.sub(LotteryNum, i, i)
                if SingleNum == SingLottoryNum  then
                    Reward = Reward - 1
                end
            end
            table.insert(RewardTable, Reward)
        end
    end

    local BestReward = 5
    for i = 1, #RewardTable do
        local Elem  = RewardTable[i]
        if Elem < BestReward then
            BestReward = Elem
        end
    end

    if BestReward == 5 then
        return LSTR(240025) ---- 五
    elseif BestReward == 4 then
        return LSTR(240026) -- 四
    elseif BestReward == 3 then
        return LSTR(240027) -- 三
    elseif BestReward == 2 then
        return LSTR(240028) -- 二
    end
    return ""
end

--- @type 从过期状态回到正常可购买状态
function JumboCactpotMgr:ExpiredToNormalState()
    self.PlayerState = FairyColorPlayerStatus.FairyColorPlayerNotBuy
    self.PurchasedNumList = {}
    self.RemainPurchases = self.TableMaxPurNum
    local FairyColorReportType = ProtoCS.FairyColorReportType
    local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.PlayEffect,
        PlayEffect = { ReportType = FairyColorReportType.FairyColorReportType_ExchangeExpired}
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody) -- 上报过期
end
--------------------------------------------------------End------------------------------------------------------

--------------------------------------------------------中奖履历------------------------------------------------------------
--- @type 设置富文本和自己朋友路人排序
function JumboCactpotMgr:GetNameColorAndSortID(RoleIdList)
    local SortList = { Self = 1, Friend = 2, Other = 3 }  -- { {SortId = 1, Nickname = "xin"}， {SortID = 2， NickName = "li"} }
    local ColorDefine = JumboCactpotDefine.ColorDefine
    local RoleList = {}
    for _, v2 in pairs(RoleIdList) do
        local TempList = {}
        local RoleId = v2
        local RoleActor = _G.RoleInfoMgr:FindRoleVM(RoleId, true)
        local Name = RoleActor.BindableProperties.Name.Value
        TempList.Nickname = Name
        if MajorUtil.IsMajorByRoleID(RoleId) then
            TempList.SortID = SortList.Self
            TempList.Nickname = RichTextUtil.GetText(TempList.Nickname, ColorDefine.ColorSelf)
        elseif FriendMgr:IsFriend(RoleId) then
            TempList.SortID = SortList.Friend
            TempList.Nickname = RichTextUtil.GetText(TempList.Nickname, ColorDefine.ColorFriend)
        elseif ArmyMgr:GetMemberDataByRoleID(RoleId) ~= nil then
            TempList.SortID = SortList.Friend
            TempList.Nickname = RichTextUtil.GetText(TempList.Nickname, ColorDefine.ColorFriend)
        else
            TempList.SortID = SortList.Other
        end
        table.insert(RoleList, TempList)
    end
    table.sort(RoleList, self.SortByID)
    return RoleList
end

--- @type 用于对中奖履历中自己 好友 路人排序
function JumboCactpotMgr.SortByID(Left, Right)
    local LeftSortID = Left.SortID
    local RightSortID = Right.SortID
    if LeftSortID ~= RightSortID then
        return LeftSortID < RightSortID
    elseif LeftSortID == RightSortID then
        return false
    end
    return false
end

--- @type 期数越大优先显示
function JumboCactpotMgr.SortByTerm(Left, Right)
    local LeftTerm = Left.Term
    local RightTerm = Right.Term
    if LeftTerm ~= RightTerm then
        return RightTerm < LeftTerm
    elseif LeftTerm == RightTerm then
        return false
    end
    return false
end

--- @type 更新需要出现几个页签点
function JumboCactpotMgr:UpdateDianList(DataLength)
    local ResumSlideData = self.ResumSlideData
    if DataLength <= 3 then
        ResumSlideData = {}
    elseif DataLength <= 6 then
        ResumSlideData[1] = ResumSlideData[1] ~= nil and ResumSlideData[1] or true
        ResumSlideData[2] = ResumSlideData[2] ~= nil and ResumSlideData[2] or false
    else
        ResumSlideData[1] = ResumSlideData[1] ~= nil and ResumSlideData[1] or true
        ResumSlideData[2] = ResumSlideData[2] ~= nil and ResumSlideData[2] or false
        ResumSlideData[3] = ResumSlideData[2] ~= nil and ResumSlideData[3] or false
    end
	JumboCactpotVM:UpdateList(JumboCactpotVM.ResumeDianList, ResumSlideData)
    self.DianSelectIndex = 1 -- 默认是1
end

--- @type 点击打开下一页
function JumboCactpotMgr:SelectNextDianItem(SelectIndex)
    local ResumSlideData = self.ResumSlideData
    if SelectIndex == #ResumSlideData then
        return
    end
    for i = 1, #ResumSlideData do
        ResumSlideData[i] = false
    end
    ResumSlideData[SelectIndex + 1] = true
    JumboCactpotVM:UpdateList(JumboCactpotVM.ResumeDianList, ResumSlideData)
end

--- @type 页面回到上一页
function JumboCactpotMgr:SelectLastDianItem(SelectIndex)
    local ResumSlideData = self.ResumSlideData
    if SelectIndex == 1 then
        return
    end
    for i = 1, #ResumSlideData do
        ResumSlideData[i] = false
    end
    ResumSlideData[SelectIndex - 1] = true
    JumboCactpotVM:UpdateList(JumboCactpotVM.ResumeDianList, ResumSlideData)
end
--------------------------------------------------------End------------------------------------------------------------

------------------------------------------------------奖励加成-------------------------------------------------------
---@type 展示奖励加成说明
function JumboCactpotMgr:ShowRewardBonusTip(Title, SubTitle1, Content1, SubTitle2, Content2)
    local Params = {
        Title = Title,
        SubTitle1 = SubTitle1,
        Content1 = Content1,
        SubTitle2 = SubTitle2,
        Content2 = Content2,
    }
    UIViewMgr:ShowView(UIViewID.JumboCactpotRewardShowWin, Params)
end

---@type 获取奖励加成界面的数据
function JumboCactpotMgr:GetRewardBonusData()
    local StageList = self.StageList
    local BuySum = self.BuySum
    local RewardRankData = self.RewardRankData
    local MaxStage = self.MaxStage -- 最大第七阶段
    local CurrStage = self.CurrStage

    local NeedData = {}
    NeedData.BuySum = string.format(LSTR(240029), BuySum) -- 全服累计：%d注
    NeedData.FinishStage = CurrStage
    NeedData.RewardBuffListData = self:GetRewardBuffData(StageList, RewardRankData)
    local OngoingStage
    if CurrStage == MaxStage then
        OngoingStage = CurrStage
    else
        OngoingStage = CurrStage + 1 -- 当前正在进行的阶段
    end
    local CurStageIndex = MaxStage + 1 - OngoingStage

    NeedData.StagePro = math.clamp(BuySum / StageList[1].InitNum, 0, 1)
    -- NeedData.StagePro = math.clamp(BuySum / StageList[1].InitNum * StageList[CurStageIndex].InitNum / StageList[1].InitNum , 0, 1)

    for i = 1, #StageList do
        local Elem = StageList[i]
        NeedData[string.format("Stage%dstInitNum", MaxStage + 1 - i)] = Elem.InitNum
    end
    
    for i = 1, #RewardRankData do
        local Elem = RewardRankData[i]
        NeedData[string.format("BaseRewardNum%d", i)] = Elem.RewardNum
    end

    return NeedData
end

---@type 获取加成tableView需要的数据
function JumboCactpotMgr:GetRewardBuffData(StageList, RewardRankData)
    local ColorDefine = JumboCactpotDefine.ColorDefine
    local CurrStage = self.CurrStage
    local NeedData = {}
    for i = #StageList, 1, -1 do
        local Temp = {}
        local Elem = StageList[i]
        local BuffLevel = Elem.Level -- 需要增加的奖励等级
        local Scale = Elem.Scale     -- 增加的比例
        local BuffNum = Elem.RewardNum -- 增加的数量
        if i < 7 then
            Temp = table.deepcopy(NeedData[7 - i])
        end
        for j = 1, #RewardRankData do
            local Elem2 = RewardRankData[j]
            local BaseReward = Elem2.RewardNum
            local Index = string.format("RewardBuff0%d", j)
            for k = 1, #BuffLevel do
                local LevelElem = BuffLevel[k]
                if LevelElem == Elem2.Level then
                    local TempBuff
                    if Elem.RewardType ~= 1 then
                        TempBuff = math.floor(BaseReward * Scale / 100)
                    else
                        TempBuff = BuffNum
                    end
                    Temp[Index] = Temp[Index] ~= nil and Temp[Index] + TempBuff or TempBuff
                else
                    Temp[Index] = Temp[Index] ~= nil and Temp[Index] or 0
                end
            end
        end

        Temp.bBuffVisible = CurrStage == Elem.ID
        Temp.TextColor = CurrStage > Elem.ID and ColorDefine.Black or CurrStage == Elem.ID and ColorDefine.BuffYellow or ColorDefine.Grey 
        table.insert(NeedData, Temp)
    end

    return NeedData
end

--- @type 更新當前阶段进度
function JumboCactpotMgr:UpdataCurStagePro(BuySum)
    -- local MaxStage = self.MaxStage -- 最大第七阶段
    local MaxStageNum = self.MaxStageNum
    -- local Index
    -- if self.CurrStage >= MaxStage then
    --     Index = 1
    -- else
    --     Index = self.StageList[self.CurrStage + 1].ID
    -- end
    -- if Index ~= nil then
        -- local CurStageInitNum = self.StageList[Index].InitNum
        -- local NeedStagePro = BuySum / CurStageInitNum
        -- self.CurStagePro = (self.CurrStage) / MaxStage + ( 1 / MaxStage ) * NeedStagePro
    self.CurStagePro = BuySum / MaxStageNum --self.StageList[1].InitNum
    -- end
    EventMgr:SendEvent(EventID.JumboCactpotUpdateBouns)
end

------------------------------------------------------End-------------------------------------------------------

--------------------------------------------------兑换奖励页面-------------------------------------------------------
--- @type 打开兑奖界面
function JumboCactpotMgr:ShowExchangeRewardPanel()
    if UIViewMgr:IsViewVisible(UIViewID.JumboCactpotGetRewardNewWin) then
        return
    end
    local QueryLotteryResult = self.QueryLotteryResult
    if QueryLotteryResult == nil then
        return
    end

    local LevelResult = self:SetLotteryRichText(QueryLotteryResult)
    UIViewMgr:ShowView(UIViewID.JumboCactpotGetRewardNewWin, LevelResult)
end

--- @type 给中奖的号码设置富文本
--- @param Msg table 服务器回包
function JumboCactpotMgr:SetLotteryRichText(QueryLotteryResult)
    local LevelResult = QueryLotteryResult.LevelResult
    local LotteryNum = QueryLotteryResult.Number
    local LotteryNumTable = {}
    local ColorDefine = JumboCactpotDefine.ColorDefine
    for LotteryIndex = 1, #LotteryNum do --PurNumber 购买的数字
        local SingleLotteryNum = string.sub(LotteryNum, LotteryIndex, LotteryIndex)
        LotteryNumTable[LotteryIndex] = SingleLotteryNum
    end

    for _, v1 in pairs(LevelResult) do
        local Elem = v1
        local PurNumber = Elem.Number   --购买的数字
        Elem.RichNumber = ""
        local bRichTable = {false, false, false, false}

        for i = 1, #PurNumber do --PurNumber 购买的数字
            local SinglePurNum = string.sub(PurNumber, i, i)
            if SinglePurNum == LotteryNumTable[i] then
                bRichTable[i] = true
            end
        end

        for index = 1, #bRichTable do
            local ArrElem = bRichTable[index]
            if ArrElem then
                local RichText = RichTextUtil.GetText(string.sub(PurNumber, index, index), ColorDefine.GetRewardColor)
                Elem.RichNumber = string.format("%s%s", Elem.RichNumber, RichText)
            else
                Elem.RichNumber = string.format("%s%s", Elem.RichNumber, string.sub(PurNumber, index, index))
            end
        end
    end
    table.sort(LevelResult, self.SortByLevel)

    return LevelResult
end

---@type 根据获得奖励等价排序
function JumboCactpotMgr.SortByLevel(Left, Right)
    local LeftLevel = Left.Level
    local RightLevel = Right.Level
    if LeftLevel ~= RightLevel then
        return LeftLevel < RightLevel
    elseif LeftLevel == RightLevel then
        return false
    end
    return false
end

--------------------------------------------------End-------------------------------------------------------
------------------------------------------------仙彩任务情报--------------------------------------------------

local WaitIndex = 0
--- @type 当进入仙彩区域
function JumboCactpotMgr:OnEnterAreaTrigger(Params)
    if Params.AreaID == JumboAreaID then
        FLOG_INFO(" JumboCactpotLottoryCeremonyMgr:OnEnterAreaTrigger(Params) ID = 1100000")
        if not _G.GoldSauserActivityMgr:CheckIsFinishNpcQuest(JumboCactpotDefine.RelatedNpcID.JumboDispenser) then
            if WaitIndex <= 1 then -- 一开始加载不到任务数据
                self:RegisterTimer(self.OnEnterAreaTrigger, 3, 0, 1, { AreaID = JumboAreaID })
                WaitIndex = WaitIndex + 1
            end
            return
        end
        WaitIndex = 0

        MainPanelVM:SetJumbpInfoVisible(true)
        JumboCactpotLottoryCeremonyMgr.bEnterJumbArea = true
        self:UpdateJumboInfo()
        if self.JumbState == FairyColorStatus.FairyColorStatusAfoot then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.JumboEnterArea)
        end
    end
end

function JumboCactpotMgr:OnLeaveAreaTrigger(Params)
    if Params.AreaID == JumboAreaID then
        WaitIndex = 0
        MainPanelVM:SetJumbpInfoVisible(false)
        self:ResetJumboInfo()
        if self.JumbState == FairyColorStatus.FairyColorStatusAfoot then
            MsgTipsUtil.ShowTipsByID(MsgTipsID.JumboLeaveArea)
        end
        JumboCactpotLottoryCeremonyMgr:HideCountDownTip()
        JumboCactpotLottoryCeremonyMgr.bEnterJumbArea = false

        FLOG_INFO(" JumboCactpotLottoryCeremonyMgr:OnLeaveAreaTrigger(Params) ID = 1100000")
    end
end

function JumboCactpotMgr:OnUpdateScoreValue(ScoreID)
    if ScoreID == ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE then
        local ColorDefine = JumboCactpotDefine.ColorDefine
        self.JdCoinNum = ScoreMgr:GetScoreValueByID(ScoreID)
        local NeedConsumptPrice = tonumber(JumboCactpotVM.NeedConsumptPrice) or 0
        JumboCactpotVM.PriceColor = self.JdCoinNum >= NeedConsumptPrice and ColorDefine.Black or ColorDefine.Red
    end
end

--- 更新右上角仙彩信息
function JumboCactpotMgr:UpdateJumboInfo()
    local JumbState = self.JumbState
    local AllPurchasesNum = self.AllPurchasesNum
    local PurchasedNum = self:GetPurNumLocal()
    self.XCTickNum = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_FAIRY_COLOR_COUPONS)

    if PurchasedNum == nil or AllPurchasesNum == nil then
        return
    end
    JumboCactpotVM.BuyCountVisible = PurchasedNum < AllPurchasesNum
    JumboCactpotVM.XCTickNumVisible = PurchasedNum < AllPurchasesNum
    JumboCactpotVM.RemainTimeVisible = PurchasedNum >= AllPurchasesNum and not JumbState == FairyColorStatus.FairyColorStatusAfoot

    JumboCactpotVM.BuyCountText = string.format(LSTR(240030), PurchasedNum, AllPurchasesNum) -- 已购买次数: %s/%s
    
    JumboCactpotVM.XCTickNumText = string.format(LSTR(240031), self.XCTickNum) -- 仙彩券数量: %s

    local NeedTimeText
    local RemainTime = JumboCactpotLottoryCeremonyMgr:GetRemainSecondTime()
    if RemainTime > OnDaySeconds then
        local Ret = LocalizationUtil.GetCountdownTimeForLongTime(RemainTime)
        NeedTimeText = string.format("%s", Ret--[[math.floor(RemainTime / OnDaySeconds)]]) 
    else
        local function UpdateTime()
            RemainTime = JumboCactpotLottoryCeremonyMgr:GetRemainSecondTime()
            local Ret = LocalizationUtil.GetCountdownTimeForShortTime(RemainTime, "hh:mm:ss")
            NeedTimeText = Ret--TimeUtil.GetTimeFormat("%H:%M:%S", RemainTime)
            JumboCactpotVM.RemainTimeText = NeedTimeText
        end
        self.UpdateTimeTimer = self:RegisterTimer(UpdateTime, 0, 0.2, 0)
    end
    JumboCactpotVM.RemainTimeText = NeedTimeText

    local NeedInfoDescText = ""
    if JumbState == FairyColorStatus.FairyColorStatusAfoot then
        NeedInfoDescText = LSTR(240032) -- 开奖中
        JumboCactpotVM.BuyCountVisible = true
        JumboCactpotVM.XCTickNumVisible = true
        JumboCactpotVM.RemainTimeVisible = false
    elseif self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExchange then
        NeedInfoDescText = LSTR(240033) -- 未领奖
    else
        local Ret = LocalizationUtil.GetTimeForFixedFormat("21:00", not CommonDefine.bChsVersion)
        NeedInfoDescText = string.format(LSTR(240034), Ret) -- 开奖时间：本周六%s
    end
    JumboCactpotVM.InfoDescText = NeedInfoDescText
end

function JumboCactpotMgr:ResetJumboInfo()
    local UpdateTimeTimer = self.UpdateTimeTimer
    if UpdateTimeTimer ~= nil then
        self:UnRegisterTimer(UpdateTimeTimer)
        self.UpdateTimeTimer = nil
    end
end

function JumboCactpotMgr:OnBtnAddXCTick()
    local ScoreType = ProtoRes.SCORE_TYPE
    local XCTicketID = ScoreType.SCORE_TYPE_FAIRY_COLOR_COUPONS
    local FunDesc = JumboCactpotMgr:GetAccessByID(XCTicketID)

    local XCTicketText = RichTextUtil.GetText(LSTR(240018), "#af4c58") -- 【仙彩券】
    local PurCount = RichTextUtil.GetText(LSTR(240019), "#af4c58") -- 【购买次数】
    local Content = string.format(LSTR(240020), XCTicketText, PurCount, FunDesc) -- 可使用%s兑换%s，请前往%s获取
    self:ShowCommTips(LSTR(240014), Content, self.OnGoGetXCTicketCallBack, nil, false) -- 购买提示
end
--------------------------------------------------End-------------------------------------------------------
--------------------------------------------------外部接口-------------------------------------------------------
function JumboCactpotMgr:IsJumboAnswer(Answers)
    local AnswerContentIDList = JumboCactpotDefine.AnswerContentIDList
    for _, v in pairs(AnswerContentIDList) do
        local AnswerContentID = v
        for i = 1, #Answers do
            if AnswerContentID == tonumber(Answers[i]) then
                return true
            end
        end
    
    end
    return false
end

function JumboCactpotMgr:CanShowExplainJumbOption()
    return self.JumbState == FairyColorStatus.FairyColorStatusWait and (self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerNotBuy or self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerWait or self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExpired)
end

function JumboCactpotMgr:CanShowBuyJumbOption()
    local bPlayerOk = self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerNotBuy or self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerWait or self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExpired

    return self.JumbState == FairyColorStatus.FairyColorStatusWait and bPlayerOk
end

--- @type 获得购买了多少注仙彩
function JumboCactpotMgr:GetPurNumLocal()
    return #self.PurchasedNumList
end

function JumboCactpotMgr:IsJumboType(InteractiveID)
    local OptionList = JumboCactpotDefine.OptionList
    for _, ID in pairs(OptionList) do
        if InteractiveID == ID then
            return true
        end
    end
    return false
end

--- @type 用于判断是否可以领奖
function JumboCactpotMgr:IsLottory()
    return self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExchange and self.JumbState == FairyColorStatus.FairyColorStatusWait
end

--- @type 是否已过期
function JumboCactpotMgr:IsExpired()
    local bExpired = self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExpired and self.JumbState == FairyColorStatus.FairyColorStatusWait -- 开奖中对话提示优先级最高
    return bExpired
end

--- @type 是否在开奖过程中
function JumboCactpotMgr:IsWaitLottory()
    return self.JumbState == FairyColorStatus.FairyColorStatusAfoot
end

--- @type 用于判断是否剩余次数
function JumboCactpotMgr:IsExistJumbCount()
    return self.RemainPurchases > 0
end

function JumboCactpotMgr:GetRemainumbCount()
    return self.RemainPurchases
end
--- @type 是否剩余一天结束
function JumboCactpotMgr:IsNearlyDeadLine()
    local RemainSeconds = JumboCactpotLottoryCeremonyMgr:GetRemainSecondTime()
    return RemainSeconds <= OnDaySeconds
end

--- @type 获得当前的状态
function JumboCactpotMgr:QueryCurJumbState(CallBack, Params)
    local PlayerState = self:GetCurJumbState()
    if PlayerState ~= nil then
        CallBack(Params, PlayerState)
    else
        local Info = {CallBack = CallBack, Params = Params, QueryType = QueryType.QueryCurState}
        if self.BaseDataCallBack == nil then
            self.BaseDataCallBack = {}
        end
        table.insert(self.BaseDataCallBack, Info) 
        local function WaitTimeOut(InInfo)
            table.remove_item(self.BaseDataCallBack, InInfo)
        end
        self:RegisterTimer(WaitTimeOut, WaitTime, nil, nil, Info)
    end
end

function JumboCactpotMgr:GetCurJumbState()
    if not self.bExistBaseData then
        if self.QueryTimer == nil then
            self.QueryTimer = self:RegisterTimer(self.SendReqBaseMsg, 0, nil, nil, false)
        end
        return
    end
    if self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExpired then
        return FairyColorPlayerStatus.FairyColorPlayerExpired -- 已过期
    elseif self.PlayerState == FairyColorPlayerStatus.FairyColorPlayerExchange then
        return FairyColorPlayerStatus.FairyColorPlayerExchange -- 已开将可兑换
    else 
        return FairyColorPlayerStatus.FairyColorPlayerWait -- 等待开奖
    end
end

---@type 请求购买的号码
function JumboCactpotMgr:QueryPurNum(CallBack, Params)
    local PurNums = self:GetPurNum()
    if PurNums ~= nil then
        CallBack(Params, PurNums)
    else
        local Info  = {CallBack = CallBack, Params = Params, QueryType = QueryType.QueryPurNum}
        if self.BaseDataCallBack == nil then
            self.BaseDataCallBack = {}
        end
        table.insert(self.BaseDataCallBack, Info) 
        local function WaitTimeOut(InInfo)
            table.remove_item(self.BaseDataCallBack, InInfo)
        end
        self:RegisterTimer(WaitTimeOut, WaitTime, nil, nil, Info)
    end
end

--- @type 获得号码
function JumboCactpotMgr:GetPurNum()
    if not self.bExistBaseData then
        if self.QueryTimer == nil then
            self.QueryTimer = self:RegisterTimer(self.SendReqBaseMsg, 0, nil, nil, false)
        end
        return
    end
    -- if self.JumbState == FairyColorState.StateExpired then
    --     return self.ExpiredNum
    -- if self.JumbState == FairyColorState.StateExchange then
    --     return self.LastNumbers
    -- end 
    return self.PurchasedNumList
    -- end
end

--- @type 收到基础数据后执行回调
function JumboCactpotMgr:ExcuteCallBackIfExist()
    local BaseDataCallBack = self.BaseDataCallBack
    if BaseDataCallBack ~= nil then
        for i = #BaseDataCallBack, 1, -1 do
            local Elem = BaseDataCallBack[i]
            local QuerySubType = Elem.QueryType
            if QuerySubType == QueryType.QueryCurState then
                Elem.CallBack(Elem.Params, self:GetCurJumbState())
            elseif QuerySubType == QueryType.QueryPurNum then
                Elem.CallBack(Elem.Params, self:GetPurNum())
            end
            table.remove(self.BaseDataCallBack, i)
        end
    end
end

--- @type 获得开奖期数
function JumboCactpotMgr:GetLottoryTerm()
    -- local PushReward = self.PushReward
    -- local LastTerm = PushReward ~= nil and PushReward.LastTerm or self.Term
    if self.PushReward ~= nil then
        return self.PushReward.LastTerm
    else
        return self.Term
    end
end

--- @type 获得开奖期数
function JumboCactpotMgr:GetLottoryNum()
    return self.WinNumber
end


function JumboCactpotMgr:GetNewTerm()
    return self.Term + 1
end

--- @type 获得当前期数
function JumboCactpotMgr:GetTerm()
    return self.Term
end

function JumboCactpotMgr:GetDialogJumboIconPath()
    return JumboCactpotDefine.IconPath.DialogIconPath
end

function JumboCactpotMgr:ShowGetJDCoinTip()
    local Content = LSTR(240035) -- 参与金碟游乐场玩法可获取金碟币
    self:ShowCommTips(LSTR(240014), Content, JumboCactpotMgr.OnGoGetJDCoinCallBack, nil, false) -- 购买提示
end

return JumboCactpotMgr

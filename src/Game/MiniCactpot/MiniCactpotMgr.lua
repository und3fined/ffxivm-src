local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local MinicactpotAwardOverviewCfg = require("TableCfg/MinicactpotAwardOverviewCfg")
local MiniCactpotMainVM = require("Game/MiniCactpot/MiniCactpotMainVM")
local ScoreMgr = require("Game/Score/ScoreMgr")
local DialogCfg = require("TableCfg/DialogCfg")
local UIUtil = require("Utils/UIUtil")
local MiniCactpotDefine = require("Game/MiniCactpot/MiniCactpotDefine")
local AudioUtil = require("Utils/AudioUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local GoldSauserVM = require("Game/Gate/GoldSauserVM")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local GoldSauserGameClientType = ProtoRes.GoldSauserGameClientType
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local AsyncReqModuleType = GoldSauserMainPanelDefine.AsyncReqModuleType
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

local CS_CMD = ProtoCS.CS_CMD
local LSTR = _G.LSTR
local NpcDialogMgr = _G.NpcDialogMgr
local JumboCactpotMgr
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local PWorldMgr = _G.PWorldMgr
local WaitTime = 20
local MiniCactpotNpcID = 1010445
local RefreshHour = 5
local GoldSauserMgr

---@class MiniCactpotMgr : MgrBase
local MiniCactpotMgr = LuaClass(MgrBase)

--[1-9]，没有0，所以直接这样定义
MiniCactpotMgr.Number2PathMap =
{
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_1_png.UI_MiniCact_Numb_Img_1_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_2_png.UI_MiniCact_Numb_Img_2_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_3_png.UI_MiniCact_Numb_Img_3_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_4_png.UI_MiniCact_Numb_Img_4_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_5_png.UI_MiniCact_Numb_Img_5_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_6_png.UI_MiniCact_Numb_Img_6_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_7_png.UI_MiniCact_Numb_Img_7_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_8_png.UI_MiniCact_Numb_Img_8_png'",
	"PaperSprite'/Game/UI/Atlas/MiniCactpot/Frames/UI_MiniCact_Numb_Img_9_png.UI_MiniCact_Numb_Img_9_png'",
}

function MiniCactpotMgr:OnInit()
	JumboCactpotMgr = _G.JumboCactpotMgr
	GoldSauserMgr = _G.GoldSauserMgr
	Utils.Init()
	
	--基本信息
	self.JDMapID = 12060
    self.JDResID = 1008204
	self.MiniCactpotIssuerNpc = 1010445 -- 微彩发放员ID
	self.MiniCactpotInfo = {
		MaxChance = 3,		--每天最多几次
		LeftChance = -1,	--当天剩余几次
		CurrentTerm = 1,	--现在是第几期微彩了
		RelectNpcID = 1010445, --微彩发放员 ID

		CostCoinValue = 10,	--消耗的货币数量
		CostCoinType = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE,	--金碟
	}

	--9个格子的数据，初始化为0		[1-9](左->右，上->下)
	self.CellDataMap = {}

	--读db
	local GlobalItemCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_MINI_CACTPOT_COST)
	if GlobalItemCfg then
		self.MiniCactpotInfo.CostCoinValue = GlobalItemCfg.Value[1]
	end
	GlobalItemCfg = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_MINI_CACTPOT_CHANCE)
	if GlobalItemCfg then
		self.MiniCactpotInfo.MaxChance = GlobalItemCfg.Value[1]
	end

	--奖励预览
	self.AwardOverviewMap = {}
	self.bWaitServerData = false
	self.bEnterWrold = false                -- 是否已经进入时间，防止OnWorldReady事件重复调用
	self.bNeedDialog = true	-- 控制收到回包后需不需要出现对话
	local AllCfgs = MinicactpotAwardOverviewCfg:FindAllCfg()
	self.MaxAwardNum = 0
	for _, AwardItem in ipairs(AllCfgs) do
		self.AwardOverviewMap[AwardItem.Sum] = AwardItem.Award

		if AwardItem.Award > self.MaxAwardNum then
			self.MaxAwardNum = AwardItem.Award
		end
	end
end

function MiniCactpotMgr:OnBegin()
	for index = 1, 9 do
		self.CellDataMap[index] = 0
	end
	MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)

	self.LastReqInfoTime = _G.DateTimeTools.GetDateTable(_G.TimeUtil.GetServerTime())

	--是不是已经出结果了，主要用于出结果后的奖励预览
	self.IsFinished = false
	self.bIsInProgress = false	--- 进行中
	--每局可以开启3个格子
	self.CanClickCellNum = 3

	--开启3个格子后，需要点选一个箭头（选择一条线），然后确认进行开奖
	self.ArrowIndex = 0
end

function MiniCactpotMgr:OnEnd()
	self:Reset()
end

--每次开局，也会进行一次reset
function MiniCactpotMgr:Reset()
	for index = 1, 9 do
		self.CellDataMap[index] = 0
	end
	
	self.CanClickCellNum = 3
	self.ArrowIndex = 0

	self.IsFinished = false
	self.bIsInProgress = false
end

function MiniCactpotMgr:OnShutdown()
end

function MiniCactpotMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MINI_CACTPOT, ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_ENTER, self.OnNetMsgEnterRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MINI_CACTPOT, ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_VIEW, self.OnNetMsgInfoRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MINI_CACTPOT, ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_CLICK_CELL, self.OnNetMsgClickCellRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MINI_CACTPOT, ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_FINISH, self.OnNetMsgFinishRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MINI_CACTPOT, ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_EXIT, self.OnNetMsgExit)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MINI_CACTPOT, ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_SCRATCH, self.OnNetMsgScratch)
end

--现在是每次开局去请求，回包后再开局，所以不用一打开客户端以及跨天 去请求了
function MiniCactpotMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldEnter)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)

    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
	self:RegisterGameEvent(EventID.EnterInteractionRange, self.OnGameEventEnterInteractionRange)

end

--- @type 当成功加载完世界
function MiniCactpotMgr:OnPWorldEnter(Parmas)
	local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = Parmas.CurrMapResID
    if Parmas.CurrMapResID == self.JDMapID then
        if self.bEnterWrold then
            return
        end
        self.bEnterWrold = true
		self.bNeedScratch = true
		self:SendMiniCactpotInfoReq(false)
	end
end

function MiniCactpotMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    local BaseInfo = PWorldMgr.BaseInfo
    if bReconnect and BaseInfo.CurrMapResID == self.JDMapID then
		self.bNeedScratch = true
        self:SendMiniCactpotInfoReq(false)
    end
end

--- @type 当退出世界
function MiniCactpotMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
	local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if LeaveMapResID == self.JDMapID then
        self.bEnterWrold = false
    end
end

-- --- @type 进入交互范围
function MiniCactpotMgr:OnGameEventEnterInteractionRange(Params)
	if Params.IntParam1 ~= _G.UE.EActorType.Npc then
        return
    end
	local NpcID = Params.ULongParam2
	if NpcID == MiniCactpotNpcID then
		self:SendMiniCactpotInfoReq(false)
	end
end

--- @type 结束交互
function MiniCactpotMgr:EndInteraction()
	NpcDialogMgr:EndInteraction()
end

--------------- 功能接口 ---------------
--是不是需要请求信息
--需要请求信息的，流程等回包后启动
--不需要请求信息的，直接启动流程
function MiniCactpotMgr:OnInteractiveClick(NpcId, NpcEntityId, FuncID, Values)
	local ExplainID = 150007	-- 对应仙人微彩说明
	if FuncID == ExplainID then
		local function Callback()
			self:EndInteraction()
		end
        NpcDialogMgr:PlayDialogLib(Values[1], nil, false, Callback)
		return
	end

	self.NpcResId = NpcId
	self.NpcEntityId = NpcEntityId


	local Chance = self.MiniCactpotInfo.LeftChance
	if Chance > 0 then
		self:ShowMainPanel()	-- 发送打页面协议
	else
		self:BeginDontDialog()
	end
end

--可以开始微彩，流程上会先开始一个对话
function MiniCactpotMgr:ShowMainPanel()
	self:ChangCostCoin()
	self.MiniCactpotMainView = UIViewMgr:ShowView(UIViewID.MiniCactpotMainFrame)
	local AudioPath = MiniCactpotDefine.AudioPath
	AudioUtil.LoadAndPlayUISound(AudioPath.Enter)
end

function MiniCactpotMgr:ChangCostCoin(bPlayAnim)
	local CostCoin = self:GetCostValue()
	MiniCactpotMainVM.CostCoinValue = CostCoin
	local Color = MiniCactpotDefine.Color
	MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	MiniCactpotMainVM.CostCoinColor = CostCoin > MiniCactpotMainVM.OwnerJDCoins and Color.Red or Color.Write
	if bPlayAnim then
		_G.EventMgr:SendEvent(EventID.PlayGetScoreAni, ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	end
end

--微彩次数已用完，会开始另外一个对话（明天再来等）
function MiniCactpotMgr:BeginDontDialog()
    local function DoStartAfterDialog()
		self:EndInteraction()
    end

	local DialogID = 11136

	Utils.PlayNpcDialog(
		self.NpcEntityId,
		DialogID,
		function()
			DoStartAfterDialog()
		end
	)
end

--- @type 当点击购买一次
function MiniCactpotMgr:OnBtnPurOnceClicked()
	local CoinNum = self:GetCostValue()
	local HaveNum = self:GetCurOwnCostValue()
	local Str
	if CoinNum > HaveNum then
		Str = string.format(LSTR(230005)) -- 金碟币不足
	else
		self:SendMiniCactpotEnterReq()
	end
	if Str then
		MsgTipsUtil.ShowTips(Str)
	end
end

function MiniCactpotMgr:ShouldWait()
	return self.bWaitServerData
end

function MiniCactpotMgr:ResetWait()
	self.bWaitServerData = false
end


function MiniCactpotMgr:IsLeftChance()
	return self.MiniCactpotInfo.LeftChance > 0
end

function MiniCactpotMgr:GetLeftChance()
	return self.MiniCactpotInfo.LeftChance
end

function MiniCactpotMgr:GetCurTurm()
	return self.MiniCactpotInfo.CurrentTerm or 1
end

function MiniCactpotMgr:GetCostValue()
	return self.MiniCactpotInfo.CostCoinValue or 0
end

function MiniCactpotMgr:GetCostTypeName()
	return _G.ScoreMgr:GetScoreName(self.MiniCactpotInfo.CostCoinType)
end

function MiniCactpotMgr:GetCurOwnCostValue()
	local HaveCoin = _G.ScoreMgr:GetScoreValueByID(self.MiniCactpotInfo.CostCoinType)
	return HaveCoin
end

function MiniCactpotMgr:GetCellNum(Index)
	return self.CellDataMap[Index]
end

function MiniCactpotMgr:GetCellDataMap()
	return self.CellDataMap
end

--是不是已经出结果了
function MiniCactpotMgr:GetIsFinished()
	return self.IsFinished
end

function MiniCactpotMgr:GetArrowIndex()
	return self.ArrowIndex
end

function MiniCactpotMgr:SetArrowIndex(Index)
	self.ArrowIndex = Index
end

function MiniCactpotMgr:GetMaxAwardNum()
	return self.MaxAwardNum
end

function MiniCactpotMgr:GetMaxPurNum()
	return self.MiniCactpotInfo.MaxChance
end

function MiniCactpotMgr:QueryLeftChance(CallBack, Params)
	local Info = {CallBack = CallBack, Params = Params}
	self.MiniInfoCallBack = Info
	
	self:RegisterTimer(self.SendMiniCactpotInfoReq, 0, nil, nil, false)

	local function WaitTimeOut()
		self.MiniInfoCallBack = nil
	end
	self:RegisterTimer(WaitTimeOut, WaitTime, nil, nil, nil)
end

function MiniCactpotMgr:ExcuteCallBackIfExist()	
	local MiniInfoCallBack = self.MiniInfoCallBack
	if MiniInfoCallBack ~= nil then
		MiniInfoCallBack.CallBack(MiniInfoCallBack.Params, self.MiniCactpotInfo.LeftChance, self.MiniCactpotInfo.MaxChance)
		self.MiniInfoCallBack = nil
	end
end

--------------- 网络：收发消息 ---------------
--微彩数据的请求
function MiniCactpotMgr:SendMiniCactpotInfoReq(bNeedDialog)
	self.bWaitServerData = true	-- 收到回包后变为为false
	self.bNeedDialog = bNeedDialog
	local MsgID = CS_CMD.CS_CMD_MINI_CACTPOT
	local SubCmd = ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_VIEW

	local MsgBody = {
		Operation = SubCmd,
		ViewReq = {}
	}

	self.LastReqInfoTime = _G.DateTimeTools.GetDateTable(_G.TimeUtil.GetServerTime())

	_G.GameNetworkMgr:SendMsg(MsgID, SubCmd, MsgBody)
end

--开始对局的请求，同时打开主界面（会自动先播放umg过场动效）
function MiniCactpotMgr:SendMiniCactpotEnterReq()
	self.bWaitServerData = true	-- 收到回包后变为为false
	-- self:RegisterTimer(function() self:ResetWait() end, 2)
	self:Reset()
	local MsgID = CS_CMD.CS_CMD_MINI_CACTPOT
	local SubCmd = ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_ENTER

	local MsgBody = {
		Operation = SubCmd,
		EnterReq = {NPCID = self.NpcResId}
	}

	_G.GameNetworkMgr:SendMsg(MsgID, SubCmd, MsgBody)
end

--开格子的请求
function MiniCactpotMgr:SendClickCellReq(CellIndex)
	self.bWaitServerData = true	-- 收到回包后变为为false

	if self.CanClickCellNum <= 0 then
		return
	end

	if self.CellDataMap[CellIndex] > 0 then
		return
	end

	local MsgID = CS_CMD.CS_CMD_MINI_CACTPOT
	local SubCmd = ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_CLICK_CELL

	local MsgBody = {
		Operation = SubCmd,
		ClickCellReq = {Index = CellIndex}
	}

	FLOG_INFO("MiniCactpot SendClickCellReq:%d", CellIndex)

	_G.GameNetworkMgr:SendMsg(MsgID, SubCmd, MsgBody)
end

--选一条线，获取结果的请求
function MiniCactpotMgr:SendFinishReq()
	if self.ArrowIndex > 8 or self.ArrowIndex <= 0 then
		FLOG_ERROR("MiniCactpot SendFinishReq:%d", self.ArrowIndex)
		return
	end

	local MsgID = CS_CMD.CS_CMD_MINI_CACTPOT
	local SubCmd = ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_FINISH
	local MsgBody = {
		Operation = SubCmd,
		FinishReq = {line = self.ArrowIndex}
	}

	_G.GameNetworkMgr:SendMsg(MsgID, SubCmd, MsgBody)
end

--开始对局的请求，同时打开主界面（会自动先播放umg过场动效）
function MiniCactpotMgr:SendMiniCactpotExit()
	self.bWaitServerData = true	-- 收到回包后变为为false
	local MsgID = CS_CMD.CS_CMD_MINI_CACTPOT
	local SubCmd = ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_EXIT
	local MsgBody = {
		Operation = SubCmd,
	}

	_G.GameNetworkMgr:SendMsg(MsgID, SubCmd, MsgBody)
end

function MiniCactpotMgr:SendMiniCactpotScratch()
	self.bWaitServerData = true	-- 收到回包后变为为false
	local MsgID = CS_CMD.CS_CMD_MINI_CACTPOT
	local SubCmd = ProtoCS.MINI_CACTPOT_OP.MINI_CACTPOT_OP_SCRATCH
	local MsgBody = {
		Operation = SubCmd,
	}

	_G.GameNetworkMgr:SendMsg(MsgID, SubCmd, MsgBody)
end

function MiniCactpotMgr:CheckNeedScrach()
	if self.bNeedScratch then
		self:SendMiniCactpotScratch()
		self.bNeedScratch = nil
	end
end

--微彩信息的回包
function MiniCactpotMgr:OnNetMsgInfoRsp(MsgBody)
	if MsgBody == nil then
		return
	end
	local ViewChanceRsp = MsgBody.ViewRsp
	if ViewChanceRsp then
		self.MiniCactpotInfo.CurrentTerm = ViewChanceRsp.CurrentTerm
		local LeftChance = ViewChanceRsp.Chance
		self.MiniCactpotInfo.LeftChance = LeftChance
		local MaxChance = self.MiniCactpotInfo.MaxChance
		MiniCactpotMainVM.RemainPurCount = string.format(LSTR(230006), LeftChance, MaxChance) -- "(剩余购买次数: %s/%s)"
		MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)

		local EntranceItem = self.EntranceItem
		-- if EntranceItem ~= nil and self.bNeedDialog then
		-- 	local ResID = EntranceItem.ResID
		-- 	if ResID == self.MiniCactpotInfo.RelectNpcID then
		-- 		local BeginDialogID = 76
		-- 		local Cfg = DialogCfg:FindCfgByKey(BeginDialogID)
		-- 		local DialogContent = Cfg.DialogContent
		-- 		local Content = string.gsub(DialogContent, "<MiniCactpotTerm>", tostring(self.MiniCactpotInfo.CurrentTerm), 1)
		-- 		NpcDialogMgr:PushDialog(Content, nil, EntranceItem.DisplayName, nil, nil)
		-- 	end
		-- end
	
		self:ExcuteCallBackIfExist()
		_G.GoldSauserMainPanelMgr:SetTheMsgUpdateState(GoldSauserGameClientType.GoldSauserGameTypeMiniCactpot, true)
	end

	self:CheckNeedScrach()
end

--微彩开始的回包
function MiniCactpotMgr:OnNetMsgEnterRsp(MsgBody)
	if MsgBody == nil then
		return
	end 
	local EnterRsp = MsgBody.EnterRsp
	if EnterRsp == nil or EnterRsp.InitIndex == 0 and EnterRsp.InitNumber == 0 then
		-- MsgTipsUtil.ShowTips(LSTR("实例已存在"))
		FLOG_INFO("MiniCactpot Instance Has Exit In Server")
		return
	end
	MsgTipsUtil.ShowTips(LSTR(230007)) -- 购买成功

	local AudioPath = MiniCactpotDefine.AudioPath
	AudioUtil.LoadAndPlayUISound(AudioPath.Buy)
	self.bIsInProgress = true
	self.MiniCactpotInfo.LeftChance = self.MiniCactpotInfo.LeftChance - 1
	MiniCactpotMainVM.RemainPurCount = string.format(LSTR(230006), self.MiniCactpotInfo.LeftChance, self.MiniCactpotInfo.MaxChance) -- (剩余购买次数: %s/%s)
	MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	if EnterRsp and EnterRsp.InitIndex then
		self.CellDataMap[EnterRsp.InitIndex] = EnterRsp.InitNumber

		FLOG_INFO("MiniCactpot EnterRsp Idx:%d, Num:%d", EnterRsp.InitIndex, EnterRsp.InitNumber)
		--打开
		MiniCactpotMainVM:OnMiniCactpotCellOpen(EnterRsp.InitIndex, EnterRsp.InitNumber, true)
	end
	_G.GoldSauserActivityMgr:CheckAndUpdateIconDissAppear(self.MiniCactpotIssuerNpc)
	-- _G.EventMgr:SendEvent(EventID.MiniCactpotBuyOneSuccess)
	if self.MiniCactpotMainView ~= nil then
		self.MiniCactpotMainView:OnNotifyBuySuccess()
	end
end

--开格子的回包
function MiniCactpotMgr:OnNetMsgClickCellRsp(MsgBody)
	if MsgBody == nil then
		return
	end
	if MsgBody.ClickCellRsp and MsgBody.ClickCellRsp.Index then
		self:OnClickCell(MsgBody.ClickCellRsp, false)
	end
end

function MiniCactpotMgr:OnClickCell(ClickCellRsp, bFirstEnter)
	self.CellDataMap[ClickCellRsp.Index] = ClickCellRsp.Number
	FLOG_INFO("MiniCactpot ClickCellRsp Idx:%d, Num:%d", ClickCellRsp.Index, ClickCellRsp.Number)
	--打开
	MiniCactpotMainVM:OnMiniCactpotCellOpen(ClickCellRsp.Index, ClickCellRsp.Number, bFirstEnter)

	if self.CanClickCellNum == 0 then
		self:ShowEnterTip()
	end

	local AudioPath = MiniCactpotDefine.AudioPath
	AudioUtil.LoadAndPlayUISound(AudioPath.OpenNum)
end

--微彩开奖结果
function MiniCactpotMgr:OnNetMsgFinishRsp(MsgBody)
	if MsgBody == nil then
		return
	end 
	local FinishRsp = MsgBody.FinishRsp
	if FinishRsp and FinishRsp.AllCells then
		self.bIsInProgress = false

		for index = 1, #FinishRsp.AllCells do
			self.CellDataMap[index] = FinishRsp.AllCells[index]
		end

		self.IsFinished = true
		-- MiniCactpotMainVM.OwnerJDCoins = ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
		local CostCoin = self:GetCostValue()
		local Color = MiniCactpotDefine.Color
		MiniCactpotMainVM.CostCoinValue = CostCoin
		MiniCactpotMainVM.CostCoinColor2 = CostCoin > ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE) and Color.Red or Color.Default
		MiniCactpotMainVM:OnMiniCactpotFinish(FinishRsp)
		self:SendMiniCactpotInfoReq(false)
		local function OpenRewardPanel()
			local JDCoinID = 19000004
			local Cfg = ItemCfg:FindCfgByKey(JDCoinID)
			if Cfg == nil then
				return
			end
			local AwardCoins = FinishRsp.AwardCoins
			local Data = {}

			local Temp = {}
			Temp.ID = JDCoinID
			Temp.Num = AwardCoins
			Temp.ItemName = ItemCfg:GetItemName(JDCoinID)
			Temp.Icon = ItemCfg.GetIconPath(Cfg.IconID)
			table.insert(Data, Temp)

			local ListVM = GoldSauserMgr:UpdateRewardListVM(Data)
			local Title = LSTR(230008) -- "获得奖励"
			local AudioPath = MiniCactpotDefine.AudioPath
			AudioUtil.LoadAndPlayUISound(AudioPath.GetReward)
			if FinishRsp.AwardCoins >= 3600 then
				AudioUtil.LoadAndPlayUISound(AudioPath.BestReward)
				UIViewMgr:ShowView(UIViewID.MiniCactpotRewardTip, FinishRsp.AwardCoins) --这其实就是个动效
			end
			GoldSauserMgr:ShowCommRewardPanel(ListVM, Title, nil)
		end
		self.GetRewardTimer = self:RegisterTimer(OpenRewardPanel, 3, 0, 1, self)

		FLOG_INFO("MiniCactpot FinishRsp, AwardCoins:%d, leftChance:%d"
			, FinishRsp.AwardCoins, self.MiniCactpotInfo.LeftChance)
	end
end

--- @type 当收到退出消息
function MiniCactpotMgr:OnNetMsgExit(MsgBody)
	if MsgBody == nil then
		return
	end
	if self.MiniCactpotMainView == nil then
		return
	end

	if not UIViewMgr:FindView(UIViewID.MiniCactpotMainFrame) then
		return
	end

	self.MiniCactpotMainView:OnRsqExitMsg()
end

function MiniCactpotMgr:OnNetMsgScratch(MsgBody)
	if MsgBody == nil then
		return
	end
	local ScratchRsp = MsgBody.ScratchRsp
	local ScratchData = ScratchRsp.ScratchData
	if ScratchData == nil or #ScratchData < 1 then
		return
	end
	self.bIsInProgress = true
	if not UIViewMgr:FindView(UIViewID.MiniCactpotMainFrame) then			--- 重登
		self:ShowMainPanel()
		self.MiniCactpotMainView:OnNotifyBuySuccess()
		for i, data in pairs(ScratchData) do
			self:OnClickCell({Index = data.Index, Number = data.Number}, i == 1)
		end
	else
		--- TODO 重连
	end
end

function MiniCactpotMgr:CheckNeedRefreshData(LastHour, NewHour)
	if tonumber(NewHour) ~= tonumber(RefreshHour) then
		return
	end

	if tonumber(LastHour) == RefreshHour - 1 and tonumber(NewHour) == RefreshHour then
		self:SendMiniCactpotInfoReq()
	end
end

--- @type 玩家
function MiniCactpotMgr:ShowEnterTip()
	local function ShowMiniCactpotOpenThreeBoxTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.MiniCactpot
        EventParams.Param2 = TutorialDefine.GamePlayStage.MiniCactpotOpenThreeBox
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
	FLOG_INFO("Show Enter Game Tip")

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowMiniCactpotOpenThreeBoxTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--- @type 玩家选择完一条直接后调用
function MiniCactpotMgr:ShowSelectLineTip()
	local function ShowMiniCactpotSelectLineTutorial(Params)
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.GamePlayCondition--新手引导触发类型
        EventParams.Param1 = TutorialDefine.GameplayType.MiniCactpot
        EventParams.Param2 = TutorialDefine.GamePlayStage.MiniCactpotSelectLine
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
	FLOG_INFO("Show Select Line Tip")
    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = ShowMiniCactpotSelectLineTutorial, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

return MiniCactpotMgr

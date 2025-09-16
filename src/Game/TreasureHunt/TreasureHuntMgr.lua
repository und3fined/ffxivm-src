-- Author : easyzhu
-- Desc   : 寻宝相关逻辑

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local RichTextUtil = require("Utils/RichTextUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemUtil = require("Utils/ItemUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EffectUtil = require("Utils/EffectUtil")
local AudioUtil = require("Utils/AudioUtil")
local AnimationUtil = require("Utils/AnimationUtil")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewID = require("Define/UIViewID")
local InterpretTreasureMapCfg = require("TableCfg/InterpretTreasureMapCfg")
local UserDataID = require("Define/UserDataID")
local ProtoCommon = require("Protocol/ProtoCommon")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local CommonUtil = require("Utils/CommonUtil")
local BusinessUIMgr = require("UI/BusinessUIMgr")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")

local EActorType = nil
local GameNetworkMgr = nil
local PWorldMgr = nil
local UIViewMgr = nil
local MsgTipsUtil = nil
local MsgBoxUtil = nil
local EventMgr = nil
local RollMgr = nil
local RoleInfoMgr = nil
local InteractiveMgr = nil
local SkillObjectMgr = nil
local EventID = nil
local LSTR = nil
local TeamMgr = nil
local UE = nil

local TreasureHuntMainVM = nil
local TreasureHuntSkillPanelVM = nil

local ProtoCS = require("Protocol/ProtoCS")
local CS_CMD_TREASURE_HUNT = ProtoCS.CS_CMD.CS_CMD_TREASURE_HUNT
local TREASURE_HUNT_CMD = ProtoCS.Game.TreasureHunt.CmdTreasureHunt
local TreasureHuntState = ProtoCS.Game.TreasureHunt.TreasureHuntState
local TreasureHuntBoxStatus = ProtoCS.Game.TreasureHunt.EStatus
local TreasureHuntEOpsType = ProtoCS.Game.TreasureHunt.EOpsType
local EDigType = ProtoCS.Game.TreasureHunt.EDigType
local ETreasureType = ProtoCS.Game.TreasureHunt.ETreasureType
local CS_CMD_VISION = ProtoCS.CS_CMD.CS_CMD_VISION
local VISION_CMD = ProtoCS.CS_VISION_CMD

local VfxFadeInTime = 0.25

local TreasureHuntMgr = LuaClass(MgrBase)
---OnInit
function TreasureHuntMgr:OnInit()
	--只初始化自身模块的数据，不能引用其他的同级模块
end

---OnBegin
function TreasureHuntMgr:OnBegin()
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）

	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	GameNetworkMgr = _G.GameNetworkMgr
	UIViewMgr = _G.UIViewMgr
	MsgBoxUtil = _G.MsgBoxUtil
	EventMgr = _G.EventMgr
	RollMgr = _G.RollMgr
	RoleInfoMgr = _G.RoleInfoMgr
	EventID = _G.EventID
	MsgTipsUtil = _G.MsgTipsUtil
    LSTR = _G.LSTR
	EActorType = _G.UE.EActorType
	TeamMgr = _G.TeamMgr
	InteractiveMgr = _G.InteractiveMgr
	SkillObjectMgr = _G.SkillObjectMgr
	PWorldMgr = _G.PWorldMgr
	UE = _G.UE

    TreasureHuntMainVM = _G.TreasureHuntMainVM
	TreasureHuntSkillPanelVM = _G.TreasureHuntSkillPanelVM

	-- 挖宝时间  GLOBAL_CFG_TREASURE_HUNT_DIG
	local Value = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_TREASURE_HUNT_DIG, "Value") or {}
	self.TreasureHuntTimeLimit = tonumber(Value[2]) or 0
	self.TreasureHuntRadius = tonumber(Value[1]) or 0
	self.RecruitMethod = tonumber(Value[3]) or 0

	self:ResetData()
end

function TreasureHuntMgr:OnEnd()
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
	self:ResetData()
end

function TreasureHuntMgr:OnShutdown()
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function TreasureHuntMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.InterpretMap, self.OnNetMsgInterpretMap)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.DigTreasure, self.OnNetMsgDigTreasure)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.TreasureHuntInfo, self.OnNetMsgTreasureHuntInfo)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.TreasureAllMap, self.OnNetMsgTreasureAllMap)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.InterpretFinMap, self.OnNetMsgInterpretFinMap)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.DigTreasureActNotify, self.OnNetMsgDigTreasureActNotify)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.OpenMapNotify, self.OnNetMsgNotifyOpenMap)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.OpenWildBox, self.OnNetMsgOpenWildBox)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.DiscardMap, self.OnNetMsgNotifyDiscardMap)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.CheckInterpretMap, self.OnNetMsgCheckInterpretMap)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.TeleportInviteNotify, self.OnNetMsgNotifyTeleportInvite)
	self:RegisterGameNetMsg(CS_CMD_TREASURE_HUNT, TREASURE_HUNT_CMD.TreasureDigFinNotify, self.OnNetMsgNotifyTreasureDigFin)

	self:RegisterGameNetMsg(CS_CMD_VISION, VISION_CMD.CS_VISION_CMD_USER_DATA_CHG,self.OnVisionUserDataUpdate)
end

function TreasureHuntMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)

	self:RegisterGameEvent(EventID.TreasureHuntGetItem, self.OnGameEventTreasureHuntGetItem)
	self:RegisterGameEvent(EventID.TreasureHuntDropItem, self.OnGameEventTreasureHuntDropItem)
	self:RegisterGameEvent(EventID.FixedFunctionPanelShowed, self.OnFixedFunctionPanelShowed)
	self:RegisterGameEvent(EventID.TeamCaptainChanged,self.OnGameEventTeamCaptainChanged)
	self:RegisterGameEvent(EventID.TeamLeave, self.OnGameEventTeamLeave)
	self:RegisterGameEvent(EventID.TeamUpdateMember, self.OnGameEventTeamUpdateMember)
	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
	self:RegisterGameEvent(EventID.TrivialSkillStart, self.OnGameEventTrivialSkillStart)
	self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)

	self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnGameEventMajorSingBarOver)

	--角色移动，使用技能、死亡、触发交互时，都会取消当前的挖宝动作
	self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.OnGameEventActorVelocityUpdate)    -- 角色速度改变
	self:RegisterGameEvent(EventID.MajorFirstMove, self.OnGameEventBreakAnim)   -- 停止时首次移动
	self:RegisterGameEvent(EventID.StartAutoMoving, self.OnGameEventBreakAnim)  -- 开始寻路
	self:RegisterGameEvent(EventID.TrivialSkillStart,	self.OnGameEventBreakAnim)	--使用技能
	self:RegisterGameEvent(EventID.TrivialSkillEnd , 	self.OnGameEventBreakAnim)	--技能结束
	self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventBreakAnim)    -- 主角死亡
	self:RegisterGameEvent(EventID.MajorHit, self.OnGameEventBreakAnim) -- 主角受击
	self:RegisterGameEvent(EventID.PostEmotionEnter, self.OnGameEventBreakAnim) -- 主角受击
	self:RegisterGameEvent(EventID.TreasureHuntBreakAnim, self.OnGameEventBreakAnim)
end

function TreasureHuntMgr:OnGameEventPWorldMapEnter(Params)
	if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDTreasureHunt) then
        return
    end

	self:ClearSettleTimer()
	self.TreasureHuntSelfData = {}
	self.TreasureHuntTeamData = {}
	self:TreasureHuntInfoReq()
end

function TreasureHuntMgr:OnGameEventPWorldMapExit()
	-- 离开地图时清理挖掘中的玩家数据
	self.DiggingMap = {}
	self:ClearSettleTimer()
end

function TreasureHuntMgr:ResetData()
	self.MarkerEffect = nil
	self.TeamMapData = nil
	self.IsTeamTreasureHunt = false
	self.TreasureHuntSelfData = {}
	self.TreasureHuntTeamData = {}
	self.SkillEffectIDMap = {}
	self.SmokeEffectIDMap = {}
    self.BoxUnlockEffectIDMap = {}
	self.BoxLockEffectIDMap = {}
	self.DiggingMap = {}
	self.OpenMainViewParams = nil
end

------------------------------------------
-- 网络通讯相关的逻辑
------------------------------------------
-- 使用未解读的地图
function TreasureHuntMgr:DecodeTreasureMap(ResID)
	local Major = MajorUtil.GetMajor()
	if Major:IsInFly() then 
		MsgTipsUtil.ShowTips(LSTR(640001)) -- 飞行状态下，无法解读宝图
		return 
	elseif Major.CharacterMovement:IsFalling() then
		MsgTipsUtil.ShowTips(LSTR(640002)) --坠落过程中，无法解读宝图
		return
	end

	self:CloseNormalLayerUI()
	local function CancelCallback()
		local Item = _G.BagMgr:GetItemByResID(ResID)

		local DecodeResID = TreasureHuntMainVM:GetDecodeMapID(ResID)
		if DecodeResID ~= nil then 
			local DecodeItemName = ItemUtil.GetItemName(DecodeResID)  
			MsgTipsUtil.ShowTipsByID(109202, nil, DecodeItemName)
		else
			if self.IsInRide then
				if Item ~= nil then
					self.TimeId = self:RegisterTimer(self.OnFinishCallback, 0, 1.5, 0, {ItemData = Item})
				end
			elseif (Item ~= nil) then
				self:DoUseItem(Item.GID)
			end
		end
	end

	local RideCom = Major:GetRideComponent()
	if RideCom and RideCom:IsInRide() then
		self.IsInRide = true
        _G.MountMgr:SendMountCancelCall(CancelCallback)
	else
		self.IsInRide = false
		CancelCallback()
	end

    --edit by sammrli
	if _G.ChocoboTransportMgr:GetIsTransporting() then
		_G.ChocoboTransportMgr:CancelTrasport()
	end
end

function TreasureHuntMgr:OnFinishCallback(Params)
	if self.TimeId ~= nil then
        self:UnRegisterTimer(self.TimeId)
        self.TimeId = nil
    end

	if Params == nil then return end

	self:DoUseItem(Params.ItemData.GID)
end

function TreasureHuntMgr:DoUseItem(ItemID)
	--自动寻路处理
	local IsAutoPathMovingState = _G.AutoPathMoveMgr:IsAutoPathMovingState()
	if IsAutoPathMovingState then
		_G.AutoPathMoveMgr:StopAutoPathMoving()

		local function DelayUseItem()
			_G.BagMgr:UseItem(ItemID, nil)
		end

		self:RegisterTimer(DelayUseItem, 0.03, 1, 1)
	else
		_G.BagMgr:UseItem(ItemID, nil)
	end	
end

-- 请求宝图解读
function TreasureHuntMgr:InterpretMapReq(MapID)
	local SubMsgID = TREASURE_HUNT_CMD.InterpretMap
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.TreasureMap = {}
	MsgBody.TreasureMap.ID = MapID 

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

-- 通知服务器开始挖掘，广播别的玩家播放动作
function TreasureHuntMgr:PreDigTreasureReq()
    local SubMsgID = TREASURE_HUNT_CMD.PreDigTreasure

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.PreDigTreasure = {}
    MsgBody.PreDigTreasure.RoleID = MajorUtil.GetMajorRoleID()

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

-- 请求挖宝
function TreasureHuntMgr:DigTreasureReq(MapID)
    local SubMsgID = TREASURE_HUNT_CMD.DigTreasure

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.DigTreasure = {}
    MsgBody.DigTreasure.ID = MapID

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--表演宝箱领奖
function TreasureHuntMgr:TreasureAwardReq(ResID,EntityID)
    local SubMsgID = TREASURE_HUNT_CMD.TreasureAward

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.TreasureHuntInfo = {}
    MsgBody.TreasureAward.ResID = ResID
    MsgBody.TreasureAward.EntityID = EntityID

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

-- 获取寻宝状态
function TreasureHuntMgr:TreasureHuntInfoReq()
    local SubMsgID = TREASURE_HUNT_CMD.TreasureHuntInfo

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.TreasureHuntInfo = {}

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

-- 请求宝图信息
function TreasureHuntMgr:GetTreasureAllMapReq()
    local SubMsgID = TREASURE_HUNT_CMD.TreasureAllMap

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.TreasureAllMap = {}

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--请求标记
function TreasureHuntMgr:TreasureMarkPointReq(ID)
	local SubMsgID = TREASURE_HUNT_CMD.MarkPointTreasureMap

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.MarkPoint = {}
    MsgBody.MarkPoint.ID = ID

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--打开野外宝箱
function TreasureHuntMgr:OpenWildBoxReq(ResID,EntityID)
	local SubMsgID = TREASURE_HUNT_CMD.OpenWildBox

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.OpenWildBox = {}
    MsgBody.OpenWildBox.ResID = ResID
	MsgBody.OpenWildBox.EntityID = EntityID

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--丢弃宝图
function TreasureHuntMgr:DiscardMapReq(ResID)
	local SubMsgID = TREASURE_HUNT_CMD.DiscardMap

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.DiscardMap = {}
    MsgBody.DiscardMap.ResID = ResID

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

--校验解读宝图,参数 宝图资源ID 角色ID ，宝图解读时间
function TreasureHuntMgr:CheckInterpretMapReq(MapData)
	if MapData == nil then return end 
	if self:IsInDungeon() then return end

	self.CheckMapData = MapData
	local SubMsgID = TREASURE_HUNT_CMD.CheckInterpretMap

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.CheckInterpretMap = {ResID = MapData.ID, RoleID = MapData.RoleID, InterpretTime = MapData.InterpretTime}

	GameNetworkMgr:SendMsg(CS_CMD_TREASURE_HUNT, SubMsgID, MsgBody)
end

-- 宝图信息回包
function TreasureHuntMgr:OnNetMsgTreasureAllMap(MsgBody)
	if MsgBody == nil then return end

	local TreasureAllMap = MsgBody.TreasureAllMap  
	if TreasureAllMap == nil then return end
	
	TreasureHuntMainVM:UpdateMapData(TreasureAllMap)
	UIViewMgr:ShowView(UIViewID.TreasureHuntMainPanel, self.OpenMainViewParams)
	self.OpenMainViewParams = nil
end

-- 打开已经解读过的宝图界面
function TreasureHuntMgr:OnNetMsgInterpretMap(MsgBody)
	if MsgBody == nil then return end

	local TreasureMap = MsgBody.TreasureMap
	if TreasureMap == nil then return end

	self:CloseNormalLayerUI()
	local MapData = TreasureMap
	MapData.RoleID = MajorUtil.GetMajorRoleID()
	TreasureHuntSkillPanelVM:ShowSkillPanel(MapData)
end

-- 组队广播解读宝图消息
function TreasureHuntMgr:OnNetMsgNotifyOpenMap(MsgBody)	
	if MsgBody == nil then return end

	local TreasureMap = MsgBody.OpenMap
	if TreasureMap == nil then return end

	local MapData = TreasureMap.Map
	if MapData == nil then return end

	if TreasureMap.Ops == TreasureHuntEOpsType.MarkPoint then
		if MapData.MarkPoint then
			TreasureHuntSkillPanelVM:SetMarkTreasureMap()
			self.TeamMapData = MapData

			local MemberName = ""
			local function Callback(_, RoleVM)
				if RoleVM ~= nil then
					MemberName = RoleVM.Name
				end
			end
			RoleInfoMgr:QueryRoleSimple(TreasureMap.Sender, Callback)

			local strContent = MemberName..LSTR(640004)..RichTextUtil.GetText(string.format(LSTR(640005)), "D1BA8EFF")  -- 标记了，宝箱位置
			MsgTipsUtil.ShowTips(strContent)

			--标记后在场景中显示标记
			self:CreateMarkedObject(MapData.Pos)
		end
	elseif TreasureMap.Ops == TreasureHuntEOpsType.OpenMap then
		if _G.TreasureHuntMgr:IsInDungeon(false) then return end
		self.TeamMapData = MapData

		local TreasureMapEx = MapData
		TreasureMapEx.RoleID = TreasureMap.RoleID

		local TeamLeader = ""
		local function Callback(_, RoleVM)
			if RoleVM ~= nil then
				TeamLeader = RoleVM.Name
			end
		end
		RoleInfoMgr:QueryRoleSimple(TreasureMap.RoleID, Callback)

		local TreasureMapCfg = InterpretTreasureMapCfg:FindCfgByKey(TreasureMapEx.ID)
		if TreasureMapCfg ~= nil then 
			local UnDecodeItemName = ItemUtil.GetItemName(TreasureMapCfg.UnReadID)	 
			local strContent = TeamLeader..string.format(LSTR(640006),RichTextUtil.GetText(string.format("%s", UnDecodeItemName), "D1BA8EFF"))  --使用了%s
			MsgTipsUtil.ShowTips(strContent)
		end

		if TreasureMapEx.MapResID ~= nil then
			self:CloseNormalLayerUI()
			TreasureHuntSkillPanelVM:ShowSkillPanel(TreasureMapEx)
		end

		--如果已经标记过的地图，则在场景中显示标记
		if TreasureMapEx.MarkPoint then
			self:CreateMarkedObject(MapData.Pos)
		end
	elseif TreasureMap.Ops == TreasureHuntEOpsType.CloseMap then 
		--服务器通知不在视野内的队友，关闭宝图界面
		-- 在地图上添加地图信息
		local MajorRoleID =  MajorUtil.GetMajorRoleID()
		local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
		if CurMapData ~= nil and CurMapData.RoleID ~= MajorRoleID then 
			local Data = table.shallowcopy(CurMapData, true)
			Data.StartTime = TimeUtil.GetServerLogicTime()
			self:AddTreasureHuntTeamData(Data)
			EventMgr:SendEvent(EventID.TreasureHuntAddMapMine, Data)

			TreasureHuntSkillPanelVM:CloseSkillPanel()
			-- 删除标记
			self:DestoryMarkedObject()
		end
	end
end

function TreasureHuntMgr:OnNetMsgOpenWildBox(MsgBody)
	if MsgBody == nil then return end
end

function TreasureHuntMgr:OnNetMsgNotifyDiscardMap(MsgBody)
	if MsgBody == nil then return end

	local DiscardMap = MsgBody.DiscardMap
	if DiscardMap then
		if TreasureHuntMainVM:GetTreasureHuntMap(DiscardMap.ResID) ~= nil then
			local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
			if CurMapData ~= nil then 
				if CurMapData.RoleID == DiscardMap.RoleID then
					TreasureHuntSkillPanelVM:CloseSkillPanel()	
				end
			end
		end
	end
    -- 删除标记
	self:DestoryMarkedObject()
end

function TreasureHuntMgr:OnNetMsgCheckInterpretMap(MsgBody)
	if MsgBody == nil then return end

	local CheckInterpretMap = MsgBody.CheckInterpretMap
	if CheckInterpretMap.Ret == 0 then
		-- 关闭聊天界面
		if UIViewMgr:IsViewVisible(UIViewID.ChatMainPanel) then
			UIViewMgr:HideView(UIViewID.ChatMainPanel)
		end

        if self.TeamMapData ~= nil then
            if self.CheckMapData.MapResID == self.TeamMapData.MapResID then 
                self.CheckMapData.MarkPoint = self.TeamMapData.MarkPoint
            end
        end

		TreasureHuntSkillPanelVM:ShowSkillPanel(self.CheckMapData)
	else
		local DecodeItemName = ItemUtil.GetItemName(self.CheckMapData.ID)
		local strContent = string.format(LSTR(640007),RichTextUtil.GetText(string.format("%s", DecodeItemName), "D1BA8EFF")) --%s 已过期
		MsgTipsUtil.ShowTips(strContent)
	end
end

--解读宝图信息回包
function TreasureHuntMgr:OnNetMsgInterpretFinMap(MsgBody)	
	if MsgBody == nil then return end

	local InterpretFinMap = MsgBody.InterpretFinMap   
	if InterpretFinMap == nil then return end

	local bMulti = false
	local TreasureMapCfg = InterpretTreasureMapCfg:FindCfgByKey(InterpretFinMap.ID)
	if TreasureMapCfg ~= nil then 
		bMulti = TreasureMapCfg.Number > 1
		local UnDecodeItemName = ItemUtil.GetItemName(TreasureMapCfg.UnReadID)	 
		local strContent = string.format(LSTR(640008),RichTextUtil.GetText(string.format("%s", UnDecodeItemName), "D1BA8EFF"))  --%s解读成功
		MsgTipsUtil.ShowTips(strContent)
	end

	self:CloseNormalLayerUI()	
	local MapData = InterpretFinMap
	local MajorRoleID =  MajorUtil.GetMajorRoleID()
	MapData.RoleID = MajorRoleID
	TreasureHuntSkillPanelVM:ShowSkillPanel(MapData)

	--如果是多人,并且是队长
	if bMulti and TeamMgr:IsCaptain() then
		local TreasureMapEx = InterpretFinMap
		TreasureMapEx.RoleID = MajorRoleID
		_G.ChatMgr:AddTeamTreasureMapChatMsg(TeamMgr:GetTeamID(), MajorRoleID,TreasureMapEx)
	end
end

-- 挖宝回包
function TreasureHuntMgr:OnNetMsgDigTreasure(MsgBody)	
	if MsgBody == nil then return end

	local DigTreasure = MsgBody.DigTreasure 
	if DigTreasure then
		local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
		if CurMapData ~= nil then
			TreasureHuntSkillPanelVM:CloseSkillPanel()
			self:DestoryMarkedObject()
			CurMapData.StartTime = DigTreasure.StartTime
			self:AddTreasureHuntSelfData(CurMapData)   -- 服务器这个时候没有更新数据，所以需要添加一个
			EventMgr:SendEvent(EventID.TreasureHuntAddMapMine, CurMapData)
		end
	elseif MsgBody.ErrorCode ~= nil then
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		self:ExitDiggingState(MajorEntityID, true)
	end
end

-- 广播挖宝过程,视野内
function TreasureHuntMgr:OnNetMsgDigTreasureActNotify(MsgBody)
	if MsgBody == nil then 	return 	end

	local DigNotify  = MsgBody.DigNotify    
	if DigNotify  == nil then return end
	
	local EntityID = ActorUtil.GetEntityIDByRoleID(DigNotify.RoleID)

	if DigNotify.DigType == EDigType.PreStart then 
        -- 进入挖掘状态
		self:EnterDiggingState(EntityID)
    elseif DigNotify.DigType == EDigType.Finish then
        -- 退出挖掘状态
		self:ExitDiggingState(EntityID)
    end
end

-- 获取寻宝状态信息回包
function TreasureHuntMgr:OnNetMsgTreasureHuntInfo(MsgBody)
	if MsgBody == nil then return end

	local TreasureHuntInfo = MsgBody.TreasureHuntInfo    
	if TreasureHuntInfo == nil then return end

	if CommonUtil.IsWithEditor() then
		FLOG_INFO("TreasureHuntMgr:OnNetMsgTreasureHuntInfo " .. _G.table_to_string_block(MsgBody))
	end

	self.TreasureHuntTeamData = {}
	self.TreasureHuntSelfData = {}
	local Datas = TreasureHuntInfo.data
	for _, Data in pairs(Datas) do
		if Data.State ~= TreasureHuntState.Treasure_Fin then
			self:AddTreasureHuntSelfData(Data)
		end
	end

	local TeamDigs = TreasureHuntInfo.teamDigs
	for _, Data in pairs(TeamDigs) do
		if Data.State ~= TreasureHuntState.Treasure_Fin then
			self:AddTreasureHuntTeamData(Data)
		end
	end

	self.TeamMapData = TreasureHuntInfo.teamMap
	if self.TeamMapData ~= nil then
		if self.TeamMapData.MarkPoint then
			TreasureHuntSkillPanelVM:SetMarkTreasureMap()
			local localMapID = PWorldMgr:GetCurrMapResID()
			if self.TeamMapData.MapResID == localMapID then
				self:CreateMarkedObject(self.TeamMapData.Pos)
			end
		end
	end

	-- 刷新小地图和世界地图宝箱信息
	EventMgr:SendEvent(EventID.TreasureHuntUpdateMapMine)
end

function TreasureHuntMgr:OnNetMsgNotifyTeleportInvite(MsgBody)
	if MsgBody == nil then return end

	local NotifyTeleportInvite = MsgBody.TeleportInvite
	if NotifyTeleportInvite  == nil then return end

    -- 新魔纹生成时旧魔纹会算寻宝结束，要把结束弹窗清掉
    self:ClearSettleTimer()
    -- 出现魔纹时弹出新手引导，对队伍内所有队员都会弹出
	self:HandleTeleportTutorial()
end

function TreasureHuntMgr:OnNetMsgNotifyTreasureDigFin(MsgBody)
	local FinishData = MsgBody and MsgBody[MsgBody.Data]
	if FinishData == nil then return end

	if CommonUtil.IsWithEditor() then
		FLOG_INFO("TreasureHuntMgr:OnNetMsgNotifyTreasureDigFin " .. _G.table_to_string_block(MsgBody))
	end

	local FindData = false
	for _, Info in pairs(self.TreasureHuntSelfData) do
		if Info.PosID == FinishData.PosID then
			self.TreasureHuntSelfData[Info.PosID] = nil
			FindData = true
			break
		end
	end

	-- 如果已经找到了就不用再找了
	if not FindData then
		for _, Info in pairs(self.TreasureHuntTeamData) do
			if Info.PosID == FinishData.PosID then
				self.TreasureHuntTeamData[Info.PosID] = nil
				FindData = true
				break
			end
		end
	end

	if FindData then
		EventMgr:SendEvent(EventID.TreasureHuntRemoveMapMine, { FinishData })

		if TeamMgr:IsInTeam() then
			self.IsTeamTreasureHunt = true
		end

		local AskDelay = 3
		self.SettleTimerID = self:RegisterTimer(function()
			if MajorUtil.GetMajorRoleID() == FinishData.RoleID then
				local Cfg = InterpretTreasureMapCfg:FindCfgByKey(FinishData.ID)
				self:ShowSettlementPanel(Cfg)
			end
			self.SettleTimerID = nil
			self.IsTeamTreasureHunt = false
		end, AskDelay)
	end
end

------------------------------------------
-- 事件相关的逻辑
------------------------------------------
function TreasureHuntMgr:OnGameEventTreasureHuntGetItem()
	-- 刷新下寻宝主界面
	if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntMainPanel) then
		TreasureHuntMainVM:UpdateMapItems()
	end
end

function TreasureHuntMgr:OnGameEventTreasureHuntDropItem(Params)
	if Params == nil then return end
	local ResID = Params.ResID
	-- 服务器要求非组队也要请求丢弃
	if TreasureHuntMainVM:GetTreasureHuntMap(ResID) ~= nil then 
		self:DiscardMapReq(ResID)
	end

	-- 刷新下寻宝主界面
	if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntMainPanel) then
		TreasureHuntMainVM:UpdateMapItems()
	end
	
	-- 关闭挖宝界面
	local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
	if CurMapData ~= nil and ResID == CurMapData.MapResID then
		TreasureHuntSkillPanelVM:CloseSkillPanel()
	end
end
-------------------------------------------

--- 打开寻宝主界面
---@param Params table 参数
function TreasureHuntMgr:OpenTreasureHuntMainPanel(Params)
	if not _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDTreasureHunt) then return end
	
	self.OpenMainViewParams = Params
	self:GetTreasureAllMapReq()
end

function TreasureHuntMgr:CloseNormalLayerUI()
	if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntMainPanel) then
		UIViewMgr:HideView(UIViewID.TreasureHuntMainPanel)
	end
	if UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel) then
		UIViewMgr:HideView(UIViewID.WorldMapPanel)
	end
	if UIViewMgr:IsViewVisible(UIViewID.BagMain) then
		UIViewMgr:HideView(UIViewID.BagMain)
	end
	if UIViewMgr:IsViewVisible(UIViewID.Main2ndPanel) then
		UIViewMgr:HideView(UIViewID.Main2ndPanel)
	end
	if UIViewMgr:IsViewVisible(UIViewID.WorldExploraMainPanel) then
		UIViewMgr:HideView(UIViewID.WorldExploraMainPanel)
	end
	if UIViewMgr:IsViewVisible(UIViewID.OpsActivityMainPanel) then
		UIViewMgr:HideView(UIViewID.OpsActivityMainPanel)
	end
end


-- 获得可以挖宝的半径
function TreasureHuntMgr:GetTreasureHuntRadius()
	return self.TreasureHuntRadius/100
end

-- 招募方式
function TreasureHuntMgr:GetRecruitMethod()
	return self.RecruitMethod
end

-- 挖宝的时间限制
function TreasureHuntMgr:GetTreasureHuntTimeLimit()
	return self.TreasureHuntTimeLimit
end

function TreasureHuntMgr:GetTreasureHuntSelfDataCount()
	local Count = 0
	for _, Info in pairs(self.TreasureHuntSelfData) do
		if not table.is_nil_empty(Info) then
			Count = Count + 1
		end
	end
	return Count
end

function TreasureHuntMgr:GetTreasureHuntSelfData()
	return self.TreasureHuntSelfData
end

function TreasureHuntMgr:GetTreasureHuntTeamDataCount()
	local Count = 0
	for _, Info in pairs(self.TreasureHuntTeamData) do
		if not table.is_nil_empty(Info) then
			Count = Count + 1
		end
	end
	return Count
end

function TreasureHuntMgr:GetTreasureHuntTeamData()
	return self.TreasureHuntTeamData
end

function TreasureHuntMgr:AddTreasureHuntSelfData(Data)
	local ID = Data.PosID
	self.TreasureHuntSelfData[ID] = Data
end

function TreasureHuntMgr:AddTreasureHuntTeamData(Data)
	local ID = Data.PosID
	self.TreasureHuntTeamData[ID] = Data
end

-- 检查当前位置是挖宝结束
function TreasureHuntMgr:CheckTreasureHuntFinish()
	if self.TreasureHuntSelfData ~= nil then
		for _, Info in pairs(self.TreasureHuntSelfData) do
			if Info.State == TreasureHuntState.Treasure_Fin then
				return true
			end
		end
	end
	return false
end

function TreasureHuntMgr:OnFixedFunctionPanelShowed(Params)
    if nil ~= Params and nil ~= Params.IsShow then
		if Params.IsShow == true then
			if UIViewMgr:IsViewVisible(UIViewID.TreasureHuntSkillPanel) == true then
				TreasureHuntSkillPanelVM:SetPanelClosedByOtherUI(true)
				TreasureHuntSkillPanelVM:CloseSkillPanel()
			end
		elseif nil ~= TreasureHuntSkillPanelVM and TreasureHuntSkillPanelVM:IsPanelClosedByOtherUI() == true then
			TreasureHuntSkillPanelVM:SetPanelClosedByOtherUI(false)
			TreasureHuntSkillPanelVM:ShowSkillPanel(TreasureHuntSkillPanelVM:GetCurMapData())
		end
    end
end

function TreasureHuntMgr:OnGameEventTeamCaptainChanged()
    -- 队员(包括新队长)关闭宝图，原队长不关闭，因为宝图是他自己的
	if TeamMgr:IsInTeam() then
		if TeamMgr:IsCaptain() then
			if self.IsTeamTreasureHunt then
				local function TreasureCB()
					self:OpenTreasureHuntMainPanel()
				end
				local MsgContent = LSTR(640013) --你已成为队长，确认继续寻宝吗？
				MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), MsgContent, TreasureCB, nil, LSTR(10003), LSTR(10002))
			end
		end

		local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
		if CurMapData == nil then return end 
		local MajorRoleID = MajorUtil.GetMajorRoleID()
		if CurMapData.RoleID ~= MajorRoleID then
			TreasureHuntSkillPanelVM:CloseSkillPanel()
            self:RemoveTeamMapMine()
			
			-- 删除队员标记
			self:DestoryMarkedObject()
		end

		-- 队长变更后队伍所有成员更新一下数据
		self:TreasureHuntInfoReq()
	end
	self.IsTeamTreasureHunt = false
end

function TreasureHuntMgr:OnGameEventTeamLeave()
	self.IsTeamTreasureHunt = false
	-- 删除队伍宝箱标记
	self:RemoveTeamMapMine()
	-- 删除队员标记
	self:DestoryMarkedObject()
end

function TreasureHuntMgr:OnGameEventTeamUpdateMember(Params)
	self.IsTeamTreasureHunt = false
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	local MemberRoleIDList = TeamMgr:GetMemberRoleIDList()
	for _, RoleID in pairs(MemberRoleIDList) do
		if MajorRoleID == RoleID then
			return
		end 
	end

	-- 处理离开队伍的玩家
	local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
	if CurMapData and CurMapData.RoleID ~= MajorRoleID then 
		TreasureHuntSkillPanelVM:CloseSkillPanel()	
        self:RemoveTeamMapMine()
	end		
	-- 删除队员标记
	self:DestoryMarkedObject()
end

-- 创建宝箱后地面播放特效
function TreasureHuntMgr:OnVisionUserDataUpdate(MsgBody)
	if (MsgBody == nil or MsgBody.UserDataChg == nil) then
        return
    end

	local EntityID = MsgBody.UserDataChg.EntityID
	local AttributeComp = ActorUtil.GetActorAttributeComponent(EntityID)
	local ObjType = AttributeComp and AttributeComp.ObjType or nil

	--_G.UE.EActorType.EObj = 9 _G.UE.EActorType.Treasure = 8
	if ObjType == UE.EActorType.EObj then
		local BoxUserData = ActorUtil.GetUserData(EntityID, UserDataID.TreasureHuntBox)
		if BoxUserData and BoxUserData.RoleID > 0 then
			-- 播放煙雾特效
			local BoxActor = ActorUtil.GetActorByEntityID(EntityID)
			if BoxActor then
				local EffectPos = BoxActor:FGetActorLocation()
				self:PlaySmokeEffect(EntityID, EffectPos) 
			end

			local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_Que_Start/Play_Zingle_Que_Start.Play_Zingle_Que_Start'"
			AudioUtil.LoadAndPlayUISound(SoundPath)
		end

		-- 播放锁链特效
		self:CheckBoxLockEffect(EntityID)
	end
end

function TreasureHuntMgr:OnGameEventVisionEnter(Params)
	if nil == Params then return end

	local EntityID = Params.ULongParam1
    local ObjType = Params.IntParam1
    local ResID = Params.IntParam2

	if ObjType == UE.EActorType.EObj then
		self:CheckBoxLockEffect(EntityID)
	end
	
	-- GetUserData性能消耗比较大，因为该功能还没完善，暂时屏蔽
	--[[local EntityID = Params.ULongParam1
	local UserData = ActorUtil.GetUserData(EntityID, UserDataID.TreasureHunt)
	if UserData ~= nil and UserData.BoxID ~= nil then
		if UserData.BoxID  > 0 then
			local MajorRoleID = MajorUtil.GetMajorRoleID()
			if UserData.RoleID == MajorRoleID then 
				local strContent = ""
				if UserData.Param == 0 then 
					strContent = LSTR(640016)  --普通怪物
				elseif UserData.Param == 1 then 
					strContent = LSTR(640017) --拟态怪
				elseif UserData.Param == 2 then 
					strContent = LSTR(640018)	--曼德拉战队
				end		
				--MsgTipsUtil.ShowTips(strContent)
				--暂时先不处理： 镜头锁定到怪物出现位置
				--self:FocusMonsterCamera(EntityID)
			end
		end
    end]]
end

function TreasureHuntMgr:FocusMonsterCamera(MonsterID)
	local Monster = ActorUtil.GetActorByEntityID(MonsterID)
	local Major = MajorUtil.GetMajor()
    if Major == nil or Monster == nil then return  end

	--隐藏UI
	if UIViewMgr:IsViewVisible(UIViewID.MainPanel) then
		_G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
		UIViewMgr:HideView(UIViewID.SkillButton)
	end

	local Origin = UE.FVector(0, 0, 0)
	local BoxExtent = UE.FVector(0, 0, 0)
	Monster:GetActorBounds(true, Origin, BoxExtent, true)
	local MaxExtent = math.max(math.max(BoxExtent.X, BoxExtent.Y), BoxExtent.Z)
	local ViewDistance = (MaxExtent + 1) * 1000

	local MonsterLocation = Monster:FGetActorLocation()
	local MajorLocation =  Major:FGetActorLocation()
	MajorLocation.Y = (MajorLocation.Y + 1) * 500
	local Major2Monster = MonsterLocation - MajorLocation
	local Rotation = Major2Monster:ToRotator()

	local DialogCamera = _G.CommonUtil.SpawnActor(_G.UE.ATargetCamera, _G.UE.FVector(0, 0, 0), _G.UE.FRotator(0, 0, 0))
	DialogCamera:SetViewDistance(ViewDistance, false)
	DialogCamera:SetTargetLocation(MonsterLocation, false)
	DialogCamera:Rotate(Rotation, false)
	DialogCamera:SwitchCollision(false)
	_G.UE.UCameraMgr.Get():SwitchCamera(DialogCamera, 0) 

	-- 播放特效
	self:PlayEffect(MonsterID,MonsterLocation)

	-- 几秒恢复镜头
	self:RegisterTimer(function()
		self:ResumeCamera(DialogCamera)
		-- 显示UI
		BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
		UIViewMgr:ShowView(UIViewID.SkillButton)

		CommonUtil.DestroyActor(DialogCamera)
     end, 2.0, 0, 1)
end

function TreasureHuntMgr:PlayEffect(EntityID,EffectPos)
	self:RemoveEffect(self.SkillEffectIDMap, EntityID)
	local EffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Fate/VBP/BP_Fate_boos_Die_1.BP_Fate_boos_Die_1_C'"

	local VfxParameter = _G.UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = EffectPath
	VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_TreasureHuntSkill
	VfxParameter.VfxRequireData.VfxTransform = _G.UE.FTransform(_G.UE.FQuat(), EffectPos, _G.UE.FVector(1, 1, 1))
	
	local Monster = ActorUtil.GetActorByEntityID(EntityID)
	local AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
    VfxParameter:SetCaster(Monster, 0, AttachPointType_Body, 0)
	local TargetEffectID = EffectUtil.PlayVfx(VfxParameter)
    self.SkillEffectIDMap[EntityID] = TargetEffectID
end

function TreasureHuntMgr:ResumeCamera(DialogCamera)
	local CameraMgr = _G.UE.UCameraMgr.Get()
    if CameraMgr ~= nil then
        CameraMgr:ResumeCamera(0, true, DialogCamera)
    end

	local Major = MajorUtil.GetMajor()
	if (Major ~= nil) then
		Major:GetCameraControllComponent():ResetSpringArmToDefault()
	end
end

function TreasureHuntMgr:OnGameEventVisionLeave(Params)
	if nil == Params then return end
	local EntityID = Params.ULongParam1

	self:RemoveEffect(self.BoxLockEffectIDMap, EntityID)
	self:RemoveEffect(self.BoxUnlockEffectIDMap, EntityID)
end

function TreasureHuntMgr:OnGameEventTrivialSkillStart(Params)
	if nil == Params then return end 
	if Params.IntParam2 == 0 then return end

    local SkillID = Params.IntParam2
    local EntityID = Params.ULongParam1
    local TargetEntityId = Params.ULongParam2

    --只检测主角释放技能
	local MajorEntityID = MajorUtil.GetMajorEntityID()
    if MajorEntityID ~= EntityID then
        return
    end

    --技能判断(只检查攻击和治疗技能)
    local SkillCfg = SkillMainCfg:FindCfgByKey(SkillID)
    --是否治疗技能
    local IsHealSkill = false
    if (SkillCfg.Class & ProtoRes.skill_class.SKILL_CLASS_HEAL) ~= 0 then
        IsHealSkill = true
    end
    --是否攻击技能
    local IsAtkSkill = false
    if (SkillCfg.Class & ProtoRes.skill_class.SKILL_CLASS_ATK) ~= 0 then
        IsAtkSkill = true
    end
    if not (IsHealSkill or IsAtkSkill) then
        return
    end

    --使用鼠标选中的目标(TargetEntityId=0，比如学者的治疗技能 / TargetEntityId=主角,比如白魔的治疗技能)
    if TargetEntityId == 0 or TargetEntityId == MajorEntityID then
        local SelectedTarget = _G.SelectTargetMgr:GetCurrSelectedTarget()
        if nil ~= SelectedTarget then
            TargetEntityId = SelectedTarget:GetAttributeComponent().EntityID
        end
    end 

	local MajorRoleID =  MajorUtil.GetMajorRoleID()
	local UserData = ActorUtil.GetUserData(TargetEntityId, UserDataID.TreasureHunt)
	if (UserData == nil or UserData.RoleID <= 0) then
        return
    end

	if TeamMgr:IsInTeam() then 
		local RoleIDList = TeamMgr:GetMemberRoleIDList()
		for _, RoleID in pairs(RoleIDList) do
			if UserData.RoleID == RoleID then 
				return 
			end
		end 
	else 
		if UserData.RoleID == MajorRoleID then 
			return
		end
	end

	local TipsContent = string.format(LSTR(640015)) --正在攻击其他玩家的任务怪，击杀后无法获得奖励
	MsgTipsUtil.ShowErrorTips(TipsContent)
end

-- 进入副本,关闭宝图界面
function TreasureHuntMgr:OnPWorldReady(Params)
	if self:IsInDungeon(false) then 
		TreasureHuntSkillPanelVM:CloseSkillPanel()	
	end
end

function TreasureHuntMgr:OnGameEventMajorSingBarOver(EntityID, IsBreak, SingStateID)
	if EntityID == MajorUtil.GetMajorEntityID() then
		if SingStateID == 58 and IsBreak then
			local NewTutorialMgr = _G.NewTutorialMgr
			if NewTutorialMgr.TutorialState and NewTutorialMgr:GetRunningSubGroup() then
				NewTutorialMgr:OnForceFinishTutorial()
			end
		end
	end
end

--- 动起来时中止动作
function TreasureHuntMgr:OnGameEventActorVelocityUpdate(Params)
	local EntityID = Params and Params.ULongParam1
	if EntityID == nil then return end

	if not self:GetEntityIsDigging(EntityID) then return end

	local IsNowVelocityZero = Params and Params.BoolParam1
	if IsNowVelocityZero == nil then return end

	if not IsNowVelocityZero then
		self:ExitDiggingState(EntityID, true)
	end
end

--- 中断播放动作
function TreasureHuntMgr:OnGameEventBreakAnim(Params)
	local EntityID
	if Params and Params.ULongParam1 then
		EntityID = Params.ULongParam1
	else
		EntityID = MajorUtil.GetMajorEntityID()
	end

	if not self:GetEntityIsDigging(EntityID) then return end

	self:ExitDiggingState(EntityID, true)
end

-- 标记物成特效，哎~~
function TreasureHuntMgr:CreateMarkedObject(Location)
	self:DestoryMarkedObject()

	local ActorResPath = "Blueprint'/Game/Assets/Effect/Particles/Sence/Common/SignMarker/BP_SignMarker.BP_SignMarker_C'"
	local ModelClass = _G.ObjectMgr:LoadClassSync(ActorResPath)
	if ModelClass ~= nil then 	
		local Translation = _G.UE.FVector(Location.X, Location.Y, Location.Z)
		self.MarkerEffect = _G.CommonUtil.SpawnActor(ModelClass, Translation)
		if self.MarkerEffect ~= nil then
			self.MarkerEffect:SetInitFlag()
			local FXPath =  "ParticleSystem'/Game/Assets/Effect/Particles/Sence/Common/PS_fld_mark_a0f_1.PS_fld_mark_a0f_1'"
			self.MarkerEffect:SetEffect(FXPath)
		end
	end
end

function TreasureHuntMgr:DestoryMarkedObject()
	if self.MarkerEffect ~= nil then
		_G.CommonUtil.DestroyActor(self.MarkerEffect)
		self.MarkerEffect = nil
	end
end

-- 玩家在副本内，无法打开宝图的并
function TreasureHuntMgr:IsInDungeon(bShowTip)
	if bShowTip == nil then 
		bShowTip = true
	end
	local IsInDungeon = PWorldMgr:CurrIsInDungeon()
    if IsInDungeon then
		if bShowTip then
			local strContent = LSTR(640014) --副本中不能使用藏宝图
			MsgTipsUtil.ShowTips(strContent)
		end
		return true
	end 
	return false
end

function TreasureHuntMgr:ShowSettlementPanel(MapData)
	if not PWorldMgr:CurrIsInField() then return end
	if MapData == nil then return end

	local IsMultipleMap = MapData.Number > 1
	local HaveUnDecodeMap = TreasureHuntMainVM:HaveUnDecodeMapByID(MapData.ID)

	local function OpenMainPanel()
		self:OpenTreasureHuntMainPanel({ UndecodeMapID = MapData.UnReadID })
	end

	if TeamMgr:IsCaptain() and IsMultipleMap then
		local function OpenTransferPanel()
			UIViewMgr:ShowView(UIViewID.TreasureHuntTransferPanel)
		end
		if HaveUnDecodeMap then
			local UnDecodeItemName = ItemUtil.GetItemName(MapData.UnReadID)
			local MsgContent = string.format(LSTR(640010), UnDecodeItemName) --你还有藏宝图，确认继续寻宝吗？
			MsgBoxUtil.ShowMsgBoxThreeOp(self, LSTR(10004), MsgContent, OpenMainPanel, OpenTransferPanel, nil, LSTR(10003), LSTR(640012), LSTR(10002))  -- 提 示，转让队长
		else
			local MsgContent = LSTR(640011) --你没有藏宝图了，是否转让队长？
			MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), MsgContent, OpenTransferPanel, nil, LSTR(10003), LSTR(10002))
		end
	else
		if HaveUnDecodeMap then 
			local UnDecodeItemName = ItemUtil.GetItemName(MapData.UnReadID)
			local MsgContent = string.format(LSTR(640010), UnDecodeItemName) --你还有藏宝图，确认继续寻宝吗？
			MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), MsgContent, OpenMainPanel, nil, LSTR(10003), LSTR(10002))
		end
	end
end

function TreasureHuntMgr:ClearSettleTimer()
	if self.SettleTimerID then
		self:UnRegisterTimer(self.SettleTimerID)
		self.SettleTimerID = nil
		self.IsTeamTreasureHunt = false
	end
end

function TreasureHuntMgr:RemoveTeamMapMine()
	if self:GetTreasureHuntTeamDataCount() > 0 then
		EventMgr:SendEvent(EventID.TreasureHuntRemoveMapMine, self.TreasureHuntTeamData)
		self.TreasureHuntTeamData = {}
	end
end

-- 辅助测试脚本,快速移动到挖宝点
function TreasureHuntMgr:TreasureHuntMove()
	local GMMgr = require("Game/GM/GMMgr")
	local CurMapData = TreasureHuntSkillPanelVM:GetCurMapData()
	if CurMapData == nil or CurMapData.Pos == nil then return end 
	local cmd = "cell move pos "..tostring(CurMapData.Pos.X).." "..tostring(CurMapData.Pos.Y).." "..tostring(CurMapData.Pos.Z)
	GMMgr:ReqGM(cmd)
end

function TreasureHuntMgr:IsBoxBelongMajorOrTeam(EntityID)
	if EntityID == nil then return false end

	local BoxUserData = ActorUtil.GetUserData(EntityID, UserDataID.TreasureHuntBox)
	if BoxUserData and BoxUserData.RoleID > 0 then
		local IsBoxBelongMajorOrTeam = false
		
		if BoxUserData.RoleID == MajorUtil.GetMajorRoleID() then
			IsBoxBelongMajorOrTeam = true
		else
			if TeamMgr:IsTeamMemberByRoleID(BoxUserData.RoleID) then
				IsBoxBelongMajorOrTeam = true
			end
		end

		return IsBoxBelongMajorOrTeam
	end

	return false
end

function TreasureHuntMgr:CheckBoxLockEffect(EntityID)
	if EntityID == nil then return end
	local ResID = ActorUtil.GetActorResID(EntityID)
	if ResID == nil then return end

	local HideEffectResIDList = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_TREASURE_BOX_NO_UNLOCK, "Value") or {}
	for _, ID in ipairs(HideEffectResIDList) do
		if ID ~= 0 and ResID == ID then return end
	end
	
	local BoxUserData = ActorUtil.GetUserData(EntityID, UserDataID.TreasureHuntBox)
	if BoxUserData and BoxUserData.RoleID > 0 then
		local Actor = ActorUtil.GetActorByEntityID(EntityID) 
		if Actor == nil then
			_G.FLOG_ERROR("[TreasureHuntMgr][CheckBoxLockEffect]Box actor nil")
			return
		end

		if BoxUserData.Status == TreasureHuntBoxStatus.EStatusClose then
			self:PlayBoxLockEffect(EntityID, Actor)
		elseif BoxUserData.Status == TreasureHuntBoxStatus.EStatusCanOpen then
			self:PlayBoxUnlockEffect(EntityID, Actor)
		end
	end
end

function TreasureHuntMgr:PlayBoxUnlockEffect(EntityID, Actor)
	if EntityID == nil or  self.BoxUnlockEffectIDMap[EntityID] ~= nil or Actor == nil then return end

	self:RemoveEffect(self.BoxLockEffectIDMap, EntityID)
	self:RemoveEffect(self.BoxUnlockEffectIDMap, EntityID)
    local VfxParameter = UE.FVfxParameter()
    VfxParameter.VfxRequireData.EffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/XBWF/VBP/BP_bxfyzt_fm002.BP_bxfyzt_fm002_C'"
    VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
    VfxParameter.PlaySourceType= UE.EVFXPlaySourceType.PlaySourceType_TreasureHuntSkill
    VfxParameter:SetCaster(Actor, 0, UE.EVFXAttachPointType.AttachPointType_Max, 0)
    local VfxID = EffectUtil.PlayVfx(VfxParameter, VfxFadeInTime)
    self.BoxUnlockEffectIDMap[EntityID] = VfxID
	if VfxID then
		local ResID = ActorUtil.GetActorResID(EntityID)
		_G.FLOG_INFO("[TreasureHuntMgr][PlayBoxUnlockEffect]EntityID:" .. EntityID .. " ResID:" .. ResID)
	end
end

function TreasureHuntMgr:RemoveEffect(EffectMap, EntityID)
	if EffectMap == nil or EntityID == nil then return end

	local EffectID = EffectMap[EntityID]
    if EffectID then
        EffectUtil.StopVfx(EffectID,0,0)
        EffectMap[EntityID] = nil
    end
end

function TreasureHuntMgr:PlayBoxLockEffect(EntityID, Actor)
	if EntityID == nil or self.BoxLockEffectIDMap[EntityID] ~= nil or Actor == nil then return end

	self:RemoveEffect(self.BoxLockEffectIDMap, EntityID)
	self:RemoveEffect(self.BoxUnlockEffectIDMap, EntityID)
    local VfxParameter = UE.FVfxParameter()
    VfxParameter.VfxRequireData.EffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Monster/XBWF/VBP/BP_bxfyzt_fm001.BP_bxfyzt_fm001_C'"
    VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
    VfxParameter.PlaySourceType= UE.EVFXPlaySourceType.PlaySourceType_TreasureHuntSkill
    VfxParameter:SetCaster(Actor, 0, UE.EVFXAttachPointType.AttachPointType_Max, 0)
    local VfxID = EffectUtil.PlayVfx(VfxParameter, VfxFadeInTime)
    self.BoxLockEffectIDMap[EntityID] = VfxID
	if VfxID then
		local ResID = ActorUtil.GetActorResID(EntityID)
		_G.FLOG_INFO("[TreasureHuntMgr][PlayBoxLockEffect]EntityID:" .. EntityID .. " ResID:" .. ResID)
	end
end

function TreasureHuntMgr:HandleTeleportTutorial()
	local function OnTelportInvite(Params)
        --发送新手引导触发传送魔纹开启消息
        local EventParams = EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.TreasureNBSP	--新手引导触发类型
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end

    local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTelportInvite, Params = {}}
    _G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
end

--- 用于宝箱交互打开后隐藏交互选项
---@param EntityID uint64 宝箱EntityID
---@return boolean 是否已打开
function TreasureHuntMgr:IsTreasureHuntBoxOpened(EntityID)
	local BoxUserData = ActorUtil.GetUserData(EntityID, UserDataID.TreasureHuntBox)
	if BoxUserData and BoxUserData.RoleID > 0 then
		if BoxUserData.Status == TreasureHuntBoxStatus.EStatusClose or BoxUserData.Status == TreasureHuntBoxStatus.EStatusCanOpen then
			return false
		end
	else
		if BoxUserData and BoxUserData.Status == TreasureHuntBoxStatus.EStatusOpened then
			return true
		end
	end

	return false
end

function TreasureHuntMgr:EnterDiggingState(EntityID)
	self:SetEntityIsDigging(EntityID, true)
	local DigActor =  ActorUtil.GetActorByEntityID(EntityID)
	local CharacterMovement = DigActor and DigActor.CharacterMovement
	if CharacterMovement then
		local Vec = CharacterMovement.Velocity
		if Vec then
			local INF = 0.000000001
			if Vec:Size() >= INF then
				self:ExitDiggingState(EntityID, true)
				return
			end
		end
	end

	if MajorUtil.GetMajorEntityID() == EntityID then
		-- 向服务器请求打断其他读条
		InteractiveMgr:SendInteractiveBreakReq()
	end

	self:ShowDigWeapon(EntityID)

    -- 进入挖掘状态后，播放动画，特效，声音
	local AnimPath = "AnimSequence'/Game/Assets/Character/Human/Animation/c0101/a0001/lv_p_min/A_c0101a0001_lv_p_min-cblm_abl_pm_c_Montage.A_c0101a0001_lv_p_min-cblm_abl_pm_c_Montage'"
	self:PlayDiggingAnim(EntityID, AnimPath)  
end

--- 退出挖掘状态
---@param IsBreak boolean 是否被中断，被中断会有事件刷新UI，不是中断则视为正常完成挖掘退出状态
function TreasureHuntMgr:ExitDiggingState(EntityID, IsBreak)
	if EntityID == nil then return end

	local OldDigState = self:GetEntityIsDigging(EntityID)
	if not OldDigState then return end	--原本不在挖掘状态则不处理

	local NewDigState = false
	self:SetEntityIsDigging(EntityID, false)
	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp then 
		AnimComp:StopAnimation()
	end
	self:HideDigWeapon(EntityID)
	self:ClearSmokeTimer()

	if IsBreak then
		if OldDigState ~= NewDigState then
			EventMgr:SendEvent(EventID.TreasureHuntShowSkillBtn)
		end
	end
end

function TreasureHuntMgr:ShowDigWeapon(EntityID)
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor == nil then return end

	local WeaponModel = "7001,1,2,0"
	local AvatarComp = Actor:GetAvatarComponent()
	if AvatarComp then 
		AvatarComp:SetAvatarHiddenInGame(UE.EAvatarPartType.WEAPON_MASTER_HAND, true, false, false)
		local ModelParams = string.split(WeaponModel, ",")
		if #ModelParams >= 3 then
			local ModelPath = string.format("w%04d", tonumber(ModelParams[1]))
			local SubModelPath = string.format("b%04d", tonumber(ModelParams[2]))
			local ImagechangeID = tonumber(ModelParams[3])
			AvatarComp:ChangeAvatarWeapon(ModelPath, SubModelPath, ImagechangeID, 0, UE.EAvatarPartType.WEAPON_SYSTEM, 0) 
		end
	end
end

function TreasureHuntMgr:HideDigWeapon(EntityID)
	if EntityID == nil then return end
	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor == nil then return end

	local AvatarComp = Actor:GetAvatarComponent()
	if AvatarComp then 
		AvatarComp:SetAvatarHiddenInGame(UE.EAvatarPartType.WEAPON_MASTER_HAND, false, false, false)
		AvatarComp:TakeOffAvatarPart(UE.EAvatarPartType.WEAPON_SYSTEM, false)
	end
end

function TreasureHuntMgr:PlayDiggingAnim(EntityID, AnimPath)
	local MapDataAtStart = TreasureHuntSkillPanelVM:GetCurMapData()
	if MapDataAtStart == nil then return end

	local function DelayPlayEffect()
		local Actor = ActorUtil.GetActorByEntityID(EntityID) 
		if Actor == nil then return end
	
		local ActorPos = Actor:FGetActorLocation()
		local ActorForward = Actor:FGetActorRotation():GetForwardVector()
		local EffectPos = ActorPos + (ActorForward * 100)
		self:PlaySmokeEffect(EntityID, EffectPos) 
		local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/Characters/Common/Earth_Evnoy/Play_SE_VFX_Live_Mining_Pecker_success_P.Play_SE_VFX_Live_Mining_Pecker_success_P'"
		AudioUtil.LoadAndPlaySoundEvent(EntityID, SoundPath)  --播放声音
    end

	self:ClearSmokeTimer()
	local DelayTime = 0.8
	self.Smoke1TimerID = self:RegisterTimer(function()
		DelayPlayEffect()
		self.Smoke1TimerID = nil
	end, DelayTime)
    -- 播放第一次动画
	self:PlayActionTimeLine(EntityID, AnimPath, function()
		-- 第一次动画播放完如果没有中断挖掘则播放第二次动画
		if self:GetEntityIsDigging(EntityID) then
			self.Smoke2TimerID = self:RegisterTimer(function()
				DelayPlayEffect()
				self.Smoke2TimerID = nil
			end, DelayTime)
			self:PlayActionTimeLine(EntityID, AnimPath, function()
				-- 第二次动画播放完如果没有被中断则请求挖宝和还原状态
				if self:GetEntityIsDigging(EntityID) then
					self:ExitDiggingState(EntityID)
					if MajorUtil.IsMajor(EntityID) then 
						local MapDataAtEnd = TreasureHuntSkillPanelVM:GetCurMapData()
						if MapDataAtStart.ID == MapDataAtEnd.ID then
							self:DigTreasureReq(MapDataAtEnd.ID)
						end
					end
				end
			end)
			AnimationUtil.PlayAutoShake(EntityID, 1)
		end
	end)
	AnimationUtil.PlayAutoShake(EntityID, 1)
end

function TreasureHuntMgr:PlaySmokeEffect(EntityID,EffectPos)
	self:RemoveEffect(self.SmokeEffectIDMap, EntityID)
	local EffectPath = "VfxBlueprint'/Game/Assets/Effect/Particles/Sence/XB/VBP/BP_Xunbao_3_Smoke.BP_Xunbao_3_Smoke_C'"

	local VfxParameter = UE.FVfxParameter()
	VfxParameter.VfxRequireData.EffectPath = EffectPath
	VfxParameter.PlaySourceType=UE.EVFXPlaySourceType.PlaySourceType_TreasureHuntSkill
	VfxParameter.VfxRequireData.VfxTransform = UE.FTransform(UE.FQuat(), EffectPos, UE.FVector(1, 1, 1))
	local TargetEffectID = EffectUtil.PlayVfx(VfxParameter)
    self.SmokeEffectIDMap[EntityID] = TargetEffectID
end

function TreasureHuntMgr:ClearSmokeTimer()
	if self.Smoke1TimerID then
		self:UnRegisterTimer(self.Smoke1TimerID)
		self.Smoke1TimerID = nil
	end
	if self.Smoke2TimerID then
		self:UnRegisterTimer(self.Smoke2TimerID)
		self.Smoke2TimerID = nil
	end
end

function TreasureHuntMgr:PlayActionTimeLine(EntityID, AnimPath, CallBack)
	if string.isnilorempty(AnimPath) then return end

	local AnimComp = ActorUtil.GetActorAnimationComponent(EntityID)
	if AnimComp then 
		AnimComp:PlayAnimationCallBack(AnimPath, CommonUtil.GetDelegatePair(CallBack, true))
	end
end

function TreasureHuntMgr:CheckCanDigTreasure(IsNeedTips)
	local CanDig = true
	local TipsContent = nil
	local TipsID = nil

	local MajorRoleID = MajorUtil.GetMajorRoleID()
	if self:GetRoleIsDigging(MajorRoleID) then
		TipsContent = LSTR(640064) -- 已在挖掘中
		CanDig = false
	end

	local Major = MajorUtil.GetMajor()
	if Major then
		-- 移动状态下，无法挖掘
		local CharacterMovement = Major.CharacterMovement
		if CharacterMovement then
			local MajorVec = CharacterMovement.Velocity
			if MajorVec then
				local INF = 0.000000001
				local IsMoving = MajorVec:Size() >= INF
				if IsMoving then
					TipsContent = LSTR(640063)
					CanDig = false
				end
			end
		end

		if Major:IsInFly() then
			TipsContent = LSTR(640022) --飞行状态下，无法挖掘
			CanDig = false 
		end

		local StateCom = MajorUtil.GetMajorStateComponent()
		if StateCom ~= nil then
			if StateCom:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_DEAD) then
				TipsContent = LSTR(640023) --死亡状态下，无法挖掘
				CanDig = false 
			end
			if StateCom:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) then
				TipsID = 109702 --战斗状态下，无法挖掘
				CanDig = false 
			end
		end

		local SkillObject = SkillObjectMgr:GetOrCreateEntityData(MajorUtil.GetMajorEntityID()).CurrentSkillObject
		if SkillObject then
			TipsID = 109216 -- 技能中无法挖掘
			CanDig = false
		end
	else
		CanDig = false
	end

	if IsNeedTips then
		if TipsContent then
			MsgTipsUtil.ShowTips(TipsContent)
		elseif TipsID then
			MsgTipsUtil.ShowTipsByID(TipsID)
		end
	end

	return CanDig
end

function TreasureHuntMgr:SetEntityIsDigging(EntityID, IsDigging)
	if EntityID == nil or IsDigging == nil then return end

	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	if RoleID == nil then return end
	self:SetRoleIsDigging(RoleID, IsDigging)
end

--- 实体是否在挖掘中
---@param EntityID uint64 实体ID
---@return boolean 是否在挖掘中
function TreasureHuntMgr:GetEntityIsDigging(EntityID)
	if EntityID == nil then return end

	local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
	if RoleID == nil then return end
	return self:GetRoleIsDigging(RoleID)
end

function TreasureHuntMgr:SetRoleIsDigging(RoleID, IsDigging)
	if RoleID == nil or IsDigging == nil then return end
	if self.DiggingMap then
		self.DiggingMap[RoleID] = IsDigging
	end
end

--- 角色是否在挖掘中
---@param RoleID uint64 角色ID
---@return boolean 是否在挖掘中
function TreasureHuntMgr:GetRoleIsDigging(RoleID)
	if RoleID == nil then return end
	if self.DiggingMap then
		return self.DiggingMap[RoleID]
	end
end
return TreasureHuntMgr
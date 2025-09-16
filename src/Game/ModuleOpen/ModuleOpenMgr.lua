
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsID = require("Define/MsgTipsID")
local ModuleOpenCfg = require("TableCfg/ModuleOpenCfg")
local DirectUpgradeGlobalCfg = require("TableCfg/DirectUpgradeGlobalCfg")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local GameNetworkMgr
local EventMgr
local UIViewMgr
local ClientSetupMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.ModuleOpenCmd
local ProfSubMsg = ProtoCS.ProfSubMsg
local DelayTime = 0.6
local Interval = 3.5
local LoopNumber = 0

--- 部队解锁等级限制
local ArmyUnlockLevelLimit = 15

---@class ModuleOpenMgr : MgrBase
local ModuleOpenMgr = LuaClass(MgrBase)

local ViewIDList = {
	[1] = UIViewID.InfoTipsSystemUnlockTips,				--- 系统解锁
	[2] = UIViewID.InfoContentUnlockTips,					--- 重要内容开放
	[3] = UIViewID.InfoContentUnlockTips,					--- 内容开放
}

--- 二级界面Item用  查询红点ID By ModuleID
local RedDotList = {
	[ProtoCommon.ModuleID.ModuleIDArmy] 		  	= 47,		--- 部队
	[ProtoCommon.ModuleID.ModuleIDEntertain] 	  	= 34,		--- 玩法
	[ProtoCommon.ModuleID.ModuleIDShadow] 		  	= 36,		--- 衣橱
	[ProtoCommon.ModuleID.ModuleIDGatherNote] 	  	= 31,		--- 采集笔记
	[ProtoCommon.ModuleID.ModuleIDMakerNote] 	  	= 32,		--- 制作笔记
	[ProtoCommon.ModuleID.ModuleIDFisherNote] 	  	= 30,		--- 钓鱼笔记
	[ProtoCommon.ModuleID.ModuleIDMount] 		  	= 35,		--- 坐骑
	[ProtoCommon.ModuleID.ModuleIDNewbie] 		  	= 43,		--- 新手指南
	[ProtoCommon.ModuleID.ModuleIDBuddy] 		  	= 40,		--- 搭档
	[ProtoCommon.ModuleID.ModuleIDCompanion] 	  	= 44,		--- 宠物
	[ProtoCommon.ModuleID.ModuleIDLeveQuest] 	  	= 39,		--- 理符
	[ProtoCommon.ModuleID.ModuleIDPerform] 		  	= 38,		--- 乐器演奏
	[ProtoCommon.ModuleID.ModuleIDCollection] 	  	= 42,		--- 收藏品交易
	[ProtoCommon.ModuleID.ModuleIDGoldSauserMain] 	= 37,		--- 金蝶
	[ProtoCommon.ModuleID.ModuleIDTreasureHunt]   	= 41,		--- 寻宝
	[ProtoCommon.ModuleID.ModuleIDLegendaryWeapon]  = 1000,		--- 传奇武器
}

---OnInit
function ModuleOpenMgr:OnInit()
    self.OpenedList = {}                            -- 已解锁的ModuleID
    self.IsNeedLock = true                         	---------------暂时逻辑代码---------------
    self.IsWaiting = true                           -- 是否正在排队播放解锁动效
   	self.ExpressionQueue = {}                 		-- 所有表现归为一个数组
    self.IsNeedHideMiniMap = false                  -- 是否需要隐藏小地图（系统解锁触发的打开小地图才需要隐藏）
    -- self.IsNeedTutorial = false                  -- 当前播放队列中是否存在需要触发新手引导的模块
    self.ModuleTable = {}
	self.TutorialDlist = {}
	self.IsOnDirectUpState = false	--- 直升状态下不播表现
	self.DUSkipModuleOpenIDList = DirectUpgradeGlobalCfg:FindCfgByKey(ProtoRes.DIRECT_UPGRADE_ID.DIRECT_UPGRADE_ID_MODULEOPEN).SkipIDList
	self.AllCfg = self:OnInitLocalAllCfg()
	for _, value in pairs(self.AllCfg) do
		local TempCfgItemData = value
		if TempCfgItemData ~= nil then
			if TempCfgItemData.ModuleEntranceID and TempCfgItemData.ModuleEntranceID > 0 then
				self.ModuleTable[TempCfgItemData.ModuleEntranceID] = self:CheckIDType(TempCfgItemData.ID)
			end
		else
			-- FLOG_WARNING("ModuleOpenMgr:OnInit  TempCfgItemData == nil")
		end
	end
	self.NeesShowRedDotList = {}
	self.RedDotList = RedDotList	
end

function ModuleOpenMgr:OnInitLocalAllCfg()
	local AllCfg = {}
	local TempAllCfg = ModuleOpenCfg:FindAllCfg()

	if TempAllCfg == nil then
		return
	end
	for _, value in pairs(TempAllCfg) do
		AllCfg[value.ID] = value
	end

	return AllCfg
end

---OnBegin
function ModuleOpenMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	UIViewMgr = _G.UIViewMgr
    ClientSetupMgr = _G.ClientSetupMgr
end

function ModuleOpenMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MODULE_OPEN, 0, self.OnQueryRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MODULE_OPEN, ProtoCS.ModuleOpenCmd.ModuleOpenCmdNotify, self.OnNotifyRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PROF, ProfSubMsg.ProfSubMsgLevelUp, self.OnNetMsgLevelUp)
end

function ModuleOpenMgr:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.RoleLoginRes, self.ModuleOpenReq)
    self:RegisterGameEvent(EventID.ModuleOpenNewBieGuideEvent, self.OnPlayNewbieGuide)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
	self:RegisterGameEvent(EventID.FateQuit, self.OnGameEventFateQuit)
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
end

function ModuleOpenMgr:ModuleOpenReq()

	local MsgID = CS_CMD.CS_CMD_MODULE_OPEN
    local MsgBody = { 
        Cmd = SUB_MSG_ID.ModuleOpenCmdQuery
    }
	GameNetworkMgr:SendMsg(MsgID, 0, MsgBody)

end

-- 获取系统解锁状态
function ModuleOpenMgr:OnQueryRsp(MsgBody)
    local Msg = MsgBody.Query
    if nil == Msg then
        return
    end
	local OpenedList = Msg.OpenedList
	if nil == OpenedList then
        return
    end
	self:UpdateOpenedList(OpenedList)
end

function ModuleOpenMgr:UpdateOpenedList(OpenedList)
    self.OpenedList = {}
    for i = 1, #OpenedList do
        local ID = self:CheckIDType(OpenedList[i])
        if ID ~= nil then
            if ID ~= ProtoCommon.ModuleID.ModuleIDArmy then
                table.insert(self.OpenedList, ID)
            end
        end
    end
	local RoleID = MajorUtil:GetMajorRoleID()
	local NewBieGuideValue = ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.CSNewBieGuideKey)
	if NewBieGuideValue ~= nil then
		table.insert(self.OpenedList, ProtoCommon.ModuleID.ModuleIDNewbie)
	end
	--- 有达到15级的职业解锁部队
	if self:CheckArmyConds() then
		local ArmtModuleCfg = ModuleOpenCfg:FindAllCfg(string.format("ModuleID=%d", ProtoCommon.ModuleID.ModuleIDArmy))
		if ArmtModuleCfg ~= nil then
			self:OnCheckModuleState(ArmtModuleCfg[1].ID)
		end
	end

    EventMgr:SendEvent(EventID.ModuleOpenUpdated)
end

--- 登陆包里的协议推送比ClientSetupMgr更新数据早,有可能查不到,所以放到创角之后再查一遍
function ModuleOpenMgr:OnGameEventMajorCreate()
	if self:CheckOpenState(ProtoCommon.ModuleID.ModuleIDNewbie) then
		return
	end
	local RoleID = MajorUtil:GetMajorRoleID()
	local NewBieGuideValue = ClientSetupMgr:GetSetupValue(RoleID, ClientSetupID.CSNewBieGuideKey)
	if NewBieGuideValue ~= nil then
		table.insert(self.OpenedList, ProtoCommon.ModuleID.ModuleIDNewbie)
	end
end

-- 系统解锁推送
function ModuleOpenMgr:OnNotifyRsp(MsgBody)
    local Msg = MsgBody.Notify
    if nil == Msg then
        return
    end
    if not self.IsNeedLock then
        return
    end
    self:OnGetModuleDetails(Msg.ID)
end

--加个中间层便于QueueMgr处理
function ModuleOpenMgr:OnGetModuleDetails(ID)
	if self:OnCheckModuleState(ID) then         -- 重复ID剔除
		-- FLOG_ERROR("ModuleOpenMgr:OnGetModuleDetails  ID %d  is repeated   ", ID)
        return
    end

	--- 收到协议直接打开入口，表现排队去播
    local UnlockCfg = self.AllCfg[ID]
	if UnlockCfg ~= nil then
		_G.EventMgr:SendEvent(_G.EventID.ModuleOpenNotify, self:GetModuleIDByType(UnlockCfg))
		--- 二级界面Item解锁需要添加红点
		if UnlockCfg.ModuleEntranceID and UnlockCfg.ModuleEntranceID > 0 then
			local ModuleID = self:CheckIDType(UnlockCfg.ID)
            if ModuleID ~= nil then
                local RedDotID = self.RedDotList[ModuleID]
                _G.RedDotMgr:AddRedDotByID(RedDotID)
                self.NeesShowRedDotList[ModuleID] = RedDotID
            end
		end
	end

    -- 解锁提示放入队列
    local function ShowTipsCallback(Params)
        self:InsertExpressionQueueByID(Params.ID)
    end

    --新手引导系统解锁处理
    local function OnTutorial(Params)
        --发送新手引导触发获得物品触发消息
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.Type = TutorialDefine.TutorialConditionType.SystemUnlock --新手引导触发类型
        EventParams.Param1 = Params.ID
        _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    end
	if not self:GetIsOnDirectUpState() or not self:OnCheckIsDirectUpSkipByID(ID) then
		if UnlockCfg ~= nil and UnlockCfg.TipsQueDelayTime ~= nil then
			self:RegisterTimer(function()
				local Config = {Type = ProtoRes.tip_class_type.TIP_SYS_UNLOCK, Callback = ShowTipsCallback, Params = {ID = ID}}
				_G.TipsQueueMgr:AddPendingShowTips(Config)
			end, UnlockCfg.TipsQueDelayTime, 0, 1)
		end
		local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {ID = ID}}
		_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)

		table.insert(self.TutorialDlist, ID)
	end
end

-- 通过ID将表现放进队列
function ModuleOpenMgr:InsertExpressionQueueByID(ID)
	FLOG_INFO(" ServerNotify ModuleOpenMgr:OnGetModuleDetails  ID == %d", ID)
    local UnlockCfg = self.AllCfg[ID]
    if nil == UnlockCfg then
        return
    end
	if ID == ProtoCommon.ModuleID.ModuleIDChallengeNote or ID == ProtoCommon.ModuleID.ModuleIDDailyRand then
		table.insert(self.OpenedList, ProtoCommon.ModuleID.ModuleIDAdventure)
    end
    local ItemData = {}
    ItemData.Type = UnlockCfg.Type
    ItemData.ID = self:GetModuleIDByType(UnlockCfg)
    ItemData.PreTask = UnlockCfg.PreTask                         -- 前置任务
    ItemData.Icon = UnlockCfg.Icon                               -- 图标Icon路径
    ItemData.SysNotice = UnlockCfg.SysNotice                     -- 解锁提示
    ItemData.SubSysNotice = UnlockCfg.SubSysNotice       	  	 -- 解锁副标题
    ItemData.ModuleEntranceID = UnlockCfg.ModuleEntranceID       -- 系统名(二级界面Item)
	local ExpressionType = UnlockCfg.ExpressionType
	if ExpressionType == ProtoRes.ExpressionType.EXPRESSION_TYPE_NONEEXPRESSION then
		_G.EventMgr:SendEvent(_G.EventID.ModuleOpenNotify, ItemData.ID)
		if ItemData.ID == ProtoCommon.ModuleID.ModuleIDNewbie then
			--- 新手指南播放之后记录在后台
			ClientSetupMgr:SendSetReq(ClientSetupID.CSNewBieGuideKey, tostring(1))
		end
		return
	end
	if ExpressionType == nil or ExpressionType == 0 then
		-- FLOG_ERROR("ModuleOpenMgr:OnGetModuleDetails UnlockCfg.ExpressionType  is nil or 0")
		return
	end
    ItemData.ExpressionType = ExpressionType                     		     -- 蓝图名
	ItemData.ViewID = ViewIDList[ExpressionType] or 0
    ItemData.IsMove = UnlockCfg.IsMove               			 			-- 是否移动
	table.insert(self.ExpressionQueue, #self.ExpressionQueue + 1, ItemData)
    if self.IsWaiting and self.IsNeedLock then
        self.TimerID = self:RegisterTimer(self.PlayMotion, DelayTime, Interval, LoopNumber)
        self.IsWaiting = false
		FLOG_INFO("ModuleOpenMgr:OnGetModuleDetails   RegisterTimer")
    end

    EventMgr:SendEvent(EventID.ModuleOpenUpdated)
end

--- 检查配置获取系统ID
function ModuleOpenMgr:GetModuleIDByType(UnlockCfg)
	if UnlockCfg.Type == ProtoCommon.ModuleType.ModuleTypeProf then
		return UnlockCfg.ProfID                                      -- 职业ID
	elseif UnlockCfg.Type == ProtoCommon.ModuleType.ModuleTypeSystem then
		return UnlockCfg.ModuleID                                    -- 系统ID
	elseif UnlockCfg.Type == ProtoCommon.ModuleType.ModuleTypeScene then
		return UnlockCfg.SceneID                                    -- 副本ID
	end
end
--- 跳过当前表现
function ModuleOpenMgr:SkipCurrentExp()
	if self.TimerID then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = nil
	end
	if #self.ExpressionQueue > 0 then
        self.TimerID = self:RegisterTimer(self.PlayMotion, DelayTime, Interval, LoopNumber)
        self.IsWaiting = false
	end
	_G.ModuleOpenMgr:OnAllMotionOver()
end

function ModuleOpenMgr:HaveExpressionQueue()
	return #self.ExpressionQueue ~= 0
end

--- 判断当前是否还有提示播放
function ModuleOpenMgr:IsPlayingMotion()
	return self.IsNeedLock and (#self.ExpressionQueue ~= 0 or
		UIViewMgr:IsViewVisible(UIViewID.SystemUnlockSkillPanel) or
		UIViewMgr:IsViewVisible(UIViewID.InfoTipsSystemUnlockTips) or
		UIViewMgr:IsViewVisible(UIViewID.InfoContentUnlockTips))
end

function ModuleOpenMgr:ForceClearMotion()
	if self.ExpressionQueue then
		table.clear(self.ExpressionQueue)
	end
	if UIViewMgr:IsViewVisible(UIViewID.SystemUnlockSkillPanel) then
		UIViewMgr:HideView(UIViewID.SystemUnlockSkillPanel)
	end
	if UIViewMgr:IsViewVisible(UIViewID.InfoTipsSystemUnlockTips) then
		UIViewMgr:HideView(UIViewID.InfoTipsSystemUnlockTips)
	end
	if UIViewMgr:IsViewVisible(UIViewID.InfoContentUnlockTips) then
		UIViewMgr:HideView(UIViewID.InfoContentUnlockTips)
	end
end

function ModuleOpenMgr:PlayMotion()
    if not self.IsNeedLock or #self.ExpressionQueue == 0  then
        return
    end
    local Params = nil
	if #self.ExpressionQueue ~= 0 then
		table.sort(self.ExpressionQueue, function(a, b)
			if a.ExpressionType ~= b.ExpressionType then
				return a.ExpressionType < b.ExpressionType
			else
				if a.IconSkill and b.IconSkill then
					return a.IconSkill < b.IconSkill
				end
				return a.ID < b.ID
			end
		end)
		Params = self.ExpressionQueue[1]
		table.remove(self.ExpressionQueue, 1)
	end
	if Params == nil then
		return
	end
	--- 传奇武器解锁需要校验版本号
	if Params.ID == ProtoCommon.ModuleID.ModuleIDLegendaryWeapon then
		if not _G.LegendaryWeaponMgr.ChapterVersion[1] then
			return
		end
	end
	-- 技能解锁需要播放动效
	if Params.ExpressionType == ProtoRes.ExpressionType.EXPRESSION_TYPE_SKILL then
		_G.EventMgr:SendEvent(EventID.ModuleOpenSkillUnLockEvent, {SkillID = Params.SkillID, ProfID = Params.ProfID})
	end
    if Params ~= nil and Params.ViewID ~= nil then
        if Params.Type == ProtoCommon.ModuleType.ModuleTypeSystem or Params.Icon ~= "" then
            if not MainPanelVM:GetMiniMapPanelVisible() then
                MainPanelVM:SetMiniMapPanelVisible(true)
                self.IsNeedHideMiniMap = true
            end
        end
        if UIViewMgr:IsViewVisible(Params.ViewID) then
            UIViewMgr:HideView(Params.ViewID)
        end
        UIViewMgr:ShowView(Params.ViewID, Params)
		FLOG_INFO(" ModuleOpenMgr:PlayMotion ShowView  ViewID == %d ", Params.ViewID)
    end
    if #self.ExpressionQueue == 0 then
        self.IsWaiting = true
        self:UnRegisterTimer(self.TimerID)
		FLOG_INFO(" ModuleOpenMgr:PlayMotion All MotionLists Is empty  UnRegisterTimer")
    end

end

--- 隐藏因为解锁系统所显示的红点		二级界面里系统打开时调用
function ModuleOpenMgr:HideRedDotByModuleID(ModuleID)
	local RedDotID = self.RedDotList[ModuleID]
	if RedDotID == nil or self.NeesShowRedDotList[ModuleID] == nil then
		return
	end
	_G.RedDotMgr:DelRedDotByID(RedDotID)
	self.NeesShowRedDotList[ModuleID] = nil
end

--- 二级界面用  判断是否有需要显示的红点
function ModuleOpenMgr:CheckRedDotIsNeedShow(RedDotID)
	return self.NeesShowRedDotList[RedDotID] ~= nil
end

-- 当前所有表现播放完
function ModuleOpenMgr:OnAllMotionOver()
	if not self.IsWaiting then
		return
	end
    self:RegisterTimer(function()
        if self.IsNeedHideMiniMap then
            MainPanelVM:SetMiniMapPanelVisible(false)
            self.IsNeedHideMiniMap = false
        end

		--新手引导系统解锁处理
		local function OnTutorial(Params)
			--发送新手引导触发获得物品触发消息
			local EventParams = _G.EventMgr:GetEventParams()
			EventParams.Type = TutorialDefine.TutorialConditionType.EndPlayUnlockAnimation 	--新手引导触发类型
			EventParams.Param1 = Params.ID
			_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
		end
		
		for i = 1, #self.TutorialDlist do
			local TutorialConfig = {Type = ProtoRes.tip_class_type.TIP_SYS_GUIDE, Callback = OnTutorial, Params = {ID = self.TutorialDlist[i]}}
			_G.TipsQueueMgr:AddPendingShowTips(TutorialConfig)
		end
		self.TutorialDlist = {}
        -- self.IsNeedTutorial = false
        -- EventMgr:SendEvent(_G.EventID.ModuleOpenAllMotionOverEvent, self.OpenedList)
    end, 0.5)
end

--加个中间层便于QueueMgr处理
function ModuleOpenMgr:OnSkillUnlock(IconSkill, SkillName, IconJob, SkillID, ProfID)
    -- 解锁提示放入队列
    local function ShowTipsCallback(Params)
        self:InsertSkillUnlock(Params.IconSkill, Params.SkillName, Params.IconJob, Params.SkillID, Params.ProfID)
    end
    local Config = {}
	Config.Callback = ShowTipsCallback
	Config.Type = ProtoRes.tip_class_type.TIP_SKILL_UNLOCK
	Config.Params = {IconSkill = IconSkill, SkillName = SkillName, IconJob = IconJob, SkillID = SkillID, ProfID = ProfID}
    _G.TipsQueueMgr:AddPendingShowTips(Config)
end

---OnSkillUnlock                            @技能解锁
---@param IconSkill     string              @技能图标路径
---@param SkillName     string              @技能名称
---@param IconJob       string              @技能图标路径
function ModuleOpenMgr:InsertSkillUnlock(IconSkill, SkillName, IconJob, SkillID, ProfID)
    if not self.IsNeedLock then
        return
    end
    local ItemData = {}
    ItemData.IconSkill = IconSkill
    ItemData.SkillName = SkillName
    ItemData.IconJob = IconJob
	ItemData.ProfID = ProfID
	ItemData.SkillID = SkillID
    ItemData.ExpressionType = ProtoRes.ExpressionType.EXPRESSION_TYPE_SKILL
    ItemData.ViewID = UIViewID.SystemUnlockSkillPanel
    table.insert(self.ExpressionQueue, #self.ExpressionQueue + 1, ItemData)
    if self.IsWaiting and self.IsNeedLock then
        self.TimerID = self:RegisterTimer(self.PlayMotion, DelayTime, Interval, LoopNumber)
        self.IsWaiting = false
    end
end

---GetModuleOpenList
---@return table            @Mgr存储的已解锁的模块ID
function ModuleOpenMgr:GetModuleOpenList()
    return self.OpenedList
end

---CheckOpenState 外部用解锁状态校验接口
---@param   ID      ProtoCommon.ModuleID    @模块ID
---@return  boolean                         @解锁状态
function ModuleOpenMgr:CheckOpenState(ID)
    if nil == ID or not self.IsNeedLock then return true end
    for i = 1, #self.OpenedList do
        if self.OpenedList[i] == ID then
            return true
        end
    end
    return false
end

---CheckOpenStateByName
---@param   Name    string                  @模块名称
---@return  ID      ProtoCommon.ModuleID    @模块ID
function ModuleOpenMgr:CheckOpenStateByName(Name)
	return self.ModuleTable[Name]
end

--- 校验模块解锁接口,一般作为点击时重复校验使用,如未开启会弹Tips,如果仅需要返回bool状态,建议使用 ModuleOpenMgr:CheckOpenState
---@param ID    ProtoCommon.ModuleID        @模块ID
function ModuleOpenMgr:ModuleState(ID)
    if ID == nil then
        return true
    end
    if type(ID) == "string" then ID = self:CheckOpenStateByName(ID) end
    local StateBool = self:CheckOpenState(ID)
    if StateBool then
        return true
    else
		local TempTipsID =  MsgTipsID.ModuleOpenTipsID
		local TempCfg = self:GetCfgByModuleID(ID)
		if TempCfg ~= nil and TempCfg.UnLockTipsID > 0 then
			TempTipsID = TempCfg.UnLockTipsID
		end
		FLOG_INFO("ModuleOpenMgr:ModuleState  TempTipsID == " .. TempTipsID)
        _G.MsgTipsUtil.ShowTipsByID(TempTipsID)
    end
end

--- 通过系统ID找Cfg
function ModuleOpenMgr:GetCfgByModuleID(ModuleID)
	local AllCfg = self.AllCfg
	if AllCfg == nil then
		return nil
	end
	local TempCfg = nil
	for key, value in pairs(AllCfg) do
		local TempModuleID = self:CheckIDType(key)
		if TempModuleID == ModuleID then
			TempCfg = value
			break
		end
	end
	return TempCfg
end

function ModuleOpenMgr:OnEnd()
end

function ModuleOpenMgr:OnShutdown()
end

--- 外部禁用！！!  
--- 外部禁用！！！  
--- 外部禁用！！！  
--- 系统解锁内部使用！！！外部校验状态请使用  
---   ModuleOpenMgr:CheckOpenState
function ModuleOpenMgr:OnCheckModuleState(ModuleID)
    local ID = self:CheckIDType(ModuleID)
    if ID == nil then
        return false
    end
    for i = 1, #self.OpenedList do
        if ID == self.OpenedList[i] then
            return true
        end
    end
    table.insert(self.OpenedList, ID)
    return false
end

---@param ModuleID    ProtoCommon.ModuleID        @模块ID
function ModuleOpenMgr:CheckIDType(ModuleID)
	if table.is_nil_empty(self.AllCfg) then
		self.AllCfg = self:OnInitLocalAllCfg()
	end
    local UnlockCfg = self.AllCfg[ModuleID]
	if UnlockCfg == nil then
		return
    end
    if UnlockCfg.Type == ProtoCommon.ModuleType.ModuleTypeProf then
        return UnlockCfg.ProfID
    elseif UnlockCfg.Type == ProtoCommon.ModuleType.ModuleTypeSystem then
        return UnlockCfg.ModuleID
    elseif UnlockCfg.Type == ProtoCommon.ModuleType.ModuleTypeScene then
        return UnlockCfg.SceneID
    end
    return nil
end

function ModuleOpenMgr:OnGmSwitchBtnClick()          -- self.IsNeedLock 为false时不会触发解锁对应逻辑
    if self.IsNeedLock then
        self.IsNeedLock = false
    end
end

function ModuleOpenMgr:OnModuleStateChange()
    if not self.IsNeedLock then                     -- 系统解锁GM按钮为一次性逻辑，单账号只做一次处理
        return
    end
    _G.GMMgr:ReqGM("role moduleopen unlock")
    self:ModuleOpenReq()
    self:OnGmSwitchBtnClick()
    EventMgr:SendEvent(EventID.ModuleOpenGMBtnEvent)
	ClientSetupMgr:SendSetReq(ClientSetupID.CSNewBieGuideKey, tostring(1))
end

--- 播放新手指南
---@param ModuleID number 固定为系统解锁表新手指南ID
---@param IsPlayMotion boolean 是否播放动效
function ModuleOpenMgr:OnPlayNewbieGuide(ModuleID, IsPlayMotion)
    if IsPlayMotion then
        self:OnGetModuleDetails(ModuleID)
    end
end

--- 监修用，GM解锁副本
function ModuleOpenMgr:OnOpenPWorld()
	_G.GMMgr:ReqGM("role quest acceptf 140313")
	self.PWorldTimerID = self:RegisterTimer(function()
		_G.GMMgr:ReqGM("role quest do")
	end, 5, 1, 1)
end

--- 部队解锁特殊处理
function ModuleOpenMgr:CheckArmyConds()
	local RoleDetail = ActorMgr:GetMajorRoleDetail()
	if RoleDetail == nil then
		-- FLOG_WARNING('ModuleOpenMgr:CheckArmyConds GetMajorRoleDetail Error ')
		return false
	end
	if RoleDetail.Prof == nil or RoleDetail.Prof.ProfList == nil then
		-- FLOG_WARNING('ModuleOpenMgr:CheckArmyConds RoleDetail.Prof == nil or RoleDetail.Prof.ProfList == nil')
		return false
	end

	local ProfList = RoleDetail.Prof.ProfList
	for _, value in pairs(ProfList) do
		if value.Level >= ArmyUnlockLevelLimit then
			return true
		end
	end
	return false
end

--- 加入部队
function ModuleOpenMgr:OnJoinArmy()
	local ArmyIsOpen = self:CheckArmyConds()
	if not ArmyIsOpen then
		table.insert(self.OpenedList, ProtoCommon.ModuleID.ModuleIDArmy)
	end
	_G.EventMgr:SendEvent(EventID.ModuleOpenNotify, ProtoCommon.ModuleID.ModuleIDArmy)
end

--- 退出部队时移除已解锁数据
function ModuleOpenMgr:OnExitArmy()
	if self:CheckArmyConds() then return end
	for i = 1, #self.OpenedList do
		if self.OpenedList[i] == ProtoCommon.ModuleID.ModuleIDArmy then
			--- 移除部队，先替换最后一个数据，然后移除最后的数据，避免下标为空或数据位移
			self.OpenedList[i] = self.OpenedList[#self.OpenedList]
			self.OpenedList[#self.OpenedList] = nil
			_G.EventMgr:SendEvent(EventID.ModuleOpenNotify, ProtoCommon.ModuleID.ModuleIDArmy)
			return
		end
	end
end

function ModuleOpenMgr:OnNetMsgLevelUp(MsgBody)
	if MsgBody == nil then
		return
	end
	local ArmyIsOpened = self:CheckArmyConds()
	local ArmtModuleCfg = ModuleOpenCfg:FindAllCfg(string.format("ModuleID=%d", ProtoCommon.ModuleID.ModuleIDArmy))
	if ArmtModuleCfg == nil or ArmtModuleCfg[1] == nil then
		-- FLOG_WARNING("ModuleOpenMgr ArmtModuleCfg is nil")
		return
	end
	if not ArmyIsOpened and MsgBody.LevelUp.NewLevel >= ArmyUnlockLevelLimit then
		local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
		local IsJoinFate = _G.FateMgr:IsJoinFate()
		if IsInDungeon or IsJoinFate then
			_G.ClientSetupMgr:SendSetReq(ClientSetupID.ModuleOpenArmState, "1")
		else
			_G.EventMgr:SendEvent(_G.EventID.ModuleOpenNotify, ProtoCommon.ModuleID.ModuleIDArmy)
			self:OnGetModuleDetails(ArmtModuleCfg[1].ID)
		end
	end
end

--- 检查是否需要播放部队解锁表现
--- 升至15级时如果在副本里需要暂时记录在后台，从副本出来后再播放
function ModuleOpenMgr:OnCheckIsNeedPlayArmMotion()
	local RecordInt = _G.ClientSetupMgr:GetSetupValue(MajorUtil:GetMajorRoleID(), ClientSetupID.ModuleOpenArmState)
	if RecordInt == "1" then
		local ArmtModuleCfg = ModuleOpenCfg:FindAllCfg(string.format("ModuleID=%d", ProtoCommon.ModuleID.ModuleIDArmy))
		if ArmtModuleCfg == nil or ArmtModuleCfg[1] == nil then
			-- FLOG_WARNING("ModuleOpenMgr ArmtModuleCfg is nil")
			return
		end
		self.PlayArmTimerID =  self:RegisterTimer(function(view, ID) 
			if not UIViewMgr:IsViewVisible(UIViewID.LoadingMainCity) then
				self:RegisterTimer(function(view, ID)
					_G.EventMgr:SendEvent(_G.EventID.ModuleOpenNotify, ProtoCommon.ModuleID.ModuleIDArmy)
					self:OnGetModuleDetails(ID)
				end, 2, 0, 1, ArmtModuleCfg[1].ID)
				self:UnRegisterTimer(self.PlayArmTimerID)
			end
		end, 1, 1, 0, ArmtModuleCfg[1].ID)
		_G.ClientSetupMgr:SendSetReq(ClientSetupID.ModuleOpenArmState, "0")
	end
end

function ModuleOpenMgr:OnGameEventPWorldExit()
	self:OnCheckIsNeedPlayArmMotion()
end

function ModuleOpenMgr:OnGameEventFateQuit()
	self:OnCheckIsNeedPlayArmMotion()
end

function ModuleOpenMgr:OnGameEventPWorldMapEnter(Params)
	if Params.bReconnect then
		local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
		local IsJoinFate = _G.FateMgr:IsJoinFate()
		if IsInDungeon or IsJoinFate then
			return
		end
		self:OnCheckIsNeedPlayArmMotion()
	end
end

function ModuleOpenMgr:SetMainPanelFadeInOrOut(IsIn, DelayTime)
	if DelayTime and DelayTime > 0 then
		self:RegisterTimer(function() EventMgr:SendEvent(EventID.ModuleOpenMainPanelFadeAnim, IsIn) end, DelayTime)
	else
		EventMgr:SendEvent(EventID.ModuleOpenMainPanelFadeAnim, IsIn)
	end
end

function ModuleOpenMgr:CheckIsInSwitchByModuleID(ModuleID)
	return RedDotList[ModuleID] ~= nil
end

function ModuleOpenMgr:SetIsOnDirectUpState(NewState)
	self.IsOnDirectUpState = NewState
end

function ModuleOpenMgr:GetIsOnDirectUpState()
	return self.IsOnDirectUpState
end

--- 检查ID是否是直升需要跳过的
function ModuleOpenMgr:OnCheckIsDirectUpSkipByID(ID)
	for i = 1, #self.DUSkipModuleOpenIDList do
		if ID == self.DUSkipModuleOpenIDList[i] then
			return true
		end
	end
	return false
end

--要返回当前类
return ModuleOpenMgr
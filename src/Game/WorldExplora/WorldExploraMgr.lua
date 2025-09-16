local LuaClass = require("Core/LuaClass")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")

local SaveKey = require("Define/SaveKey")

local MgrBase = require("Common/MgrBase")
local ModuleOpenMgr = require("Game/ModuleOpen/ModuleOpenMgr")
local FateMgr = require("Game/Fate/FateMgr")
local CounterMgr = require("Game/Counter/CounterMgr")
local CrystalPortalMgr = require("Game/PWorld/CrystalPortal/CrystalPortalMgr")

local ProfUtil = require("Game/Profession/ProfUtil")
local MajorUtil = require("Utils/MajorUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local UIUtil = require("Utils/UIUtil")

local LevelExpCfg = require("TableCfg/LevelExpCfg")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local WilderExploreMainCfg = require("TableCfg/WilderExploreMainCfg")
local WEFateRecMapCfg = require("TableCfg/WEFateRecMapCfg")
local WEFishRecMapCfg = require("TableCfg/WEFishRecMapCfg")
local MapCfg = require("TableCfg/MapCfg")
local WEGatherRecMapCfg = require("TableCfg/WEGatherRecMapCfg")
local WELoggingRecMapCfg = require("TableCfg/WELoggingRecMapCfg")

local WorldExploraVM = require("Game/WorldExplora/WorldExploraVM")
local WorldExploraDefine = require("Game/WorldExplora/WorldExploraDefine")

local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local TipsUtil = require("Utils/TipsUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local ItemUtil = require("Utils/ItemUtil")

local FVector2D = _G.UE.FVector2D
local UUIUtil = _G.UE.UUIUtil

local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local EventMgr = _G.EventMgr
local EventID = _G.EventID

local ModuleID = ProtoCommon.ModuleID
local ProfType = ProtoCommon.prof_type
local Wilder_Explore_GameType = ProtoRes.Wilder_Explore_GameType
local Wilder_Explore_FUNC = ProtoRes.Wilder_Explore_FUNC
local MaxRecommandMapCount = 4

---@class WorldExploraMgr : MgrBase
local WorldExploraMgr = LuaClass(MgrBase)


function WorldExploraMgr:OnInit()
    self.UnlockTable = {
        [ModuleID.ModuleIDTreasureHunt] = {IsUnlock = false , bPlayUnLockAnim = false},        -- 寻宝是否解锁
        [ModuleID.ModuleIDAetherCurrent] = {IsUnlock = false , bPlayUnLockAnim = false},       -- 风脉泉是否解锁
        [ModuleID.ModuleIDSightseeingLog] = {IsUnlock = false , bPlayUnLockAnim = false},      -- 探索笔记是否解锁
        -- TODO 友好部族
        -- TODO 怪物狩猎
    }
    self.ActivityCfgs = nil
    self.ExploraCfgs = nil

end

function WorldExploraMgr:OnBegin()
end

function WorldExploraMgr:OnEnd()
    self.ActivityCfgs = nil
    self.ExploraCfgs = nil
end

function WorldExploraMgr:OnShutdown()

end

function WorldExploraMgr:OnRegisterNetMsg()

end

function WorldExploraMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ModuleOpenUpdated, self.OnModuleOpenUpdated) -- 系统解锁全部数据
    self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify)   -- 当某个系统解锁
    self:RegisterGameEvent(EventID.FateArchiveDataUpdate, self.OnFateArchiveDataUpdate)
end

--============================================================= Common ===========================================================================
--- @type 当拿到系统模块解锁数据
function WorldExploraMgr:OnModuleOpenUpdated()
    local UnlockTable = self.UnlockTable
    for ModuleID, UnlockTable in pairs(UnlockTable) do
        UnlockTable.IsUnlock = ModuleOpenMgr:CheckOpenState(ModuleID)
    end

    -- 只需要存一次数据，剩下的ModuleOpenNotify处理
    self:UnRegisterGameEvent(EventID.ModuleOpenUpdated, self.OnModuleOpenUpdated)
end

--- @type 当某个系统解锁
function WorldExploraMgr:OnModuleOpenNotify(ModuleID)
    if self.UnlockTable[ModuleID] ~= nil and not self.UnlockTable[ModuleID].IsUnlock then
        self.UnlockTable[ModuleID].bPlayUnLockAnim = true  -- 需要播放第一次解锁动效
        local SaveValue = TableToString(self.UnlockTable)
        _G.UE.USaveMgr.SetString(SaveKey.WeChatLaunchPrivilege, SaveValue, false)
    end 
end

-- function WorldExploraMgr:Test()
--     local function StringToTable(str)
--         if not str or type(str) ~= "string" then
--             return
--         end
    
--         local flag, result = xpcall(load("return " .. str), _G.CommonUtil.XPCallLog)
--         if flag then
--             return result
--         else
--             return
--         end
--     end

--     local SaveValue = TableToString(self.UnlockTable)
--     _G.UE.USaveMgr.SetString(SaveKey.WeChatLaunchPrivilege, SaveValue, false)

--     local GetString = _G.UE.USaveMgr.GetString(SaveKey.WeChatLaunchPrivilege, SaveValue, false)

--     FLOG_INFO(GetString)
--     local Table = StringToTable(GetString)
--     return Table
-- end

--- @type 需要的服务器数据
function WorldExploraMgr:ReqAllData()
    -- 请求fate图鉴地图记录_用于打开Fata页面
    FateMgr:ShowFateArchive(nil, nil, false, true)
    return false
end

--- @type 打开世界探索主界面
function WorldExploraMgr:OpenWorldExploreMain()
    self:ReqAllData()
    self:InitTreasureHuntVMData()                       -- 初始化寻宝VM信息
    self:InitMonsterVMData()                            -- 初始化怪物狩猎VM信息
    self:InitFriendlyTribeVMData()                      -- 初始化友好部族VM信息
    UIViewMgr:ShowView(UIViewID.WorldExploraMainPanel)
end

--- @type 主界面是否默认选择活动
function WorldExploraMgr:bSelectActivityModule()
    return self:FriendlyTribeIsUnLocked() or self:TreasureHuntIsUnLocked() or self:MonsterIsUnLocked()
end

--- @type 检测某个职业等级是否已满
function WorldExploraMgr:ProfIsMaxLevel(ProfID)
    if not self:ProfIsUnlock(ProfID) then
        return false
    end
    local CurLevel = MajorUtil.GetMajorLevelByProf(ProfID)
    return CurLevel >= LevelExpCfg:GetMaxLevel()
end

--- @type 职业是否已经解锁
function WorldExploraMgr:ProfIsUnlock(InProfID)
    if InProfID == 0 then
        return false
    end
    local RoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    local ProfList = RoleDetail.Prof.ProfList
    for _, Elem in pairs(ProfList) do
        local ProfID = Elem.ProfID
        if ProfID == InProfID then
            return true
        end
    end
    return false
end

--- @type 当前职业是否为战斗职业
function WorldExploraMgr:IsCombatProf()
    local Prof = MajorUtil.GetMajorProfID()
    return ProfUtil.IsCombatProf(Prof)
end

--- @type 获取当前职业等级
function WorldExploraMgr:GetCurProfLevel()
    local Prof = MajorUtil.GetMajorProfID()
    return MajorUtil.GetMajorLevelByProf(Prof)
end

--- @type 获取最高战斗职业等级
function WorldExploraMgr:GetMaxCombatProfLevel()
    local MaxLevel = 0
    for _, ProfID in pairs(ProfType) do
        if ProfID ~= 0 and ProfUtil.IsCombatProf(ProfID) then
            local ProfLevel = MajorUtil.GetMajorLevelByProf(ProfID)
            ProfLevel = ProfLevel or 0
            if ProfLevel > MaxLevel then
                MaxLevel = ProfLevel
            end
        end
    end
    return MaxLevel
end

--- @type 打开新手指南
function WorldExploraMgr:OnShowPWorldGuideTip(GuideID)
    local Params = {}
	Params.ID = GuideID
	Params.PWorldTeaching = false
	UIViewMgr:ShowView(UIViewID.TutorialGuideShowPanel, Params)
end

--- @type 选出需要传送到的水晶
function WorldExploraMgr:GetOneCrystal(MapID)    
    local AllCrystalCfg = TeleportCrystalCfg:FindAllCfg(string.format("MapID == %d", MapID))
    if AllCrystalCfg == nil or #AllCrystalCfg <= 0 then
        return nil
    end

    for _, CrystalCfg in pairs(AllCrystalCfg) do
        --找到激活的水晶
        if (CrystalPortalMgr:IsExistActiveCrystal(CrystalCfg.ID)) then
            return CrystalCfg
        end
    end

    return AllCrystalCfg[1]
end

--- @type 点击前往某个地图
function WorldExploraMgr:GoMapClick(MapID)
    -- _G.WorldMapMgr:CancelMapFollow()
    local CrystalCfg = self:GetOneCrystal(MapID)
    if CrystalCfg then
        local Cfg = MapCfg:FindCfgByKey(MapID)
        if Cfg then         --传送至
            local NeedText = LSTR(1610017)..RichTextUtil.GetText((Cfg.DisplayName or ""), "#490f00")
            _G.EasyTraceMapMgr:ShowEasyTraceMap(MapID, NeedText, { CrystalID = CrystalCfg.CrystalID }, { CrystalID = CrystalCfg.CrystalID, bBanTrace = true })
        end
    else
        _G.FLOG_ERROR("WorldExploraMgr:GoMapClick MapID = %d 未找到水晶", MapID)
    end
end

--- @type 根据枚举类型获取配置
function WorldExploraMgr:FindCfgByGameType(GameType, TabType)
    local DefineTabType = WorldExploraDefine.TabType
	if self.ActivityCfgs == nil and TabType == DefineTabType.EActivity then
		self.ActivityCfgs = WilderExploreMainCfg:FindAllCfg(string.format("LinkTab == %d", TabType))
    elseif self.ExploraCfgs == nil and TabType == DefineTabType.EExplora then
		self.ExploraCfgs = WilderExploreMainCfg:FindAllCfg(string.format("LinkTab == %d", TabType))
    end
    local Cfgs = TabType == DefineTabType.EActivity and self.ActivityCfgs or self.ExploraCfgs

	if not Cfgs then
		return
	end

	for i = 1, #Cfgs do
		local Cfg = Cfgs[i]
		if Cfg.RelateGame == GameType then
			return Cfg
		end
	end
	return
end

--- @type 获取下拉栏信息
function WorldExploraMgr:GetAllDownTabData()
    local Cfgs = table.deepcopy(WilderExploreMainCfg:FindAllCfg(string.format("LinkTab == 2")))
    table.sort(Cfgs, function(l, r) return l.SortID < r.SortID end)
    local Data = {}
    for _, v in pairs(Cfgs) do
        local TmpData = {}
        local Cfg = v
        TmpData.IconPath = Cfg.ImgPath
        TmpData.Name = Cfg.FuncName
        TmpData.GameType = Cfg.RelateGame
        TmpData.bLock = false
        if Cfg.RelateGame == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_AETHER then
            TmpData.bLock = not self:CheckAetherIsUnlock()
        elseif Cfg.RelateGame == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_SIGHTSEE then
            TmpData.bLock = not self:CheckSightseeingLogIsUnlock()
        end
        TmpData.IsLastItem = false

        if (#Data == #Cfgs - 1) then
            TmpData.IsLastItem = true
        end

        table.insert(Data, TmpData)
    end
    return Data
end

--- @type 打开详情页面
function WorldExploraMgr:ShowExploraWin(GameType)
    local Cfg = self:FindCfgByGameType(GameType, WorldExploraDefine.TabType.EExplora)
    if Cfg == nil then
        return
    end
    local Params = {}
    Params.SelectIndex = Cfg.SortID - 3
    Params.ItemData = self:GetAllDownTabData()
    UIViewMgr:ShowView(UIViewID.WorldExploraWin, Params)
end

-- 处理富文本图片
function WorldExploraMgr:AddTextureToRichText(DescStr)
    local str = DescStr
    for Path in string.gmatch(str, '|(.-)|') do
        local Texture = RichTextUtil.GetTexture(Path, 40, 40, -8)
        str = string.gsub(str, '|.-|', Texture, 1)
    end
    return str
end

--- @type 更新VM通用
function WorldExploraMgr:UpdateVMByCfg(Cfg)
    WorldExploraVM.BGImgPath = Cfg.BGImgPath or ""

    WorldExploraVM.bGoPanelVisible = (Cfg.ProfID ~= 0 and not self:ProfIsUnlock(Cfg.ProfID))
    WorldExploraVM.GoReasonText = Cfg.ProfID ~= 0 and string.format(LSTR(1610010), ProfUtil.Prof2Name(Cfg.ProfID)) or ""  -- %s未解锁

    WorldExploraVM.bPanelBtnVisible = Cfg.bShowOpenTab
    WorldExploraVM.BookName = Cfg.OpenTabName or ""
    WorldExploraVM.GameName = Cfg.FuncName
    WorldExploraVM.Describe = self:AddTextureToRichText(Cfg.Description) --string.format("测试图片%s", Texture)   --
    WorldExploraVM.bPanelRewardVisible = #Cfg.Reward > 0 and Cfg.Reward[1].ID ~= 0  -- 配置了物品则奖励是物品
    WorldExploraVM.bPanelFunctionVisible = not WorldExploraVM.bPanelRewardVisible
    WorldExploraVM.FuncIconPath = Cfg.RewardFuncIcon or ""
    WorldExploraVM.FuncName = Cfg.RewardFuncName or ""
    WorldExploraVM.bProgressVisible = Cfg.FuncType == Wilder_Explore_FUNC.WILDER_EXPLORE_SHOWPROGRESS or Cfg.FuncType == Wilder_Explore_FUNC.WILDER_EXPLORE_RECOM_AND_PRO and
    not WorldExploraVM.bGoPanelVisible
    WorldExploraVM.NumText = Cfg.ProText ~= nil and Cfg.ProText[1] or ""
    WorldExploraVM.TipDesc = Cfg.ProText ~= nil and Cfg.ProText[2] or ""
    -- WorldExploraVM.CurNum = ""  -- 根据系统而论
    -- WorldExploraVM.CurProgress = 0 -- 根据系统而论
    WorldExploraVM.bRecomMapVisible = (Cfg.FuncType == Wilder_Explore_FUNC.WILDER_EXPLORE_RECOMMMAP or Cfg.FuncType == Wilder_Explore_FUNC.WILDER_EXPLORE_RECOM_AND_PRO) and
     not WorldExploraVM.bGoPanelVisible
    WorldExploraVM.RecommMapText = Cfg.RecomText
    WorldExploraVM.HasFinishTipText = Cfg.NoRecomText
    -- self.bFinishTipVisible = false --根据系统而论
    WorldExploraVM.bDownTextVisible = false
    WorldExploraVM.bTipDescVisible = true

    WorldExploraVM.RewardChangeCallBackNum = WorldExploraVM.RewardChangeCallBackNum + 1
end

--- @type 当详情页面选择改变
function WorldExploraMgr:OnGameTypeSelectChanged(GameType)
    local Cfg = self:FindCfgByGameType(GameType, WorldExploraDefine.TabType.EExplora)
    if Cfg == nil then
        return
    end
    self:UpdateVMByCfg(Cfg)        -- 根据Cfg刷新通用的VM属性 下方Update可做特殊处理

    if GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_AETHER then
		self:UpdateAetherWinVM()
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_TRANS then
        self:UpdateTourChocoboTransVM()
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_FATE then
        self:UpdateFateWinVM(Cfg)
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_SIGHTSEE then
        self:UpdateSightSeeingWinVM(Cfg)
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_MYSTERMECH then
        self:UpdateMysterMechWinVM(Cfg)
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_TOUR then
        self:UpdateTourWinVM()
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_FISHING then
        self:UpdateFishingWinVM(Cfg)
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_MIN then
        self:UpdateMiningWinVM(Cfg)
	elseif GameType == Wilder_Explore_GameType.WILDER_EXPLORE_GAMEPLAY_GATHER then
        self:UpdateMiningGatherVM(Cfg)
	end
end

-- 功能被锁，展示Tips
function WorldExploraMgr:ShowLockTips(GameType, TargetWidget, TabType, InAlignment)
	local CfgData = self:FindCfgByGameType(GameType, TabType)
    if CfgData == nil then
        return
    end
	local IsRecommendTask = false
	local TaskID = CfgData.TaskID
	local HelpInfoID = CfgData.LockHelpInfoID
	if CfgData then
		---目前只显示一个任务,默认显示配置第一个
		local QuestCfg = QuestHelper.GetQuestCfgItem(TaskID)
		if QuestCfg ~= nil then
			local RecommendTask =  _G.AdventureRecommendTaskMgr:GetRecommendTask()
			if RecommendTask then
				IsRecommendTask =  table.contain(RecommendTask, QuestCfg.ChapterID)
			end
		end
		if IsRecommendTask then
			HelpInfoID = CfgData.RecHelpInfoID
		end
	end
	local Offset = FVector2D( 0, 0)

    local Alignment = FVector2D(1, 0)
    if (InAlignment ~= nil) then
        Alignment = InAlignment
    end

	--- 显示未解锁提示文本tips
	local Params
	---美术同学要求无任务tips使用通用文本tips
	if TaskID ~= 0 then
		Params = {
			ID = HelpInfoID,
			-- LSTR string:解锁条件
			TitleText = LSTR(1210001),
			InTargetWidget = TargetWidget,	
			Offset = Offset,
			Alignment = Alignment,
			IsAutoFlip = true,
			TaskID = TaskID,
			IsShowTaskUI = true,
		}
		_G.UIViewMgr:ShowView(UIViewID.Main2ndHelpInfoTips, Params)
	else
		self:ShowInfoTips(TargetWidget, HelpInfoID)
	end
end

--- @type 展示无图标Tips
function WorldExploraMgr:ShowInfoTips(TargetWidget, HelpInfoID)
	---通用tips无反转逻辑，需要额外处理
	local Offset = FVector2D( 0, 0)
	local TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
	local IsFlip = not self:PosIsUpInViewport(TargetWidget)
	if TargetWidget then
		TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
		Offset = FVector2D( - TargetWidgetSize.X, 0)
	end
	local Alignment
	if IsFlip then
		Alignment = FVector2D(1, 1)
		Offset.Y = Offset.Y + TargetWidgetSize.Y
	else
		Alignment = FVector2D(1, 0)
		Offset.Y = Offset.Y  + 5
	end
	local HelpCfgs = HelpCfg:FindAllHelpIDCfg(HelpInfoID)
	local TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
	if TipsContent then
		TipsUtil.ShowInfoTitleTips(TipsContent, TargetWidget, Offset, Alignment, false)
	end
end

--- @type 展示无图标Tips
function WorldExploraMgr:ShowInfoTipByContent(TargetWidget, Title, Content)
	---通用tips无反转逻辑，需要额外处理
	local Offset = FVector2D( 0, 0)
	local TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
	local IsFlip = not self:PosIsUpInViewport(TargetWidget)
	if TargetWidget then
		TargetWidgetSize = UUIUtil.GetLocalSize(TargetWidget)
		Offset = FVector2D( - TargetWidgetSize.X, 0)
	end
	local Alignment
	if IsFlip then
		Alignment = FVector2D(1, 1)
		Offset.Y = Offset.Y + TargetWidgetSize.Y
	else
		Alignment = FVector2D(1, 0)
		Offset.Y = Offset.Y  + 5
	end
    local ContentData = {}
    local Data = {}
    Data.Title = Title
    Data.Content = {}
    table.insert(Data.Content, Content)
    table.insert(ContentData, Data)
	TipsUtil.ShowInfoTitleTips(ContentData, TargetWidget, Offset, Alignment, false)
end

--- 是否在上半屏幕
function WorldExploraMgr:PosIsUpInViewport(Widget)
	local TargetWidget = Widget
	local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(FVector2D(0, 0), false) or FVector2D(0, 0)
	local ViewportSize = UIUtil.GetViewportSize()
	local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(TargetWidget)
	if TragetAbsolute.Y - WindowAbsolute.Y  > ViewportSize.Y / 2 then
		return false
	else
		return true
	end
end

--============================================================= Common End ===========================================================================

--=============================================================活动页面===========================================================================
--------------------------------友好部族相关---------------------------------------
--- @type 友好部族是否解锁
function WorldExploraMgr:FriendlyTribeIsUnLocked()
    return true -- ModuleOpenMgr:CheckOpenState(ModuleID.XXX)
end

--- @type 获取推荐部族
function WorldExploraMgr:GetRecommendTribe()
    return ""
end

--- @type 友好部族获取总次数与剩余参与次数
function WorldExploraMgr:GetTribeRemainCountData()
    return string.format(LSTR(1610022), 1, 1)  -- 今日参与%d/%d
end

--- @type 获取推荐部族
function WorldExploraMgr:GetRecommendTribeRaceLevel()
    return ""
end

--- @type 友好部族获取总次数与剩余参与次数
function WorldExploraMgr:GetRecommendTribeIconPath()
    return ""
end

--- @type 初始化友好部族VM数据
function WorldExploraMgr:InitFriendlyTribeVMData()
    WorldExploraVM.bFTLockImgVisible = not self:FriendlyTribeIsUnLocked()
    WorldExploraVM.FTRemainCount = self:GetTribeRemainCountData()
    WorldExploraVM.RecommRace = "X"..self:GetRecommendTribe()
    WorldExploraVM.RaceLevel = self:GetRecommendTribeRaceLevel()
    WorldExploraVM.RaceIconPath = self:GetRecommendTribeIconPath()
end

--------------------------------友好部族End---------------------------------------

--------------------------------怪物狩猎相关---------------------------------------

--- @type 怪物狩猎是否解锁
function WorldExploraMgr:MonsterIsUnLocked()
    return false -- ModuleOpenMgr:CheckOpenState(ModuleID.XXX)
end

--- @type 怪物狩猎获取总次数与剩余参与次数
function WorldExploraMgr:GetMonsterCountData()
    return string.format(LSTR(1610023), 1, 1) -- 今日参与%d/%d
end

--- @type 初始化怪物狩猎VM数据
function WorldExploraMgr:InitMonsterVMData()
    WorldExploraVM.bMonsterLockVisible = not self:MonsterIsUnLocked()
    WorldExploraVM.MonsterRemainCount = self:GetMonsterCountData()
end
--------------------------------怪物狩猎End---------------------------------------

--------------------------------寻宝相关---------------------------------------

--- @type 寻宝是否解锁
function WorldExploraMgr:TreasureHuntIsUnLocked()
    return ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDTreasureHunt)
end

--- @type 获取背包中宝图总数
function WorldExploraMgr:GetTreasureItemNum()
    local AllTreasureMap = _G.BagMgr:FilterItemByCondition(
        function(Item) 
            return ItemUtil.CheckIsTreasureMapByResID(Item.ResID) 
        end
    )
    
    local AllNum = 0
    if (#AllTreasureMap > 0) then
        for _, Value in pairs(AllTreasureMap) do
            AllNum = AllNum + Value.Num
        end        
    end

    return AllNum
end

--- @type 获取今日获得宝图数量数据
function WorldExploraMgr:GetTreasureCountData()
    local CounterID = 22300
	local CurrentLimit = CounterMgr:GetCounterRestore(CounterID) or 0	-- 每天最大获取次数
	local CurrentNum = CounterMgr:GetCounterCurrValue(CounterID) or 0	-- 今日已获得次数
    return string.format(LSTR(1610004), CurrentNum, CurrentLimit)  -- 今日参与%d/%d
end

--- @type 初始化寻宝VM数据
function WorldExploraMgr:InitTreasureHuntVMData()
    WorldExploraVM.bTHLockImgVisible = not self:TreasureHuntIsUnLocked()
    WorldExploraVM.THRemainCount = self:GetTreasureCountData()
    WorldExploraVM.TreasureNum = "X"..self:GetTreasureItemNum()
end

--------------------------------寻宝相关End---------------------------------------
--=============================================================活动页面End===========================================================================


--=============================================================探索页面===========================================================================
--------------------------------风脉泉---------------------------------------
--- @type 风脉泉是否解锁
function WorldExploraMgr:CheckAetherIsUnlock()
    return ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDAetherCurrent)
end

--- @type 刷新风脉泉详情页面VM
function WorldExploraMgr:UpdateAetherWinVM()
    local Data = _G.AetherCurrentsMgr:RecommandMapArrayForWildExplore()
    local RecommPlaceList = {}
    for i = 1, #Data do
        table.insert(RecommPlaceList, {Data[i].MapID, Data[i].ActivedNum, Data[i].TotalNum})
    end
    if RecommPlaceList == nil then
        return
    end
    WorldExploraVM.bFinishTipVisible = #RecommPlaceList <= 0
    WorldExploraVM.bPlaceListVisible = #RecommPlaceList > 0
    if #RecommPlaceList > 0 then
        WorldExploraVM:UpdateList(WorldExploraVM.RecommPlaceList, RecommPlaceList)
    end
end

--------------------------------风脉泉End---------------------------------------

--------------------------------探索笔记---------------------------------------
--- @type 探索笔记是否解锁
function WorldExploraMgr:CheckSightseeingLogIsUnlock()
    return ModuleOpenMgr:CheckOpenState(ModuleID.ModuleIDSightseeingLog)
end

--- @type 初步收录是否已满
function WorldExploraMgr:bSightseeingNormalFinish()
    local bNormalCompleteMax = _G.DiscoverNoteMgr:GetNormalDiscoverProcess()
    return bNormalCompleteMax
end

--- @type 完美收录是否已满
function WorldExploraMgr:bSightseeingPrefectFinish()
    local bPerfectCompleteMax = _G.DiscoverNoteMgr:GetPerfectDiscoverProcess()
    return bPerfectCompleteMax
end

--- @type 当前初步收录数量
function WorldExploraMgr:GetSightseeingNormalNum()
    local _, NormalCompleteNum = _G.DiscoverNoteMgr:GetNormalDiscoverProcess()
    return NormalCompleteNum
end

--- @type 当前完美收录数量
function WorldExploraMgr:GetSightseeingPrefectNum()
    local _, PerfectCompleteNum = _G.DiscoverNoteMgr:GetPerfectDiscoverProcess()
    return PerfectCompleteNum
end

--- @type 初步收录总数量
function WorldExploraMgr:GetSightseeingNormalTotalNum()
    local _, _, NormalTotalNum = _G.DiscoverNoteMgr:GetNormalDiscoverProcess()
    return NormalTotalNum
end

--- @type 完美收录总数量
function WorldExploraMgr:GetSightseeingPrefectTotalNum()
    local _, _, bPerfectTotalNum = _G.DiscoverNoteMgr:GetPerfectDiscoverProcess()
    return bPerfectTotalNum
end

--- @type 刷新探索笔记详情页面VM
function WorldExploraMgr:UpdateSightSeeingWinVM(Cfg)
    local RecommPlaceList = _G.DiscoverNoteMgr:RecommandMapListForWildExplore()
    if RecommPlaceList == nil then
        return
    end
    local NeedText, NeedProgress
    if not self:bSightseeingNormalFinish() then             -- 没有完成初步收录
        WorldExploraVM.NumText = LSTR(1610028)  -- 初步收录进度
        NeedText = tostring(self:GetSightseeingNormalNum()).."/"..tostring(self:GetSightseeingNormalTotalNum())
        NeedProgress = self:GetSightseeingNormalNum() / self:GetSightseeingNormalTotalNum()
    else
        WorldExploraVM.NumText = LSTR(1610016)  -- 完美收录进度
        NeedText = tostring(self:GetSightseeingPrefectNum()).."/"..tostring(self:GetSightseeingPrefectTotalNum())
        NeedProgress = self:GetSightseeingPrefectNum() / self:GetSightseeingPrefectTotalNum()
    end
    WorldExploraVM.CurNum = NeedText
    WorldExploraVM.CurProgress = NeedProgress

    local NumRecommPlace = #RecommPlaceList

    WorldExploraVM.bFinishTipVisible = NumRecommPlace <= 0
    WorldExploraVM.bPlaceListVisible = NumRecommPlace > 0

    if (string.isnilorempty(WorldExploraVM.TipDesc)) then
        WorldExploraVM.bTipDescVisible = false
    end

    if NumRecommPlace > 0 then
        WorldExploraVM:UpdateList(WorldExploraVM.RecommPlaceList, RecommPlaceList)
    end
end

--------------------------------探索笔记End---------------------------------------
--------------------------------Fate---------------------------------------

--- @type 当Fate图鉴数据更新
function WorldExploraMgr:OnFateArchiveDataUpdate(bNeed)
    if not bNeed then
        return
    end
    local FateMapState = FateMgr:GetAllMapState()
    FateMapState = self:SortMapByProgress(FateMapState)

    local FateMapInfo = FateMgr:GatherMapFateStageInfo()

    self.RecFateMapsByLog = self:FindRecommendFateMapByLog(FateMapState, FateMapInfo)
end

--- @type Fate图鉴中是否完成了一个Fate成就
function WorldExploraMgr:IsFinishOneFate(FateID)
    local AllFateRecord =  FateMgr:GetAllFateRecord()
    local FateRecord = AllFateRecord[FateID]
    if FateRecord == nil then
        return false
    end
    local bFinish = true
    local Achievements = FateRecord.Achievement
    for i = 1, #Achievements do
        local Elem = Achievements[i]
        if Elem then
            local Progress = Elem.Progress or 0
            local Target = Elem.Target or 0
            if Progress < Target then
                bFinish = false
                break
            end
        end
       
    end
    return bFinish
end

--- @type 根据地图完成进度对地图进行排序
function WorldExploraMgr:SortMapByProgress(FateMapState)
    local NewFataMapState = {}
    for _, MapData in pairs(FateMapState) do
        if MapData.MaxProgress == 0 then
            MapData.Progress = 1
        else
            MapData.Progress = math.clamp(MapData.CurProgress / MapData.MaxProgress, 0, MapData.CurProgress / MapData.MaxProgress)
        end
        table.insert(NewFataMapState, MapData)
    end
    table.sort(NewFataMapState, function(Left, Right) return Left.Progress < Right.Progress end)
    return NewFataMapState
end

--- @type 获取推荐的Fate地图1-4个 只能在ReqFateArchiveData之后调用
function WorldExploraMgr:GetRecommondFateMap()
    local ProfLevel = self:GetCurProfLevel()
    if self:IsCombatProf() and ProfLevel < LevelExpCfg:GetMaxLevel() then -- 当前战斗职业未满级
        return self:GetRecommondFateMapByLevel(ProfLevel)
    else                                               -- 生产职业 || 战斗职业满级
        return self.RecFateMapsByLog or {}
    end
end

--- @type 是否完成了所有的Fate图鉴成就
function WorldExploraMgr:IsFinishAllFate()
    local FateMapState = FateMgr:GetAllMapState()
    for _, Elem in pairs(FateMapState) do
        if Elem.CurProgress < Elem.MaxProgress then
            return false
        end
    end
    return true
end

--- @type 根据Fate图鉴推荐Fate地图
function WorldExploraMgr:FindRecommendFateMapByLog(FateMapState, FateMapInfo)
    local MaxCombatProf = self:GetMaxCombatProfLevel()
    local NeedMapID = {}
    for i = 1, #FateMapState do
        local Elem = FateMapState[i]
        local MapID = Elem.MapID
        local MapFateData = FateMapInfo[MapID]
        local IsNeedMap = false
        if MapFateData ~= nil then
            for i = 1, #MapFateData do
                local FataData = MapFateData[i]
                if not self:IsFinishOneFate(FataData.ID) and FataData.Level <= MaxCombatProf then
                    IsNeedMap = true
                    break;
                end
            end
        end
        if IsNeedMap and #NeedMapID < MaxRecommandMapCount then
            table.insert(NeedMapID, MapID)
        elseif NeedMapID == MaxRecommandMapCount then
            break
        end
    end
    return NeedMapID
end

--- @type 根据战斗职业等级获取Fate地图
function WorldExploraMgr:GetRecommondFateMapByLevel(Level)
    local FateCfg = WEFateRecMapCfg:FindCfgByKey(Level)
    if FateCfg == nil then
        return
    end
    return FateCfg.MapID
    -- local FateCfgs = FateMainCfg:FindAllCfg(string.format("Level <= %s", Level))
    -- table.sort(FateCfgs, function(left, right) return left.Level > right.Level end)
    -- local NeedMapTable = {}
    -- for i = 1, #FateCfgs do
    --     local Cfg = FateCfgs[i]
    --     local ID = Cfg.ID
    --     local GeneratorCfg = FateGeneratorCfg:FindCfgByKey(ID)
    --     if GeneratorCfg ~= nil then
    --         local bNeedMap = true
    --         for j = 1, #NeedMapTable do
    --             local ExitMap = NeedMapTable[j]
    --             if GeneratorCfg.MapID ~= nil and ExitMap == GeneratorCfg.MapID then
    --                 bNeedMap = false
    --                 break
    --             end
    --         end

    --         if bNeedMap and #NeedMapTable < MaxRecommandMapCount and GeneratorCfg.MapID ~= nil then
    --             table.insert(NeedMapTable, GeneratorCfg.MapID)
    --         elseif #NeedMapTable == MaxRecommandMapCount then
    --             break
    --         end
    --     end
        
    -- end
    -- return NeedMapTable
end

--- @type 刷新Fate详情页面VM
function WorldExploraMgr:UpdateFateWinVM(Cfg)
    local RecommPlaceList = self:GetRecommondFateMap()
    if RecommPlaceList == nil then
        return
    end
    WorldExploraVM.bFinishTipVisible = #RecommPlaceList <= 0
    WorldExploraVM.bPlaceListVisible = #RecommPlaceList > 0
    local ExplainText
    local ProfLevel = self:GetCurProfLevel()
    if self:IsCombatProf() and ProfLevel < LevelExpCfg:GetMaxLevel() then
        ExplainText = LSTR(1610012) --(根据当前职业等级推荐)
        WorldExploraVM.HasFinishTipText = Cfg.NoRecomText
    else
        ExplainText = LSTR(1610013) -- (根据临危受命图鉴推荐)
        WorldExploraVM.HasFinishTipText = Cfg.BookNoText
    end
    WorldExploraVM.RecommMapText = WorldExploraVM.RecommMapText..ExplainText

    if #RecommPlaceList > 0 then
        WorldExploraVM:UpdateList(WorldExploraVM.RecommPlaceList, RecommPlaceList)
    end
end

--------------------------------Fate End---------------------------------------
--------------------------------冒险商游团-----------------------------------------
---@type 是否解锁友好度
function WorldExploraMgr:IsUnlockFriendliness()
    return _G.MysterMerchantMgr:IsUnlockFriendliness()
end

---@type 获取友好度信息(可能为nil)
function WorldExploraMgr:GetFriendlinessInfo()
    return _G.MysterMerchantMgr:GetFriendlinessInfo()
end

--- @type 刷新冒险商游团详情页面VM
function WorldExploraMgr:UpdateMysterMechWinVM(Cfg)
    local Info = self:GetFriendlinessInfo()
    local bUnLock = self:IsUnlockFriendliness()
    WorldExploraVM.bFinishTipVisible = not bUnLock

    if (Info.IsGetMaxLevel) then
        --满级
        WorldExploraVM.CurNum = LSTR(1610027) --友好度已满
        WorldExploraVM.CurProgress = 1
    else
        WorldExploraVM.CurNum = tostring(Info.LevelLeftExp).."/"..tostring(Info.NextLevelRequiredExp)
        WorldExploraVM.CurProgress = Info.LevelLeftExp / Info.NextLevelRequiredExp        
    end

    WorldExploraVM.NumText = WorldExploraVM.NumText..tostring(Info.Level)
    WorldExploraVM.bProgressVisible = bUnLock
    WorldExploraVM.bRecomMapVisible = not bUnLock
    WorldExploraVM.bPlaceListVisible = false
    WorldExploraVM.bDownTextVisible = not bUnLock
end

--------------------------------冒险商游团 End---------------------------------------

-----------------------------------巡回乐团---------------------------------------
--- @type 刷新巡回乐团详情页面VM
function WorldExploraMgr:UpdateTourWinVM()
    WorldExploraVM.bFinishTipVisible = false
    local NumText, CurNum, CurProgress
    local CurMeetCount = _G.TouringBandMgr:GetCurrentMeetCount()
    local TotalMeetableCount = _G.TouringBandMgr:GetTotalMeetableCount()
    local AvailableFansCount = _G.TouringBandMgr:GetAvailableFansCount()
    local TotalFansCount = _G.TouringBandMgr:GetTotalFansCount()
    if not _G.TouringBandMgr:IsMeetBandFull() then
        NumText = LSTR(1610020) --相遇乐团的数量
        CurNum = tostring(CurMeetCount).."/"..tostring(TotalMeetableCount)
        CurProgress = CurMeetCount / TotalMeetableCount
    else
        NumText = LSTR(1610021) --成为粉丝的乐团数量
        CurNum = tostring(AvailableFansCount).."/"..tostring(TotalFansCount)
        CurProgress = AvailableFansCount / TotalFansCount
    end
    WorldExploraVM.NumText =  NumText

    WorldExploraVM.CurNum = CurNum
    WorldExploraVM.CurProgress = CurProgress
    WorldExploraVM.bProgressVisible = true
end
--------------------------------巡回乐团 End---------------------------------------

-----------------------------------陆行鸟房---------------------------------------
---
------ @type 刷新陆行鸟房详情页面VM
function WorldExploraMgr:UpdateTourChocoboTransVM()
    self.bFinishTipVisible = false
end
--------------------------------陆行鸟房 End---------------------------------------

-----------------------------------捕鱼---------------------------------------
--- @type 根据钓鱼人等级获取钓场ID
function WorldExploraMgr:GetFishLocByProfLevel()
    local Level = MajorUtil.GetMajorLevelByProf(ProfType.PROF_TYPE_FISHER)
    if Level == nil then
        return
    end
    local Cfg = WEFishRecMapCfg:FindCfgByKey(Level)
    if Cfg == nil then
        return
    end
    return Cfg.MapID
    -- local MapList = {}
    -- if not self:ProfIsUnlock(ProfType.PROF_TYPE_FISHER) then
    --     return MapList
    -- end
    -- local FishProfLevel = MajorUtil.GetMajorLevelByProf(ProfType.PROF_TYPE_FISHER)
    -- local AllFishLocCfg = FishLocationCfg:FindAllCfg(string.format("Level <= %s", FishProfLevel))
    -- table.sort(AllFishLocCfg, function(Left, Right) return Left.Level > Right.Level end)
    -- for i = 1, MaxRecommandMapCount do
    --     table.insert(MapList, AllFishLocCfg[i].MapID)
    -- end
    -- return MapList
end

--- @type 刷新捕鱼详情页面VM
function WorldExploraMgr:UpdateFishingWinVM(Cfg)
    local RecommPlaceList = {}
    local ExplainText = LSTR(1610015) -- (根据鱼类图鉴推荐)
    if not self:ProfIsMaxLevel(ProfType.PROF_TYPE_FISHER) then -- 钓鱼等级未满
        RecommPlaceList = self:GetFishLocByProfLevel() or {}
        ExplainText = LSTR(1610014) --(根据捕鱼人等级推荐)
     elseif _G.FishNotesMgr:GetFishGuideIsAllUnLock() then
    --     ExplainText = LSTR(161001) -- (根据鱼类图鉴推荐)
        --满级处理
        RecommPlaceList = {} 
    else
        RecommPlaceList = _G.FishNotesMgr:GetMinUnLockProgress() or {}
    end

    if #RecommPlaceList > 0 then
        WorldExploraVM:UpdateList(WorldExploraVM.RecommPlaceList, RecommPlaceList)
    end
    WorldExploraVM.bPanelBtnVisible = self:ProfIsUnlock(ProfType.PROF_TYPE_FISHER)

    WorldExploraVM.RecommMapText = WorldExploraVM.RecommMapText..ExplainText
    WorldExploraVM.bFinishTipVisible = #RecommPlaceList <= 0 and self:ProfIsMaxLevel(ProfType.PROF_TYPE_FISHER)
    WorldExploraVM.bPlaceListVisible = #RecommPlaceList > 0

    WorldExploraVM.bPanelRewardVisible = #Cfg.Reward > 0 and self:ProfIsUnlock(ProfType.PROF_TYPE_FISHER)  -- 配置了物品则奖励是物品
    WorldExploraVM.bPanelFunctionVisible = not WorldExploraVM.bPanelRewardVisible
end
--------------------------------捕鱼 End---------------------------------------

-----------------------------------伐木---------------------------------------
--- @type 根据采矿等级获取钓场ID
function WorldExploraMgr:GetGatherLocByProfLevel()
    local Level = MajorUtil.GetMajorLevelByProf(ProfType.PROF_TYPE_BOTANIST)
    if Level == nil then
        return
    end
    local Cfg = WELoggingRecMapCfg:FindCfgByKey(Level)
    if Cfg == nil then
        return
    end
    return Cfg.MapID
end

--- @type 刷新采矿详情页面VM
function WorldExploraMgr:UpdateMiningGatherVM(Cfg)
    local RecommPlaceList = {}

    local ExplainText = LSTR(1610026) --(根据伐木工等级推荐)
    if not self:ProfIsMaxLevel(ProfType.PROF_TYPE_BOTANIST) then -- 伐木工等级未满
        RecommPlaceList = self:GetGatherLocByProfLevel() or {}
    else
        RecommPlaceList = _G.GatheringLogMgr:GetRecommendRareGatherPoint(ProfType.PROF_TYPE_BOTANIST) or {}

        if #RecommPlaceList <= 0 then
            ExplainText = LSTR(1610025) --当前暂无可推荐场景            
        else
            ExplainText = LSTR(1610024) --当前时段有几率获得稀有采集物的场景            
        end 
    end

    if #RecommPlaceList > 0 then
        WorldExploraVM:UpdateList(WorldExploraVM.RecommPlaceList, RecommPlaceList)
    end
    WorldExploraVM.bPanelBtnVisible = self:ProfIsUnlock(ProfType.PROF_TYPE_BOTANIST)

    WorldExploraVM.RecommMapText = WorldExploraVM.RecommMapText..ExplainText
    WorldExploraVM.bFinishTipVisible = #RecommPlaceList <= 0 and self:ProfIsMaxLevel(ProfType.PROF_TYPE_BOTANIST)
    WorldExploraVM.bPlaceListVisible = #RecommPlaceList > 0

    WorldExploraVM.bPanelRewardVisible = #Cfg.Reward > 0 and self:ProfIsUnlock(ProfType.PROF_TYPE_BOTANIST)  -- 配置了物品则奖励是物品
    WorldExploraVM.bPanelFunctionVisible = not WorldExploraVM.bPanelRewardVisible
end

--------------------------------伐木 End---------------------------------------

--------------------------------------采矿---------------------------------------

--- @type 根据矿工等级获取矿场ID
function WorldExploraMgr:GetMiningLocByProfLevel()
    local Level = MajorUtil.GetMajorLevelByProf(ProfType.PROF_TYPE_MINER)
    if Level == nil then
        return
    end
    local Cfg = WEGatherRecMapCfg:FindCfgByKey(Level)
    if Cfg == nil then
        return
    end
    return Cfg.MapID
end

--- @type 刷新矿工详情页面VM
function WorldExploraMgr:UpdateMiningWinVM(Cfg)
    local RecommPlaceList = {}

    local ExplainText = LSTR(1610018) --(根据采矿工等级推荐)
    if not self:ProfIsMaxLevel(ProfType.PROF_TYPE_MINER) then -- 矿工等级未满
        RecommPlaceList = self:GetMiningLocByProfLevel() or {}
    else
        RecommPlaceList = _G.GatheringLogMgr:GetRecommendRareGatherPoint(ProfType.PROF_TYPE_MINER) or {}

        if #RecommPlaceList <= 0 then
            ExplainText = LSTR(1610025) --当前暂无可推荐场景            
        else
            ExplainText = LSTR(1610024) --当前时段有几率获得稀有采集物的场景            
        end        
        
    end

    if #RecommPlaceList > 0 then
        WorldExploraVM:UpdateList(WorldExploraVM.RecommPlaceList, RecommPlaceList)
    end
    WorldExploraVM.bPanelBtnVisible = self:ProfIsUnlock(ProfType.PROF_TYPE_MINER)
    
    WorldExploraVM.RecommMapText = WorldExploraVM.RecommMapText..ExplainText
    WorldExploraVM.bFinishTipVisible = #RecommPlaceList <= 0 and self:ProfIsMaxLevel(ProfType.PROF_TYPE_MINER)
    WorldExploraVM.bPlaceListVisible = #RecommPlaceList > 0

    WorldExploraVM.bPanelRewardVisible = #Cfg.Reward > 0 and self:ProfIsUnlock(ProfType.PROF_TYPE_MINER)  -- 配置了物品则奖励是物品
    WorldExploraVM.bPanelFunctionVisible = not WorldExploraVM.bPanelRewardVisible
end

--------------------------------采矿 End---------------------------------------
--=============================================================探索页面End===========================================================================

return WorldExploraMgr
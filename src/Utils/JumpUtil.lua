local JumpCfg = require("TableCfg/JumpCfg")
local MiniappWechatParamsCfg = require("TableCfg/MiniappWechatParamsCfg")
local MiniappQQParamsCfg = require("TableCfg/MiniappQqParamsCfg")
local UIViewMgr = _G.UIViewMgr
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local AccountUtil = require("Utils/AccountUtil")
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS
local FVector2D = _G.UE.FVector2D

local JumpUtil = {}
local Jump_Type = {
    JumpView = 1,                   --- 通过ViewID跳转
    JumpWorldEnt = 2,               --- 跳副本 Type 副本入口类型:JumpData.Params[1], ID 该类型下副本入口ID:JumpData.Params[2], 副本有的用globacfg控制了开启JumpData.Params[3]
    CustomJumpFunc = 3,             --- 通过CustomJumpFunc配置的Lua跳      
    ShowMapNpc = 4,                 --- 跳转地图NPC MapID:JumpData.Params[1], NPCID:JumpData.Params[2]
    PageLink = 5,                   --- 网页链接  链接:JumpData.Params[1]
    Pandora  = 6,                   --- 潘多拉 AppID:JumpData.Params[1]
    Mount =  7,                     --- 跳转至坐骑 Params[1] 坐骑表ID 配置后支持选中指定ID坐骑
    MapCrystal = 8,                 --- 跳转地图对应水晶 Params[1] MapID, Params[2] CrystalID
    PreView = 9,                    --- 跳转预览界面(宠物 坐骑 时装)
    Shop = 10,                      --- 跳转至商会对应商店 Params[1] 商店ID Params[2] 商品一级分类
    Task = 11,                      --- 通过ChapterID 跳转地图标注任务 Params[1] ChapterID
    GameBot = 12,                   --- 游戏知己 Params[1] string的Question 可传 可不传
    PwordTeaching = 13,             --- 机制特训
    ShareMiniAppToFriend = 14,      --- 分享小程序给好友跳转 Params[1] QQ小程序ID Param[2]微信小程序ID(小程序参数配置在跳转表的小程序参数页签)
    GoldSauser = 15,                --- 金蝶 Params[1]  GoldSauserGameClientType
    ActivityPicShare = 16,          --- 活动图片分享 Params[1] ActivityID Params[2] ShareNodeCfg.Params[1]
    Emotion = 17,                   --- 情感动作界面 Params[1] TabType Params[2] EmoActID
    ShowMapPoint = 18,              --- 地图标记点   Params[1] 地图ID Params[2]MarkerID Params[3]UIMapID
    MusicPerformance = 19,          --- 乐器演奏
    MiniApp = 20,                   --- 拉起小程序 Params[1] QQ小程序ID Param[2]微信小程序ID(小程序参数配置在跳转表的小程序参数页签)
    ShowMapCustomPos = 21,          --- 打开地图指定Pos Params[1] 地图ID Params[2]Posx Params[3]PosY
}

JumpUtil.JumpType = Jump_Type
-----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- CheckFuncStart -------------------------------------------------------

--- 检测副本对应type 是否解锁开启
local function CheckWorldEntOpen(JumpParams)
    if JumpParams[3] then
        local TableData = ClientGlobalCfg:FindCfgByKey(JumpParams[3])
        if TableData and TableData.Value[1] ~= 1 then
            return false
        end
    end

    local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
    local Type = JumpParams and tonumber(JumpParams[1]) or 0
    local EntID = tonumber(JumpParams[2])
    if Type == 0 or EntID == 0 then return false end
	local Pol = PWorldEntUtil.GetPol(EntID, Type)

	return Pol:CheckFilter(EntID)
end

local function CheckShopOpenByShopID(JumpParams)
    return _G.ShopMgr:ShopIsUnLock(tonumber(JumpParams[1]))
end

local function CheckCanGoTask(JumpParams)
    local ChapterID = tonumber(JumpParams[1])
    local ChapterCfg = QuestChapterCfg:FindCfgByKey(ChapterID)
    local StartStatus = _G.QuestMgr:GetQuestStatus(ChapterCfg.StartQuest)
    local EndStatus = _G.QuestMgr:GetQuestStatus(ChapterCfg.EndQuest)
    local QuestHelper = require("Game/Quest/QuestHelper")
    if EndStatus == QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
        return false
    elseif StartStatus == QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED and not QuestHelper.CheckCanActivate(ChapterCfg.StartQuest) then
        return false, _G.LSTR(520067)
    else
        return true
    end
end

local function CheckPwordTeaching()
    _G.PWorldEntVM:UpdateTeach()
    return _G.PWorldEntVM.bUnlockTeach
end

local function CheckEmotionActActivited(JumpParams)
    local EmotionID = JumpParams and tonumber(JumpParams[2]) or 0
    if EmotionID == 0 then return false end

    return _G.EmotionMgr:IsActivatedID(EmotionID)
end

---- 可以在这里加 也可以在表格中配置 CheckOpenFunc字段
local JumpCheckOpenCondition = {
    [Jump_Type.JumpWorldEnt]   = CheckWorldEntOpen,
    [Jump_Type.Shop]           = CheckShopOpenByShopID,
    [Jump_Type.Task]           = CheckCanGoTask,
    [Jump_Type.PwordTeaching]  = CheckPwordTeaching,
    [Jump_Type.Emotion]        = CheckEmotionActActivited,
}

local function DoLuaFuncByStr(LuaFuncStr)
    if LuaFuncStr and not string.isnilorempty(LuaFuncStr) then
        local LuaFunc = _G.load(string.format("return %s", LuaFuncStr))
        if LuaFunc then
            local Result = LuaFunc()
            return Result
        else
            FLOG_ERROR(string.format("JumpUtil Lua error, please check lua script  = %s", LuaFuncStr))
            return false
        end
    end
end

local function CheckJump(JumpData, CustomJumpParams)
    local ModuleID = JumpData.ModuleID or 0
    local CanJump = true
    local ForbidTipsStr
    if ModuleID ~= 0 then
        CanJump = _G.ModuleOpenMgr:CheckOpenState(JumpData.ModuleID)
    end

    if CanJump and JumpCheckOpenCondition[JumpData.JumpType] then
        local JumpParams = CustomJumpParams or JumpData.Params
        CanJump, ForbidTipsStr = JumpCheckOpenCondition[JumpData.JumpType](JumpParams)
    end

    if not CanJump then return false, ForbidTipsStr end
    if JumpData.CheckOpenFunc and not string.isnilorempty(JumpData.CheckOpenFunc) then
        CanJump, ForbidTipsStr = DoLuaFuncByStr(JumpData.CheckOpenFunc)
    end

    return CanJump, ForbidTipsStr
end

function JumpUtil.IsCurJumpIDCanJump(JumpID)
    if not JumpID or JumpID == 0 then 
        return false 
    end

    local JumpData = JumpCfg:FindCfgByKey(JumpID) or {}
    if not next(JumpData) then 
        FLOG_ERROR(string.format("JumpUtil.IsCurJumpIDCanJump , Error JumpCfg JumpID = %d", JumpID))
        return false 
    end

    return CheckJump(JumpData)
end

function JumpUtil.IsCurJumpTypeCanJump(JumpType, CustomJumpParams)
    local TypeJumpData = JumpCfg:FindCfg(string.format("JumpType = %d", JumpType)) or {}
    if not next(TypeJumpData) then 
        FLOG_ERROR(string.format("JumpUtil.IsCurJumpTypeCanJump , Error JumpType JumpType = %d", JumpType))
        return false 
    end

    return CheckJump(TypeJumpData, CustomJumpParams)
end
-----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- CheckFuncEnd -------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- JumpFuncStart -------------------------------------------------------
local function JumpView(JumpData, ...)
    local View = UIViewMgr:FindVisibleView(JumpData.ViewID)
    if not View then
        UIViewMgr:ShowView(JumpData.ViewID, {JumpData = {...}})
    else
        local Params = View.Params or {}
        Params.JumpData = {...}
        View:UpdateView(Params)
    end
end

local function JumpWorldEnt(JumpData, ...)
    local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
    PWorldEntUtil.ShowPWorldEntView(...)
end

local function CustomJumpFunc(JumpData, JumpParams)
    if JumpData.CustomJumpFunc and not string.isnilorempty(JumpData.CustomJumpFunc) then
        -- local ParamsStr = ""
        -- for i, v in ipairs(JumpParams) do
        --     if ParamsStr == "" then
        --         ParamsStr = tostring(v)
        --     else
        --         ParamsStr = string.format("%s,%d", ParamsStr, v) 
        --     end
        -- end

        -- local FinalFuncStr = string.gsub(JumpData.CustomJumpFunc, "%(", "(" .. ParamsStr)
        DoLuaFuncByStr(JumpData.CustomJumpFunc)
    end
end

local function ShowMapNpc(JumpData, ...)
    _G.WorldMapMgr:ShowWorldMapNpc(...)
end

local function JumpWebPage(JumpData, ...)
    AccountUtil.OpenUrlWithParam(...)
end

local function JumpPandora(JumpData, ...)
    local ParamsData = {...}
    if ParamsData[1] then
        _G.PandoraMgr:OpenApp(tostring(ParamsData[1]))
    end
end

local function JumpMount(JumpData, ...)
    _G.MountMgr:JumpToMountPanel(...)
end

local function JumpMapCrystal(JumpData, ...)
    _G.WorldMapMgr:ShowWorldMapCrystal(...)
end

local function JumpPreView(JumpData, ...)
    _G.PreviewMgr:OpenPreviewView(...)
end

local function JumpShop(JumpData, ...)
    _G.ShopMgr:OpenShop(...)
end

local function JumpTaskOnMapByChapterID(JumpData, ...)
    _G.AdventureCareerMgr:JumpChapterOnMap(...)
end

local function JumpGameBot(JumpData, ...)
    local OperationUtil = require("Utils/OperationUtil")
    local ParamsData = {...}
    OperationUtil.OpenGameBot(ParamsData[1] or "")
end

local function JumpPwordTeaching()
    _G.TeachingMgr:OnShowMainWindow()
end

local function JumpShareMiniAppToFriend(JumpData, ...)
    local JumpParam = {...}
    local ParamsData
    if _G.LoginMgr:IsQQLogin() and JumpParam[1] then
        ParamsData =  MiniappQQParamsCfg:FindCfgByKey(JumpParam[1]) or {}
    elseif _G.LoginMgr:IsWeChatLogin() and JumpParam[2] then
        ParamsData =  MiniappWechatParamsCfg:FindCfgByKey(JumpParam[2]) or {}
    else
        FLOG_INFO("JumpShareMiniAppToFriend Channel not support ")
    end

    if ParamsData then
        JumpUtil.JumpShareMiniAppToFriendByParamsData(ParamsData)
    end
end

local function JumpGoldSauserByType(JumpData, ...)
    _G.GoldSauserMainPanelMgr:OpenGoldSauserMainPanel(...)
end

local function JumpActivityPicShare(JumpData, ...)
    _G.ShareMgr:OpenShareActivityUI(...)
end

local function JumpEmotion(JumpData, ...)
    local JumpParam = {...}
    _G.EmotionMgr:ShowEmotionMainPanel({TabType = JumpParam[1], EmoActID = JumpParam[2]})
end

local function ShowMapPoint(JumpData, ...)
    local JumpParam = {...}
    _G.WorldMapMgr:ShowWorldMapFixPoint(JumpParam[1], JumpParam[2], JumpParam[3])
end

local function ShowMusicPerformance(JumpData, ...)
    if _G.MusicPerformanceMgr:CanPerformance() then
        UIViewMgr:ShowView(_G.UIViewID.MusicPerformanceSelectPanelView)
    end
end

local function JumpMiniApp(JumpData, ...)
    local JumpParam = {...}
    local ParamsData
    if _G.LoginMgr:IsQQLogin() and JumpParam[1] then
        ParamsData =  MiniappQQParamsCfg:FindCfgByKey(JumpParam[1]) or {}
    elseif _G.LoginMgr:IsWeChatLogin() and JumpParam[2] then
        ParamsData =  MiniappWechatParamsCfg:FindCfgByKey(JumpParam[2]) or {}
    else
        FLOG_INFO("JumpMiniApp Channel not support ")
    end

    if ParamsData then
        JumpUtil.JumpMiniAppByParamsData(ParamsData)
    end
end

local function JumpMapByPos(JumpData, ...)
    local JumpParam = {...}
    _G.WorldMapMgr:OpenMapFromChatHyperlink(JumpParam[1] or 1001, FVector2D(JumpParam[2] or 0, JumpParam[3] or 0))
end

local JumpMethodsList = {
    [Jump_Type.JumpView]                = JumpView,
    [Jump_Type.JumpWorldEnt]            = JumpWorldEnt,
    [Jump_Type.CustomJumpFunc]          = CustomJumpFunc,
    [Jump_Type.ShowMapNpc]              = ShowMapNpc,
    [Jump_Type.PageLink]                = JumpWebPage,
    [Jump_Type.Pandora]                 = JumpPandora,
    [Jump_Type.Mount]                   = JumpMount,
    [Jump_Type.MapCrystal]              = JumpMapCrystal,
    [Jump_Type.PreView]                 = JumpPreView,
    [Jump_Type.Shop]                    = JumpShop,
    [Jump_Type.Task]                    = JumpTaskOnMapByChapterID,
    [Jump_Type.GameBot]                 = JumpGameBot,
    [Jump_Type.PwordTeaching]           = JumpPwordTeaching,
    [Jump_Type.ShareMiniAppToFriend]    = JumpShareMiniAppToFriend,
    [Jump_Type.GoldSauser]              = JumpGoldSauserByType,
    [Jump_Type.ActivityPicShare]        = JumpActivityPicShare,
    [Jump_Type.Emotion]                 = JumpEmotion,
    [Jump_Type.ShowMapPoint]            = ShowMapPoint,
    [Jump_Type.MusicPerformance]        = ShowMusicPerformance,
    [Jump_Type.MiniApp]                 = JumpMiniApp,
    [Jump_Type.ShowMapCustomPos]        = JumpMapByPos,
}   

--- 跳转至对应系统
--- @param JumpID       对应跳转表ID
--- @param IsShowTips   不可跳转时弹Tips(前提是跳转表配置了有效的ForbiddenTips)
function JumpUtil.JumpTo(JumpID, IsShowTips)
    if not JumpID then return end
    local JumpData = JumpCfg:FindCfgByKey(JumpID) or {}
    local CanJump, ForbidTipsStr = JumpUtil.IsCurJumpIDCanJump(JumpID)
    if CanJump then
        if not next(JumpData) then
            FLOG_ERROR(string.format("JumpUtil.JumpTo , Error JumpID = %d", JumpID))
            return 
        end

        if JumpMethodsList[JumpData.JumpType] then
            local ParamsData = {}
            for i, v in ipairs(JumpData.Params) do
                ParamsData[i] = tonumber(v) and tonumber(v) or v
            end

            JumpMethodsList[JumpData.JumpType](JumpData, table.unpack(ParamsData))
        else
            FLOG_ERROR("JumpUtil.JumpTo, Undefine JumpType") 
        end
    else
        ForbidTipsStr = ForbidTipsStr or JumpData.ForbiddenTips
        if IsShowTips and not string.isnilorempty(ForbidTipsStr) then
            _G.MsgTipsUtil.ShowTips(ForbidTipsStr)
        end
    end
end

--- 跳转至对应系统通过Jump_Type和自定义的参数 (需跳转表存在此类型的配置)
function JumpUtil.JumpToByTypeWithJumpParams(JumpType, ...)
    if Jump_Type == Jump_Type.CustomJumpFunc then
        FLOG_ERROR("Jump_Type.CustomJumpFunc Nonsupport") 
        return 
    end

    if JumpUtil.IsCurJumpTypeCanJump(JumpType, {...}) then
        local TypeJumpData = JumpCfg:FindCfg(string.format("JumpType = %d", JumpType)) or {}
        if JumpMethodsList[TypeJumpData.JumpType] then
            JumpMethodsList[TypeJumpData.JumpType](TypeJumpData, ...)
        else
            FLOG_ERROR("JumpUtil.JumpToByTypeWithJumpParams, Undefine JumpType") 
        end
    end
end

--- 拉起小程序
function JumpUtil.JumpMiniAppByParamsData(ParamsData)
    if _G.LoginMgr:IsQQLogin() then
        AccountUtil.SendPullUpQQMiniApp(
            ParamsData.MiniAppID, 
            ParamsData.MiniPath, 
            ParamsData.MiniProgramType
        )
    elseif _G.LoginMgr:IsWeChatLogin() then
        AccountUtil.SendPullUpWechatMiniApp(
            ParamsData.MediaPath, 
            ParamsData.MiniAppID, 
            ParamsData.ShareTicket and tonumber(ParamsData.ShareTicket) or 0,
            ParamsData.MiniProgramType
        )
    else
        FLOG_INFO("JumpMiniAppByParamsData Channel not support ")
    end     
end

--- 分享小程序给好友 会先拉起好友
function JumpUtil.JumpShareMiniAppToFriendByParamsData(ParamsData)
    if _G.LoginMgr:IsQQLogin() then
        AccountUtil.SendQQMiniApp("", 
            ParamsData.Link,
            ParamsData.Title,
            ParamsData.Desc,
            ParamsData.ThumbPath,
            ParamsData.MiniAppID,
            ParamsData.MiniPath,
            ParamsData.MiniWebpageUrl,
            ParamsData.MiniProgramType
        )
    elseif _G.LoginMgr:IsWeChatLogin() then
        AccountUtil.SendWechatMiniApp("", 
            ParamsData.Link,
            ParamsData.ThumbPath,
            ParamsData.MiniAppID,
            ParamsData.MiniProgramType,
            ParamsData.MediaTagName,
            ParamsData.MediaPath,
            ParamsData.GameData
        )
    else
        FLOG_INFO("JumpShareMiniAppToFriendByParamsData Channel not support ")
    end
end

--- 知己侧调用跳转用
function JumpUtil.OnGameBotJump(JumpParamsStr)
    if JumpParamsStr and string.find(JumpParamsStr, "JumpForm_") then
		local JumpID = JumpParamsStr:match("JumpForm_(%d+)")
		if JumpID then
			local JumpUtil = require("Utils/JumpUtil")
			JumpUtil.JumpTo(tonumber(JumpID), true)
            _G.UE.UGameBotMgr.Get():ClosePage()
		end
	end
end
----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------- JumpFuncEnd -------------------------------------------------------

return JumpUtil
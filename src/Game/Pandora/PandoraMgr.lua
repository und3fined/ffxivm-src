local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local CommonUtil = require("Utils/CommonUtil")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local JumpUtil = require("Utils/JumpUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MSDKDefine = require("Define/MSDKDefine")
local Json = require("Core/Json")
local AccountUtil = require("Utils/AccountUtil")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
local OperationUtil = require("Utils/OperationUtil")
local PayUtil = require("Utils/PayUtil")

local PandoraMgr = LuaClass(MgrBase)

local PandoraActivityType = {
    FaceSlap = 1,
    Announcement = 2,
    OpsActivity = 3,
}

local ShareMiniAppType = {
    WeChatRelease = 0,
    QQPreview = 1,
    WeChatPreview = 2,
    QQRelease = 3,
}

function PandoraMgr:OnInit()
    self.EnableFunction = true

    self.AnnouncementRedDotID = 17004
    self.AnnouncementAppId = "6153"  --公告
    --self.AnnouncementAppId = "6082"  --测试Demo
	self.FaceSlapAppId = "6280"	--拍脸

    self.TimerID = nil
	self.HasOpenedFaceSlapApp = false
    self.CurOpenedAppId = ""
    self.MaxCheckTime = 10
    self.IsGameSDKOpened = false
    self.AnotherAppId = "" --被潘多拉活动打开的其他潘多拉活动
    self.RedDotList = {}
    self.SinkToBottomActivityList = {}
    self.CurLabelDataArray = ""
    self.CurrentShareContent = ""

    self.CurPayAppID = ""
    self.CurPayAppName = ""
    self.CurPayCoinType = ""
    self.CurrentProductID = ""
    self.OrderToken = ""

    self.AppList = {}
end

function PandoraMgr:OnBegin()

end

function PandoraMgr:OnEnd()
    self:ResetDatas()
end

function PandoraMgr:OnShutdown()

end

function PandoraMgr:OnRegisterNetMsg()

end

function PandoraMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MainPanelShow, self.OnMainPanelShow)
    self:RegisterGameEvent(EventID.MSDKDeliverMessageNotify, self.OnGameEventMSDKDeliverMessageNotify)
    self:RegisterGameEvent(EventID.MSDKQueryFriendNotify, self.OnGameEventMSDKQueryFriendNotify)
    self:RegisterGameEvent(EventID.AppEnterBackground, self.OnGameEventAppEnterBackground)
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function PandoraMgr:OnGameEventAppEnterBackground()
   self:OnApplicationFocusChanged(false)
end

function PandoraMgr:OnGameEventAppEnterForeground()
    self:OnApplicationFocusChanged(true)
end

function PandoraMgr:InitGamelet(ChannelId, UserId, RoleId, bIsTestEnv, bEnableLog)
    _G.FLOG_INFO("PandoraMgr:InitGamelet, EnableFunction:%s", tostring(self.EnableFunction))
    if not self.EnableFunction then
        _G.UE.UGameletMgr.Get():SetEnableGamelet(false)
        return
    end

    local IsTestEnv = bIsTestEnv
    if not CommonUtil.IsShipping() then
        IsTestEnv = true
    end

    -- 测试OpenID
    -- UserId = "3903467765502703339"
    self:DoInit(ChannelId, UserId, tostring(RoleId), true, IsTestEnv)
end

function PandoraMgr:SwitchToReleaseEnv()
    self:CloseGameletSDK()
    self:DoInit(_G.LoginMgr:GetChannelID(), tostring(_G.LoginMgr:GetOpenID()), tostring(_G.LoginMgr:GetRoleID()), true, false)
end

function PandoraMgr:GetUserData(UserId)
    local UserDataMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    UserDataMap:Add("sOpenId", UserId)

    if _G.LoginMgr:IsWeChatLogin() then
        UserDataMap:Add("sAppId", MSDKDefine.Config.WechatAppID)
        UserDataMap:Add("sAccountType", "wx")
        UserDataMap:Add("sArea", "1")
    else
        UserDataMap:Add("sAppId", MSDKDefine.Config.QQAPPID)
        UserDataMap:Add("sAccountType", "qq")
        UserDataMap:Add("sArea", "2")
    end

    local Platform = CommonUtil.GetPlatformName()
    local PlatID = "1"
    if Platform == "Android" then
        PlatID = "1"
    elseif Platform == "IOS" then
        PlatID = "0"
    end
    UserDataMap:Add("sPlatID", PlatID)
    UserDataMap:Add("sRoleId", tostring(_G.LoginMgr:GetRoleID()))
    if _G.LoginMgr:GetChannelID() == "10" then
        UserDataMap:Add("sAccessToken", "TestAccessToken")
    else
        UserDataMap:Add("sAccessToken", _G.LoginMgr:GetToken())
    end
    UserDataMap:Add("sGameVer", _G.UE.UVersionMgr.GetAppVersion())
    UserDataMap:Add("sServiceType", "FMGAME")       --国内版
    --UserDataMap:Add("sServiceType", "Fmgamegl")   --海外版
    UserDataMap:Add("sPartition", tostring(_G.LoginMgr:GetWorldID()))

    --以下为非必填项
    UserDataMap:Add("sRegion", "0")                 --国内版
    --UserDataMap:Add("sRegion", "5")               --海外版
    UserDataMap:Add("sLanguage", "zh-Hans")         --国内版
    --UserDataMap:Add("sLanguage", "en")            --海外版
    --UserDataMap:Add("sPayToken", "")
    --UserDataMap:Add("sChannelID", "")
    --UserDataMap:Add("sLoginChannel", "")
    --UserDataMap:Add("sIntlSdkParam", "")
    if Platform == "Android" then
        if _G.UE.UCommonUtil.IsAppInstalled("com.tencent.mobileqq", "") then
            UserDataMap:Add("sQQInstalled", "1")
        else
            UserDataMap:Add("sQQInstalled", "0")
        end
        if _G.UE.UCommonUtil.IsAppInstalled("com.tencent.mm", "") then
            UserDataMap:Add("sWXInstalled", "1")
        else
            UserDataMap:Add("sWXInstalled", "0")
        end
    elseif Platform == "IOS" then
        if _G.UE.UCommonUtil.IsAppInstalled("QQ", "") then
            UserDataMap:Add("sQQInstalled", "1")
        else
            UserDataMap:Add("sQQInstalled", "0")
        end
        if _G.UE.UCommonUtil.IsAppInstalled("WeChat", "") then
            UserDataMap:Add("sWXInstalled", "1")
        else
            UserDataMap:Add("sWXInstalled", "0")
        end
    end
    UserDataMap:Add("sExtend", "")
    UserDataMap:Add("sExtCgiAttrs", "{\"attr1\":\"\",\"attr2\":\"\",\"attr3\":\"\"}")
    return UserDataMap
end

function PandoraMgr:DoInit(ChannelId, UserId, RoleId, EnableLog, IsTestEnv)
	_G.UE.UGameletMgr.Get():SetEnableLog(EnableLog)
    _G.UE.UGameletMgr.Get():SetIsTestMode(IsTestEnv)
	_G.UE.UGameletMgr.Get():SetUserInfo(ChannelId, UserId, self:GetUserData(UserId))
	_G.UE.UGameletMgr.Get():SetFont("Main_Font", "Font'/Game/UI/Fonts/Main_Font.Main_Font'")
	_G.UE.UGameletMgr.Get():SetFont("Title_Font", "Font'/Game/UI/Fonts/Title_Font.Title_Font'")
	_G.UE.UGameletMgr.Get():SetDefaultFont("Main_Font")
	_G.UE.UGameletMgr.Get():LaunchGameletSDK(RoleId)
    self.IsGameSDKOpened = true
    self:RefreshUserdata()
end

function PandoraMgr:RefreshUserdata()
    local UserId = tostring(_G.LoginMgr:GetOpenID())
    _G.FLOG_INFO("PandoraMgr:RefreshUserdata, UserId:%s", UserId)
    _G.UE.UGameletMgr.Get():DoRefreshUserdata(self:GetUserData(UserId))
end

function PandoraMgr:OnMainPanelShow(Params)
    --_G.FLOG_INFO("PandoraMgr:OnMainPanelShow: %s", table_to_string(Params))
    if nil ~= Params and nil ~= Params.bShow and Params.bShow == true then
        self:OpenFaceSlapApp()
    end
end

function PandoraMgr:OpenFaceSlapApp()
    if self:CanOpenFaceSlapApp() then
        self:OpenApp(self.FaceSlapAppId)
    end
end

function PandoraMgr:OpenAnnouncement()
    local Cfg = OperationUtil.GetOperationChannelFuncConfig()
    if nil ~= Cfg and Cfg.IsEnableInGameAnnouncement == 0 then
        _G.FLOG_WARNING("PandoraMgr:OpenAnnouncement, Cfg.IsEnableInGameAnnouncement is false!")
        return
    end
    self:OpenApp(self.AnnouncementAppId)

    -- self:RegisterTimer(function()
    --     self:ShowReceivedItems("60100001|18,60100002|7,60700010|9,60200003|16,19000101|56")
    -- end, 5, 1, 1)
end

function PandoraMgr:OpenApp(AppId)
    _G.FLOG_INFO("PandoraMgr:OpenApp %s", AppId)
    if not self.IsGameSDKOpened then
        _G.FLOG_WARNING("PandoraMgr:OpenApp, Gamelet sdk is not open!")
        return
    end
    --local IsShow = true
    -- if AppId == self.FaceSlapAppId and self.HasOpenedFaceSlapApp then
    --     IsShow = false
    -- end

    --if IsShow then
        if not self.TimerID then
            self.CheckTime = 0
            self.CurOpenedAppId = AppId
            self.TimerID = self:RegisterTimer(self.ShowMainPanel, 0, 0.3, 0)
        else
            _G.FLOG_WARNING("PandoraMgr:OpenApp, already has a app is opening!")
        end
    --end
end

function PandoraMgr:ShowMainPanel()
    self.CheckTime = self.CheckTime + 1
	if self.CheckTime >= self.MaxCheckTime then
		_G.FLOG_WARNING("PandoraMgr:ShowMainPanel, timeout!")
		self:CloseMainPanel(self.CurOpenedAppId)
		return
	end

    if self:IsActivityReady(self.CurOpenedAppId) then
        self:ShowPanelView(UIViewID.PandoraMainPanelView, { AppId = self.CurOpenedAppId, OpenArgs = "" })
        --拍脸当次登录期间只打开一次
        if self.CurOpenedAppId == self.FaceSlapAppId then
            self.HasOpenedFaceSlapApp = true
            -- local SaveTime = TimeUtil.GetServerTime()
            -- local SaveValue = string.format("%d", SaveTime)
            -- _G.UE.USaveMgr.SetString(SaveKey.FaceSlapActivityOpenStatus, SaveValue, true)
            --self:OpenAnotherPandoraApp("6153", "")
        end
		self:CloseTimer()
    end
end

function PandoraMgr:IsActivityReady(AppId)
    local IsAppReady = _G.UE.UGameletMgr.Get():IsAppReady(AppId)
    _G.FLOG_INFO("PandoraMgr:IsActivityReady, AppId:%s, IsAppReady:%s", AppId, tostring(IsAppReady))
	if nil ~= IsAppReady and IsAppReady == true then
        return true
	end
    return false
end

function PandoraMgr:GetActivityRedDotStatus(AppId)
    if nil ~= self.RedDotList[AppId] then
        return self.RedDotList[AppId]
    end
    return false
end

function PandoraMgr:SetActivityRedDotStatus(AppId, Status)
    if nil ~= self.RedDotList[AppId] then
        self.RedDotList[AppId] = Status
    end
end

function PandoraMgr:IsActivityNeedToSinkToBottom(AppId)
    if nil ~= self.SinkToBottomActivityList[AppId] and self.SinkToBottomActivityList[AppId] == true then
        return true
    end
    return false
end

function PandoraMgr:OpenAnotherPandoraApp(TargetAppId, OpenArgs)
    if self:IsActivityReady(TargetAppId) then
        -- self:CloseApp(self.CurOpenedAppId)
        -- local ViewID = UIViewID.PandoraMainPanelView
        -- if UIViewMgr:IsViewVisible(ViewID) then
        --     ViewID = UIViewID.PandoraActivityPanelView
        -- end

        local ViewID = UIViewID.PandoraActivityPanelView
        self.AnotherAppId = TargetAppId
        self.CurOpenedAppId = TargetAppId
        self:ShowPanelView(ViewID, { AppId = TargetAppId, OpenArgs = OpenArgs })
    end
end

function PandoraMgr:ShowPanelView(ViewID, Params)
    _G.FLOG_INFO("PandoraMgr:ShowPanelView, ViewID:%s, Params:%s", ViewID, table_to_string(Params))
    UIViewMgr:ShowView(ViewID, Params)
end

function PandoraMgr:CloseMainPanel(AppId)
    _G.EventMgr:SendEvent(EventID.PandoraActivityClosed, { AppId = AppId })
    -- if AppId == "7078" then
    --     _G.FLOG_WARNING("PandoraMgr:CloseMainPanel, AppId is 7078, do not close main panel!")
    --     return
    -- end
    _G.FLOG_INFO("PandoraMgr:CloseMainPanel, AppId:%s, AnotherAppId:%s", AppId, self.AnotherAppId)
    if self.AnotherAppId == AppId then
        self.AnotherAppId = ""
        UIViewMgr:HideView(UIViewID.PandoraActivityPanelView)
    else
        self:CloseTimer()
        UIViewMgr:HideView(UIViewID.PandoraMainPanelView)
    end
    -- if UIViewMgr:IsViewVisible(UIViewID.PandoraMainPanelView) then
    --     UIViewMgr:HideView(UIViewID.PandoraMainPanelView)
    -- elseif UIViewMgr:IsViewVisible(UIViewID.PandoraActivityPanelView) then
    --     UIViewMgr:HideView(UIViewID.PandoraActivityPanelView)
    -- end
end

function PandoraMgr:ResetDatas()
    self.HasOpenedFaceSlapApp = false
    self.RedDotList = {}
    self.SinkToBottomActivityList = {}
    self.CurLabelDataArray = ""
    self.CurrentShareContent = ""
    self.CurPayAppID = ""
    self.CurPayAppName = ""
    self.CurPayCoinType = ""
    self.CurrentProductID = ""
    self.OrderToken = ""
    self.CurOpenedAppId = ""
    self.AnotherAppId = ""
    self.AppList = {}
end

function PandoraMgr:CloseTimer()
	if self.TimerID then
		self:UnRegisterTimer(self.TimerID)
		self.TimerID = nil
		self.CheckTime = 0
        self.CurOpenedAppId = ""
	end
end

function PandoraMgr:SetEnableGamelet()
    self.EnableFunction = true
    _G.UE.UGameletMgr.Get():SetEnableGamelet(true)
end

function PandoraMgr:OpenAppWithWidget(InWidget, AppId, OpenArgs)
    self:RefreshADData(true)
    _G.UE.UGameletMgr.Get():OpenApp(InWidget, AppId, OpenArgs)
end

function PandoraMgr:CloseAllApp()
    _G.UE.UGameletMgr.Get():CloseAllApp()
end

function PandoraMgr:CloseApp(AppId)
    _G.UE.UGameletMgr.Get():CloseApp(AppId)
end

function PandoraMgr:CloseGameletSDK()
    if self.IsGameSDKOpened then
        self:CloseTimer()
        _G.UE.UGameletMgr.Get():CloseGameletSDK()
        self.IsGameSDKOpened = false
    end
end

function PandoraMgr:ReturnToLogin()
    self:CloseGameletSDK()
    self:ResetDatas()
end

function PandoraMgr:IsActivityOpenedToday()
    local SaveData = _G.UE.USaveMgr.GetString(SaveKey.FaceSlapActivityOpenStatus, "", true)
    --_G.FLOG_INFO("PandoraMgr:IsActivityOpenedToday, SaveData:%s", SaveData)
    if SaveData == "" then
        return false
    end

    local SaveTime = tonumber(SaveData)
    if SaveTime == 0 then
        return false
    end

    local ServerTime = TimeUtil.GetServerTime()
    local Today = math.ceil(ServerTime / 86400)
    local LastSaveDay = math.ceil(SaveTime / 86400)
    if (Today - LastSaveDay) >= 1 then
        return false
    end

    return true
end

function PandoraMgr:CanOpenFaceSlapApp()
    -- _G.FLOG_INFO("PandoraMgr:CanOpenFaceSlapApp, IsGameSDKOpened:%s, HasOpenedFaceSlapApp:%s",
    --     tostring(self.IsGameSDKOpened), tostring(self.HasOpenedFaceSlapApp))
    if not self.IsGameSDKOpened or self.HasOpenedFaceSlapApp then
        return false
    end

    local Cfg = OperationUtil.GetOperationChannelFuncConfig()
    if nil ~= Cfg and Cfg.IsEnableTapFaceActivity == 0 then
        _G.FLOG_WARNING("PandoraMgr:CanOpenFaceSlapApp, Cfg.IsEnableTapFaceActivity is false!")
        return false
    end

    -- local VisibleViews = UIViewMgr:GetVisibleViewList()
    -- for ViewID, View in pairs(VisibleViews) do
    --     _G.FLOG_INFO("PandoraMgr:CanOpenFaceSlapApp, ViewID:%d, ViewName:%s", ViewID, View:GetBPName())
    -- end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local IsCombatState = ActorUtil.IsCombatState(MajorEntityID)

    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    local IsInMiniGame = _G.GoldSaucerMiniGameMgr:CheckIsInMiniGame()
    local IsPlayingDialogue = _G.InteractiveMgr:IsMajorPlayingDialogue()
    -- _G.FLOG_INFO("PandoraMgr:CanOpenFaceSlapApp, IsCombatState:%s, IsInDungeon:%s, IsInMiniGame:%s, IsPlayingDialogue:%s",
    --     tostring(IsCombatState), tostring(IsInDungeon), tostring(IsInMiniGame), tostring(IsPlayingDialogue))
    if IsCombatState or IsInDungeon or IsInMiniGame or IsPlayingDialogue then
        return false
    end

    return true
end

function PandoraMgr:ShowActivityRedDot(AppId, IsShow)
    local RedDotId = 0
    local OpenState = true
    if AppId == self.AnnouncementAppId then
        RedDotId = self.AnnouncementRedDotID
        local ModuleID = _G.ModuleOpenMgr:CheckOpenStateByName(Main2ndPanelDefine.MenuType.Announcement)
        OpenState = _G.ModuleOpenMgr:CheckOpenState(ModuleID)
    end
    --_G.FLOG_INFO("PandoraMgr:ShowActivityRedDot, AppId:%s, IsShow:%s, RedDotId:%s, OpenState:%s", AppId, tostring(IsShow), RedDotId, tostring(OpenState))
    if RedDotId ~= 0 then
        if OpenState then
            if IsShow then
                _G.RedDotMgr:AddRedDotByID(RedDotId)
            else
                _G.RedDotMgr:DelRedDotByID(RedDotId)
            end
        end
    end

    self.RedDotList[AppId] = IsShow
    --_G.FLOG_INFO("PandoraMgr:ShowActivityRedDot, RedDotList:%s", tostring(self.RedDotList))
    --TODO:另需活动中心接入
    _G.EventMgr:SendEvent(EventID.PandoraShowRedot, { AppId = AppId, bShow = IsShow })
end

function PandoraMgr:GoToSystem(Params)
    local JumpID = tonumber(Params)
    JumpUtil.JumpTo(JumpID)
end

-- 道具列表, 使用","分割每组道具信息，使用"|"分割道具id和道具数量。例如："60100001|18,60100002|7,..."
function PandoraMgr:ShowReceivedItems(ReceivedItems)
    local ItemList = {}
    local ItemsInfo = string.split(ReceivedItems, ",")
    for _, ItemInfo in ipairs(ItemsInfo) do
        local Item = string.split(ItemInfo, "|")
        local ItemID = tonumber(Item[1])
        local ItemCount = tonumber(Item[2])
        table.insert(ItemList, { ResID = ItemID, Num = ItemCount })
    end
    self:ShowPanelView(UIViewID.CommonRewardPanel, { ItemList = ItemList })
end

function PandoraMgr:ShowMailRewardItemTips()
    _G.MsgTipsUtil.ShowTips(_G.LSTR(740023))
end

-- 游戏内分享小程序到QQ或微信好友
function PandoraMgr:ShareMiniApp(Params)
    local MiniAppType = tonumber(Params.miniAppType)
    if MiniAppType == ShareMiniAppType.WeChatRelease or MiniAppType == ShareMiniAppType.WeChatPreview then
        AccountUtil.SendWechatMiniApp(Params.user,
            Params.link,
            Params.thumbPath,
            Params.miniAppId,
            MiniAppType,
            Params.mediaTagName,
            Params.mediaPath,
            Params.gameData)
    elseif MiniAppType == ShareMiniAppType.QQRelease or MiniAppType == ShareMiniAppType.QQPreview then
        AccountUtil.SendQQMiniApp(Params.user,
            Params.link,
            Params.title,
            Params.desc,
            Params.thumbPath,
			Params.miniAppId,
            Params.mediaPath,
            "",
            MiniAppType)
    else
        _G.FLOG_WARNING("PandoraMgr:ShareMiniApp, invalid MiniAppType %d", MiniAppType)
    end
end

-- 游戏内拉起外部小程序（QQ或微信）
function PandoraMgr:LaunchMiniApp(Params)
    if _G.LoginMgr:IsQQLogin() then
        AccountUtil.SendPullUpQQMiniApp(
            Params.miniAppID,
            Params.mediaPath,
            Params.miniAppType
        )
    elseif _G.LoginMgr:IsWeChatLogin() then
        AccountUtil.SendPullUpWechatMiniApp(
            Params.mediaPath,
            Params.miniAppID,
            Params.withShareTicket and tonumber(Params.withShareTicket) or 0,
            Params.miniAppType
        )
    else
        _G.FLOG_WARNING("PandoraMgr:LaunchMiniApp, Channel not support!")
    end
end

-- 分享活动图片
function PandoraMgr:ShareActivityImage(Params)
    if string.isnilorempty(Params.activityID) or string.isnilorempty(Params.shareID) then
        _G.FLOG_WARNING("PandoraMgr:ShareActivityImage, Invalid params!")
        return
    end
    local ActivityID = tonumber(Params.activityID) or 0
    local ShareID = tonumber(Params.shareID) or 0
    _G.ShareMgr:OpenShareActivityUI(ActivityID, ShareID)
end

-- 游戏切换前后台
function PandoraMgr:OnApplicationFocusChanged(IsFocused)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "applicationFocusChanged")
    if IsFocused then
        SendMessage:Add("isFocused", "1")
    else
        SendMessage:Add("isFocused", "0")
    end
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

-- 获取当前角色信息
function PandoraMgr:GetUserInfo(OpenIDs, Source)
    local UserName = MajorUtil.GetMajorName() or ""
    local AvatarUrl = MajorUtil.GetMajorPortrait() or ""
    local Content = string.format("%s#%s", UserName, AvatarUrl)

    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "getUserInfoResult")
    SendMessage:Add("content", Content)
    SendMessage:Add("source", Source)
    _G.UE.UGameletMgr.Get():SendMessageToCurrentOpenedApp(SendMessage)
end

-- 查询当前是否允许潘多拉弹出活动面板
function PandoraMgr:PandoraIsPopPanelAllowed(AppId, AppName, ActivityClassification)
    local IsAllowed = true
    local ActivityType = tonumber(ActivityClassification)
    if ActivityType == PandoraActivityType.FaceSlap then
        IsAllowed = self:CanOpenFaceSlapApp()
    elseif ActivityType == PandoraActivityType.OpsActivity then
        if not _G.UIViewMgr:IsViewVisible(UIViewID.OpsActivityMainPanel) then
            IsAllowed = false
        end
    end

    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "isPopPanelAllowedResult")
    if IsAllowed then
        SendMessage:Add("content", "1")
    else
        SendMessage:Add("content", "0")
    end
    SendMessage:Add("activityClassification", ActivityClassification)
    SendMessage:Add("appId", AppId)
    SendMessage:Add("appName", AppName)
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

-- 通知游戏是否需要将活动沉底
function PandoraMgr:NotifyActivitySinkToBottom(AppId, AppName)
    self.SinkToBottomActivityList[AppId] = true
    _G.EventMgr:SendEvent(EventID.SinkActivityToBottom, { AppId = AppId, bFlag = true })
end



function PandoraMgr:ShowItemDetailTips(ItemID, ScreenPosition)
    ItemTipsUtil.ShowTipsByResID(ItemID, nil, ScreenPosition)
end

-- 根据物品ID/套装ID显示指定预览界面
function PandoraMgr:ShowPreviewPanelByID(ItemID)
    _G.PreviewMgr:OpenPreviewView(ItemID)
end

function PandoraMgr:GetItemIconId(ItemID)
    local ItemData = ItemCfg:FindCfgByKey(ItemID)
    if nil ~= ItemData and nil ~= ItemData.IconID then
        return ItemData.IconID
    end
    return 0
end

function PandoraMgr:GetIconPathFromGame(IconId)
    local Folder = math.floor(IconId / 1000) * 1000
	local IconPath = string.format("Texture2D'/Game/Assets/Icon/ItemIcon/%06d/UI_Icon_%06d.UI_Icon_%06d'", Folder, IconId, IconId)
	_G.FLOG_INFO("PandoraMgr:GetIconPathFromGame, IconId:%d, IconPath:%s", IconId, IconPath)
	return IconPath
end

function PandoraMgr:GetItemIconIdList(Content, ExtendParams)
    local ItemIDList = string.split(Content, ",")
    if #ItemIDList > 0 then
        local IconIdList = {}
        for _, ItemID in ipairs(ItemIDList) do
            local IconID = self:GetItemIconId(tonumber(ItemID))
            if IconID ~= 0 then
                local IconPath = self:GetIconPathFromGame(IconID)
                table.insert(IconIdList, {
                    item = ItemID,
                    path = IconPath,
                })
            end
        end
        if #IconIdList == 0 then
            _G.FLOG_WARNING("PandoraMgr:GetItemIconIdList, IconIdList is empty!")
            return
        end
        local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
        SendMessage:Add("type", "pandoraGetItemIconResult")
        local IconIdListStr = Json.encode(IconIdList)
        SendMessage:Add("content", IconIdListStr)
        SendMessage:Add("extend", ExtendParams)
        _G.UE.UGameletMgr.Get():SendMessageToCurrentOpenedApp(SendMessage)
    else
        _G.FLOG_WARNING("PandoraMgr:GetItemIconIdList, ItemIDList is empty!")
    end
end

-- 通知游戏查询标签数据
function PandoraMgr:GetLabelsData(Contents)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "panameraReceiveLabelsData")

    local LabelDataArray = {}
    for _, Content in ipairs(Contents) do
        local LabelData = {}
        LabelData.name = Content
        local Value = ""
        if Content == "LoginChannel" then
            Value = tostring(_G.LoginMgr:GetChannelID())
        elseif Content == "InstallChannel" then
            Value = tostring(_G.LoginMgr:GetInstallChannel())
        elseif Content == "RoleLevel" then
            Value = tostring(MajorUtil.GetMajorLevel() or 0)
        end
        LabelData.value = Value
        table.insert(LabelDataArray, LabelData)
    end
    self.CurLabelDataArray = Json.encode(LabelDataArray)
    SendMessage:Add("content", self.CurLabelDataArray)
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

function PandoraMgr:RefreshADData(IsForce)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "panameraRefreshADData")
    SendMessage:Add("newLabels", self.CurLabelDataArray)
    if IsForce then
        SendMessage:Add("isForce", "true")
    else
        SendMessage:Add("isForce", "false")
    end
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

-- 国内MSDK分享（V5）发消息给好友 / 分享到空间/朋友圈
function PandoraMgr:MSDKShare(Params)
    local FriendReqInfo = AccountUtil.MakeFriendReqInfo()
	if not FriendReqInfo then
		_G.FLOG_WARNING("PandoraMgr:MSDKShare, MakeFriendReqInfo failed!")
		return
	end

    self.CurrentShareContent = Params.content   -- 传入应用appid作为分享流水号，游戏侧在通知小应用分享结果的时候会回传回来
    local MSDKFriendReqInfo = MSDKDefine.ClassMembers.FriendReqInfo
	FriendReqInfo[MSDKFriendReqInfo.Type] = tonumber(Params.friendReqType)
	FriendReqInfo[MSDKFriendReqInfo.User] = Params.user -- 可以是id或者openid，比如微信指定好友分享时，需要填写指定好友的openid
    FriendReqInfo[MSDKFriendReqInfo.Title] = Params.title
	FriendReqInfo[MSDKFriendReqInfo.Desc] = Params.desc
    FriendReqInfo[MSDKFriendReqInfo.ImagePath] = Params.imagePath
	FriendReqInfo[MSDKFriendReqInfo.ThumbPath] = Params.thumbPath
    FriendReqInfo[MSDKFriendReqInfo.MediaPath] = Params.mediaPath
    FriendReqInfo[MSDKFriendReqInfo.Link] = Params.link
	FriendReqInfo[MSDKFriendReqInfo.ExtraJson] = Params.extraJson

    local ShareChannel = ""
    if _G.LoginMgr:IsWeChatLogin() then
        ShareChannel = MSDKDefine.Channel.WeChat
    elseif _G.LoginMgr:IsQQLogin() then
        ShareChannel = MSDKDefine.Channel.QQ
    else
        _G.FLOG_WARNING("PandoraMgr:MSDKShare, Channel not support!")
    end

    if Params.type == "pandoraSendMessage" then
        AccountUtil.SendMessage(FriendReqInfo, ShareChannel)
    elseif Params.type == "pandoraShare" then
        AccountUtil.Share(FriendReqInfo, ShareChannel)
    end
end

function PandoraMgr:OnProcessMSDKNotify(Notify, NotifyType)
    if self.CurrentShareContent == "" then
        _G.FLOG_INFO("PandoraMgr:OnProcessMSDKNotify, CurrentShareContent is empty!")
        return
    end

    local RetCode = Notify[MSDKDefine.ClassMembers.BaseRet.RetCode]
	local MethodNameID = Notify[MSDKDefine.ClassMembers.BaseRet.MethodNameID]
	local RetMsg = Notify[MSDKDefine.ClassMembers.BaseRet.RetMsg]
	local ThirdCode = Notify[MSDKDefine.ClassMembers.BaseRet.ThirdCode]
	local ThirdMsg = Notify[MSDKDefine.ClassMembers.BaseRet.ThirdMsg]
	local ExtraJson = Notify[MSDKDefine.ClassMembers.BaseRet.ExtraJson]
	_G.FLOG_INFO("PandoraMgr:OnProcessMSDKNotify(%s), MethodNameID: %d, RetCode: %d, RetMsg: %s, ThirdCode: %d, ThirdMsg: %s, ExtraJson: %s",
		NotifyType, MethodNameID, RetCode, RetMsg, ThirdCode, ThirdMsg, ExtraJson)

    if NotifyType == "DeliverMessageNotify" then
        if MethodNameID == MSDKDefine.MethodName.SendMessageToFriend or MethodNameID == MSDKDefine.MethodName.ShareToWall then
            self:SendMSDKShareResult("sendMessageResult", RetCode)
        end
    elseif NotifyType == "QueryFriendNotify" then
        if MethodNameID == MSDKDefine.MethodName.QueryFriend then
            self:SendMSDKShareResult("shareResult", RetCode)
        end
    end
end

function PandoraMgr:SendMSDKShareResult(ResultType, ResultCode)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", ResultType)
    SendMessage:Add("content", self.CurrentShareContent)
    if ResultCode == 0 then
        SendMessage:Add("result", "success")
    else
        SendMessage:Add("result", "fail")
    end
    _G.UE.UGameletMgr.Get():SendMessageToCurrentOpenedApp(SendMessage)
    self.CurrentShareContent = ""
end


function PandoraMgr:OnGameEventMSDKDeliverMessageNotify(Notify)
    self:OnProcessMSDKNotify(Notify, "DeliverMessageNotify")
end

function PandoraMgr:OnGameEventMSDKQueryFriendNotify(Notify)
    self:OnProcessMSDKNotify(Notify, "QueryFriendNotify")
end

function PandoraMgr:OpenUrl(Params)
    if string.isnilorempty(Params.content) then
        _G.FLOG_WARNING("PandoraMgr:OpenUrl, Params.content is empty!")
        return
    end

    local ScreenType = tonumber(Params.adaptation) or 1      -- 1:自动适配, 2:横屏, 3:竖屏
    local BrowserType = tonumber(Params.urlType) or 1        -- 1:游戏内置浏览器, 2:系统浏览器
    _G.AccountUtil.OpenUrl(Params.content, ScreenType, false, true, "", BrowserType == 2)
end

function PandoraMgr:OpenOpsActivity(JsonData)
    if not string.isnilorempty(JsonData.activityID) then
        local ActivityID = tonumber(JsonData.activityID)
        _G.OpsActivityMgr:JumpToActivity(ActivityID)
    else
        _G.FLOG_WARNING("PandoraMgr:OpenOpsActivity, activityID is empty!")
    end
end

function PandoraMgr:IsOpsActivityOpened(JsonData)
    local IsOpened = false
    if not string.isnilorempty(JsonData.activityID) then
        local ActivityID = tonumber(JsonData.activityID)
        IsOpened = _G.OpsActivityMgr:IsOpsActivityOnShelf(ActivityID)
    end
    _G.FLOG_INFO("PandoraMgr:IsOpsActivityOpened, ActivityID: %s, IsOpened: %s", JsonData.activityID, tostring(IsOpened))
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "isOpsActivityOpenedResult")
    SendMessage:Add("appId", JsonData.appId)
    SendMessage:Add("appName", JsonData.appName)
    SendMessage:Add("activityID", JsonData.activityID)
    if IsOpened then
        SendMessage:Add("content", "1")
    else
        SendMessage:Add("content", "0")
    end
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

function PandoraMgr:InvokeMidasPay(Params, View)
    self.CurPayAppID = Params.appId or ""
    self.CurPayAppName = Params.appName or ""
    self.CurPayCoinType = Params.content or ""
    local StallID = Params.stallId or 0
    if StallID == 0 then
        _G.FLOG_WARNING("PandoraMgr:OnMidasPay, StallID is 0, do not pay!")
        return
    end

    PayUtil.BuyCoins(StallID,
	    function(_, BillData) self:OnBillReceived(BillData) end,
	    function(_) self:OnLoginExpired() end,
	    function(_, PayReturnData) self:OnPayFinished(PayReturnData) end,
	    function(_, GoodsData) self:OnGoodsReceived(GoodsData) end,
	    View)
	self.CurrentProductID = PayUtil.GetProductID(StallID)
end

function PandoraMgr:OnBillReceived(BillData)
	if BillData == nil then
		_G.FLOG_ERROR("PandoraMgr:OnBillReceived, Cannot get pay bill data")
        self:OnMidasPayCallBack(-1, "fail", "Cannot get pay bill data!")
		return
	end

    if string.isnilorempty(BillData.Token) then
		_G.FLOG_ERROR("PandoraMgr:OnBillReceived, Pay token is empty")
	else
		self.OrderToken = BillData.Token
	end

	if BillData.URL == "" then
        self:OnMidasPayCallBack(-1, "fail", "Bill url is empty!")
		_G.FLOG_ERROR("PandoraMgr:OnBillReceived, Pay bill is empty")
	end
end

function PandoraMgr:OnLoginExpired()
    self:OnMidasPayCallBack(-1, "fail", "Pay login expired!")
	_G.FLOG_ERROR("PandoraMgr:OnBillReceived, Login expired!")
end

function PandoraMgr:OnPayFinished(PayReturnData)
	local IsPaySuccess = true
	if PayReturnData == nil then
		_G.FLOG_ERROR("PandoraMgr:OnPayFinished, Cannot get pay return data")
		IsPaySuccess = false
	else
		if PayReturnData.ResultCode == 0 then
			_G.FLOG_INFO("PandoraMgr:OnPayFinished, Pay succeeded.")
			--self.CurrentProductID = ""
		else
			IsPaySuccess = false
		end
	end
    _G.RechargingMgr:SendPayResultToServer(self.CurrentProductID, IsPaySuccess, self.OrderToken)
end

function PandoraMgr:OnGoodsReceived(GoodsData)
    self:OnMidasPayCallBack(0, "success", "");
end

function PandoraMgr:OnMidasPayCallBack(RetCode, Result, ResultMsg)
    _G.FLOG_INFO("PandoraMgr:OnMidasPayCallBack, RetCode: %d, Result: %s, ResultMsg: %s, CurrentProductID: %s",
        RetCode, Result, ResultMsg, self.CurrentProductID)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "midasPayCallback")
    SendMessage:Add("content", self.CurPayCoinType)
    SendMessage:Add("appId", self.CurPayAppID)
    SendMessage:Add("appName", self.CurPayAppName)
    SendMessage:Add("result", Result)
    SendMessage:Add("resultCode", tostring(RetCode))
    SendMessage:Add("resultMessage", ResultMsg)
    _G.UE.UGameletMgr.Get():SendMessageToCurrentOpenedApp(SendMessage)
    self.CurrentProductID = ""
    self.OrderToken = ""
end

function PandoraMgr:NotifyActivityShow(AppId, ActivityID)
    _G.FLOG_INFO("PandoraMgr:NotifyActivityShow, AppId: %d, ActivityID: %s", AppId, ActivityID)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "notifyActivityShow")
    SendMessage:Add("appId", AppId)
    SendMessage:Add("activityID", ActivityID)
    SendMessage:Add("appName", self.AppList[AppId] or "")
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

function PandoraMgr:NotifyActivityClose(AppId, ActivityID)
    _G.FLOG_INFO("PandoraMgr:NotifyActivityClose, AppId: %d, ActivityID: %s", AppId, ActivityID)
    local SendMessage = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
    SendMessage:Add("type", "notifyActivityClose")
    SendMessage:Add("appId", AppId)
    SendMessage:Add("activityID", ActivityID)
    SendMessage:Add("appName", self.AppList[AppId] or "")
    _G.UE.UGameletMgr.Get():SendMessageToApp("", SendMessage)
end

function PandoraMgr:OnRecievedPandoraMsg(Msg)
    local JsonData = Json.decode(Msg)
    if nil ~= JsonData and nil ~= JsonData.type then
        if JsonData.type == "pandoraShowEntrance" then
            if not string.isnilorempty(JsonData.appId) then
                self.AppList[JsonData.appId] = JsonData.appName or ""
            end
        elseif JsonData.type == "pandoraShowItemTips" then
            if nil ~= JsonData.itemId and nil ~= JsonData.xPos and nil ~= JsonData.yPos then
                self:ShowItemDetailTips(tonumber(JsonData.itemId), _G.UE.FVector2D(JsonData.xPos, JsonData.yPos))
            end
        elseif JsonData.type == "pandoraShowPreviewPage" then
            if nil ~= JsonData.itemId then
                self:ShowPreviewPanelByID(tonumber(JsonData.itemId))
            end
        elseif JsonData.type == "pandoraGoSystem" then
            if not string.isnilorempty(JsonData.content) then
                self:GoToSystem(JsonData.content)
                --self:OpenOpsActivity({ activityID = "24120901" })
            end
        elseif JsonData.type == "pandoraGoPandora" then
            if not string.isnilorempty(JsonData.extendParams) then
                _G.EventMgr:SendEvent(EventID.OpenAnotherOpsActivity, { ActivityID = JsonData.extendParams })
            else
                if nil ~= JsonData.targetAppId and nil ~= JsonData.targetAppPage and nil ~= JsonData.jumpParams then
                    local OpenArgs = { appPage = JsonData.targetAppPage, jumpParams = JsonData.jumpParams }
                    local OpenArgsStr = Json.encode(OpenArgs)
                    self:OpenAnotherPandoraApp(JsonData.targetAppId, OpenArgsStr)
                end
            end
        elseif JsonData.type == "pandoraGetItemIcon" then
            if not string.isnilorempty(JsonData.content) then
                self:GetItemIconIdList(JsonData.content, JsonData.extend)
            end
        elseif JsonData.type == "pandoraOpenWGLaunchMiniApp" then
            self:LaunchMiniApp(JsonData)
        elseif JsonData.type == "pandoraShareMiniApp" then
            self:ShareMiniApp(JsonData)
        elseif JsonData.type == "pandoraShareActivityImage" then
            self:ShareActivityImage(JsonData)
        elseif JsonData.type == "panameraGetLabelsData" then
            if nil ~= JsonData.content then
                self:GetLabelsData(JsonData.content)
            end
        elseif JsonData.type == "pandoraSendMessage" or JsonData.type == "pandoraShare" then
            self:MSDKShare(JsonData)
        elseif JsonData.type == "pandoraOpenUrl" then
            self:OpenUrl(JsonData)
        elseif JsonData.type == "pandoraMidasPay" then
            _G.EventMgr:SendEvent(EventID.PandoraPayment, JsonData)
        elseif JsonData.type == "pandoraIsOpsActivityOpened" then
            self:IsOpsActivityOpened(JsonData)
        elseif JsonData.type == "pandoraOpenOpsActivity" then
            self:OpenOpsActivity(JsonData)
        elseif JsonData.type == "pandoraNotifyAppClose" then
            self:CloseMainPanel(JsonData.appId)
        elseif JsonData.type == "pandoraShowRedpoint" then
            local IsShow = false
            if nil ~= JsonData.content and JsonData.content == "1" then
                IsShow = true
            end
            self:ShowActivityRedDot(JsonData.appId, IsShow)
        elseif JsonData.type == "pandoraShowReceivedItem" then
            if not string.isnilorempty(JsonData.content) then
                self:ShowReceivedItems(JsonData.content)
            end
        elseif JsonData.type == "pandoraGetUserInfo" then
            self:GetUserInfo("", JsonData.source)
        elseif JsonData.type == "pandoraIsPopPanelAllowed" then
            self:PandoraIsPopPanelAllowed(JsonData.appId, JsonData.appName, JsonData.activityClassification)
        elseif JsonData.type == "pandoraNotifySinkToBottom" then
            self:NotifyActivitySinkToBottom(JsonData.appId, JsonData.appName)
        end
    end
end

return PandoraMgr
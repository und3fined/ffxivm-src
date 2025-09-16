local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local JumpUtil = require("Utils/JumpUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local Json = require("Core/Json")
local AccountUtil = require("Utils/AccountUtil")
local TimeUtil = require("Utils/TimeUtil")
local SaveKey = require("Define/SaveKey")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local Main2ndPanelDefine = require("Game/Main2nd/Main2ndPanelDefine")
local OperationUtil = require("Utils/OperationUtil")

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
    self.TimerID = nil
    self.AnnouncementRedDotID = 17004
    self.AnnouncementAppId = "6153"  --公告
    --self.AnnouncementAppId = "6082"  --测试Demo
	self.FaceSlapAppId = "6280"	--拍脸
	self.HasOpenedFaceSlapApp = false
    self.CurOpenedAppId = ""
    self.MaxCheckTime = 10
    self.IsGameSDKOpened = false
    self.AnotherAppId = "" --被潘多拉活动打开的其他潘多拉活动
    self.RedDotList = {}
    self.SinkToBottomActivityList = {}
end

function PandoraMgr:OnBegin()

end

function PandoraMgr:OnEnd()
    self:ResetActivitStatus()
end

function PandoraMgr:OnShutdown()

end

function PandoraMgr:OnRegisterNetMsg()

end

function PandoraMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.MainPanelShow, self.OnMainPanelShow)
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
    --_G.FLOG_INFO("PandoraMgr:ShowPanelView, ViewID:%s, Params:%s", ViewID, table_to_string(Params))
    UIViewMgr:ShowView(ViewID, Params)
end

function PandoraMgr:CloseMainPanel(AppId)
    _G.EventMgr:SendEvent(EventID.PandoraActivityClosed, { AppId = AppId })
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

function PandoraMgr:ResetActivitStatus()
    self.HasOpenedFaceSlapApp = false
    self.RedDotList = {}
    self.SinkToBottomActivityList = {}
end

function PandoraMgr:CloseTimer()
	if self.TimerID then
		TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
		self.CheckTime = 0
        self.CurOpenedAppId = ""
	end
end

function PandoraMgr:SetEnableGamelet()
    self.EnableFunction = true
    _G.UE.UGameletMgr.Get():SetEnableGamelet(true)
end

function PandoraMgr:InitGamelet(ChannelId, UserId, RoleId, IsTestMode, EnableLog)
    _G.FLOG_INFO("PandoraMgr:InitGamelet, EnableFunction:%s", tostring(self.EnableFunction))
    if not self.EnableFunction then
        _G.UE.UGameletMgr.Get():SetEnableGamelet(false)
        return
    end

    if IsTestMode then
        _G.UE.UGameletMgr.Get():SetIsTestMode(true)
    end
    --if EnableLog then
	    _G.UE.UGameletMgr.Get():SetEnableLog(true)
    --end
	_G.UE.UGameletMgr.Get():SetUserInfo(ChannelId, UserId)

    --_G.UE.UGameletMgr.Get():SetEnableLog(true)
    --_G.UE.UGameletMgr.Get():SetUserInfo(ChannelId, "3903467765502703339")
	_G.UE.UGameletMgr.Get():SetFont("Main_Font", "Font'/Game/UI/Fonts/Main_Font.Main_Font'")
	_G.UE.UGameletMgr.Get():SetFont("Title_Font", "Font'/Game/UI/Fonts/Title_Font.Title_Font'")
	_G.UE.UGameletMgr.Get():SetDefaultFont("Main_Font")
	_G.UE.UGameletMgr.Get():LaunchGameletSDK(tostring(RoleId))
    self.IsGameSDKOpened = true
end

function PandoraMgr:OpenAppWithWidget(InWidget, AppId, OpenArgs)
    _G.UE.UGameletMgr.Get():RefreshADData(true)
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
        _G.UE.UGameletMgr.Get():CloseGameletSDK()
        self.IsGameSDKOpened = false
    end
end

function PandoraMgr:ReturnToLogin()
    self:CloseGameletSDK()
    self:ResetActivitStatus()
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

    local IsInDungeon = _G.PWorldMgr:CurrIsInDungeon()
    local IsInMiniGame = _G.GoldSaucerMiniGameMgr:CheckIsInMiniGame()
    local IsSquencePlaying = _G.StoryMgr:SequenceIsPlaying()
    -- _G.FLOG_INFO("PandoraMgr:CanOpenFaceSlapApp, IsInDungeon:%s, IsInMiniGame:%s, IsSquencePlaying:%s",
    --     tostring(IsInDungeon), tostring(IsInMiniGame), tostring(IsSquencePlaying))
    if IsInDungeon or IsInMiniGame or IsSquencePlaying then
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

-- 通知游戏打开小程序
function PandoraMgr:PandoraShareMiniApp(Params)
    local MiniAppInfo = Json.decode(Params)
    local MiniAppType = tonumber(MiniAppInfo.miniAppType)
    if MiniAppType == ShareMiniAppType.WeChatRelease or MiniAppType == ShareMiniAppType.WeChatPreview then
        AccountUtil.SendWechatMiniApp(MiniAppInfo.user,
            MiniAppInfo.link,
            MiniAppInfo.thumbPath,
            MiniAppInfo.miniAppId,
            MiniAppType,
            "MSG_INVITE",
            MiniAppInfo.mediaPath,
            "")
    elseif MiniAppType == ShareMiniAppType.QQRelease or MiniAppType == ShareMiniAppType.QQPreview then
        AccountUtil.SendQQMiniApp(MiniAppInfo.user,
            MiniAppInfo.link,
            MiniAppInfo.title,
            MiniAppInfo.desc,
            MiniAppInfo.thumbPath,
			MiniAppInfo.miniAppId,
            MiniAppInfo.mediaPath,
            "",
            MiniAppType)
    else
        _G.FLOG_WARNING("PandoraMgr:PandoraShareMiniApp, invalid MiniAppType %d", MiniAppType)
    end
end

-- 获取当前角色信息
function PandoraMgr:GetUserInfo(OpenIDs, Source)
    local UserName = MajorUtil.GetMajorName() or ""
    local AvatarUrl = MajorUtil.GetMajorPortrait() or ""
    local Content = string.format("%s#%s", UserName, AvatarUrl)
    _G.UE.UGameletMgr.Get():GetUserInfoCallback(Content, Source)
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
    _G.UE.UGameletMgr.Get():IsPopPanelAllowedResult(AppId, AppName, ActivityClassification, IsAllowed)
end

-- 通知游戏是否需要将活动沉底
function PandoraMgr:NotifyActivitySinkToBottom(AppId, AppName)
    self.SinkToBottomActivityList[AppId] = true
    _G.EventMgr:SendEvent(EventID.SinkActivityToBottom, { AppId = AppId, bFlag = true })
end

function PandoraMgr:OnRecievedPandoraMsg(Msg)
    local JsonData = Json.decode(Msg)
    if nil ~= JsonData and nil ~= JsonData.type then
        if JsonData.type == "pandoraShowItemTips" then
            if nil ~= JsonData.itemId and nil ~= JsonData.xPos and nil ~= JsonData.yPos then
                self:ShowItemDetailTips(tonumber(JsonData.itemId), _G.UE.FVector2D(JsonData.xPos, JsonData.yPos))
            end
        elseif JsonData.type == "pandoraShowPreviewPage" then
            if nil ~= JsonData.itemId then
                self:ShowPreviewPanelByID(tonumber(JsonData.itemId))
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
        elseif JsonData.type == "pandoraIsOpsActivityOpened" then
            self:IsOpsActivityOpened(JsonData)
        elseif JsonData.type == "pandoraOpenOpsActivity" then
            self:OpenOpsActivity(JsonData)
        end
    end
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
        _G.UE.UGameletMgr.Get():SendMessageToApp(SendMessage)
    else
        _G.FLOG_WARNING("PandoraMgr:GetItemIconIdList, ItemIDList is empty!")
    end
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
    _G.UE.UGameletMgr.Get():SendMessageToApp(SendMessage)
end

return PandoraMgr
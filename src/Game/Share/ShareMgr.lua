 --[[
Author: jususchen jususchen@tencent.com
Date: 2025-01-17 11:47:55
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-01-20 10:43:38
FilePath: \Script\Game\Share\ShareMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewID = require("Define/UIViewID")
local LogableMgr = require("Common/LogableMgr")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local ShareDefine = require("Game/Share/ShareDefine")
local PathMgr = require("Path/PathMgr")
local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local MSDKDefine = require("Define/MSDKDefine")
local ShareActivityCfg = require("TableCfg/ShareActivityCfg")
local ShareActivityRewardCfg = require("TableCfg/ShareActivityRewardCfg")
local TimeUtil = require("Utils/TimeUtil")
local PhotoMediaUtil = require("Game/Photo/Util/PhotoMediaUtil")
local DataReportUtil = require("Utils/DataReportUtil")
local AccountUtil = require("Utils/AccountUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SaveKey = require("Define/SaveKey")
local ProtoBuff = require("Network/Protobuff")
local Json = require("Core/Json")
local OperationUtil = require("Utils/OperationUtil")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Profile.PreLogin.CsPreLoginCmd
local IdIpCfgTableName = ProtoRes.IDip.IdIpCfgTableName

---@class ShareMgr : LogableMgr
local ShareMgr = LuaClass(LogableMgr, nil)

function ShareMgr:OnInit()
    self.CrystalSummonQQShareCfg = {
        Prompt = "最终幻想14水晶世界-水晶召唤令",
        Link = "https://ff14m.qq.com/cp/a20250506fmweb/index.html?",
        Title = "水晶召唤令",
        Desc = "冒险者与我绑定，共同探险艾欧泽亚大陆！",
        TumbPath = "https://game.gtimg.cn/images/ff14/act/a20250214call/share.png",
        PreviewIcon = "https://game.gtimg.cn/images/ff14/cp/a20250506fmweb/top-icon.png"
    }

    self.CrystalSummonWeChatShareCfg = {
        AppID = "gh_5249c375c947",
        Link = "pages/index/index?",
        TumbPath = "https://game.gtimg.cn/images/ff14/act/a20250214call/share.png"
    }
    self.RequestUrl = ""
    self.MaxRequestTime = 0.6
    self.TimerInterval = 0.03

    self:SetLogName("ShareMgr")
    self:InitShareInfo()
end

function ShareMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MSDKDeliverMessageNotify, self.OnGameEventMSDKDeliverMessageNotify)
    --self:RegisterGameEvent(EventID.MainPanelShow, self.OnMainPanelShow)
    self:RegisterGameEvent(EventID.PhotoStart, self.OnPhotoStart)
    self:RegisterGameEvent(EventID.OpsActivityMainPanelShowed, self.OnOpsActivityMainPanelShowed)
end

function ShareMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PRELOGIN, SUB_MSG_ID.CS_PRELOGIN_IDIP_CFG_CMD_QUERY, self.OnIDIPCfgRsp)
end

function ShareMgr:InitShareInfo()
    self:SetOpsActivityInfo(0, 0)
    self.ShareImageFileName = ""
    self.bIsShowRoleInfoOption = true
    self.bIsShowQRCodeOption = true
    self.QRCodePath = ""

    self.ElapseTime = 0
    --self:StopCfgRequestTimer()
    self.IsShareActivityCfgFromServerReady = true
    self.IsShareActivityRewardCfgFromServerReady = true
end

function ShareMgr:GetDefaultAppsForActivityImageShare()
    local Apps = {}
    local bEditor = CommonUtil.IsWithEditor()

    if _G.LoginMgr:IsQQLogin() then
        table.insert(Apps, ShareDefine.SharePlatformEnum.QQ)
        table.insert(Apps, ShareDefine.SharePlatformEnum.QQ_ZONE)
        --table.insert(Apps, ShareDefine.SharePlatformEnum.QQ_PINDAO)
    end

    if _G.LoginMgr:IsWeChatLogin() then
        table.insert(Apps, ShareDefine.SharePlatformEnum.WECHAT)
        table.insert(Apps, ShareDefine.SharePlatformEnum.WECHAT_CIRCLE)
    end

    if bEditor or self:IsOverseas() then
        table.insert(Apps, ShareDefine.SharePlatformEnum.FACEBOOK)
    end

    if bEditor or (self:IsOverseas() and CommonUtil.IsAndroidPlatform()) then
        table.insert(Apps, ShareDefine.SharePlatformEnum.TWITTER)
    end

    if bEditor or self:IsOverseas() then
        table.insert(Apps, ShareDefine.SharePlatformEnum.WHATSAPP)
    end

    if nil ~= self.ShareID and self.ShareID ~= 0 then
        _G.FLOG_INFO("ShareMgr:GetDefaultAppsForActivityImageShare, ShareID: %d", self.ShareID)
        local Cfg = self:GetShareActivityCfg(self.ShareID)
        if Cfg then
            if Cfg.IsShowQRCodeOption == true or Cfg.IsShowQRCodeOption == false then
                self.bIsShowQRCodeOption = Cfg.IsShowQRCodeOption
            else
                self.bIsShowQRCodeOption = Cfg.IsShowQRCodeOption == 1 and true or false
            end

            if Cfg.IsShowRoleInfoOption == true or Cfg.IsShowRoleInfoOption == false then
                self.bIsShowRoleInfoOption = Cfg.IsShowRoleInfoOption
            else
                self.bIsShowRoleInfoOption = Cfg.IsShowRoleInfoOption == 1 and true or false
            end

            if bEditor or self:IsOverseas() then
                self.QRCodePath = OperationUtil.ShareQRCodePath.Oversea
            end
            if _G.LoginMgr:IsWeChatLogin() then
                self.QRCodePath = OperationUtil.ShareQRCodePath.WeChat
            end
            if _G.LoginMgr:IsQQLogin() then
                self.QRCodePath = OperationUtil.ShareQRCodePath.QQ
            end
            local ShareAppIDList = Cfg.APPID
            if nil ~= ShareAppIDList then
                if type(ShareAppIDList) == "string" then
                    if ShareAppIDList ~= "" then
                        local ShareAppIDs = string.split(ShareAppIDList, ',')
                        if ShareAppIDs and #ShareAppIDs > 0 then
                            for _, AppIDStr in ipairs(ShareAppIDs) do
                                local AppID = tonumber(AppIDStr)
                                if AppID > 0 then
                                    table.insert(Apps, AppID)
                                end
                            end
                        end
                    end
                else
                    for _, AppID in ipairs(ShareAppIDList) do
                        if AppID > 0 then
                            table.insert(Apps, AppID)
                        end
                    end
                end
            end
        end
    end

    --table.insert(Apps, ShareDefine.SharePlatformEnum.SYSTEM)

    return Apps
end

function ShareMgr:OnGameEventMSDKDeliverMessageNotify(Notify)
    local RetCode = Notify[MSDKDefine.ClassMembers.BaseRet.RetCode]
	local MethodNameID = Notify[MSDKDefine.ClassMembers.BaseRet.MethodNameID]
	local RetMsg = Notify[MSDKDefine.ClassMembers.BaseRet.RetMsg]
	local ThirdCode = Notify[MSDKDefine.ClassMembers.BaseRet.ThirdCode]
	local ThirdMsg = Notify[MSDKDefine.ClassMembers.BaseRet.ThirdMsg]
	local ExtraJson = Notify[MSDKDefine.ClassMembers.BaseRet.ExtraJson]
	_G.FLOG_INFO("ShareMgr:OnGameEventMSDKDeliverMessageNotify, MethodNameID: %d, RetCode: %d, RetMsg: %s, ThirdCode: %d, ThirdMsg: %s, ExtraJson: %s, ActivityID: %d",
		MethodNameID, RetCode, RetMsg, ThirdCode, ThirdMsg, ExtraJson, self.ActivityID)
    -- ShareMgr.AfterShare()

    -- if MethodNameID == MSDKDefine.MethodName.SendMessageToFriend or MethodNameID == MSDKDefine.MethodName.ShareToWall then
    --     if RetCode == 0 and self.ActivityID ~= 0 then
    --         EventMgr:SendEvent(EventID.ShareOpsActivitySuccess, { ActivityID = self.ActivityID } )
    --     end
    -- end
end

---@param Content ClsShareExLinkContent
---@param AppsToShare number[] | nil an optinal field
function ShareMgr:ShareExternalLink(Content, AppsToShare)
    ---@class ClsShareExLinkContent
    ---@field Title string
    ---@field Link string
    ---@field Text string | nil
    if Content == nil then
        self:LogErr("can not share nil: %s", debug.traceback())
        return
    end

    if self:GetShareVM() then
        local ItemDatas = self.CreateShareItemDataList( AppsToShare or self:GetDefaultAppsForExternalLinks(), ShareDefine.ShareTypeEnum.EXTERNAL_LINK, Content)
        self:GetShareVM().ExternalLinkShareItemList:UpdateByValues(ItemDatas)
        self:ShowView(UIViewID.ShareExternalLink, nil)
    end
end

---@param Obj ShareObject
function ShareMgr:ShareImage(Obj)
    if not self.IsImageShareObject(Obj) then
        self:LogErr("not a image share object")
       return 
    end

    if not Obj:IsAppToShareInstalled() and Obj:HandleAppNotInstalled() then
        return 
    end

    if not Obj:CanShareImage() then
        self:LogErr("can not share image, failed to pass check")
        return
    end

    local ShareChannel = Obj:GetShareChannel()
    local RealShareChannel = nil
    if nil ~= Obj.GetRealShareChannel then
        RealShareChannel = Obj:GetRealShareChannel()
    end
    _G.FLOG_INFO("ShareMgr:ShareImage, channel: %s", ShareChannel)
    local IsShareWithoutQRCode = false
    if nil ~= RealShareChannel and RealShareChannel == "WeChatCircle" then
        _G.FLOG_INFO("ShareMgr:ShareImage, channel: WeChatCircle")
        IsShareWithoutQRCode = true
    else
        local Cfg = OperationUtil.GetOperationChannelFuncConfig()
        if nil ~= Cfg and Cfg.IsEnableQRCodeForShare == 0 then
            IsShareWithoutQRCode = true
        end
    end

    if IsShareWithoutQRCode then
        _G.EventMgr:SendEvent(_G.EventID.ShareWithoutQRCode)
    end

    Obj:ShareImage()
    DataReportUtil.ReportShareFlowData(nil, ShareChannel, self.ActivityID or 0, self.bIsShowRoleInfoOption and 1 or 2)
end

---@param Obj ShareObject
function ShareMgr:ShareExternalLinkByShareObject(Obj)
    if not self.IsExtearnalLinkShareObject(Obj) then
       self:LogErr("not an external link share object") 
       return
    end

    if not Obj:IsAppToShareInstalled() and Obj:HandleAppNotInstalled() then
        return 
    end

    Obj:ShareExternalLink()
    DataReportUtil.ReportShareFlowData(nil, Obj:GetShareChannel(), self.ActivityID or 0, self.bIsShowRoleInfoOption and 1 or 2)
end

---@param Obj ShareObject
function ShareMgr.IsImageShareObject(Obj)
    return Obj and Obj.ShareType == ShareDefine.ShareTypeEnum.IMAGE
end

---@param Obj ShareObject
function ShareMgr.IsExtearnalLinkShareObject(Obj)
    return Obj and Obj.ShareType == ShareDefine.ShareTypeEnum.EXTERNAL_LINK
end

function ShareMgr:IsOverseas()
    return not (_G.LoginMgr:IsQQLogin() or _G.LoginMgr:IsWeChatLogin())
end

---@return ShareVM | nil
function ShareMgr:GetShareVM()
    return _G.ShareVM
end

---@param ImageName string | nil
---@return string
function ShareMgr.GetImageLocalSharePath()
    --ImageName = ImageName or "share.jpg"
    local Dir = PathMgr.SavedDir()
    if string.sub(Dir, -1) == '/' then
       Dir =  string.sub(Dir, 1, #Dir - 1)
    end

    return Dir .. '/' .. ShareMgr.ShareImageFileName
end

function ShareMgr:GenShareImageFileName()
	local TmTime = os.date("*t", TimeUtil.GetServerTime())
    self.ShareImageFileName = string.format("FF14MOBILE%04d%02d%02d%02d%02d%02d.jpg",
        TmTime.year, TmTime.month, TmTime.day, TmTime.hour, TmTime.min, TmTime.sec)
end

function ShareMgr:GetShareImageFileName()
     return self.ShareImageFileName
end

---@private
function ShareMgr:ShowView(ViewID, Params)
    _G.UIViewMgr:ShowView(ViewID, Params)
end

---@param Apps table
function ShareMgr.CreateShareItemDataList(Apps, ...)
    local DataList = {}
    for _, App in ipairs(Apps) do
        local O = ShareMgr.NewShareObject(App, ...)
        if O then
            table.insert(DataList, { ShareObject = O })
        end
    end
    
    return DataList
end

function ShareMgr:GetDefaultAppsForExternalLinks()
    local Apps = {}
    if _G.LoginMgr:IsQQLogin() then
        Apps = ShareDefine.EXLINK_QQ_APPS
    elseif _G.LoginMgr:IsWeChatLogin() then
        Apps = ShareDefine.EXLINK_WECHAT_APPS
    else
        Apps = ShareDefine.EXLINK_OVERSEAS_APPS
    end

    return Apps
end

---@return ShareObject | nil
function ShareMgr.NewShareObject(AppEnum, ...)
    local ClsPath = ShareDefine.GetShareObjectClassPath(AppEnum)
    local OK, Cls, Err
    if ClsPath then
        OK, Cls = pcall(require, ClsPath)
        if not OK then
           Err = Cls
           Cls = nil 
        end
    end
    
    if Cls == nil or Err then
        _G.FLOG_ERROR("failed to create share object for %s %s: %s", AppEnum, ClsPath, Err)
        return nil
    end

    return Cls.New(...)
end

function ShareMgr:UpdateActivityShareRewards(Cfg, RewardContainerView)
    local Rewards = {}
	for _, RewardID in ipairs(Cfg.Reward or {}) do
		local RewardCfg = self:GetShareActivityRewardCfg(RewardID)
		if RewardCfg then
			table.insert(Rewards, {
				Icon = RewardCfg.Icon,
				bSyncIcon = true,
				Num = RewardCfg.ItemCount or 0,
				})
		else
			_G.FLOG_ERROR("missing reward id for share activity %s: %s", Cfg.ActivityID, RewardID)
		end
	end

    local UIUtil = require("Utils/UIUtil")
	self:GetShareVM().ShareActivityRewardVMList:UpdateByValues(Rewards)
	UIUtil.SetIsVisible(RewardContainerView, #Rewards > 0)

    local ChildrenCopy = RewardContainerView:GetAllChildren()
    RewardContainerView:ClearChildren()
    -- RewardContainerView:SetVolatility(false)
    for i = 1, ChildrenCopy:Length() do
        local Child = ChildrenCopy:Get(i)
        if Child then
            Child:RemoveFromParent()
        end
    end
    if #Rewards > 0 then
        local WidgetPoolMgr = require("UI/WidgetPoolMgr")
        for _, Data in ipairs(self:GetShareVM().ShareActivityRewardVMList:GetItems()) do
            local Params = {Data=Data}
            local RewardView = WidgetPoolMgr:CreateWidgetSyncByViewID(_G.UIViewID.ShareReward, true, true, Params)
            RewardContainerView:AddChild(RewardView)
        end
    end
    -- RewardContainerView:SetVolatility(true)
    RewardContainerView:InvalidateLayoutAndVolatility()
end

---@param ShareObj ShareObject
function ShareMgr.ShareLinkByMSDK(ShareObj)
    if ShareObj.ShareType ~= ShareDefine.ShareTypeEnum.EXTERNAL_LINK then
        _G.FLOG_ERROR("ShareMgr:ShareLinkByMSDK: invalid share type %s", ShareObj.ShareType)
        return
    end

    local Title = ShareObj.Content.Title
    local Link = ShareObj.Content.Link
    local Desc = ""
    if Title == nil or Title == "" then
        _G.FLOG_ERROR("content must specify `Title` field")
        return
    end

    ShareObj:BeforeShare()
    _G.FLOG_INFO("share with channel: %s, title: %s, link: %s", ShareObj:GetShareChannel(), Title, Link)
    ShareMgr.AfterShare()
    _G.AccountUtil.SendLink(ShareObj:GetShareChannel(), nil, false, Title, Desc, Link, ShareObj.Content.ThumbPath, "")
end

---@param ShareObj ShareObject
function ShareMgr.ShareImageToFriendByMSDK(ShareObj)
    if ShareObj.ShareType ~= ShareDefine.ShareTypeEnum.IMAGE then
        _G.FLOG_ERROR("ShareMgr.ShareImageToFriendByMSDK invalid share type: %s", ShareObj.ShareType)
        return
    end

    ShareObj:BeforeShare()
    _G.FLOG_INFO("channel: %s content: %s", ShareObj:GetShareChannel(), ShareObj.Content)

    --local ImagePath = ShareObj.Content.ImagePath
    local ImagePath = ShareMgr.GetImageLocalSharePath()
    local ThumbPath = ShareObj.Content.ThumbPath
    local User = ShareObj:GetMSDKUserField()
    local IsSOpenID = ShareObj:IsUsingSOpenID() == true

    _G.FLOG_INFO(string.sformat("ShareImageToFriendByMSDK img: %s, user: %s, sopen?: %s, thumb: %s", ImagePath, User, IsSOpenID, ThumbPath))
    ShareMgr.AfterShare()
    _G.AccountUtil.SendIMG(ShareObj:GetShareChannel(), User, IsSOpenID, ImagePath, ThumbPath)
end

function ShareMgr.AfterShare()
    if ShareMgr.ActivityID ~= 0 then
        _G.FLOG_INFO("ShareMgr:AfterShare, ActivityID: %d", ShareMgr.ActivityID)
        _G.EventMgr:SendEvent(_G.EventID.ShareOpsActivitySuccess, { ActivityID = ShareMgr.ActivityID } )
    end
end

function ShareMgr:IsShowQRCodeOption()
    return self.bIsShowQRCodeOption
end

function ShareMgr:IsShowRoleInfoOption()
    return self.bIsShowRoleInfoOption
end

function ShareMgr:GetQRCodePath()
    return self.QRCodePath
end

-- 分享"水晶召唤令"，非通用接口
function ShareMgr:ShareCrystalSummon(SCode, UserOpenID)
    if _G.LoginMgr:IsQQLogin() then
        local DynamicData = {}
        DynamicData.prompt = LSTR(1630003)
        DynamicData.title = LSTR(1630001)
        DynamicData.desc = LSTR(1630002)
        DynamicData.preview = self.CrystalSummonQQShareCfg.PreviewIcon
        DynamicData.jumpUrl = self.CrystalSummonQQShareCfg.Link..SCode
        local DynamicParams = Json.encode(DynamicData)
        --FLOG_INFO(string.format("ShareMgr:ShareCrystalSummon, DynamicParams:%s", DynamicParams))

        self:GetArkInfo(nil, DynamicParams)

        -- local Path = self.CrystalSummonQQShareCfg.Link..Params
        -- AccountUtil.SendLink(MSDKDefine.Channel.QQ,
        --     UserOpenID or "",
        --     false,
        --     self.CrystalSummonQQShareCfg.Title,
        --     self.CrystalSummonQQShareCfg.Desc,
        --     Path,
        --     self.CrystalSummonQQShareCfg.TumbPath,
		-- 	"")
    elseif _G.LoginMgr:IsWeChatLogin() then
        local Path = self.CrystalSummonWeChatShareCfg.Link..SCode
        AccountUtil.SendWechatMiniApp(UserOpenID or "",
            Path,
            self.CrystalSummonWeChatShareCfg.TumbPath,
            self.CrystalSummonWeChatShareCfg.AppID,
            0,
            "MSG_INVITE",
            Path,
            "")
    end
end

function ShareMgr:OnMainPanelShow(Params)
    if nil ~= Params and nil ~= Params.bShow and Params.bShow == true then
        self:RequestCfgDataFromServer()
    end
end

function ShareMgr:OnPhotoStart()
    self:RequestCfgDataFromServer()
end

function ShareMgr:OnOpsActivityMainPanelShowed()
    self:RequestCfgDataFromServer()
end

function ShareMgr:OpenShareActivityUI(ActivityID, ShareID)
    self:SetOpsActivityInfo(ActivityID, ShareID)
    _G.UIViewMgr:ShowView(UIViewID.ShareMain, { ShareID = ShareID })
end

function ShareMgr:SetOpsActivityInfo(ActivityID, ShareID)
    self.ActivityID = ActivityID
    self.ShareID = ShareID
end

function ShareMgr:OpenPhotoShare(Tex, Width, Height, IsPhoto)
    self.ShareID = 1
    _G.UIViewMgr:ShowView(_G.UIViewID.ShareMain, { ShareID = self.ShareID, Tex = Tex, W = Width, H = Height, bPhoto = IsPhoto})
end

---@type 打开游戏屏幕分享
function ShareMgr:OpenScreenShotShare(Callback)
    PhotoMediaUtil.CapScreen(function (W, H, AR) 
        local Tex = _G.UE.UMediaUtil.CovertColorsToTexture2D("", AR, W, H)
        _G.UE.UUIUtil.SetTextureHighQuality(Tex,_G.UE.TextureCompressionSettings.TC_EditorIcon)
        -- print('testinfo set succ')
        _G.ShareMgr:OpenPhotoShare(Tex, W, H, true)
        -- _G.UE.USettingUtil.ExeCommand("r.ScreenPercentage", 100)
		_G.ObjectMgr:CollectGarbage(false)
        Callback()
	end, true)
end

function ShareMgr:StartCfgRequestTimer(Callback)
    if self.CfgRequestTimerID == nil then
        self.CfgRequestTimerID = self:RegisterTimer(function()
            if (self.IsShareActivityCfgFromServerReady and self.IsShareActivityRewardCfgFromServerReady) or
                self.ElapseTime >= self.MaxRequestTime then
                self:StopCfgRequestTimer()
                Callback()
            end
            self.ElapseTime = self.ElapseTime + self.TimerInterval
        end, 0, 0.05, 0)
    end
end

function ShareMgr:StopCfgRequestTimer()
    if self.CfgRequestTimerID ~= nil then
        _G.TimerMgr:CancelTimer(self.CfgRequestTimerID)
        self.CfgRequestTimerID = nil
    end
    self.ElapseTime = 0
end

function ShareMgr:RequestCfgDataFromServer()
    self.IsShareActivityCfgFromServerReady = false
    local Version = _G.UE.USaveMgr.GetInt(SaveKey.ShareActivityConfigVersion, 0, false)
    self:SendRequest(IdIpCfgTableName.IdIpCfgTableShare, Version)

    -- local Token = _G.LoginMgr:GetToken()
    -- local SendData = { Version = Version, Token = Token }
    -- if _G.HttpMgr:Get(self.RequestUrl, Token, SendData, self.OnShareActivityCfgRsp, self) then
	-- 	_G.FLOG_INFO("ShareMgr:RequestCfgDataFromServer, IdIpCfgTableShare success!")
	-- end

    self.IsShareActivityRewardCfgFromServerReady = false
    Version = _G.UE.USaveMgr.GetInt(SaveKey.ShareActivityRewardConfigVersion, 0, false)
    self:SendRequest(IdIpCfgTableName.IdIpCfgTableShareReward, Version)
end

function ShareMgr:SendRequest(TableNameType, Version)
    local MsgID = CS_CMD.CS_CMD_PRELOGIN
    local SubMsgID = SUB_MSG_ID.CS_PRELOGIN_IDIP_CFG_CMD_QUERY
	local QueryCfg = {
        TableName = TableNameType,
        Version = (Version + 1)
    }
	local MsgBody = { }
    MsgBody.Cmd = SubMsgID
    MsgBody.QueryCfg = QueryCfg
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function ShareMgr:OnIDIPCfgRsp(MsgBody)
    if nil == MsgBody or nil == MsgBody.QueryCfg or nil == MsgBody.QueryCfg.Contents or nil == MsgBody.QueryCfg.TableName then
        return
    end
    if MsgBody.QueryCfg.TableName == IdIpCfgTableName.IdIpCfgTableShare then
        self:OnShareActivityCfgRsp(MsgBody)
    elseif MsgBody.QueryCfg.TableName == IdIpCfgTableName.IdIpCfgTableShareReward then
        self:OnShareActivityRewardCfgRsp(MsgBody)
    end
end

function ShareMgr:OnShareActivityCfgRsp(MsgBody)
    local CfgData = MsgBody.QueryCfg.Contents
    if CfgData and #CfgData > 0 then
        local SaveData = {}
        for _, Data in pairs(CfgData) do
            local CfgFromServer = ProtoBuff:Decode("resproto.idip.ShareInfoCfg", Data) or {}
            if nil ~= CfgFromServer.ID then
                SaveData[tostring(CfgFromServer.ID)] = CfgFromServer
            end
        end
        local SaveDataStr = Json.encode(SaveData)
        _G.UE.USaveMgr.SetString(SaveKey.ShareActivityConfig, SaveDataStr, false)
    else
        _G.UE.USaveMgr.SetString(SaveKey.ShareActivityConfig, "", false)
    end

    local Version = MsgBody.QueryCfg.Version
    _G.UE.USaveMgr.SetInt(SaveKey.ShareActivityConfigVersion, Version, false)
    self.IsShareActivityCfgFromServerReady = true

    -- self.SavePath = string.format("%s/GameData/ShareTmp1_%s.txt", _G.FDIR_SAVED_RELATIVE(), Version)
    -- CommonUtil.SaveJsonFile(self.SavePath, self.SaveData)
end

function ShareMgr:OnShareActivityRewardCfgRsp(MsgBody)
    local CfgData = MsgBody.QueryCfg.Contents
    if CfgData and #CfgData > 0 then
        local SaveData = {}
        for _, Data in pairs(CfgData) do
            local CfgFromServer = ProtoBuff:Decode("resproto.idip.ShareRewardCfg", Data) or {}
            if nil ~= CfgFromServer.ID then
                SaveData[tostring(CfgFromServer.ID)] = CfgFromServer
            end
        end
        local SaveDataStr = Json.encode(SaveData)
        _G.UE.USaveMgr.SetString(SaveKey.ShareActivityRewardConfig, SaveDataStr, false)
    else
        _G.UE.USaveMgr.SetString(SaveKey.ShareActivityRewardConfig, "", false)
    end

    local Version = MsgBody.QueryCfg.Version
    _G.UE.USaveMgr.SetInt(SaveKey.ShareActivityRewardConfigVersion, Version, false)

    self.IsShareActivityRewardCfgFromServerReady = true
end

function ShareMgr:GetShareActivityCfg(ShareID)
    local Config = ShareActivityCfg:FindCfgByKey(ShareID)
    if Config then
        return Config
    end

    -- 表格中查不到就从大管家配置数据中查
    local LocalShareActivityCfg = _G.UE.USaveMgr.GetString(SaveKey.ShareActivityConfig, "", false)
    if not string.isnilorempty(LocalShareActivityCfg) then
        local JsonData = Json.decode(LocalShareActivityCfg)
        if JsonData then
            return JsonData[tostring(ShareID)]
        end
    end

    return nil
end

function ShareMgr:GetShareActivityRewardCfg(RewardID)
    local Config = ShareActivityRewardCfg:FindCfgByKey(RewardID)
    if Config then
        return Config
    end

    -- 表格中查不到就从大管家配置数据中查
    local LocalShareActivityRewardConfig = _G.UE.USaveMgr.GetString(SaveKey.ShareActivityRewardConfig, "", false)
    if not string.isnilorempty(LocalShareActivityRewardConfig) then
        local JsonData = Json.decode(LocalShareActivityRewardConfig)
        if JsonData then
            return JsonData[tostring(RewardID)]
        end
    end

    return nil
end

function ShareMgr:ShareToQQPinDao()
    local Desc = ""
    local Cfg = self:GetShareActivityCfg(self.ShareID)
    if Cfg then
        Desc = Cfg.PinDaoContent or ""
    end
    --TODO:需要将图片上传到服务器然后再获取URL
    local PicUrl = ""

    local EncodePicUrl = CommonUtil.GetBase64String(PicUrl)
    local EncodeDesc = CommonUtil.GetUrlEncodeStr(Desc)
    local OpenUrl = string.format("%s&pic1=%s&text=%s", OperationUtil.QQPinDaoUrl, EncodePicUrl, EncodeDesc)
    local ExtraJson = {}
    ExtraJson.WEBVIEW_LANDSCAPE_BAR_HIDEABLE = true
    ExtraJson.closeLoadingView = true
    local ExtraJsonStr = Json.encode(ExtraJson)
    _G.FLOG_INFO("ShareMgr:ShareToQQPinDao, OpenUrl: %s, ExtraJsonStr:%s", OpenUrl, ExtraJsonStr)
    _G.AccountUtil.OpenUrl(OpenUrl, 3, true, true, ExtraJsonStr, false)
end


--region QQ Ark分享/微信原生分享
-- QQ Ark分享
function ShareMgr:SendArkFriends(ArkJson)
    -- {"token":"BC47225F1F29F1954C7024BB57788CAB","openid":"493583177","interfaceid":"/trpc.gamecenter.ark_template_proxy.ArkTemplateProxy/GetSignedCommArk",
    -- "interface_param":{"type":1,"scene_id":"c29a0749-384e-4194-9a6d-c776872d1897","static_params":{"area":"1"}}}
    --local StaticParamJsonItems = {}
    --AccountUtil.JsonUtil.AddItem(StaticParamJsonItems, "area", "1")
    --local StaticParamJson = AccountUtil.JsonUtil.ToJson(StaticParamJsonItems)
    --
    --local InterfaceParamJsonItems = {}
    --AccountUtil.JsonUtil.AddItem(InterfaceParamJsonItems, "type", 1)
    --AccountUtil.JsonUtil.AddItem(InterfaceParamJsonItems, "scene_id", "a2734659-b934-4196-b69c-7726ffa89aee")
    --AccountUtil.JsonUtil.AddItem(InterfaceParamJsonItems, "static_params", StaticParamJson)
    --local InterfaceParamJson = AccountUtil.JsonUtil.ToJson(InterfaceParamJsonItems)
    --
    --local ExtraJsonItems = {}
    --AccountUtil.JsonUtil.AddItem(ExtraJsonItems, "token", _G.LoginMgr.Token)
    --AccountUtil.JsonUtil.AddJson(ExtraJsonItems, "openid", _G.LoginMgr.OpenID)
    --AccountUtil.JsonUtil.AddItem(ExtraJsonItems, "interfaceid", "/trpc.gamecenter.ark_template_proxy.ArkTemplateProxy/GetSignedCommArk")
    --AccountUtil.JsonUtil.AddItem(ExtraJsonItems, "interface_param", InterfaceParamJson)
    --local ExtraJson = AccountUtil.JsonUtil.ToJson(ExtraJsonItems)

    _G.FLOG_INFO("[ShareMgr:SendArkFriends] ExtraJsonStr: %s", ArkJson)
    -- 470162:我在艾欧泽亚等你
    -- 470163:勇敢的光之战士，我正在艾欧泽亚冒险，快来加入我吧！
    AccountUtil.SendArk("https://ff14m.qq.com", LSTR(470162), LSTR(470163), ShareDefine.WxNativeSharePic, ArkJson)
end

-- 微信原生分享（好友）
function ShareMgr:SendNativeFriends()
    local ExtraJsonStr = self:GetNativeExtraJson()
    _G.FLOG_INFO("[ShareMgr:SendNativeFriends] ExtraJsonStr: %s", ExtraJsonStr)
    -- 470162:我在艾欧泽亚等你
    -- 470163:勇敢的光之战士，我正在艾欧泽亚冒险，快来加入我吧！
    AccountUtil.SendWxNative(LSTR(470162), LSTR(470163), ShareDefine.WxNativeSharePic, ExtraJsonStr)
end

-- 微信原生分享（朋友圈）
function ShareMgr:SendNativeMoments()
    local ExtraJsonStr = self:GetNativeExtraJson()
    _G.FLOG_INFO("[ShareMgr:SendNativeMoments] ExtraJsonStr: %s", ExtraJsonStr)
    -- 470162:我在艾欧泽亚等你
    -- 470163:勇敢的光之战士，我正在艾欧泽亚冒险，快来加入我吧！
    AccountUtil.ShareWxNative(LSTR(470162), LSTR(470163), ShareDefine.WxNativeSharePic, ExtraJsonStr)
end

-- 获取微信原生分享ExtraJson数据
-- https://game.weixin.qq.com/cgi-bin/h5/static/sharedetail/validator.html
function ShareMgr:GetNativeExtraJson()
    --- game_launch
    local GameLaunch = {}
    GameLaunch.message_ext = ""
    --- share_img_list
    local ShareImageListItems = {}
    ShareImageListItems.img_url = ShareDefine.WxNativeSharePic
    ShareImageListItems.width = 1956
    ShareImageListItems.height = 978
    local ShareImageList = {}
    table.insert(ShareImageList, ShareImageListItems)
    --- user_card
    local UserCard = {}
    -- 470163:勇敢的光之战士，我正在艾欧泽亚冒险，快来加入我吧！
    UserCard.content = LSTR(470163)
    --- share_image_tpl
    local ShareImageTplJsonItems = {}
    ShareImageTplJsonItems.share_img_list = ShareImageList
    ShareImageTplJsonItems.user_card = UserCard
    --- shareData
    local ShareData = {}
    ShareData.appid = MSDKDefine.Config.WechatAppID
    ShareData.game_launch = GameLaunch
    ShareData.share_image_tpl = ShareImageTplJsonItems

    local ExtraJson = {}
    ExtraJson.message_action = ""
    ExtraJson.game_data = ""
    ExtraJson.media_tag_name = "MSG_INVITE"
    ExtraJson.isVideo = 0
    ExtraJson.videoDuration = 0
    ExtraJson.shareData = Json.encode(ShareData)

    local ExtraJsonStr = Json.encode(ExtraJson)
    return ExtraJsonStr
end

--- 获取Ark分享信息
function ShareMgr:TestBackendArkInfo()
    --self:GetArkInfo(string.format('{"%s"}' , FriendOpenID))
    local FriendOpenIDList = {}
    table.insert(FriendOpenIDList, "10371924097176034046")
    self:GetArkInfo(FriendOpenIDList)
end

--- 获取Ark分享信息
---@param FriendOpenID string 后端分享，需要带上好友的 openID
function ShareMgr:QueryBackendArkInfo(FriendOpenID)
    --self:GetArkInfo(string.format('{"%s"}' , FriendOpenID))
    local FriendOpenIDList = {}
    table.insert(FriendOpenIDList, tostring(FriendOpenID))
    self:GetArkInfo(FriendOpenIDList)
end

--- 获取Ark分享信息
---@param FriendOpenIDList string[]|nil 后端分享，需要带上好友的 openIDs
function ShareMgr:GetArkInfo(FriendOpenIDList, DynamicParams, bShowTips)
    local Os = "5"
    if CommonUtil.IsAndroidPlatform() then
        Os = "1"
    elseif CommonUtil.IsIOSPlatform() then
        Os = "2"
    end

    local Url = LoginNewDefine:GetArkUrl(LoginMgr:GetWorldID())
    local OpenID = LoginMgr:GetOpenID()
    local Token = LoginMgr:GetToken()
    local ChannelID = LoginMgr:GetChannelID() or 0
    local StaticParams = string.format('{"area":"%d"}' , ChannelID)

    -- TEST
    if CommonUtil.IsWithEditor() then
        if Token == nil or Token == "root" then
            OpenID = "10093262986685645012"
            Token = "8C7213D7DE9F00B8ACC258538B4A31D4"
            Os = "1"
            ChannelID = 2
        end
    end

    local InterfaceID
    local SendData
    local FriendOpenIDString = ""
    if DynamicParams then
        if FriendOpenIDList then
        -- 后端动态分享
            InterfaceID = "/trpc.gamecenter.ark_template_proxy.ArkTemplateProxy/SendCommArk"
            FriendOpenIDString = table.concat(FriendOpenIDList, ",")
            SendData = { ChannelID = ChannelID, Os = Os, OpenID = OpenID, Token = Token, InterfaceID = InterfaceID, DynamicParams = DynamicParams, FOpenIDs = FriendOpenIDString }
        else
        -- 前端动态分享
            InterfaceID = "/trpc.gamecenter.ark_template_proxy.ArkTemplateProxy/GetSignedCommArk"
            SendData = { ChannelID = ChannelID, Os = Os, OpenID = OpenID, Token = Token, InterfaceID = InterfaceID, DynamicParams = DynamicParams }
        end
        FLOG_INFO(string.format("[ShareMgr:QueryArkInfo] Url:%s, ChannelID:%s, Os:%s, OpenID:%s, Token:%s, InterfaceID:%s, FriendOpenIDList:%s",
                Url, ChannelID, Os, OpenID, Token, InterfaceID, FriendOpenIDString
        ))
    else
        if FriendOpenIDList then
            -- 后端静态分享
            InterfaceID = "/trpc.gamecenter.ark_template_proxy.ArkTemplateProxy/SendCommArk"
            FriendOpenIDString = table.concat(FriendOpenIDList, ",")
            SendData = { ChannelID = ChannelID, Os = Os, OpenID = OpenID, Token = Token, InterfaceID = InterfaceID, StaticParams = StaticParams, FOpenIDs = FriendOpenIDString }
        else
            -- 前端静态分享
            InterfaceID = "/trpc.gamecenter.ark_template_proxy.ArkTemplateProxy/GetSignedCommArk"
            SendData = { ChannelID = ChannelID, Os = Os, OpenID = OpenID, Token = Token, InterfaceID = InterfaceID, StaticParams = StaticParams }
        end

        FLOG_INFO(string.format("[ShareMgr:QueryArkInfo] Url:%s, ChannelID:%s, Os:%s, OpenID:%s, Token:%s, InterfaceID:%s, StaticParams:%s, FriendOpenIDList:%s",
                Url, ChannelID, Os, OpenID, Token, InterfaceID, StaticParams, FriendOpenIDString
        ))
    end

    if _G.HttpMgr:Get(Url, Token, SendData, self.OnArkInfoResponse, self, false) then
        if bShowTips then
            MsgTipsUtil.ShowTips(LSTR(1600033)) --"发送成功"
        end
        FLOG_INFO(string.format('[ShareMgr:QueryArkInfo] request success'))
    end
end

--- 联调测试Demo
--- https://doc.weixin.qq.com/doc/w3_AQMATgawABw7iFx6kHkTYylJw4cz0?scode=AJEAIQdfAAoclSSrGqAEwAlwbdAFw
function ShareMgr:GetDynamicArkInfoDemo(FriendOpenIDList)
    local DynamicData = {}
    -- 最终幻想14水晶世界-水晶召唤令
    DynamicData.prompt = _G.HttpMgr:UrlEncode(LSTR("最终幻想14水晶世界-水晶召唤令"))
    -- 水晶召唤令
    DynamicData.title = _G.HttpMgr:UrlEncode(LSTR("水晶召唤令"))
    -- 冒险者与我绑定，共同探险艾欧泽亚大陆!
    DynamicData.desc = _G.HttpMgr:UrlEncode(LSTR("冒险者与我绑定，共同探险艾欧泽亚大陆!"))
    DynamicData.preview = "https://game.gtimg.cn/images/ff14/cp/a20250506fmweb/top-icon.png"
    DynamicData.jumpUrl = "https://ff14m.qq.com/cp/a20250506fmweb/index.html?sCode=xxxx"

    --local DynamicParams = string.format('{"area":"%d"}' , ChannelID)
    local DynamicParams = Json.encode(DynamicData)
    --print("[ShareMgr:GetDynamicArkInfo] DynamicParams:", DynamicParams)
    self:GetArkInfo(FriendOpenIDList, DynamicParams)
end

--{"Data":"Base64编码后的ArkJson"}
function ShareMgr:OnArkInfoResponse(MsgBody, bSucceeded)
    if not bSucceeded then
        FLOG_WARNING("[ShareMgr:OnArkInfoResponse] Failed : %s", MsgBody)
        return
    end

    FLOG_INFO(string.format("[ShareMgr:OnArkInfoResponse] MsgBody:%s, bSucceeded:%s", MsgBody, tostring(bSucceeded)))
    if string.isnilorempty(MsgBody) then
        FLOG_WARNING("[ShareMgr:OnArkInfoResponse] invalid MsgBody : [%s]", MsgBody)
    end

    --MsgBody = '{"Data":"eyJzaWduZWRfYXJrIjoie1wiYXBwXCI6XCJjb20udGVuY2VudC50dXdlbi5sdWFcIixcInByb21wdFwiOlwi44CQ5rWL6K+V55So44CR5pyA57uI5bm75oOzMTTvvJrmsLTmmbbkuJbnlYzlkIznjqnlpb3lj4vpobXpgoDor7cyXCIsXCJiaXpzcmNcIjpcImZtZ2FtZS5uZXd0dXdlblwiLFwibWV0YVwiOntcIm5ld3NcIjp7XCJhcHBpZFwiOlwiMTExMTMxOTEzMlwiLFwiYXBwaWNvblwiOlwiaHR0cHM6Ly9pbWcuZ2FtZWNlbnRlci5xcS5jb20vZ2NfaW1nL2djL2Zvcm1hbC9jb21tb24vMTExMTMxOTEzMi90aHVtSW1nLnBuZz92PTE3NDIyNjIzODQxMzhcIixcImFwcG5hbWVcIjpcIkZGMTRcIixcInNjZW5ldG9rZW5cIjpcIjVhOGM4ZmE2LWU5MmYtNGFiYS04MjRiLTAyYTdmNDdhZThhOVwiLFwidGl0bGVcIjpcIuaIkeWcqOiJvuasp+azveS6muetieS9oFwiLFwiZGVzY1wiOlwi5YuH5pWi55qE5YWJ5LmL5oiY5aOr77yM5oiR5q2j5Zyo6Im+5qyn5rO95Lqa5YaS6Zmp77yM5b+r5p2l5Yqg5YWl5oiR5ZCn77yBXCIsXCJqdW1wVXJsXCI6XCJodHRwczovL3lvdXhpLmdhbWVjZW50ZXIucXEuY29tL20vYWN0L2Y3NWRmM2Q4ODJiYjAyNDRfMTAyNzAwNDcuaHRtbD9fd3Y9MVx1MDAyNl93d3Y9NFx1MDAyNmFkdGFnPWFpby5xaWFuZHVhbi4xMTExMzE5MTMyLjEwNDM2NlwiLFwicHJldmlld1wiOlwiaHR0cHM6Ly9pbWcuZ2FtZWNlbnRlci5xcS5jb20vb2FzaXMvcGNhZHBpYy84MTQ0NWRiM2FiZTE4NmZhOGNmNzFhOTBmNjZhODNlOC5wbmdcIixcInRhZ1wiOlwiRkYxNFwiLFwidGFnSWNvblwiOlwiaHR0cHM6Ly9pbWcuZ2FtZWNlbnRlci5xcS5jb20vZ2NfaW1nL2djL2Zvcm1hbC9jb21tb24vMTExMTMxOTEzMi90aHVtSW1nLnBuZz92PTE3NDIyNjIzODQxMzhcIixcImV4dHJhcGFyYW1zXCI6e1wiYXJlYVwiOlwiMlwifX19LFwiY29uZmlnXCI6e1wiYXV0b3NpemVcIjowLFwiY29sbGVjdFwiOjEsXCJjdGltZVwiOjE3NDQ5NzgwNjgsXCJmb3J3YXJkXCI6MSxcImhlaWdodFwiOjMxOCxcInJlcGx5XCI6MSxcInJvdW5kXCI6MSxcInRva2VuXCI6XCI4ZWM5YzZkZDJjYThmOGY5OWRmNjRhZjE0Y2NiYmQwY1wiLFwidHlwZVwiOlwibm9ybWFsXCIsXCJ3aWR0aFwiOjUyNn0sXCJ2aWV3XCI6XCJuZXdzXCIsXCJ2ZXJcIjpcIjAuMC4wLjFcIn0ifQ=="}'
    --MsgBody = '{"Data":"eyJzaWduZWRfYXJrIjoie1wiYXBwXCI6XCJjb20udGVuY2VudC50dXdlbi5sdWFcIixcInByb21wdFwiOlwi5pyA57uI5bm75oOzMTTmsLTmmbbkuJbnlYwt5rC05pm25Y+s5ZSk5LukXCIsXCJiaXpzcmNcIjpcImZtZ2FtZS5uZXd0dXdlblwiLFwibWV0YVwiOntcbiAgICBcIm5ld3NcIjp7XG4gICAgICBcInRpdGxlXCI6XCLmsLTmmbblj6zllKTku6RcIixcbiAgICAgIFwiZGVzY1wiOlwi5YaS6Zmp6ICF5LiO5oiR57uR5a6a77yM5YWx5ZCM5o6i6Zmp6Im+5qyn5rO95Lqa5aSn6ZmGIVwiLFxuICAgICAgXCJqdW1wVXJsXCI6XCJodHRwczovL2ZmMTRtLnFxLmNvbS9jcC9hMjAyNTA1MDZmbXdlYi9pbmRleC5odG1sP3NDb2RlPXh4eHhcIixcbiAgICAgIFwicHJldmlld1wiOlwiaHR0cHM6Ly9nYW1lLmd0aW1nLmNuL2ltYWdlcy9mZjE0L2NwL2EyMDI1MDUwNmZtd2ViL3RvcC1pY29uLnBuZ1wiLFxuICAgICAgXCJ0YWdcIjpcIuacgOe7iOW5u+aDszE05rC05pm25LiW55WMXCIsXG4gICAgICBcInRhZ0ljb25cIjpcImh0dHBzOi8vZ2FtZS5ndGltZy5jbi9pbWFnZXMvZmYxNC9jcC9hMjAyNTA1MDZmbXdlYi90b3AtaWNvbi5wbmdcIlxuICAgIH1cbiAgfSxcImNvbmZpZ1wiOntcImF1dG9zaXplXCI6MCxcImNvbGxlY3RcIjoxLFwiY3RpbWVcIjoxNzQ3MjEzMTA5LFwiZm9yd2FyZFwiOjEsXCJoZWlnaHRcIjozMTgsXCJyZXBseVwiOjEsXCJyb3VuZFwiOjEsXCJ0b2tlblwiOlwiM2YyMjUxZTA5ZDA4Y2I2ZmZiYWU0MmNlYWM3ZWE1MTRcIixcInR5cGVcIjpcIm5vcm1hbFwiLFwid2lkdGhcIjo1MjZ9LFwidmlld1wiOlwibmV3c1wiLFwidmVyXCI6XCIwLjAuMC4xXCJ9In0="}'
    local ResponseData = string.isnilorempty(MsgBody) and {} or Json.decode(MsgBody)
    if ResponseData and ResponseData.Data then
        -- 解码Base64编码的ArkJson
        local ArkJsonData = CommonUtil.DecodeBase64String(ResponseData.Data)
        local ArkJson = string.isnilorempty(ArkJsonData) and {} or Json.decode(ArkJsonData)
        FLOG_INFO("[ShareMgr:OnArkInfoResponse] Decoded ArkJson: %s", ArkJson.signed_ark)
        if ArkJson.signed_ark then
            self:SendArkFriends(ArkJson.signed_ark)
        end
    else
        FLOG_WARNING("[ShareMgr:OnArkInfoResponse] Missing or invalid Data field in response")
    end
end

--endregion QQ Ark分享/微信原生分享

return ShareMgr

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local HairUnlockCfg = require("TableCfg/HairUnlockCfg")
local UIViewMgr = require("UI/UIViewMgr")
local HaircutMainPanelView = require("Game/Haircut/View/HaircutMainPanelView")
local DataReportUtil = require("Utils/DataReportUtil")
local SaveKey = require("Define/SaveKey")
local EBGMChannel = _G.UE.EBGMChannel

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Game.Barbershop.Cmd
local LSTR = _G.LSTR
local USaveMgr = _G.UE.USaveMgr
local LoginAvatarMgr = _G.LoginAvatarMgr

---@class HaircutMgr : MgrBase
local HaircutMgr = LuaClass(MgrBase)

-- 理发屋过场动画
HaircutMgr.HaircutMap = HaircutMgr.HaircutMap or
{
	Map1 = 13009,	-- 利姆萨罗敏萨旅馆
	Map2 = 2006,	-- 乌尔达哈旅馆
	Map3 = 11009,   -- 格里达尼亚旅馆
}

HaircutMgr.HaircutInSeq = HaircutMgr.HaircutInSeq or
{
    [HaircutMgr.HaircutMap.Map1] = 21600102,
    [HaircutMgr.HaircutMap.Map2] = 21600103,
    [HaircutMgr.HaircutMap.Map3] = 21600104,
}

HaircutMgr.HaircutOutSeq = HaircutMgr.HaircutOutSeq or
{
    [HaircutMgr.HaircutMap.Map1] = 21600105,
    [HaircutMgr.HaircutMap.Map2] = 21600106,
    [HaircutMgr.HaircutMap.Map3] = 21600107,
}

HaircutMgr.HaircutBreakSeq = HaircutMgr.HaircutBreakSeq or
{
    [HaircutMgr.HaircutMap.Map1] = 21600108,
    [HaircutMgr.HaircutMap.Map2] = 21600109,
    [HaircutMgr.HaircutMap.Map3] = 21600110,
}

-- 理发屋弹窗类型
HaircutMgr.HaircutWinType = HaircutMgr.HaircutWinType or
{
	HairUnlock = 1, -- 解锁发型
	HairNotOwn = 2, -- 发型未获取提示
    UnModify = 3, -- 未修改保存提示
    Save = 4, -- 保存提示
    Exist = 5, -- 退出提示
}


function HaircutMgr:OnInit()

    self.UnLockedList = nil -- 已解锁发型列表
    self.HairLockID = nil -- 请求解锁类型

    self.DefaultAvatarFace = nil -- 理发屋初始捏脸数据

    self.bShowSuitTips = false -- 服装试穿提示

    self.EnterMapID = 0 -- 进理发屋前的MapID
    
    self.bReconnect = false --是否是重连回理发屋

    self.HairCutSubMenuSelect = nil -- 次级菜单

    self.RecordIndex = nil --主菜单
    
    self.HairCutColorIsLeft = true --色板
    
    self.RealLeaveHaircut = true --是否真的离开理发屋 用来记录页签信息
    
    self.EnterTime = nil
end

function HaircutMgr:OnReset()

    self.HairLockID = nil -- 请求解锁类型

    self.DefaultAvatarFace = nil -- 理发屋初始捏脸数据

    self.bShowSuitTips = false -- 服装试穿提示
    self.EnterMapID = 0
    self.bReconnect = false
    self.HairCutSubMenuSelect = nil

    self.RecordIndex = nil
    
    self.RealLeaveHaircut = true
    self.EnterTime = nil
end

function HaircutMgr:OnBegin()
    self.bReconnectedNoLogin = false
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_COIFFURE, self.CheckHairUnlock)
end

function HaircutMgr:OnEnd()
    self.UnLockedList = nil -- 已解锁发型列表
    self.bReconnectedNoLogin = false
end

function HaircutMgr:OnShutdown()
	
end

function HaircutMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_BARBER_SHOP, SUB_MSG_ID.SetFace, self.OnHaircutSet)			--理发完成
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_BARBER_SHOP, SUB_MSG_ID.Update, self.OnHairQuery)			--获取解锁发型
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_BARBER_SHOP, SUB_MSG_ID.UnlockHair, self.OnHairUnlock)	    --解锁发型

end

function HaircutMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected)
    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
end

-- 确保主角被隐藏
function HaircutMgr:OnShowMajor(bShow)
    local Major = MajorUtil.GetMajor()
    if Major then
        Major:SetVisibility(bShow, _G.UE.EHideReason.LoginMap, true)
    end
end

--断线重连相关处理
function HaircutMgr:OnGameEventLoginRes(Params)
    if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDBarberShop) == false then return end
    local bReconnect = Params and Params.bReconnect
    local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
    --处理断线重连 回复到上一操作信息界面
    if PWorldInfo and PWorldInfo.MainPanelUIType == _G.LoginMapType.HairCut then
        LoginAvatarMgr:UpdateVersionName() -- 获取资源版本号
        if bReconnect then
            self:SendMsgHairQuery()
            self.bReconnectedNoLogin = false
    
            self.bReconnect = bReconnect
            -- _G.LoginUIMgr:ReleaseCameraActor()
            UIViewMgr:ShowView(UIViewID.HaircutMainPanel)
            -- _G.LoginUIMgr:CreateCameraActor()
            _G.LoginMapMgr.bFirstEnterHairCutMap = false
            _G.LoginUIMgr:ClearRoleWearSuit()
    
            HaircutMainPanelView:DoLoginRes()
            local MainTile
            MainTile = _G.LoginUIMgr.LoginReConnectMgr:GetValue("HairCutSubMenu")
            self.HairCutSubMenuSelect = _G.LoginUIMgr.LoginReConnectMgr:GetValue("HairCutSubMenuSelect")
            local MainMenuList = LoginAvatarMgr:GetMainMenuList()
            self.RecordIndex = 1
            if MainTile == MainMenuList[LoginAvatarMgr.CustomizeMainMenu.Decorate] then
                self.RecordIndex = 2
            end
            self.HairCutColorIsLeft = _G.LoginUIMgr.LoginReConnectMgr:GetValue("HairCutColorIsLeft")
            CommonUtil.HideJoyStick()
            LoginUIMgr.IsShowPreviewPage = false
        else
            LoginUIMgr:ReturnCurPhaseView(false)
        end
        UIViewMgr:HideView(_G.LoginMapMgr:GetPreViewPageID())
        self:OnShowMajor(true)
        self:OnShowMajor(false)
    end
end

function HaircutMgr:OnMajorCreate()
    if self.bReconnectedNoLogin then
        _G.LoginUIMgr:ReSwitchCamera()

        self.bReconnectedNoLogin = false
    end
end

function HaircutMgr:OnNetworkReconnected()
    self.bReconnectedNoLogin = true
end

-- 上报检测数据
function HaircutMgr:ReportData(bEnter, bFinished)
    local RoleSimple = MajorUtil.GetMajorRoleSimple()
    local PreAvatarFace = table.clone(RoleSimple.Avatar.Face)
    if bEnter then
        -- 进入时上报
        DataReportUtil.ReportHairSalonData("1", nil, nil,
        PreAvatarFace[ProtoCommon.avatar_personal.AvatarPersonalHair], PreAvatarFace[ProtoCommon.avatar_personal.AvatarPersonalHairColor])
        self.EnterTime = TimeUtil.GetServerTimeMS()
    else
        -- 关闭时上报
        local OpTime = 0
        if self.EnterTime ~= nil then
            OpTime = TimeUtil.GetServerTimeMS() - self.EnterTime
        end
        local CurtAvatarFace = LoginAvatarMgr:GetCurAvatarFace()
        DataReportUtil.ReportHairSalonData("2", tostring(OpTime*0.001), tostring(bFinished), 
            PreAvatarFace[ProtoCommon.avatar_personal.AvatarPersonalHair], PreAvatarFace[ProtoCommon.avatar_personal.AvatarPersonalHairColor], 
            CurtAvatarFace[ProtoCommon.avatar_personal.AvatarPersonalHair], CurtAvatarFace[ProtoCommon.avatar_personal.AvatarPersonalHairColor])
    end
end

-- 获取入场动画ID
function HaircutMgr:GetLcutID(MapID, Type)
    if Type ~= nil and MapID ~= nil and Type[MapID] ~= nil then
        return Type[MapID]
    else
        return 0
    end
end

function HaircutMgr:SetEnterMap(MapID)
    self.EnterMapID = MapID
    self:SendMsgHairQuery()
    self:ReportData(true)
    -- 记录
    USaveMgr.SetInt(SaveKey.PreHaircutMapID, MapID, true)
end

-- 获取解锁列表
function HaircutMgr:GetHairUnlockList()
	--self:RegisterGameEvent(EventID.ActorVMCreate, self.OnGameEventActorVMCreate)
    return self.UnLockedList
end

-- 初始化理发屋数据
function HaircutMgr:InitAvatarFace()
    -- 获取到最新
    -- local function Callback(_, RoleVM)
    --     local RoleSimple = RoleVM.RoleSimple
    --     if RoleSimple then
    --         LoginAvatarMgr:SetCurAvatarFace(RoleSimple.Avatar.Face)
    --         _G.EventMgr:SendEvent(EventID.HairRoleQuery)
    --     end
	-- end
	-- _G.RoleInfoMgr:QueryRoleSimple(MajorUtil.GetMajorRoleID(), Callback, self, false)
    local CurFace = LoginAvatarMgr:GetCurAvatarFace()
    if CurFace == nil or table.size(CurFace) == 0 then 
        local RoleSimple = MajorUtil.GetMajorRoleSimple()
        if RoleSimple ~= nil then
            LoginAvatarMgr:SetCurAvatarFace(RoleSimple.Avatar.Face)
            if RoleSimple.Avatar.Face ~= nil then
                self.DefaultAvatarFace = table.clone(RoleSimple.Avatar.Face)
            end
        end
    end
end

function HaircutMgr:GetDefaultAvatarFace()
   return self.DefaultAvatarFace
end

-- 离开理发屋
function HaircutMgr:EndHaircut(bFinished)
    self:ReportData(false, bFinished)

    if self.EnterMapID == 0 then
        self.EnterMapID = USaveMgr.GetInt(SaveKey.PreHaircutMapID, HaircutMgr.HaircutMap.Map1, true)
    end
    local SequenceID = 0
    if bFinished then
        SequenceID = self:GetLcutID(self.EnterMapID, HaircutMgr.HaircutOutSeq)
    else
        SequenceID = self:GetLcutID(self.EnterMapID, HaircutMgr.HaircutBreakSeq)
    end

    local function SequenceCallBack()
       -- 离开理发屋
       _G.WorldMsgMgr:ShowLoadingView(_G.WorldMsgMgr.CurWorldName)
	    self:PlayBGM(false)
	    _G.LoginUIMgr:ClearRoleWearSuit()
        _G.UE.UBGMMgr.Get():SetKeepBGMWhenWorldChange(false)
        UIViewMgr:HideView(UIViewID.HaircutMainPanel)
        self:OnReset()
        LoginAvatarMgr:Reset()
        LoginAvatarMgr:ResetParam("bResetCamera", false)
        CommonUtil.ShowJoyStick()
        self.BgmPlayingID = nil
        _G.PWorldMgr:SendLeavePWorld()
    end
    
    local PlaybackSettings = {
        bDisableMovementInput = true,
        bDisableLookAtInput = true,
        bPauseAtEnd = false,
    }
    -- 播放过程动画
    if SequenceID > 0 then
        _G.StoryMgr:PlayDialogueSequence(SequenceID, SequenceCallBack, 
            nil, SequenceCallBack, PlaybackSettings)
    else
        SequenceCallBack()
    end
end

-- 服装试穿提示
function HaircutMgr:SetSuitTips(bShow)
    self.bShowSuitTips = bShow
end

function HaircutMgr:GetSuitTips()
    return self.bShowSuitTips
end

-- 音效
function HaircutMgr:PlayBGM(bPlay)
	local UAudioMgr = _G.UE.UAudioMgr.Get()
	if bPlay then
        if not self.BgmPlayingID then
            local Channel =  EBGMChannel.Content
            local BgmID = 191
            self.BgmPlayingID = UAudioMgr:PlayBGM(BgmID, Channel)
        end
	else
		UAudioMgr:StopBGM(self.BgmPlayingID)
	end
end

-- 协议文件参考 csbarbershop.proto
-----------------------------------------------Rsp start-----------------------------------------------

function HaircutMgr:OnHairQuery(MsgBody)
    if MsgBody == nil or MsgBody.UpdateRsp == nil then return end
    self.UnLockedList = MsgBody.UpdateRsp.UnlockHairIDs
    _G.EventMgr:SendEvent(EventID.HairUnlockListChange)
end

---检查发型是否解锁
function HaircutMgr.CheckHairUnlock(HairLockID)
    return _G.HaircutMgr:CheckIsHairUnlock(HairLockID)
end
---判断是否存在该发型
function HaircutMgr:CheckIsHairUnlock(HairLockID)
    local Cfg = HairUnlockCfg:FindCfgByItemID(HairLockID)
    if Cfg == nil then
        return false
    end
    if self.UnLockedList == nil or #self.UnLockedList == 0 then
        return false
    end
    for _,v in pairs(self.UnLockedList) do
        if v==Cfg.HairID then
            return true
        end
    end
end

--判断是否是发型道具
function HaircutMgr:CheckIsHairItem(HairItemID)
    local Cfg = HairUnlockCfg:FindCfgByItemID(HairItemID)
    if Cfg == nil then
        return false
    else
        return true
    end
end

--添加发型
function HaircutMgr:AddNewHair(HairLockID)
    if self:CheckIsHairUnlock(HairLockID) then
        return false
    end
    local bHasHair = false;
    local Cfg = HairUnlockCfg:FindCfgByItemID(HairLockID)
    if Cfg and Cfg.HairID and self.UnLockedList then
        table.insert(self.UnLockedList, Cfg.HairID)
        bHasHair = true
    else
        FLOG_WARNING("HaircutMgr:AddNewHair Cfg is nil or Cfg.HairID is nil")
    end
    return bHasHair
end

function HaircutMgr:OnHairUnlock(MsgBody)
    if self.UnLockedList == nil then 
        self.UnLockedList = {}
    end
    if self.HairLockID ~= nil then
        table.insert(self.UnLockedList, self.HairLockID)
        MsgTipsUtil.ShowTips(LSTR(1250009)) --"发型解锁成功"
    end
    _G.EventMgr:SendEvent(EventID.HairUnlockListChange)
    _G.EventMgr:SendEvent(EventID.HairUnlockCompleted)
end

function HaircutMgr:OnHaircutSet(MsgBody)
    local FaceRsp = MsgBody.SetFaceRsp
    if FaceRsp ~= nil then
        LoginAvatarMgr:SetMajorAvatarCustomize(FaceRsp.RoleSimple.Avatar.Face)
        self:EndHaircut(true)
    end
end

-----------------------------------------------Rsp end-----------------------------------------------

-----------------------------------------------Req start-----------------------------------------------

-- 查询已解锁发型
function HaircutMgr:SendMsgHairQuery()
    local SubMsgID = SUB_MSG_ID.Update
	local MsgID = CS_CMD.CS_CMD_BARBER_SHOP
    local MsgBody = {Cmd = SubMsgID}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 请求解锁对应发型
function HaircutMgr:SendMsgHairUnlock(HairLockID)
    self.HairLockID = HairLockID
    local SubMsgID = SUB_MSG_ID.UnlockHair
	local MsgID = CS_CMD.CS_CMD_BARBER_SHOP
    local MsgBody = {Cmd = SubMsgID,  UnlockHairReq = {HairID = HairLockID}}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 完成理发
function HaircutMgr:SendMsgHaircutSet()
    local FaceData = LoginAvatarMgr:GetCurAvatarFace()
    local SubMsgID = SUB_MSG_ID.SetFace
	local MsgID = CS_CMD.CS_CMD_BARBER_SHOP
    local MsgBody = {Cmd = SubMsgID,  SetFaceReq = {Face = FaceData}}
    if FaceData == nil or table.size(FaceData) == 0 then
        FLOG_WARNING("HaircutMgr:SendMsgHaircutSet CurAvatarFace is Empty")
    end
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function HaircutMgr:SendChangeBGMap(PWorldID, MapID)
    if not PWorldID then
        return
    end

	local MsgID = CS_CMD.CS_CMD_BARBER_SHOP
    local SubMsgID = SUB_MSG_ID.ChangeMap
    local MsgBody = {Cmd = SubMsgID,  ChangeMapReq = {SceneResID = PWorldID}}

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-----------------------------------------------Req end-----------------------------------------------


return HaircutMgr
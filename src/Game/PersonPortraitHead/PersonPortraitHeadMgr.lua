---
--- Author: xingcaicao
--- DateTime: 2023-11-29 14:28:00
--- Description: 个人信息--肖像
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local PersonPortraitHeadVM 
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local EditVM = require("Game/PersonPortraitHead/VM/PersonPortraitHeadEditVM")
local HeadFrameCfg = require("TableCfg/HeadFrameCfg")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")

local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Role.Portrait.PersonalPortraitOptCmd

---

local CS_CMD_HEAD = CS_CMD.CS_CMD_HEAD_PORTRAIT
local SUB_CMD_HEAD = ProtoCS.Role.Portrait.HeadPortraitOptCmd

local CS_CMD_FRAME = CS_CMD.CS_CMD_HEADER_FRAME
local SUB_CMD_FRAME = ProtoCS.Role.HeaderFrame.CsHeaderFrameCmd

local CS_CMD_FANTASY = ProtoCS.CS_CMD.CS_CMD_FANTASY_MEDICINE
local SUB_CMD_FANTASY = ProtoCS.FantasyMedicineCmd

local LOG = _G.FLOG_INFO

local function LOG_S(K, S)
    LOG(string.format('[PersonHead][PersonPortraitHeadMgr][%s] %s', tostring(K), tostring(S)))
end

local function ERR_S(K, S)
    FLOG_ERROR(string.format('[PersonHead][PersonPortraitHeadMgr][%s] %s', tostring(K), tostring(S)))
end


---@class PersonPortraitHeadMgr : MgrBase
local Class = LuaClass(MgrBase)

function Class:OnInit()
    PersonPortraitHeadVM = _G.PersonPortraitHeadVM
end

function Class:OnBegin()
    PersonPortraitHeadVM = _G.PersonPortraitHeadVM
    self:BeginHead()
    self:BeginHeadFrame()
end

function Class:OnEnd()
    self:EndHead()
    self:EndHeadFrame()
end

function Class:OnShutdown()
    self.HasReqSetHeadGuideRedPoint = nil
end

function Class:OnRegisterNetMsg()
    self:OnRegisterNetMsgHead()
    self:OnRegisterNetMsgHeadFrame()
    self:OnRegisterNetMsgHeadSave()
    
    self:OnRegisterNetMsgFantasyMedicine()
end

function Class:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ClientSetupPost, self.RespHeadGuideRedPoint)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes) --角色成功登录
end

function Class:OnGameEventLoginRes()
    self:ReqGetHeadGuideRedPoint()
end

-------------------------------------------------------------------------------------------------------
---@region Head

function Class:OnRegisterNetMsgHead()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_Get,                 self.OnNetMsgGetData)                --获取肖像数据
end

function Class:SendGetPersonalPortraitData(ProfID)
    if nil == ProfID then
        return
    end

    PersonPortraitHeadVM.CurProfID = ProfID

	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_Get

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.header_list = { prof_id = ProfID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function Class:OnNetMsgGetData(MsgBody)
    local Rsp = MsgBody.header_list 
    if nil == Rsp then
        return
    end

    local Data = Rsp.personal_portrait_data
    if nil == Data then
        return
    end

    -- 模型编辑数据
    PersonPortraitHeadVM.CurEquipScheme = Data.equip_scheme
    EventMgr:SendEvent(EventID.PersonGetPortraitHeadDataSuc)
    self.IsSavingImg = false 
end

-------------------------------------------------------------------------------------------------------
---@region ui inf

function Class:OpenEditHeadView()
	-- _G.UIViewMgr:ShowView(_G.UIViewID.PersonHeadMainPanel)
    self.IsWaitForOpenUI = true
    self:ReqGetHead()
end

function Class:TryDeleteCustHead(ID)
    local IsInUse = self:IsInUseHead(ID, PersonPortraitHeadDefine.HeadType.Custom)
    local Tips = IsInUse and LSTR(960021) or LSTR(960023)
    _G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(960006), Tips, 
        function() 
            self:ReqDeleteHead(ID)
	        MsgTipsUtil.ShowTips(LSTR(960039))
        end, 
    nil, LSTR(960007), LSTR(960026))
end

-------------------------------------------------------------------------------------------------------
---@region head

--- net like

function Class:ReqSetHeadGuideRedPoint()
    if self.HasReqSetHeadGuideRedPoint then
        return
    end
    self.HasReqSetHeadGuideRedPoint = true
    _G.ClientSetupMgr:SendSetReq(ClientSetupID.HeadGuideRedPoint, "1")
end

function Class:ReqGetHeadGuideRedPoint()
    _G.ClientSetupMgr:SendQueryReq({ClientSetupID.HeadGuideRedPoint})
end

function Class:RespHeadGuideRedPoint(EventParams)
    if nil == EventParams then
		return
	end

    local SetupKey = EventParams.IntParam1
    if SetupKey == ClientSetupID.HeadGuideRedPoint then  -- 是否已提示初始肖像保存
        local Value = tonumber(EventParams.StringParam1)
        if Value ~= 1 then
            LOG_S('RespHeadGuideRedPoint', 'Add RedDot 202')
            _G.RedDotMgr:AddRedDotByID(202)
        else
            LOG_S('RespHeadGuideRedPoint', 'Del RedDot 202')
            _G.RedDotMgr:DelRedDotByID(202)
        end
    end
end

--- net

function Class:OnRegisterNetMsgHeadSave()
    self:RegisterGameNetMsg(CS_CMD_HEAD, SUB_CMD_HEAD.HeadPortrait_Set, self.RespSetHead)          --设置头像
    self:RegisterGameNetMsg(CS_CMD_HEAD, SUB_CMD_HEAD.HeadPortrait_Get, self.RespGetHead)          --获取头像
    self:RegisterGameNetMsg(CS_CMD_HEAD, SUB_CMD_HEAD.HeadPortrait_Save, self.RespSaveHead)        --保存头像
    self:RegisterGameNetMsg(CS_CMD_HEAD, SUB_CMD_HEAD.HeadPortrait_Delete, self.RespDeleteHead)      --删除头像
end

function Class:ReqSetHead(HeadIdx, HeadType)

    self:SetCurHeadInfo(HeadIdx, HeadType)
    local Cmd = SUB_CMD_HEAD.HeadPortrait_Set
    local Msg = {
        cmd = Cmd,
        set = {
            head_id = HeadIdx,
            head_type = HeadType
        }
    }

    LOG_S('ReqSetHead', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_HEAD, Cmd, Msg)
end

function Class:RespSetHead(Msg)
    LOG_S('RespSetHead', string.format('msg = %s', table.tostring(Msg)))

    -- local Resp = Msg.set
end

function Class:ReqGetHead()
    local Cmd = SUB_CMD_HEAD.HeadPortrait_Get
    local Msg = {
        cmd = Cmd,
        get = {}
    }

    LOG_S('ReqGetHead', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_HEAD, Cmd, Msg)
end

function Class:RespGetHead(Msg)
    local Resp = Msg.get

    LOG_S('RespGetHead', string.format('msg = %s', table.tostring(Msg)))

    if not Resp then
        return
    end

    local Idx = (Resp.head_id == nil or Resp.head_id == 0) and 1 or Resp.head_id
    local Type = Resp.head_type
    local Meta = Resp.head_metadata
    local Heads = Resp.custom_heads

    local CustomHeads = {}
    for I, Item in pairs(Heads) do
        table.insert(CustomHeads, {HeadIdx = I, HeadID = Item.head_id, HeadType = Item.head_type, HeadUrl = Item.head_url})
    end

    self:SetCustomHeadList(CustomHeads)
    self:SetCurHeadInfo(Idx, Type)
    self:SetHistoryHeads(Resp.history_heads)

    self:SetHeadEditShut(Meta)

    if self.IsWaitForOpenUI then
        self.IsWaitForOpenUI = nil
	    _G.UIViewMgr:ShowView(_G.UIViewID.PersonHeadMainPanel)
    end

    if self.IsSet then
	    PersonPortraitHeadVM.LastUseCustHead = true
    end
end

function Class:ReqSaveHead(IsSet)
    local Josn = PersonPortraitHeadVM.CurModelEditVM:GetDataJsonStr()
    local Idx = 0

    for _, Item in pairs(self.HeadCustList) do
        if Item.HeadID > Idx then
            Idx = Item.HeadID
        end
    end
    
    -- local JsonStr = Json.encode({ data = Josn })
    self:SetHeadEditShut(Josn)

    local Cmd = SUB_CMD_HEAD.HeadPortrait_Save
    local Msg = {
        cmd = Cmd,
        save = {
            head_id = Idx + 1,
            head_metadata = Josn,
            is_set = IsSet and 1 or 0,
        }
    }

    self.IsSet = IsSet

    LOG_S('ReqSaveHead', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_HEAD, Cmd, Msg)
end

function Class:RespSaveHead(Msg)
    local Resp = Msg.save

    if not Resp then
        return
    end

    local Upload = Resp.upload
    -- local IsSet = Resp.is_set == 1

    LOG_S('RespSaveHead', string.format('msg = %s', table.tostring(Msg)))

    self:PostCustomHead(Upload)
end

function Class:PostCustomHead(Upload)
    if table.is_nil_empty(Upload) then
        return
    end

    local Widget = PersonPortraitHeadVM.ScreenshotWidget

    if nil == Widget then
        self.IsSavingHead = false 
        return
    end

    local DataStr = _G.UE.UMediaUtil.GetWidgetScreenshotImageData(Widget, PersonPortraitHeadDefine.PortraitSize, 100, true)
    if string.isnilorempty(DataStr) then
        self.IsSavingHead = false 
        ERR_S('PostCustomHead', 'encode Image err')
        return
    end

    local JsonStr = Json.encode({ data = DataStr })
    LOG_S('PostCustomHead')

    if _G.HttpMgr:Post(Upload.upload_url, Upload.http_token, JsonStr, function(Msg, Secc)
        if not Secc then
            ERR_S('RespSaveHead', string.format('Post Image err msg = %s', table.tostring(Msg)))
        else
            self:ReqGetHead()
            LOG_S('PostCustomHead')
        end
    end, self) then
        PersonPortraitHeadVM.IsEnabledSaveBtn = false
    end
end

function Class:ReqDeleteHead(Idx)
    local Cmd = SUB_CMD_HEAD.HeadPortrait_Delete
    local Msg = {
        cmd = Cmd,
        delete = {
            head_id = Idx,
        }
    }

    LOG_S('ReqDeleteHead', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_HEAD, Cmd, Msg)
end

function Class:RespDeleteHead(Msg)
    local Resp = Msg.delete
    self:ReqGetHead()
end

--- set

function Class:SetCurHeadInfo(HeadIdx, HeadType)
    local NewInfo = {
        HeadIdx = HeadIdx,
        HeadType = HeadType,
    }
    self.CurHeadInfo = NewInfo
    
    local MajorVM = MajorUtil.GetMajorRoleVM()

    if MajorVM then
        local Url
        if HeadType == PersonPortraitHeadDefine.HeadType.Custom then
            if (self.HeadCustList) then
                for _, Info in pairs(self.HeadCustList) do
                    if Info.HeadID == HeadIdx then
                        Url = Info.HeadUrl
                        break;
                    end
                end
            end
        end
        -- LOG_S('SetCurHeadInfo', string.format('HeadIdx = %s, HeadType = %s, Url = %s', tostring(HeadIdx), tostring(HeadType), tostring(Url)))
        MajorVM:SetHeadInfo(HeadIdx, HeadType, Url)
    end

    PersonPortraitHeadVM:UpdHeadCustList()
    PersonPortraitHeadVM:UpdHeadFixedList()

    PersonPortraitHeadVM.CurHeadInfo = self.CurHeadInfo
end

function Class:SetCustomHeadList(List)
    self.HeadCustList = List
    PersonPortraitHeadVM:UpdHeadCustList()
end

---@param HeadPortraitGetRsp.history_heads
function Class:SetHistoryHeads(Data)
    self.HistoryHeadList = Data
    PersonPortraitHeadVM:UpdHistoryHeadInfo()
end

function Class:SetHeadEditShut(MetaJson)
    PersonPortraitHeadVM:UpdateCurModelEditVM(MetaJson)
end

--- inf

function Class:BeginHead()
    self.HeadCustList = {}
    self.CurHeadInfo = {}
end

function Class:EndHead()
    self.HeadCustList = {}
    self.CurHeadInfo = {}
end

function Class:IsInUseHead(HeadIdx, HeadType)
    local Info = self.CurHeadInfo
    local CurHeadIdx = Info.HeadIdx or 1
    local CurHeadType = Info.HeadType or PersonPortraitHeadDefine.HeadType.Default
    return (HeadIdx == CurHeadIdx) and  (HeadType == CurHeadType)
end

-------------------------------------------------------------------------------------------------------
---@region head frame

function Class:OnRegisterNetMsgHeadFrame()
    self:RegisterGameNetMsg(CS_CMD_FRAME, SUB_CMD_FRAME.CsHeaderFrameQuery, self.RespGetFrame)  
    self:RegisterGameNetMsg(CS_CMD_FRAME, SUB_CMD_FRAME.CsHeaderFrameUse, self.RespSetFrame)  
    self:RegisterGameNetMsg(CS_CMD_FRAME, SUB_CMD_FRAME.CsHeaderFrameNotify, self.RespFrameNotity)  
end

--- net

function Class:ReqGetFrame()
    local Cmd = SUB_CMD_FRAME.CsHeaderFrameQuery
    local Msg = {
        Cmd = Cmd,
        FrameQuery = {
            
        }
    }

    LOG_S('ReqGetFrame', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_FRAME, Cmd, Msg)
end

function Class:RespGetFrame(Msg)
    local Resp = Msg.FrameQuery

    LOG_S('RespGetFrame', string.format('msg = %s', table.tostring(Msg)))

    if not Resp then
        return
    end

    local FrameMap = Resp.HeaderFrames
    local CurFrameID

    for ID, Item in pairs(FrameMap) do
        if Item.Status == 1 then
            CurFrameID = ID
            break
        end
    end

    self:SetFrameMap(FrameMap)
    self:SetCurFrameID(CurFrameID or 1)
end

--

function Class:ReqSetFrame(FrameID)
    self:SetCurFrameID(FrameID)
    local Cmd = SUB_CMD_FRAME.CsHeaderFrameUse
    local Msg = {
        Cmd = Cmd,
        FrameUse = {
            FrameID = FrameID
        }
    }

    LOG_S('ReqSetFrame', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_FRAME, Cmd, Msg)
end

function Class:RespSetFrame(Msg)
    local Resp = Msg.FrameUse

    LOG_S('RespSetFrame', string.format('msg = %s', table.tostring(Msg)))

    if not Resp then
        return
    end

    PersonPortraitHeadVM:UpdFrameList()
    _G.EventMgr:SendEvent(_G.EventID.PersonHeadFrameUse)

    -- local FrameID = Resp.FrameID
    -- local CreateTime = Resp.CreateTime
end

--

function Class:RespFrameNotity(Msg)
    local Resp = Msg.FrameNotify

    LOG_S('RespFrameNotity', string.format('msg = %s', table.tostring(Msg)))

    if not Resp then
        return
    end

    self:ReqGetFrame()

    -- local FrameID = Resp.FrameID
end

--- set

function Class:SetFrameMap(FrameMap)
    self.FrameMap = FrameMap
    PersonPortraitHeadVM:UpdFrameList()
    _G.EventMgr:SendEvent(_G.EventID.PersonHeadFrameListUpd)
end

function Class:SetCurFrameID(CurFrameID)
    local MajorVM = MajorUtil.GetMajorRoleVM()
    self.CurFrameID = CurFrameID
    PersonPortraitHeadVM.InUseFrameID = CurFrameID
    MajorVM:SetHeadFrameID(CurFrameID)
    PersonPortraitHeadVM:UpdFrameListInUse()
end

---

function Class:BeginHeadFrame()
    self.FrameMap = {}
    self.CurFrameID = nil
end

function Class:EndHeadFrame()
    self.FrameMap = {}
    self.CurFrameID = nil
end

function Class:IsHeadFrameInUse(FrameResID)
    return self.CurFrameID == FrameResID
end

-- inf

function Class:GetFrameRemainTime(FrameResID)
    local Cfg = HeadFrameCfg:FindCfgByKey(FrameResID)
    if not Cfg then
        return -1
    end

    local Ele = self.FrameMap[FrameResID]
    if not Ele then
        return -1
    end

    local CreatedTime = Ele.CreatedTime
    local Now = _G.TimeUtil.GetServerTime()
    local Dur = Now - CreatedTime
    local LifeTime = tonumber(Cfg.Timelimit) or Dur
    local Remain = LifeTime - Dur
    local FmtRemain = _G.LocalizationUtil.GetCountdownTimeForLongTime(Remain)
    return FmtRemain
end

-------------------------------------------------------------------------------------------------------
---@region fantasy_med

function Class:OnRegisterNetMsgFantasyMedicine()
    self:RegisterGameNetMsg(CS_CMD_FANTASY, SUB_CMD_FANTASY.FantasyMedicineCmdQuery, self.RespQueryFantasyStat)  
end

function Class:ReqQueryFantasyStat()
    local Cmd = SUB_CMD_FANTASY.FantasyMedicineCmdQuery
    local Msg = {
        Cmd = Cmd,
        FantasyMedicineCmdQuery = {
        }
    }

    LOG_S('ReqQueryFantasyStat', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_FANTASY, Cmd, Msg)
end


function Class:RespQueryFantasyStat(Msg)
    local Resp = Msg.QueryRsp

    LOG_S('RespQueryFantasyStat', string.format('msg = %s', table.tostring(Msg)))

    if not Resp then
        return
    end

    local Stat = Resp.Status

    if Stat then
        MsgTipsUtil.ShowTips(LSTR(960003))
        self:ReqModifyFantasyStat()
    end
end

function Class:ReqModifyFantasyStat()
    local Cmd = SUB_CMD_FANTASY.FantasyMedicineCmdChangeStatus
    local Msg = {
        Cmd = Cmd,
        FantasyMedicineCmdChangeStatus = {
        }
    }

    LOG_S('ReqModifyFantasyStat', string.format('msg = %s', table.tostring(Msg)))

    GameNetworkMgr:SendMsg(CS_CMD_FANTASY, Cmd, Msg)
end


return Class
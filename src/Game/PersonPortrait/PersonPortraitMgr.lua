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
local PersonPortraitVM = require("Game/PersonPortrait/VM/PersonPortraitVM")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local UIUtil = require("Utils/UIUtil")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Role.Portrait.PersonalPortraitOptCmd

local ImgSaveStrategy = PersonPortraitDefine.ImgSaveStrategy

---@class PersonPortraitMgr : MgrBase
local Class = LuaClass(MgrBase)

function Class:OnInit()

end

function Class:OnBegin()

end

function Class:OnEnd()

end

function Class:OnShutdown()

end

function Class:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_Save,                self.OnNetMsgSaveImageData)          --保存肖像图片数据
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_SaveDataList,        self.OnNetMsgSaveSettings)           --保存肖像设置
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_Get,                 self.OnNetMsgGetData)                --获取肖像数据
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_GetResList,          self.OnNetMsgGetResUnlockStatus)     --获取资源解锁状态
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_UpdateProfAppear,    self.OnNetMsgAppearUpdateProfIDs)    --外观有更新职业列表
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_Remove,              self.OnNetMsgAppearUpdateTipsRemove) --移除外观更新提醒
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_ChangeNotify,        self.OnNetMsgResetData)              --重置数据通知（使用幻想药）
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_UnlockResNotify,     self.OnNetMsgResStatusNotify)        --资源状态变更通知
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PERSONAL_HEADER, SUB_MSG_ID.PersonalPortrait_GetAppear,           self.OnNetMsgGetAppearInfo)          --获取外观信息
end

function Class:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes) --角色成功登录
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected) -- 断线重连 
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)
end

function Class:OnGameEventLoginRes()
    self.IsSavingImg = false
    self.IsQueryInitData = true 
end

function Class:OnNetworkReconnected(Params)
    if nil == Params then
        return
    end

    if Params.bRelay then -- 闪断重连
        self.IsSavingImg = false
    end
end

function Class:QueryInitData()
    if not self.IsQueryInitData then
        return
    end

    self:SendGetUnlockResList()
    self:SendGetAppearUpdateProfIDs()

    self.IsQueryInitData = false
end

function Class:OnEventClientSetupPost( EventParams )
	if nil == EventParams then
		return
	end

	local IsSetRsp = EventParams.BoolParam1
    if IsSetRsp then
        return
    end

    local SetupKey = EventParams.IntParam1
    if SetupKey == ClientSetupID.PortraitReadRedDotIDs then  -- 已读的红点ID列表
        local Value = EventParams.StringParam1 or ""
        if not string.isnilorempty(Value) then
            local IDs = Json.decode(Value)
            if IDs then
                PersonPortraitVM:UpdateReadRedDotIDs(IDs)
            end
        end
    elseif SetupKey == ClientSetupID.PortraitSaveImgUrlStrategy then  -- 肖像保存图片策略
        local Value = tonumber(EventParams.StringParam1)
        if Value ~= ImgSaveStrategy.AllProf then
            Value = ImgSaveStrategy.CurProf
        end

        PersonPortraitVM:SetSaveImgUrlStrategy(Value, false)
    end
end

function Class:OnNetMsgSaveImageData(MsgBody)
    local Rsp = MsgBody.save 
    if nil == Rsp then
        return
    end

    self:PostPortraitImage(Rsp.upload)
end

function Class:OnNetMsgSaveSettings(MsgBody)
    local Rsp = MsgBody.data_list
    if nil == Rsp then
        return
    end

    if Rsp.success then
        MsgTipsUtil.ShowTips(LSTR(60008)) -- "设置保存成功"
    end

	self:SendGetPersonalPortraitData(PersonPortraitVM.CurProfID)
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

    local ProfID = Data.prof_id

    -- 更新主角角色信息
    local MajorRoleVM = MajorUtil.GetMajorRoleVM()
    if MajorRoleVM and MajorRoleVM.Prof == ProfID then
        MajorRoleVM:SetPortraitUrl(Data.header_url, Data.create_time)
    end

    if ProfID ~= PersonPortraitVM.CurProfID then
        return
    end

    -- 模型编辑数据
    PersonPortraitVM:UpdateCurModelEditVM(Data.user_data)

    -- 背景、装饰、装饰框、动作、表情
    PersonPortraitVM:UpdateCurProfSetResIDsServer(Data.res_data)

    -- 获取外观数据
    self:SendGetAppearInfo(ProfID)
end

--- 获取资源解锁状态（配置类型为非默认解锁）
function Class:OnNetMsgGetResUnlockStatus(MsgBody)
    local Rsp = MsgBody.res_list
    if nil == Rsp then
        return
    end

    PersonPortraitVM:UpdateServerResStatus(Rsp.res_status)
    EventMgr:SendEvent(EventID.PersonPortraitResStatusUpdate)
end

function Class:OnNetMsgResStatusNotify(MsgBody)
    local Rsp = MsgBody.unlock_notify
    if nil == Rsp then
        return
    end

    PersonPortraitVM:UpdateServerResStatus(Rsp.res_status)
    EventMgr:SendEvent(EventID.PersonPortraitResStatusUpdate)
end

function Class:OnNetMsgAppearUpdateProfIDs(MsgBody)
    local Rsp = MsgBody.prof_list
    if nil == Rsp then
        return
    end

    local CurProfIDs = PersonPortraitVM.AppearUpdateProfIDs
    if nil == CurProfIDs then
        return
    end

    local NewList = Rsp.prof_ids
    if NewList then
        for _, v in ipairs(NewList) do
            if not table.contain(CurProfIDs, v) then
                table.insert(CurProfIDs, v)
            end
        end
    end
end

function Class:OnNetMsgAppearUpdateTipsRemove(MsgBody)
    local Rsp = MsgBody.remove
    if nil == Rsp then
        return
    end

    if Rsp.success then
        local ProfID = PersonPortraitVM.CurProfID
        table.remove_item(PersonPortraitVM.AppearUpdateProfIDs, ProfID)

        EventMgr:SendEvent(EventID.PersonPortraitRemoveAppearUpdateTips, ProfID)
    end
end

--重置数据通知（使用幻想药）
function Class:OnNetMsgResetData(MsgBody)
    local ProfID = (MsgBody.change_notify or {}).prof_id
    if nil == ProfID then
        return
    end

    -- 更新主角角色信息
    local MajorRoleVM = MajorUtil.GetMajorRoleVM()
    if MajorRoleVM and MajorRoleVM.Prof == ProfID then
        MajorRoleVM:SetPortraitUrl()
    end
end

function Class:OnNetMsgGetAppearInfo(MsgBody)
    if nil == MsgBody then
        return
    end

    local Data = MsgBody.appear
    if nil == Data then
        return
    end

    local ProfID = Data.prof_id
    if ProfID ~= PersonPortraitVM.CurProfID then
        return
    end

    PersonPortraitVM.CurEquipList = Data.equip_list
    EventMgr:SendEvent(EventID.PersonPortraitGetDataSuc, self.IsSavingImg)

    self.IsSavingImg = false
end

---获取指定职业的肖像数据
---@param ProfID number @职业ID
function Class:SendGetPersonalPortraitData(ProfID)
    if nil == ProfID then
        return
    end

    PersonPortraitVM.CurProfID = ProfID

	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_Get

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.header_list = { prof_id = ProfID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---获取已解锁的资源数据
function Class:SendGetUnlockResList()
	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_GetResList

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.res_list = { }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求保存个人肖像图片数据
function Class:SendSavePortraitImageData()
	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_Save

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.save = {
        prof_id = PersonPortraitVM.CurProfID,
        save_strategy = PersonPortraitVM.SaveImgUrlStrategy or 0,
     }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---请求保存肖像设置数据
function Class:SendSavePortraitSettings( )
	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_SaveDataList

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.data_list = {
        prof_id = PersonPortraitVM.CurProfID,
        res_data = PersonPortraitVM:GetCurSetResIDs(),
        user_data = PersonPortraitVM.CurModelEditVM:GetDataJsonStr()
     }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---获取外观有更新职业列表
function Class:SendGetAppearUpdateProfIDs()
	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_UpdateProfAppear

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.prof_list = { }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---移除外观更新提醒
---@param ProfID number @职业ID
function Class:SendRemoveAppearUpdateTips(ProfID)
    if not table.contain(PersonPortraitVM.AppearUpdateProfIDs, PersonPortraitVM.CurProfID) then
        return
    end

	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_Remove

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.remove = { prof_id = ProfID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---获取指定职业的外观信息
---@param ProfID number @职业ID
function Class:SendGetAppearInfo(ProfID)
    if nil == ProfID then
        return
    end

	local MsgID = CS_CMD.CS_CMD_PERSONAL_HEADER
	local SubMsgID = SUB_MSG_ID.PersonalPortrait_GetAppear

	local MsgBody = {}
	MsgBody.cmd = SubMsgID
	MsgBody.appear = { prof_id = ProfID }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--@param Upload CommonUpload @Http上传信息
function Class:PostPortraitImage(Upload)
    if table.is_nil_empty(Upload) then
        return
    end

    local Widget = PersonPortraitVM.ScreenshotWidget 
    if nil == Widget then
        self.IsSavingImg = false 
        return
    end

    local Size = UIUtil.GetLocalSize(Widget)
    local DataStr = _G.UE.UMediaUtil.GetWidgetScreenshotImageData(Widget, Size, 100, false)
    if string.isnilorempty(DataStr) then
        self.IsSavingImg = false 
        FLOG_ERROR("PersonPortraitMgr::PostPortraitImage, the widget's screenshot data is empty")
        return
    end

    local JsonStr = Json.encode({ data = DataStr })
    _G.HttpMgr:Post(Upload.upload_url, Upload.http_token, JsonStr, self.OnPostPortraitImageCallback, self)
end

function Class:OnPostPortraitImageCallback(MessageBody, bSucceeded)
    if not bSucceeded then
        FLOG_ERROR("PersonPortraitMgr::OnPostPortraitImageCallback: %s", MessageBody)
        return
    end

    -- 界面关闭，数据被清空了
    if nil == PersonPortraitVM.CurProfID then
        return
    end

    self:SendSavePortraitSettings()
end

return Class
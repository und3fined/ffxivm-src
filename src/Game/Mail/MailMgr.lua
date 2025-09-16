local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MailDefine = require("Game/Mail/MailDefine")
local RenderSceneDefine = require ("Game/Common/Render2D/RenderSceneDefine")
local LetterCfg = require("TableCfg/LetterCfg")
local MailSampleCfg = require("TableCfg/MailSampleCfg")
local MailStyleCfg = require("TableCfg/MailStyleCfg")
local ScoreSummaryCfg = require("TableCfg/ScoreSummaryCfg")
local TimeUtil = require("Utils/TimeUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoBuff = require("Network/ProtoBuff")
local AudioUtil = require("Utils/AudioUtil")
local ActorUtil = require("Utils/ActorUtil")
local MailUtil = require("Game/Mail/MailUtil")
local Json = require("Core/Json")
local ObjectGCType = require("Define/ObjectGCType")
local MailMainVM = require("Game/Mail/View/MailMainVM")


local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Mail.Mail.CmdMail

local MailTypeList = MailDefine.MailType
local UIViewMgr
local GameNetworkMgr
local LootMgr
local ScoreMgr
local LSTR
local RedDotMgr


---@class MailMgr : MgrBase
local MailMgr = LuaClass(MgrBase)


function MailMgr:OnInit()
	self:DataReset()
end

function MailMgr:DataReset()
	self.CacheMailList = {}
	self.SeverStoreMailNum = {}
	self.ReqDeleteMailIDList = {}
	self.CreatedNPCEntityID = nil
	self.LoadModeling = nil
	self.LoadModelTimeUpper = 3.0
	self.HaveNewMail = false
	self.HaveNewMailTypes = {}
	self.MailTotalNum = {}
	self.RedDotNameList = {}
	self.MailTypeRedDotNameList = {} -- { [ID] = { RedDotName Count} }    类型的ID用自己的枚举值
	self.DecorationMap = {}
	self.OpenMainViewParams = nil
end

function MailMgr:ReconnectDataReset()
	self.ReqDeleteMailIDList = {}
	self.HaveNewMail = false
	self.HaveNewMailTypes = {}
end

---OnBegin
function MailMgr:OnBegin()
	self:DataReset()
	UIViewMgr = _G.UIViewMgr
	LootMgr = _G.LootMgr
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	ScoreMgr = _G.ScoreMgr
	RedDotMgr = _G.RedDotMgr

	self.DecorationMap = MailStyleCfg:FindAllCfg()
end

function MailMgr:OnEnd()
	self:ClearAllMailRedDot()
	self:DataReset()
end

function MailMgr:OnShutdown()
	self:ClearAllMailRedDot()
	self:DataReset()
end

function MailMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MAIL, SUB_MSG_ID.CmdGetMail, self.GetMailRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MAIL, SUB_MSG_ID.CmdSetRead, self.SetReadRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MAIL, SUB_MSG_ID.CmdReceiveAttachmentAward, self.ReceiveAttachmentAwardRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MAIL, SUB_MSG_ID.CmdDelMail, self.DelMailRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_MAIL, SUB_MSG_ID.CmdNewMailNotify, self.NewMailNotify)
end

function MailMgr:OnRegisterTimer()

end

function MailMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_AssembleAllEnd, self.OnAssembleAllEnd)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventRoleLoginRes)
end

function MailMgr:OnGameEventRoleLoginRes(Params)
	self:ReconnectDataReset()
	self:GetServerAllTypeMailList()
	if not Params.bReconnect then
		self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	end
end

function MailMgr:OnAssembleAllEnd(Params)
	local EntityID = Params.ULongParam1
	if EntityID == self.CreatedNPCEntityID and self.LoadModeling ~= nil then
		UIViewMgr:ShowView(UIViewID.MailMainView, self.OpenMainViewParams)
		self.OpenMainViewParams = nil
		self.LoadModeling = nil
	end
end

function MailMgr:OnGameEventPWorldMapEnter()
	self:UnRegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	for _, Value in pairs(self.CacheMailList) do
		local MailList = Value or {}
		for i = 1, #MailList do
			if not MailList[i].Readed then
				AudioUtil.LoadAndPlayUISound(MailDefine.NewMailNotifyAudioPath)
				return
			end
		end
	end
end

--- 计时函数
function MailMgr:OnTimerUpdate()
	--模型加载等待
	if self.LoadModeling ~= nil then
		UIViewMgr:ShowView(UIViewID.MailMainView, self.OpenMainViewParams)
		self.OpenMainViewParams = nil
		self.LoadModeling = nil
	end
end

function MailMgr:ClearCreatedNPCEntityID()
	self.CreatedNPCEntityID = nil
end

--------- 协议相关
--- 获取邮件请求
function MailMgr:GetMailReq(MailType, MailNum)
	self.CacheMailList[MailType] = {}
	self:RefreshRedDotList(MailType, {})
	local MsgID = CS_CMD.CS_CMD_MAIL
	local SubMsgID = SUB_MSG_ID.CmdGetMail
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CmdGetMail,
		GetMail = {
					MailType = MailType,
					Offset = 0,
					Count = MailNum,
				},
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--获取邮件回复
function MailMgr:GetMailRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.GetMail then
		return
	end
	local GetMailRsp = MsgBody.GetMail
	local MailNumber = MsgBody.GetMail.MailNumber or 0
	local MailList = GetMailRsp.Mails or {}
	if MailNumber > 0 and #MailList > 0 then
		local MailType = MailList[1].Mail.MailType
		for Index, Value in pairs(self.SeverStoreMailNum) do
			if Value.Type == MailType then
				self.SeverStoreMailNum[Index].MailNumber = MailNumber
			end
		end
		if self:GetMailTotalNum(MailType) <= MailNumber then
			self:RefreshRedDotList(MailType, MailList)
		end
		self:GetReceiveMailCacheRsp(MailList)
	end
end

--向服务端发送领取协议
function MailMgr:ReceiveAttachmentAwardReq(MailIDList, MailType)
	local MsgID = CS_CMD.CS_CMD_MAIL
	local SubMsgID = SUB_MSG_ID.CmdReceiveAttachmentAward
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CmdReceiveAttachmentAward,
		ReceiveAttachmentAward = { MailID = MailIDList, MailType = MailType },
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--向服务端发送删除邮件协议
function MailMgr:DelMailReq(MailIDList, MailType)
	local MsgID = CS_CMD.CS_CMD_MAIL
	local SubMsgID = SUB_MSG_ID.CmdDelMail
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CmdDelMail,
		DelMail = { MailID = MailIDList, MailType = MailType }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 已读协议请求
function MailMgr:SetReadReq(MailID, MailType)
	local MsgID = CS_CMD.CS_CMD_MAIL
	local SubMsgID = SUB_MSG_ID.CmdSetRead
	local MsgBody = { 
		Cmd = SUB_MSG_ID.CmdSetRead,
		SetRead = { MailID = MailID, MailType = MailType },
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--删除回包
function MailMgr:DelMailRsp(MsgBody)
	if nil == MsgBody or MsgBody.ErrorCode or nil == MsgBody.DelMail then
		self.ReqDeleteMailIDList = {}
		return
	end
	local DelMail = MsgBody.DelMail
	local FailedMailList = DelMail.MailID or {}
	self:DeleteMailListData(FailedMailList, DelMail.MailType)
end

--领取邮件附件回包
function MailMgr:ReceiveAttachmentAwardRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.ReceiveAttachmentAward or MsgBody.ErrorCode then
		self:ReceivedAttachmentSuccessfully({})      -- 上次所有领取失败
		return
	end

	local ReceiveAttachmentAward = MsgBody.ReceiveAttachmentAward or {}
	self:ReceivedAttachmentSuccessfully(ReceiveAttachmentAward.Mails or {}, ReceiveAttachmentAward.MailType) --领取成功的ID列表
end

--新邮件通知
function MailMgr:NewMailNotify(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.NewMailNotify then
		return
	end
	local NewMailNotify = MsgBody.NewMailNotify

	AudioUtil.LoadAndPlayUISound(MailDefine.NewMailNotifyAudioPath)
	if UIViewMgr:IsViewVisible(UIViewID.MailMainView) then
		self.HaveNewMail = true
		if table.concat(self.HaveNewMailTypes, NewMailNotify.MailType) then
			table.insert(self.HaveNewMailTypes, NewMailNotify.MailType)
		end
	else
		self:GetMailReq(NewMailNotify.MailType, self:GetMailTotalNum(NewMailNotify.MailType))
	end
end

--------- 功能相关

function MailMgr:GetServerAllTypeMailList()
	for _, Value in pairs(MailTypeList) do
		table.insert(self.SeverStoreMailNum, { Type = Value, MailNumber = 0 } )
        self.MailTotalNum[Value] = LetterCfg:FindValue(Value, "ShowLimit") or 0
		local OutBoxID = MailUtil.GetOutBoxID(Value)
		local MailRedDotName = RedDotMgr:GetRedDotNameByID(MailDefine.MailMenuRedDotID)
		if MailRedDotName ~= nil then
			local TypeName = MailRedDotName .. "/" .. tostring(Value)
			self.MailTypeRedDotNameList[Value] = {  RedDotName = TypeName, Count = 0 }
		end
		if OutBoxID ~= nil then
			table.insert(self.SeverStoreMailNum, { Type = OutBoxID, MailNumber = 0 } )
			self.MailTotalNum[OutBoxID] = LetterCfg:FindValue(Value, "ShowLimit") or 0
			self:GetMailReq(OutBoxID, self.MailTotalNum[OutBoxID])
		end
		self:GetMailReq(Value, self.MailTotalNum[Value])
	end
end


--- 根据表中获取配置
---@type LocalMailData table@客户端存储的邮件结构体成员
---@field ID number @邮件唯一ID
---@field SenderID string @邮件发送者ID     系统邮件 给 发件人名称   商城赠礼邮件给赠送人 string类型roleid
---@field MailType ProtoCS.MailType @邮件类型
---@field Title string @邮件标题
---@field Text string @邮件正文
---@field Attachment repeated Attach @邮件附件列表
---@field ExpiresTime number @过期时间戳 0不过期
---@field Readed bool @是否已读
---@field Attach bool @是否有附件
---@field SendTime number @发送时间
---@field GetDataTime number @展示前获取数据的时间
---@field GiftData bytes @商城赠礼数据
---@field CfgID number @ 如果是 Y邮件配置表 中的邮件 则有 配置表中ID
---@field StyleID number 信笺样式ID
---@field ArgList string [] @ Y邮件配置表 中的邮件 的参数列表
--- 发件
---@field ReceiverID number @邮件接受者ID


---存储收件箱邮件缓存数据
function MailMgr:GetReceiveMailCacheRsp(AllMailRsp)
	if AllMailRsp == nil or #AllMailRsp <= 0  then
		return
	end

	local MailType = AllMailRsp[1].Mail.MailType
	self.CacheMailList[MailType] = {}
	for i = 1, #AllMailRsp do
		local MailData = AllMailRsp[i]
		local LocalMailData = {
			ID = MailUtil.SeverIDToClientID(MailData.Mail.ID, MailType) ,
			SenderID = MailData.Mail.SenderID or "",
			MailType = MailData.Mail.MailType,
			ExpiresTime = MailData.Mail.ExpiresTime or 0,
			Readed = MailData.Read,
			SendTime = MailData.SendTime,
			ReceiverID = MailData.ReceiverID or "",
			ArgList = {},
			StyleID = 1,
		}

		local Attach = ProtoBuff:Decode("csproto.MailAttachment", MailData.Mail.AttachmentByte)
		if LocalMailData.MailType == MailDefine.MailType.Gift then
			LocalMailData.GiftData = ProtoBuff:Decode("csproto.MallGift", Attach.ExtraData) or {}
		end
		LocalMailData.Attachment = Attach.MailItemList or {}
		local InBoxID = MailUtil.GetInBoxID(MailType)
		if InBoxID ~= nil then
			-- 是发件箱
			LocalMailData.Readed = true
			LocalMailData.Attach = false
		else
			if #(LocalMailData.Attachment) > 0 then
				if MailData.Attach then
					LocalMailData.Attach = false
					LocalMailData.Readed = true
				else
					LocalMailData.Attach = true
				end
			else
				LocalMailData.Attach = false
			end
		end
		if not LocalMailData.Readed then
			self:AddRedDot(MailType, LocalMailData.ID)
		end

		local IsCustomData = (MailData.Mail.MailData or {}).Data == "CustomData"
		if IsCustomData then 
			LocalMailData.Title = MailData.Mail.MailData.CustomData.Title or ""
			LocalMailData.Text = MailData.Mail.MailData.CustomData.Text or ""
			LocalMailData.CfgID = 0
		else
			LocalMailData.CfgID = ((MailData.Mail.MailData or {}).ConfigData or {}).ConfigID or 0
			LocalMailData.Title = ""
			LocalMailData.Text = ""
		end

		local MailSampleInfo = MailSampleCfg:FindCfgByKey(LocalMailData.CfgID or 0)
		if MailSampleInfo ~= nil then
			LocalMailData.StyleID = MailSampleInfo.MailStyle
			LocalMailData.Title = MailSampleInfo.Title
			LocalMailData.Text = MailSampleInfo.Text
			LocalMailData.SenderID = MailSampleInfo.SenderID
		end

		local Ret, UserTranportData = pcall(Json.decode, MailData.Mail.MetaData)
		if Ret and UserTranportData then
			LocalMailData.ArgList = ((UserTranportData.ArgMap or {}).ArgList or {}).Value or {}
			local ToList = ((UserTranportData.ArgMap or {}).to or {}).Value or {}
			if ToList[1] ~= nil then
				LocalMailData.ReceiverID = tostring(ToList[1])
			end
		end
		if not table.empty(LocalMailData.ArgList) then
			LocalMailData.Text = string.sformat(LocalMailData.Text, table.unpack(LocalMailData.ArgList))
		end

		table.insert(self.CacheMailList[MailType], LocalMailData )
	end

	self:OverCapacityRedDot(MailType)
end

--- 获取缓存收件箱邮件列表数据
---@param MailType MailDefine.MailType @需要获取的邮件类型
---@param IsSort bool   @是否刷新排序 
function MailMgr:GetCacheMailList(MailType, IsSort)
	local MailList = self.CacheMailList[MailType]
	if nil == MailList then
		return {}
	end

	local CurrentTime = TimeUtil.GetServerTime()

	local ShowList = {}
	for i = 1, #MailList do
		if MailList[i].ExpiresTime > (MailList[i].GetDataTime or CurrentTime) or MailList[i].ExpiresTime == 0 then
			table.insert(ShowList, MailList[i])
		end
	end

	-- 邮件列表排序规则
	local MailListSortFunc = function(A, B)
		-- A.Readed  已读
		-- A.Attach  有附件未领取

		if A.Readed and not(A.Attach) then    --如果a已读 并且 无附件
			if not(B.Readed) or B.Attach then  -- b 未读 或 有附件
				return false
			else
				return A.SendTime > B.SendTime
			end
		else
			if not(B.Readed) or B.Attach then  -- b 未读 或 有附件
				return A.SendTime > B.SendTime
			else
				return true
			end
		end
	end

	if IsSort then
		table.sort(ShowList, MailListSortFunc)
		table.sort(MailList, MailListSortFunc)
	end

	return ShowList
end

--获取当前客户端显示邮件总数
function MailMgr:GetMailTotalNum(MailType)
	return self.MailTotalNum[MailType] or 0
end

-- 获取发件箱数据列表
---@param MailType MailDefine.MailType @需要获取的邮件类型
function MailMgr:GetSendMailList(MailType)
	local MailList = {}
	local OutBoxID = MailUtil.GetOutBoxID(MailType)
	if OutBoxID ~= nil then
		MailList = self.CacheMailList[OutBoxID] or {}
	end
	return MailList
end

--已读某个邮件
function MailMgr:ReadMail(MailID, MailType)
	if nil == MailID or MailType == nil then
		return
	end
	self:SetReadReq(MailUtil.ClientIDToSeverID(MailID), MailType)
end

-- 返回 已读某个邮件结果
function MailMgr:SetReadRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.SetRead or MsgBody.ErrorCode then
		return
	end
	local SetReadRsp = MsgBody.SetRead

	local ReadMailID = MailUtil.SeverIDToClientID( SetReadRsp.MailID,  SetReadRsp.MailType)
	local ExpiresTime = SetReadRsp.ExpiresTime
	local MailType = MailMgr:QueryMailTypeFromID(ReadMailID)
	local MailList = self.CacheMailList[MailType] or {}
	for j = 1, table.length(MailList) do
		if MailList[j].ID == ReadMailID then
			MailList[j].Readed = true
			MailList[j].ExpiresTime = ExpiresTime
			if ExpiresTime ~= 0 then
				MailList[j].GetDataTime = TimeUtil.GetServerTime()
			end
		end
	end

	MailMainVM:RefreshCurrentMailList(ReadMailID)
	self:RemoveRedDot(ReadMailID)
end

-- 检查附件中货币类有无达到上限并提示
---@param MailID number @邮件ID
---@param MailType number @邮件类型
---@return 是否继续领取  true @继续  false @中断
function MailMgr:CheckScoreUpperLimit(MailID, MailType)
	local MailList = self.CacheMailList[MailType] or {}
	local MailInfo, _ = table.find_by_predicate(MailList, function(Item) return MailID == Item.ID end )
	if MailInfo ~= nil and MailInfo.Attachment ~= nil then
		for i = 1, #MailInfo.Attachment do
			local Attachment = MailInfo.Attachment[i]
			local ScoreCfg = ScoreSummaryCfg:FindCfgByKey(Attachment.ResID)
			if ScoreCfg ~= nil then
				local MsgBoxOpRightCB = function ()
					self:GetMailAttch({MailID}, MailType)
				end
				local MaxValue = ScoreMgr:GetScoreMaxValue(Attachment.ResID)
				local CurValue = ScoreMgr:GetScoreValueByID(Attachment.ResID)
				if MaxValue < CurValue + Attachment.Num then
					local HintText = string.format( LSTR(740002), ScoreCfg.NameText)
					MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(740005), HintText, MsgBoxOpRightCB,  nil, LSTR(740007), LSTR(740014))
					return
				end
			end
		end
	end
	self:GetMailAttch({MailID}, MailType)
end

--领取邮件列表附件附件
function MailMgr:GetMailAttch(MailIDList, MailType)
	if table.empty(MailIDList) then
		return
	end

	LootMgr:SetDealyState(true)
	--上报服务器
	self:ReceiveAttachmentAwardReq(MailUtil.CIDListToSIDList(MailIDList), MailType)
end

--获取可领取邮件的ID列表
function MailMgr:GetMailAllAttchList(MailListData)
	local MailIDList = {}
	for i = 1, #MailListData do
		if MailListData[i].Attach then
			table.insert(MailIDList, MailListData[i].ID )
		end
	end
	return MailIDList
end

-- 领取附件成功列表处理
function MailMgr:ReceivedAttachmentSuccessfully(SuccessList, InBoxType)
	local MailIDList = {}
	local ReceivedItemList = {}
	if #SuccessList > 0 then
		local MailList = self.CacheMailList[InBoxType] or {}
		for j = 1, table.length(MailList) do
			local Value, _ = table.find_by_predicate(SuccessList, function(Item) return MailList[j].ID == MailUtil.SeverIDToClientID(Item.MailID, InBoxType) end )
			if Value ~= nil then
				local MailInfo = MailList[j]
				MailInfo.Attach = false
				MailInfo.ExpiresTime = Value.ExpiresTime
				MailList[j].GetDataTime = TimeUtil.GetServerTime()
				table.insert(MailIDList, MailInfo.ID)
				for k = 1, #MailInfo.Attachment do
					local ItemInfo = { ResID = MailInfo.Attachment[k].ResID , Num = MailInfo.Attachment[k].Num }
					table.insert(ReceivedItemList, ItemInfo)
				end
				if not MailInfo.Readed then
					self:RemoveRedDot(MailInfo.ID)
					MailInfo.Readed = true
				end
			end
		end
		MailMainVM:RefreshAfterReceivedAttachment(MailIDList)
	end

	if #ReceivedItemList <= 0 then
		-- 成功领取但无附件
		LootMgr:SetDealyState(false)
		return
	end
	MailUtil.OpenRewardPanel(ReceivedItemList)
end

--删除邮件
---@param MailIDList tabele @待删除邮件ID列表
---@param MailType MailDefine.MailType @待删除邮件类型
function MailMgr:DeleteMail(MailIDList, MailType, MailBoxType)
	if table.empty(MailIDList) or nil == MailType or (not table.empty(self.ReqDeleteMailIDList)) then
		return
	end

	self.ReqDeleteMailIDList = MailIDList
	-- 发后台
	if MailBoxType == MailDefine.MailBoxType.OutBox then
		local OutBoxType = MailUtil.GetOutBoxID(MailType)
		if OutBoxType ~= nil then
			self:DelMailReq(MailUtil.CIDListToSIDList(MailIDList), OutBoxType)
		end
	elseif MailBoxType == MailDefine.MailBoxType.InBox then
		self:DelMailReq(MailUtil.CIDListToSIDList(MailIDList), MailType)
	end
end

---删除所有已读邮件
---@param MailType MailDefine.MailType @需要获取的邮件类型
function MailMgr:DeleteAllReadMail(MailType)
	local MailList = self.CacheMailList[MailType] or {}

	local MailIDList = {}
	for i = 1, #MailList do
		if (MailList[i].Readed and MailList[i].Attach == false)             --已读无附件
		or (MailList[i].Attach == false and #MailList[i].Attachment > 0 )   --有附件已领取
		then
			table.insert(MailIDList, MailList[i].ID )
		end
	end

	self:DeleteMail(MailIDList, MailType, MailDefine.MailBoxType.InBox)  --收件箱才有删除已读
end

-- 删除邮件列表回复
function MailMgr:DeleteMailListData(FailedMailList, MailType)
	FailedMailList = MailUtil.SIDListToCIDList(FailedMailList, MailType)
	local ReqDelMailCount = #self.ReqDeleteMailIDList
	local function DelListRemoveFun(ID)
		return table.contain(FailedMailList, ID)
	end 
	table.array_remove_item_pred(self.ReqDeleteMailIDList, DelListRemoveFun )

	local DelSuccessfullyCount = #self.ReqDeleteMailIDList
	local DelMailType = self:QueryMailTypeFromID(self.ReqDeleteMailIDList[1])
	local MailList = self.CacheMailList[DelMailType] or {}

	local function RemoveFun(Item)
		return table.contain(self.ReqDeleteMailIDList, Item.ID)
	end 
	table.array_remove_item_pred(MailList, RemoveFun )

	if DelSuccessfullyCount > 0 and ReqDelMailCount > 0 then
		MsgTipsUtil.ShowTips(LSTR(740004))
	end

	self.ReqDeleteMailIDList = {}

	--刷新Vm
	MailMainVM:RefreshAfterDeleteMail()
	self:OverCapacityRedDot(DelMailType)
end

-- 根据ID和类型 获取邮件当前缓存数据
---@param MailID number @邮件ID
---@param MailType MailDefine.MailType @邮件类型
---@param MailBoxType MailDefine.MailType @邮件箱类型
function MailMgr:GetMailData(MailID, MailType, MailBoxType)
	if nil == MailID or nil == MailType or self.CacheMailList == nil then
		return
	end
	local MailList = {}
	if MailBoxType == MailDefine.MailBoxType.OutBox then
		local OutBoxID = MailUtil.GetOutBoxID(MailType)
		if OutBoxID ~= nil then
			MailList = self.CacheMailList[OutBoxID] or {}
		end
	else
		MailList = self.CacheMailList[MailType] or {}
	end
	for i = 1, #MailList do
		if MailList[i].ID == MailID then
			return MailList[i]
		end
	end
	return
end

--获取服务器额外储存邮件
function MailMgr:GetSeverStoreMail()
	for _, Value in pairs(self.SeverStoreMailNum) do
		local TotalNum = self:GetMailTotalNum(Value.Type)
		if Value.MailNumber > TotalNum and #(self.CacheMailList[Value.Type]) < TotalNum then
			self:GetMailReq(Value.Type, TotalNum)
		end
	end
end

--刷新一下所有获取邮件数据时间
function MailMgr:SetAllMailGetDataTime()
	local CurrentTime = TimeUtil.GetServerTime()
	for _, MailList in pairs(self.CacheMailList) do
		for i = 1, #(MailList or {}) do
			if MailList[i] ~= nil then
				if MailList[i].ExpiresTime ~= 0 then
					MailList[i].GetDataTime = CurrentTime
				else
					MailList[i].GetDataTime = nil
				end
			end
		end
	end
end

-- 检查是否有新邮件并获取
function MailMgr:GetNewEmails()
	if self.HaveNewMail then
		for i = 1, #self.HaveNewMailTypes do
            local MailType = self.HaveNewMailTypes[i]
            self:GetMailReq(MailType, self:GetMailTotalNum(MailType))
		end
	end

	self.HaveNewMail = false
	self.HaveNewMailTypes = {}
end

-- 查询目标类型收件箱是否有未读邮件
---@param MailType MailDefine.MailType @邮件类型
---@return  true @有  false @没有
function MailMgr:CheckUnReadMail(MailType)
	local MailList = self.CacheMailList[MailType] or {}
	for i = 1, #MailList do
		if not MailList[i].Readed then
			return true
		end
	end
	return false
end

-- 根据邮件id 获取当前邮件类型
---@param MailID number @邮件ID
---@param MailBoxType MailDefine.MailBoxType @邮件箱类型
---@return MailDefine.MailType 
function MailMgr:QueryMailTypeFromID(MailID)
	if MailID == nil then
		return 
	end

	local CacheMailList = self.CacheMailList or {}
	for MailType, Value in pairs(CacheMailList) do
		local MailList = Value or {}
		local MailInfo, _ = table.find_by_predicate(MailList, function(Item) return MailID == Item.ID end )
		if MailInfo ~= nil then
			return MailType
		end
	end
end

--获取邮件信笺样式
function MailMgr:GetStyleData(MailStyleID)
	return table.find_item(self.DecorationMap, MailStyleID, "ID" )
end

--- RedDot BEGIN ---
---

--根据邮件id 获取红点名称
function MailMgr:GetRedDotName(MailID)
	local RedDotNameItem, _ = table.find_by_predicate(self.RedDotNameList, function(Item) return MailID == Item.ID end )
	if RedDotNameItem ~= nil then 
		return RedDotNameItem.RedDotName or "";
	end
	RedDotNameItem = self.MailTypeRedDotNameList[MailID]
	if RedDotNameItem ~= nil then 
		return RedDotNameItem.RedDotName or "";
	end

	return ""
end

--增加邮件列表红点
function MailMgr:AddRedDot(MailType, MailID)
	if self:GetRedDotName(MailID) ~= "" then 
		return
	end
	local TypeRedDotName = self:GetRedDotName(MailType)
	if TypeRedDotName ~= "" then
		TypeRedDotName = TypeRedDotName .. "/" .. tostring(MailID)
		RedDotMgr:AddRedDotByName( TypeRedDotName, 1)
		table.insert(self.RedDotNameList, { ID = MailID, MailType = MailType, RedDotName = TypeRedDotName } )
		local TypeRedDot = self.MailTypeRedDotNameList[MailType]
		if TypeRedDot ~= nil then
			TypeRedDot.Count = TypeRedDot.Count + 1
		end
	end
end

--移除邮件列表红点
---@param InMailType  已经不在列表的邮件获取不到类型用传入类型
function MailMgr:RemoveRedDot(MailID, InMailType)
	local MailType = MailMgr:QueryMailTypeFromID(MailID)
	if MailType == nil then
		MailType = InMailType
	end
	local RedDotName = self:GetRedDotName(MailID)
	if RedDotName ~= "" and RedDotMgr:DelRedDotByName( RedDotName) then
		table.remove_item(self.RedDotNameList, MailID, "ID" )
		local TypeRedDot = self.MailTypeRedDotNameList[MailType]
		if TypeRedDot ~= nil then
			TypeRedDot.Count = TypeRedDot.Count - 1
			if TypeRedDot.Count == 0 then
				self:OverCapacityRedDot(MailType)
			end
		end
	end
end

-- 超容量红点检测
function MailMgr:OverCapacityRedDot(MailType)
	local TypeRedDot = self.MailTypeRedDotNameList[MailType]
	if TypeRedDot == nil or TypeRedDot.Count > 0 then
		return 
	end

	local IsOpen = false
	local MailCount = #(self.CacheMailList[MailType] or {})
	if self:GetMailTotalNum(MailType) - MailCount <= 10 then
		IsOpen = true
	end

	local OutBoxID = MailUtil.GetOutBoxID(MailType)
	if OutBoxID ~= nil then
		local SendMailCount = #(self.CacheMailList[OutBoxID] or {})
		if self:GetMailTotalNum(MailType) - SendMailCount <= 10 then
			IsOpen = true
		end
	end

	local TypeRedDotName = self:GetRedDotName(MailType) .. "/Type"
	if IsOpen then
		RedDotMgr:AddRedDotByName(TypeRedDotName, 1)
	else
		RedDotMgr:DelRedDotByName(TypeRedDotName)
	end
end

-- 清理多余红点
-- 场景：由于邮件超出显示容量 旧邮件会被新邮件顶掉 所以刷新一下红点列表
function MailMgr:RefreshRedDotList(MailType, MailList)
	local AllRedDot = table.find_all_by_predicate(self.RedDotNameList, function(Item) return MailType == Item.MailType end )
	for i = 1, #AllRedDot do
		local TarItem = table.find_by_predicate(MailList, function(Item) 
			if Item.Mail == nil then 
				return false
			else
				return AllRedDot[i].ID == Item.Mail.ID
			end
		 end )
		if TarItem == nil then
			self:RemoveRedDot(AllRedDot[i].ID, MailType)
		end
	end
end

-- 清除所有红点
function MailMgr:ClearAllMailRedDot()
	for i = 1, #self.RedDotNameList do
		RedDotMgr:DelRedDotByName(self.RedDotNameList[i].RedDotName)
	end
	for Key, _ in pairs(self.MailTypeRedDotNameList) do
		RedDotMgr:DelRedDotByName(self:GetRedDotName(Key) .. "/Type")
	end
	self.RedDotNameList = {}
	self.MailTypeRedDotNameList = {}
end

------ RedDot END ------


--- Interface BEGIN ---
---

--- 打开邮件主界面
function MailMgr:OpenMailMainView()
	local UE = _G.UE
	local ObjectMgr = _G.ObjectMgr
	self.CreatedNPCEntityID = nil
	local UActorManager = UE.UActorManager.Get()
	local finalRotator = UE.FRotator(0, 0, 0)
	local Params = UE.FCreateClientActorParams()
	Params.bUIActor = true
	self.LoadModeling = 0
	self:RegisterTimer(self.OnTimerUpdate, self.LoadModelTimeUpper)
	self.CreatedNPCEntityID = UActorManager:CreateClientActorByParams(UE.EActorType.Npc, 0, 1001174, RenderSceneDefine.MailActorLocation, finalRotator, Params)
	local NpcActor = ActorUtil.GetActorByEntityID(self.CreatedNPCEntityID)
	if NpcActor ~= nil then
		UE.UVisionMgr.Get():RemoveFromVision(NpcActor)
	end

	UIViewMgr:PreLoadWidgetByViewID(UIViewID.MailMainView, ObjectGCType.LRU)
	ObjectMgr:LoadObjectAsync(MailDefine.FirstFlyInStep4AnimPath, nil, ObjectGCType.LRU)
	ObjectMgr:LoadObjectAsync(MailDefine.FirstFlyInStep2AnimPath, nil, ObjectGCType.LRU)
	ObjectMgr:LoadObjectAsync(MailDefine.FirstFlyInStep1AnimPath, nil, ObjectGCType.LRU)
	self:SetAllMailGetDataTime()
end

-- 根据商品id 获取收到赠礼邮件ID
---@param GoodID number
---@return MailID 返回对应的邮件ID，没有对应邮件返回nil
function MailMgr:GetGiftMailIDByGoodID(GoodID)
	if (GoodID or 0) == 0 then
		return
	end
	local MailList = self:GetCacheMailList(MailDefine.MailType.Gift, false)
	for i = 1, #MailList do
		local GiftData = MailList[i].GiftData or {}
		if GoodID == GiftData.GoodID then
			return MailList[i].ID
		end
	end
	return
end

-- 根据邮件ID 打开赠礼邮件界面 收到赠礼页签
---@param MailID number
function MailMgr:OpenGiftMailViewByMailID(MailID)
	local BoxType = MailDefine.MailBoxType.InBox
	local MailType = MailDefine.MailType.Gift
	local MailData = MailMgr:GetMailData(MailID, MailType, BoxType)
	if MailData == nil then
		MsgTipsUtil.ShowTips( LSTR(740011) )
		return
	end

	self.OpenMainViewParams = { MailType = MailType, BoxType = BoxType, FirstPickMailID = MailID }
	self:OpenMailMainView()
end

-- 根据物品ID 查询本地所有收件箱附件中是否有对应的物品
---@param ItemID number
---@return true 有  false 无
function MailMgr:QueryMailAttachByItemID(ItemID)
	for _, Value in pairs(MailTypeList) do
		local MailList = self.CacheMailList[Value] or {}
		for i = 1, #MailList do
			local Attachment = MailList[i].Attachment or {}
			for j = 1, #Attachment do
				if Attachment[j].ResID == ItemID then
					return true
				end
			end
		end
	end

	return false
end

------ Interface END ------
return MailMgr
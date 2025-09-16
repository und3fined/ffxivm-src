local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local CommonUtil = require("Utils/CommonUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local TitleCfg = require("TableCfg/TitleCfg")
local AchievementTypeCfg = require("TableCfg/AchievementTypeCfg")
local TitleDefine = require("Game/Title/TitleDefine")
local TitleMainPanelVM = require("Game/Title/View/TitleMainPanelVM")

local TitleCollectOpt = ProtoCS.TitleCollectOpt
local RoleGender = ProtoCommon.role_gender
local AppendTitleType = TitleDefine.AppendTitleType
local RedDotMgr
local LSTR
local GameNetworkMgr
local EventMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.TitleOptCmd


---@class TitleMgr : MgrBase
local TitleMgr = LuaClass(MgrBase)

function TitleMgr:OnInit()
	self.CurrentTitle = 0     --0 表示没有称号 后台约定
	self.OwnedTitle = {}
	self.NewTitle = {}
	self.CollectedTitleList = {}
	self.TypeList = {}

	self.AllTitleData = {}
	self.VisionEntityTitleData = {}   -- self.VisionEntityTitleData[InEntityID] = Bitset
end

function TitleMgr:OnBegin()
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	RedDotMgr = _G.RedDotMgr
	self.TypeList = {}
	self.ItemMappingList = {}

	local AllAchievementType = AchievementTypeCfg:FindAllCfg() or {}
	table.merge_table(self.TypeList, AllAchievementType)
	table.merge_table(self.TypeList, AppendTitleType)
	table.sort(self.TypeList, function(Lift, Right) return Lift.Sort < Right.Sort  end )

	self:ReadAllTitleData()
	_G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.MISCELLANY_CERTIFICATE, function(ItemResID) return self:CheckItemUsedFun(ItemResID) end)
end

function TitleMgr:OnEnd()

end

function TitleMgr:OnShutdown()

end

function TitleMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TITLE, SUB_MSG_ID.TOCTitle, self.GetTitleRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TITLE, SUB_MSG_ID.TOCTitleMsg, self.TitleMsgRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TITLE, SUB_MSG_ID.TOCSet, self.TitleSetRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TITLE, SUB_MSG_ID.TOCCollect, self.TitleCollectRsp)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_TITLE, SUB_MSG_ID.TOCUpdate, self.TitleUpdateLastRsp)

	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnNetMsgVisionUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnNetMsgVisionUpdate)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_AVATAR_SYNC, self.OnNetMsgVisionPlayerStatusChanged)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_LEAVE, self.OnNetMsgVisionLeave)
end

function TitleMgr:OnRegisterTimer()

end

function TitleMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)

	self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)    
end

---@type  使用物品判断注册函数
---@return bool  @true代表已经拥有，不弹提示 @false代表未拥有，弹提示
function TitleMgr:CheckItemUsedFun(ItemResID)
	local TitleID = self.ItemMappingList[ItemResID] or 0
	if TitleID == 0 then
		return true
	else
		return self:QueryUnLockState(TitleID)
	end
end

--更新主角称号属性
function TitleMgr:OnGameEventMajorCreate()
	if self.CurrentTitle == 0 then
		return
	end
	self:UpdateRoleAttributeTitle(MajorUtil.GetMajorEntityID(), self.CurrentTitle)
end

--重连后重新获取称号信息
function TitleMgr:OnGameEventLoginRes(Param)
	self:GetTitleReq()
	self:TitleMsgReq()
end

-- 监听这个事件是为了处理 将最新的称号信息设置给刚创建出Actor的实体
function TitleMgr:OnGameEventVisionEnter(Params)
	local EntityID = Params.ULongParam1
	local Actor = ActorUtil.GetExistActorByEntityID(EntityID)
	if nil == Actor then
		return
	end
	local AttributeComp = Actor:GetAttributeComponent()
	if nil == AttributeComp then
		return
	end

	local CurTitleID = self.VisionEntityTitleData[EntityID]
	if CurTitleID ~= nil then
		self:UpdateRoleAttributeTitle(EntityID, CurTitleID)
	end
end

---对于视野内玩家的称号改变，需要缓存状态并分发事件
---@param EntityID number
---@param TitleID Bitset
---@private
function TitleMgr:CacheAndSentEvent(InEntityID, TitleID)
	if InEntityID == MajorUtil.GetMajorEntityID() then
		if self.CurrentTitle ~= TitleID then
			-- 报错
		end
	else
		local OldTitleID = self.VisionEntityTitleData[InEntityID]
		self.VisionEntityTitleData[InEntityID] = TitleID

		if OldTitleID ~= TitleID  then
			local Params = {
				TitleID =  TitleID,
				EntityID = InEntityID,
			}
			EventMgr:SendEvent(EventID.TitleChange, Params)
			local CppParams = _G.EventMgr:GetEventParams()
			CppParams.ULongParam1 = Params.EntityID
			CppParams.IntParam1 = Params.TitleID
			EventMgr:SendCppEvent(EventID.RoleTitleChange, CppParams)

			local RoleID = ActorUtil.GetRoleIDByEntityID(InEntityID) or 0
			self:UpdateRoleVMTitleID(RoleID, TitleID)
			self:UpdateRoleAttributeTitle(InEntityID, TitleID)
		end
	end
end

--------- 视野协议相关

function TitleMgr:UpdateTitleFromAvatarList(EntityID, AvatarList)
	for _, Avatar in ipairs(AvatarList) do
		if Avatar.Key == ProtoCS.VDataType.Title then
			self:CacheAndSentEvent(EntityID, tonumber(Avatar.Value))
		end
	end
end

function TitleMgr:OnNetMsgVisionUpdate(MsgBody)
	local VisionRsp = MsgBody.Enter or MsgBody.Query
	local Entities = VisionRsp and VisionRsp.Entities
	if Entities == nil then return end

	for _, Entity in ipairs(Entities) do
		local AvatarList = ((Entity.Role or {}).Avatars or {}).AvatarList
		if AvatarList ~= nil then
			self:UpdateTitleFromAvatarList(Entity.ID, AvatarList)
		end
	end
end

function TitleMgr:OnNetMsgVisionPlayerStatusChanged(MsgBody)
	local AvatarList = MsgBody.AvatarSync and MsgBody.AvatarSync.AvatarList
	if AvatarList == nil then
		return
	end

	self:UpdateTitleFromAvatarList(MsgBody.AvatarSync.EntityID, AvatarList)
end

function TitleMgr:OnNetMsgVisionLeave(MsgBody)
	local Leave = MsgBody.Leave
	if Leave == nil then return end
	local Entities = Leave.Entities
	if Entities == nil then return end

	for _, Value in ipairs(Entities) do
		self.VisionEntityTitleData[Value] = nil
	end
end

--------- 称号协议相关

--- 请求玩家当前称号
function TitleMgr:GetTitleReq()
	local MsgID = CS_CMD.CS_CMD_TITLE
	local SubMsgID = SUB_MSG_ID.TOCTitle
	local MsgBody = { 
		Cmd = SUB_MSG_ID.TOCTitle,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 返回玩家当前称号
function TitleMgr:GetTitleRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Title then
		return
	end

	local SetTitle = MsgBody.Title.Title
	if SetTitle ~= nil then
		self.CurrentTitle = SetTitle

		self:UpdateRoleVMTitleID(MajorUtil.GetMajorRoleID(), SetTitle)
		self:UpdateRoleAttributeTitle(MajorUtil.GetMajorEntityID(), SetTitle)
		local Params = {
			TitleID =  SetTitle,
			EntityID = MajorUtil.GetMajorEntityID()
		}
		EventMgr:SendEvent(EventID.TitleChange, Params)
		local CppParams = _G.EventMgr:GetEventParams()
		CppParams.ULongParam1 = Params.EntityID
		CppParams.IntParam1 = Params.TitleID
		EventMgr:SendCppEvent(EventID.RoleTitleChange, CppParams)
	end
end

--- 请求玩家称号信息
function TitleMgr:TitleMsgReq()
	local MsgID = CS_CMD.CS_CMD_TITLE
	local SubMsgID = SUB_MSG_ID.TOCTitleMsg
	local MsgBody = { 
		Cmd = SUB_MSG_ID.TOCTitleMsg,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 返回玩家称号信息
function TitleMgr:TitleMsgRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.TitleMsg then
		return
	end
	local TitleMsg = MsgBody.TitleMsg
	self:SetOwnedTitle(TitleMsg.OwnedTitle)
	self:SetNewTitle(TitleMsg.NewTitle)
	self:SetCollectedTitleList(TitleMsg.CollectedTitle)
	if _G.UIViewMgr:IsViewVisible(UIViewID.TitleMainPanelView) then
		local TitleMainPanelView = _G.UIViewMgr:FindVisibleView(UIViewID.TitleMainPanelView)
		TitleMainPanelView:RefreshSelectTitleType()
	end
end

--- 请求设置玩家称号
function TitleMgr:TitleSetReq(SetTitle)
	local MsgID = CS_CMD.CS_CMD_TITLE
	local SubMsgID = SUB_MSG_ID.TOCSet
	local MsgBody = {
		Cmd = SUB_MSG_ID.TOCSet,
		Setting = { Title = SetTitle }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 返回设置玩家称号
function TitleMgr:TitleSetRsp(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Setting then
		return
	end
	local SetTitleID = MsgBody.Setting.Title
	if SetTitleID ~= nil then
		if self.CurrentTitle ~= nil and self.CurrentTitle ~= 0 then
			TitleMainPanelVM:ClearUseState(self.CurrentTitle)
		end
		TitleMainPanelVM:SetTitleSucceed(SetTitleID)    -- 0代表取消设置
		self.CurrentTitle = SetTitleID
		self:UpdateRoleVMTitleID(MajorUtil.GetMajorRoleID(), SetTitleID)
		self:UpdateRoleAttributeTitle(MajorUtil.GetMajorEntityID(), SetTitleID)
		TitleMainPanelVM:SetCurrentTitleText(self:GetCurrentTitleText())
		if SetTitleID ~= 0 then
			_G.MsgTipsUtil.ShowTips(LSTR(710016))
		end

		local Params = {
			TitleID =  SetTitleID,
			EntityID = MajorUtil.GetMajorEntityID()
		}
		EventMgr:SendEvent(EventID.TitleChange, Params)
		local CppParams = _G.EventMgr:GetEventParams()
		CppParams.ULongParam1 = Params.EntityID
		CppParams.IntParam1 = Params.TitleID
		EventMgr:SendCppEvent(EventID.RoleTitleChange, CppParams)
	end
end

--- 收藏/取消收藏玩家称号
function TitleMgr:TitleCollectReq(TargetTitle, IsCollect)
	local MsgID = CS_CMD.CS_CMD_TITLE
	local SubMsgID = SUB_MSG_ID.TOCCollect
	local MsgBody = {
		Cmd = SUB_MSG_ID.TOCCollect,
		Collect = { Title = TargetTitle, opt = IsCollect }
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 返回收藏/取消收藏玩家称号
function TitleMgr:TitleCollectRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.Collect then
		return
	end
	local Collect = MsgBody.Collect

	if Collect.opt == TitleCollectOpt.TCOCancelCollect then 
		if table.contain(self.CollectedTitleList, Collect.Title) then 
			table.remove_item(self.CollectedTitleList, Collect.Title)
		end
		TitleMainPanelVM:CollectFinish(Collect.Title, false)
	elseif Collect.opt == TitleCollectOpt.TCOCollect then
		if not table.contain(self.CollectedTitleList, Collect.Title) then
			table.insert(self.CollectedTitleList, 1, Collect.Title)
		end
		TitleMainPanelVM:CollectFinish(Collect.Title, true)
	end
end

--- 取消玩家所有新称号状态
function TitleMgr:TitleUpdateLastReq()
	local MsgID = CS_CMD.CS_CMD_TITLE
	local SubMsgID = SUB_MSG_ID.TOCUpdate
	local MsgBody = {
		Cmd = SUB_MSG_ID.TOCUpdate,
	}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 取消玩家称号新状态
function TitleMgr:TitleUpdateLastRsp(MsgBody)
	if nil == MsgBody or nil == MsgBody.Update then
		return
	end
	local Success = MsgBody.Update.Success
	if Success then
		self:SetNewTitle({})
	end
end

--------- 功能相关
--设置当前称号ID
function TitleMgr:SetCurrentTitle(CurrentTitle)
	if CurrentTitle ~= nil and self.CurrentTitle ~= CurrentTitle and self:QueryUnLockState(CurrentTitle) then
		self:TitleSetReq(CurrentTitle)
	end
end

--设置拥有称号列表
function TitleMgr:SetOwnedTitle(OwnedTitle)
	self.OwnedTitle = OwnedTitle or {}
end

--设置新解锁的称号列表
function TitleMgr:SetNewTitle(NewTitle)
	local NewTitleList = NewTitle or {}
	local OldTitleList = self.NewTitle
	for i = 1, #OldTitleList do
		local TypeRedDotName = TitleDefine.RedDotName .. '/' .. tostring(OldTitleList[i])
		RedDotMgr:DelRedDotByName( TypeRedDotName )
	end
	for i = 1, #NewTitleList do
		local TypeRedDotName = TitleDefine.RedDotName .. '/' .. tostring(NewTitleList[i])
		RedDotMgr:AddRedDotByName( TypeRedDotName, 1 )
	end
	self.NewTitle = NewTitle or {}
end

--设置收藏的称号列表
function TitleMgr:SetCollectedTitleList(CollectedTitle)
	self.CollectedTitleList = {}
	for _, Value in pairs(CollectedTitle) do
		table.insert(self.CollectedTitleList, 1, Value) --顺序倒一下
	end
	self.AllTitleData[AppendTitleType[1].ID] = self.CollectedTitleList
end

--收藏某称号
function TitleMgr:CollectedTitle(Title)
	if self:QueryCollectedState(Title) then
		return 
	end
	self:TitleCollectReq(Title, TitleCollectOpt.TCOCollect)
end

--取消收藏某称号
function TitleMgr:UnCollectedTitle(Title)
	if self:QueryCollectedState(Title) then
		self:TitleCollectReq(Title, TitleCollectOpt.TCOCancelCollect)
	end
end

-- 查询当前称号是否在收藏中
function TitleMgr:QueryCollectedState(Title)
	return table.contain(self.CollectedTitleList, Title)
end

-- 查询当前称号是否解锁
function TitleMgr:QueryUnLockState(Title)
	return table.contain(self.OwnedTitle, Title)
end

-- 读取所有称号数据
function TitleMgr:ReadAllTitleData()
	self.AllTitleData = {}
	local AllTitleID = {}
	local AllCfgData = TitleCfg:FindAllCfg()
	for _, Value in pairs(AllCfgData) do
		if Value.ID ~= nil then
			local TitleType = Value.Type or ""
			self.AllTitleData[TitleType] = self.AllTitleData[TitleType] or {}
			if (Value.ItemID or 0) ~= 0 then
				self.ItemMappingList[Value.ItemID] = Value.ID
			end
			table.insert(self.AllTitleData[TitleType], Value.ID )
			table.insert(AllTitleID, Value.ID)
		end
	end

	self.AllTitleData[AppendTitleType[2].ID] = AllTitleID
end

--查询称号本地数据
function TitleMgr:QueryTitleTableData(TitleID)
	return TitleCfg:FindCfgByKey(TitleID)
end

-- 获取所有称号分类
function TitleMgr:GetAllTitleType()
	return self.TypeList
end

-- 获取某分类下拥有在显示的称号数量
function TitleMgr:GetShowTitleNumByType(TypeID)
	local TarTypeList = self.AllTitleData[TypeID] or {}
	local Num = #TarTypeList
	for i = 1, #TarTypeList do
		local TitleCfg = TitleMgr:QueryTitleTableData(TarTypeList[i])
		if TitleCfg ~= nil and TitleCfg.Display == 1 and not self:QueryUnLockState(TitleCfg.ID) then
			Num = Num - 1
		end
	end
	return Num
end

-- 获取某分类下的所有称号
function TitleMgr:GetAllTitleFromType(TypeID)
	if TypeID == AppendTitleType[1].ID then
		return self.AllTitleData[TypeID] or {}
	else
		local TitleList =  self.AllTitleData[TypeID] or {}
		local AllSortFun = function(AID, BID)
			local ALock = self:QueryUnLockState(AID)  --table.contain(self.OwnedTitle, AData.ID)
			local BLock = self:QueryUnLockState(BID)  -- table.contain(self.OwnedTitle, BData.ID)

			if ALock ~= BLock then
				if ALock then
					return true
				else
					return false
				end
			end

			local _, AIndex = table.find_item(self.NewTitle, AID)
			local _, BIndex = table.find_item(self.NewTitle, BID)
			if AIndex and BIndex then
				return AIndex > BIndex
			elseif AIndex and (not BIndex) then
				return true
			elseif BIndex and (not AIndex) then
				return false
			end

			local AData = self:QueryTitleTableData(AID)
			local BData = self:QueryTitleTableData(BID)
			return	AData.Priority < BData.Priority     -- 策划设计优先级数值越小优先级越高
		end

		table.sort(TitleList, AllSortFun)
		return TitleList
	end
end

------------------ 对外使用

--获取当前称号ID
function TitleMgr:GetCurrentTitle()
	return self.CurrentTitle
end

--获取当前称号文本
function TitleMgr:GetCurrentTitleText()
	local Gender = MajorUtil.GetMajorGender()
	return self:GetTargetTitleText(self:GetCurrentTitle(), Gender)
end

--获取目标称号文本
---@param TargetTitleID number @目标称号ID
---@param TargetGender RoleGender @目标佩戴者性别
function TitleMgr:GetTargetTitleText(TargetTitleID, TargetGender)
	local CurrtentTitleCfg = self:QueryTitleTableData(TargetTitleID)
	if CurrtentTitleCfg == nil then
		return ""
	end

	local TitleText
	if TargetGender == RoleGender.GENDER_MALE then
		TitleText = CurrtentTitleCfg.MaleName or ""
	elseif TargetGender == RoleGender.GENDER_FEMALE then
		TitleText = CurrtentTitleCfg.FemaleName or ""
	else
		TitleText = ""
	end

	return TitleText
end

--获取当前称号位置   
---@param TitleID number @称号ID
---@return bool @true 是名称上  false 是名称下显示
function TitleMgr:GetTargetTitleTextLocation(TitleID) 
	local Cfg = self:QueryTitleTableData(TitleID)
	if Cfg ~= nil and Cfg.Front ~= nil  then
		return Cfg.Front
	end
	return true
end

---更新主角称号ID
function TitleMgr:UpdateRoleVMTitleID( RoleID, NewTitleID)
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)

	if RoleVM then
		RoleVM:SetTitleID(NewTitleID)
	end
end

--更新角色称号属性
function TitleMgr:UpdateRoleAttributeTitle(EntityID, NewTitleID)
	local Actor = ActorUtil.GetExistActorByEntityID(EntityID)
	if nil == Actor then
		return
	end
	local AttributeComp = Actor:GetAttributeComponent()
	if nil == AttributeComp then
		return
	end
	AttributeComp.Title = NewTitleID
end

--获取当前所有称号缓存
---@param EntityID number
function TitleMgr:GetTitleDataFromEntityID(EntityID)
	if self.VisionEntityTitleData[EntityID] == nil then
		local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
		local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
		if RoleVM then
			self.VisionEntityTitleData[EntityID] = RoleVM.TitleID
			return RoleVM.TitleID
		end
	end
	return self.VisionEntityTitleData[EntityID]
end

-- 装饰称号文本
function TitleMgr:DecorationTitle(TitleText)
	if (TitleText or "") == "" then
		return
	end
	return  CommonUtil.GetTextFromStringWithSpecialCharacter("<10004>" .. TitleText .. "<10005>")
end

--查询是否是新称号
function TitleMgr:CheckNewTitle(TitleId)
	return table.contain(self.NewTitle, TitleId)
end

--移除新称号
function TitleMgr:RemoveNewTitle(TitleId)
	if self:CheckNewTitle(TitleId) then
		table.remove_item(self.NewTitle, TitleId)
	end
end

--移除种类下所有新称号
function TitleMgr:RemoveNewTitleFromType(TitleType)
	local AllTitle = self:GetAllTitleFromType(TitleType)
	for i = 1, #AllTitle do
		if self:CheckNewTitle(AllTitle[i]) then
			self:RemoveNewTitle(AllTitle[i])
		end
	end
end

-- 获取装饰后的成就文本
---@param TargetTitleID number @目标称号ID
---@param TargetGender RoleGender @目标佩戴者性别
function TitleMgr:GetDecoratedTitleText(TitleID, Gender)
	return TitleMgr:DecorationTitle(TitleMgr:GetTargetTitleText(TitleID, Gender))
end

--要返回当前类
return TitleMgr
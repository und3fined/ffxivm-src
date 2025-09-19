--
--Author: ZhengJanChuan
--Date: 2024-02-22 19:06
--Description:由于外观跟装备十分的相似, 特别备注,Appearance属于外观, Equipment属于装备
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ClosetCfg = require("TableCfg/ClosetCfg")
local ClosetCharismCfg = require("TableCfg/ClosetCharismCfg")
local ClosetPresetSuitCfg = require("TableCfg/ClosetPresetSuitCfg")
local ClosetCameraParamsCfg = require("TableCfg/ClosetCameraParamsCfg")
local ProfClassCfg = require("TableCfg/ProfClassCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ClosetBindEObjectCfg = require("TableCfg/ClosetBindEObjectCfg")
local ProtoCS = require("Protocol/ProtoCS")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local ItemUtil = require("Utils/ItemUtil")
local CommonUtil = require("Utils/CommonUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoRes = require("Protocol/ProtoRes")
local PworldCfg = require("TableCfg/PworldCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")
local CondCfg = require("TableCfg/CondCfg")
local FuncCfg = require("TableCfg/FuncCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")
local WardrobeAppearanceItemVM = require("Game/Wardrobe/VM/WardrobeAppearanceItemVM")
local UIBindableList = require("UI/UIBindableList")
local ClosetGlobalCfg = require("TableCfg/ClosetGlobalCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CsClosetCmd
local EquipmentPartList = ProtoCommon.equip_part
local ItemCondType = ProtoRes.CondType


local LSTR

local GameNetworkMgr
local EventMgr
local UIViewMgr
local FLOG_INFO

---@class WardrobeMgr : MgrBase
local WardrobeMgr = LuaClass(MgrBase)

---OnInit
function WardrobeMgr:OnInit()
	--只初始化自身模块的数据，不能引用其他的同级模块
	self.CollectionList = {}
	--预设套装 table {ID, Name, Suits, RelatedProf}, Suits = table {PartID = {Avatar , Color}}
	self.Suits = {}
	--当前使用套装
	self.UsedSuitID = 0
	--套装上限
	self.SuitUpperLimit = 0
	--已领取魅力奖励的阶段
	self.ClaimedCharismReward = 0
	--已激活/解锁外观<ApperanceID, ColorID, ActivedColor, ProfLimit, RaceLimit, GenderLimit, LevelLimit, ClassLimit, EnableDye, RegionDye>
	self.UnlockedAppearance = {}
	--当前的魅力值
	self.ChrismValue = 0
	--界面展示用的模型数据
	self.ViewSuit = {}
	--染色界面使用的模型数据
	self.StainViewSuit = {}
	--正在穿戴的外观IDList MAP<PartID, <Avatar, Color, RegionDye>>
	self.CurAppearanceIDList = {}
	--- 点击进入界面
	self.IsClickBtnEnter = false
	--- 是否需要跟服务器进行指定外观ID 请求
	self.IsUpdateUnlock = false 
	-- 常用染色试剂
	self.UsedStainList = {}
	
	--- 外观染色的数组 Map<AppID, Colors>
	self.AppearanceActiveColor = {}

	-- 外观收集数量总数
	self.AppearanceCollectTotal = {}
	-- 已解锁的外观收集数量
	self.UnlockAppearanceCollect = {}

	-- 解锁的所有的外观装备Gid
	self.UnlockGidsList = {}

	-- 解锁外观List
	self.PlanUnlockAppearanceList = {}
 
	-- 版本号
	self.GameVersionName = self:GetGameVersionName()

	-- 随机外观<外观id, 随机出来的EquipID>
	self.RandomAppEquipList = {}

	-- 随机外观下次刷新时间
	self.RandomAppRefreshTime = 0

	-- 随机外观计时器
	self.RandomAppRefreshTimer = nil

	-- 快捷使用系统接入，判断此道具外观是否已解锁过
	local function CheckItemUsed(ItemResID)
		local FindItemCfg = ItemCfg:FindCfgByKey(ItemResID)
		if FindItemCfg == nil then return false end
		local FindFuncCfg = FuncCfg:FindCfgByKey(FindItemCfg.UseFunc)
		if FindFuncCfg == nil then return false end
		local AppID = FindFuncCfg.Func[1].Value[1]
		return self:GetIsUnlock(AppID)
	end
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FASHION, CheckItemUsed)
end

function WardrobeMgr:ClearStainViewSuit()
	self.StainViewSuit = {}
end

function WardrobeMgr:SetStainViewSuit(PartID, AppID, ColorID, RegionDye)
	if self.StainViewSuit == nil then
		self.StainViewSuit  = {}
	end
	if PartID ~= nil then
		if self.StainViewSuit[PartID] == nil then
			self.StainViewSuit[PartID] = {}
			self.StainViewSuit[PartID].Avatar = AppID
			self.StainViewSuit[PartID].Color = ColorID
			self.StainViewSuit[PartID].RegionDye = RegionDye
			_G.FLOG_ERROR( "WardrobeMgr:SetStainViewSuit[part] is nil  "  .. table_to_string(self.StainViewSuit[PartID].RegionDye))
			return
		end
	
		for key, value in pairs(self.StainViewSuit) do
			if tonumber(key) == PartID then
				self.StainViewSuit[PartID].Avatar = AppID
				self.StainViewSuit[PartID].Color = ColorID
				self.StainViewSuit[PartID].RegionDye = RegionDye
				_G.FLOG_ERROR( "WardrobeMgr:SetStainViewSuit[part] is not nil  "  .. table_to_string(self.StainViewSuit[PartID].RegionDye))
			end
		end
	end
end

function WardrobeMgr:GetStainViewSuit()
	return self.StainViewSuit
end

function WardrobeMgr:GetStainViewSuitByAppID(AppID)
	for _, v in pairs(self.StainViewSuit) do
		if v.Avatar == AppID then
			return v
		end
	end
	return  {}
end


function WardrobeMgr:SetUnlockGidsList(List)
	self.UnlockGidsList = List
end


function WardrobeMgr:GetUsedStainList()
	return self.UsedStainList
end


function WardrobeMgr:PushUsedStainList(ColorID)
	local IsContain = false
	for _, v in ipairs(self.UsedStainList) do
		if v.ID == ColorID then
			v.UsedTime = TimeUtil.GetServerLogicTimeMS()
			IsContain = true
			break
		end
	end

	-- table.sort(self.UsedStainList, function(a, b) 
	-- 	return a.UsedTime > b.UsedTime
	-- end)

	if not IsContain then 
		if #self.UsedStainList >= 5 then
			table.remove(self.UsedStainList, 5)
		end

		table.insert(self.UsedStainList, 1, {ID = ColorID, UsedTime = TimeUtil.GetServerLogicTimeMS() })
	end
end

---OnBegin
function WardrobeMgr:OnBegin()
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
	UIViewMgr = _G.UIViewMgr
	FLOG_INFO = _G.FLOG_INFO
end

function WardrobeMgr:OnEnd()
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
	self.IsClickBtnEnter = false
	self.IsUpdateUnlock = false
	self.AppearanceCollectTotal = {}
	self.UnlockAppearanceCollect = {}
end

function WardrobeMgr:OnShutdown()
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
	-- 清除定时器
	if self.RandomAppRefreshTimer ~= nil then
        self:UnRegisterTimer(self.RandomAppRefreshTimer)
        self.RandomAppRefreshTimer = nil
    end
end

function WardrobeMgr:OnRegisterNetMsg()
	--示例代码先注释 以免影响正常逻辑
	--衣橱数据查询
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_QUERY, self.OnClosetQueryRsp)
	--衣橱外观解锁					
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_UNLOCK, self.OnClosetUnLockRsp)
	--衣橱单件外观穿戴
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_CLOTHING, self.OnClosetClothingRsp)
	--衣橱单件外观取消穿戴
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_UNCLOTHING, self.OnClosetUnClothingRsp)
	--衣橱收藏
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_COLLECT, self.OnClosetCollectRsp)
	--衣橱激活染色
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_ACTIVE_STAIN, self.OnClosetActiveStainRsp)
	--衣橱染色	
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_DYE, self.OnClosetDyeRsp)
	--衣橱染色取消
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_DYE_RECOVERY, self.OnClosetRecoveryRsp)
	--衣橱查询染色
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_ACTIVE_COLOR, self.OnClosetActiveColor)
	--衣橱预设套装扩充
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_SUIT_ENLARGE, self.OnClosetEnlargeSuitRsp)
	--衣橱预设套装改名
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_SUIT_RENAME, self.OnClosetSuitRenameRsp)
	--衣橱套装保存
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_SUIT_SAVE, self.OnClosetSuitSaveRsp)
	--衣橱预设套装关联职业
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_SUIT_LINK_PROF, self.OnClosetSuitLinkProfRsp)
	--衣橱领取魅力值奖励
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_CHARISM_REWARD, self.OnClosetCharismRewardRsp)
	--衣橱使用预设套装
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_CHOOSESUIT, self.OnClosetChooseSuitRsp)
	--衣橱查询解锁列表
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_QUERY_UNLOCK, self.OnClosetQueryUnlockRsp)
	--衣橱查询指定外观ID解锁外观数据
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_QUERY_PART_UNLOCK, self.OnClosetQueryPartUnlockRsp)
	--衣橱外观推送（当前外观更新）
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_APPEAR_NOTIFY , self.OnClosetAppearNoitfy)
	--衣橱随机外观
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_RANDOM_PATTERN , self.OnClosetRandomPatternRsq)
	--衣橱区域染色
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.Cs_CLOSET_REGION_DYE, self.OnClosetRegionDyeRsp)
	-- 常用染色查询/推送
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_USED_STAIN_QUERY, self.OnClosetUsedStainQuery)
	-- 常用试剂保存
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_USED_STAIN_SAVE, self.OnClosetUsedStainSave)
	-- 套装使用
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_CLOSET, SUB_MSG_ID.CS_CLOSET_SUIT_CLOTHING, self.OnClosetSuitClothing)
end

function WardrobeMgr:OnRegisterGameEvent()
	--示例代码先注释 以免影响正常逻辑
	self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventLoginRes)
end


function WardrobeMgr:OnGameEventLoginRes()
	if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDShadow) then
		self:SendClosetQueryReq()
	end
end

function WardrobeMgr:OnClosetModuleOpen(ModuleID)
	if ModuleID == ProtoCommon.ModuleID.ModuleIDShadow then
        self:SendClosetQueryReq()
    end
end

--- 查询当前外观解锁数据
function WardrobeMgr:SendClosetQueryPartUnlockReq(AppID)
	if not self.IsUpdateUnlock then
		return
	end
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_QUERY_PART_UNLOCK

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.PartUnlock = {ID = AppID}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function WardrobeMgr:OnClosetQueryPartUnlockRsp(MsgBody)
	if MsgBody == nil or MsgBody.PartUnlock == nil then
	    return
	end 
	local Data = MsgBody.PartUnlock 
	if  Data.Unlocked ~= nil and Data.Unlocked.AppearanceID ~= nil then
		self.UnlockedAppearance[Data.Unlocked.AppearanceID] = Data.Unlocked
		EventMgr:SendEvent(EventID.WardrobeUnlockIDUpdate, Data.Unlocked.AppearanceID)
	end
end

--- 发送衣橱数据请求
function WardrobeMgr:SendClosetQueryReq()
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_QUERY

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 衣橱数据请求回调
function WardrobeMgr:OnClosetQueryRsp(MsgBody)
	if MsgBody == nil or MsgBody.Query == nil then
	    return
	end 
	local Data = MsgBody.Query 

	--收藏列表
	self.CollectionList = Data.CollectionList
	--预设套装
	self.Suits = Data.Suits -- <ID, Name, Suit, RelatedProf, ProfID>
	--当前使用套装
	self.UsedSuitID = Data.UsedSuitID
	--套装上限
	self.SuitUpperLimit = Data.SuitUpperLimit
	--已领取
	self.ClaimedCharismReward = Data.ClaimedCharismReward

	--当前穿戴的外观放进解锁外观列表中
	for _, value in ipairs(Data.Unlocked) do
		local TempValue = value
		self.UnlockedAppearance[value.AppearanceID] = TempValue
	end

	--当前的魅力值
	self.ChrismValue = Data.ChrismValue
	--当前穿戴的外观
	self.CurAppearanceIDList = Data.Parts or {}

	-- 初始化界面展示外观
	self:InitViewSuit()
	WardrobeMgr:SendClosetRandomPatternReq()
	WardrobeMgr:SetIsUpdateUnlock(true)
	WardrobeMgr:SendClosetQueryUnlockReq(0)

	EventMgr:SendEvent(EventID.WardrobeUpdate, {bUpdate = true})
end

function WardrobeMgr:SetIsUpdateUnlock(IsUpdate)
	self.IsUpdateUnlock = IsUpdate
end

---解锁列表查询
---@param PageIndex number 页签
function WardrobeMgr:SendClosetQueryUnlockReq(PageIndex)
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_QUERY_UNLOCK

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.QueryUnlock = {UnlockedAppearanceIndex = PageIndex}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---解锁列表数据
function WardrobeMgr:OnClosetQueryUnlockRsp(MsgBody)
	if MsgBody == nil or MsgBody.QueryUnlock == nil then
	    return
	end 
	local Data = MsgBody.QueryUnlock 
	if Data == nil then
	    return
	end	

	local UnlockedAppearanceIndex = Data.NextUnlockedIndex

	local _ <close> = CommonUtil.MakeProfileTag(string.format("WardrobeMgr:OnClosetQueryUnlockRsp() UnlockedAppearanceIndex=%d", UnlockedAppearanceIndex))

	for _, value in ipairs(Data.Unlocked) do
		local TempValue = value
		self.UnlockedAppearance[value.AppearanceID] = TempValue
	end

	self.IsUpdateUnlock = UnlockedAppearanceIndex ~= 0

	if UnlockedAppearanceIndex ~= 0 then
		self:SendClosetQueryUnlockReq(UnlockedAppearanceIndex)
	else
		WardrobeMgr:SetRedDot()
		EventMgr:SendEvent(EventID.WardrobeUpdate)
	end
end

--- 解锁外观请求
---@param table <ID, GIDs>
function WardrobeMgr:SendClosetUnLockReq(List)
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_UNLOCK

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	local Acitves = List
	MsgBody.Unlock = {Acitves = Acitves}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 解锁外观请求回调
function WardrobeMgr:OnClosetUnLockRsp(MsgBody)
	if MsgBody == nil or MsgBody.Unlock == nil then
	    return
	end 
	local Data = MsgBody.Unlock 

	if table.is_nil_empty(Data.Acitves) then
		FLOG_INFO(string.format(" =====  WardrobeMgr UnlockRsp AppID Data.Acitves Is  Nil"))
		return
	end

	-- 解锁的外观以及对应的装备ID
	for _, v in ipairs(Data.Acitves) do
		-- FLOG_INFO(string.format(" =====  WardrobeMgr UnlockRsp AppID : %d", v.AppearanceID))
		if self.UnlockedAppearance[v.AppearanceID] ~= nil then
			self.UnlockedAppearance[v.AppearanceID]= {}
		end
		self.UnlockedAppearance[v.AppearanceID] = v
	end

	self.ChrismValue = Data.CharismValue

	local Params = {}
	Params.ItemVMList = UIBindableList.New(WardrobeAppearanceItemVM)
	Params.Title = _G.LSTR(1080001)
	Params.HideClickItem = true
	local AppList = {}
	local ItemVMList = {}

	-- 如果解锁的是成就外观，塞入list, 
	for _, v in ipairs(Data.Acitves) do
		local Cfg = ClosetCfg:FindCfgByKey(v.AppearanceID)
		if Cfg then
			if #WardrobeUtil.GetAchievementIDList(v.AppearanceID) > 0 then
				table.insert(AppList, v.AppearanceID)
			else
				local VM = {}
				VM.ResID = WardrobeUtil.GetIsSpecial(v.AppearanceID) and WardrobeUtil.GetUnlockCostItemID(v.AppearanceID) or WardrobeUtil.GetEquipIDByAppearanceID(v.AppearanceID)
				VM.Num = 1
				VM.GID = 1
				VM.ItemName = WardrobeUtil.GetEquipmentAppearanceName(v.AppearanceID)
				VM.ItemNameVisible = true
				VM.IsCanBeSelected = false
				Params.ItemVMList:AddByValue(VM)
				table.insert(ItemVMList, VM)
			end
		end
	end
	if #ItemVMList > 0 and #AppList == 0 then
		UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	end
	
	if #AppList > 0 then
		_G.LegendaryWeaponMgr:InsertTask(AppList)
	end

	self.UnlockGidsList = {}
	WardrobeMgr:SetRedDot()
	EventMgr:SendEvent(EventID.WardrobeUnlockUpdate, {UnlockAppearanceList = Data.Acitves})
	-- 更新魅力值
	EventMgr:SendEvent(EventID.WardrobeCharismValueUpdate)
	
end

--- 取消/收藏外观请求
---@param ID number 外观id
---@param IsCollect bool 收藏or取消收藏
function WardrobeMgr:SendClosetCollectReq(ID, IsCollect)
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_COLLECT

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Collect = {ID = ID, IsCollect = IsCollect}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 取消/收藏外观回调
function WardrobeMgr:OnClosetCollectRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.Collect 
	if Data == nil then
	    return
	end

	local IsCollect = Data.IsCollect
	local ID = Data.ID

	if IsCollect then
		if not table.contain(self.CollectionList, ID) then
			table.insert(self.CollectionList, ID)
		end
	else
		--删除
		for index, value in ipairs(self.CollectionList) do
			if value == ID then
				table.remove(self.CollectionList, index)
				break
			end
		end
	end

	if IsCollect then
		MsgTipsUtil.ShowTips(LSTR(1080002))
	else
		MsgTipsUtil.ShowTips(LSTR(1080003))
	end

	--Todo更新界面
	EventMgr:SendEvent(EventID.WardrobeCollectUpdate)
	
end

--- 扩充预设请求
---@param SuitID number 衣橱预设ID
function WardrobeMgr:SendClosetEnlargeSuitReq(SuitID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_SUIT_ENLARGE

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.EnlargeSuit = {SuitID = SuitID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 扩充预设回调
function WardrobeMgr:OnClosetEnlargeSuitRsp(MsgBody)
	if MsgBody == nil or  MsgBody.EnlargeSuit == nil then
	    return
	end 
	local Data = MsgBody.EnlargeSuit 
	local EnlargeSuitID = Data.SuitID
	self.SuitUpperLimit = EnlargeSuitID
	EventMgr:SendEvent(EventID.WardrobeEnlagerPresets, {EnlargeSuitID = EnlargeSuitID})
	
end

---@param SuitID number 衣橱预设ID
---@param NewName string 预设新名字
function WardrobeMgr:SendClosetSuitRenameReq(SuitID, NewName)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_SUIT_RENAME

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SuitRename = {SuitID = SuitID, NewName = NewName}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 预设改名回调
function WardrobeMgr:OnClosetSuitRenameRsp(MsgBody)
	if MsgBody == nil or  MsgBody.SuitRename == nil then
	    return
	end 
	local Data = MsgBody.SuitRename 

	local SuitID = Data.SuitID
	local NewName =  Data.NewName

	MsgTipsUtil.ShowTips(LSTR(1080100)) --"预设套装改名成功"

	local IsExist = false
	for i, v in ipairs(self.Suits) do
		if v.ID == SuitID then
			IsExist = true
			self.Suits[i].SuitName = NewName
			self.Suits[i].Name = NewName
			break
		end
	end

	if not IsExist then
		local CurSuit = self:GetPresetsClient(SuitID)
		CurSuit.SuitName = NewName
		CurSuit.Name = NewName
		table.insert(self.Suits, CurSuit)
	end

	-- 更新界面
	EventMgr:SendEvent(EventID.WardrobePresetSuitUpdate, {SuitID = SuitID})
end

--- 保存预设套装请求
---@param Avatar number
---@param Color number
---@param Appearance <Avatar, Color>
---@param Suit <int32, Appearance>
function WardrobeMgr:SendClosetSuitSaveReq(Suit, ID, NewName, ProfID, RelatedProf)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_SUIT_SAVE

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SuitSave = {Suit = Suit, ID = ID, SuitName = NewName, ProfID = ProfID, RelatedProf  = RelatedProf}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 保存预设套装回调
function WardrobeMgr:OnClosetSuitSaveRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.SuitSave 
	if Data == nil then
	    return
	end

	-- 更新预设套装数据
	local Suit = Data.Suit
	local ID = Data.ID
	local ProfID = Data.ProfID
	self.UsedSuitID = ID
	local IsExist = false
	local MajorID = MajorUtil.GetMajorProfID()
	local IsCancelLinkProf = false
	local CancelLinkProf = nil
	for _, v in ipairs(self.Suits) do
		if v.ID == ID then
			IsExist = true
			v.Suit = Suit
			v.SuitProfID = ProfID
			if v.RelatedProf ~= MajorID and v.RelatedProf ~= 0 then
				CancelLinkProf = v.RelatedProf 
				IsCancelLinkProf = true
				v.RelatedProf = 0
			end
		end
	end

	-- 如果保存的时候没有预设套装数据，客户端这边存入
	if not IsExist then
		local CurSuit = {}
		CurSuit.ID = Data.ID
		CurSuit.Suit = Data.Suit
		CurSuit.SuitName = Data.SuitName
		CurSuit.RelatedProf = 0
		CurSuit.SuitProfID = ProfID
		table.insert(self.Suits, CurSuit)
	end

	-- 展示tips
	if IsCancelLinkProf then
		if CancelLinkProf then
			local Name = _G.EquipmentMgr:GetProfName(CancelLinkProf) or ""
			MsgTipsUtil.ShowTips((string.format(LSTR(1080004), Name)))
		end
	else
		MsgTipsUtil.ShowTips(LSTR(1080005))
	end

	EventMgr:SendEvent(EventID.WardrobePresetSuitUpdate, {SuitID = ID})
end

---预设套装关联职业请求
---@param SuitID number 衣橱预设ID
---@param ProfID number 职业ID 
function WardrobeMgr:SendClosetSuitLinkProfReq(SuitID, ProfID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_SUIT_LINK_PROF

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SuitProf = { SuitID = SuitID, ProfID = ProfID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 预设套装关联职业回调
function WardrobeMgr:OnClosetSuitLinkProfRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.SuitProf 
	if Data == nil then
	    return
	end

	local ID = Data.SuitID
	local ProfID = Data.ProfID
	local IsRepeated = WardrobeMgr:CheckIsRepeatLinkProfID()

	local IsExist = false
	for _, v in ipairs(self.Suits) do
		if v.ID == ID then
			IsExist = true
		end
	end

	if IsRepeated then
		for _, v in ipairs(self.Suits) do
			if v.ID ~= ID and v.RelatedProf == ProfID then
				v.RelatedProf = 0
				break
			end
		end
	end

	if not IsExist then
		local CurSuit = self:GetPresetsClient(ID)
		CurSuit.RelatedProf = ProfID
		table.insert(self.Suits, CurSuit)
	else
		for _, v in ipairs(self.Suits) do
			if v.ID == ID then
				v.RelatedProf = ProfID
			end
		end
	end

	if ProfID == 0 then
		MsgTipsUtil.ShowTips(LSTR(1080006))
	else
		local ProfName = _G.EquipmentMgr:GetProfName(ProfID)
		MsgTipsUtil.ShowTips(string.format(LSTR(1080007), ProfName))
	end

	-- 预设套装关联职业刷新
	EventMgr:SendEvent(EventID.WardrobePresetSuitUpdate, {SuitID = ID})

end

--- 染色激活请求
---@param ID 外观ID
---@param ColorID 颜色ID
function WardrobeMgr:SendClosetActiveStainReq(ID, ColorID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_ACTIVE_STAIN

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.ActiveStain = { ID = ID, ColorID = ColorID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 染色激活回调
function WardrobeMgr:OnClosetActiveStainRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.ActiveStain 
	if Data == nil then
	    return
	end

	local ID = Data.ID
	local ColorID = Data.ColorID
	local CharismValue = Data.CharmValue

	if CharismValue then
		self.ChrismValue = CharismValue
	end
	
	--激活染色
	if self.AppearanceActiveColor[ID] == nil then
		self.AppearanceActiveColor[ID] = {}
	end
	table.insert(self.AppearanceActiveColor[ID], ColorID)

	MsgTipsUtil.ShowTips(LSTR(1080008))

	EventMgr:SendEvent(EventID.WardrobeActiveStain, {ID = ID, ColorID = ColorID})

	-- 更新魅力值
	EventMgr:SendEvent(EventID.WardrobeCharismValueUpdate)

end

--- 外观染色请求
---@param ID 外观ID
---@param ColorID 颜色ID
function WardrobeMgr:SendClosetDyeReq(ID, ColorID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_DYE

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Dye = { ID = ID, ColorID = ColorID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 外观染色回调
function WardrobeMgr:OnClosetDyeRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.Dye 
	if Data == nil then
	    return
	end

	local ID = Data.ID -- 外观ID
	local ColorID = Data.ColorID --颜色ID
	local EquipPartID

	-- 更新解锁外观的颜色
	local TempRegionDye = {}
	if self.UnlockedAppearance[ID] ~= nil then
		self.UnlockedAppearance[ID].ColorID = ColorID
		if ColorID ~= 0 then
			local Cfg = ClosetCfg:FindCfgByKey(ID)
			if Cfg ~= nil then
				if not table.is_nil_empty(Cfg.StainAera) then
					for index, v in ipairs(Cfg.StainAera) do
						if v.Ban ~= 1 then
							table.insert(TempRegionDye, {ID = index, ColorID = ColorID})
						end
					end
					self.UnlockedAppearance[ID].RegionDyes = TempRegionDye
				end
			end
		end
	end

	-- 更新当前穿戴外观List的数据
	for partID, v in pairs(self.CurAppearanceIDList) do
		if v.Avatar == ID then
			v.Color = ColorID
			v.RegionDye = TempRegionDye
			EquipPartID = partID
		end
	end

	-- 更新当前穿戴的外观颜色
	if EquipPartID  ~= nil then
		local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
		local EquipList = MajorRoleDetail.Simple.Avatar.EquipList
		local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(ID)
		for _, v in ipairs(EquipList) do
			if v.Part == EquipPartID then
				v.ColorID = ColorID
				if v.RegionDyes == nil then
					v.RegionDyes = {}
				end
				v.RegionDyes = IsAppRegionDye and TempRegionDye or {}
			end
		end
		MajorRoleDetail.Simple.Avatar.EquipList = EquipList
		_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)
	end
	
	-- 更新界面外观的颜色
	for _, v in pairs(self.ViewSuit) do
		if v.Avatar == ID then
			v.Color = ColorID
			v.RegionDye = TempRegionDye
		end
	end	

	for _, v in pairs(self.StainViewSuit) do
		if v.Avatar == ID then
			v.Color = ColorID
			v.RegionDye = TempRegionDye
		end
	end	

	EventMgr:SendEvent(EventID.WardrobeDyeUpdate, {ID = ID})

end

--- 染色取消
---@param ID 外观ID
function WardrobeMgr:SendClosetDyeRecoveryReq(ID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_DYE_RECOVERY

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.DyeRecovery = {ID = ID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 染色取消回调
function WardrobeMgr:OnClosetRecoveryRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.DyeRecovery 
	if Data == nil then
	    return
	end

	local ID = Data.ID

	-- 取消染色
	local TempRegionDye = {}
	if self.UnlockedAppearance[ID] ~= nil then
		self.UnlockedAppearance[ID].ColorID = 0
		local Cfg = ClosetCfg:FindCfgByKey(ID)
		if Cfg ~= nil then
			if not table.is_nil_empty(Cfg.StainAera) then
				for index, v in ipairs(Cfg.StainAera) do
					table.insert(TempRegionDye, {ID = v.SocketID, ColorID = 0})
				end
				self.UnlockedAppearance[ID].RegionDyes = TempRegionDye
			end
		end
	end

	-- 修改界面展示外观

	for partID, v in pairs(self.ViewSuit) do
		if v.Avatar == ID then
			v.Color = 0
			self:SetViewSuit(partID, ID, v.Color, TempRegionDye)
		end
	end

	for partID, v in pairs(self.StainViewSuit) do
		if v.Avatar == ID then
			v.Color = 0
			self:SetStainViewSuit(partID, ID, v.Color, TempRegionDye)
		end
	end

	FLOG_INFO(" WardrobeMgr:OnClosetRecoveryRsp 取消染色 ".. table_to_string(self.ViewSuit))

	-- 更新当前穿戴的外观颜色
	local EquipPartID
	for partID, v in pairs(self.CurAppearanceIDList) do
		if v.Avatar == ID then
			v.Color = 0
			v.RegionDye = TempRegionDye
			EquipPartID = partID
		end
	end

	-- 更新当前穿戴的外观颜色
	if EquipPartID  ~= nil then
		local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
		local EquipList = MajorRoleDetail.Simple.Avatar.EquipList
		for _, v in ipairs(EquipList) do
			if v.Part == EquipPartID then
				v.ColorID = 0
				v.RegionDyes = TempRegionDye
			end
		end
		MajorRoleDetail.Simple.Avatar.EquipList = EquipList
		_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)
	end

	EventMgr:SendEvent(EventID.WardrobeDyeUpdate, {ID = ID, ColorID = 0})

end

---发送领取魅力值奖励
---@param ID number 进度编号
function WardrobeMgr:SendClosetCharismRewardReq(ID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_CHARISM_REWARD

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.CharismReward = {ID = ID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---领取魅力值奖励回调
function WardrobeMgr:OnClosetCharismRewardRsp(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.CharismReward 
	if Data == nil then
	    return
	end

	-- 组装奖励
	local Params = {}
	Params.ItemList = {}
	Params.Title = _G.LSTR(1080009)
	local Cfg = ClosetCharismCfg:FindCfgByKey(Data.ID)
	if Cfg ~= nil then
		for _, v in ipairs(Cfg.Rewards) do
			if v.ResID ~= 0 then
				table.insert(Params.ItemList, { ResID = v.ResID, Num = v.Num})
			end
		end
	end
	UIViewMgr:ShowView(UIViewID.CommonRewardPanel, Params)
	-- 当前魅力值阶段
	self.ClaimedCharismReward = Data.ID

	EventMgr:SendEvent(EventID.WardrobeCollectReward)

	EventMgr:SendEvent(EventID.WardrobeCharismValueUpdate)

end

--- 发送穿戴外观请求
---@param AppID 外观ID
---@param PartID 穿戴部位
function WardrobeMgr:SendClosetClothingReq(AppID , PartID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_CLOTHING

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Clothing = {AppearanceID  = AppID, Part = PartID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 穿戴外观回调
function WardrobeMgr:OnClosetClothingRsp(MsgBody)
	if MsgBody == nil then
		return
	end
	local Data = MsgBody.Clothing 
	if Data == nil then
	    return
	end

	-- 当前穿的外观
	local AppID = Data.AppearanceID
	local Part = Data.Part

	-- 更新当前穿戴外观信息，如果存在替换，不存在创建个新的
	if self.CurAppearanceIDList ~= nil and self.CurAppearanceIDList[Part] ~= nil then
		self.CurAppearanceIDList[Part].Avatar = AppID
		self.CurAppearanceIDList[Part].Color =  WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetDyeColor(AppID) or 0
		self.CurAppearanceIDList[Part].RegionDye = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
	else
		self.CurAppearanceIDList[Part] = {}
		self.CurAppearanceIDList[Part].Avatar = AppID
		self.CurAppearanceIDList[Part].Color =  WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetDyeColor(AppID) or 0
		self.CurAppearanceIDList[Part].RegionDye = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
	end

	local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
	local EquipList = MajorRoleDetail.Simple.Avatar.EquipList

	local IsExist = false
	for _, v in pairs(EquipList) do
		if v.Part == Part then
			IsExist = true
			v.ResID = AppID
			v.ColorID = WardrobeMgr:GetIsUnlock(AppID) and  WardrobeMgr:GetDyeColor(AppID) or 0
			v.RegionDyes =  WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
		end
	end


	if not IsExist then
		local EquipData = {}
		EquipData.Part = Part
		EquipData.EquipID = 0
		EquipData.ResID = AppID
		EquipData.ColorID = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetDyeColor(AppID) or 0
		EquipData.RegionDyes = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
		table.insert(EquipList, EquipData)
	end

	MajorRoleDetail.Simple.Avatar.EquipList = EquipList
	_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)

	-- 刷新穿戴
	WardrobeMgr:SetRedDot()
	EventMgr:SendEvent(EventID.WardrobeUpdate)
	EventMgr:SendEvent(EventID.WardrobeClothingUpdate, {AppID = AppID, Part = Part})
end

--- 脱下外观请求
function WardrobeMgr:SendClosetUnClothingReq(PartID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_UNCLOTHING

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.Unclothing = {Part = PartID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 脱下外观请求
function WardrobeMgr:OnClosetUnClothingRsp(MsgBody)
	if MsgBody == nil then
		return
	end
	local Data = MsgBody.Unclothing
	if Data == nil then
	    return
	end

	local PartID = Data.Part

	for key, v in pairs(self.ViewSuit) do
		if PartID == key then
			self.ViewSuit[key] = nil
		end
	end

	-- 更新当前CurAppearanceIDList数据
	if self.CurAppearanceIDList ~= nil and self.CurAppearanceIDList[PartID] ~= nil then
		self.CurAppearanceIDList[PartID].Avatar = 0
		self.CurAppearanceIDList[PartID].Color = 0
		self.CurAppearanceIDList[PartID].RegionDye = 0
	end

	--更新模型外观数据
	local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
	local EquipList = MajorRoleDetail.Simple.Avatar.EquipList
	for _, v  in pairs(EquipList) do
		if v.Part == PartID then
			v.ResID = 0
			v.ColorID = 0
			v.RegionDyes = {}
		end	
	end
	
	MajorRoleDetail.Simple.Avatar.EquipList = EquipList
	_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)

	WardrobeMgr:SetRedDot()
	EventMgr:SendEvent(EventID.WardrobeUpdate)

	EventMgr:SendEvent(EventID.WardrobeUnClothingUpdate, { PartID  = PartID})

end

--- 发送使用预设请求
---@param ID  预设套装ID
function WardrobeMgr:SendClosetChooseSuitRep(ID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_CHOOSESUIT

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.ChooseSuit  = { SuitID  = ID}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 选择预设套装回调
function WardrobeMgr:OnClosetChooseSuitRsp(MsgBody)
	if MsgBody == nil then
		return
	end
	local Data = MsgBody.ChooseSuit 
	if Data == nil then
	    return
	end

	self.UsedSuitID = Data.SuitID
	
	--检查当前装备是否全部可穿戴
	local AllCanEquip = true
	local Suits = WardrobeMgr:GetPresets(self.UsedSuitID)
	if Suits then
		for _, v in ipairs(Suits.Suit) do
			if v.Avatar ~= 0 then
				local CanEquip = WardrobeMgr:CanEquipAppearance(v.Avatar)
				if not CanEquip  then
					AllCanEquip = false
				end
			end
		end	
		if AllCanEquip then
			MsgTipsUtil.ShowTips(LSTR(1080010))
		else
			MsgTipsUtil.ShowTips(LSTR(1080011))
		end
	end

	-- 刷新界面
	EventMgr:SendEvent(EventID.WardrobePresetSuitUpdate, {SuitID = self.UsedSuitID})
	
end

--- 查询外观激活的颜色
function WardrobeMgr:SendClosetActiveColor(IDList)
	local MsgID = CS_CMD.CS_CMD_CLOSET
	local SubMsgID = SUB_MSG_ID.CS_CLOSET_ACTIVE_COLOR

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.ActiveColor = { AppearanceID = IDList}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 查询外观激活的颜色
function WardrobeMgr:OnClosetActiveColor(MsgBody)
	if MsgBody == nil or MsgBody.ActiveColor  == nil then
		return
	end
	local Data = MsgBody.ActiveColor
	local Colors = Data.Colors

	for _, v in ipairs(Colors) do
		local AppearanceID = v.AppearanceID
		if self.AppearanceActiveColor[AppearanceID] == nil then
			self.AppearanceActiveColor[AppearanceID] = {}
		end
		local TempValue = WardrobeUtil.ParseStainByte(v.Colors)
		self.AppearanceActiveColor[AppearanceID] = TempValue
	end

	EventMgr:SendEvent(EventID.WardrobeActiveColorUpdate)
end

--- 外观数据更新
function WardrobeMgr:OnClosetAppearNoitfy(MsgBody)
	if MsgBody == nil then
		return
	end
	local Data = MsgBody.AppearNotify
	if Data == nil then
	    return
	end

	-- 重置穿戴当前外观List
	self.CurAppearanceIDList = {}
	self.CurAppearanceIDList = Data.Suit

	-- 更新RoleDetail的数据
	local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
	if MajorRoleDetail ~= nil then
		local EquipList = MajorRoleDetail.Simple.Avatar.EquipList
		-- FLOG_INFO("WardrobeMgr:OnClosetAppearNoitfy 重置前的数据 ".. table_to_string(EquipList))

		-- 遍历所有部位
		local NotExistEquipPartList = {}
		for index, partID in pairs(WardrobeDefine.EquipmentTab) do
			local IsExist = false
			for  _, v in pairs(EquipList) do
				if v.Part == partID then
					IsExist = true
				end
			end

			if not IsExist then
				table.insert(NotExistEquipPartList, partID)
			end
		end

		for _, partID in ipairs(NotExistEquipPartList) do
			local PartData  = {}
			PartData.Part = partID
			PartData.EquipID = 0
			PartData.ResID = 0
			PartData.ColorID = 0
			table.insert(EquipList, PartData)
		end

		local SuitEquipPartList = {}
		for  _, v in pairs(EquipList) do
			for equip_part, value in pairs(Data.Suit) do
				if v.Part == equip_part then
					v.ResID = value.Avatar
					v.ColorID = value.Color
					v.RegionDyes = value.RegionDye
					table.insert(SuitEquipPartList, equip_part)
				end
			end
		end

		for _, v in pairs(EquipList) do
			if not table.contain(SuitEquipPartList, v.Part) then
				v.ResID = 0
				v.ColorID = 0
				v.RegionDyes  = {}
			end
		end

		-- FLOG_INFO("WardrobeMgr:OnClosetAppearNoitfy 重置后的数据 ".. table_to_string(EquipList))

		MajorRoleDetail.Simple.Avatar.EquipList = EquipList
		_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)
	end

	-- 更新viewsuit 数据
	self:ClearViewSuit()
	for partID, v in pairs(Data.Suit) do
		local CanEquip = WardrobeMgr:CanEquipAppearance(v.Avatar)
		if CanEquip then
			WardrobeMgr:SetViewSuit(partID, v.Avatar, v.Color, v.RegionDye or {})
		end
	end

	WardrobeMgr:SetRedDot()
	EventMgr:SendEvent(EventID.WardrobeUpdate)
end

--- 发送获取外观随机图案数据
function WardrobeMgr:SendClosetRandomPatternReq()
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_RANDOM_PATTERN

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 随机图案数据回调
function WardrobeMgr:OnClosetRandomPatternRsq(MsgBody)
	if MsgBody == nil then
	    return
	end 
	local Data = MsgBody.RefreshPattern 
	if Data == nil then
	    return
	end

	self.RandomAppEquipList = Data.RandomPattern.RandomPatterns or {}

	self.RandomAppRefreshTime = Data.RandomPattern.RefreshTime or 0

	local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
	local EquipList = MajorRoleDetail.Simple.Avatar.EquipList

	for key, v in pairs(self.RandomAppEquipList) do
		local AppID = tonumber(key)
		local PartID = WardrobeUtil.GetPartIDByAppearanceID(AppID)
		for _, v  in pairs(EquipList) do
			if v.Part == PartID then
				v.RandomID = AppID
			end	
		end
	end

	MajorRoleDetail.Simple.Avatar.EquipList = EquipList
	_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)

	WardrobeMgr:StartRandomAppFreshTimer()
end

-- 查询常用染色试剂
function WardrobeMgr:SendClosetUsedStainQuery()
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_USED_STAIN_QUERY

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function WardrobeMgr:OnClosetUsedStainQuery(MsgBody)
	if MsgBody == nil or MsgBody.UsedStainQuery == nil then
	    return
	end 
	local Data = MsgBody.UsedStainQuery
	local TempList = {}
	for _, v in ipairs(Data.UsedStain) do
		table.insert(TempList, v)
	end
	self.UsedStainList = TempList
	EventMgr:SendEvent(EventID.WardrobeUsedStainUpdate)
end

-- 常用染色保存
function WardrobeMgr:SengClosetUsedStainSave(AppID, StainIDList)
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_USED_STAIN_SAVE

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.StainSave = {
		Appear = AppID,
		StainIDList = StainIDList
	}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function WardrobeMgr:OnClosetUsedStainSave(MsgBody)
	if MsgBody == nil or MsgBody.StainSave == nil then
	    return
	end
	local Data = MsgBody.StainSave
	local TempList = {}
	for _, v in ipairs(Data.UsedStain) do
		table.insert(TempList, v)
	end

	self.UsedStainList = TempList

	EventMgr:SendEvent(EventID.WardrobeUsedStainUpdate)
end

--衣橱区域染色
function WardrobeMgr:SendClosetRegionDyeReq(AppID, RegionDyeID, RegionColorID)
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.Cs_CLOSET_REGION_DYE

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	local SendRegionDyes = {{ID = RegionDyeID, ColorID = RegionColorID}}
	MsgBody.RegionDye = {AppearID = AppID, RegionDyes = SendRegionDyes}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function WardrobeMgr:OnClosetRegionDyeRsp(MsgBody)
	if MsgBody == nil or MsgBody.RegionDye == nil then
	    return
	end
	local Data = MsgBody.RegionDye

	local ID = Data.AppearID -- 外观ID
	
	if not (Data.RegionDyes and next(Data.RegionDyes)) then
		return
	end

	--Todo 处理染色逻辑
	local EquipPartID
	local TempRegionDye = {}
	local Cfg = ClosetCfg:FindCfgByKey(ID)
	if Cfg ~= nil then
		if not table.is_nil_empty(Cfg.StainAera) then
			for index, v in ipairs(Cfg.StainAera) do
				if v.Ban ~= 1 then
					table.insert(TempRegionDye, {ID = index, ColorID = 0})
				end
			end
		end
	end

	for index, v in ipairs(TempRegionDye) do
		for pos, value in ipairs(Data.RegionDyes) do
			if v.ID == value.ID then
				-- v.ColorID = value.ColorID
				TempRegionDye[index].ColorID = Data.RegionDyes[pos].ColorID
			end
		end
	end

	-- 只要使用了区域染色 这个值就值为0
	if self.UnlockedAppearance[ID] ~= nil then
		self.UnlockedAppearance[ID].ColorID = 0
		self.UnlockedAppearance[ID].RegionDyes = TempRegionDye
	end

	for _, v in pairs(self.StainViewSuit) do
		if v.Avatar == ID then
			for key, vvlalue in ipairs(v.RegionDye) do
				for pos, value in ipairs(Data.RegionDyes) do
					if vvlalue.ID == value.ID then
						vvlalue.ColorID = value.ColorID
					end
				end
			end
		end
	end

	for _, v in pairs(self.ViewSuit) do
		if v.Avatar == ID then
			v.RegionDye = TempRegionDye
		end
	end

	-- 更新区域染色逻辑
	for partID,  v in pairs(self.CurAppearanceIDList) do
		if v.Avatar == ID then
			v.Color = 0
			v.RegionDye = TempRegionDye
			EquipPartID = partID
		end
	end
	
	-- 更新当前穿戴的外观颜色
	if EquipPartID  ~= nil then
		local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
		local EquipList = MajorRoleDetail.Simple.Avatar.EquipList
		for _, v in ipairs(EquipList) do
			if v.Part == EquipPartID then
				v.ColorID = 0
				v.RegionDyes = TempRegionDye
			end
		end
		MajorRoleDetail.Simple.Avatar.EquipList = EquipList
		_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)
	end

	EventMgr:SendEvent(EventID.WardrobeRegionDyeUpdate, {ID = ID, RegionDyes = TempRegionDye})
end

--衣橱套装使用
function WardrobeMgr:SendClosetSuitClothingReq(SuitClothingList)
	local MsgID = CS_CMD.CS_CMD_CLOSET
    local SubMsgID = SUB_MSG_ID.CS_CLOSET_SUIT_CLOTHING

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	MsgBody.SuitClothing  = {Clothing  = SuitClothingList}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function WardrobeMgr:OnClosetSuitClothing(MsgBody)
	if MsgBody == nil or MsgBody.SuitClothing == nil then
	    return
	end
	local Data = MsgBody.SuitClothing

	if not Data.Limit then
		MsgTipsUtil.ShowTips(_G.LSTR(1080120)) --当前套装使用成功
	else
		MsgTipsUtil.ShowTips(_G.LSTR(1080121)) --当前套装使用成功, 部分外观不符合使用条件
	end

	local Clothing = Data.Clothing or {}
	local MajorRoleDetail = MajorUtil.GetMajorRoleDetail()
	local EquipList = MajorRoleDetail.Simple.Avatar.EquipList

	for  _, v in ipairs(Clothing) do
		local Part = v.Part
		local AppID = v.AppearanceID
		if Part ~= nil and AppID ~= nil then
			if self.CurAppearanceIDList == nil then
				self.CurAppearanceIDList = {}
			end
			if self.CurAppearanceIDList[Part] ~= nil then
				self.CurAppearanceIDList[Part].Avatar = AppID
				self.CurAppearanceIDList[Part].Color =  WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetDyeColor(AppID) or 0
				self.CurAppearanceIDList[Part].RegionDye = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
			else
				self.CurAppearanceIDList[Part] = {}
				self.CurAppearanceIDList[Part].Avatar = AppID
				self.CurAppearanceIDList[Part].Color =  WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetDyeColor(AppID) or 0
				self.CurAppearanceIDList[Part].RegionDye = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
			end
		end

		local IsExist = false
		for _, v in pairs(EquipList) do
			if v.Part == Part then
				IsExist = true
				v.ResID = AppID
				v.ColorID = WardrobeMgr:GetIsUnlock(AppID) and  WardrobeMgr:GetDyeColor(AppID) or 0
				v.RegionDye =  WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
			end
		end


		if not IsExist then
			local EquipData = {}
			EquipData.Part = Part
			EquipData.EquipID = 0
			EquipData.ResID = AppID
			EquipData.ColorID = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetDyeColor(AppID) or 0
			EquipData.RegionDyes = WardrobeMgr:GetIsUnlock(AppID) and WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID) or {}
			table.insert(EquipList, EquipData)
		end

		MajorRoleDetail.Simple.Avatar.EquipList = EquipList
		_G.ActorMgr:SetMajorRoleDetail(MajorRoleDetail)
	end

	-- 刷新穿戴
	WardrobeMgr:SetRedDot()
	EventMgr:SendEvent(EventID.WardrobeUpdate)

	for _, v in ipairs(Clothing) do
		if v.AppearanceID > 0 then
		EventMgr:SendEvent(EventID.WardrobeClothingUpdate, {Part = v.Part, AppID = v.AppearanceID})
		end
	end

end

--------------------------------------------- 对外接口 ---------------------------------------------
function WardrobeMgr:IsRandomAppID(AppID)
	if self.RandomAppEquipList[AppID] then
		return true
	end
	return false
end

function WardrobeMgr:GetEquipIDByRandomApp(AppID)
	return self.RandomAppEquipList[AppID] or nil
end

function WardrobeMgr:StartRandomAppFreshTimer()
	if self.RandomAppRefreshTimer ~= nil then
		self:UnRegisterTimer(self.RandomAppRefreshTimer)
		self.RandomAppRefreshTimer = nil
	end

	if self.RandomAppRefreshTime > 0 then
		self.RandomAppRefreshTimer = self:RegisterTimer(self.OnRandomAppFreshTimer, 0, 1, 0)
	end
end

function WardrobeMgr:OnRandomAppFreshTimer()
	local ServerTime = TimeUtil.GetServerTimeMS()
	if self.RandomAppRefreshTime > 0 then
		local IsCurDailyCycleTime =  TimeUtil.GetIsCurDailyCycleTime(math.floor(self.RandomAppRefreshTime / 1000))
		if not IsCurDailyCycleTime then
			WardrobeMgr:SendClosetRandomPatternReq()
			self:UnRegisterTimer(self.RandomAppRefreshTimer)
			self.RandomAppRefreshTimer = nil
		end
	end
end

function WardrobeMgr:GetGameVersionName()
    -- local GameVersionName = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    -- local VersionName = GameVersionName.Value
    -- if not table.is_nil_empty(VersionName) then
    --     VersionName = string.format("%d.%d.%d",VersionName[1],VersionName[2],VersionName[3])
    -- else
    --     _G.FLOG_ERROR("WardrobeMgr:GetGameVersionName GameVersionName.Value is nil")
    --     VersionName = "2.0.0"
    -- end
	local VersionName = _G.UE.UVersionMgr.GetGameVersion()
	return VersionName
end

---@type 指定版本是否被包含于当前游戏版本
---@param VersionName string @指定版本
function WardrobeMgr:BeIncludedInGameVersion(AssignedVersionName)
    if string.isnilorempty(AssignedVersionName) then
		return
    end
	return _G.UE.UVersionMgr.IsBelowOrEqualGameVersion(AssignedVersionName)
end

function WardrobeMgr:OpenWardrobeMainPanel(bDelay)
	if not _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDShadow) then
		return
	end

	local bWorldCond = self:CheckCanGlamours(true)
    if not bWorldCond then
        return
    end

	local MajorEntityID = MajorUtil.GetMajorEntityID()
    local bIsCombat = ActorUtil.IsCombatState(MajorEntityID)
    if bIsCombat then
        MsgTipsUtil.ShowTips(LSTR(1080012))
        return
    end

	local function SendSeverReq()
		self.IsClickBtnEnter = true
		UIViewMgr:ShowView(UIViewID.WardrobeMainPanel)
	end

	self:PlaySgActorAnim(true)

	if bDelay then
		self:RegisterTimer(SendSeverReq, 1, 0, 1)
		return
	end

	SendSeverReq()	
end

function WardrobeMgr:PlaySgActorAnim(bOpen)
	local CurMapID = _G.PWorldMgr:GetCurrMapResID()
	local Cfg = ClosetBindEObjectCfg:FindCfg(string.format("MapID = %d", CurMapID))
	if Cfg ~= nil then
		local AllSgActors = _G.UE.TArray(_G.UE.ASgLayoutActorBase)
		_G.UE.UGameplayStatics.GetAllActorsOfClass(FWORLD(),  _G.UE.ASgLayoutActorBase.StaticClass(), AllSgActors)
		local DynamicAssetCnt = AllSgActors:Length()
		for i = 1, DynamicAssetCnt, 1 do
			local SgActor = AllSgActors:Get(i)
			if SgActor then
				if SgActor.ID == Cfg.SGBID then
					local ContentSgMgr = _G.UE.UContentSgMgr
					ContentSgMgr:Get():PlayManagedSGWithSgIDAndIndex(SgActor.ID, bOpen and 1 or 0)
					break
				end
			end
		end
	end
end

function WardrobeMgr:CheckCanGlamours(ShowTips)
    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()

	local Value = PworldCfg:FindValue(CurrPWorldResID, "CanGlamours")
    if Value == nil then
        return true
    end

	local CanGlamours = nil ~= Value and Value > 0

	if not CanGlamours and ShowTips then
		MsgTipsUtil.ShowTips(LSTR(1080013))
	end

	return CanGlamours
end

function WardrobeMgr:GetCurAppearanceList()
	return self.CurAppearanceIDList
end

function WardrobeMgr:OpenWardrobeUnlockPanel(AppID)
	if not _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDShadow) then
		return
	end

	local bWorldCond = self:CheckCanGlamours(true)
    if not bWorldCond then
        return
    end

	local MajorEntityID = MajorUtil.GetMajorEntityID()
    local bIsCombat = ActorUtil.IsCombatState(MajorEntityID)
    if bIsCombat then
        MsgTipsUtil.ShowTips(LSTR(1080012))
        return
    end

	if AppID == nil then
		return
	end

	UIViewMgr:ShowView(UIViewID.WardrobeMainPanel, {UnlockAppID = AppID})

end

function WardrobeMgr:InitViewSuit()
	local _ <close> = CommonUtil.MakeProfileTag("WardrobeMgr_InitViewSuit")

	self.ViewSuit = {}
	for partID, value in pairs(self.CurAppearanceIDList) do
		if value.Avatar ~= nil and value.Avatar ~= 0 then
			local CanEquiped = WardrobeMgr:CanEquipedAppearanceByServerData(tonumber(value.Avatar))
			if CanEquiped then				
				WardrobeMgr:SetViewSuit(partID, value.Avatar, value.Color, value.RegionDye)
			end
		end
	end
end

function WardrobeMgr:ClearViewSuit()
	self.ViewSuit = {}
end

function WardrobeMgr:GetViewSuit()
	return self.ViewSuit
end

function WardrobeMgr:SetViewSuit(PartID, AppID, ColorID, RegionDye)
	local _ <close> = CommonUtil.MakeProfileTag("WardrobeMgr_SetViewSuit")
	if PartID == nil then
		_G.FLOG_ERROR( "WardrobeMgr:SetViewSuit PartID IS niL ")
		return
	end

	if self.ViewSuit[PartID] == nil then
		self.ViewSuit[PartID] = {}
		self.ViewSuit[PartID].Avatar = AppID
		self.ViewSuit[PartID].Color = ColorID
		self.ViewSuit[PartID].RegionDye = RegionDye
		_G.FLOG_ERROR( "WardrobeMgr:SetViewSuit[part] is nil  "  .. table_to_string(self.ViewSuit[PartID]))
		return
	end

	for key, value in pairs(self.ViewSuit) do
		if tonumber(key) == PartID then
			self.ViewSuit[PartID].Avatar = AppID
			self.ViewSuit[PartID].Color = ColorID
			self.ViewSuit[PartID].RegionDye = RegionDye
			_G.FLOG_ERROR( "WardrobeMgr:SetViewSuit[part] ~= nil "  .. table_to_string(self.ViewSuit[PartID]))
		end
	end
end

function WardrobeMgr:GetUsedSuitID()
	return self.UsedSuitID
end

function WardrobeMgr:GetCurUsedSuitIsUsed(PresetsID, CurSuitData)
    local SuitID = self:GetUsedSuitID()
    
    -- 验证套装ID有效性
    if not PresetsID or (SuitID and PresetsID ~= SuitID) then
        return false
    end
    
    -- 无激活套装时直接通过
    if not SuitID then
        return true
    end
    
    -- 获取套装配置
    local SuitsInfo = WardrobeMgr:GetPresets(SuitID) or WardrobeMgr:GetPresetsClient(SuitID)
    local Suit = SuitsInfo.Suit
    
    -- 遍历所有装备部位
    for _, part in ipairs(WardrobeDefine.EquipmentTab) do
        local curPart = nil
		for _, v in ipairs(CurSuitData) do
			if v.PartID == part then
				curPart = v
				break
			end
		end
        local suitPart = Suit[part]

		if curPart == nil or suitPart == nil then
			return false
		end
        
        -- 检查部件存在性冲突
        if curPart.Avatar ~= suitPart.Avatar then
			return false
        end
        
        -- 当套装部件存在时进行详细校验
        if suitPart and curPart then
            -- 基础Avatar匹配检查
            if curPart.Avatar ~= 0 and suitPart.Avatar ~= 0 then
                if curPart.Avatar ~= suitPart.Avatar then
                    return false
                end
                
                -- 颜色系统校验
                local isRegionDye = WardrobeUtil.IsAppRegionDye(curPart.Avatar)
                if not isRegionDye then
                    -- 普通染色检查
                    if curPart.Color ~= suitPart.Color then
                        return false
                    end
                else
                    -- 区域染色检查
                    local curDye = curPart.RegionDye or {}
                    local suitDye = suitPart.RegionDye or {}
                    
                    -- 长度检查
                    if #curDye ~= #suitDye then
                        return false
                    end
                    
                    -- 逐项颜色比对
                    for i, dye in ipairs(curDye) do
                        if not suitDye[i] or dye.ColorID ~= suitDye[i].ColorID then
                            return false
                        end
                    end
                end
            end
        end
    end
    
    return true
end

function WardrobeMgr:GetCharismNum()
	return self.ChrismValue
end

function WardrobeMgr:GetClaimedCharismReward()
	return self.ClaimedCharismReward
end

function WardrobeMgr:GetMaxUnlockNum()
	local Cfg = ClosetGlobalCfg:FindCfgByKey(ProtoRes.ClosetParamCfgID.ClosetUnlockLimit)
    return (Cfg and Cfg.Value[1]) and Cfg.Value[1] or 99999
end

function WardrobeMgr:IsExceedCfgLevel()
	local Cfgs = ClosetCharismCfg:FindAllCfg()
	return self.ClaimedCharismReward >= table.length(Cfgs)
end

function WardrobeMgr:GetCharismTotalNum()
	local ID = self:IsExceedCfgLevel() and self.ClaimedCharismReward or self.ClaimedCharismReward + 1 
	if ID ~= nil then
		local Cfg = ClosetCharismCfg:FindCfgByKey(ID)
		if Cfg ~= nil then
			return Cfg.Charism ~= nil and tonumber(Cfg.Charism) or 1
		end
	end

	return 1
end

---@return boolean 是否已经解锁外观 True 已解锁, false 未解锁
function WardrobeMgr:GetIsUnlock(AppearanceID)
	if AppearanceID == nil or AppearanceID == 0 then
		return false
	end
	if table.is_nil_empty(self.UnlockedAppearance) then
		return false
	end
	return self.UnlockedAppearance[AppearanceID] ~= nil
end

function WardrobeMgr:CanEquipAppearance(AppearanceID)
	if self:GetIsUnlock(AppearanceID) then
		return self:CanEquipedAppearanceByServerData(AppearanceID)
	else
		return self:CanEquipedAppearanceByClientData(AppearanceID)
	end
end


function WardrobeMgr:CanPreviewAppearance(AppearanceID)
	if self:GetIsUnlock(AppearanceID) then
		return self:CanPreviewAppearanceByServerData(AppearanceID)
	else
		return self:CanPreviewAppearanceByClientData(AppearanceID)
	end
end

---@return boolean True 已收藏, false 未收藏
function WardrobeMgr:GetIsFavorite(AppearanceID)
	return table.contain(self.CollectionList, AppearanceID)
end

---@return boolean 是否是当前外观id
function WardrobeMgr:GetIsClothing(AppearanceID, PartID)
	if not WardrobeMgr:GetIsUnlock(AppearanceID) then
		return false
	end
	if self.CurAppearanceIDList == nil then
		return false
	end
	for key, v in pairs(self.CurAppearanceIDList) do
		if PartID ~= nil then
			if v.Avatar == AppearanceID and key == PartID then
				return true
			end
		else
			if v.Avatar == AppearanceID then
				return true
			end
		end
	end
	return false
end

---@return table 解锁外观 
function WardrobeMgr:GetUnlockedAppearance()
	return self.UnlockedAppearance
end

---@return boolean 是否外观已染色 True 已染色， fasle 未染色
function WardrobeMgr:GetIsDye(AppearanceID)
	if self.UnlockedAppearance[AppearanceID] == nil then
		return false
	end
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppearanceID)
	if not IsAppRegionDye then
		return self.UnlockedAppearance[AppearanceID].ColorID ~= 0
	else
		local RegionDye =  self.UnlockedAppearance[AppearanceID].RegionDyes  or {}
		for _, v in ipairs(RegionDye) do
			if v.ID ~= 0 then
				if v.ColorID ~= 0 then
					return true
				end
			end
		end
	end
	return false
end

---@return 
function WardrobeMgr:GetCurrentIsDye(AppID)
	if self.CurAppearanceIDList == nil then
		return false
	end

	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)

	if not IsAppRegionDye then
		for _, v in pairs(self.CurAppearanceIDList) do
			if v.Avatar == AppID then
				return v.Color ~= 0
			end
		end
	else
		for _, v in pairs(self.CurAppearanceIDList) do
			if v.Avatar == AppID then
				if not table.is_nil_empty(v.RegionDye) then
					for _, v in ipairs(v.RegionDye) do
						if v.ID ~= 0 and  v.ColorID  ~= 0 then
							return true
						end 
					end
				end
			end
		end
	end

	return false
end

---@return int32 获取染色值，如果是区域染色，获取统一色，否则获取ColorID
function WardrobeMgr:GetDyeColor(AppearanceID)
	if self.UnlockedAppearance[AppearanceID] == nil then
		return 0
	end
	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppearanceID)
	if not IsAppRegionDye then
		return self.UnlockedAppearance[AppearanceID].ColorID
	else
		return WardrobeUtil.GetUnifyRegionDyeColor(AppearanceID, self.UnlockedAppearance[AppearanceID].RegionDyes or {})
	end
end

---@return boolean 能不能染色
function WardrobeMgr:GetDyeEnable(AppearanceID)
	if self.UnlockedAppearance[AppearanceID] == nil then
		return WardrobeUtil.GetAppearanceCanBeDyed(AppearanceID)
	end

	return self.UnlockedAppearance[AppearanceID].CanDye
end


---@return table 返回已激活的颜色
function WardrobeMgr:GetActiveColor(AppearanceID)
	if self.AppearanceActiveColor[AppearanceID] == nil then
		return
	end

	return self.AppearanceActiveColor[AppearanceID]
end

---@return boolean 返回是否是激活的颜色
function WardrobeMgr:IsActiveColor(AppearanceID, ColorID)
	if self.AppearanceActiveColor[AppearanceID] == nil then
		return false
	end
	local Table = self.AppearanceActiveColor[AppearanceID] or {}
	for _, activeColor in ipairs(Table) do
		if ColorID == activeColor then
			return true
		end
	end
	return false
end

---@return number 是否对应上职业
function WardrobeMgr:GetPresetLinkProfID(SuitID)
	for _, v in ipairs(self.Suits) do
		if v.ID == SuitID  then
			return v.RelatedProf
		end
	end
	return 0
end

function WardrobeMgr:CheckIsRepeatLinkProfID()
	local MajorProfID = MajorUtil.GetMajorProfID()
	for _, v in ipairs(self.Suits) do
		if v.RelatedProf == MajorProfID then
			return true
		end
	end

	return false
end

function WardrobeMgr:GetRepeatLinkProfData()
	local MajorProfID = MajorUtil.GetMajorProfID()
	for _, v in ipairs(self.Suits) do
		if v.RelatedProf == MajorProfID then
			return v
		end
	end

end

---@return 是否解锁预设套装上限
function WardrobeMgr:GetUnlockPresets(ID)
	return ID <= self.SuitUpperLimit
end

---@return number 正在使用的预设套装ID
function WardrobeMgr:GetUsedSuitID()
	return self.UsedSuitID
end

---@return number 预设套装上限
function WardrobeMgr:GetSuitUpperLimit()
	return self.SuitUpperLimit 
end

---table<int, Appearance>Suit
---@return table<ID, Name, Suit, RelatedProf> Suits --预设套装
function WardrobeMgr:GetPresets(ID)
	for index, value in ipairs(self.Suits) do
		if value.ID == ID then
			if value.Name ~= nil then
				value.SuitName = value.Name
			end
			return value 
		end
	end

	return nil
end

---@param ID int32 预设套装ID
---@return boolean 预设套装是否全空
function WardrobeMgr:IsPresetsAllEmpty(ID)
	local Preset = self:GetPresets(ID)

	if Preset == nil then
		return true
	end
 
	if table.is_nil_empty(Preset.Suit)then
		return true
	end

	for _, v in pairs(Preset.Suit) do
		if v.Avatar ~= 0 then
			return false
		end
	end
	return true
end

---@param ID int32 预设套装ID
---@return CurSuit 预设套装数据
function WardrobeMgr:GetPresetsClient(ID)
	local EquipmentList = WardrobeDefine.EquipmentTab
	local Cfg = ClosetPresetSuitCfg:FindCfgByKey(ID)

	if Cfg == nil then
		return
	end

	if ID <= self.SuitUpperLimit then
		local CurSuit = {}
		CurSuit.ID = ID
		CurSuit.Suit = {}
		CurSuit.SuitName = Cfg.Name
		CurSuit.RelatedProf = 0
		CurSuit.ProfID = 0
		CurSuit.SuitProfID = 0
		for key, value in ipairs(EquipmentList) do
			CurSuit.Suit[value] = { Color = 0, Avatar = 0}
			CurSuit.Suit[value].RegionDye = {}
		end
		return CurSuit
	end

end

---@param AppID int32 外观id
---@return int32 Color 当前外观的染色
function WardrobeMgr:GetCurAppearanceDyeColor(AppID, SocketID)
	if self.CurAppearanceIDList == nil then
		return
	end

	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)

	if not IsAppRegionDye then
		for _, v in pairs(self.CurAppearanceIDList) do
			if v.Avatar == AppID then
				return v.Color
			end
		end
	else
		if SocketID == -1 then
			return WardrobeUtil.GetUnifyRegionDyeColor(AppID, WardrobeMgr:GetCurAppearanceRegionDyes(AppID))
		end
		for _, v in pairs(self.CurAppearanceIDList) do
			if v.Avatar == AppID then
				if not table.is_nil_empty(v.RegionDye) then
					for _, v in ipairs(v.RegionDye) do
						if v.ID == SocketID then
							return v.ColorID
						end 
					end
				end
			end
		end
	end
end

-- 获取正在穿戴的外观的染色区域
function WardrobeMgr:GetCurAppearanceRegionDyes(AppID)
	if self.CurAppearanceIDList == nil then
		return {}
	end

	for _, v in pairs(self.CurAppearanceIDList) do
		if v.Avatar == AppID then
			if not table.is_nil_empty(v.RegionDye) then
				return v.RegionDye
			end
		end
	end

	return {}
end

--- 获取解锁外观的染色区域
function WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID)
	if self.UnlockedAppearance[AppID] ~= nil then
		return self.UnlockedAppearance[AppID].RegionDyes
	end

	return {}
end

--- 获取当前部位穿的东西 能不能染色呢
function WardrobeMgr:GetEquipPartCanDyeColor(PartID)
	if self.CurAppearanceIDList == nil or self.CurAppearanceIDList[PartID] == nil then
		return false
	end

	local Appearance = self.CurAppearanceIDList[PartID]
	local AppearanceID = Appearance.Avatar
	if Appearance.Avatar == 0 or not self:GetIsUnlock(Appearance.Avatar) then
		return false
	end

	return WardrobeMgr:GetDyeEnable(AppearanceID)
end

--- 获取当前部位的外观ID
function WardrobeMgr:GetEquipPartAppearanceID(PartID)
	if self.CurAppearanceIDList == nil or self.CurAppearanceIDList[PartID] == nil then
		return 0
	end

	local Appearance = self.CurAppearanceIDList[PartID]

	if Appearance.Avatar == 0 or not self:GetIsUnlock(Appearance.Avatar) then
		return 0
	end
 
	return Appearance.Avatar
end

--- 获取解锁外观的数据
function WardrobeMgr:GetUnlockAppearanceDataByID(AppearanceID)
	if table.is_nil_empty(self.UnlockedAppearance) then
		return
	end
	if self.UnlockedAppearance[AppearanceID] == nil then
		return
	end

	return self.UnlockedAppearance[AppearanceID]
end

local function FindLevelLimit(EquipDetailData, EquipOriginData)
	if not EquipDetailData.LevelLimit then
		EquipDetailData.LevelLimit = EquipOriginData.LevelLimit
	end

	if EquipOriginData.LevelLimit < EquipDetailData.LevelLimit then
		EquipDetailData.LevelLimit = EquipOriginData.LevelLimit
	end

	return EquipDetailData
end

local function FindLimitByParam(EquipDetailData, EquipOriginData, Param, JudgeNum)
	if not EquipDetailData[Param] then
		EquipDetailData[Param] = EquipOriginData[Param]
	end

	if EquipOriginData[Param] == 0 then
		EquipDetailData[Param] = 0
	else
		if JudgeNum == EquipOriginData[Param] then
			EquipDetailData[Param] = JudgeNum
		end
	end

	return EquipDetailData
end

local function FindProfLimit(EquipDetailData, EquipOriginData)
	if EquipDetailData.ProfLimits == {} and (EquipDetailData.ClassLimits[1] == 0  or EquipDetailData.ClassLimits == 0 ) then return EquipDetailData  end

	if EquipOriginData.ClassLimits == 0 and not next(EquipOriginData.ProfLimits) then
		EquipDetailData.ProfLimits = {0}
		EquipDetailData.ClassLimits = {0}
		return EquipDetailData
	end

	if EquipDetailData.ClassLimits == nil then
		EquipDetailData.ClassLimits = {}
	end

	if not table.contain(EquipDetailData.ClassLimits, EquipOriginData.ClassLimits) then
		table.insert(EquipDetailData.ClassLimits, EquipOriginData.ClassLimits)
	end

	for _, profID in ipairs(EquipOriginData.ProfLimits) do
		if not table.contain(EquipDetailData.ProfLimits, profID) then
			table.insert(EquipDetailData.ProfLimits, profID)
		end
	end

	return EquipDetailData
end

function WardrobeMgr:GetBestEquipementData(AppearanceID)
	local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)

	if table.is_nil_empty(EquipmentCfgs) then
		_G.FLOG_ERROR(string.format("WardrobeMgr:GetBestEquipementData is NIl %s", tostring(AppearanceID)))
		local EquipDetailData1 = {}
		EquipDetailData1.ClassLimits = {0}
		EquipDetailData1.ProfLimits = {0}
		EquipDetailData1.LevelLimit = 1
		EquipDetailData1.RaceLimits = 0
		EquipDetailData1.GenderLimit = 0
		return EquipDetailData1
	end

	local EquipmentList = {}
	local IsUnlock = self:GetIsUnlock(AppearanceID)
	-- 特殊外观
	if WardrobeUtil.GetIsSpecial(AppearanceID) then
		if (_G.BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(AppearanceID)) >= WardrobeUtil.GetUnlockCostItemNum(AppearanceID)) then
			table.insert(EquipmentList, WardrobeUtil.GetUnlockCostItemID(AppearanceID))
		end
	else
		for _, v in ipairs(EquipmentCfgs) do
			-- 传奇武器
			if (not table.is_nil_empty(WardrobeUtil.GetAchievementIDList(AppearanceID))) then
				table.insert(EquipmentList, v.ID)
			end

			local ItemNum = _G.BagMgr:GetItemNum(v.ID) + _G.EquipmentMgr:GetEquipedItemNum(v.ID)

			if IsUnlock then
				if ItemNum > 0 and WardrobeMgr:IsLessReduceConditionEquipment(AppearanceID, v.ID)  then
					table.insert(EquipmentList, v.ID)
				end
			else
				if ItemNum > 0 then
					table.insert(EquipmentList, v.ID)
				end
			end
		end
	end

	local EquipDetailData = {}
	if IsUnlock then
		EquipDetailData = table.deepcopy(WardrobeMgr:GetUnlockAppearanceDataByID(AppearanceID))
		if EquipDetailData and EquipDetailData.RaceLimits and #EquipDetailData.RaceLimits == 0 then
			EquipDetailData.RaceLimits = {0}
		end
	end

	if not IsUnlock then
		if not table.is_nil_empty(EquipmentList) then
			local ItemConfig = ItemCfg:FindCfgByKey(EquipmentList[1])
			if ItemConfig ~= nil then
				EquipDetailData.ClassLimits = table.deepcopy({ItemConfig.ClassLimit})
				EquipDetailData.ProfLimits =  table.deepcopy(ItemConfig.ProfLimit)
				EquipDetailData.LevelLimit = ItemConfig.Grade
				EquipDetailData.RaceLimits = WardrobeUtil.GetClientRaceCond(ItemConfig.UseCond)
				EquipDetailData.GenderLimit = WardrobeUtil.GetClientGenderCond(ItemConfig.UseCond)
			end
		end
	end

	local MajorGender = MajorUtil.GetMajorGender()
	local CurProfID = MajorUtil.GetMajorProfID()
	local CurRaceID = MajorUtil.GetMajorRaceID()
	--查找是否能满足的条件
	for i, equipment in ipairs(EquipmentList) do
		local ItemConfig = ItemCfg:FindCfgByKey(EquipmentList[i])
		if ItemConfig ~= nil then
			local ClientData = self:ConvertEquipmentLimit(ItemConfig)
			EquipDetailData = FindLevelLimit(EquipDetailData, ClientData)
			EquipDetailData = FindLimitByParam(EquipDetailData, ClientData, 'RaceLimits', CurRaceID)
			EquipDetailData = FindLimitByParam(EquipDetailData, ClientData, 'GenderLimit', MajorGender)
			EquipDetailData = FindProfLimit(EquipDetailData, ClientData, CurProfID)
		end
	end

	return EquipDetailData
end

function WardrobeMgr:GetReduceEquipmentList(OwnEquipList, AppID)
	local Ret = {}

	local ProfEquipList = {}
	local RaceEquipList = {}
	local GenderEquipList = {}
	local LevelEquipList = {}

	local EquipDetailData = {}
	local IsUnlock = WardrobeMgr:GetIsUnlock(AppID)
	if IsUnlock then
		EquipDetailData = table.deepcopy(WardrobeMgr:GetUnlockAppearanceDataByID(AppID))
		RaceEquipList = {EquipID = 0, Race = EquipDetailData.RaceLimits[1]}
		LevelEquipList = {EquipID = 0, Level = EquipDetailData.LevelLimit}
		GenderEquipList = {{EquipID = 0, Gender = EquipDetailData.GenderLimit}}

		local TempClassList = {}
		for _, v in ipairs(EquipDetailData.ClassLimits) do
			if not table.contain(TempClassList, v) then
				table.insert(TempClassList, v)
			end
		end

		local TempProfList = {}
		for _, profID in ipairs(EquipDetailData.ProfLimits) do
			if not table.contain(TempProfList, profID) then
				table.insert(TempProfList, profID)
			end
		end
		ProfEquipList = {{EquipID = 0, ClassLimit = TempClassList, ProfLimits = TempProfList}}
	end

	for _, EquipID in ipairs(OwnEquipList) do
		local ItemConfig = ItemCfg:FindCfgByKey(EquipID)
		if ItemConfig ~= nil then
			local ClassLimit = {ItemConfig.ClassLimit}
			local Level = ItemConfig.Grade
			local ProfLimits = ItemConfig.ProfLimit
			local Race = WardrobeUtil.GetClientRaceCond(ItemConfig.UseCond)
			local Gender = WardrobeUtil.GetClientGenderCond(ItemConfig.UseCond)
			--种族
			if table.is_nil_empty(RaceEquipList) then
				RaceEquipList = {EquipID = EquipID, Race = Race}
			else
				if RaceEquipList.Race ~= 0 then
					RaceEquipList = {EquipID = EquipID, Race = Race}
				end
			end

			--性别
			if table.is_nil_empty(GenderEquipList) then
				GenderEquipList = {{EquipID = EquipID, Gender = Gender}}
			else
				if GenderEquipList[1].Gender ~= 0 then
					if Gender == 0 then
						GenderEquipList = {EquipID = EquipID, Gender = Gender}
					else
						if GenderEquipList[1].Gender ~= Gender and table.length(GenderEquipList) < 2 then
							table.insert(GenderEquipList,  {EquipID = EquipID, Gender = Gender})
						end
					end
				end

			end

			-- 职业, 如果没有 获得的就是当前物品的职业属性
			if table.is_nil_empty(ProfEquipList) then
				ProfEquipList = {{EquipID = EquipID, ClassLimit = ClassLimit, ProfLimits = ProfLimits}}
			else
				-- 有数据，判断一下是否是 所有职业 所有职业就不用判断等级了
				if not(table.length(ProfEquipList[1].ClassLimit) == 1 and ProfEquipList[1].ClassLimit[1] == 0  and table.length(ProfEquipList[1].ProfLimits)  == 1 and ProfEquipList[1].ProfLimits[1] == 0) then
					if (#ClassLimit == 0 or ClassLimit[1] == 0) and (#ProfLimits == 0 or ProfLimits[1] == 0) then
						ProfEquipList = { {EquipID = EquipID, ClassLimit = {0}, ProfLimits = {0}} }
						break
					else
						-- 获取所有的classlimit
						local TempClass =  {}
						for _, v in ipairs(ProfEquipList) do
							for _, value in ipairs(v.ClassLimit) do
								if value ~= 0 then
									table.insert(TempClass, value)
								end
							end
						end

						-- 判断跟当前的classlimit 没有重复
						-- 物品的classLimit
						for _, v in ipairs(ClassLimit) do
							if not table.contain(TempClass, v) and v ~= 0 then
								table.insert(ProfEquipList, {EquipID = EquipID, ClassLimit = ClassLimit, ProfLimits = ProfLimits})
							end
						end

						local TempProfList = {}
						for _, v in ipairs(ProfEquipList) do
							for _, value in ipairs(v.ClassLimit) do
								if value ~= 0 then
									local Cfg = ProfClassCfg:FindCfgByKey(value)
									if Cfg ~= nil then
										for index, subProf in ipairs(Cfg.Prof) do
											if not table.contain(TempProfList, subProf) then
												table.insert(TempProfList, subProf)
											end
										end
									end
								end
							end
						end


						for _, v in ipairs(ProfEquipList) do
							for _, value in ipairs(v.ProfLimits) do
								if value ~= 0 then
									if not table.contain(TempProfList, value) and value ~= 0 then
										table.insert(TempProfList, value)
									end
								end
							end
						end

						if ProfLimits[1] ~= 0 then
							local NotContain = false
							for _, prof in ipairs(ProfLimits) do
								if not table.contain(TempProfList, prof) and prof ~= 0 then
									NotContain = true
									table.insert(TempProfList, prof)
								end
							end
		
							if NotContain then
								table.insert(ProfEquipList, {EquipID = EquipID, ClassLimit = ClassLimit, ProfLimits = ProfLimits})
							end
						end

					end
				end
			end

			--等级
			if table.is_nil_empty(LevelEquipList) then
				LevelEquipList = {EquipID = EquipID, Level = Level}
			else
				if LevelEquipList.Level ~= 1 then
					if  LevelEquipList.Level > Level then
						table.insert(LevelEquipList, {EquipID = EquipID, Level = Level})
					end
				end
			end
		end
	end

	for _, v in ipairs(RaceEquipList) do
		if not table.contain(Ret, v.EquipID) and v.EquipID ~= 0 then
			table.insert(Ret, v.EquipID)
		end
	end
	for _, v in ipairs(GenderEquipList) do
		if not table.contain(Ret, v.EquipID) and v.EquipID ~= 0 then
			table.insert(Ret, v.EquipID)
		end
	end
	for _, v in ipairs(ProfEquipList) do
		if not table.contain(Ret, v.EquipID) and v.EquipID ~= 0 then
			table.insert(Ret, v.EquipID)
		end
	end
	for _, v in ipairs(LevelEquipList) do
		if not table.contain(Ret, v.EquipID) and v.EquipID ~= 0 then
			table.insert(Ret, v.EquipID)
		end
	end
	return Ret
end

function WardrobeMgr:CanEquipedAppearanceByClientData(AppearanceID)
	if AppearanceID == nil or AppearanceID == 0 then
		return false
	end

	local ClientData = self:GetAppearanceClientData(AppearanceID)

	return self:CanEquip(ClientData)
end


function WardrobeMgr:CanEquip(ClientData)
	local Type = WardrobeDefine.EquipOrCanPreviewErrorType
	if ClientData == nil then
		FLOG_INFO("WardrobeMgr:CanEquipedAppearanceByClientData is nil Please Checked Closet, Equipment, Item 's  Cfg.")
		return false, Type.None
	end

	if not WardrobeUtil.JudgeRaceCond(ClientData.RaceLimit) then
		return false, Type.Race
	end

	if not WardrobeUtil.JudgeGenderCond(ClientData.GenderLimit) then
		return false, Type.Gender
	end

	if not WardrobeUtil.JudgeProfCond(ClientData.ProfLimit, ClientData.ClassLimit) then
		return false, Type.Prof
	end

	if not WardrobeUtil.JudgeLevelCond(ClientData.LevelLimit) then
		return false, Type.Level
	end

	return true
end

function WardrobeMgr:CanPreviewAppearanceByClientData(AppearanceID)
	if AppearanceID == nil or AppearanceID == 0 then
		return false
	end
	
	local ClientData = self:GetAppearanceClientData(AppearanceID)

	return self:CanPreview(ClientData)
end

function WardrobeMgr:CanPreview(ClientData)
	if ClientData == nil then
		FLOG_INFO("WardrobeMgr:CanEquipedAppearanceByClientData is nil Please Checked Closet, Equipment, Item 's  Cfg.")
		return false
	end

	return WardrobeUtil.JudgeGenderCond(ClientData.GenderLimit) and WardrobeUtil.JudgeRaceCond(ClientData.RaceLimit)
end

---@param int32 AppearanceID 外观id
---@return Ret 外观限制数据
function WardrobeMgr:GetAppearanceClientData(AppearanceID)
	if AppearanceID == nil or AppearanceID == 0 then
		return nil
	end
	
	-- 获取装备列表
	local Ret = {}
	Ret.AppID = AppearanceID
	Ret.LevelLimit = math.huge
	Ret.ProfLimit = {}
	Ret.ClassLimit= {}
	Ret.RaceLimit = {}
	Ret.GenderLimit = {}
	Ret.CanBeDyed = 0
	
	-- 特殊外观
	if WardrobeUtil.GetIsSpecial(AppearanceID) then
		local ItemConfig = ItemCfg:FindCfgByKey(WardrobeUtil.GetUnlockCostItemID(AppearanceID))
		if ItemConfig ~= nil then
			-- 获取装备的等级限制, 如果有比原来的小，就用更小的等级
			if ItemConfig.Grade <= Ret.LevelLimit then
				Ret.LevelLimit = ItemConfig.Grade
			end
			
			-- 如果有物品的限制条件是这样直接就返回
			if table.is_nil_empty(ItemConfig.ProfLimit) and ItemConfig.ClassLimit == 0 then
				Ret.ProfLimit = {}
				Ret.ClassLimit = {0}
			else
				for _, profID in ipairs(ItemConfig.ProfLimit) do
					if not table.contain(Ret.ProfLimit, profID) then
						table.insert(Ret.ProfLimit, profID)
					end
				end
			
				-- 获取装备的职业大类限制
				for _, profClassID in ipairs({ItemConfig.ClassLimit}) do
					if not table.contain(Ret.ClassLimit, profClassID) then
						table.insert(Ret.ClassLimit, profClassID)
					end
				end
			end

			-- 先去物品表里查对应装备的条件ID（包含种族，性别），再去条件表里查找限制
			local CondConfig = CondCfg:FindCfgByKey(ItemConfig.UseCond)
			if CondConfig ~= nil then
				for _, Cond in pairs(CondConfig.Cond) do
					if Cond.Type == ItemCondType.GenderLimit then
						-- 性别不相等的时候，判断一下,
						if Cond.Value[1] ~= 0 and not table.contain(Ret.GenderLimit, Cond.Value[1]) then
							table.insert(Ret.GenderLimit, Cond.Value[1])
						end
					end
					-- 策划说种族不会覆盖
					if Cond.Type == ItemCondType.RaceLimit then
						if table.length(Ret.RaceLimit) > 0 and Ret.RaceLimit[1] ~= Cond.Value[1] and Cond.Value[1] ~= 0 then
							FLOG_INFO("WardrobeMgr:GetAppearanceClientData There ara difference Ret.RaceLimit")
						end
						Ret.RaceLimit[1] = Cond.Value[1]
					end
				end
			end
		end
	
		if table.is_nil_empty(Ret.RaceLimit) then
			table.insert(Ret.RaceLimit, 1, ProtoCommon.race_type.RACE_TYPE_NULL)
		end

		if table.is_nil_empty(Ret.GenderLimit) then
			Ret.GenderLimit = 0
		elseif table.length(Ret.GenderLimit) == 2 then
			Ret.GenderLimit = 0
		else
			Ret.GenderLimit = Ret.GenderLimit[1]
		end

		if Ret.LevelLimit >= math.huge then
			Ret.LevelLimit = 1
		end

		Ret.RaceLimit = Ret.RaceLimit[1]
	
		return Ret
	end
	
	-- 非特殊外观
	local EquipementCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppearanceID)
	for k, Cfg in ipairs(EquipementCfgs) do
		-- 获取是否能够染色
		if Cfg.CanBeDyed == 1 then
			Ret.CanBeDyed = Cfg.CanBeDyed
		end

		-- 先去物品表里查对应装备的条件ID（包含种族，性别），再去条件表里查找限制
		local ItemConfig = ItemCfg:FindCfgByKey(Cfg.ID)
		if ItemConfig ~= nil then
			-- 获取装备的等级限制, 如果有比原来的小，就用更小的等级
			if ItemConfig.Grade <= Ret.LevelLimit then
				Ret.LevelLimit = ItemConfig.Grade
			end

			-- 如果有物品的限制条件是这样直接就返回
			if table.is_nil_empty(ItemConfig.ProfLimit) and ItemConfig.ClassLimit == 0 then
				Ret.ProfLimit = {}
				Ret.ClassLimit = {0}
			else
				for _, profID in ipairs(ItemConfig.ProfLimit) do
					if not table.contain(Ret.ProfLimit, profID) then
						table.insert(Ret.ProfLimit, profID)
					end
				end
			
				-- 获取装备的职业大类限制
				for _, profClassID in ipairs({ItemConfig.ClassLimit}) do
					if not table.contain(Ret.ClassLimit, profClassID) then
						table.insert(Ret.ClassLimit, profClassID)
					end
				end
			end

			local CondConfig = CondCfg:FindCfgByKey(ItemConfig.UseCond)
			if CondConfig ~= nil then
				for _, Cond in pairs(CondConfig.Cond) do
					if Cond.Type == ItemCondType.GenderLimit then
						-- 性别不相等的时候，判断一下,
						if Cond.Value[1] ~= 0 and not table.contain(Ret.GenderLimit, Cond.Value[1]) then
							table.insert(Ret.GenderLimit, Cond.Value[1])
						end
					end
			
					if Cond.Type == ItemCondType.RaceLimit then
						if table.length(Ret.RaceLimit) > 0 and Ret.RaceLimit[1] ~= Cond.Value[1] then
							FLOG_INFO("WardrobeMgr:GetAppearanceClientData There ara difference Ret.RaceLimit")
						end
						Ret.RaceLimit[1] = Cond.Value[1]
					end
				end
			end

		end
	end

	if Ret.LevelLimit >= math.huge then
		Ret.LevelLimit = 1
	end

	if table.is_nil_empty(Ret.RaceLimit) then
		table.insert(Ret.RaceLimit, 1, ProtoCommon.race_type.RACE_TYPE_NULL)
	end

	if table.is_nil_empty(Ret.GenderLimit) or table.length(Ret.GenderLimit) == 2 then
		Ret.GenderLimit = 0
	else
		Ret.GenderLimit = Ret.GenderLimit[1]
	end

	Ret.RaceLimit = Ret.RaceLimit[1]
	return Ret
end

-- 从各种地方读出来的条件，转化成服务器形式。
function WardrobeMgr:ConvertEquipmentLimit(EquipementCfg)
	local LevelLimit = EquipementCfg.Grade
	local CondLimitID = EquipementCfg.UseCond
	local ProfLimit = EquipementCfg.ProfLimit
	local ClassLimit = EquipementCfg.ClassLimit
	local RaceLimit = WardrobeUtil.GetClientRaceCond(CondLimitID)
	local GenderLimit = WardrobeUtil.GetClientGenderCond(CondLimitID)

	local Data = {
		RaceLimits = RaceLimit, 
		GenderLimit = GenderLimit, 
		ProfLimits = ProfLimit, 
		LevelLimit = LevelLimit, 
		ClassLimits = ClassLimit
	}
	return Data	
end

--外观解锁时，根据服务器数据判断是否符合穿戴条件
function WardrobeMgr:CanEquipedAppearanceByServerData(AppearanceID)
	local _ <close> = CommonUtil.MakeProfileTag(string.format("WardrobeMgr_CanEquipedAppearanceByServerData_%d", AppearanceID))

	local Type = WardrobeDefine.EquipOrCanPreviewErrorType

	local Data = WardrobeMgr:GetUnlockAppearanceDataByID(AppearanceID)
	if Data == nil then
		return false, Type.None
	end

	local GenderLimit = WardrobeMgr:GetGenderLimit(Data)
	local ProfLimit = WardrobeMgr:GetProfLimit(Data)
	local LevelLimit =  WardrobeMgr:GetLevelLimit(Data)
	local RaceLimit = WardrobeMgr:GetRaceLimit(Data)
	local ClassLimit = WardrobeMgr:GetClassLimits(Data)

	if not WardrobeUtil.JudgeRaceCond(RaceLimit) then
		return false, Type.Race
	end

	if not WardrobeUtil.JudgeGenderCond(GenderLimit) then
		return false, Type.Gender
	end

	if not WardrobeUtil.JudgeProfCond(ProfLimit, ClassLimit) then
		return false, Type.Prof
	end

	if not WardrobeUtil.JudgeLevelCond(LevelLimit) then
		return false, Type.Level
	end

	return true
end

--外观解锁时，根据服务器数据判断是否符合预览条件
function WardrobeMgr:CanPreviewAppearanceByServerData(AppearanceID)
	local Data = WardrobeMgr:GetUnlockAppearanceDataByID(AppearanceID)
	if Data == nil then
		return false
	end

	local GenderLimit = WardrobeMgr:GetGenderLimit(Data)
	local RaceLimit = WardrobeMgr:GetRaceLimit(Data)

	return (WardrobeUtil.JudgeGenderCond(GenderLimit) and WardrobeUtil.JudgeRaceCond(RaceLimit))
end


local function GetProfID(ProfID)
	local Cfg = RoleInitCfg:FindCfgByKey(ProfID)
	-- if Cfg ~= nil then
	-- 	if Cfg.AdvancedProfID ~= nil and Cfg.AdvancedProfID ~= 0 then
	-- 		return tostring(Cfg.AdvancedProfID)
	-- 	end
	-- end
	return tostring(ProfID)
end

-- 判断是否是所有职业
local function IsUniversalAppearance(data)
	local classLimit = data.ClassLimit or {}
	local profLimit = data.ProfLimit or {}
	
	-- 优化后的全职业判断逻辑
	return (table.is_nil_empty(classLimit) and table.is_nil_empty(profLimit)) or
		   (#classLimit == 1 and classLimit[1] == 0 and  #profLimit == 1 and profLimit[1] == 0) or 
		   (#profLimit == 1 and profLimit[1] == 0 and classLimit and classLimit == 0)
end

-- 获取大类地下的职业
local function GetSubProfessions(classID)
	local cfg = ProfClassCfg:FindCfgByKey(classID)
	return cfg and cfg.Prof or {}
end

local function GetValidProfessions(data)
	local professions = {}

	-- 处理职业大类限制
	for _, classID in ipairs(data.ClassLimit or {}) do
		if classID ~= 0 then
			local List = GetSubProfessions(classID)
			for _, profID in ipairs(List) do
				professions[profID] = true
			end
		end
	end

	-- 处理具体职业限制（带覆盖检查）
	for _, profID in ipairs(data.ProfLimit or {}) do
		if profID ~= 0 and not professions[profID] then
			professions[profID] = true
		end
	end

	return professions
end

function WardrobeMgr:GetAppearanceCollectTotalNum(OutProfID)
	local ProfID = GetProfID(OutProfID)
	if self.AppearanceCollectTotal[ProfID] ~= nil then
		return self.AppearanceCollectTotal[ProfID] or 0
	end

	self.AppearanceCollectTotal = {}
	-- 构造一个外观Map
	for _, v in pairs(ProtoCommon.prof_type) do
		if v > 0 then
		self.AppearanceCollectTotal[tostring(v)] = 0
		end
	end

	-- 构造一个外观Map
	local AppList = {}
	local CfgList = ClosetCfg:FindAllCfg()

	local function tableTokeys(t)
		local keys = {}
		for k in pairs(t) do
			table.insert(keys, k)
		end
		return keys
	end

	for _, cfg in ipairs(CfgList) do
	    if cfg.ID > 0 then
	        local AppID = cfg.ID
	        local IsSpecial = WardrobeUtil.GetIsSpecial(AppID)
	        local ProfLimit = {}
			local ClassLimit = {}

	        -- 特殊外观处理
	        if IsSpecial then
	            local itemID = WardrobeUtil.GetUnlockCostItemID(AppID)
	            local itemCfg = ItemCfg:FindCfgByKey(itemID) or {}
				if itemCfg ~= nil then
	           		ProfLimit = itemCfg.ProfLimit or {}
	            	ClassLimit = itemCfg.ClassLimit == 0 and {} or {itemCfg.ClassLimit}
				end
	        else
				  -- 普通外观处理
	            local equipCfgs = EquipmentCfg:FindAllCfgByAppearanceID(AppID)
	            local profSet = {}
	            local classSet = {}
	            local hasEmptyCondition = false

	            -- 遍历收集限制条件
	            for _, equipCfg in ipairs(equipCfgs) do
	                local itemCfg = ItemCfg:FindCfgByKey(equipCfg.ID) or {}
	                if itemCfg.ProfLimit and itemCfg.ClassLimit then
	                    -- 检测是否存在无限制条件
	                    if #itemCfg.ProfLimit == 0 and itemCfg.ClassLimit == 0 then
	                        hasEmptyCondition = true
	                    else
	                        -- 使用哈希表去重职业限制
	                        for _, prof in ipairs(itemCfg.ProfLimit) do
	                            if prof ~= 0 then profSet[prof] = true end
	                        end
	                        -- 去重职业分支限制
	                        local class = itemCfg.ClassLimit
	                        if class ~= 0 then classSet[class] = true end
	                    end
	                end
	            end

	            -- 处理最终限制条件
	            if hasEmptyCondition then
	                ProfLimit = {0}
	                ClassLimit = {0}
	            else
	                -- 转换哈希表为数组
	                ProfLimit = tableTokeys(profSet)
	                ClassLimit = tableTokeys(classSet)
	                -- 默认值处理
	                if #ProfLimit == 0 then ProfLimit = {0} end
	                if #ClassLimit == 0 then ClassLimit = {0} end
	            end
	        end

	        AppList[AppID] = {ProfLimit = ProfLimit, ClassLimit = ClassLimit}
	    end
	end

	-- 更新所有职业
	local function UpdateAllProf()
		for key, value in pairs(self.AppearanceCollectTotal) do
			self.AppearanceCollectTotal[key] = self.AppearanceCollectTotal[key] + 1
		end
	end

	local function UpdateProfessionCounts(ProfLimits)
		local Desc = ""
		for profID, v in pairs(ProfLimits) do
			local CurProfID = GetProfID(profID)
			if self.AppearanceCollectTotal[CurProfID] then
				self.AppearanceCollectTotal[CurProfID] = self.AppearanceCollectTotal[CurProfID] + 1
		        --FLOG_INFO(string.format("更新职业 %s",  ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, tonumber(CurProfID))))
				-- Desc = Desc .. string.format(" %s",  ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, tonumber(CurProfID)))
			end
		end
		--FLOG_INFO(string.format("<janlog> 职业外观 ： %s ", Desc))
	end

    -- 处理所有外观数据
    for appid, data in pairs(AppList) do
        if IsUniversalAppearance(data) then
			-- FLOG_INFO(string.format("<janlog> AppList GetAppearanceCollectTotalNum 全职业外观 ： %d ", appid))
            UpdateAllProf()
        else
            local ProfLimits = GetValidProfessions(data)
			-- FLOG_INFO(string.format("<janlog> AppList GetAppearanceCollectTotalNum 非职业外观 ： %d ", appid))
            UpdateProfessionCounts(ProfLimits)
        end
    end
    
    return self.AppearanceCollectTotal[ProfID]
end

--筛选出这个职业已解锁的外观总量
function WardrobeMgr:GetUnlockAppearanceCollectNum(OutProfID, IsUpdate)
	--不更新
	if not IsUpdate then
		local ProfID = GetProfID(OutProfID)
		if self.UnlockAppearanceCollect[ProfID] ~= nil then
			return self.UnlockAppearanceCollect[ProfID] or 0
		end
		return
	end
	-- 构造一个外观Map
	for _, v in pairs(ProtoCommon.prof_type) do
		if v > 0 then
			self.UnlockAppearanceCollect[tostring(v)] = 0
		end
	end

	-- 构造一个外观Map
	local AppList = {}
	for _, value in pairs(self.UnlockedAppearance) do
		local AppID = value.AppearanceID
		if AppID > 0 then
			AppList[AppID] = {ProfLimit = value.ProfLimits, ClassLimit = value.ClassLimits}
		end
	end

	local function UpdateAllProf()
		for key, value in pairs(self.UnlockAppearanceCollect) do
			self.UnlockAppearanceCollect[key] = self.UnlockAppearanceCollect[key] + 1
		end
	end

	local function UpdateProfessionCounts(ProfLimits)
		local Desc = ""
		for profID, v in pairs(ProfLimits) do
			if profID ~= 0 then
				local CurProfID = GetProfID(profID)
				if self.UnlockAppearanceCollect[CurProfID] then
					self.UnlockAppearanceCollect[CurProfID]  = self.UnlockAppearanceCollect[CurProfID] + 1
					-- FLOG_INFO(string.format("更新职业 %s",  ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, tonumber(CurProfID))))
					-- Desc = Desc .. string.format(" %s",  ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, tonumber(CurProfID)))
				end
			end
		end
		-- FLOG_INFO(string.format("解锁职业外观 ： %s ", Desc))
	end

	 -- 处理所有外观数据
	 for appid, data in pairs(AppList) do
        if IsUniversalAppearance(data) then
			-- FLOG_INFO(string.format("<janlog> AppList GetUnlockAppearanceCollectNum 全职业外观 ： %d ", appid))
            UpdateAllProf()
        else
            local ProfLimits = GetValidProfessions(data)
			-- FLOG_INFO(string.format("<janlog> AppList GetUnlockAppearanceCollectNum 非职业外观 ： %d ", appid))
            UpdateProfessionCounts(ProfLimits)
        end
    end


	return self.UnlockAppearanceCollect[tostring(ProfID)] or 0
end

--- 获取职业列表
function WardrobeMgr:GetProfList()
	local List =  WardrobeDefine.ProfInfo
    local RealProfIDList = {}

    for key, value in pairs(List) do
        local Cfg = RoleInitCfg:FindCfgByKey(key)
		if Cfg ~= nil then
        	local AProfID = Cfg.AdvancedProf ~= 0 and Cfg.AdvancedProf or key
        	if not table.contain(RealProfIDList, AProfID) then
        	    table.insert(RealProfIDList, AProfID)
        	end
		end
    end

	return RealProfIDList
end


local function ConvertNoRepeatProfLimit(ClassLimit, ProfTable)
	local RetProfTable = {}
	if #ClassLimit > 0 then
		for i = 1 , #ClassLimit do
			local Cfg = ProfClassCfg:FindCfgByKey(ClassLimit[i])
			if Cfg ~= nil then
				for index, subProf in ipairs(Cfg.Prof) do
					if not table.contain(RetProfTable, subProf) then
						table.insert(RetProfTable, subProf)
					end
				end
			end
		end
	end

	if #ProfTable > 0 then
		for i = 1, #ProfTable do
			if not table.contain(RetProfTable, ProfTable[i]) then
				table.insert(RetProfTable, ProfTable[i])
			end
		end
	end

	return RetProfTable
end

---@param int32 AppearanceID 外观ID
---@return boolean 同模装备是否有更加优的条件
function WardrobeMgr:IsLessReduceConditionEquipment(AppearanceID)

	-- 检查服务器数据确定有可以降低条件
	if not self:CheckedAppDataByServerData(AppearanceID) then
		return  false
	end

	-- 服务器数据
	local ServerData = self:GetUnlockAppearanceDataByID(AppearanceID)
	local ServerRaceLimit = WardrobeMgr:GetRaceLimit(ServerData)
	local ServerGenderLimit = WardrobeMgr:GetGenderLimit(ServerData)
	local ServerLevelLimit = WardrobeMgr:GetLevelLimit(ServerData)
	local ServerProfLimit = WardrobeMgr:GetProfLimit(ServerData)
	local ServerClassLimit = WardrobeMgr:GetClassLimits(ServerData)
	local ServerProfList = ConvertNoRepeatProfLimit(ServerClassLimit, ServerProfLimit)

	-- 客户端数据
	local EquipmentList = {}
	local TempEquipmentList = WardrobeUtil.GetBagOwnAppearanceEquipmentList(AppearanceID)
	for _, v in ipairs(TempEquipmentList) do
		if not table.contain(EquipmentList, v.ResID) then
			table.insert(EquipmentList, {ResID = v.ResID})
		end
	end

	-- 判断种族跟性别
	for _, v in ipairs(EquipmentList) do
		local Item = ItemCfg:FindCfgByKey(v.ResID)
		if Item ~= nil then
			local ItemRaceLimit = Item.UseCond == 0 and ProtoCommon.race_type.RACE_TYPE_NULL or WardrobeUtil.GetClientRaceCond(Item.UseCond)
			local ItemGenderLimit = Item.UseCond == 0 and ProtoCommon.role_gender.GENDER_UNKNOWN or WardrobeUtil.GetClientGenderCond(Item.UseCond)

			local MajorRaceID = MajorUtil.GetMajorRaceID()
			local MajorGender = MajorUtil.GetMajorGender()

			if ServerRaceLimit ~= ProtoCommon.race_type.RACE_TYPE_NULL then
				if ItemRaceLimit == ProtoCommon.race_type.RACE_TYPE_NULL then
					return true
				end
				if ServerRaceLimit ~= MajorRaceID then
					if ItemRaceLimit == MajorRaceID then
						return true
					end
				end
			end

			if ServerGenderLimit ~= ProtoCS.GenderLimit.GENDER_ALL then
				if ItemGenderLimit == ProtoCommon.role_gender.GENDER_UNKNOWN then
					return true
				end
				if ServerGenderLimit ~= MajorGender then
					if ItemGenderLimit == MajorGender then
						return true
					end
				end
			end
		end
	end

	-- 判断大类，职业, 以及等级
	for _, v in ipairs(EquipmentList) do
		local Item = ItemCfg:FindCfgByKey(v.ResID)
		if Item ~= nil then
			-- 解锁的外观限制等级大于物品的限制等级
			local ItemProfLimit = Item.ProfLimit
			local ItemLevelLimit = Item.Grade
			local ItemClassLimit = Item.ClassLimit

			-- 把服务器/客户端的装备的职业大类,职业小类判断是否包含
			local TempItemProfList = ConvertNoRepeatProfLimit({ItemClassLimit}, ItemProfLimit)
			if not( ( table.is_nil_empty(ServerClassLimit) or ServerClassLimit[1] == 0 ) and ( table.is_nil_empty(ServerProfLimit) or ServerProfLimit[1] == 0 )) then
				for _, value in ipairs(TempItemProfList) do
					if not table.contain(ServerProfList, value) then
						return true
					end
				end
			end
 
			if ItemLevelLimit < ServerLevelLimit then
				return true
			end
		end
	end
	
	return false
end

function WardrobeMgr:CheckedAppDataByServerData(AppearanceID)
	local ServerData = self:GetUnlockAppearanceDataByID(AppearanceID)

	if ServerData == nil then
		return false
	end

	-- 服务器数据
	local ServerRaceLimit = WardrobeMgr:GetRaceLimit(ServerData)
	local ServerGenderLimit = WardrobeMgr:GetGenderLimit(ServerData)
	local ServerLevelLimit = WardrobeMgr:GetLevelLimit(ServerData)
	local ServerProfLimit = WardrobeMgr:GetProfLimit(ServerData)
	local ServerClassLimit = WardrobeMgr:GetClassLimits(ServerData)

	-- 检查服务器数据是否有存在可降低的条件
	local IsReduceConditon = false
	if ServerRaceLimit ~= ProtoCommon.race_type.RACE_TYPE_NULL then
		IsReduceConditon = true
	end

	if ServerGenderLimit ~= ProtoCS.GenderLimit.GENDER_ALL then
		IsReduceConditon = true
	end

	if not ( 
			 (table.is_nil_empty(ServerClassLimit) and table.is_nil_empty(ServerProfLimit))  or 
			 (ServerClassLimit[1] == 0 and table.is_nil_empty(ServerProfLimit)) or
			 (ServerClassLimit[1] == 0 and ServerProfLimit[1] == 0)
	) 
	then
		IsReduceConditon = true
	end

	if ServerLevelLimit > 1 then
		IsReduceConditon = true
	end

	return IsReduceConditon
end

-- 获取当前穿着是否有机关
-- 先判断穿戴头部外观，如果穿戴头部外观, 获取穿戴头部的Equip
-- 再判断当前穿戴的头部装备，如果穿戴头部装备，获取穿戴头部的
function WardrobeMgr:CheckHeadHasGimmick()
	local HasGimmick = false
	local AppData = self.CurAppearanceIDList[EquipmentPartList.EQUIP_PART_HEAD]
	if AppData ~= nil then
		local AppID = AppData.Avatar
		local ECfg = EquipmentCfg:FindAllCfgByAppearanceID(AppID)
		if not table.is_nil_empty(ECfg) then
			return _G.EquipmentMgr:IsEquipHasGimmick(ECfg[1].ID)
		end
	else
		local Equip =  _G.ActorMgr:GetMajorRoleDetail().Equip
		local TempEquipList = Equip.EquipList
		if TempEquipList == nil then
			return false
		end

		local TempInitialData = TempEquipList[EquipmentPartList.EQUIP_PART_HEAD] 
		if TempInitialData == nil then
			return false
		end

		if TempInitialData ~= nil then
			return _G.EquipmentMgr:IsEquipHasGimmick(TempInitialData.ResID)
		end

	end

	return HasGimmick
end

---@type 获取摄像机配置
---@param AttachType string SkeletonName 骨骼模型名
---@param CameraIndex number 
function WardrobeMgr:GetCameraControlParams(AttachType, CameraIndex)
    local CameraParams = {}
    local CameraCfg = ClosetCameraParamsCfg:FindCfg(string.format("SkeletonName = \"%s\"", AttachType))

    if CameraCfg then
        CameraParams.Distance = CameraCfg.ViewDistanceList[CameraIndex]
        CameraParams.Offset = CameraCfg.OffsetList[CameraIndex]
        local Rot = CameraCfg.RotationList[CameraIndex]
        CameraParams.Rotation = {X = Rot.Y, Y = Rot.Z, Z = Rot.X}
        CameraParams.FOV = CameraCfg.FOVList[CameraIndex]
    end

    return CameraParams
end

function WardrobeMgr:GetProfLimit(Data)
    return Data.ProfLimits
end

function WardrobeMgr:GetRaceLimit(Data)
	if table.is_nil_empty(Data.RaceLimits) then
		return 0
	end
	return Data.RaceLimits[1]
end

function WardrobeMgr:GetLevelLimit(Data)
	return Data.LevelLimit
end

function WardrobeMgr:GetClassLimits(Data)
	return Data.ClassLimits
end

function WardrobeMgr:GetGenderLimit(Data)
	return Data.GenderLimit
end

-- 获取正在穿着的界面外观
function WardrobeMgr:GetClothingViewSuit(Part)
	if self.ViewSuit[Part] == nil then
		return nil
	end

	for key, v in pairs(self.ViewSuit) do
		if key == Part then
			return v.Avatar
		end
	end
end

-- 设置解锁外观列表
function WardrobeMgr:SetPlanUnlockAppearanceList(List)
	self.PlanUnlockAppearanceList = List
end

-- 获取解锁外表列表
function WardrobeMgr:GetPlanUnlockAppearanceList()
	return self.PlanUnlockAppearanceList
end

-- 清除解锁外观列表
function WardrobeMgr:ClearPlanUnlockAppearanceList()
	self.PlanUnlockAppearanceList = {}
end

function WardrobeMgr:CheckTwoHandWeaponProf(ProfID)
	local TwoHandProfList = {
		ProtoCommon.prof_type.PROF_TYPE_GLADIATOR,
		ProtoCommon.prof_type.PROF_TYPE_PALADIN,
		ProtoCommon.prof_type.PROF_TYPE_PUGILIST,
		ProtoCommon.prof_type.PROF_TYPE_MONK,
	}

	if ProfID == nil then return false end
	for _, profID in ipairs(TwoHandProfList) do
		if ProfID == profID then
			return true
		end
	end
	return false
end

function WardrobeMgr:SetRedDot()
	local _ <close> = CommonUtil.MakeProfileTag("WardrobeMgr_SetRedDot")

	local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
	local IsQuickUnlock = WardrobeMgr:GetQuickUnlockAppearanceListVisible(true)
	if 	IsQuickUnlock then
		RedDotMgr:AddRedDotByID(WardrobeDefine.RedDotList.QuickUnlock)
	else
		RedDotMgr:DelRedDotByID(WardrobeDefine.RedDotList.QuickUnlock)
	end
end

function WardrobeMgr:GetQuickUnlockAppearanceListVisible(IsNeedItem)
	local BagMgr = _G.BagMgr
	local bNeedItem = IsNeedItem or false
	local JudegeFunction = bNeedItem and WardrobeUtil.JudgeUnlockAppearanceItem  or WardrobeUtil.JudgeUnlockAppearanceWithouItem

	-- 查找背包里的装备1.是否有可以解锁的外观 2.同模装备中装备可以染色的 3.同模装备中可以有更低的激活条件的装备
	local lstEquipments = BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP)
	for _, v in ipairs(lstEquipments) do
		local Cfg = EquipmentCfg:FindCfgByKey(v.ResID)
		if Cfg ~= nil and Cfg.AppearanceID ~= 0 then
			local AppID = Cfg.AppearanceID
			local IsUnlock = self:GetIsUnlock(AppID)
			if not IsUnlock then
				if JudegeFunction(AppID) then
					return true
				end
			else
				local IsEnough = BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(AppID)) > 0
				if self:IsLessReduceConditionEquipment(AppID) and IsEnough then
					return true
				end
			end
		end
	end

	local EquipList = EquipmentVM.ItemList
	for _, v in pairs(EquipList) do
		local Cfg = EquipmentCfg:FindCfgByKey(v.ResID)
		if Cfg ~= nil and Cfg.AppearanceID ~= 0 then
			local AppID = Cfg.AppearanceID
			local IsUnlock = self:GetIsUnlock(AppID)
			if not IsUnlock then
				if JudegeFunction(AppID) then
					return true
				end
			else
				local CanDye = WardrobeMgr:GetDyeEnable(AppID)
				local ItemList = WardrobeUtil.GetBagOwnAppearanceEquipmentList(AppID)
				for _, value in ipairs(ItemList) do
					local Item = EquipmentCfg:FindCfgByKey(value.ID)
					if Item ~= nil then
						if (not CanDye) and Item.CanBeDyed then
							return true
						end
					end
				end

				local IsEnough = BagMgr:GetItemNum(WardrobeUtil.GetUnlockCostItemID(AppID)) > 0

				if self:IsLessReduceConditionEquipment(AppID) and IsEnough then
					return true
				end
			end
		end
	end

	-- 特殊外观
	local BagList = _G.BagMgr:GetItemByCondition(function(Item)
		local ItemConfig = ItemCfg:FindCfgByKey(Item.ResID)
		return ItemConfig ~= nil and ItemConfig.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FASHION
	end)
	
	for _, v in ipairs(BagList) do
		if v.ResID ~= 0 then
			local ItemC = ItemCfg:FindCfgByKey(v.ResID)
			if ItemC ~= nil then
				local EquipCfg = EquipmentCfg:FindCfgByKey(ItemC.EquipmentID)
				if EquipCfg ~= nil then
					local AppID = EquipCfg.AppearanceID
					if not self:GetIsUnlock(AppID) then
						local AppCfg = ClosetCfg:FindCfgByKey(AppID)
						if AppCfg ~= nil then
							local ItemNum = BagMgr:GetItemNum(AppCfg.UnlockCostItemID)				
							local CostItemNum = AppCfg.UnlockCostItemNum
							if ItemNum >= CostItemNum then
								return true
							end	
						end
					end
				end
			end
		end
	end
	
	return false
end

function WardrobeMgr:GetQuickUnlockAppearanceList()
	local _ <close> = CommonUtil.MakeProfileTag("WardrobeMgr_GetQuickUnlockAppearanceList")
    local BagMgr = _G.BagMgr
	local AppearanceList = {}
	local CacheAppearanceList = {}

    local JudegeFunction =  WardrobeUtil.JudgeUnlockAppearanceWithouItem

	local function RepeatCacheAppearanceList(AppID)
		return CacheAppearanceList[tostring(AppID)] ~= nil
	end

	local function AddCacheAppearanceList(AppID)
		if not CacheAppearanceList[tostring(AppID)]  then
		CacheAppearanceList[tostring(AppID)] = true
		table.insert(AppearanceList, AppID)
		end
	end

    -- 检查背包装备
    local lstEquipments = BagMgr:FindItemsByItemType(ProtoCommon.ITEM_TYPE.ITEM_TYPE_EQUIP)
    for _, v in ipairs(lstEquipments) do
		local Cfg = EquipmentCfg:FindCfgByKey(v.ResID)
        if Cfg and Cfg.AppearanceID ~= 0 then
			local AppID = Cfg.AppearanceID
			local AppCfg = ClosetCfg:FindCfgByKey(AppID)
			if AppCfg ~= nil then
				if not RepeatCacheAppearanceList(AppID) then
					-- 未解锁
					if not self:GetIsUnlock(AppID) then
						if JudegeFunction(AppID) then
							AddCacheAppearanceList(AppID)
						end
					else
						local CanDye = WardrobeMgr:GetDyeEnable(AppID)
						if not CanDye then
							local ItemList = WardrobeUtil.GetBagOwnAppearanceEquipmentList(AppID)
							for _, value in ipairs(ItemList) do
								local Item = EquipmentCfg:FindCfgByKey(value.ID)
								if Item ~= nil then
									if Item.CanBeDyed then
										AddCacheAppearanceList(AppID)
									end
								end
							end
						end

						if self:IsLessReduceConditionEquipment(AppID)  then
							AddCacheAppearanceList(AppID)
						end
					end
				end
			end
		end
    end

    -- 检查EquipmentVM中的装备
    local EquipList = EquipmentVM.ItemList
    for _, v in pairs(EquipList) do
		local Cfg = EquipmentCfg:FindCfgByKey(v.ResID)
        if Cfg and Cfg.AppearanceID ~= 0 then
			local AppID = Cfg.AppearanceID
			local AppCfg = ClosetCfg:FindCfgByKey(AppID)
			if AppCfg ~= nil then
				if not RepeatCacheAppearanceList(AppID) then
					if not self:GetIsUnlock(AppID) then
						if JudegeFunction(AppID) then
							AddCacheAppearanceList(AppID)
						end
					else
						local CanDye = WardrobeMgr:GetDyeEnable(AppID)
						if not CanDye then
							local ItemList = WardrobeUtil.GetBagOwnAppearanceEquipmentList(AppID)
							for _, value in ipairs(ItemList) do
								local Item = EquipmentCfg:FindCfgByKey(value.ID)
								if Item ~= nil then
									if Item.CanBeDyed then
										AddCacheAppearanceList(AppID)
									end
								end
							end
						end

						if self:IsLessReduceConditionEquipment(AppID)  then
							AddCacheAppearanceList(AppID)
						end
					end
				end
			end
		end
    end

    -- 2. 检查特殊外观（拼贴时装）
    local BagList = _G.BagMgr:GetItemByCondition(function(Item)
        local ItemConfig = ItemCfg:FindCfgByKey(Item.ResID)
        return ItemConfig and ItemConfig.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_FASHION
    end)

    for _, v in ipairs(BagList) do
        local ItemC = ItemCfg:FindCfgByKey(v.ResID)
        if ItemC and ItemC.EquipmentID ~= 0 then
            local EquipCfg = EquipmentCfg:FindCfgByKey(ItemC.EquipmentID)
            if EquipCfg then
                local AppID = EquipCfg.AppearanceID
                if not self:GetIsUnlock(AppID) and not RepeatCacheAppearanceList(AppID) then
                    local AppCfg = ClosetCfg:FindCfgByKey(AppID)
                    if AppCfg and AppCfg.UnlockCostItemID then
                        local ItemNum = BagMgr:GetItemNum(AppCfg.UnlockCostItemID)
                        local CostItemNum = AppCfg.UnlockCostItemNum or 0
                        if ItemNum >= CostItemNum then
							AddCacheAppearanceList(AppID)
                        end
                    end
                end
            end
        end
    end

	return AppearanceList
end


--要返回当前类
return WardrobeMgr
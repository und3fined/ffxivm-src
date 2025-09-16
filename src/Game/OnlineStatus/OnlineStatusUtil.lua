--
-- Author: loiafeng
-- Date : 2023-03-01 09:56:38
-- Description: 用于处理在线状态的工具函数
--

local OnlineStatusUtil = {}
local MajorUtil = require("Utils/MajorUtil")
local ActorUIUtil = require("Utils/ActorUIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local OnlineStatusCfg = require("TableCfg/OnlineStatusCfg")
local ProtoRes = require("Protocol/ProtoRes")

local OnlineStatusDefine = require("Game/OnlineStatus/OnlineStatusDefine")
local ProtoOnlineStatusRes = ProtoRes.OnlineStatus
local ProtoOnlineStatusIdentify = ProtoRes.OnlineStatusIdentify
local table = _G.table

------------ 位集处理函数 BEGIN ------------

---解码位集。举例: 0x31 -> {0, 4, 5}
---@param Bitset uint64 位集
---@return table 返回Index列表 {[1] = Index, ...} Index从0开始，Index 0 代表 Bitset 的第一位
function OnlineStatusUtil.DecodeBitset(Bitset)
    local Result = {}
    if nil ~= Bitset then 
        local Index = 0
        while Bitset ~= 0x00 do
            if (Bitset & 0x01) == 0x01 then
                table.insert(Result, Index)
            end
            Bitset = Bitset >> 1
            Index = Index + 1
        end
    end
    return Result
end

---编码位集。{0, 4, 5} -> 0x31
---@param IndexList table Index列表 {[1] = Index, ...}
---@return uint64 位集
function OnlineStatusUtil.EncodeBitset(IndexList)
    local Result = 0x00
    for _, Value in ipairs(IndexList) do
        Result = Result | (0x01 << Value)
    end
    return Result
end

---在列表中筛选指定条目
---@param IndexList table 需要处理的Index列表
---@param PrioritySet set 需要优先考虑的Index，形式: {[Index] = true, ...}
---@return table 处理后的列表，可以是空的{}
function OnlineStatusUtil.Select(IndexList, PrioritySet)
    local Result = {}
    for Index = 1, #IndexList do
        if PrioritySet[IndexList[Index]] == true then
            table.insert(Result, IndexList[Index])
        end
    end
    return Result
end

---在列表中剔除指定条目
---@param IndexList table 需要处理的在线状态列表
---@param IgnoreSet set 需要剔除的Index，形式: {[Index] = true, ...}
---@return table 返回处理后的列表，可以是空的{}
function OnlineStatusUtil.Trim(IndexList, IgnoreSet)
    local Result = {}
    for Index = 1, #IndexList do
        if IgnoreSet[IndexList[Index]] == nil then
            table.insert(Result, IndexList[Index])
        end
    end
    return Result
end

---查询目标位集中是否包含指定条目
---@param Bitset uint64 查询数据
---@param IgnoreSet set 需要判定的结构的Index，形式: {[Index] = true, ...}
---@return true 包含  false 不包含
function OnlineStatusUtil.Contain(Bitset, IgnoreSet)
    for Key, _ in pairs(IgnoreSet) do
        if OnlineStatusUtil.CheckBit(Bitset, Key) then
            return true
        end
    end
    return false
end

---判断位集中的某一位是否为1
---@param Bitset uint64 位集
---@param Index number 从0开始，Index 0 代表 Bitset 的第一位
---@return boolean
function OnlineStatusUtil.CheckBit(Bitset, Index)
    if Bitset and Index then
        return Bitset & (0x01 << Index) ~= 0x00
    end
    return false
end

---获取两个Bitset的差异部分
---@param A uint64 位集
---@param B uint64 位集
---@return Bitset
function OnlineStatusUtil.GetDiff(A, B)
    if A and B then
        return A ~ B
    end
    return A or B
end

---三十六进制字符串转换为10进制
---@param StringBase36 string 三十六进制字符串
---@return Bitset
function OnlineStatusUtil.GetOnlineStatusInBase36(StringBase36)
    local Value = 0
    for Index = 1, #StringBase36 do
        -- 36进制字符串
        local CurrentDigit = string.byte(string.sub(StringBase36, Index, Index))
        local NumDec = CurrentDigit >= 97 and CurrentDigit - 97 + 10 or CurrentDigit - 48  -- ASCII 'a': 97, '0': 48
        Value = Value * 36 + NumDec
    end
    return Value
end

------------ 位集处理函数 END ------------

local function StatusCompareByPriority(A, B)
    local CfgA = OnlineStatusCfg:FindCfgByKey(A)
    local CfgB = OnlineStatusCfg:FindCfgByKey(B)
    if nil == CfgA or nil == CfgB then
        _G.FLOG_ERROR("OnlineStatusCfg: Do not find the key!")
        return false
    end

    return CfgA.Priority < CfgB.Priority
end

---根据配表中的状态优先级进行排序
---@param Status table 需要处理的在线状态列表
function OnlineStatusUtil.SortByPriority(Status)
    table.sort(Status, StatusCompareByPriority)
end

---状态显示特殊处理 队伍类(如：队员 队长)图标 和 指导者类(如：指导者,新人...) 两类状态相遇的互换优先级
---@param Status table 需要处理的在线状态列表
function OnlineStatusUtil.SortByMentorStatusRule(Status)
    local function QueryFun(StatusID)
        local Cfg = OnlineStatusCfg:FindCfgByKey(StatusID)
        if Cfg == nil then
            return false
        end
        return OnlineStatusDefine.TeammatesStatus[Cfg.ID] ~= nil
    end

    local Value, _ = table.find_by_predicate(Status, QueryFun)
    if Value == nil then
       return
    end

    local FirstState = OnlineStatusCfg:FindCfgByKey(Status[1])
    if FirstState == nil then
        return
    end
    if OnlineStatusDefine.MentorReturnerNewbieStatus[FirstState.ID]  then
            table.remove_item(Status, Value)
            table.insert(Status, 1, Value)
    end
end


---简化DB查询，获取状态ID对应的信息
---@param StatusID number
---@return string, string Icon路径, Name
function OnlineStatusUtil.GetStatusRes(StatusID)
    local Cfg = OnlineStatusCfg:FindCfgByKey(StatusID)
    if Cfg == nil then
        _G.FLOG_ERROR("OnlineStatusUtil.GetStatusRes: Unknown StatusID: %d", StatusID or 0)
        return "", _G.LSTR(730007)
    end

    return Cfg.Icon, Cfg.Name
end

-- 判断是否是队友  小队队友 副本内队友 剧情辅助器队友
function OnlineStatusUtil.IsTeamMember(EntityID)
	return ActorUIUtil.IsTeamMember(EntityID)
end

-- 剔除玩家自己需要忽略的状态
function OnlineStatusUtil.RemoveMajorIgnoreStatus(NewStatus)
    local NewStatusList = OnlineStatusUtil.DecodeBitset(NewStatus)
	NewStatusList = OnlineStatusUtil.Trim(NewStatusList, OnlineStatusDefine.MajorStatusIgnore)
	return OnlineStatusUtil.EncodeBitset(NewStatusList)
end

--- 主角是否为指导者身份
function OnlineStatusUtil.IsMentorMajor()
	local RoleIdentity = (MajorUtil.GetMajorRoleVM() or {}).Identity
    local MajorIdentity = OnlineStatusUtil.QueryMentorRelatedIdentity(RoleIdentity)
	return MajorIdentity == ProtoOnlineStatusIdentify.OnlineStatusIdentifyMentor
end

------------ 其他模块的接口函数 BEGIN ------------

---获取新人频道需要显示图标
---@param Identity Bitset 玩家身份
---@param StatusID number 玩家主动设置的在线状态ID
---@param OnlineStatus Bitset 玩家在线状态
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetChatNewbieChannelStatusIcon(Identity, StatusID, OnlineStatus)
	if OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyNewHand)
	or OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyNewHandChat) then
		--新人， 对于加入新人频道的新人，也只显示新人图标
        local Icon, _ = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusNewHand)
        return Icon
	elseif OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyReturner) then
		--回归者
		local Icon, _ = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusReturner)
        return Icon
	elseif OnlineStatusUtil.Contain(Identity, OnlineStatusDefine.MentorIdentitys) then
		--指导者
        local Icon
        if OnlineStatusDefine.MentorStatus[StatusID] then
            Icon = OnlineStatusUtil.GetStatusRes(StatusID)
        else
            -- 如果没有主动设置为指导者，则 大皇冠指导者＞战斗指导者＞采集指导者＞对战指导者(暂时没有相关身份)＞内测指导者（未开发，后续会新增）
            if OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyMentor) then
                Icon = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusMentor)
            elseif OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyBattleMentor) then
                Icon = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusCombatMentor)
            elseif OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyMakeMentor) then
                Icon = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusMakeMentor)
            elseif OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyRedFlowerMentor) then
                Icon = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusRedFlowerMentor)
            end
        end
        return Icon
    elseif OnlineStatusUtil.Contain(Identity, OnlineStatusDefine.UnverifiedMentorIdentitys) then
		--未认证的指导者
        return OnlineStatusDefine.UnverifiedMentorIcon
	end
    return nil
end

---获取队伍频道需要显示图标
---@param Identity Bitset 玩家身份
---@param StatusID number 玩家主动设置的在线状态ID
---@param OnlineStatus Bitset 玩家在线状态
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetChatTeamChannelStatusIcon(Identity, StatusID, OnlineStatus)
    local StatusList = OnlineStatusUtil.DecodeBitset(OnlineStatus)
    StatusList = OnlineStatusUtil.Select(StatusList, OnlineStatusDefine.TeammatesStatus)
    if table.empty(StatusList) then
        return nil
    end
    OnlineStatusUtil.SortByPriority(StatusList)
    return OnlineStatusUtil.GetStatusRes(StatusList[1])
end

---获取招募频道需要显示图标
---@param Identity Bitset 玩家身份
---@param StatusID number 玩家主动设置的在线状态ID
---@param OnlineStatus Bitset 玩家在线状态
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetChatRecruitChannelStatusIcon(Identity, StatusID, OnlineStatus)
    return OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusRecruit)
end

---获取聊天频道需要显示图标 用于需要显示在线状态但没有对应特殊规则的频道
---@param Identity Bitset 玩家身份
---@param StatusID number 玩家主动设置的在线状态ID
---@param OnlineStatus Bitset 玩家在线状态
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetChatChannelStatusIcon(Identity, StatusID, OnlineStatus)
    local StatusList = OnlineStatusUtil.DecodeBitset(OnlineStatus)
    StatusList = OnlineStatusUtil.Trim(StatusList, OnlineStatusDefine.TeammatesStatus)
    if table.empty(StatusList) then
        return nil
    end
    OnlineStatusUtil.SortByPriority(StatusList)
    return OnlineStatusUtil.GetStatusRes(StatusList[1])
end

---获取通常情况下（好友列表、个人信息、组队邀请等）需要显示的图标和名称，只考虑优先级，不考虑忽略规则等
---@param Status Bitset 玩家状态
---@return string, string, number Icon, Name, StatusID
function OnlineStatusUtil.GetDefaultStatusRes(Status)
    local StatusList = OnlineStatusUtil.DecodeBitset(Status)

    local Icon, Name, State
    if not table.empty(StatusList) then
		OnlineStatusUtil.SortByPriority(StatusList)
        OnlineStatusUtil.SortByMentorStatusRule(StatusList)
        State = StatusList[1]
		Icon, Name = OnlineStatusUtil.GetStatusRes(StatusList[1])
    else
        -- 永远都会有状态显示，即便离线
        _G.FLOG_WARNING("OnlineStatusUtil.GetDefaultStatusRes: StatusList is empty or Icon is not valid!")
        State = ProtoOnlineStatusRes.OnlineStatusOffline
        Icon, Name = OnlineStatusUtil.GetStatusRes(State)
    end

    return Icon, Name, State
end

---获取场景中需要显示的图标
---@param Status Bitset 玩家状态
---@param EntityID number EntityID
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetVisionStatusIcon(Status, EntityID)
    local StatusList = OnlineStatusUtil.DecodeBitset(Status)

    -- 忽略 离线、在线、封闭任务中 三种状态
    local ListAfterTrim = OnlineStatusUtil.Trim(StatusList, OnlineStatusDefine.VisionStatusIgnore)
    if not OnlineStatusUtil.IsTeamMember(EntityID) then
        ListAfterTrim = OnlineStatusUtil.Trim(ListAfterTrim, OnlineStatusDefine.TeammatesStatus)
    end

    -- 副本和非副本处理下 断线重连状态的显示
    local OnlineStatusMgr = _G.OnlineStatusMgr
    local ShowElectrocardiogram 
    if _G.PWorldMgr:CurrIsInDungeon() then 
        ShowElectrocardiogram = OnlineStatusMgr:GetShowElectrocardiogramInPWorldTeam()
    else
        ShowElectrocardiogram = OnlineStatusMgr:GetShowElectrocardiogramInVision()
    end
    if not ShowElectrocardiogram then 
        for Index = #ListAfterTrim, 1, -1  do
            if ListAfterTrim[Index] == ProtoOnlineStatusRes.OnlineStatusElectrocardiogram then
                table.remove(ListAfterTrim, Index)
                break
            end
        end
    end

    if not table.empty(ListAfterTrim) then
        OnlineStatusUtil.SortByPriority(ListAfterTrim)

        local OnlineStatusID = ListAfterTrim[1]
        -- 对于加入新人频道的新人，只显示新人图标
        if OnlineStatusID == ProtoOnlineStatusRes.OnlineStatusJoinNewbieChannel then
            OnlineStatusID = ProtoOnlineStatusRes.OnlineStatusNewHand
        end

        local Icon, _ = OnlineStatusUtil.GetStatusRes(OnlineStatusID)
        return Icon
    end

    return nil
end

---获取导随副本场景中需要显示的图标，战斗指导者玩家强制显示战斗指导者图标
---@param Status Bitset 玩家状态
---@param Identity Bitset 玩家指导者身份
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetVisionStatusIconInMenter(Status, Identity, EntityID)
    if nil ~= Identity and OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyBattleMentor) then
        local Icon, _ = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusCombatMentor)
        return Icon
    else
        return OnlineStatusUtil.GetVisionStatusIcon(Status, EntityID)
    end
end

---获取客户端本地需要显示的状态图标
---@param EntityID number 实体ID
---@return string | nil 如果不应显示图标的话，会返回nil
function OnlineStatusUtil.GetVisionStatusIconInClientLocal(EntityID)
    if _G.ChocoboTransportMgr:GetActorIsTransporting(EntityID) then
        return _G.ChocoboTransportMgr:GetVisionStatusIcon()
    end
    return nil
end

---查询目标身份当前指导者的相关身份 是指导者、回归者、新人 
---@param Identity Bitset 玩家身份
---@return ProtoRes.OnlineStatusIdentify
function OnlineStatusUtil.QueryMentorRelatedIdentity(Identity)
    if Identity ~= nil then
        if OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyNewHandChat)
            or OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyNewHand) then
            return ProtoOnlineStatusIdentify.OnlineStatusIdentifyNewHand
        end

        if OnlineStatusUtil.CheckBit(Identity, ProtoOnlineStatusIdentify.OnlineStatusIdentifyReturner) then
            return ProtoOnlineStatusIdentify.OnlineStatusIdentifyReturner
        end

        if OnlineStatusUtil.Contain(Identity, OnlineStatusDefine.MentorIdentitys)
            or OnlineStatusUtil.Contain(Identity, OnlineStatusDefine.UnverifiedMentorIdentitys) then
            return ProtoOnlineStatusIdentify.OnlineStatusIdentifyMentor
        end
    end
    return ProtoOnlineStatusIdentify.OnlineStatusIdentifyNormal
end

---主角个人信息界面需要显示的图标和名称 特殊处理 需要将“已加入新人频道”图标 换成 “未已加入新人频道”图标
---@return string, string Icon, Name
function OnlineStatusUtil.GetMajorPersonInfoStatusRes()
    local RoleVM = MajorUtil.GetMajorRoleVM()
	if nil == RoleVM then
        _G.FLOG_WARNING("OnlineStatusUtil.GetMajorPersonInfoStatusRes: RoleVM is nil !")
		return OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusOnline)
	end
    local Icon, Name
    if OnlineStatusUtil.CheckBit(RoleVM.OnlineStatus, ProtoOnlineStatusRes.OnlineStatusLeave) then
		Icon, Name = OnlineStatusUtil.GetStatusRes(ProtoOnlineStatusRes.OnlineStatusLeave)
	else
		local OnlineStatusCustomID = RoleVM.OnlineStatusCustomID
		if OnlineStatusCustomID == ProtoOnlineStatusRes.OnlineStatusJoinNewbieChannel then
			OnlineStatusCustomID = ProtoOnlineStatusRes.OnlineStatusNewHand
		end
		Icon, Name = OnlineStatusUtil.GetStatusRes(OnlineStatusCustomID)
	end
    return Icon, Name
end

--- “内测指导者”消失处理
function OnlineStatusUtil.RedflowerMentorDisappear()
    local RedFlowerOnlineState = ProtoOnlineStatusRes.OnlineStatusRedFlowerMentor
    local _, Name = OnlineStatusUtil.GetStatusRes(RedFlowerOnlineState)
    MsgTipsUtil.ShowTips(string.format(_G.LSTR(OnlineStatusDefine.NotifyText.StatusDisappear), Name or ""))
end

------------ 其他模块的接口函数 END ------------


------- 测试函数 BEGIN -------

---转化为文本，用于打印
---@param Bitset number
---@return string
function OnlineStatusUtil.ToString(Bitset)
    local Status = OnlineStatusUtil.DecodeBitset(Bitset)
    local Result = {}

    for _, StatusID in ipairs(Status) do
        local Cfg = OnlineStatusCfg:FindCfgByKey(StatusID)
        if Cfg ~= nil then
            table.insert(Result, Cfg.Name)
        else
            _G.FLOG_ERROR("OnlineStatusUtil.ToString: Unknown StatusID: %d", StatusID)
        end
    end

    return table.concat(Result, " ")
end

------- 测试函数 END -------

return OnlineStatusUtil
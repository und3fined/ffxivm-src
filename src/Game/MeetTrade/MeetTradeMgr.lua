---
--- Author: usakizhang
--- DateTime: 2024-12-24 11:36:01
--- Description: 面对面交易
---
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local MajorUtil = require("Utils/MajorUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local MeetTradeVM = require("Game/MeetTrade/VM/MeetTradeVM")
local ProtoCommon = require("Protocol/ProtoCommon")
local SidebarMgr = require("Game/Sidebar/SidebarMgr")
local OnlineStatusMgr = require("Game/OnlineStatus/OnlineStatusMgr")
local ActorUtil = require("Utils/ActorUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local MeettradeParamCfg = require("TableCfg/MeettradeParamCfg")
local AudioUtil = require("Utils/AudioUtil")
local TimeUtil = require("Utils/TimeUtil")
local LSTR = _G.LSTR
local CS_CMD = ProtoCS.CS_CMD
local SidebarType = SidebarDefine.SidebarType
local MsgTipsUtil = _G.MsgTipsUtil
local MeetTradeParamsID = ProtoRes.MeetTradeParamsID
---@class MeetTradeMgr : MgrBase
local MeetTradeMgr = LuaClass(MgrBase)

local MajorState = {
    --可以交易的状态
    SuitableForTrade = 1,
    --不可交易状态
    NotSuitableForTrade = 2,
}

local MeetTradeCancelReason = {
    ---取消交易
    CancelTrade = 1,
    EnterCombat = 2,
    IsDead = 3,
    OnlineStatus = 4,
    EnterLevelConfirmView = 5,
    HasReachedGoldLimit = 6,
    BagIsFull = 7,
}

function MeetTradeMgr:OnInit()
    self:ReSet()
    ---初始化面对面交易全局参数
    self.DistanceLimit = MeettradeParamCfg:FindCfgByKey(MeetTradeParamsID.MeetTradeParamsID_ApplyDis).Value[1]
    self.GoldNumLimit = MeettradeParamCfg:FindCfgByKey(MeetTradeParamsID.MeetTradeParamsID_ScoreMax).Value[1]
    self.SelectListCapacity = MeettradeParamCfg:FindCfgByKey(MeetTradeParamsID.MeetTradeParamsID_ItemTypeNum).Value[1]
end

function MeetTradeMgr:ReSet()
    self.OtherIsReadyForTrade = false
    self.MajorIsReadyForTrade = false
    self.OtherIsSureForTrade = false
    self.MajorIsSureForTrade = false
    --当前交易的交易ID，也可用于判断当前是否处于交易状态
    self.TradeID = nil
    self.GoldForTrade = 0
end
function MeetTradeMgr:OnBegin()

end

function MeetTradeMgr:OnEnd()

end

function MeetTradeMgr:OnShutdown()

end

function MeetTradeMgr:OnRegisterNetMsg()
    --- 收到交易请求
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MEETTRADE, ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Apply, self.OnRecieveMeetTradeRequestFormOthers)
    --- 收到交易请求回复
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MEETTRADE, ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Reply, self.OnRecieveMeetTradeRequestReply)
    --- 收到对方放置物品的消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MEETTRADE, ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Place, self.OnRecieveOtherUpdateSelectItem)
    --- 收到对方锁定物品条件的消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MEETTRADE, ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Lock, self.OnRecieveOtherLockItem)
    --- 收到对方确认交易的消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MEETTRADE, ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Confirm, self.OnRecieveOtherConfirmTrade)
    --- 收到对方取消交易的消息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_MEETTRADE, ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Cancel, self.OnRecieveOtherCancelTrade)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
end


function MeetTradeMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.SidebarItemTimeOut, self.OnMeetTradeSidebarItemTimeOut) --侧边栏Item超时
    -- --监听死亡状态
    self:RegisterGameEvent(EventID.MajorDead, self.OnGameEventMajorDead)
    --监听战斗状态
    self:RegisterGameEvent(EventID.NetStateUpdate, self.OnGameEventCombatStateChanged)
    --监听离线状态、暂离状态以及剧情状态的事件
    self:RegisterGameEvent(EventID.OnlineStatusMajorChanged, self.OnGameEventOnlineStatusMajorChanged)
    --监听进入副本确认界面的事件
    self:RegisterGameEvent(EventID.EnterLevelConfirmView, self.OnEnterLevelConfirmView)

end

--- 向对方发送交易请求
function MeetTradeMgr:SendMeetTradeRequest(RoleID)
    ---校验我方状态
    local CurrentMajorState = self:CheckSelfIsSuitableForTrade(true)
    if  CurrentMajorState == MajorState.NotSuitableForTrade then
        return
    end

    ---校验对方状态
    local InviteeState = self:CheckOtherIsSuitableForTrade(RoleID)
    if InviteeState == false then
        return
    end
    ---本地初步校验通过，发送交易请求
    local MsgBody = {
		Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Apply,
		Apply = {
			InviteeID = RoleID,
		}
	}
	self:SendNetMsgMeetTrade(MsgBody)
    ---若角色铭牌处于打开状态，关闭角色铭牌
    if UIViewMgr:IsViewVisible(UIViewID.PersonInfoSimplePanel) then
        UIViewMgr:HideView(UIViewID.PersonInfoSimplePanel)
    end
end

---------------------------向服务器发送消息
function MeetTradeMgr:SendNetMsgMeetTrade(MsgBody)
    local MsgID = CS_CMD.CS_CMD_MEETTRADE
	local SubMsgID = MsgBody.Cmd
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function MeetTradeMgr:SendMeetTradeReply(InviterID, IsAccept)
    local MsgBody = {
		Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Reply,
		Reply = {
			InviterID = InviterID,
            Accept = IsAccept,
		}
	}
	self:SendNetMsgMeetTrade(MsgBody)
end

function MeetTradeMgr:SendMeetTradeCancel(Reason)
    if self.TradeID == nil then
        _G.FLOG_ERROR("MeetTradeMgr SendMeetTradeCancel: TradeID is nil")
        return
    end
    local MsgBody = {
        Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Cancel,
        Cancel = {
            TradeID = self.TradeID,
            Reason = Reason,
        }
    }
    self:SendNetMsgMeetTrade(MsgBody)
end

function MeetTradeMgr:SendMeetTradePlaceItem(Items, GoldNum)
    if self.TradeID == nil then
        _G.FLOG_ERROR("MeetTradeMgr SendMeetTradePlaceItem: TradeID is nil")
        return
    end
    ---检查物品是否发生了变化，如果没有则不发送
    if MeetTradeVM:CheckMajorItemListChange(Items) == false and GoldNum == self.GoldForTrade then
        _G.FLOG_INFO("MeetTradeMgr SendMeetTradePlaceItem: ItemList is not changed")
        return
    end
    ---添加金币至末尾
    if GoldNum > 0 then
        local GoldItem = {
            GID = 0,
            ResID = _G.BagMgr.RecoveryScoreID,
            Num = GoldNum,
        }
        table.insert(Items, GoldItem)
    end
    self.GoldForTrade = GoldNum
    local MsgBody = {
        Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Place,
        Place = {
            TradeID = self.TradeID,
            Items = Items,
        }
    }
    self:SendNetMsgMeetTrade(MsgBody)
end

function MeetTradeMgr:SendMeetTradeKeep()
    if self.TradeID then
        local MsgBody = {
            Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Keep,
            Keep = {
                Macro = {
                    None = 0,
                    Interval = 60,
                },
                TradeID = self.TradeID,
            }
        }
        self:SendNetMsgMeetTrade(MsgBody)
    end
end

function MeetTradeMgr:SendMeetTradeLock()
    if self.TradeID == nil then
        _G.FLOG_ERROR("MeetTradeMgr SendMeetTradeLock: TradeID is nil")
        return
    end
    if self.TradeID then
        local MsgBody = {
            Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Lock,
            Lock = {
                TradeID = self.TradeID,
            }
        }
        self:SendNetMsgMeetTrade(MsgBody)
    end
end

function MeetTradeMgr:SendMeetTradeConfirm()
    if self.TradeID == nil then
        _G.FLOG_ERROR("MeetTradeMgr SendMeetTradeConfirm: TradeID is nil")
        return
    end
    if self.TradeID then
        local MsgBody = {
            Cmd = ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Confirm,
            Confirm = {
                TradeID = self.TradeID,
            }
        }
        self:SendNetMsgMeetTrade(MsgBody)
    end
end
-----------------------------接收服务器下发的消息包
--- 收到交易请求
function MeetTradeMgr:OnRecieveMeetTradeRequestFormOthers(MsgBody)
    if nil == MsgBody or nil == MsgBody.Apply then
        return
    end
    local Data = MsgBody.Apply
    ---如果自己是邀请者，那么弹出Tips
    local InviterID = Data.InviterID
    if MajorUtil.GetMajorRoleID() == InviterID then
        ---获取被邀请者的信息
        _G.RoleInfoMgr:QueryRoleSimple(Data.InviteeID, function(_, RoleVM)
            MsgTipsUtil.ShowTips(string.format(LSTR(1490050), RoleVM.Name)) --已向%s发出交易邀请
        end, nil, true)
        return
    end
    ---如果自己是受邀者且自身状态可以交易，那么弹出侧边栏
    local InviteeID = Data.InviteeID
    if MajorUtil.GetMajorRoleID() == InviteeID then
        if self:CheckSelfIsSuitableForTrade(false) ~= MajorState.SuitableForTrade then
            self:SendMeetTradeReply(InviterID, false)
            return
        end
        ---请求邀请者角色信息，构建透传数据传递给侧边栏
        _G.RoleInfoMgr:QueryRoleSimple(Data.InviterID, function(Params, RoleVM)
            local InviterName = RoleVM.Name
            local TransData = {
                InviterID = Params.InviterID,
                InviterName = InviterName,
            }
            SidebarMgr:AddSidebarItem(SidebarType.MeetTradeRequest, TimeUtil.GetServerTime(), -1, TransData, true)
        end, Data, true)
        AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_notice_new.Play_SE_UI_SE_UI_notice_new'")
        ---获取被邀请者的信息
        _G.RoleInfoMgr:QueryRoleSimple(Data.InviterID, function(_, RoleVM)
            MsgTipsUtil.ShowTips(string.format(LSTR(1490056), RoleVM.Name)) --%s向您发出交易邀请
        end, nil, true)
    end
end


--- 收到交易请求的回复
function MeetTradeMgr:OnRecieveMeetTradeRequestReply(MsgBody)
    if nil == MsgBody or nil == MsgBody.Reply then
        return
    end
    local Data = MsgBody.Reply
    local Entry = Data.Entry
    if not Entry then
        _G.FLOG_ERROR("MeetTradeMgr:OnRecieveMeetTradeRequestReply", "MeetTradeEntry is nil")
        return
    end 
    ---如果自己是邀请者，收到拒绝回复弹出提示Tips
    ---如果收到接受回复，则校验自身状态，如果状态不对则取消交易，若状态正确，则拉起交易面板
    local InviterID = Entry.InviterID
    if MajorUtil.GetMajorRoleID() == InviterID then
        ---对方拒绝了交易
        if Data.Accept == false then
            _G.RoleInfoMgr:QueryRoleSimple(Entry.InviteeID, function(_, RoleVM)
                MsgTipsUtil.ShowTips(string.format(LSTR(1490051),RoleVM.Name))
            end, nil, true)
            return
        end
        ---否则对方同意了交易
        ---校验自身状态
        local State = self:CheckSelfIsSuitableForTrade(true)
        ---我方状态校验通过
        if State == MajorState.SuitableForTrade then
            self.TradeID = Entry.TradeID
            ---从成员列表中找到自己的交易税率
            for _, Member in ipairs(Entry.Members) do
                if Member.RoleID == MajorUtil.GetMajorRoleID() then
                    MeetTradeVM:SetTradeTaxRate(Member.TaxRate)
                    break
                end
            end
            --- 注册计时器，发送保活信息
            self.TimerID = self:RegisterTimer(self.SendMeetTradeKeep, 60, 60, 0, nil)
            self:OpenMeetTradeMainView(Entry.InviteeID)
            return
        else
            --- 发送交易取消的消息
            self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.CancelTrade))
            return
        end
    end

    ---如果自己是被邀者，说明上一次自己发送的回复消息已被服务端确认，那么拉起交易面板
    local InviteeID = Entry.InviteeID
    if MajorUtil.GetMajorRoleID() == InviteeID then
        ---我方接受了交易，拉起交易面板
        if Data.Accept == true then
            --- Mgr记录当前的交易ID
            self.TradeID = Entry.TradeID
            ---从成员列表中找到自己的交易税率
            for _, Member in ipairs(Entry.Members) do
                if Member.RoleID == MajorUtil.GetMajorRoleID() then
                    MeetTradeVM:SetTradeTaxRate(Member.TaxRate)
                    break
                end
            end
            --- 注册计时器，发送保活信息
            self.TimerID = self:RegisterTimer(self.SendMeetTradeKeep, 60, 60, 0, nil)
            self:OpenMeetTradeMainView(Entry.InviterID)
            return
        ---拒绝请求不用处理
        end

    end
end

---收到取消交易的消息
function MeetTradeMgr:OnRecieveOtherCancelTrade(MsgBody)
    if nil == MsgBody or nil == MsgBody.Cancel then
        return
    end
    local Data = MsgBody.Cancel
    ---如果取消交易的是自己
    if Data.RoleID == MajorUtil.GetMajorRoleID() then
        if tonumber(Data.Reason) == MeetTradeCancelReason.CancelTrade then
            MsgTipsUtil.ShowTips(LSTR(1490049)) --"您已取消交易"
            ---由取消方发送交易取消消息
            self:MeetTradeEnd()
        else
            self:MeetTradeEnd({TradeIsEnd = true})
        end
    else
        local Reason = tonumber(Data.Reason)
        self:ProcessMeetTradeCancel(Reason, Data.RoleID)
        ---被取消方发送交易带参数关闭界面，不发送取消消息
        self:MeetTradeEnd({TradeIsEnd = true})
    end
end

---收到玩家放置交易物品的消息
function MeetTradeMgr:OnRecieveOtherUpdateSelectItem(MsgBody)
    local Date = MsgBody.Place
    local Entry = Date.Entry
    if not Entry then
        _G.FLOG_ERROR("MeetTradeMgr:OnRecieveOtherUpdateSelectItem", "MeetTradeEntry is nil")
        return
    end
    if not self.TradeID and self.TradeID ~= Entry.TradeID then
        _G.FLOG_ERROR("MeetTradeMgr:OnRecieveOtherUpdateSelectItem", "RecieveErrorTradeCancelMessage")
        return
    end
    ---更新交易面板
    for _, Member in ipairs(Entry.Members) do
        ---更新对方交易面板
        if Member.RoleID  and Member.RoleID ~= MajorUtil.GetMajorRoleID() then
            if MeetTradeVM:CheckRoleItemListChange(Member.Items) then
                MeetTradeVM:UpdateRoleTradeItemListParams(Member.Items)
                local NewState = Member.State == 1
                MsgTipsUtil.ShowTips(LSTR(1490057)) --"对方修改了物品"
            end
            if self.OtherIsReadyForTrade ~= NewState then
                self.OtherIsReadyForTrade = NewState
                EventMgr:SendEvent(EventID.MeetTradeLockStateChange, Member)
            end
         ---更新自己交易面板
        elseif Member.RoleID  and Member.RoleID == MajorUtil.GetMajorRoleID() then
            MeetTradeVM:UpdateMajorTradeItemList(Member.Items)
            local NewState = Member.State == 1
            if self.MajorIsReadyForTrade ~= NewState then
                self.MajorIsReadyForTrade = NewState
                EventMgr:SendEvent(EventID.MeetTradeLockStateChange, Member)
            end
        end
    end

end

function MeetTradeMgr:OnRecieveOtherLockItem(MsgBody)
    local Date = MsgBody.Lock
    local Entry = Date.Entry
    for _, Member in ipairs(Entry.Members) do
        ---更新对方状态
        if Member.RoleID  and Member.RoleID ~= MajorUtil.GetMajorRoleID() then
            local NewState = Member.State == 1
            if self.OtherIsReadyForTrade ~= NewState then
                self.OtherIsReadyForTrade = NewState
                EventMgr:SendEvent(EventID.MeetTradeLockStateChange, Member)
            end
         ---更新自己的状态
        elseif Member.RoleID  and Member.RoleID == MajorUtil.GetMajorRoleID() then
            local NewState = Member.State == 1
            if self.MajorIsReadyForTrade ~= NewState then
                self.MajorIsReadyForTrade = NewState
                EventMgr:SendEvent(EventID.MeetTradeLockStateChange, Member)
            end
        end
    end
    --- 如果双方都准备好了，拉起确认面板
    if self.OtherIsReadyForTrade and self.MajorIsReadyForTrade then
        if not UIViewMgr:IsViewVisible(UIViewID.MeetTradeConfirmationView) then
            UIViewMgr:ShowView(UIViewID.MeetTradeConfirmationView)
        end
    end
end


---收到对方确认交易的消息
function MeetTradeMgr:OnRecieveOtherConfirmTrade(MsgBody)
    local Date = MsgBody.Confirm
    local Entry = Date.Entry
    local ItemList = nil
    for _, Member in ipairs(Entry.Members) do
        ---更新对方状态
        if Member.RoleID  and Member.RoleID ~= MajorUtil.GetMajorRoleID() then
            local NewState = Member.State == 2
            ItemList = Member.Items
            if self.OtherIsSureForTrade ~= NewState then
                self.OtherIsSureForTrade = NewState
                EventMgr:SendEvent(EventID.MeetTradeConfirmStateChange, Member)
            end
         ---更新自己的状态
        elseif Member.RoleID  and Member.RoleID == MajorUtil.GetMajorRoleID() then
            local NewState = Member.State == 2
            if self.MajorIsSureForTrade ~= NewState then
                self.MajorIsSureForTrade = NewState
                EventMgr:SendEvent(EventID.MeetTradeConfirmStateChange, Member)
            end
        end
    end
    if self.OtherIsSureForTrade and self.MajorIsSureForTrade then
        if UIViewMgr:IsViewVisible(UIViewID.MeetTradeConfirmationView) then
            UIViewMgr:HideView(UIViewID.MeetTradeConfirmationView)
        end
        self:MeetTradeEnd()
        self:OpenRewardPanel(ItemList)
    end
end
--收到保活消息的回包
function MeetTradeMgr:OnNetMsgError(MsgBody)
    local Msg = MsgBody
	if nil == Msg then
		return
	end
    local Cmd = Msg.Cmd
	if nil == Cmd then
		return
	end
    local SubCmd = Msg.SubCmd
    if nil == SubCmd then
        return
    end
    local ErrorCode = Msg.ErrCode
    if Cmd == CS_CMD.CS_CMD_MEETTRADE then
        if SubCmd == ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Keep then
            self:MeetTradeEnd({TradeIsEnd = true})
        elseif SubCmd == ProtoCS.CS_MEET_TRADE_CMD.CS_MEET_TRADE_CMD_Confirm then
            ---检查错误码
            if ErrorCode == 353035 then--金币达到上限,交易中止
                self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.HasReachedGoldLimit))
            elseif ErrorCode == 353036 then--背包已满,交易中止
                self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.BagIsFull))
            end
            self:MeetTradeEnd({TradeIsEnd = true})
        end
    end
end
-----------------------------------其他功能函数
--- 处理取消交易
function MeetTradeMgr:ProcessMeetTradeCancel(Reason,RoleID)
    if Reason == MeetTradeCancelReason.CancelTrade then
        _G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
            MsgTipsUtil.ShowTips(string.format(LSTR(1490044),RoleVM.Name))
        end, nil, true)
    elseif Reason == MeetTradeCancelReason.EnterCombat then
        MsgTipsUtil.ShowTips(LSTR(1490045)) --"对方进入了战斗状态,交易已取消"
    elseif Reason == MeetTradeCancelReason.IsDead then
        MsgTipsUtil.ShowTips(LSTR(1490046)) --"对方已死亡,交易已取消"
    elseif Reason == MeetTradeCancelReason.OnlineStatus then
        MsgTipsUtil.ShowTips(LSTR(1490047)) --"对方暂离或不在线,交易已取消"
    elseif Reason == MeetTradeCancelReason.EnterLevelConfirmView then
        MsgTipsUtil.ShowTips(LSTR(1490048)) --"对方已进入副本确认状态,交易已取消"
    elseif Reason == MeetTradeCancelReason.HasReachedGoldLimit then
        MsgTipsUtil.ShowTips(LSTR(1490055)) --"对方金币达到上限,交易中止"
    elseif Reason == MeetTradeCancelReason.BagIsFull then
        MsgTipsUtil.ShowTips(LSTR(1490060)) --"对方已进入副本确认状态,交易已取消"
    end
end
----- 打开通用奖励面板

function MeetTradeMgr:OpenRewardPanel(ItemList)
    if not ItemList or #ItemList < 1 then
        MsgTipsUtil.ShowTips(LSTR(1490054)) --"交易成功"
        return
    end
	local VMList = UIBindableList.New(ItemVM)
	local NewItemList = {}
	for _, V in ipairs(ItemList) do
        local Item = {
            ResID = V.ResID,
            Num = V.Num,
        }
        table.insert(NewItemList, Item)
	end
	for _, V in pairs(NewItemList) do
		VMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, IsValid = true, NumVisible = true, ItemNameVisible = true, IsShowNum = true }, nil, true)
	end
    _G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(740015), ItemVMList = VMList })
    -- local BtnRightCB = function()
    --     if UIViewMgr:IsViewVisible(UIViewID.CommonRewardPanel) then
    --         UIViewMgr:HideView(UIViewID.CommonRewardPanel)
    --     end
    -- end
	-- _G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(1490059), ItemVMList = VMList, ShowBtn = true, ShowBtnRight = true, BtnRightCB = BtnRightCB, BtnRightText = LSTR(10065)})
end

function MeetTradeMgr:CheckSelfIsSuitableForTrade(bShowTips)
    ---校验自身通用状态
    if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_MEETTRADE, bShowTips) then
        return MajorState.NotSuitableForTrade
    ---我方已经处于交易状态下、是否处于合适的地图，后台已处理，否则会导致重复弹窗
    --- 校验是否处于副本确定状态
    elseif _G.PWorldVoteMgr:GetEnterSceneRoleCnt() > 0 then
        if bShowTips then
            MsgTipsUtil.ShowTips(LSTR(1490043))
        end
        return MajorState.NotSuitableForTrade
    --"副本进入确认中无法进行面对面交易"
    elseif _G.PWorldEntourageMgr:GetConfirmState() then
        if bShowTips then
            MsgTipsUtil.ShowTips(LSTR(1490043))
        end
		return MajorState.NotSuitableForTrade
    else
        return MajorState.SuitableForTrade
    end
end

function MeetTradeMgr:CheckOtherIsSuitableForTrade(RoleID)
    if self:CheckOtherIsTooFarForTrade(RoleID) then
        MsgTipsUtil.ShowTips(LSTR(1490024))
        return false
    end
    ---其他状态校验
    local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
    local RoleStatComp = ActorUtil.GetActorStateComponent(EntityID)
    if nil == RoleStatComp then
        ---TODO 多语言接入
        MsgTipsUtil.ShowTips(LSTR(1490024))
        return false
    else
        if RoleStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT) then
            MsgTipsUtil.ShowTips(LSTR(1490021)) --"对方正处于战斗状态，请稍后再试试吧"
            return false
        elseif RoleStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_VIDEO) or RoleStatComp:IsInNetState(ProtoCommon.CommStatID.CommStatDialog) then
            MsgTipsUtil.ShowTips(LSTR(1490023)) --"对方正在观看剧情动画，请稍后再试试吧"
            return false

        elseif RoleStatComp:IsCrafting() or RoleStatComp:IsGathering() or RoleStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_SPELL) then
            MsgTipsUtil.ShowTips(LSTR(1490027)) --"对方正在忙，请稍后再试试吧"
            return false

        elseif OnlineStatusMgr:HasStatus(EntityID, ProtoRes.OnlineStatus.OnlineStatusLeave) or OnlineStatusMgr:HasStatus(EntityID, ProtoRes.OnlineStatus.OnlineStatusElectrocardiogram) then
            MsgTipsUtil.ShowTips(LSTR(1490028)) --"对方已离线，请稍后再试试吧"
            return false

        elseif RoleStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_DEAD) then
            MsgTipsUtil.ShowTips(LSTR(1490029)) --"对方已阵亡，请稍后再试试吧"
            return false
        elseif _G.FriendMgr:IsInBlackList(RoleID) then
            MsgTipsUtil.ShowTips(LSTR(1490042)) --"对方已加入黑名单，请稍后再试试吧"
            return false
        ---否则通过校验
        else
            return true
        end
    end
end

function MeetTradeMgr:CheckOtherIsTooFarForTrade(RoleID)
    ---目标距离过远
    local MajorActor = MajorUtil.GetMajor()
    local MajorPos = MajorActor:FGetActorLocation()
    local TargetActor = ActorUtil.GetActorByRoleID(RoleID)
    if nil == TargetActor then
        return true
    end
    local TargetActorPos = TargetActor:FGetActorLocation()
    local TargetActorToMajor = ((TargetActorPos.X - MajorPos.X) ^ 2) + ((TargetActorPos.Y - MajorPos.Y) ^ 2) + ((TargetActorPos.Z - MajorPos.Z) ^ 2)
    --- 距离大于交易距离
    if TargetActorToMajor > self.DistanceLimit * 10000 then
        return true
    end
    return false
end
--- 侧边栏接受收到的交易请求按钮的回调函数
--- @param TransData table 透传数据，包含：RoleID, RoleName, TradeID
function MeetTradeMgr:AcceptMeetTradeRequest(TransData)
    ---校验自身状态
    local State = self:CheckSelfIsSuitableForTrade(true)
    ---校验对方状态
    local InviterState = self:CheckOtherIsSuitableForTrade(TransData.InviterID)
    ---校验对方状态
    ---状态校验通过
    if State == MajorState.SuitableForTrade and InviterState == true then
        ---发送接受交易的回复
        self:SendMeetTradeReply(TransData.InviterID, true)
    ---否则校验失败,发送拒绝消息
    else
        self:RejectMeetTradeRequest(TransData)
    end
    ---关闭侧边栏
    SidebarMgr:RemoveSidebarItemByParam(TransData.InviterID, "InviterID")
end

---侧边栏拒绝收到的交易请求按钮的回调函数
---@param TransData table 透传数据，包含：RoleID, RoleName, TradeID
function MeetTradeMgr:RejectMeetTradeRequest(TransData)
    ---发送拒绝回复
    self:SendMeetTradeReply(TransData.InviterID, false)
    ---关闭侧边栏
    SidebarMgr:RemoveSidebarItemByParam(TransData.InviterID, "InviterID")
end

---角色阵亡时触发事件
function MeetTradeMgr:OnGameEventMajorDead()
    if self.TradeID == nil then
        return
    end
    MsgTipsUtil.ShowTips(LSTR(1490041))
    --- 发送交易取消的消息
    self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.IsDead))
end

---角色进入战斗状态时触发事件
function MeetTradeMgr:OnGameEventCombatStateChanged(Params)
    if self.TradeID == nil then
        return
    end
    if MajorUtil.IsMajor(Params.ULongParam1) and Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT then
        MsgTipsUtil.ShowTips(LSTR(1490040))
        --- 发送交易取消的消息
        self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.EnterCombat))
	end
end

---角色状态发生改变触发的事件
function MeetTradeMgr:OnGameEventOnlineStatusMajorChanged(_,NewStatus)
    if self.TradeID == nil then
        return
    end
    --- 发送交易取消的消息
    if OnlineStatusUtil.CheckBit(NewStatus, ProtoRes.OnlineStatus.OnlineStatusLeave) or OnlineStatusUtil.CheckBit(NewStatus, ProtoRes.OnlineStatus.OnlineStatusOffline) then
        self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.OnlineStatus))
    end
end

function MeetTradeMgr:OnEnterLevelConfirmView()
    if self.TradeID == nil then
        return
    end
    MsgTipsUtil.ShowTips(LSTR(1490033))
    --- 发送交易取消的消息
    self:SendMeetTradeCancel(tostring(MeetTradeCancelReason.EnterLevelConfirmView))
end

--- 交易无论是中断还是完成，都有统一的收尾工作需要做
function MeetTradeMgr:MeetTradeEnd(Params)
    self:OnMeetTradeEnd()
    ---交易面板关闭
    if UIViewMgr:IsViewVisible(UIViewID.MeetTradeMainView) then
        UIViewMgr:HideView(UIViewID.MeetTradeMainView, nil, Params)
    end
    ---选择面板关闭
    if UIViewMgr:IsViewVisible(UIViewID.MeetTradeExchangeChoosePanel) then
        UIViewMgr:HideView(UIViewID.MeetTradeExchangeChoosePanel, nil, Params)
    end
    ---确认面板关闭
    if UIViewMgr:IsViewVisible(UIViewID.MeetTradeConfirmationView) then
        UIViewMgr:HideView(UIViewID.MeetTradeConfirmationView, nil, Params)
    end
end

--- 交易无论是中断还是完成，都有统一的收尾工作需要做
function MeetTradeMgr:OnMeetTradeEnd()
    ---清空选择列表
    _G.MeetTradeBagMainVM:ClearSelectedItemList()
    ---Mgr状态重置
    self:ReSet()
    self:UnRegisterTimer(self.TimerID)
end

function MeetTradeMgr:GetOtherIsReadyForTrade()
    return self.OtherIsReadyForTrade
end

function MeetTradeMgr:GetMajorIsReadyForTrade()
    return self.MajorIsReadyForTrade
end

function MeetTradeMgr:GetOtherIsSureForTrade()
    return self.OtherIsSureForTrade
end

function MeetTradeMgr:GetMajorIsSureForTrade()
    return self.MajorIsSureForTrade
end

function MeetTradeMgr:GetGoldNumForTrade()
    return self.GoldForTrade
end
--- 打开收到交易请求的左侧边栏
function MeetTradeMgr:OpenMeetTradeRequestSidebar(StartTime, CountDown, TransData, Type)
    -- local Info = self:GetNewMeetTradeFirstRequest()
    -- if nil == Info then
    --     return
    -- end
    local AcceptCallBack = function(_, Params)
		self:AcceptMeetTradeRequest(Params)
    end

    local RefuseCallBack = function(_, Params)
        self:RejectMeetTradeRequest(Params)
    end

    local Params = {
        Title       = LSTR(1490038), --"交易申请"
        Desc1       = string.format('<span color="#8FBDD5FF">%s</>', TransData.InviterName), --"玩家"
        Desc2       = LSTR(1490039), --"向你发起交易"
        StartTime   = StartTime,
        CountDown   = CountDown,
        CBFuncLeft  = RefuseCallBack,
        CBFuncRight = AcceptCallBack,
        Type        = Type, 

        --透传数据
        TransData = TransData,
    }

    _G.UIViewMgr:ShowView(_G.UIViewID.SidebarCommon, Params)
end

function MeetTradeMgr:OnMeetTradeSidebarItemTimeOut(Type, TransData)
    if Type == SidebarType.MeetTradeRequest then
        self:RejectMeetTradeRequest(TransData)
    end
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---打开面对面交易面板
---@param RoleID number @对方角色ID 
function MeetTradeMgr:OpenMeetTradeMainView(RoleID) 
    ---TODO 修改ViewID
    if nil == RoleID or UIViewMgr:IsViewVisible(UIViewID.MeetTradeMainView) then
        return
    end

    ---初始化主角的RoleID、RoleVM
    local MajorVM = MajorUtil.GetMajorRoleVM()
    MeetTradeVM:UpdateMajorInfo(MajorVM)
    ---初始化对方角色信息
    MeetTradeVM:SetRoleID(RoleID)
    ---请求对方角色信息
	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        MeetTradeVM:UpdateRoleInfo(RoleVM)
        UIViewMgr:ShowView(UIViewID.MeetTradeMainView)
    end, nil, false)
end

return MeetTradeMgr
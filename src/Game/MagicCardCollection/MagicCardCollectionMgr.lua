--
-- Author: Carl
-- Date: 2023-09-08 16:57:14
-- Description:幻卡图鉴Mgr

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local BoardType = require("Define/BoardType")
local ProtoCS = require("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local FantasyCardCfg = require("TableCfg/FantasyCardCfg")
local CollectionAwardUtil = require("Game/Guide/CollectionAwardUtil")
local MagicCardCollectionVM = require("Game/MagicCardCollection/VM/MagicCardCollectionVM")
local MagicCardCollectionAwardVM = require("Game/MagicCardCollection/VM/MagicCardCollectionAwardVM")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local CS_CMD = ProtoCS.CS_CMD
local FANTASY_CARD_OP = ProtoCS.FANTASY_CARD_OP
local MagicCardCollectionMgr = LuaClass(MgrBase)

function MagicCardCollectionMgr:OnInit()
    self:ResetData()

    self.CollectionAwardVM = MagicCardCollectionAwardVM.New()
end

function MagicCardCollectionMgr:OnEnd()
    self:ResetData()
end

function MagicCardCollectionMgr:OnBegin()
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD, self.CheckMagicCardUnlock)
end

function MagicCardCollectionMgr:OnShutdown()
    self:ResetData()
end

function MagicCardCollectionMgr:ResetData()
    self.IsUpdateAllUnlockCard = false
    self.NewGetMagicCardList = {}
    self.SelectCardID = 0
    self.UnLockCardList = {}
end

function MagicCardCollectionMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION, self.OnNetMsgMagicCardList)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_ROLE_COUNT, self.OnNetMsgMagicCardCollectionCount)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_AWARD_RECORD, self.OnNetMsgMagicCardCollectionAwardRecord)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FANTASYCARD, FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_PROGRESS_AWARD, self.OnNetMsgMagicCardCollectionAward)
end

function MagicCardCollectionMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBag)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function MagicCardCollectionMgr:OnGameEventLoginRes()
    -- 登录时拉取幻卡解锁数据，用于是否弹窗快捷使用方式的判断依据
	self:SendNetMsgMagicCardList()
end

function MagicCardCollectionMgr:OnUpdateBag(UpdateItem)
    if UpdateItem == nil or next(UpdateItem) == nil then
        return
    end

    for _, v in ipairs(UpdateItem) do
        if v.Type == ProtoCS.ITEM_UPDATE_TYPE.ITEM_UPDATE_TYPE_ADD then
            local NewResID = v.PstItem.ResID
            local Cfg = ItemCfg:FindCfgByKey(NewResID)
            if Cfg and Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_TRIPLETRIADCARD then
                self:AddNewGetCard(NewResID)
            end
        end 
    end
end

function MagicCardCollectionMgr:AddNewGetCard(NewResID)
    if self.NewGetMagicCardList == nil then
        self.NewGetMagicCardList = {}
    end

    if not table.contain(self.NewGetMagicCardList, NewResID) then
        self.NewGetMagicCardList[NewResID] = NewResID
    end
end

function MagicCardCollectionMgr:RemoveAllNewGetCard()
    self.NewGetMagicCardList = nil
end

function MagicCardCollectionMgr:RemoveNewGetCard(CardID)
    self.NewGetMagicCardList[CardID] = nil
end

function MagicCardCollectionMgr:GetNewGetCardList()
    return self.NewGetMagicCardList
end

function MagicCardCollectionMgr:IsCardNewGet(CardID)
    return self.NewGetMagicCardList[CardID] ~= nil
end

function MagicCardCollectionMgr.CheckMagicCardUnlock(CardResID)
    return MagicCardCollectionVM:IsCardUnLock(CardResID)
end

function MagicCardCollectionMgr:ShowMagicCardCollectionMainPanel(InSelectCardID)
    -- 从图鉴界面跳转到商店界面，购买后使用并通过幻卡快捷方式跳转回来，需要隐藏商店界面
    if UIViewMgr:IsViewVisible(UIViewID.MagicCardCollectionMainPanel) then
        if UIViewMgr:IsViewVisible(UIViewID.ShopMainPanelView) then
            UIViewMgr:HideView(UIViewID.ShopMainPanelView)
        end
    end

    self:SendNetMsgMagicCardList()
    self:SendNetMsgMagicCardCollectionAwardRecord()
    UIViewMgr:ShowView(UIViewID.MagicCardCollectionMainPanel)
    self.SelectCardID = InSelectCardID
end

function MagicCardCollectionMgr:OnCollectionAwardClicked()
    local Params = MagicCardCollectionVM:GetCollectProgressInfo()
    if Params == nil or Params.AwardList == nil then
        return
    end
    
    local function OnGetAwardClicked(Index, ItemData, ItemView)
        if ItemData then
            local IsGetProgress = ItemData.IsGetProgress
            local IsCollectedAward = ItemData.IsCollectedAward
            local AwardID = ItemData.CollectTargetNum
            if IsGetProgress and not IsCollectedAward then
                self:SendNetMsgMagicCardCollectionAward(AwardID)
            end
        end
    end

    CollectionAwardUtil.ShowCollectionAwardView(UIViewID.MagicCardCollectionMainPanel, Params.CollectedNum, Params.MaxCollectNum, 
                                                Params.AwardList,  OnGetAwardClicked)
end

---@type 幻卡排序 ID升序
function MagicCardCollectionMgr.CardSortFunc(CardID1, CardID2)
    if CardID1 == CardID2 then
        return false
    end
    return CardID1 < CardID2
end

---@type 显示留言区
function MagicCardCollectionMgr:ShowMessageBoard()
    local Params = {
		BoardTypeID = BoardType.FishNote, -- 留言板类型ID
		SelectObjectID = self.SelectCardItemID -- 图鉴中的物品ID
	}
    _G.UIViewMgr:ShowView(_G.UIViewID.MessageBoardPanel, Params)
end

---@type 获取解锁幻卡数量
function MagicCardCollectionMgr:GetUnlockCardNum()
    if (self.MagicCardList == nil) then
        return 0
    end

    if (type(self.MagicCardList) ~= "table") then
        return 0
    end

    local MagicCardUnlockNum = #self.MagicCardList

    return MagicCardUnlockNum
end

function MagicCardCollectionMgr:IsCardUnlock(InCardID)
    if (self.UnLockCardList == nil) then
        return false
    end

    local Result = self.UnLockCardList[InCardID] ~= nil
    return Result
end

function MagicCardCollectionMgr:UpdateUnLockCardList(UnLockList)
    if UnLockList == nil then
        return
    end

    for _, CardID in ipairs(UnLockList) do
        self.UnLockCardList[CardID] = CardID
    end
end

--region NetMsg


---@type 请求幻卡收藏数据
function MagicCardCollectionMgr:SendNetMsgMagicCardList()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION
    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_UPDATE_COLLECTION
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 返回的幻卡收藏数据
function MagicCardCollectionMgr:OnNetMsgMagicCardList(MsgBody)
    if MsgBody == nil or MsgBody.CollectionUpdateRsp == nil then
        return
    end
    local CollectionUpdateRsp = MsgBody.CollectionUpdateRsp
    self.MagicCardList = CollectionUpdateRsp.Cards
    self:UpdateUnLockCardList(self.MagicCardList)
    MagicCardCollectionVM:UpdateUnLockMagicCardList(self.MagicCardList, self.IsUpdateAllUnlockCard)
    self.IsUpdateAllUnlockCard = true

    if (self.SelectCardID ~= nil and self.SelectCardID > 0) then
        MagicCardCollectionVM:TrySelectTargetCard(self.SelectCardID)
        self.SelectCardID = 0
    end

    _G.EventMgr:SendEvent(EventID.MagicCardCollectionUpdate)
end

---@type 幻卡收藏玩家数统计请求
function MagicCardCollectionMgr:SendNetMsgMagicCardCollectionCount(CardID)
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_ROLE_COUNT

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_ROLE_COUNT
    MsgBody.CollectionRoleCountReq = {
        CardID = CardID
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 幻卡收藏玩家统计回调
function MagicCardCollectionMgr:OnNetMsgMagicCardCollectionCount(MsgBody)
    if MsgBody == nil then
        return
    end

    local CollectionRoleCountRsp = MsgBody.CollectionRoleCountRsp
    if CollectionRoleCountRsp == nil then
        return
    end
        -- int32 CardID = 1;               //幻卡id
    -- int32 ActiveRoleCount = 2;      //开启图鉴玩家数
    -- int32 CollectionRoleCount = 3;  //收藏该幻卡的玩家数
    local CurSelectCardCollectInfo = {
        CardID = CollectionRoleCountRsp.CardID,
        ActiveRoleCount = CollectionRoleCountRsp.ActiveRoleCount,
        CollectionRoleCount = CollectionRoleCountRsp.CollectionRoleCount,
        CollectionTimes = CollectionRoleCountRsp.CollectionTimes,
    }
    MagicCardCollectionVM:UpdateCurSelectCardCollection(CurSelectCardCollectInfo)
end

---@type 玩家收藏奖励领取
function MagicCardCollectionMgr:SendNetMsgMagicCardCollectionAward(CollectProgress)
    if CollectProgress == nil or CollectProgress <= 0 then
        return
    end
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_PROGRESS_AWARD

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_PROGRESS_AWARD
    MsgBody.CollectionProgressAwardReq = {
        ResID = CollectProgress
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 玩家收藏奖励回包
function MagicCardCollectionMgr:OnNetMsgMagicCardCollectionAward(MsgBody)
    if MsgBody == nil then
        return
    end
    local CollectionProgressAwardRsp = MsgBody.CollectionProgressAwardRsp
    if CollectionProgressAwardRsp == nil then
        return
    end
    local Rewards = CollectionProgressAwardRsp.Rewards
    if Rewards == nil or #Rewards <= 0 then
        return
    end
    self:SendNetMsgMagicCardCollectionAwardRecord()
end

---@type 玩家收藏奖励记录请求
function MagicCardCollectionMgr:SendNetMsgMagicCardCollectionAwardRecord()
    local MsgID = CS_CMD.CS_CMD_FANTASYCARD
    local SubMsgID = FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_AWARD_RECORD

    local MsgBody = {}
    MsgBody.Operation = FANTASY_CARD_OP.FANTASY_CARD_OP_COLLECTION_AWARD_RECORD
    MsgBody.CollectionAwardRecordReq = {}
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---@type 玩家收藏奖励记录回包
function MagicCardCollectionMgr:OnNetMsgMagicCardCollectionAwardRecord(MsgBody)
    if MsgBody == nil then
        return
    end
    local CollectionAwardRecordRsp = MsgBody.CollectionAwardRecordRsp
    if CollectionAwardRecordRsp == nil then
        return
    end
    self.CollectionAwardRecordList = CollectionAwardRecordRsp.ResIDs
    MagicCardCollectionVM:UpdateCollectProgressList(self.CollectionAwardRecordList)
end

--endregion
return MagicCardCollectionMgr
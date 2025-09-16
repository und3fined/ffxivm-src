---
--- Created by Easy
--- DateTime: 2024/11/13 11:07
----
---
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemCfg = require("TableCfg/ItemCfg")
local BuddyEquipCfg = require("TableCfg/BuddyEquipCfg")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")

local GameNetworkMgr = nil
local MsgTipsUtil = nil
local LSTR = nil

local SUB_MSG_ID = ProtoCS.ChocoboCmd
local CS_CMD_CHOCOBO = ProtoCS.CS_CMD.CS_CMD_CHOCOBO
local ChocoboArmorPos = ProtoCS.ChocoboArmorPos

---@class ChocoboCodexArmorMgr : MgrBase
local ChocoboCodexArmorMgr = LuaClass(MgrBase)

function ChocoboCodexArmorMgr:OnInit()
end

function ChocoboCodexArmorMgr:OnBegin()
    GameNetworkMgr = _G.GameNetworkMgr
    MsgTipsUtil = _G.MsgTipsUtil
    LSTR = _G.LSTR
   
    _G.BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT, self.CheckArmorItemUsed)
end

function ChocoboCodexArmorMgr:OnEnd()
end

function ChocoboCodexArmorMgr:OnShutdown()
end

function ChocoboCodexArmorMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.BagUseItemSucc, self.OnEventUseItemSucc)
end

function ChocoboCodexArmorMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, SUB_MSG_ID.ChocoboCmdGetSuitProcessAward, self.OnNetMsgSuitProcessAward)   --套装进度奖励
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, SUB_MSG_ID.ChocoboCmdGetPartProcessAward, self.OnNetMsgPartProcessAward)   --套装部件进度奖励
    self:RegisterGameNetMsg(CS_CMD_CHOCOBO, SUB_MSG_ID.ChocoboCmdGetSuitCollected, self.OnNetMsgGetSuitCollected)   --获取解锁套装
end

function ChocoboCodexArmorMgr:OpenChocoboCodexArmorPanel()
    if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocoboArmorCollect) then
        return
    end
    
    UIViewMgr:ShowView(UIViewID.ChocoboCodexArmorPanelView)
end

-- 网络通讯请求代码
function ChocoboCodexArmorMgr:ChocoboArmorReq(Params)
    local SubMsgID = SUB_MSG_ID.ChocoboCmdArmor

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Armor = {}
    MsgBody.Armor.ID = Params.ID 
    MsgBody.Armor.Armor = Params.Armor
    MsgBody.Armor.Pos = Params.Pos --ChocoboArmorPos.PosHead

    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO, SubMsgID, MsgBody)
end

--// 请求套装进度领取奖励
function ChocoboCodexArmorMgr:ChocoboGetSuitProscessAwardReq(Process)
    local SubMsgID = SUB_MSG_ID.ChocoboCmdGetSuitProcessAward

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.SuitProcessAward = {}
    MsgBody.SuitProcessAward.Process = Process

    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO, SubMsgID, MsgBody)
end

--请求套装部件进度领取奖励
function ChocoboCodexArmorMgr:ChocoboGetPartProscessAwardReq(Process)
    local SubMsgID = SUB_MSG_ID.ChocoboCmdGetPartProcessAward

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.PartProcessAward = {}
    MsgBody.PartProcessAward.Process = Process

    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO, SubMsgID, MsgBody)
end

--请求获取已解锁部件的陆行鸟套装信息
function ChocoboCodexArmorMgr:ChocoboGetSuitCollectedReq()
    local SubMsgID = SUB_MSG_ID.ChocoboCmdGetSuitCollected

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.SuitCollected = {}

    GameNetworkMgr:SendMsg(CS_CMD_CHOCOBO, SubMsgID, MsgBody)
end

function ChocoboCodexArmorMgr:OnNetMsgSuitProcessAward(MsgBody)
    if MsgBody == nil then 
        _G.FLOG_ERROR("ChocoboCodexArmorMgr:OnNetMsgSuitProcessAward: MsgBody is nil")
        return 
    end

    local SuitProcessAward  = MsgBody.SuitProcessAward    
    if SuitProcessAward  == nil then return end

    _G.ChocoboCodexArmorPanelVM:UpdateSuitProcessAward(SuitProcessAward)
end

function ChocoboCodexArmorMgr:OnNetMsgPartProcessAward(MsgBody)
    if MsgBody == nil then 
        _G.FLOG_ERROR("ChocoboCodexArmorMgr:OnNetMsgPartProcessAward: MsgBody is nil")
        return 
    end

    local PartProcessAward  = MsgBody.PartProcessAward    
    if PartProcessAward  == nil then return end

    _G.ChocoboCodexArmorPanelVM:UpdatePartProcessAward(PartProcessAward)
end

function ChocoboCodexArmorMgr:OnNetMsgGetSuitCollected(MsgBody)
    if MsgBody == nil then 
        _G.FLOG_ERROR("ChocoboCodexArmorMgr:OnNetMsgGetSuitCollected: MsgBody is nil")
        return 
    end

    local SuitCollected  = MsgBody.SuitCollected    
    if SuitCollected  == nil then return end

    _G.ChocoboCodexArmorPanelVM:UpdateAllSuit(SuitCollected.SuitList)
    _G.ChocoboCodexArmorPanelVM:UpdateSuitAward(SuitCollected.SuitAwardCollected)
    _G.ChocoboCodexArmorPanelVM:UpdatePartAward(SuitCollected.PartAwardCollected)
end

function ChocoboCodexArmorMgr:OnEventUseItemSucc(Params)
    if nil == Params then return end

    --重新请求数据
    self:ChocoboGetSuitCollectedReq()

    --判断道具是不是装甲图鉴道具
    local ItemID = Params.ResID
    local Cfg = ItemCfg:FindCfgByKey(ItemID)
    if Cfg == nil then return end

    if (Cfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT) then
        _G.ChocoboCodexArmorPanelVM:AddReddot(ItemID)
    end

    local BuddyEquip = BuddyEquipCfg:FindCfgByKey(ItemID)
    if BuddyEquip ~= nil then 
        local Content =  string.format(LSTR(670018), BuddyEquip.Name)
        _G.ChatMgr:AddSysChatMsg(Content) 
    end
end

---@type 检查陆行鸟装甲图鉴模块是否解锁
function ChocoboCodexArmorMgr.CheckArmorOpenState(ResID)
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if Cfg == nil then
        return false
    end

    if (Cfg.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT) then
        return false
    end

    local _isModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocoboArmorCollect)
    return _isModuelOpen
end

---@type 检查陆行鸟装甲是否解锁
function ChocoboCodexArmorMgr.CheckArmorItemUsed(ResID)
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if Cfg == nil then
        return false
    end

    if (Cfg.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_BUDDYEQUIT) then
        return false
    end

    --local isModuelOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChocoboArmorCollect)
    return _G.ChocoboCodexArmorPanelVM:CheckItemUsed(ResID)
end

return ChocoboCodexArmorMgr
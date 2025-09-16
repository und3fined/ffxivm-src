local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewMgr = require("UI/UIViewMgr")
local DirectUpgradeCfg = require("TableCfg/DirectUpgradeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local FuncCfg = require("TableCfg/FuncCfg")
local FuncType = ProtoRes.FuncType
local LSTR
local GameNetworkMgr

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Role.DirectUpgrade.Cmd
---@class UpgradeMgr : MgrBase
local UpgradeMgr = LuaClass(MgrBase)

---OnInit
function UpgradeMgr:OnInit()
    self.IsOnDirectUpState = false
    self.IsProfActivate = false
    self.IsLevelUpgrade = false
    self.UpgradeRewards = {}
end

---OnBegin
function UpgradeMgr:OnBegin()
    LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
end

function UpgradeMgr:OnEnd()
end

function UpgradeMgr:OnShutdown()
end

function UpgradeMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DIRECT_UPGRADE, SUB_MSG_ID.Upgrade, self.OnDirectUpgrade) -- 直升
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DIRECT_UPGRADE, SUB_MSG_ID.ReadyUpgrade, self.OnReadyUpgrade) -- 准备直升
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DIRECT_UPGRADE, SUB_MSG_ID.Update, self.OnUpgradeInfo)   -- 查询直升使用的职业
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_DIRECT_UPGRADE, SUB_MSG_ID.AdventureReward, self.OnAdventureReward) -- 冒险录
end

function UpgradeMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.MajorProfActivate, self.MajorProfActivate) --激活
    self:RegisterGameEvent(_G.EventID.BagUseItemSucc, self.OnBagUseItemSucc)
end

function UpgradeMgr:SendUpgrade(Prof)
	local MsgID = CS_CMD.CS_CMD_DIRECT_UPGRADE
	local SubMsgID = SUB_MSG_ID.Upgrade

	local MsgBody = {
        Cmd = SubMsgID,
        UpgradeReq = { Prof = Prof}
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function UpgradeMgr:SendUpdate()
    local MsgID = CS_CMD.CS_CMD_DIRECT_UPGRADE
	local SubMsgID = SUB_MSG_ID.Update

	local MsgBody = {
        Cmd = SubMsgID,
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

function UpgradeMgr:OnDirectUpgrade(MsgBody)
    _G.ModuleOpenMgr:SetIsOnDirectUpState(false)
    self.IsOnDirectUpState = false
    if self.IsProfActivate then
        self.IsProfActivate = false
    else
        self:ShowReward()
    end
end

function UpgradeMgr:OnReadyUpgrade(MsgBody)
    if nil == MsgBody or MsgBody.ErrCode then
        return
    end
    _G.ModuleOpenMgr:SetIsOnDirectUpState(true)
    self.IsOnDirectUpState = true
end

function UpgradeMgr:OnUpgradeInfo(MsgBody)
    if nil == MsgBody or nil ==  MsgBody.UpdateRsp then
		return
	end
	local UpdateRsp = MsgBody.UpdateRsp
    local Prof = UpdateRsp.Prof
    local Exp = UpdateRsp.Exp
    local QuestID2Finish = UpdateRsp.QuestID2Finish
    if UIViewMgr:IsViewVisible(_G.UIViewID.BagMain) then
        UIViewMgr:HideView(_G.UIViewID.BagMain)
    end
    UIViewMgr:ShowView(_G.UIViewID.UpgradeMainPanelView, {Prof = Prof, Exp = Exp, QuestID2Finish = QuestID2Finish})
end

function UpgradeMgr:OnAdventureReward(MsgBody)
    _G.NewTutorialMgr:OnDirectUpgrade()
    _G.ModuleOpenMgr:SetIsOnDirectUpState(false)
    self.IsOnDirectUpState = false
    if self.IsProfActivate then
        self.IsProfActivate = false
    else
        self:ShowReward()
    end
end

function UpgradeMgr:GetDirectUpgradeLoot(LootList)
    self.UpgradeRewards = {}
    if not LootList or not next(LootList) then return end
    local LOOT_TYPE = ProtoCS.LOOT_TYPE
    for _, loot in ipairs(LootList) do
        if loot.Type == LOOT_TYPE.LOOT_TYPE_ITEM then
            table.insert(self.UpgradeRewards, {ResID = loot.Item.ResID, Num = loot.Item.Value})
        end
    end
end

function UpgradeMgr:ShowReward()
    if not self.UpgradeRewards or not next(self.UpgradeRewards) then return end
    local Params = {}
    if next(self.UpgradeRewards) ~= nil then
        Params.ShowBtn = false
	    Params.ItemList = self.UpgradeRewards
        Params.IsOnDirectUpState = true
        UIViewMgr:ShowView(_G.UIViewID.CommonRewardPanel, Params)
        self.UpgradeRewards = {}
    end
end

function UpgradeMgr:MajorProfActivate(Params)
    if self.IsOnDirectUpState then
        self.IsProfActivate = true
    end
end

function UpgradeMgr:GetLevelUpdateInfo(ProfID, OldLevel, NewLevel)
    self.ProfID = ProfID
    self.OldLevel = OldLevel
    self.NewLevel = NewLevel
    self.IsLevelUpgrade = true
end

-- 使用光之直升升级的升级提示与特效
function UpgradeMgr:PlayLevelUpdateEffect()
    if not self.IsLevelUpgrade then
       return
    end
    local ProfID = self.ProfID
    local OldLevel = self.OldLevel
    local NewLevel = self.NewLevel
    local NewProfID = nil == ProfID and MajorUtil.GetMajorProfID() or ProfID
    _G.ProfMgr:AddLevelUpSysChatMsg(MajorUtil.GetMajorEntityID(), OldLevel, NewLevel, NewProfID)
    local Major = MajorUtil.GetMajor()
    _G.ProfMgr:PlayLevelUpEffects(Major)
    -- 播放屏幕特效与升级tips
    self.StartTime = _G.TimeUtil:GetLocalTimeMS()

    -- 播放升级特效的时候中断
    self.Blur = true
    self.NewProf = ProfID
    self.NewLevel = NewLevel

    _G.MsgTipsUtil.ShowLevelUpTips(self.NewProf, self.NewLevel)

    -- 音效
    _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, 0)
    local CallBack = function()
        _G.UE.UAudioMgr.Get():SetAudioVolumeScale(_G.UE.EWWiseAudioType.Music, 1)
    end
    local LevelUpAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_LvUP_CountStop/Play_Zingle_LvUP_CountStop.Play_Zingle_LvUP_CountStop'"
    AudioUtil.LoadAndPlayUISound(LevelUpAudioPath, CallBack)
end

function UpgradeMgr:GetUpgradeTimeStamp()
    local StartTimeCfg = DirectUpgradeCfg:FindCfgByKey(ProtoRes.DirectUpgradeCfgID.DirectUpgradeCfgIDOpenServerTime)
    local DurationDaysCfg = DirectUpgradeCfg:FindCfgByKey(ProtoRes.DirectUpgradeCfgID.DirectUpgradeCfgIDLastDays)

    local StartTimeTable = self:ParseTimeString(StartTimeCfg.SValue)
    local StartTimeStamp = os.time(StartTimeTable)

    local DurationSeconds = (DurationDaysCfg.Value) * 24 * 3600

    local EndTimeStamp = StartTimeStamp + DurationSeconds

    return StartTimeStamp, EndTimeStamp
end

function UpgradeMgr:IsUpgradeCanUse()
    local StartTimeStamp, EndTimeStamp = self:GetUpgradeTimeStamp()
    local ServerTimeStamp = TimeUtil.GetServerLogicTime()
    local IsUpgradeStart = StartTimeStamp <= ServerTimeStamp
    local IsUpgradeEnd = ServerTimeStamp > EndTimeStamp
    return IsUpgradeStart, IsUpgradeEnd
end

function UpgradeMgr:ParseTimeString(TimeStr)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = TimeStr:match(pattern)
    return {
        year = tonumber(year),
        month = tonumber(month),
        day = tonumber(day),
        hour = tonumber(hour),
        min = tonumber(min),
        sec = tonumber(sec)
    }
end

function UpgradeMgr:GetUpgradeItemID()
    local Cfg = DirectUpgradeCfg:FindCfgByKey(ProtoRes.DirectUpgradeCfgID.DirectUpgradeCfgIDCostItemID)
    if Cfg ~= nil then
        return Cfg.Value
    end
end

function UpgradeMgr:OnBagUseItemSucc(Params)
    if nil == Params or nil == Params.ResID then
        return
    end
    local ResID = Params.ResID
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if Cfg == nil then
        return
    end

    if ResID == self:GetUpgradeItemID() then
        MsgTipsUtil.ShowTips(string.format(LSTR(990107), Cfg.ItemName))
        return
    end

    local Func = FuncCfg:FindCfgByKey(Cfg.UseFunc)
    if Func ~= nil then
        local isAdventureRecord = (Func.Func[1].Type == FuncType.UseAdventureRocord) or 
                                (Func.Func[2].Type == FuncType.UseAdventureRocord)
        if isAdventureRecord then
            MsgTipsUtil.ShowTips(string.format(LSTR(990107), Cfg.ItemName))
        end
    end
end

--要返回当前类
return UpgradeMgr

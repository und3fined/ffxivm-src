--[[
Author: lightpaw_Leo
Date: 2023-10-12 14:35:12
Description: 空军小游戏通用部分
--]]

local LuaClass = require("Core/LuaClass")
local GoldGameNewBase = require("Game/Gate/GoldGame/GoldGameNewBase")
local GateMainVM = require("Game/Gate/View/VM/GateMainVM")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")

local GoldSauserMgr

---@class GoldAirForce
local GoldAirForce = LuaClass(GoldGameNewBase)

-- --Ctor
function GoldAirForce:Ctor()
    GoldSauserMgr = _G.GoldSauserMgr

    self.SgInstanceID = 7808374
    self.BGMID = 0 -- 自己有场景特有BGM不用上层播放
end

--- @type 当游戏结束时
function GoldAirForce:OnPlayerGameEnd(InGameMgr, InGameVM, InMsgData)
    local End = InMsgData.End
    local bSuccess = End.Success

    if bSuccess then
        _G.RideShootingMgr:PlayEndingAnimation()
    end

    self:PlaySound(bSuccess)

    _G.UIViewMgr:HideView(UIViewID.CommonMsgBox)

    _G.EventMgr:SendEvent(EventID.GoldSauserAirForceGameOver)
end

function GoldAirForce:OnNeedCheckNotInTeam()
    return true
end

-- 玩家自己的游戏状态已经完成后，和NPC对话的ID，子类子类覆写
function GoldAirForce:OnGetFinishDialogID(InTableData)
    return InTableData.FinishLibID
end

--- @type 主动结束游戏
function GoldAirForce:EndGame(isSuccess)
    GateMainVM:SetGameRunning(false)
    GoldSauserMgr:SendEndGameReq(GateMainVM:GetScore(), isSuccess)
end

-- 子类用，判断是否能注册报名倒计时，默认是可以注册的
function GoldAirForce:OnCanRegisterSignUpTimeCountDown()
    return false
end

function GoldAirForce:PlaySound(bSuccess)
    local UAudioMgr = _G.UE.UAudioMgr.Get()
    if bSuccess then
        if GateMainVM:GetScore() >= 5000 then
            UAudioMgr:PlayBGM(258, _G.UE.EBGMChannel.BaseZone)
        else
            UAudioMgr:PlayBGM(642, _G.UE.EBGMChannel.BaseZone)
        end
    else
        UAudioMgr:PlayBGM(643, _G.UE.EBGMChannel.BaseZone)
    end
end

-- 机遇临门奖励动画播放完成后
function GoldAirForce:AfterGateOpportunityRewardAnimEnd(Params)
    _G.UIViewMgr:ShowView(UIViewID.GoldSauserResultPanel, Params)
    _G.LootMgr:SetDealyState(false)
end

return GoldAirForce
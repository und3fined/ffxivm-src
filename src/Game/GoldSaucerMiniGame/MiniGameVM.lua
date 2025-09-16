--
-- Author: Alex
-- Date: 2023-10-12 19:36
-- Description:金蝶小游戏
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local MiniGameOutOnALimbVM = require("Game/GoldSaucerMiniGame/OutOnALimb/MiniGameOutOnALimbVM")
local MiniGameTheFinerMinerVM = require("Game/GoldSaucerMiniGame/TheFinerMiner/MiniGameTheFinerMinerVM")
local MiniGameMooglesPawVM = require("Game/GoldSaucerMiniGame/MooglesPaw/MiniGameMooglesPawVM")
local MiniGameMonsterTossVM = require("Game/GoldSaucerMiniGame/MonsterToss/MiniGameMonsterTossVM")
local MiniGameCuffVM = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuffVM")
local MiniGameCrystalTowerVM = require("Game/GoldSaucerMiniGame/CrystalTower/MiniGameCrystalTowerVM")

local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType
local MiniGameClientConfig = GoldSaucerMiniGameDefine.MiniGameClientConfig
local ScoreMgr = _G.ScoreMgr
local FLOG_ERROR = _G.FLOG_ERROR

---@class MiniGameVM
local MiniGameVM = LuaClass(UIViewModel)

---Ctor
function MiniGameVM:Ctor()
end

function MiniGameVM:OnInit()
    -- Main Part
    self.MiniGameVMMap = {}
end

function MiniGameVM:OnShutdown()
    self.MiniGameVMMap = nil
end

--- 创建小游戏VM
function MiniGameVM:CreateDetailMiniGameVM(Type, MiniGameInst)
    local ViewModel = self.CreateMiniGameVM(Type)
    if ViewModel then
        ViewModel:CreateVM(MiniGameInst)
    end
    local MiniGameVMMap = self.MiniGameVMMap or {}
    MiniGameVMMap[Type] = ViewModel
    self.MiniGameVMMap = MiniGameVMMap
    return ViewModel
end

--- 移除小游戏VM
function MiniGameVM:RemoveDetailMiniGameVM(Type)
    self.MiniGameVMMap[Type] = nil
end

--- 更新小游戏VM
function MiniGameVM:UpdateDetailMiniGameVM(Type)
    local VMMap = self.MiniGameVMMap
    if VMMap == nil then
        return
    end
    local ViewModel = VMMap[Type]
    if ViewModel then
        ViewModel:UpdateVM()
    end
end

--- 更新小游戏时间（频率较快，故不与其他逻辑一同更新）
function MiniGameVM:UpdateDetailMiniGameTime(Type)
    if Type == nil then
        FLOG_ERROR("MiniGameVM:UpdateDetailMiniGameTime the GameType is nil")
        return
    end

    local VMMap = self.MiniGameVMMap
    if VMMap == nil then
        return
    end

    local ViewModel = VMMap[Type]
    if ViewModel then
        ViewModel:UpdateTimeShow()
    end
end

---MiniGameVM
---@param GameType MiniGameType
---@return MiniGameVMMap@Value
function MiniGameVM.CreateMiniGameVM(GameType)
	if MiniGameType.OutOnALimb == GameType then
		return MiniGameOutOnALimbVM.New()
    elseif MiniGameType.TheFinerMiner == GameType then
        return MiniGameTheFinerMinerVM.New()
    elseif MiniGameType.MooglesPaw == GameType then
        return MiniGameMooglesPawVM.New()
    elseif MiniGameType.MonsterToss == GameType then
        return MiniGameMonsterTossVM.New()
    elseif MiniGameType.Cuff == GameType then
        return MiniGameCuffVM.New()
    elseif MiniGameType.CrystalTower == GameType then
        return MiniGameCrystalTowerVM.New()
    end
end

--- 获取小游戏VM
function MiniGameVM:GetDetailMiniGameVM(Type)
    local MiniGameVMMap = self.MiniGameVMMap
    if MiniGameVMMap == nil then
        return
    end
    local ViewModel = MiniGameVMMap[Type]
    return ViewModel
end

return MiniGameVM
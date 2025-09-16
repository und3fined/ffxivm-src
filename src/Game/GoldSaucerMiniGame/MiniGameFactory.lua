--
-- Author: alexchen
-- Date: 2023-10-10 14:34
-- Description:
--

--local LuaClass = require("Core/LuaClass")
local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local MiniGameBase = require("Game/GoldSaucerMiniGame/MiniGameBase")
local MiniGameOutOnALimb = require("Game/GoldSaucerMiniGame/OutOnALimb/MiniGameOutOnALimb")
local MiniGameTheFinerMiner = require("Game/GoldSaucerMiniGame/TheFinerMiner/MiniGameTheFinerMiner")
local MiniGameMooglesPaw = require("Game/GoldSaucerMiniGame/MooglesPaw/MiniGameMooglesPaw")
local MiniGameMonsterToss = require("Game/GoldSaucerMiniGame/MonsterToss/MiniGameMonsterToss")
local MiniGameCuff = require("Game/GoldSaucerMiniGame/Cuff/MiniGameCuff")
local MiniGameCrystalTower = require("Game/GoldSaucerMiniGame/CrystalTower/MiniGameCrystalTower")

local MiniGameType = GoldSaucerMiniGameDefine.MiniGameType

local MiniGameFactory = {}

---MiniGameInstance
---@param GameType MiniGameType
---@return MiniGameBase
function MiniGameFactory.CreateMiniGameInstance(GameType)
	if MiniGameType.OutOnALimb == GameType then
		return MiniGameOutOnALimb.New()
	elseif MiniGameType.TheFinerMiner == GameType then
		return MiniGameTheFinerMiner.New()
	elseif MiniGameType.MooglesPaw == GameType then
		return MiniGameMooglesPaw.New()
	elseif MiniGameType.MonsterToss == GameType then
		return MiniGameMonsterToss.New()
	elseif MiniGameType.Cuff == GameType then
		return MiniGameCuff.New()
	elseif MiniGameType.CrystalTower == GameType then
		return MiniGameCrystalTower.New()
	else
		return MiniGameBase.New()
	end
end

return MiniGameFactory
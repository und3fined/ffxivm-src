--
-- Author: alexchen
-- Date: 2025-02-20 11:29
-- Description:范围检查工厂 
--

local RangeCheckTriggerDefine = require("Game/RangeCheckTrigger/RangeCheckTriggerDefine")
local RangeDataBase = require("Game/RangeCheckTrigger/RangeData/RangeDataBase")
local RangeDataDiscoverNoteEffect = require("Game/RangeCheckTrigger/RangeData/RangeDataDiscoverNoteEffect")
local RangeDataWildBox = require("Game/RangeCheckTrigger/RangeData/RangeDataWildBox")
local RangeDataBand = require("Game/RangeCheckTrigger/RangeData/RangeDataBand")
local RangeDataMysterMerchant = require("Game/RangeCheckTrigger/RangeData/RangeDataMysterMerchant")
local RangeDataDiscoverNoteTutorial = require("Game/RangeCheckTrigger/RangeData/RangeDataDiscoverNoteTutorial")
local RangeDataAetherCurrentTutorial = require("Game/RangeCheckTrigger/RangeData/RangeDataAetherCurrentTutorial")
local TriggerGamePlayType = RangeCheckTriggerDefine.TriggerGamePlayType

local RangeDataFactory = {}

---RangeDataBase instance
---@param GameType TriggerGamePlayType
function RangeDataFactory.CreateRangeDataInstance(GamePlayType)
	if TriggerGamePlayType.DiscoverNoteClueEffect == GamePlayType then
		return RangeDataDiscoverNoteEffect.New()
	elseif TriggerGamePlayType.WildBox == GamePlayType then
		return RangeDataWildBox.New()
	elseif TriggerGamePlayType.Band == GamePlayType then
		return RangeDataBand.New()
	elseif TriggerGamePlayType.MysterMerchant == GamePlayType then
		return RangeDataMysterMerchant.New()
	elseif TriggerGamePlayType.DiscoverNoteTutorial == GamePlayType then
		return RangeDataDiscoverNoteTutorial.New()
	elseif TriggerGamePlayType.AetherCurrentTutorial == GamePlayType then
		return RangeDataAetherCurrentTutorial.New()
	else
		return RangeDataBase.New()
	end
end

return RangeDataFactory
--
-- Author: anypkvcai
-- Date: 2020-08-05 14:39:13
-- Description:
--


---@class GameplayStaticsUtil
local GameplayStaticsUtil = {

}

---GetWorld
---@return UWorld
function GameplayStaticsUtil.GetWorld()
	local ULuaMgr = _G.UE.ULuaMgr.Get()
	if nil == ULuaMgr then
		return
	end

	return ULuaMgr:GetCurrentWorld()
end

---GetPlayerController
---@return APlayerController
function GameplayStaticsUtil.GetPlayerController()
	local World = GameplayStaticsUtil.GetWorld()
	if nil == World then
		return
	end

	return _G.UE.UGameplayStatics.GetPlayerController(World, 0)
end

---GetPlayerCharacter
---@return ACharacter
function GameplayStaticsUtil.GetPlayerCharacter()
	local World = GameplayStaticsUtil.GetWorld()
	if nil == World then
		return
	end

	return _G.UE.UGameplayStatics.GetPlayerCharacter(World, 0)
end

return GameplayStaticsUtil
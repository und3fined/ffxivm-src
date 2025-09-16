local CommonStateUtil = {}

function CommonStateUtil.IsInState(StateID)
	local CommStateMgr = _G.UE.UCommonStateMgr.Get()
	if nil == CommStateMgr then
		return false
	end
	return CommStateMgr:IsInState(StateID)
end

function CommonStateUtil.SetIsInState(StateID, bIsInState)
	local CommStateMgr = _G.UE.UCommonStateMgr.Get()
	if nil == CommStateMgr then
		return
	end
	CommStateMgr:SetIsInState(StateID, bIsInState)
end

function CommonStateUtil.GetActiveStates()
	local CommStateMgr = _G.UE.UCommonStateMgr.Get()
	if nil == CommStateMgr then
		return {}
	end
	return CommStateMgr:GetActiveStates()
end

---@param BehaviorID number
---@param bNeedTips boolean
---@param IgnoreStates table
---@return boolean
function CommonStateUtil.CheckBehavior(BehaviorID, bNeedTips, IgnoreStates)
	local CommStateMgr = _G.UE.UCommonStateMgr.Get()
	if nil == CommStateMgr then
		return true
	end
	local IgnoreStateArray = nil
	if nil ~= IgnoreStates then
		IgnoreStateArray = _G.UE.TArray(_G.UE.int32)
		for _, State in pairs(IgnoreStates) do
			IgnoreStateArray:Add(State)
		end
	end
	return CommStateMgr:CheckBehavior(BehaviorID, bNeedTips, IgnoreStateArray)
end

return CommonStateUtil

---
--- Author: sammrli
--- DateTime: 2024-08-16 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MovePathView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MovePathView = LuaClass(UIView, true)

function MovePathView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MovePathView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MovePathView:OnInit()

end

function MovePathView:OnDestroy()

end

function MovePathView:OnShow()

end

function MovePathView:OnHide()

end

function MovePathView:OnRegisterUIEvent()

end

function MovePathView:OnRegisterGameEvent()

end

function MovePathView:OnRegisterBinder()

end

---更新进度
function MovePathView:UpdateProgress()
	local Progress = 0
	if _G.WorldMapMgr:IsMapAutoPathMoving() then
		Progress = _G.WorldMapMgr:GetMoveProgress()
	elseif _G.ChocoboTransportMgr:GetIsTransporting() then
		Progress = _G.ChocoboTransportMgr:GetMoveProgress()
	end
	self:SetProgress(Progress)
end

---设置进度百分比(0~1)
---@param Percent number
function MovePathView:SetProgress(Percent)
	local TotoalU = self:GetTotalU()
	if not TotoalU then
		return
	end
	local UCut = Percent * TotoalU
	--FLOG_ERROR("Percent="..tostring(Percent).." ,TotoalU="..tostring(TotoalU).." , UCut="..tostring(UCut))
	self:SetMaterialParam("UCut", UCut)
end

return MovePathView
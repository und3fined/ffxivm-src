local LuaClass = require("Core/LuaClass")
local HPBarLikeAnimProxyFactory = require("Game/Main/HPBarLikeAnimProxyFactory")

---@class LocalHpBarAnimProxy: HPBarLikeAnimProxy
local LocalHpBarAnimProxy = LuaClass(HPBarLikeAnimProxyFactory.GetMatProxyClass())

function LocalHpBarAnimProxy:Upd(HPPct, ShiledPct)
    if (not HPPct) or (not ShiledPct) then return end
	if HPPct == self.HPPct and ShiledPct == self.ShiledPct then return end
	if (not self.HPPct) or (not self.ShiledPct) then
		self.HPPct = HPPct
		self.ShiledPct = ShiledPct
		return
	end

	local LastPct = self.ShiledPct == 0 and self.HPPct or self.ShiledPct
	local NowPct = ShiledPct == 0 and HPPct or ShiledPct

	if LastPct == NowPct then
		self.HPPct = HPPct
		self.ShiledPct = ShiledPct
	end

	local IsAdd = NowPct > LastPct
	-- 白黄条的分界线在白条末尾
	local Split = HPPct
	if IsAdd then
		self:StopSubAnim()
		self.AnimAddMat:SetScalarParameterValue("ProgressStart", LastPct)
		self.AnimAddMat:SetScalarParameterValue("ProgressEnd", NowPct)
		self.AnimAddMat:SetScalarParameterValue("SecondColorPoint", Split)
		self:PlayAddAnim()
	else
		self:StopAddAnim()
		self.AnimSubMat:SetScalarParameterValue("ProgressStart", LastPct)
		self.AnimSubMat:SetScalarParameterValue("ProgressEnd", NowPct)
		self.AnimSubMat:SetScalarParameterValue("SecondColorPoint", Split)
		self:PlaySubAnim()
	end

	self.HPPct = HPPct
	self.ShiledPct = ShiledPct
end

return LocalHpBarAnimProxy
local CameraUtil = {}

function CameraUtil.FOVYToFOVX(InFOVY)
	local CameraMgr = _G.UE.UCameraMgr.Get()
	if nil == CameraMgr then
		return 0
	end
	local AspectRatio = CameraMgr:GetAspectRatio()
	local TanHalfFOVX = AspectRatio * math.tan(math.rad(InFOVY) * 0.5)
	return math.deg(2 * math.atan(TanHalfFOVX))
end

function CameraUtil.FOVXToFOVY(FOVX, AspectRatio)
	local CameraMgr = _G.UE.UCameraMgr.Get()
	if nil == CameraMgr then
		return 0
	end
	if not AspectRatio then
		AspectRatio = _G.UE.UCameraMgr.Get():GetAspectRatio()
	end
    local RadFOVX = math.rad(FOVX)
    local TanHalfFOVX = math.tan(RadFOVX / 2)
    local TanHalfFOVY = TanHalfFOVX / AspectRatio
    local RadFOVY = 2 * math.atan(TanHalfFOVY)
    local FOVY = math.deg(RadFOVY)
    return FOVY
end

return CameraUtil
local CameraUtil = {}

local UE = _G.UE

function CameraUtil.FOVYToFOVX(InFOVY, AspectRatio)
	local CameraMgr = UE.UCameraMgr.Get()
	if nil == CameraMgr then
		return 0
	end
	if nil == AspectRatio or AspectRatio == 0 then
		AspectRatio = CameraMgr:GetAspectRatio()
	end
	local TanHalfFOVX = AspectRatio * math.tan(math.rad(InFOVY) * 0.5)
	return math.deg(2 * math.atan(TanHalfFOVX))
end

function CameraUtil.FOVXToFOVY(FOVX, AspectRatio)
	local CameraMgr = UE.UCameraMgr.Get()
	if nil == CameraMgr then
		return 0
	end
	if not AspectRatio then
		AspectRatio = CameraMgr:GetAspectRatio()
	end
    local RadFOVX = math.rad(FOVX)
    local TanHalfFOVX = math.tan(RadFOVX / 2)
    local TanHalfFOVY = TanHalfFOVX / AspectRatio
    local RadFOVY = 2 * math.atan(TanHalfFOVY)
    local FOVY = math.deg(RadFOVY)
    return FOVY
end

-- 假定相机朝向平行于X轴，且无滚筒角，计算相机注视点偏移量，使得ViewportPos的X轴坐标与世界坐标系Y=0对齐
function CameraUtil.GetCameraOffsetY(ViewportX, FOV, ViewDistance)
	if nil == ViewportX or nil == FOV or nil == ViewDistance then
		return
	end
	-- 计算反投影向量与中轴的夹角
	local Scale = UE.UUIUtil.GetViewportScale()
	local Size = UE.UUIUtil.GetViewportSize()
	if Scale == 0 then
		return 0
	end
	local ViewportWidth = (Size / Scale).X
	if ViewportWidth == 0 then
		return 0
	end
	return (1 - 2 * ViewportX / ViewportWidth) * math.tan(math.rad(FOV * 0.5)) * ViewDistance
end

return CameraUtil
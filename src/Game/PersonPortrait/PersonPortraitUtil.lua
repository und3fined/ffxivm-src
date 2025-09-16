local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local PersonPortraitDefine = require("Game/PersonPortrait/PersonPortraitDefine")
local PortraitModelDefaultParamsCfg = require("TableCfg/PortraitModelDefaultParamsCfg")
local MathUtil = require("Utils/MathUtil")

local DesignerType = ProtoCommon.DesignerType

local MinFOV = PersonPortraitDefine.MinFOV
local MaxFOV = PersonPortraitDefine.MaxFOV
local SliderMaxFOV = PersonPortraitDefine.SliderMaxFOV
local SliderUnitFOV = (MaxFOV - MinFOV) / SliderMaxFOV
local FOVUnitSlider = SliderMaxFOV / (MaxFOV - MinFOV)
local IntensityMaxValue = PersonPortraitDefine.IntensityMaxValue
local ColorMaxValue = PersonPortraitDefine.ColorChannelMaxValue
local MinDistance = PersonPortraitDefine.MinDistance
local MaxDistance = PersonPortraitDefine.MaxDistance

local FLOG_ERROR = _G.FLOG_ERROR

---@class PersonPortraitUtil
local PersonPortraitUtil = {

}

---根据设置类型获取类型名
function PersonPortraitUtil.GetDesignTypeName(Type)
	return ProtoEnumAlias.GetAlias(DesignerType, Type) or ""
end

---获取肖像设计图标资源路径
function PersonPortraitUtil.GetDesignIconPath(IconName)
	if string.isnilorempty(IconName) then
		return
	end

	return string.format("Texture2D'/Game/UI/Texture/PersonPortrait/%s.%s'", IconName, IconName)
end

--- 相机距离（模型缩放）默认值
function PersonPortraitUtil.GetDefaultDistance()
	local Ret = (PortraitModelDefaultParamsCfg:GetMajorCfg() or {}).Distance or 160
	if Ret < MinDistance or Ret > MaxDistance then
		FLOG_ERROR("PersonPortraitUtil:GetDefaultDistance, Cfg error, Distance: " .. tostring(Ret))

		Ret = math.max(Ret, MinDistance)
		Ret = math.min(Ret, MaxDistance)
	end

    return Ret
end

--- 是否隐藏武器 默认值	
function PersonPortraitUtil.GetDefaultIsHideWeapon()
	return false
end

--- 是否隐藏帽子 默认值
function PersonPortraitUtil.GetDefaultIsHideHat()
	return false
end

--- 是否面向镜头 默认值
function PersonPortraitUtil.GetDefaultIsFace()
    return false 
end

--- 是否看向镜头 默认值
function PersonPortraitUtil.GetDefaultIsLook()
    return false 
end

--- 移动数据 默认值
function PersonPortraitUtil.GetDefaultMove()
    local Z =  (PortraitModelDefaultParamsCfg:GetMajorCfg() or {}).SpringArmLocZ or 160 
	-- Fixed，偶现获取的值低精度位会添加一些数据（比如，配置154.77，最后拿到的是154.77000427246）
	Z = MathUtil.Round(Z, 2) 
    return {0, 0, Z} 
end

--- 相机滑动条FOV 默认值
function PersonPortraitUtil.GetDefaultFOV()
    return 100 
end

--- 相机滚动默认值
function PersonPortraitUtil.GetDefaultRoll( )
    return 0 
end

--- 旋转默认值
function PersonPortraitUtil.GetDefaultRotate( )
    return 0 
end

--- 俯仰默认值
function PersonPortraitUtil.GetDefaultPitch( )
    return 0 
end

--- 动作位置默认值
function PersonPortraitUtil.GetDefaultActionPosition( )
	return PersonPortraitDefine.MontageZero
end

-- 环境光默认值 -- 亮度
function PersonPortraitUtil.GetDefaultAmbientLightIntensity( )
    return (PortraitModelDefaultParamsCfg:GetMajorCfg() or {}).AmbientLightIntensity or 127
end

-- 环境光默认值 -- 颜色（R、G、B）
function PersonPortraitUtil.GetDefaultAmbientLightColor( )
	local Cfg = PortraitModelDefaultParamsCfg:GetMajorCfg()
	if Cfg then
		local Color = Cfg.AmbientLightColor
		if Color and #Color >= 3 then
			return Color 
		end
	end

	return {51, 51, 51}
end

-- 方向光默认值 -- 亮度
function PersonPortraitUtil.GetDefaultDirectLightIntensity( )
    return (PortraitModelDefaultParamsCfg:GetMajorCfg() or {}).DirectLightIntensity or 127
end

-- 方向光默认值 -- 颜色（R、G、B）
function PersonPortraitUtil.GetDefaultDirectLightColor( )
	local Cfg = PortraitModelDefaultParamsCfg:GetMajorCfg()
	if Cfg then
		local Color = Cfg.DirectLightColor
		if Color and #Color >= 3 then
			return Color 
		end
	end

    return {255, 255, 255}
end

-- 方向光默认值 -- 方向（X、Y）
function PersonPortraitUtil.GetDefaultDirectLightDir( )
	local Cfg = PortraitModelDefaultParamsCfg:GetMajorCfg()
	if Cfg then
		local Dir = Cfg.DirectLightDir
		if Dir and #Dir >= 2 then
			return Dir 
		end
	end

    return {-77, 133}
end

function PersonPortraitUtil.SliderValue2CameraFOV( SliderValue )
	return MinFOV + (SliderMaxFOV - SliderValue) * SliderUnitFOV
end

function PersonPortraitUtil.FOV2SliderValue( FOV )
	return SliderMaxFOV - (FOV - MinFOV) * FOVUnitSlider
end

function PersonPortraitUtil.NormalizedIntensity(Intensity)
	return (Intensity or 0)/IntensityMaxValue * 20 
end

function PersonPortraitUtil.NormalizedColor(R, G, B)
	R = R or 0
	G = G or 0
	B = B or 0

	return R/ColorMaxValue, G/ColorMaxValue, B/ColorMaxValue
end

-- 镜头最远上下偏移默认值
function PersonPortraitUtil.GetDefaultFarZOffset( )
    return (PortraitModelDefaultParamsCfg:GetMajorCfg() or {}).FarZOffset
end

-- 镜头最远角度偏移默认值
function PersonPortraitUtil.GetDefaultFarPitchOffset( )
    return (PortraitModelDefaultParamsCfg:GetMajorCfg() or {}).FarPitchOffset
end

function PersonPortraitUtil.SetDirectionalLightDir(ComImageView, X, Y)
	if nil == ComImageView then
		return
	end

	-- 左上角(-80,-45)、右上角(80,-45)、左下角(-80,45)、右下角(80,45)、中上(-45,180)、中下(45,180)
	X = (X < 0) and (180 + X*260/180) or (180 - X*100/180)
	Y = -Y*90/360

	ComImageView:SetDirectionalLightDirection(Y, X, 0)
end

return PersonPortraitUtil
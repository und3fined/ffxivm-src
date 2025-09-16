local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local PersonPortraitHeadDefine = require("Game/PersonPortraitHead/PersonPortraitHeadDefine")
local HeadEditModelParamsCfg = require("TableCfg/HeadEditModelParamsCfg")
local MathUtil = require("Utils/MathUtil")

local DesignerType = ProtoCommon.DesignerType

local MinFOV = PersonPortraitHeadDefine.MinFOV
local MaxFOV = PersonPortraitHeadDefine.MaxFOV
local SliderMaxFOV = PersonPortraitHeadDefine.SliderMaxFOV
local SliderUnitFOV = (MaxFOV - MinFOV) / SliderMaxFOV
local FOVUnitSlider = SliderMaxFOV / (MaxFOV - MinFOV)
local IntensityMaxValue = PersonPortraitHeadDefine.IntensityMaxValue
local ColorMaxValue = PersonPortraitHeadDefine.ColorChannelMaxValue
local MinDistance = PersonPortraitHeadDefine.MinDistance
local MaxDistance = PersonPortraitHeadDefine.MaxDistance

local FLOG_ERROR = _G.FLOG_ERROR

---@class PersonPortraitHeadUtil
local PersonPortraitHeadUtil = {

}

---根据设置类型获取类型名
function PersonPortraitHeadUtil.GetDesignTypeName(Type)
	return ProtoEnumAlias.GetAlias(DesignerType, Type) or ""
end

function PersonPortraitHeadUtil.GetDesignIconPath(IconName)
	if string.isnilorempty(IconName) then
		return
	end

	return string.format("Texture2D'/Game/UI/Texture/PersonPortrait/%s.%s'", IconName, IconName)
end

--- 相机距离（模型缩放）默认值
function PersonPortraitHeadUtil.GetDefaultDistance()

	local Dis, MinDis, MaxDis = PersonPortraitHeadUtil.GetDistanceParam()

	local Ret = Dis
	if Ret < MinDis or Ret > MaxDis then
		FLOG_ERROR("PersonPortraitHeadUtil:GetDefaultDistance, Cfg error, Distance: " .. tostring(Ret))

		Ret = math.max(Ret, MinDis)
		Ret = math.min(Ret, MaxDis)
	end

    return Ret
end

--- 相机距离（模型缩放）默认值
function PersonPortraitHeadUtil.GetDistanceParam()

	local Cfg = (HeadEditModelParamsCfg:GetMajorCfg() or {})
	local MinDis = Cfg.DistanceMin or 65
	local MaxDis = Cfg.DistanceMax or 85
	local Dis = Cfg.Distance or 80

	-- print('testinfo min dis = ' .. tostring(MinDis))
	return Dis, MinDis, MaxDis
end

--- 是否面向镜头 默认值
function PersonPortraitHeadUtil.GetDefaultIsFace()
    return false 
end

--- 是否看向镜头 默认值
function PersonPortraitHeadUtil.GetDefaultIsLook()
    return false 
end

--- 移动数据 默认值
function PersonPortraitHeadUtil.GetDefaultMove()
    local Z =  (HeadEditModelParamsCfg:GetMajorCfg() or {}).SpringArmLocZ or 160 
	-- Fixed，偶现获取的值低精度位会添加一些数据（比如，配置154.77，最后拿到的是154.77000427246）
	Z = MathUtil.Round(Z, 2) 
    return {0, 0, Z} 
end

--- 相机滑动条FOV 默认值
function PersonPortraitHeadUtil.GetDefaultFOV()
    return 100 
end

--- 相机滚动默认值
function PersonPortraitHeadUtil.GetDefaultRoll( )
    return 0 
end

--- 旋转默认值
function PersonPortraitHeadUtil.GetDefaultRotate( )
    return 0 
end

--- 动作位置默认值
function PersonPortraitHeadUtil.GetDefaultActionPosition( )
	return PersonPortraitHeadDefine.MontageZero
end

--- 表情位置默认值
function PersonPortraitHeadUtil.GetDefaultEmotionPosition( )
	return PersonPortraitHeadDefine.MontageZero
end

-- 环境光默认值 -- 亮度
function PersonPortraitHeadUtil.GetDefaultAmbientLightIntensity( )
    return (HeadEditModelParamsCfg:GetMajorCfg() or {}).AmbientLightIntensity or 127
end

-- 环境光默认值 -- 颜色（R、G、B）
function PersonPortraitHeadUtil.GetDefaultAmbientLightColor( )
	local Cfg = HeadEditModelParamsCfg:GetMajorCfg()
	if Cfg then
		local Color = Cfg.AmbientLightColor
		if Color and #Color >= 3 then
			return Color 
		end
	end

	return {51, 51, 51}
end

-- 方向光默认值 -- 亮度
function PersonPortraitHeadUtil.GetDefaultDirectLightIntensity( )
    return (HeadEditModelParamsCfg:GetMajorCfg() or {}).DirectLightIntensity or 127
end

-- 方向光默认值 -- 颜色（R、G、B）
function PersonPortraitHeadUtil.GetDefaultDirectLightColor( )
	local Cfg = HeadEditModelParamsCfg:GetMajorCfg()
	if Cfg then
		local Color = Cfg.DirectLightColor
		if Color and #Color >= 3 then
			return Color 
		end
	end

    return {255, 255, 255}
end

-- 方向光默认值 -- 方向（X、Y）
function PersonPortraitHeadUtil.GetDefaultDirectLightDir( )
	local Cfg = HeadEditModelParamsCfg:GetMajorCfg()
	if Cfg then
		local Dir = Cfg.DirectLightDir
		if Dir and #Dir >= 2 then
			return Dir 
		end
	end

    return {-77, 133}
end

function PersonPortraitHeadUtil.SliderValue2CameraFOV( SliderValue )
	return MinFOV + (SliderMaxFOV - SliderValue) * SliderUnitFOV
end

function PersonPortraitHeadUtil.FOV2SliderValue( FOV )
	return SliderMaxFOV - (FOV - MinFOV) * FOVUnitSlider
end

function PersonPortraitHeadUtil.NormalizedIntensity(Intensity)
	return (Intensity or 0)/IntensityMaxValue * 20 
end

function PersonPortraitHeadUtil.NormalizedColor(R, G, B)
	R = R or 0
	G = G or 0
	B = B or 0

	return R/ColorMaxValue, G/ColorMaxValue, B/ColorMaxValue
end

-- 镜头最远上下偏移默认值
function PersonPortraitHeadUtil.GetDefaultFarZOffset( )
    return (HeadEditModelParamsCfg:GetMajorCfg() or {}).FarZOffset
end

-- 镜头最远角度偏移默认值
function PersonPortraitHeadUtil.GetDefaultFarPitchOffset( )
    return (HeadEditModelParamsCfg:GetMajorCfg() or {}).FarPitchOffset
end

return PersonPortraitHeadUtil
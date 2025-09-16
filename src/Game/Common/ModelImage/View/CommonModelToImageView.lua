---
--- Author: sammrli
--- DateTime: 2023-12-04 10:25
--- Description:模型转Image通用组件
--- 只处理简单的相机逻辑，如有复杂需求，传入Actor和相机，这里只做UI显示

local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")

local CommonUtil = require("Utils/CommonUtil")

local UIBinderSetIsVisible = require ("Binder/UIBinderSetIsVisible")
local UIBinderCanvasSlotSetScale = require ("Binder/UIBinderCanvasSlotSetScale")
local UIBinderSetMaterialTextureParameterValue = require("Binder/UIBinderSetMaterialTextureParameterValue")

local CommonModelToImageVM = require("Game/Common/ModelImage/VM/CommonModelToImageVM")

---@class CommonModelToImageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Image UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonModelToImageView = LuaClass(UIView, true)

function CommonModelToImageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Image = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	---@type CommonModelToImageVM
	self.ViewModel = CommonModelToImageVM.New()
end

function CommonModelToImageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonModelToImageView:OnInit()
end

function CommonModelToImageView:OnDestroy()

end

function CommonModelToImageView:OnShow()
	_G.CommonModelToImageMgr:AddReferenceCount()
end

function CommonModelToImageView:OnHide()
	self.ViewModel:Release()
	_G.CommonModelToImageMgr:RemoveReferenceCount()
end

function CommonModelToImageView:OnRegisterUIEvent()

end

function CommonModelToImageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.Avatar_Merge_End, self.OnAvatarMergeEnd)
end

function CommonModelToImageView:OnRegisterBinder()
	local Binders = {
		{ "IsVisible", UIBinderSetIsVisible.New(self, self.Image)},
		{ "Scale", UIBinderCanvasSlotSetScale.New(self, self.Image)},
		{ "RenderTarget", UIBinderSetMaterialTextureParameterValue.New(self, self.Image, "RenderTarget")},
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function CommonModelToImageView:OnAvatarMergeEnd()
	self.ViewModel:UpdateRender()
end


-- ==================================================
-- 外部系统接口
-- ==================================================

---显示
---@param TargetActor UE.AActor 目标Actor
---@param CameraComponent UE.UCameraComponent 相机组件（可填nil）
---@param Location UE.FVector 创建位置（填nil为默认位置）
---@param Size table<X,Y>
function CommonModelToImageView:Show(TargetActor, CameraComponent, Location, Size)
	if not TargetActor then
		return
	end
	if Size == nil then
		Size = UIUtil.GetWidgetSize(self)
	end
	self.ViewModel:Show(TargetActor, CameraComponent, Size, Location)
	self:SetDrawEffectNoGamma(true)
end

---@deprecated @禁止使用 全屏显示（该接口不会压缩RT尺寸，但是限制RT为全屏大小）
---@param TargetActor UE.AActor 目标Actor
---@param CameraComponent UE.UCameraComponent 相机组件（可填nil）
function CommonModelToImageView:ShowFullScreen(TargetActor, CameraComponent)
	if not TargetActor then
		return
	end
	local Size = UIUtil.GetScreenSize()
	self.ViewModel:Show(TargetActor, CameraComponent, Size)
	self:SetDrawEffectNoGamma(true)
end

---创建并显示
---@param ModelPath string 模型路径
---@param CameraComponent UE.UCameraComponent 相机组件（可填nil）
function CommonModelToImageView:CreateAndShow(ModelPath, CameraComponent)
	if string.isnilorempty(ModelPath) then
		return
	end
	local Size = UIUtil.GetWidgetSize(self)
	self.ViewModel:CreateAndShow(ModelPath, CameraComponent, Size)
end

---设置是否创建默认场景（普通光照）
---建议show之前调用
---@param Val boolean
function CommonModelToImageView:SetAutoCreateDefaultScene(Val)
	self.ViewModel:SetAutoCreateDefaultScene(Val)
end

---@deprecated @禁止设置高清模式
function CommonModelToImageView:SetHDModel()
	self.ViewModel:SetHDModel()
end

---@param Val number 相机离目标距离(默认120)
function CommonModelToImageView:SetDistance(Val)
	self.ViewModel:SetDistance(Val)
end

---@param Val number 相机与模型高度(默认0)
function CommonModelToImageView:SetHightOffset(Val)
	self.ViewModel:SetHightOffset(Val)
end

---@param Val number 相机与Target偏航角度
function CommonModelToImageView:SetYawAngle(Val)
	self.ViewModel:SetYawAngle(Val)
end

---@param Val number 相机与Target俯仰角度
function CommonModelToImageView:SetPitchAngle(Val)
	self.ViewModel:SetPitchAngle(Val)
end

---@param Val number 相机围绕Target旋转
function CommonModelToImageView:RotateCamera(Val)
	self.ViewModel:RotateCamera(Val)
end

---@param Val number 相机平移Val
function CommonModelToImageView:SetPan(Val)
	self.ViewModel:SetPan(Val)
end

---@param Val number 相机FOV
function CommonModelToImageView:SetFOV(Val)
	self.ViewModel:SetFOV(Val)
end

---自动设置摄像机距离,让摄像机能够看全Actor
---@param MaxExtent 模型最大半径 (可传nil, 传nil会遍历Actor所有collision计算最大半径)
function CommonModelToImageView:AutoSetDistance(MaxExtent)
	self.ViewModel:AutoSetDistance(MaxExtent)
end

---@return number
function CommonModelToImageView:GetDistance()
	return self.ViewModel.Distance
end

---@return number
function CommonModelToImageView:GetYawAngle()
	return self.ViewModel.Angle
end

---@return number
function CommonModelToImageView:GetPitchAngle()
	return self.ViewModel.PitchAngle
end

---@return number
function CommonModelToImageView:GetHightOffset()
	return self.ViewModel.HightOffset
end

---@return number
function CommonModelToImageView:GetPan()
	return self.ViewModel.PanOffset
end

function CommonModelToImageView:SetDrawEffectNoGamma(IsNoGamma)
	if self.Image then
		self.Image:SetDrawEffectNoGamma(IsNoGamma)
	end
	local RT = self.ViewModel.RenderTarget
	if RT and CommonUtil.IsObjectValid(RT) then
		if IsNoGamma then
			RT.TargetGamma = 2.2
		else
			RT.TargetGamma = 0
		end
	end
end

---切换模型相机为主相机
---@param Show boolean
function CommonModelToImageView:SwitchModelCamera(Show)
	self.ViewModel:SwitchModelCamera(Show)
end

return CommonModelToImageView
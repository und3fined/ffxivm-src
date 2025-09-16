---
--- Author: sammrli
--- DateTime: 2024-03-19 09:58
--- Description:模型展示示例界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local ModelMajorController = require ("Game/Model/Actor/ModelMajorController")
local ModelCameraController = require ("Game/Model/Camera/ModelCameraController")
local StageUniverseController = require ("Game/Model/Stage/StageUniverseController")

---@class ShowModelPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommGesture_UIBP CommGestureView
---@field Common_CloseBtn_UIBP CommonCloseBtnView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShowModelPanelView = LuaClass(UIView, true)

function ShowModelPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommGesture_UIBP = nil
	--self.Common_CloseBtn_UIBP = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShowModelPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommGesture_UIBP)
	self:AddSubView(self.Common_CloseBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShowModelPanelView:OnInit()
	--相机控制，如果没有相机操作，可以不实例化
	self.ModelCameraController = ModelCameraController.New()

	--相机控制绑定通用手势组件，也可以不绑定，需要自己手动注册回调，让相机和界面操作关联
	self.ModelCameraController:BindCommGesture(self.CommGesture_UIBP)

	--主角模型控制
	self.ModelMajorController = ModelMajorController.New()

	--Npc模型控制
	--self.ModelNpcController = ModelNpcController.New()

	--武器模型控制
	--self.ModelEObjController = ModelEObjController.New()

	--多个模型控制
	self.ModelControllerList = {}
	for i=1, 5 do
		--table.insert(self.ModelControllerList, ModelNpcController.New())
	end

	--星空场景控制
	self.StageUniverseController = StageUniverseController.New()
	self.StageUniverseController:SetCreateFinish(self, self.OnCreateStageFinish)

	--登陆场景控制
	--self.StageLoginController = StageLoginController.New()

	--[[
		以上控制器和UIView是剥离的,可以在其他地方实例化controller并管理好，这样可以多个界面用一套controller，或者实现预加载
	]]
end

function ShowModelPanelView:OnDestroy()

end

function ShowModelPanelView:OnShow()
	--创建模型
	self.ModelMajorController:Create()
	--创建场景
	self.StageUniverseController:Create()
	--场景绑定模型,因为星空场景里的射灯需要匹配角色模型bound,其他场景不需要这样处理
	self.StageUniverseController:BindUIComplexCharacter(self.ModelMajorController:GetChildActor())
	--关闭场景里的灯光
	_G.LightMgr:SwitchSceneLights(false)
	--如果美术有为这个场景制作了相应的灯光关卡，调用LightMgr的接口加载
	--_G.LightMgr:LoadLightLevel(LightDefine.LightLevelID.LIGHT_LEVEL_ID_RECHARGE1)
end

function ShowModelPanelView:OnHide()
	--管理器释放资源
	self.ModelMajorController:Release()
	self.StageUniverseController:Release()
	--开启场景里的灯光
	_G.LightMgr:SwitchSceneLights(true)
	--卸载灯光关卡
	--_G.LightMgr:UnLoadLightLevel(LightDefine.LightLevelID.LIGHT_LEVEL_ID_RECHARGE1)
	--切换回主角相机
	self.ModelCameraController:Switch(false)
end

function ShowModelPanelView:OnRegisterUIEvent()

end

function ShowModelPanelView:OnRegisterGameEvent()

end

function ShowModelPanelView:OnRegisterBinder()
end

function ShowModelPanelView:OnCreateStageFinish()
	--相机绑定CameraActor (这里因为场景里放置了相机,所以直接绑定)
	self.ModelCameraController:BindCameraActor(self.StageUniverseController:GetActor())
	--切换相机为主相机
	self.ModelCameraController:Switch(true)
end

return ShowModelPanelView
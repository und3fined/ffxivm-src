--
-- Author: sammrli
-- Date: 2024-3-18
-- Description:
--

local UE = _G.UE

local DefaultLocation = UE.FVector(0, 0, 100000)
local DefaultRotation = UE.FRotator(0, 0, 0)

---@class StagePath
---@field Universe string
local StagePath =
{
    Universe = "Class'/Game/UI/Render2D/Common/BP_Render2DLoginActor_%s.BP_Render2DLoginActor_%s_C'",
}

local ChocoboStagePath =
{
    Universe = "Class'/Game/UI/Render2D/Chocobo/BP_Render2DForChocoboAndBuddy.BP_Render2DForChocoboAndBuddy_C'",
}


local ChocoboSceneRes = 
{
    ArmorRes = 
    {

    },
    ArmorRes1 = 
    {
        [1] = 
        {
            ModelPath = "StaticMesh'/Game/UI/Render2D/Chocoboequip/NanSen/bgparts/SM_f1f3_jinjing_1.SM_f1f3_jinjing_1'",
            FLocation = UE.FVector(0, 0, 100000),
            FRotation = UE.FRotator(0, 0, 0),
            FScale = UE.FVector(1, 1, 1),
        },
        [2] = 
        {
            ModelPath = "StaticMesh'/Game/UI/Render2D/Chocoboequip/NanSen/bgparts/SM_f1f3_BeiJing_1.SM_f1f3_BeiJing_1'",
            FLocation = UE.FVector(-920, 0, 100250),
            FRotation = UE.FRotator(0, 0, 0),
            FScale = UE.FVector(1.5, 1.5, 1.5),
        },
    }
}

local CameraResPath = ""

---@class ModelDefine
---@field StagePath StagePath@场景资源路径
---@field CameraResPath string@相机资源路径
---@field DefaultLocation UE.FVector@模型默认位置
---@field DefaultRotation UE.FRotator@模型默认朝向
local ModelDefine =
{
	StagePath = StagePath,
    CameraResPath = CameraResPath,
    DefaultLocation = DefaultLocation,
    DefaultRotation = DefaultRotation,
    ChocoboStagePath =  ChocoboStagePath,
    ChocoboSceneRes = ChocoboSceneRes,
}

return ModelDefine
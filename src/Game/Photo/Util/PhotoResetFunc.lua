local PhotoDefine = require("Game/Photo/PhotoDefine")

local UITabMain = PhotoDefine.UITabMain
local UITabSub = PhotoDefine.UITabSub

local function ResetCameraDOF()
    _G.PhotoCamVM:SetCurUnit(PhotoDefine.CameraResetUnit)
end

local function ResetCameraFOV()
    _G.PhotoCamVM:SetCurUnit(PhotoDefine.CameraResetUnit)
end

local function ResetCameraRot()
    _G.PhotoCamVM:SetCurUnit(PhotoDefine.CameraResetUnit)
end

local function ResetRoleActAni()
    _G.PhotoActionVM:ResetRoleActAni()
end

local function ResetRoleEmoAni()
    _G.PhotoEmojiVM:ResetRoleActAni()
end


local function ResetRoleSettingMajor()
    _G.PhotoRoleSettingVM:ResetMajorAngleIdx()
end

local function ResetFilter()
    _G.PhotoFilterVM:SetFilterIdx(nil)
end

local function ResetMaskEdge()
    _G.PhotoDarkEdgeVM:ResetEdge()
end

local function ResetRoleSettingVisible()
    -- _G.PhotoRoleSettingVM:ResetAllActorVisible()
end

local function ResetRoleState()
    _G.PhotoRoleStatVM:SetStatIdx(nil, nil)
end

local function ResetScene()
    _G.PhotoSceneVM:ResetWeatherAndTime2Now()
end

local function ResetRoleSetting()
    local Idx = _G.PhotoRoleSettingVM.SubUIIdx

    if Idx == 0 then
        ResetRoleSettingMajor()
    else
        ResetRoleSettingVisible()
    end
end

local UITabResetFunc = {
    [UITabMain.Camera] = {
        [UITabSub[UITabMain.Camera].DOF]        = ResetCameraDOF,
        [UITabSub[UITabMain.Camera].FOV]        = ResetCameraFOV,
        [UITabSub[UITabMain.Camera].Rot]        = ResetCameraRot,
    },

    [UITabMain.Role] = {
        [UITabSub[UITabMain.Role].Act]          = ResetRoleActAni,
        [UITabSub[UITabMain.Role].Emo]          = ResetRoleEmoAni,
        [UITabSub[UITabMain.Role].Stat]         = ResetRoleState,
        [UITabSub[UITabMain.Role].Setting]      = ResetRoleSetting,
    },

    [UITabMain.Eff] = {
        [UITabSub[UITabMain.Eff].Filer]         = ResetFilter,
        [UITabSub[UITabMain.Eff].DarkFrame]     = ResetMaskEdge,
        -- [UITabSub[UITabMain.Role].Frame]        = LSTR(630033),
        [UITabSub[UITabMain.Eff].Scene]         = ResetScene,
    },

    [UITabMain.Mod] = {
        [UITabSub[UITabMain.Mod].Mod]           = nil,
    },
}

local Util = {}

function Util.CallResetFunc(MainTy, SubTy, ...)
    if UITabResetFunc[MainTy] then
        if UITabResetFunc[MainTy][SubTy] then
            return UITabResetFunc[MainTy][SubTy](...)
        end
    end
    _G.FLOG_ERROR('Andre.PhotoResetFunc.UITabResetFunc.Ty not match function')
end


return Util
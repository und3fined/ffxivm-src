

local Util = {}

function Util.TakePicture(TexName, CustCB)
    local UMediaUtil = _G.UE.UMediaUtil

    local CB = function (_, W, H, ColArr)
        local Tex = UMediaUtil.CovertColorsToTexture2D(TexName or "", ColArr, W, H)
        CustCB(Tex)
    end

    UMediaUtil.TakeScreenshot(false, CB)
end

function Util.OnStartCap()
    local SeltActor = _G.UE.USelectEffectMgr:Get():GetCurrSelectedTarget()
    local SeltID = nil

    -- engine 那边不太好改， 先異步处理，选中那边让用事件处理
    if SeltActor then
        local AttrComp = SeltActor:GetAttributeComponent()
        if AttrComp then
            SeltID = AttrComp.EntityID
            local EventParams = _G.EventMgr:GetEventParams()
            EventParams.ULongParam1 = 0
            _G.EventMgr:SendCppEvent(_G.EventID.ManualUnSelectTarget, EventParams)
            _G.EventMgr:SendEvent(_G.EventID.ManualUnSelectTarget, EventParams)
        end
    end

    _G.HUDMgr:SetPlayerInfoVisible(false)

    return 
    {
        SeltID = SeltID
    }
end

function Util.OnEndCap(CacheInfo)
    local SeltID = CacheInfo.SeltID
    _G.HUDMgr:SetPlayerInfoVisible(true)
    if SeltID then
        local EventParams = _G.EventMgr:GetEventParams()
        EventParams.ULongParam1 = SeltID
        _G.EventMgr:SendCppEvent(_G.EventID.ManualSelectTarget, EventParams)
        _G.EventMgr:SendEvent(_G.EventID.ManualSelectTarget, EventParams)
    end
end

function Util.TakePictureAndSetImage(Image)
    local UMediaUtil = _G.UE.UMediaUtil
    local CapCacheInfo = Util.OnStartCap()

    local CB = function (W, H, ColArr)
        local Tex = UMediaUtil.CovertColorsToTexture2D("", ColArr, W, H)
        -- local DynamicMat = Image:GetDynamicMaterial()
        if Tex then
            -- DynamicMat:SetTextureParameterValue("Texture", Tex)
            UIUtil.ImageSetBrushResourceObject(Image, Tex)
        end

        Util.OnEndCap(CapCacheInfo)
    end

    Util.CapScreen(CB, false)
end

function Util.CapScreen(CB, bShowUI)
    local UMediaUtil = _G.UE.UMediaUtil
    local CapCacheInfo = Util.OnStartCap()
    local InnerCB = CommonUtil.GetDelegatePair(function (_, W, H, ColArr)
        Util.OnEndCap(CapCacheInfo)
        CB(W, H, ColArr)
    end, true)

    UMediaUtil.TakeScreenshot(bShowUI, InnerCB)
end

function Util.SaveToAlbum(BitmapInfo)
    local UE = _G.UE
    local UMediaUtil = UE.UMediaUtil
    local PathMgr = require("Path/PathMgr")

    if not BitmapInfo then
        return
    end
    local W, H, ColArr = BitmapInfo.W, BitmapInfo.H, BitmapInfo.ColArr

    if not (W and H and ColArr) then
        return
    end

    local TempPath = UMediaUtil.BitmapToSavedFile(W, H, ColArr, true)
    local AlbumPath = UMediaUtil.GetAlbumPath()

    local PlatformName = CommonUtil.GetPlatformName()
	if PlatformName == "Android" then
		local DesPath = string.format("%s/%s", AlbumPath, PathMgr.GetCleanFilename(TempPath))
		if UE.UCommonUtil.MoveFile(DesPath, TempPath, true) then
			UE.UMediaUtil.NotifyAlbumUpdate(DesPath)
		end
	elseif PlatformName == "IOS" then
		UMediaUtil.SaveNativeScreenshot(TempPath)
	end
end

return Util
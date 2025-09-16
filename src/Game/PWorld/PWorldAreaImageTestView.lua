---
--- Author: haialexzhou
--- DateTime: 2021-12-06 17:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")

---@class PWorldAreaImageTestView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn UButton
---@field CurrPosFlag UImage
---@field Img_Area UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldAreaImageTestView = LuaClass(UIView, true)

function PWorldAreaImageTestView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CurrPosFlag = nil
	--self.Img_Area = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldAreaImageTestView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldAreaImageTestView:OnInit()
	_G.UIUtil.AddOnClickedEvent(self, self.CloseBtn, self.OnClickCloseBtn)
end

function PWorldAreaImageTestView:OnDestroy()

end

function PWorldAreaImageTestView:OnShow()
	local Major = MajorUtil.GetMajor()

    if not Major then
        return
    end
	local MajorPos = Major:FGetActorLocation()
    local ImagePosX, ImagePosY = _G.MapAreaImageMgr:GetImagePosByActorPos(MajorPos)
	local ScreenSize = UIUtil.GetScreenSize()
	local AreaImageSize = _G.MapAreaImageMgr:GetAreaImageSize()
	local NewImagePosX = ImagePosX * (ScreenSize.X / AreaImageSize.X)
	local NewImagePosY = ImagePosY * (ScreenSize.Y / AreaImageSize.Y)
	local NewWidgetPos = _G.UE.FVector2D(NewImagePosX, NewImagePosY)
	--print("DragMove StartWidgetPos=" .. table_to_string(StartWidgetPos) .. "; EndWidgetPos=" .. table_to_string(EndWidgetPos))
	UIUtil.CanvasSlotSetPosition(self.CurrPosFlag, NewWidgetPos)

	local AreaImagePath = _G.MapAreaImageMgr:GetAreaImagePath()
	if (AreaImagePath ~= nil) then
		UIUtil.ImageSetBrushFromAssetPath(self.Img_Area, AreaImagePath)
	end
end

function PWorldAreaImageTestView:OnClickCloseBtn()
	_G.UIViewMgr:HideView(self.ViewID)
end

function PWorldAreaImageTestView:OnHide()

end

function PWorldAreaImageTestView:OnRegisterUIEvent()

end

function PWorldAreaImageTestView:OnRegisterGameEvent()

end

function PWorldAreaImageTestView:OnRegisterBinder()

end

return PWorldAreaImageTestView
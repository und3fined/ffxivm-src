---
--- Author: peterxie
--- DateTime: 2024-10-18 16:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")


---@class MapContentGoldSaucerPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgName UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapContentGoldSaucerPanelView = LuaClass(UIView, true)

function MapContentGoldSaucerPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MapContentGoldSaucerPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapContentGoldSaucerPanelView:OnInit()

end

function MapContentGoldSaucerPanelView:OnDestroy()

end

function MapContentGoldSaucerPanelView:OnShow()
	local DefaultPath = "Texture2D'/Game/UI/Texture/Localized/chs/UI_Map_Img_GoldSaucer_MapName.UI_Map_Img_GoldSaucer_MapName'"
	local LocalIconPath = LocalizationUtil.GetLocalizedAssetPath(DefaultPath)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgName, LocalIconPath)

	-- 重构制作的资源默认是缩小的
	self:SetRenderScale(_G.UE.FVector2D(2, 2))
end

function MapContentGoldSaucerPanelView:OnHide()

end

function MapContentGoldSaucerPanelView:OnRegisterUIEvent()

end

function MapContentGoldSaucerPanelView:OnRegisterGameEvent()

end

function MapContentGoldSaucerPanelView:OnRegisterBinder()

end

return MapContentGoldSaucerPanelView
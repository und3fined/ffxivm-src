---
--- Author: zimuyi
--- DateTime: 2025-07-08 14:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")

local ItemBgColor = {
	"Texture2D'/Game/UI/Texture/CommPic/UI_Comm_Shop_Img_ColorWhite.UI_Comm_Shop_Img_ColorWhite'",
	"Texture2D'/Game/UI/Texture/CommPic/UI_Comm_Shop_Img_ColorGreen.UI_Comm_Shop_Img_ColorGreen'",
	"Texture2D'/Game/UI/Texture/CommPic/UI_Comm_Shop_Img_ColorBlue.UI_Comm_Shop_Img_ColorBlue'",
	"Texture2D'/Game/UI/Texture/CommPic/UI_Comm_Shop_Img_ColorPurple.UI_Comm_Shop_Img_ColorPurple'",
}

local ImgPicColor = {
	"ffffff07",
	"b0ffc307",
	"b0c8ff07",
	"ecafff07"
}
---@class CommWinSlotQualityView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg2 UFImage
---@field ImgBgPic UFImage
---@field ShowCircle bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommWinSlotQualityView = LuaClass(UIView, true)

function CommWinSlotQualityView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg2 = nil
	--self.ImgBgPic = nil
	--self.ShowCircle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommWinSlotQualityView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommWinSlotQualityView:OnInit()

end

function CommWinSlotQualityView:OnDestroy()

end

function CommWinSlotQualityView:OnShow()
	
end

function CommWinSlotQualityView:UpdateUIByItem(ResID)
	local Cfg = ItemCfg:FindCfgByKey(ResID)
	if Cfg ~= nil then
		UIUtil.ImageSetBrushFromAssetPathSync(self.ImgBg2, ItemBgColor[Cfg.ItemColor])
		UIUtil.ImageSetBrushTintColorHex(self.ImgBgPic, ImgPicColor[Cfg.ItemColor])
	end
end

function CommWinSlotQualityView:OnHide()

end

function CommWinSlotQualityView:OnRegisterUIEvent()

end

function CommWinSlotQualityView:OnRegisterGameEvent()

end

function CommWinSlotQualityView:OnRegisterBinder()

end

return CommWinSlotQualityView
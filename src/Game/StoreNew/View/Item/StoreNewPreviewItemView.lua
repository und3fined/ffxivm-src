---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local StoreMgr = require("Game/Store/StoreMgr")

---@class StoreNewPreviewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgItem UFImage
---@field ImgPoster UFImage
---@field ImgSelect UFImage
---@field PanelReceived UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewPreviewItemView = LuaClass(UIView, true)

function StoreNewPreviewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgItem = nil
	--self.ImgPoster = nil
	--self.ImgSelect = nil
	--self.PanelReceived = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewPreviewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewPreviewItemView:OnInit()
	
end

function StoreNewPreviewItemView:OnDestroy()

end

function StoreNewPreviewItemView:OnShow()
	local Data = self.Params.Data
	if Data ~= nil then
		local GoodsID = Data.ID
		if GoodsID ~= nil then
			local GoodsData = _G.StoreMgr:GetProductDataByID(GoodsID)
			if GoodsData ~= nil then
				local GoodsCfg = GoodsData.Cfg
				if GoodsCfg ~= nil then
					local IsPoster = tonumber(GoodsCfg.Icon) == nil
					local IconPath = IsPoster and GoodsCfg.Icon or UIUtil.GetIconPath(GoodsCfg.Icon)
					UIUtil.SetIsVisible(self.ImgItem, not IsPoster)
					UIUtil.SetIsVisible(self.ImgPoster, IsPoster)
					UIUtil.ImageSetBrushFromAssetPath(self.ImgItem, IconPath, true)
					UIUtil.ImageSetBrushFromAssetPath(self.ImgPoster, IconPath, true)
					-- UIUtil.SetIsVisible(self.ImgPoster, GoodsCfg.LabelMain == ProtoRes.Store_Label_Type.STORE_LABEL_MAIN_FASHION)
					UIUtil.SetIsVisible(self.PanelReceived, StoreMgr:CheckGoodsIsOwned(GoodsCfg))
				end
			end
		end
	end
end

function StoreNewPreviewItemView:OnSelectChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue)
end

function StoreNewPreviewItemView:OnHide()

end

function StoreNewPreviewItemView:OnRegisterUIEvent()
end



function StoreNewPreviewItemView:OnRegisterGameEvent()

end

function StoreNewPreviewItemView:OnRegisterBinder()
	
end

return StoreNewPreviewItemView
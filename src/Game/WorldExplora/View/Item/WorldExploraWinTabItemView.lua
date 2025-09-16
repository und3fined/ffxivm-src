---
--- Author: Administrator
--- DateTime: 2025-03-18 11:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldExploraWinTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgIcon UFImage
---@field ImgLine UFImage
---@field ImgLock UFImage
---@field SelectEffect UFCanvasPanel
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraWinTabItemView = LuaClass(UIView, true)

function WorldExploraWinTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgIcon = nil
	--self.ImgLine = nil
	--self.ImgLock = nil
	--self.SelectEffect = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraWinTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraWinTabItemView:OnInit()
	
end

function WorldExploraWinTabItemView:OnDestroy()

end

function WorldExploraWinTabItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, Data.IconPath)
	UIUtil.SetIsVisible(self.ImgLock, Data.bLock)
	self.TextName:SetText(Data.Name or "")

	UIUtil.SetIsVisible(self.ImgLine, not Data.IsLastItem) 
end

function WorldExploraWinTabItemView:OnHide()

end

function WorldExploraWinTabItemView:OnRegisterUIEvent()

end

function WorldExploraWinTabItemView:OnRegisterGameEvent()

end

function WorldExploraWinTabItemView:OnRegisterBinder()

end

function WorldExploraWinTabItemView:OnSelectChanged(IsSelected)	
	UIUtil.SetIsVisible(self.SelectEffect, IsSelected)
end

return WorldExploraWinTabItemView
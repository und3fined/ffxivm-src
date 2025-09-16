---
--- Author: v_vvxinchen
--- DateTime: 2024-03-28 10:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommEmptyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Moggle UFImage
---@field Text_SearchAgain UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommEmptyView = LuaClass(UIView, true)

function CommEmptyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Moggle = nil
	--self.Text_SearchAgain = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommEmptyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommEmptyView:OnInit()
	self:UpdateText(_G.LSTR("暂无内容"))
end

function CommEmptyView:OnDestroy()

end

function CommEmptyView:OnShow()

end

function CommEmptyView:OnHide()

end

function CommEmptyView:OnRegisterUIEvent()

end

function CommEmptyView:OnRegisterGameEvent()

end

function CommEmptyView:OnRegisterBinder()

end

function CommEmptyView:UpdateText(content)
	self.Text_SearchAgain:SetText(content)
end

function CommEmptyView:UpdateImg(AssetPath)
	UIUtil.ImageSetBrushFromAssetPath(self.FImg_Moggle, AssetPath, true)
end

return CommEmptyView
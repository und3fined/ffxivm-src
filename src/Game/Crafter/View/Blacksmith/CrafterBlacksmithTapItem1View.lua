---
--- Author: henghaoli
--- DateTime: 2023-09-27 14:39
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CrafterBlacksmithTapItemUtil = require("Game/Crafter/View/Blacksmith/CrafterBlacksmithTapItemUtil")

---@class CrafterBlacksmithTapItem1View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTap UFButton
---@field EFF_HotForge UFCanvasPanel
---@field ImgBtnColor1 UFImage
---@field ImgBtnColor2 UFImage
---@field ImgBtnColor3 UFImage
---@field ImgBtnNormal UFImage
---@field ImgLight UFImage
---@field Text1 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterBlacksmithTapItem1View = LuaClass(UIView, true)

function CrafterBlacksmithTapItem1View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTap = nil
	--self.EFF_HotForge = nil
	--self.ImgBtnColor1 = nil
	--self.ImgBtnColor2 = nil
	--self.ImgBtnColor3 = nil
	--self.ImgBtnNormal = nil
	--self.ImgLight = nil
	--self.Text1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterBlacksmithTapItem1View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterBlacksmithTapItem1View:OnInit()

end

function CrafterBlacksmithTapItem1View:OnDestroy()

end

function CrafterBlacksmithTapItem1View:OnShow()

end

function CrafterBlacksmithTapItem1View:OnHide()

end

function CrafterBlacksmithTapItem1View:OnRegisterUIEvent()

end

function CrafterBlacksmithTapItem1View:OnRegisterGameEvent()

end

function CrafterBlacksmithTapItem1View:OnRegisterBinder()
	CrafterBlacksmithTapItemUtil.RegisterTapBinders(self)
end

return CrafterBlacksmithTapItem1View
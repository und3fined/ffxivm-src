---
--- Author: jususchen
--- DateTime: 2025-07-29 17:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsMoggleCollectUnlockWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo UFButton
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field ImgArrow UFImage
---@field ImgGotoBG UFImage
---@field ImgItemIcon UFImage
---@field ImgLockBG UFImage
---@field TextLock UFTextBlock
---@field TextMain UFTextBlock
---@field TextQuestName UFTextBlock
---@field TextUnLock UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsMoggleCollectUnlockWinView = LuaClass(UIView, true)

function OpsMoggleCollectUnlockWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.Comm2FrameS_UIBP = nil
	--self.ImgArrow = nil
	--self.ImgGotoBG = nil
	--self.ImgItemIcon = nil
	--self.ImgLockBG = nil
	--self.TextLock = nil
	--self.TextMain = nil
	--self.TextQuestName = nil
	--self.TextUnLock = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectUnlockWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsMoggleCollectUnlockWinView:OnInit()

end

function OpsMoggleCollectUnlockWinView:OnDestroy()

end

function OpsMoggleCollectUnlockWinView:OnShow()

end

function OpsMoggleCollectUnlockWinView:OnHide()

end

function OpsMoggleCollectUnlockWinView:OnRegisterUIEvent()

end

function OpsMoggleCollectUnlockWinView:OnRegisterGameEvent()

end

function OpsMoggleCollectUnlockWinView:OnRegisterBinder()

end

return OpsMoggleCollectUnlockWinView
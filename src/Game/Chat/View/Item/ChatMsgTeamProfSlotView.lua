---
--- Author: xingcaicao
--- DateTime: 2023-10-12 17:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ChatMsgTeamProfSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ContentNode UFCanvasPanel
---@field ImgProf UFImage
---@field ImgReady UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgTeamProfSlotView = LuaClass(UIView, true)

function ChatMsgTeamProfSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ContentNode = nil
	--self.ImgProf = nil
	--self.ImgReady = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgTeamProfSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgTeamProfSlotView:OnInit()

end

function ChatMsgTeamProfSlotView:OnDestroy()

end

function ChatMsgTeamProfSlotView:OnShow()
	local Data = (self.Params or {}).Data

	-- 图标
	UIUtil.ImageSetBrushFromAssetPath(self.ImgProf, Data.Icon)

	-- 是否已招募到玩家
	UIUtil.SetIsVisible(self.ImgReady, Data.HasRole)
end

function ChatMsgTeamProfSlotView:OnHide()

end

function ChatMsgTeamProfSlotView:OnRegisterUIEvent()

end

function ChatMsgTeamProfSlotView:OnRegisterGameEvent()

end

function ChatMsgTeamProfSlotView:OnRegisterBinder()

end

return ChatMsgTeamProfSlotView
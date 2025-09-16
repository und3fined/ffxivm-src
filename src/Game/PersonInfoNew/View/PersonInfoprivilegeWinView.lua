---
--- Author: saintzhao
--- DateTime: 2024-11-25 10:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PersonInfoprivilegeWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TextHint1 UFTextBlock
---@field TextHint2 UFTextBlock
---@field Textprivilege UFTextBlock
---@field Textprivilege1 UFTextBlock
---@field Textprivilege1_1 UFTextBlock
---@field Textprivilege1_2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PersonInfoprivilegeWinView = LuaClass(UIView, true)

function PersonInfoprivilegeWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.TextHint1 = nil
	--self.TextHint2 = nil
	--self.Textprivilege = nil
	--self.Textprivilege1 = nil
	--self.Textprivilege1_1 = nil
	--self.Textprivilege1_2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PersonInfoprivilegeWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PersonInfoprivilegeWinView:OnInit()

end

function PersonInfoprivilegeWinView:OnDestroy()

end

function PersonInfoprivilegeWinView:OnShow()
	self.Comm2FrameM_UIBP.FText_Title:SetText(_G.LSTR(100002))
	self.TextHint1:SetText(_G.LSTR(100109))
	self.Textprivilege:SetText(_G.LSTR(100110))
	self.Textprivilege1:SetText(_G.LSTR(100111))
	self.Textprivilege1_1:SetText(_G.LSTR(100112))
	self.Textprivilege1_2:SetText(_G.LSTR(100113))
	self.TextHint2:SetText(_G.LSTR(100114))
end

function PersonInfoprivilegeWinView:OnHide()

end

function PersonInfoprivilegeWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.ButtonClose, self.OnButtonClose)
end

function PersonInfoprivilegeWinView:OnRegisterGameEvent()

end

function PersonInfoprivilegeWinView:OnRegisterBinder()

end

function PersonInfoprivilegeWinView:OnButtonClose()
	self:Hide()
end

return PersonInfoprivilegeWinView
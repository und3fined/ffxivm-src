---
--- Author: enqingchen
--- DateTime: 2022-03-14 17:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MagicsparRemoveTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG CommMsgTipsView
---@field FBtn_Cancel CommBtnLView
---@field FBtn_OK CommBtnLView
---@field FTextBlock_Desc UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparRemoveTipsView = LuaClass(UIView, true)

function MagicsparRemoveTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.FBtn_Cancel = nil
	--self.FBtn_OK = nil
	--self.FTextBlock_Desc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparRemoveTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.FBtn_Cancel)
	self:AddSubView(self.FBtn_OK)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparRemoveTipsView:OnInit()

end

function MagicsparRemoveTipsView:OnDestroy()

end

function MagicsparRemoveTipsView:OnShow()
	self.CallbackView = self.Params[1]
	self.Callback = self.Params[2]
	self.FTextBlock_Desc:SetText(self.Params[3])
	if self.Params[4] ~= nil then
		self.BG.RichTextBox_Title:SetText(self.Params[4])
	end
	self.FBtn_Cancel.TextContent:SetText(_G.LSTR(1060029)) -- "取消"
	self.FBtn_OK.TextContent:SetText(_G.LSTR(1060030)) -- "确定"
end

function MagicsparRemoveTipsView:OnHide()

end

function MagicsparRemoveTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_OK.Button, self.OnBtnOKClick)
	UIUtil.AddOnClickedEvent(self, self.FBtn_Cancel.Button, self.OnBtnCancelClick)
end

function MagicsparRemoveTipsView:OnRegisterGameEvent()

end

function MagicsparRemoveTipsView:OnRegisterBinder()

end

function MagicsparRemoveTipsView:OnBtnOKClick()
	if self.Callback then
		self.Callback(self.CallbackView)
	end
	UIViewMgr:HideView(self.ViewID)
end

function MagicsparRemoveTipsView:OnBtnCancelClick()
	UIViewMgr:HideView(self.ViewID)
end

return MagicsparRemoveTipsView
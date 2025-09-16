---
--- Author: Administrator
--- DateTime: 2023-10-10 20:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommStorageBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtnM CommBtnMView
---@field RedDot CommonRedDotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommStorageBtnView = LuaClass(UIView, true)

function CommStorageBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommBtnM = nil
	--self.RedDot = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommStorageBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommBtnM)
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommStorageBtnView:OnInit()

end

function CommStorageBtnView:OnDestroy()

end

function CommStorageBtnView:OnShow()
	local Params = self.Params
	self.RedDot:SetIsCustomizeRedDot(true)
	if Params then
		self:UpdateRedDot()
		self:SetButtonEnable()
		self.CommBtnM:SetButtonText(Params.Data.Content)
		self.View = Params.Data.View
	end

end

--外部数据结构不一样，这里需要兼容两种数据结构
function CommStorageBtnView:UpdateRedDot()
	if self.Params and self.Params.Data then
		local bShowRedPoint = self.Params.Data.bShowRedPoint
		if not bShowRedPoint and self.Params.Data.Value then
			bShowRedPoint = self.Params.Data.Value.bShowRedPoint
		end
		self.RedDot:SetRedDotUIIsShow(bShowRedPoint)
	end
end

function CommStorageBtnView:OnHide()
end

function CommStorageBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommBtnM.Button, self.OnClickedItem)
end

function CommStorageBtnView:OnRegisterGameEvent()

end

function CommStorageBtnView:OnRegisterBinder()
end

function CommStorageBtnView:OnClickedItem()
	local Params = self.Params
	if Params then
		if Params.Data.ClickItemCallback ~= nil then
			Params.Data.ClickItemCallback(self.View, self.Params.Data)
		end
	end
end

function CommStorageBtnView:SetButtonEnable()
	local Params = self.Params
	if Params.Data.NeedSetEnable then
		self.CommBtnM:SetIsEnabled(Params.Data.bIsEnabled, true)
	end
end
return CommStorageBtnView
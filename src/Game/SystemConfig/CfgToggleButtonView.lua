---
--- Author: chaooren
--- DateTime: 2021-10-22 15:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CfgToggleButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Checked UFImage
---@field Text UFTextBlock
---@field ToggleButton_332 UToggleButton
---@field UnChecked UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CfgToggleButtonView = LuaClass(UIView, true)

function CfgToggleButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Checked = nil
	--self.Text = nil
	--self.ToggleButton_332 = nil
	--self.UnChecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CfgToggleButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CfgToggleButtonView:OnInit()
	self.OnStateChecked = nil
	self.SaveKey = nil
end

function CfgToggleButtonView:OnDestroy()

end

function CfgToggleButtonView:OnShow()

end

function CfgToggleButtonView:OnHide()

end

function CfgToggleButtonView:OnRegisterUIEvent()

end

function CfgToggleButtonView:OnRegisterGameEvent()

end

function CfgToggleButtonView:OnRegisterBinder()

end

function CfgToggleButtonView:Init(CfgData, Name, Index, Ptr, Callback, SaveKey)
	self.CfgData = CfgData
	self.Text:SetText(Name or "null")
	self.ToggleIndex = Index
	self.Ptr = Ptr
	self.OnStateChecked = Callback
	UIUtil.SetIsVisible(self.Checked, false)
	self.State = false
	self.SaveKey = SaveKey
end

function CfgToggleButtonView:GetIndex()
	return self.ToggleIndex
end

function CfgToggleButtonView:OnToggleGroupStateChanged(bEqual)
	if bEqual == true then
		if self.State == false then
			self.State = true
			UIUtil.SetIsVisible(self.Checked, true)
			--if self.Ptr then
			self.OnStateChecked(self.Ptr, self:GetIndex(), self.Text:GetText(), self.CfgData)
			self:SaveData(self:GetIndex())
		end
	else
		self.State = false
		UIUtil.SetIsVisible(self.Checked, false)
	end
end

function CfgToggleButtonView:SetToggleButtonChecked(bChecked, bBroadCast)
	UIUtil.SetIsVisible(self.Checked, bChecked)
	self.State = bChecked
	if bBroadCast and self.OnStateChecked then
		self.OnStateChecked(self.Ptr, self:GetIndex(), self.Text:GetText(), self.CfgData)
	end
end

function CfgToggleButtonView:SaveData(Data)
	if self.SaveKey then
		_G.UE.USaveMgr.SetInt(self.SaveKey, Data, false)
	end
end

return CfgToggleButtonView
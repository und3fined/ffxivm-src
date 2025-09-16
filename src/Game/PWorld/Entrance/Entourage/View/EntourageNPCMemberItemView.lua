---
--- Author: Administrator
--- DateTime: 2023-12-18 19:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class EntourageNPCMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNPCAppearance UFImage
---@field ImgNPCJobBg UFImage
---@field ImgPlayerJob UFImage
---@field TextNPCInfo UFTextBlock
---@field TextNPCName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EntourageNPCMemberItemView = LuaClass(UIView, true)

function EntourageNPCMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNPCAppearance = nil
	--self.ImgNPCJobBg = nil
	--self.ImgPlayerJob = nil
	--self.TextNPCInfo = nil
	--self.TextNPCName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EntourageNPCMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EntourageNPCMemberItemView:OnInit()
	self.Binders = {
		{ "Name", 						UIBinderSetText.New(self, self.TextNPCName) },
		{ "ProfName", 					UIBinderSetText.New(self, self.TextNPCInfo) },
		-- { "Lv", 						UIBinderSetText.New(self, self.TextNPCName) },
		----------------------------------------------------------------------------------
		{ "ProfIcon", 					UIBinderSetBrushFromAssetPath.New(self, self.ImgPlayerJob) },
		{ "Portrait", 					UIBinderSetBrushFromAssetPath.New(self, self.ImgNPCAppearance) },
		{ "BGRes", 						UIBinderSetBrushFromAssetPath.New(self, self.ImgNPCJobBg) },
	}
end

function EntourageNPCMemberItemView:OnDestroy()

end

function EntourageNPCMemberItemView:OnShow()

end

function EntourageNPCMemberItemView:OnHide()

end

function EntourageNPCMemberItemView:OnRegisterUIEvent()

end

function EntourageNPCMemberItemView:OnRegisterGameEvent()

end

function EntourageNPCMemberItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	self.VM = self.Params.Data
	if nil == self.VM then
		return
	end
	
	self:RegisterBinders(self.VM,               self.Binders)
end

return EntourageNPCMemberItemView
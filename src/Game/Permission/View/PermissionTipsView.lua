---
--- Author: richyczhou
--- DateTime: 2025-05-01 15:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PermissionTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field TextDescribe UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PermissionTipsView = LuaClass(UIView, true)

function PermissionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.TextDescribe = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PermissionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PermissionTipsView:OnInit()

end

function PermissionTipsView:OnDestroy()

end

function PermissionTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	_G.FLOG_INFO("[PermissionTipsView:OnShow]")

	self.TextDescribe:SetText(Params.TipsStr)
	self.SourcePath = Params.SourcePath
end

function PermissionTipsView:OnHide()

end

function PermissionTipsView:OnRegisterUIEvent()

end

function PermissionTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.MicPermissionNotify, self.OnMicPermissionNotify)
	self:RegisterGameEvent(_G.EventID.StoragePermissionNotify, self.OnStoragePermissionNotify)

end

function PermissionTipsView:OnRegisterBinder()

end

function PermissionTipsView:OnMicPermissionNotify()
	_G.FLOG_INFO("[PermissionTipsView:OnMicPermissionNotify]")
	self:Hide()
end

function PermissionTipsView:OnStoragePermissionNotify(Result)
	_G.FLOG_INFO("[PermissionTipsView:OnStoragePermissionNotify]")
	self:Hide()
	if Result then
		_G.CommonUtil.SaveToGallery(self.SourcePath)
		_G.MsgTipsUtil.ShowTipsByID(172022)
	end
end

return PermissionTipsView
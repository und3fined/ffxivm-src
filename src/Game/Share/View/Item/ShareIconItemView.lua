--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-13 19:23:03
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 14:56:29
FilePath: \Script\Game\Share\View\Item\ShareIconItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ShareMgr = require("Game/Share/ShareMgr")

---@class ShareIconItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnIcon UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShareIconItemView = LuaClass(UIView, true)

function ShareIconItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShareIconItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShareIconItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnIcon, self.OnBtnClick, nil)
end

function ShareIconItemView:OnRegisterBinder()
	self.ViewModel = self.Params and self.Params.Data or nil
	if self.ViewModel then
		self:SetImage(self.ViewModel.Icon)
	end
end

function ShareIconItemView:OnBtnClick()
	local ShareObj = self:GetShareObject()
	if ShareObj == nil then
		return
	end
	
	if ShareMgr.IsImageShareObject(ShareObj) then
		ShareMgr:ShareImage(self.ViewModel.ShareObject)
	elseif ShareMgr.IsExtearnalLinkShareObject(ShareObj) then
		ShareMgr:ShareExternalLinkByShareObject(ShareObj)
	end
end

---@return ShareObject
function ShareIconItemView:GetShareObject()
	return self.ViewModel and self.ViewModel.ShareObject or nil
end

return ShareIconItemView
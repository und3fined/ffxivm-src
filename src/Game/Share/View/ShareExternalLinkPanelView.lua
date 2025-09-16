--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-12 20:11:21
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-17 16:20:23
FilePath: \Script\Game\Share\View\ShareExternalLinkPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class ShareExternalLinkPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field TableViewIcon UTableView
---@field TextHint UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShareExternalLinkPanelView = LuaClass(UIView, true)

function ShareExternalLinkPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.TableViewIcon = nil
	--self.TextHint = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShareExternalLinkPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShareExternalLinkPanelView:OnInit()
	self.ShareItemTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewIcon)
	self.Binders = {
		{"ExternalLinkShareItemList", UIBinderUpdateBindableList.New(self, self.ShareItemTableView)},
	}
	self.TextHint:SetText(_G.LSTR(1460003))
end

function ShareExternalLinkPanelView:OnRegisterBinder()
	if _G.ShareVM then
		self:RegisterBinders(_G.ShareVM, self.Binders)
	end
end

return ShareExternalLinkPanelView
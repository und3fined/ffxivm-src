---
--- Author: Administrator
--- DateTime: 2025-03-17 20:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local WorldExploraVM = require("Game/WorldExplora/WorldExploraVM")

---@class WorldExploraMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityPanel WorldExploraActivityPanelView
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field ExploraPanel WorldExploraExploraPanelView
---@field SelectionPanel WorldExploraSelectionPanelView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraMainView = LuaClass(UIView, true)

function WorldExploraMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityPanel = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.ExploraPanel = nil
	--self.SelectionPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityPanel)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.ExploraPanel)
	self:AddSubView(self.SelectionPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraMainView:OnInit()

end

function WorldExploraMainView:OnDestroy()

end

function WorldExploraMainView:OnShow()
	_G.TouringBandMgr:QueryCollectionReq()
end

function WorldExploraMainView:OnHide()

end

function WorldExploraMainView:OnRegisterUIEvent()

end

function WorldExploraMainView:OnRegisterGameEvent()

end

function WorldExploraMainView:OnRegisterBinder()

end

--- @type 当下选框线选择改变
function WorldExploraMainView:OnSubTabSelectChange(index)
	local bActiviryVisible = index == 1
	UIUtil.SetIsVisible(self.ActivityPanel, bActiviryVisible)
	UIUtil.SetIsVisible(self.ExploraPanel, not bActiviryVisible)
end

return WorldExploraMainView
---
--- Author: Administrator
--- DateTime: 2025-03-18 14:11
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LSTR = _G.LSTR
---@class WorldExploraSelectionPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelBottom UFCanvasPanel
---@field TableViewTab UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraSelectionPanelView = LuaClass(UIView, true)

function WorldExploraSelectionPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelBottom = nil
	--self.TableViewTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraSelectionPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraSelectionPanelView:OnInit()
	self.TableAdapterTab = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChangedTab)
end

function WorldExploraSelectionPanelView:OnDestroy()

end

function WorldExploraSelectionPanelView:OnShow()
	local Data = {{Name = LSTR(1610001)}, {Name = LSTR(1610002)}} -- 活动  探索
	self.TableAdapterTab:UpdateAll(Data)
	self:SetDefaultSelectedIndex()
end

function WorldExploraSelectionPanelView:OnHide()

end

function WorldExploraSelectionPanelView:OnRegisterUIEvent()

end

function WorldExploraSelectionPanelView:OnRegisterGameEvent()
end

function WorldExploraSelectionPanelView:OnRegisterBinder()


	-- local DefaultIndex = _G.WorldExploraMgr:bSelectActivityModule() and 1 or 2
	-- self.TableAdapterTab:SetSelectedIndex(DefaultIndex)
end

function WorldExploraSelectionPanelView:OnSelectChangedTab(Index, ItemData, ItemView)
	self.ParentView:OnSubTabSelectChange(Index)

end

function WorldExploraSelectionPanelView:SetDefaultSelectedIndex()
	local DefaultIndex = _G.WorldExploraMgr:bSelectActivityModule() and 1 or 2
	self.TableAdapterTab:SetSelectedIndex(DefaultIndex)
end

return WorldExploraSelectionPanelView
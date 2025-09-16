---
--- Author: Administrator
--- DateTime: 2024-08-29 09:50
--- Description: 传送网使用券列表
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local AetheryteticketVM = require("Game/Aetheryteticket/AetheryteticketVM")

---@class WorldMapUsePortalPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field CommonTitle CommonTitleView
---@field ImgBkg UFImage
---@field ImgPattern UFImage
---@field PanelTop UFCanvasPanel
---@field Sidebar UFCanvasPanel
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapUsePortalPanelView = LuaClass(UIView, true)

function WorldMapUsePortalPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.CommonTitle = nil
	--self.ImgBkg = nil
	--self.ImgPattern = nil
	--self.PanelTop = nil
	--self.Sidebar = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapUsePortalPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapUsePortalPanelView:OnInit()
    self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)
	self.Binders = {
        {"AetheryteticketList", UIBinderUpdateBindableList.New(self, self.TableViewListAdapter)},
    }
	self.BtnBack:AddBackClick(self, self.HideSelf)
end

function WorldMapUsePortalPanelView:OnDestroy()

end

function WorldMapUsePortalPanelView:OnShow()
	local LSTR = _G.LSTR
	self.CommonTitle.TextTitleName:SetText(LSTR(290006)) -- 传送网使用券
end

function WorldMapUsePortalPanelView:OnHide()

end

function WorldMapUsePortalPanelView:OnRegisterUIEvent()

end

function WorldMapUsePortalPanelView:OnRegisterGameEvent()

end

function WorldMapUsePortalPanelView:OnRegisterBinder()
	self:RegisterBinders(AetheryteticketVM, self.Binders)
end

function WorldMapUsePortalPanelView:HideSelf()
	self:Hide()
end


return WorldMapUsePortalPanelView
---
--- Author: Administrator
--- DateTime: 2025-03-04 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local WardrobeTipsItem2VM = require("Game/Wardrobe/VM/Item/WardrobeTipsItem2VM")
local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class WardrobeTipsItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelGetWayTips UFCanvasPanel
---@field TableViewList UTableView
---@field TextGetWay UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeTipsItem2View = LuaClass(UIView, true)

function WardrobeTipsItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelGetWayTips = nil
	--self.TableViewList = nil
	--self.TextGetWay = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeTipsItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeTipsItem2View:OnInit()
	self.ProfAppListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.VM = WardrobeTipsItem2VM.New()

	self.Binders = {
		{"ProfAppList", UIBinderUpdateBindableList.New(self, self.ProfAppListAdapter)},
	}
end

function WardrobeTipsItem2View:OnDestroy()

end

function WardrobeTipsItem2View:OnShow()
	if self.Params == nil then
		return
	end
	local TargetView = self.Params.TargetView
	local Offset = self.Params.Offset
	local Alignment = self.Params.Alignment
	if self.Params.TargetView ~= nil and self.Params.Offset ~= nil and self.Params.Alignment then
		TipsUtil.AdjustTipsPosition(self.PanelGetWayTips, TargetView, Offset, Alignment)
	end

	self.TextGetWay:SetText(_G.LSTR(1080115)) -- 职业外观收集
	_G.WardrobeMgr:GetUnlockAppearanceCollectNum(0, true)
	self.VM:UpdateProfAppList()

	self.CommonPopUpBG:SetHideOnClick(true)
end

function WardrobeTipsItem2View:OnHide()

end

function WardrobeTipsItem2View:OnRegisterUIEvent()
end

function WardrobeTipsItem2View:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WardrobeTipsItem2View:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function WardrobeTipsItem2View:OnPreprocessedMouseButtonDown(MouseEvent)
	-- local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	-- if UIUtil.IsUnderLocation(self.PanelGetWayTips, MousePosition) == false then
	-- 	UIViewMgr:HideView(UIViewID.WardrobeProfAppListWin)
	-- end
end

return WardrobeTipsItem2View
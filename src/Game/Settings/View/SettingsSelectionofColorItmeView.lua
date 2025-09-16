---
--- Author: xingcaicao
--- DateTime: 2024-01-31 11:04
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

-- TODO(loiafeng): 更通用的颜色表格
local ActorUIColorCfg = require("TableCfg/ActorUiColorCfg")

---@class SettingsSelectionofColorItmeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CloseBtn CommonCloseBtnView
---@field CommonMask CommonMaskPanelView
---@field TableViewColorItems UTableView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsSelectionofColorItmeView = LuaClass(UIView, true)

function SettingsSelectionofColorItmeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CloseBtn = nil
	--self.CommonMask = nil
	--self.TableViewColorItems = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsSelectionofColorItmeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonMask)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsSelectionofColorItmeView:OnInit()
	self.AdapterColor = UIAdapterTableView.CreateAdapter(self, self.TableViewColorItems, self.OnSelectChangedColor)
	self.ColorID = 0
end

function SettingsSelectionofColorItmeView:OnDestroy()

end

function SettingsSelectionofColorItmeView:OnShow()
	self.AdapterColor:UpdateAll(ActorUIColorCfg:FindAllCfg())
	self.AdapterColor:SetSelectedIndex(self.ColorID + 1)  -- TableView的Index从1开始
	self.FTextBlock_60:SetText(_G.LSTR(110040))	--选择颜色
end

function SettingsSelectionofColorItmeView:OnHide()

end

function SettingsSelectionofColorItmeView:OnRegisterUIEvent()
	self.CloseBtn:SetCallback(self, self.OnClickButtonClose)
	self.CommonMask:SetOnPressedCallback(self, self.OnClickButtonClose)
end

function SettingsSelectionofColorItmeView:OnRegisterGameEvent()

end

function SettingsSelectionofColorItmeView:OnRegisterBinder()

end

function SettingsSelectionofColorItmeView:ShowPanel(ColorID, Obj, Callback)
	self.ColorID = ColorID or 0
	self.CallbackObj = Obj
	self.CallbackFunc = Callback

	UIUtil.SetIsVisible(self, true)
end

function SettingsSelectionofColorItmeView:OnClickButtonClose()
	if self.CallbackObj and _G.CommonUtil.IsObjectValid(self.CallbackObj) and self.CallbackFunc then
		self.CallbackFunc(self.CallbackObj, self.ColorID)
	end

	UIUtil.SetIsVisible(self, false)
end

function SettingsSelectionofColorItmeView:OnSelectChangedColor(Index, ItemData, ItemView)
	self.ColorID = Index - 1  -- TableView的Index从1开始
end

return SettingsSelectionofColorItmeView
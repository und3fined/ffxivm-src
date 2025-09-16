---
--- Author: xingcaicao
--- DateTime: 2023-03-20 21:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LSTR = _G.LSTR
---@class SettingsColorWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnOK CommBtnLView
---@field TableViewColor UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsColorWinView = LuaClass(UIView, true)

function SettingsColorWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnOK = nil
	--self.TableViewColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsColorWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOK)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsColorWinView:OnInit()
	self.AdapterColor = UIAdapterTableView.CreateAdapter(self, self.TableViewColor, self.OnSelectChangedColor)
end

function SettingsColorWinView:OnDestroy()

end

function SettingsColorWinView:OnShow()
	self.AdapterColor:UpdateAll(SettingsDefine.ColorList)

	if self.Params ~= nil then
		self.ColorIndex = self:GetIndex(self.Params.Color)
		self.AdapterColor:SetSelectedIndex(self.ColorIndex)
	end
	
	self.BG:SetTitleText(LSTR(110045))	--颜色设置
	self.BtnOK:SetBtnName(LSTR(110032))
	self.BtnCancel:SetBtnName(LSTR(110021))
end

function SettingsColorWinView:OnHide()

end

function SettingsColorWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnClickButtonOK)
end

function SettingsColorWinView:OnRegisterGameEvent()

end

function SettingsColorWinView:OnRegisterBinder()

end

function SettingsColorWinView:OnClickButtonCancel()
	self:Hide(self.ViewID)
end

function SettingsColorWinView:OnClickButtonOK()
	local Color = SettingsDefine.ColorList[self.ColorIndex]
	if not string.isnilorempty(Color) and self.Params ~= nil then
		self.Params.Color = Color

		SettingsUtils.SetValue(self.Params.SetValueFunc, self.Params.SettingCfg, self.Params.ColorSaveKey, Color, true)
	end

	self:Hide(self.ViewID)
end

function SettingsColorWinView:OnSelectChangedColor(Index, ItemData, ItemView)
	self.ColorIndex = Index
end

function SettingsColorWinView:GetIndex( Color )
	if nil == Color then
		return 1
	end

	for k, v in ipairs(SettingsDefine.ColorList) do
		if Color == v then
			return k
		end
	end

	return 1
end

return SettingsColorWinView
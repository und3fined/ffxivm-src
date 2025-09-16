--[[
Author: jususchen jususchen@tencent.com
Date: 2024-08-06 20:21:48
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-08-06 20:26:19
FilePath: \Script\Game\PWorld\PWorldExplainWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class PWorldExplainWinView : UIView
---@field MenuVM CommHelpInfoWinLMenuVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field Menu CommMenuView
---@field PanelExplain UFCanvasPanel
---@field PanelSet UFCanvasPanel
---@field PanelSet01 UFCanvasPanel
---@field PanelSet02 UFCanvasPanel
---@field PanelSet03 UFCanvasPanel
---@field TableRows UTableView
---@field Text01 UFTextBlock
---@field Text02 URichTextBox
---@field Text03 UFTextBlock
---@field Text04 URichTextBox
---@field Text05 UFTextBlock
---@field Text06 URichTextBox
---@field TextLeader URichTextBox
---@field TextSet UFTextBlock
---@field TextTitle01 UFTextBlock
---@field TextTitle02 UFTextBlock
---@field TextTitle03 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldExplainWinView = LuaClass(UIView, true)

function PWorldExplainWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.Menu = nil
	--self.PanelExplain = nil
	--self.PanelSet = nil
	--self.PanelSet01 = nil
	--self.PanelSet02 = nil
	--self.PanelSet03 = nil
	--self.TableRows = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.Text05 = nil
	--self.Text06 = nil
	--self.TextLeader = nil
	--self.TextSet = nil
	--self.TextTitle01 = nil
	--self.TextTitle02 = nil
	--self.TextTitle03 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldExplainWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.Menu)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local ParseAndFill = function(Data, TextWidgets)
	if not (Data and Data.SecContent) then
		return
	end

	local Offset = #Data.SecContent - #TextWidgets
	if Offset >= 0 then
		for i = #TextWidgets, 1, -1 do
			local Content = Data.SecContent[i + Offset].SecContent or ""
			TextWidgets[i]:SetText(Content)
		end
	end
end

function PWorldExplainWinView:OnInit()
	self.MenuVM = require("Game/Common/Tips/VM/CommHelpInfoWinLMenuVM").New()
	self.AdapterContentList = UIAdapterTableView.CreateAdapter(self, self.TableRows)
	
	self.MenuBinders = {
		{"TableViewContentList", UIBinderUpdateBindableList.New(self, self.AdapterContentList)},
	}

	self.TextTitle01:SetText(_G.LSTR(1320203))
	self.TextTitle02:SetText(_G.LSTR(1320204))
	self.TextTitle03:SetText(_G.LSTR(1320205))
end

function PWorldExplainWinView:OnShow()
	if self.Params == nil then
		return
	end

	local TitleText = _G.LSTR(1320116)
	local bGroup = HelpInfoUtil.IsAGroupInfo(self.Params.HelpInfoID)
	local GroupParms = nil
	if bGroup then
		GroupParms = HelpInfoUtil.GetGroupMenuParams(self.Params.HelpInfoID)
		if GroupParms then
			self.MenuVM:InitVM(GroupParms)
			self.Menu:UpdateItems(GroupParms.MenuList)
			TitleText = GroupParms.Title
		end
	else
		self.Menu:UpdateItems({
			{
				Key = 1,
				Name = LSTR(1320116),
			},
		}, false)
	end

	self.BG.FText_Title:SetText(TitleText)
	
	UIUtil.SetIsVisible(self.PanelExplain, false)
	self.Menu:SetSelectedIndex(1)

	local EntCfg = require("TableCfg/SceneEnterCfg"):FindCfgByKey(self.Params.EntID)
	if EntCfg then
		UIUtil.SetIsVisible(self.PanelSet01, EntCfg.HasNormal == 1)
		UIUtil.SetIsVisible(self.PanelSet02, EntCfg.HasChallenge == 1)
		UIUtil.SetIsVisible(self.PanelSet03, EntCfg.HasUnlimited == 1)
	end

	local FirstID = self.Params.HelpInfoID
	if bGroup then
		local HelpGroupCfg = require("TableCfg/HelpGroupCfg")
		local GroupCfg = HelpGroupCfg:FindCfgByKey(self.Params.HelpInfoID)
		FirstID = GroupCfg and GroupCfg.HID[1] or nil
	end
	local HelpCfgs = require("TableCfg/HelpCfg"):FindAllHelpIDCfg(FirstID)
	
    if #HelpCfgs == 0 then
        return
    end

    if HelpCfgs[1].Type == nil then
        return
    end

	local HelpInfoUtil = require("Utils/HelpInfoUtil")

    local HCfgData = HelpInfoUtil.ParseContent(HelpCfgs)
	
	if HCfgData[1] then
		local HeadContent = HCfgData[1].SecContent and HCfgData[1].SecContent[1] and HCfgData[1].SecContent[1].SecContent or ""
		local HeadTitle = HCfgData[1].SecContent and HCfgData[1].SecContent[1] and HCfgData[1].SecContent[1].TitleName or ""
		self.TextSet:SetText(HeadTitle)
		self.TextLeader:SetText(HeadContent)
	end

	ParseAndFill(HCfgData[2], {self.Text01, self.Text02})
	ParseAndFill(HCfgData[3], {self.Text03, self.Text04})
	ParseAndFill(HCfgData[4], {self.Text05, self.Text06})
end

function PWorldExplainWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnMenuSelect)
end

function PWorldExplainWinView:OnMenuSelect(Index)
	if Index == 1 then
		UIUtil.SetIsVisible(self.PanelExplain, false)
		UIUtil.SetIsVisible(self.PanelSet, true)
	else
		UIUtil.SetIsVisible(self.PanelExplain, true)
		UIUtil.SetIsVisible(self.PanelSet, false)
		self.MenuVM:UpdateContentList(Index)
	end

	if #(self.MenuVM.MenuList or {}) > 1 then
		self.BG.FText_Title:SetText(self.MenuVM.MenuList[Index].Name)
	end
end

function PWorldExplainWinView:OnRegisterBinder()
	self:RegisterBinders(self.MenuVM, self.MenuBinders)
end

return PWorldExplainWinView
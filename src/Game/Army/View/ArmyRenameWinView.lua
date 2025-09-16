---
--- Author: Administrator
--- DateTime: 2023-12-06 16:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterToggleGroup = require("UI/Adapter/UIAdapterToggleGroup")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetCheckedIndex = require("Binder/UIBinderSetCheckedIndex")
local ArmyRenameWinVM = require("Game/Army/VM/ArmyRenameWinVM")
local UTF8Util = require("Utils/UTF8Util")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local MAX_NAME_LENGTH = 6
local ArmyMgr = nil
local ArmyDepotPageVM = nil
local ArmyDefine = require("Game/Army/ArmyDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

---@class ArmyRenameWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRename CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field InputBox CommInputBoxView
---@field TextDefault UFTextBlock
---@field TextNew UFTextBlock
---@field ToggleGroupDynamic UToggleGroupDynamic
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRenameWinView = LuaClass(UIView, true)

function ArmyRenameWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRename = nil
	--self.Comm2FrameM_UIBP = nil
	--self.InputBox = nil
	--self.TextDefault = nil
	--self.TextNew = nil
	--self.ToggleGroupDynamic = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRenameWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRename)
	self:AddSubView(self.Comm2FrameM_UIBP)
	self:AddSubView(self.InputBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRenameWinView:OnInit()
	self.AdapterTabToggleGroup = UIAdapterToggleGroup.CreateAdapter(self, self.ToggleGroupDynamic)
	ArmyRenameWinVM:UpdateListInfo()
	ArmyMgr = require("Game/Army/ArmyMgr")
	local ArmyDepotPanelVM = ArmyMainVM:GetDepotPanelVM()
    ArmyDepotPageVM = ArmyDepotPanelVM:GetDepotPageVM()
	local Value = GroupGlobalCfg:GetValueByType(ArmyDefine.GlobalCfgType.GroupStoreNameCategoryMax)
	MAX_NAME_LENGTH = Value or 6
	self.InputBox:SetMaxNum(MAX_NAME_LENGTH)
	self.InputBox:SetCallback(self , nil, self.CommittedCallback)
	self.Binders = {
		{ "DepotIconBindableList", UIBinderUpdateBindableList.New(self, self.AdapterTabToggleGroup) },
		{ "CurrentIndex", UIBinderSetCheckedIndex.New(self, self.ToggleGroupDynamic) },
	}
end

function ArmyRenameWinView:OnDestroy()

end

function ArmyRenameWinView:OnShow()
	self.InputBox:SetText(ArmyDepotPageVM.PageName)
	-- LSTR string:储物柜改名
	self.Comm2FrameM_UIBP:SetTitleText(LSTR(910318))
	-- LSTR string:默认
	self.TextDefault:SetText(LSTR(910276))
	-- LSTR string:输入新储物柜的名字
	self.TextNew:SetText(LSTR(910319))

	local ViewModel = ArmyDepotPageVM:FindDepotPageVM(ArmyDepotPageVM.CurrentPage)
	if nil ~= ViewModel then
		local Index = ViewModel.PageType
		ArmyRenameWinVM:SetSelectedIndex(Index)
	end
	
	-- LSTR string:更  改
	self.BtnRename:SetText(LSTR(910157))
end


function ArmyRenameWinView:OnHide()

end


function ArmyRenameWinView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupDynamic, self.OnToggleGroupStateChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnRename, self.OnClickedRename)
end

function ArmyRenameWinView:OnRegisterGameEvent()
end

function ArmyRenameWinView:OnRegisterBinder()
	self:RegisterBinders(ArmyRenameWinVM, self.Binders)
end

function ArmyRenameWinView:OnToggleGroupStateChanged(ToggleGroup, ToggleButton, Index, State)
	ArmyRenameWinVM:SetSelectedIndex(Index + 1)
end

function ArmyRenameWinView:OnClickedRename()
	local Index = ArmyDepotPageVM:GetCurDepotIndex()
	local Name = self.InputBox:GetText()
	---查询文本是否合法（敏感词）
	ArmyMgr:CheckSensitiveText(Name, function( IsLegal )
		if IsLegal then
			ArmyMgr:SendGroupStoreSetStoreName(Index, Name, ArmyRenameWinVM.CurrentIndex)
			self:Hide()
		else
			-- LSTR string:当前文本不可使用，请重新输入
			MsgTipsUtil.ShowErrorTips(LSTR(10057))
        end
    end)
end

function ArmyRenameWinView:CommittedCallback(Text)
	self:CheckRenameBtnState(Text)
end

function ArmyRenameWinView:CheckRenameBtnState(Text)
	if "" == Text then
		self.BtnRename:SetIsEnabled(false, false)
	else
		self.BtnRename:SetIsEnabled(true, true)

	end
end

-- function ArmyRenameWinView:OnTextChangedName(Text)
-- 	local Length = UTF8Util.Len(Text)
-- 	if Length > MAX_NAME_LENGTH then
-- 		Length = MAX_NAME_LENGTH
-- 		self.InputBox:SetText(UTF8Util.Sub(Text, 0, MAX_NAME_LENGTH))
-- 	end

-- 	local Color = Length >= MAX_NAME_LENGTH and "d05758ff" or "7d7e7fff"
-- 	UIUtil.TextBlockSetColorAndOpacityHex(self.InputBox.TextNumber, Color)

-- 	local TextNumber = string.format("%d/%d", Length, MAX_NAME_LENGTH)
-- 	self.InputBox.RichTextNumber:SetText(TextNumber)
-- end

return ArmyRenameWinView
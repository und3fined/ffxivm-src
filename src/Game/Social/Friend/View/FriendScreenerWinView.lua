---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local FriendVM = require("Game/Social/Friend/FriendVM")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local FriendScreenProfItemVM = require("Game/Social/Friend/VM/FriendScreenProfItemVM")
local FriendScreenStyleItemVM = require("Game/Social/Friend/VM/FriendScreenStyleItemVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local GameStyleCfg = require("TableCfg/GameStyleCfg")

local LSTR = _G.LSTR
local ScreenTabType = FriendDefine.ScreenTabType
local ProfClassType = ProtoCommon.class_type

---@class FriendScreenerWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnReset CommBtnLView
---@field BtnSure CommBtnLView
---@field CommMenu CommMenuView
---@field PanelPlayStyle UFCanvasPanel
---@field PanelProf UFCanvasPanel
---@field TableViewPlayStyle UTableView
---@field TableViewProf UTableView
---@field TextStyle UFTextBlock
---@field AnimChangeMenu UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendScreenerWinView = LuaClass(UIView, true)

function FriendScreenerWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnReset = nil
	--self.BtnSure = nil
	--self.CommMenu = nil
	--self.PanelPlayStyle = nil
	--self.PanelProf = nil
	--self.TableViewPlayStyle = nil
	--self.TableViewProf = nil
	--self.TextStyle = nil
	--self.AnimChangeMenu = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendScreenerWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnReset)
	self:AddSubView(self.BtnSure)
	self:AddSubView(self.CommMenu)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendScreenerWinView:OnInit()
	self.TableAdapterProf = UIAdapterTableView.CreateAdapter(self, self.TableViewProf)
	self.TableAdapterPlayStyle = UIAdapterTableView.CreateAdapter(self, self.TableViewPlayStyle, self.OnSelectChangedPlayStyle, true)

	self.ProfVMList = UIBindableList.New(FriendScreenProfItemVM) 
	self.StyleVMList = UIBindableList.New(FriendScreenStyleItemVM) 

	self.Bg:SetTitleText(LSTR(10007)) -- "筛选器"
	self.BtnReset:SetButtonText(LSTR(10008)) -- "重  置"
	self.BtnSure:SetButtonText(LSTR(30068)) -- "确认筛选"
	self.TextStyle:SetText(LSTR(30061)) -- "游戏风格"
end

function FriendScreenerWinView:OnDestroy()

end

function FriendScreenerWinView:OnShow()

	self.CurKey = nil
	self.CommMenu:UpdateItems(FriendDefine.ScreenTabs, false)
	self.CommMenu:SetSelectedKey(ScreenTabType.Prof)
end

function FriendScreenerWinView:OnHide()
	self.CommMenu:CancelSelected()
	self.ProfVMList:Clear()
	self.StyleVMList:Clear()
end

function FriendScreenerWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)

	UIUtil.AddOnClickedEvent(self, self.Bg.ButtonClose, self.OnClickButtonClose)
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickButtonReset)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, self.OnClickButtonSure)
end

function FriendScreenerWinView:OnRegisterGameEvent()

end

function FriendScreenerWinView:OnRegisterBinder()

end

function FriendScreenerWinView:GetProfData()
	local GetProfCfgListByClass = function(ProfClass)
		local CfgList = RoleInitCfg:GetOpenProfCfgListByClass(ProfClass) or {}
		return CfgList
	end

	local GetAttackCfgList = function()
		local CfgList = RoleInitCfg:GetAttackProfCfgList() or {}
		return CfgList
	end

	local Ret = {
		{
			Name = LSTR(30056), --"防护职业"
			Icon = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_Friend_Icon_Job_01_png.UI_Friend_Icon_Job_01_png'", 
			CfgList = GetProfCfgListByClass(ProfClassType.CLASS_TYPE_TANK),
		},
		{
			Name = LSTR(30057), --"治疗职业"
			Icon = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_Friend_Icon_Job_02_png.UI_Friend_Icon_Job_02_png'",
			CfgList = GetProfCfgListByClass(ProfClassType.CLASS_TYPE_HEALTH),
		},
		{
			Name = LSTR(30058), --"进攻职业"
			Icon = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_Friend_Icon_Job_03_png.UI_Friend_Icon_Job_03_png'",
			CfgList = GetAttackCfgList(),
		},
		{
			Name = LSTR(30059), --"能工巧匠"
			Icon = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_Friend_Icon_Job_04_png.UI_Friend_Icon_Job_04_png'",
			CfgList = GetProfCfgListByClass(ProfClassType.CLASS_TYPE_CARPENTER),
		},
		{
			Name = LSTR(30060), --"大地使者"
			Icon = "PaperSprite'/Game/UI/Atlas/NewFriend/Frames/UI_Friend_Icon_Job_05_png.UI_Friend_Icon_Job_05_png'",
			CfgList = GetProfCfgListByClass(ProfClassType.CLASS_TYPE_EARTHMESSENGER),
		},
	}

	return Ret
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function FriendScreenerWinView:OnSelectionChangedCommMenu(_, ItemData)
	if nil == ItemData then
		return
	end

	local Key = ItemData:GetKey()
	if Key == self.CurKey then
		return
	end

	self.CurKey = Key

	local PanelProfVisible = false
	local PanelStyleVisible = false

	if Key == ScreenTabType.Prof then
		PanelProfVisible = true 

		if self.ProfVMList:Length() <= 0 then
			local Data = self:GetProfData()
			self.ProfVMList:UpdateByValues(Data)
			self.TableAdapterProf:UpdateAll(self.ProfVMList)
		end

	elseif Key == ScreenTabType.PlayStyle then
		PanelStyleVisible = true 

		if self.StyleVMList:Length() <= 0 then
			local Data = GameStyleCfg:GetGameStyleList() or {}
			self.StyleVMList:UpdateByValues(Data)
			self.TableAdapterPlayStyle:UpdateAll(self.StyleVMList)
		end
	end

	UIUtil.SetIsVisible(self.PanelProf, PanelProfVisible)
	UIUtil.SetIsVisible(self.PanelPlayStyle, PanelStyleVisible)

	-- 播放动效
	self:PlayAnimation(self.AnimChangeMenu)
end

function FriendScreenerWinView:OnSelectChangedPlayStyle(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local ID = ItemData.ID
	if ID then
		FriendVM:UpdatePlayStyleScreen(ID)
	end
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendScreenerWinView:OnClickButtonClose()
	FriendVM:ClearFindScreenData()
end

function FriendScreenerWinView:OnClickButtonReset()
	FriendVM:ResetFindScreenData()
end

function FriendScreenerWinView:OnClickButtonSure()
	-- 在 FriendAddPanelView:OnSelectionChangedDropDownList 函数中调用查询函数
	EventMgr:SendEvent(EventID.FriendAddResetDefaultState)
	self:Hide()
end

return FriendScreenerWinView
---
--- Author: xingcaicao
--- DateTime: 2024-07-20 17:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local UIBindableList = require("UI/UIBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellActivityVM = require("Game/Social/LinkShell/VM/LinkShellActivityVM")
local LinkshellCfg = require("TableCfg/LinkshellCfg")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR
local MaxScreenActNum = LinkShellDefine.MaxScreenActNum

local ACT_TITLE_PRE_STR = LSTR(40110) -- "偏好筛选"

---@class LinkShellScreenerWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnReset CommBtnLView
---@field BtnSure CommBtnLView
---@field TableViewActivity UTableView
---@field TextActTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellScreenerWinView = LuaClass(UIView, true)

function LinkShellScreenerWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnReset = nil
	--self.BtnSure = nil
	--self.TableViewActivity = nil
	--self.TextActTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellScreenerWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnReset)
	self:AddSubView(self.BtnSure)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellScreenerWinView:OnInit()
	self.TableAdapterActivity = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity, self.OnSelectChangedActivity, true)
	self.AllActVMList = UIBindableList.New(LinkShellActivityVM) 
end

function LinkShellScreenerWinView:OnDestroy()

end

function LinkShellScreenerWinView:OnShow()
	self:InitConstText()

	-- 活动标题
	self:UpdateActTitle()

	-- 活动列表
	local CfgList = LinkshellCfg:GetActList() or {}
	self.AllActVMList:UpdateByValues(CfgList)
	self.TableAdapterActivity:UpdateAll(self.AllActVMList)
end

function LinkShellScreenerWinView:OnHide()
	self.AllActVMList:Clear()
    LinkShellVM:UpdateIsScreeningState()
end

function LinkShellScreenerWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickButtonReset)
	UIUtil.AddOnClickedEvent(self, self.BtnSure, self.OnClickButtonSure)
	UIUtil.AddOnClickedEvent(self, self.Bg.ButtonClose, self.OnClickCloseBtn)
end

function LinkShellScreenerWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellScreenActUpdate, self.OnGameEventScreenActUpdate)
end

function LinkShellScreenerWinView:OnRegisterBinder()

end

function LinkShellScreenerWinView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.Bg:SetTitleText(LSTR(10007)) -- "筛选器"
	self.BtnReset:SetBtnName(LSTR(10008)) -- "重  置"
	self.BtnSure:SetBtnName(LSTR(40109)) -- "确认筛选"
end
function LinkShellScreenerWinView:UpdateActTitle()
	local CurNum = #(LinkShellVM.ScreenActIDs or {})
	local Title = string.format("%s %d/%d", ACT_TITLE_PRE_STR, CurNum, MaxScreenActNum)
	self.TextActTitle:SetText(Title)
end

function LinkShellScreenerWinView:OnSelectChangedActivity(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	local ID = ItemData.ID
	if ID then
		LinkShellVM:UpdateScreenActIDs(ID)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellScreenerWinView:OnGameEventScreenActUpdate()
	self:UpdateActTitle()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellScreenerWinView:OnClickButtonClose()
	LinkShellVM:ResetFindScreenData()
end

function LinkShellScreenerWinView:OnClickButtonReset()
	LinkShellVM.ScreenActIDs = {}
    EventMgr:SendEvent(EventID.LinkShellScreenActUpdate)
end

function LinkShellScreenerWinView:OnClickButtonSure()
	local ActIDs = LinkShellVM.ScreenActIDs or {}
	if #ActIDs <= 0 then
        MsgTipsUtil.ShowTips(LSTR(40006)) -- "请选择主要活动偏好筛选"
		return
	end

	LinkShellMgr:SendSearchLinkShellByAct(ActIDs)

	self:Hide()
end

function LinkShellScreenerWinView:OnClickCloseBtn()
	LinkShellVM:ResetFindScreenData()
	self:Hide()
end

return LinkShellScreenerWinView
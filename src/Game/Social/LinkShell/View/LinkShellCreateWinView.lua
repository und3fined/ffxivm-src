---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local LinkShellActivityVM = require("Game/Social/LinkShell/VM/LinkShellActivityVM")
local LinkshellCfg = require("TableCfg/LinkshellCfg")

local LSTR = _G.LSTR
local MaxActNum = LinkShellDefine.MaxActNum
local FromHex = _G.UE.FLinearColor.FromHex

local ACT_TITLE_PRE_STR = LSTR(40104) -- "通讯贝主要活动"

---@class LinkShellCreateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnCancel CommBtnLView
---@field BtnCreate CommBtnLView
---@field CommInforBtn CommInforBtnView
---@field CurrentMoneySlot CommMoneySlotView
---@field InputBox CommInputBoxView
---@field MoneyBar CommMoneySlotView
---@field TableViewActivity UTableView
---@field TextActTitle UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellCreateWinView = LuaClass(UIView, true)

function LinkShellCreateWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnCancel = nil
	--self.BtnCreate = nil
	--self.CommInforBtn = nil
	--self.CurrentMoneySlot = nil
	--self.InputBox = nil
	--self.MoneyBar = nil
	--self.TableViewActivity = nil
	--self.TextActTitle = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellCreateWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnCreate)
	self:AddSubView(self.CommInforBtn)
	self:AddSubView(self.CurrentMoneySlot)
	self:AddSubView(self.InputBox)
	self:AddSubView(self.MoneyBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellCreateWinView:OnInit()
	self.TableAdapterActivity = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity)

	self.AllActVMList = UIBindableList.New(LinkShellActivityVM) 
end

function LinkShellCreateWinView:OnDestroy()

end

function LinkShellCreateWinView:OnShow()
	self:InitConstText()

	self.InputBox:SetText("")
	self.InputBox:SetMaxNum(LinkshellDefineCfg:GetNameMaxLength())

	-- 主要活动
	local CfgList = LinkshellCfg:GetActList() or {}
	self.AllActVMList:UpdateByValues(CfgList)
	self.TableAdapterActivity:UpdateAll(self.AllActVMList)

	--创建花费
	local CostID, CostNum = LinkshellDefineCfg:GetCreateCost()
    self.MoneyBar:UpdateView(CostID, false)
	self.MoneyBar:SetMoneyNum(CostNum)
	self.MoneyBar:SetbForceNotUpdateVal(true)

	local CurNum = ScoreMgr:GetScoreValueByID(CostID)
	local LinearColor = CurNum >= CostNum and FromHex("D1BA8EFF") or FromHex("DC5868FF")
    self.MoneyBar:SetTextMoneyColorAndOpacity(LinearColor)

	-- 当前货币信息
    self.CurrentMoneySlot:UpdateView(CostID, false, nil, true)

	self:UpdateActTitle()
end

function LinkShellCreateWinView:OnHide()
	LinkShellVM.CreateSelectedActIDs = {} 
	self.AllActVMList:Clear()
end

function LinkShellCreateWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnCreate, self.OnClickButtonCreate)
    UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
end

function LinkShellCreateWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellCreateSelectedActIDsUpdate, self.OnGameEventSelectedActIDsUpdate)
end

function LinkShellCreateWinView:OnRegisterBinder()

end

function LinkShellCreateWinView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.Bg:SetTitleText(LSTR(40045)) -- "创建通讯贝"
	self.TextName:SetText(LSTR(40046)) -- "通讯贝"
	self.InputBox:SetHintText(LSTR(40047)) -- "请输入通讯贝名称"
	self.BtnCancel:SetBtnName(LSTR(10003)) -- "取 消"
	self.BtnCreate:SetBtnName(LSTR(40053)) -- "确定创建"
end

function LinkShellCreateWinView:UpdateActTitle()
	local CurNum = #(LinkShellVM.CreateSelectedActIDs or {})
	local Title = string.format("%s %d/%d", ACT_TITLE_PRE_STR, CurNum, MaxActNum)
	self.TextActTitle:SetText(Title)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellCreateWinView:OnGameEventSelectedActIDsUpdate( )
	self:UpdateActTitle()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellCreateWinView:OnClickButtonCreate()
	local LinkShellName = self.InputBox:GetText()
	if string.isnilorempty(LinkShellName) then
		MsgTipsUtil.ShowTips(LSTR(40054)) -- "通讯贝名称不可为空！"
		return
	end

	local CostID, CostNum = LinkshellDefineCfg:GetCreateCost()
	local CurScoreNum = ScoreMgr:GetScoreValueByID(CostID)
	if CostNum > CurScoreNum then
		local CostName = ScoreMgr:GetScoreNameText(CostID) or ""
		-- "当前%s不足"
		MsgTipsUtil.ShowTips(string.format(LSTR(10009), CostName))
		return
	end

	LinkShellMgr:SendMsgCreateLinkShellReq(LinkShellName, LinkShellVM.CreateSelectedActIDs or {})
end

function LinkShellCreateWinView:OnClickButtonCancel()
	self:Hide()
end

return LinkShellCreateWinView
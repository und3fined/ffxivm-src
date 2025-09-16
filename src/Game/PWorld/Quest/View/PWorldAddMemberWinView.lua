---
--- Author: v_hggzhang
--- DateTime: 2023-05-16 17:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PWorldQuestMgr
local PWorldMgr
local PWorldTeamMgr
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local FUNCTION_TYPE = ProtoCommon.function_type
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
---@class PWorldAddMemberWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnOK CommBtnLView
---@field DPanel UFHorizontalBox
---@field HorizonBox UFHorizontalBox
---@field PanelFangHu UFCanvasPanel
---@field PanelJinGong UFCanvasPanel
---@field PanelZhiLiao UFCanvasPanel
---@field TPanel UFHorizontalBox
---@field TextAdd UFTextBlock
---@field TextFangHu UFTextBlock
---@field TextJinGong UFTextBlock
---@field TextZhiLiao UFTextBlock
---@field nPanel UFHorizontalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldAddMemberWinView = LuaClass(UIView, true)

function PWorldAddMemberWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnOK = nil
	--self.DPanel = nil
	--self.HorizonBox = nil
	--self.PanelFangHu = nil
	--self.PanelJinGong = nil
	--self.PanelZhiLiao = nil
	--self.TPanel = nil
	--self.TextAdd = nil
	--self.TextFangHu = nil
	--self.TextJinGong = nil
	--self.TextZhiLiao = nil
	--self.nPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldAddMemberWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnOK)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldAddMemberWinView:OnInit()
	PWorldQuestMgr = _G.PWorldQuestMgr
    PWorldMgr = _G.PWorldMgr
    PWorldTeamMgr = _G.PWorldTeamMgr

	self.ProfDict = {
		[FUNCTION_TYPE.FUNCTION_TYPE_RECOVER] = {
			Text = self.TextZhiLiao,
			Panel = self.NPanel,
		},
    	[FUNCTION_TYPE.FUNCTION_TYPE_GUARD] = {
			Text = self.TextFangHu,
			Panel = self.TPanel,
		},
    	[FUNCTION_TYPE.FUNCTION_TYPE_ATTACK] = {
			Text = self.TextJinGong,
			Panel = self.DPanel,
		},
	}

	self.BG:SetTitleText(_G.LSTR(1320182))
	self.TextAdd:SetText(_G.LSTR(1320183))
	self.BtnCancel:SetBtnName(_G.LSTR(1320184))
	self.BtnOK:SetBtnName(_G.LSTR(1320185))
end

function PWorldAddMemberWinView:OnDestroy()

end

function PWorldAddMemberWinView:OnShow()
	self:UpdateMemProf()
end

function PWorldAddMemberWinView:OnHide()

end

function PWorldAddMemberWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, function()
        self:Hide()
	end)

	UIUtil.AddOnClickedEvent(self, self.BtnOK, function()
		PWorldTeamMgr:ReqStartAddMem()
        self:Hide()
	end)
end

function PWorldAddMemberWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PWorldTeamMemUpd, self.UpdateMemProf)
end

function PWorldAddMemberWinView:OnRegisterBinder()

end

function PWorldAddMemberWinView:UpdateMemProf()
	local MemIDList = PWorldTeamMgr:GetMemIDList()
	local PWorldID =  PWorldMgr:GetCurrPWorldResID()
    local MemProfFuncDict = PWorldEntUtil.GetMemProfFuncDict(MemIDList)
    local RequireProfDict = PWorldEntUtil.GetRequireMemProfFunc(PWorldID)

	for Ty, Info in pairs(self.ProfDict) do
		local Text = Info.Text
		local RequireCnt = RequireProfDict[Ty] or 0
		local MemCnt = MemProfFuncDict[Ty] or 0
		local Delta = RequireCnt - MemCnt
		local Str = string.format("%s/%s", tostring(0), tostring(Delta))
		Text:SetText(Str)
		UIUtil.SetIsVisible(Info.Panel, Delta > 0)
	end
end

return PWorldAddMemberWinView
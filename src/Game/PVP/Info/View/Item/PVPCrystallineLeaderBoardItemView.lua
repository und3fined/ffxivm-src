---
--- Author: Administrator
--- DateTime: 2025-07-03 11:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local PVPInfoMgr = _G.PVPInfoMgr

---@class PVPCrystallineLeaderBoardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommHead CommHeadView
---@field ImgBg UFImage
---@field ImgRank UFImage
---@field ImgRanking UFImage
---@field PanelNoInfo UFCanvasPanel
---@field PanelRank UFCanvasPanel
---@field PanelShowInfo UFCanvasPanel
---@field TableViewProf UTableView
---@field TableViewStar UTableView
---@field TextDescNoInfo UFTextBlock
---@field TextNoRank UFTextBlock
---@field TextRank UFTextBlock
---@field TextRanking UFTextBlock
---@field TextRankingNoInfo UFTextBlock
---@field TextRoleName UFTextBlock
---@field TextScore UFTextBlock
---@field TextWinCount UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineLeaderBoardItemView = LuaClass(UIView, true)

function PVPCrystallineLeaderBoardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommHead = nil
	--self.ImgBg = nil
	--self.ImgRank = nil
	--self.ImgRanking = nil
	--self.PanelNoInfo = nil
	--self.PanelRank = nil
	--self.PanelShowInfo = nil
	--self.TableViewProf = nil
	--self.TableViewStar = nil
	--self.TextDescNoInfo = nil
	--self.TextNoRank = nil
	--self.TextRank = nil
	--self.TextRanking = nil
	--self.TextRankingNoInfo = nil
	--self.TextRoleName = nil
	--self.TextScore = nil
	--self.TextWinCount = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineLeaderBoardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommHead)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineLeaderBoardItemView:OnInit()
	self.ProfList = UIAdapterTableView.CreateAdapter(self, self.TableViewProf)
	self.StarList = UIAdapterTableView.CreateAdapter(self, self.TableViewStar)
	self.Binders = {
		{ "Ranking", UIBinderSetText.New(self, self.TextRanking) },
		{ "RoleID", UIBinderValueChangedCallback.New(self, nil, self.OnRoleIDChanged) },
		{ "WinCount", UIBinderSetText.New(self, self.TextWinCount) },
		{ "ProfVMList", UIBinderUpdateBindableList.New(self, self.ProfList) },
		{ "StarVMList", UIBinderUpdateBindableList.New(self, self.StarList) },
		{ "IsScoreType", UIBinderValueChangedCallback.New(self, nil, self.OnIsScoreTypeChanged) },
		{ "RankingIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgRanking, nil, nil, true) },
		{ "RankIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgRank, nil, nil, true) },
		{ "BGIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBg) },
		{ "Ranking", UIBinderSetText.New(self, self.TextRankingNoInfo) },
		{ "NotShowInfoText", UIBinderSetText.New(self, self.TextDescNoInfo) },
		{ "IsShowInfo", UIBinderSetIsVisible.New(self, self.PanelShowInfo)},
		{ "IsShowInfo", UIBinderSetIsVisible.New(self, self.PanelNoInfo, true)},
		{ "IsRankNone", UIBinderValueChangedCallback.New(self, nil, self.OnIsRankNoneChanged) },
		{ "IsRankNone", UIBinderSetIsVisible.New(self, self.TextNoRank)},
		{ "IsRankNone", UIBinderSetIsVisible.New(self, self.PanelRank, true)},
	}
end

function PVPCrystallineLeaderBoardItemView:OnDestroy()

end

function PVPCrystallineLeaderBoardItemView:OnShow()

end

function PVPCrystallineLeaderBoardItemView:OnHide()

end

function PVPCrystallineLeaderBoardItemView:OnRegisterUIEvent()

end

function PVPCrystallineLeaderBoardItemView:OnRegisterGameEvent()

end

function PVPCrystallineLeaderBoardItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then return end

	local ViewModel = Params.Data
	if ViewModel == nil then return end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function PVPCrystallineLeaderBoardItemView:OnRoleIDChanged(NewValue, OldValue)
	if NewValue then
		local RoleInfoMgr = _G.RoleInfoMgr
		local RoleVM, IsValid = RoleInfoMgr:FindRoleVM(NewValue)
		if not IsValid then
			RoleInfoMgr:QueryRoleSimple(NewValue, function(Params, RoleVM)
				if RoleVM then
					self.TextRoleName:SetText(RoleVM.Name or "")
					self.CommHead:SetInfo(RoleVM.RoleID)
				end
			end)
		else
			self.TextRoleName:SetText(RoleVM and RoleVM.Name or "")
			self.CommHead:SetInfo(NewValue)
		end
	end
end

function PVPCrystallineLeaderBoardItemView:OnIsRankNoneChanged(NewValue, OldValue)
	local RankName = self.ViewModel and self.ViewModel.RankName
	if not NewValue then
		self.TextRank:SetText(RankName)
	else
		self.TextNoRank:SetText(RankName)
	end
end

function PVPCrystallineLeaderBoardItemView:OnIsScoreTypeChanged(NewValue, OldValue)
	UIUtil.SetIsVisible(self.TextScore, NewValue)
	UIUtil.SetIsVisible(self.TableViewStar, not NewValue)
end

return PVPCrystallineLeaderBoardItemView
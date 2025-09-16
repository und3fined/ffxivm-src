---
--- Author: Administrator
--- DateTime: 2024-12-24 15:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SavageRankTeamInfoWinVM = require("Game/SavageRank/View/SavageRankTeamInfoWinVM")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class SavageRankTeamInfoWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field ImgBadge UFImage
---@field ImgNormal UFImage
---@field TableViewTeamMateList UTableView
---@field TextClass UFTextBlock
---@field TextDate UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SavageRankTeamInfoWinView = LuaClass(UIView, true)

function SavageRankTeamInfoWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.ImgBadge = nil
	--self.ImgNormal = nil
	--self.TableViewTeamMateList = nil
	--self.TextClass = nil
	--self.TextDate = nil
	--self.TextNumber = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SavageRankTeamInfoWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SavageRankTeamInfoWinView:OnInit()
	self.ViewModel = SavageRankTeamInfoWinVM.New()
	self.TeamTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTeamMateList, self.OnTeamPlayerSelectChanged, true)
	self.Binders = {
		{ "RankNumber", UIBinderSetText.New(self, self.TextNumber) },
		{ "EquipLvText", UIBinderSetText.New(self, self.TextClass) },
		{ "TimeText", UIBinderSetText.New(self, self.TextTime) },	
		{ "DateText", UIBinderSetText.New(self, self.TextDate) },		
		{ "RankIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgBadge) },	
		{ "CurTeamList", UIBinderUpdateBindableList.New(self, self.TeamTableViewAdapter) },
		{ "ImgBadgeVisible", UIBinderSetIsVisible.New(self, self.ImgBadge) },
		{ "ImgNormalVisible", UIBinderSetIsVisible.New(self, self.ImgNormal) },	
	}
end

function SavageRankTeamInfoWinView:OnDestroy()

end

function SavageRankTeamInfoWinView:OnShow()
	if not self.Params then
		return
	end
	self.Info = {}
	self.Info.Lv = self.Params.Lv
	self.Info.Rank = self.Params.Rank
	self.Info.Time = self.Params.Time
	self.Info.TeamList = self.Params.TeamList
	self.Info.RankIcon = self.Params.RankIcon
	self.Info.PassDate = self.Params.PassDate
	self.Info.EquipLv = self.Params.EquipLv
	self:SetTitle()
	self.ViewModel:UpdateInfo(self.Info)
end

function SavageRankTeamInfoWinView:SetTitle()
	self.Comm2FrameL_UIBP:SetTitleText(_G.LSTR(1450014)) --队伍信息
	self.Text01:SetText(_G.LSTR(1450003))  --排名
	self.Text02:SetText(_G.LSTR(1450005))  --平均品级
	self.Text03:SetText(_G.LSTR(1450006))  --通关时长
	self.Text04:SetText(_G.LSTR(1450015))  --通关时间
end

function SavageRankTeamInfoWinView:OnHide()

end

function SavageRankTeamInfoWinView:OnRegisterUIEvent()

end

function SavageRankTeamInfoWinView:OnRegisterGameEvent()

end

function SavageRankTeamInfoWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function SavageRankTeamInfoWinView:OnTeamPlayerSelectChanged(Index, ItemData, ItemView)
	_G.PersonInfoMgr:ShowPersonalSimpleInfoView(ItemData.RoleID)
end

return SavageRankTeamInfoWinView
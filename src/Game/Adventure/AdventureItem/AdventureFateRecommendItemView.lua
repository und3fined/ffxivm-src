---
--- Author: Administrator
--- DateTime: 2025-08-15 11:36
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TeleportCrystalCfg = require("TableCfg/TeleportCrystalCfg")
local ProtoRes = require("Protocol/ProtoRes")

---@class AdventureFateRecommendItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGo CommBtnSView
---@field FateDes_Battle AdventureJobStateItemView
---@field FateDes_PlayerNum AdventureJobStateItemView
---@field ImgTextIcon UFImage
---@field TableViewReward UTableView
---@field TextPalace UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureFateRecommendItemView = LuaClass(UIView, true)

function AdventureFateRecommendItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGo = nil
	--self.FateDes_Battle = nil
	--self.FateDes_PlayerNum = nil
	--self.ImgTextIcon = nil
	--self.TableViewReward = nil
	--self.TextPalace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureFateRecommendItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.FateDes_Battle)
	self:AddSubView(self.FateDes_PlayerNum)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureFateRecommendItemView:OnInit()
	self.TableViewRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)

	self.Binders = {
		{"TextTitle", UIBinderSetText.New(self, self.TextPalace)},
		{"PlayerNum", UIBinderSetText.New(self, self.FateDes_PlayerNum.TextOngoing)},
		{"BattleDes", UIBinderSetText.New(self, self.FateDes_Battle.TextOngoing)},
		{"RewardList", UIBinderUpdateBindableList.New(self, self.TableViewRewardAdapter)},
	}
end

function AdventureFateRecommendItemView:OnDestroy()

end

function AdventureFateRecommendItemView:OnShow()
	self.FateDes_Battle:SetProfTagShow()
	UIUtil.SetIsVisible(self.FateDes_Battle.SizeBoxJob, false)
	self.FateDes_PlayerNum:SetProfTagShow()
	UIUtil.SetIsVisible(self.FateDes_PlayerNum.SizeBoxJob, false)
	self.BtnGo:SetText(_G.LSTR(520009))
	local ViewModel = self.Params.Data
	if nil == ViewModel then return end
	self:RegisterBinders(ViewModel, self.Binders)
end

function AdventureFateRecommendItemView:OnHide()

end

function AdventureFateRecommendItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoHandle)
end

function AdventureFateRecommendItemView:OnClickedGoHandle()
	local ViewModel = self.Params.Data
	if nil == ViewModel then return end

	local MapID = ViewModel.MapID
	local CrystalType = ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP
	local SearchCondition = string.format("MapID == %d and Type == %d", MapID, CrystalType)
	local CrystalCfg = TeleportCrystalCfg:FindCfg(SearchCondition)
	local Title = string.format(_G.LSTR(520078), ViewModel.TextTitle)
	if CrystalCfg then
		_G.EasyTraceMapMgr:ShowEasyTraceMap(MapID, Title, {CrystalID = CrystalCfg.CrystalID})
	end
end

function AdventureFateRecommendItemView:OnRegisterGameEvent()

end

function AdventureFateRecommendItemView:OnRegisterBinder()

end

return AdventureFateRecommendItemView
---
--- Author: daniel
--- DateTime: 2023-03-22 18:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class ArmyRankListWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelRankList UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TableViewRank UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRankListWinView = LuaClass(UIView, true)

function ArmyRankListWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelRankList = nil
	--self.PopUpBG = nil
	--self.TableViewRank = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyRankListWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRankListWinView:OnInit()
	self.Callback = nil
	self.TableViewRankAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRank)
	self.TableViewRankAdapter:SetOnClickedCallback(self.OnClickedItem)
	local Callback = function()
		self:Hide()
	end
	self.PopUpBG:SetCallback(self, Callback)
end

function ArmyRankListWinView:OnClickedItem(Index, ItemData, ItemView)
	local Params = self.Params
	if nil ~= Params then
		local CategoryID = Params.Categories[Index].CategoryData.ID
		if Params.SelectedID ~= CategoryID then
			_G.ArmyMgr:SendArmySetMemberCategoryMsg(Params.RoleID, CategoryID)
		end
	end
	self:Hide()
end

function ArmyRankListWinView:OnDestroy()

end

function ArmyRankListWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	UIUtil.CanvasSlotSetSize(self.PanelRankList, _G.UE.FVector2D(510, Params.Heigth))
	UIUtil.CanvasSlotSetPosition(self.PanelRankList, Params.Position)
	self.TableViewRankAdapter:UpdateAll(Params.Categories)
end

function ArmyRankListWinView:OnHide()

end

function ArmyRankListWinView:OnRegisterUIEvent()

end

function ArmyRankListWinView:OnRegisterGameEvent()

end

function ArmyRankListWinView:OnRegisterBinder()

end

return ArmyRankListWinView
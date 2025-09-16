---
--- Author: v_vvxinchen
--- DateTime: 2025-01-06 10:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local FishCfg = require("TableCfg/FishCfg")
local FishIngholeVM = require("Game/FishNotes/FishIngholeVM")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class FishIngholeBaitWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field FishingBaitTipsFrame ItemFishingBaitTipsFrameView
---@field TableView UTableView
---@field TextNum UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishIngholeBaitWinView = LuaClass(UIView, true)

function FishIngholeBaitWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.FishingBaitTipsFrame = nil
	--self.TableView = nil
	--self.TextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.FishingBaitTipsFrame)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishIngholeBaitWinView:OnInit()
	self.TextNum:SetText(_G.LSTR(180074))--"使用以下鱼饵才可以钓起该鱼类"
	self.BaitsListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView, self.TableViewSelected, false, false)
	self.Binders = {
		{"FishDetailAllBaitList", UIBinderUpdateBindableList.New(self, self.BaitsListAdapter)},
	}
end

function FishIngholeBaitWinView:OnDestroy()

end

function FishIngholeBaitWinView:OnShow()
	self.BG:SetTitleText(_G.LSTR(180073))--"目标可用钓饵"
	self.FishingBaitTipsFrame:UpdateUI({ResID = _G.FishIngholeVM.SelectFishData.Cfg.ItemID})
	FishIngholeVM:InitFishBaitsList()
end

function FishIngholeBaitWinView:OnHide()

end

function FishIngholeBaitWinView:OnRegisterUIEvent()

end

function FishIngholeBaitWinView:OnRegisterGameEvent()

end

function FishIngholeBaitWinView:OnRegisterBinder()
	self:RegisterBinders(FishIngholeVM, self.Binders)
end

function FishIngholeBaitWinView:TableViewSelected(Index, ItemData, ItemView)
	if ItemData.ItemID == nil then
		_G.FLOG_ERROR("FishIngholeBaitWinView ItemID is nil")
		return
	end
	local FishData = FishCfg:FindCfg("ItemID = ".. ItemData.ItemID)
	if FishData then
		if _G.FishNotesMgr:CheckFishUnlockInFround(FishData.ID, _G.FishIngholeVM.SelectLocationID) then
			ItemTipsUtil.ShowTipsByResID(FishData.ItemID, ItemView)
		end
	else
		ItemTipsUtil.ShowTipsByResID(ItemData.ItemID, ItemView)
	end
    self.BaitsListAdapter:CancelSelected()
end

return FishIngholeBaitWinView
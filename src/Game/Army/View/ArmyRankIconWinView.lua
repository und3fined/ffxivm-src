---
--- Author: daniel
--- DateTime: 2023-03-24 18:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local ArmyMgr = require("Game/Army/ArmyMgr")

---@class ArmyRankIconWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field TableViewIcon UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyRankIconWinView = LuaClass(UIView, true)

local SelectedID

function ArmyRankIconWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.TableViewIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.Callback = nil
end

function ArmyRankIconWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyRankIconWinView:OnInit()
	self.TableViewIconAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewIcon)
	self.TableViewIconAdapter:SetOnClickedCallback(self.OnClickedIconItem)
	local Callback = function()
		self:Hide()
	end
	self.PopUpBG:SetCallback(self, Callback)
end


function ArmyRankIconWinView:OnClickedIconItem(Index, ItemData, ItemView)
	local ItemParams = ItemView.Params
    if nil == ItemParams then
        return
    end
    local ItemVM = ItemParams.Data
    if nil == ItemVM then
        return
    end
	if ItemVM.IsEnabled then
		if self.Callback then
			self.Callback(Index)
		end
		self:Hide()
	else
		if nil ~= SelectedID then
			self.TableViewIconAdapter:SetSelectedIndex(SelectedID)
		end
	end
end

function ArmyRankIconWinView:OnDestroy()

end

function ArmyRankIconWinView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	if Params.Callback then
		self.Callback = Params.Callback
	end
	local IconData = {}
	local IconIDs = ArmyMgr:GetCategoryIconIDs()
	SelectedID = Params.IconID
	local CategoryIcons = GroupMemberCategoryCfg:GetAllCategoryCfg()
	for _, Data in ipairs(CategoryIcons) do
		local IsEnabled = not table.contain(IconIDs, Data.ID)
		table.insert(IconData, {
			ID = Data.ID,
			IsSelected = SelectedID == Data.ID,
			Icon = Data.Icon,
			IsEnabled = IsEnabled
		})
	end
	self.TableViewIconAdapter:UpdateAll(IconData)
	self.TableViewIconAdapter:SetSelectedIndex(SelectedID)
end

function ArmyRankIconWinView:OnHide()

end

function ArmyRankIconWinView:OnRegisterUIEvent()

end

function ArmyRankIconWinView:OnRegisterGameEvent()

end

function ArmyRankIconWinView:OnRegisterBinder()

end

return ArmyRankIconWinView
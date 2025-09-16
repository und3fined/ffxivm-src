---
--- Author: Administrator
--- DateTime: 2024-12-02 10:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local JumpListItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewbieStrategyJumpListItemVM")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")



---@class OpsNewBieStrategyCommListWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TableView_31 UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewBieStrategyCommListWinView = LuaClass(UIView, true)

function OpsNewBieStrategyCommListWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameM_UIBP = nil
	--self.TableView_31 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewBieStrategyCommListWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewBieStrategyCommListWinView:OnInit()
	self.TableViewJumpListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_31)
	self.TableViewJumpListAdapter:SetOnClickedCallback(self.OnRightItemClicked)
	self.JumpList = UIBindableList.New(JumpListItemVM)
end

function OpsNewBieStrategyCommListWinView:OnDestroy()
end

function OpsNewBieStrategyCommListWinView:OnShow()
	local Params = self.Params
	if Params and Params.NodeID then
		if Params.NodeTitle then
			self.Comm2FrameM_UIBP:SetTitleText(Params.NodeTitle)
		end
		self.JumpData = Params.JumpData
		local Data = {} 
		local JumpIndex = 1
		if OpsNewbieStrategyDefine.JumpNodePanelData[Params.NodeID] == nil then
			return
		end
		for Index, Value in ipairs(OpsNewbieStrategyDefine.JumpNodePanelData[Params.NodeID]) do
			local Item = {}
			Item.Key = Index
			Item.ItemViewType = Value.ItemViewType
			if Value.ItemViewType == 0 then
				Item.TitleTextUKey = Value.TitleTextUKey
			elseif Value.ItemViewType == 1 then
				Item.ContentTextUKey = Value.ContentTextUKey
				Item.Icon = Value.Icon
				if self.JumpData[JumpIndex] then
					Item.JumpData = self.JumpData[JumpIndex]
					JumpIndex = JumpIndex + 1
				end
				Item.ActivityID = Params.ActivityID
			end
			table.insert(Data, Item)
		end
		if Data then
			self.JumpList:UpdateByValues(Data)
			self.TableViewJumpListAdapter:UpdateAll(self.JumpList)
		end
	end
end

function OpsNewBieStrategyCommListWinView:OnHide()

end

function OpsNewBieStrategyCommListWinView:OnRegisterUIEvent()

end

function OpsNewBieStrategyCommListWinView:OnRegisterGameEvent()

end

function OpsNewBieStrategyCommListWinView:OnRegisterBinder()

end

return OpsNewBieStrategyCommListWinView
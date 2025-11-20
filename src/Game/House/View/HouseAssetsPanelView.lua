--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-14 11:29:26
FilePath: \Script\Game\House\View\HouseAssetsPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-13 11:06:09
FilePath: \Script\Game\House\View\HouseAssetsPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local VM = require("Game/House/View/HouseAssetsPanelVM") 
local UIUtil = require("Utils/UIUtil")

---@class HouseAssetsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnRecycle CommBtnLView
---@field HouseMineBG_UIBP HouseMineBGView
---@field TableViewSlot1 UTableView
---@field TableViewSlot2 UTableView
---@field TextHint1 URichTextBox
---@field TextNotRecyclable UFTextBlock
---@field TextRecyclable UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseAssetsPanelView = LuaClass(UIView, true)

function HouseAssetsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnRecycle = nil
	--self.HouseMineBG_UIBP = nil
	--self.TableViewSlot1 = nil
	--self.TableViewSlot2 = nil
	--self.TextHint1 = nil
	--self.TextNotRecyclable = nil
	--self.TextRecyclable = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseAssetsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnRecycle)
	self:AddSubView(self.HouseMineBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseAssetsPanelView:OnInit()
	self.RecycleList = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot1)
	self.UnRecycleList = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot2)

	self.Binders = {
		{"RecycleList", UIBinderUpdateBindableList.New(self, self.RecycleList)},
		{"UnRecycleList", UIBinderUpdateBindableList.New(self, self.UnRecycleList)},
	}
end

function HouseAssetsPanelView:OnDestroy()

end

function HouseAssetsPanelView:OnShow()
	self.HouseMineBG_UIBP:SetTitleInfo(HouseLocalDef.RecycleAssetsTitle, 11223)
	UIUtil.SetIsVisible(self.HouseMineBG_UIBP.CommTab, false)
	self:SetMenuTab()
	self.TextRecyclable:SetText(HouseLocalDef.RecycleAssetsPanelText.RecycleAssets)
	self.TextNotRecyclable:SetText(HouseLocalDef.RecycleAssetsPanelText.UnRecycleAssets)
	self.BtnRecycle:SetText(HouseLocalDef.RecycleAssetsPanelText.RecycleBtnText)
end

function HouseAssetsPanelView:GetMenuData()
	local DeinfeData = HouseLocalDef.RecycleAssetsTab
	local MenuData = {}
	for i, v in ipairs(DeinfeData) do
		local RecyclyData = _G.HouseInfoMgr:GetRecycleDataByRecycleType(v.Key)
		if next(RecyclyData) then
			local Tabdata = {
				Key = v.Key,
				Name = v.Name,
				ExtraData = RecyclyData,
				RedDotID = v.RedDotID
			}

			table.insert(MenuData, Tabdata)
		end
	end

	self.MenuData = MenuData
	return MenuData
end

function HouseAssetsPanelView:SetMenuTab()
	local MenuData = self:GetMenuData()

	if next(MenuData) then
		self.HouseMineBG_UIBP:SetOnSelectionChangedCallback(self.OnSelectionChanged, self)
		self.HouseMineBG_UIBP:SetTabView(MenuData, MenuData[1].Key)
	else
		self:Hide()
	end
end

function HouseAssetsPanelView:OnSelectionChanged(Index, ItemData, ItemView)
	local Key = ItemData.Key
	local RecyclyAllData = _G.HouseInfoMgr:GetRecycleDataByRecycleType(Key)
    if RecyclyAllData and next(RecyclyAllData) then
		local RecycleData = RecyclyAllData.RecycleItemList
		local UnRecycleData = RecyclyAllData.UnrecycleItemList
		local DestroyTimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d %H:%M", RecyclyAllData.DestoryTime)
		self.VM:UpdateRecycleItem(RecycleData, UnRecycleData)
		self.Key = ItemData.Key

		local ProtoCS = require("Protocol/ProtoCS")
		if self.Key and self.Key == ProtoCS.RecycleHouseAssetType.RecycleHouseAssetType_Group then
			self.TextHint1:SetText(HouseLocalDef.RecycleAssetsPanelText.ArmyTips, DestroyTimeStr)
		else
			local Text = self.Key == ProtoCS.RecycleHouseAssetType.RecycleHouseAssetType_GroupMemberRoom and 
				HouseLocalDef.RecycleAssetsPanelText.ArmyRoomTips or HouseLocalDef.RecycleAssetsPanelText.PersonalTips
				Text = string.format(Text, DestroyTimeStr)
			self.TextHint1:SetText(Text)
		end
    end
end

function HouseAssetsPanelView:OnHide()

end

function HouseAssetsPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnRecycle, self.OnBtnRecycleClicked)
end

function HouseAssetsPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PullSelfRoleHouseInfo, self.OnHouseInfoUpdate)
	self:RegisterGameEvent(_G.EventID.HouseGroupInfoUpdate, self.OnHouseInfoUpdate)
end

function HouseAssetsPanelView:OnHouseInfoUpdate()
	self:SetMenuTab()
end

function HouseAssetsPanelView:OnRegisterBinder()
	self.VM = VM:New()
	if self.VM then
		self:RegisterBinders(self.VM, self.Binders)
	end
end

function HouseAssetsPanelView:OnBtnRecycleClicked()
	local ProtoCS = require("Protocol/ProtoCS")
	if self.Key and self.Key == ProtoCS.RecycleHouseAssetType.RecycleHouseAssetType_Group then
		_G.HouseInfoMgr:SendRecycleGroupAsset(self.Key, _G.ArmyMgr:GetArmyID())
	else
		_G.HouseInfoMgr:SendRecycleRoleAsset(self.Key)
	end
end

return HouseAssetsPanelView
---
--- Author: Administrator
--- DateTime: 2025-08-05 11:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WardrobePreviewColorWinVM = require("Game/Wardrobe/VM/WardrobePreviewColorWinVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ItemUtil = require("Utils/ItemUtil")
local SystemEntranceMgr = require("Game/Common/Tips/SystemEntranceMgr")
local RichTextUtil = require("Utils/RichTextUtil")
local WardrobeMgr =  require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local ClosetCfg = require("TableCfg/ClosetCfg")
local EventID = _G.EventID
local UKismetInputLibrary = UE.UKismetInputLibrary
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class WardrobePreviewColorWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn1 UFButton
---@field BtnColor CommBtnLView
---@field CommBackpackEmpty CommBackpackEmptyView
---@field CommSidebarFrameS_UIBP CommSidebarFrameSView
---@field PanelPreview UFCanvasPanel
---@field RichText URichTextBox
---@field RichText2 URichTextBox
---@field TableViewList1 UTableView
---@field TableViewList2 UTableView
---@field TableViewRegion UTableView
---@field TextBtnTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobePreviewColorWinView = LuaClass(UIView, true)

function WardrobePreviewColorWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn1 = nil
	--self.BtnColor = nil
	--self.CommBackpackEmpty = nil
	--self.CommSidebarFrameS_UIBP = nil
	--self.PanelPreview = nil
	--self.RichText = nil
	--self.RichText2 = nil
	--self.TableViewList1 = nil
	--self.TableViewList2 = nil
	--self.TableViewRegion = nil
	--self.TextBtnTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobePreviewColorWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnColor)
	self:AddSubView(self.CommBackpackEmpty)
	self:AddSubView(self.CommSidebarFrameS_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobePreviewColorWinView:OnInit()
	self.VM = WardrobePreviewColorWinVM.New()
	-- 染色区域列表List
	self.ColorAreaListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRegion)
	--  染剂列表1
	self.StainListAdapter1 = UIAdapterTableView.CreateAdapter(self, self.TableViewList1)
	--  染剂列表2
	self.StainListAdapter2 = UIAdapterTableView.CreateAdapter(self, self.TableViewList2)

	self.Binders = {
		{ "ColorAreaList",  UIBinderUpdateBindableList.New(self, self.ColorAreaListAdapter)},
		{ "StainList1",  UIBinderUpdateBindableList.New(self, self.StainListAdapter1)},
		{ "StainList2",  UIBinderUpdateBindableList.New(self, self.StainListAdapter2)},
		{ "IsDiff", UIBinderSetIsVisible.New(self, self.PanelPreview)},
		{ "IsMore4", UIBinderSetIsVisible.New(self, self.TableViewList2, false, true)},
		{ "IsDiff", UIBinderSetIsVisible.New(self, self.CommBackpackEmpty, true)},
		{ "IsComsume", UIBinderSetIsVisible.New(self, self.RichText2)},
		{ "IsLessStain", UIBinderSetIsVisible.New(self, self.TextBtnTips)},
	}

end

function WardrobePreviewColorWinView:OnDestroy()

end

function WardrobePreviewColorWinView:OnShow()
	self.Info = nil
	self:InitText()
	self.BtnColor:SetIsRecommendState(true)

	self.VM:UpdateColorAreaList(self.Params.AppID, self.Params.StainColorList, self.Params.PreviewColorList)
	self.VM:UpdateConsumeList(self.Params.AppID)
end

function WardrobePreviewColorWinView:OnHide()

end

function WardrobePreviewColorWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnColor, self.OnClickedOneTouchColor)
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnClickedBtn1)
end

function WardrobePreviewColorWinView:OnRegisterGameEvent()
	--背包监听
	self:RegisterGameEvent(EventID.BagUpdate, self.OnBagUpdate)
	--染色监听
	self:RegisterGameEvent(EventID.WardrobeDyeUpdate, self.OnWardrobeDyeUpdate)
	--区域染色监听
	self:RegisterGameEvent(EventID.WardrobeRegionDyeUpdate, self.OnWardrobeRegionDyeUpdate)
end

function WardrobePreviewColorWinView:OnRegisterBinder()
	self:RegisterBinders(self.VM, self.Binders)
end

function WardrobePreviewColorWinView:OnWardrobeDyeUpdate(Params)
	local AppID = Params.ID
	local ColorID = Params.ColorID -- 染色值
	-- local RegionDyes = Params.RegionDyes or {}

	self.Params.StainColorList.Color = ColorID

	self.VM:UpdateColorAreaList(AppID, self.Params.StainColorList, self.Params.PreviewColorList)
	self.VM:UpdateConsumeList(AppID)
end

function WardrobePreviewColorWinView:OnWardrobeRegionDyeUpdate(Params)
	local AppID = Params.ID
	-- local ColorID = Params.ColorID
	local RegionDyes = Params.RegionDyes or  {}
	self.Params.StainColorList.RegionDye = RegionDyes
	-- 获取当前颜色
	-- 获取当前预览颜色
	self.VM:UpdateColorAreaList(AppID, self.Params.StainColorList, self.Params.PreviewColorList)
	self.VM:UpdateConsumeList(AppID)
end

function WardrobePreviewColorWinView:InitText()
	self.CommSidebarFrameS_UIBP:SetTitleText(_G.LSTR(1080135)) --预览颜色确认
	self.RichText:SetText(_G.LSTR(1080136)) -- 确认后会将当前外观所有区域的预览颜色变为外观的实际颜色
	self.RichText2:SetText(_G.LSTR(1080137)) --未解锁的颜色需要消耗染色剂
	self.BtnColor:SetText(_G.LSTR(1080138)) --确认染色
	self.CommBackpackEmpty:SetTipsContent(_G.LSTR(1080139)) --预览不同区域的染色后，可以在这里一次性完成染色确认
	self.TextBtnTips:SetText(_G.LSTR(1080165)) --染剂不足
end

--Todo 如果不缺道具 就前往染色，如果缺少道具就去弹窗
function WardrobePreviewColorWinView:OnClickedOneTouchColor()
	local DataList = self.VM:GetStainDataList()
	for _, v in ipairs(DataList) do
		local BagNum = _G.BagMgr:GetItemNum(v.ResID)
		if BagNum < v.Num then
			local function  GoShopping()
				local Cfg = ItemUtil.GetItemGetWayList(v.ResID)
				if table.length(Cfg) > 0 then
					local TransferData = {}
					TransferData.NeedBuyNum =  v.Num - BagNum
					TransferData.FunValue = 0
					SystemEntranceMgr:ShowStoreEntrance(v.ResID, TransferData)
				end
			end

			local QuantityText = string.format(_G.LSTR("%s/%d"), RichTextUtil.GetText(BagNum, "dc5868"), v.Num)
			local CostText = string.format(_G.LSTR(1080101), RichTextUtil.GetText(ItemUtil.GetItemName(v.ResID), "d1ba8e"))
			local Params = {ItemResID = v.ResID, TextQuantity = QuantityText}
			self.Info = Params
					_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(620039), CostText, GoShopping, nil, _G.LSTR(620011), _G.LSTR(620029), Params)
			return
		end
	end

	local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(self.Params.AppID)
	local RegionDyes = {}
	local ColorID  = 0
	if not IsAppRegionDye then
		for i = 1, self.ColorAreaListAdapter:GetNum(), 1 do
			local ItemData = self.ColorAreaListAdapter:GetItemDataByIndex(i)
			if ItemData ~= nil then
				if ItemData.ColorVM.ID ~= ItemData.PreColorVM.ID then
					ColorID = ItemData.PreColorVM.ID
					break
				end
			end
		end
		WardrobeMgr:SendClosetDyeReq(self.Params.AppID, ColorID)
	else
		for i = 1, self.ColorAreaListAdapter:GetNum(), 1 do
			local ItemData = self.ColorAreaListAdapter:GetItemDataByIndex(i)
			if ItemData ~= nil then
				if ItemData.ColorVM.ID ~= ItemData.PreColorVM.ID then
					if ItemData.SectionID == -1 then
						local CCfg = ClosetCfg:FindCfgByKey(self.Params.AppID)
						RegionDyes = {}
						ColorID = ItemData.PreColorVM.ID
						if CCfg ~= nil and CCfg.StainAera ~= nil then
							for index, v in ipairs(CCfg.StainAera) do
								if v.Ban ~= 1 and v.List ~= "" then
									table.insert(RegionDyes, {ID = index, ColorID = ColorID})
								end
							end
						end
						break
					else
						table.insert(RegionDyes, {ID = ItemData.SectionID, ColorID = ItemData.PreColorVM.ID})
					end
				end
			end
		end
		WardrobeMgr:SendClosetRegionDyeListReq(self.Params.AppID, RegionDyes)
	end
end

function WardrobePreviewColorWinView:OnBagUpdate()
	-- local View = UIViewMgr:FindVisibleView(UIViewID.CommonMsgBox)
	-- if View ~= nil then

	-- 	if self.Info ~= nil then
	-- 		View:UpdateView(self.Info)
	-- 	end
	-- end
	self.VM:UpdateConsumeList(self.Params.AppID)
end

function WardrobePreviewColorWinView:OnClickedBtn1()
	UIViewMgr:HideView(UIViewID.WardrobePreviewColorWin)
end



return WardrobePreviewColorWinView
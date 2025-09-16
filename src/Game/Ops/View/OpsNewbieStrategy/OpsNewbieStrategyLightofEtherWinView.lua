---
--- Author: Administrator
--- DateTime: 2024-11-29 18:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local OpsNewbieStrategyMgr
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local AetherLightIcon = OpsNewbieStrategyDefine.AetherLightIcon
local ProtoRes = require("Protocol/ProtoRes")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBindableList = require("UI/UIBindableList")
local OpsNewbieStrategyAetherLightListItemVM = require("Game/Ops/VM/OpsNewbieStrategy/ItemVM/OpsNewbieStrategyAetherLightListItemVM")
local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE
local ItemUtil = require("Utils/ItemUtil")
local CrystalPortalMgr
local PWorldMgr
local JumpUtil = require("Utils/JumpUtil")

---@class OpsNewbieStrategyLightofEtherWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field TableViewAetherLight UTableView
---@field TableViewAetherLight_1 UTableView
---@field TextAetherCrystal UFTextBlock
---@field TextAetherCrystalQuantity UFTextBlock
---@field TextAetherLight UFTextBlock
---@field TextAetherLightQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsNewbieStrategyLightofEtherWinView = LuaClass(UIView, true)

function OpsNewbieStrategyLightofEtherWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm2FrameL_UIBP = nil
	--self.TableViewAetherLight = nil
	--self.TableViewAetherLight_1 = nil
	--self.TextAetherCrystal = nil
	--self.TextAetherCrystalQuantity = nil
	--self.TextAetherLight = nil
	--self.TextAetherLightQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyLightofEtherWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm2FrameL_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsNewbieStrategyLightofEtherWinView:OnInit()
	PWorldMgr = _G.PWorldMgr
	CrystalPortalMgr = PWorldMgr:GetCrystalPortalMgr()
	OpsNewbieStrategyMgr =_G.OpsNewbieStrategyMgr
	---小水晶列表
	self.TableViewSmallCrystalAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAetherLight_1)
	self.TableViewSmallCrystalAdapter:SetOnClickedCallback(self.OnRightItemClicked)
	self.SmallCrystalList = UIBindableList.New( OpsNewbieStrategyAetherLightListItemVM )
	---大水晶列表
	self.TableViewBigCrystalAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewAetherLight)
	self.TableViewBigCrystalAdapter:SetOnClickedCallback(self.OnLeftItemClicked)
	self.BigCrystalList = UIBindableList.New( OpsNewbieStrategyAetherLightListItemVM )
end

function OpsNewbieStrategyLightofEtherWinView:OnDestroy()

end

function OpsNewbieStrategyLightofEtherWinView:OnShow()
	-- LSTR string:以太之光
	local TitleText = LSTR(920030)
	-- LSTR string:以太之光
	local AetherLightTextUkey = 920030
	-- LSTR string:以太水晶
	local AetherCrystalTextUkey = 920031
	
	local Params = self.Params
	if Params and Params.NodeID then
		local ActivatedList = CrystalPortalMgr:GetActivatedList() or {}
		local AllCrystalData = OpsNewbieStrategyMgr:GetAllCrystalDataByNodeID(Params.NodeID)
		local SmallCrystalDatas = {}
		local SmallActivatedNum = 0
		local SmallCrystalNum = 0
		local BigCrystalDatas ={}
		local BigActivatedNum = 0
		local BigCrystalNum = 0

		local ShieldCrystalIDList = {}
		if Params.NodeTitle then
			TitleText = Params.NodeTitle
		end
		if Params.ShieldCrystalIDList then
			ShieldCrystalIDList = Params.ShieldCrystalIDList
		end
		if OpsNewbieStrategyDefine.AetherLightNodeJumpPanelData[Params.NodeID] then
			AetherLightTextUkey = OpsNewbieStrategyDefine.AetherLightNodeJumpPanelData[Params.NodeID].AetherLightTextUkey
			AetherCrystalTextUkey = OpsNewbieStrategyDefine.AetherLightNodeJumpPanelData[Params.NodeID].AetherCrystalTextUkey
		end

		for _, CrystalData in ipairs(AllCrystalData) do
			local CrystalItemData = {}
			local IsActivated = false
			local ID = CrystalData.CrystalID
			IsActivated = ActivatedList[ID]
			-- IsActivated = table.find_by_predicate(ActivatedList, function(A)
			-- 	return A == ID
			-- end)
			---local CrystalIcon = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ID))
			--local CrystalIcon
			CrystalItemData = 
			{
				MapID = CrystalData.MapID,
				CrystalID = ID,
				CrystalName = CrystalData.CrystalName,
				IsActivated = IsActivated,
				--CrystalIcon = CrystalIcon,
			}
			local IsShieldCrystal = false
			for _, ShieldCrystalID in ipairs(ShieldCrystalIDList) do
				if ID == ShieldCrystalID then
					IsShieldCrystal = true
				end
			end
			if CrystalData.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP and not IsShieldCrystal then
				if IsActivated then
					CrystalItemData.CrystalIcon = AetherLightIcon.BigAetherLightIconPath
					BigActivatedNum = BigActivatedNum + 1
				else
					CrystalItemData.CrystalIcon = AetherLightIcon.BigAetherLightGrayIconPath
				end
				table.insert(BigCrystalDatas, CrystalItemData)
			elseif CrystalData.Type == TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_CURRENTMAP and not IsShieldCrystal then
				if IsActivated then
					SmallActivatedNum = SmallActivatedNum + 1
					CrystalItemData.CrystalIcon = AetherLightIcon.SmallAetherLightIconPath
				else
					CrystalItemData.CrystalIcon = AetherLightIcon.SmallAetherLightGrayIconPath
				end
				table.insert(SmallCrystalDatas, CrystalItemData)
			end
		end
		SmallCrystalNum = #SmallCrystalDatas
		self.SmallCrystalList:UpdateByValues(SmallCrystalDatas)
		self.TableViewSmallCrystalAdapter:UpdateAll(self.SmallCrystalList)
		BigCrystalNum = #BigCrystalDatas
		self.BigCrystalList:UpdateByValues(BigCrystalDatas)
		self.TableViewBigCrystalAdapter:UpdateAll(self.BigCrystalList)
		---数量显示
		local BigNumText = string.format("(%s/%s)", BigActivatedNum,BigCrystalNum)
		self.TextAetherLightQuantity:SetText(BigNumText)
		local SmallNumText = string.format("(%s/%s)", SmallActivatedNum,SmallCrystalNum)
		self.TextAetherCrystalQuantity:SetText(SmallNumText)

	end
	self.Comm2FrameL_UIBP:SetTitleText(TitleText)
	self.TextAetherLight:SetText(LSTR(AetherLightTextUkey))
	self.TextAetherCrystal:SetText(LSTR(AetherCrystalTextUkey))
end

function OpsNewbieStrategyLightofEtherWinView:OnHide()

end

function OpsNewbieStrategyLightofEtherWinView:OnRegisterUIEvent()

end

function OpsNewbieStrategyLightofEtherWinView:OnRegisterGameEvent()

end

function OpsNewbieStrategyLightofEtherWinView:OnRegisterBinder()

end

function OpsNewbieStrategyLightofEtherWinView:OnRightItemClicked(Index, ItemData, ItemView)
	self:OnItemClicked(Index, ItemData, ItemView)
end

function OpsNewbieStrategyLightofEtherWinView:OnLeftItemClicked(Index, ItemData, ItemView)
	self:OnItemClicked(Index, ItemData, ItemView)
end

function OpsNewbieStrategyLightofEtherWinView:OnItemClicked(Index, ItemData, ItemView)
	local MapID = ItemData.MapID
	local CrystalID = ItemData.CrystalID
	-- local Params = {
	-- 	[1] = MapID,
	-- 	[2] = CrystalID,
	-- }
	if MapID and CrystalID then
		--JumpUtil.JumpToByTypeWithJumpParams(JumpUtil.JumpType.MapCrystal, Params)
		_G.WorldMapMgr:ShowWorldMapCrystal(MapID, CrystalID)
	end
end

return OpsNewbieStrategyLightofEtherWinView
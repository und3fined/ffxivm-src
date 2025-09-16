-- local EquipmentDetailVM = require("Game/Equipment/VM/EquipmentDetailVM")
local MajorUtil = require("Utils/MajorUtil")
local EquipmentTipsUtil = {}

---ShowTipsByItem
---@param Item common.Item
---@param ContainerView UWidget
---@param ViewOffset table @{X = 0, Y = 0}
---@param Part number
---@param ProfLevel number
function EquipmentTipsUtil.ShowTipsByItem(Item, ContainerView, ViewOffset, Part, ProfLevel)
	-- local ViewModel = EquipmentDetailVM.New()
	-- if nil == Part then
	-- 	Part = Item.Attr.Equip.Part
	-- end
	-- if nil == ProfLevel then
	-- 	ProfLevel = MajorUtil.GetMajorLevel()
	-- end
	-- ViewModel:SetOtherEquipment(Item, Part, ProfLevel)

	local EquipTips = _G.UIViewMgr:ShowView(_G.UIViewID.EquipTips, {ContainerView = ContainerView, ViewOffset = ViewOffset, bHideButtons = true, bPersonUI = true})
	EquipTips:UpdateEquipment(Item)
end

return EquipmentTipsUtil
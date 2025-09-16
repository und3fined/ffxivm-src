local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CommScreenerTableItemVM = require("Game/Common/Screener/CommScreenerTableItemVM")
local ScreenerInfoCfg = require("TableCfg/ScreenerInfoCfg")

local CheckBoxNumPerRow = 5

---@class CommScreenerVM : UIViewModel
local CommScreenerVM = LuaClass(UIViewModel)

---Ctor
function CommScreenerVM:Ctor()
	self.ScreenerItemVMList = UIBindableList.New(CommScreenerTableItemVM)
end

--0-下拉框、1-多选， 2-单选，3-复选框
function CommScreenerVM:UpdateScreenerList(DropDownScreenList, OtherScreenerList, ScreenerSelectedInfo)
    local CommScreenerItemList = {}

	-- 处理下拉框
	for i = 1, #DropDownScreenList, 2 do
		local ScreenerInfo = DropDownScreenList[i]

		--标题行
		local TileItemValue = {}
		TileItemValue.Title1 = ScreenerInfo.Name
		TileItemValue.ScreenerID1 = ScreenerInfo.ScreenerID
		
		--下拉框行
		local DropDownItemValue = {}
		local ScreenerInfoList = self:GetScreenerInfoList(ScreenerInfo.ScreenerID)
		DropDownItemValue.DropDown1List = ScreenerInfoList
		DropDownItemValue.ScreenerSelectedInfo = ScreenerSelectedInfo
		DropDownItemValue.ScreenerID1 = ScreenerInfo.ScreenerID
		if #DropDownScreenList > i then
			local ScreenerInfo2 = DropDownScreenList[i+1]
			TileItemValue.Title2 = ScreenerInfo2.Name
			TileItemValue.ScreenerID2 = ScreenerInfo2.ScreenerID

			local ScreenerInfo2List = self:GetScreenerInfoList(ScreenerInfo2.ScreenerID)
			DropDownItemValue.DropDown2List = ScreenerInfo2List
			DropDownItemValue.ScreenerID2 = ScreenerInfo2.ScreenerID
		end
		TileItemValue.Index = #CommScreenerItemList
		table.insert(CommScreenerItemList, TileItemValue)

		DropDownItemValue.Index = #CommScreenerItemList
		table.insert(CommScreenerItemList, DropDownItemValue)

	end

	--处理其他筛选类型
	for i = 1, #OtherScreenerList do
		local ScreenerInfo = OtherScreenerList[i]
		local ScreenerInfoList = self:GetScreenerInfoList(ScreenerInfo.ScreenerID)
		if ScreenerInfoList ~= nil or  #ScreenerInfoList > 0 then
			if ScreenerInfo.ScreenerType == 2 then  --复选框
				local TileItemValue = {}
				TileItemValue.Title1 = ScreenerInfo.Name
				TileItemValue.Index = #CommScreenerItemList
				TileItemValue.ScreenerID1 = ScreenerInfo.ScreenerID
				table.insert(CommScreenerItemList, TileItemValue)

				local CheckBoxItemValue = {}
				CheckBoxItemValue.CheckBoxScreenerInfo = ScreenerInfoList
				CheckBoxItemValue.Index = #CommScreenerItemList
				CheckBoxItemValue.ScreenerID1 = ScreenerInfo.ScreenerID
				CheckBoxItemValue.ScreenerSelectedInfo = ScreenerSelectedInfo
				table.insert(CommScreenerItemList, CheckBoxItemValue)
			else
				local TileItemValue = {}
				TileItemValue.Title1 = ScreenerInfo.Name
				TileItemValue.Index = #CommScreenerItemList
				TileItemValue.ScreenerID1 = ScreenerInfo.ScreenerID
				table.insert(CommScreenerItemList, TileItemValue)
				for j = 1, #ScreenerInfoList, CheckBoxNumPerRow do
					local SelectList = {}
					local End = (j + CheckBoxNumPerRow) > #ScreenerInfoList and #ScreenerInfoList or (j + CheckBoxNumPerRow)
					for k = j, End do
						table.insert(SelectList, ScreenerInfoList[k])
					end
					local SelectItemValue = {}
					SelectItemValue.SelectList = SelectList
					SelectItemValue.Index = #CommScreenerItemList
					SelectItemValue.ScreenerID1 = ScreenerInfo.ScreenerID
					SelectItemValue.IsMultiple = ScreenerInfo.ScreenerType == 1
					SelectItemValue.ScreenerSelectedInfo = ScreenerSelectedInfo
					table.insert(CommScreenerItemList, SelectItemValue)
				end
			end
		end
	end
		
	self.ScreenerItemVMList:UpdateByValues(CommScreenerItemList)
end

function CommScreenerVM:ResetScreener()
	for i = 1, self.ScreenerItemVMList:Length() do
		local ItemVM = self.ScreenerItemVMList:Get(i)
		if ItemVM.DropDown1Visible == true then
			ItemVM:ResetDropDown()
		elseif ItemVM.SelectListVisible == true then
			ItemVM:ResetSelected()
		elseif ItemVM.CheckBoxVisible == true then
			ItemVM:ResetCheckBox()
		end
	end
end

function CommScreenerVM:ResetLastSingleSelectIndex(ScreenerIndex, ScreenerID)
	for i = 1, self.ScreenerItemVMList:Length() do
		local ItemVM = self.ScreenerItemVMList:Get(i)
		if ItemVM.Index ~= ScreenerIndex and  ItemVM.SelectListVisible == true and ItemVM.ScreenerID1 == ScreenerID then
			ItemVM:ResetSelected()
		end
	end
end

function CommScreenerVM:GetScreenerSearchCond(ScreenerInfo)
    if ScreenerInfo == nil then
        return nil
    end
	local FilterAnd = {}
	for i = 1, #ScreenerInfo.FilterAnd do
		local FilterAndStr = self:TransArraySymbol(ScreenerInfo.FilterAnd[i])
		table.insert(FilterAnd, FilterAndStr)
	end

	local FilterOR = {}
	for i = 1, #ScreenerInfo.FilterOR do
		local FilterORStr = self:TransArraySymbol(ScreenerInfo.FilterOR[i])
		table.insert(FilterOR, FilterORStr)
	end

	local FilterAndStr = table.concat(FilterAnd, " AND ", 1, #FilterAnd)
    local FilterORStr = table.concat(FilterOR, " OR ", 1, #FilterOR)

	if #FilterAnd == 0  and #FilterOR == 0 then
		return nil
	end

	if #FilterAnd > 0  and #FilterOR > 0 then
		return string.format("(%s) AND (%s)", FilterAndStr, FilterORStr)
	end

	if #FilterOR > 0 then
		return string.format("(%s)", FilterORStr)
	end

	return string.format("(%s)", FilterAndStr)

end

function CommScreenerVM:TransArraySymbol(FilterStr)
	local Temp = string.gsub(FilterStr, '{', '"[')
	return string.gsub(Temp, '}', ']"')
end

function CommScreenerVM:SearchCondAndScreenerList()
	local SearchCond = {}
	local SelectSearchCond = {}
	local CurScreenerID1 = nil
	local ScreenerList = {}
	for i = 1, self.ScreenerItemVMList:Length() do
		local ItemVM = self.ScreenerItemVMList:Get(i)
		if ItemVM.DropDown1Visible == true then
			local SingleSearchCond = self:GetScreenerSearchCond(ItemVM.DropDown1List[ItemVM.DropDown1Index])
			if SingleSearchCond ~= nil then
				table.insert(SearchCond, SingleSearchCond)
				table.insert(ScreenerList, ItemVM.DropDown1List[ItemVM.DropDown1Index])
			end

			if ItemVM.DropDown2Visible == true then
				local SingleSearchCond2 = self:GetScreenerSearchCond(ItemVM.DropDown2List[ItemVM.DropDown2Index])
				if SingleSearchCond2 ~= nil then
					table.insert(SearchCond, SingleSearchCond2)
					table.insert(ScreenerList, ItemVM.DropDown2List[ItemVM.DropDown2Index])
				end
			end
		elseif ItemVM.CheckBoxVisible == true then
			local CheckBoxSearchCond = self:GetScreenerSearchCond(ItemVM:GetCheckBoxInfo())
			if CheckBoxSearchCond ~= nil then
				table.insert(SearchCond, CheckBoxSearchCond)
				table.insert(ScreenerList, ItemVM:GetCheckBoxInfo())
			end
		elseif ItemVM.SelectListVisible == true then
			if CurScreenerID1 ~= nil and CurScreenerID1 ~= ItemVM.ScreenerID1  and #SelectSearchCond > 0 then
				table.insert(SearchCond, string.format("(%s)", table.concat(SelectSearchCond, " OR ", 1, #SelectSearchCond)))
				SelectSearchCond = {}
			end

			if ItemVM.SelectListVMList ~= nil then
				for j = 1, ItemVM.SelectListVMList:Length() do
					local SelectVM = ItemVM.SelectListVMList:Get(j)
					if SelectVM ~= nil and SelectVM.SelectedNodeVisible == true then
						table.insert(SelectSearchCond, self:GetScreenerSearchCond(ItemVM.SelectList[j]))
						table.insert(ScreenerList, ItemVM.SelectList[j])
					end
				end
			end
			
			CurScreenerID1 = ItemVM.ScreenerID1
		end
	end

	if #SelectSearchCond > 0 then
		table.insert(SearchCond, string.format("(%s)", table.concat(SelectSearchCond, " OR ", 1, #SelectSearchCond)))
	end

	return table.concat(SearchCond, " AND ", 1, #SearchCond), ScreenerList
end


function CommScreenerVM:GetScreenerInfoList(ScreenerID)
	local CfgSearchCond = string.format("ScreenerID == %d", ScreenerID)
	return ScreenerInfoCfg:FindAllCfg(CfgSearchCond)
end

---获取标签参数
---@return table<CommScreenerTagItemVMParam>
function CommScreenerVM:GetTagParams()
	local TagParams = {}
	for i = 1, self.ScreenerItemVMList:Length() do
		local ItemVM = self.ScreenerItemVMList:Get(i)
		if ItemVM.SingleBoxVisible == true then
			local ScreenerInfo = ItemVM.SingleBoxList[ItemVM.SingleBoxIndex]
			if ScreenerInfo then
				---@type CommScreenerTagItemVMParam
				local CommScreenerTagItemVMParam = {}
				CommScreenerTagItemVMParam.TagText = ScreenerInfo.ScreenerName
				table.insert(TagParams, CommScreenerTagItemVMParam)
			end
		elseif ItemVM.CheckBoxVisible == true then
			for j = 1, ItemVM.CheckBoxVMList:Length() do
				local CheckBoxVM = ItemVM.CheckBoxVMList:Get(j)
				if CheckBoxVM ~= nil and CheckBoxVM.SelectedItemVisible == true then
					local ScreenerInfo = ItemVM.CheckBoxList[j]
					if ScreenerInfo then
						---@type CommScreenerTagItemVMParam
						local CommScreenerTagItemVMParam = {}
						CommScreenerTagItemVMParam.TagText = ScreenerInfo.ScreenerName
						table.insert(TagParams, CommScreenerTagItemVMParam)
					end
				end
			end
		end
	end
	return TagParams
end

--要返回当前类
return CommScreenerVM
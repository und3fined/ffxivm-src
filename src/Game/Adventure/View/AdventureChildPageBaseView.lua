--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-03-12 16:29:29
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-12 16:30:56
FilePath: \Script\Game\Adventure\View\AdventureChildPageBaseView.lua
Description: 周任务 日随 推荐任务 职业引导主界面基类
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local AdventureChildPageBaseView = LuaClass(UIView, true)
local CreatCount = 5

function AdventureChildPageBaseView:OnInit()
    self.VM = nil
	self.CreatSucess = false
end

function AdventureChildPageBaseView:CreatItemList(ItemListData)
	self.CreatSucess = false
	self:UnRegisterAllTimer()
    if not self.VM then
        FLOG_ERROR("AdventureChildPageBaseView ChildView Need Init VM")
        return
    end

    self.VM:ClearItemList()
    if #ItemListData > CreatCount then
		local Time = 1
		self:RegisterTimer(function()
			local Start = (Time - 1) * 5 > 0 and (Time - 1) * 5 + 1 or 1
			for i = Start, Time * CreatCount, 1 do
				if ItemListData[i] then
					self.VM:SetOneItemListData(ItemListData[i])
				else
					break
				end
			end

			Time = Time + 1
			if Time >= math.ceil(#ItemListData / CreatCount)then
				self.CreatSucess = true
			end
		end, 0, 0.1, math.ceil(#ItemListData / CreatCount))
	else
		self.VM:SetItemListData(ItemListData)
		self.CreatSucess = true
	end
end

function AdventureChildPageBaseView:OnHide()
	self.CreatSucess = false
    self:UnRegisterAllTimer()
	if self.VM then
		self.VM:ClearItemList()
	end
end

return AdventureChildPageBaseView
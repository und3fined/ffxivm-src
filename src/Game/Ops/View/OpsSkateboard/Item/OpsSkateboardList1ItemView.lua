--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-03-31 11:54:44
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-31 15:30:20
FilePath: \Script\Game\Ops\View\OpsSkateboard\Item\OpsSkateboardList1ItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local TaskUIView = require("Game/Ops/View/OpsActivity/Item/OpsWhaleMonutRebatesList1ItemView")
local LuaClass = require("Core/LuaClass")

---@class OpsSkateboardList1ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot CommBtnSView
---@field ImgBG UFImage
---@field TableViewSlot UTableView
---@field TextList UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkateboardList1ItemView = LuaClass(TaskUIView, true)

function OpsSkateboardList1ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.ImgBG = nil
	--self.TableViewSlot = nil
	--self.TextList = nil
	--self.TextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsSkateboardList1ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

return OpsSkateboardList1ItemView
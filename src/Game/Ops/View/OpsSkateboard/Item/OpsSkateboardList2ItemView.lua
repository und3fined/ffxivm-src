--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-03-31 15:07:36
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-03-31 15:09:29
FilePath: \Script\Game\Ops\View\OpsSkateboard\Item\OpsSkateboardList2ItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local TaskUIView = require("Game/Ops/View/OpsActivity/Item/OpsWhaleMonutRebatesList1ItemView")
local LuaClass = require("Core/LuaClass")
---@class OpsSkateboardList2ItemView : TaskUIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot CommBtnSView
---@field ImgBG UFImage
---@field TableViewSlot UTableView
---@field TextList UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsSkateboardList2ItemView = LuaClass(TaskUIView, true)

return OpsSkateboardList2ItemView
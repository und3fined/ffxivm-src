---
--- Author: ds_herui
--- DateTime: 2024-12-05 16:11
--- Description:
---
local MailDefine = require("Game/Mail/MailDefine")
local UIViewID = require("Define/UIViewID")
local UIBindableList = require("UI/UIBindableList")
local MailSlotItemViewVM = require("Game/Mail/View/Item/MailSlotItemViewVM")

local LSTR = _G.LSTR

local MailUtil = {}

-- 获取发件箱类型id
---@param InBoxID number @发件箱类型ID
---@return number    nil @没有找到
function MailUtil.GetOutBoxID(InBoxID)
    local TypeStr = table.find_item(MailDefine.OutBoxMailID, InBoxID, "InBoxID") or {}
    return TypeStr.OutBoxID
end

-- 获取收件箱类型ID
---@param OutBoxID number @收件箱类型ID
---@return number 
function MailUtil.GetInBoxID(OutBoxID)
    local TypeStr = table.find_item(MailDefine.OutBoxMailID, OutBoxID, "OutBoxID") or {}
    return TypeStr.InBoxID
end

-- 打开通用奖励面板
function MailUtil.OpenRewardPanel(ItemList)
	local VMList = UIBindableList.New(MailSlotItemViewVM)
	local NewItemList = {}
	for _, V in ipairs(ItemList) do
		if NewItemList[V.ResID] ~= nil then
			NewItemList[V.ResID].Num = NewItemList[V.ResID].Num + V.Num
		else
			NewItemList[V.ResID] = { ResID = V.ResID, Num = V.Num }
		end
	end

	for _, V in pairs(NewItemList) do
		VMList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, IsValid = true, NumVisible = true, ItemNameVisible = true }, nil, true)
	end
	_G.UIViewMgr:ShowView(UIViewID.CommonRewardPanel, { Title = LSTR(740015), ItemVMList = VMList })
end

--拿发送者名称
---@param Sender string @发送者的RoleID
---@param MailType 邮件类型
function MailUtil.GetMailSenderName(Sender)
    Sender = Sender or ""
	if string.find(Sender, "[^0-9]") then
		return Sender
	else
		local RoleVM = _G.RoleInfoMgr:FindRoleVM(tonumber(Sender), true)
		if nil == RoleVM then
			return ""
		end
		return RoleVM.Name or ""
	end
end

-- 邮件id 服务器ID转客户端Id
---@param SeverID number @服务器ID
---@param InBoxType number @收件箱类型
---@return number    
function MailUtil.SeverIDToClientID(SeverID, InBoxType)
    if SeverID == nil then return 0 end
    return (InBoxType << 32) + SeverID
end

-- 邮件id 客户端ID转服务器Id
---@param ClientID number @发件箱类型ID
---@return number    
function MailUtil.ClientIDToSeverID(ClientID)
    if ClientID == nil then return 0 end
    return ClientID & 0xFFFFFFFF
end

function MailUtil.SIDListToCIDList(SeverIDList, InBoxType)
    local ResList = {}
    if not table.empty(SeverIDList) then 
        for i = 1, #SeverIDList do
            table.insert(ResList, MailUtil.SeverIDToClientID(SeverIDList[i], InBoxType))
        end
    end
   
    return ResList
end

function MailUtil.CIDListToSIDList(ClientIDList)
    local ResList = {}
    if not table.empty(ClientIDList) then 
        for i = 1, #ClientIDList do
            table.insert(ResList, MailUtil.ClientIDToSeverID(ClientIDList[i]))
        end
    end
   
    return ResList
end


return MailUtil
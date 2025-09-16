--
-- Author: anypkvcai
-- Date: 2020-08-06 14:08:10
-- Description:
--

local pb = require "pb"
local pbslice = require "pb.slice"

local FLOG_ERROR = _G.FLOG_ERROR
local FDIR_EXISTFILE = _G.FDIR_EXISTFILE
local FDIR_PERSISTENT_RELATIVE = _G.FDIR_PERSISTENT_RELATIVE
local FDIR_CONTENT_RELATIVE = _G.FDIR_CONTENT_RELATIVE

local ProtoBuff = {
	ProtoBP = { "ProtoCommon.pb", "ProtoCS.pb", "ProtoRes.pb" }
}

---LoadProtoBP
---no_default_values    do not default values for decoded message Table (default)
---use_default_values    set default values by copy values from default Table before decode
---use_default_metaTable    set default values by set Table from pb.default() as the metaTable
function ProtoBuff:LoadProtoBP()
	pb.option("use_default_values")
	pb.option("enum_as_value")

	local function Load(Name)
		local Path = string.format("%s/ProtoPB/%s", FDIR_PERSISTENT_RELATIVE(), Name)
		if not FDIR_EXISTFILE(Path) then
			Path = string.format("%s/ProtoPB/%s", FDIR_CONTENT_RELATIVE(), Name)
		end

		if not FDIR_EXISTFILE(Path) then
			FLOG_ERROR("ProtoBuff:LoadProtoBP error,filename=%s", Name)
			return
		end

		pb.loadufsfile(Path)
	end

	for i = 1, #self.ProtoBP do
		Load(self.ProtoBP[i])
	end

end

---UnLoadProtoBP
function ProtoBuff:UnLoadProtoBP()
	pb.clear()
end

---Encode encode a message Table into binary form to buffer
---@param Type string
---@param Table table
---@param Buffer table
function ProtoBuff:Encode(Type, Table, Buffer)
	return pb.encode(Type, Table, Buffer)
end

---Decode decode a binary message into a given lua table
---@param Type string
---@param Data table
---@param Table table
function ProtoBuff:Decode(Type, Data, Table)
	return pb.decode(Type, Data, Table)
end

---DecodeAsync decode a binary message into a given lua table async
---@param Type string
---@param Data table
---@param Callback fun(Table : table|nil) 无论成功失败都会调用, 失败传nil
---@param TimeLimit number|nil 每次tick最大用时(ms), 0表示没有限制, 默认5ms
---@param Table table|nil
function ProtoBuff:DecodeAsync(Type, Data, Callback, TimeLimit, Table)
	local _ <close> = CommonUtil.MakeProfileTag("ProtoBuff:DecodeAsync")
	local TypeDesc = pb.typedesc(Type)
	local Slice = pbslice.new(Data)
	if not TypeDesc or not Slice then
		Callback(nil)
		return
	end

	TimeLimit = TimeLimit or 5
	local SlicingMgr = SlicingMgr

	local co = coroutine.create(function()
		local bDone = false
		while not bDone do
			do
				local _ <close> = CommonUtil.MakeProfileTag("ProtoBuff:DecodeAsyncFrame")
				Table, bDone = pb.decodeasync(TypeDesc, Slice, Table, TimeLimit)
			end
			SlicingMgr:YieldCoroutine()
		end
		Callback(Table)
	end)

	SlicingMgr:EnqueueCoroutineHighPriority(co)
end

return ProtoBuff
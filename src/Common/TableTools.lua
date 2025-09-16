--表相关操作

local Json = require("Core/Json")

local TableTools = {}

TransferedTableName = {}

--清空表
function TableTools.ClearTable(T)
	if T == nil or type(T) ~= "table" then
		return
	end

	for k, _ in pairs(T) do
		T[k] = nil
	end
end

--快速清空表（不安全）
function TableTools.ClearQuick(T)
    if T == nil then
		return
	end
	for k, _ in pairs(T) do
		T[k] = nil
	end
end

--删除一个表元素
function TableTools.RemoveTableElement(T, E, Name)
	if (T ~= nil and type(T) == "table") then
		local Count = #T
		if (Count > 500) then
			--FLOG_WARNING("remove table item num > 500 !!!, please use map!")

			local TraceBack = debug.traceback()
			FLOG_ERROR("TableTools.RemoveTableElement() "..TraceBack)
		end

		for i = 1, Count do
			if nil == Name then
				if (E == T[i]) then
					return table.remove(T, i)
				end
			else
				if (E == T[i][Name]) then
					return table.remove(T, i)
				end
			end
		end
	end
end

table.remove_item = TableTools.RemoveTableElement

--删除多个表元素
function TableTools.RemoveTableElements(T, Start)
	if (T ~= nil and type(T) == "table") then
		for i = #T, 1, -1 do
			if (i > Start) then
				table.remove(T, i)
			end
		end
	end
end

--查找一个表元素
function TableTools.FindTableElement(T, E, Name)
	if (T ~= nil and type(T) == "table") then
		local Count = #T
		if (Count > 500) then
			--FLOG_WARNING("find table item num > 500 !!!, please use map!")
			local TraceBack = debug.traceback()
			FLOG_ERROR("TableTools.FindTableElement() "..TraceBack)
		
		end

		for i = 1, Count do
			if nil == Name then
				if (E == T[i]) then return E, i end
			else
				if (E == T[i][Name]) then return T[i], i end
			end
		end
	end
end

table.find_item = TableTools.FindTableElement

--- 通过筛选条件查找元素
---@param T table @表格
---@param P function @筛选条件
function TableTools.FindTableElementByPredicate(T, P)
	if (T ~= nil and type(T) == "table") then
		for k, v in pairs(T) do
			if P(v) then
				return v, k
			end
		end
	end
end

table.find_by_predicate = TableTools.FindTableElementByPredicate

function TableTools.FindTableAllElementByPredicate(T, P)
	if nil == T or type(T) ~= "table" then
		return
	end

	local Ret = {}

	for _, v in pairs(T) do
		if P(v) then
			table.insert(Ret , v)
		end
	end

	return Ret
end

table.find_all_by_predicate = TableTools.FindTableAllElementByPredicate


table.clear = TableTools.ClearQuick

--清空转换的Lua表
function TableTools.ClearTransferedTable()
    for i = #TransferedTableName, 1, -1 do
        --print (TransferedTableName)
        TableTools.ClearTable(_G[TransferedTableName[i]])
    end
end

--Array是否已转换为LuaTable
function TableTools.ArrayExist(TableName, ID, ArrayName)
	if _G[TableName] == nil then
		return 0
	end

	if _G[TableName][ID] == nil then
		return 0
	end

	if _G[TableName][ID][ArrayName] == nil then
		return 0
	end
	return 1
end

--[[
--将DB中的数组字符串转为LuaTable
--TableName: 表名
--ID: ID列数，整型
--ArrayName: 数组名称
--ArrayString: 数组字符串
function TableTools.ArrayToLuaTable(TableName, ID, ArrayName, ArrayString)
	--print (table_to_string(ArrayString))
	if _G[TableName] == nil then
        _G[TableName] = {}
        table.insert(TransferedTableName, TableName)
	end

	if _G[TableName][ID] == nil then
		_G[TableName][ID] = {}
	end

	if _G[TableName][ID][ArrayName] == nil then
		_G[TableName][ID][ArrayName] = Json.decode(ArrayString)

		--_G[TableName][ID][ArrayName] = {}
		--
		--local func = load("_G." .. TableName .. "[" .. ID .. "]." .. ArrayName .. " = " .. ArrayString)
		--if func then
		--	func()
		--else
		--	FLOG_ERROR(string.format("ArrayToLuaTable failed: %s[%d]%s", TableName, ID, ArrayName))
		--end
	end
end

--将table string转为json格式
function TableTools.TableStringToJson(TableString)
	local ret = load("return "..TableString)()
	local json = require("Core/Json").encode(ret)
	return json
end
--]]

local function CheckValue(retValue, retType)
	if retValue == nil then
		return -1
	end

	if retType == 'number' then
		if type(retValue) == retType then
			return retValue
		else
			return -1
		end
	elseif retType == 'string' then
		if type(retValue) == retType then
			return retValue
		else
			return ""
		end
	else
		return -1
	end
end

--C++端访问: ElementName为LuaTable的字段名
--Lua端访问: c_skill_sub_cfg[1].HitList[1].AreaNum
local function GetArrayElement(TableName, ID, ArrayName, RowIndex, ElementName)
	return _G[TableName][ID][ArrayName][RowIndex][ElementName]
end

--C++端访问第2级数组内元素
--Lua端访问第2级数组内元素: c_skill_sub_cfg[1].HitList[1].AreaList[1].XXX
local function GetArrayElement2(TableName, ID, Array1Name, RowIndex1, Array2Name, RowIndex2, ElementName)
	local ret = _G[TableName][ID][Array1Name][RowIndex1][Array2Name][RowIndex2]

	if ElementName ~= nil and ElementName ~= "" then
		return ret[ElementName]
	end
	return ret
end

--获取数值型字段
function TableTools.GetNumberElement(TableName, ID, ArrayName, RowIndex, ElementName)
	local retValue = GetArrayElement(TableName, ID, ArrayName, RowIndex, ElementName)

	return CheckValue(retValue, 'number')
end

--获取字符型字段
function TableTools.GetStringElement(TableName, ID, ArrayName, RowIndex, ElementName)
	local retValue = GetArrayElement(TableName, ID, ArrayName, RowIndex, ElementName)

	return CheckValue(retValue, 'string')
end

--获取数值型字段
function TableTools.GetNumberElement2(TableName, ID, Array1Name, RowIndex1, Array2Name, RowIndex2, ElementName)
	local retValue = GetArrayElement2(TableName, ID, Array1Name, RowIndex1, Array2Name, RowIndex2, ElementName)

	return CheckValue(retValue, 'number')
end

--获取字符型字段
function TableTools.GetStringElement2(TableName, ID, Array1Name, RowIndex1, Array2Name, RowIndex2, ElementName)
	local retValue = GetArrayElement2(TableName, ID, Array1Name, RowIndex1, Array2Name, RowIndex2, ElementName)

	return CheckValue(retValue, 'string')
end

--table转string，方便打印luatable查看
function TableTools.table_to_string(T)
	local Result = {}

	if type(T) == "table" then
		table.insert(Result, "{")
		for k, v in pairs(T) do
			local KeyStr = tostring(k)
			if type(k) == "string" then
				KeyStr = string.format("%s", k)
			end
			table.insert(Result, KeyStr .. "=")
			table.insert(Result, TableTools.table_to_string(v))
			table.insert(Result, ",")
		end
		if Result[#Result] == ',' then
			table.remove(Result, #Result)
		end
		table.insert(Result, "}")
	else
		table.insert(Result, tostring(T))
	end

	return table.concat(Result)
end

_G.table_to_string = TableTools.table_to_string

table.tostring = TableTools.table_to_string

local function DoSpace(InConcat, Level)
    local Space = "  "

    for _ = 1, Level do
        table.insert(InConcat, Space)
    end
end

 local function Table2StrInner(Table, Level, InConcat, MaxLevel)
    table.insert(InConcat, "\n")
    DoSpace(InConcat, Level - 1)
    table.insert(InConcat,"{\n")
    for K, V in pairs(Table) do
        DoSpace(InConcat, Level)
        if type(K) == "number" then
            table.insert(InConcat, "[")
            table.insert(InConcat, tostring(K))
            table.insert(InConcat, "]")
            table.insert(InConcat, " = ")
        else
            table.insert(InConcat, tostring(K))
            table.insert(InConcat, " = ")
        end

        if type(V) == "number" or type(V) == "boolean" then
            table.insert(InConcat, tostring(V))
        elseif type(V) == "string" then
            table.insert(InConcat, V == "" and "[empty string]" or V)
        elseif type(V) == "function" then
            table.insert(InConcat, "[function]")
        elseif type(V) == "table" then
            if Level >= MaxLevel then
                table.insert(InConcat, "{...}")
            else
                Table2StrInner(V, Level + 1, InConcat, MaxLevel)
            end
        elseif type(V) == "userdata" then
            table.insert(InConcat, "[userdata]")
        else
            table.insert(InConcat, "[undefine]")
        end
        table.insert(InConcat, "\n")
    end
    DoSpace(InConcat, Level-1)
    table.insert(InConcat,"}\n")
 end

 function TableTools.table_to_string_block(Table, MaxLevel)
	if nil == Table then
		return "nil"
	end

    MaxLevel = MaxLevel or 5
    local Concat = {}
    Table2StrInner(Table,1,Concat,MaxLevel)
    return table.concat(Concat)
 end

_G.table_to_string_block = TableTools.table_to_string_block

table.tostring_block = TableTools.table_to_string_block

function TableTools.deepcopy(orig, deep_copy_metatable)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[TableTools.deepcopy(orig_key)] = TableTools.deepcopy(orig_value)
		end
		if deep_copy_metatable then
			setmetatable(copy, TableTools.deepcopy(getmetatable(orig)))
		else
			setmetatable(copy, getmetatable(orig))
		end
	else
		-- number, string, boolean, etc
        copy = orig
    end
    return copy
end

table.deepcopy = TableTools.deepcopy

table.length = function(t)
	local length = 0
	for _,_ in pairs(t) do
		length = length + 1
	end
	return length
end

table.is_array = function(t)
	-- test if there is any value in the "array part" of the table, then checks if there is any value after that part,
	-- by using next with the last consecutive numeric index
	-- https://stackoverflow.com/a/66370080/254681
	return type(t) == 'table' and (#t > 0 or next(t) == nil)
end

local GNext = _G.next
table.empty = function(t)
	return GNext(t) == nil
end

--- Find the number of elements in a table.
-- @param t table
-- @return number of elements in t
table.size = function (t)
  local n = 0

  for _ in pairs (t) do
    n = n + 1
  end

  return n
end

--- Make the list of indices of a table.
-- @param t table
-- @return list of indices
table.indices = function (t)
  local u = {}

  for i, _ in pairs (t) do
    table.insert (u, i)
  end

  return u
end

--- Make the list of values of a table.
-- @param t table
-- @return list of values
table.values = function (t)
  local u = {}

  for _, v in pairs (t) do
    table.insert (u, v)
  end

  return u
end

--- Invert a table.
-- @param t table <code>{i=v, ...}</code>
-- @return inverted table <code>{v=i, ...}</code>
table.invert = function (t)
  local u = {}

  for i, v in pairs (t) do
    u[v] = i
  end

  return u
end

-- Make the list of extract value from a table 
-- @param t table
-- @param name key name
table.extract = function(t, name)
	local u = {}
	if nil == t or nil == name then
		return u
	end

	for _, v in pairs (t) do
		if type(v) == 'table' then
			local r = v[name]
			if r then
				table.insert(u, r)
			end
		end
	end

	return u
end

-- Whether the value is included in the table
-- @param t table
-- @param e value 
-- @return ret bool 
table.contain = function (t, e)
	if type(t) ~= 'table' then
		return false
	end

	for _, v in pairs(t) do
		if v == e then
			return true
		end
	end

	return false
end

-- Whether the value of the specific name is included in the table
-- @param t table
-- @param e value
-- @param name attribute name
-- @return ret bool
table.containAttr = function (t, e, name)
	for _, v in pairs(t) do
		if v ~= nil and v[name] == e then
			return true
		end
	end
	return false
end

--- Make an index of a list of tables on a given field
-- @param f field
-- @param l list of tables <code>{t<sub>1</sub>, ...,
-- t<sub>n</sub>}</code>
-- @return index <code>{t<sub>1</sub>[f]=1, ...,
-- t<sub>n</sub>[f]=n}</code>
table.indexKey = function (f, l)
	local m = {}

	for i, v in ipairs (l) do
		local k = v[f]
		if k then
			m[k] = i
		end
	end

	return m
end

--- Copy a list of tables, indexed on a given field
-- @param f field whose value should be used as index
-- @param l list of tables <code>{i<sub>1</sub>=t<sub>1</sub>, ...,
-- i<sub>n</sub>=t<sub>n</sub>}</code>
-- @return index <code>{t<sub>1</sub>[f]=t<sub>1</sub>, ...,
-- t<sub>n</sub>[f]=t<sub>n</sub>}</code>
table.indexValue = function (f, l)
	local m = {}

	for _, v in ipairs (l) do
		local k = v[f]
		if k then
			m[k] = v
		end
	end

	return m
end

--- Make a shallow copy of a table, including any metatable (for a
-- deep copy, use tree.clone).
-- @param t table
-- @param nometa if non-nil don't copy metatable
-- @param nonewindex if non-nil don't copy __newindex
-- @return copy of table
table.clone = function (t, nometa, nonewindex)
    local u = {}
    if not nometa then
		local mt = getmetatable (t)
		if nonewindex then
			mt = table.clone(mt)
			mt.__newindex = nil
		end
        setmetatable (u, mt)
    end

    for i, v in pairs (t) do
        u[i] = v

		if nometa and type(u[i]) == "table" then
			setmetatable (u[i], nil)
		end
    end

    return u
end

table.shallowcopy = table.clone

--- Merge two tables.
-- If there are duplicate fields, u's will be used. The metatable of
-- the returned table is that of t.
-- @param t first table
-- @param u second table
-- @return merged table
table.merge = function (t, u)
    local r = table.clone (t)

    for i, v in pairs (u) do
        r[i] = v
    end

    return r
end

--- 合并数组类型表并排序
-- @param pred 排序函数
-- @param ... 排序可变长度参数列表，任意多个数组类型表
-- @return 合并数组并排序后的结果
table.array_concat_sort = function(pred, ...)
	local n = table.array_concat(...)
	table.sort(n, pred)
	return n
end


--- 合并数组类型表
-- @param ... 排序可变长度参数列表，任意多个数组类型表
-- @return 合并数组后的结果
table.array_concat = function(...)
	local args = table.pack(...)
	local r = {}
	for _, array in ipairs(args) do
		for _, e in ipairs(array) do
			table.insert(r, e)
		end
	end

	return r
end

---append_table @把u中的元素添加到t中
---@param t table
---@param u table
table.merge_table = function(t, u)
	if u then
		for _, v in pairs(u) do
			table.insert(t, v)
		end
	end
	return t
end

---array_remove_item_pred 根据预测函数移除数组类型表里的元素
---@param t table
---@param pred function 预测函数
---@param n number | nil 数量， 不填全部移除
table.array_remove_item_pred = function(t, pred, n)
	n = n or #t
	local Count = 0
	for i = #t, 1, -1 do
		if pred(t[i]) then
			table.remove(t, i)
			Count = Count + 1
			if n == Count then
				break
			end
		end
	end

	return Count > 0
end

--- array_add_unique
---@param t table
---@param e any
table.array_add_unique = function(t, e)
	for _, v in ipairs(t) do
		if v == e then
			return
		end
	end

	t[#t + 1] = e
end

local function DeflautCompare(a, b)
	return a == b
end

---@param t1 t2 set
---@param pred function for compare a to b, if there is no value, the deflaut compare are used
---@return table
table.set_overlap = function(t1, t2, pred)
	local r = {}
	pred = pred or DeflautCompare
	for _, m in pairs(t1) do
		for _, s in pairs(t2) do
			if pred(m, s) then
				table.insert(r, m)
				break
			end
		end
	end

	return r
end

---@param t1 t2 set
---@param pred function function for compare a to b
---@return boolean
table.set_has_overlap = function(t1, t2, pred)
	pred = pred or DeflautCompare
	for _, m in pairs(t1) do
		for _, s in pairs(t2) do
			if pred(m, s) then
				return true
			end
		end
	end

	return false
end

---@param T table
---@return table
table.shuffle = function(T)
	for i=#T, 2, -1 do
		local j = math.random(i)
        T[i], T[j] = T[j], T[i]
	end
    return T
end

---compare_table @比较t和u中元素
---@param t table
---@param u table
---@return boolean
table.compare_table = function(t, u)
	if t == u then
		return true
	end
	if t == nil or u == nil then
		return false
	end
	if #t ~= #u then
        return false
    end
    for k, v in pairs(t) do
        if type(v) == "table" and type(u[k]) == "table" then
            if not table.compare_table(v, u[k]) then
                return false
            end
        else
            if v ~= u[k] then
                return false
            end
        end
    end

    return true
end

---@function 无序返回table的所有key组成的列表
---@param t table
---@return table
table.keys = function(t)
	local r = {}
	for k, _ in pairs(t) do
		table.insert(r, k)
	end

	return r
end

--- 是否是nil或空表
---@param t table
---@return boolean
function TableTools.IsNilOrEmpty(t)
    return not t or type(t) ~= "table" or not next(t)
end
table.is_nil_empty = TableTools.IsNilOrEmpty


--- make a set from a variable list (only one layer considered), which all elements are keys with a boolean true.
---@param ... any
---@return table
table.makeset = function(...)
	local aset = {}
	local count = select("#", ...)  -- Get the number of arguments
    for i = 1, count do
        local t = select(i, ...)  -- Get the i-th argument
        if type(t) == "table" then
			for _, v in pairs(t) do
				aset[v] = true
			end
		elseif t ~= nil then
			aset[t] = true
		end
    end

	return aset
end

local const_mt = {
	__newindex = function ()
		_G.FLOG_ERROR("set a const table, trace:\n%s", debug.traceback())
	end
}

table.makeconst = function (t)
	return setmetatable(t, const_mt)
end

-- 判断 table 是否连续数组
local function is_continuous_array(t)
	local count = 0
	-- 统计表中元素的数量
	for _ in pairs(t) do
		count = count + 1
	end
	-- 检查从 1 到元素数量的索引是否都有对应的值
	for i = 1, count do
		if t[i] == nil then
			return false
		end
	end
	return true
end

local function is_need_convert(t)
	continuous_array = is_continuous_array(t)
	for k, v in pairs(t) do
		if type(k) ~= "string" then
			if not continuous_array then
				return true
			end
		elseif type(v) == "table" then
			if is_need_convert(v) then
				return true
			end
		end
	end
	return false
end


-- 递归将非字符串键转换为字符串，连续数组保持不变，但数组中的值如果是 table 也要转换
local function convert_keys_to_strings(t)
	-- 如果不是 table，直接返回
	if type(t) ~= "table" then
		return t
	end

	-- 如果是连续数组，创建一个新的数组并递归处理每个元素
	if is_continuous_array(t) then
		local new_array = {}
		for i, v in ipairs(t) do
			new_array[i] = convert_keys_to_strings(v)
		end
		return new_array
	end

	-- 如果不需要转换，直接返回原 table
	if not is_need_convert(t) then
		return t
	end

	-- 创建新 table 并转换键
	local new_table = {}

	for k, v in pairs(t) do
		local new_key = type(k) == "string" and k or tostring(k)
		new_table[new_key] = convert_keys_to_strings(v)
	end
	return new_table
end

--命名规范和其他接口统一，没用UE的命名规范
table.is_continuous_array = is_continuous_array
table.convert_keys_to_strings = convert_keys_to_strings

return TableTools
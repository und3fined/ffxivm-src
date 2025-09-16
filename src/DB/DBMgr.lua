--
-- Author: anypkvcai
-- Date: 2020-10-22 15:14:28
-- Description:
--

local UDBMgr = _G.UE.UDBMgr.Get()

local DBMgr = {}

function DBMgr.Init()
    UDBMgr = _G.UE.UDBMgr.Get()
end

---ReloadDataBase
function DBMgr.ReloadDataBase()
    UDBMgr:ReloadDataBase()
    TableTools.ClearTransferedTable();
end

---GetOneRow
---@param TableName string
---@param SearchConditions string       @SQL
---@return userdata                     @FSQLiteResultSet
function DBMgr.GetOneRow(TableName, SearchConditions)
    return UDBMgr:GetOneRow(TableName, SearchConditions)
end

---GetOneRowByIndex
---@param TableName string
---@param Index number
---@return userdata                     @FSQLiteResultSet
function DBMgr.GetOneRowByIndex(TableName, Index)
    return UDBMgr:GetOneRowByIndex(TableName, Index)
end

---GetColumnType
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param ColumnName string
---@return userdata                     @EDataBaseUnrealTypes
function DBMgr.GetColumnType(SQLiteResultSet, ColumnName)
    return UDBMgr:GetColumnType(SQLiteResultSet, ColumnName)
end

---GetColumnTypeByIndex
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param Index number                  @Column index
---@return userdata                     @EDataBaseUnrealTypes
function DBMgr.GetColumnTypeByIndex(SQLiteResultSet, Index)
    return UDBMgr:GetColumnTypeByIndex(SQLiteResultSet, Index)
end

---GetMultiRow
---@param TableName string
---@param SearchConditions string       @SQL
---@return userdata                     @FSQLiteResultSet
function DBMgr.GetMultiRow(TableName, SearchConditions)
    return UDBMgr:GetMultiRow(TableName, SearchConditions)
end

---GetCount
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@return number
function DBMgr.GetCount(SQLiteResultSet)
    return UDBMgr:GetCount(SQLiteResultSet)
end

---MoveTo
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param RowNum number
function DBMgr.MoveTo(SQLiteResultSet, RowNum)
    return UDBMgr:MoveTo(SQLiteResultSet, RowNum)
end

---Next
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@return userdata                     @FSQLiteResultSet
function DBMgr.Next(SQLiteResultSet)
    return UDBMgr:Next(SQLiteResultSet)
end

---Reset
---@param SQLiteResultSet userdata      @FSQLiteResultSet
function DBMgr.Reset(SQLiteResultSet)
    return UDBMgr:Reset(SQLiteResultSet)
end

---Destroy
---@param SQLiteResultSet userdata      @FSQLiteResultSet
function DBMgr.Destroy(SQLiteResultSet)
    return UDBMgr:Destroy(SQLiteResultSet)
end

---GetInt32
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param ColumnName string
---@return number
function DBMgr.GetInt32(SQLiteResultSet, ColumnName)
    return UDBMgr:GetInt32(SQLiteResultSet, ColumnName)
end

---GetInt64
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param ColumnName string
---@return number
function DBMgr.GetInt64(SQLiteResultSet, ColumnName)
    return UDBMgr:GetInt64(SQLiteResultSet, ColumnName)
end

---GetFloat
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param ColumnName string
---@return number
function DBMgr.GetFloat(SQLiteResultSet, ColumnName)
    return UDBMgr:GetFloat(SQLiteResultSet, ColumnName)
end

---GetString
---@param SQLiteResultSet userdata      @FSQLiteResultSet
---@param ColumnName string
---@return string
function DBMgr.GetString(SQLiteResultSet, ColumnName)
    return UDBMgr:GetString(SQLiteResultSet, ColumnName)
end





---GetOneRow
---@param TableName string
---@param SearchConditions string       @SQL
---@return table<string,any> | nil
function DBMgr.SelectOneRow(TableName, SearchConditions)
    return UDBMgr.SelectOneRow(TableName, SearchConditions)
end

---GetAllRow
---@param TableName string
---@param SearchConditions string       @SQL
---@return table<number,table> | nil
function DBMgr.SelectAllRow(TableName, SearchConditions)
    return UDBMgr.SelectAllRow(TableName, SearchConditions)
end

function DBMgr.SetResTableKeys(ResTableKeys)
    if nil == ResTableKeys then
        return
    end

    local Params = ResTableKeys[6]
    if nil == Params then
        return
    end

    UDBMgr.SetConvertParams(Params)
end

return DBMgr
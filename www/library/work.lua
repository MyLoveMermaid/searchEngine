-- 作品相关作品 index 库 文档type
_Work = { _index = "zk_user_works", _type = "work" }
-- 作品相关的字段
_Work["params"] = {"id", "name", "egname", "userlogin", "worktype", "from", "createtime", "status", "tag1", "tag2", "tag3", "desc"}
-- 添加作品必填字段
_Work["must_params_add"] = {"id", "name", "userlogin", "status", "from", "worktype", "createtime"}
-- 更新作品必填字段
_Work["must_params_update"] = {"id", "worktype"}
-- 删除作品必须字段
_Work["must_params_del"] = {"id","worktype"}

-- 获取子查询语句
local function subQuery(_type, key, value)
	_tmp = {}
    if _type == "term" then 
		_tmp[key] = value
		return { term = _tmp }
	end
	if _type == "wildcard" then 
		_tmp[key] = "*"..value.."*"
	    return { wildcard = _tmp }
	end
end
-- 判断value是否在list中
local function inArray(value, list)
	if next(list) == nil then
		return false
	end
	for _, v in pairs(list) do
		if value == v then
			return true
		end
	end
	return false
end
-- 获取完整查询语句
function _Work.getQueryStr(args)
	query_str = { from = 0, size = 10}
	must_str = {}
    -- term 子查询语句字段
	term_arr = {"keyid", "id", "userlogin", "worktype", "from", "status", "tag1", "tag2", "tag3"}
    -- wildcard 子查询语句字段
	wildcard_arr = {"name", "egname", "desc"}
	for k, v in pairs(args) do 
		if inArray(k, term_arr) == true then
			sub_query_str = subQuery("term", k, v)
			table.insert(must_str, sub_query_str)
		end
		if inArray(k, wildcard_arr) == true then
			sub_query_str = subQuery("wildcard", k, v)
			table.insert(must_str, sub_query_str)
		end
	end
	range = {}
	createtime = {}
    time_str = ""
	start_time = tonumber(args["starttime"])
	if  start_time ~= nil and start_time > 0 then
		createtime["gte"] = start_time
	end
	
	end_time = tonumber(args["endtime"])
	if  end_time ~= nil and end_time > 0 then
		createtime["lte"] = end_time
	end
        len = string.len(time_str)
	if len > 0 then 
	    time_str = string.sub(time_str, 0, len-1)
            createtime = {time_str}
        end 
	if next(createtime) ~= nil then
		range = {
			range = {
				createtime = createtime
			}
		}
	    table.insert(must_str, range)
	end
	size = tonumber(args["limit"])
	page = tonumber(args["page"])
	from = (page - 1) * size
    -- sort 排序方式 此处按 createtime desc 排序作品
	sort = {
	    { createtime = { order = "desc"} }
	}
	query_str = {
        from = from,
        size = size,
        sort = sort
    }
	
	if next(must_str) == nil then
	    return query_str
	end
	query_str = {
	    from = from,
		size = size,
		query = {
			bool = {
				must = must_str
			}
        },
		sort = sort
	}
	return query_str
end

-- 校验必须参数
function _Work.checkParams(args, must_params_type)
    must_params = _Work[must_params_type]
	for k, v in pairs(must_params) do
	    if args[v] == nil then
		    return false
		end
	end
	return true
end
-- 组合参数
function _Work.makeInfo(args, method)
    params = _Work["params"]
	info = {}
	info["keyid"] = args["worktype"].."_"..args["id"]
	for _ ,v in pairs(params) do
        if method == "update" and args[v] ~= nil then
            info[v] = args[v]
        else
	        info[v] = args[v]
        end
	end
	return info
end

return _Work

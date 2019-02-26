--package.path = "/usr/local/openresty/www"
local cjson = require "cjson"
local elastic = require "resty.elasticsearch.client"
local redis = require "resty.redis"
local conf = require "conf.conf"
local work = require "library.work"
local request = require "util.request"
-- 获取请求参数 并默认 page=1 limit=10
function getArgs()
	args = request.getArgs()
	limit = tonumber(args["limit"])
	if  limit ~= nil and limit > 0 then
		args["limit"] = limit
	else
		args["limit"] = 10
	end
	page = tonumber(args["page"])
	if  page ~= nil and page > 0 then
		args["page"] = page
	else
		args["page"] = 1
	end
	return args
end

local args = getArgs()
if next(args) == nil then
    request.responseFail("param_err")
end
--ngx.say(cjson.encode(args))
-- 判断是否使用cache 如果使用cache 需要连接redis 获取缓存 查到缓存直接返回 否则继续向下执行
if tonumber(args["use_cache"]) == 1 then
    -- cache_key 通过请求参数md5 得到
    cache_key = ngx.md5(cjson.encode(args))
    red = redis:new()
    red:set_timeout(1000)
    local ok, err = red:connect(conf["redis"]["host"], conf["redis"]["port"])
    if not ok then
        request.responseFail("redis_connect_err")
    end
    --ngx.say("connect redis ok")
    -- 请注意这里 auth 的调用过程
    local count
    count, err = red:get_reused_times()
    if 0 == count then
        ok, err = red:auth(conf["redis"]["auth"])
        if not ok then
            request.responseFail("redis_auth_pwd_err")
        end
    elseif err then
        request.responseFail("redis_get_resu_time_err")
    end
    res, err = red:get(cache_key)
    if res ~= ngx.null then
        request.responseSucc(cjson.decode(res))
    end
end
-- 初始化es
local el = elastic:new(conf["elastic"])
-- 初始化连接的 es index
function initSearch(search_type)
	search_arr = { work = work }
	search = search_arr[search_type]
	return search
end

local search = initSearch(args["search_type"]) 
if search == nil then
	request.responseFail("search_type_err")
end

el:index(search["_index"])
el:type(search["_type"])

--ngx.say(search["_index"])
--ngx.exit(200)
-- 获取index type 中是否有文档
local ok, err = el:count()
if ok then
    total_docs = ok
else 
    request.responseFail(conf["err_code"]["no_docs"])
end
-- 根据请求参数 组合获取query_str 查询语句
local query_str = search.getQueryStr(args)

if next(args) == nil then
    request.responseFail("param_err")
end
-- 搜索
local res, err = el:search(query_str)
-- 格式化返回搜索结果
if res then
	res = cjson.decode(res)
	total = res["hits"]["total"]
	content = {}
    if total == 0 then
        content = { total = 0 }
        request.responseSucc(content)
        --ngx.say("find total "..total)
    end
    res = res["hits"]["hits"]
    --ngx.say(type(data))
    data = {}
    for k, v in pairs(res) do
        source = v["_source"]
        table.insert(data, source)
    end
    
	content["current_page"] = args["page"]
	content["limit"] = args["limit"]
	content["total"] = total
	content["total_page"] = math.ceil(total / args["limit"])
    content["data"] = data
    -- 如果使用cache 需要设置redis 缓存以及expire时间
    if tonumber(args["use_cache"]) == 1 then
        red:set(cache_key, cjson.encode(content))
        red:expire(cache_key, conf["redis"]["expire"])
    end
    request.responseSucc(content)
else 
    request.responseFail("search_err")
end

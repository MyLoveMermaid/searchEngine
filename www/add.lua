--package.path = "/usr/local/openresty/www"
local cjson = require "cjson"
local elastic = require "resty.elasticsearch.client"
local redis = require "resty.redis"
local conf = require "conf.conf"
local work = require "library.work"
local request = require "util.request"

-- 获取请求参数
local args = request.getArgs()
if next(args) == nil then
    responseFail("param_err")
end
-- 初始化es
local el = elastic:new(conf["elastic"])
-- 初始化连接的es index
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
-- 校验必须参数
local check_params = search.checkParams(args, "must_params_add")
if check_params == false then
	request.responseFail("param_err")
end
-- 组合参数
local add_info = search.makeInfo(args, "add")
local id = add_info["keyid"]
-- 创建索引
local ok, err = el:create(id, add_info)
-- 返回
if ok then
    request.responseSucc({})
else 
    request.responseFail("add err")
end

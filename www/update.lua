--package.path = "/usr/local/openresty/www"
local cjson = require "cjson"
local elastic = require "resty.elasticsearch.client"
local redis = require "resty.redis"
local conf = require "conf.conf"
local work = require "library.work"
local request = require "util.request"


local args = request.getArgs()
if next(args) == nil then
    responseFail("param_err")
end

local el = elastic:new(conf["elastic"])

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
local check_params = search.checkParams(args, "must_params_update")
if check_params == false then
	request.responseFail("param_err")
end

local update_info = search.makeInfo(args, "update")
local id = update_info["keyid"]
update_info  = { doc = update_info }
local ok, err = el:update(id, update_info)

if ok then
    request.responseSucc({})
else 
    request.responseFail("update err")
end
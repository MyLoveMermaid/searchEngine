--package.path = "/usr/local/openresty/www"
local cjson = require "cjson"
local conf = require "conf.conf"
_Request = {}

function _Request.responseSucc(data)
    ret = {}
    ret["result"] = 0
    ret["msg"] = "ok"
    ret["content"] = data
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode(ret))
    ngx.exit(200)
end


function _Request.responseFail(err)
    ret = {}
    ret["result"] = conf["err_code"][err]
    ret["msg"] = err
    ret["content"] = ""
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode(ret))
    ngx.exit(200)
end

function _Request.getArgs()
	request_method = ngx.var.request_method
	args = nil
	--获取参数的值
	if "GET" == request_method then
		args = ngx.req.get_uri_args()
	elseif "POST" == request_method then
		ngx.req.read_body()
		args = ngx.req.get_post_args()
	end
	return args
end

return _Request
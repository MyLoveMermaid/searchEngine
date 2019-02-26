conf = {}

conf["elastic"] = {
    { host = "127.0.0.1", port = 9201 }
}

conf["redis"] = {}
conf["redis"]["host"] = "127.0.0.1"
conf["redis"]["port"] = 6479
conf["redis"]["auth"] = "123456"
conf["redis"]["expire"] = 300

conf["err_code"] = {
    unknow_err = 100,
    param_err = 101,
    search_type_err = 102,
    search_err = 103,
    no_docs = 104,
    redis_connect_err = 105,
    redis_auth_pwd_err = 106,
    redis_get_resu_time_err = 107
}

return conf

-- conf 配置文件
conf = {}

-- elasticsearch 配置（可集群）
conf["elastic"] = {
    { host = "10.30.176.216", port = 9201 }
}

-- redis 相关配置
conf["redis"] = {}
conf["redis"]["host"] = "127.0.0.1"
conf["redis"]["port"] = 6479
conf["redis"]["auth"] = "1q2w3e4r5t"
conf["redis"]["expire"] = 300

-- 错误码说明
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

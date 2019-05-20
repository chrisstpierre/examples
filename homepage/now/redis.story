# Communicate with a Redis server.
http server as client
    when client listen method:'get' path:'/cache' as r
        key = r.query_params['key']
        result = redis/get key='cache-{key}'
        r write content:result

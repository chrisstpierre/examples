# API's
when http server listen path:'/user' as req
    user = psql exec query:'select ...'
    req write content:user

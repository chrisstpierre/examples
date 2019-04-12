
when http server listen method:'POST' path:'/alerts/create' as req
    # USER
    req.body['keyword']
    req.body['flags']
    req.body['whole_word']

when schedule cron every minutes:3
    
###
Clone of file.io to upload/download files
###
http server
    when listen path:'/' method:'POST' as req
        id = awesome id
        req write content:'https://{app.hostname}/?id={id}\n'
        req finish  # Go asynchronous from the upload client, closing it out
        storage put :id content:req.content
        events schedule name:'expire' data:{'id': id} delay:864000

    when listen path:'/' method:'GET' as req
        file = storage get id:req.query_params['id']
        if file
            req write content:file
            req finish
            storage delete id:events.data['id']
        else
            req set_status code:404
            req write content:'Not found'


when events listener triggered name:'expire' as events
    storage delete id:events.data['id']

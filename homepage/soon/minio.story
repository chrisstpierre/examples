# Store things in minio (S3 API)...
http server as client
    when client listen method:'post' path:'/store' as r
        upload = r.body['store']
        minio fputobject name:'mybucket' objectname:'converted.html' contents:upload

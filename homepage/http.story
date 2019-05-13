http server as client
    when client listen method:'get' path:'/' as r
        r write content:'Hello world!'

# Harness Pandoc, anywhere, to interchange data.
http server as client
    when client listen method:'post' path:'/md2html' as r
        doc = r.body['md']
        html = pandoc convert doc:doc format:'markdown' output:'html'
        r write content:html

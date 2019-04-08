when github webhooks listen event:'issues' as req

    if !(['labeled', 'opened'] contains item:req.body['action'])
        return

    gfis = ['good first issue', 'good-first-issue']
    if req.body['issue']['labels'] contains any:gfis
        html_url = req.body['issue']['html_url']
        repo = req.body['repository']['full_name']
        twitter tweet status:'New issue in {repo} - {html_url}'

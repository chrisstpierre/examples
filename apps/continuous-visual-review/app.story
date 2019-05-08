###
Listen for Netlify webhooks and take screenshots of changes
###
function getSlugFromUrl url:string returns string
    # https://github.com/owner/repo/... => owner/repo
    return url split by:'/' then slice from:3 to:5 then join by:'/'


when http server listen method:'post' path:'/webhooks' as req
    req set_status code:204
    req finish
    # go asynchronous from the web server perspective

    commit = req.body['commit_ref']
    slug = getSlugFromUrl(url:req.body['commit_url'])
    gh_url = '/repos/{slug}/commits/{commit}/statuses'
    paths = ['/events', '/faq']
    sizes = ['1200x800', '800x600']

    # set pending status
    github api method:'post' url:gh_url data:{
      'state': 'pending',
      'context': 'ci/visual',
      'description': 'Analyzing pages...'
    }

    # screenshot staging site
    pageres capture :paths :sizes dest:'/new' base_url:req.body['deploy_ssl_url']
    storage cp from:'/new/' to:'{slug}/{commit}/new/' recursive:true

    # screenshot production site
    pageres capture :paths :sizes dest:'/old' base_url:req.body['url']
    storage cp from:'/old/' to:'{slug}/{commit}/old/' recursive:true

    # diff the screenshots
    diffs = imagediff many before:'/old' after:'/new' results:'/diff'
    storage cp from:'/diff/' to:'{slug}/{commit}/diffs/' recursive:true

    # store the results
    storage put content:diffs dest:'{slug}/{commit}/results.json'

    # set final status
    if diffs.failed > 0
        state = 'failure'
        description = '{diffs.failed} pages changed.'
    else
        state = 'success'
        description = '{diffs.passed} are all same. :tada:'

    github api method:'post' url:gh_url data:{
      'state': state,
      'context': 'ci/visual',
      'description': description,
      'target_url': '{env.app_url}/{slug}/{commit}'
    }

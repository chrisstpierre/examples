when github webhooks receives event:['pull_request'] as req
    if !(['synchronize', 'opened', 'rerequested'] contains item:req.action)
        log info content:'Ignored action {req.action}'
        return

    if req.action == 'rerequested'
        if req['check_run']['check_suite']['pull_requests'] length != 1
            return
        pull_request = req['check_run']['check_suite']['pull_requests'][0]
    else
        pull_request = req['pull_request']

    if pull_request == null
        log warning content:"No 'pull_request' for action {req.action}!"
        return

    # https://api.github.com/repos/judepereira/platform-engine
    base_url = pull_request['base']['repo']['url']
    repo_full_name = req['repository']['full_name']

    res = github api endpoint:'/{repo_full_name}/pull/{pull_request["number"]}.diff'
                     app_id:req.data['installation']['id']

    added = diff(text:res.data)

    pr_head_sha = pull_request['head']['sha']
    check = {
        'name': 'No added/edited TODO items found',
        'head_sha': pr_head_sha,
        'status': 'completed',
        'completed_at': f'{datetime.now().isoformat()[:19]}Z'
    }

    if added length > 0
        check['conclusion'] = 'failure'
        check['name'] = 'Added/edited TODO items found'

        text = 'Added/edited TODO items found:\n'
        foreach added as e
            file_url = f'https://github.com/{repo_full_name}' \
                        f'/blob/{pr_head_sha}' \
                        f'/{e["file"]}#L{e["line"]}'

            this_line = f'[{e["file"]}#L{e["line"]}]({file_url}): ' \
                        f'`{e["content"]}`'

            # Append to the existing.
            text = f'{text} - {this_line}\n'

        output = {
            'title': 'Check TODO',
            'summary': f'{len(added)} added/edited TODO '
                        f'item(s) were found',
            'text': text
        }
        check['output'] = output
    
    else
        check['conclusion'] = 'success'

    check_kwargs = {
        'url': f'{base_url}/check-runs',
        'data': json.dumps(check),
        'headers': {
            'Accept': 'application/vnd.github.antiope-preview+json',
            'Authorization': f'token {token}',
            'Content-Type': 'application/json; charset=utf-8'
        }
    }

    if action == 'rerequested' and req.get('check-run'):
        check_kwargs['url'] = f'{base_url}/check-runs/' \
                                f'{req["check-run"]["id"]}'
        r = requests.patch(**check_kwargs)
    else:
        r = requests.post(**check_kwargs)

    if int(r.status_code / 100) == 2:
        logger.info(f'Payload processed: {req}')
        logger.info(f'Successfully processed action {action} for '
                    f'{req["repository"]["full_name"]}:'
                    f' {len(added)} todos')
    else:
        logger.warning(f'FAILED: status: {r.status_code}; '
                        f'response: {r.text}; error: {r.reason}; '
                        f'payload = {req}')

    return 'ok'
except:
    logger.exception(f'Failed to process {req}')
    return 'ok'

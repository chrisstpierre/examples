when gmail inbox receives as email
    if email.attachments
        match_found = false
        foreach email.attachments as attachment
            res = machinebox/facebox process input:attachment
            if res.match_found
                match_found = true
                break

        if match_found is false
            slack send channel:'#no-face-found'
                       text:'No face matched this email. :('
                       attachments:{...}

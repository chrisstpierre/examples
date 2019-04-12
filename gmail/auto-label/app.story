when gmail email labeled as email
    # remember we tagged this, train our ML
    if redis sismember key:'ml-tagged' item:email.id == false
        machinebox/textbox teach intput:email.text
                                 labels:email.labels

when gmail inbox receives as email
    res = machinebox/textbox analyze intput:email.text
    if res.labels
        email label add:res.labels
        redis sadd key:'ml-tagged' item:email.id

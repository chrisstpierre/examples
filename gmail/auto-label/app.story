when gmail email labeled as email
    # remember we tagged this, train our ML
    
    # TODO only if it was not done below
    machinebox/textbox teach intput:email.text
                             labels:email.labels

when gmail inbox receives as email
    res = machinebox/textbox analyze intput:email.text
    if res.labels
        email label add:res.labels
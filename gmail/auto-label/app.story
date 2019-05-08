###
Train a machine learning model to label new emails in your inbox.
###

# Create the model using MachineBox's ClassificationBox
ml = machinebox/classificationbox createModel
        id: 'gmailLabels'
        name: 'gmailLabels'


gmail inbox 
    when received as email
        res = ml predict inputs: email_to_inputs(:email) limit: 3
        if res.success
            redis sadd key: 'tagged-by-ml' item: email.id

            labels = []
            foreach res.classes as class
                if class.score >= app.secrets.min_score
                    labels append item:class.id

            if labels
                email label add: labels

    when labeled as email
        # skip if tagged by ML module
        if (redis sismember key: 'tagged-by-ml' item: email.id) == false

            inputs = email_to_inputs(:email)
            examples = []
            foreach email.labels as label
                examples append item: {class: label, inputs: inputs}

            ml teach_multi :examples


function email_to_inputs email:object returns list
    return [
        {key: 'from',    type: 'keyword', value: email.from},
        {key: 'to',      type: 'keyword', value: email.to},
        {key: 'subject', type: 'string',  value: email.subject},
        {key: 'body',    type: 'text',    value: email.body}
    ]
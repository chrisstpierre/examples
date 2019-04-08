patterns [
    'have our va'
    'assign the va'
    'create task for the va'
]
when googl/assist listener hears :patterns as command
    asana createTask name:command.text asignee:'va@mycompany.com'
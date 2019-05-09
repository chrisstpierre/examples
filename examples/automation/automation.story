# Automations
when google/docs listener newRowAdded as row
    fc = fullcontact person email:row.cell['email']
    row update cells:{'twitter': fc.twitter}

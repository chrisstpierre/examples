def main(text):
    lines = text.split('\n')
    current_file = None
    current_pos = 0
    added = []
    for line in lines:
        if current_pos is not None:
            current_pos = current_pos + 1

        if line.startswith('+++'):
            current_file = line[6:]
            current_pos = None
            continue
        elif line.startswith('@@'):
            current_pos = int(line.split(' ')[2].split(',')[0]) - 1
        elif current_file is not None \
                and current_pos is not None \
                and line.startswith('+'):
            if 'todo' in line.lower():
                added.append({
                    'line': current_pos,
                    'file': current_file,
                    'content': line[1:80]
                })
        # current_pos = current_pos + 1
    return added
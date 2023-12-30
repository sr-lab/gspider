import sys

# Total up password frequencies.
current_line = 1
with open(sys.argv[1]) as file:
    buffer = file.readline()
    total_passwords = 0

    # While there's another line...
    while buffer:

        # Split line along colons.
        line = buffer.split(':') 
        
        # Skip blank lines without error.
        if len(buffer.strip()) > 0:
            if len(line) >= 2 and line[-1].isnumeric():
                total_passwords += int(line[-1].strip())
            else:
                print(f'Line {current_line} is bad. Aborting.') # Distributions should be free from errors.
                exit(1)
        buffer = file.readline()
        current_line += 1

print('Total passwords: {total_passwords}')

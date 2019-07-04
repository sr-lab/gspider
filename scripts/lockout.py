import sys
import os
import subprocess


# Specify relative location of GSPIDER executable.
GSPIDER_LOC = '../src/gspider.exe'


def print_usage(show_help_line=False):
    """ Prints the short help card for the program.
    Args:
        show_help_line (bool): If true, information on help flag `-h` will be printed.
    """
    print('Usage: python lockout.py [-h] <sysfile> <distfile> <attfile> <acceptable_risk>')
    print('Computes the minimum number of guesses permitted to keep probability of breach below acceptable threshold.')
    if show_help_line:
        print('For extended help use \'-h\' option.')


def print_help():
    """ Prints the full help card for the program.
    """
    print_usage()
    print('Arguments:')
    print('\tsysfile: The system file that specifies supported password characters on the system. (see ../systems)')
    print('\tdistfile: A file that specifies a password frequency distribution. (see ../dists)')
    print('\tattfile: A file that specifies a password guessing attack. (see ../attacks)')
    print('Options:')
    print('\t-h: Show this help screen')
    
    
# Print help if asked.
if '-h' in sys.argv:
    print_help()
    exit(0)

# Check argument list length.
if len(sys.argv) < 5:
    print_usage(True)
    exit(1)

# Get arguments.
system = sys.argv[1]
dist = sys.argv[2]
att = sys.argv[3]
risk = sys.argv[4]

# Check GSPIDER is present.
if not os.path.exists(GSPIDER_LOC):
    print('Error: GSPIDER executable could not be located at', GSPIDER_LOC)
    print('Build it first, then ensure working directory is correct.')
    exit(1)

# Check files exist.
if not os.path.isfile(system):
    print('Error: Could not load system.')
    exit(1)
if not os.path.isfile(dist):
    print('Error: Could not load distribution.')
    exit(1)
if not os.path.isfile(att):
    print('Error: Could not load attack.')
    exit(1)

# Ensure acceptable risk is valid.
try:
    risk = float(risk)
    if risk < 0 or risk > 1:
        raise Exception('Acceptable risk out of range.')
except:
    print('Error: Acceptable risk must be given as a floating-point number between 0 and 1.')
    exit(1)

# Get output from GSPIDER.
gspider_out = subprocess.check_output([GSPIDER_LOC, system, dist, att]).decode(sys.stdout.encoding)

# Process output into numbers.
raw_probs = gspider_out.split('\n')
probs = []
for raw_prob in raw_probs:
    try:
        prob = float(raw_prob)
        probs.append(prob)
    except:
        pass
    
# Get number of guesses needed to exceed risk (-1).
guesses = -1
for prob in probs:
    guesses += 1
    if prob > risk:
        break
        
# Show friendly output.
print('A total of', guesses, 'guesses can be made in the worst case in order for guess success probability to exceed', str(risk) + '.')

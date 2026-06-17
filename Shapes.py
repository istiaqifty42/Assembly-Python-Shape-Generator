1# 'import' loads a built-in Python library so we can use its functions.
# 'random' is a library that gives us tools to generate random numbers.
# Example: random.randint(1, 9) gives us a random number between 1 and 9.
# In assembly, we used 'rdtsc' to read the CPU clock for randomness.
# Python's random library does the same thing but hides all that complexity.
import random
# ANSI COLOR CODES
RED     = "\033[31m"                                                        # Sets terminal text to Red
GREEN   = "\033[32m"                                                        # Sets terminal text to Green
YELLOW  = "\033[33m"                                                        # Sets terminal text to Yellow
BLUE    = "\033[34m"                                                        # Sets terminal text to Blue
MAGENTA = "\033[35m"                                                        # Sets terminal text to Magenta
CYAN    = "\033[36m"                                                        # Sets terminal text to Cyan 
RESET   = "\033[0m"                                                         # Resets terminal text back to default
# COLORS list holds every color together in one place
COLORS = [RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, RESET]

# MAIN FUNCTION
def main():
    while True:
        print("\nNASM ASSEMBLY SHAPE GENERATOR")
        print("1. Concentric Square (Istiaque Ahmed Ifty)")
        print("2. Hexagon (Mohtasim Ahmed Rhythm)")
        print("3. Hourglass (Donaley Kururama Makarawa)")
        print("4. Diamond (W Shein Zi)")
        print("5. Heart (Royyan Firdaus Alpha)")
        print("6. Exit")
        
        print()
        
        # Using the universal input validation functions for the input
        choice = get_valid_input("Select Option(1-6): ", "int", 1, 6)       # expected_type = "int", min_value = 1, max_value = 6
        if choice == 6:
            break

        if choice == 1:
            # Asks for all input except color
            size = get_valid_input("Enter size (1-9): ", "int", 1, 9)
            x_offset = get_location()
            num_shapes = get_valid_input("Enter number of shapes (1-9): ", "int", 1, 9)
            char = get_valid_input("Enter character: ", "char")

            print()                                                         # Push cursor down to avoid terminal glitch
            print("[>> Applying Random Color...]")

            for i in range(num_shapes):

                # Color randomization factor
                color = random.choice(["\033[31m", "\033[32m", "\033[33m", "\033[34m", "\033[35m", "\033[36m"])
                draw_square(size, x_offset, char, color)                    # puts all the input into the draw_square function
                print() # Print gap between shapes
        
        elif choice == 2:
            # Skip asking for size here
            x_offset = get_location()
            num_shapes = get_valid_input("Enter number of shapes (1-9): ", "int", 1, 9)
            char = get_valid_input("Enter character: ", "char")
            color = get_color()
            
            print()
            print("[>> Generating Random Size ...]")
            for i in range(num_shapes):
                # Generates a random size between 3 and 9 right before drawing
                size = random.randint(3, 9)                                 # size randomization factor
                draw_hexagon(size, x_offset, char, color)                   # puts all the input into the draw_hexagon function
                print()
        
        elif choice == 3:
            # Skips asking for location/offset
            size = get_valid_input("Enter size (1-9): ", "int", 1, 9)
            num_shapes = get_valid_input("Enter number of shapes (1-9): ", "int", 1, 9)
            char = get_valid_input("Enter character: ", "char")
            color = get_color()
            
            print()
            print("[>> Shuffling Random Location...]")

            for i in range(num_shapes):
                # 0 as Left, 20 as Center, 40 as Right
                x_offset = random.choice([0, 20, 40])                       # location randomization factor
                draw_hourglass(size, x_offset, char, color)                 # puts all the input into the draw_hourglass function
                print()
        
        elif choice == 4: 
            # Skip asking for drawing character
            size = get_valid_input("Enter size (1-9): ", "int", 1, 9)
            x_offset = get_location()
            num_shapes = get_valid_input("Enter number of shapes (1-9): ", "int", 1, 9)
            color = get_color()
            
            print()
            print("[>> Picking Random Character...]")

            for i in range(num_shapes):
                # Grab a random uppercase letter from the string library
                char = chr(random.randint(33, 126))                         # drawn character randomization factor
                draw_diamond(size, x_offset, char, color)                   # puts all the input into the draw_diamond function
                print()

        elif choice == 5:
            num_shapes = random.randint(1, 6)                               # Number of how many shapes randomization factor
            size = get_valid_input("Enter size (1-9): ", "int", 1, 9)
            x_offset = get_location()
            char = get_valid_input("Enter character: ", "char")
            color = get_color()
            
            print()
            print("[>> Rolling Random Number of Shapes...]")
            
            for i in range(num_shapes):
                draw_heart(size, x_offset, char, color)                     # puts all the input into draw_heart function
                print()

# INPUT HELPER FUNCTIONS
def get_location():
    # Helper function to convert 1, 2, 3 into actual space counts
    loc = get_valid_input("Enter location (1=Left, 2=Center, 3=Right): ", "int", 1, 3)
    if loc == 1: return 0
    elif loc == 2: return 20
    else: return 40

def get_color():
    # Helper function to map menu choices to ANSI escape codes
    col = get_valid_input("Select Color (1=Red, 2=Green, 3=Yellow, 4=Blue, 5=Magenta, 6=Cyan, 7=Reset): ", "int", 1, 7)
    if col == 1: return "\033[31m"
    elif col == 2: return "\033[32m"
    elif col == 3: return "\033[33m"
    elif col == 4: return "\033[34m"
    elif col == 5: return "\033[35m"
    elif col == 6: return "\033[36m"
    else: return "\033[0m"

# UNIVERSAL INPUT VALIDATION FUNCTION
def get_valid_input(prompt, expected_type, min_value=0, max_value=0):
    while True:
        try:
            user_input = input(prompt)                                   # grabs raw string from the terminal
            # If the program is asking for numbers
            if expected_type == "int":
                value = int(user_input)
                if min_value <= value <= max_value:                     
                    return value
            
            # If the program asks for character
            elif expected_type == "char":
                if len(user_input) == 1 and user_input[0] != " ":       # len(user_input) > 0 to == 1 to strictly enforces 1 character limit
                    return user_input[0]                                # returns the first character
            
            # If the following conditions are not met, then prints error msg
            print("INVALID INPUT! Please select a valid option")
        except ValueError:
            # Catch the crash if it tries to turn a letter into number
            print("INVALID INPUT! Please select a valid option")

# SHAPE DRAWING LOOPS AND ALGORITHMS
def draw_square(max_size, x_offset, char, color):
    for current_row in range(-max_size, max_size + 1):                   # goes from -max_size to the total positive max_size
        line = " " * x_offset                                            # creates empty space as necessary
        for current_col in range(-max_size, max_size + 1):
            # Remove the negative signs
            abs_col = abs(current_col)
            abs_row = abs(current_row)
            # Find out the highest number (X or Y) or the Ring number
            if abs_col > abs_row:
                highest_number = abs_col
            else:
                highest_number = abs_row
            # Even numbers get drawns while odd numbers print empty
            if highest_number % 2 == 0:
                line = line + char + " "
            else:
                line = line + "  "
        print(color +line +"\033[0m")

def draw_hexagon(max_size, x_offset, char, color):
    max_width = max_size * 2
    for current_row in range(-max_size, max_size + 1):                  # goes from -max_size to the total positive max_size
        line = " " * x_offset
        abs_row = abs(current_row)                                      # makes |Y|
        current_width = max_width - abs_row                             
        for current_col in range(-max_width, max_width + 1):
            abs_col = abs(current_col)                                  # makes |X|

            # Draw diagonal side walls
            if abs_col == current_width:
                line = line + char + " "
            # Draw flat top and bottom edges
            elif abs_row == max_size and abs_col <= current_width:
                line = line + char + " "
            else:
                line = line + "  "
        print(color + line + "\033[0m")

def draw_hourglass(max_size, x_offset, char, color):
    for current_row in range (-max_size, max_size + 1):                 # goes from -max_size to the total positiv max_size
        line = " " * x_offset
        for current_col in range(-max_size, max_size + 1):
            abs_col = abs(current_col)                                  # |X|
            abs_row = abs(current_row)                                  # |Y|
            
            # Draw the \ and / diagonals (where X distance equals Y distance)
            if abs_col == abs_row:
                line = line + char + " "
            # Draw the flat ceiling and floor
            elif abs_row == max_size and abs_col <= abs_row:
                line = line + char + " "
            else:
                line = line + "  "
        print(color + line + "\033[0m")

def draw_diamond(max_size, x_offset, char, color):
    for current_row in range(-max_size, max_size + 1):
        line = " " * x_offset
        for current_col in range(-max_size, max_size + 1):
            abs_col = abs(current_col)
            abs_row = abs(current_row)
    
            # If |X| + |Y| equals to max_size, print the character
            if abs_col + abs_row == max_size:
                line = line + char + " "
            else:
                line = line + "  "
        print(color + line + "\033[0m")

def draw_heart(max_size, x_offset, char, color):
    # starts higher up to make room for the two humps
    start_row = -(max_size // 2)
    for current_row in range(start_row, max_size + 1):
        line = " " * x_offset
        for current_col in range(-max_size, max_size + 1):
            abs_col = abs(current_col)                                  # |Y|
            
            # TOP HALF: row < 0
            if current_row < 0:
                # Top most row needs the V-cleft carved out and corners rounded
                if current_row == start_row:
                    if abs_col == 0 or abs_col == max_size:
                        line = line + "  "
                    else:
                        line = line + char + " "
                # Rest of the humps are filled solid within the max_size limit
                else:
                    if abs_col <= max_size:
                        line = line + char + " "
                    else:
                        line = line + "  "
            
            # BOTTOM HALF: Row >= 0 which forms the downward triangle
            else:
                if abs_col + current_row <= max_size:
                    line = line + char + " "
                else:
                    line = line + "  "
        print(color + line + "\033[0m")

if __name__ == "__main__":
    main()
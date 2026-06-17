; ==============================================================================
; NASM ASSEMBLY SHAPE PROGRAM
; Description:
; A menu-driven system that algorithmically generates five unique geometric
; shapes on a 2D Cartesian grid using NASM assembly. All shapes are built dynamically using loops,
; parameters, and logic-based boundary rules.
;
; System Architecture & Error Handling:
; The system uses a centralized, shared input functions. This prevents redundant
; code across the five shapes and ensures robust input validation/error
; handling while gracefully recovering from invalid user keystrokes.
;
; The Randomization Factor:
; To satisfy dynamic execution requirements, the program intentionally skips
; one user prompt per shape. Instead, it utilizes the CPU clock (rdtsc) to
; mathematically randomize that specific parameter:
;
; 1. Concentric Square  -> Randomizes COLOR (ANSI codes)
; 2. Hexagon            -> Randomizes SIZE (3 to 9)
; 3. Hourglass          -> Randomizes LOCATION (Left, Center or Right)
; 4. Diamond            -> Randomizes CHARACTER (A to Z)
; 5. Heart              -> Randomizes NUMBER OF SHAPES (1 to 9)
;
; Authors:
; - Istiaque Ahmed Ifty (Concentric Square)
; - Mohtasim Ahmed Rhythm (Hexagon)
; - Donaley Kururama Makarawa (Hourglass)
; - W Shein Zi (Diamond)
; - Royyan Firdaus Alpha (Heart)
; ==============================================================================
section .data
    ; Main Menu
    mainmenu_msg db 10, "NASM ASSEMBLY SHAPE GENERATOR", 10
                 db "1. Concentric Square (Istiaque Ahmed Ifty)", 10
                 db "2. Hexagon (Mohtasim Ahmed Rhythm)", 10
                 db "3. Hourglass (Donaley Kururama Makarawa)", 10
                 db "4. Diamond (W Shein Zi)", 10
                 db "5. Heart (Royyan Firdaus Alpha)", 10
                 db "6. Exit", 10
                 db "Select Option(1-6): ", 0
    mainmenu_msg_len equ $ - mainmenu_msg

    ; All of the prompts for the program
    prompt_size db "Enter size (1-9): ", 0
    prompt_size_len equ $ - prompt_size     ; Calculates the length of the prompt
    prompt_location db "Enter location (1=Left, 2=Center, 3=Right): ", 0
    prompt_location_len equ $ - prompt_location
    prompt_number db "Enter number of shapes (1-9): ", 0
    prompt_number_len equ $ - prompt_number
    prompt_character db "Enter drawing character (e.g. #, %, *): ", 0
    prompt_character_len equ $ - prompt_character
    prompt_color db "Select Color (1=Red, 2=Green, 3=Yellow, 4=Blue, 5=Magenta, 6=Cyan, 7=Reset): ", 0
    prompt_color_len equ $ - prompt_color

    ; Error message for input validation
    error_msg db "INVALID INPUT! Please select a valid option."
    error_msg_len equ $ - error_msg

    ; Ansi color codes
    c_red         db  27, "[31m", 0
    c_green       db  27, "[32m", 0
    c_yellow      db  27, "[33m", 0
    c_blue        db  27, "[34m", 0
    c_magenta     db  27, "[35m", 0
    c_cyan        db  27, "[36m", 0
    c_reset       db  27, "[0m",  0

    ; Specific Randomization Announcements
    msg_color db 10, "[>> Applying Random Color...]", 10, 10, 0
    msg_color_len equ $ - msg_color
    msg_size db 10, "[>> Generating Random Size ...]", 10, 10, 0
    msg_size_len equ $ - msg_size
    msg_loc db 10, "[>> Shuffling Random Location...]", 10, 10, 0
    msg_loc_len equ $ - msg_loc
    msg_char db 10, "[>> Picking Random Character...]", 10, 10, 0
    msg_char_len equ $ - msg_char
    msg_num db 10, "[>> Rolling Random Number of Shapes...]", 10, 10, 0
    msg_num_len equ $ - msg_num

    newline db 10, 0
    space db "  ", 0

section .bss
    ; Shared variables to save memory
    input_user resb 16                  ; Reserves 16 bytes to securely absorb buffer overflows
    max_size resd 1                     ; Reserves 4 bytes or 1 dword
    x_offset resd 1                     ; Memory address for location change
    num_of_shapes resd 1                ; Memory address for number of squares/shapes
    draw_character resb 2               ; Reserves 2 bytes for any character to be drawn
    chosen_color resd 1                 ; Reserves 4 bytes or 1 dword for the randomized color
    current_row resd 1                  ; Memory address to use in the row loop
    current_col resd 1                  ; Memory address to use in the col loop
    space_cnt resd 1                    ; Memory address to print spaces

    ; Hexagon specific math variables
    rand_size resd 1                    ; Memory address for the size value that will be randomized
    max_width resd 1                    ; Memory address for the width value that is necessary for hexagon drawing calculation

section .text
    global _start

_start:

; Main menu function
main_menu:
    mov ecx, mainmenu_msg               ; collects the memory address for the main menu message
    mov edx, mainmenu_msg_len           ; gets the length of the memory address
    call print_msg                      ; calls the sys_write subroutine function
    call read_input                     ; calls the sys_read subroutine function

    ; Main menu error handling
    cmp eax, 2                          ; Hardware Check: 1 input char + 1 Enter key = Exactly 2 bytes
    jne error_main                      ; Rejects anything longer, or empty Enter keys

    xor eax, eax
    mov al, [input_user]
    cmp al, '1'
    je init_square
    cmp al, '2'
    je init_hexagon
    cmp al, '3'
    je init_hourglass
    cmp al, '4'
    je init_diamond
    cmp al, '5'
    je init_heart
    cmp al, '6'
    je exit
    jmp error_main

; Different register for each shapes logic and loop
init_square:
    mov bl, 1                           ; bl = 1 means Square flow
    jmp ask_size

init_hexagon:
    mov bl, 2                           ; bl = 2 means Hexagon flow
    jmp ask_location

init_hourglass:
    mov bl, 3                           ; bl = 3 means Hourglass flow
    jmp ask_size

init_diamond:
    mov bl, 4                           ; bl = 4 means Diamond flow
    jmp ask_size

init_heart:
    mov bl, 5                           ; bl = 5 means Heart flow
    jmp ask_size

; SHARED INPUT COLLECTION FUNCTIONS
ask_size:
    mov ecx, prompt_size
    mov edx, prompt_size_len
    call print_msg                      ; calls the print_msg subroutine function to print
    call read_input                     ; calls the read_input subroutine function to read input

    ; error handles double digit number
    cmp eax, 2
    jne error_size

    ; Error handling for the size input
    xor eax, eax                        ; wipes the eax register for error handling
    mov al, [input_user]
    cmp al, '1'
    jl error_size
    cmp al, '9'
    jg error_size

    ; Storing the input size into memory
    sub al, '0'                         ;subtracts 48 which is 0 according to ASCII to convert string to interger
    mov [max_size], eax

    cmp bl, 3                           ; checks if hourglass skips for location input
    je ask_number                       ; it skips because hourglass randomizes location instead
    jmp ask_location

ask_location:
    mov ecx, prompt_location
    mov edx, prompt_location_len
    call print_msg
    call read_input

    ; Input Validation & Sanitization
    cmp eax, 2
    jne error_location

    ; Error handling for location input
    xor eax, eax
    mov al, [input_user]
    cmp al, '1'
    je set_left
    cmp al, '2'
    je set_center
    cmp al, '3'
    je set_right
    jmp error_location

; Data storing for location changes
set_left:
    mov dword [x_offset], 0
    cmp bl, 5                           ; checks if heart skips number of shapes input
    je ask_character                    ; it skips because heart randomizes number of shapes
    jmp ask_number

set_center:
    mov dword [x_offset], 20
    cmp bl, 5
    je ask_character
    jmp ask_number

set_right:
    mov dword [x_offset], 40
    cmp bl, 5
    je ask_character
    jmp ask_number

ask_number:
    mov ecx, prompt_number
    mov edx, prompt_number_len
    call print_msg
    call read_input

    ; Input Validation
    cmp eax, 2
    jne error_number

    ; Error handling for asking number of shapes
    xor eax, eax
    mov al, [input_user]
    cmp al, '1'
    jl error_number
    cmp al, '9'
    jg error_number

    ; Data collection for how many number of shapes
    sub al, '0'
    mov [num_of_shapes], eax

    cmp bl, 4
    je ask_color                        ; diamond skips asking character (randomizes it)

ask_character:
    mov ecx, prompt_character
    mov edx, prompt_character_len
    call print_msg
    call read_input

    cmp eax, 2
    jne error_character

    mov al, [input_user]
    mov [draw_character], al
    mov byte [draw_character + 1], ' '  ; adds a space after the symbol to make the drawn pixels twice as wide

    cmp bl, 1
    je sq_announce                      ; if square, then announce color and jump to randomizer
    jmp ask_color                       ; if hexagon/hourglass/heart/diamond, then ask for color

ask_color:
    mov ecx, prompt_color
    mov edx, prompt_color_len
    call print_msg
    call read_input

    cmp eax, 2
    jne error_color

    mov al, [input_user]
    cmp al, '1'
    je set_red
    cmp al, '2'
    je set_green
    cmp al, '3'
    je set_yellow
    cmp al, '4'
    je set_blue
    cmp al, '5'
    je set_magenta
    cmp al, '6'
    je set_cyan
    cmp al, '7'
    je set_default
    jmp error_color

; Classifies which color is being generated/chosen and routes to appropriate shape loop
set_red:
    mov dword [chosen_color], c_red
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

set_green:
    mov dword [chosen_color], c_green
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

set_blue:
    mov dword [chosen_color], c_blue
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

set_yellow:
    mov dword [chosen_color], c_yellow
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

set_cyan:
    mov dword [chosen_color], c_cyan
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

set_magenta:
    mov dword [chosen_color], c_magenta
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

set_default:
    mov dword [chosen_color], c_reset
    cmp bl, 1
    je sq_master_loop
    cmp bl, 2
    je hex_announce
    cmp bl, 3
    je hg_announce
    cmp bl, 4
    je dia_announce
    jmp hrt_announce

; SQUARE DRAWING LOGIC:
; Compares between |X| and |Y| coordinates to pick the highest number.
; CONDITION A: If the highest number is even then it prints the character.
; CONDITION B: If the highest number is odd then it prints a space.

sq_announce:                            ; announces the randomization factor in the terminal
    mov ecx, msg_color
    mov edx, msg_color_len
    call print_msg

sq_master_loop:
    mov eax, [num_of_shapes]
    cmp eax, 0                          ; dictates how many squares would be drawn
    je main_menu

    call generate_random_color          ; calls the dedicated subroutine for color randomizer

    ; Paints the color
    mov ecx, [chosen_color]
    mov edx, 5                          ; 5 cause the code of the color is usually 5 bytes long
    call print_msg

sq_init_row_loop:
    mov eax, [max_size]
    neg eax                             ; turns the input negative to make the (0,0) coordinates center
    mov [current_row], eax              ; puts the input size into the current row counter

sq_row_loop:
    mov eax, [current_row]
    cmp eax, [max_size]                 ; compares according to the input Size
    jg sq_shape_done

    ; Location loop initialization
    mov eax, [x_offset]
    mov [space_cnt], eax

sq_location_loop:
    cmp dword [space_cnt], 0
    je sq_col_loop_initialization
    mov ecx, space
    mov edx, 1
    call print_msg
    dec dword [space_cnt]
    jmp sq_location_loop

sq_col_loop_initialization:
    mov eax, [max_size]
    neg eax
    mov [current_col], eax

sq_col_loop:
    mov eax, [current_col]
    cmp eax, [max_size]
    jg sq_next_row                      ; jump to next row if its greater

sq_get_x:
    mov ecx, [current_col]              ; grab x
    cmp ecx, 0                          ; checks if x is negative
    jge sq_get_y                        ; if it is 0 or positive, jumps to the next step
    neg ecx                             ; if it is negative, neg flips it to positive

sq_get_y:
    mov eax, [current_row]              ; grabs y
    cmp eax, 0                          ; checks if y is negative?
    jge sq_find_biggest_number          ; if it is 0 or positive, jumps to the next step
    neg eax                             ; if it is negative, neg flips it to positive

sq_find_biggest_number:
    cmp ecx, eax                        ; compares them
    jle sq_check_even                   ; jumps if ecx is less or equal to eax.
    mov eax, ecx                        ; If ecx is bigger, overwrites eax with ecx.

sq_check_even:
    and eax, 1                          ; isolates the even/odd bit because every even decimal number in binary ends with 0 and odd numbers end with 1
    jz sq_print_solid                   ; jz means jump if zero (even), then prints the symbol
    jmp sq_print_empty                  ; otherwise, if it's odd prints a empty space

sq_print_solid:
    mov ecx, draw_character             ; Prints the character user chose
    mov edx, 2
    call print_msg
    jmp sq_next_col

sq_print_empty:
    mov ecx, space                      ; print empty space when needed
    mov edx, 2
    call print_msg
    jmp sq_next_col

sq_next_col:
    inc dword [current_col]             ; moves to the next column
    jmp sq_col_loop

sq_next_row:
    mov ecx, newline
    mov edx, 1
    call print_msg
    inc dword [current_row]             ; moves to the next row
    jmp sq_row_loop

sq_shape_done:
    ; Reset the terminal to normal color
    mov ecx, c_reset
    mov edx, 4
    call print_msg

    ; Print gap between shapes
    mov ecx, newline
    mov edx, 1
    call print_msg
    ; Decrement total count and jump back to main loop
    dec dword [num_of_shapes]           ; subtracts from the total number of squares
    jmp sq_master_loop

; HEXAGON DRAWING LOGIC:
; Calculates max_width/W = [(max_size * 2) - |Y|]
; CONDITION A: |X| = W ; prints the character.
; CONDITION B: |Y| = max_size AND |X| <= W; prints the character

hex_announce:                           ; announces the randomization factor
    mov ecx, msg_size
    mov edx, msg_size_len
    call print_msg

hex_master_loop:
    mov eax, [num_of_shapes]            ; grabs the number on how many hexagon to draw
    cmp eax, 0
    je main_menu                        ; after printing every hexagon required it jumps back to the main menu

    ; applies the choosen color
    mov ecx, [chosen_color]
    mov edx, 5
    call print_msg
    call generate_random_hex_size       ; calls the dedicated subroutine for size randomizer

    ; calculate max width/w = rand_size * 2
    mov eax, [rand_size]
    imul eax, 2
    mov [max_width], eax

hex_init_row_loop:
    mov eax, [rand_size]
    neg eax
    mov [current_row], eax

hex_row_loop:
    mov eax, [current_row]
    cmp eax, [rand_size]                ; compares to the randomized size
    jg hex_shape_done                   ; jumps if greater than the randomized size

    ; Location loop intialization
    mov eax, [x_offset]                 ; pulls the offset (15, 35, or 55)
    mov [space_cnt], eax

hex_location_loop:
    cmp dword [space_cnt], 0            ; checks whether we have printed all the offset spaces
    je hex_col_loop_initialization      ; if yes then starts drawing the columns
    mov ecx, space                      ; loads 1 blank space
    mov edx, 1
    call print_msg                      ; prints the space
    dec dword [space_cnt]               ; subtracts 1 from the counter
    jmp hex_location_loop               ; loop again untill it hits 0

hex_col_loop_initialization:
    mov eax, [max_width]
    neg eax
    mov [current_col], eax              ; put the max width into current_col which is our starting point

hex_col_loop:
    mov eax, [current_col]
    cmp eax, [max_width]                ; compares to max width
    jg hex_next_row                     ; jumps to next row if the column is greater than max width

    mov ecx, [current_row]
    cmp ecx, 0
    jge hex_get_width                   ; jumps to gather width if the current_row count comes to 0 or greater
    neg ecx

hex_get_width:
    mov ebx, [rand_size]                ; puts size into ebx
    imul ebx, 2                         ; multiplies by 2
    sub ebx, ecx                        ; subtracts |Y|. the formula is ebx = (rand_size * 2) - |Y|

    mov eax, [current_col]
    cmp eax, 0                          ; checks if x is 0 or positive
    jge hex_check_bounds                ; if greater than 0 or equal, it jumps to the next function
    neg eax                             ; if its negative, "neg" now makes it positive

hex_check_bounds:
    cmp eax, ebx                        ; Condition A: Is |X| == W
    je hex_print_solid                  ; If yes then prints the character

    cmp ecx, [rand_size]                ; Condition B: Is |Y| == rand_size
    jne hex_print_empty                 ; If not on the top or bottom row then print space

    cmp eax, ebx                        ; Condition B: If |Y| == rand_size, now it checks is |X| <= W
    jle hex_print_solid                 ; if yes then prints the character
    jmp hex_print_empty                 ; otherwise, prints space

hex_print_solid:
    mov ecx, draw_character
    mov edx, 2
    call print_msg
    jmp hex_next_col

hex_print_empty:
    mov ecx, space
    mov edx, 2
    call print_msg

hex_next_col:
    inc dword [current_col]             ; makes X = X + 1
    jmp hex_col_loop

hex_next_row:
    mov ecx, newline
    mov edx, 1
    call print_msg
    inc dword [current_row]             ; makes Y = Y + 1
    jmp hex_row_loop

hex_shape_done:
    mov ecx, c_reset
    mov edx, 4
    call print_msg

    mov ecx, newline
    mov edx, 1
    call print_msg
    call print_msg

    dec dword [num_of_shapes]           ; after finishing printing one shape, subtracts 1 from the total shape
    jmp hex_master_loop

; HOURGLASS DRAWING LOGIC:
; CONDITION A: |X| == |Y| (draws the diagonal walls: \ and /)
; CONDITION B: |Y| == max_size AND |X| <= |Y| (draws the flat ceiling and floor: ---)

hg_announce:                            ; announces the randomization factor
    mov ecx, msg_loc
    mov edx, msg_loc_len
    call print_msg

hg_master_loop:
    mov eax, [num_of_shapes]            ; checks how many hourglass to draw
    cmp eax, 0                          ; compares if every hourglass asked to draw is finished or not
    je main_menu                        ; loops back to main menu when finished

    ; paints the color chosen to the hourglass
    mov ecx, [chosen_color]
    mov edx, 5
    call print_msg

    call generate_random_hg_location    ; calls the dedicated subroutine for location randomizer
    jmp hg_init_row_loop                ; jumps to row loop initialization since routing is done in subroutine

; initializes the setup before row loop
hg_init_row_loop:
    mov eax, [max_size]
    neg eax                             ; makes the max_size negative to make (0,0) the center of the hourglass
    mov [current_row], eax              ; Sets the vertical grid

hg_row_loop:
    mov eax, [current_row]
    cmp eax, [max_size]
    jg hg_shape_done

    ; location loop intialization
    mov eax, [x_offset]
    mov [space_cnt], eax

hg_location_loop:
    cmp dword [space_cnt], 0
    je hg_col_loop_initialization
    mov ecx, space
    mov edx, 1
    call print_msg
    dec dword [space_cnt]
    jmp hg_location_loop

hg_col_loop_initialization:
    mov eax, [max_size]
    neg eax
    mov [current_col], eax              ; sets the horizontal grid

hg_col_loop:
    mov eax, [current_col]
    cmp eax, [max_size]
    jg hg_next_row

hg_get_x:
    mov eax, [current_col]              ; gets |X|
    cmp eax, 0
    jge hg_get_y
    neg eax

hg_get_y:
    mov ecx, [current_row]              ; gets |Y|
    cmp ecx, 0
    jge hg_check_bounds
    neg ecx

hg_check_bounds:
    ;Condition A: |X| == |Y| (draws the diagonal walls: \ and /)
    cmp eax, ecx
    je hg_print_solid

    ; Condition B: |Y| == max_size AND |X| <= |Y| (draws the flat ceiling and floor: ---)
    cmp ecx, [max_size]
    jne hg_print_empty

    cmp eax, ecx
    jle hg_print_solid
    jmp hg_print_empty

; prints the character
hg_print_solid:
    mov ecx, draw_character
    mov edx, 2
    call print_msg
    jmp hg_next_col

; prints empty space
hg_print_empty:
    mov ecx, space
    mov edx, 2
    call print_msg

; jumps to the next column
hg_next_col:
    inc dword [current_col]
    jmp hg_col_loop

; jumps to the next row
hg_next_row:
    mov ecx, newline
    mov edx, 1
    call print_msg
    inc dword [current_row]
    jmp hg_row_loop

; finalizes when one shape is done
hg_shape_done:
    mov ecx, c_reset                    ; resets the terminal to default color
    mov edx, 4
    call print_msg

    mov ecx, newline                    ; prints a new line for the next hourglass shape
    mov edx, 1
    call print_msg
    call print_msg

    dec dword [num_of_shapes]           ; after printing one hourglass, it decreases 1 from the total count
    jmp hg_master_loop                  ; then it jumps back to the master loop to print the next hourglass

; DIAMOND DRAWING LOGIC:
; CONDITION: |X| + |Y| = max_size; prints the character

dia_announce:                           ; announces the randomization factor
    mov ecx, msg_char
    mov edx, msg_char_len
    call print_msg

dia_master_loop:
    mov eax, [num_of_shapes]            ; grabs how many diamonds to draw
    cmp eax, 0
    je main_menu                        ; loops back to main menu when done

    ; paints the chosen color
    mov ecx, [chosen_color]
    mov edx, 5
    call print_msg

    call generate_random_dia_char       ; calls the dedicated subroutine for character randomizer

; initializes the setup before row loop
dia_init_row_loop:
    mov eax, [max_size]
    neg eax
    mov [current_row], eax              ; sets the vertical grid

dia_row_loop:
    mov eax, [current_row]
    cmp eax, [max_size]
    jg dia_shape_done

    ; location loop intialization
    mov eax, [x_offset]
    mov [space_cnt], eax

dia_location_loop:
    cmp dword [space_cnt], 0
    je dia_col_loop_initialization
    mov ecx, space
    mov edx, 1
    call print_msg
    dec dword [space_cnt]
    jmp dia_location_loop

dia_col_loop_initialization:
    mov eax, [max_size]
    neg eax
    mov [current_col], eax              ; sets the horizontal grid

dia_col_loop:
    mov eax, [current_col]
    cmp eax, [max_size]
    jg dia_next_row

dia_get_x:
    mov eax, [current_col]              ; gets |X|
    cmp eax, 0
    jge dia_get_y
    neg eax

dia_get_y:
    mov ecx, [current_row]              ; gets |Y|
    cmp ecx, 0
    jge dia_check_bounds
    neg ecx

dia_check_bounds:
    ; A diamond's walls perfectly align where |X| + |Y| == max_size
    add eax, ecx                        ; eax = |X| + |Y|
    cmp eax, [max_size]
    je dia_print_solid                  ; prints character if they perfectly equal max size
    jmp dia_print_empty                 ; otherwise leaves it completely hollow

; prints the character
dia_print_solid:
    mov ecx, draw_character
    mov edx, 2
    call print_msg
    jmp dia_next_col

; prints empty space
dia_print_empty:
    mov ecx, space
    mov edx, 2
    call print_msg

; jumps to the next column
dia_next_col:
    inc dword [current_col]
    jmp dia_col_loop

; jumps to the next row
dia_next_row:
    mov ecx, newline
    mov edx, 1
    call print_msg
    inc dword [current_row]
    jmp dia_row_loop

; finalizes when one shape is done
dia_shape_done:
    mov ecx, c_reset                    ; resets the terminal color
    mov edx, 4
    call print_msg

    mov ecx, newline                    ; prints gap for the next diamond shape
    mov edx, 1
    call print_msg
    call print_msg

    dec dword [num_of_shapes]           ; subtracts 1 from the shape count
    jmp dia_master_loop                 ; jumps back up for the next shape

; HEART DRAWING LOGIC:
; The grid is split into two sections based on the Y coordinate. Y starts at -(max_size / 2).
; CONDITION A: (Bottom Half, Y >= 0): |X| + Y <= max_size; prints the character to form the bottom triangle.
; CONDITION B: (Top Half, Top Row): X = 0 OR |X| = max_size; prints empty space to carve the cleft and rounded shoulders.
; CONDITION C: (Top Half, Body): |X| <= max_size; prints the character to fill in the rounded humps.

hrt_announce:
    mov ecx, msg_num
    mov edx, msg_num_len
    call print_msg
    call generate_random_hrt_num        ; calls the dedicated subroutine for number of shapes

hrt_master_loop:
    mov eax, [num_of_shapes]
    cmp eax, 0
    je main_menu                        ; Return to menu when done

    ; Paints the color
    mov ecx, [chosen_color]
    mov edx, 5
    call print_msg

hrt_init_row_loop:
    ; STEP 1: SET THE PROPORTIONS
    ; put the max_size into eax, divide it by 2, and make it negative.
    ; Example: if max_size is 6, Y starts at -3.
    mov eax, [max_size]                 ; loads the Size into eax
    xor edx, edx                        ; wipes edx clean
    mov ebx, 2                          ; loads our divisor (2) into a spare register
    div ebx                             ; divides edx:eax by ebx. the answer stays in eax
    neg eax                             ; flips it negative
    mov [current_row], eax              ; saves this as our starting Y coordinate

hrt_row_loop:
    mov eax, [current_row]
    cmp eax, [max_size]
    jg hrt_shape_done                   ; if Y > max_size,  jumps to shape done

    ; Push shape to correct location
    mov eax, [x_offset]
    mov [space_cnt], eax

hrt_location_loop:
    cmp dword [space_cnt], 0
    je hrt_col_loop_initialization
    mov ecx, space
    mov edx, 1
    call print_msg
    dec dword [space_cnt]
    jmp hrt_location_loop

hrt_col_loop_initialization:
    mov eax, [max_size]
    neg eax
    mov [current_col], eax              ; X starts at -max_size

hrt_col_loop:
    mov eax, [current_col]
    cmp eax, [max_size]
    jg hrt_next_row                     ; if X > max_size, drops down to the next row

hrt_get_x:
    mov eax, [current_col]
    cmp eax, 0
    jge hrt_evaluate                    ; if X is 0 or positive, jump to the math
    neg eax                             ; if X is negative, flip it positive. EAX now = |X|

hrt_evaluate:
    mov ecx, [current_row]              ; grabs our raw Y coordinate into ECX
    cmp ecx, 0
    jl hrt_top_half                     ; if Y is negative (< 0), jump to the top half logic

hrt_bottom_half:
    ; STEP 2: THE BOTTOM TRIANGLE (Y >= 0)
    ; Math: Checks if |X| + Y <= max_size--
    add eax, ecx                        ; adds |X| and Y together
    cmp eax, [max_size]
    jle hrt_print_solid                 ; If the sum is less than or equal to size, prints the character
    jmp hrt_print_empty                 ; otherwise, it prints empty space

hrt_top_half:
    ; STEP 3: THE TOP HUMPS (Y < 0)
    ; First, we check if we are currently scanning the absolute highest row in the grid (Y == -Size/2).
    ; div requires eax, but eax currently holds |X|! We must protect it.
    push eax                            ; saves |X| to the stack
    push edx                            ; saves edx to the stack just in case

    mov eax, [max_size]                 ; loads size into eax for division
    xor edx, edx                        ; wipes edx clean
    mov ebx, 2                          ; loads divisor into ebx
    div ebx                             ; divides edx:eax by ebx. Answer goes to eax.

    mov ebx, eax                        ; Moves our answer (size/2) safely into ebx
    pop edx                             ; restores edx from the stack
    pop eax                             ; restores |X| back into eax!

    neg ebx                             ; makes it negative
    cmp ecx, ebx                        ; is our current Y equal to the top row?
    jne hrt_top_hump_body               ; if no, jump down and just draw the solid body of the hump.

hrt_top_cleft_and_corners:
    ; STEP 4: knocks out three specific blocks to round out the shape.
    cmp dword [current_col], 0          ; check if we are at the exact center column (X = 0)
    je hrt_print_empty                  ; if yes, print an empty space (carves the cleft)

    cmp eax, [max_size]                 ; checks if |X| is equal to the max size?
    je hrt_print_empty                  ; if yes, print an empty space! (this carves the rounded shoulders)

    jmp hrt_print_solid                 ; if it's not the cleft and not a shoulder, print a solid block

hrt_top_hump_body:
    ; For all the negative rows below the top row, just draw a solid
    ; block of characters, ensuring not drawing wider than the max_size.
    cmp eax, [max_size]                 ; is |X| <= max_size?
    jle hrt_print_solid
    jmp hrt_print_empty

hrt_print_solid:
    mov ecx, draw_character
    mov edx, 2
    call print_msg
    jmp hrt_next_col

hrt_print_empty:
    mov ecx, space
    mov edx, 2
    call print_msg

hrt_next_col:
    inc dword [current_col]             ; X = X + 1
    jmp hrt_col_loop

hrt_next_row:
    mov ecx, newline
    mov edx, 1
    call print_msg
    inc dword [current_row]             ; Y = Y + 1
    jmp hrt_row_loop

hrt_shape_done:
    mov ecx, c_reset
    mov edx, 4
    call print_msg

    mov ecx, newline
    mov edx, 1
    call print_msg
    call print_msg

    dec dword [num_of_shapes]
    jmp hrt_master_loop

; ALL RANDOMIZATION FUNCTIONS
generate_random_color:
    push eax                            ; protects eax register before randomization
    push ecx                            ; protects ecx register before randomization
    push edx                            ; protects edx register before randomization

    ; grabs the cpu clock cycles
    rdtsc                               ; fills eax with low bits and edx with high bits
    xor edx, edx                        ; wipes edx register
    mov ecx, 7                          ; sets divisor to 7
    div ecx                             ; divide eax by 7 while the remainder (0-6) drops back into edx.

    ; Routes to the randomized color
    cmp edx, 0
    je rand_set_red                      ; jump to red
    cmp edx, 1
    je rand_set_green
    cmp edx, 2
    je rand_set_blue
    cmp edx, 3
    je rand_set_yellow
    cmp edx, 4
    je rand_set_cyan
    cmp edx, 5
    je rand_set_magenta
    jmp rand_set_default                 ; if the remainder is 6 it picks default

rand_set_red:
    mov dword [chosen_color], c_red     ; applies red color
    jmp color_done                      ; jumps to color_done
rand_set_green:
    mov dword [chosen_color], c_green   ; applies green color
    jmp color_done
rand_set_blue:
    mov dword [chosen_color], c_blue    ; applies blue color
    jmp color_done
rand_set_yellow:
    mov dword [chosen_color], c_yellow  ; applies yellow color
    jmp color_done
rand_set_cyan:
    mov dword [chosen_color], c_cyan    ; applies cyan color
    jmp color_done
rand_set_magenta:
    mov dword [chosen_color], c_magenta ; applies magenta color
    jmp color_done
rand_set_default:
    mov dword [chosen_color], c_reset   ; applies default color
    jmp color_done

color_done:
    pop edx                             ; restores edx register
    pop ecx                             ; restores ecx register
    pop eax                             ; restores eax register
    ret                                 ; returns to master loop

generate_random_hex_size:
    push eax                            ; protects eax register
    push ecx                            ; protects ecx register
    push edx                            ; protects edx register

    ; randomization of the size value (it juggles from 3 to 9)
    rdtsc                               ; reads time-stamp Counter (CPU clock cycles) which fills eax and edx
    xor edx, edx                        ; wipes the edx register clean for division
    mov ecx, 7                          ; sets the divisor to 7
    div ecx                             ; divides by 7 and the remainder from 0 to 6 goes to edx
    add edx, 3                          ; adds 3 to the remainder. now edx is a number from 3 to 9
    mov [rand_size], edx                ; saves this random number as the main size

    pop edx                             ; restores edx register
    pop ecx                             ; restores ecx register
    pop eax                             ; restores eax register
    ret                                 ; returns to master loop

generate_random_hg_location:
    push eax                            ; protects eax register
    push ecx                            ; protects ecx register
    push edx                            ; protects edx register

    ; Random Location Generator (Juggles location for every shape drawn)
    rdtsc                               ; grabs CPU clock cycles
    xor edx, edx
    mov ecx, 3                          ; divides by 3
    div ecx                             ; remainder (0, 1, or 2) goes to edx

    ; allocates location according to the randomization factor
    cmp edx, 0
    je rand_left
    cmp edx, 1
    je rand_center
    jmp rand_right

rand_left:
    mov dword [x_offset], 0            	; applies left offset
    jmp hg_loc_done                     ; jumps to loc_done
rand_center:
    mov dword [x_offset], 20            ; applies center offset
    jmp hg_loc_done
rand_right:
    mov dword [x_offset], 40            ; applies right offset
    jmp hg_loc_done

hg_loc_done:
    pop edx                             ; restores edx register
    pop ecx                             ; restores ecx register
    pop eax                             ; restores eax register
    ret                                 ; returns to master loop

generate_random_dia_char:
    push eax                            ; protects eax register
    push ecx                            ; protects ecx register
    push edx                            ; protects edx register

    ; Random Symbol Generator (Juggles A-Z for every shape drawn)
    rdtsc                               ; grabs CPU clock cycles
    xor edx, edx
    mov ecx, 94                         ; divide by 94 total character
    div ecx                             ; remainders is  0 to 93
    add edx, 33                         ; add 33 into the printable ascii block
    mov [draw_character], dl            ; loads the random letter into the draw variable
    mov byte [draw_character + 1], ' '

    pop edx                             ; restores edx register
    pop ecx                             ; restores ecx register
    pop eax                             ; restores eax register
    ret                                 ; returns to master loop

generate_random_hrt_num:
    push eax                            ; protects eax register
    push ecx                            ; protects ecx register
    push edx                            ; protects edx register

    ; Random Number Generator (1 to 9 shapes)
    rdtsc
    xor edx, edx
    mov ecx, 9
    div ecx
    add edx, 1                          ; shift remainder from 0-8 to 1-9
    mov [num_of_shapes], edx

    pop edx                             ; restores edx register
    pop ecx                             ; restores ecx register
    pop eax                             ; restores eax register
    ret                                 ; returns to master loop


; SHARED INPUT VALIDATION FUNCTIONS
error_main:
    call print_error_msg
    jmp main_menu

error_size:
    call print_error_msg
    jmp ask_size

error_location:
    call print_error_msg
    jmp ask_location

error_number:
    call print_error_msg
    jmp ask_number

error_character:
    call print_error_msg
    jmp ask_character

error_color:
    call print_error_msg
    jmp ask_color

print_error_msg:
    mov ecx, error_msg
    mov edx, error_msg_len
    call print_msg

    mov ecx, newline
    mov edx, 1
    call print_msg

    ret                                 ; teleports backs to whichever error block called it

; SHARED SUBROUTINE FUNCTIONS
print_msg:
    push eax                            ; pushes into stack to protect eax
    push ebx                            ; pushes into stack to protect ebx
    mov eax, 4                          ; sys_write
    mov ebx, 1                          ; stdout
    int 0x80                            ; System call for linux 32 bit
    pop ebx                             ; restores ebx
    pop eax                             ; restores eax
    ret                                 ; returns to the line of code where print_msg was called

read_input:
    ; Linux overwrites eax with the keystroke count which we need for input validation.
    push ebx                            ; pushes into stack to protect ebx
    push ecx                            ; pushes into stack to protect ecx
    push edx                            ; pushes into stack to protect edx
    mov eax, 3                          ; sys_read for terminal
    mov ebx, 0                          ; stdin
    mov ecx, input_user                 ; collects the input of the user
    mov edx, 16                         ; clears up to 16 bytes from the OS buffer
    int 0x80
    pop edx                             ; restores edx
    pop ecx                             ; restores ecx
    pop ebx                             ; restores ebx
    ret                                 ; returns to the line of code where read_input was called

; EXIT FUNCTION
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

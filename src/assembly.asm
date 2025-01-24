.data
    spaceship_x: 0x0140
    spaceship_y: 0x00f0
    planet_x: 0x0140
    planet_y: 0x00f0

.code
    # Initialize memory locations for planet bitmap
    ldi 3 0x91f
    ldi 2 0x0
    st 3 2
    ldi 3 0x91e
    ldi 2 0x0
    st 3 2
    ldi 3 0x91d
    ldi 2 0x380
    st 3 2
    ldi 3 0x91c
    ldi 2 0x7c0
    st 3 2
    ldi 3 0x91b
    ldi 2 0xfe0
    st 3 2
    ldi 3 0x91a
    ldi 2 0x1ff0
    st 3 2
    ldi 3 0x919
    ldi 2 0x3ff8
    st 3 2
    ldi 3 0x918
    ldi 2 0x7ffc
    st 3 2
    ldi 3 0x917
    ldi 2 0x7ffc
    st 3 2
    ldi 3 0x916
    ldi 2 0x7ffc
    st 3 2
    ldi 3 0x915
    ldi 2 0x3ff8
    st 3 2
    ldi 3 0x914
    ldi 2 0x1ff0
    st 3 2
    ldi 3 0x913
    ldi 2 0xfe0
    st 3 2
    ldi 3 0x912
    ldi 2 0x7c0
    st 3 2
    ldi 3 0x911
    ldi 2 0x380
    st 3 2
    ldi 3 0x910
    ldi 2 0x0
    st 3 2

    # Initialize memory locations for spaceship bitmap
    ldi 3 0x92f
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x92e
    ldi 2 0x7f0
    st 3 2
    ldi 3 0x92d
    ldi 2 0x3e0
    st 3 2
    ldi 3 0x92c
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x92b
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x92a
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x929
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x928
    ldi 2 0x1ffc
    st 3 2
    ldi 3 0x927
    ldi 2 0xff8
    st 3 2
    ldi 3 0x926
    ldi 2 0x7f0
    st 3 2
    ldi 3 0x925
    ldi 2 0x3e0
    st 3 2
    ldi 3 0x924
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x923
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x922
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x921
    ldi 2 0x1c0
    st 3 2
    ldi 3 0x920
    ldi 2 0x80
    st 3 2

    # Load spaceship and planet coordinates into specific memory locations
    ldi 2 spaceship_x
    ld 2 2
    ldi 3 0x905
    st 3 2

    ldi 2 spaceship_y
    ld 2 2
    ldi 3 0x906
    st 3 2

    ldi 2 planet_x
    ld 2 2
    ldi 3 0x903
    st 3 2

    ldi 2 planet_y
    ld 2 2
    ldi 3 0x904
    st 3 2

    # Initialize planet direction
    ldi 5 0x1 # planet direction x
    ldi 6 0x1 # planet direction y

    # Set up interrupt handlers
    ldi 7 0x1e0
    ldi 0 0x1f2
    ldi 1 handle_key # keyboard interrupt
    st 0 1
    ldi 0 0x1f3
    ldi 1 handle_planet # timer interrupt
    st 0 1
    sti

loop
    jmp loop

handle_planet
    ldi 0 0x907
    ld 0 0
    jmp planet_direction_x

planet_direction_x
    ldi 1 0x1
    sub 2 5 1
    jz planet_right
    ldi 1 0x2
    sub 2 5 1
    jz planet_left
    jmp handle_planet_out

planet_left
    ldi 0 0x903
    ld 0 0
    ldi 1 0x14
    sub 2 0 1
    ldi 0 0x903
    st 0 2
    jmp direction_x_update

planet_right
    ldi 0 0x903
    ld 0 0
    ldi 1 0x14
    add 2 0 1
    ldi 0 0x903
    st 0 2
    jmp direction_x_update

direction_x_update
    ldi 0 0x903
    ld 0 0
    ldi 1 0x0
    sub 2 0 1
    jz direction_right
    ldi 1 0x26c
    sub 2 0 1
    jz direction_left
    jmp planet_direction_y

direction_left
    ldi 5 0x2
    jmp planet_direction_y

direction_right
    ldi 5 0x1
    jmp planet_direction_y

planet_direction_y
    ldi 1 0x1
    sub 2 6 1
    jz planet_up
    ldi 1 0x2
    sub 2 6 1
    jz planet_down
    jmp handle_planet_out

planet_down
    ldi 0 0x904
    ld 0 0
    ldi 1 0xa
    add 2 0 1
    ldi 0 0x904
    st 0 2
    jmp direction_y_update

planet_up
    ldi 0 0x904
    ld 0 0
    ldi 1 0xa
    sub 2 0 1
    ldi 0 0x904
    st 0 2
    jmp direction_y_update

direction_y_update
    ldi 0 0x904
    ld 0 0
    ldi 1 0x0
    sub 2 0 1
    jz direction_down
    ldi 1 0x1cc
    sub 2 0 1
    jz direction_up
    jmp handle_planet_out

direction_up
    ldi 6 0x1
    jmp handle_planet_out

direction_down
    ldi 6 0x2
    jmp handle_planet_out

handle_planet_out
    sti
    iret

handle_key
    ldi 0 0x902
    ld 0 0
    ldi 1 0x001c
    sub 2 0 1
    jz handle_left
    ldi 1 0x0023
    sub 2 0 1
    jz handle_right
    ldi 1 0x001d
    sub 2 0 1
    jz handle_up
    ldi 1 0x001b
    sub 2 0 1
    jz handle_down
    jmp handle_key_out

handle_left
    ldi 1 0x905
    ld 1 1
    ldi 2 0x4
    sub 1 1 2
    ldi 2 0xfffc
    sub 2 1 2
    jz handle_key_out
    ldi 2 0x905
    st 2 1
    jmp handle_key_out

handle_right
    ldi 1 0x905
    ld 1 1
    ldi 2 0x4
    add 1 1 2
    ldi 2 0x274
    sub 2 1 2
    jz handle_key_out
    ldi 2 0x905
    st 2 1
    jmp handle_key_out

handle_up
    ldi 1 0x906
    ld 1 1
    ldi 2 0x4
    sub 1 1 2
    ldi 2 0xfffc
    sub 2 1 2
    jz handle_key_out
    ldi 2 0x906
    st 2 1
    jmp handle_key_out

handle_down
    ldi 1 0x906
    ld 1 1
    ldi 2 0x4
    add 1 1 2
    ldi 2 0x1d4
    sub 2 1 2
    jz handle_key_out
    ldi 2 0x906
    st 2 1
    jmp handle_key_out

handle_key_out
    sti
    iret
.data
initial_prompt:  .asciiz "How many numbers would you like to enter? "
part_one_prompt: .asciiz "Enter the number at index "
part_two_prompt: .asciiz ": "
newline:         .asciiz "\n"
result:          .asciiz "\nThe sorted result is: \n"
goodbye:         .asciiz "\nGoodbye!\n"

.text

main:
    #user prompt for the number of inputs
    li      $v0, 4  
    la      $a0, initial_prompt 
    syscall

    # read in the value
    li      $v0, 5          #5 for int, 6 for float
    syscall 
    move    $t0, $v0        #moves input to $t0

    mul     $t1, $t0, 4     #calculates total size of the array (number of floats * 4 size of floats)

    li      $v0, 9     
    move    $a0, $t1        #number of bytes we want to allocate 
    syscall             
    move    $t8, $v0        #input array

    move    $t1, $t8        #array pointer
    move    $t2, $zero      #for counter
    jal input 

    move    $t1, $t8        #reset array pointer
    li      $t2, 1          #reset counter for sort
    jal sort   #insertion sort

    move    $t2, $zero        #reset counter for print
    move    $t1, $t8          #reset array pointer
    li      $v0, 4  
    la      $a0, result 
    syscall
    jal   print

    #exits program
    li      $v0, 4  
    la      $a0, goodbye 
    syscall
    li $v0, 10 
    syscall

#t0 has number of values, t1 is array pointer, t2 is incrementer
input:
    beq     $t0, $t2, finish 

    li      $v0, 4  
    la      $a0, part_one_prompt 
    syscall
    li      $v0, 1 
    move    $a0, $t2 
    syscall
    li      $v0, 4  
    la      $a0, part_two_prompt 
    syscall

    
    li      $v0, 6            
    syscall                  
    s.s     $f0, 0($t1)       #stores input in array

    addi    $t1, $t1, 4       #array element increment
    addi    $t2, $t2, 1       #while-loop increment
    j       input

#t0 has number of values (n)
#t1 is array pointer (arr[])
#t2 is incrementer (i)
#t3 is j
#t4 is arr[i]
#t5 is arr[j]
#f0 is key 
#f1 is arr[j]
sort:       #for (int i = 1; i < n; i++)
    slt		$t9, $t2, $t0		
    beq     $t9, $zero, finish
    mul     $t6, $t2, 4 
    add     $t4, $t1, $t6 
    l.s     $f0, 0($t4) #stores key (key = arr[i])
    sub     $t3, $t2, 1 #sets j as i - 1
    j       inner_loop  #while(j >= 0 && arr[j] > key)

inner_loop:  #while(j >= 0 && arr[j] > key)
    slti    $t9, $t3, 0  #if j < 0, t9 = 1
    bne     $t9, $zero, increment
    mul     $t6, $t3, 4 
    add     $t5, $t1, $t6
    l.s     $f1, 0($t5)  #valye of arr[j]
    c.lt.s  $f0, $f1     #if arr[j] < key
    bc1f    increment    #if 0, go to increment (leave loop)

    s.s     $f1, 4($t5)  #arr[j + 1] = arr[j]
    sub     $t3, $t3, 1  #j = j - 1;
    j       inner_loop

increment:    #arr[j + 1] = key;
    mul     $t6, $t3, 4  #recalculate arr[j]
    add     $t5, $t1, $t6
    s.s     $f0, 4($t5)
    addi    $t2, $t2, 1
    j       sort

print:
    beq     $t0, $t2, finish  #while-loop check
    
    li      $v0, 2  
    l.s     $f12, 0($t1)      
    syscall

    li      $v0, 4  
    la      $a0, newline 
    syscall

    addi    $t1, $t1, 4       #array element increment
    addi    $t2, $t2, 1       #while-loop increment

    j       print

finish:
    jr      $ra

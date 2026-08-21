.data
    array:      .word 29, 10, 14, 37, 13, -5, 42, 8, 0, 1
    temp:       .space 40        # Espacio auxiliar para la fusión (10 palabras x 4 bytes)
    size:       .word 10
    space:      .asciiz " "
    newline:    .asciiz "\n"
    msg_unsort: .asciiz "Arreglo original: \n"
    msg_sort:   .asciiz "Arreglo ordenado con Mergesort Iterativo: \n"

.text
.globl main

main:
    # Imprimir mensaje inicial
    li $v0, 4
    la $a0, msg_unsort
    syscall

    # Imprimir arreglo original
    la $a0, array
    lw $a1, size
    jal print_array

    # Preparar argumentos para Mergesort Iterativo
    la $a0, array       # $a0 = dirección base del arreglo
    lw $a1, size        # $a1 = tamaño del arreglo (n)

    # Llamar a Mergesort Iterativo
    jal mergesort_iterativo

    # Imprimir mensaje final
    li $v0, 4
    la $a0, msg_sort
    syscall

    # Imprimir arreglo ordenado
    la $a0, array
    lw $a1, size
    jal print_array

    # Fin del programa
    li $v0, 10
    syscall

# ---------------------------------------------------------
# Función: mergesort_iterative (Bottom-Up)
# Argumentos: $a0 = dirección base, $a1 = n (tamaño)
# ---------------------------------------------------------
mergesort_iterativo:
    # --- Prólogo ---
    # Guardamos registros $s y $ra ya que iteraremos y llamaremos a merge
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s5, 20($sp)     # $s5 = base address
    sw $s4, 16($sp)     # $s4 = right_end
    sw $s3, 12($sp)     # $s3 = mid
    sw $s2, 8($sp)      # $s2 = n
    sw $s1, 4($sp)      # $s1 = left_start
    sw $s0, 0($sp)      # $s0 = curr_size

    move $s5, $a0       # Guardar base address de forma segura
    move $s2, $a1       # Guardar n
    li $s0, 1           # curr_size = 1

outer_loop:
    bge $s0, $s2, end_outer_loop    # Si curr_size >= n, terminar

    li $s1, 0                       # left_start = 0

inner_loop:
    addi $t0, $s2, -1               # $t0 = n - 1
    bge $s1, $t0, end_inner_loop    # Si left_start >= n - 1, salir del bucle interno

    # Calcular mid = min(left_start + curr_size - 1, n - 1)
    add $t1, $s1, $s0               # left_start + curr_size
    addi $t1, $t1, -1               # left_start + curr_size - 1
    ble $t1, $t0, mid_ok
    move $t1, $t0                   # Si excede, mid = n - 1
mid_ok:
    move $s3, $t1                   # $s3 = mid

    # Calcular right_end = min(left_start + 2 * curr_size - 1, n - 1)
    sll $t2, $s0, 1                 # 2 * curr_size
    add $t2, $s1, $t2               # left_start + 2 * curr_size
    addi $t2, $t2, -1               # left_start + 2 * curr_size - 1
    ble $t2, $t0, right_ok
    move $t2, $t0                   # Si excede, right_end = n - 1
right_ok:
    move $s4, $t2                   # $s4 = right_end

    # Preparar argumentos y llamar a merge
    move $a0, $s5                   # $a0 = base address
    move $a1, $s1                   # $a1 = left_start
    move $a2, $s3                   # $a2 = mid
    move $a3, $s4                   # $a3 = right_end
    jal merge

    # left_start += 2 * curr_size
    sll $t3, $s0, 1                 # 2 * curr_size
    add $s1, $s1, $t3
    j inner_loop

end_inner_loop:
    sll $s0, $s0, 1                 # curr_size *= 2
    j outer_loop

end_outer_loop:
    # --- Epílogo ---
    lw $ra, 24($sp)
    lw $s5, 20($sp)
    lw $s4, 16($sp)
    lw $s3, 12($sp)
    lw $s2, 8($sp)
    lw $s1, 4($sp)
    lw $s0, 0($sp)
    addi $sp, $sp, 28
    jr $ra

# ---------------------------------------------------------
# Función: merge
# Fusión de subarreglos: array[l..mid] y array[mid+1..r]
# Argumentos: $a0 = base, $a1 = l, $a2 = mid, $a3 = r
# ---------------------------------------------------------
merge:
    move $t0, $a1       # i = l
    addi $t1, $a2, 1    # j = mid + 1
    move $t2, $a1       # k = l
    la $t3, temp        # $t3 = base temp

merge_loop:
    bgt $t0, $a2, copy_remaining_right
    bgt $t1, $a3, copy_remaining_left

    # array[i]
    sll $t4, $t0, 2
    add $t4, $a0, $t4
    lw $t5, 0($t4)

    # array[j]
    sll $t6, $t1, 2
    add $t6, $a0, $t6
    lw $t7, 0($t6)

    bgt $t5, $t7, select_right

    # temp[k] = array[i]
    sll $t8, $t2, 2
    add $t8, $t3, $t8
    sw $t5, 0($t8)
    addi $t0, $t0, 1
    j next_merge_step

select_right:
    # temp[k] = array[j]
    sll $t8, $t2, 2
    add $t8, $t3, $t8
    sw $t7, 0($t8)
    addi $t1, $t1, 1

next_merge_step:
    addi $t2, $t2, 1
    j merge_loop

copy_remaining_left:
    bgt $t0, $a2, copy_back
    sll $t4, $t0, 2
    add $t4, $a0, $t4
    lw $t5, 0($t4)

    sll $t8, $t2, 2
    add $t8, $t3, $t8
    sw $t5, 0($t8)

    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j copy_remaining_left

copy_remaining_right:
    bgt $t1, $a3, copy_back
    sll $t6, $t1, 2
    add $t6, $a0, $t6
    lw $t7, 0($t6)

    sll $t8, $t2, 2
    add $t8, $t3, $t8
    sw $t7, 0($t8)

    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j copy_remaining_right

copy_back:
    move $t0, $a1       # i = l
copy_back_loop:
    bgt $t0, $a3, merge_end

    sll $t4, $t0, 2
    add $t5, $t3, $t4   # temp[i]
    lw $t6, 0($t5)

    add $t7, $a0, $t4   # array[i]
    sw $t6, 0($t7)      # array[i] = temp[i]

    addi $t0, $t0, 1
    j copy_back_loop

merge_end:
    jr $ra

# ---------------------------------------------------------
# Función: print_array
# Argumentos: $a0 = base address, $a1 = size
# ---------------------------------------------------------
print_array:
    move $t0, $a0
    move $t1, $a1
    li $t2, 0

print_loop:
    bge $t2, $t1, print_end

    lw $a0, 0($t0)
    li $v0, 1
    syscall

    la $a0, space
    li $v0, 4
    syscall

    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j print_loop

print_end:
    la $a0, newline
    li $v0, 4
    syscall
    jr $ra
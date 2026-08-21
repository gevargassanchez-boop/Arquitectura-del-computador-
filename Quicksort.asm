.data
    array:      .word 29, 10, 14, 37, 13, -5, 42, 8, 0, 1
    size:       .word 10
    space:      .asciiz " "
    newline:    .asciiz "\n"
    msg_unsort: .asciiz "Arreglo original: \n"
    msg_sort:   .asciiz "Arreglo ordenado: \n"

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
    jal print_array	#Llamada a la funcion

    # Preparar argumentos para Quicksort
    la $a0, array       # $a0 = dirección base del arreglo
    li $a1, 0           # $a1 = low (índice 0)
    lw $t0, size
    addi $a2, $t0, -1   # $a2 = high (size - 1)

    # Llamar a Quicksort
    jal quicksort

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
# Función: quicksort
# Argumentos: $a0 = base address, $a1 = low, $a2 = high
# ---------------------------------------------------------
quicksort:
    bge $a1, $a2, end_quicksort # Caso base: si low >= high, retornar

    # --- Prólogo ---
    # Guardamos registros en la pila. Disminuimos $sp estrictamente en 16 (4 palabras x 4 bytes)
    addi $sp, $sp, -16
    sw $ra, 12($sp)     # Guardar return address
    sw $a0, 8($sp)      # Guardar base address
    sw $a1, 4($sp)      # Guardar low
    sw $a2, 0($sp)      # Guardar high

    # Llamar a partition
    jal partition
    move $s0, $v0       # $s0 = índice pivote devuelto por partition

    # Llamada recursiva 1: quicksort(array, low, pivot - 1)
    lw $a0, 8($sp)      # Restaurar base address
    lw $a1, 4($sp)      # Restaurar low
    addi $a2, $s0, -1   # high = pivot - 1
    jal quicksort

    # Llamada recursiva 2: quicksort(array, pivot + 1, high)
    lw $a0, 8($sp)      # Restaurar base address
    addi $a1, $s0, 1    # low = pivot + 1
    lw $a2, 0($sp)      # Restaurar high original
    jal quicksort

    # --- Epílogo ---
    # Restaurar registros y pila
    lw $ra, 12($sp)
    lw $a0, 8($sp)
    lw $a1, 4($sp)
    lw $a2, 0($sp)
    addi $sp, $sp, 16   # Liberar los 16 bytes de la pila

end_quicksort:
    jr $ra

# ---------------------------------------------------------
# Función: partition
# Argumentos: $a0 = base address, $a1 = low, $a2 = high
# Retorna: $v0 = índice del pivote
# ---------------------------------------------------------
partition:
    # Calculamos la dirección del pivote (high)
    sll $t0, $a2, 2     # $t0 = high * 4
    add $t0, $a0, $t0   # $t0 = dirección de array[high]
    lw $t1, 0($t0)      # $t1 = pivote (valor)

    addi $t2, $a1, -1   # $t2 = i = low - 1
    move $t3, $a1       # $t3 = j = low

partition_loop:
    bge $t3, $a2, partition_end # si j >= high, salir del bucle

    # Cargar array[j]
    sll $t4, $t3, 2     # $t4 = j * 4
    add $t4, $a0, $t4   # $t4 = dirección de array[j]
    lw $t5, 0($t4)      # $t5 = array[j]

    bgt $t5, $t1, skip_swap # si array[j] > pivote, no intercambiar

    # Incrementar i y hacer swap(array[i], array[j])
    addi $t2, $t2, 1
    sll $t6, $t2, 2
    add $t6, $a0, $t6   # $t6 = dirección de array[i]
    lw $t7, 0($t6)      # $t7 = array[i]

    sw $t5, 0($t6)      # array[i] = array[j]
    sw $t7, 0($t4)      # array[j] = temp

skip_swap:
    addi $t3, $t3, 1    # j++
    j partition_loop

partition_end:
    # swap(array[i+1], array[high])
    addi $t2, $t2, 1    # i + 1
    sll $t6, $t2, 2
    add $t6, $a0, $t6   # dirección de array[i+1]
    lw $t7, 0($t6)      # cargar array[i+1]

    sw $t1, 0($t6)      # array[i+1] = pivote
    sw $t7, 0($t0)      # array[high] = temp

    move $v0, $t2       # retornar (i + 1) en $v0
    jr $ra

# ---------------------------------------------------------
# Función: print_array (Imprime el arreglo para verificar)
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

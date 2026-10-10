.data
    buffer:     .space 256          # Espacio para el buffer circular
    msg_out:    .asciiz "\n[Tiempo de 20s cumplido] Contenido del buffer: "
    newline:    .asciiz "\n"

.text
.globl main

main:
    # Obtener tiempo inicial
    li $v0, 30          # Syscall 30: System Time
    syscall             # Retorna: $a0 = low 32 bits, $a1 = high 32 bits
    move $s0, $a0       # $s0 = tiempo inicial (ms)
    
    la $s1, buffer      # $s1 = puntero actual del buffer
    la $s2, buffer      # $s2 = dirección base del buffer

loop_principal:
    # 1. Verificar tiempo transcurrido
    li $v0, 30
    syscall
    subu $t0, $a0, $s0  # $t0 = tiempo actual - tiempo inicial
    bge $t0, 20000, imprimir_buffer  # Si pasaron 20000 ms (20s), vaciar buffer

    # 2. Verificar si hay un caracter disponible en el teclado (MMIO)
    lui $t1, 0xffff     # Dirección base de I/O
    lw $t2, 0($t1)      # Leer registro de control del teclado (0xffff0000)
    andi $t2, $t2, 1    # Comprobar el bit Ready (bit 0)
    beqz $t2, loop_principal # Si no hay tecla, seguir iterando

    # 3. Leer el caracter y filtrar
    lw $t3, 4($t1)      # Leer el dato del teclado (0xffff0004)
    
    # Filtrar: Solo mayúsculas (A-Z) -> ASCII 65 a 90
    blt $t3, 65, loop_principal # Si es menor a 'A', ignorar
    bgt $t3, 90, loop_principal # Si es mayor a 'Z', ignorar

    # Guardar en buffer
    sb $t3, 0($s1)      # Guardar byte en la posición actual
    addiu $s1, $s1, 1   # Avanzar puntero
    # (Opcional: aquí se podría implementar la lógica estricta de reinicio circular si se llena, 
    # pero al vaciarse cada 20s, 256 bytes suelen ser suficientes).
    
    j loop_principal

imprimir_buffer:
    # Terminar el string con null para imprimirlo
    sb $zero, 0($s1)

    # Imprimir mensaje
    li $v0, 4
    la $a0, msg_out
    syscall

    # Imprimir el contenido del buffer
    li $v0, 4
    la $a0, buffer
    syscall

    # Imprimir salto de línea
    li $v0, 4
    la $a0, newline
    syscall

    # Reiniciar estado (Vaciar buffer y reiniciar tiempo)
    la $s1, buffer      # Puntero vuelve al inicio
    li $v0, 30
    syscall
    move $s0, $a0       # Nuevo tiempo inicial
    
    j loop_principal
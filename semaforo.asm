.data
    msg_verde_esp:  .asciiz "\nSemáforo en verde, esperando pulsador...\n"
    msg_pulsador:   .asciiz "\nPulsador activado: en 20 segundos, el semáforo cambiará a amarillo.\n"
    msg_amarillo:   .asciiz "\nSemáforo en amarillo, en 10 segundos, semáforo en rojo.\n"
    msg_rojo:       .asciiz "\nSemáforo en rojo, en 30 segundos, semáforo en verde.\n"

.text
.globl main

main:
    # Estado 0: Verde esperando pulsador
estado_verde:
    li $v0, 4
    la $a0, msg_verde_esp
    syscall

esperar_pulsador:
    # Verificar teclado (MMIO)
    lui $t1, 0xffff
    lw $t2, 0($t1)
    andi $t2, $t2, 1
    beqz $t2, esperar_pulsador # Ciclo infinito hasta que se presione algo

    lw $t3, 4($t1)             # Leer tecla
    bne $t3, 115, esperar_pulsador # 115 es el código ASCII para 's' minúscula. Si no es 's', seguir esperando.

    # Transición al ciclo automático
    li $v0, 4
    la $a0, msg_pulsador
    syscall

    # Iniciar temporizador de 20s
    li $v0, 30
    syscall
    move $s0, $a0       # $s0 = Tiempo inicial de espera

esperar_20s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    blt $t0, 20000, esperar_20s # Esperar hasta cumplir 20s

    # Estado 1: Amarillo
estado_amarillo:
    li $v0, 4
    la $a0, msg_amarillo
    syscall
    
    li $v0, 30
    syscall
    move $s0, $a0

esperar_10s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    blt $t0, 10000, esperar_10s # Esperar 10s

    # Estado 2: Rojo
estado_rojo:
    li $v0, 4
    la $a0, msg_rojo
    syscall

    li $v0, 30
    syscall
    move $s0, $a0

esperar_30s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    blt $t0, 30000, esperar_30s # Esperar 30s

    # Volver al inicio del ciclo
    j estado_verde
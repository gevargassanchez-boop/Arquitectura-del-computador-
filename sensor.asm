.data
    # Simulación del mapa de memoria del sensor (Memory-Mapped I/O)
    LuzControl: .word 0  # 1 = inicializa
    LuzEstado:  .word 0  # 0 = no listo, 1 = listo, -1 = error
    LuzDatos:   .word 0  # Valor entre 0 y 1023

.text
.globl main

main:
    # Llamada de prueba para inicializar
    jal InicializarSensorLuz
    
    # Llamada de prueba para leer datos
    jal LeerLuminosidad
    
    # Fin del programa (Llamada al sistema para salir de manera limpia en MARS)
    li $v0, 10
    syscall

# =====================================================================
# Procedimiento: InicializarSensorLuz
# Descripción: Escribe 0x1 en LuzControl y hace polling hasta estar listo.
# =====================================================================
InicializarSensorLuz:
    # 1. Enviar comando de inicialización
    la $t0, LuzControl         # Cargamos la dirección en memoria de LuzControl
    li $t1, 1                  # Cargamos el valor 0x1
    sw $t1, 0($t0)             # Escribimos 1 en LuzControl (Inicia el hardware)

espera_init_luz:
    # 2. Bucle de espera activa (Polling)
    la $t0, LuzEstado          # Cargamos la dirección de LuzEstado
    lw $t1, 0($t0)             # Leemos el valor actual del estado
    
    # Si el estado es 0 (no listo), saltamos de nuevo a 'espera_init_luz'
    beqz $t1, espera_init_luz  
    
    # Si sale del bucle (es 1 o -1), terminamos la rutina
    jr $ra                     # Retornar al programa que hizo el llamado


# =====================================================================
# Procedimiento: LeerLuminosidad
# Descripción: Revisa el estado. Retorna lectura y código de estado.
# Salida: $v0 = Valor leído, $v1 = Estado (0 correcto, -1 error)
# =====================================================================
LeerLuminosidad:
    # 1. Leer el estado actual
    la $t0, LuzEstado
    lw $t1, 0($t0)             # Cargamos LuzEstado en $t1
    
    # 2. Verificar si hay error de hardware (-1)
    li $t2, -1
    beq $t1, $t2, error_luz    # Si Estado == -1, saltar a la etiqueta de error

    # 3. Si el estado es 1 (listo), procedemos a leer los datos
    la $t0, LuzDatos
    lw $v0, 0($t0)             # $v0 = Valor leído (luminosidad)
    li $v1, 0                  # $v1 = 0 (Código de lectura correcta)
    jr $ra                     # Retornar

error_luz:
    li $v0, 0                  # En caso de error, devolvemos 0 en los datos
    li $v1, -1                 # $v1 = -1 (Código de error)
    jr $ra                     # Retornar
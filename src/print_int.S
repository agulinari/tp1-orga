#include <mips/regdef.h>
#include <sys/syscall.h>

    .text            # segmento de texto del programa

    .abicalls
    .align 2        # alineacion 2^2

    .globl    print_int
    .ent      print_int
print_int:
    # debugging info: descripcion del stack frame
    .frame    $fp, 40, ra              # $fp: registro usado como frame pointer
                                       # 40: size del stack frame
                                       # ra: registro que almacena el return address
    # bloque para codigo PIC
    .set    noreorder                  # apaga reordenamiento de instrucciones
    .cpload t9                         # directiva usada para codigo PIC
    .set    reorder                    # enciende reordenamiento de instrucciones

    # creo stack frame
    subu         sp, sp, 40            # 4 (SRA) + 2 (LTA) + 4 (ABA)

    # directiva para codigo PIC
    .cprestore 24                      # inserta aqui "sw gp, 24(sp)",
                                       # mas "lw gp, 24(sp)" luego de cada jal.
    # salvado de callee-saved regs en SRA    
    sw           $fp, 28(sp)
    sw           ra, 32(sp)

    # de aqui al fin de la funcion uso $fp en lugar de sp.
    move         $fp, sp
    
    # salvo 1er arg (siempre)
    sw           a0, 40($fp)            # n: a0, sp+40

    # salveo 2do arg
    sw           a1, 44($fp)            # fd: a1, sp+44

    # r = n % 10;
    remu         t0, a0, 10             # r: t0, sp+16    ## remU
    sw           t0, 16($fp)

    # n /= 10;
    lw           a0, 40($fp)            ## redundante
    divu         a0, a0, 10             ## divU!
    sw           a0, 40($fp)

    ## if (n > 0)
    lw           a0, 40($fp)            ## redundante
    beq          a0, zero, _write_digit # n>0 equivale a n!=0 (n unsigned)
    
    #    print_int(n);
    lw           a0, 40($fp)            ## redundante
    la           t9, print_int
    jal          ra, t9

_write_digit:
    # write(1, digit[r], 1);
    # calculo auxiliar: obtengo digit[r]
    lw           a0, 16($fp)            # r: a0, sp+16
    sll          a0, a0, 2              # escalo r con tam de ptr (r*=4)
    lw           a0, digit(a0)          # digit[r]: a0
    sw           a0, 20($fp)            # almaceno digit[r] en LTA
    
    # cargo argumentos y llamo a buff_write
    li           a2, 1
    lw           a1, 20($fp)            # digit[r] ## (por que no hago move a1, a0?)
    lw           a0, 44($fp)            # fd    
    la           t9, buff_write
    jal          ra, t9

    # return;
    # restauro callee-saved regs
    lw           gp, 24(sp)
    lw           $fp, 28(sp)
    lw           ra, 32(sp)
    # destruyo stack frame
    addu         sp, sp, 40
    # vuelvo a funcion llamante
    jr           ra

    .end     print_int
    .size    print_int,.-print_int



    .rdata            # segmento read-only data

    .align 2
digit:    .word digit_0, digit_1, digit_2, digit_3, digit_4, \
          digit_5, digit_6, digit_7, digit_8, digit_9
    .size digit, 40

    .align 0        # alineacion 2^0

digit_0: .asciiz "0"
digit_1: .asciiz "1"
digit_2: .asciiz "2"
digit_3: .asciiz "3"
digit_4: .asciiz "4"
digit_5: .asciiz "5"
digit_6: .asciiz "6"
digit_7: .asciiz "7"
digit_8: .asciiz "8"
digit_9: .asciiz "9"


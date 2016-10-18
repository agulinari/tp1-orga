#include <mips/regdef.h>
#include <sys/syscall.h>


#define STACK_SIZE       88
#define BUFFER_SIZE      64
#define RA_POS           80
#define GP_POS           76
#define FP_POS           72

.data
.align 2
endl: .asciiz "\n"

.text
.abicalls
.align 2
.global mips32_plot
.ent mips32_plot

mips32_plot:    
    .frame        $fp, STACK_SIZE, ra
    .set          noreorder
    .cpload       t9
    .set          reorder
      subu          sp, sp, STACK_SIZE      
      sw            ra, RA_POS(sp)             #save ra      
      # directiva para codigo PIC
      .cprestore GP_POS		# inserta aqui "sw gp, GP_POS(sp)",
				# mas "lw gp, GP_POS(sp)" luego de cada jal.
      sw            $fp,FP_POS(sp)             #save fp
      move          $fp, sp                    #fp->sp


    ####
    #aca empieza el codigo de la function
      ####
      sw            a0, STACK_SIZE($fp)
      l.s           $f2, 24(a0)             #cpr = parms->cp_re          
      l.s           $f4, 28(a0)             #cpi = parms-> cp_im
      s.s           $f2, 60($fp)
      s.s           $f4, 64($fp)

      ##
      # LLAMAR A FUNCION QUE IMPRIMA imprimirHeader(x,y,shades)
      # static char header[16] = "P2\n%u\n%u\n%u\n";
      # .data 
      # header: .ascii "P2\n%u\n%u\n%u\n"
      ## 
      
# CICLO FOR Y

      li           t0,0
      sw           t0, 48($fp)         #y=0
      lw           t0, STACK_SIZE($fp) #params
      l.s          $f2, 4(t0)           #params->UL_im 
      s.s          $f2, 20($fp)         #ci = params->UL_im
loop_y:      
      lw           t0, 48($fp)         #t0=y
      l.s          $f2, 20($fp)        #f2=ci       
      lw           t2, STACK_SIZE($fp) #t2=params
      lw           t3, 36(t2)          #t3=params->y_res 
      bge          t0, t3, end_y       #y<params->y_res
      
#CICLO FOR X
      li           t0, 0                #t0=0
      sw           t0, 44($fp)          #x=0
      lw           t0, STACK_SIZE($fp)  #params
      l.s          $f2, 0(t0)           #params->UL_re
      s.s          $f2, 16($fp)         #cr = params->UL_re
loop_x:
      lw           t0, 44($fp)          #t0=x
      l.s          $f2, 16($fp)         #f2=cr       
      lw           t2, STACK_SIZE($fp)  #t2=params
      lw           t3, 32(t2)           #t3=params->x_res 
      bge          t0, t3, end_x        #x<params->y_res
       
      l.s          $f4, 20($fp)         #ci                                
      s.s          $f2, 24($fp)         #zr=cr
      s.s          $f4, 28($fp)         #zi=ci 

#CICLO FOR C

      li           t0, 0                #t0=0
      sw           t0, 52($fp)          #c=0
loop_c:
      lw           t0, 52($fp)          #t0=c
      lw           t1, STACK_SIZE($fp)  #params
      lw           t1, 40(t1)           #params->shades
      bge          t0, t1, end_c        #c<params->shades

#IF
      l.s          $f2, 24($fp)         #f2=zr
      l.s          $f4, 28($fp)         #f4=zi
      mul.s        $f6, $f2, $f2        #f6=zr*zr
      mul.s        $f8, $f4, $f4        #f8=zi*zi
      add.s        $f10, $f6,$f8         #f10=zr*zr+zi*zi
      s.s          $f10, 40($fp)         #absz=zr*zr+zi*zi
      li.s         $f12, 4.0  
      c.lt.s       $f12, $f10           # (absz < 4.0)           
      bc1t         end_c                #if (absz>4.0f) break      
      sub.s        $f6, $f6, $f8        #f6=zr*zr-zi*zi
      l.s          $f8 , 60($fp)        #f8 =cpr
      add.s        $f6, $f6, $f8        #f6=zr*zr-zi*zi+cpr
      s.s          $f6, 32($fp)         #sr=zr*zr-zi*zi+cpr
      li.s         $f10, 2.0
      mul.s        $f8, $f2, $f10          #f8=2*zr
      mul.s        $f8, $f8, $f4        #f8=2*zr*zi
      l.s          $f4, 64($fp)         #f4 = cpi
      add.s        $f8, $f8, $f4        #f8=2*zr*zi + cpi   
      s.s          $f8, 36($fp)         #si=2*zr*zi + cpi
      s.s          $f6, 24($fp)         #zr=sr
      s.s          $f8, 28($fp)         #zi=si

      lw           t0, 52($fp)          #t0=c
      add          t0, t0, 1            #c+1
      sw           t0, 52($fp)          #c=c+1
      j loop_c
end_c:
      
      # imprimir(c)
      lw           a1, STACK_SIZE($fp) #a1 <- params
      lw           a1, 44(a1)         #a1 <- params->fd
      lw           a0, 52($fp)         #a0 <- c   
      la           t9, print_dnames     
      jal          ra, t9
      
      # imprimir fin de linea
      li           a2, 1
      la           a1, endl
      lw           a0, STACK_SIZE($fp)  #a0 <- params
      lw           a0, 44(a0)          #a0 <- params->fd
      la           t9, buff_write
      jal          ra, t9      

      lw           t0, 44($fp)          #t0=x
      l.s          $f2, 16($fp)          #f2=cr
      lw           t2, STACK_SIZE($fp)  #t2=params           
      add          t0, t0,1             #x+1         
      sw           t0, 44($fp)          #x=x+1
      l.s          $f4, 16(t2)           #f4=params->d_re
      add.s        $f2, $f2, $f4           #cr-params->d_re
      s.s          $f2, 16($fp)          #cr=cr-params->d_re       
      j loop_x
 
end_x:
      lw           t0, 48($fp)          #t0=y
      l.s          $f2, 20($fp)          #f2=ci
      lw           t2, STACK_SIZE($fp)  #t2=params           
      add          t0, t0,1             #y+1         
      sw           t0, 48($fp)          #y=y+1
      l.s          $f4, 20(t2)           #f4=params->d_im
      sub.s        $f2, $f2, $f4           #ci-params->d_im
      s.s          $f2, 20($fp)          #ci = ci-params->d_im       
      j loop_y

end_y:
     #FLUSH 
      lw           a0, STACK_SIZE($fp)  #a0 <- params
      lw           a0, 44(a0)          #a0 <- params->fd
      la           t9, buff_flush
      jal          ra, t9  

      #finalizacion
      lw            ra, RA_POS(sp)              #restore ra
      lw            gp, GP_POS(sp)              #restore gp
      lw            $fp, FP_POS(sp)             #restore fp      
      addu          sp, sp, STACK_SIZE          #restore sp
      jr            ra
      .end          mips32_plot

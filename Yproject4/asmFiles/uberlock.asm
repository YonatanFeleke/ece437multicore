	org		0x0000							# first processor p0
	ori		$a0, $zero, l1
	ori   $t1, $zero, 0x3FF
	ori   $t2, $zero, 0x400
	ori   $t3, $zero, 0
	
	loop: 
	jal		lock							# go to lock
	lw 		$t4, 0($t2)
	addiu $t3, $t3, 1
	addu 	$t4, $t4, $t3
	sw 		$t4, 0($t2)
	jal   unlock
	bne 	$t3, $t1, loop   
	halt

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
	ll              $t0, 0($a0)       					# load lock location
        bne             $t0, $0, aquire   					# wait on lock to be open
        addiu           $t0, $t0, 1
        sc              $t0, 0($a0)
        beq             $t0, $0, lock     					# if sc failed retry
        jr              $ra

	
# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock: 
	sw              $0, 0($a0)
        jr              $ra
l1:
	cfw	0x0
      
    
#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200							# second processor p1
	ori		$a0, $zero, l1
	ori   $t1, $zero, 0x3FF
	ori   $t2, $zero, 0x400
	ori   $t3, $zero, 0
	
	loop1: 
	jal		lock							# go to lock
	lw $t4, 0($t2)
	addiu $t3, $t3, 1
	addu $t4, $t4, $t3
	sw $t4, 0($t2)
	jal   unlock
	bne $t3, $t1, loop1  
	halt


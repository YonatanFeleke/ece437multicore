#void bubbleSort(int numbers[], int array_size)
#{
#  int i, j, temp;
# 
#  for (i = (array_size - 1); i > 0; i--)
#  {
#    for (j = 1; j <= i; j++)
#   {
#      if (numbers[j-1] > numbers[j])
#     {
#        temp = numbers[j-1];
#        numbers[j-1] = numbers[j];
#        numbers[j] = temp;
#     }
#    }
#  }
#}

#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
	org		0x0000							# first processor p0
	ori		$sp, $zero, 0x3ffc					# stack
	jal		mainp0							# go to program
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

# main function does something ugly but demonstrates beautifully
mainp0:

	#Start Address 400
	#100 entries

	ori	$s0,$zero,0x3FC #start address
	ori $s1,$zero,0x590 #end address
	ori	$s2,$zero,204 #outer loop counter
	or $s3,$zero,$zero #inner loop counter
	or $s5,$zero,$zero #merge counter

outerloop0:
	addiu $s2,$s2,-4 #decrement outer loop counter
	or $s3,$zero,$zero #inner loop counter
    beq $s2,$0,exit00 
innerloop0:
	addiu $s3,$s3,4 #increase innerloop counter
	addu $s4,$s0,$s3 #add counter to start address to get current address
	beq $s3,$s2,outerloop0 #branch to outer loop once end of array is reached


	lw		$t1,0($s4)
	lw		$t2,4($s4)
	sltu	$t3,$t1,$t2
	bne 	$t3,$zero,innerloop0 #if a[j] < a[j+1] then return to innerloop0
	#swap memory locations
	sw 		$t1,4($s4)
	sw 		$t2,0($s4)


	beq		$0,$0, innerloop0
	
exit00:
	bne $s5,$zero,exit01
	ori		$a0, $zero, l1						# move lock to arguement register
	jal		lock							# try to aquire the lock
	ori $s2,$zero,404 #set outer loop counter to cover entire merged array
	addiu $s5,$s5,1
	beq $0,$0,outerloop0
exit01:
	ori		$a0, $zero, l1						# move lock to arguement register
	jal		unlock							# release the lock
	halt
l1:
	cfw	0x0


#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
	org		0x200							# second processor p1
	ori		$sp, $zero, 0x7ffc					# stack
	jal		mainp1							# go to program
	halt

# main function does something ugly but demonstrates beautifully
mainp1:
	#Start Address 4C8
	#100 entries

	ori		$a0, $zero, l1						# move lock to arguement register
	jal		lock							# try to aquire the lock

	ori	$s0,$zero,0x4C4 #start address - 4
	ori $s1,$zero,0x590 #end address
	ori	$s2,$zero,204 #outer loop counter
	or $s3,$zero,$zero #inner loop counter


outerloop1:
	addiu $s2,$s2,-4 #decrement outer loop counter
	or $s3,$zero,$zero #inner loop counter
    beq $s2,$0,exit1 
innerloop1:
	addiu $s3,$s3,4 #increase innerloop counter
	addu $s4,$s0,$s3 #add counter to start address to get current address
	beq $s3,$s2,outerloop1 #branch to outer loop once end of array is reached


	lw		$t1,0($s4)
	lw		$t2,4($s4)
	sltu	$t3,$t1,$t2
	bne 	$t3,$zero,innerloop1 #if a[j] < a[j+1] then return to innerloop1
	#swap memory locations
	sw 		$t1,4($s4)
	sw 		$t2,0($s4)


	beq		$0,$0, innerloop1
	
exit1:
	ori		$a0, $zero, l1						# move lock to arguement register
	jal		unlock							# release the lock
	halt
res:
	cfw 0x0									# end result should be 3


org	0x400
sortdata: 
cfw 0x087d
cfw 0x5fcb
cfw 0xa41a
cfw 0x4109
cfw 0x4522
cfw 0x700f
cfw 0x766d
cfw 0x6f60
cfw 0x8a5e
cfw 0x9580
cfw 0x70a3
cfw 0xaea9
cfw 0x711a
cfw 0x6f81
cfw 0x8f9a
cfw 0x2584
cfw 0xa599
cfw 0x4015
cfw 0xce81
cfw 0xf55b
cfw 0x399e
cfw 0xa23f
cfw 0x3588
cfw 0x33ac
cfw 0xbce7
cfw 0x2a6b
cfw 0x9fa1
cfw 0xc94b
cfw 0xc65b
cfw 0x0068
cfw 0xf499
cfw 0x5f71
cfw 0xd06f
cfw 0x14df
cfw 0x1165
cfw 0xf88d
cfw 0x4ba4
cfw 0x2e74
cfw 0x5c6f
cfw 0xd11e
cfw 0x9222
cfw 0xacdb
cfw 0x1038
cfw 0xab17
cfw 0xf7ce
cfw 0x8a9e
cfw 0x9aa3
cfw 0xb495
cfw 0x8a5e
cfw 0xd859
cfw 0x0bac
cfw 0xd0db
cfw 0x3552
cfw 0xa6b0
cfw 0x727f
cfw 0x28e4
cfw 0xe5cf
cfw 0x163c
cfw 0x3411
cfw 0x8f07
cfw 0xfab7
cfw 0x0f34
cfw 0xdabf
cfw 0x6f6f
cfw 0xc598
cfw 0xf496
cfw 0x9a9a
cfw 0xbd6a
cfw 0x2136
cfw 0x810a
cfw 0xca55
cfw 0x8bce
cfw 0x2ac4
cfw 0xddce
cfw 0xdd06
cfw 0xc4fc
cfw 0xfb2f
cfw 0xee5f
cfw 0xfd30
cfw 0xc540
cfw 0xd5f1
cfw 0xbdad
cfw 0x45c3
cfw 0x708a
cfw 0xa359
cfw 0xf40d
cfw 0xba06
cfw 0xbace
cfw 0xb447
cfw 0x3f48
cfw 0x899e
cfw 0x8084
cfw 0xbdb9
cfw 0xa05a
cfw 0xe225
cfw 0xfb0c
cfw 0xb2b2
cfw 0xa4db
cfw 0x8bf9
cfw 0x12f7

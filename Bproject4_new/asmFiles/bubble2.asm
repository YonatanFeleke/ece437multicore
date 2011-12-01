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


	#Start Address 400
	#100 entries

	ori	$s0,$zero,0x3FC #start address
	#ori $s1,$zero,0x590 #end address
	ori $s1,$zero,0x428 #end address
	#ori	$s2,$zero,404 #outer loop counter
	ori	$s2,$zero,44 #outer loop counter
	or $s3,$zero,$zero #inner loop counter


outerloop0:
	addiu $s2,$s2,-4 #decrement outer loop counter
	or $s3,$zero,$zero #inner loop counter
    beq $s2,$0,exit 
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
	
exit:
halt

org 0x200
halt

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


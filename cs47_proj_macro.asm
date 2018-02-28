# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

.macro extract_nth_bit($regD, $regS, $regT)	
		#regD = result 0 or 1 (of the position regT in the array regS)
		#regS = the bit pattern
		#regT = position in the bit pattern
	li	$regD, 0x1
	sllv	$regD, $regD, $regT
	and	$regD, $regS, $regD
	srlv	$regD, $regD, $regT
	.end_macro

.macro insert_to_nth_bit($regD, $regS, $regT, $maskReg)		
		# regD:    bit pattern in which to be inserted at nth position
   		 # regS:    position n ( 0-31)
 		   # regT:    the bit to insert ( 0x0 or 0x1)-----------regD in the above macro
 		   # maskReg: temporary mask

	li	$maskReg, 0x1
	sllv $maskReg, $maskReg, $regS  	# maskReg = 0000000..1..0
	not $maskReg, $maskReg         		# maskReg = 1111..0..1
	
   	 and $regD, $regD, $maskReg      # change the bit at nth position of regD to 0
   	 
   	 sllv $regT, $regT, $regS        # bring the bit in regT to the right position. regT = 0000..x..0
    	or $regD, $regD, $regT          # add the bit to that position of the bit pattern
	.end_macro	

						

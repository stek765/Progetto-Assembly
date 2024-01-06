#  Nome file
#  ---------- 
#  postfix.s
#
#
#  struttura per la compilazione
#  --------------------------------
#  ./postfix input.txt output.txt
#


.data


r_eax:
	.long 0
r_ebx:
	.long 0
r_ecx:
	.long 0
r_edx:					# variabili  r_ (remember)  per ripristinare i valori iniziali una volta finita l'esecuzione 
	.long 0
r_esp:
	.long 0
r_ebp:
	.long 0

cost:					# costante con valore 10 (serve per operazioni come il mul che non accettano valori immediati)
	.long 10
	
	
	
.text				
	.global postfix		# start
	
postfix:
	movl %esp, r_esp
	movl %ebp, r_ebp
	movl %eax, r_eax
	movl %ebx, r_ebx		# salvo i registri iniziali r_ (remember)
	movl %ecx, r_ecx
	movl %edx, r_edx
	
	movl %esp, %ebp		# salvo una copia di esp in ebp per poter modifica esp senza problemi
	
	movl 4(%ebp), %esi		# asseno l'INPUT
	movl 8(%ebp), %edi		# assegno l'OUTPUT
	
	movl $0, %ebx			# resetto il contatore dei caratteri in input
	
	movl $0, %ecx			# pulisco il registro ecx
	
	movb (%ebx, %esi), %cl	
	cmpl $0, %ecx			# se l'input è vuoto salto all'etichetta Invalid
	je Invalid				
			
	
					
# CONTROLLO STRINGA ELEMENTI (Prec e Controllo)
# ---------------------------------------------
Prec:
	xorl %edx, %edx		# resetto i registri utili
	movl $0, %eax

Controllo:  
	xorl %ecx, %ecx		# azzero ecx che conteneva l'elemento precedente


	# guardo se l'elemento preso in considerazione è un:
	
	movb (%ebx,%esi), %cl	
								
	cmpl $0, %ecx			# carattere nullo di fine vettore
	je Termine1
	
	cmpl $32, %ecx			# carattere "spazio", ' '
	je Spazio
	
	cmpl $43, %ecx			# carattere "somma", '+'
	je Somma		
	
	cmpl $42, %ecx			# carattere "moltiplicazione", '*'
	je Moltiplicazione
	
	cmpl $45, %ecx			# carattere "segno negativo", '-'
	je Negativo
	
	cmpl $47, %ecx			# carattere "divisione", '/'
	je Divisione
	
	cmpl $48, %ecx
	jl Invalid
					# carattere non valido
	cmpl $57, %ecx		
	jg Invalid 
	
	jmp Calcolo			# altrimenti salta all'etichetta Calcolo

	
	
# CALCOLO DEL NUMERO IN INTERO (Calcolo)
# --------------------------------------
Calcolo:	
	addl $-48, %ecx		# trasformo da ascii in intero l'elemento del vettore
	mull cost			
	addl %ecx, %eax		# ad ogni lettura eax = (eax precedente * 10) + (elemento vettore)
	incl %ebx		      	
	jmp Controllo			# no condizioni, ritorna all'etichetta Controllo
	
	
	  # ciò va a comporre i numeri inseriti in input
	
	

# CARATTERE SUCCESSIVO ALLO SPAZIO? (Spazio)
# ------------------------------------------
Spazio:
	incl %ebx			# incremento ebx per guardare l'elemento dopo lo spazio, ' '
	
	xorl %ecx, %ecx
	movb (%ebx,%esi), %cl	
	
	cmpl $32, %ecx	
	je Invalid
					# invalido se ci sono 2 spazi o se l'input termina con un NULL
	cmpl $0, %ecx		
	je Invalid

	decl %ebx
		
	jmp Save			# altrimenti: no condizioni, salta all'etichetta Save



# SALVO NELLO STACK (Save)
# ------------------------
Save:
	pushl %eax			# salvo il valore in cima allo stack
	incl %ebx
	jmp Prec			# no condizioni, ritorna all'etichetta Prec



# SOMMA (Somma)
# -------------
Somma:
	popl %eax			# recupero i primi 2 valori in cima allo stack
	popl %edx	
	addl %edx, %eax		# svolgo la somma
	
	incl %ebx			# incremento il contatore posizione
	
	jmp Next 			# no condizioni, salta all'etichetta Next
	
	
	
# MOLTIPLICAZIONE (Moltiplicazione)
# ---------------------------------
Moltiplicazione:
	popl %eax			# recupero i primi 2 valori in cima allo stack
	popl %edx
	mull %edx			# svolgo la moltiplicazione	
	
	incl %ebx			# incremento il contatore posizione
	
	jmp Next			# no condizioni, salta all'etichetta Next



# SEGNO NEGATIVO (Negativo)
# -------------------------
Negativo:
	incl %ebx			# incremento ebx per guardare l'elemento successivo
	
	movb (%ebx, %esi), %cl
	
	cmpl $32, %ecx			# è uno spazio? => è presento solo il segno meno
	je Sottrazione
		
	cmpl $0, %ecx			# è NULL? => è presento solo il segno meno
	je Sottrazione
		
	cmpl $48, %ecx				
	jl Invalid
					# è un carattere valido?
	cmpl $57, %ecx
	jg Invalid
		
	jmp CalcoloN			# no condizioni, salta all'etichetta CalcoloN
	


# SOTTRAZIONE (Sottrazione)
# -------------------------
Sottrazione:
	popl %edx			# recupero i primi 2 valori in cima allo stack
	popl %eax
	subl %edx, %eax		# svolgo la sottrazione 
	
	#  ebx è gia incrementato
	
	jmp Next			# no condizioni, salta all'eticheta Next
	


# CALCOLO DEL NUMERO IN INTERO NEGATIVO (CalcoloN)
# ------------------------------------------------
CalcoloN:	
	addl $-48, %ecx		# trasformo da ascii in intero l'elemento del vettore
	mull cost	
	addl %ecx, %eax		# ad ogni lettura eax = (eax precedente * 10) + (elemento vettore) 
				      
	  # ciò va a comporre il numero negativo in input
	
	incl %ebx 			# incremento ebx per guardare l'elemento successivo
	
	movb (%ebx, %esi), %cl
	
	cmpl $32, %ecx		        # è uno spazio?
	je Cambiosegno
	
	cmpl $0, %ecx  		# è NULL?  in questo caso ci sarebbe stato un numero di cui non ci si fa niente
	je Invalid
	
	
	cmpl $48, %ecx			
	jl Invalid
					# è un carattere valido?
	cmpl $57, %ecx
	jg Invalid
	
	jmp CalcoloN			# altrimenti: no condizioni, riesegui questa etichetta con l'elemento successivo



# DVISIONE (Divisione)
# --------------------
Divisione:		
	# recupero i primi due valori dalla cima dello stack 
	
	popl %ecx			# DENOMINATORE	
	popl %eax			# NUMERATORE
	
	cmpl $0, %ecx			# denominatore = 0?
	je Invalid
	
	cmpl $0, %eax			# numeratore negativo? 
	jl Invalid
	
	cmpl $0, %ecx			# denominatore negativo?
	jl DivisioneN
	
	divl %ecx			# eseguo divisione (denominatore positivo)
	incl %ebx			# incremento ebx per guardare l'elemento successivo
	
	jmp Next



# DIVISIONE CON DENOMINATORE NEGATIVO (DivisioneN)
# ------------------------------------------------
DivisioneN:
	imull $-1, %ecx  		# cambo il segno del denominatore
	divl %ecx			# eseguo la divisione (quoziente in eax)
	imull $-1, %eax		# ripristino il segno negativo
	
	incl %ebx			# incremento ebx per guardare l'elemento successivo
	
	jmp Next			# no condizioni, salta all'etichetta Next
	
	
	
	
# TRASFORMO INTERI POSITIVI IN NEGATIVI (Cambiosegno)
# ---------------------------------------------------
Cambiosegno:
	imull $-1, %eax		# nego il numero intero compostoin precedenza
		
	jmp Next			# no condizioni, salta all'etichetta Next



# CHECKPOINT DI MEZZO (Next)
# ---------------------------------
Next:
	xorl %ecx, %ecx
	movb (%ebx,%esi), %cl
	
	cmpl $32, %ecx		# se l'elemento successivo all'operazione è uno spazio salta all'etichetta Spazio
	je Spazio
	
	cmpl $0, %ecx		# se è NULL salta all'etichetta Termine2
	je Termine2

	jmp Invalid			# altrimenti Invalid

	


	
	
# INVALID_OUT (Invalid)
# ---------------------
Invalid:
	movb $73, 0(%edi)     #I
	movb $110, 1(%edi)    #n
	movb $118, 2(%edi)    #v
	movb $97, 3(%edi)     #a	# mette la scritta "Invalid" sul vettore destinazione
	movb $108, 4(%edi)    #l
	movb $105, 5(%edi)    #i
	movb $100, 6(%edi)    #d
	movb $0, 7(%edi)      #NULL di fine stringa
	
	jmp END   			# no condizioni, salta all'etichetta END
	

	
# FINE LETTURA (Termine1, Termine2)
# ---------------------------------
Termine1:
	popl %eax			# prendo il valore in cima allo stack (valore_finale)


Termine2:
	xorl %ecx, %ecx		
	xorl %ebx, %ebx		# azzero i registri ecx, ebx, edx
	xorl %edx, %edx
	
	cmpl $0, %eax			# numeratore FINALE positivo? 
	jge Riconverti
	
	#-----
	
	imull $-1, %eax		# se negativo lo faccio diventare positivo
	movl $45, (%ecx,%edi)		# e aggiungo sul vettore di output al primo posto un meno '-'
	incl %ecx			# incremento contatore dei caratteri (per inserire il NULL di fine vettore in Riconverti)
	incl %ebx			# incremento contatore posizione (posizione elementi sul vettore di output)



# RICONVERTE L'ELEMENTO IN ASCII E LO CARICA SUL VETTORE DI OUTPUT (Riconverti, Output)
# -------------------------------------------------------------------------------------
Riconverti:
	divl cost			# divido il numero finale 
	pushl %edx			# e inserisco il resto nello stack, ovvero le singole cifre (ma al contrario)
	
	xor %edx, %edx			# azzero edx per fare spazio al prossimo resto
	incl %ecx			# incremento contatore dei caratteri (che era stato azzerato)
	
	cmpl $0, %eax			# se il quoziente è diverso da 0 ripeto il ciclo
	jne Riconverti
 
 	movl $0, (%ecx, %edi)		# inserisco NULL alla fine della stringa di output
 
 	 	
 	
 Output:
 	popl %eax			# recupero dalla cima dello stack le singole cifre (ma sta volta sono in ordine)
	
 	addl $48, %eax			# trasformo le cifre in ascii
 	
	movl %eax, (%ebx, %edi)	# aggiungo al vettore di output al ebx_posto la cifra eax
	incl %ebx			#		e poi aumenta ebx (contatore posizione)
	
	cmpl %ebx, %ecx		# finchè ebx (contatore posizione) non coincide con ecx (contatore cifre + eventuale segno)
	jne Output			# 		ripeto il ciclo 
	
	

# END_PROGRAM (END)
# -----------------
END:
	movl r_eax, %eax		
	movl r_ebx, %ebx
	movl r_ecx, %ecx			
	movl r_edx, %edx		# ripristino i valori iniziali dei vari registri 
	movl r_ebp, %ebp
	movl r_esp, %esp
	
	ret				# fine programma e ritorno al main.c	


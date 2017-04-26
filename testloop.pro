	if sum gt 100. and sum lt. 150. then begin
 					pcttree[j] = pcttree[j]*100./sum
 					pctherb[j] = pctherb[j]*100./sum
 					pctbare[j] = pctbare[j]*100./sum
 				endif else begin
 					if sum gt 150. then begin
 						sum = pcttree[j-1] + pcctherb[j-1] + pctbare[j-1]
 						if sum gt 100. and sum lt. 150. then begin
 							pcttree[j] = pcttree[j-1]*100./sum
 							pctherb[j] = pctherb[j-1]*100./sum
 							pctbare[j] = pctbare[j-1]*100./sum
 						endif else begin
 							if sum gt 150 then begin
								sum = pcttree[j+1] + pcctherb[j+1] + pctbare[j+1]
 									if sum gt 100. and sum lt. 150. then begin
 										pcttree[j] = pcttree[j+1]*100./sum
 										pctherb[j] = pctherb[j+1]*100./sum
 										pctbare[j] = pctbare[j+1]*100./sum
 									endif else begin
 											print, 'Sum is still messed up!"
 											goto, quitearly
 									endelse
 							endif
 						endelse
 					endif
 				endelse

### Files related to HZAR



#### How to hack excel to convert structure to HZAR format

##### Part I: Filter for "discriminatory alleles"

What we have done is set a .75/.25 allele frequency threshold. This means that one population must have an allele frequency of at least .75 and the other must have an allele frequency of no more than .25.

Bocas and Veraguas are our "west" populations (not just Bocas in order to increase sample size) and Chucanti and Darien are our "east" populations.

 - Step 1: Convert data to 1 and 0. Do this immediately below the data matrix `=IF(E3=E$42,1,0)`
 - Step 2: Filter for above .75 in west `=IF((SUM(E47:E54)/COUNT(E47:E54))>0.749,1,0)`
 - Step 3: Filter for below .25 in west `=IF((SUM(E47:E54)/COUNT(E47:E54))<0.251,1,0)`
 - Step 4: Filter for above .75 in east `=IF((SUM(E79:E84)/COUNT(E79:E84))<0.251,1,0)`
 - Step 5: Filter for below .25 in east `=IF((SUM(E79:E84)/COUNT(E79:E84))>0.749,1,0)`
 - Use 1,0 math to make an "only if" statement. Only if both Step 2 and 4, or both Step 3 and 5 are true  will the following equation return a 1. `=(E93*E95)+(E94*E96)`
 - Step 6: Extend this equation to all cells, Copy the matrix, and paste into a new sheet as "values" and transposed
 - Step 7: In the new sheet sort by "1" on the column with the only if data. Copy, paste into a new sheet, again transposed. This new matrix will be just the "discriminatory alleles"

##### Part II: Convert line details to population frequencies

- Step 1: Add to this new file a column with numbers representing population assignment.
- Step 2: Use "SUMIF" to scan through the population column and sum 1s for a given population `=(SUMIF($C$2:$C$39,$B41,D$2:D$39))/$C41` This new matrix is your population level frequencies.

##### Part III: Add extra columns for the minor allele frequency and count.
- Step 1: Add a column that counts the number of alleles in a given population. You can hack this by doing 2*COUNTIF on the population column.
- Step 2: Use CONCATENATE to convert a single cell to three cells. Add additional code to round values to 2 significant digits. `=CONCATENATE((ROUND(C2,2)),",",(1-ROUND(C2,2)),",",$B12)` The third item looks up the allele count by population.
- Step 3: Copy this data matrix to a text editor. Search for tabs (`\t`) replacing with commas (`,`). Afterwards, copy this data matrix back to excel. Use Text to Columns (with commas as delimiter) to convert this into the final data matrix.

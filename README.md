# DataDrifters
Documentație - Proiect ASM  

1. Descriere generală a programului  

Programul are ca scop prelucrarea unui șir de octeți introduși de utilizator în format hexazecimal. Programul validează datele introduse, convertește valorile din format ASCII în valori binare, efectuează mai multe operații de procesare pe biți, sortează șirul de octeți și afișează rezultatele în formate binar și hexazecimal. 

 2. Structura programului și etapele principale  

Programul afișează un mesaj de introducere și citește un șir de caractere. Valorile sunt introduse sub formă de numere hexazecimale separate prin spații. Se verifică dacă fiecare caracter aparține intervalelor valide (0–9, A–F). De asemenea, se verifică dacă numărul de octeți este cuprins între 8 și 16. În caz contrar, se afișează un mesaj de eroare și citirea se reia.  

După validare, fiecare pereche de caractere hexazecimale este convertită într-un octet și stocată într-un vector. Se calculează apoi cuvântul C folosind mai multe etape: extragerea unor semi-octeți, operații logice (AND, OR, XOR) și suma tuturor octeților modulo 256. Rezultatul este afișat în format hexazecimal.  

Șirul este sortat descrescător folosind algoritmul Bubble Sort. Sortarea este realizată prin compararea elementelor adiacente și interschimbarea lor atunci când este necesar.  

După sortare, programul parcurge șirul și numără biții de 1 pentru fiecare octet. Se reține poziția octetului care are cel mai mare număr de biți de 1, cu condiția ca acesta să fie mai mare decât 3. Poziția este afișată în format hexazecimal.   

Pentru fiecare octet din șir, se calculează valoarea N ca fiind suma primilor doi biți . Octetul este rotit circular la stânga cu N poziții. 

 Rezultatul este afișat atât în format binar, cât și în format hexazecimal (2 cifre).  

3. Dificultăți întâlnite și soluții  

Principalele dificultăți au fost gestionarea corectă a registrelor în timpul apelurilor, evitarea modificării registrelor utilizate drept contoare de bucle și implementarea rotirilor fără a afecta structura buclelor. Aceste probleme au fost rezolvate prin salvarea temporară a valorilor în memorie, utilizarea registrelor auxiliare și restructurarea instrucțiunilor de salt condiționat pentru a evita erorile de tip “jump out of range”.  

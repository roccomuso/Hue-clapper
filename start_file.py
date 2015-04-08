import os
import sys

'''
Cerca un file in un percorso e lo avvia.
'''

def find(name, path): # funzione di ricerca (non ricerca in sub-directory ma solo nel path indicato)
    i = 0
    name = name.lower() # tutti i caratteri minuscoli
    name = name.strip() # via gli spazi a inizio o fine stringa
    for root, dirs, files in os.walk(path):
        while i < len(files):
            if name in files[i].lower():
                return path+"\\"+files[i] #os.path.join(root, name)
            i = i + 1

def avvia_file(titolo_parziale, percorso_cartella):
    percorso_file = find(titolo_parziale, percorso_cartella ) # NOME FILE (o parte del nome), PERCORSO DOVE CERCARLA ex. D:\Musica

    if percorso_file:
        os.startfile(percorso_file) # eseguiamo il file
        print(titolo_parziale)
    else:
        print("File non trovato!")


if __name__ == "__main__":
    avvia_file("out of the shadows", "D:\Musica")

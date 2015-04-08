import serial
import os
import hue_bridge
import start_file

# works on python 3.2 (with requests module installed) 

def scan():
    """scan for available ports. return a list of tuples (num, name)"""
    available = []
    for i in range(256):
        try:
            s = serial.Serial(i)
            available.append( (i, s.portstr))
            s.close()   # explicit close 'cause of delayed GC in java
        except serial.SerialException:
            pass
    return available

def connessione_seriale(port):
    """ funzione per connessione alla porta seriale """
    try:
        return serial.Serial(port, 9600)
    except serial.SerialException:
        print("verificatosi ERRORE...")


porte = scan()
if len(porte): # porte seriali libere
   porta = porte[0][1] # ci connettiamo alla prima porta disponibile

   ser = connessione_seriale(porta)

   play = False
   # restiamo in attesa di un comando da seriale.
   while True:
    comando = ser.readline()
    #print(comando) # DEBUG
    if comando.decode() == "OK\r\n": # toggle della luce. (Philips HUE, comunicazione in JSON).
        print(comando)
       # hue_bridge.toggle_light(3, effect=True) # on/off light bulb number 3
        hue_bridge.toggle_light(1, effect=True) # on/off light bulb number 1
        if play:
            os.system('taskkill /f /im vlc.exe') # chiudiamo vlc attraverso un comando windows
            play = False
        else:
            start_file.avvia_file("out of the shadows", "D:\Musica") # start the file found in the specified path
            play = True
    comando = ""

else:
   print("Nessun dispositivo seriale connesso oppure porta seriale occupata!")

'''
print("Found ports:")
for n,s in scan():
   print("(%d) %s" % (n,s))
'''

  

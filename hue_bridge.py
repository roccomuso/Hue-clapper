import requests
import json

def toggle_light(light, effect=False):
    light = str(light)
    
    r = requests.get("http://www.meethue.com/api/nupnp") # url for getting hue bridge local ip address
    if len(r.text) > 3:
        j = str(r.text).strip("[]") # convertiamo stringa in json valido
    
        json_list = json.loads(j) # mappiamo la stringa json in una lista
        #print(json_list['internalipaddress'])

        # controlliamo se la luce è accesa o spenta:
        r = requests.get("http://"+json_list['internalipaddress']+"/api/newdeveloper/lights/"+light+"/")
        l = str(r.text).strip("[]") # convertiamo stringa in json valido
        luce = json.loads(l) # mappiamo la stringa json in una lista

        # se accesa la spegniamo e viceversa
        stato = "false" if luce['state']['on'] else "true" # operatore ternario in python
        effetto = "colorloop" if effect else "none" 

        payload = '{"on": '+stato+', "effect": "'+effetto+'"}' # RICHIESTA JSON DA MANDARE
        #print(payload)
        url_luce = "http://"+json_list['internalipaddress']+"/api/newdeveloper/lights/"+light+"/state"
        #print(url_luce)
        r = requests.put(url_luce, data=payload)
        if r.status_code == 200: # in base allo status code analizziamo la risposta
            print("200 - Richiesta inviata!")
        else:
            print("Errore nella richiesta!")
    else:
        print("Nessuna connessione internet attiva o servizio UPNP di meethue.com assente")


if __name__ == "__main__": # se eseguito direttamente questo file
    toggle_light(1, effect=True)

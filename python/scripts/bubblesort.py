import random
feld = []
counter = 0
for i in range(5):
    feld.append(random.randint(0,100))
print(feld)
while True:
    vertauscht = False
    for i in range(len(feld)-1):
        if feld[i] > feld[i+1]:
            tmp         = feld[i]
            feld[i]     = feld[i+1]
            feld[i+1]   = tmp
            vertauscht  = True
            counter = (counter + 1)
        # Posselbility to print steps
        #print(feld)
    if vertauscht == False: break
print(feld)
print("Benoetigte Durchläufe: " + str(counter))

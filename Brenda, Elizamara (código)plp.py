# servidor de Figuras
# para testa-lo, use como cliente o telnet
# Ex: telnet localhost 7777
from socket import *
from threading import *
from Tkinter import *
from random import randint

HOST = '' # hostname
PORT = 7778 # comm port
#PORT = 7777


class Desenha(object): # Classe Desenha objeto
    def __init__(self, w , id, color='blue', coord_x = 2, coord_y = 2 , height = 50, width = 50):
        self.w = w
        self.id = id
        self.color = color
        self.coord_x = coord_x
        self.coord_y = coord_y
        self.height = height
        self.width = width
    
    def SetaCoord(self, x, y):
        self.coord_x = x
        self.coord_y = y
    
    def Id(self):
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.w.create_text(col+(self.width/2), lin+(self.height/2) ,fill="white",font="Times 12 bold", text=str(self.id))

    def desenha(self):
        pass

    def move(self):
        pass

    def apaga(self):
        pass


# desenhar o circulo

class Circulo(Desenha): # Classe circulo
    referencia = None
    def __init__(self, w, id, color, coord_x, coord_y, height = 60, width = 60):
        Desenha.__init__(self, w, id, color, coord_x, coord_y, height, width)

    def desenha(self): 
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.referencia = self.w.create_oval(col + 10, lin + 10, col + self.width - 10, lin + self.height - 10,fill = self.color, outline = '')
        self.Id()
    
    def move(self, coord_x, coord_y):
        self.apaga()
        self.SetaCoord(coord_x, coord_y) 
        self.desenha()

    def apaga(self):
        self.w.delete(self.referencia)



class Quadrado(Desenha): #classe quadrado
    referencia = None
    def __init__(self, w, id, color, coord_x, coord_y, height = 60, width = 60):
        Desenha.__init__(self, w, id, color, coord_x, coord_y, height, width)

    def desenha(self): 
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.referencia = self.w.create_rectangle(col + 10, lin + 10, col + self.width - 10, lin + self.height - 10, fill = self.color, outline = '')
        self.Id()

    def move(self, coord_x, coord_y):
        self.SetaCoord(coord_x, coord_y)
        self.apaga() 
        self.desenha()

    def apaga(self):
        self.w.delete(self.referencia)


class Grid:
    def __init__(self, master, lins, cols, cell_h = 50, cell_w = 50):
        self.cell_h = cell_h
        self.cell_w = cell_w
        self.maxlins = lins
        self.maxcols = cols
        h = lins * cell_h + 1
        w = cols * cell_w + 1
        self.w = Canvas(master, height = h, width = w, bg='white')
        self.w.configure(borderwidth=0, highlightthickness=0)
        self.w.pack()
        for i in range(0, h, cell_h):
            self.w.create_line([(i, 0), (i, h)])
        for i in range(0, w, cell_w):
            self.w.create_line([(0, i), (w, i)])



class Server(Thread):
    figurasGuardadas = []
    def __init__(self, grid):
        Thread.__init__(self)
        self.grid = grid
        self.server = socket()
        self.server.bind((HOST, PORT))

        self.server.listen(5)
        self.client, addr = self.server.accept()
    
    def process_cmd(self, cmd):
        reply = 'Done.\n'
        comandos = cmd.split(" ") #pega os comandos e separa
        comandos[len(comandos)-1] = comandos[len(comandos)-1][:-2] # retira os \r\n do comando
        
        # + id shape(c|s) color lin col ok
        # - id
        # m id lin col ok
        # + shape(c|s) color lin col ok
        # - shape(c|s) color ok
        # m shape(c|s) color lin col ok

#---------------------------------cria ou move -----------------------------------#
        if(comandos[0] == '+' or comandos[0] == 'm'): #verifica se eh para criar ou mover
             # cria: + id shape(c|s) color lin col --- ok
            if(len(comandos) == 6):
                id = int(comandos[1])
                ids_ = [el[0] for el in self.figurasGuardadas if len(el) > 0]
                if id in ids_:
                    reply = 'Figura ja existente: '+ str(id)
                    return reply
                forma = comandos[2]
                cor = comandos[3]
                lin = int(comandos[4])
                col = int(comandos[5])
                if(comandos[0] == '+'):
                    if(forma == 'c'):
                        c  = Circulo(self.grid.w, id, cor, lin, col)
                        c.desenha()
                        self.figurasGuardadas.append((id, forma, cor, c))
                    else:
                        q = Quadrado(self.grid.w, id, cor, lin, col)
                        q.desenha()
                        self.figurasGuardadas.append((id, forma, cor, q))
        
            if(len(comandos) == 5):
                forma = comandos[1]
                cor = comandos[2]
                lin = int(comandos[3])
                col = int(comandos[4])
                id = int(randint(0,50))
                ids_ = [el[0] for el in self.figurasGuardadas if len(el) > 0]
                
                while id in ids_:
                    id = int(randint(0, 9))
                c  = Circulo(self.grid.w, id , cor, lin, col)
                q = Quadrado(self.grid.w, id, cor, lin, col)
                
                #cria: + shape(c|s) color lin col -- ok
                if(comandos[0] == '+'): 
                    if(forma == 'c'):
                        c.desenha()
                        self.figurasGuardadas.append((id, forma, cor, c))
                    else:
                        q.desenha()
                        self.figurasGuardadas.append((id, forma, cor, q))
                
#-----------------------------------move-----------------------------------------#
                
                elif(comandos[0] == 'm'): 
                    #move: m shape(c|s) color lin col ok
                    figura = None
                    for i in range(len(self.figurasGuardadas)):
                        if(self.figurasGuardadas[i][1] == forma and self.figurasGuardadas[i][2] == cor):
                            figura = self.figurasGuardadas[i]
                    if(figura != None):
                        figura[3].move(lin, col)
                    else:
                        reply = 'Figure not found: ' + forma + ' ' + cor
                        return reply

            if(len(comandos)== 4):
                #move: m id lin col ok
                id = comandos[1]
                lin = int(comandos[2])
                col = int(comandos[3])
                if(comandos[0]== 'm'):
                    figura = None
                    for i in range(len(self.figurasGuardadas)):
                        #print(self.figurasGuardadas[i][1])
                        if(self.figurasGuardadas[i][0] == int(id)):
                            figura = self.figurasGuardadas[i]
                    if(figura != None):
                        figura[3].move(lin, col)
                    else:
                        reply = 'Figure not found: ' + str(id)
                        return reply
                
#------------------------------------apaga---------------------------------------------#
        
        
        elif(comandos[0] == '-'):
            #apaga: - shape(c|s) color ok
            if(len(comandos) == 3):  
                forma = comandos[1]
                cor = comandos[2]
                figura = None
                for i in range(len(self.figurasGuardadas)):
                    if(self.figurasGuardadas[i][1] == forma and self.figurasGuardadas[i][2] == cor):
                        figura = self.figurasGuardadas[i]
                if(figura != None):
                    id = figura[0]
                    figura[3].apaga()
                    self.figurasGuardadas = [f for f in self.figurasGuardadas if f[0] != id]
                else:
                    reply = 'Figure not found: ' + forma + ' ' + cor
                    return reply
            
            # apaga: - id ok
            elif(len(comandos)== 2):
                id = int(comandos[1]) 
                print(id)
                figura = None
                print(self.figurasGuardadas)
                for i in range(len(self.figurasGuardadas)):
                    print(self.figurasGuardadas[i][0])
                    if(self.figurasGuardadas[i][0] == id):
                        figura = self.figurasGuardadas[i]

                
                if(figura != None):
                    aux = figura[0]
                    figura[3].apaga()
                    self.figurasGuardadas = [f for f in self.figurasGuardadas if f[0] != aux]
                else:
                    reply = 'Figure not found: ' + str(id)
                    return reply

        return reply
        
    def run(self):
        while True:
            try:
                text = self.client.recv(1024)
                if not text:
                    break
                reply = self.process_cmd(text)
                self.client.sendall(reply)
            except Exception as e:
                print(e)
                break
        self.client.close()


# criando uma figura no grid
# + ou - para criar e apagar
# id um identificador da figura
# F da forma, se eh um circulo ou quadrado
# C cor pelo menos - black, red, green e blue
# X e Y as coordenadas
# EX: + 1 C blue 1 1

# Para jogar basta colocar um dos comandos abaixo:

# ----------criar-----------#
# + id shape(c|s) color lin col ok
# + shape(c|s) color lin col ok

#-----------apagar---------#
# - id
# - shape(c|s) color ok

#-----------mover----------#
# m id lin col ok
# m shape(c|s) color lin col ok

root = Tk()
root.title('joguinho maroto')
grid = Grid(root, 5, 5, cell_h = 60, cell_w = 60)

print('Aguardando conexoes...')
app = Server(grid).start()
print("Uma conexao encontrada!")

root.mainloop()
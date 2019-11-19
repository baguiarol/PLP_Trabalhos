# servidor de Figuras
# para testa-lo, use como cliente o telnet
# Ex: telnet localhost 7777
from socket import *
from threading import *
from Tkinter import *
HOST = '' # hostname
PORT = 7777 # comm port

class Desenha(object):
    def __init__(self, w , id, color='blue', coord_x = 2, coord_y = 2 , height = 50, width = 50):
        self.w = w
        self.id = id
        self.color = color
        self.coord_x = coord_x
        self.coord_y = coord_y
        self.height = height
        self.width = width
    
    def PegaCoord(self):
        return self.coord_x, self.coord_y
    
    def SetaCoord(self, x, y):
        self.coord_x = x
        self.coord_y = y
    
    def Id(self):
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.w.create_text(col+(self.width/2), lin+(self.height/2) ,fill="white",font="Times 12 bold", text=str(self.id))

    def desenha(self):
        pass
    
    def apaga(self):
        pass
    
    def move(self):
        pass


# desenhar o circulo

class Circulo(Desenha):
    def __init__(self, w, id, color, coord_x, coord_y, height = 60, width = 60, raio = 100):
        Desenha.__init__(self, w, id, color, coord_x, coord_y, height, width)
        self.raio = raio

    def desenha(self): 
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.w.create_oval(col + 10, lin + 10, col + self.width - 10, lin + self.height - 10,fill = self.color, outline = '')
        self.Id()

    def move(self, coord_x, coord_y):
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.w.create_oval(col + 10, lin + 10, col + self.width - 10, lin + self.height - 10,fill = 'white' ,outline = '')
        self.SetaCoord(coord_x, coord_y) 
        self.desenha()

#desenha o quadrado

class Quadrado(Desenha):
    def __init__(self, w, id, color, coord_x, coord_y, height = 60, width = 60, lado = 100):
        Desenha.__init__(self, w, id, color, coord_x, coord_y, height, width)
        self.lado = lado

    def desenha(self): 
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.w.create_rectangle(col + 10, lin + 10,
                                col + self.width - 10,
                                lin + self.height - 10, fill = self.color, outline = '')
        self.Id()

    def move(self, coord_x, coord_y):
        col = self.coord_y * self.height
        lin = self.coord_x * self.width
        self.w.create_rectangle(col + 10, lin + 10,
                                col + self.width - 10, 
                                lin + self.height - 10, fill = 'white' ,outline = '')
        self.SetaCoord(coord_x, coord_y) 
        self.desenha()




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
    def __init__(self, grid):
        Thread.__init__(self)
        self.grid = grid
        self.server = socket()
        self.server.bind((HOST, PORT))

        self.server.listen(5)
        self.client, addr = self.server.accept()
    
    def process_cmd(self, cmd):
        reply = 'Done.\n'
        comandos = cmd.split(" ")
        comandos[len(comandos)-1] = comandos[len(comandos)-1][:-2]
        
       
        
        # + shape(c|s) color lin col
        # - shape(c|s) color
        

        # + id shape(c|s) color lin col
        if(comandos[0] == '+'): #cria
            if(len(comandos) == 6):
                id = int(comandos[1])
                forma = comandos[2]
                cor = comandos[3]
                lin = int(comandos[4])
                col = int(comandos[5])
                if(forma == 'c'):
                    c  = Circulo(self.grid.w, id, cor, lin, col)
                    c.desenha()
                else:
                    q = Quadrado(self.grid.w, id, cor, lin, col)
                    q.desenha()
        # - id
        #if(comendos[0] == '-'): #apaga

        # m shape(c|s) color lin col
        if(comandos[0] == 'm'):
            if(len(comandos) == 6):
                id = int(comandos[1])
                forma = comandos[2]
                cor = comandos[3]
                lin = int(comandos[4])
                col = int(comandos[5])
            if(forma == 'c'):
                    c  = Circulo(self.grid.w, id, cor, lin, col)
                    c.move()
                else:
                    q = Quadrado(self.grid.w, id, cor, lin, col)
                    q.move()
        # m id lin col
        




        #removendo id tal
        # if nao achou : reply = 'figure not found'
        
        
        return reply

    def run(self):
        while True:
            try:
                text = self.client.recv(1024)
                if not text:
                    break
                reply = self.process_cmd(text)
                self.client.sendall(reply)
            except:
                break
        self.client.close()


# criando uma figura no grid
# + ou - para criar e apagar
# id um identificador da figura
# F da forma, se eh um circulo ou quadrado
# C cor pelo menos - black, red, green e blue
# X e Y as coordenadas
# EX: + 1 C blue 1 1


#falta apenas conectar junto ao servidor para fazer o joguinho funcionar
#falta apagar a figura 

root = Tk()
root.title('Jogue este crlh e morra')
grid = Grid(root, 5, 5, cell_h = 60, cell_w = 60)
#grid.draw_circle(2, 2)

print('Aguardando conexoes...')
app = Server(grid).start()
print("Uma conexao encontrada!")



#c  = Circulo(grid.w, 2,'blue', 1, 3)    
#c2 = Circulo(grid.w, 3, 'red', 2, 0)
#c3 = Circulo(grid.w, 4, 'black', 4, 4)

#q = Quadrado(grid.w,1, 'blue', 1, 2)
#q.draw()
#q.move(2,2)
#c.desenha()
#c.move(1,4)
#c.move(0,4)
#c2.draw()
#c3.draw()

root.mainloop()

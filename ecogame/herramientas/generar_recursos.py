"""Genera los sprites (PNG) y sonidos (WAV) de EcoGame sin librerías externas.

Uso:  python generar_recursos.py
Salida: ../recursos/sprites/*.png  y  ../recursos/sonidos/*.wav
Todo se dibuja en baja resolución y se escala x2 (estilo pixel-art).
"""
import math
import os
import random
import struct
import wave
import zlib

BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'recursos')
SPR = os.path.join(BASE, 'sprites')
SND = os.path.join(BASE, 'sonidos')
os.makedirs(SPR, exist_ok=True)
os.makedirs(SND, exist_ok=True)

C = {
    'k': (27, 38, 49), 'g': (76, 175, 80), 'G': (46, 125, 50), 'l': (165, 214, 167),
    's': (255, 204, 153), 'p': (244, 143, 177), 'w': (250, 250, 250), 'b': (30, 136, 229),
    'B': (13, 71, 161), 'y': (253, 216, 53), 'Y': (249, 168, 37), 'o': (251, 140, 0),
    'r': (229, 57, 53), 'R': (183, 28, 28), 'n': (141, 110, 99), 'N': (93, 64, 55),
    'e': (189, 189, 189), 'E': (117, 117, 117), 'c': (179, 229, 252), 'm': (120, 144, 156),
}


# ---------------------------------------------------------------- lienzo y PNG
class Lienzo:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.px = [[None] * w for _ in range(h)]

    def p(self, x, y, col):
        x, y = int(round(x)), int(round(y))
        if 0 <= x < self.w and 0 <= y < self.h:
            self.px[y][x] = C[col] if isinstance(col, str) else col

    def rect(self, x0, y0, x1, y1, col):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.p(x, y, col)

    def elipse(self, cx, cy, rx, ry, col):
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0:
                    self.p(x, y, col)

    def contorno(self, col='k'):
        """Añade borde oscuro a toda la figura (look pixel-art)."""
        orig = [fila[:] for fila in self.px]
        for y in range(self.h):
            for x in range(self.w):
                if orig[y][x] is None:
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        xx, yy = x + dx, y + dy
                        if 0 <= xx < self.w and 0 <= yy < self.h and orig[yy][xx] is not None:
                            self.px[y][x] = C[col]
                            break

    def guardar(self, nombre, escala=2):
        w, h = self.w * escala, self.h * escala
        filas = bytearray()
        for y in range(h):
            filas.append(0)
            for x in range(w):
                c = self.px[y // escala][x // escala]
                filas += bytes(c + (255,)) if c else b'\0\0\0\0'

        def trozo(t, d):
            return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)

        png = b'\x89PNG\r\n\x1a\n' + trozo(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
        png += trozo(b'IDAT', zlib.compress(bytes(filas), 9)) + trozo(b'IEND', b'')
        with open(os.path.join(SPR, nombre + '.png'), 'wb') as f:
            f.write(png)


# ---------------------------------------------------------------- personaje
def brote(fotograma, nombre):
    """Brote: niño-semilla con un retoño en la cabeza. 16x24 base."""
    L = Lienzo(16, 24)
    piernas = {'reposo1': (0, 0), 'reposo2': (0, 0), 'correr1': (-2, 1), 'correr2': (0, 0),
               'correr3': (2, -1), 'correr4': (0, 0), 'salto': (-1, -1)}[fotograma]
    sube = 1 if fotograma == 'reposo2' else 0
    # piernas y zapatos
    L.rect(6 + piernas[0], 19, 7 + piernas[0], 21, 'B')
    L.rect(9 + piernas[1], 19, 10 + piernas[1], 21, 'B')
    L.rect(5 + piernas[0], 22, 7 + piernas[0], 22, 'N')
    L.rect(9 + piernas[1], 22, 11 + piernas[1], 22, 'N')
    # cuerpo (playera verde con hoja)
    L.rect(5, 14 + sube, 10, 19, 'g')
    L.p(8, 16 + sube, 'l'); L.p(7, 17 + sube, 'l')
    # brazos
    brazo = -1 if fotograma in ('correr1', 'salto') else (1 if fotograma == 'correr3' else 0)
    L.rect(4, 15 + sube + brazo, 4, 17 + sube + brazo, 's')
    L.rect(11, 15 + sube - brazo, 11, 17 + sube - brazo, 's')
    # cabeza
    L.elipse(7.5, 9.5 + sube, 4.6, 4.3, 's')
    L.p(6, 9 + sube, 'k'); L.p(10, 9 + sube, 'k')
    L.p(5, 11 + sube, 'p'); L.p(11, 11 + sube, 'p')
    L.rect(7, 12 + sube, 9, 12 + sube, 'R')
    # retoño
    L.rect(8, 3 + sube, 8, 5 + sube, 'G')
    L.elipse(6, 2.5 + sube, 2, 1.2, 'g')
    L.elipse(10.2, 2 + sube, 2, 1.2, 'l')
    L.contorno()
    L.guardar('brote_' + nombre)


for f in ('reposo1', 'reposo2', 'correr1', 'correr2', 'correr3', 'correr4', 'salto'):
    brote(f, f)


# ---------------------------------------------------------------- residuos
def residuo(nombre, dibujar):
    L = Lienzo(16, 16)
    dibujar(L)
    L.contorno()
    L.guardar('residuo_' + nombre)


def botella(L):
    L.rect(6, 1, 9, 2, 'b')
    L.rect(6, 3, 9, 4, 'c')
    L.rect(5, 5, 10, 14, 'c')
    L.rect(5, 8, 10, 10, 'b')
    L.p(6, 6, 'w'); L.p(6, 11, 'w')


def lata(L):
    L.rect(4, 2, 11, 14, 'e')
    L.rect(4, 6, 11, 10, 'r')
    L.rect(4, 2, 11, 2, 'E'); L.rect(4, 14, 11, 14, 'E')
    L.p(5, 4, 'w'); L.p(5, 12, 'w')


def papel(L):
    L.rect(3, 3, 12, 13, 'w')
    for y in (5, 7, 9, 11):
        L.rect(4, y, 10 if y != 11 else 8, y, 'E')
    L.p(12, 3, None)


def platano(L):
    for i in range(10):
        a = math.pi * (0.15 + i / 12)
        x, y = 8 + 6 * math.cos(a), 4 + 8 * math.sin(a)
        L.elipse(x, y, 1.5, 1.5, 'y')
    L.p(13, 4, 'N'); L.p(2, 6, 'N')
    L.elipse(7, 12, 2, 0.8, 'Y')


def manzana(L):
    L.elipse(7.5, 9, 5, 4.6, 'r')
    for y in range(6, 11):
        L.px[y][12] = None
        L.px[y][11] = C['w'] if 7 <= y <= 9 else L.px[y][11]
    L.rect(7, 2, 7, 4, 'N')
    L.elipse(9.5, 3, 1.6, 0.9, 'g')
    L.p(5, 7, 'w')


def vaso_unicel(L):
    for y in range(3, 15):
        m = (y - 3) // 4
        L.rect(3 + m, y, 12 - m, y, 'w')
    L.rect(3, 3, 12, 3, 'e')
    L.rect(5, 7, 10, 7, 'e')


def frituras(L):
    L.rect(3, 3, 12, 14, 'o')
    L.rect(3, 2, 12, 2, 'e'); L.rect(3, 15, 12, 15, 'e')
    L.elipse(7.5, 9, 3, 2.5, 'y')
    L.p(4, 5, 'w')


for n, d in (('botella', botella), ('lata', lata), ('papel', papel), ('platano', platano),
             ('manzana', manzana), ('vaso_unicel', vaso_unicel), ('frituras', frituras)):
    residuo(n, d)


# ---------------------------------------------------------------- contenedores
def contenedor(nombre, cuerpo, oscuro, simbolo):
    L = Lienzo(24, 28)
    L.rect(2, 4, 21, 7, oscuro)          # tapa
    L.rect(9, 2, 14, 3, oscuro)          # asa
    for y in range(8, 27):
        m = (y - 8) // 8
        L.rect(3 + m, y, 20 - m, y, cuerpo)
    L.rect(5, 10, 5, 24, oscuro); L.rect(18, 10, 18, 24, oscuro)
    simbolo(L)
    L.contorno()
    L.guardar('contenedor_' + nombre)


def sim_hoja(L):
    L.elipse(11.5, 16, 3.5, 5, 'l')
    L.rect(11, 13, 12, 21, 'G')


def sim_reciclar(L):
    for i in range(18):
        a = 2 * math.pi * i / 18
        L.p(11.5 + 4 * math.cos(a), 17 + 4 * math.sin(a), 'w')
    for x, y in ((15, 15), (15, 16), (14, 16), (8, 19), (8, 18), (9, 18)):
        L.p(x, y, 'w')


def sim_tache(L):
    for i in range(-3, 4):
        L.p(11.5 + i, 17 + i, 'w'); L.p(12.5 + i, 17 + i, 'w')
        L.p(11.5 + i, 17 - i, 'w'); L.p(12.5 + i, 17 - i, 'w')


contenedor('organico', 'g', 'G', sim_hoja)
contenedor('reciclable', 'b', 'B', sim_reciclar)
contenedor('no_reciclable', 'm', 'E', sim_tache)


# ---------------------------------------------------------------- escenario
def tile(nombre, f):
    L = Lienzo(16, 16)
    f(L)
    L.guardar('tile_' + nombre)


def pasto(L):
    L.rect(0, 0, 15, 15, 'n')
    rnd = random.Random(1)
    for _ in range(14):
        L.p(rnd.randrange(16), rnd.randrange(6, 16), 'N')
    L.rect(0, 0, 15, 4, 'g')
    for x in range(0, 16, 3):
        L.p(x, 5, 'g'); L.p(x + 1, 0, 'l')


def tierra(L):
    L.rect(0, 0, 15, 15, 'n')
    rnd = random.Random(2)
    for _ in range(18):
        L.p(rnd.randrange(16), rnd.randrange(16), 'N')


def madera(L):
    L.rect(0, 0, 15, 7, 'n')
    L.rect(0, 0, 15, 1, 'Y')
    L.rect(0, 7, 15, 7, 'N')
    for x in (4, 11):
        L.rect(x, 2, x, 6, 'N')


tile('pasto', pasto)
tile('tierra', tierra)
tile('madera', madera)


def fondo():
    L = Lienzo(320, 180)
    for y in range(180):
        t = y / 180
        L.rect(0, y, 319, y, (int(129 + 60 * t), int(212 + 20 * t), int(250 - 20 * t)))
    L.elipse(270, 35, 16, 16, 'y')
    rnd = random.Random(3)
    for cx in range(20, 330, 60):                      # nubes
        cy = rnd.randrange(20, 60)
        for dx in (-10, 0, 10):
            L.elipse(cx + dx, cy - (4 if dx == 0 else 0), 10, 6, 'w')
    for x in range(320):                                # colinas lejanas
        h = 120 + 14 * math.sin(x / 37) + 8 * math.sin(x / 13)
        L.rect(x, int(h), x, 179, (129, 199, 132))
    for x in range(320):                                # colinas cercanas
        h = 145 + 10 * math.sin(x / 29 + 2)
        L.rect(x, int(h), x, 179, (102, 187, 106))
    for tx in range(15, 320, 45):                       # árboles
        ty = 140 + 10 * math.sin(tx / 29 + 2)
        L.rect(tx, int(ty) - 6, tx + 2, int(ty) + 4, 'N')
        L.elipse(tx + 1, ty - 14, 8, 10, 'G')
        L.elipse(tx - 1, ty - 17, 4, 4, 'g')
    L.guardar('fondo_parque')


def smog(fotograma):
    L = Lienzo(22, 16)
    d = fotograma
    for cx, cy, r in ((6, 9, 5), (11, 7 - d, 6), (16, 9, 5), (11, 11, 5)):
        L.elipse(cx, cy, r, r * 0.9, 'E')
    L.elipse(9, 6 - d, 2, 1.5, 'e')
    L.rect(7, 9, 8, 10, 'w'); L.rect(14, 9, 15, 10, 'w')
    L.p(8, 10, 'k'); L.p(14, 10, 'k')
    L.rect(6, 8, 8, 8, 'k'); L.rect(14, 8, 16, 8, 'k')   # cejas enojadas
    L.rect(9, 13, 13, 13, 'k')
    L.contorno()
    L.guardar('smog_%d' % (fotograma + 1))


def corazon(nombre, col):
    L = Lienzo(9, 8)
    for y, (a, b) in enumerate(((1, 2), (0, 3), (0, 8), (0, 8), (1, 7), (2, 6), (3, 5), (4, 4))):
        L.rect(a, y, b, y, col)
    for x in range(5, 8):
        L.p(x, 0, None if x == 5 else col)
    L.p(5, 0, None); L.p(6, 0, col); L.p(7, 0, col); L.p(4, 1, None)
    L.p(2, 2, 'w') if col == 'r' else None
    L.guardar(nombre, 3)


def meta():
    L = Lienzo(16, 40)
    L.rect(2, 2, 3, 39, 'E')
    L.elipse(2.5, 1.5, 1.5, 1.5, 'y')
    for y in range(4, 16):
        L.rect(4, y, 4 + (12 - abs(y - 10)), y, 'g')
    L.elipse(9, 10, 2.5, 3, 'l')
    L.contorno()
    L.guardar('meta_bandera')


def destello():
    L = Lienzo(7, 7)
    L.rect(3, 0, 3, 6, 'y'); L.rect(0, 3, 6, 3, 'y'); L.p(3, 3, 'w')
    L.guardar('destello')


fondo()
smog(0)
smog(1)
corazon('corazon_lleno', 'r')
corazon('corazon_vacio', 'E')
meta()
destello()


# ---------------------------------------------------------------- sonidos
FR = 22050


def guardar_wav(nombre, muestras):
    with wave.open(os.path.join(SND, nombre + '.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(FR)
        w.writeframes(b''.join(struct.pack('<h', int(max(-1, min(1, s)) * 30000)) for s in muestras))


def tono(f0, dur, f1=None, forma='sen', vol=0.5, ataque=0.005, caida=None):
    n = int(FR * dur)
    f1 = f0 if f1 is None else f1
    fase, out = 0.0, []
    for i in range(n):
        t = i / n
        fase += 2 * math.pi * (f0 + (f1 - f0) * t) / FR
        if forma == 'sen':
            v = math.sin(fase)
        elif forma == 'tri':
            v = 2 / math.pi * math.asin(math.sin(fase))
        else:  # campana: seno con armónico suave
            v = math.sin(fase) + 0.3 * math.sin(2.01 * fase)
        env = min(1, i / (FR * ataque + 1)) * ((1 - t) ** (caida or 1.5))
        out.append(v * env * vol)
    return out


def nota(n):
    return 440 * 2 ** ((n - 69) / 12)


def mezclar(*pistas):
    largo = max(len(p) for p in pistas)
    return [sum(p[i] for p in pistas if i < len(p)) for i in range(largo)]


guardar_wav('salto', tono(330, 0.18, 700, 'tri', 0.45))
guardar_wav('recoger', tono(nota(76), 0.07, forma='tri') + tono(nota(83), 0.12, forma='tri'))
guardar_wav('correcto', sum((tono(nota(n), 0.12, forma='campana', vol=0.35, caida=2)
                             for n in (72, 76, 79)), []) + tono(nota(84), 0.4, forma='campana', vol=0.35))
guardar_wav('incorrecto', tono(220, 0.18, 180, 'tri', 0.5) + tono(170, 0.3, 120, 'tri', 0.5))
rnd = random.Random(4)
guardar_wav('dano', [rnd.uniform(-1, 1) * 0.5 * (1 - i / 6000) ** 2 for i in range(6000)])
guardar_wav('victoria', sum((tono(nota(n), d, forma='campana', vol=0.35, caida=1.2)
                             for n, d in ((67, .15), (72, .15), (76, .15), (79, .3), (76, .15), (79, .6))), []))

# Música de fondo en bucle: melodía tranquila en Do mayor (8 compases, 96 bpm)
negra = 60 / 96
melodia = [72, 74, 76, 79, 76, 74, 72, None, 74, 76, 77, 81, 79, 77, 76, None,
           76, 77, 79, 84, 81, 79, 77, 76, 74, 76, 72, 74, 72, None, None, None]
bajo = [48, 55, 53, 55, 48, 55, 53, 43]
pista_m, pista_b = [], []
for n in melodia:
    pista_m += tono(nota(n), negra, forma='tri', vol=0.22, caida=0.8) if n else [0.0] * int(FR * negra)
for n in bajo:
    for _ in range(4):
        pista_b += tono(nota(n), negra, forma='sen', vol=0.25, caida=1.2)
guardar_wav('musica_parque', mezclar(pista_m, pista_b))

print('Listo:', len(os.listdir(SPR)), 'sprites y', len(os.listdir(SND)), 'sonidos en', os.path.abspath(BASE))

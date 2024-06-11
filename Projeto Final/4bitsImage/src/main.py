import numpy as np
from PIL import Image
from matplotlib import pyplot as plt
import numpy as np
from io import StringIO
import shutil

img = Image.open('./image.png')

resolution = (800, 600)

print(f'Usando resolução: {resolution[0]}x{resolution[1]}')


def to_bytearray(x):
   return np.array(x.astype('half')/16, dtype='b')

def format_rgb(rbg):
    return '"' + ''.join((bin(x)[2:].zfill(4) for x in rbg)) + '"'

img = img.resize(resolution) 

img_arr = np.asarray(img)
img_bytes = to_bytearray(img_arr)

rows, columns, _ = img_bytes.shape

buf = StringIO()

buf.write('\n')
buf.write('constant image_pixels : pixel_array := (\n')

for row in range(rows):
    buf.write('(')
    for column in range(columns):
        buf.write(format_rgb(img_bytes[row,column]))

        if(column < columns-1):
            buf.write(',')
    buf.write('),\n')
buf.write(');\n')

with open('./output.txt', 'w') as file:
    buf.seek(0)
    shutil.copyfileobj(buf, file)

# print(img.shape)
# plt.imshow(img)






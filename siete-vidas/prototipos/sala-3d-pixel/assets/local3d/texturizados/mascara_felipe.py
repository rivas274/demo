import numpy as np
from PIL import Image
from scipy import ndimage
A='/home/user/demo/siete-vidas/prototipos/sala-3d-pixel/assets/local3d/'
CAJA=(335,60,680,540)
def rasgos_felipe():
    rgb=np.array(Image.open(A+'felipe_variantes/entrada_gemini.png').convert('RGB').crop(CAJA)).astype(float)
    r,g,b=rgb[...,0],rgb[...,1],rgb[...,2]; lum=0.3*r+0.59*g+0.11*b
    H,W=lum.shape; m=np.zeros((H,W),bool)
    def caja(x0,y0,x1,y1):
        k=np.zeros((H,W),bool); k[y0:y1,x0:x1]=True; return k
    verde=(g>r+10)&(g>b+10)
    oscuro=lum<75
    for bx in [caja(198,218,256,272), caja(282,226,324,272)]:
        o=(verde|oscuro)&bx
        o=ndimage.binary_closing(o,iterations=2)
        o=ndimage.binary_fill_holes(o)
        lab,n=ndimage.label(o)
        if n>1:
            t=ndimage.sum(o,lab,range(1,n+1)); o=lab==(np.argmax(t)+1)
        m|=ndimage.binary_dilation(o,iterations=1)
    rosa=(r>g+25)&(r>140)&caja(262,255,292,280)
    rosa=ndimage.binary_fill_holes(ndimage.binary_closing(rosa,iterations=1))
    m|=ndimage.binary_dilation(rosa,iterations=1)
    boca=(lum<175)&caja(258,276,296,296)&~rosa
    m|=boca
    w=ndimage.gaussian_filter(m.astype(float),1.0)
    w=np.clip(w*1.4,0,1)
    return rgb, w
if __name__=='__main__':
    rgb,w=rasgos_felipe()
    out=(rgb*w[...,None]+np.array([255,0,255])*(1-w[...,None])*0.3+rgb*(1-w[...,None])*0.7)
    Image.fromarray(np.clip(out,0,255).astype(np.uint8)).crop((180,200,340,310)).resize((640,440),Image.NEAREST).save('f_mask.png')

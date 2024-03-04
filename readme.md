# NeptUNO: Tandy Color Computer 2 (CoCo2) and Dragon 32 [English]

Core originally created by Pierco: https://github.com/pcornier/coco2

Finished by dshadoff, alanswx and pcornier.

DeMISTerized and DeMiSTified by ramp069 (UAEReloaded, Neptu)

### Tandy Color 2

This core implements a Tandy Color Computer 2 (CoCo2) that includes:
  * 64k memory
  * 2 analog joysticks (with swap function)
  * Loading cassettes
  * Sound
  * Cartridge holder

### Dragon 32 / 64
  * only dragon 32 seems to work
  * 2 analog joysticks (with swap function)
  * Loading cassettes
  * Sound
  * Cartridge holder

Under development

___________________________________________________________________________

# NeptUNO: Tandy Color Computer 2 (CoCo2) y Dragon 32 [Spanish]

Core arrancando originalmente por Pierco: https://github.com/pcornier/coco2

Terminado por dshadoff y alanswx y pcornier.

DeMISTerizado y DeMiSTificado por rampa069 (UAEReloaded , Neptu )


### Tandy Color 2

Este core implementa un Tandy Color Computer 2 (CoCo2) que incluye:
  * Memoria de 64k
  * 2 joysticks analógicos (con función de intercambio)
  * Carga de casetes
  * Sonido
  * Soporte de cartucho

### Dragon 32 / 64

  * sólo el dragón 32 parece funcionar
  * 2 joysticks analógicos (con función de intercambio)
  * Carga de casetes
  * Sonido
  * Soporte de cartucho

En desarrollo y port.

_____________________________________________________________________________________

# HowTo

-- Install Intel® Quartus® Prime Lite v18.1 (including the updates for it) 
-- https://www.intel.com/content/www/us/en/software-kit/665988/intel-quartus-prime-lite-edition-design-software-version-18-1-for-linux.html
git clone https://github.com/turri21/CoCo2-Dragon-neptuno.git

-- Edit right paths for your system in site.mk file
nano CoCo2-Dragon-neptuno/DeMiSTify/site.mk

make BOARD=neptuno

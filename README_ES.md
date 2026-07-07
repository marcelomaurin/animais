# Animales — Simulación de Ecosistema Simplificado

**Animales** es una simulación visual de ecosistema desarrollada en **Lazarus / Free Pascal**.

El proyecto demuestra un entorno en cuadrícula 2D con seres simples, reglas de supervivencia, alimentación, reproducción, muerte, materia orgánica y estadísticas básicas en tiempo real.

También funciona como un demo práctico de la biblioteca [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT), porque el proyecto depende del paquete `openai_simulation` y la clase `TSer` hereda de `TAISimEntity`.

---

## Estado actual del proyecto

Esta versión es una simulación **simplificada y funcional**, enfocada en demostrar:

- uso de una cuadrícula bidimensional;
- agentes/seres vivos representados como objetos;
- ciclo de simulación por timer;
- alimentación entre especies;
- reproducción;
- muerte por edad o hambre;
- transformación de seres muertos en materia orgánica;
- degradación de la materia orgánica en bacterias;
- renderizado visual simple;
- contadores de población;
- exportación de un resumen CSV simple.

Subespecies, gráficos históricos, mutaciones complejas, pantallas visuales de configuración y paneles avanzados de biodiversidad **no están implementados en el código actual**. Deben considerarse mejoras futuras.

---

## Entidades de la simulación

| Tipo | Color en la interfaz | Comportamiento actual |
|---|---|---|
| **Bacteria** | Amarillo | Puede consumir materia orgánica, moverse aleatoriamente y reproducirse. |
| **Planta** | Verde | Sirve como alimento para herbívoros y puede reproducirse. |
| **Herbívoro** | Azul | Come plantas, se mueve y muere por edad o hambre. |
| **Carnívoro** | Rojo | Entra en el ciclo configurado, come herbívoros y muere por edad o hambre. |
| **Materia orgánica** | Marrón | Surge de plantas, herbívoros y carnívoros muertos; luego se degrada en bacterias. |

---

## Estructura del código

| Archivo | Responsabilidad |
|---|---|
| `animal.lpr` | Programa principal Lazarus. |
| `animal.lpi` | Archivo del proyecto Lazarus, con dependencia de `openai_simulation`. |
| `form2.pas` / `form2.lfm` | Interfaz visual principal, timer, dibujo y exportación CSV. |
| `uTipos.pas` | Define `TTipo` y `TSer`, que hereda de `TAISimEntity`. |
| `uConfig.pas` | Define `TConfig` y los parámetros predeterminados. |
| `uTabuleiro.pas` | Implementa la cuadrícula con `FBoard` y `FNextBoard`. |
| `uSimulacao.pas` | Implementa las reglas ecológicas y el ciclo de simulación. |
| `uEstat.pas` | Define el record `TEstat` usado para contadores poblacionales. |

---

## Relación con la biblioteca CHATGPT

Este proyecto es un ejemplo de lo que se puede construir con la biblioteca [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT), especialmente con el área **AI Simulation**.

En la versión actual, la integración aún es mínima:

- el proyecto Lazarus depende de `openai_simulation`;
- `TSer` hereda de `TAISimEntity`;
- la estructura sigue conceptos de simulación como entidades, cuadrícula, ciclos y métricas.

El proyecto sirve como base didáctica para evolucionar hacia un uso más completo de los componentes de `AI Simulation`.

---

## Cómo compilar

### Requisitos

- Lazarus IDE;
- Free Pascal Compiler;
- copia local de [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT);
- paquete `openai_simulation` instalado o visible para Lazarus.

### Compilación

```bash
git clone https://github.com/marcelomaurin/animais.git
cd animais
lazbuild animal.lpi
```

O abra `animal.lpi` en Lazarus y compile desde el IDE.

---

## Limitaciones actuales

- La configuración es estática en `uConfig.pas`.
- La exportación CSV es solo un snapshot simple.
- Todavía no hay historial completo por ciclo.
- No hay gráficos ni pestañas.
- No hay subespecies ni mutaciones avanzadas en el código actual.
- El proyecto aún no utiliza todos los componentes de `AI Simulation`.

---

## Licencia

Este proyecto se distribuye bajo la licencia **GPL-3.0**.

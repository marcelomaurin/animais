# Animales — Simulación de Ecosistema Simplificado (Lazarus / Free Pascal)

**Animales** es una simulación visual de ecosistemas basada en agentes desarrollada en **Lazarus / Free Pascal**. El proyecto está integrado con la biblioteca **CHATGPT** (específicamente utilizando los componentes de simulación del paquete `openai_simulation`), lo que demuestra la aplicación práctica de redes celulares, reglas evolutivas y control de ciclos con doble búfer seguro.

---

## Idiomas / Languages

- [Português (PT-BR)](README.md)
- [English (EN)](README_EN.md)
- [Español (ES)](README_ES.md)
- [Français (FR)](README_FR.md)
- [中文 (ZH)](README_ZH.md)
- [العربية (AR)](README_AR.md)

---

## Qué hace el proyecto

La simulación modela la dinámica de supervivencia y reproducción de un ecosistema simplificado en una cuadrícula bidimensional de $80 \times 80$. El sistema está regido por 5 tipos de entidades:

| Tipo | Color | Comportamiento |
|---|---|---|
| **Planta** | Verde | Recurso primario, se reproduce tras algunos ciclos si hay espacio. |
| **Herbívoro** | Azul | Se mueve y se alimenta de plantas. Muere por edad o inanición (hambre). |
| **Carnívoro** | Rojo | Entra en el ciclo 200, se alimenta de herbívoros. Muere por edad o hambre. |
| **Materia Orgánica** | Marrón | Generada por la muerte de plantas, herbívoros o carnívoros. Se degrada después de algunos ciclos. |
| **Bacteria** | Amarillo | Surge de la degradación de la materia orgánica, consume materia y se reproduce. |

---

## Principios de Diseño y Estabilidad

Esta versión ha sido completamente reestructurada para garantizar la estabilidad y evitar problemas de memoria (Access Violations y Double-Frees):

1. **Doble Búfer Seguro**: El tablero (`TTabuleiro`) mantiene `FBoard` (estado activo) y `FNextBoard` (próximo estado). Todos los cambios se escriben en `FNextBoard` y se aplican al final de cada ciclo.
2. **Propietario Único**: Un objeto vivo (`TSer`) pertenece a un solo búfer a la vez.
3. **Liberación de Memoria Segura**: Las entidades que mueren se marcan con `Morto := True` y se eliminan de la simulación activa. La liberación de memoria (`Free`) se gestiona exclusivamente durante la fase de `Commit` del tablero.
4. **Semilla Fija**: Utiliza una semilla pseudoaleatoria fija al inicio para reproducibilidad científica.

---

## Integración con la biblioteca CHATGPT

La clase fundamental `TSer` (en `uTipos.pas`) hereda directamente de `TAISimEntity` del paquete `openai_simulation`. Esto permite utilizar el ecosistema como un entorno simulado para el entrenamiento de modelos de IA, la toma de decisiones de agentes lógicos y el análisis de datos ecológicos.

---

## Estructura del Código

* **`uTipos.pas`**: Clase `TSer` que extiende `TAISimEntity`.
* **`uTabuleiro.pas`**: Gestor de cuadrícula con doble búfer y gestión de memoria segura.
* **`uConfig.pas`**: Registro `TConfig` con parámetros ecológicos calibrados.
* **`uSimulacao.pas`**: Motor central que procesa los pasos de la simulación y aplica reglas biológicas.
* **`uEstat.pas`**: Registro estadístico de recuento de población por ciclo.
* **`form2.pas` / `form2.lfm`**: Interfaz de control visual con botones Iniciar, Pausar, Parar, Reiniciar y exportación de CSV.

---

## Cómo Compilar y Ejecutar

### Requisitos
- Lazarus IDE
- Free Pascal Compiler (FPC)
- Biblioteca CHATGPT (carpeta `pacote` accesible en las rutas de búsqueda definidas en `.lpi`)

### Compilación
Abra la terminal en el directorio del proyecto y ejecute:
```bash
lazbuild animal.lpi
```

O abra `animal.lpi` directamente en el IDE de Lazarus y presione **F9**.

---

## Licencia
Este proyecto está bajo la licencia **GPL-3.0**.

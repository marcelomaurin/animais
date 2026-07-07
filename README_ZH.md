# Animals — 简化版生态系统模拟项目 (Lazarus / Free Pascal)

**Animals** 是一个基于智能体的视觉生态系统模拟项目，使用 **Lazarus / Free Pascal** 开发。本项目与 **CHATGPT** 库深度集成（具体使用 `openai_simulation` 包中的模拟组件），展示了元胞网格、进化规则以及基于安全双缓冲的循环执行的实际应用。

---

## 语言 / Languages

- [Português (PT-BR)](README.md)
- [English (EN)](README_EN.md)
- [Español (ES)](README_ES.md)
- [Français (FR)](README_FR.md)
- [中文 (ZH)](README_ZH.md)
- [العربية (AR)](README_AR.md)

---

## 项目功能

该项目在一个 $80 \times 80$ 的二维网格中模拟简化生态系统的生存和繁殖动态。系统由 5 种实体类型构成：

| 类型 | 颜色 | 行为 |
|---|---|---|
| **植物 (Plant)** | 绿色 | 基础资源，若有空间，在若干循环后进行繁殖。 |
| **草食动物 (Herbivore)** | 蓝色 | 移动并以植物为食。因年龄或饥饿死亡。 |
| **肉食动物 (Carnivore)** | 红色 | 在第 200 个循环引入，以草食动物为食。因年龄或饥饿死亡。 |
| **有机物 (Organic Matter)** | 棕色 | 由植物、草食动物或肉食动物死亡产生。在若干循环后降解。 |
| **细菌 (Bacteria)** | 黄色 | 从降解的有机物中产生，消耗有机物并进行繁殖。 |

---

## 设计原则与稳定性

此版本经过完全重构，以确保稳定运行并防止内存问题（内存访问冲突 Access Violations 和双重释放 Double-Frees）：

1. **安全双缓冲**：网格 (`TTabuleiro`) 维护 `FBoard`（当前状态）和 `FNextBoard`（下一状态）。所有修改写入 `FNextBoard` 并于循环结束时提交。
2. **唯一所有权**：存活的实体对象 (`TSer`) 在同一时间仅属于一个缓冲区。
3. **安全内存释放**：死亡的实体被标记为 `Morto := True` 并从活动模拟中移除。内存释放 (`Free`) 仅在网格的 `Commit` 阶段集中执行。
4. **固定随机种子**：初始化时使用固定的伪随机种子以保证科学可重复性。

---

## 与 CHATGPT 库集成

核心类 `TSer`（位于 `uTipos.pas`）直接继承自 `openai_simulation` 包中的 `TAISimEntity`。这使得该生态系统能够作为模拟环境，用于 AI 模型训练、逻辑智能体决策以及生态数据分析。

---

## 代码结构

* **`uTipos.pas`**：继承自 `TAISimEntity` 的 `TSer` 类。
* **`uTabuleiro.pas`**：包含双缓冲和安全内存管理的网格管理器。
* **`uConfig.pas`**：包含已校准生态参数的 `TConfig` 记录类型。
* **`uSimulacao.pas`**：处理模拟步骤并应用生物学规则的核心引擎。
* **`uEstat.pas`**：记录每个循环人口数量的数据结构。
* **`form2.pas` / `form2.lfm`**：包含启动、暂停、停止、重新启动按钮以及 CSV 导出的可视化控制界面。

---

## 如何编译和运行

### 开发要求
- Lazarus IDE
- Free Pascal Compiler (FPC)
- CHATGPT 库（`pacote` 文件夹必须在 `.lpi` 中配置的搜索路径内）

### 编译步骤
在项目根目录下打开终端并运行：
```bash
lazbuild animal.lpi
```

或者直接在 Lazarus IDE 中打开 `animal.lpi` 并按 **F9** 运行。

---

## 开源协议
本项目采用 **GPL-3.0** 开源协议。

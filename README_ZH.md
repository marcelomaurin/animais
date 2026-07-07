# Animals — 简化生态系统模拟

**Animals** 是一个使用 **Lazarus / Free Pascal** 开发的可视化生态系统模拟项目。

该项目演示了一个 2D 网格环境，其中包含简单生物、生存规则、进食、繁殖、死亡、有机物以及基础的实时统计。

它也是 [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) 库的一个实践示例，因为该项目依赖 `openai_simulation` 包，并且 `TSer` 类继承自 `TAISimEntity`。

---

## 当前项目状态

当前版本是一个**简化但可运行的模拟项目**，重点展示：

- 二维网格；
- 用对象表示的生物/代理；
- 基于 timer 的模拟循环；
- 物种之间的进食关系；
- 繁殖；
- 因年龄或饥饿死亡；
- 死亡生物转化为有机物；
- 有机物降解后转化为细菌；
- 简单可视化渲染；
- 种群计数；
- 简单 CSV 摘要导出。

亚种、历史图表、复杂突变、可视化配置界面和高级生物多样性面板**尚未在当前源码中实现**，应作为未来改进方向。

---

## 模拟实体

| 类型 | 界面颜色 | 当前行为 |
|---|---|---|
| **细菌** | 黄色 | 可以消耗有机物，随机移动并繁殖。 |
| **植物** | 绿色 | 作为草食动物的食物，也可以繁殖。 |
| **草食动物** | 蓝色 | 吃植物、移动，并因年龄或饥饿死亡。 |
| **肉食动物** | 红色 | 在配置的循环中出现，吃草食动物，并因年龄或饥饿死亡。 |
| **有机物** | 棕色 | 由死亡的植物、草食动物和肉食动物产生，之后降解为细菌。 |

---

## 代码结构

| 文件 | 职责 |
|---|---|
| `animal.lpr` | Lazarus 主程序。 |
| `animal.lpi` | Lazarus 项目文件，包含 `openai_simulation` 依赖。 |
| `form2.pas` / `form2.lfm` | 主界面、timer、绘制和 CSV 导出。 |
| `uTipos.pas` | 定义 `TTipo` 和继承自 `TAISimEntity` 的 `TSer`。 |
| `uConfig.pas` | 定义 `TConfig` 和默认参数。 |
| `uTabuleiro.pas` | 使用 `FBoard` 和 `FNextBoard` 实现网格。 |
| `uSimulacao.pas` | 实现生态规则和模拟循环。 |
| `uEstat.pas` | 定义用于种群计数的 `TEstat` record。 |

---

## 与 CHATGPT 库的关系

该项目展示了可以使用 [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) 库构建的应用类型，特别是 **AI Simulation** 区域。

当前版本的集成仍然是最小化的：

- Lazarus 项目依赖 `openai_simulation`；
- `TSer` 继承自 `TAISimEntity`；
- 项目结构遵循实体、网格、循环和指标等模拟概念。

该项目可以作为教学基础，逐步演进到更完整地使用 `AI Simulation` 组件。

---

## 如何编译

### 要求

- Lazarus IDE；
- Free Pascal Compiler；
- 本地 [`CHATGPT`](https://github.com/marcelomaurin/CHATGPT) 副本；
- Lazarus 能访问或安装 `openai_simulation` 包。

### 编译

```bash
git clone https://github.com/marcelomaurin/animais.git
cd animais
lazbuild animal.lpi
```

也可以在 Lazarus 中打开 `animal.lpi` 并通过 IDE 编译。

---

## 当前限制

- 配置仍然固定在 `uConfig.pas` 中。
- CSV 导出只是简单快照。
- 尚无完整的循环历史记录。
- 尚无图表或分页面板。
- 当前代码中没有亚种或高级突变。
- 项目尚未使用完整的 `AI Simulation` 组件集。

---

## 许可证

本项目采用 **GPL-3.0** 许可证发布。

# 蘑菇体 · MUSHROOM BODY

![screenshot](docs/screenshot.jpg)

果蝇（*Drosophila melanogaster*）蘑菇体（mushroom body, MB）的 3D 神经模拟。
点击高亮的刺激位点施加刺激，看脉冲在 Kenyon 细胞纤维上跑；接上 OpenAI 兼容接口，让 LLM **以果蝇的第一人称** 说出它此刻感觉到什么。

单页 HTML，离线可跑，安卓手机直接打开。

---

## 怎么用

直接打开 `index.html`（或在 Minis 里点 `minis://workspace/fly-mushroom-body/index.html`）。

| 操作 | 效果 |
|---|---|
| 拖动 | 旋转视角 |
| 双指 / 滚轮 | 缩放 |
| 点击 3D 里的光点，或左栏列表 | 对该位点施加刺激（强度按底栏滑杆） |
| 底栏「强度」 | 刺激强度 0.1 – 2.0 |
| 底栏「速度」 | 每帧推进的模拟毫秒数，0 = 冻结 |
| 右下「说 / 想」 | 对它说话 / 让它自言自语 |
| 右上 ⚙ | 填 API Key、模型、温度 |
| 右上 ⬇ | 导出当前神经快照 JSON |

### 接 LLM（让它“以为自己是果蝇”）

右上 ⚙ → 选一个预设（DeepSeek / OpenAI / 智谱 / Kimi / 通义）或手填：

- **Base URL**：形如 `https://api.deepseek.com/v1`（会自动拼 `/chat/completions`）
- **Model**：`deepseek-chat` 等
- **API Key**：只存在本机 `localStorage`，只发往你填的那个地址
- 先点「测试连接」→「保存」

配好后：**每次施加刺激，它会立刻“哼”一句**（6 秒节流），也可以点「想」让它自己说。

它的台词完全由注入的神经状态决定：多巴胺高 → 兴奋趋近；多巴胺负 → 退缩僵住；饥饿高 → 只想糖和发酵果香；恐惧高 → 想贴着边缘飞。

---

## 模拟了什么

### 解剖（几何按比例近似）

| 结构 | 数量 | 说明 |
|---|---|---|
| Kenyon 细胞（KC） | 540（两侧） | γ 150 / αβ 70 / α′β′ 32 / γd 18，每侧 |
| 投射神经元（PN） | 52 | 触角叶 → 萼 |
| 触角叶（AL） | 30 | 嗅觉输入小球 |
| SEZ 味觉 | 15 | 糖 / 苦 / 水 |
| DAN 多巴胺能 | 34 | PAM（奖赏）、PPL1（惩罚）、PPL2（睡眠） |
| OA 神经元 | 10 | 觉醒 / 奖赏 |
| MBON 输出 | 18 | KC → 下游 |
| 中央复合体 | 42 | EB 环 / PB / FB，导航 |

纤维是 4 段折线：**萼 → 花梗 → 分叉点 → 水平叶 / 竖叶**，两侧对称。

### 动力学（`js/sim.js`）

- **漏积分发放（LIF）**，1 ms 一步，2–3 ms 不应期
- **分级电位传递**：果蝇神经元靠分级电位编码，突触前驱动力 = `发放 + 0.85 × 亚阈值去极化`，比纯脉冲模型更像真实果蝇
- **稀疏编码**：KC 层按 APL / 局部中间神经元做侧抑制，活跃 KC 超过 ~4.5% 就开始整体压暗，最终稳定在 3–10% —— 这就是蘑菇体的组合码
- **三因子可塑**：资格迹 × 多巴胺。奖赏（DA>0）加强 KC→MBON，惩罚（DA<0）削弱
- 钙成像式的慢成分 `slow`，让“亮斑”停留几百毫秒，跟真实成像观感接近

### 刺激位点（12 个）

触角叶 CH1 / DM2、SEZ 甜 / 苦、萼 CA、γ 主叶、α 竖叶、PAM（奖赏）、PPL1（惩罚）、MBON、中央复合体 EB、全脑电击。

---

## 文件

```
index.html          页面骨架 + UI
css/app.css         暗色玻璃风格
js/net.js           网络几何 / 连接构建（数据驱动）
js/sim.js           LIF + 可塑性 + 快照
js/render.js        Three.js + Bloom 后处理 + 拾取
js/llm.js           OpenAI 兼容调用 + 果蝇人设提示词
js/main.js          交互、UI、事件→果蝇状态
vendor/             three.js r128 与后处理脚本（本地，离线可用）
tools/report.js     命令行摘要：node tools/report.js obs.json
test/sim_test.js    Node 侧模拟自检（纯 Node，不开浏览器）
docs/screenshot.jpg README 用图
LICENSE             MIT
```

### 本地跑

零依赖、零构建，**双击 `index.html` 就能用**（脚本全部本地化，离线可跑）。
想走本地服务器：`python3 -m http.server 8000` → 开 `http://localhost:8000`。
想部署成网页：整包丢进 GitHub Pages（Settings → Pages → 根目录）即可。

### 自检

```sh
node test/sim_test.js      # 静息 / 气味 / 甜味 / 惩罚 / 电击 五段检查
```
```

### 命令行看导出的快照

```sh
node tools/report.js ~/Downloads/fly-observation-*.json
```

输出各叶活动条、DA/OA 水平、果蝇主观状态和最近经历。

---

## 改人设

`js/llm.js` 里的 `SYSTEM_PROMPT` 决定它怎么说话；
`sensations()` 决定神经读数被翻译成什么“感官描述”。

## 边界说明

这是**教学 / 艺术化的近似模型**，不是生物学定量仿真：真实蘑菇体约 2000 个 KC，连接拓扑是随机化的，没有做 Hebbian 之外的学习、没有做真实的多巴胺分区解剖学。它足够“像”，但不是论文级。

反向：果蝇**没有海马体**——海马体是哺乳动物结构，果蝇的记忆中枢是蘑菇体与中央复合体。

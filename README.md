# 沐曦PD分离架构方案

## 概述

PD 分离架构是一种先进的大模型推理优化技术，其核心思想是将 LLM 推理过程中的两个关键计算阶段——**Prefill（预填充）**和**Decode（解码）**——分别部署在不同的计算节点上。这种架构设计能够有效解决传统单体部署模式下的资源瓶颈问题，显著提升推理系统的整体吞吐量和资源利用率。

采用 PD 分离架构的主要优势包括：

- **资源优化**：Prefill 阶段计算密集，Decode 阶段访存密集，分离部署可针对性优化资源配置
- **吞吐量提升**：支持多请求并行处理，大幅提升系统并发能力
- **弹性扩展**：可根据实际负载动态调整 Prefill 和 Decode 节点数量
- **延迟优化**：通过流水线并行机制，有效降低端到端推理延迟

**本文档详细介绍了在沐曦曦云 C 系列硬件平台上，使用沐曦自研 MXMACA 软件栈和 SGLang 框架进行大语言模型（LLM）PD（Prefill-Decode，预填充 - 解码）分离推理部署与测试的完整流程。**

## 支持模型

<table>
<tr>
<th>分类</th>
<th>模型名称</th>
</tr>
<tr>
<td rowspan="3">DeepSeek</td>
<td>DeepSeek-R1</td>
</tr>
<tr>
<td>DeepSeek-V3.1</td>
</tr>
<tr>
<td>DeepSeek-V3.2</td>
</tr>
<tr>
<td rowspan="2">GLM</td>
<td>GLM-5</td>
</tr>
<tr>
<td>GLM-5.1</td>
</tr>
<tr>
<td>MiniMax</td>
<td>MiniMax-2.5</td>
</tr>
<tr>
<td>Qwen</td>
<td>Qwen3.5-397B-A17B</td>
</tr>
<tr>
<td>MiMo</td>
<td>MiMo-V2-Flash</td>
</tr>
</table>

## 版本配套说明

<table>
<tr>
<th>名称</th>
<th colspan="2">版本</th>
</tr>
<tr>
<td>GPU支持型号</td>
<td colspan="2">曦云C500/C550/C588</td>
</tr>
<tr>
<td>CPU支持架构</td>
<td colspan="2">X86</td>
</tr>
<tr>
<td>MXMACA版本</td>
<td colspan="2">3.2及以上</td>
</tr>
<tr>
<td>SGLang版本</td>
<td colspan="2">v0.5.7</td>
</tr>
</table>

## PD分离配置说明

PD 分离部署时，Prefill 实例与 Decode 实例需遵循特定的配比规则。为便于后续说明，PD 分离配比采用以下格式表示：

`xPm yDn`：表示 x 个 Prefill 实例（每个实例占用 m 个节点）和 y 个 Decode 实例（每个实例占用 n 个节点）。每个节点默认配置 8 张GPU。

**最低配置要求如下：**

### DeepSeek

<table>
<tr>
<th>模型名称</th>
<th>模型精度</th>
<th>GPU型号</th>
<th>Prefill配置</th>
<th>Decode配置</th>
<th>总节点数</th>
</tr>
<tr>
<td rowspan="2">

* DeepSeek-R1
* DeepSeek-V3.1
* DeepSeek-V3.2
</td>
<td rowspan="2">W8A8</td>
<td>C500/C550</td>
<td>1P2</td>
<td>1D4</td>
<td>6</td>
</tr>
<tr>
<td>C588</td>
<td>1P1</td>
<td>1D2</td>
<td>3</td>
</tr>
</table>

### GLM

<table>
<tr>
<th>模型名称</th>
<th>模型精度</th>
<th>GPU型号</th>
<th>Prefill配置</th>
<th>Decode配置</th>
<th>总节点数</th>
</tr>
<tr>
<td rowspan="2">

* GLM-5
* GLM-5.1
</td>
<td rowspan="2">W8A8</td>
<td>C500/C550</td>
<td>1P2</td>
<td>1D4</td>
<td>6</td>
</tr>
<tr>
<td>C588</td>
<td>1P1</td>
<td>1D2</td>
<td>3</td>
</tr>
</table>

### MiniMax

<table>
<tr>
<th>模型名称</th>
<th>模型精度</th>
<th>GPU型号</th>
<th>Prefill配置</th>
<th>Decode配置</th>
<th>总节点数</th>
</tr>
<tr>
<td rowspan="2">MiniMax-M2.5</td>
<td rowspan="2">W8A8</td>
<td>C500/C550</td>
<td>1P1</td>
<td>1D2</td>
<td>3</td>
</tr>
<tr>
<td>C588</td>
<td>1P1</td>
<td>1D1</td>
<td>2</td>
</tr>
</table>

### Qwen

<table>
<tr>
<th>模型名称</th>
<th>模型精度</th>
<th>GPU型号</th>
<th>Prefill配置</th>
<th>Decode配置</th>
<th>总节点数</th>
</tr>
<tr>
<td rowspan="2">Qwen3.5-397B-A17B</td>
<td rowspan="2">W8A8</td>
<td>C500/C550</td>
<td>1P1</td>
<td>1D2</td>
<td>3</td>
</tr>
<tr>
<td>C588</td>
<td>1P1</td>
<td>1D1</td>
<td>2</td>
</tr>
</table>

### MiMo

<table>
<tr>
<th>模型名称</th>
<th>模型精度</th>
<th>GPU型号</th>
<th>Prefill配置</th>
<th>Decode配置</th>
<th>总节点数</th>
</tr>
<tr>
<td rowspan="2">MiMo-V2-Flash</td>
<td rowspan="2">W8A8</td>
<td>C500/C550</td>
<td>1P1</td>
<td>1D2</td>
<td>3</td>
</tr>
<tr>
<td>C588</td>
<td>1P1</td>
<td>1D1</td>
<td>2</td>
</tr>
</table>

## 部署文档

| 名称     | 链接                                  |
| -------- | ------------------------------------- |
| DeepSeek | [DeepSeek](DeepSeek/启动服务.md) |
| GLM      | [GLM](GLM/启动服务.md)           |
| MiniMax  | [MiniMax](MiniMax/启动服务.md)   |
| Qwen     | [Qwen](Qwen/启动服务.md)         |
| MiMo     | [MiMo](MiMo/启动服务.md)         |


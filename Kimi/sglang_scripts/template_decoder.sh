#!/bin/bash

set -x
pidof python | xargs -n 1 kill -9
pidof python3 | xargs -n 1 kill -9
pidof sglang | xargs -n 1 kill -9
source configs/$(hostname -i).env


export MACA_SMALL_PAGESIZE_ENABLE=1
export TRITON_ENABLE_MACA_OPT_MOVE_DOT_OPERANDS_OUT_LOOP=1
export TRITON_ENABLE_MACA_CHAIN_DOT_OPT=1
export PYTORCH_ENABLE_PG_HIGH_PRIORITY_STREAM=1
export MACA_QUEUE_SCHEDULE_POLICY=1
export MACA_GRAPH_LAUNCH_MODE=5

export MCCL_IB_HCA=mlx5_1,mlx5_2,mlx5_3,mlx5_4
export NVSHMEM_DISABLE_CUDA_VMM=1
export NVSHMEM_ENABLE_NIC_PE_MAPPING=1
export NVSHMEM_HCA_PE_MAPPING=mlx5_1:1:2,mlx5_2:1:2,mlx5_3:1:2,mlx5_4:1:2
export NVSHMEM_BOOTSTRAP_UID_SOCK_IFNAME=inbond1
export NVSHMEM_IB_TRAFFIC_CLASS=160

export MXSHMEM_DISABLE_CUDA_VMM=1
export MXSHMEM_ENABLE_NIC_PE_MAPPING=1
export MXSHMEM_HCA_PE_MAPPING=mlx5_1:1:2,mlx5_2:1:2,mlx5_3:1:2,mlx5_4:1:2
export MXSHMEM_BOOTSTRAP_UID_SOCK_IFNAME=inbond1
export MXSHMEM_IB_TRAFFIC_CLASS=160


export MCCL_SOCKET_IFNAME=inbond1
export GLOO_SOCKET_IFNAME=inbond1
export SGLANG_ENABLE_JIT_DEEPGEMM=true
export FUSED_RMSNORM_QUANT=1
export DEEPEP_MORE_EXPERTS=1



TP=32
DP=32
MEMORY_FRACTION=0.82

env


python3 -m sglang.launch_server \
    --random-seed 0 \
    --model-path $MODEL \
    --host $(hostname -i) \
    --port 30001 \
    --tp-size $TP \
    --dp-size $DP \
    --enable-dp-attention \
    --enable-dp-lm-head \
    --disable-radix-cache --disable-chunked-prefix-cache \
    --attention-backend flashinfer  \
    --quantization w8a8_int8 \
    --disaggregation-mode decode  \
    --disaggregation-ib-device  $MCCL_IB_HCA \
    --moe-a2a-backend deepep \
    --deepep-mode low_latency \
    --moe-runner-backend deep_gemm \
    --dist-init-addr $DIST_INIT_ADDR  \
    --nnodes $NNODES \
    --node-rank $NODE_RANK \
    --trust-remote-code 2>&1 | tee logs/decoder_$(hostname -i).log \

    

   

#!/bin/bash

set -x
pidof python | xargs -n 1 kill -9
source configs/$(hostname -i).env


export MACA_SMALL_PAGESIZE_ENABLE=1
export TRITON_ENABLE_MACA_OPT_MOVE_DOT_OPERANDS_OUT_LOOP=1
export TRITON_ENABLE_MACA_CHAIN_DOT_OPT=1
export PYTORCH_ENABLE_PG_HIGH_PRIORITY_STREAM=1
export MACA_QUEUE_SCHEDULE_POLICY=1
export MACA_DIRECT_DISPATCH=1
export MACA_GRAPH_LAUNCH_MODE=5

export MCCL_SOCKET_IFNAME=inbond1
export GLOO_SOCKET_IFNAME=inbond1

export MCCL_IB_HCA=mlx5_1,mlx5_2,mlx5_3,mlx5_4


PP=$PREFILL_PP_SIZE
TP=$(( $NNODES * 8 / $PP ))
MEMORY_FRACTION=0.82

env

python3 -m sglang.launch_server \
    --model-path $MODEL \
    --host $(hostname -i) \
    --port 30000 \
    --tp-size $TP \
    --pp-size $PP \
    --disable-radix-cache  \
    --attention-backend flashinfer  \
    --mem-fraction-static ${MEMORY_FRACTION} \
    --quantization w8a8_int8 \
    --disaggregation-mode prefill  \
    --disaggregation-ib-device  $MCCL_IB_HCA \
    --dist-init-addr $DIST_INIT_ADDR  \
    --nnodes $NNODES \
    --node-rank $NODE_RANK \
    --trust-remote-code 2>&1 | tee logs/prefill_$(hostname -i).log
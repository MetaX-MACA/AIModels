
set -x

WORKDIR=$(dirname "$(readlink -f "$0")")
cd $WORKDIR

source configs/$(hostname -i).env

docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true

DOCKER_IMAGE=cr.metax-tech.com && docker pull cr.metax-tech.com/public-ai-release/maca/sglang:0.5.10-maca.ai3.7.1.12-torch2.8-py312-ubuntu22.04-amd64


if [[ $ROLE == "decoder" ]]; then
    LAUNCH_SCRIPT=template_decoder.sh
else
    LAUNCH_SCRIPT=template_prefill.sh
fi

docker run -itd --rm --name=$CONTAINER_NAME \
            --net=host \
            --uts=host \
            --ipc=host \
            --device=/dev/dri \
            --device=/dev/mxcd  \
            --device=/dev/infiniband \
            --privileged=true \
            --group-add video \
            --security-opt seccomp=unconfined \
            --security-opt apparmor=unconfined \
            --shm-size 100gb \
            --ulimit memlock=-1 \
            -d \
            -v /data/:/data/ \
            -v /home/:/home/ \
            -v /metax0402/metax0402/:/metax0402/metax0402/ \
            -v $WORKDIR:/workspace \
            --workdir=/workspace \
            --runtime=runc -t $DOCKER_IMAGE /bin/bash -c "source /etc/profile && source ~/.bashrc && bash $LAUNCH_SCRIPT"
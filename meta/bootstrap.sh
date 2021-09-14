for i in {1..5};
do
    UUID=$(uuid -v 4)
    DATASET=a258b6f1-e580-42ea-a79d-c6df33239837/datafs/var/lib/volumes
    zfs create -o mountpoint=legacy ${DATASET}/${UUID}
    podman volume create --opt type=zfs --opt device=${DATASET}/${UUID} ${UUID}
done

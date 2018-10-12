database -open my_shm -shm -into $env(PROJECT_VER_DIR)/WAVES/$env(TC)_$env(SEED).shm
probe -create -database my_shm -depth all -all

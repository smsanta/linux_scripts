#/bin/bash
cd /opt/work/projects/ar-bancor-rediseno
git apply /home/juan/rediseno_local_config.patch
git status
echo ""
echo "Local config for ar-bancor-rediseno was applied."
exit 0
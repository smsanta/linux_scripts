#/bin/bash
cd /opt/work/projects/ar-bancor-rediseno
git reset HEAD --hard && git clean -f -d
git status
echo ""
echo "Git ar-bancor-rediseno is clean on HEAD commit."
exit 0
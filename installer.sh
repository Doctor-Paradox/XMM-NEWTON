set -e
sudo apt install figlet
[ -d ~/bin ] || mkdir ~/bin
cp *.py ~/bin/
cp *.sh ~/bin/

chmod 700 ~/bin/xmm_newton_advanced_script.sh
(echo "#----------------XMM SCRIPT---------------------")>>~/.bashrc
(echo "alias xmmadvanced="~/bin/xmm_newton_advanced_script.sh"")>>~/.bashrc
(echo "#----------------XMM SCRIPT---------------------")>>~/.bashrc
set +e

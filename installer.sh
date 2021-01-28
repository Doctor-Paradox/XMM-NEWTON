set -e
sudo apt install figlet
[ -d ~/bin ] || mkdir ~/bin
cp bkg_multicircle_xmm.py ~/bin/bkg_multicircle_xmm.py
cp coord.py ~/bin/coord.py
cp coordX.py ~/bin/coordX.py
cp coordY.py ~/bin/coordY.py
cp src_circle.py ~/bin/src_circle.py
cp for_phasecalc.py ~/bin/for_phasecalc.py
cp rgs_contaminator.py ~/bin/rgs_contaminator.py
cp rgs_pileup.py ~/bin/rgs_pileup.py
cp rgs_user_index_finder.py ~/bin/rgs_user_index_finder.py
cp time_fil_expre_maker.py ~/bin/time_fil_expre_maker.py
cp xmm_newton_advanced_script.sh ~/bin/xmm_newton_advanced_script.sh

chmod 700 ~/bin/xmm_newton_advanced_script.sh
(echo "#----------------XMM SCRIPT---------------------")>>~/.bashrc
(echo "alias xmmadvanced="~/bin/xmm_newton_advanced_script.sh"")>>~/.bashrc
(echo "#----------------XMM SCRIPT---------------------")>>~/.bashrc
set +e

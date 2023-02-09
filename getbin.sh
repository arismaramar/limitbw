#!/bin/bash

settDir="/root/resipt"
settPath="$settDir/ipt.txt"
fwUr="/etc/firewall.user"
clear
if [[ -e $settPath ]]; then
	ipr2="$(cat $settPath |grep -i ipr | cut -d= -f2 | head -n1)"
	spd2="$(cat $settPath |grep -i spd | cut -d= -f2 | head -n1)"
	spu2="$(cat $settPath |grep -i spu | cut -d= -f2 | head -n1)"
else
	echo "File ipt.txt tidak ditemukan, membuat file kosong."
	[ ! -d $settDir ] && mkdir $settDir
	[ -d $settDir ] && touch $settPath
fi

home() {
	echo " Masukkan range ip /ip anda cth: 192.168.1.1-192.168.1.254 atau 192.168.1.1 " 
	read -p " default ip: $ipr2 : " ipr
	echo " Masukkan limit speed download, ket : dalam KB/s (cth:100)"
	read -p " default speed download: $spd2 KB/s : " spd
	echo " Masukkan limit speed upload,ket : dalam KB/s (cth:100) "
	read -p " default speed download: $spu2 KB/s : " spu
}

hapusset() {
	echo " Menghapus pengaturan limitbw yang tersimpan..."
	sleep 3
	clear

	#remove old setting iptables

	#download
	iptables -L --line-numbers | grep DROP | grep destination | cut -b 68-78 > $settDir/hasilcekdown
	cekdes=$(cat $settDir/hasilcekdown)
	if [[ $cekdes == "destination" ]]; then
		echo " Menghapus limit download"
		iptables -D FORWARD -m iprange --dst-range $ipr2 -m hashlimit --hashlimit-above $spd2+kb/s --hashlimit-mode dstip --hashlimit-name vitod -j DROP
	else
		echo " tidak ada pengaturan limit download tersimpan"
	fi


	#upload
	iptables -L --line-numbers | grep DROP | grep source | cut -b 68-73 > $settDir/hasilcekup
	ceksou=$(cat $settDir/hasilcekup)
	if [[ $ceksou == "source" ]]; then
		iptables -D FORWARD -m iprange --src-range $ipr2 -m hashlimit --hashlimit-above $spu2+kb/s --hashlimit-mode srcip --hashlimit-name vitou -j DROP
		echo " Menghapus limit upload"
	else
		echo " tidak ada pengaturan limit upload tersimpan"
	fi

	rm $settDir/hasilcekdown
	rm $settDir/hasilcekup
}

addlim() {
	#add limit bw
	echo -e "# LIMITBW-STARTVITO" >> $fwUr
	echo -e "iptables -I FORWARD -m iprange --dst-range $ipr -m hashlimit --hashlimit-above $spd+kb/s --hashlimit-mode dstip --hashlimit-name vitod -j DROP" >> $fwUr
	echo -e "iptables -I FORWARD -m iprange --src-range $ipr -m hashlimit --hashlimit-above $spu+kb/s --hashlimit-mode srcip --hashlimit-name vitou -j DROP" >> $fwUr
	echo -e "# LIMITBW-ENDVITO" >> $fwUr
	echo -e " Limit bandwidth telah berhasil dimasukkan"
}

exportdtb() {
	echo "ipr=$ipr
	spd=$spd
	spu=$spu" > $settPath
	chmod 777 $settPath
}

printset() {
	echo " Menampilkan konfigurasi saat ini ... "
	sleep 2
	iptables -L --line-numbers | grep DROP | grep destination
	iptables -L --line-numbers | grep DROP | grep source
}

startupoff() {
	echo " Menghapus pengaturan dari startup..."
	sleep 2
	if grep -q '# LIMITBW-STARTVITO' $fwUr && grep -q '# LIMITBW-ENDVITO' $fwUr && grep -q 'vitod' $fwUr && grep -q 'vitou' $fwUr; then
		echo " Pengaturan ditemukan!"
		sed -i "/^# LIMITBW-STARTVITO/,/^# LIMITBW-ENDVITO/d" $fwUr > /dev/null
		echo " Pengaturan terhapus!"
	else
		echo " Pengaturan startup tidak ditemukan."
	fi
}

flushdtb() {
	cat /dev/null>$settPath
}

case $1 in
"1")
	home;hapusset;addlim;exportdtb;printset;startupoff;exit
;;
esac

case $1 in
"2")
	printset;exit
;;
esac

case $1 in
"3")
	hapusset;startupoff;flushdtb;exit
;;
esac


#-- colors --#
#R='\e[1;31m' #RED
#G='\e[1;32m' #GREEN
#B='\e[1;34m' #BLUE
#Y='\e[1;33m' #YELLOW
#C='\e[1;36m' #CYAN
W='\e[1;37m' #WHITE
##############

#-- colors v2 --#
R='\e[31;1m' #RED
G='\e[32;1m' #GREEN
Y='\e[33;1m' #YELLOW
DB='\e[34;1m' #DARKBLUE
P='\e[35;1m' #PURPLE
LB='\e[36;1m' #LIGHTBLUE

#-- colors v3 --#
BR='\e[3;31m' #RED
BG='\e[3;32m' #GREEN
BY='\e[3;33m' #YELLOW
BDB='\e[3;34m' #DARKBLUE
BP='\e[3;35m' #PURPLE
BLB='\e[3;36m' #LIGHTBLUE

echo -e "$DB ******************************************************"
echo -e "$DB ******************************************************"
echo -e " **                                                  **"
echo -e "$DB **$R       SELAMAT DATANG DI LIMIT BANDWIDTHW         $DB**"
echo -e " **                                                  **"
echo -e "$DB ******************************************************"
echo -e "$DB **$Y         PILIH OPSI YANG SUDAH TERTERA            $DB**"
echo -e "$DB ******************************************************"
echo -e "$DB **$G        	DAFTAR :                 *PERINTAH : $DB**"
echo -e "$DB **$G ATUR LIMIT                           * limitbw 1 $DB**"
echo -e "$DB **$G LIHAT PENGATURAN TERSIMPAN           * limitbw 2 $DB**"
echo -e "$DB **$G HAPUS PENGATURAN TERSIMPAN           * limitbw 3 $DB**"
echo -e "$DB **$G KELUAR DARI MENU                     *   exit    $DB**"
echo -e "$DB ******************************************************"
echo -e "$DB **$Y             LIMIT BW  BY VITO H.S                $DB**"
echo -e "$DB **$R         https://github.com/vitoharhari           $DB**"
echo -e "$DB ******************************************************"
echo -e "$DB ******************************************************"
echo -e "$Y"

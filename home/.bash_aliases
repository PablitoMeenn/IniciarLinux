# Alias para utilizar o comandos
alias abrirsamba='sudo chmod -R 777 /tmp/samba && ip a | grep inet'
alias liberarSwap='sudo swapoff -a && sudo swapon -a'
alias MontarSeries='sudo mount -t cifs //nas-series/Series /mnt/Series -o username=meenn,password=Desdecasa12345,uid=ppavez,gid=ppavez,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm'
alias MontarNofound='sudo mount -t cifs //nas-peliculas/nofound/ /mnt/nofound -o username=nofound,password=nofoundxxx,uid=ppavez,gid=ppavez,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm

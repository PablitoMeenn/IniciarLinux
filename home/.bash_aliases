# Alias para utilizar o comandos
alias abrirsamba='sudo chmod -R 777 /tmp/samba && ip a | grep inet'
alias liberarSwap='sudo swapoff -a && sudo swapon -a'
#Montar Unidades de red
alias montar-Nofound='sudo mount -t cifs //nas-peliculas/nofound/ /mnt/nofound -o username=nofound,password=nofoundxxx,uid=meenn,gid=plex,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm'
alias montarSeries='sudo mount -t cifs //nas-series/SeriesAnime /mnt/SeriesAnime -o username=meenn,password=Desdecasa12345,uid=meenn,gid=plex,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm && sudo mount -t cifs //nas-series/Series /mnt/Series -o username=meenn,password=Desdecasa12345,uid=meenn,gid=plex,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm'
alias montarPeliculas='sudo mount -t cifs //nas-peliculas/Peliculas /mnt/Peliculas -o username=meenn,password=Desdecasa12345,uid=meenn,gid=plex,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm && sudo mount -t cifs //nas-series/PeliculasAnime /mnt/PeliculasAnime -o username=meenn,password=Desdecasa12345,uid=meenn,gid=plex,nounix,dir_mode=0770,file_mode=0770,vers=1.0,iocharset=utf8,noperm'
#Desmontar unidades de red
alias desmontarTodo='sudo umount /mnt/nofound /mnt/SeriesAnime /mnt/Series /mnt/Peliculas /mnt/PeliculasAnime'

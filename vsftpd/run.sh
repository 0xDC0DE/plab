docker run -d -v /home/p/vsftpd/data:/home/vsftpd \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e FTP_USER=reolink -e FTP_PASS=reolink4ducks \
-e PASV_ADDRESS=192.168.0.20 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
-e LOG_STDOUT=1 \
--name vsftpd --restart=always fauria/vsftpd

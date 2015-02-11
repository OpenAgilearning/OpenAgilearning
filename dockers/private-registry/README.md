# private-registry

### Reference

Follow this [slide](http://www.slideshare.net/Docker/https-dldropboxusercontentcomu20637798docker-meetup-freiburg)

the 9 page

### Usage

```{shell}
~$ docker run -d -p 5000:5000 \
 -v /opt/sqlitedb:/opt/sqlitedb \
 -v /home/agilearning/sslPlace/sslRegistry:/ssl \
 -v /home/agilearning/mnt_dev_sdb/registry:/opt/registry \
 wen777/private-registry
```

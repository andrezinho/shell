#! /bin/sh
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Script para generar backup de las base de datos de postgres, el
# backup se genera en formato de sql. 
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

#Directorio donde se va grabar el backup
BACKUP_DIR=/home/andrez/Documentos
#Numero de la cantidad maxima del mismo backup.
BACKUP_NUM=1

# Realizar Backup de las DB'S
databases=`su -l postgres -c 'psql -q -t -c "select datname from pg_database order by datname;" template1'`
for d in $databases; do
if [ ! -d $BACKUP_DIR/$d ];
then echo -n "Creando directorio de respaldo $BACKUP_DIR/$d... "
     su -l postgres -c "mkdir $BACKUP_DIR/$d" ] || continue
     echo "done."
fi
# Establecer cantidad maxima del mismo backup $BACKUP_NUM
archive=$BACKUP_DIR/$d/$d.gz
if [ -f $archive.$BACKUP_NUM ]; then
  rm -f $archive.$BACKUP_NUM;
fi
n=$(( $BACKUP_NUM - 1 ))
while [ $n -gt 0 ]; do
     if [ -f $archive.$n ]; then
       mv $archive.$n $archive.$(( $n + 1 ))
     fi
     n=$(( $n - 1 ))
done
if [ -f $archive ]; then
   mv $archive $archive.1;
fi
echo -n "Respaldando la base $d... "
su -l postgres -c "(pg_dump $d |gzip -9) > $archive"
echo "Transfiriendo archivo $archive"
#scp $archive root@$BACKUP_DIR_REMOTO
echo "Tarea Finalizada."
done

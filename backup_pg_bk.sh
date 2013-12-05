#!/bin/bash
 ######## Bash script para hacer mantenimiento y backup de bases de datos especificas ######## 
 dbcxn="-h localhost -p 5432 -U postgres";    	  # Datos de conexion 
 rtdir="/home/andrez/Documentos/backup01";        # Directorio de backups
 
 #dblst=( bd1 bd2 bd3 ); Lista de base de datos a generar backup
 dblst=( srnw );
 
 # Directorio de backup
 dirdt=`eval date +%Y%m%d`;             # Fecha para el directorio
 bkdir=$rtdir"/backup-"$dirdt;            # Direccion absoluta directorio
 if [ ! -d $bkdir ]; then
   echo "Creando directorio: "$bkdir" ";
   /bin/mkdir $bkdir
 fi
 
 # Boocle para vacum, reparacion, y backup
 dbsc=0;
 dbst=${#dblst[@]};
 while [ "$dbsc" -lt "$dbst" ]; do
   dbsp=${dblst[$dbsc]};
   dbspf=""$bkdir"/"$dbsp"";            # Prefijo (dir+nom+fecha) nombre de archivo
   echo "";
   echo "###########################################";
   echo "Procesando base de datos '"$dbsp"'";
 
   echo "  * Realizando reindexado de: '"$dbsp"'";
   ridt=`eval date +%Y%m%d_%H%M%S`;
   /usr/bin/reindexdb $dbcxn -d $dbsp -e > $dbspf"-"$ridt"-reindexdb.log" 2>&1
 
   echo "  * Realizando vacuum de: '"$dbsp"'";
   vadt=`eval date +%Y%m%d_%H%M%S`;
   /usr/bin/vacuumdb $dbcxn -f -v -d $dbsp > $dbspf"-"$vadt"-vacuumdb.log" 2>&1
 
   echo "  * Realizando copia de seguridad de: '"$dbsp"'";
   bkdt=`eval date +%Y%m%d_%H%M%S`;
   /usr/bin/pg_dump -i $dbcxn -F c -b -v -f $dbspf"-"$bkdt".backup" $dbsp > $dbspf"-"$bkdt"-backup.log" 2>&1
 
   echo "######################################################";
   echo "";
 
   dbsc=`expr $dbsc + 1`;
 done
 chmod -R 777 /home/andrez/Documentos/
 exit 0;

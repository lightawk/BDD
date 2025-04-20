# block change tracking [-oracle]

Le Block Change Tracking est une fonctionnalite Oracle qui permet d’accroitre les performances dans les sauvegardes de bases de donnees (sauvegarde incrementale level 1).

RMAN scrute tous les blocs dans les sauvegardes incrementales pour identifier les blocs modifies depuis la derniere sauvegarde effectuee grace au fichier block change tracking file.

Une fois le fichier block change tracking file "db_block_trk.chg" cree, la maintenance de ce dernier est automatique et transparent pour le DBA.

> Activer / desactiver le block change tracking.

```
ALTER DATABASE ENABLE BLOCK CHANGE TRACKING;
```

> Active le BCT et cree un fichier dans le repertoire dont le nom est mentionne dans le parametre "db_create_file_dest".

```
ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '+DATA';
ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;
```

> Deplacer le fichier block change tracking file.

```
sqlplus / as sysdba
SELECT filename FROM v$block_change_tracking;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
exit;
! mv /u01/app/oracle/oradata/db_block_trk.chg /u04/app/oracle/oradata/db_block_trk.chg
sqlplus / as sysdba
ALTER DATABASE RENAME FILE '/u01/app/oracle/oradata/db_block_trk.chg' to '/u04/app/oracle/oradata/db_block_trk.chg';
ALTER DATABASE OPEN;
SELECT filename FROM v$block_change_tracking;
exit;
```

> Script pour l'activation et la desactivation du block change tracking.

```
#!/bin/bash

#@(#)Description: Script pour l'activation, la desactivation, la verification et le changement de localisation du fichier pour le block change tracking
#@(#)Usage:       hx_bct.sh [ -i <instance> ] -a <action>
#@(#)Author:      AHA
#@(#)Date:        10/05/2023
#@(#)Revision:    1.0

## ===============================================================================================================
##
## Librairies & parametres
##
## ===============================================================================================================

set -o pipefail

declare -r DBA_SCRIPTS=${DBA_SCRIPTS:-/app/exploit/dba_scripts}

# Chargement de la bibliotheque commune
[[ -f ${DBA_SCRIPTS}/lib/hx_common.ish ]] || { echo "Bibliotheque commune inexistante" ; exit 1 ; }
[[ -r ${DBA_SCRIPTS}/lib/hx_common.ish ]] || { echo "Bibliotheque commune inaccessible en lecture" ; exit 1 ; }
. ${DBA_SCRIPTS}/lib/hx_common.ish 2>&1 || { echo "Echec du chargement de la bibliotheque commune" ; exit 1 ; }

# Par defaut se positionner sur le conteneur
unset ORACLE_PDB_SID

## ===============================================================================================================
##
## Fonctions locales
##
## ===============================================================================================================

# ========================================
# @fn _f_status_bct
# @brief Affiche le statut du block change tracking
# ========================================
function _f_status_bct {

   local vf_status

   ## On recupere le statut
   vf_status=$(ORACLE_PDB_SID= __lance_sql "SELECT status FROM v\$block_change_tracking;" "PAGES_0" 2>&1)
   (( $? == 0 )) || { echo -e "[ ${FUNCNAME[0]} ] Echec SQL :\n${vf_status}"; return 2; }

   ## Code retour en fonction du statut (0 ENABLED, 1 DISABLED, 3 TRANSITION)
   case "${vf_status}" in
       "ENABLED") ORACLE_PDB_SID= __lance_sql "SELECT filename FROM v\$block_change_tracking;" "SILENT" ; return 0 ;;
      "DISABLED") return 1 ;;
    "TRANSITION") return 3 ;;
               *) echo -e "[ ${FUNCNAME[0]} ] Echec SQL :\n${vf_status}"
                  return 2 ;;
   esac

}

# ========================================
# @fn _f_enable_bct
# @brief Active le block change tracking
# ========================================
function _f_enable_bct {

   local vf_bct_fichier="${1}"

   _f_status_bct

   case "$?" in
     0) echo "Le block change tracking est deja active" ; return 1 ;;
     1) ORACLE_PDB_SID= __lance_sql "ALTER DATABASE ENABLE BLOCK CHANGE TRACKING USING FILE '${vf_bct_fichier}' REUSE;" "SILENT" ;;
     2) return 2 ;;
     3) echo "Le block change tracking est dans un etat transitoire" ; return 3 ;;
   esac

}

# ========================================
# @fn _f_disable_bct
# @brief Desactive le block change tracking
# ========================================
function _f_disable_bct {

   _f_status_bct

   case "$?" in
     0) ORACLE_PDB_SID= __lance_sql "ALTER DATABASE DISABLE BLOCK CHANGE TRACKING;" "SILENT" ;;
     1) echo "Le block change tracking est deja desactive" ; return 1 ;;
     2) return 2 ;;
     3) echo "Le block change tracking est dans un etat transitoire" ; return 3 ;;
   esac

}

# ========================================
# @fn _f_afficher_usage
# @brief Affiche l'usage du script
# ========================================
function _f_afficher_usage {

        cat <<-EOT >&2
                Usage : $(basename ${0}) [ -i <instance> ] -a <action>
                      -i : instance
                      -a : action [ enable|disable|check ]
                           enable  => activer le block change tracking
                           disable => desactiver le block change tracking
                           check   => verifier le block change tracking
                      -f : nouveau chemin du fichier pour le block change tracking (uniquement pour l'option "change")
                ex: $(basename ${0}) -a check
        EOT

}

## ===============================================================================================================
##
## Initialisation des variables locales et des arguments
##
## ===============================================================================================================

declare instance="${ORACLE_SID}"
declare action

declare bct_repertoire
declare bct_fichier

(( $# < 2 )) && { _f_afficher_usage ; exit 1 ; }

while getopts ":i:a:f:" OPTION; do
        case "${OPTION}" in
            i)    instance="${OPTARG}"
                  export ORACLE_SID=${instance}
                  ;;
            a)    action="${OPTARG}"
                  ;;
            *)    __message "Option -${OPTARG} inconnue"
                  _f_afficher_usage
                  exit 1
                  ;;
        esac
done

# Controle de l'instance
[[ "${instance}" =~ ^[A-Za-z0-9][A-Za-z0-9_#$]{0,7}$ ]] || { __message "Format d'instance incorrect." ; _f_afficher_usage ; exit 1 ; }

# Controle de l'action
[[ "${action}" =~ ^enable|disable|check$ ]] || {
  __message "L'action doit etre egale a l'une des valeurs suivantes : enable|disable|check" ; _f_afficher_usage ; exit 1 ;
}

# Chargement ORADATA
. ${DBA_SCRIPTS}/lib/hx_oradata.cfg 2>&1 || { echo "Echec du chargement pour ORADATA" ; exit 1 ; }

# Renommage de la log du script
LOGFILE="${DIR_LOG}/$(basename ${0%.*})_${instance}_${action}_$(date +'%d%m%y')_$(date +'%H%M%S').log"

# Alimentation des variables
bct_repertoire="${ORADATA}/u07/oradata/${instance}/bct"
bct_fichier="${bct_repertoire}/${instance}_01.bct"

## ===============================================================================================================
##
## Bloc principal
##
## ===============================================================================================================

__debut

    # ============================== Verifications prealables ============================== #

    # Creation du repertoire si inexistant
    if [[ ! -d "${bct_repertoire}" ]]; then
      mkdir -p ${bct_repertoire} \
        && __tracer_message "Creation du repertoire ${bct_repertoire} effectue avec succes" \
        || __tracer_erreur "Creation du repertoire ${bct_repertoire} en echec"
    fi

    # ============================== Execution du traitement en fonction de l'action ============================== #

    case "${action}" in

        enable)

          _f_enable_bct "${bct_fichier}" | __tracer_message

          (( $? == 0 )) \
            && __tracer_succes "Activation du block change tracking effectuee avec succes" \
            || __tracer_erreur "Activation du block change tracking en echec"

        ;;

        disable)

          _f_disable_bct | __tracer_message

          (( $? == 0 )) \
            && __tracer_succes "Desactivation du block change tracking effectuee avec succes" \
            || __tracer_erreur "Desactivation du block change tracking en echec"

        ;;

        check)

          _f_status_bct | __tracer_message

          case "$?" in
            0) __tracer_message "Le block change tracking est [ ACTIVE ]" ;;
            1) __tracer_message "Le block change tracking est [ DESACTIVE ]" ;;
            2) __tracer_erreur  "Echec lors de la recuperation du statut" ;;
            3) __tracer_message "Le block change tracking est [ EN COURS D'ACTIVATION ] ou [ EN COURS DESACTIVATION ]" ;;
          esac

        ;;

        change)

        ;;

    esac

__fin
```
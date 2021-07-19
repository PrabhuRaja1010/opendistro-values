#! /bin/bash
read -p "Enter your secret Name:" secret
PODS=$(kubectl get po | awk '{if (NR!=1) print $1}')
for each in ${PODS}
do  
  sec=$(kubectl get  po $each  -o yaml  | grep secretName | awk {'print $2'})
  for sc in ${sec}
  do
      if [[ $secret = $sc ]]
      then
      kubectl delete po ${each}
      fi 
  done
done

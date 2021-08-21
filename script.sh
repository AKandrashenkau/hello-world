#!/bin/bash
stdin() {
   local n=0
   for word in ${stdout[0]}; do
      stdout[++n]=$word
   done
   for (( i=0; i<n; i++ )); do
      case $i in
         0) stdout[i]=""
            continue ;;
         *) stdout[0]+=${stdout[i]}
            continue ;;
      esac
   done
   for (( i=0; i<${#stdout[0]}; i++ )); do
      case $i in
         0) continue ;;
         1) stdout[i]=${stdout[$(expr ${#stdout[@]} - 1)]}
            continue ;;
         *) stdout[i]=""
            continue ;;
      esac
   done
}
chain() {
   if [[ $2 -ge $(expr $4 + $3) ]]; then
      ((XY[1]++))
      ((XY[0]+=$3))
      chain $1 $2 $3 ${XY[0]} ${XY[1]}
   else
      if [[ $1 -eq $(expr ${#tmp1} - 1) ]]; then
         echo "[$5,$(expr $2 - $4)]"
      else
         echo "[$5,$(expr $2 - $4)]->"
      fi
      return
   fi
}
keyword() {
   local tmp=$1
   readonly local tmp1=$2
   for (( i=0, XY[0]=0, XY[1]=0; i < ${#tmp1}; i++ )); do
      for (( j=0; j < ${#tmp}; XY[0]=0, XY[1]=0, j++ )); do
         if [[ ${tmp1:($i):(1)} == ${tmp:($j):(1)} ]]; then
            tmp=${tmp/${tmp:($j):(1)}/ }
            if [ $j -gt 9 ]; then
               stdout[2]+=$(chain $i $j $3 ${XY[0]} ${XY[1]})
            else
               stdout[2]+=$(chain $i $j $3 ${XY[0]} ${XY[1]})
            fi
            break
         fi
      done
   done
   echo ${stdout[2]}
}
subfunc() {
   case $(($(expr $2 + 1) < $3)) in
      1) case $(($2 == 0 && $1 != 0)) in
            1) printf " '${tmp:($(expr $(expr $1 * $3) + $2)):(1)}'," ;;
            *) printf "'${tmp:($(expr $(expr $1 * $3) + $2)):(1)}'," ;;
         esac
         return ;;
      *) printf "'${tmp:($(expr $(expr $1 * $3) + $2)):(1)}',\n"
         return ;;
   esac
}
word() {
   readonly local tmp=$1
   for (( i=0; i < $3; i++ )); do
      for (( j=0; j < $2; j++ )); do
         case $(($i == 0 && $j == 0)) in
            1) printf "['${tmp:(0):(1)}',"
               continue ;;
            *) case $i in
                  0) case $(($j == $(expr ${#tmp[0]} - 1))) in
                        1) printf "'${tmp:($(expr $(expr $3 * $2) - 1)):(1)}']\n"
                           break ;;
                        *) subfunc $i $j $2 $1
                           continue ;;
                     esac
                     continue ;;
                  *) case $(($(expr $(expr $i + 1) * $(expr $j + 1)) == ${#tmp[0]})) in
                        1) printf "'${tmp:($(expr $(expr $((++i)) * $((++j))) - 1)):(1)}']\n"
                           break ;;
                        *) subfunc $i $j $2 $1
                           continue ;;
                     esac
                     continue ;;
               esac
               continue ;;
         esac
      done
   done
}
compose() {
   readonly local x=$3
   readonly local tmpArrSqrt=$(echo "sqrt($x)" | bc)
   readonly local limitN=$(expr $x / 2)
   local isPrime=1
   for (( i=2; i < $limitN; i++ )); do
      case $(expr $x % $i) in
         0) isPrime=0
            break ;;
      esac
   done
   case $isPrime in
      0) case $(expr $x % 2) in
            0) case $(($(expr $tmpArrSqrt * $tmpArrSqrt) == $x)) in
                  0) readonly local fKeyword=$(keyword $1 $2 $limitN)
                     readonly local fWord=$(word $1 $limitN $tmpArrSqrt)
                     printf "$fKeyword\n$fWord" ;;
                  *) readonly local fKeyword=$(keyword $1 $2 $tmpArrSqrt)
                     readonly local fWord=$(word $1 $tmpArrSqrt $tmpArrSqrt)
                     printf "$fKeyword\n$fWord" ;;
               esac ;;
            *) readonly local tmpMOddPart=$(expr $x / $tmpArrSqrt)
               readonly local fKeyword=$(keyword $1 $2 $tmpMOddPart)
               readonly local fWord=$(word $1 $tmpMOddPart $tmpArrSqrt)
               printf "$fKeyword\n$fWord" ;;
         esac ;;
      *) readonly local fKeyword=$(keyword $1 $2 $x)
         readonly local fWord=$(word $1 $x 1)
         printf "$fKeyword\n$fWord" ;;
   esac
}
declare -a stdout=$@
stdin
stdout[3]=$(compose ${stdout[0]} ${stdout[1]} ${#stdout[0]})
printf "${stdout[3]}\n"
exit $?

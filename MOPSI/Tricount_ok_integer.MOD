/* Données connues du problème auxquelles on fait référence dans la partie Data */

set Name_Users;
param Amount{Name_Users}; /* Montants avancés par chaque personne */
table tab_Amount IN "CSV" "Data_ok.csv" : 
  Name_Users <- [NAME], Amount ~ VALUE;
param Mean := (1/card(Name_Users))*sum{k in Name_Users}(Amount[k]); /* Combien chacun a payé */
param Sum_Amount := sum{k in Name_Users}(Amount[k]);

/* Introduction des paramètres et des variables */

var Exchanges{Name_Users, Name_Users}, binary; /* Matrice indiquant s'il y a eu un échange entre l'individu i et j */
var Flow{Name_Users, Name_Users} >= 0;  /* Matrice indiquant combien l'individu i doit à l'individu j */
/*var Flow_integer{Name_Users, Name_Users} >= 0 integer; */
var Penalisation {Name_Users, Name_Users}, integer; 

/* Corps du problème d'optimisation */

minimize Nb_exchanges : sum{i in Name_Users, j in Name_Users}(Exchanges[i, j] + (0.2+100*(Penalisation[i, j]-Flow[i, j]))); /* Minimisation du nombre de transactions */ /* J'ai mis des coeff au pif c'est peut etre pas bon le 100 et 0.2 */
s.t. Transaction_integer{k in Name_Users, l in Name_Users} : Exchanges[k, l] >= Flow[k, l]/ (1 + Sum_Amount); /* Il y a transaction si le flow entre i et j est posistif */
s.t. Equilibrium_integer{m in Name_Users} : Amount[m]-Mean = sum{n in Name_Users}(Flow[m, n] - Flow[n, m]); /* L'équilibre budgetaire doit etre respecté */
s.t. Min_Amount_Exchange_integer{i in Name_Users, j in Name_Users} : if Amount[j] >= Mean then Exchanges[i, j] = 0;
s.t. Calcul_penalisation{i in Name_Users, j in Name_Users} : Penalisation[i, j]  >= Flow[i, j]; /* Ici tu peux pas mettre de if ni de floor, donc tu fais autrement */

solve;

/* Visualisation des résultats */

printf "Le nombre total de transaction(s) est de : %i\n", Nb_exchanges >> "Results.csv";
printf "Le montant total que chacun a fourni : %g\n", Mean >> "Results.csv";
printf "\n" >> "Results.csv";
printf {i in Name_Users, j in Name_Users: Flow[i, j]!=0} "%s doit %g à %s \n", j, Flow[i, j], i >> "Results.csv"; /* On affiche uniquement les transactions non nulles entre personnes */

end;

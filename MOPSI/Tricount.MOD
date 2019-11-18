/* Données connues du problème auxquelles on fait référence dans la partie Data */

set Name_Users;
param Amount{Name_Users}; /* Montants avancés par chaque personne */
table tab_Amount IN "CSV" "./Data.csv" : 
  Name_Users <- [NAME], Amount ~ VALUE;
param Mean := (1/card(Name_Users))*sum{k in Name_Users}(Amount[k]); /* Combien chacun a payé */
param Sum_Amount := sum{k in Name_Users}(Amount[k]);

/* Introduction des paramètres et des variables */

var Exchanges{Name_Users, Name_Users}, binary; /* Matrice indiquant s'il y a eu un échange entre l'individu i et j */
var Flow{Name_Users, Name_Users} >= 0;  /* Matrice indiquant combien l'individu i doit à l'individu j */

/* Corps du problème d'optimisation */

minimize Nb_exchanges : sum{i in Name_Users, j in Name_Users}(Exchanges[i, j]); /* Minimisation du nombre de transactions */

s.t. Transaction{k in Name_Users, l in Name_Users} : Exchanges[k, l] >= Flow[k, l]/ (1 + Sum_Amount); /* Il y a transaction si le flow entre i et j est posistif */
s.t. Equilibrium{m in Name_Users} : Amount[m]-Mean = sum{n in Name_Users}(Flow[m, n] - Flow[n, m]); /* L'équilibre budgetaire doit etre respecté */
s.t. Min_Amount_Exchange{i in Name_Users, j in Name_Users} : if Amount[j] >= Mean then Exchanges[i, j] = 0; 
s.t. Above_mean {i in Name_Users, j in Name_Users} : if (Amount[i] - Mean)*(Amount[j] - Mean) >=0 then Exchanges[i, j] = 0; /* On empeche les transferts d'argents entre utilisateurs étant soit tous les deux au dessus de la moyenne soit en dessous de la moyenne */

solve;

/* Visualisation des résultats */

printf "Le nombre total de transaction(s) est de : %i\n", Nb_exchanges >> "./Results.csv";
printf "Le montant total que chacun a fourni : %g\n", Mean >> "./Results.csv";
printf "\n" >> "./Results.csv";
printf {i in Name_Users, j in Name_Users: Flow[i, j]!=0} "%s doit %g à %s \n", j, Flow[i, j], i >> "./Results.csv"; /* On affiche uniquement les transactions non nulles entre personnes */

end;

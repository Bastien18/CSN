
\center

# Manipulation 5: Servo-moteur commandé par PWM

\hfill\break

\hfill\break

Département: **TIC**

Unité d'enseignement: **CSN**


\hfill\break

\hfill\break

\hfill\break

\hfill\break

\hfill\break

\hfill\break

\hfill\break

\hfill\break

\hfill\break

\raggedright

Auteur(s):

- **PILLONEL Bastien**

- **BOUGNON-PEIGNE Kévin**

Professeur:

- **MESSERLI Etienne**

Assistant:

- **JACCARD Anthony**

Date:

- 2023 

\pagebreak

# Introduction

Le but de ce laboratoire est de réaliser un système qui pilote un servo-moteur, sur commande par PWM (Pulse Width Modulation).

## Objectif

L’objectif de ce laboratoire est de concevoir, développer, simuler et tester un contrôleur de servo-moteur, sous la forme d’un système séquentiel simple.

Le système utilise le principe d’un PWM ("Pulse Width Modulation" ou "modulation à largeur d’impulsion") qui permet de transmettre une information analogique via un signal binaire. Ce signal PWM est responsable de la transmission de la consigne de position au servo.

Le laboratoire est décomposé en deux parties. Dans la première partie il s’agit de générer un signal PWM à l’aide d’un compteur en "dent de scie" et d’une comparaison (plus d’explications dans la section "Partie 1"). Dans la deuxième partie il s’agit de gérer la position courante du servo selon le mode de fonctionnement et l’état des signaux de commande (voir la section "Partie 2").

## Spécification

# Analyse

## Première partie: Gestion de la création du PWM

## Deuxième partie: Gestion de la position

Blablabla...

Voici la table de fonctions synchrones:

| center_i | mode_i | up_i | down_i | reg_pres | reg_fut | Commentaires |
| :----: | :----: | :--: | :------: | :------: | :------ | :----------- |
| / | / | / | / | <999 ou >1999 | =1499 | Chargement pos. centrale si hors limite |
| 1 | / | / | / | / | =1499 | Chargement pos. centrale |
| / | 1 | / | / | =1999 | =999 | Rebouclement |
| / | 1 | / | / | autres | =reg_pres + 1 | Incrément (mode auto.) |
| / | / | 1 | / | =1999 | =reg_pres | Maintien |
| / | / | 1 | / | autres | =reg_pres + 1 | Incrément (mode man.) |
| / | / | / | 1 | =999 | =reg_pres | Maintien |
| / | / | / | 1 | autres | =reg_pres - 1 | Soustraction |

Un premier regroupement peut être effectuer, on obtient alors la table suivante:

| center_i | mode_i | up_i | down_i | reg_pres | reg_fut | Commentaires |
| :----: | :----: | :--: | :------: | :------: | :------ | :----------- |
| / | / | / | / | <999 ou >1999 | =1499 | Chargement pos. centrale si hors limite |
| 1 | / | / | / | / | =1499 | Chargement pos. centrale |
| / | 1 | / | / | =1999 | =999 | Rebouclement |
| / | / | 1 | / | =1999 | =reg_pres | Maintien |
| / | / | / | 1 | =999 | =reg_pres | Maintien |
| / | / | / | 1 | autres | =reg_pres - 1 | Soustraction |
| / | / | / | / | autres | =reg_pres + 1 | Incrément |

L'addition et la soustraction peuvent être effectuer par le même bloc additionneur (pour une soustraction, on met le report d'entrée à '1' et on inverse le second nombre d'entrée).

On peut donc coupler ces états et terminer avec la table suivante:

| center_i | mode_i | up_i | down_i | reg_pres | reg_fut | Commentaires |
| :----: | :----: | :--: | :------: | :------: | :------ | :----------- |
| / | / | / | / | <999 ou >1999 | =1499 | Chargement pos. centrale si hors limite |
| 1 | / | / | / | / | =1499 | Chargement pos. centrale |
| / | 1 | / | / | =1999 | =999 | Rebouclement |
| / | / | 1 | / | =1999 | =reg_pres | Maintien |
| / | / | / | 1 | =999 | =reg_pres | Maintien |
| / | / | / | / | autres | =reg_pres "opération" 1 | Incrément/Soustraction |

# Réalisation et implantation

# Simulation

# Conclusion

\raggedleft

Date: Date de rendu

- **PILLONEL Bastien**

- **BOUGNON-PEIGNE Kévin**

\raggedright

\pagebreak

# Annexes ...


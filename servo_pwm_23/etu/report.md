
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

Le but de ce laboratoire est de réaliser un système qui pilote un servo-moteur (abrégé *servo* pour le reste du rapport), sur commande par PWM (Pulse Width Modulation).

## Objectif

Les objectifs sont de concevoir, développer, simuler et tester un contrôleur de servo-moteur, sous la forme d’un système séquentiel simple.

Le système utilise le principe d’un PWM ("Pulse Width Modulation" ou "modulation à largeur d’impulsion") qui permet de transmettre une information analogique via un signal binaire. Ce signal PWM est responsable de la transmission de la consigne de position au servo.

Le laboratoire est décomposé en deux parties. Dans la première partie il s’agit de générer un signal PWM à l’aide d’un compteur en "dent de scie" et d’une comparaison (plus d’explications dans la section "Première partie: Création du PWM"). Dans la deuxième partie il s’agit de gérer la position courante du servo, selon le mode de fonctionnement et l’état des signaux de commande (voir la section "Deuxième partie: Gestion de la position").

## Spécification

### PWM: Pulse Width Modulation

Un PWM est un signal carré de période fixe, à rapport cyclique changeant. Pour réaliser ce genre de signal, l'on se base sur un signal triangulaire (ou en dent de scie, dans le cas présent) et on le compare avec un signal de contrôle.

Voici une démonstration:

![pwm_behavior](pics/pwm_behavior.png)

### Comportement du servo

Dans le cadre de ce laboratoire, le PWM du servo fonctionne selon ces informations:

\center

![servo_behavior_lab_sheet](pics/servo_behavior_from_lab_sheet.png){ width=70% }

\raggedright

\pagebreak

# Analyse

## Première partie: Gestion de la création du PWM

Soit le bloc de cette partie représentée par:

\center

![schema_bloc_part_pwm](pics/pwm_schem_bloc.png){ width=70% }

\raggedright

Pour générer un PWM, voici les fonctions nécessaires:

- asynchrone: Reset

- synchrone&nbsp;: Un compteur de la période du PWM

- synchrone&nbsp;: Un élément mémoire pour le compteur précédent

- synchrone&nbsp;: Un rebouclement de ce compteur (chargement à 0)

- synchrone&nbsp;: Un comparateur entre le compteur de la période du PWM et le seuil d'entrée, pour fixer la sortie pwm_o, soit à '1', soit à '0'.

<!--Contrairement à ce qu'il sera vu pour la gestion de position ... Je sais plus ce que je voulais dire iciiiiiii ...-->

Selon cette liste, on voit que la table de fonctions synchrones ne peut faire intervenir que les éléments liés au comtpeur. Car l'entrée **seuil_i** et la sortie **pwm.o** sont régies par la règle:

```python
pwm_o = '1' if cpt_period <= seul_i else '0'
```

qui permet de générer le PWM.

On obtient alors le décodeur d'états futurs du compteur:

| top_1MHz_i | cpt_period | cpt_fut_period | Commentaires |
| :--------: | ---------: | :------------- | :----------- |
| 0 | - | =cpt_period | =Maintien des valeurs |
| 1 | =19999 | =0 | Rebouclement de la période |
| 1 | / | =cpt_period+1 | Incrémentation du compteur |

## Deuxième partie: Gestion de la position

Blablabla...

\center

![schema_bloc_part_pwm](pics/pos_schem_bloc.png){ width=70% }

\raggedright

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

# Intégration/Mesure

## Angle maximale

![meas_t_up_2.0ms](pics/meas_Tup_2.0ms.jpg)

![meas_period_2.0ms](pics/meas_period_2.0ms.jpg)

## Angle milieu

![meas_t_up_1.5ms](pics/meas_Tup_1.5ms.jpg)

![meas_period_1.5ms](pics/meas_period_1.5ms.jpg)

## Angle minimale

![meas_t_up_1.0ms](pics/meas_Tup_1.0ms.jpg)

![meas_period_1.0ms](pics/meas_period_1.0ms.jpg)

# Conclusion

\raggedleft

Date: Date de rendu

- **PILLONEL Bastien**

- **BOUGNON-PEIGNE Kévin**

\raggedright

\pagebreak

# Annexes ...


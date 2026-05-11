# Cycle de l'Hydrogène : Simulation P2G & G2P 🔋💧

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![MATLAB](https://img.shields.io/badge/Software-MATLAB%20Online-orange.svg)](https://matlab.mathworks.com/)
[![Project-SI](https://img.shields.io/badge/Niveau-Terminale%20SI-green.svg)]()

## 📝 Présentation du Projet
Ce projet, réalisé dans le cadre des **Sciences de l'Ingénieur en classe de Terminale**, vise à simuler le comportement d'une chaîne énergétique à hydrogène utilisant le matériel pédagogique **Horizon Educational**. 

L'objectif est de modéliser les deux phases critiques du cycle :
1.  **Power-to-Gas (P2G)** : Transformation de l'énergie électrique en hydrogène via un électrolyseur PEM.
2.  **Gas-to-Power (G2P)** : Reconversion de l'hydrogène stocké en électricité via une pile à combustible PEM pour alimenter une charge (ex: moteur du kit Auto Horizon).

## 🚀 Fonctionnalités
*   **Interface Interactive (UI)** : Sliders réactifs en temps réel pour modifier les paramètres physiques.
*   **Physique Calibrée** : Basée sur les constantes de Faraday et les spécifications techniques des piles Horizon.
*   **Suivi Télémétrique** : Affichage instantané du courant (A), de la puissance (W), des débits de gaz (ml/min) et de l'efficacité ($\eta$).
*   **Graphiques Dynamiques** : Tracé permanent des données sans effacement pour analyse de performance sur la durée.

## ⚙️ Modélisation Physique
Le projet s'appuie sur plusieurs principes fondamentaux du programme de SI :
*   **Loi de Faraday** : Calcul de la production/consommation de dihydrogène ($H_2$) et dioxygène ($O_2$).
*   **Thermodynamique** : Calcul du rendement ($\eta$) basé sur la tension de charge par rapport au potentiel thermodynamique théorique ($1.23V$).
*   **Loi d'Ohm généralisée** : Modélisation des pertes internes et de la résistance de membrane.



## 🛠️ Installation et Utilisation
1.  Ouvrez **MATLAB Online** ou **MATLAB Desktop**.
2.  Téléchargez les fichiers `.m` de ce dépôt.
3.  Lancez le script souhaité :
    *   `G2P_Horizon_Gauges.m` : Simulation de la pile à combustible (Consommation de gaz).
    *   `P2G_Monitor.m` : Simulation de l'électrolyseur (Production de gaz).
4.  Manipulez les curseurs pour observer l'influence de la tension et du débit d'eau sur le rendement.

## 📊 Caractéristiques Techniques (Horizon Set)
| Paramètre | Valeur Simulation | Unité |
| :--- | :--- | :--- |
| Débit H2 max | 500 | ml/min |
| Tension de charge | 0.1 - 1.2 | V |
| Rendement Type | 40% - 60% | $\eta$ |
| Sortie Eau | ml/min | liquide |

## 📜 Licence
Ce projet est sous licence **GPL 3.0**. Vous êtes libre de copier, modifier et distribuer ce logiciel, à condition que les sources restent ouvertes et sous la même licence. Voir le fichier `LICENSE` pour plus de détails.

---
*Projet réalisé pour l'épreuve de spécialité Sciences de l'Ingénieur - 2026*

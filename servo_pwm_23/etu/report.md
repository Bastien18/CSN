
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

| center_i | mode_i | up_i | down_i | reg_pres | reg_fut | Commentaires |
| :----: | :----: | :--: | :------: | :------: | :------ | :----------- |
| / | / | / | / | <999 ou >1999 | =1499 | Chargement pos. centrale si hors limite |
| 1 | / | / | / | / | =1499 | Chargement pos. centrale |
| / | 1 | / | / | =1999 | =999 | Rebouclement |
| / | / | 1 | / | =1999 | =reg_pres | Maintien |
| / | / | / | 1 | =999 | =reg_pres | Maintien |
| / | / | / | 1 | autres | =reg_pres - 1 | Soustraction |
| / | / | / | / | autres | =reg_pres + 1 | Incrément |


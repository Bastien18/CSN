
| center_i | mode_i | up_i | down_i | reg_pres | reg_fut | Commentaires |
| :----: | :----: | :--: | :------: | :------: | :------ | :----------- |
| / | / | / | / | <999 ou >1999 | =1499 | Chargement pos. centrale si hors limite |
| 1 | / | / | / | / | =1499 | Chargement pos. centrale |
| / | 1 | / | / | =1999 | =999 | Rebouclement |
| / | 1 | / | / | >=999 et <1999 | =reg_pres + 1 | Incrément (mode auto.) |
| / | / | 1 | / | =1999 | =reg_pres | Maintien |
| / | / | 1 | / | >=999 et <1999 | =reg_pres + 1 | Incrément (mode man.) |
| / | / | / | 1 | 999 | =reg_pres | Maintien |
| / | / | / | 1 | <=1999 et >999 | =reg_pres - 1 | |

| mode_i | down_i | up_i | center_i | reg_pres | reg_fut | Commentaires |
| :----: | :----: | :--: | :------: | :------: | :------ | :----------- |
| '-' | '-' | '-' | 1 | '-' | =1499 | Fixation pos. centrale |
| '-' | '-' | '-' | '-' | < 999 ou > 1999 | =1499 | Pos. centrale si hors limite |
| '-' | '-' | '-' | 0 | [999, 1998] | =reg_pres + 1 | |
| 1 | '-' | '-' | 0 | 1999 | =999 | |
| 0 | '-' | 1 | 0 | 1999 | =1999 | |
| 0 | 1 | 0 | 0 | [1999, 1000] | =reg_pres - 1 | |
| 0 | 1 | 0 | 0 | 999 | =999 | |

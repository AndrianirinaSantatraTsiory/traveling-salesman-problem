import '../model/arbre.dart';
import '../model/arc.dart';

class Traitement {
  bool possible = true;
  List<Arc> arcs = [];
  List<List<Arc>> arcs_result = [];
  List<List<List<List<int>>>> etapes = [];
  List<List<List<int>>> etape = [];
  List<Arc> regret_max_per_step = [];
  List<List<List<int>>> val_sous_per_step = [];
  Noeud noeud = Noeud();
  List<List<List<String>>> sommets = [];
  List<Map<String, dynamic>> list_parasite = [];
  List<String> copieVect(List<String> vect) {
    List<String> vect_tmp = [];
    for (int i = 0; i < vect.length; i++) {
      vect_tmp.add(vect[i]);
    }
    return vect_tmp;
  }

  //Traitement
  void littleAlgorithm(List<List<int>> data) {
    List<List<Arc>> arcs_tab = [];
    List<Noeud> noeuds_tab = [];
    List<List<List<int>>> data_tab = [];
    List<List<List<List<int>>>> etape_tab = [];
    bool reprendre = false;
    /*data = [
      [-1, 18, 9, 14, 10, 13],
      [17, -1, 13, 9, 8, 15],
      [18, 15, -1, 18, 9, 16],
      [11, 9, 11, -1, 16, 14],
      [9, 15, 17, 7, -1, 13],
      [14, 19, 12, 10, 13, -1]
    ];*/
    data = [
      [-1, -1, -1, 8, -1, -1, 7, 5],
      [8, -1, 9, 4, -1, -1, -1, -1],
      [-1, 3, -1, -1, 3, 7, -1, -1],
      [-1, 3, 7, -1, 9, -1, -1, -1],
      [-1, -1, 3, -1, -1, -1, -1, 4],
      [4, -1, -1, 6, 4, -1, 5, -1],
      [-1, -1, 6, -1, -1, 2, -1, -1],
      [-1, 4, -1, -1, -1, -1, 3, -1]
    ];
    int minimum = -1;
    int cur_ind = 0;
    data_tab.add(copieList(data));
    arcs_tab.add([]);
    noeuds_tab.add(noeud);
    arcs = [];
    Noeud cur_noeud;
    etape_tab.add([]);

    print("matrice initiale");
    afficheMatrice(data_tab[cur_ind]);
    etape.add(copieList(data_tab[cur_ind])); //ito aloha le initiale
    noeud.val += minLigne(data_tab[cur_ind]);
    print("après minimum par ligne");
    afficheMatrice(data_tab[cur_ind]);
    noeud.val += minColonne(data_tab[cur_ind]);
    print("après minimum par colonne");
    afficheMatrice(data_tab[cur_ind]);

    cur_noeud = noeud;
    print("après minimum par ligne et minimum par colonne");
    afficheMatrice(data_tab[cur_ind]);
    etape.add(copieList(data_tab[cur_ind])); //min ligne et colonne
    int ind_diff = 1;
    while (cur_ind < data_tab.length && !arreter(data_tab[cur_ind])) {
      if (reprendre && cur_ind > 0) {
        print("mireprendre");
        //print(etape_tab[cur_ind][0].length);
        etape.addAll(etape_tab[cur_ind]);
        print(etape.length);
        reprendre = false;
      }
      if (!possibilityOfSolution(netoyerMatrice(data_tab[cur_ind]))) {
        //possible = false;
        //return;
      }
      Noeud noeud_gauche_tmp = Noeud();
      Noeud noeud_droite_tmp = Noeud();
      noeud_gauche_tmp.isGauche = true;
      noeud_gauche_tmp.indice = ind_diff++;
      noeud_droite_tmp.indice = ind_diff++;
      int regretMax = coutType1(data_tab[cur_ind]);
      print("Matrice regret");
      afficheMatrice(regret(data_tab[cur_ind]));
      if (regretMax != -1) {
        print("Regret maximal: $regretMax");
        noeud_gauche_tmp.val = cur_noeud.val + regretMax;
      } else {
        print("Regret gauche infini");
        noeud_gauche_tmp.val = -1;
      }
      List<List<int>> reg = regret(data_tab[cur_ind]);
      etape.add(copieList(reg)); //ajouter le regret
      Arc arc = regretPlusFort(reg);
      arc.value = data[arc.i][arc.j];

      Map<String, dynamic> map_tmp = {};
      map_tmp["new_arc"] = arc;

      regret_max_per_step.add(Arc(arc.i, arc.j));
      print("arc fort ${arc.i}->${arc.j}");
      noeud_gauche_tmp.arc = arc;
      noeud_droite_tmp.arc = arc;
      List<List<int>> data_tmp = copieList(data_tab[cur_ind]);
      supprimeLigneColonne(arc, data_tmp);
      print(
          "Apres suppression de ligne et de colonne de l'arc fort on utilise un data temporaire");
      afficheMatrice(data_tmp);

      map_tmp["list_arcs"] = copieListArc(arcs_tab[cur_ind]);

      if (nbZeroMatrice(data_tmp) > 1) {
        print("Arcs présent:");
        for (Arc arc in arcs_tab[cur_ind]) {
          print("${arc.i}->${arc.j}");
        }
        //bloquer arc parasite
        if (arcs_tab[cur_ind].length != 0) {
          data_tmp[descendent(arc, arcs_tab[cur_ind]).j]
              [ancetre(arc, arcs_tab[cur_ind]).i] = -2;

          map_tmp["arc_parasite"] = Arc(descendent(arc, arcs_tab[cur_ind]).j,
              ancetre(arc, arcs_tab[cur_ind]).i);

          print(
              "Arc parasite ${descendent(arc, arcs_tab[cur_ind]).j}->${ancetre(arc, arcs_tab[cur_ind]).i}");
        } else {
          data_tmp[arc.j][arc.i] = -2;

          map_tmp["arc_parasite"] = Arc(arc.j, arc.i);

          print("Arc parasite ${arc.j}->${arc.i}");
        }

        print("Apres blockage de l'arc parasite");
        afficheMatrice(data_tmp);
      }
      list_parasite.add(map_tmp);
      noeud_droite_tmp.val =
          cur_noeud.val + minLigne(data_tmp) + minColonne(data_tmp);
      cur_noeud.gauche = noeud_gauche_tmp;
      cur_noeud.droite = noeud_droite_tmp;
      print(
          "Noeud gauche:${noeud_gauche_tmp.val} et Noeud droite:${noeud_droite_tmp.val}");
      if (noeud_gauche_tmp.val == -1 ||
          noeud_gauche_tmp.val > noeud_droite_tmp.val) {
        //Normal
        print("traitement normal et prendre en compte ${arc.i}->${arc.j}");
        etapes.add(etape); //ajout de l'etape
        data_tab[cur_ind] = List<List<int>>.from(data_tmp);
        etape = []; //reinitialiser l'étape
        etape.add(copieList(data_tab[cur_ind])); //intiale vaovao
        etape.add(copieList(data_tab[cur_ind])); //Zero par ligne et par colonne
        if (position(arc, arcs_tab[cur_ind]) == -1) {
          arcs_tab[cur_ind].add(arc);
        } else {
          arcs_tab[cur_ind].insert(position(arc, arcs_tab[cur_ind]), arc);
        }
        cur_noeud = noeud_droite_tmp;
      } else if (noeud_gauche_tmp.val == noeud_droite_tmp.val) {
        print("Otrany manasalasala fa aleo aloh copiena");
        //conservation de l'état
        List<List<List<int>>> etape_tmp = [];
        List<List<int>> data_conservation = copieList(data_tab[cur_ind]);
        arcs_tab.add(copieListArc(arcs_tab[cur_ind]));
        noeuds_tab.add(noeud_gauche_tmp);
        data_conservation[arc.i][arc.j] = -2;
        etape_tmp.add(copieList(data_conservation));

        minLigne(data_conservation);
        minColonne(data_conservation);
        etape_tmp.add(copieList(data_conservation));
        etape_tab.add(etape_tmp);
        print("rehefa conservena");
        afficheMatrice(data_conservation);
        data_tab.add(data_conservation);
        //Normal
        print(
            "tohizana traitement normal et prendre en compte ${arc.i}->${arc.j}");
        etapes.add(etape); //ajout de l'etape
        data_tab[cur_ind] = List<List<int>>.from(data_tmp);
        etape = []; //reinitialiser l'étape
        etape.add(copieList(data_tab[cur_ind])); //intiale vaovao
        etape.add(copieList(data_tab[cur_ind])); //Zero par ligne et par colonne
        if (position(arc, arcs_tab[cur_ind]) == -1) {
          arcs_tab[cur_ind].add(arc);
        } else {
          arcs_tab[cur_ind].insert(position(arc, arcs_tab[cur_ind]), arc);
        }
        cur_noeud = noeud_droite_tmp;
      } else {
        print("On ne prend pas en compte l'arc ${arc.i}->${arc.j}");

        data_tab[cur_ind][arc.i][arc.j] = -2;
        print("après blockage de l'arc ${arc.i}->${arc.j}");
        afficheMatrice(data_tab[cur_ind]);
        etapes.add(etape);

        etape = []; //reinitialiser l'étape

        etape.add(copieList(data_tab[cur_ind])); //intiale vaovao
        minLigne(data_tab[cur_ind]);
        minColonne(data_tab[cur_ind]);
        etape.add(copieList(data_tab[cur_ind])); //Zero par ligne et par colonne
        print("reassurer la présence de 0 par ligne et par colonne");
        afficheMatrice(data_tab[cur_ind]);
        cur_noeud = noeud_gauche_tmp;
      }

      if (minimum != -1 && cur_noeud.val > minimum) {
        cur_ind++;
        print("Miverina amin'ny noeud noenregistrena fa pas la peine");
        while (
            cur_ind < noeuds_tab.length && noeuds_tab[cur_ind].val > minimum) {
          cur_ind++;
        }
        if (cur_ind < noeuds_tab.length) {
          cur_noeud = noeuds_tab[cur_ind];
          reprendre = true;
          etape = [];
        }
        continue;
      }

      if (arreter(data_tab[cur_ind])) {
        if (arcs_result.length == 0 || minimum == cur_noeud.val) {
          arcs_result.add(arcs_tab[cur_ind]);
          minimum = cur_noeud.val;
        } else if (minimum > cur_noeud.val) {
          arcs_result.clear();
          arcs_result.add(arcs_tab[cur_ind]);
          minimum = cur_noeud.val;
        }
        cur_ind++;
        print("Miverina amin'ny noeud noenregistrena");
        if (cur_ind < noeuds_tab.length) {
          print("milamina le indice");
          cur_noeud = noeuds_tab[cur_ind];
          reprendre = true;
          etape = [];
        }
      }
    }
    arcs = arcs_tab[0];
    print("Nombre d'arc : ${arcs.length}");
    for (Arc arc in arcs) {
      print("${arc.i} -> ${arc.j}");
    }
    print("nombre d'étape ${etapes.length} ${regret_max_per_step.length}");
    print("nombre de parasiste ${list_parasite.length}");
    for (int i = 0; i < etapes.length; i++) {
      if (etapes[i][0].length > 0) {
        print("etape $i");
        print("avant netoyage");
        List<int> ignorable_ligne = [];
        List<int> ignorable_col = [];
        List<String> lignes = [];
        List<String> colonnes = [];
        List<int> val_sous_lignes = [];
        List<int> val_sous_cols = [];
        List<List<int>> val_sous = [];
        List<List<String>> sommet = [];
        int nb_ignorable_ligne = 0;
        int nb_ignorable_col = 0;
        afficheMatrice(etapes[i][0]);
        listIgnorable(etapes[i][0], ignorable_ligne, ignorable_col);
        for (int j = 0; j < data.length; j++) {
          if (!ignorable_ligne.contains(j)) {
            lignes.add(String.fromCharCode(65 + j));
          } else {
            if (j < regret_max_per_step[i].i) {
              nb_ignorable_ligne++;
            }
          }
          if (!ignorable_col.contains(j)) {
            colonnes.add(String.fromCharCode(65 + j));
          } else {
            if (j < regret_max_per_step[i].j) {
              nb_ignorable_col++;
            }
          }
        }
        //Valeurs soustraite par ligne
        List<List<int>> matrice_tmp = [];
        matrice_tmp = copieList(etapes[i][0]);
        for (int j = 0; j < data.length; j++) {
          if (!ignorable_ligne.contains(j)) {
            val_sous_lignes.add(minByLine(matrice_tmp, j));
          }
        }
        minLigne(matrice_tmp);
        //Valeurs soustraite par colonne
        for (int j = 0; j < data.length; j++) {
          if (!ignorable_col.contains(j)) {
            val_sous_cols.add(minByCol(matrice_tmp, j));
          }
        }

        regret_max_per_step[i].i =
            regret_max_per_step[i].i - nb_ignorable_ligne;
        regret_max_per_step[i].j = regret_max_per_step[i].j - nb_ignorable_col;
        sommet.add(lignes);
        sommet.add(colonnes);
        sommets.add(sommet);

        val_sous.add(val_sous_lignes);
        val_sous.add(val_sous_cols);
        val_sous_per_step.add(val_sous);

        etapes[i][0] = netoyerMatrice(etapes[i][0]);
        etapes[i][1] = netoyerMatrice(etapes[i][1]);
        etapes[i][2] = netoyerMatriceRegret(regret(etapes[i][1]));
        print("après netoyage");
        afficheMatrice(etapes[i][0]);
      } else {
        print("Misy matrice vide");
        etapes.removeAt(i);
      }
    }
    for (List<List<String>> sommet in sommets) {
      print("Ligne ${sommet[0]}");
      print("Colonne ${sommet[1]}");
    }
    print("minimum $minimum");
  }

  //method extra
  bool possibilityOfSolution(List<List<int>> matrice) {
    bool ligne = true;
    bool col = true;
    //parcours ligne
    for (int i = 0; i < matrice.length; i++) {
      int nb_valid = 0;
      for (int j = 0; j < matrice[i].length; j++) {
        if (matrice[i][j] >= 0) {
          nb_valid++;
        }
      }
      if (nb_valid < 1) {
        ligne = false;
        return ligne;
      }
    }
    //parcours cols
    for (int i = 0; i < matrice[0].length; i++) {
      int nb_valid = 0;
      for (int j = 0; j < matrice.length; j++) {
        if (matrice[j][i] >= 0) {
          nb_valid++;
        }
      }
      if (nb_valid < 1) {
        col = false;
        return col;
      }
    }
    return ligne && col;
  }

  int minByLine(List<List<int>> matrice, int i) {
    int min = 0;
    bool first = true;
    for (int j = 0; j < matrice[i].length; j++) {
      if (matrice[i][j] >= 0) {
        if (first) {
          min = matrice[i][j];
          first = false;
        } else {
          if (min > matrice[i][j]) {
            min = matrice[i][j];
          }
        }
      }
    }
    return min;
  }

  int minByCol(List<List<int>> matrice, int i) {
    int min = 0;
    bool first = true;
    for (int j = 0; j < matrice.length; j++) {
      if (matrice[j][i] >= 0) {
        if (first) {
          min = matrice[j][i];
          first = false;
        } else {
          if (matrice[j][i] < min) {
            min = matrice[j][i];
          }
        }
      }
    }
    return min;
  }

  int minLigne(List<List<int>> matrice) {
    int totalMin = 0;
    for (int i = 0; i < matrice.length; i++) {
      int min = 0;
      bool first = true;
      for (int j = 0; j < matrice[i].length; j++) {
        if (matrice[i][j] >= 0) {
          if (first) {
            min = matrice[i][j];
            first = false;
          } else {
            if (min > matrice[i][j]) {
              min = matrice[i][j];
            }
          }
        }
      }
      totalMin += min;
      for (int j = 0; j < matrice[i].length; j++) {
        if (matrice[i][j] >= 0) {
          matrice[i][j] = matrice[i][j] - min;
        }
      }
    }
    return totalMin;
  }

  int minColonne(List<List<int>> matrice) {
    int totalMin = 0;
    for (int i = 0; i < matrice[0].length; i++) {
      int min = 0;
      bool first = true;
      for (int j = 0; j < matrice.length; j++) {
        if (matrice[j][i] >= 0) {
          if (first) {
            min = matrice[j][i];
            first = false;
          } else {
            if (matrice[j][i] < min) {
              min = matrice[j][i];
            }
          }
        }
      }
      totalMin += min;
      for (int j = 0; j < matrice.length; j++) {
        if (matrice[j][i] >= 0) {
          matrice[j][i] = matrice[j][i] - min;
        }
      }
    }
    return totalMin;
  }

  List<List<int>> regret(List<List<int>> matrice) {
    int nbZero = nbZeroMatrice(matrice);
    List<List<int>> matrice_regret = [];
    for (int i = 0; i < matrice.length; i++) {
      List<int> tmp = [];
      for (int j = 0; j < matrice[i].length; j++) {
        if ((nbZero > 0 && matrice[i][j] == 0) ||
            (nbZero == 0 && matrice[i][j] == -2)) {
          bool first = true;
          int minL = -1;
          int minC = -1;
          for (int k = 0; k < matrice[i].length; k++) {
            if (matrice[i][k] >= 0 && k != j) {
              if (first) {
                minL = matrice[i][k];
                first = false;
              } else {
                if (matrice[i][k] < minL) {
                  minL = matrice[i][k];
                }
              }
            }
          }
          first = true;
          for (int k = 0; k < matrice.length; k++) {
            if (matrice[k][j] >= 0 && i != k) {
              if (first) {
                minC = matrice[k][j];
                first = false;
              } else {
                if (matrice[k][j] < minC) {
                  minC = matrice[k][j];
                }
              }
            }
          }
          if (minC == -1 || minL == -1) {
            tmp.add(-1);
          } else {
            tmp.add(minC + minL);
          }
        } else if ((nbZero != 0 && matrice[i][j] == -2)) {
          tmp.add(-3);
        } else {
          tmp.add(-2);
        }
      }
      matrice_regret.add(tmp);
    }
    return matrice_regret;
  }

  Arc regretPlusFort(List<List<int>> matrice_regret) {
    int ligne = 0;
    int colonne = 0;
    bool stop = false;
    for (int i = 0; i < matrice_regret.length && !stop; i++) {
      for (int j = 0; j < matrice_regret[i].length && !stop; j++) {
        if (matrice_regret[i][j] != -2 && matrice_regret[i][j] != -3) {
          if (matrice_regret[i][j] != -1) {
            if (matrice_regret[i][j] > matrice_regret[ligne][colonne]) {
              ligne = i;
              colonne = j;
            }
          } else {
            ligne = i;
            colonne = j;
            stop = true;
          }
        }
      }
    }
    return Arc(ligne, colonne);
  }

  void supprimeLigneColonne(Arc arc, List<List<int>> matrice) {
    for (int j = 0; j < matrice[arc.i].length; j++) {
      matrice[arc.i][j] = -1;
    }
    for (int i = 0; i < matrice.length; i++) {
      matrice[i][arc.j] = -1;
    }
  }

  bool arreter(List<List<int>> matrice) {
    bool arret = true;
    for (int i = 0; i < matrice.length; i++) {
      for (int j = 0; j < matrice[i].length; j++) {
        if (matrice[i][j] != -1) {
          arret = false;
        }
      }
    }
    return arret;
  }

  Arc precedent(Arc arc, List<Arc> arcs) {
    for (Arc tmp in arcs) {
      if (tmp.j == arc.i) {
        return tmp;
      }
    }
    return arc;
  }

  Arc suivant(Arc arc, List<Arc> arcs) {
    for (Arc tmp in arcs) {
      if (tmp.i == arc.j) {
        return tmp;
      }
    }
    return arc;
  }

  Arc ancetre(Arc arc, List<Arc> arcs) {
    Arc tmp = precedent(arc, arcs);
    if (arc.i != tmp.i || arc.j != tmp.j) {
      return ancetre(tmp, arcs);
    } else {
      return tmp;
    }
  }

  Arc descendent(Arc arc, List<Arc> arcs) {
    Arc tmp = suivant(arc, arcs);
    if (arc.i != tmp.i || arc.j != tmp.j) {
      return descendent(tmp, arcs);
    } else {
      return tmp;
    }
  }

  List<List<int>> copieList(List<List<int>> list) {
    List<List<int>> nouv = [];
    for (int i = 0; i < list.length; i++) {
      List<int> tmp = [];
      for (int j = 0; j < list[i].length; j++) {
        tmp.add(list[i][j]);
      }
      nouv.add(tmp);
    }
    return nouv;
  }

  List<Arc> copieListArc(List<Arc> arcs) {
    List<Arc> new_arcs = [];
    for (Arc arc in arcs) {
      Arc arc_tmp = Arc(arc.i, arc.j);
      arc_tmp.value = arc.value;
      new_arcs.add(arc_tmp);
    }
    return new_arcs;
  }

  int position(Arc arc, List<Arc> arcs) {
    for (int i = 0; i < arcs.length; i++) {
      if (arc.j == arcs[i].i) {
        return i;
      }
    }
    return -1;
  }

  int coutType1(List<List<int>> matrice) {
    List<List<int>> reg = regret(matrice);
    Arc arc = regretPlusFort(reg);
    return reg[arc.i][arc.j];
  }

  int nbZeroMatrice(List<List<int>> matrice) {
    int nb = 0;
    for (int i = 0; i < matrice.length; i++) {
      //String line = "";
      for (int j = 0; j < matrice[i].length; j++) {
        if (matrice[i][j] == 0) nb++;
      }
    }
    return nb;
  }

  void parcoursArbre(Noeud? nou, List<Noeud> noeuds) {
    if (nou != null) {
      noeuds.add(nou);
      print("Arc ${nou.arc?.i}->${nou.arc?.j} et sommet:${nou.val}");
      parcoursArbre(nou.gauche, noeuds);
      parcoursArbre(nou.droite, noeuds);
    }
  }

  bool ignorableLigne(int i, List<List<int>> matrice) {
    for (int j = 0; j < matrice[i].length; j++) {
      if (matrice[i][j] != -1) {
        return false;
      }
    }
    return true;
  }

  bool ignorableColonne(int j, List<List<int>> matrice) {
    for (int i = 0; i < matrice.length; i++) {
      if (matrice[i][j] != -1) {
        return false;
      }
    }
    return true;
  }

  List<List<int>> netoyerMatrice(List<List<int>> matrice) {
    List<List<int>> tmp_list = [];
    List<int> lignes = [];
    List<int> cols = [];
    listIgnorable(matrice, lignes, cols);
    print("ingnorable ligne $lignes");
    print("ingnorable colonne $cols");
    for (int i = 0; i < matrice.length; i++) {
      if (!lignes.contains(i)) {
        List<int> tmp = [];
        for (int j = 0; j < matrice[0].length; j++) {
          if (!cols.contains(j)) {
            tmp.add(matrice[i][j]);
          }
        }
        tmp_list.add(tmp);
      }
    }
    return tmp_list;
  }

  void listIgnorable(List<List<int>> matrice, List<int> ignorable_ligne,
      List<int> ignorable_col) {
    for (int i = 0; i < matrice.length; i++) {
      if (ignorableLigne(i, matrice)) {
        ignorable_ligne.add(i);
      }
    }
    if (matrice.length > 0) {
      for (int j = 0; j < matrice[0].length; j++) {
        if (ignorableColonne(j, matrice)) {
          ignorable_col.add(j);
        }
      }
    }
  }

  void listIgnorableRegret(List<List<int>> matrice, List<int> ignorable_ligne,
      List<int> ignorable_col) {
    for (int i = 0; i < matrice.length; i++) {
      if (ignorableLigneRegret(i, matrice)) {
        ignorable_ligne.add(i);
      }
    }
    if (matrice.length > 0) {
      for (int j = 0; j < matrice[0].length; j++) {
        if (ignorableColonneRegret(j, matrice)) {
          ignorable_col.add(j);
        }
      }
    }
  }

  bool ignorableLigneRegret(int i, List<List<int>> matrice) {
    for (int j = 0; j < matrice[i].length; j++) {
      if (matrice[i][j] != -2) {
        return false;
      }
    }
    return true;
  }

  bool ignorableColonneRegret(int j, List<List<int>> matrice) {
    for (int i = 0; i < matrice.length; i++) {
      if (matrice[i][j] != -2) {
        return false;
      }
    }
    return true;
  }

  List<List<int>> netoyerMatriceRegret(List<List<int>> matrice) {
    List<List<int>> tmp_list = [];
    List<int> lignes = [];
    List<int> cols = [];
    listIgnorableRegret(matrice, lignes, cols);
    for (int i = 0; i < matrice.length; i++) {
      if (!lignes.contains(i)) {
        List<int> tmp = [];
        for (int j = 0; j < matrice[0].length; j++) {
          if (!cols.contains(j)) {
            tmp.add(matrice[i][j]);
          }
        }
        tmp_list.add(tmp);
      }
    }
    return tmp_list;
  }

  void afficheMatrice(List<List<int>> matrice) {
    for (int i = 0; i < matrice.length; i++) {
      String line = "";
      for (int j = 0; j < matrice[i].length; j++) {
        line += "\t${matrice[i][j]}";
      }
      print(line);
    }
  }
}

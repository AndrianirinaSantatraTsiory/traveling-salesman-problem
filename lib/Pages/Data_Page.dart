import 'package:flutter/material.dart';
import 'package:flutter_app/Pages/resultat.dart';
import 'package:flutter_app/model/arbre.dart';

import '../Outil/traitement.dart';

class DataPage extends StatefulWidget {
  final int dimension;
  const DataPage({Key? key, required this.dimension}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool isLoading = true;
  List<List<TextEditingController>> controllers = [];
  List<List<String>> errorMessages = [];

  @override
  void initState() {
    super.initState();
    initialiseController();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Matrice de données")),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      String.fromCharCode(65),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    for (int i = 0; i < widget.dimension; i++)
                      Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            Text(
                              String.fromCharCode(65 + i),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            TextFormField(
                              enabled: 0 != i,
                              controller: controllers[0][i],
                              decoration: InputDecoration(
                                errorText: errorMessages[0][i] != ""
                                    ? errorMessages[0][i]
                                    : null,
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            )
                          ],
                        ),
                      ))
                  ],
                ),
                for (int ligne = 1; ligne < widget.dimension; ligne++)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(
                          String.fromCharCode(65 + ligne),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        for (int col = 0; col < widget.dimension; col++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3),
                              child: TextFormField(
                                enabled: ligne != col,
                                controller: controllers[ligne][col],
                                decoration: InputDecoration(
                                  errorText: errorMessages[ligne][col] != ""
                                      ? errorMessages[ligne][col]
                                      : null,
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (formValidation() &&
                        possibilityOfSolution(recupereData())) {
                      Traitement trt = Traitement();
                      List<Noeud> noeuds = [];
                      trt.littleAlgorithm(recupereData());
                      trt.parcoursArbre(trt.noeud, noeuds);
                      print("nombre de noeuds ${noeuds.length}");
                      if (trt.possible) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Resultat(
                            arcs: trt.arcs,
                            noeuds: noeuds,
                            etapes: trt.etapes,
                            sommets: trt.sommets,
                            regret_max: trt.regret_max_per_step,
                            arcs_result: trt.arcs_result,
                            val_sous_par_etape: trt.val_sous_per_step,
                            list_parasite: trt.list_parasite,
                          ),
                        ));
                      } else {
                        //Ts mahita solution ny algorithme
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Message'),
                              content:
                                  Text('Impossible de trouver une solution😅'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      showErrorMessage("Veuillez verifier les données entrées");
                    }
                  },
                  child: Text("Traiter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showErrorMessage(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(snackBar);
  }

  void initialiseController() {
    for (int i = 0; i < widget.dimension; i++) {
      List<TextEditingController> tmp = [];
      List<String> error_tmp = [];
      for (int j = 0; j < widget.dimension; j++) {
        TextEditingController controller = TextEditingController();
        if (i == j) {
          controller.text = "X";
        }
        error_tmp.add("");
        tmp.add(controller);
      }
      controllers.add(tmp);
      errorMessages.add(error_tmp);
    }
  }

  List<List<int>> recupereData() {
    List<List<int>> matrix = [];
    for (int i = 0; i < widget.dimension; i++) {
      List<int> tmp = [];
      for (int j = 0; j < widget.dimension; j++) {
        if (j == i || controllers[i][j].text.isEmpty) {
          tmp.add(-1);
        } else {
          tmp.add(int.parse(controllers[i][j].text));
        }
      }
      matrix.add(tmp);
    }
    return matrix;
  }

  bool formValidation() {
    for (int i = 0; i < widget.dimension; i++) {
      for (int j = 0; j < widget.dimension; j++) {
        if (j != i) {
          if (!controllers[i][j].text.isEmpty &&
              (int.tryParse(controllers[i][j].text) == null ||
                  int.parse(controllers[i][j].text) < 0)) {
            setState(() {
              errorMessages[i][j] = "Erreur";
            });
            return false;
          }
        }
      }
    }
    return true;
  }

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
}

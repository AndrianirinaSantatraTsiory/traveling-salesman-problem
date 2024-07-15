import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Outil/traitement.dart';
import 'package:graphite/core/typings.dart';
import 'package:graphite/graphite.dart';
import 'package:graphview/GraphView.dart';

import '../model/arbre.dart';
import '../model/arc.dart';

class Resultat extends StatefulWidget {
  List<Arc> arcs = [];
  List<Node> list_nodes = [];
  List<Noeud> noeuds = [];
  List<List<List<List<int>>>> etapes = [];
  List<List<List<String>>> sommets;
  List<Arc> regret_max = [];
  List<List<Arc>> arcs_result = [];
  List<List<List<int>>> val_sous_par_etape = [];
  List<Map<String, dynamic>> list_parasite = [];
  Resultat(
      {super.key,
      required this.arcs,
      required this.noeuds,
      required this.etapes,
      required this.sommets,
      required this.regret_max,
      required this.arcs_result,
      required this.val_sous_par_etape,
      required this.list_parasite});

  @override
  State<Resultat> createState() => _ResultatState();
}

class _ResultatState extends State<Resultat> {
  int cur_step = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Graph')),
        ),
        body: Center(
          child: InteractiveViewer(
            constrained: false,
            boundaryMargin: EdgeInsets.all(100),
            minScale: 0.01,
            maxScale: 5.6,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.green,
                  child: Text(
                    circuit().toString(),
                    style: TextStyle(color: Colors.white, fontSize: 50),
                  ),
                ),
                Row(
                  children: [
                    for (List<Arc> each_arcs in widget.arcs_result)
                      Row(children: [
                        GraphView(
                          graph: _buildGraph(each_arcs),
                          algorithm: FruchtermanReingoldAlgorithm(),
                          paint: Paint()
                            ..color = Colors.black
                            ..strokeWidth = 1.5
                            ..style = PaintingStyle.stroke,
                          builder: (Node node) {
                            return Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.blue,
                                    width:
                                        2), // Couleur et largeur de la bordure
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.blue,
                                radius: 15,
                                child: Text(
                                  node.key?.value as String,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                ),
                              ),
                            );
                          },
                        ),
                        for (Arc arc in each_arcs)
                          Text(
                              "${String.fromCharCode(65 + arc.i)}->${String.fromCharCode(65 + arc.j)}:${arc.value.toString()}  "),
                      ]),
                  ],
                ),
                DirectGraph(
                  list: nodeInputFromJson(nodeToJson()),
                  defaultCellSize: const Size(100.0, 100.0),
                  cellPadding: const EdgeInsets.all(20),
                  orientation: MatrixOrientation.Vertical,
                  nodeBuilder: (context, node) {
                    String data = node.id.toString();
                    List<String> data_list = data.split(" ");
                    return CircleAvatar(
                        backgroundColor:
                            data_list[0] == "D" ? Colors.blue : Colors.red,
                        radius: 10,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data_list[2] != "-1" ? data_list[2] : '\u221E',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              data_list[1],
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ));
                  },
                ),
                Row(children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(""),
                        ),
                        for (int j = 0;
                            j < widget.sommets[cur_step][1].length &&
                                j < widget.etapes[cur_step][0][0].length;
                            j++)
                          DataColumn(
                              label: Text(
                            widget.sommets[cur_step][1][j],
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          )),
                        DataColumn(
                          label: Text(""),
                        )
                      ],
                      rows: [
                        for (int i = 0;
                            i < widget.etapes[cur_step][0].length &&
                                i < widget.sommets[cur_step][0].length;
                            i++)
                          DataRow(cells: [
                            DataCell(Text(
                              widget.sommets[cur_step][0][i],
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ),
                            )),
                            for (int j = 0;
                                j < widget.etapes[cur_step][0][i].length &&
                                    j < widget.sommets[cur_step][1].length;
                                j++)
                              DataCell(Text(widget.etapes[cur_step][0][i][j] >=
                                      0
                                  ? widget.etapes[cur_step][0][i][j].toString()
                                  : '\u221E')),
                            DataCell(
                              Text(
                                widget.val_sous_par_etape[cur_step][0][i] != 0
                                    ? widget.val_sous_par_etape[cur_step][0][i]
                                        .toString()
                                    : "",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ]),
                        DataRow(cells: [
                          DataCell(
                            Text(""),
                          ),
                          for (int j = 0;
                              j < widget.sommets[cur_step][1].length &&
                                  j < widget.etapes[cur_step][0][0].length;
                              j++)
                            DataCell(Text(
                              widget.val_sous_par_etape[cur_step][1][j] != 0
                                  ? widget.val_sous_par_etape[cur_step][1][j]
                                      .toString()
                                  : "",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            )),
                          DataCell(Text("")),
                        ])
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(""),
                        ),
                        for (int j = 0;
                            j < widget.sommets[cur_step][1].length &&
                                j < widget.etapes[cur_step][1][0].length;
                            j++)
                          DataColumn(
                              label: Text(
                            widget.sommets[cur_step][1][j],
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          )),
                      ],
                      rows: [
                        for (int i = 0;
                            i < widget.etapes[cur_step][1].length &&
                                i < widget.sommets[cur_step][0].length;
                            i++)
                          DataRow(cells: [
                            DataCell(Text(
                              widget.sommets[cur_step][0][i],
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ),
                            )),
                            for (int j = 0;
                                j < widget.etapes[cur_step][0][i].length &&
                                    j < widget.sommets[cur_step][1].length;
                                j++)
                              DataCell(Text(
                                widget.etapes[cur_step][1][i][j] >= 0
                                    ? widget.etapes[cur_step][1][i][j]
                                        .toString()
                                    : '\u221E',
                                style: TextStyle(
                                    color: widget.etapes[cur_step][1][i][j] == 0
                                        ? Colors.red
                                        : Colors.black),
                              )),
                          ]),
                        DataRow(cells: [
                          for (int j = 0;
                              j < widget.sommets[cur_step][1].length + 1 &&
                                  j < widget.etapes[cur_step][1][0].length + 1;
                              j++)
                            DataCell(Text("")),
                        ]),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text(""),
                        ),
                        for (int j = 0;
                            j < widget.sommets[cur_step][1].length &&
                                j < widget.etapes[cur_step][1][0].length;
                            j++)
                          DataColumn(
                              label: Text(
                            widget.sommets[cur_step][1][j],
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          )),
                      ],
                      rows: [
                        for (int i = 0;
                            i < widget.etapes[cur_step][2].length &&
                                i < widget.sommets[cur_step][0].length;
                            i++)
                          DataRow(cells: [
                            DataCell(Text(
                              widget.sommets[cur_step][0][i],
                              style: TextStyle(
                                color: Colors.blueAccent,
                              ),
                            )),
                            for (int j = 0;
                                j < widget.etapes[cur_step][2][i].length &&
                                    i < widget.sommets[cur_step][1].length;
                                j++)
                              DataCell(Text(
                                regretValue(widget.etapes[cur_step][2][i][j]),
                                style: TextStyle(
                                    color: regret_color(cur_step, i, j)),
                              )),
                          ]),
                        DataRow(cells: [
                          for (int j = 0;
                              j < widget.sommets[cur_step][1].length + 1 &&
                                  j < widget.etapes[cur_step][2][0].length + 1;
                              j++)
                            DataCell(Text("")),
                        ]),
                      ],
                    ),
                  )
                ]),
                parasite(cur_step),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (cur_step > 0) {
                            setState(() {
                              cur_step--;
                            });
                          }
                        },
                        child: Text("Précedent"),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (cur_step < widget.etapes.length - 1 &&
                              widget.etapes[cur_step + 1][0].length > 0) {
                            setState(() {
                              cur_step++;
                            });
                          }
                        },
                        child: Text("Suivant"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Graph _buildGraph(List<Arc> arcs_param) {
    final Graph graph = Graph();
    List<Node> nodes = [];
    for (int i = 0; i < widget.etapes[0][0].length; i++) {
      nodes.add(Node.Id(String.fromCharCode(65 + i)));
    }
    for (Arc arc in arcs_param) {
      graph.addEdge(nodes[arc.i], nodes[arc.j]);
    }
    return graph;
  }

  bool isArcInList(Arc arc, List<Arc> arcs) {
    for (Arc arc_tmp in arcs) {
      if (arc_tmp.i == arc.i && arc_tmp.j == arc.j) {
        return true;
      }
    }
    return false;
  }

  String regretValue(int n) {
    if (n == -1) {
      return '\u221E';
    } else if (n == -2 || n == -3) {
      return "X";
    } else {
      return n.toString();
    }
  }

  int circuit() {
    int total = 0;
    for (Arc arc in widget.arcs_result[0]) {
      total += arc.value;
    }
    return total;
  }

  Color regret_color(int step, int ligne, int col) {
    if (ligne == widget.regret_max[step].i &&
        col == widget.regret_max[step].j) {
      return Colors.green;
    }
    return (widget.etapes[cur_step][1][ligne][col] == 0)
        ? Colors.red
        : Colors.black;
  }

  String arcsToJson(List<Arc> arcs) {
    List<Map<String, dynamic>> map_list = [];
    for (Arc arc in arcs) {
      Map<String, dynamic> edge_map = {};
      Map<String, String> child_map = {};
      List<Map<String, String>> child_list = [];
      edge_map["id"] = String.fromCharCode(65 + arc.i);
      child_map["outcome"] = String.fromCharCode(65 + arc.j);
      child_list.add(child_map);
      edge_map["next"] = child_list;
      map_list.add(edge_map);
    }
    return jsonEncode(map_list);
  }

  DirectGraph parasite(int indice) {
    int i_par = -1;
    int j_par = -1;
    Traitement trt = Traitement();
    List<Map<String, dynamic>> map_list = [];
    List<Arc> arcs = [];
    Arc new_arc = widget.list_parasite[indice]["new_arc"];
    arcs = trt.copieListArc(widget.list_parasite[indice]["list_arcs"]);
    arcs.add(new_arc);
    if (widget.list_parasite[indice].containsKey("arc_parasite")) {
      Arc arc_par = widget.list_parasite[indice]["arc_parasite"];
      arcs.add(arc_par);
      i_par = arc_par.i;
      j_par = arc_par.j;
    }
    print("nombre d'arc ${arcs.length}");
    for (Arc arc in arcs) {
      print("${arc.i}->${arc.j}");
      Map<String, dynamic> edge_map = {};
      Map<String, String> child_map = {};
      List<Map<String, String>> child_list = [];
      edge_map["id"] =
          "${i_par != -1 && (i_par == arc.i || j_par == arc.i) ? "P" : "NP"} ${String.fromCharCode(65 + arc.i)}";
      child_map["outcome"] =
          "${i_par != -1 && (i_par == arc.j || j_par == arc.j) ? "P" : "NP"} ${String.fromCharCode(65 + arc.j)}";
      child_list.add(child_map);
      edge_map["next"] = child_list;
      map_list.add(edge_map);
    }
    for (Arc arc in arcs) {
      if (!haveChild(arc, arcs)) {
        Map<String, dynamic> edge_map = {};
        edge_map["id"] =
            "${i_par != -1 && (i_par == arc.j || j_par == arc.j) ? "P" : "NP"} ${String.fromCharCode(65 + arc.j)}";
        edge_map["next"] = [];
        map_list.add(edge_map);
      }
    }
    print(jsonEncode(map_list));
    //return jsonEncode(map_list);
    return DirectGraph(
      list: nodeInputFromJson(jsonEncode(map_list)),
      defaultCellSize: const Size(100.0, 100.0),
      cellPadding: const EdgeInsets.all(20),
      orientation: MatrixOrientation.Horizontal,
      nodeBuilder: (context, node) {
        String data = node.id.toString();
        List<String> data_split = data.split(" ");
        return CircleAvatar(
          backgroundColor: data_split[0] == "P" ? Colors.red : Colors.blue,
          radius: 5,
          child: Text(data_split[1]),
        );
      },
    );
  }

  bool haveChild(Arc arc, arcs) {
    for (Arc arc_tmp in arcs) {
      if (arc_tmp.i == arc.j) {
        return true;
      }
    }
    return false;
  }

  String nodeToJson() {
    List<Map<String, dynamic>> map_list = [];
    Set<Noeud> set_noeuds = {};
    set_noeuds.addAll(widget.noeuds);
    for (Noeud noeud in widget.noeuds) {
      Map<String, dynamic> edge_map = {};
      Map<String, String> fils_gauche = {};
      Map<String, String> fils_droite = {};
      List<Map<String, String>> list_enfants = [];
      edge_map["id"] =
          "${noeud.isGauche ? "G" : "D"} ${noeud.arc?.i == null ? "R" : "" + String.fromCharCode(65 + (noeud.arc?.i as int)) + String.fromCharCode(65 + (noeud.arc?.j as int))} ${noeud.val} ${noeud.indice}";
      if (noeud.gauche != null)
        fils_gauche["outcome"] =
            "G ${noeud.gauche?.arc?.i == null ? "R" : "" + String.fromCharCode(65 + (noeud.gauche?.arc?.i as int)) + String.fromCharCode(65 + (noeud.gauche?.arc?.j as int))} ${noeud.gauche?.val} ${noeud.gauche?.indice}";
      if (noeud.droite != null)
        fils_droite["outcome"] =
            "D ${noeud.droite?.arc?.i == null ? "R" : "" + String.fromCharCode(65 + (noeud.droite?.arc?.i as int)) + String.fromCharCode(65 + (noeud.droite?.arc?.j as int))} ${noeud.droite?.val} ${noeud.droite?.indice}";
      if (fils_gauche.length != 0) list_enfants.add(fils_gauche);
      if (fils_droite.length != 0) list_enfants.add(fils_droite);
      edge_map["next"] = list_enfants;
      map_list.add(edge_map);
    }
    var copy = map_list.toList();
    return jsonEncode(copy);
    //return '[{"id":"null->null 20","next":[{"outcome":"1->3 24"},{"outcome":"1->3 20"}]},{"id":"1->3 24","next":[]},{"id":"1->3 20","next":[{"outcome":"0->4 22"},{"outcome":"0->4 23"}]},{"id":"0->4 22","next":[{"outcome":"3->5 24"},{"outcome":"3->5 22"}]},{"id":"3->5 24","next":[]},{"id":"3->5 22","next":[{"outcome":"5->4 25"},{"outcome":"5->4 23"}]},{"id":"5->4 25","next":[]},{"id":"5->4 23","next":[{"outcome":"0->1 30"},{"outcome":"0->1 23"}]},{"id":"0->1 30","next":[]},{"id":"0->1 23","next":[{"outcome":"2->0 -1"},{"outcome":"2->0 23"}]},{"id":"2->0 -1","next":[]},{"id":"2->0 23","next":[{"outcome":"4->2 -1"},{"outcome":"4->2 23"}]},{"id":"4->2 -1","next":[]},{"id":"4->2 23","next":[]},{"id":"0->4 23","next":[]}]';
  }

  Graph _treeGraph() {
    final Graph graph = Graph();
    Set<Noeud> set_noeuds = {};
    set_noeuds.addAll(widget.noeuds);
    Map<Noeud, Node> map_noeuds = {};
    for (Noeud noeud in set_noeuds) {
      map_noeuds[noeud] = Node.Id("${noeud.arc?.i} ${noeud.val}");
    }
    for (Noeud noeud in widget.noeuds) {
      print("Noeud 1");
      print(noeud.val);
      if (noeud.gauche != null)
        graph.addEdge(map_noeuds[noeud]!, map_noeuds[noeud.gauche]!);
      if (noeud.droite != null)
        graph.addEdge(map_noeuds[noeud]!, map_noeuds[noeud.droite]!);
    }
    return graph;
  }
}

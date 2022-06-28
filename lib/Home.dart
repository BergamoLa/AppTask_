import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helper/AnotacaoHelper.dart';
import 'model/Anotacao.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  var _db = AnotacaoHelper();
  List<Anotacao> _anotacoes = <Anotacao>[];

  _exibirTelaCadastro({Anotacao? anotacao}){
    String? textoSalvarAtualizar = "";

    if(anotacao == null){//salvar
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";

    }else{ //atualiza
      textoSalvarAtualizar = "Atualizar";
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;

    }
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("$textoSalvarAtualizar anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título",
                      hintText: "Digite título..."
                  ),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição",
                      hintText: "Digite descrição..."
                  ),
                )
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")
              ),
              ElevatedButton(
                  onPressed: (){

                    //salvar
                    _SalvarAtualizarAnotacao(anotacaoSelecionada: anotacao);

                    Navigator.pop(context);
                  },
                  child: Text("$textoSalvarAtualizar")
              )
            ],
          );
        }
    );

  }

  _recuperarAnotacoes() async {

    List anotacoesRecuperadas = await _db.recuperarAnotacoes();

    List<Anotacao> listaTemporaria = <Anotacao>[];
    for( var item in anotacoesRecuperadas ){

      Anotacao anotacao = Anotacao.fromMap( item );
      listaTemporaria.add( anotacao );

    }

    setState(() {
      _anotacoes = listaTemporaria;
    });
    //listaTemporaria.clear();

    //print("Lista anotacoes: " + anotacoesRecuperadas.toString() );

  }

  _SalvarAtualizarAnotacao({Anotacao? anotacaoSelecionada}) async {

    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;

    if(anotacaoSelecionada == null){ //salvar
      Anotacao anotacao = Anotacao(titulo, descricao, DateTime.now().toString() );
      int resultado = await _db.salvarAnotacao( anotacao );
    }else{//atualiza
        anotacaoSelecionada.titulo = titulo;
        anotacaoSelecionada.descricao = descricao;
        anotacaoSelecionada.data = DateTime.now().toString();
        int resultado = await _db.atualizarNota(anotacaoSelecionada);


    }



    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();

  }

  _formatarData(String data){

    initializeDateFormatting("pt_BR");

    //Year -> y month-> M Day -> d
    // Hour -> H minute -> m second -> s
    //var formatador = DateFormat("d/MMMM/y H:m:s");
    var formatador = DateFormat.yMd("pt_BR");

    DateTime dataConvertida = DateTime.parse( data );
    String? dataFormatada = formatador.format( dataConvertida );

    return dataFormatada;


  }

  _removerAnotacao (int id) async {

    await _db.removerAnotacao(id);
    _recuperarAnotacoes();
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas anotações"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, index){

                    final anotacao = _anotacoes[index];

                    return Card(
                      child: ListTile(
                        title: Text( anotacao.titulo! ),
                        subtitle: Text("${_formatarData(anotacao.data!)} - ${anotacao.descricao}") ,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: (){
                                _exibirTelaCadastro(anotacao: anotacao);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.mode_edit_rounded,
                                  color: Colors.blueAccent,

                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: (){
                                _removerAnotacao(anotacao.id!);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.remove_circle_outlined,
                                  color: Colors.redAccent,

                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                  }
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: (){
            _exibirTelaCadastro();
          }
      ),
    );
  }
}

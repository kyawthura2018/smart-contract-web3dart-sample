import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:web3dart_example/bloc/document_sign.dart';
import 'package:web3dart_example/contract_services.dart';
import 'document_sign_event.dart';
import 'document_sign_state.dart';

class DocumentSignBloc extends Bloc<DocumentSignEvent, DocumentSignState> {
  final ContractService contract;
  final String message;

  DocumentSignBloc(this.contract, {@required this.message})
      : assert(message != null);

  @override
  DocumentSignState get initialState => DocumentSignUninitialized();

  @override
  void onTransition(
      Transition<DocumentSignEvent, DocumentSignState> transition) {
    super.onTransition(transition);
    print(transition);
  }

  @override
  Stream<DocumentSignState> mapEventToState(
    DocumentSignEvent event,
  ) async* {
    if (event is InitalizedSM) {
      yield DocumentSignMining("akthura");
    } else if (event is Mining) {
      yield DocumentSignConfirmed("akthura");
    } else if (event is Confirmed) {
      yield DocumentSignConfirmed("akthura");
    }
  }
}

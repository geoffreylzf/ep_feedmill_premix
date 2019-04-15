import 'package:ep_feedmill/bloc/bloc_base.dart';
import 'package:ep_feedmill/db/dao/premix_dao.dart';
import 'package:ep_feedmill/model/table/premix.dart';
import 'package:rxdart/rxdart.dart';

class PremixHistoryBloc extends BlocBase {
  final _premixListSubject = BehaviorSubject<List<Premix>>();

  Stream<List<Premix>> get premixListStream => _premixListSubject.stream;

  @override
  void dispose() {
    _premixListSubject.close();
  }

  PremixHistoryBloc() {
    _loadPremixList();
  }

  _loadPremixList() async {
    _premixListSubject.add(await PremixDao().getAll());
  }
}

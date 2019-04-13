enum Actions { Edit }

class SelectGroupNo {
  final int groupNo;

  SelectGroupNo(this.groupNo);
}

int groupNoReducer(int state, dynamic action) {
  if (action is SelectGroupNo) {
    return action.groupNo;
  }
  return state;
}

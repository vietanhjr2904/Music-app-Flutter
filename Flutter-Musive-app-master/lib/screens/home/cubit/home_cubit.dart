import 'package:bloc/bloc.dart';

import '../../../models/loading_enum.dart';
import '../../../models/song_model.dart';
import '../../../models/user.dart';
import '../../../repositories/get_home_page.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final repo = GetHomePage();

  HomeCubit() : super(HomeState.initial());

  Future<void> getUsers() async {
    try {
      emit(state.copyWith(status: LoadPage.loading));

      final users = await repo.getUsers();
      final songs = await repo.getSongs();

      emit(state.copyWith(
        users: users,
        songs: songs,
        status: LoadPage.loaded,
      ));
    } catch (e) {
      print('HomeCubit error: $e');
      emit(state.copyWith(status: LoadPage.error));
    }
  }
}

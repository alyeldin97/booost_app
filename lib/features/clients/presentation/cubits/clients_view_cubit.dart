import 'package:flutter_bloc/flutter_bloc.dart';

enum ClientsViewMode { grid, table }

class ClientsViewCubit extends Cubit<ClientsViewMode> {
  ClientsViewCubit() : super(ClientsViewMode.grid);

  void setMode(ClientsViewMode mode) => emit(mode);
}

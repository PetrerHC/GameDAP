import '../Models/user_model.dart';
// Permite consultar y guardar usuarios en la API.
import 'api_client.dart';

class UserService {
  Future<List<UserModel>> obtenerUsuarios() async {
    final datos = await ApiClient.get('/usuarios') as List;
    List<UserModel> usuarios = [];
    for (final dato in datos) {
      usuarios.add(UserModel.fromJson(dato));
    }
    return usuarios;
  }

  // Crea una cuenta desde el panel de usuarios.
  Future<UserModel> agregarUsuario(UserModel usuario) async {
    final datos = await ApiClient.post('/usuarios', usuario.toJsonCrear());
    return UserModel.fromJson(datos);
  }

  // Envía los datos editados del usuario elegido.
  Future<UserModel> actualizarUsuario(UserModel usuario) async {
    final datos = await ApiClient.put('/usuarios/${usuario.id}', {
      'nom_usr': usuario.nombre,
      'mail': usuario.correo,
      'dir_usr': usuario.direccion,
      'tip_usu': usuario.tipoUsuario,
    });
    return UserModel.fromJson(datos);
  }

  Future<void> eliminarUsuario(int id) async {
    await ApiClient.delete('/usuarios/$id');
  }
}

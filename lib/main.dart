// Práctica: Conociendo a la persona
// Captura nombre, edad y sueldo; valida los datos y aplica reglas
// condicionales. El resultado se muestra en un diálogo y en una etiqueta.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemNavigator e inputFormatters

// ---------- VALORES GLOBALES ----------
// Color principal de la app: cambiándolo aquí se actualiza todo.
const MaterialColor colorBase = Colors.indigo;

// Reglas de negocio declaradas una sola vez.
const double sueldoMinimoMensual = 9582.47;
const int edadMinimaMayoria = 18;

void main() {
  runApp(const AplicacionPersona());
}

// Widget raíz: solo configura la app, no cambia durante la ejecución.
class AplicacionPersona extends StatelessWidget {
  const AplicacionPersona({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conociendo a la persona',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colorBase),
        useMaterial3: true,
      ),
      home: const PantallaRegistro(),
    );
  }
}

// Pantalla con estado: el texto del resultado cambia mientras se usa la app.
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _EstadoPantallaRegistro();
}

class _EstadoPantallaRegistro extends State<PantallaRegistro> {
  // Controladores: permiten leer y borrar el contenido de cada campo.
  final TextEditingController _ctrlNombre = TextEditingController();
  final TextEditingController _ctrlEdad = TextEditingController();
  final TextEditingController _ctrlSueldo = TextEditingController();

  // Texto que se muestra en la etiqueta de resultado (vacío al inicio).
  String _textoResultado = '';

  // Libera la memoria de los controladores al destruir la pantalla.
  @override
  void dispose() {
    _ctrlNombre.dispose();
    _ctrlEdad.dispose();
    _ctrlSueldo.dispose();
    super.dispose();
  }

  // ---------- DIÁLOGO REUTILIZABLE ----------
  // Sirve tanto para el resultado como para el aviso de datos incompletos.
  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // ---------- LÓGICA PRINCIPAL ----------
  void _verificar() {
    // Oculta el teclado.
    FocusScope.of(context).unfocus();

    // 1) Leer: todo lo escrito es String, hay que convertirlo.
    final String nombre = _ctrlNombre.text.trim();
    final int? edad = int.tryParse(_ctrlEdad.text.trim());
    final double? sueldo = double.tryParse(_ctrlSueldo.text.trim());

    // 2) Validar: si algo falta o no es número, avisamos y salimos.
    if (nombre.isEmpty || edad == null || sueldo == null) {
      _mostrarDialogo(
        'Datos incompletos',
        'Por favor captura tu nombre completo, tu edad y tu sueldo mensual.',
      );
      return;
    }

    // 3) Reglas de negocio.
    final bool esMayor = edad >= edadMinimaMayoria; // 18 o más
    final bool superaMinimo = sueldo > sueldoMinimoMensual; // estrictamente mayor

    // 4) Armar los mensajes según cada regla.
    final String lineaEdad =
        esMayor ? 'Eres mayor de edad.' : 'Eres menor de edad.';

    final String minimoFormateado = sueldoMinimoMensual.toStringAsFixed(2);
    final String lineaSueldo = superaMinimo
        ? 'Tu sueldo mensual SÍ está por arriba del sueldo mínimo (\$$minimoFormateado).'
        : 'Tu sueldo mensual NO está por arriba del sueldo mínimo (\$$minimoFormateado).';

    final String mensajeFinal = 'Hola, $nombre.\n$lineaEdad\n$lineaSueldo';

    // 5) Actualizar la etiqueta: setState hace que Flutter redibuje.
    setState(() {
      _textoResultado = mensajeFinal;
    });

    // 6) Mostrar el mismo mensaje en el diálogo.
    _mostrarDialogo('Resultado', mensajeFinal);
  }

  // Borra los campos y la etiqueta.
  void _limpiarDatos() {
    _ctrlNombre.clear();
    _ctrlEdad.clear();
    _ctrlSueldo.clear();
    setState(() {
      _textoResultado = '';
    });
  }

  // Cierra la app (funciona en Android).
  void _salirApp() {
    SystemNavigator.pop();
  }

  // ---------- WIDGET AUXILIAR PARA LOS CAMPOS ----------
  // Evita repetir el mismo código tres veces.
  Widget _campoTexto({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
    TextCapitalization mayusculas = TextCapitalization.none,
    List<TextInputFormatter>? filtros,
  }) {
    return TextField(
      controller: controlador,
      keyboardType: teclado,
      textCapitalization: mayusculas,
      inputFormatters: filtros,
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // ---------- INTERFAZ ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conociendo a la persona'),
        centerTitle: true,
        backgroundColor: colorBase,
        foregroundColor: Colors.white,
      ),
      // Scroll para que el teclado no desborde la pantalla.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Captura tus datos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorBase,
              ),
            ),
            const SizedBox(height: 16),

            // Nombre: cada palabra inicia con mayúscula.
            _campoTexto(
              controlador: _ctrlNombre,
              etiqueta: 'Nombre completo',
              icono: Icons.person,
              teclado: TextInputType.name,
              mayusculas: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Edad: teclado numérico, solo dígitos.
            _campoTexto(
              controlador: _ctrlEdad,
              etiqueta: 'Edad',
              icono: Icons.cake,
              teclado: TextInputType.number,
              filtros: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Sueldo: decimal con máximo dos decimales.
            _campoTexto(
              controlador: _ctrlSueldo,
              etiqueta: 'Sueldo mensual',
              icono: Icons.attach_money,
              teclado: const TextInputType.numberWithOptions(decimal: true),
              filtros: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 24),

            // Botón Verificar
            ElevatedButton.icon(
              onPressed: _verificar,
              icon: const Icon(Icons.check_circle),
              label: const Text('Verificar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorBase,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Botón Limpiar datos
            OutlinedButton.icon(
              onPressed: _limpiarDatos,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Limpiar datos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorBase,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Botón Salir
            TextButton.icon(
              onPressed: _salirApp,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Salir'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            const SizedBox(height: 24),

            // Etiqueta de resultado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorBase.shade50,
                border: Border.all(color: colorBase.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _textoResultado.isEmpty
                    ? 'Aquí aparecerá el resultado'
                    : _textoResultado,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
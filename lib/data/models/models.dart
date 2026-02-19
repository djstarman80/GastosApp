class Usuario {
  final int id;
  final String nombre;

  Usuario({required this.id, required this.nombre});

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(id: map['id'] as int, nombre: map['nombre'] as String);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre};
  }

  Map<String, dynamic> toJson() => toMapBackup();
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario.fromMapBackup(json);

  // Para backup JSON
  factory Usuario.fromMapBackup(Map<String, dynamic> map) {
    return Usuario(id: map['id'] as int, nombre: map['nombre'] as String);
  }

  Map<String, dynamic> toMapBackup() {
    return {'id': id, 'nombre': nombre};
  }

  Usuario copyWith({int? id, String? nombre}) {
    return Usuario(id: id ?? this.id, nombre: nombre ?? this.nombre);
  }
}

class Tarjeta {
  final int id;
  final String tipo;
  final String nombre;
  final String banco;
  final String nombreTarjeta;
  final String color;
  final double? limite;
  final int usuarioId;
  final int? fechaCierre;

  Tarjeta({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.banco,
    required this.nombreTarjeta,
    required this.color,
    this.limite,
    required this.usuarioId,
    this.fechaCierre,
  });

  factory Tarjeta.fromMap(Map<String, dynamic> map) {
    return Tarjeta(
      id: map['id'] as int,
      tipo: map['tipo'] as String,
      nombre: map['nombre'] as String,
      banco: map['banco'] as String,
      nombreTarjeta: map['nombre_tarjeta'] as String,
      color: map['color'] as String,
      limite: map['limite'] as double?,
      usuarioId: map['usuario_id'] as int,
      fechaCierre: map['fecha_cierre'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'nombre': nombre,
      'banco': banco,
      'nombre_tarjeta': nombreTarjeta,
      'color': color,
      'limite': limite,
      'usuario_id': usuarioId,
      'fecha_cierre': fechaCierre,
    };
  }

  // Para backup JSON
  factory Tarjeta.fromMapBackup(Map<String, dynamic> map) {
    return Tarjeta(
      id: map['id'] as int,
      tipo: map['tipo'] as String,
      nombre: map['nombre'] as String,
      banco: map['banco'] as String,
      nombreTarjeta: map['bandera'] as String? ?? map['nombre_tarjeta'] as String? ?? 'Visa',
      color: map['color'] as String,
      limite: map['limite'] != null ? (map['limite'] as num).toDouble() : null,
      usuarioId: map['usuarioId'] as int,
      fechaCierre: map['fechaCierre'] as int?,
    );
  }

  Map<String, dynamic> toMapBackup() {
    return {
      'id': id,
      'tipo': tipo,
      'nombre': nombre,
      'banco': banco,
      'nombre_tarjeta': nombreTarjeta,
      'color': color,
      'limite': limite,
      'usuarioId': usuarioId,
      'fechaCierre': fechaCierre,
    };
  }

  Map<String, dynamic> toJson() => toMapBackup();
  factory Tarjeta.fromJson(Map<String, dynamic> json) => Tarjeta.fromMapBackup(json);

  Tarjeta copyWith({
    int? id, String? tipo, String? nombre, String? banco, String? nombreTarjeta,
    String? color, double? limite, int? usuarioId, int? fechaCierre,
  }) {
    return Tarjeta(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      banco: banco ?? this.banco,
      nombreTarjeta: nombreTarjeta ?? this.nombreTarjeta,
      color: color ?? this.color,
      limite: limite ?? this.limite,
      usuarioId: usuarioId ?? this.usuarioId,
      fechaCierre: fechaCierre ?? this.fechaCierre,
    );
  }
}

class Gasto {
  final int id;
  final double monto;
  final String descripcion;
  final int tarjetaId;
  final int usuarioId;
  final int? cuotas;
  final bool esRecurrente;
  final int fecha;
  final int? fechaPago;
  final bool pagado;

  Gasto({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.tarjetaId,
    required this.usuarioId,
    this.cuotas,
    required this.esRecurrente,
    required this.fecha,
    this.fechaPago,
    required this.pagado,
  });

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as int,
      monto: (map['monto'] as num).toDouble(),
      descripcion: map['descripcion'] as String,
      tarjetaId: map['tarjeta_id'] as int,
      usuarioId: map['usuario_id'] as int,
      cuotas: map['cuotas'] as int?,
      esRecurrente: (map['es_recurrente'] as int) == 1,
      fecha: map['fecha'] as int,
      fechaPago: map['fecha_pago'] as int?,
      pagado: (map['pagado'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monto': monto,
      'descripcion': descripcion,
      'tarjeta_id': tarjetaId,
      'usuario_id': usuarioId,
      'cuotas': cuotas,
      'es_recurrente': esRecurrente ? 1 : 0,
      'fecha': fecha,
      'fecha_pago': fechaPago,
      'pagado': pagado ? 1 : 0,
    };
  }

  // Para backup JSON
  factory Gasto.fromMapBackup(Map<String, dynamic> map) {
    return Gasto(
      id: map['id'] as int,
      monto: (map['monto'] as num).toDouble(),
      descripcion: map['descripcion'] as String,
      tarjetaId: map['tarjetaId'] as int,
      usuarioId: map['usuarioId'] as int,
      cuotas: map['cuotas'] as int?,
      esRecurrente: map['esRecurrente'] is bool ? map['esRecurrente'] as bool : (map['esRecurrente'] as int) == 1,
      fecha: map['fecha'] is int ? map['fecha'] as int : int.parse(map['fecha'].toString()),
      fechaPago: map['fechaPago'] as int?,
      pagado: map['pagado'] is bool ? map['pagado'] as bool : (map['pagado'] as int) == 1,
    );
  }

  Map<String, dynamic> toMapBackup() {
    return {
      'id': id,
      'monto': monto,
      'descripcion': descripcion,
      'tarjetaId': tarjetaId,
      'usuarioId': usuarioId,
      'cuotas': cuotas,
      'esRecurrente': esRecurrente,
      'fecha': fecha,
      'fechaPago': fechaPago,
      'pagado': pagado,
    };
  }

  Map<String, dynamic> toJson() => toMapBackup();
  factory Gasto.fromJson(Map<String, dynamic> json) => Gasto.fromMapBackup(json);

  Gasto copyWith({
    int? id, double? monto, String? descripcion, int? tarjetaId, int? usuarioId,
    int? cuotas, bool? esRecurrente, int? fecha, int? fechaPago, bool? pagado,
  }) {
    return Gasto(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      descripcion: descripcion ?? this.descripcion,
      tarjetaId: tarjetaId ?? this.tarjetaId,
      usuarioId: usuarioId ?? this.usuarioId,
      cuotas: cuotas ?? this.cuotas,
      esRecurrente: esRecurrente ?? this.esRecurrente,
      fecha: fecha ?? this.fecha,
      fechaPago: fechaPago ?? this.fechaPago,
      pagado: pagado ?? this.pagado,
    );
  }
}

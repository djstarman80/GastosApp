// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nombreMeta = VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>('nombre', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, nombre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(Insertable<Usuario> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    if (data.containsKey('nombre')) context.handle(_nombreMeta, nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    else if (isInserting) context.missing(_nombreMeta);
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, nombre: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}nombre'])!);
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final int id;
  final String nombre;
  const Usuario({required this.id, required this.nombre});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(id: Value(id), nombre: Value(nombre));
  }

  factory Usuario.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(id: serializer.fromJson<int>(json['id']), nombre: serializer.fromJson<String>(json['nombre']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id), 'nombre': serializer.toJson<String>(nombre)};
  }

  Usuario copyWith({int? id, String? nombre}) => Usuario(id: id ?? this.id, nombre: nombre ?? this.nombre);
  @override
  String toString() {
    return (StringBuffer('Usuario(')..write('id: $id, ')..write('nombre: $nombre')..write(')')).toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is Usuario && other.id == this.id && other.nombre == this.nombre);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<int> id;
  final Value<String> nombre;
  const UsuariosCompanion({this.id = const Value.absent(), this.nombre = const Value.absent()});
  UsuariosCompanion.insert({this.id = const Value.absent(), required String nombre}) : nombre = Value(nombre);
  static Insertable<Usuario> custom({Expression<int>? id, Expression<String>? nombre}) {
    return RawValuesInsertable({if (id != null) 'id': id, if (nombre != null) 'nombre': nombre});
  }

  UsuariosCompanion copyWith({Value<int>? id, Value<String>? nombre}) {
    return UsuariosCompanion(id: id ?? this.id, nombre: nombre ?? this.nombre);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (nombre.present) map['nombre'] = Variable<String>(nombre.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')..write('id: $id, ')..write('nombre: $nombre')..write(')')).toString();
  }
}

class $TarjetasTable extends Tarjetas with TableInfo<$TarjetasTable, Tarjeta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarjetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _tipoMeta = VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>('tipo', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nombreMeta = VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>('nombre', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bancoMeta = VerificationMeta('banco');
  @override
  late final GeneratedColumn<String> banco = GeneratedColumn<String>('banco', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bandeiraMeta = VerificationMeta('bandeira');
  @override
  late final GeneratedColumn<String> bandeira = GeneratedColumn<String>('bandeira', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>('color', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _limiteMeta = VerificationMeta('limite');
  @override
  late final GeneratedColumn<double> limite = GeneratedColumn<double>('limite', aliasedName, true, type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _usuarioIdMeta = VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>('usuario_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES usuarios (id)'));
  static const VerificationMeta _fechaCierreMeta = VerificationMeta('fechaCierre');
  @override
  late final GeneratedColumn<int> fechaCierre = GeneratedColumn<int>('fecha_cierre', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, tipo, nombre, banco, bandeira, color, limite, usuarioId, fechaCierre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarjetas';
  @override
  VerificationContext validateIntegrity(Insertable<Tarjeta> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    if (data.containsKey('tipo')) context.handle(_tipoMeta, tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta));
    else if (isInserting) context.missing(_tipoMeta);
    if (data.containsKey('nombre')) context.handle(_nombreMeta, nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta));
    else if (isInserting) context.missing(_nombreMeta);
    if (data.containsKey('banco')) context.handle(_bancoMeta, banco.isAcceptableOrUnknown(data['banco']!, _bancoMeta));
    else if (isInserting) context.missing(_bancoMeta);
    if (data.containsKey('bandeira')) context.handle(_bandeiraMeta, bandeira.isAcceptableOrUnknown(data['bandeira']!, _bandeiraMeta));
    else if (isInserting) context.missing(_bandeiraMeta);
    if (data.containsKey('color')) context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    else if (isInserting) context.missing(_colorMeta);
    if (data.containsKey('limite')) context.handle(_limiteMeta, limite.isAcceptableOrUnknown(data['limite']!, _limiteMeta));
    if (data.containsKey('usuario_id')) context.handle(_usuarioIdMeta, usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    else if (isInserting) context.missing(_usuarioIdMeta);
    if (data.containsKey('fecha_cierre')) context.handle(_fechaCierreMeta, fechaCierre.isAcceptableOrUnknown(data['fecha_cierre']!, _fechaCierreMeta));
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tarjeta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tarjeta(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, tipo: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tipo'])!, nombre: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}nombre'])!, banco: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}banco'])!, bandeira: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}bandeira'])!, color: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}color'])!, limite: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}limite']), usuarioId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}usuario_id'])!, fechaCierre: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fecha_cierre']));
  }

  @override
  $TarjetasTable createAlias(String alias) {
    return $TarjetasTable(attachedDatabase, alias);
  }
}

class Tarjeta extends DataClass implements Insertable<Tarjeta> {
  final int id;
  final String tipo;
  final String nombre;
  final String banco;
  final String bandeira;
  final String color;
  final double? limite;
  final int usuarioId;
  final int? fechaCierre;
  const Tarjeta({required this.id, required this.tipo, required this.nombre, required this.banco, required this.bandeira, required this.color, this.limite, required this.usuarioId, this.fechaCierre});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['nombre'] = Variable<String>(nombre);
    map['banco'] = Variable<String>(banco);
    map['bandeira'] = Variable<String>(bandeira);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || limite != null) map['limite'] = Variable<double>(limite);
    map['usuario_id'] = Variable<int>(usuarioId);
    if (!nullToAbsent || fechaCierre != null) map['fecha_cierre'] = Variable<int>(fechaCierre);
    return map;
  }

  TarjetasCompanion toCompanion(bool nullToAbsent) {
    return TarjetasCompanion(id: Value(id), tipo: Value(tipo), nombre: Value(nombre), banco: Value(banco), bandeira: Value(bandeira), color: Value(color), limite: limite == null && nullToAbsent ? const Value.absent() : Value(limite), usuarioId: Value(usuarioId), fechaCierre: fechaCierre == null && nullToAbsent ? const Value.absent() : Value(fechaCierre));
  }

  factory Tarjeta.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tarjeta(id: serializer.fromJson<int>(json['id']), tipo: serializer.fromJson<String>(json['tipo']), nombre: serializer.fromJson<String>(json['nombre']), banco: serializer.fromJson<String>(json['banco']), bandeira: serializer.fromJson<String>(json['bandeira']), color: serializer.fromJson<String>(json['color']), limite: serializer.fromJson<double?>(json['limite']), usuarioId: serializer.fromJson<int>(json['usuarioId']), fechaCierre: serializer.fromJson<int?>(json['fechaCierre']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id), 'tipo': serializer.toJson<String>(tipo), 'nombre': serializer.toJson<String>(nombre), 'banco': serializer.toJson<String>(banco), 'bandeira': serializer.toJson<String>(bandeira), 'color': serializer.toJson<String>(color), 'limite': serializer.toJson<double?>(limite), 'usuarioId': serializer.toJson<int>(usuarioId), 'fechaCierre': serializer.toJson<int?>(fechaCierre)};
  }

  Tarjeta copyWith({int? id, String? tipo, String? nombre, String? banco, String? bandeira, String? color, Value<double?> limite = const Value.absent(), int? usuarioId, Value<int?> fechaCierre = const Value.absent()}) => Tarjeta(id: id ?? this.id, tipo: tipo ?? this.tipo, nombre: nombre ?? this.nombre, banco: banco ?? this.banco, bandeira: bandeira ?? this.bandeira, color: color ?? this.color, limite: limite.present ? limite.value : this.limite, usuarioId: usuarioId ?? this.usuarioId, fechaCierre: fechaCierre.present ? fechaCierre.value : this.fechaCierre);
  @override
  String toString() {
    return (StringBuffer('Tarjeta(')..write('id: $id, ')..write('tipo: $tipo, ')..write('nombre: $nombre, ')..write('banco: $banco, ')..write('bandeira: $bandeira, ')..write('color: $color, ')..write('limite: $limite, ')..write('usuarioId: $usuarioId, ')..write('fechaCierre: $fechaCierre')..write(')')).toString();
  }

  @override
  int get hashCode => Object.hash(id, tipo, nombre, banco, bandeira, color, limite, usuarioId, fechaCierre);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is Tarjeta && other.id == this.id && other.tipo == this.tipo && other.nombre == this.nombre && other.banco == this.banco && other.bandeira == this.bandeira && other.color == this.color && other.limite == this.limite && other.usuarioId == this.usuarioId && other.fechaCierre == this.fechaCierre);
}

class TarjetasCompanion extends UpdateCompanion<Tarjeta> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<String> nombre;
  final Value<String> banco;
  final Value<String> bandeira;
  final Value<String> color;
  final Value<double?> limite;
  final Value<int> usuarioId;
  final Value<int?> fechaCierre;
  const TarjetasCompanion({this.id = const Value.absent(), this.tipo = const Value.absent(), this.nombre = const Value.absent(), this.banco = const Value.absent(), this.bandeira = const Value.absent(), this.color = const Value.absent(), this.limite = const Value.absent(), this.usuarioId = const Value.absent(), this.fechaCierre = const Value.absent()});
  TarjetasCompanion.insert({this.id = const Value.absent(), required String tipo, required String nombre, required String banco, required String bandeira, required String color, this.limite = const Value.absent(), required int usuarioId, this.fechaCierre = const Value.absent()}) : tipo = Value(tipo), nombre = Value(nombre), banco = Value(banco), bandeira = Value(bandeira), color = Value(color), usuarioId = Value(usuarioId);
  static Insertable<Tarjeta> custom({Expression<int>? id, Expression<String>? tipo, Expression<String>? nombre, Expression<String>? banco, Expression<String>? bandeira, Expression<String>? color, Expression<double>? limite, Expression<int>? usuarioId, Expression<int>? fechaCierre}) {
    return RawValuesInsertable({if (id != null) 'id': id, if (tipo != null) 'tipo': tipo, if (nombre != null) 'nombre': nombre, if (banco != null) 'banco': banco, if (bandeira != null) 'bandeira': bandeira, if (color != null) 'color': color, if (limite != null) 'limite': limite, if (usuarioId != null) 'usuario_id': usuarioId, if (fechaCierre != null) 'fecha_cierre': fechaCierre});
  }

  TarjetasCompanion copyWith({Value<int>? id, Value<String>? tipo, Value<String>? nombre, Value<String>? banco, Value<String>? bandeira, Value<String>? color, Value<double?>? limite, Value<int>? usuarioId, Value<int?>? fechaCierre}) {
    return TarjetasCompanion(id: id ?? this.id, tipo: tipo ?? this.tipo, nombre: nombre ?? this.nombre, banco: banco ?? this.banco, bandeira: bandeira ?? this.bandeira, color: color ?? this.color, limite: limite ?? this.limite, usuarioId: usuarioId ?? this.usuarioId, fechaCierre: fechaCierre ?? this.fechaCierre);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (tipo.present) map['tipo'] = Variable<String>(tipo.value);
    if (nombre.present) map['nombre'] = Variable<String>(nombre.value);
    if (banco.present) map['banco'] = Variable<String>(banco.value);
    if (bandeira.present) map['bandeira'] = Variable<String>(bandeira.value);
    if (color.present) map['color'] = Variable<String>(color.value);
    if (limite.present) map['limite'] = Variable<double>(limite.value);
    if (usuarioId.present) map['usuario_id'] = Variable<int>(usuarioId.value);
    if (fechaCierre.present) map['fecha_cierre'] = Variable<int>(fechaCierre.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarjetasCompanion(')..write('id: $id, ')..write('tipo: $tipo, ')..write('nombre: $nombre, ')..write('banco: $banco, ')..write('bandeira: $bandeira, ')..write('color: $color, ')..write('limite: $limite, ')..write('usuarioId: $usuarioId, ')..write('fechaCierre: $fechaCierre')..write(')')).toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, Gasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _montoMeta = VerificationMeta('monto');
  @override
  late final GeneratedColumn<double> monto = GeneratedColumn<double>('monto', aliasedName, false, type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _descripcionMeta = VerificationMeta('descripcion');
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>('descripcion', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tarjetaIdMeta = VerificationMeta('tarjetaId');
  @override
  late final GeneratedColumn<int> tarjetaId = GeneratedColumn<int>('tarjeta_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tarjetas (id)'));
  static const VerificationMeta _usuarioIdMeta = VerificationMeta('usuarioId');
  @override
  late final GeneratedColumn<int> usuarioId = GeneratedColumn<int>('usuario_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES usuarios (id)'));
  static const VerificationMeta _cuotasMeta = VerificationMeta('cuotas');
  @override
  late final GeneratedColumn<int> cuotas = GeneratedColumn<int>('cuotas', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _esRecurrenteMeta = VerificationMeta('esRecurrente');
  @override
  late final GeneratedColumn<bool> esRecurrente = GeneratedColumn<bool>('es_recurrente', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("es_recurrente" IN (0, 1))'), defaultValue: const Constant(false));
  static const VerificationMeta _fechaMeta = VerificationMeta('fecha');
  @override
  late final GeneratedColumn<int> fecha = GeneratedColumn<int>('fecha', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fechaPagoMeta = VerificationMeta('fechaPago');
  @override
  late final GeneratedColumn<int> fechaPago = GeneratedColumn<int>('fecha_pago', aliasedName, true, type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pagadoMeta = VerificationMeta('pagado');
  @override
  late final GeneratedColumn<bool> pagado = GeneratedColumn<bool>('pagado', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("pagado" IN (0, 1))'), defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, monto, descripcion, tarjetaId, usuarioId, cuotas, esRecurrente, fecha, fechaPago, pagado];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(Insertable<Gasto> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    if (data.containsKey('monto')) context.handle(_montoMeta, monto.isAcceptableOrUnknown(data['monto']!, _montoMeta));
    else if (isInserting) context.missing(_montoMeta);
    if (data.containsKey('descripcion')) context.handle(_descripcionMeta, descripcion.isAcceptableOrUnknown(data['descripcion']!, _descripcionMeta));
    else if (isInserting) context.missing(_descripcionMeta);
    if (data.containsKey('tarjeta_id')) context.handle(_tarjetaIdMeta, tarjetaId.isAcceptableOrUnknown(data['tarjeta_id']!, _tarjetaIdMeta));
    else if (isInserting) context.missing(_tarjetaIdMeta);
    if (data.containsKey('usuario_id')) context.handle(_usuarioIdMeta, usuarioId.isAcceptableOrUnknown(data['usuario_id']!, _usuarioIdMeta));
    else if (isInserting) context.missing(_usuarioIdMeta);
    if (data.containsKey('cuotas')) context.handle(_cuotasMeta, cuotas.isAcceptableOrUnknown(data['cuotas']!, _cuotasMeta));
    if (data.containsKey('es_recurrente')) context.handle(_esRecurrenteMeta, esRecurrente.isAcceptableOrUnknown(data['es_recurrente']!, _esRecurrenteMeta));
    if (data.containsKey('fecha')) context.handle(_fechaMeta, fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta));
    else if (isInserting) context.missing(_fechaMeta);
    if (data.containsKey('fecha_pago')) context.handle(_fechaPagoMeta, fechaPago.isAcceptableOrUnknown(data['fecha_pago']!, _fechaPagoMeta));
    if (data.containsKey('pagado')) context.handle(_pagadoMeta, pagado.isAcceptableOrUnknown(data['pagado']!, _pagadoMeta));
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gasto(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, monto: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}monto'])!, descripcion: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}descripcion'])!, tarjetaId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tarjeta_id'])!, usuarioId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}usuario_id'])!, cuotas: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cuotas']), esRecurrente: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}es_recurrente'])!, fecha: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fecha'])!, fechaPago: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fecha_pago']), pagado: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}pagado'])!);
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }
}

class Gasto extends DataClass implements Insertable<Gasto> {
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
  const Gasto({required this.id, required this.monto, required this.descripcion, required this.tarjetaId, required this.usuarioId, this.cuotas, required this.esRecurrente, required this.fecha, this.fechaPago, required this.pagado});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monto'] = Variable<double>(monto);
    map['descripcion'] = Variable<String>(descripcion);
    map['tarjeta_id'] = Variable<int>(tarjetaId);
    map['usuario_id'] = Variable<int>(usuarioId);
    if (!nullToAbsent || cuotas != null) map['cuotas'] = Variable<int>(cuotas);
    map['es_recurrente'] = Variable<bool>(esRecurrente);
    map['fecha'] = Variable<int>(fecha);
    if (!nullToAbsent || fechaPago != null) map['fecha_pago'] = Variable<int>(fechaPago);
    map['pagado'] = Variable<bool>(pagado);
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(id: Value(id), monto: Value(monto), descripcion: Value(descripcion), tarjetaId: Value(tarjetaId), usuarioId: Value(usuarioId), cuotas: cuotas == null && nullToAbsent ? const Value.absent() : Value(cuotas), esRecurrente: Value(esRecurrente), fecha: Value(fecha), fechaPago: fechaPago == null && nullToAbsent ? const Value.absent() : Value(fechaPago), pagado: Value(pagado));
  }

  factory Gasto.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gasto(id: serializer.fromJson<int>(json['id']), monto: serializer.fromJson<double>(json['monto']), descripcion: serializer.fromJson<String>(json['descripcion']), tarjetaId: serializer.fromJson<int>(json['tarjetaId']), usuarioId: serializer.fromJson<int>(json['usuarioId']), cuotas: serializer.fromJson<int?>(json['cuotas']), esRecurrente: serializer.fromJson<bool>(json['esRecurrente']), fecha: serializer.fromJson<int>(json['fecha']), fechaPago: serializer.fromJson<int?>(json['fechaPago']), pagado: serializer.fromJson<bool>(json['pagado']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'id': serializer.toJson<int>(id), 'monto': serializer.toJson<double>(monto), 'descripcion': serializer.toJson<String>(descripcion), 'tarjetaId': serializer.toJson<int>(tarjetaId), 'usuarioId': serializer.toJson<int>(usuarioId), 'cuotas': serializer.toJson<int?>(cuotas), 'esRecurrente': serializer.toJson<bool>(esRecurrente), 'fecha': serializer.toJson<int>(fecha), 'fechaPago': serializer.toJson<int?>(fechaPago), 'pagado': serializer.toJson<bool>(pagado)};
  }

  Gasto copyWith({int? id, double? monto, String? descripcion, int? tarjetaId, int? usuarioId, Value<int?> cuotas = const Value.absent(), bool? esRecurrente, int? fecha, Value<int?> fechaPago = const Value.absent(), bool? pagado}) => Gasto(id: id ?? this.id, monto: monto ?? this.monto, descripcion: descripcion ?? this.descripcion, tarjetaId: tarjetaId ?? this.tarjetaId, usuarioId: usuarioId ?? this.usuarioId, cuotas: cuotas.present ? cuotas.value : this.cuotas, esRecurrente: esRecurrente ?? this.esRecurrente, fecha: fecha ?? this.fecha, fechaPago: fechaPago.present ? fechaPago.value : this.fechaPago, pagado: pagado ?? this.pagado);
  @override
  String toString() {
    return (StringBuffer('Gasto(')..write('id: $id, ')..write('monto: $monto, ')..write('descripcion: $descripcion, ')..write('tarjetaId: $tarjetaId, ')..write('usuarioId: $usuarioId, ')..write('cuotas: $cuotas, ')..write('esRecurrente: $esRecurrente, ')..write('fecha: $fecha, ')..write('fechaPago: $fechaPago, ')..write('pagado: $pagado')..write(')')).toString();
  }

  @override
  int get hashCode => Object.hash(id, monto, descripcion, tarjetaId, usuarioId, cuotas, esRecurrente, fecha, fechaPago, pagado);
  @override
  bool operator ==(Object other) => identical(this, other) || (other is Gasto && other.id == this.id && other.monto == this.monto && other.descripcion == this.descripcion && other.tarjetaId == this.tarjetaId && other.usuarioId == this.usuarioId && other.cuotas == this.cuotas && other.esRecurrente == this.esRecurrente && other.fecha == this.fecha && other.fechaPago == this.fechaPago && other.pagado == this.pagado);
}

class GastosCompanion extends UpdateCompanion<Gasto> {
  final Value<int> id;
  final Value<double> monto;
  final Value<String> descripcion;
  final Value<int> tarjetaId;
  final Value<int> usuarioId;
  final Value<int?> cuotas;
  final Value<bool> esRecurrente;
  final Value<int> fecha;
  final Value<int?> fechaPago;
  final Value<bool> pagado;
  const GastosCompanion({this.id = const Value.absent(), this.monto = const Value.absent(), this.descripcion = const Value.absent(), this.tarjetaId = const Value.absent(), this.usuarioId = const Value.absent(), this.cuotas = const Value.absent(), this.esRecurrente = const Value.absent(), this.fecha = const Value.absent(), this.fechaPago = const Value.absent(), this.pagado = const Value.absent()});
  GastosCompanion.insert({this.id = const Value.absent(), required double monto, required String descripcion, required int tarjetaId, required int usuarioId, this.cuotas = const Value.absent(), this.esRecurrente = const Value.absent(), required int fecha, this.fechaPago = const Value.absent(), this.pagado = const Value.absent()}) : monto = Value(monto), descripcion = Value(descripcion), tarjetaId = Value(tarjetaId), usuarioId = Value(usuarioId), esRecurrente = Value(esRecurrente), fecha = Value(fecha), pagado = Value(pagado);
  static Insertable<Gasto> custom({Expression<int>? id, Expression<double>? monto, Expression<String>? descripcion, Expression<int>? tarjetaId, Expression<int>? usuarioId, Expression<int>? cuotas, Expression<bool>? esRecurrente, Expression<int>? fecha, Expression<int>? fechaPago, Expression<bool>? pagado}) {
    return RawValuesInsertable({if (id != null) 'id': id, if (monto != null) 'monto': monto, if (descripcion != null) 'descripcion': descripcion, if (tarjetaId != null) 'tarjeta_id': tarjetaId, if (usuarioId != null) 'usuario_id': usuarioId, if (cuotas != null) 'cuotas': cuotas, if (esRecurrente != null) 'es_recurrente': esRecurrente, if (fecha != null) 'fecha': fecha, if (fechaPago != null) 'fecha_pago': fechaPago, if (pagado != null) 'pagado': pagado});
  }

  GastosCompanion copyWith({Value<int>? id, Value<double>? monto, Value<String>? descripcion, Value<int>? tarjetaId, Value<int>? usuarioId, Value<int?>? cuotas, Value<bool>? esRecurrente, Value<int>? fecha, Value<int?>? fechaPago, Value<bool>? pagado}) {
    return GastosCompanion(id: id ?? this.id, monto: monto ?? this.monto, descripcion: descripcion ?? this.descripcion, tarjetaId: tarjetaId ?? this.tarjetaId, usuarioId: usuarioId ?? this.usuarioId, cuotas: cuotas ?? this.cuotas, esRecurrente: esRecurrente ?? this.esRecurrente, fecha: fecha ?? this.fecha, fechaPago: fechaPago ?? this.fechaPago, pagado: pagado ?? this.pagado);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<int>(id.value);
    if (monto.present) map['monto'] = Variable<double>(monto.value);
    if (descripcion.present) map['descripcion'] = Variable<String>(descripcion.value);
    if (tarjetaId.present) map['tarjeta_id'] = Variable<int>(tarjetaId.value);
    if (usuarioId.present) map['usuario_id'] = Variable<int>(usuarioId.value);
    if (cuotas.present) map['cuotas'] = Variable<int>(cuotas.value);
    if (esRecurrente.present) map['es_recurrente'] = Variable<bool>(esRecurrente.value);
    if (fecha.present) map['fecha'] = Variable<int>(fecha.value);
    if (fechaPago.present) map['fecha_pago'] = Variable<int>(fechaPago.value);
    if (pagado.present) map['pagado'] = Variable<bool>(pagado.value);
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')..write('id: $id, ')..write('monto: $monto, ')..write('descripcion: $descripcion, ')..write('tarjetaId: $tarjetaId, ')..write('usuarioId: $usuarioId, ')..write('cuotas: $cuotas, ')..write('esRecurrente: $esRecurrente, ')..write('fecha: $fecha, ')..write('fechaPago: $fechaPago, ')..write('pagado: $pagado')..write(')')).toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  late final $TarjetasTable tarjetas = $TarjetasTable(this);
  late final $GastosTable gastos = $GastosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [usuarios, tarjetas, gastos];
}

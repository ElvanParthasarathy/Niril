// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VanigaTharavugalTableTable extends VanigaTharavugalTable
    with TableInfo<$VanigaTharavugalTableTable, VanigaTharavugalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VanigaTharavugalTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _seyaliVagaiMeta =
      const VerificationMeta('seyaliVagai');
  @override
  late final GeneratedColumn<String> seyaliVagai = GeneratedColumn<String>(
      'seyali_vagai', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mudhanMozhiMeta =
      const VerificationMeta('mudhanMozhi');
  @override
  late final GeneratedColumn<String> mudhanMozhi = GeneratedColumn<String>(
      'mudhan_mozhi', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Tamil'));
  static const VerificationMeta _thunaiMozhiMeta =
      const VerificationMeta('thunaiMozhi');
  @override
  late final GeneratedColumn<String> thunaiMozhi = GeneratedColumn<String>(
      'thunai_mozhi', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('English'));
  static const VerificationMeta _iruMozhiMeta =
      const VerificationMeta('iruMozhi');
  @override
  late final GeneratedColumn<bool> iruMozhi = GeneratedColumn<bool>(
      'iru_mozhi', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("iru_mozhi" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      niruvanathinPeyar = GeneratedColumn<String>(
              'niruvanathin_peyar', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$converterniruvanathinPeyar);
  static const VerificationMeta _kurumPeyarMeta =
      const VerificationMeta('kurumPeyar');
  @override
  late final GeneratedColumn<String> kurumPeyar = GeneratedColumn<String>(
      'kurum_peyar', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tholaipesi1Meta =
      const VerificationMeta('tholaipesi1');
  @override
  late final GeneratedColumn<String> tholaipesi1 = GeneratedColumn<String>(
      'tholaipesi1', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tholaipesi2Meta =
      const VerificationMeta('tholaipesi2');
  @override
  late final GeneratedColumn<String> tholaipesi2 = GeneratedColumn<String>(
      'tholaipesi2', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _minnanchalMeta =
      const VerificationMeta('minnanchal');
  @override
  late final GeneratedColumn<String> minnanchal = GeneratedColumn<String>(
      'minnanchal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
      'gstin', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      mugavari = GeneratedColumn<String>('mugavari', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$convertermugavari);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String> oor =
      GeneratedColumn<String>('oor', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$converteroor);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      maavattam = GeneratedColumn<String>('maavattam', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$convertermaavattam);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      maanilam = GeneratedColumn<String>('maanilam', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$convertermaanilam);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      naadu = GeneratedColumn<String>('naadu', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$converternaadu);
  static const VerificationMeta _anchalkuriyeeduMeta =
      const VerificationMeta('anchalkuriyeedu');
  @override
  late final GeneratedColumn<String> anchalkuriyeedu = GeneratedColumn<String>(
      'anchalkuriyeedu', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      vangiPeyar = GeneratedColumn<String>('vangi_peyar', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$convertervangiPeyar);
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      kilai = GeneratedColumn<String>('kilai', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$converterkilai);
  static const VerificationMeta _vangiKanakkuMeta =
      const VerificationMeta('vangiKanakku');
  @override
  late final GeneratedColumn<String> vangiKanakku = GeneratedColumn<String>(
      'vangi_kanakku', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _ifscMeta = const VerificationMeta('ifsc');
  @override
  late final GeneratedColumn<String> ifsc = GeneratedColumn<String>(
      'ifsc', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _ovuruMeta = const VerificationMeta('ovuru');
  @override
  late final GeneratedColumn<String> ovuru = GeneratedColumn<String>(
      'ovuru', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _agalaOvuruMeta =
      const VerificationMeta('agalaOvuru');
  @override
  late final GeneratedColumn<String> agalaOvuru = GeneratedColumn<String>(
      'agala_ovuru', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _thallaippuVadivuMeta =
      const VerificationMeta('thallaippuVadivu');
  @override
  late final GeneratedColumn<String> thallaippuVadivu = GeneratedColumn<String>(
      'thallaippu_vadivu', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('small'));
  static const VerificationMeta _kaiyoppamMeta =
      const VerificationMeta('kaiyoppam');
  @override
  late final GeneratedColumn<String> kaiyoppam = GeneratedColumn<String>(
      'kaiyoppam', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _oppamPeyarMeta =
      const VerificationMeta('oppamPeyar');
  @override
  late final GeneratedColumn<String> oppamPeyar = GeneratedColumn<String>(
      'oppam_peyar', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
      adaimozhi = GeneratedColumn<String>('adaimozhi', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('{}'))
          .withConverter<Map<String, String>>(
              $VanigaTharavugalTableTable.$converteradaimozhi);
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
      'upi_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _thottranNiramMeta =
      const VerificationMeta('thottranNiram');
  @override
  late final GeneratedColumn<String> thottranNiram = GeneratedColumn<String>(
      'thottran_niram', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seyaliVagai,
        mudhanMozhi,
        thunaiMozhi,
        iruMozhi,
        niruvanathinPeyar,
        kurumPeyar,
        tholaipesi1,
        tholaipesi2,
        minnanchal,
        gstin,
        mugavari,
        oor,
        maavattam,
        maanilam,
        naadu,
        anchalkuriyeedu,
        vangiPeyar,
        kilai,
        vangiKanakku,
        ifsc,
        ovuru,
        agalaOvuru,
        thallaippuVadivu,
        kaiyoppam,
        oppamPeyar,
        adaimozhi,
        upiId,
        thottranNiram
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaniga_tharavugal_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<VanigaTharavugalEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('seyali_vagai')) {
      context.handle(
          _seyaliVagaiMeta,
          seyaliVagai.isAcceptableOrUnknown(
              data['seyali_vagai']!, _seyaliVagaiMeta));
    } else if (isInserting) {
      context.missing(_seyaliVagaiMeta);
    }
    if (data.containsKey('mudhan_mozhi')) {
      context.handle(
          _mudhanMozhiMeta,
          mudhanMozhi.isAcceptableOrUnknown(
              data['mudhan_mozhi']!, _mudhanMozhiMeta));
    }
    if (data.containsKey('thunai_mozhi')) {
      context.handle(
          _thunaiMozhiMeta,
          thunaiMozhi.isAcceptableOrUnknown(
              data['thunai_mozhi']!, _thunaiMozhiMeta));
    }
    if (data.containsKey('iru_mozhi')) {
      context.handle(_iruMozhiMeta,
          iruMozhi.isAcceptableOrUnknown(data['iru_mozhi']!, _iruMozhiMeta));
    }
    if (data.containsKey('kurum_peyar')) {
      context.handle(
          _kurumPeyarMeta,
          kurumPeyar.isAcceptableOrUnknown(
              data['kurum_peyar']!, _kurumPeyarMeta));
    }
    if (data.containsKey('tholaipesi1')) {
      context.handle(
          _tholaipesi1Meta,
          tholaipesi1.isAcceptableOrUnknown(
              data['tholaipesi1']!, _tholaipesi1Meta));
    }
    if (data.containsKey('tholaipesi2')) {
      context.handle(
          _tholaipesi2Meta,
          tholaipesi2.isAcceptableOrUnknown(
              data['tholaipesi2']!, _tholaipesi2Meta));
    }
    if (data.containsKey('minnanchal')) {
      context.handle(
          _minnanchalMeta,
          minnanchal.isAcceptableOrUnknown(
              data['minnanchal']!, _minnanchalMeta));
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    }
    if (data.containsKey('anchalkuriyeedu')) {
      context.handle(
          _anchalkuriyeeduMeta,
          anchalkuriyeedu.isAcceptableOrUnknown(
              data['anchalkuriyeedu']!, _anchalkuriyeeduMeta));
    }
    if (data.containsKey('vangi_kanakku')) {
      context.handle(
          _vangiKanakkuMeta,
          vangiKanakku.isAcceptableOrUnknown(
              data['vangi_kanakku']!, _vangiKanakkuMeta));
    }
    if (data.containsKey('ifsc')) {
      context.handle(
          _ifscMeta, ifsc.isAcceptableOrUnknown(data['ifsc']!, _ifscMeta));
    }
    if (data.containsKey('ovuru')) {
      context.handle(
          _ovuruMeta, ovuru.isAcceptableOrUnknown(data['ovuru']!, _ovuruMeta));
    }
    if (data.containsKey('agala_ovuru')) {
      context.handle(
          _agalaOvuruMeta,
          agalaOvuru.isAcceptableOrUnknown(
              data['agala_ovuru']!, _agalaOvuruMeta));
    }
    if (data.containsKey('thallaippu_vadivu')) {
      context.handle(
          _thallaippuVadivuMeta,
          thallaippuVadivu.isAcceptableOrUnknown(
              data['thallaippu_vadivu']!, _thallaippuVadivuMeta));
    }
    if (data.containsKey('kaiyoppam')) {
      context.handle(_kaiyoppamMeta,
          kaiyoppam.isAcceptableOrUnknown(data['kaiyoppam']!, _kaiyoppamMeta));
    }
    if (data.containsKey('oppam_peyar')) {
      context.handle(
          _oppamPeyarMeta,
          oppamPeyar.isAcceptableOrUnknown(
              data['oppam_peyar']!, _oppamPeyarMeta));
    }
    if (data.containsKey('upi_id')) {
      context.handle(
          _upiIdMeta, upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta));
    }
    if (data.containsKey('thottran_niram')) {
      context.handle(
          _thottranNiramMeta,
          thottranNiram.isAcceptableOrUnknown(
              data['thottran_niram']!, _thottranNiramMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VanigaTharavugalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VanigaTharavugalEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seyaliVagai: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seyali_vagai'])!,
      mudhanMozhi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mudhan_mozhi'])!,
      thunaiMozhi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thunai_mozhi'])!,
      iruMozhi: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}iru_mozhi'])!,
      niruvanathinPeyar: $VanigaTharavugalTableTable.$converterniruvanathinPeyar
          .fromSql(attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}niruvanathin_peyar'])!),
      kurumPeyar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kurum_peyar'])!,
      tholaipesi1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tholaipesi1'])!,
      tholaipesi2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tholaipesi2'])!,
      minnanchal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}minnanchal'])!,
      gstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gstin'])!,
      mugavari: $VanigaTharavugalTableTable.$convertermugavari.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}mugavari'])!),
      oor: $VanigaTharavugalTableTable.$converteroor.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}oor'])!),
      maavattam: $VanigaTharavugalTableTable.$convertermaavattam.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}maavattam'])!),
      maanilam: $VanigaTharavugalTableTable.$convertermaanilam.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}maanilam'])!),
      naadu: $VanigaTharavugalTableTable.$converternaadu.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}naadu'])!),
      anchalkuriyeedu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}anchalkuriyeedu'])!,
      vangiPeyar: $VanigaTharavugalTableTable.$convertervangiPeyar.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}vangi_peyar'])!),
      kilai: $VanigaTharavugalTableTable.$converterkilai.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}kilai'])!),
      vangiKanakku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vangi_kanakku'])!,
      ifsc: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ifsc'])!,
      ovuru: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ovuru'])!,
      agalaOvuru: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agala_ovuru'])!,
      thallaippuVadivu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thallaippu_vadivu'])!,
      kaiyoppam: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kaiyoppam'])!,
      oppamPeyar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}oppam_peyar'])!,
      adaimozhi: $VanigaTharavugalTableTable.$converteradaimozhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}adaimozhi'])!),
      upiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upi_id'])!,
      thottranNiram: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thottran_niram'])!,
    );
  }

  @override
  $VanigaTharavugalTableTable createAlias(String alias) {
    return $VanigaTharavugalTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, String>, String>
      $converterniruvanathinPeyar = const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $convertermugavari =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $converteroor =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $convertermaavattam =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $convertermaanilam =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $converternaadu =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $convertervangiPeyar =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $converterkilai =
      const MozhiMapConverter();
  static TypeConverter<Map<String, String>, String> $converteradaimozhi =
      const MozhiMapConverter();
}

class VanigaTharavugalEntry extends DataClass
    implements Insertable<VanigaTharavugalEntry> {
  final int id;
  final String seyaliVagai;
  final String mudhanMozhi;
  final String thunaiMozhi;
  final bool iruMozhi;
  final Map<String, String> niruvanathinPeyar;
  final String kurumPeyar;
  final String tholaipesi1;
  final String tholaipesi2;
  final String minnanchal;
  final String gstin;
  final Map<String, String> mugavari;
  final Map<String, String> oor;
  final Map<String, String> maavattam;
  final Map<String, String> maanilam;
  final Map<String, String> naadu;
  final String anchalkuriyeedu;
  final Map<String, String> vangiPeyar;
  final Map<String, String> kilai;
  final String vangiKanakku;
  final String ifsc;
  final String ovuru;
  final String agalaOvuru;
  final String thallaippuVadivu;
  final String kaiyoppam;
  final String oppamPeyar;
  final Map<String, String> adaimozhi;
  final String upiId;
  final String thottranNiram;
  const VanigaTharavugalEntry(
      {required this.id,
      required this.seyaliVagai,
      required this.mudhanMozhi,
      required this.thunaiMozhi,
      required this.iruMozhi,
      required this.niruvanathinPeyar,
      required this.kurumPeyar,
      required this.tholaipesi1,
      required this.tholaipesi2,
      required this.minnanchal,
      required this.gstin,
      required this.mugavari,
      required this.oor,
      required this.maavattam,
      required this.maanilam,
      required this.naadu,
      required this.anchalkuriyeedu,
      required this.vangiPeyar,
      required this.kilai,
      required this.vangiKanakku,
      required this.ifsc,
      required this.ovuru,
      required this.agalaOvuru,
      required this.thallaippuVadivu,
      required this.kaiyoppam,
      required this.oppamPeyar,
      required this.adaimozhi,
      required this.upiId,
      required this.thottranNiram});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seyali_vagai'] = Variable<String>(seyaliVagai);
    map['mudhan_mozhi'] = Variable<String>(mudhanMozhi);
    map['thunai_mozhi'] = Variable<String>(thunaiMozhi);
    map['iru_mozhi'] = Variable<bool>(iruMozhi);
    {
      map['niruvanathin_peyar'] = Variable<String>($VanigaTharavugalTableTable
          .$converterniruvanathinPeyar
          .toSql(niruvanathinPeyar));
    }
    map['kurum_peyar'] = Variable<String>(kurumPeyar);
    map['tholaipesi1'] = Variable<String>(tholaipesi1);
    map['tholaipesi2'] = Variable<String>(tholaipesi2);
    map['minnanchal'] = Variable<String>(minnanchal);
    map['gstin'] = Variable<String>(gstin);
    {
      map['mugavari'] = Variable<String>(
          $VanigaTharavugalTableTable.$convertermugavari.toSql(mugavari));
    }
    {
      map['oor'] = Variable<String>(
          $VanigaTharavugalTableTable.$converteroor.toSql(oor));
    }
    {
      map['maavattam'] = Variable<String>(
          $VanigaTharavugalTableTable.$convertermaavattam.toSql(maavattam));
    }
    {
      map['maanilam'] = Variable<String>(
          $VanigaTharavugalTableTable.$convertermaanilam.toSql(maanilam));
    }
    {
      map['naadu'] = Variable<String>(
          $VanigaTharavugalTableTable.$converternaadu.toSql(naadu));
    }
    map['anchalkuriyeedu'] = Variable<String>(anchalkuriyeedu);
    {
      map['vangi_peyar'] = Variable<String>(
          $VanigaTharavugalTableTable.$convertervangiPeyar.toSql(vangiPeyar));
    }
    {
      map['kilai'] = Variable<String>(
          $VanigaTharavugalTableTable.$converterkilai.toSql(kilai));
    }
    map['vangi_kanakku'] = Variable<String>(vangiKanakku);
    map['ifsc'] = Variable<String>(ifsc);
    map['ovuru'] = Variable<String>(ovuru);
    map['agala_ovuru'] = Variable<String>(agalaOvuru);
    map['thallaippu_vadivu'] = Variable<String>(thallaippuVadivu);
    map['kaiyoppam'] = Variable<String>(kaiyoppam);
    map['oppam_peyar'] = Variable<String>(oppamPeyar);
    {
      map['adaimozhi'] = Variable<String>(
          $VanigaTharavugalTableTable.$converteradaimozhi.toSql(adaimozhi));
    }
    map['upi_id'] = Variable<String>(upiId);
    map['thottran_niram'] = Variable<String>(thottranNiram);
    return map;
  }

  VanigaTharavugalTableCompanion toCompanion(bool nullToAbsent) {
    return VanigaTharavugalTableCompanion(
      id: Value(id),
      seyaliVagai: Value(seyaliVagai),
      mudhanMozhi: Value(mudhanMozhi),
      thunaiMozhi: Value(thunaiMozhi),
      iruMozhi: Value(iruMozhi),
      niruvanathinPeyar: Value(niruvanathinPeyar),
      kurumPeyar: Value(kurumPeyar),
      tholaipesi1: Value(tholaipesi1),
      tholaipesi2: Value(tholaipesi2),
      minnanchal: Value(minnanchal),
      gstin: Value(gstin),
      mugavari: Value(mugavari),
      oor: Value(oor),
      maavattam: Value(maavattam),
      maanilam: Value(maanilam),
      naadu: Value(naadu),
      anchalkuriyeedu: Value(anchalkuriyeedu),
      vangiPeyar: Value(vangiPeyar),
      kilai: Value(kilai),
      vangiKanakku: Value(vangiKanakku),
      ifsc: Value(ifsc),
      ovuru: Value(ovuru),
      agalaOvuru: Value(agalaOvuru),
      thallaippuVadivu: Value(thallaippuVadivu),
      kaiyoppam: Value(kaiyoppam),
      oppamPeyar: Value(oppamPeyar),
      adaimozhi: Value(adaimozhi),
      upiId: Value(upiId),
      thottranNiram: Value(thottranNiram),
    );
  }

  factory VanigaTharavugalEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VanigaTharavugalEntry(
      id: serializer.fromJson<int>(json['id']),
      seyaliVagai: serializer.fromJson<String>(json['seyaliVagai']),
      mudhanMozhi: serializer.fromJson<String>(json['mudhanMozhi']),
      thunaiMozhi: serializer.fromJson<String>(json['thunaiMozhi']),
      iruMozhi: serializer.fromJson<bool>(json['iruMozhi']),
      niruvanathinPeyar:
          serializer.fromJson<Map<String, String>>(json['niruvanathinPeyar']),
      kurumPeyar: serializer.fromJson<String>(json['kurumPeyar']),
      tholaipesi1: serializer.fromJson<String>(json['tholaipesi1']),
      tholaipesi2: serializer.fromJson<String>(json['tholaipesi2']),
      minnanchal: serializer.fromJson<String>(json['minnanchal']),
      gstin: serializer.fromJson<String>(json['gstin']),
      mugavari: serializer.fromJson<Map<String, String>>(json['mugavari']),
      oor: serializer.fromJson<Map<String, String>>(json['oor']),
      maavattam: serializer.fromJson<Map<String, String>>(json['maavattam']),
      maanilam: serializer.fromJson<Map<String, String>>(json['maanilam']),
      naadu: serializer.fromJson<Map<String, String>>(json['naadu']),
      anchalkuriyeedu: serializer.fromJson<String>(json['anchalkuriyeedu']),
      vangiPeyar: serializer.fromJson<Map<String, String>>(json['vangiPeyar']),
      kilai: serializer.fromJson<Map<String, String>>(json['kilai']),
      vangiKanakku: serializer.fromJson<String>(json['vangiKanakku']),
      ifsc: serializer.fromJson<String>(json['ifsc']),
      ovuru: serializer.fromJson<String>(json['ovuru']),
      agalaOvuru: serializer.fromJson<String>(json['agalaOvuru']),
      thallaippuVadivu: serializer.fromJson<String>(json['thallaippuVadivu']),
      kaiyoppam: serializer.fromJson<String>(json['kaiyoppam']),
      oppamPeyar: serializer.fromJson<String>(json['oppamPeyar']),
      adaimozhi: serializer.fromJson<Map<String, String>>(json['adaimozhi']),
      upiId: serializer.fromJson<String>(json['upiId']),
      thottranNiram: serializer.fromJson<String>(json['thottranNiram']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seyaliVagai': serializer.toJson<String>(seyaliVagai),
      'mudhanMozhi': serializer.toJson<String>(mudhanMozhi),
      'thunaiMozhi': serializer.toJson<String>(thunaiMozhi),
      'iruMozhi': serializer.toJson<bool>(iruMozhi),
      'niruvanathinPeyar':
          serializer.toJson<Map<String, String>>(niruvanathinPeyar),
      'kurumPeyar': serializer.toJson<String>(kurumPeyar),
      'tholaipesi1': serializer.toJson<String>(tholaipesi1),
      'tholaipesi2': serializer.toJson<String>(tholaipesi2),
      'minnanchal': serializer.toJson<String>(minnanchal),
      'gstin': serializer.toJson<String>(gstin),
      'mugavari': serializer.toJson<Map<String, String>>(mugavari),
      'oor': serializer.toJson<Map<String, String>>(oor),
      'maavattam': serializer.toJson<Map<String, String>>(maavattam),
      'maanilam': serializer.toJson<Map<String, String>>(maanilam),
      'naadu': serializer.toJson<Map<String, String>>(naadu),
      'anchalkuriyeedu': serializer.toJson<String>(anchalkuriyeedu),
      'vangiPeyar': serializer.toJson<Map<String, String>>(vangiPeyar),
      'kilai': serializer.toJson<Map<String, String>>(kilai),
      'vangiKanakku': serializer.toJson<String>(vangiKanakku),
      'ifsc': serializer.toJson<String>(ifsc),
      'ovuru': serializer.toJson<String>(ovuru),
      'agalaOvuru': serializer.toJson<String>(agalaOvuru),
      'thallaippuVadivu': serializer.toJson<String>(thallaippuVadivu),
      'kaiyoppam': serializer.toJson<String>(kaiyoppam),
      'oppamPeyar': serializer.toJson<String>(oppamPeyar),
      'adaimozhi': serializer.toJson<Map<String, String>>(adaimozhi),
      'upiId': serializer.toJson<String>(upiId),
      'thottranNiram': serializer.toJson<String>(thottranNiram),
    };
  }

  VanigaTharavugalEntry copyWith(
          {int? id,
          String? seyaliVagai,
          String? mudhanMozhi,
          String? thunaiMozhi,
          bool? iruMozhi,
          Map<String, String>? niruvanathinPeyar,
          String? kurumPeyar,
          String? tholaipesi1,
          String? tholaipesi2,
          String? minnanchal,
          String? gstin,
          Map<String, String>? mugavari,
          Map<String, String>? oor,
          Map<String, String>? maavattam,
          Map<String, String>? maanilam,
          Map<String, String>? naadu,
          String? anchalkuriyeedu,
          Map<String, String>? vangiPeyar,
          Map<String, String>? kilai,
          String? vangiKanakku,
          String? ifsc,
          String? ovuru,
          String? agalaOvuru,
          String? thallaippuVadivu,
          String? kaiyoppam,
          String? oppamPeyar,
          Map<String, String>? adaimozhi,
          String? upiId,
          String? thottranNiram}) =>
      VanigaTharavugalEntry(
        id: id ?? this.id,
        seyaliVagai: seyaliVagai ?? this.seyaliVagai,
        mudhanMozhi: mudhanMozhi ?? this.mudhanMozhi,
        thunaiMozhi: thunaiMozhi ?? this.thunaiMozhi,
        iruMozhi: iruMozhi ?? this.iruMozhi,
        niruvanathinPeyar: niruvanathinPeyar ?? this.niruvanathinPeyar,
        kurumPeyar: kurumPeyar ?? this.kurumPeyar,
        tholaipesi1: tholaipesi1 ?? this.tholaipesi1,
        tholaipesi2: tholaipesi2 ?? this.tholaipesi2,
        minnanchal: minnanchal ?? this.minnanchal,
        gstin: gstin ?? this.gstin,
        mugavari: mugavari ?? this.mugavari,
        oor: oor ?? this.oor,
        maavattam: maavattam ?? this.maavattam,
        maanilam: maanilam ?? this.maanilam,
        naadu: naadu ?? this.naadu,
        anchalkuriyeedu: anchalkuriyeedu ?? this.anchalkuriyeedu,
        vangiPeyar: vangiPeyar ?? this.vangiPeyar,
        kilai: kilai ?? this.kilai,
        vangiKanakku: vangiKanakku ?? this.vangiKanakku,
        ifsc: ifsc ?? this.ifsc,
        ovuru: ovuru ?? this.ovuru,
        agalaOvuru: agalaOvuru ?? this.agalaOvuru,
        thallaippuVadivu: thallaippuVadivu ?? this.thallaippuVadivu,
        kaiyoppam: kaiyoppam ?? this.kaiyoppam,
        oppamPeyar: oppamPeyar ?? this.oppamPeyar,
        adaimozhi: adaimozhi ?? this.adaimozhi,
        upiId: upiId ?? this.upiId,
        thottranNiram: thottranNiram ?? this.thottranNiram,
      );
  VanigaTharavugalEntry copyWithCompanion(VanigaTharavugalTableCompanion data) {
    return VanigaTharavugalEntry(
      id: data.id.present ? data.id.value : this.id,
      seyaliVagai:
          data.seyaliVagai.present ? data.seyaliVagai.value : this.seyaliVagai,
      mudhanMozhi:
          data.mudhanMozhi.present ? data.mudhanMozhi.value : this.mudhanMozhi,
      thunaiMozhi:
          data.thunaiMozhi.present ? data.thunaiMozhi.value : this.thunaiMozhi,
      iruMozhi: data.iruMozhi.present ? data.iruMozhi.value : this.iruMozhi,
      niruvanathinPeyar: data.niruvanathinPeyar.present
          ? data.niruvanathinPeyar.value
          : this.niruvanathinPeyar,
      kurumPeyar:
          data.kurumPeyar.present ? data.kurumPeyar.value : this.kurumPeyar,
      tholaipesi1:
          data.tholaipesi1.present ? data.tholaipesi1.value : this.tholaipesi1,
      tholaipesi2:
          data.tholaipesi2.present ? data.tholaipesi2.value : this.tholaipesi2,
      minnanchal:
          data.minnanchal.present ? data.minnanchal.value : this.minnanchal,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      mugavari: data.mugavari.present ? data.mugavari.value : this.mugavari,
      oor: data.oor.present ? data.oor.value : this.oor,
      maavattam: data.maavattam.present ? data.maavattam.value : this.maavattam,
      maanilam: data.maanilam.present ? data.maanilam.value : this.maanilam,
      naadu: data.naadu.present ? data.naadu.value : this.naadu,
      anchalkuriyeedu: data.anchalkuriyeedu.present
          ? data.anchalkuriyeedu.value
          : this.anchalkuriyeedu,
      vangiPeyar:
          data.vangiPeyar.present ? data.vangiPeyar.value : this.vangiPeyar,
      kilai: data.kilai.present ? data.kilai.value : this.kilai,
      vangiKanakku: data.vangiKanakku.present
          ? data.vangiKanakku.value
          : this.vangiKanakku,
      ifsc: data.ifsc.present ? data.ifsc.value : this.ifsc,
      ovuru: data.ovuru.present ? data.ovuru.value : this.ovuru,
      agalaOvuru:
          data.agalaOvuru.present ? data.agalaOvuru.value : this.agalaOvuru,
      thallaippuVadivu: data.thallaippuVadivu.present
          ? data.thallaippuVadivu.value
          : this.thallaippuVadivu,
      kaiyoppam: data.kaiyoppam.present ? data.kaiyoppam.value : this.kaiyoppam,
      oppamPeyar:
          data.oppamPeyar.present ? data.oppamPeyar.value : this.oppamPeyar,
      adaimozhi: data.adaimozhi.present ? data.adaimozhi.value : this.adaimozhi,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      thottranNiram: data.thottranNiram.present
          ? data.thottranNiram.value
          : this.thottranNiram,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VanigaTharavugalEntry(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('mudhanMozhi: $mudhanMozhi, ')
          ..write('thunaiMozhi: $thunaiMozhi, ')
          ..write('iruMozhi: $iruMozhi, ')
          ..write('niruvanathinPeyar: $niruvanathinPeyar, ')
          ..write('kurumPeyar: $kurumPeyar, ')
          ..write('tholaipesi1: $tholaipesi1, ')
          ..write('tholaipesi2: $tholaipesi2, ')
          ..write('minnanchal: $minnanchal, ')
          ..write('gstin: $gstin, ')
          ..write('mugavari: $mugavari, ')
          ..write('oor: $oor, ')
          ..write('maavattam: $maavattam, ')
          ..write('maanilam: $maanilam, ')
          ..write('naadu: $naadu, ')
          ..write('anchalkuriyeedu: $anchalkuriyeedu, ')
          ..write('vangiPeyar: $vangiPeyar, ')
          ..write('kilai: $kilai, ')
          ..write('vangiKanakku: $vangiKanakku, ')
          ..write('ifsc: $ifsc, ')
          ..write('ovuru: $ovuru, ')
          ..write('agalaOvuru: $agalaOvuru, ')
          ..write('thallaippuVadivu: $thallaippuVadivu, ')
          ..write('kaiyoppam: $kaiyoppam, ')
          ..write('oppamPeyar: $oppamPeyar, ')
          ..write('adaimozhi: $adaimozhi, ')
          ..write('upiId: $upiId, ')
          ..write('thottranNiram: $thottranNiram')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        seyaliVagai,
        mudhanMozhi,
        thunaiMozhi,
        iruMozhi,
        niruvanathinPeyar,
        kurumPeyar,
        tholaipesi1,
        tholaipesi2,
        minnanchal,
        gstin,
        mugavari,
        oor,
        maavattam,
        maanilam,
        naadu,
        anchalkuriyeedu,
        vangiPeyar,
        kilai,
        vangiKanakku,
        ifsc,
        ovuru,
        agalaOvuru,
        thallaippuVadivu,
        kaiyoppam,
        oppamPeyar,
        adaimozhi,
        upiId,
        thottranNiram
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VanigaTharavugalEntry &&
          other.id == this.id &&
          other.seyaliVagai == this.seyaliVagai &&
          other.mudhanMozhi == this.mudhanMozhi &&
          other.thunaiMozhi == this.thunaiMozhi &&
          other.iruMozhi == this.iruMozhi &&
          other.niruvanathinPeyar == this.niruvanathinPeyar &&
          other.kurumPeyar == this.kurumPeyar &&
          other.tholaipesi1 == this.tholaipesi1 &&
          other.tholaipesi2 == this.tholaipesi2 &&
          other.minnanchal == this.minnanchal &&
          other.gstin == this.gstin &&
          other.mugavari == this.mugavari &&
          other.oor == this.oor &&
          other.maavattam == this.maavattam &&
          other.maanilam == this.maanilam &&
          other.naadu == this.naadu &&
          other.anchalkuriyeedu == this.anchalkuriyeedu &&
          other.vangiPeyar == this.vangiPeyar &&
          other.kilai == this.kilai &&
          other.vangiKanakku == this.vangiKanakku &&
          other.ifsc == this.ifsc &&
          other.ovuru == this.ovuru &&
          other.agalaOvuru == this.agalaOvuru &&
          other.thallaippuVadivu == this.thallaippuVadivu &&
          other.kaiyoppam == this.kaiyoppam &&
          other.oppamPeyar == this.oppamPeyar &&
          other.adaimozhi == this.adaimozhi &&
          other.upiId == this.upiId &&
          other.thottranNiram == this.thottranNiram);
}

class VanigaTharavugalTableCompanion
    extends UpdateCompanion<VanigaTharavugalEntry> {
  final Value<int> id;
  final Value<String> seyaliVagai;
  final Value<String> mudhanMozhi;
  final Value<String> thunaiMozhi;
  final Value<bool> iruMozhi;
  final Value<Map<String, String>> niruvanathinPeyar;
  final Value<String> kurumPeyar;
  final Value<String> tholaipesi1;
  final Value<String> tholaipesi2;
  final Value<String> minnanchal;
  final Value<String> gstin;
  final Value<Map<String, String>> mugavari;
  final Value<Map<String, String>> oor;
  final Value<Map<String, String>> maavattam;
  final Value<Map<String, String>> maanilam;
  final Value<Map<String, String>> naadu;
  final Value<String> anchalkuriyeedu;
  final Value<Map<String, String>> vangiPeyar;
  final Value<Map<String, String>> kilai;
  final Value<String> vangiKanakku;
  final Value<String> ifsc;
  final Value<String> ovuru;
  final Value<String> agalaOvuru;
  final Value<String> thallaippuVadivu;
  final Value<String> kaiyoppam;
  final Value<String> oppamPeyar;
  final Value<Map<String, String>> adaimozhi;
  final Value<String> upiId;
  final Value<String> thottranNiram;
  const VanigaTharavugalTableCompanion({
    this.id = const Value.absent(),
    this.seyaliVagai = const Value.absent(),
    this.mudhanMozhi = const Value.absent(),
    this.thunaiMozhi = const Value.absent(),
    this.iruMozhi = const Value.absent(),
    this.niruvanathinPeyar = const Value.absent(),
    this.kurumPeyar = const Value.absent(),
    this.tholaipesi1 = const Value.absent(),
    this.tholaipesi2 = const Value.absent(),
    this.minnanchal = const Value.absent(),
    this.gstin = const Value.absent(),
    this.mugavari = const Value.absent(),
    this.oor = const Value.absent(),
    this.maavattam = const Value.absent(),
    this.maanilam = const Value.absent(),
    this.naadu = const Value.absent(),
    this.anchalkuriyeedu = const Value.absent(),
    this.vangiPeyar = const Value.absent(),
    this.kilai = const Value.absent(),
    this.vangiKanakku = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.ovuru = const Value.absent(),
    this.agalaOvuru = const Value.absent(),
    this.thallaippuVadivu = const Value.absent(),
    this.kaiyoppam = const Value.absent(),
    this.oppamPeyar = const Value.absent(),
    this.adaimozhi = const Value.absent(),
    this.upiId = const Value.absent(),
    this.thottranNiram = const Value.absent(),
  });
  VanigaTharavugalTableCompanion.insert({
    this.id = const Value.absent(),
    required String seyaliVagai,
    this.mudhanMozhi = const Value.absent(),
    this.thunaiMozhi = const Value.absent(),
    this.iruMozhi = const Value.absent(),
    this.niruvanathinPeyar = const Value.absent(),
    this.kurumPeyar = const Value.absent(),
    this.tholaipesi1 = const Value.absent(),
    this.tholaipesi2 = const Value.absent(),
    this.minnanchal = const Value.absent(),
    this.gstin = const Value.absent(),
    this.mugavari = const Value.absent(),
    this.oor = const Value.absent(),
    this.maavattam = const Value.absent(),
    this.maanilam = const Value.absent(),
    this.naadu = const Value.absent(),
    this.anchalkuriyeedu = const Value.absent(),
    this.vangiPeyar = const Value.absent(),
    this.kilai = const Value.absent(),
    this.vangiKanakku = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.ovuru = const Value.absent(),
    this.agalaOvuru = const Value.absent(),
    this.thallaippuVadivu = const Value.absent(),
    this.kaiyoppam = const Value.absent(),
    this.oppamPeyar = const Value.absent(),
    this.adaimozhi = const Value.absent(),
    this.upiId = const Value.absent(),
    this.thottranNiram = const Value.absent(),
  }) : seyaliVagai = Value(seyaliVagai);
  static Insertable<VanigaTharavugalEntry> custom({
    Expression<int>? id,
    Expression<String>? seyaliVagai,
    Expression<String>? mudhanMozhi,
    Expression<String>? thunaiMozhi,
    Expression<bool>? iruMozhi,
    Expression<String>? niruvanathinPeyar,
    Expression<String>? kurumPeyar,
    Expression<String>? tholaipesi1,
    Expression<String>? tholaipesi2,
    Expression<String>? minnanchal,
    Expression<String>? gstin,
    Expression<String>? mugavari,
    Expression<String>? oor,
    Expression<String>? maavattam,
    Expression<String>? maanilam,
    Expression<String>? naadu,
    Expression<String>? anchalkuriyeedu,
    Expression<String>? vangiPeyar,
    Expression<String>? kilai,
    Expression<String>? vangiKanakku,
    Expression<String>? ifsc,
    Expression<String>? ovuru,
    Expression<String>? agalaOvuru,
    Expression<String>? thallaippuVadivu,
    Expression<String>? kaiyoppam,
    Expression<String>? oppamPeyar,
    Expression<String>? adaimozhi,
    Expression<String>? upiId,
    Expression<String>? thottranNiram,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seyaliVagai != null) 'seyali_vagai': seyaliVagai,
      if (mudhanMozhi != null) 'mudhan_mozhi': mudhanMozhi,
      if (thunaiMozhi != null) 'thunai_mozhi': thunaiMozhi,
      if (iruMozhi != null) 'iru_mozhi': iruMozhi,
      if (niruvanathinPeyar != null) 'niruvanathin_peyar': niruvanathinPeyar,
      if (kurumPeyar != null) 'kurum_peyar': kurumPeyar,
      if (tholaipesi1 != null) 'tholaipesi1': tholaipesi1,
      if (tholaipesi2 != null) 'tholaipesi2': tholaipesi2,
      if (minnanchal != null) 'minnanchal': minnanchal,
      if (gstin != null) 'gstin': gstin,
      if (mugavari != null) 'mugavari': mugavari,
      if (oor != null) 'oor': oor,
      if (maavattam != null) 'maavattam': maavattam,
      if (maanilam != null) 'maanilam': maanilam,
      if (naadu != null) 'naadu': naadu,
      if (anchalkuriyeedu != null) 'anchalkuriyeedu': anchalkuriyeedu,
      if (vangiPeyar != null) 'vangi_peyar': vangiPeyar,
      if (kilai != null) 'kilai': kilai,
      if (vangiKanakku != null) 'vangi_kanakku': vangiKanakku,
      if (ifsc != null) 'ifsc': ifsc,
      if (ovuru != null) 'ovuru': ovuru,
      if (agalaOvuru != null) 'agala_ovuru': agalaOvuru,
      if (thallaippuVadivu != null) 'thallaippu_vadivu': thallaippuVadivu,
      if (kaiyoppam != null) 'kaiyoppam': kaiyoppam,
      if (oppamPeyar != null) 'oppam_peyar': oppamPeyar,
      if (adaimozhi != null) 'adaimozhi': adaimozhi,
      if (upiId != null) 'upi_id': upiId,
      if (thottranNiram != null) 'thottran_niram': thottranNiram,
    });
  }

  VanigaTharavugalTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? seyaliVagai,
      Value<String>? mudhanMozhi,
      Value<String>? thunaiMozhi,
      Value<bool>? iruMozhi,
      Value<Map<String, String>>? niruvanathinPeyar,
      Value<String>? kurumPeyar,
      Value<String>? tholaipesi1,
      Value<String>? tholaipesi2,
      Value<String>? minnanchal,
      Value<String>? gstin,
      Value<Map<String, String>>? mugavari,
      Value<Map<String, String>>? oor,
      Value<Map<String, String>>? maavattam,
      Value<Map<String, String>>? maanilam,
      Value<Map<String, String>>? naadu,
      Value<String>? anchalkuriyeedu,
      Value<Map<String, String>>? vangiPeyar,
      Value<Map<String, String>>? kilai,
      Value<String>? vangiKanakku,
      Value<String>? ifsc,
      Value<String>? ovuru,
      Value<String>? agalaOvuru,
      Value<String>? thallaippuVadivu,
      Value<String>? kaiyoppam,
      Value<String>? oppamPeyar,
      Value<Map<String, String>>? adaimozhi,
      Value<String>? upiId,
      Value<String>? thottranNiram}) {
    return VanigaTharavugalTableCompanion(
      id: id ?? this.id,
      seyaliVagai: seyaliVagai ?? this.seyaliVagai,
      mudhanMozhi: mudhanMozhi ?? this.mudhanMozhi,
      thunaiMozhi: thunaiMozhi ?? this.thunaiMozhi,
      iruMozhi: iruMozhi ?? this.iruMozhi,
      niruvanathinPeyar: niruvanathinPeyar ?? this.niruvanathinPeyar,
      kurumPeyar: kurumPeyar ?? this.kurumPeyar,
      tholaipesi1: tholaipesi1 ?? this.tholaipesi1,
      tholaipesi2: tholaipesi2 ?? this.tholaipesi2,
      minnanchal: minnanchal ?? this.minnanchal,
      gstin: gstin ?? this.gstin,
      mugavari: mugavari ?? this.mugavari,
      oor: oor ?? this.oor,
      maavattam: maavattam ?? this.maavattam,
      maanilam: maanilam ?? this.maanilam,
      naadu: naadu ?? this.naadu,
      anchalkuriyeedu: anchalkuriyeedu ?? this.anchalkuriyeedu,
      vangiPeyar: vangiPeyar ?? this.vangiPeyar,
      kilai: kilai ?? this.kilai,
      vangiKanakku: vangiKanakku ?? this.vangiKanakku,
      ifsc: ifsc ?? this.ifsc,
      ovuru: ovuru ?? this.ovuru,
      agalaOvuru: agalaOvuru ?? this.agalaOvuru,
      thallaippuVadivu: thallaippuVadivu ?? this.thallaippuVadivu,
      kaiyoppam: kaiyoppam ?? this.kaiyoppam,
      oppamPeyar: oppamPeyar ?? this.oppamPeyar,
      adaimozhi: adaimozhi ?? this.adaimozhi,
      upiId: upiId ?? this.upiId,
      thottranNiram: thottranNiram ?? this.thottranNiram,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seyaliVagai.present) {
      map['seyali_vagai'] = Variable<String>(seyaliVagai.value);
    }
    if (mudhanMozhi.present) {
      map['mudhan_mozhi'] = Variable<String>(mudhanMozhi.value);
    }
    if (thunaiMozhi.present) {
      map['thunai_mozhi'] = Variable<String>(thunaiMozhi.value);
    }
    if (iruMozhi.present) {
      map['iru_mozhi'] = Variable<bool>(iruMozhi.value);
    }
    if (niruvanathinPeyar.present) {
      map['niruvanathin_peyar'] = Variable<String>($VanigaTharavugalTableTable
          .$converterniruvanathinPeyar
          .toSql(niruvanathinPeyar.value));
    }
    if (kurumPeyar.present) {
      map['kurum_peyar'] = Variable<String>(kurumPeyar.value);
    }
    if (tholaipesi1.present) {
      map['tholaipesi1'] = Variable<String>(tholaipesi1.value);
    }
    if (tholaipesi2.present) {
      map['tholaipesi2'] = Variable<String>(tholaipesi2.value);
    }
    if (minnanchal.present) {
      map['minnanchal'] = Variable<String>(minnanchal.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (mugavari.present) {
      map['mugavari'] = Variable<String>(
          $VanigaTharavugalTableTable.$convertermugavari.toSql(mugavari.value));
    }
    if (oor.present) {
      map['oor'] = Variable<String>(
          $VanigaTharavugalTableTable.$converteroor.toSql(oor.value));
    }
    if (maavattam.present) {
      map['maavattam'] = Variable<String>($VanigaTharavugalTableTable
          .$convertermaavattam
          .toSql(maavattam.value));
    }
    if (maanilam.present) {
      map['maanilam'] = Variable<String>(
          $VanigaTharavugalTableTable.$convertermaanilam.toSql(maanilam.value));
    }
    if (naadu.present) {
      map['naadu'] = Variable<String>(
          $VanigaTharavugalTableTable.$converternaadu.toSql(naadu.value));
    }
    if (anchalkuriyeedu.present) {
      map['anchalkuriyeedu'] = Variable<String>(anchalkuriyeedu.value);
    }
    if (vangiPeyar.present) {
      map['vangi_peyar'] = Variable<String>($VanigaTharavugalTableTable
          .$convertervangiPeyar
          .toSql(vangiPeyar.value));
    }
    if (kilai.present) {
      map['kilai'] = Variable<String>(
          $VanigaTharavugalTableTable.$converterkilai.toSql(kilai.value));
    }
    if (vangiKanakku.present) {
      map['vangi_kanakku'] = Variable<String>(vangiKanakku.value);
    }
    if (ifsc.present) {
      map['ifsc'] = Variable<String>(ifsc.value);
    }
    if (ovuru.present) {
      map['ovuru'] = Variable<String>(ovuru.value);
    }
    if (agalaOvuru.present) {
      map['agala_ovuru'] = Variable<String>(agalaOvuru.value);
    }
    if (thallaippuVadivu.present) {
      map['thallaippu_vadivu'] = Variable<String>(thallaippuVadivu.value);
    }
    if (kaiyoppam.present) {
      map['kaiyoppam'] = Variable<String>(kaiyoppam.value);
    }
    if (oppamPeyar.present) {
      map['oppam_peyar'] = Variable<String>(oppamPeyar.value);
    }
    if (adaimozhi.present) {
      map['adaimozhi'] = Variable<String>($VanigaTharavugalTableTable
          .$converteradaimozhi
          .toSql(adaimozhi.value));
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (thottranNiram.present) {
      map['thottran_niram'] = Variable<String>(thottranNiram.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VanigaTharavugalTableCompanion(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('mudhanMozhi: $mudhanMozhi, ')
          ..write('thunaiMozhi: $thunaiMozhi, ')
          ..write('iruMozhi: $iruMozhi, ')
          ..write('niruvanathinPeyar: $niruvanathinPeyar, ')
          ..write('kurumPeyar: $kurumPeyar, ')
          ..write('tholaipesi1: $tholaipesi1, ')
          ..write('tholaipesi2: $tholaipesi2, ')
          ..write('minnanchal: $minnanchal, ')
          ..write('gstin: $gstin, ')
          ..write('mugavari: $mugavari, ')
          ..write('oor: $oor, ')
          ..write('maavattam: $maavattam, ')
          ..write('maanilam: $maanilam, ')
          ..write('naadu: $naadu, ')
          ..write('anchalkuriyeedu: $anchalkuriyeedu, ')
          ..write('vangiPeyar: $vangiPeyar, ')
          ..write('kilai: $kilai, ')
          ..write('vangiKanakku: $vangiKanakku, ')
          ..write('ifsc: $ifsc, ')
          ..write('ovuru: $ovuru, ')
          ..write('agalaOvuru: $agalaOvuru, ')
          ..write('thallaippuVadivu: $thallaippuVadivu, ')
          ..write('kaiyoppam: $kaiyoppam, ')
          ..write('oppamPeyar: $oppamPeyar, ')
          ..write('adaimozhi: $adaimozhi, ')
          ..write('upiId: $upiId, ')
          ..write('thottranNiram: $thottranNiram')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VanigaTharavugalTableTable vanigaTharavugalTable =
      $VanigaTharavugalTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [vanigaTharavugalTable];
}

typedef $$VanigaTharavugalTableTableCreateCompanionBuilder
    = VanigaTharavugalTableCompanion Function({
  Value<int> id,
  required String seyaliVagai,
  Value<String> mudhanMozhi,
  Value<String> thunaiMozhi,
  Value<bool> iruMozhi,
  Value<Map<String, String>> niruvanathinPeyar,
  Value<String> kurumPeyar,
  Value<String> tholaipesi1,
  Value<String> tholaipesi2,
  Value<String> minnanchal,
  Value<String> gstin,
  Value<Map<String, String>> mugavari,
  Value<Map<String, String>> oor,
  Value<Map<String, String>> maavattam,
  Value<Map<String, String>> maanilam,
  Value<Map<String, String>> naadu,
  Value<String> anchalkuriyeedu,
  Value<Map<String, String>> vangiPeyar,
  Value<Map<String, String>> kilai,
  Value<String> vangiKanakku,
  Value<String> ifsc,
  Value<String> ovuru,
  Value<String> agalaOvuru,
  Value<String> thallaippuVadivu,
  Value<String> kaiyoppam,
  Value<String> oppamPeyar,
  Value<Map<String, String>> adaimozhi,
  Value<String> upiId,
  Value<String> thottranNiram,
});
typedef $$VanigaTharavugalTableTableUpdateCompanionBuilder
    = VanigaTharavugalTableCompanion Function({
  Value<int> id,
  Value<String> seyaliVagai,
  Value<String> mudhanMozhi,
  Value<String> thunaiMozhi,
  Value<bool> iruMozhi,
  Value<Map<String, String>> niruvanathinPeyar,
  Value<String> kurumPeyar,
  Value<String> tholaipesi1,
  Value<String> tholaipesi2,
  Value<String> minnanchal,
  Value<String> gstin,
  Value<Map<String, String>> mugavari,
  Value<Map<String, String>> oor,
  Value<Map<String, String>> maavattam,
  Value<Map<String, String>> maanilam,
  Value<Map<String, String>> naadu,
  Value<String> anchalkuriyeedu,
  Value<Map<String, String>> vangiPeyar,
  Value<Map<String, String>> kilai,
  Value<String> vangiKanakku,
  Value<String> ifsc,
  Value<String> ovuru,
  Value<String> agalaOvuru,
  Value<String> thallaippuVadivu,
  Value<String> kaiyoppam,
  Value<String> oppamPeyar,
  Value<Map<String, String>> adaimozhi,
  Value<String> upiId,
  Value<String> thottranNiram,
});

class $$VanigaTharavugalTableTableFilterComposer
    extends Composer<_$AppDatabase, $VanigaTharavugalTableTable> {
  $$VanigaTharavugalTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seyaliVagai => $composableBuilder(
      column: $table.seyaliVagai, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mudhanMozhi => $composableBuilder(
      column: $table.mudhanMozhi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thunaiMozhi => $composableBuilder(
      column: $table.thunaiMozhi, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get iruMozhi => $composableBuilder(
      column: $table.iruMozhi, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get niruvanathinPeyar => $composableBuilder(
          column: $table.niruvanathinPeyar,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get kurumPeyar => $composableBuilder(
      column: $table.kurumPeyar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tholaipesi1 => $composableBuilder(
      column: $table.tholaipesi1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tholaipesi2 => $composableBuilder(
      column: $table.tholaipesi2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get minnanchal => $composableBuilder(
      column: $table.minnanchal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get mugavari => $composableBuilder(
          column: $table.mugavari,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get oor => $composableBuilder(
          column: $table.oor,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get maavattam => $composableBuilder(
          column: $table.maavattam,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get maanilam => $composableBuilder(
          column: $table.maanilam,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get naadu => $composableBuilder(
          column: $table.naadu,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get anchalkuriyeedu => $composableBuilder(
      column: $table.anchalkuriyeedu,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get vangiPeyar => $composableBuilder(
          column: $table.vangiPeyar,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get kilai => $composableBuilder(
          column: $table.kilai,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get vangiKanakku => $composableBuilder(
      column: $table.vangiKanakku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ifsc => $composableBuilder(
      column: $table.ifsc, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ovuru => $composableBuilder(
      column: $table.ovuru, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agalaOvuru => $composableBuilder(
      column: $table.agalaOvuru, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thallaippuVadivu => $composableBuilder(
      column: $table.thallaippuVadivu,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kaiyoppam => $composableBuilder(
      column: $table.kaiyoppam, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get oppamPeyar => $composableBuilder(
      column: $table.oppamPeyar, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Map<String, String>, Map<String, String>,
          String>
      get adaimozhi => $composableBuilder(
          column: $table.adaimozhi,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thottranNiram => $composableBuilder(
      column: $table.thottranNiram, builder: (column) => ColumnFilters(column));
}

class $$VanigaTharavugalTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VanigaTharavugalTableTable> {
  $$VanigaTharavugalTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seyaliVagai => $composableBuilder(
      column: $table.seyaliVagai, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mudhanMozhi => $composableBuilder(
      column: $table.mudhanMozhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thunaiMozhi => $composableBuilder(
      column: $table.thunaiMozhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get iruMozhi => $composableBuilder(
      column: $table.iruMozhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get niruvanathinPeyar => $composableBuilder(
      column: $table.niruvanathinPeyar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kurumPeyar => $composableBuilder(
      column: $table.kurumPeyar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tholaipesi1 => $composableBuilder(
      column: $table.tholaipesi1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tholaipesi2 => $composableBuilder(
      column: $table.tholaipesi2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get minnanchal => $composableBuilder(
      column: $table.minnanchal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mugavari => $composableBuilder(
      column: $table.mugavari, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oor => $composableBuilder(
      column: $table.oor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get maavattam => $composableBuilder(
      column: $table.maavattam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get maanilam => $composableBuilder(
      column: $table.maanilam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get naadu => $composableBuilder(
      column: $table.naadu, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get anchalkuriyeedu => $composableBuilder(
      column: $table.anchalkuriyeedu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vangiPeyar => $composableBuilder(
      column: $table.vangiPeyar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kilai => $composableBuilder(
      column: $table.kilai, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vangiKanakku => $composableBuilder(
      column: $table.vangiKanakku,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ifsc => $composableBuilder(
      column: $table.ifsc, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ovuru => $composableBuilder(
      column: $table.ovuru, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agalaOvuru => $composableBuilder(
      column: $table.agalaOvuru, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thallaippuVadivu => $composableBuilder(
      column: $table.thallaippuVadivu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kaiyoppam => $composableBuilder(
      column: $table.kaiyoppam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oppamPeyar => $composableBuilder(
      column: $table.oppamPeyar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adaimozhi => $composableBuilder(
      column: $table.adaimozhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thottranNiram => $composableBuilder(
      column: $table.thottranNiram,
      builder: (column) => ColumnOrderings(column));
}

class $$VanigaTharavugalTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VanigaTharavugalTableTable> {
  $$VanigaTharavugalTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get seyaliVagai => $composableBuilder(
      column: $table.seyaliVagai, builder: (column) => column);

  GeneratedColumn<String> get mudhanMozhi => $composableBuilder(
      column: $table.mudhanMozhi, builder: (column) => column);

  GeneratedColumn<String> get thunaiMozhi => $composableBuilder(
      column: $table.thunaiMozhi, builder: (column) => column);

  GeneratedColumn<bool> get iruMozhi =>
      $composableBuilder(column: $table.iruMozhi, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
      get niruvanathinPeyar => $composableBuilder(
          column: $table.niruvanathinPeyar, builder: (column) => column);

  GeneratedColumn<String> get kurumPeyar => $composableBuilder(
      column: $table.kurumPeyar, builder: (column) => column);

  GeneratedColumn<String> get tholaipesi1 => $composableBuilder(
      column: $table.tholaipesi1, builder: (column) => column);

  GeneratedColumn<String> get tholaipesi2 => $composableBuilder(
      column: $table.tholaipesi2, builder: (column) => column);

  GeneratedColumn<String> get minnanchal => $composableBuilder(
      column: $table.minnanchal, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get mugavari =>
      $composableBuilder(column: $table.mugavari, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get oor =>
      $composableBuilder(column: $table.oor, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get maavattam =>
      $composableBuilder(column: $table.maavattam, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get maanilam =>
      $composableBuilder(column: $table.maanilam, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get naadu =>
      $composableBuilder(column: $table.naadu, builder: (column) => column);

  GeneratedColumn<String> get anchalkuriyeedu => $composableBuilder(
      column: $table.anchalkuriyeedu, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
      get vangiPeyar => $composableBuilder(
          column: $table.vangiPeyar, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get kilai =>
      $composableBuilder(column: $table.kilai, builder: (column) => column);

  GeneratedColumn<String> get vangiKanakku => $composableBuilder(
      column: $table.vangiKanakku, builder: (column) => column);

  GeneratedColumn<String> get ifsc =>
      $composableBuilder(column: $table.ifsc, builder: (column) => column);

  GeneratedColumn<String> get ovuru =>
      $composableBuilder(column: $table.ovuru, builder: (column) => column);

  GeneratedColumn<String> get agalaOvuru => $composableBuilder(
      column: $table.agalaOvuru, builder: (column) => column);

  GeneratedColumn<String> get thallaippuVadivu => $composableBuilder(
      column: $table.thallaippuVadivu, builder: (column) => column);

  GeneratedColumn<String> get kaiyoppam =>
      $composableBuilder(column: $table.kaiyoppam, builder: (column) => column);

  GeneratedColumn<String> get oppamPeyar => $composableBuilder(
      column: $table.oppamPeyar, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get adaimozhi =>
      $composableBuilder(column: $table.adaimozhi, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get thottranNiram => $composableBuilder(
      column: $table.thottranNiram, builder: (column) => column);
}

class $$VanigaTharavugalTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VanigaTharavugalTableTable,
    VanigaTharavugalEntry,
    $$VanigaTharavugalTableTableFilterComposer,
    $$VanigaTharavugalTableTableOrderingComposer,
    $$VanigaTharavugalTableTableAnnotationComposer,
    $$VanigaTharavugalTableTableCreateCompanionBuilder,
    $$VanigaTharavugalTableTableUpdateCompanionBuilder,
    (
      VanigaTharavugalEntry,
      BaseReferences<_$AppDatabase, $VanigaTharavugalTableTable,
          VanigaTharavugalEntry>
    ),
    VanigaTharavugalEntry,
    PrefetchHooks Function()> {
  $$VanigaTharavugalTableTableTableManager(
      _$AppDatabase db, $VanigaTharavugalTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VanigaTharavugalTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$VanigaTharavugalTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VanigaTharavugalTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> seyaliVagai = const Value.absent(),
            Value<String> mudhanMozhi = const Value.absent(),
            Value<String> thunaiMozhi = const Value.absent(),
            Value<bool> iruMozhi = const Value.absent(),
            Value<Map<String, String>> niruvanathinPeyar = const Value.absent(),
            Value<String> kurumPeyar = const Value.absent(),
            Value<String> tholaipesi1 = const Value.absent(),
            Value<String> tholaipesi2 = const Value.absent(),
            Value<String> minnanchal = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<Map<String, String>> mugavari = const Value.absent(),
            Value<Map<String, String>> oor = const Value.absent(),
            Value<Map<String, String>> maavattam = const Value.absent(),
            Value<Map<String, String>> maanilam = const Value.absent(),
            Value<Map<String, String>> naadu = const Value.absent(),
            Value<String> anchalkuriyeedu = const Value.absent(),
            Value<Map<String, String>> vangiPeyar = const Value.absent(),
            Value<Map<String, String>> kilai = const Value.absent(),
            Value<String> vangiKanakku = const Value.absent(),
            Value<String> ifsc = const Value.absent(),
            Value<String> ovuru = const Value.absent(),
            Value<String> agalaOvuru = const Value.absent(),
            Value<String> thallaippuVadivu = const Value.absent(),
            Value<String> kaiyoppam = const Value.absent(),
            Value<String> oppamPeyar = const Value.absent(),
            Value<Map<String, String>> adaimozhi = const Value.absent(),
            Value<String> upiId = const Value.absent(),
            Value<String> thottranNiram = const Value.absent(),
          }) =>
              VanigaTharavugalTableCompanion(
            id: id,
            seyaliVagai: seyaliVagai,
            mudhanMozhi: mudhanMozhi,
            thunaiMozhi: thunaiMozhi,
            iruMozhi: iruMozhi,
            niruvanathinPeyar: niruvanathinPeyar,
            kurumPeyar: kurumPeyar,
            tholaipesi1: tholaipesi1,
            tholaipesi2: tholaipesi2,
            minnanchal: minnanchal,
            gstin: gstin,
            mugavari: mugavari,
            oor: oor,
            maavattam: maavattam,
            maanilam: maanilam,
            naadu: naadu,
            anchalkuriyeedu: anchalkuriyeedu,
            vangiPeyar: vangiPeyar,
            kilai: kilai,
            vangiKanakku: vangiKanakku,
            ifsc: ifsc,
            ovuru: ovuru,
            agalaOvuru: agalaOvuru,
            thallaippuVadivu: thallaippuVadivu,
            kaiyoppam: kaiyoppam,
            oppamPeyar: oppamPeyar,
            adaimozhi: adaimozhi,
            upiId: upiId,
            thottranNiram: thottranNiram,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String seyaliVagai,
            Value<String> mudhanMozhi = const Value.absent(),
            Value<String> thunaiMozhi = const Value.absent(),
            Value<bool> iruMozhi = const Value.absent(),
            Value<Map<String, String>> niruvanathinPeyar = const Value.absent(),
            Value<String> kurumPeyar = const Value.absent(),
            Value<String> tholaipesi1 = const Value.absent(),
            Value<String> tholaipesi2 = const Value.absent(),
            Value<String> minnanchal = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<Map<String, String>> mugavari = const Value.absent(),
            Value<Map<String, String>> oor = const Value.absent(),
            Value<Map<String, String>> maavattam = const Value.absent(),
            Value<Map<String, String>> maanilam = const Value.absent(),
            Value<Map<String, String>> naadu = const Value.absent(),
            Value<String> anchalkuriyeedu = const Value.absent(),
            Value<Map<String, String>> vangiPeyar = const Value.absent(),
            Value<Map<String, String>> kilai = const Value.absent(),
            Value<String> vangiKanakku = const Value.absent(),
            Value<String> ifsc = const Value.absent(),
            Value<String> ovuru = const Value.absent(),
            Value<String> agalaOvuru = const Value.absent(),
            Value<String> thallaippuVadivu = const Value.absent(),
            Value<String> kaiyoppam = const Value.absent(),
            Value<String> oppamPeyar = const Value.absent(),
            Value<Map<String, String>> adaimozhi = const Value.absent(),
            Value<String> upiId = const Value.absent(),
            Value<String> thottranNiram = const Value.absent(),
          }) =>
              VanigaTharavugalTableCompanion.insert(
            id: id,
            seyaliVagai: seyaliVagai,
            mudhanMozhi: mudhanMozhi,
            thunaiMozhi: thunaiMozhi,
            iruMozhi: iruMozhi,
            niruvanathinPeyar: niruvanathinPeyar,
            kurumPeyar: kurumPeyar,
            tholaipesi1: tholaipesi1,
            tholaipesi2: tholaipesi2,
            minnanchal: minnanchal,
            gstin: gstin,
            mugavari: mugavari,
            oor: oor,
            maavattam: maavattam,
            maanilam: maanilam,
            naadu: naadu,
            anchalkuriyeedu: anchalkuriyeedu,
            vangiPeyar: vangiPeyar,
            kilai: kilai,
            vangiKanakku: vangiKanakku,
            ifsc: ifsc,
            ovuru: ovuru,
            agalaOvuru: agalaOvuru,
            thallaippuVadivu: thallaippuVadivu,
            kaiyoppam: kaiyoppam,
            oppamPeyar: oppamPeyar,
            adaimozhi: adaimozhi,
            upiId: upiId,
            thottranNiram: thottranNiram,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VanigaTharavugalTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $VanigaTharavugalTableTable,
        VanigaTharavugalEntry,
        $$VanigaTharavugalTableTableFilterComposer,
        $$VanigaTharavugalTableTableOrderingComposer,
        $$VanigaTharavugalTableTableAnnotationComposer,
        $$VanigaTharavugalTableTableCreateCompanionBuilder,
        $$VanigaTharavugalTableTableUpdateCompanionBuilder,
        (
          VanigaTharavugalEntry,
          BaseReferences<_$AppDatabase, $VanigaTharavugalTableTable,
              VanigaTharavugalEntry>
        ),
        VanigaTharavugalEntry,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VanigaTharavugalTableTableTableManager get vanigaTharavugalTable =>
      $$VanigaTharavugalTableTableTableManager(_db, _db.vanigaTharavugalTable);
}

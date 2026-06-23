// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seyali_tharavuthalam.dart';

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
  static const VerificationMeta _tholaipaesi1Meta =
      const VerificationMeta('tholaipaesi1');
  @override
  late final GeneratedColumn<String> tholaipaesi1 = GeneratedColumn<String>(
      'tholaipaesi1', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _tholaipaesi2Meta =
      const VerificationMeta('tholaipaesi2');
  @override
  late final GeneratedColumn<String> tholaipaesi2 = GeneratedColumn<String>(
      'tholaipaesi2', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _minnanjalMeta =
      const VerificationMeta('minnanjal');
  @override
  late final GeneratedColumn<String> minnanjal = GeneratedColumn<String>(
      'minnanjal', aliasedName, false,
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
  static const VerificationMeta _anjalKuriyeeduMeta =
      const VerificationMeta('anjalKuriyeedu');
  @override
  late final GeneratedColumn<String> anjalKuriyeedu = GeneratedColumn<String>(
      'anjal_kuriyeedu', aliasedName, false,
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
  static const VerificationMeta _oavuruMeta = const VerificationMeta('oavuru');
  @override
  late final GeneratedColumn<String> oavuru = GeneratedColumn<String>(
      'oavuru', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _agalaOavuruMeta =
      const VerificationMeta('agalaOavuru');
  @override
  late final GeneratedColumn<String> agalaOavuru = GeneratedColumn<String>(
      'agala_oavuru', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _thalaippuVadivuMeta =
      const VerificationMeta('thalaippuVadivu');
  @override
  late final GeneratedColumn<String> thalaippuVadivu = GeneratedColumn<String>(
      'thalaippu_vadivu', aliasedName, false,
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
  static const VerificationMeta _thoatraNiramMeta =
      const VerificationMeta('thoatraNiram');
  @override
  late final GeneratedColumn<String> thoatraNiram = GeneratedColumn<String>(
      'thoatra_niram', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seyaliVagai,
        mudhanMozhi,
        thunaiMozhi,
        iruMozhi,
        niruvanathinPeyar,
        kurumPeyar,
        tholaipaesi1,
        tholaipaesi2,
        minnanjal,
        gstin,
        mugavari,
        oor,
        maavattam,
        maanilam,
        naadu,
        anjalKuriyeedu,
        vangiPeyar,
        kilai,
        vangiKanakku,
        ifsc,
        oavuru,
        agalaOavuru,
        thalaippuVadivu,
        kaiyoppam,
        oppamPeyar,
        adaimozhi,
        upiId,
        thoatraNiram,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt
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
    if (data.containsKey('tholaipaesi1')) {
      context.handle(
          _tholaipaesi1Meta,
          tholaipaesi1.isAcceptableOrUnknown(
              data['tholaipaesi1']!, _tholaipaesi1Meta));
    }
    if (data.containsKey('tholaipaesi2')) {
      context.handle(
          _tholaipaesi2Meta,
          tholaipaesi2.isAcceptableOrUnknown(
              data['tholaipaesi2']!, _tholaipaesi2Meta));
    }
    if (data.containsKey('minnanjal')) {
      context.handle(_minnanjalMeta,
          minnanjal.isAcceptableOrUnknown(data['minnanjal']!, _minnanjalMeta));
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    }
    if (data.containsKey('anjal_kuriyeedu')) {
      context.handle(
          _anjalKuriyeeduMeta,
          anjalKuriyeedu.isAcceptableOrUnknown(
              data['anjal_kuriyeedu']!, _anjalKuriyeeduMeta));
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
    if (data.containsKey('oavuru')) {
      context.handle(_oavuruMeta,
          oavuru.isAcceptableOrUnknown(data['oavuru']!, _oavuruMeta));
    }
    if (data.containsKey('agala_oavuru')) {
      context.handle(
          _agalaOavuruMeta,
          agalaOavuru.isAcceptableOrUnknown(
              data['agala_oavuru']!, _agalaOavuruMeta));
    }
    if (data.containsKey('thalaippu_vadivu')) {
      context.handle(
          _thalaippuVadivuMeta,
          thalaippuVadivu.isAcceptableOrUnknown(
              data['thalaippu_vadivu']!, _thalaippuVadivuMeta));
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
    if (data.containsKey('thoatra_niram')) {
      context.handle(
          _thoatraNiramMeta,
          thoatraNiram.isAcceptableOrUnknown(
              data['thoatra_niram']!, _thoatraNiramMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
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
      tholaipaesi1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tholaipaesi1'])!,
      tholaipaesi2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tholaipaesi2'])!,
      minnanjal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}minnanjal'])!,
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
      anjalKuriyeedu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}anjal_kuriyeedu'])!,
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
      oavuru: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}oavuru'])!,
      agalaOavuru: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agala_oavuru'])!,
      thalaippuVadivu: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}thalaippu_vadivu'])!,
      kaiyoppam: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kaiyoppam'])!,
      oppamPeyar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}oppam_peyar'])!,
      adaimozhi: $VanigaTharavugalTableTable.$converteradaimozhi.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.string, data['${effectivePrefix}adaimozhi'])!),
      upiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upi_id'])!,
      thoatraNiram: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thoatra_niram'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
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
  final String tholaipaesi1;
  final String tholaipaesi2;
  final String minnanjal;
  final String gstin;
  final Map<String, String> mugavari;
  final Map<String, String> oor;
  final Map<String, String> maavattam;
  final Map<String, String> maanilam;
  final Map<String, String> naadu;
  final String anjalKuriyeedu;
  final Map<String, String> vangiPeyar;
  final Map<String, String> kilai;
  final String vangiKanakku;
  final String ifsc;
  final String oavuru;
  final String agalaOavuru;
  final String thalaippuVadivu;
  final String kaiyoppam;
  final String oppamPeyar;
  final Map<String, String> adaimozhi;
  final String upiId;
  final String thoatraNiram;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  const VanigaTharavugalEntry(
      {required this.id,
      required this.seyaliVagai,
      required this.mudhanMozhi,
      required this.thunaiMozhi,
      required this.iruMozhi,
      required this.niruvanathinPeyar,
      required this.kurumPeyar,
      required this.tholaipaesi1,
      required this.tholaipaesi2,
      required this.minnanjal,
      required this.gstin,
      required this.mugavari,
      required this.oor,
      required this.maavattam,
      required this.maanilam,
      required this.naadu,
      required this.anjalKuriyeedu,
      required this.vangiPeyar,
      required this.kilai,
      required this.vangiKanakku,
      required this.ifsc,
      required this.oavuru,
      required this.agalaOavuru,
      required this.thalaippuVadivu,
      required this.kaiyoppam,
      required this.oppamPeyar,
      required this.adaimozhi,
      required this.upiId,
      required this.thoatraNiram,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt});
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
    map['tholaipaesi1'] = Variable<String>(tholaipaesi1);
    map['tholaipaesi2'] = Variable<String>(tholaipaesi2);
    map['minnanjal'] = Variable<String>(minnanjal);
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
    map['anjal_kuriyeedu'] = Variable<String>(anjalKuriyeedu);
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
    map['oavuru'] = Variable<String>(oavuru);
    map['agala_oavuru'] = Variable<String>(agalaOavuru);
    map['thalaippu_vadivu'] = Variable<String>(thalaippuVadivu);
    map['kaiyoppam'] = Variable<String>(kaiyoppam);
    map['oppam_peyar'] = Variable<String>(oppamPeyar);
    {
      map['adaimozhi'] = Variable<String>(
          $VanigaTharavugalTableTable.$converteradaimozhi.toSql(adaimozhi));
    }
    map['upi_id'] = Variable<String>(upiId);
    map['thoatra_niram'] = Variable<String>(thoatraNiram);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
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
      tholaipaesi1: Value(tholaipaesi1),
      tholaipaesi2: Value(tholaipaesi2),
      minnanjal: Value(minnanjal),
      gstin: Value(gstin),
      mugavari: Value(mugavari),
      oor: Value(oor),
      maavattam: Value(maavattam),
      maanilam: Value(maanilam),
      naadu: Value(naadu),
      anjalKuriyeedu: Value(anjalKuriyeedu),
      vangiPeyar: Value(vangiPeyar),
      kilai: Value(kilai),
      vangiKanakku: Value(vangiKanakku),
      ifsc: Value(ifsc),
      oavuru: Value(oavuru),
      agalaOavuru: Value(agalaOavuru),
      thalaippuVadivu: Value(thalaippuVadivu),
      kaiyoppam: Value(kaiyoppam),
      oppamPeyar: Value(oppamPeyar),
      adaimozhi: Value(adaimozhi),
      upiId: Value(upiId),
      thoatraNiram: Value(thoatraNiram),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
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
      tholaipaesi1: serializer.fromJson<String>(json['tholaipaesi1']),
      tholaipaesi2: serializer.fromJson<String>(json['tholaipaesi2']),
      minnanjal: serializer.fromJson<String>(json['minnanjal']),
      gstin: serializer.fromJson<String>(json['gstin']),
      mugavari: serializer.fromJson<Map<String, String>>(json['mugavari']),
      oor: serializer.fromJson<Map<String, String>>(json['oor']),
      maavattam: serializer.fromJson<Map<String, String>>(json['maavattam']),
      maanilam: serializer.fromJson<Map<String, String>>(json['maanilam']),
      naadu: serializer.fromJson<Map<String, String>>(json['naadu']),
      anjalKuriyeedu: serializer.fromJson<String>(json['anjalKuriyeedu']),
      vangiPeyar: serializer.fromJson<Map<String, String>>(json['vangiPeyar']),
      kilai: serializer.fromJson<Map<String, String>>(json['kilai']),
      vangiKanakku: serializer.fromJson<String>(json['vangiKanakku']),
      ifsc: serializer.fromJson<String>(json['ifsc']),
      oavuru: serializer.fromJson<String>(json['oavuru']),
      agalaOavuru: serializer.fromJson<String>(json['agalaOavuru']),
      thalaippuVadivu: serializer.fromJson<String>(json['thalaippuVadivu']),
      kaiyoppam: serializer.fromJson<String>(json['kaiyoppam']),
      oppamPeyar: serializer.fromJson<String>(json['oppamPeyar']),
      adaimozhi: serializer.fromJson<Map<String, String>>(json['adaimozhi']),
      upiId: serializer.fromJson<String>(json['upiId']),
      thoatraNiram: serializer.fromJson<String>(json['thoatraNiram']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
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
      'tholaipaesi1': serializer.toJson<String>(tholaipaesi1),
      'tholaipaesi2': serializer.toJson<String>(tholaipaesi2),
      'minnanjal': serializer.toJson<String>(minnanjal),
      'gstin': serializer.toJson<String>(gstin),
      'mugavari': serializer.toJson<Map<String, String>>(mugavari),
      'oor': serializer.toJson<Map<String, String>>(oor),
      'maavattam': serializer.toJson<Map<String, String>>(maavattam),
      'maanilam': serializer.toJson<Map<String, String>>(maanilam),
      'naadu': serializer.toJson<Map<String, String>>(naadu),
      'anjalKuriyeedu': serializer.toJson<String>(anjalKuriyeedu),
      'vangiPeyar': serializer.toJson<Map<String, String>>(vangiPeyar),
      'kilai': serializer.toJson<Map<String, String>>(kilai),
      'vangiKanakku': serializer.toJson<String>(vangiKanakku),
      'ifsc': serializer.toJson<String>(ifsc),
      'oavuru': serializer.toJson<String>(oavuru),
      'agalaOavuru': serializer.toJson<String>(agalaOavuru),
      'thalaippuVadivu': serializer.toJson<String>(thalaippuVadivu),
      'kaiyoppam': serializer.toJson<String>(kaiyoppam),
      'oppamPeyar': serializer.toJson<String>(oppamPeyar),
      'adaimozhi': serializer.toJson<Map<String, String>>(adaimozhi),
      'upiId': serializer.toJson<String>(upiId),
      'thoatraNiram': serializer.toJson<String>(thoatraNiram),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
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
          String? tholaipaesi1,
          String? tholaipaesi2,
          String? minnanjal,
          String? gstin,
          Map<String, String>? mugavari,
          Map<String, String>? oor,
          Map<String, String>? maavattam,
          Map<String, String>? maanilam,
          Map<String, String>? naadu,
          String? anjalKuriyeedu,
          Map<String, String>? vangiPeyar,
          Map<String, String>? kilai,
          String? vangiKanakku,
          String? ifsc,
          String? oavuru,
          String? agalaOavuru,
          String? thalaippuVadivu,
          String? kaiyoppam,
          String? oppamPeyar,
          Map<String, String>? adaimozhi,
          String? upiId,
          String? thoatraNiram,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      VanigaTharavugalEntry(
        id: id ?? this.id,
        seyaliVagai: seyaliVagai ?? this.seyaliVagai,
        mudhanMozhi: mudhanMozhi ?? this.mudhanMozhi,
        thunaiMozhi: thunaiMozhi ?? this.thunaiMozhi,
        iruMozhi: iruMozhi ?? this.iruMozhi,
        niruvanathinPeyar: niruvanathinPeyar ?? this.niruvanathinPeyar,
        kurumPeyar: kurumPeyar ?? this.kurumPeyar,
        tholaipaesi1: tholaipaesi1 ?? this.tholaipaesi1,
        tholaipaesi2: tholaipaesi2 ?? this.tholaipaesi2,
        minnanjal: minnanjal ?? this.minnanjal,
        gstin: gstin ?? this.gstin,
        mugavari: mugavari ?? this.mugavari,
        oor: oor ?? this.oor,
        maavattam: maavattam ?? this.maavattam,
        maanilam: maanilam ?? this.maanilam,
        naadu: naadu ?? this.naadu,
        anjalKuriyeedu: anjalKuriyeedu ?? this.anjalKuriyeedu,
        vangiPeyar: vangiPeyar ?? this.vangiPeyar,
        kilai: kilai ?? this.kilai,
        vangiKanakku: vangiKanakku ?? this.vangiKanakku,
        ifsc: ifsc ?? this.ifsc,
        oavuru: oavuru ?? this.oavuru,
        agalaOavuru: agalaOavuru ?? this.agalaOavuru,
        thalaippuVadivu: thalaippuVadivu ?? this.thalaippuVadivu,
        kaiyoppam: kaiyoppam ?? this.kaiyoppam,
        oppamPeyar: oppamPeyar ?? this.oppamPeyar,
        adaimozhi: adaimozhi ?? this.adaimozhi,
        upiId: upiId ?? this.upiId,
        thoatraNiram: thoatraNiram ?? this.thoatraNiram,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
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
      tholaipaesi1: data.tholaipaesi1.present
          ? data.tholaipaesi1.value
          : this.tholaipaesi1,
      tholaipaesi2: data.tholaipaesi2.present
          ? data.tholaipaesi2.value
          : this.tholaipaesi2,
      minnanjal: data.minnanjal.present ? data.minnanjal.value : this.minnanjal,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      mugavari: data.mugavari.present ? data.mugavari.value : this.mugavari,
      oor: data.oor.present ? data.oor.value : this.oor,
      maavattam: data.maavattam.present ? data.maavattam.value : this.maavattam,
      maanilam: data.maanilam.present ? data.maanilam.value : this.maanilam,
      naadu: data.naadu.present ? data.naadu.value : this.naadu,
      anjalKuriyeedu: data.anjalKuriyeedu.present
          ? data.anjalKuriyeedu.value
          : this.anjalKuriyeedu,
      vangiPeyar:
          data.vangiPeyar.present ? data.vangiPeyar.value : this.vangiPeyar,
      kilai: data.kilai.present ? data.kilai.value : this.kilai,
      vangiKanakku: data.vangiKanakku.present
          ? data.vangiKanakku.value
          : this.vangiKanakku,
      ifsc: data.ifsc.present ? data.ifsc.value : this.ifsc,
      oavuru: data.oavuru.present ? data.oavuru.value : this.oavuru,
      agalaOavuru:
          data.agalaOavuru.present ? data.agalaOavuru.value : this.agalaOavuru,
      thalaippuVadivu: data.thalaippuVadivu.present
          ? data.thalaippuVadivu.value
          : this.thalaippuVadivu,
      kaiyoppam: data.kaiyoppam.present ? data.kaiyoppam.value : this.kaiyoppam,
      oppamPeyar:
          data.oppamPeyar.present ? data.oppamPeyar.value : this.oppamPeyar,
      adaimozhi: data.adaimozhi.present ? data.adaimozhi.value : this.adaimozhi,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      thoatraNiram: data.thoatraNiram.present
          ? data.thoatraNiram.value
          : this.thoatraNiram,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
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
          ..write('tholaipaesi1: $tholaipaesi1, ')
          ..write('tholaipaesi2: $tholaipaesi2, ')
          ..write('minnanjal: $minnanjal, ')
          ..write('gstin: $gstin, ')
          ..write('mugavari: $mugavari, ')
          ..write('oor: $oor, ')
          ..write('maavattam: $maavattam, ')
          ..write('maanilam: $maanilam, ')
          ..write('naadu: $naadu, ')
          ..write('anjalKuriyeedu: $anjalKuriyeedu, ')
          ..write('vangiPeyar: $vangiPeyar, ')
          ..write('kilai: $kilai, ')
          ..write('vangiKanakku: $vangiKanakku, ')
          ..write('ifsc: $ifsc, ')
          ..write('oavuru: $oavuru, ')
          ..write('agalaOavuru: $agalaOavuru, ')
          ..write('thalaippuVadivu: $thalaippuVadivu, ')
          ..write('kaiyoppam: $kaiyoppam, ')
          ..write('oppamPeyar: $oppamPeyar, ')
          ..write('adaimozhi: $adaimozhi, ')
          ..write('upiId: $upiId, ')
          ..write('thoatraNiram: $thoatraNiram, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
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
        tholaipaesi1,
        tholaipaesi2,
        minnanjal,
        gstin,
        mugavari,
        oor,
        maavattam,
        maanilam,
        naadu,
        anjalKuriyeedu,
        vangiPeyar,
        kilai,
        vangiKanakku,
        ifsc,
        oavuru,
        agalaOavuru,
        thalaippuVadivu,
        kaiyoppam,
        oppamPeyar,
        adaimozhi,
        upiId,
        thoatraNiram,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt
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
          other.tholaipaesi1 == this.tholaipaesi1 &&
          other.tholaipaesi2 == this.tholaipaesi2 &&
          other.minnanjal == this.minnanjal &&
          other.gstin == this.gstin &&
          other.mugavari == this.mugavari &&
          other.oor == this.oor &&
          other.maavattam == this.maavattam &&
          other.maanilam == this.maanilam &&
          other.naadu == this.naadu &&
          other.anjalKuriyeedu == this.anjalKuriyeedu &&
          other.vangiPeyar == this.vangiPeyar &&
          other.kilai == this.kilai &&
          other.vangiKanakku == this.vangiKanakku &&
          other.ifsc == this.ifsc &&
          other.oavuru == this.oavuru &&
          other.agalaOavuru == this.agalaOavuru &&
          other.thalaippuVadivu == this.thalaippuVadivu &&
          other.kaiyoppam == this.kaiyoppam &&
          other.oppamPeyar == this.oppamPeyar &&
          other.adaimozhi == this.adaimozhi &&
          other.upiId == this.upiId &&
          other.thoatraNiram == this.thoatraNiram &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt);
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
  final Value<String> tholaipaesi1;
  final Value<String> tholaipaesi2;
  final Value<String> minnanjal;
  final Value<String> gstin;
  final Value<Map<String, String>> mugavari;
  final Value<Map<String, String>> oor;
  final Value<Map<String, String>> maavattam;
  final Value<Map<String, String>> maanilam;
  final Value<Map<String, String>> naadu;
  final Value<String> anjalKuriyeedu;
  final Value<Map<String, String>> vangiPeyar;
  final Value<Map<String, String>> kilai;
  final Value<String> vangiKanakku;
  final Value<String> ifsc;
  final Value<String> oavuru;
  final Value<String> agalaOavuru;
  final Value<String> thalaippuVadivu;
  final Value<String> kaiyoppam;
  final Value<String> oppamPeyar;
  final Value<Map<String, String>> adaimozhi;
  final Value<String> upiId;
  final Value<String> thoatraNiram;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  const VanigaTharavugalTableCompanion({
    this.id = const Value.absent(),
    this.seyaliVagai = const Value.absent(),
    this.mudhanMozhi = const Value.absent(),
    this.thunaiMozhi = const Value.absent(),
    this.iruMozhi = const Value.absent(),
    this.niruvanathinPeyar = const Value.absent(),
    this.kurumPeyar = const Value.absent(),
    this.tholaipaesi1 = const Value.absent(),
    this.tholaipaesi2 = const Value.absent(),
    this.minnanjal = const Value.absent(),
    this.gstin = const Value.absent(),
    this.mugavari = const Value.absent(),
    this.oor = const Value.absent(),
    this.maavattam = const Value.absent(),
    this.maanilam = const Value.absent(),
    this.naadu = const Value.absent(),
    this.anjalKuriyeedu = const Value.absent(),
    this.vangiPeyar = const Value.absent(),
    this.kilai = const Value.absent(),
    this.vangiKanakku = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.oavuru = const Value.absent(),
    this.agalaOavuru = const Value.absent(),
    this.thalaippuVadivu = const Value.absent(),
    this.kaiyoppam = const Value.absent(),
    this.oppamPeyar = const Value.absent(),
    this.adaimozhi = const Value.absent(),
    this.upiId = const Value.absent(),
    this.thoatraNiram = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  VanigaTharavugalTableCompanion.insert({
    this.id = const Value.absent(),
    required String seyaliVagai,
    this.mudhanMozhi = const Value.absent(),
    this.thunaiMozhi = const Value.absent(),
    this.iruMozhi = const Value.absent(),
    this.niruvanathinPeyar = const Value.absent(),
    this.kurumPeyar = const Value.absent(),
    this.tholaipaesi1 = const Value.absent(),
    this.tholaipaesi2 = const Value.absent(),
    this.minnanjal = const Value.absent(),
    this.gstin = const Value.absent(),
    this.mugavari = const Value.absent(),
    this.oor = const Value.absent(),
    this.maavattam = const Value.absent(),
    this.maanilam = const Value.absent(),
    this.naadu = const Value.absent(),
    this.anjalKuriyeedu = const Value.absent(),
    this.vangiPeyar = const Value.absent(),
    this.kilai = const Value.absent(),
    this.vangiKanakku = const Value.absent(),
    this.ifsc = const Value.absent(),
    this.oavuru = const Value.absent(),
    this.agalaOavuru = const Value.absent(),
    this.thalaippuVadivu = const Value.absent(),
    this.kaiyoppam = const Value.absent(),
    this.oppamPeyar = const Value.absent(),
    this.adaimozhi = const Value.absent(),
    this.upiId = const Value.absent(),
    this.thoatraNiram = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : seyaliVagai = Value(seyaliVagai);
  static Insertable<VanigaTharavugalEntry> custom({
    Expression<int>? id,
    Expression<String>? seyaliVagai,
    Expression<String>? mudhanMozhi,
    Expression<String>? thunaiMozhi,
    Expression<bool>? iruMozhi,
    Expression<String>? niruvanathinPeyar,
    Expression<String>? kurumPeyar,
    Expression<String>? tholaipaesi1,
    Expression<String>? tholaipaesi2,
    Expression<String>? minnanjal,
    Expression<String>? gstin,
    Expression<String>? mugavari,
    Expression<String>? oor,
    Expression<String>? maavattam,
    Expression<String>? maanilam,
    Expression<String>? naadu,
    Expression<String>? anjalKuriyeedu,
    Expression<String>? vangiPeyar,
    Expression<String>? kilai,
    Expression<String>? vangiKanakku,
    Expression<String>? ifsc,
    Expression<String>? oavuru,
    Expression<String>? agalaOavuru,
    Expression<String>? thalaippuVadivu,
    Expression<String>? kaiyoppam,
    Expression<String>? oppamPeyar,
    Expression<String>? adaimozhi,
    Expression<String>? upiId,
    Expression<String>? thoatraNiram,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seyaliVagai != null) 'seyali_vagai': seyaliVagai,
      if (mudhanMozhi != null) 'mudhan_mozhi': mudhanMozhi,
      if (thunaiMozhi != null) 'thunai_mozhi': thunaiMozhi,
      if (iruMozhi != null) 'iru_mozhi': iruMozhi,
      if (niruvanathinPeyar != null) 'niruvanathin_peyar': niruvanathinPeyar,
      if (kurumPeyar != null) 'kurum_peyar': kurumPeyar,
      if (tholaipaesi1 != null) 'tholaipaesi1': tholaipaesi1,
      if (tholaipaesi2 != null) 'tholaipaesi2': tholaipaesi2,
      if (minnanjal != null) 'minnanjal': minnanjal,
      if (gstin != null) 'gstin': gstin,
      if (mugavari != null) 'mugavari': mugavari,
      if (oor != null) 'oor': oor,
      if (maavattam != null) 'maavattam': maavattam,
      if (maanilam != null) 'maanilam': maanilam,
      if (naadu != null) 'naadu': naadu,
      if (anjalKuriyeedu != null) 'anjal_kuriyeedu': anjalKuriyeedu,
      if (vangiPeyar != null) 'vangi_peyar': vangiPeyar,
      if (kilai != null) 'kilai': kilai,
      if (vangiKanakku != null) 'vangi_kanakku': vangiKanakku,
      if (ifsc != null) 'ifsc': ifsc,
      if (oavuru != null) 'oavuru': oavuru,
      if (agalaOavuru != null) 'agala_oavuru': agalaOavuru,
      if (thalaippuVadivu != null) 'thalaippu_vadivu': thalaippuVadivu,
      if (kaiyoppam != null) 'kaiyoppam': kaiyoppam,
      if (oppamPeyar != null) 'oppam_peyar': oppamPeyar,
      if (adaimozhi != null) 'adaimozhi': adaimozhi,
      if (upiId != null) 'upi_id': upiId,
      if (thoatraNiram != null) 'thoatra_niram': thoatraNiram,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
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
      Value<String>? tholaipaesi1,
      Value<String>? tholaipaesi2,
      Value<String>? minnanjal,
      Value<String>? gstin,
      Value<Map<String, String>>? mugavari,
      Value<Map<String, String>>? oor,
      Value<Map<String, String>>? maavattam,
      Value<Map<String, String>>? maanilam,
      Value<Map<String, String>>? naadu,
      Value<String>? anjalKuriyeedu,
      Value<Map<String, String>>? vangiPeyar,
      Value<Map<String, String>>? kilai,
      Value<String>? vangiKanakku,
      Value<String>? ifsc,
      Value<String>? oavuru,
      Value<String>? agalaOavuru,
      Value<String>? thalaippuVadivu,
      Value<String>? kaiyoppam,
      Value<String>? oppamPeyar,
      Value<Map<String, String>>? adaimozhi,
      Value<String>? upiId,
      Value<String>? thoatraNiram,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt}) {
    return VanigaTharavugalTableCompanion(
      id: id ?? this.id,
      seyaliVagai: seyaliVagai ?? this.seyaliVagai,
      mudhanMozhi: mudhanMozhi ?? this.mudhanMozhi,
      thunaiMozhi: thunaiMozhi ?? this.thunaiMozhi,
      iruMozhi: iruMozhi ?? this.iruMozhi,
      niruvanathinPeyar: niruvanathinPeyar ?? this.niruvanathinPeyar,
      kurumPeyar: kurumPeyar ?? this.kurumPeyar,
      tholaipaesi1: tholaipaesi1 ?? this.tholaipaesi1,
      tholaipaesi2: tholaipaesi2 ?? this.tholaipaesi2,
      minnanjal: minnanjal ?? this.minnanjal,
      gstin: gstin ?? this.gstin,
      mugavari: mugavari ?? this.mugavari,
      oor: oor ?? this.oor,
      maavattam: maavattam ?? this.maavattam,
      maanilam: maanilam ?? this.maanilam,
      naadu: naadu ?? this.naadu,
      anjalKuriyeedu: anjalKuriyeedu ?? this.anjalKuriyeedu,
      vangiPeyar: vangiPeyar ?? this.vangiPeyar,
      kilai: kilai ?? this.kilai,
      vangiKanakku: vangiKanakku ?? this.vangiKanakku,
      ifsc: ifsc ?? this.ifsc,
      oavuru: oavuru ?? this.oavuru,
      agalaOavuru: agalaOavuru ?? this.agalaOavuru,
      thalaippuVadivu: thalaippuVadivu ?? this.thalaippuVadivu,
      kaiyoppam: kaiyoppam ?? this.kaiyoppam,
      oppamPeyar: oppamPeyar ?? this.oppamPeyar,
      adaimozhi: adaimozhi ?? this.adaimozhi,
      upiId: upiId ?? this.upiId,
      thoatraNiram: thoatraNiram ?? this.thoatraNiram,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (tholaipaesi1.present) {
      map['tholaipaesi1'] = Variable<String>(tholaipaesi1.value);
    }
    if (tholaipaesi2.present) {
      map['tholaipaesi2'] = Variable<String>(tholaipaesi2.value);
    }
    if (minnanjal.present) {
      map['minnanjal'] = Variable<String>(minnanjal.value);
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
    if (anjalKuriyeedu.present) {
      map['anjal_kuriyeedu'] = Variable<String>(anjalKuriyeedu.value);
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
    if (oavuru.present) {
      map['oavuru'] = Variable<String>(oavuru.value);
    }
    if (agalaOavuru.present) {
      map['agala_oavuru'] = Variable<String>(agalaOavuru.value);
    }
    if (thalaippuVadivu.present) {
      map['thalaippu_vadivu'] = Variable<String>(thalaippuVadivu.value);
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
    if (thoatraNiram.present) {
      map['thoatra_niram'] = Variable<String>(thoatraNiram.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
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
          ..write('tholaipaesi1: $tholaipaesi1, ')
          ..write('tholaipaesi2: $tholaipaesi2, ')
          ..write('minnanjal: $minnanjal, ')
          ..write('gstin: $gstin, ')
          ..write('mugavari: $mugavari, ')
          ..write('oor: $oor, ')
          ..write('maavattam: $maavattam, ')
          ..write('maanilam: $maanilam, ')
          ..write('naadu: $naadu, ')
          ..write('anjalKuriyeedu: $anjalKuriyeedu, ')
          ..write('vangiPeyar: $vangiPeyar, ')
          ..write('kilai: $kilai, ')
          ..write('vangiKanakku: $vangiKanakku, ')
          ..write('ifsc: $ifsc, ')
          ..write('oavuru: $oavuru, ')
          ..write('agalaOavuru: $agalaOavuru, ')
          ..write('thalaippuVadivu: $thalaippuVadivu, ')
          ..write('kaiyoppam: $kaiyoppam, ')
          ..write('oppamPeyar: $oppamPeyar, ')
          ..write('adaimozhi: $adaimozhi, ')
          ..write('upiId: $upiId, ')
          ..write('thoatraNiram: $thoatraNiram, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $VanigarTableTable extends VanigarTable
    with TableInfo<$VanigarTableTable, VanigarEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VanigarTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _peyarMeta = const VerificationMeta('peyar');
  @override
  late final GeneratedColumn<String> peyar = GeneratedColumn<String>(
      'peyar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tholaipaesiMeta =
      const VerificationMeta('tholaipaesi');
  @override
  late final GeneratedColumn<String> tholaipaesi = GeneratedColumn<String>(
      'tholaipaesi', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _mugavariMeta =
      const VerificationMeta('mugavari');
  @override
  late final GeneratedColumn<String> mugavari = GeneratedColumn<String>(
      'mugavari', aliasedName, false,
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seyaliVagai,
        peyar,
        tholaipaesi,
        mugavari,
        gstin,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vanigar_table';
  @override
  VerificationContext validateIntegrity(Insertable<VanigarEntry> instance,
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
    if (data.containsKey('peyar')) {
      context.handle(
          _peyarMeta, peyar.isAcceptableOrUnknown(data['peyar']!, _peyarMeta));
    } else if (isInserting) {
      context.missing(_peyarMeta);
    }
    if (data.containsKey('tholaipaesi')) {
      context.handle(
          _tholaipaesiMeta,
          tholaipaesi.isAcceptableOrUnknown(
              data['tholaipaesi']!, _tholaipaesiMeta));
    }
    if (data.containsKey('mugavari')) {
      context.handle(_mugavariMeta,
          mugavari.isAcceptableOrUnknown(data['mugavari']!, _mugavariMeta));
    }
    if (data.containsKey('gstin')) {
      context.handle(
          _gstinMeta, gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VanigarEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VanigarEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seyaliVagai: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seyali_vagai'])!,
      peyar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}peyar'])!,
      tholaipaesi: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tholaipaesi'])!,
      mugavari: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mugavari'])!,
      gstin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gstin'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $VanigarTableTable createAlias(String alias) {
    return $VanigarTableTable(attachedDatabase, alias);
  }
}

class VanigarEntry extends DataClass implements Insertable<VanigarEntry> {
  final int id;
  final String seyaliVagai;
  final String peyar;
  final String tholaipaesi;
  final String mugavari;
  final String gstin;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  const VanigarEntry(
      {required this.id,
      required this.seyaliVagai,
      required this.peyar,
      required this.tholaipaesi,
      required this.mugavari,
      required this.gstin,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seyali_vagai'] = Variable<String>(seyaliVagai);
    map['peyar'] = Variable<String>(peyar);
    map['tholaipaesi'] = Variable<String>(tholaipaesi);
    map['mugavari'] = Variable<String>(mugavari);
    map['gstin'] = Variable<String>(gstin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  VanigarTableCompanion toCompanion(bool nullToAbsent) {
    return VanigarTableCompanion(
      id: Value(id),
      seyaliVagai: Value(seyaliVagai),
      peyar: Value(peyar),
      tholaipaesi: Value(tholaipaesi),
      mugavari: Value(mugavari),
      gstin: Value(gstin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory VanigarEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VanigarEntry(
      id: serializer.fromJson<int>(json['id']),
      seyaliVagai: serializer.fromJson<String>(json['seyaliVagai']),
      peyar: serializer.fromJson<String>(json['peyar']),
      tholaipaesi: serializer.fromJson<String>(json['tholaipaesi']),
      mugavari: serializer.fromJson<String>(json['mugavari']),
      gstin: serializer.fromJson<String>(json['gstin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seyaliVagai': serializer.toJson<String>(seyaliVagai),
      'peyar': serializer.toJson<String>(peyar),
      'tholaipaesi': serializer.toJson<String>(tholaipaesi),
      'mugavari': serializer.toJson<String>(mugavari),
      'gstin': serializer.toJson<String>(gstin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  VanigarEntry copyWith(
          {int? id,
          String? seyaliVagai,
          String? peyar,
          String? tholaipaesi,
          String? mugavari,
          String? gstin,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      VanigarEntry(
        id: id ?? this.id,
        seyaliVagai: seyaliVagai ?? this.seyaliVagai,
        peyar: peyar ?? this.peyar,
        tholaipaesi: tholaipaesi ?? this.tholaipaesi,
        mugavari: mugavari ?? this.mugavari,
        gstin: gstin ?? this.gstin,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  VanigarEntry copyWithCompanion(VanigarTableCompanion data) {
    return VanigarEntry(
      id: data.id.present ? data.id.value : this.id,
      seyaliVagai:
          data.seyaliVagai.present ? data.seyaliVagai.value : this.seyaliVagai,
      peyar: data.peyar.present ? data.peyar.value : this.peyar,
      tholaipaesi:
          data.tholaipaesi.present ? data.tholaipaesi.value : this.tholaipaesi,
      mugavari: data.mugavari.present ? data.mugavari.value : this.mugavari,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VanigarEntry(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('peyar: $peyar, ')
          ..write('tholaipaesi: $tholaipaesi, ')
          ..write('mugavari: $mugavari, ')
          ..write('gstin: $gstin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seyaliVagai, peyar, tholaipaesi, mugavari,
      gstin, createdAt, updatedAt, isDeleted, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VanigarEntry &&
          other.id == this.id &&
          other.seyaliVagai == this.seyaliVagai &&
          other.peyar == this.peyar &&
          other.tholaipaesi == this.tholaipaesi &&
          other.mugavari == this.mugavari &&
          other.gstin == this.gstin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt);
}

class VanigarTableCompanion extends UpdateCompanion<VanigarEntry> {
  final Value<int> id;
  final Value<String> seyaliVagai;
  final Value<String> peyar;
  final Value<String> tholaipaesi;
  final Value<String> mugavari;
  final Value<String> gstin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  const VanigarTableCompanion({
    this.id = const Value.absent(),
    this.seyaliVagai = const Value.absent(),
    this.peyar = const Value.absent(),
    this.tholaipaesi = const Value.absent(),
    this.mugavari = const Value.absent(),
    this.gstin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  VanigarTableCompanion.insert({
    this.id = const Value.absent(),
    required String seyaliVagai,
    required String peyar,
    this.tholaipaesi = const Value.absent(),
    this.mugavari = const Value.absent(),
    this.gstin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : seyaliVagai = Value(seyaliVagai),
        peyar = Value(peyar);
  static Insertable<VanigarEntry> custom({
    Expression<int>? id,
    Expression<String>? seyaliVagai,
    Expression<String>? peyar,
    Expression<String>? tholaipaesi,
    Expression<String>? mugavari,
    Expression<String>? gstin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seyaliVagai != null) 'seyali_vagai': seyaliVagai,
      if (peyar != null) 'peyar': peyar,
      if (tholaipaesi != null) 'tholaipaesi': tholaipaesi,
      if (mugavari != null) 'mugavari': mugavari,
      if (gstin != null) 'gstin': gstin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  VanigarTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? seyaliVagai,
      Value<String>? peyar,
      Value<String>? tholaipaesi,
      Value<String>? mugavari,
      Value<String>? gstin,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt}) {
    return VanigarTableCompanion(
      id: id ?? this.id,
      seyaliVagai: seyaliVagai ?? this.seyaliVagai,
      peyar: peyar ?? this.peyar,
      tholaipaesi: tholaipaesi ?? this.tholaipaesi,
      mugavari: mugavari ?? this.mugavari,
      gstin: gstin ?? this.gstin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (peyar.present) {
      map['peyar'] = Variable<String>(peyar.value);
    }
    if (tholaipaesi.present) {
      map['tholaipaesi'] = Variable<String>(tholaipaesi.value);
    }
    if (mugavari.present) {
      map['mugavari'] = Variable<String>(mugavari.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VanigarTableCompanion(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('peyar: $peyar, ')
          ..write('tholaipaesi: $tholaipaesi, ')
          ..write('mugavari: $mugavari, ')
          ..write('gstin: $gstin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PorulTableTable extends PorulTable
    with TableInfo<$PorulTableTable, PorulEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PorulTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _porulPeyarMeta =
      const VerificationMeta('porulPeyar');
  @override
  late final GeneratedColumn<String> porulPeyar = GeneratedColumn<String>(
      'porul_peyar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hsnCodeMeta =
      const VerificationMeta('hsnCode');
  @override
  late final GeneratedColumn<String> hsnCode = GeneratedColumn<String>(
      'hsn_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _vilaiMeta = const VerificationMeta('vilai');
  @override
  late final GeneratedColumn<double> vilai = GeneratedColumn<double>(
      'vilai', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _variVeethamMeta =
      const VerificationMeta('variVeetham');
  @override
  late final GeneratedColumn<double> variVeetham = GeneratedColumn<double>(
      'vari_veetham', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seyaliVagai,
        porulPeyar,
        hsnCode,
        vilai,
        variVeetham,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'porul_table';
  @override
  VerificationContext validateIntegrity(Insertable<PorulEntry> instance,
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
    if (data.containsKey('porul_peyar')) {
      context.handle(
          _porulPeyarMeta,
          porulPeyar.isAcceptableOrUnknown(
              data['porul_peyar']!, _porulPeyarMeta));
    } else if (isInserting) {
      context.missing(_porulPeyarMeta);
    }
    if (data.containsKey('hsn_code')) {
      context.handle(_hsnCodeMeta,
          hsnCode.isAcceptableOrUnknown(data['hsn_code']!, _hsnCodeMeta));
    }
    if (data.containsKey('vilai')) {
      context.handle(
          _vilaiMeta, vilai.isAcceptableOrUnknown(data['vilai']!, _vilaiMeta));
    }
    if (data.containsKey('vari_veetham')) {
      context.handle(
          _variVeethamMeta,
          variVeetham.isAcceptableOrUnknown(
              data['vari_veetham']!, _variVeethamMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PorulEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PorulEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seyaliVagai: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seyali_vagai'])!,
      porulPeyar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}porul_peyar'])!,
      hsnCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hsn_code'])!,
      vilai: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vilai'])!,
      variVeetham: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}vari_veetham'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PorulTableTable createAlias(String alias) {
    return $PorulTableTable(attachedDatabase, alias);
  }
}

class PorulEntry extends DataClass implements Insertable<PorulEntry> {
  final int id;
  final String seyaliVagai;
  final String porulPeyar;
  final String hsnCode;
  final double vilai;
  final double variVeetham;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  const PorulEntry(
      {required this.id,
      required this.seyaliVagai,
      required this.porulPeyar,
      required this.hsnCode,
      required this.vilai,
      required this.variVeetham,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seyali_vagai'] = Variable<String>(seyaliVagai);
    map['porul_peyar'] = Variable<String>(porulPeyar);
    map['hsn_code'] = Variable<String>(hsnCode);
    map['vilai'] = Variable<double>(vilai);
    map['vari_veetham'] = Variable<double>(variVeetham);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PorulTableCompanion toCompanion(bool nullToAbsent) {
    return PorulTableCompanion(
      id: Value(id),
      seyaliVagai: Value(seyaliVagai),
      porulPeyar: Value(porulPeyar),
      hsnCode: Value(hsnCode),
      vilai: Value(vilai),
      variVeetham: Value(variVeetham),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PorulEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PorulEntry(
      id: serializer.fromJson<int>(json['id']),
      seyaliVagai: serializer.fromJson<String>(json['seyaliVagai']),
      porulPeyar: serializer.fromJson<String>(json['porulPeyar']),
      hsnCode: serializer.fromJson<String>(json['hsnCode']),
      vilai: serializer.fromJson<double>(json['vilai']),
      variVeetham: serializer.fromJson<double>(json['variVeetham']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seyaliVagai': serializer.toJson<String>(seyaliVagai),
      'porulPeyar': serializer.toJson<String>(porulPeyar),
      'hsnCode': serializer.toJson<String>(hsnCode),
      'vilai': serializer.toJson<double>(vilai),
      'variVeetham': serializer.toJson<double>(variVeetham),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PorulEntry copyWith(
          {int? id,
          String? seyaliVagai,
          String? porulPeyar,
          String? hsnCode,
          double? vilai,
          double? variVeetham,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      PorulEntry(
        id: id ?? this.id,
        seyaliVagai: seyaliVagai ?? this.seyaliVagai,
        porulPeyar: porulPeyar ?? this.porulPeyar,
        hsnCode: hsnCode ?? this.hsnCode,
        vilai: vilai ?? this.vilai,
        variVeetham: variVeetham ?? this.variVeetham,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  PorulEntry copyWithCompanion(PorulTableCompanion data) {
    return PorulEntry(
      id: data.id.present ? data.id.value : this.id,
      seyaliVagai:
          data.seyaliVagai.present ? data.seyaliVagai.value : this.seyaliVagai,
      porulPeyar:
          data.porulPeyar.present ? data.porulPeyar.value : this.porulPeyar,
      hsnCode: data.hsnCode.present ? data.hsnCode.value : this.hsnCode,
      vilai: data.vilai.present ? data.vilai.value : this.vilai,
      variVeetham:
          data.variVeetham.present ? data.variVeetham.value : this.variVeetham,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PorulEntry(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('porulPeyar: $porulPeyar, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('vilai: $vilai, ')
          ..write('variVeetham: $variVeetham, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, seyaliVagai, porulPeyar, hsnCode, vilai,
      variVeetham, createdAt, updatedAt, isDeleted, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PorulEntry &&
          other.id == this.id &&
          other.seyaliVagai == this.seyaliVagai &&
          other.porulPeyar == this.porulPeyar &&
          other.hsnCode == this.hsnCode &&
          other.vilai == this.vilai &&
          other.variVeetham == this.variVeetham &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt);
}

class PorulTableCompanion extends UpdateCompanion<PorulEntry> {
  final Value<int> id;
  final Value<String> seyaliVagai;
  final Value<String> porulPeyar;
  final Value<String> hsnCode;
  final Value<double> vilai;
  final Value<double> variVeetham;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  const PorulTableCompanion({
    this.id = const Value.absent(),
    this.seyaliVagai = const Value.absent(),
    this.porulPeyar = const Value.absent(),
    this.hsnCode = const Value.absent(),
    this.vilai = const Value.absent(),
    this.variVeetham = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PorulTableCompanion.insert({
    this.id = const Value.absent(),
    required String seyaliVagai,
    required String porulPeyar,
    this.hsnCode = const Value.absent(),
    this.vilai = const Value.absent(),
    this.variVeetham = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : seyaliVagai = Value(seyaliVagai),
        porulPeyar = Value(porulPeyar);
  static Insertable<PorulEntry> custom({
    Expression<int>? id,
    Expression<String>? seyaliVagai,
    Expression<String>? porulPeyar,
    Expression<String>? hsnCode,
    Expression<double>? vilai,
    Expression<double>? variVeetham,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seyaliVagai != null) 'seyali_vagai': seyaliVagai,
      if (porulPeyar != null) 'porul_peyar': porulPeyar,
      if (hsnCode != null) 'hsn_code': hsnCode,
      if (vilai != null) 'vilai': vilai,
      if (variVeetham != null) 'vari_veetham': variVeetham,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PorulTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? seyaliVagai,
      Value<String>? porulPeyar,
      Value<String>? hsnCode,
      Value<double>? vilai,
      Value<double>? variVeetham,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt}) {
    return PorulTableCompanion(
      id: id ?? this.id,
      seyaliVagai: seyaliVagai ?? this.seyaliVagai,
      porulPeyar: porulPeyar ?? this.porulPeyar,
      hsnCode: hsnCode ?? this.hsnCode,
      vilai: vilai ?? this.vilai,
      variVeetham: variVeetham ?? this.variVeetham,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (porulPeyar.present) {
      map['porul_peyar'] = Variable<String>(porulPeyar.value);
    }
    if (hsnCode.present) {
      map['hsn_code'] = Variable<String>(hsnCode.value);
    }
    if (vilai.present) {
      map['vilai'] = Variable<double>(vilai.value);
    }
    if (variVeetham.present) {
      map['vari_veetham'] = Variable<double>(variVeetham.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PorulTableCompanion(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('porulPeyar: $porulPeyar, ')
          ..write('hsnCode: $hsnCode, ')
          ..write('vilai: $vilai, ')
          ..write('variVeetham: $variVeetham, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $PatrucheettuTableTable extends PatrucheettuTable
    with TableInfo<$PatrucheettuTableTable, PatrucheettuEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatrucheettuTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _patrucheettuEnMeta =
      const VerificationMeta('patrucheettuEn');
  @override
  late final GeneratedColumn<String> patrucheettuEn = GeneratedColumn<String>(
      'patrucheettu_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _finYearMeta =
      const VerificationMeta('finYear');
  @override
  late final GeneratedColumn<int> finYear = GeneratedColumn<int>(
      'fin_year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _vanigarIdMeta =
      const VerificationMeta('vanigarId');
  @override
  late final GeneratedColumn<int> vanigarId = GeneratedColumn<int>(
      'vanigar_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _vanigarPeyarMeta =
      const VerificationMeta('vanigarPeyar');
  @override
  late final GeneratedColumn<String> vanigarPeyar = GeneratedColumn<String>(
      'vanigar_peyar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _vanigarTholaipaesiMeta =
      const VerificationMeta('vanigarTholaipaesi');
  @override
  late final GeneratedColumn<String> vanigarTholaipaesi =
      GeneratedColumn<String>('vanigar_tholaipaesi', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant(''));
  static const VerificationMeta _mothaThogaiMeta =
      const VerificationMeta('mothaThogai');
  @override
  late final GeneratedColumn<double> mothaThogai = GeneratedColumn<double>(
      'motha_thogai', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _tharavugalMeta =
      const VerificationMeta('tharavugal');
  @override
  late final GeneratedColumn<String> tharavugal = GeneratedColumn<String>(
      'tharavugal', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        seyaliVagai,
        patrucheettuEn,
        finYear,
        vanigarId,
        vanigarPeyar,
        vanigarTholaipaesi,
        mothaThogai,
        tharavugal,
        createdAt,
        updatedAt,
        isDeleted,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patrucheettu_table';
  @override
  VerificationContext validateIntegrity(Insertable<PatrucheettuEntry> instance,
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
    if (data.containsKey('patrucheettu_en')) {
      context.handle(
          _patrucheettuEnMeta,
          patrucheettuEn.isAcceptableOrUnknown(
              data['patrucheettu_en']!, _patrucheettuEnMeta));
    } else if (isInserting) {
      context.missing(_patrucheettuEnMeta);
    }
    if (data.containsKey('fin_year')) {
      context.handle(_finYearMeta,
          finYear.isAcceptableOrUnknown(data['fin_year']!, _finYearMeta));
    } else if (isInserting) {
      context.missing(_finYearMeta);
    }
    if (data.containsKey('vanigar_id')) {
      context.handle(_vanigarIdMeta,
          vanigarId.isAcceptableOrUnknown(data['vanigar_id']!, _vanigarIdMeta));
    }
    if (data.containsKey('vanigar_peyar')) {
      context.handle(
          _vanigarPeyarMeta,
          vanigarPeyar.isAcceptableOrUnknown(
              data['vanigar_peyar']!, _vanigarPeyarMeta));
    } else if (isInserting) {
      context.missing(_vanigarPeyarMeta);
    }
    if (data.containsKey('vanigar_tholaipaesi')) {
      context.handle(
          _vanigarTholaipaesiMeta,
          vanigarTholaipaesi.isAcceptableOrUnknown(
              data['vanigar_tholaipaesi']!, _vanigarTholaipaesiMeta));
    }
    if (data.containsKey('motha_thogai')) {
      context.handle(
          _mothaThogaiMeta,
          mothaThogai.isAcceptableOrUnknown(
              data['motha_thogai']!, _mothaThogaiMeta));
    }
    if (data.containsKey('tharavugal')) {
      context.handle(
          _tharavugalMeta,
          tharavugal.isAcceptableOrUnknown(
              data['tharavugal']!, _tharavugalMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatrucheettuEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatrucheettuEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      seyaliVagai: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seyali_vagai'])!,
      patrucheettuEn: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}patrucheettu_en'])!,
      finYear: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fin_year'])!,
      vanigarId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}vanigar_id']),
      vanigarPeyar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}vanigar_peyar'])!,
      vanigarTholaipaesi: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}vanigar_tholaipaesi'])!,
      mothaThogai: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}motha_thogai'])!,
      tharavugal: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tharavugal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PatrucheettuTableTable createAlias(String alias) {
    return $PatrucheettuTableTable(attachedDatabase, alias);
  }
}

class PatrucheettuEntry extends DataClass
    implements Insertable<PatrucheettuEntry> {
  final int id;
  final String seyaliVagai;
  final String patrucheettuEn;
  final int finYear;
  final int? vanigarId;
  final String vanigarPeyar;
  final String vanigarTholaipaesi;
  final double mothaThogai;
  final String tharavugal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  const PatrucheettuEntry(
      {required this.id,
      required this.seyaliVagai,
      required this.patrucheettuEn,
      required this.finYear,
      this.vanigarId,
      required this.vanigarPeyar,
      required this.vanigarTholaipaesi,
      required this.mothaThogai,
      required this.tharavugal,
      required this.createdAt,
      required this.updatedAt,
      required this.isDeleted,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['seyali_vagai'] = Variable<String>(seyaliVagai);
    map['patrucheettu_en'] = Variable<String>(patrucheettuEn);
    map['fin_year'] = Variable<int>(finYear);
    if (!nullToAbsent || vanigarId != null) {
      map['vanigar_id'] = Variable<int>(vanigarId);
    }
    map['vanigar_peyar'] = Variable<String>(vanigarPeyar);
    map['vanigar_tholaipaesi'] = Variable<String>(vanigarTholaipaesi);
    map['motha_thogai'] = Variable<double>(mothaThogai);
    map['tharavugal'] = Variable<String>(tharavugal);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PatrucheettuTableCompanion toCompanion(bool nullToAbsent) {
    return PatrucheettuTableCompanion(
      id: Value(id),
      seyaliVagai: Value(seyaliVagai),
      patrucheettuEn: Value(patrucheettuEn),
      finYear: Value(finYear),
      vanigarId: vanigarId == null && nullToAbsent
          ? const Value.absent()
          : Value(vanigarId),
      vanigarPeyar: Value(vanigarPeyar),
      vanigarTholaipaesi: Value(vanigarTholaipaesi),
      mothaThogai: Value(mothaThogai),
      tharavugal: Value(tharavugal),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PatrucheettuEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatrucheettuEntry(
      id: serializer.fromJson<int>(json['id']),
      seyaliVagai: serializer.fromJson<String>(json['seyaliVagai']),
      patrucheettuEn: serializer.fromJson<String>(json['patrucheettuEn']),
      finYear: serializer.fromJson<int>(json['finYear']),
      vanigarId: serializer.fromJson<int?>(json['vanigarId']),
      vanigarPeyar: serializer.fromJson<String>(json['vanigarPeyar']),
      vanigarTholaipaesi:
          serializer.fromJson<String>(json['vanigarTholaipaesi']),
      mothaThogai: serializer.fromJson<double>(json['mothaThogai']),
      tharavugal: serializer.fromJson<String>(json['tharavugal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seyaliVagai': serializer.toJson<String>(seyaliVagai),
      'patrucheettuEn': serializer.toJson<String>(patrucheettuEn),
      'finYear': serializer.toJson<int>(finYear),
      'vanigarId': serializer.toJson<int?>(vanigarId),
      'vanigarPeyar': serializer.toJson<String>(vanigarPeyar),
      'vanigarTholaipaesi': serializer.toJson<String>(vanigarTholaipaesi),
      'mothaThogai': serializer.toJson<double>(mothaThogai),
      'tharavugal': serializer.toJson<String>(tharavugal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  PatrucheettuEntry copyWith(
          {int? id,
          String? seyaliVagai,
          String? patrucheettuEn,
          int? finYear,
          Value<int?> vanigarId = const Value.absent(),
          String? vanigarPeyar,
          String? vanigarTholaipaesi,
          double? mothaThogai,
          String? tharavugal,
          DateTime? createdAt,
          DateTime? updatedAt,
          bool? isDeleted,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      PatrucheettuEntry(
        id: id ?? this.id,
        seyaliVagai: seyaliVagai ?? this.seyaliVagai,
        patrucheettuEn: patrucheettuEn ?? this.patrucheettuEn,
        finYear: finYear ?? this.finYear,
        vanigarId: vanigarId.present ? vanigarId.value : this.vanigarId,
        vanigarPeyar: vanigarPeyar ?? this.vanigarPeyar,
        vanigarTholaipaesi: vanigarTholaipaesi ?? this.vanigarTholaipaesi,
        mothaThogai: mothaThogai ?? this.mothaThogai,
        tharavugal: tharavugal ?? this.tharavugal,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  PatrucheettuEntry copyWithCompanion(PatrucheettuTableCompanion data) {
    return PatrucheettuEntry(
      id: data.id.present ? data.id.value : this.id,
      seyaliVagai:
          data.seyaliVagai.present ? data.seyaliVagai.value : this.seyaliVagai,
      patrucheettuEn: data.patrucheettuEn.present
          ? data.patrucheettuEn.value
          : this.patrucheettuEn,
      finYear: data.finYear.present ? data.finYear.value : this.finYear,
      vanigarId: data.vanigarId.present ? data.vanigarId.value : this.vanigarId,
      vanigarPeyar: data.vanigarPeyar.present
          ? data.vanigarPeyar.value
          : this.vanigarPeyar,
      vanigarTholaipaesi: data.vanigarTholaipaesi.present
          ? data.vanigarTholaipaesi.value
          : this.vanigarTholaipaesi,
      mothaThogai:
          data.mothaThogai.present ? data.mothaThogai.value : this.mothaThogai,
      tharavugal:
          data.tharavugal.present ? data.tharavugal.value : this.tharavugal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatrucheettuEntry(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('patrucheettuEn: $patrucheettuEn, ')
          ..write('finYear: $finYear, ')
          ..write('vanigarId: $vanigarId, ')
          ..write('vanigarPeyar: $vanigarPeyar, ')
          ..write('vanigarTholaipaesi: $vanigarTholaipaesi, ')
          ..write('mothaThogai: $mothaThogai, ')
          ..write('tharavugal: $tharavugal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      seyaliVagai,
      patrucheettuEn,
      finYear,
      vanigarId,
      vanigarPeyar,
      vanigarTholaipaesi,
      mothaThogai,
      tharavugal,
      createdAt,
      updatedAt,
      isDeleted,
      deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatrucheettuEntry &&
          other.id == this.id &&
          other.seyaliVagai == this.seyaliVagai &&
          other.patrucheettuEn == this.patrucheettuEn &&
          other.finYear == this.finYear &&
          other.vanigarId == this.vanigarId &&
          other.vanigarPeyar == this.vanigarPeyar &&
          other.vanigarTholaipaesi == this.vanigarTholaipaesi &&
          other.mothaThogai == this.mothaThogai &&
          other.tharavugal == this.tharavugal &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.deletedAt == this.deletedAt);
}

class PatrucheettuTableCompanion extends UpdateCompanion<PatrucheettuEntry> {
  final Value<int> id;
  final Value<String> seyaliVagai;
  final Value<String> patrucheettuEn;
  final Value<int> finYear;
  final Value<int?> vanigarId;
  final Value<String> vanigarPeyar;
  final Value<String> vanigarTholaipaesi;
  final Value<double> mothaThogai;
  final Value<String> tharavugal;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<DateTime?> deletedAt;
  const PatrucheettuTableCompanion({
    this.id = const Value.absent(),
    this.seyaliVagai = const Value.absent(),
    this.patrucheettuEn = const Value.absent(),
    this.finYear = const Value.absent(),
    this.vanigarId = const Value.absent(),
    this.vanigarPeyar = const Value.absent(),
    this.vanigarTholaipaesi = const Value.absent(),
    this.mothaThogai = const Value.absent(),
    this.tharavugal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PatrucheettuTableCompanion.insert({
    this.id = const Value.absent(),
    required String seyaliVagai,
    required String patrucheettuEn,
    required int finYear,
    this.vanigarId = const Value.absent(),
    required String vanigarPeyar,
    this.vanigarTholaipaesi = const Value.absent(),
    this.mothaThogai = const Value.absent(),
    this.tharavugal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.deletedAt = const Value.absent(),
  })  : seyaliVagai = Value(seyaliVagai),
        patrucheettuEn = Value(patrucheettuEn),
        finYear = Value(finYear),
        vanigarPeyar = Value(vanigarPeyar);
  static Insertable<PatrucheettuEntry> custom({
    Expression<int>? id,
    Expression<String>? seyaliVagai,
    Expression<String>? patrucheettuEn,
    Expression<int>? finYear,
    Expression<int>? vanigarId,
    Expression<String>? vanigarPeyar,
    Expression<String>? vanigarTholaipaesi,
    Expression<double>? mothaThogai,
    Expression<String>? tharavugal,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seyaliVagai != null) 'seyali_vagai': seyaliVagai,
      if (patrucheettuEn != null) 'patrucheettu_en': patrucheettuEn,
      if (finYear != null) 'fin_year': finYear,
      if (vanigarId != null) 'vanigar_id': vanigarId,
      if (vanigarPeyar != null) 'vanigar_peyar': vanigarPeyar,
      if (vanigarTholaipaesi != null) 'vanigar_tholaipaesi': vanigarTholaipaesi,
      if (mothaThogai != null) 'motha_thogai': mothaThogai,
      if (tharavugal != null) 'tharavugal': tharavugal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PatrucheettuTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? seyaliVagai,
      Value<String>? patrucheettuEn,
      Value<int>? finYear,
      Value<int?>? vanigarId,
      Value<String>? vanigarPeyar,
      Value<String>? vanigarTholaipaesi,
      Value<double>? mothaThogai,
      Value<String>? tharavugal,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<bool>? isDeleted,
      Value<DateTime?>? deletedAt}) {
    return PatrucheettuTableCompanion(
      id: id ?? this.id,
      seyaliVagai: seyaliVagai ?? this.seyaliVagai,
      patrucheettuEn: patrucheettuEn ?? this.patrucheettuEn,
      finYear: finYear ?? this.finYear,
      vanigarId: vanigarId ?? this.vanigarId,
      vanigarPeyar: vanigarPeyar ?? this.vanigarPeyar,
      vanigarTholaipaesi: vanigarTholaipaesi ?? this.vanigarTholaipaesi,
      mothaThogai: mothaThogai ?? this.mothaThogai,
      tharavugal: tharavugal ?? this.tharavugal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
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
    if (patrucheettuEn.present) {
      map['patrucheettu_en'] = Variable<String>(patrucheettuEn.value);
    }
    if (finYear.present) {
      map['fin_year'] = Variable<int>(finYear.value);
    }
    if (vanigarId.present) {
      map['vanigar_id'] = Variable<int>(vanigarId.value);
    }
    if (vanigarPeyar.present) {
      map['vanigar_peyar'] = Variable<String>(vanigarPeyar.value);
    }
    if (vanigarTholaipaesi.present) {
      map['vanigar_tholaipaesi'] = Variable<String>(vanigarTholaipaesi.value);
    }
    if (mothaThogai.present) {
      map['motha_thogai'] = Variable<double>(mothaThogai.value);
    }
    if (tharavugal.present) {
      map['tharavugal'] = Variable<String>(tharavugal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatrucheettuTableCompanion(')
          ..write('id: $id, ')
          ..write('seyaliVagai: $seyaliVagai, ')
          ..write('patrucheettuEn: $patrucheettuEn, ')
          ..write('finYear: $finYear, ')
          ..write('vanigarId: $vanigarId, ')
          ..write('vanigarPeyar: $vanigarPeyar, ')
          ..write('vanigarTholaipaesi: $vanigarTholaipaesi, ')
          ..write('mothaThogai: $mothaThogai, ')
          ..write('tharavugal: $tharavugal, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VanigaTharavugalTableTable vanigaTharavugalTable =
      $VanigaTharavugalTableTable(this);
  late final $VanigarTableTable vanigarTable = $VanigarTableTable(this);
  late final $PorulTableTable porulTable = $PorulTableTable(this);
  late final $PatrucheettuTableTable patrucheettuTable =
      $PatrucheettuTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [vanigaTharavugalTable, vanigarTable, porulTable, patrucheettuTable];
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
  Value<String> tholaipaesi1,
  Value<String> tholaipaesi2,
  Value<String> minnanjal,
  Value<String> gstin,
  Value<Map<String, String>> mugavari,
  Value<Map<String, String>> oor,
  Value<Map<String, String>> maavattam,
  Value<Map<String, String>> maanilam,
  Value<Map<String, String>> naadu,
  Value<String> anjalKuriyeedu,
  Value<Map<String, String>> vangiPeyar,
  Value<Map<String, String>> kilai,
  Value<String> vangiKanakku,
  Value<String> ifsc,
  Value<String> oavuru,
  Value<String> agalaOavuru,
  Value<String> thalaippuVadivu,
  Value<String> kaiyoppam,
  Value<String> oppamPeyar,
  Value<Map<String, String>> adaimozhi,
  Value<String> upiId,
  Value<String> thoatraNiram,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
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
  Value<String> tholaipaesi1,
  Value<String> tholaipaesi2,
  Value<String> minnanjal,
  Value<String> gstin,
  Value<Map<String, String>> mugavari,
  Value<Map<String, String>> oor,
  Value<Map<String, String>> maavattam,
  Value<Map<String, String>> maanilam,
  Value<Map<String, String>> naadu,
  Value<String> anjalKuriyeedu,
  Value<Map<String, String>> vangiPeyar,
  Value<Map<String, String>> kilai,
  Value<String> vangiKanakku,
  Value<String> ifsc,
  Value<String> oavuru,
  Value<String> agalaOavuru,
  Value<String> thalaippuVadivu,
  Value<String> kaiyoppam,
  Value<String> oppamPeyar,
  Value<Map<String, String>> adaimozhi,
  Value<String> upiId,
  Value<String> thoatraNiram,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get tholaipaesi1 => $composableBuilder(
      column: $table.tholaipaesi1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tholaipaesi2 => $composableBuilder(
      column: $table.tholaipaesi2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get minnanjal => $composableBuilder(
      column: $table.minnanjal, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<String> get anjalKuriyeedu => $composableBuilder(
      column: $table.anjalKuriyeedu,
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

  ColumnFilters<String> get oavuru => $composableBuilder(
      column: $table.oavuru, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agalaOavuru => $composableBuilder(
      column: $table.agalaOavuru, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thalaippuVadivu => $composableBuilder(
      column: $table.thalaippuVadivu,
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

  ColumnFilters<String> get thoatraNiram => $composableBuilder(
      column: $table.thoatraNiram, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get tholaipaesi1 => $composableBuilder(
      column: $table.tholaipaesi1,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tholaipaesi2 => $composableBuilder(
      column: $table.tholaipaesi2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get minnanjal => $composableBuilder(
      column: $table.minnanjal, builder: (column) => ColumnOrderings(column));

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

  ColumnOrderings<String> get anjalKuriyeedu => $composableBuilder(
      column: $table.anjalKuriyeedu,
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

  ColumnOrderings<String> get oavuru => $composableBuilder(
      column: $table.oavuru, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agalaOavuru => $composableBuilder(
      column: $table.agalaOavuru, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thalaippuVadivu => $composableBuilder(
      column: $table.thalaippuVadivu,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kaiyoppam => $composableBuilder(
      column: $table.kaiyoppam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get oppamPeyar => $composableBuilder(
      column: $table.oppamPeyar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get adaimozhi => $composableBuilder(
      column: $table.adaimozhi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thoatraNiram => $composableBuilder(
      column: $table.thoatraNiram,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get tholaipaesi1 => $composableBuilder(
      column: $table.tholaipaesi1, builder: (column) => column);

  GeneratedColumn<String> get tholaipaesi2 => $composableBuilder(
      column: $table.tholaipaesi2, builder: (column) => column);

  GeneratedColumn<String> get minnanjal =>
      $composableBuilder(column: $table.minnanjal, builder: (column) => column);

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

  GeneratedColumn<String> get anjalKuriyeedu => $composableBuilder(
      column: $table.anjalKuriyeedu, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String>
      get vangiPeyar => $composableBuilder(
          column: $table.vangiPeyar, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get kilai =>
      $composableBuilder(column: $table.kilai, builder: (column) => column);

  GeneratedColumn<String> get vangiKanakku => $composableBuilder(
      column: $table.vangiKanakku, builder: (column) => column);

  GeneratedColumn<String> get ifsc =>
      $composableBuilder(column: $table.ifsc, builder: (column) => column);

  GeneratedColumn<String> get oavuru =>
      $composableBuilder(column: $table.oavuru, builder: (column) => column);

  GeneratedColumn<String> get agalaOavuru => $composableBuilder(
      column: $table.agalaOavuru, builder: (column) => column);

  GeneratedColumn<String> get thalaippuVadivu => $composableBuilder(
      column: $table.thalaippuVadivu, builder: (column) => column);

  GeneratedColumn<String> get kaiyoppam =>
      $composableBuilder(column: $table.kaiyoppam, builder: (column) => column);

  GeneratedColumn<String> get oppamPeyar => $composableBuilder(
      column: $table.oppamPeyar, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get adaimozhi =>
      $composableBuilder(column: $table.adaimozhi, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get thoatraNiram => $composableBuilder(
      column: $table.thoatraNiram, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
            Value<String> tholaipaesi1 = const Value.absent(),
            Value<String> tholaipaesi2 = const Value.absent(),
            Value<String> minnanjal = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<Map<String, String>> mugavari = const Value.absent(),
            Value<Map<String, String>> oor = const Value.absent(),
            Value<Map<String, String>> maavattam = const Value.absent(),
            Value<Map<String, String>> maanilam = const Value.absent(),
            Value<Map<String, String>> naadu = const Value.absent(),
            Value<String> anjalKuriyeedu = const Value.absent(),
            Value<Map<String, String>> vangiPeyar = const Value.absent(),
            Value<Map<String, String>> kilai = const Value.absent(),
            Value<String> vangiKanakku = const Value.absent(),
            Value<String> ifsc = const Value.absent(),
            Value<String> oavuru = const Value.absent(),
            Value<String> agalaOavuru = const Value.absent(),
            Value<String> thalaippuVadivu = const Value.absent(),
            Value<String> kaiyoppam = const Value.absent(),
            Value<String> oppamPeyar = const Value.absent(),
            Value<Map<String, String>> adaimozhi = const Value.absent(),
            Value<String> upiId = const Value.absent(),
            Value<String> thoatraNiram = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              VanigaTharavugalTableCompanion(
            id: id,
            seyaliVagai: seyaliVagai,
            mudhanMozhi: mudhanMozhi,
            thunaiMozhi: thunaiMozhi,
            iruMozhi: iruMozhi,
            niruvanathinPeyar: niruvanathinPeyar,
            kurumPeyar: kurumPeyar,
            tholaipaesi1: tholaipaesi1,
            tholaipaesi2: tholaipaesi2,
            minnanjal: minnanjal,
            gstin: gstin,
            mugavari: mugavari,
            oor: oor,
            maavattam: maavattam,
            maanilam: maanilam,
            naadu: naadu,
            anjalKuriyeedu: anjalKuriyeedu,
            vangiPeyar: vangiPeyar,
            kilai: kilai,
            vangiKanakku: vangiKanakku,
            ifsc: ifsc,
            oavuru: oavuru,
            agalaOavuru: agalaOavuru,
            thalaippuVadivu: thalaippuVadivu,
            kaiyoppam: kaiyoppam,
            oppamPeyar: oppamPeyar,
            adaimozhi: adaimozhi,
            upiId: upiId,
            thoatraNiram: thoatraNiram,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String seyaliVagai,
            Value<String> mudhanMozhi = const Value.absent(),
            Value<String> thunaiMozhi = const Value.absent(),
            Value<bool> iruMozhi = const Value.absent(),
            Value<Map<String, String>> niruvanathinPeyar = const Value.absent(),
            Value<String> kurumPeyar = const Value.absent(),
            Value<String> tholaipaesi1 = const Value.absent(),
            Value<String> tholaipaesi2 = const Value.absent(),
            Value<String> minnanjal = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<Map<String, String>> mugavari = const Value.absent(),
            Value<Map<String, String>> oor = const Value.absent(),
            Value<Map<String, String>> maavattam = const Value.absent(),
            Value<Map<String, String>> maanilam = const Value.absent(),
            Value<Map<String, String>> naadu = const Value.absent(),
            Value<String> anjalKuriyeedu = const Value.absent(),
            Value<Map<String, String>> vangiPeyar = const Value.absent(),
            Value<Map<String, String>> kilai = const Value.absent(),
            Value<String> vangiKanakku = const Value.absent(),
            Value<String> ifsc = const Value.absent(),
            Value<String> oavuru = const Value.absent(),
            Value<String> agalaOavuru = const Value.absent(),
            Value<String> thalaippuVadivu = const Value.absent(),
            Value<String> kaiyoppam = const Value.absent(),
            Value<String> oppamPeyar = const Value.absent(),
            Value<Map<String, String>> adaimozhi = const Value.absent(),
            Value<String> upiId = const Value.absent(),
            Value<String> thoatraNiram = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              VanigaTharavugalTableCompanion.insert(
            id: id,
            seyaliVagai: seyaliVagai,
            mudhanMozhi: mudhanMozhi,
            thunaiMozhi: thunaiMozhi,
            iruMozhi: iruMozhi,
            niruvanathinPeyar: niruvanathinPeyar,
            kurumPeyar: kurumPeyar,
            tholaipaesi1: tholaipaesi1,
            tholaipaesi2: tholaipaesi2,
            minnanjal: minnanjal,
            gstin: gstin,
            mugavari: mugavari,
            oor: oor,
            maavattam: maavattam,
            maanilam: maanilam,
            naadu: naadu,
            anjalKuriyeedu: anjalKuriyeedu,
            vangiPeyar: vangiPeyar,
            kilai: kilai,
            vangiKanakku: vangiKanakku,
            ifsc: ifsc,
            oavuru: oavuru,
            agalaOavuru: agalaOavuru,
            thalaippuVadivu: thalaippuVadivu,
            kaiyoppam: kaiyoppam,
            oppamPeyar: oppamPeyar,
            adaimozhi: adaimozhi,
            upiId: upiId,
            thoatraNiram: thoatraNiram,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
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
typedef $$VanigarTableTableCreateCompanionBuilder = VanigarTableCompanion
    Function({
  Value<int> id,
  required String seyaliVagai,
  required String peyar,
  Value<String> tholaipaesi,
  Value<String> mugavari,
  Value<String> gstin,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
});
typedef $$VanigarTableTableUpdateCompanionBuilder = VanigarTableCompanion
    Function({
  Value<int> id,
  Value<String> seyaliVagai,
  Value<String> peyar,
  Value<String> tholaipaesi,
  Value<String> mugavari,
  Value<String> gstin,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
});

class $$VanigarTableTableFilterComposer
    extends Composer<_$AppDatabase, $VanigarTableTable> {
  $$VanigarTableTableFilterComposer({
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

  ColumnFilters<String> get peyar => $composableBuilder(
      column: $table.peyar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tholaipaesi => $composableBuilder(
      column: $table.tholaipaesi, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mugavari => $composableBuilder(
      column: $table.mugavari, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$VanigarTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VanigarTableTable> {
  $$VanigarTableTableOrderingComposer({
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

  ColumnOrderings<String> get peyar => $composableBuilder(
      column: $table.peyar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tholaipaesi => $composableBuilder(
      column: $table.tholaipaesi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mugavari => $composableBuilder(
      column: $table.mugavari, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gstin => $composableBuilder(
      column: $table.gstin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$VanigarTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VanigarTableTable> {
  $$VanigarTableTableAnnotationComposer({
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

  GeneratedColumn<String> get peyar =>
      $composableBuilder(column: $table.peyar, builder: (column) => column);

  GeneratedColumn<String> get tholaipaesi => $composableBuilder(
      column: $table.tholaipaesi, builder: (column) => column);

  GeneratedColumn<String> get mugavari =>
      $composableBuilder(column: $table.mugavari, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$VanigarTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VanigarTableTable,
    VanigarEntry,
    $$VanigarTableTableFilterComposer,
    $$VanigarTableTableOrderingComposer,
    $$VanigarTableTableAnnotationComposer,
    $$VanigarTableTableCreateCompanionBuilder,
    $$VanigarTableTableUpdateCompanionBuilder,
    (
      VanigarEntry,
      BaseReferences<_$AppDatabase, $VanigarTableTable, VanigarEntry>
    ),
    VanigarEntry,
    PrefetchHooks Function()> {
  $$VanigarTableTableTableManager(_$AppDatabase db, $VanigarTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VanigarTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VanigarTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VanigarTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> seyaliVagai = const Value.absent(),
            Value<String> peyar = const Value.absent(),
            Value<String> tholaipaesi = const Value.absent(),
            Value<String> mugavari = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              VanigarTableCompanion(
            id: id,
            seyaliVagai: seyaliVagai,
            peyar: peyar,
            tholaipaesi: tholaipaesi,
            mugavari: mugavari,
            gstin: gstin,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String seyaliVagai,
            required String peyar,
            Value<String> tholaipaesi = const Value.absent(),
            Value<String> mugavari = const Value.absent(),
            Value<String> gstin = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              VanigarTableCompanion.insert(
            id: id,
            seyaliVagai: seyaliVagai,
            peyar: peyar,
            tholaipaesi: tholaipaesi,
            mugavari: mugavari,
            gstin: gstin,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$VanigarTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VanigarTableTable,
    VanigarEntry,
    $$VanigarTableTableFilterComposer,
    $$VanigarTableTableOrderingComposer,
    $$VanigarTableTableAnnotationComposer,
    $$VanigarTableTableCreateCompanionBuilder,
    $$VanigarTableTableUpdateCompanionBuilder,
    (
      VanigarEntry,
      BaseReferences<_$AppDatabase, $VanigarTableTable, VanigarEntry>
    ),
    VanigarEntry,
    PrefetchHooks Function()>;
typedef $$PorulTableTableCreateCompanionBuilder = PorulTableCompanion Function({
  Value<int> id,
  required String seyaliVagai,
  required String porulPeyar,
  Value<String> hsnCode,
  Value<double> vilai,
  Value<double> variVeetham,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
});
typedef $$PorulTableTableUpdateCompanionBuilder = PorulTableCompanion Function({
  Value<int> id,
  Value<String> seyaliVagai,
  Value<String> porulPeyar,
  Value<String> hsnCode,
  Value<double> vilai,
  Value<double> variVeetham,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
});

class $$PorulTableTableFilterComposer
    extends Composer<_$AppDatabase, $PorulTableTable> {
  $$PorulTableTableFilterComposer({
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

  ColumnFilters<String> get porulPeyar => $composableBuilder(
      column: $table.porulPeyar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hsnCode => $composableBuilder(
      column: $table.hsnCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get vilai => $composableBuilder(
      column: $table.vilai, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get variVeetham => $composableBuilder(
      column: $table.variVeetham, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PorulTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PorulTableTable> {
  $$PorulTableTableOrderingComposer({
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

  ColumnOrderings<String> get porulPeyar => $composableBuilder(
      column: $table.porulPeyar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hsnCode => $composableBuilder(
      column: $table.hsnCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get vilai => $composableBuilder(
      column: $table.vilai, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get variVeetham => $composableBuilder(
      column: $table.variVeetham, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PorulTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PorulTableTable> {
  $$PorulTableTableAnnotationComposer({
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

  GeneratedColumn<String> get porulPeyar => $composableBuilder(
      column: $table.porulPeyar, builder: (column) => column);

  GeneratedColumn<String> get hsnCode =>
      $composableBuilder(column: $table.hsnCode, builder: (column) => column);

  GeneratedColumn<double> get vilai =>
      $composableBuilder(column: $table.vilai, builder: (column) => column);

  GeneratedColumn<double> get variVeetham => $composableBuilder(
      column: $table.variVeetham, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PorulTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PorulTableTable,
    PorulEntry,
    $$PorulTableTableFilterComposer,
    $$PorulTableTableOrderingComposer,
    $$PorulTableTableAnnotationComposer,
    $$PorulTableTableCreateCompanionBuilder,
    $$PorulTableTableUpdateCompanionBuilder,
    (PorulEntry, BaseReferences<_$AppDatabase, $PorulTableTable, PorulEntry>),
    PorulEntry,
    PrefetchHooks Function()> {
  $$PorulTableTableTableManager(_$AppDatabase db, $PorulTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PorulTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PorulTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PorulTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> seyaliVagai = const Value.absent(),
            Value<String> porulPeyar = const Value.absent(),
            Value<String> hsnCode = const Value.absent(),
            Value<double> vilai = const Value.absent(),
            Value<double> variVeetham = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PorulTableCompanion(
            id: id,
            seyaliVagai: seyaliVagai,
            porulPeyar: porulPeyar,
            hsnCode: hsnCode,
            vilai: vilai,
            variVeetham: variVeetham,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String seyaliVagai,
            required String porulPeyar,
            Value<String> hsnCode = const Value.absent(),
            Value<double> vilai = const Value.absent(),
            Value<double> variVeetham = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PorulTableCompanion.insert(
            id: id,
            seyaliVagai: seyaliVagai,
            porulPeyar: porulPeyar,
            hsnCode: hsnCode,
            vilai: vilai,
            variVeetham: variVeetham,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PorulTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PorulTableTable,
    PorulEntry,
    $$PorulTableTableFilterComposer,
    $$PorulTableTableOrderingComposer,
    $$PorulTableTableAnnotationComposer,
    $$PorulTableTableCreateCompanionBuilder,
    $$PorulTableTableUpdateCompanionBuilder,
    (PorulEntry, BaseReferences<_$AppDatabase, $PorulTableTable, PorulEntry>),
    PorulEntry,
    PrefetchHooks Function()>;
typedef $$PatrucheettuTableTableCreateCompanionBuilder
    = PatrucheettuTableCompanion Function({
  Value<int> id,
  required String seyaliVagai,
  required String patrucheettuEn,
  required int finYear,
  Value<int?> vanigarId,
  required String vanigarPeyar,
  Value<String> vanigarTholaipaesi,
  Value<double> mothaThogai,
  Value<String> tharavugal,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
});
typedef $$PatrucheettuTableTableUpdateCompanionBuilder
    = PatrucheettuTableCompanion Function({
  Value<int> id,
  Value<String> seyaliVagai,
  Value<String> patrucheettuEn,
  Value<int> finYear,
  Value<int?> vanigarId,
  Value<String> vanigarPeyar,
  Value<String> vanigarTholaipaesi,
  Value<double> mothaThogai,
  Value<String> tharavugal,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isDeleted,
  Value<DateTime?> deletedAt,
});

class $$PatrucheettuTableTableFilterComposer
    extends Composer<_$AppDatabase, $PatrucheettuTableTable> {
  $$PatrucheettuTableTableFilterComposer({
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

  ColumnFilters<String> get patrucheettuEn => $composableBuilder(
      column: $table.patrucheettuEn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get finYear => $composableBuilder(
      column: $table.finYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vanigarId => $composableBuilder(
      column: $table.vanigarId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vanigarPeyar => $composableBuilder(
      column: $table.vanigarPeyar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get vanigarTholaipaesi => $composableBuilder(
      column: $table.vanigarTholaipaesi,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get mothaThogai => $composableBuilder(
      column: $table.mothaThogai, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tharavugal => $composableBuilder(
      column: $table.tharavugal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PatrucheettuTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PatrucheettuTableTable> {
  $$PatrucheettuTableTableOrderingComposer({
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

  ColumnOrderings<String> get patrucheettuEn => $composableBuilder(
      column: $table.patrucheettuEn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get finYear => $composableBuilder(
      column: $table.finYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get vanigarId => $composableBuilder(
      column: $table.vanigarId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vanigarPeyar => $composableBuilder(
      column: $table.vanigarPeyar,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get vanigarTholaipaesi => $composableBuilder(
      column: $table.vanigarTholaipaesi,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get mothaThogai => $composableBuilder(
      column: $table.mothaThogai, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tharavugal => $composableBuilder(
      column: $table.tharavugal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PatrucheettuTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatrucheettuTableTable> {
  $$PatrucheettuTableTableAnnotationComposer({
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

  GeneratedColumn<String> get patrucheettuEn => $composableBuilder(
      column: $table.patrucheettuEn, builder: (column) => column);

  GeneratedColumn<int> get finYear =>
      $composableBuilder(column: $table.finYear, builder: (column) => column);

  GeneratedColumn<int> get vanigarId =>
      $composableBuilder(column: $table.vanigarId, builder: (column) => column);

  GeneratedColumn<String> get vanigarPeyar => $composableBuilder(
      column: $table.vanigarPeyar, builder: (column) => column);

  GeneratedColumn<String> get vanigarTholaipaesi => $composableBuilder(
      column: $table.vanigarTholaipaesi, builder: (column) => column);

  GeneratedColumn<double> get mothaThogai => $composableBuilder(
      column: $table.mothaThogai, builder: (column) => column);

  GeneratedColumn<String> get tharavugal => $composableBuilder(
      column: $table.tharavugal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PatrucheettuTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatrucheettuTableTable,
    PatrucheettuEntry,
    $$PatrucheettuTableTableFilterComposer,
    $$PatrucheettuTableTableOrderingComposer,
    $$PatrucheettuTableTableAnnotationComposer,
    $$PatrucheettuTableTableCreateCompanionBuilder,
    $$PatrucheettuTableTableUpdateCompanionBuilder,
    (
      PatrucheettuEntry,
      BaseReferences<_$AppDatabase, $PatrucheettuTableTable, PatrucheettuEntry>
    ),
    PatrucheettuEntry,
    PrefetchHooks Function()> {
  $$PatrucheettuTableTableTableManager(
      _$AppDatabase db, $PatrucheettuTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatrucheettuTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatrucheettuTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatrucheettuTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> seyaliVagai = const Value.absent(),
            Value<String> patrucheettuEn = const Value.absent(),
            Value<int> finYear = const Value.absent(),
            Value<int?> vanigarId = const Value.absent(),
            Value<String> vanigarPeyar = const Value.absent(),
            Value<String> vanigarTholaipaesi = const Value.absent(),
            Value<double> mothaThogai = const Value.absent(),
            Value<String> tharavugal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PatrucheettuTableCompanion(
            id: id,
            seyaliVagai: seyaliVagai,
            patrucheettuEn: patrucheettuEn,
            finYear: finYear,
            vanigarId: vanigarId,
            vanigarPeyar: vanigarPeyar,
            vanigarTholaipaesi: vanigarTholaipaesi,
            mothaThogai: mothaThogai,
            tharavugal: tharavugal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String seyaliVagai,
            required String patrucheettuEn,
            required int finYear,
            Value<int?> vanigarId = const Value.absent(),
            required String vanigarPeyar,
            Value<String> vanigarTholaipaesi = const Value.absent(),
            Value<double> mothaThogai = const Value.absent(),
            Value<String> tharavugal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
          }) =>
              PatrucheettuTableCompanion.insert(
            id: id,
            seyaliVagai: seyaliVagai,
            patrucheettuEn: patrucheettuEn,
            finYear: finYear,
            vanigarId: vanigarId,
            vanigarPeyar: vanigarPeyar,
            vanigarTholaipaesi: vanigarTholaipaesi,
            mothaThogai: mothaThogai,
            tharavugal: tharavugal,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isDeleted: isDeleted,
            deletedAt: deletedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatrucheettuTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatrucheettuTableTable,
    PatrucheettuEntry,
    $$PatrucheettuTableTableFilterComposer,
    $$PatrucheettuTableTableOrderingComposer,
    $$PatrucheettuTableTableAnnotationComposer,
    $$PatrucheettuTableTableCreateCompanionBuilder,
    $$PatrucheettuTableTableUpdateCompanionBuilder,
    (
      PatrucheettuEntry,
      BaseReferences<_$AppDatabase, $PatrucheettuTableTable, PatrucheettuEntry>
    ),
    PatrucheettuEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VanigaTharavugalTableTableTableManager get vanigaTharavugalTable =>
      $$VanigaTharavugalTableTableTableManager(_db, _db.vanigaTharavugalTable);
  $$VanigarTableTableTableManager get vanigarTable =>
      $$VanigarTableTableTableManager(_db, _db.vanigarTable);
  $$PorulTableTableTableManager get porulTable =>
      $$PorulTableTableTableManager(_db, _db.porulTable);
  $$PatrucheettuTableTableTableManager get patrucheettuTable =>
      $$PatrucheettuTableTableTableManager(_db, _db.patrucheettuTable);
}

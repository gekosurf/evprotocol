// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalIdentitiesTable extends LocalIdentities
    with TableInfo<$LocalIdentitiesTable, LocalIdentity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalIdentitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pubkeyMeta = const VerificationMeta('pubkey');
  @override
  late final GeneratedColumn<String> pubkey = GeneratedColumn<String>(
    'pubkey',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedPrivateKeyMeta =
      const VerificationMeta('encryptedPrivateKey');
  @override
  late final GeneratedColumn<String> encryptedPrivateKey =
      GeneratedColumn<String>(
        'encrypted_private_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dhtKeyMeta = const VerificationMeta('dhtKey');
  @override
  late final GeneratedColumn<String> dhtKey = GeneratedColumn<String>(
    'dht_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pubkey,
    displayName,
    bio,
    avatarUrl,
    encryptedPrivateKey,
    dhtKey,
    createdAt,
    updatedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalIdentity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pubkey')) {
      context.handle(
        _pubkeyMeta,
        pubkey.isAcceptableOrUnknown(data['pubkey']!, _pubkeyMeta),
      );
    } else if (isInserting) {
      context.missing(_pubkeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('encrypted_private_key')) {
      context.handle(
        _encryptedPrivateKeyMeta,
        encryptedPrivateKey.isAcceptableOrUnknown(
          data['encrypted_private_key']!,
          _encryptedPrivateKeyMeta,
        ),
      );
    }
    if (data.containsKey('dht_key')) {
      context.handle(
        _dhtKeyMeta,
        dhtKey.isAcceptableOrUnknown(data['dht_key']!, _dhtKeyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalIdentity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalIdentity(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      pubkey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}pubkey'],
          )!,
      displayName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}display_name'],
          )!,
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      encryptedPrivateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_private_key'],
      ),
      dhtKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dht_key'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      isActive:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_active'],
          )!,
    );
  }

  @override
  $LocalIdentitiesTable createAlias(String alias) {
    return $LocalIdentitiesTable(attachedDatabase, alias);
  }
}

class LocalIdentity extends DataClass implements Insertable<LocalIdentity> {
  /// Auto-incremented primary key.
  final int id;

  /// The public key (hex-encoded).
  final String pubkey;

  /// Display name.
  final String displayName;

  /// Optional bio.
  final String? bio;

  /// Avatar file path or URL.
  final String? avatarUrl;

  /// The encrypted private key material (for backup/restore).
  final String? encryptedPrivateKey;

  /// DHT key if published.
  final String? dhtKey;

  /// When the identity was created.
  final DateTime createdAt;

  /// When last updated.
  final DateTime? updatedAt;

  /// Whether this is the currently active identity.
  final bool isActive;
  const LocalIdentity({
    required this.id,
    required this.pubkey,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.encryptedPrivateKey,
    this.dhtKey,
    required this.createdAt,
    this.updatedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pubkey'] = Variable<String>(pubkey);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || encryptedPrivateKey != null) {
      map['encrypted_private_key'] = Variable<String>(encryptedPrivateKey);
    }
    if (!nullToAbsent || dhtKey != null) {
      map['dht_key'] = Variable<String>(dhtKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  LocalIdentitiesCompanion toCompanion(bool nullToAbsent) {
    return LocalIdentitiesCompanion(
      id: Value(id),
      pubkey: Value(pubkey),
      displayName: Value(displayName),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      avatarUrl:
          avatarUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(avatarUrl),
      encryptedPrivateKey:
          encryptedPrivateKey == null && nullToAbsent
              ? const Value.absent()
              : Value(encryptedPrivateKey),
      dhtKey:
          dhtKey == null && nullToAbsent ? const Value.absent() : Value(dhtKey),
      createdAt: Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  factory LocalIdentity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalIdentity(
      id: serializer.fromJson<int>(json['id']),
      pubkey: serializer.fromJson<String>(json['pubkey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      bio: serializer.fromJson<String?>(json['bio']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      encryptedPrivateKey: serializer.fromJson<String?>(
        json['encryptedPrivateKey'],
      ),
      dhtKey: serializer.fromJson<String?>(json['dhtKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pubkey': serializer.toJson<String>(pubkey),
      'displayName': serializer.toJson<String>(displayName),
      'bio': serializer.toJson<String?>(bio),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'encryptedPrivateKey': serializer.toJson<String?>(encryptedPrivateKey),
      'dhtKey': serializer.toJson<String?>(dhtKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  LocalIdentity copyWith({
    int? id,
    String? pubkey,
    String? displayName,
    Value<String?> bio = const Value.absent(),
    Value<String?> avatarUrl = const Value.absent(),
    Value<String?> encryptedPrivateKey = const Value.absent(),
    Value<String?> dhtKey = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    bool? isActive,
  }) => LocalIdentity(
    id: id ?? this.id,
    pubkey: pubkey ?? this.pubkey,
    displayName: displayName ?? this.displayName,
    bio: bio.present ? bio.value : this.bio,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    encryptedPrivateKey:
        encryptedPrivateKey.present
            ? encryptedPrivateKey.value
            : this.encryptedPrivateKey,
    dhtKey: dhtKey.present ? dhtKey.value : this.dhtKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    isActive: isActive ?? this.isActive,
  );
  LocalIdentity copyWithCompanion(LocalIdentitiesCompanion data) {
    return LocalIdentity(
      id: data.id.present ? data.id.value : this.id,
      pubkey: data.pubkey.present ? data.pubkey.value : this.pubkey,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      bio: data.bio.present ? data.bio.value : this.bio,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      encryptedPrivateKey:
          data.encryptedPrivateKey.present
              ? data.encryptedPrivateKey.value
              : this.encryptedPrivateKey,
      dhtKey: data.dhtKey.present ? data.dhtKey.value : this.dhtKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalIdentity(')
          ..write('id: $id, ')
          ..write('pubkey: $pubkey, ')
          ..write('displayName: $displayName, ')
          ..write('bio: $bio, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('dhtKey: $dhtKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pubkey,
    displayName,
    bio,
    avatarUrl,
    encryptedPrivateKey,
    dhtKey,
    createdAt,
    updatedAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalIdentity &&
          other.id == this.id &&
          other.pubkey == this.pubkey &&
          other.displayName == this.displayName &&
          other.bio == this.bio &&
          other.avatarUrl == this.avatarUrl &&
          other.encryptedPrivateKey == this.encryptedPrivateKey &&
          other.dhtKey == this.dhtKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive);
}

class LocalIdentitiesCompanion extends UpdateCompanion<LocalIdentity> {
  final Value<int> id;
  final Value<String> pubkey;
  final Value<String> displayName;
  final Value<String?> bio;
  final Value<String?> avatarUrl;
  final Value<String?> encryptedPrivateKey;
  final Value<String?> dhtKey;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<bool> isActive;
  const LocalIdentitiesCompanion({
    this.id = const Value.absent(),
    this.pubkey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.bio = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.encryptedPrivateKey = const Value.absent(),
    this.dhtKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  LocalIdentitiesCompanion.insert({
    this.id = const Value.absent(),
    required String pubkey,
    required String displayName,
    this.bio = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.encryptedPrivateKey = const Value.absent(),
    this.dhtKey = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : pubkey = Value(pubkey),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<LocalIdentity> custom({
    Expression<int>? id,
    Expression<String>? pubkey,
    Expression<String>? displayName,
    Expression<String>? bio,
    Expression<String>? avatarUrl,
    Expression<String>? encryptedPrivateKey,
    Expression<String>? dhtKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pubkey != null) 'pubkey': pubkey,
      if (displayName != null) 'display_name': displayName,
      if (bio != null) 'bio': bio,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (encryptedPrivateKey != null)
        'encrypted_private_key': encryptedPrivateKey,
      if (dhtKey != null) 'dht_key': dhtKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
    });
  }

  LocalIdentitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? pubkey,
    Value<String>? displayName,
    Value<String?>? bio,
    Value<String?>? avatarUrl,
    Value<String?>? encryptedPrivateKey,
    Value<String?>? dhtKey,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<bool>? isActive,
  }) {
    return LocalIdentitiesCompanion(
      id: id ?? this.id,
      pubkey: pubkey ?? this.pubkey,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      encryptedPrivateKey: encryptedPrivateKey ?? this.encryptedPrivateKey,
      dhtKey: dhtKey ?? this.dhtKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pubkey.present) {
      map['pubkey'] = Variable<String>(pubkey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (encryptedPrivateKey.present) {
      map['encrypted_private_key'] = Variable<String>(
        encryptedPrivateKey.value,
      );
    }
    if (dhtKey.present) {
      map['dht_key'] = Variable<String>(dhtKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalIdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('pubkey: $pubkey, ')
          ..write('displayName: $displayName, ')
          ..write('bio: $bio, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('encryptedPrivateKey: $encryptedPrivateKey, ')
          ..write('dhtKey: $dhtKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $CachedEventsTable extends CachedEvents
    with TableInfo<$CachedEventsTable, CachedEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dhtKeyMeta = const VerificationMeta('dhtKey');
  @override
  late final GeneratedColumn<String> dhtKey = GeneratedColumn<String>(
    'dht_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorPubkeyMeta = const VerificationMeta(
    'creatorPubkey',
  );
  @override
  late final GeneratedColumn<String> creatorPubkey = GeneratedColumn<String>(
    'creator_pubkey',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 256,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAddressMeta = const VerificationMeta(
    'locationAddress',
  );
  @override
  late final GeneratedColumn<String> locationAddress = GeneratedColumn<String>(
    'location_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _geohashMeta = const VerificationMeta(
    'geohash',
  );
  @override
  late final GeneratedColumn<String> geohash = GeneratedColumn<String>(
    'geohash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _visibilityMeta = const VerificationMeta(
    'visibility',
  );
  @override
  late final GeneratedColumn<String> visibility = GeneratedColumn<String>(
    'visibility',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('public_'),
  );
  static const VerificationMeta _rsvpCountMeta = const VerificationMeta(
    'rsvpCount',
  );
  @override
  late final GeneratedColumn<int> rsvpCount = GeneratedColumn<int>(
    'rsvp_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxCapacityMeta = const VerificationMeta(
    'maxCapacity',
  );
  @override
  late final GeneratedColumn<int> maxCapacity = GeneratedColumn<int>(
    'max_capacity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _groupDhtKeyMeta = const VerificationMeta(
    'groupDhtKey',
  );
  @override
  late final GeneratedColumn<String> groupDhtKey = GeneratedColumn<String>(
    'group_dht_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ticketingJsonMeta = const VerificationMeta(
    'ticketingJson',
  );
  @override
  late final GeneratedColumn<String> ticketingJson = GeneratedColumn<String>(
    'ticketing_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _evVersionMeta = const VerificationMeta(
    'evVersion',
  );
  @override
  late final GeneratedColumn<String> evVersion = GeneratedColumn<String>(
    'ev_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0.1.0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dhtKey,
    creatorPubkey,
    name,
    description,
    startAt,
    endAt,
    locationName,
    locationAddress,
    latitude,
    longitude,
    geohash,
    category,
    tags,
    visibility,
    rsvpCount,
    maxCapacity,
    groupDhtKey,
    ticketingJson,
    createdAt,
    updatedAt,
    lastSyncedAt,
    isDirty,
    evVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dht_key')) {
      context.handle(
        _dhtKeyMeta,
        dhtKey.isAcceptableOrUnknown(data['dht_key']!, _dhtKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dhtKeyMeta);
    }
    if (data.containsKey('creator_pubkey')) {
      context.handle(
        _creatorPubkeyMeta,
        creatorPubkey.isAcceptableOrUnknown(
          data['creator_pubkey']!,
          _creatorPubkeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creatorPubkeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('location_address')) {
      context.handle(
        _locationAddressMeta,
        locationAddress.isAcceptableOrUnknown(
          data['location_address']!,
          _locationAddressMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('geohash')) {
      context.handle(
        _geohashMeta,
        geohash.isAcceptableOrUnknown(data['geohash']!, _geohashMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('visibility')) {
      context.handle(
        _visibilityMeta,
        visibility.isAcceptableOrUnknown(data['visibility']!, _visibilityMeta),
      );
    }
    if (data.containsKey('rsvp_count')) {
      context.handle(
        _rsvpCountMeta,
        rsvpCount.isAcceptableOrUnknown(data['rsvp_count']!, _rsvpCountMeta),
      );
    }
    if (data.containsKey('max_capacity')) {
      context.handle(
        _maxCapacityMeta,
        maxCapacity.isAcceptableOrUnknown(
          data['max_capacity']!,
          _maxCapacityMeta,
        ),
      );
    }
    if (data.containsKey('group_dht_key')) {
      context.handle(
        _groupDhtKeyMeta,
        groupDhtKey.isAcceptableOrUnknown(
          data['group_dht_key']!,
          _groupDhtKeyMeta,
        ),
      );
    }
    if (data.containsKey('ticketing_json')) {
      context.handle(
        _ticketingJsonMeta,
        ticketingJson.isAcceptableOrUnknown(
          data['ticketing_json']!,
          _ticketingJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('ev_version')) {
      context.handle(
        _evVersionMeta,
        evVersion.isAcceptableOrUnknown(data['ev_version']!, _evVersionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dhtKey},
  ];
  @override
  CachedEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedEvent(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      dhtKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}dht_key'],
          )!,
      creatorPubkey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}creator_pubkey'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      startAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}start_at'],
          )!,
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      locationAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_address'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      geohash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geohash'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      tags:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}tags'],
          )!,
      visibility:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}visibility'],
          )!,
      rsvpCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}rsvp_count'],
          )!,
      maxCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_capacity'],
      ),
      groupDhtKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_dht_key'],
      ),
      ticketingJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticketing_json'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      lastSyncedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_synced_at'],
          )!,
      isDirty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_dirty'],
          )!,
      evVersion:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}ev_version'],
          )!,
    );
  }

  @override
  $CachedEventsTable createAlias(String alias) {
    return $CachedEventsTable(attachedDatabase, alias);
  }
}

class CachedEvent extends DataClass implements Insertable<CachedEvent> {
  /// Auto-incremented primary key.
  final int id;

  /// DHT key of the event record.
  final String dhtKey;

  /// Public key of the event creator.
  final String creatorPubkey;

  /// Event title.
  final String name;

  /// Event description (markdown).
  final String? description;

  /// Start time (UTC).
  final DateTime startAt;

  /// End time (UTC).
  final DateTime? endAt;

  /// Location name.
  final String? locationName;

  /// Location address.
  final String? locationAddress;

  /// Latitude.
  final double? latitude;

  /// Longitude.
  final double? longitude;

  /// Geohash (6 chars, for range queries).
  final String? geohash;

  /// Category.
  final String? category;

  /// Comma-separated tags.
  final String tags;

  /// Visibility enum name.
  final String visibility;

  /// RSVP count (approximate).
  final int rsvpCount;

  /// Max capacity.
  final int? maxCapacity;

  /// Group DHT key.
  final String? groupDhtKey;

  /// Ticketing JSON blob (nullable — free events have none).
  final String? ticketingJson;

  /// When the event was created (on the network).
  final DateTime createdAt;

  /// When the event was last updated (on the network).
  final DateTime? updatedAt;

  /// When we last synced this record from DHT.
  final DateTime lastSyncedAt;

  /// Whether the record has local changes pending DHT push.
  final bool isDirty;

  /// EV protocol version.
  final String evVersion;
  const CachedEvent({
    required this.id,
    required this.dhtKey,
    required this.creatorPubkey,
    required this.name,
    this.description,
    required this.startAt,
    this.endAt,
    this.locationName,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.geohash,
    this.category,
    required this.tags,
    required this.visibility,
    required this.rsvpCount,
    this.maxCapacity,
    this.groupDhtKey,
    this.ticketingJson,
    required this.createdAt,
    this.updatedAt,
    required this.lastSyncedAt,
    required this.isDirty,
    required this.evVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dht_key'] = Variable<String>(dhtKey);
    map['creator_pubkey'] = Variable<String>(creatorPubkey);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || locationAddress != null) {
      map['location_address'] = Variable<String>(locationAddress);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || geohash != null) {
      map['geohash'] = Variable<String>(geohash);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['tags'] = Variable<String>(tags);
    map['visibility'] = Variable<String>(visibility);
    map['rsvp_count'] = Variable<int>(rsvpCount);
    if (!nullToAbsent || maxCapacity != null) {
      map['max_capacity'] = Variable<int>(maxCapacity);
    }
    if (!nullToAbsent || groupDhtKey != null) {
      map['group_dht_key'] = Variable<String>(groupDhtKey);
    }
    if (!nullToAbsent || ticketingJson != null) {
      map['ticketing_json'] = Variable<String>(ticketingJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    map['is_dirty'] = Variable<bool>(isDirty);
    map['ev_version'] = Variable<String>(evVersion);
    return map;
  }

  CachedEventsCompanion toCompanion(bool nullToAbsent) {
    return CachedEventsCompanion(
      id: Value(id),
      dhtKey: Value(dhtKey),
      creatorPubkey: Value(creatorPubkey),
      name: Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      startAt: Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      locationName:
          locationName == null && nullToAbsent
              ? const Value.absent()
              : Value(locationName),
      locationAddress:
          locationAddress == null && nullToAbsent
              ? const Value.absent()
              : Value(locationAddress),
      latitude:
          latitude == null && nullToAbsent
              ? const Value.absent()
              : Value(latitude),
      longitude:
          longitude == null && nullToAbsent
              ? const Value.absent()
              : Value(longitude),
      geohash:
          geohash == null && nullToAbsent
              ? const Value.absent()
              : Value(geohash),
      category:
          category == null && nullToAbsent
              ? const Value.absent()
              : Value(category),
      tags: Value(tags),
      visibility: Value(visibility),
      rsvpCount: Value(rsvpCount),
      maxCapacity:
          maxCapacity == null && nullToAbsent
              ? const Value.absent()
              : Value(maxCapacity),
      groupDhtKey:
          groupDhtKey == null && nullToAbsent
              ? const Value.absent()
              : Value(groupDhtKey),
      ticketingJson:
          ticketingJson == null && nullToAbsent
              ? const Value.absent()
              : Value(ticketingJson),
      createdAt: Value(createdAt),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      lastSyncedAt: Value(lastSyncedAt),
      isDirty: Value(isDirty),
      evVersion: Value(evVersion),
    );
  }

  factory CachedEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedEvent(
      id: serializer.fromJson<int>(json['id']),
      dhtKey: serializer.fromJson<String>(json['dhtKey']),
      creatorPubkey: serializer.fromJson<String>(json['creatorPubkey']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      locationAddress: serializer.fromJson<String?>(json['locationAddress']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      geohash: serializer.fromJson<String?>(json['geohash']),
      category: serializer.fromJson<String?>(json['category']),
      tags: serializer.fromJson<String>(json['tags']),
      visibility: serializer.fromJson<String>(json['visibility']),
      rsvpCount: serializer.fromJson<int>(json['rsvpCount']),
      maxCapacity: serializer.fromJson<int?>(json['maxCapacity']),
      groupDhtKey: serializer.fromJson<String?>(json['groupDhtKey']),
      ticketingJson: serializer.fromJson<String?>(json['ticketingJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
      evVersion: serializer.fromJson<String>(json['evVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dhtKey': serializer.toJson<String>(dhtKey),
      'creatorPubkey': serializer.toJson<String>(creatorPubkey),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'locationName': serializer.toJson<String?>(locationName),
      'locationAddress': serializer.toJson<String?>(locationAddress),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'geohash': serializer.toJson<String?>(geohash),
      'category': serializer.toJson<String?>(category),
      'tags': serializer.toJson<String>(tags),
      'visibility': serializer.toJson<String>(visibility),
      'rsvpCount': serializer.toJson<int>(rsvpCount),
      'maxCapacity': serializer.toJson<int?>(maxCapacity),
      'groupDhtKey': serializer.toJson<String?>(groupDhtKey),
      'ticketingJson': serializer.toJson<String?>(ticketingJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
      'evVersion': serializer.toJson<String>(evVersion),
    };
  }

  CachedEvent copyWith({
    int? id,
    String? dhtKey,
    String? creatorPubkey,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? startAt,
    Value<DateTime?> endAt = const Value.absent(),
    Value<String?> locationName = const Value.absent(),
    Value<String?> locationAddress = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> geohash = const Value.absent(),
    Value<String?> category = const Value.absent(),
    String? tags,
    String? visibility,
    int? rsvpCount,
    Value<int?> maxCapacity = const Value.absent(),
    Value<String?> groupDhtKey = const Value.absent(),
    Value<String?> ticketingJson = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
    DateTime? lastSyncedAt,
    bool? isDirty,
    String? evVersion,
  }) => CachedEvent(
    id: id ?? this.id,
    dhtKey: dhtKey ?? this.dhtKey,
    creatorPubkey: creatorPubkey ?? this.creatorPubkey,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    startAt: startAt ?? this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    locationName: locationName.present ? locationName.value : this.locationName,
    locationAddress:
        locationAddress.present ? locationAddress.value : this.locationAddress,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    geohash: geohash.present ? geohash.value : this.geohash,
    category: category.present ? category.value : this.category,
    tags: tags ?? this.tags,
    visibility: visibility ?? this.visibility,
    rsvpCount: rsvpCount ?? this.rsvpCount,
    maxCapacity: maxCapacity.present ? maxCapacity.value : this.maxCapacity,
    groupDhtKey: groupDhtKey.present ? groupDhtKey.value : this.groupDhtKey,
    ticketingJson:
        ticketingJson.present ? ticketingJson.value : this.ticketingJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    isDirty: isDirty ?? this.isDirty,
    evVersion: evVersion ?? this.evVersion,
  );
  CachedEvent copyWithCompanion(CachedEventsCompanion data) {
    return CachedEvent(
      id: data.id.present ? data.id.value : this.id,
      dhtKey: data.dhtKey.present ? data.dhtKey.value : this.dhtKey,
      creatorPubkey:
          data.creatorPubkey.present
              ? data.creatorPubkey.value
              : this.creatorPubkey,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      locationName:
          data.locationName.present
              ? data.locationName.value
              : this.locationName,
      locationAddress:
          data.locationAddress.present
              ? data.locationAddress.value
              : this.locationAddress,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      geohash: data.geohash.present ? data.geohash.value : this.geohash,
      category: data.category.present ? data.category.value : this.category,
      tags: data.tags.present ? data.tags.value : this.tags,
      visibility:
          data.visibility.present ? data.visibility.value : this.visibility,
      rsvpCount: data.rsvpCount.present ? data.rsvpCount.value : this.rsvpCount,
      maxCapacity:
          data.maxCapacity.present ? data.maxCapacity.value : this.maxCapacity,
      groupDhtKey:
          data.groupDhtKey.present ? data.groupDhtKey.value : this.groupDhtKey,
      ticketingJson:
          data.ticketingJson.present
              ? data.ticketingJson.value
              : this.ticketingJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastSyncedAt:
          data.lastSyncedAt.present
              ? data.lastSyncedAt.value
              : this.lastSyncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      evVersion: data.evVersion.present ? data.evVersion.value : this.evVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedEvent(')
          ..write('id: $id, ')
          ..write('dhtKey: $dhtKey, ')
          ..write('creatorPubkey: $creatorPubkey, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('locationName: $locationName, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('visibility: $visibility, ')
          ..write('rsvpCount: $rsvpCount, ')
          ..write('maxCapacity: $maxCapacity, ')
          ..write('groupDhtKey: $groupDhtKey, ')
          ..write('ticketingJson: $ticketingJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('evVersion: $evVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    dhtKey,
    creatorPubkey,
    name,
    description,
    startAt,
    endAt,
    locationName,
    locationAddress,
    latitude,
    longitude,
    geohash,
    category,
    tags,
    visibility,
    rsvpCount,
    maxCapacity,
    groupDhtKey,
    ticketingJson,
    createdAt,
    updatedAt,
    lastSyncedAt,
    isDirty,
    evVersion,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedEvent &&
          other.id == this.id &&
          other.dhtKey == this.dhtKey &&
          other.creatorPubkey == this.creatorPubkey &&
          other.name == this.name &&
          other.description == this.description &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.locationName == this.locationName &&
          other.locationAddress == this.locationAddress &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.geohash == this.geohash &&
          other.category == this.category &&
          other.tags == this.tags &&
          other.visibility == this.visibility &&
          other.rsvpCount == this.rsvpCount &&
          other.maxCapacity == this.maxCapacity &&
          other.groupDhtKey == this.groupDhtKey &&
          other.ticketingJson == this.ticketingJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.isDirty == this.isDirty &&
          other.evVersion == this.evVersion);
}

class CachedEventsCompanion extends UpdateCompanion<CachedEvent> {
  final Value<int> id;
  final Value<String> dhtKey;
  final Value<String> creatorPubkey;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<String?> locationName;
  final Value<String?> locationAddress;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> geohash;
  final Value<String?> category;
  final Value<String> tags;
  final Value<String> visibility;
  final Value<int> rsvpCount;
  final Value<int?> maxCapacity;
  final Value<String?> groupDhtKey;
  final Value<String?> ticketingJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<DateTime> lastSyncedAt;
  final Value<bool> isDirty;
  final Value<String> evVersion;
  const CachedEventsCompanion({
    this.id = const Value.absent(),
    this.dhtKey = const Value.absent(),
    this.creatorPubkey = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.locationName = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.rsvpCount = const Value.absent(),
    this.maxCapacity = const Value.absent(),
    this.groupDhtKey = const Value.absent(),
    this.ticketingJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.evVersion = const Value.absent(),
  });
  CachedEventsCompanion.insert({
    this.id = const Value.absent(),
    required String dhtKey,
    required String creatorPubkey,
    required String name,
    this.description = const Value.absent(),
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.locationName = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.geohash = const Value.absent(),
    this.category = const Value.absent(),
    this.tags = const Value.absent(),
    this.visibility = const Value.absent(),
    this.rsvpCount = const Value.absent(),
    this.maxCapacity = const Value.absent(),
    this.groupDhtKey = const Value.absent(),
    this.ticketingJson = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    required DateTime lastSyncedAt,
    this.isDirty = const Value.absent(),
    this.evVersion = const Value.absent(),
  }) : dhtKey = Value(dhtKey),
       creatorPubkey = Value(creatorPubkey),
       name = Value(name),
       startAt = Value(startAt),
       createdAt = Value(createdAt),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<CachedEvent> custom({
    Expression<int>? id,
    Expression<String>? dhtKey,
    Expression<String>? creatorPubkey,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? locationName,
    Expression<String>? locationAddress,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? geohash,
    Expression<String>? category,
    Expression<String>? tags,
    Expression<String>? visibility,
    Expression<int>? rsvpCount,
    Expression<int>? maxCapacity,
    Expression<String>? groupDhtKey,
    Expression<String>? ticketingJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? isDirty,
    Expression<String>? evVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dhtKey != null) 'dht_key': dhtKey,
      if (creatorPubkey != null) 'creator_pubkey': creatorPubkey,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (locationName != null) 'location_name': locationName,
      if (locationAddress != null) 'location_address': locationAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null) 'geohash': geohash,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (visibility != null) 'visibility': visibility,
      if (rsvpCount != null) 'rsvp_count': rsvpCount,
      if (maxCapacity != null) 'max_capacity': maxCapacity,
      if (groupDhtKey != null) 'group_dht_key': groupDhtKey,
      if (ticketingJson != null) 'ticketing_json': ticketingJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (evVersion != null) 'ev_version': evVersion,
    });
  }

  CachedEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? dhtKey,
    Value<String>? creatorPubkey,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? startAt,
    Value<DateTime?>? endAt,
    Value<String?>? locationName,
    Value<String?>? locationAddress,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? geohash,
    Value<String?>? category,
    Value<String>? tags,
    Value<String>? visibility,
    Value<int>? rsvpCount,
    Value<int?>? maxCapacity,
    Value<String?>? groupDhtKey,
    Value<String?>? ticketingJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<DateTime>? lastSyncedAt,
    Value<bool>? isDirty,
    Value<String>? evVersion,
  }) {
    return CachedEventsCompanion(
      id: id ?? this.id,
      dhtKey: dhtKey ?? this.dhtKey,
      creatorPubkey: creatorPubkey ?? this.creatorPubkey,
      name: name ?? this.name,
      description: description ?? this.description,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      locationName: locationName ?? this.locationName,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geohash: geohash ?? this.geohash,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      groupDhtKey: groupDhtKey ?? this.groupDhtKey,
      ticketingJson: ticketingJson ?? this.ticketingJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
      evVersion: evVersion ?? this.evVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dhtKey.present) {
      map['dht_key'] = Variable<String>(dhtKey.value);
    }
    if (creatorPubkey.present) {
      map['creator_pubkey'] = Variable<String>(creatorPubkey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (locationAddress.present) {
      map['location_address'] = Variable<String>(locationAddress.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (geohash.present) {
      map['geohash'] = Variable<String>(geohash.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (visibility.present) {
      map['visibility'] = Variable<String>(visibility.value);
    }
    if (rsvpCount.present) {
      map['rsvp_count'] = Variable<int>(rsvpCount.value);
    }
    if (maxCapacity.present) {
      map['max_capacity'] = Variable<int>(maxCapacity.value);
    }
    if (groupDhtKey.present) {
      map['group_dht_key'] = Variable<String>(groupDhtKey.value);
    }
    if (ticketingJson.present) {
      map['ticketing_json'] = Variable<String>(ticketingJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    if (evVersion.present) {
      map['ev_version'] = Variable<String>(evVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedEventsCompanion(')
          ..write('id: $id, ')
          ..write('dhtKey: $dhtKey, ')
          ..write('creatorPubkey: $creatorPubkey, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('locationName: $locationName, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('geohash: $geohash, ')
          ..write('category: $category, ')
          ..write('tags: $tags, ')
          ..write('visibility: $visibility, ')
          ..write('rsvpCount: $rsvpCount, ')
          ..write('maxCapacity: $maxCapacity, ')
          ..write('groupDhtKey: $groupDhtKey, ')
          ..write('ticketingJson: $ticketingJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('evVersion: $evVersion')
          ..write(')'))
        .toString();
  }
}

class $CachedRsvpsTable extends CachedRsvps
    with TableInfo<$CachedRsvpsTable, CachedRsvp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRsvpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventDhtKeyMeta = const VerificationMeta(
    'eventDhtKey',
  );
  @override
  late final GeneratedColumn<String> eventDhtKey = GeneratedColumn<String>(
    'event_dht_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attendeePubkeyMeta = const VerificationMeta(
    'attendeePubkey',
  );
  @override
  late final GeneratedColumn<String> attendeePubkey = GeneratedColumn<String>(
    'attendee_pubkey',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guestCountMeta = const VerificationMeta(
    'guestCount',
  );
  @override
  late final GeneratedColumn<int> guestCount = GeneratedColumn<int>(
    'guest_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  @override
  late final GeneratedColumn<bool> isDirty = GeneratedColumn<bool>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventDhtKey,
    attendeePubkey,
    status,
    guestCount,
    note,
    createdAt,
    lastSyncedAt,
    isDirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_rsvps';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRsvp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_dht_key')) {
      context.handle(
        _eventDhtKeyMeta,
        eventDhtKey.isAcceptableOrUnknown(
          data['event_dht_key']!,
          _eventDhtKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventDhtKeyMeta);
    }
    if (data.containsKey('attendee_pubkey')) {
      context.handle(
        _attendeePubkeyMeta,
        attendeePubkey.isAcceptableOrUnknown(
          data['attendee_pubkey']!,
          _attendeePubkeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attendeePubkeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('guest_count')) {
      context.handle(
        _guestCountMeta,
        guestCount.isAcceptableOrUnknown(data['guest_count']!, _guestCountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {eventDhtKey, attendeePubkey},
  ];
  @override
  CachedRsvp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRsvp(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      eventDhtKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}event_dht_key'],
          )!,
      attendeePubkey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}attendee_pubkey'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      guestCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}guest_count'],
          )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      lastSyncedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_synced_at'],
          )!,
      isDirty:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_dirty'],
          )!,
    );
  }

  @override
  $CachedRsvpsTable createAlias(String alias) {
    return $CachedRsvpsTable(attachedDatabase, alias);
  }
}

class CachedRsvp extends DataClass implements Insertable<CachedRsvp> {
  /// Auto-incremented primary key.
  final int id;

  /// DHT key of the event.
  final String eventDhtKey;

  /// Public key of the attendee.
  final String attendeePubkey;

  /// RSVP status enum name (going, maybe, notGoing, waitlisted).
  final String status;

  /// Number of additional guests.
  final int guestCount;

  /// Optional note.
  final String? note;

  /// When the RSVP was created.
  final DateTime createdAt;

  /// When last synced from DHT.
  final DateTime lastSyncedAt;

  /// Pending DHT push.
  final bool isDirty;
  const CachedRsvp({
    required this.id,
    required this.eventDhtKey,
    required this.attendeePubkey,
    required this.status,
    required this.guestCount,
    this.note,
    required this.createdAt,
    required this.lastSyncedAt,
    required this.isDirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_dht_key'] = Variable<String>(eventDhtKey);
    map['attendee_pubkey'] = Variable<String>(attendeePubkey);
    map['status'] = Variable<String>(status);
    map['guest_count'] = Variable<int>(guestCount);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    map['is_dirty'] = Variable<bool>(isDirty);
    return map;
  }

  CachedRsvpsCompanion toCompanion(bool nullToAbsent) {
    return CachedRsvpsCompanion(
      id: Value(id),
      eventDhtKey: Value(eventDhtKey),
      attendeePubkey: Value(attendeePubkey),
      status: Value(status),
      guestCount: Value(guestCount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      lastSyncedAt: Value(lastSyncedAt),
      isDirty: Value(isDirty),
    );
  }

  factory CachedRsvp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRsvp(
      id: serializer.fromJson<int>(json['id']),
      eventDhtKey: serializer.fromJson<String>(json['eventDhtKey']),
      attendeePubkey: serializer.fromJson<String>(json['attendeePubkey']),
      status: serializer.fromJson<String>(json['status']),
      guestCount: serializer.fromJson<int>(json['guestCount']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
      isDirty: serializer.fromJson<bool>(json['isDirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventDhtKey': serializer.toJson<String>(eventDhtKey),
      'attendeePubkey': serializer.toJson<String>(attendeePubkey),
      'status': serializer.toJson<String>(status),
      'guestCount': serializer.toJson<int>(guestCount),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'isDirty': serializer.toJson<bool>(isDirty),
    };
  }

  CachedRsvp copyWith({
    int? id,
    String? eventDhtKey,
    String? attendeePubkey,
    String? status,
    int? guestCount,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    bool? isDirty,
  }) => CachedRsvp(
    id: id ?? this.id,
    eventDhtKey: eventDhtKey ?? this.eventDhtKey,
    attendeePubkey: attendeePubkey ?? this.attendeePubkey,
    status: status ?? this.status,
    guestCount: guestCount ?? this.guestCount,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    isDirty: isDirty ?? this.isDirty,
  );
  CachedRsvp copyWithCompanion(CachedRsvpsCompanion data) {
    return CachedRsvp(
      id: data.id.present ? data.id.value : this.id,
      eventDhtKey:
          data.eventDhtKey.present ? data.eventDhtKey.value : this.eventDhtKey,
      attendeePubkey:
          data.attendeePubkey.present
              ? data.attendeePubkey.value
              : this.attendeePubkey,
      status: data.status.present ? data.status.value : this.status,
      guestCount:
          data.guestCount.present ? data.guestCount.value : this.guestCount,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastSyncedAt:
          data.lastSyncedAt.present
              ? data.lastSyncedAt.value
              : this.lastSyncedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRsvp(')
          ..write('id: $id, ')
          ..write('eventDhtKey: $eventDhtKey, ')
          ..write('attendeePubkey: $attendeePubkey, ')
          ..write('status: $status, ')
          ..write('guestCount: $guestCount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventDhtKey,
    attendeePubkey,
    status,
    guestCount,
    note,
    createdAt,
    lastSyncedAt,
    isDirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRsvp &&
          other.id == this.id &&
          other.eventDhtKey == this.eventDhtKey &&
          other.attendeePubkey == this.attendeePubkey &&
          other.status == this.status &&
          other.guestCount == this.guestCount &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.isDirty == this.isDirty);
}

class CachedRsvpsCompanion extends UpdateCompanion<CachedRsvp> {
  final Value<int> id;
  final Value<String> eventDhtKey;
  final Value<String> attendeePubkey;
  final Value<String> status;
  final Value<int> guestCount;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastSyncedAt;
  final Value<bool> isDirty;
  const CachedRsvpsCompanion({
    this.id = const Value.absent(),
    this.eventDhtKey = const Value.absent(),
    this.attendeePubkey = const Value.absent(),
    this.status = const Value.absent(),
    this.guestCount = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
  });
  CachedRsvpsCompanion.insert({
    this.id = const Value.absent(),
    required String eventDhtKey,
    required String attendeePubkey,
    required String status,
    this.guestCount = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastSyncedAt,
    this.isDirty = const Value.absent(),
  }) : eventDhtKey = Value(eventDhtKey),
       attendeePubkey = Value(attendeePubkey),
       status = Value(status),
       createdAt = Value(createdAt),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<CachedRsvp> custom({
    Expression<int>? id,
    Expression<String>? eventDhtKey,
    Expression<String>? attendeePubkey,
    Expression<String>? status,
    Expression<int>? guestCount,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastSyncedAt,
    Expression<bool>? isDirty,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventDhtKey != null) 'event_dht_key': eventDhtKey,
      if (attendeePubkey != null) 'attendee_pubkey': attendeePubkey,
      if (status != null) 'status': status,
      if (guestCount != null) 'guest_count': guestCount,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (isDirty != null) 'is_dirty': isDirty,
    });
  }

  CachedRsvpsCompanion copyWith({
    Value<int>? id,
    Value<String>? eventDhtKey,
    Value<String>? attendeePubkey,
    Value<String>? status,
    Value<int>? guestCount,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastSyncedAt,
    Value<bool>? isDirty,
  }) {
    return CachedRsvpsCompanion(
      id: id ?? this.id,
      eventDhtKey: eventDhtKey ?? this.eventDhtKey,
      attendeePubkey: attendeePubkey ?? this.attendeePubkey,
      status: status ?? this.status,
      guestCount: guestCount ?? this.guestCount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventDhtKey.present) {
      map['event_dht_key'] = Variable<String>(eventDhtKey.value);
    }
    if (attendeePubkey.present) {
      map['attendee_pubkey'] = Variable<String>(attendeePubkey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (guestCount.present) {
      map['guest_count'] = Variable<int>(guestCount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<bool>(isDirty.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRsvpsCompanion(')
          ..write('id: $id, ')
          ..write('eventDhtKey: $eventDhtKey, ')
          ..write('attendeePubkey: $attendeePubkey, ')
          ..write('status: $status, ')
          ..write('guestCount: $guestCount, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('isDirty: $isDirty')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localRecordIdMeta = const VerificationMeta(
    'localRecordId',
  );
  @override
  late final GeneratedColumn<int> localRecordId = GeneratedColumn<int>(
    'local_record_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dhtKeyMeta = const VerificationMeta('dhtKey');
  @override
  late final GeneratedColumn<String> dhtKey = GeneratedColumn<String>(
    'dht_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt =
      GeneratedColumn<DateTime>(
        'completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operation,
    recordType,
    localRecordId,
    dhtKey,
    payload,
    retryCount,
    lastError,
    queuedAt,
    lastAttemptAt,
    completedAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('local_record_id')) {
      context.handle(
        _localRecordIdMeta,
        localRecordId.isAcceptableOrUnknown(
          data['local_record_id']!,
          _localRecordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localRecordIdMeta);
    }
    if (data.containsKey('dht_key')) {
      context.handle(
        _dhtKeyMeta,
        dhtKey.isAcceptableOrUnknown(data['dht_key']!, _dhtKeyMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_queuedAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      operation:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}operation'],
          )!,
      recordType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}record_type'],
          )!,
      localRecordId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}local_record_id'],
          )!,
      dhtKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dht_key'],
      ),
      payload:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}payload'],
          )!,
      retryCount:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}retry_count'],
          )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      queuedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}queued_at'],
          )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  /// Auto-incremented primary key.
  final int id;

  /// Operation type: 'create', 'update', 'delete'.
  final String operation;

  /// Record type: 'identity', 'event', 'rsvp', 'group', 'message'.
  final String recordType;

  /// Local record ID in the source table.
  final int localRecordId;

  /// DHT key (null for creates, populated for updates/deletes).
  final String? dhtKey;

  /// JSON payload of the record to push.
  final String payload;

  /// Number of retry attempts.
  final int retryCount;

  /// Last error message if failed.
  final String? lastError;

  /// When the operation was queued.
  final DateTime queuedAt;

  /// When it was last attempted.
  final DateTime? lastAttemptAt;

  /// When the operation was completed successfully.
  final DateTime? completedAt;

  /// Status: 'pending', 'processing', 'failed', 'completed'.
  final String status;
  const SyncQueueData({
    required this.id,
    required this.operation,
    required this.recordType,
    required this.localRecordId,
    this.dhtKey,
    required this.payload,
    required this.retryCount,
    this.lastError,
    required this.queuedAt,
    this.lastAttemptAt,
    this.completedAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation'] = Variable<String>(operation);
    map['record_type'] = Variable<String>(recordType);
    map['local_record_id'] = Variable<int>(localRecordId);
    if (!nullToAbsent || dhtKey != null) {
      map['dht_key'] = Variable<String>(dhtKey);
    }
    map['payload'] = Variable<String>(payload);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['queued_at'] = Variable<DateTime>(queuedAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      operation: Value(operation),
      recordType: Value(recordType),
      localRecordId: Value(localRecordId),
      dhtKey:
          dhtKey == null && nullToAbsent ? const Value.absent() : Value(dhtKey),
      payload: Value(payload),
      retryCount: Value(retryCount),
      lastError:
          lastError == null && nullToAbsent
              ? const Value.absent()
              : Value(lastError),
      queuedAt: Value(queuedAt),
      lastAttemptAt:
          lastAttemptAt == null && nullToAbsent
              ? const Value.absent()
              : Value(lastAttemptAt),
      completedAt:
          completedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(completedAt),
      status: Value(status),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      operation: serializer.fromJson<String>(json['operation']),
      recordType: serializer.fromJson<String>(json['recordType']),
      localRecordId: serializer.fromJson<int>(json['localRecordId']),
      dhtKey: serializer.fromJson<String?>(json['dhtKey']),
      payload: serializer.fromJson<String>(json['payload']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operation': serializer.toJson<String>(operation),
      'recordType': serializer.toJson<String>(recordType),
      'localRecordId': serializer.toJson<int>(localRecordId),
      'dhtKey': serializer.toJson<String?>(dhtKey),
      'payload': serializer.toJson<String>(payload),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(status),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? operation,
    String? recordType,
    int? localRecordId,
    Value<String?> dhtKey = const Value.absent(),
    String? payload,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? queuedAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    String? status,
  }) => SyncQueueData(
    id: id ?? this.id,
    operation: operation ?? this.operation,
    recordType: recordType ?? this.recordType,
    localRecordId: localRecordId ?? this.localRecordId,
    dhtKey: dhtKey.present ? dhtKey.value : this.dhtKey,
    payload: payload ?? this.payload,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    queuedAt: queuedAt ?? this.queuedAt,
    lastAttemptAt:
        lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
    completedAt:
        completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      operation: data.operation.present ? data.operation.value : this.operation,
      recordType:
          data.recordType.present ? data.recordType.value : this.recordType,
      localRecordId:
          data.localRecordId.present
              ? data.localRecordId.value
              : this.localRecordId,
      dhtKey: data.dhtKey.present ? data.dhtKey.value : this.dhtKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      lastAttemptAt:
          data.lastAttemptAt.present
              ? data.lastAttemptAt.value
              : this.lastAttemptAt,
      completedAt:
          data.completedAt.present
              ? data.completedAt.value
              : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('recordType: $recordType, ')
          ..write('localRecordId: $localRecordId, ')
          ..write('dhtKey: $dhtKey, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operation,
    recordType,
    localRecordId,
    dhtKey,
    payload,
    retryCount,
    lastError,
    queuedAt,
    lastAttemptAt,
    completedAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.operation == this.operation &&
          other.recordType == this.recordType &&
          other.localRecordId == this.localRecordId &&
          other.dhtKey == this.dhtKey &&
          other.payload == this.payload &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.queuedAt == this.queuedAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> operation;
  final Value<String> recordType;
  final Value<int> localRecordId;
  final Value<String?> dhtKey;
  final Value<String> payload;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> queuedAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> completedAt;
  final Value<String> status;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.operation = const Value.absent(),
    this.recordType = const Value.absent(),
    this.localRecordId = const Value.absent(),
    this.dhtKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String operation,
    required String recordType,
    required int localRecordId,
    this.dhtKey = const Value.absent(),
    required String payload,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime queuedAt,
    this.lastAttemptAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
  }) : operation = Value(operation),
       recordType = Value(recordType),
       localRecordId = Value(localRecordId),
       payload = Value(payload),
       queuedAt = Value(queuedAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? operation,
    Expression<String>? recordType,
    Expression<int>? localRecordId,
    Expression<String>? dhtKey,
    Expression<String>? payload,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? queuedAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operation != null) 'operation': operation,
      if (recordType != null) 'record_type': recordType,
      if (localRecordId != null) 'local_record_id': localRecordId,
      if (dhtKey != null) 'dht_key': dhtKey,
      if (payload != null) 'payload': payload,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? operation,
    Value<String>? recordType,
    Value<int>? localRecordId,
    Value<String?>? dhtKey,
    Value<String>? payload,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? queuedAt,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime?>? completedAt,
    Value<String>? status,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      operation: operation ?? this.operation,
      recordType: recordType ?? this.recordType,
      localRecordId: localRecordId ?? this.localRecordId,
      dhtKey: dhtKey ?? this.dhtKey,
      payload: payload ?? this.payload,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      queuedAt: queuedAt ?? this.queuedAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (localRecordId.present) {
      map['local_record_id'] = Variable<int>(localRecordId.value);
    }
    if (dhtKey.present) {
      map['dht_key'] = Variable<String>(dhtKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('operation: $operation, ')
          ..write('recordType: $recordType, ')
          ..write('localRecordId: $localRecordId, ')
          ..write('dhtKey: $dhtKey, ')
          ..write('payload: $payload, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalIdentitiesTable localIdentities = $LocalIdentitiesTable(
    this,
  );
  late final $CachedEventsTable cachedEvents = $CachedEventsTable(this);
  late final $CachedRsvpsTable cachedRsvps = $CachedRsvpsTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localIdentities,
    cachedEvents,
    cachedRsvps,
    syncQueue,
  ];
}

typedef $$LocalIdentitiesTableCreateCompanionBuilder =
    LocalIdentitiesCompanion Function({
      Value<int> id,
      required String pubkey,
      required String displayName,
      Value<String?> bio,
      Value<String?> avatarUrl,
      Value<String?> encryptedPrivateKey,
      Value<String?> dhtKey,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isActive,
    });
typedef $$LocalIdentitiesTableUpdateCompanionBuilder =
    LocalIdentitiesCompanion Function({
      Value<int> id,
      Value<String> pubkey,
      Value<String> displayName,
      Value<String?> bio,
      Value<String?> avatarUrl,
      Value<String?> encryptedPrivateKey,
      Value<String?> dhtKey,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<bool> isActive,
    });

class $$LocalIdentitiesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalIdentitiesTable> {
  $$LocalIdentitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pubkey => $composableBuilder(
    column: $table.pubkey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dhtKey => $composableBuilder(
    column: $table.dhtKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalIdentitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalIdentitiesTable> {
  $$LocalIdentitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pubkey => $composableBuilder(
    column: $table.pubkey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dhtKey => $composableBuilder(
    column: $table.dhtKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalIdentitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalIdentitiesTable> {
  $$LocalIdentitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pubkey =>
      $composableBuilder(column: $table.pubkey, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get encryptedPrivateKey => $composableBuilder(
    column: $table.encryptedPrivateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dhtKey =>
      $composableBuilder(column: $table.dhtKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$LocalIdentitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalIdentitiesTable,
          LocalIdentity,
          $$LocalIdentitiesTableFilterComposer,
          $$LocalIdentitiesTableOrderingComposer,
          $$LocalIdentitiesTableAnnotationComposer,
          $$LocalIdentitiesTableCreateCompanionBuilder,
          $$LocalIdentitiesTableUpdateCompanionBuilder,
          (
            LocalIdentity,
            BaseReferences<_$AppDatabase, $LocalIdentitiesTable, LocalIdentity>,
          ),
          LocalIdentity,
          PrefetchHooks Function()
        > {
  $$LocalIdentitiesTableTableManager(
    _$AppDatabase db,
    $LocalIdentitiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$LocalIdentitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LocalIdentitiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$LocalIdentitiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pubkey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> encryptedPrivateKey = const Value.absent(),
                Value<String?> dhtKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LocalIdentitiesCompanion(
                id: id,
                pubkey: pubkey,
                displayName: displayName,
                bio: bio,
                avatarUrl: avatarUrl,
                encryptedPrivateKey: encryptedPrivateKey,
                dhtKey: dhtKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pubkey,
                required String displayName,
                Value<String?> bio = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String?> encryptedPrivateKey = const Value.absent(),
                Value<String?> dhtKey = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => LocalIdentitiesCompanion.insert(
                id: id,
                pubkey: pubkey,
                displayName: displayName,
                bio: bio,
                avatarUrl: avatarUrl,
                encryptedPrivateKey: encryptedPrivateKey,
                dhtKey: dhtKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalIdentitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalIdentitiesTable,
      LocalIdentity,
      $$LocalIdentitiesTableFilterComposer,
      $$LocalIdentitiesTableOrderingComposer,
      $$LocalIdentitiesTableAnnotationComposer,
      $$LocalIdentitiesTableCreateCompanionBuilder,
      $$LocalIdentitiesTableUpdateCompanionBuilder,
      (
        LocalIdentity,
        BaseReferences<_$AppDatabase, $LocalIdentitiesTable, LocalIdentity>,
      ),
      LocalIdentity,
      PrefetchHooks Function()
    >;
typedef $$CachedEventsTableCreateCompanionBuilder =
    CachedEventsCompanion Function({
      Value<int> id,
      required String dhtKey,
      required String creatorPubkey,
      required String name,
      Value<String?> description,
      required DateTime startAt,
      Value<DateTime?> endAt,
      Value<String?> locationName,
      Value<String?> locationAddress,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<String?> category,
      Value<String> tags,
      Value<String> visibility,
      Value<int> rsvpCount,
      Value<int?> maxCapacity,
      Value<String?> groupDhtKey,
      Value<String?> ticketingJson,
      required DateTime createdAt,
      Value<DateTime?> updatedAt,
      required DateTime lastSyncedAt,
      Value<bool> isDirty,
      Value<String> evVersion,
    });
typedef $$CachedEventsTableUpdateCompanionBuilder =
    CachedEventsCompanion Function({
      Value<int> id,
      Value<String> dhtKey,
      Value<String> creatorPubkey,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> startAt,
      Value<DateTime?> endAt,
      Value<String?> locationName,
      Value<String?> locationAddress,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> geohash,
      Value<String?> category,
      Value<String> tags,
      Value<String> visibility,
      Value<int> rsvpCount,
      Value<int?> maxCapacity,
      Value<String?> groupDhtKey,
      Value<String?> ticketingJson,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<DateTime> lastSyncedAt,
      Value<bool> isDirty,
      Value<String> evVersion,
    });

class $$CachedEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedEventsTable> {
  $$CachedEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dhtKey => $composableBuilder(
    column: $table.dhtKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creatorPubkey => $composableBuilder(
    column: $table.creatorPubkey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rsvpCount => $composableBuilder(
    column: $table.rsvpCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCapacity => $composableBuilder(
    column: $table.maxCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupDhtKey => $composableBuilder(
    column: $table.groupDhtKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketingJson => $composableBuilder(
    column: $table.ticketingJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evVersion => $composableBuilder(
    column: $table.evVersion,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedEventsTable> {
  $$CachedEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dhtKey => $composableBuilder(
    column: $table.dhtKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creatorPubkey => $composableBuilder(
    column: $table.creatorPubkey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get geohash => $composableBuilder(
    column: $table.geohash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rsvpCount => $composableBuilder(
    column: $table.rsvpCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCapacity => $composableBuilder(
    column: $table.maxCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupDhtKey => $composableBuilder(
    column: $table.groupDhtKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketingJson => $composableBuilder(
    column: $table.ticketingJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evVersion => $composableBuilder(
    column: $table.evVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedEventsTable> {
  $$CachedEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dhtKey =>
      $composableBuilder(column: $table.dhtKey, builder: (column) => column);

  GeneratedColumn<String> get creatorPubkey => $composableBuilder(
    column: $table.creatorPubkey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get geohash =>
      $composableBuilder(column: $table.geohash, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get visibility => $composableBuilder(
    column: $table.visibility,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rsvpCount =>
      $composableBuilder(column: $table.rsvpCount, builder: (column) => column);

  GeneratedColumn<int> get maxCapacity => $composableBuilder(
    column: $table.maxCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get groupDhtKey => $composableBuilder(
    column: $table.groupDhtKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ticketingJson => $composableBuilder(
    column: $table.ticketingJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get evVersion =>
      $composableBuilder(column: $table.evVersion, builder: (column) => column);
}

class $$CachedEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedEventsTable,
          CachedEvent,
          $$CachedEventsTableFilterComposer,
          $$CachedEventsTableOrderingComposer,
          $$CachedEventsTableAnnotationComposer,
          $$CachedEventsTableCreateCompanionBuilder,
          $$CachedEventsTableUpdateCompanionBuilder,
          (
            CachedEvent,
            BaseReferences<_$AppDatabase, $CachedEventsTable, CachedEvent>,
          ),
          CachedEvent,
          PrefetchHooks Function()
        > {
  $$CachedEventsTableTableManager(_$AppDatabase db, $CachedEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CachedEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CachedEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dhtKey = const Value.absent(),
                Value<String> creatorPubkey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<int> rsvpCount = const Value.absent(),
                Value<int?> maxCapacity = const Value.absent(),
                Value<String?> groupDhtKey = const Value.absent(),
                Value<String?> ticketingJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
                Value<String> evVersion = const Value.absent(),
              }) => CachedEventsCompanion(
                id: id,
                dhtKey: dhtKey,
                creatorPubkey: creatorPubkey,
                name: name,
                description: description,
                startAt: startAt,
                endAt: endAt,
                locationName: locationName,
                locationAddress: locationAddress,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                category: category,
                tags: tags,
                visibility: visibility,
                rsvpCount: rsvpCount,
                maxCapacity: maxCapacity,
                groupDhtKey: groupDhtKey,
                ticketingJson: ticketingJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                isDirty: isDirty,
                evVersion: evVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dhtKey,
                required String creatorPubkey,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime startAt,
                Value<DateTime?> endAt = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> geohash = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> visibility = const Value.absent(),
                Value<int> rsvpCount = const Value.absent(),
                Value<int?> maxCapacity = const Value.absent(),
                Value<String?> groupDhtKey = const Value.absent(),
                Value<String?> ticketingJson = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                required DateTime lastSyncedAt,
                Value<bool> isDirty = const Value.absent(),
                Value<String> evVersion = const Value.absent(),
              }) => CachedEventsCompanion.insert(
                id: id,
                dhtKey: dhtKey,
                creatorPubkey: creatorPubkey,
                name: name,
                description: description,
                startAt: startAt,
                endAt: endAt,
                locationName: locationName,
                locationAddress: locationAddress,
                latitude: latitude,
                longitude: longitude,
                geohash: geohash,
                category: category,
                tags: tags,
                visibility: visibility,
                rsvpCount: rsvpCount,
                maxCapacity: maxCapacity,
                groupDhtKey: groupDhtKey,
                ticketingJson: ticketingJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastSyncedAt: lastSyncedAt,
                isDirty: isDirty,
                evVersion: evVersion,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedEventsTable,
      CachedEvent,
      $$CachedEventsTableFilterComposer,
      $$CachedEventsTableOrderingComposer,
      $$CachedEventsTableAnnotationComposer,
      $$CachedEventsTableCreateCompanionBuilder,
      $$CachedEventsTableUpdateCompanionBuilder,
      (
        CachedEvent,
        BaseReferences<_$AppDatabase, $CachedEventsTable, CachedEvent>,
      ),
      CachedEvent,
      PrefetchHooks Function()
    >;
typedef $$CachedRsvpsTableCreateCompanionBuilder =
    CachedRsvpsCompanion Function({
      Value<int> id,
      required String eventDhtKey,
      required String attendeePubkey,
      required String status,
      Value<int> guestCount,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime lastSyncedAt,
      Value<bool> isDirty,
    });
typedef $$CachedRsvpsTableUpdateCompanionBuilder =
    CachedRsvpsCompanion Function({
      Value<int> id,
      Value<String> eventDhtKey,
      Value<String> attendeePubkey,
      Value<String> status,
      Value<int> guestCount,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> lastSyncedAt,
      Value<bool> isDirty,
    });

class $$CachedRsvpsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRsvpsTable> {
  $$CachedRsvpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventDhtKey => $composableBuilder(
    column: $table.eventDhtKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendeePubkey => $composableBuilder(
    column: $table.attendeePubkey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get guestCount => $composableBuilder(
    column: $table.guestCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedRsvpsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRsvpsTable> {
  $$CachedRsvpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventDhtKey => $composableBuilder(
    column: $table.eventDhtKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendeePubkey => $composableBuilder(
    column: $table.attendeePubkey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get guestCount => $composableBuilder(
    column: $table.guestCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRsvpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRsvpsTable> {
  $$CachedRsvpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventDhtKey => $composableBuilder(
    column: $table.eventDhtKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attendeePubkey => $composableBuilder(
    column: $table.attendeePubkey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get guestCount => $composableBuilder(
    column: $table.guestCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);
}

class $$CachedRsvpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRsvpsTable,
          CachedRsvp,
          $$CachedRsvpsTableFilterComposer,
          $$CachedRsvpsTableOrderingComposer,
          $$CachedRsvpsTableAnnotationComposer,
          $$CachedRsvpsTableCreateCompanionBuilder,
          $$CachedRsvpsTableUpdateCompanionBuilder,
          (
            CachedRsvp,
            BaseReferences<_$AppDatabase, $CachedRsvpsTable, CachedRsvp>,
          ),
          CachedRsvp,
          PrefetchHooks Function()
        > {
  $$CachedRsvpsTableTableManager(_$AppDatabase db, $CachedRsvpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CachedRsvpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$CachedRsvpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$CachedRsvpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventDhtKey = const Value.absent(),
                Value<String> attendeePubkey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> guestCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<bool> isDirty = const Value.absent(),
              }) => CachedRsvpsCompanion(
                id: id,
                eventDhtKey: eventDhtKey,
                attendeePubkey: attendeePubkey,
                status: status,
                guestCount: guestCount,
                note: note,
                createdAt: createdAt,
                lastSyncedAt: lastSyncedAt,
                isDirty: isDirty,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventDhtKey,
                required String attendeePubkey,
                required String status,
                Value<int> guestCount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastSyncedAt,
                Value<bool> isDirty = const Value.absent(),
              }) => CachedRsvpsCompanion.insert(
                id: id,
                eventDhtKey: eventDhtKey,
                attendeePubkey: attendeePubkey,
                status: status,
                guestCount: guestCount,
                note: note,
                createdAt: createdAt,
                lastSyncedAt: lastSyncedAt,
                isDirty: isDirty,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedRsvpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRsvpsTable,
      CachedRsvp,
      $$CachedRsvpsTableFilterComposer,
      $$CachedRsvpsTableOrderingComposer,
      $$CachedRsvpsTableAnnotationComposer,
      $$CachedRsvpsTableCreateCompanionBuilder,
      $$CachedRsvpsTableUpdateCompanionBuilder,
      (
        CachedRsvp,
        BaseReferences<_$AppDatabase, $CachedRsvpsTable, CachedRsvp>,
      ),
      CachedRsvp,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      required String operation,
      required String recordType,
      required int localRecordId,
      Value<String?> dhtKey,
      required String payload,
      Value<int> retryCount,
      Value<String?> lastError,
      required DateTime queuedAt,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> completedAt,
      Value<String> status,
    });
typedef $$SyncQueueTableUpdateCompanionBuilder =
    SyncQueueCompanion Function({
      Value<int> id,
      Value<String> operation,
      Value<String> recordType,
      Value<int> localRecordId,
      Value<String?> dhtKey,
      Value<String> payload,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<DateTime> queuedAt,
      Value<DateTime?> lastAttemptAt,
      Value<DateTime?> completedAt,
      Value<String> status,
    });

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get localRecordId => $composableBuilder(
    column: $table.localRecordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dhtKey => $composableBuilder(
    column: $table.dhtKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get localRecordId => $composableBuilder(
    column: $table.localRecordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dhtKey => $composableBuilder(
    column: $table.dhtKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get localRecordId => $composableBuilder(
    column: $table.localRecordId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dhtKey =>
      $composableBuilder(column: $table.dhtKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<int> localRecordId = const Value.absent(),
                Value<String?> dhtKey = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                operation: operation,
                recordType: recordType,
                localRecordId: localRecordId,
                dhtKey: dhtKey,
                payload: payload,
                retryCount: retryCount,
                lastError: lastError,
                queuedAt: queuedAt,
                lastAttemptAt: lastAttemptAt,
                completedAt: completedAt,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operation,
                required String recordType,
                required int localRecordId,
                Value<String?> dhtKey = const Value.absent(),
                required String payload,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime queuedAt,
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                operation: operation,
                recordType: recordType,
                localRecordId: localRecordId,
                dhtKey: dhtKey,
                payload: payload,
                retryCount: retryCount,
                lastError: lastError,
                queuedAt: queuedAt,
                lastAttemptAt: lastAttemptAt,
                completedAt: completedAt,
                status: status,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalIdentitiesTableTableManager get localIdentities =>
      $$LocalIdentitiesTableTableManager(_db, _db.localIdentities);
  $$CachedEventsTableTableManager get cachedEvents =>
      $$CachedEventsTableTableManager(_db, _db.cachedEvents);
  $$CachedRsvpsTableTableManager get cachedRsvps =>
      $$CachedRsvpsTableTableManager(_db, _db.cachedRsvps);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}

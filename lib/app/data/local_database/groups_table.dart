import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class GroupsTable {
  final groupsTableName = groupTable;
  final usersTableName = usersTable;
  final userGroupsTableName = userGroupsTable;

  Future<void> createTable(Database database) async {
    await createTableGroup(database);
    await createTableUsers(database);

    await createTableUserGroups(database);
  }

  Future<void> createTableGroup(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $groupsTableName (
            id INTEGER PRIMARY KEY,
            name TEXT,
            displayPicture TEXT,
            groupDescription TEXT,
            creatorId INTEGER,
            isActive INTEGER
      );
    """);
  }

  Future<void> createTableUsers(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $usersTableName (
            userId INTEGER PRIMARY KEY,
            countryCode INTEGER,
            phoneNumber TEXT,
            name TEXT,
            email TEXT,
            userDescription TEXT,
            isOnline INTEGER,
            displayPicture TEXT,
            displayPictureUrl TEXT
      );
    """);
  }

  Future<void> createTableUserGroups(Database database) async {
    await database.execute("""
      CREATE TABLE IF NOT EXISTS $userGroupsTableName (
            groupId INTEGER,
            userId INTEGER,
            isAdmin INTEGER,
            updaterId INTEGER,
            PRIMARY KEY (groupId, userId),
            FOREIGN KEY (groupId) REFERENCES groups(id) ON DELETE CASCADE,
            FOREIGN KEY (userId) REFERENCES users(userId) ON DELETE CASCADE
      );
    """);
  }

  Future<void> insertGroupWithUsers(CreateGroupModel data) async {
    final db = await DataBaseService().database;
    final dataDb = data.data!;
    final group = {
      'id': dataDb.id,
      'name': dataDb.name,
      'displayPicture': dataDb.displayPicture,
      'groupDescription': dataDb.groupDescription,
      'creatorId': dataDb.creatorId,
      'isActive': dataDb.isActive,
    };

    await db.insert('groups', group,
        conflictAlgorithm: ConflictAlgorithm.replace);

    for (var user in dataDb.users!) {
      final userInfo = user.userInfo!;
      final userGroupInfo = user.userGroupInfo!;

      await db.insert(
          'users',
          {
            'userId': userInfo.userId,
            'countryCode': userInfo.countryCode,
            'phoneNumber': userInfo.phoneNumber,
            'name': userInfo.name,
            'email': userInfo.email,
            'userDescription': userInfo.userDescription,
            'isOnline': userInfo.isOnline,
            'displayPicture': userInfo.displayPicture,
            'displayPictureUrl': userInfo.displayPictureUrl,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);

      await db.insert(
          'user_groups',
          {
            'groupId': userGroupInfo.groupId,
            'userId': userGroupInfo.userId,
            'isAdmin': userGroupInfo.isAdmin!,
            'updaterId': userGroupInfo.updaterId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Future<List<CreateGroupModel>> fetchAll() async {
  //   final db = await DataBaseService().database;
  //   final result = await db.query(userGroupsTable);
  //   return result.map((e) => CreateGroupModel.fromJson(e)).toList();
  // }

  Future<void> insertGroup(GroupData group) async {
    final db = await DataBaseService().database;

    await db.insert(groupsTableName, {
      'id': group.id,
      'name': group.name,
      'displayPicture': group.displayPicture,
      'groupDescription': group.groupDescription,
      'creatorId': group.creatorId,
      'isActive': group.isActive!,
    });

    for (var user in group.users!) {
      final info = user.userInfo!;
      final groupInfo = user.userGroupInfo!;

      await db.insert(usersTableName, {
        'userId': info.userId,
        'countryCode': info.countryCode,
        'phoneNumber': info.phoneNumber,
        'name': info.name,
        'email': info.email,
        'userDescription': info.userDescription,
        'isOnline': info.isOnline!,
        'displayPicture': info.displayPicture,
        'displayPictureUrl': info.displayPictureUrl,
      });

      await db.insert(userGroupsTableName, {
        'groupId': groupInfo.groupId,
        'userId': groupInfo.userId,
        'isAdmin': groupInfo.isAdmin!,
        'updaterId': groupInfo.updaterId,
      });
    }
  }

  Future<List<GroupData>> getAllGroups(Database db) async {
    final groupMaps = await db.query('groups');
    List<GroupData> groups = [];

    for (var groupMap in groupMaps) {
      final groupId = groupMap['id'] as int;

      final userGroupMaps = await db.rawQuery('''
      SELECT * FROM user_group_info 
      INNER JOIN user_info ON user_info.userId = user_group_info.userId 
      WHERE user_group_info.groupId = ?
    ''', [groupId]);

      final users = userGroupMaps.map((map) {
        return Users(
          userInfo: UserInfo(
            userId: map['userId'] as int,
            countryCode: map['countryCode'] as int,
            phoneNumber: map['phoneNumber'] as String,
            name: map['name'] as String,
            email: map['email'] as String,
            userDescription: map['userDescription'] as String?,
            isOnline: map['isOnline'] as int,
            displayPicture: map['displayPicture'] as String,
            displayPictureUrl: map['displayPictureUrl'] as String,
          ),
          userGroupInfo: UserGroupInfo(
            groupId: map['groupId'] as int,
            userId: map['userId'] as int,
            isAdmin: map['isAdmin'] as int,
            updaterId: map['updaterId'] as int,
          ),
        );
      }).toList();

      groups.add(GroupData(
        id: groupMap['id'] as int,
        name: groupMap['name'] as String,
        displayPicture: groupMap['displayPicture'] as String,
        groupDescription: groupMap['groupDescription'] as String?,
        creatorId: groupMap['creatorId'] as int,
        isActive: groupMap['isActive'] as int,
        users: users,
      ));
    }

    return groups;
  }

  Future<void> deleteGroup(int groupId, Database db) async {
    await db.delete(userGroupsTableName,
        where: 'groupId = ?', whereArgs: [groupId]);
    await db.delete('groups', where: 'id = ?', whereArgs: [groupId]);
  }

  Future<void> updateGroup(GroupData group, Database db) async {
    await db.update(
      'groups',
      {
        'name': group.name,
        'displayPicture': group.displayPicture,
        'groupDescription': group.groupDescription,
        'creatorId': group.creatorId,
        'isActive': group.isActive!,
      },
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteTable() async {
    final db = await DataBaseService().database;
    await db.execute('DROP TABLE IF EXISTS $groupsTableName');
    await createTableGroup(db);
    await createTableUsers(db);
    await createTableUserGroups(db);
  }
}

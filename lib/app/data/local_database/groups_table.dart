import 'package:genchatapp/app/constants/constants.dart';
import 'package:genchatapp/app/data/models/new_models/response_model/create_group_model.dart';
import 'package:sqflite/sqflite.dart';
import 'local_database.dart';

class GroupsTable {
  final String groupsTableName = groupTable;
  final String usersTableName = usersTable;
  final String userGroupsTableName = userGroupsTable;

  Future<void> createTable(Database db) async {
    await db.execute( '''
      CREATE TABLE IF NOT EXISTS $groupsTableName (
        id INTEGER PRIMARY KEY,
        name TEXT,
        displayPicture TEXT,
        groupDescription TEXT,
        creatorId INTEGER,
        createdAt TEXT,
        updatedAt TEXT,
        displayPictureUrl TEXT,
        isActive INTEGER
      );
    ''');

    await db.execute('''
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
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $userGroupsTableName (
        groupId INTEGER,
        userId INTEGER,
        isAdmin INTEGER,
        updaterId INTEGER,
        createdAt TEXT,
        updatedAt TEXT,
        isRemoved INTEGER,
        PRIMARY KEY (groupId, userId),
        FOREIGN KEY (groupId) REFERENCES $groupsTableName(id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES $usersTableName(userId) ON DELETE CASCADE
      );
    ''');
  }

  /// ⚠️ Call this in `onUpgrade` inside your database service
  Future<void> migrate(Database db) async {
    // Example: Add a column if not exists
    final columns = await db.rawQuery("PRAGMA table_info($groupsTableName)");
    final hasGroupDescription = columns.any((col) => col['name'] == 'groupDescription');

    if (!hasGroupDescription) {
      await db.execute('ALTER TABLE $groupsTableName ADD COLUMN groupDescription TEXT;');
    }
    // Repeat for any other missing columns
  }

  Future<void> insertOrUpdateGroup(GroupData groupData) async {
    final db = await DataBaseService().database;
    final group = groupData.group;

    await db.insert(groupsTableName, {
      'id': group?.id,
      'name': group?.name,
      'displayPicture': group?.displayPicture,
      'groupDescription': group?.groupDescription,
      'creatorId': group?.creatorId,
      'createdAt': group?.createdAt,
      'updatedAt': group?.updatedAt,
      'displayPictureUrl': group?.displayPictureUrl,
      'isActive': group?.isActive == true ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (User user in groupData.users ?? []) {
      final u = user.userInfo!;
      final g = user.userGroupInfo!;

      await db.insert(usersTableName, {
        'userId': u.userId,
        'countryCode': u.countryCode,
        'phoneNumber': u.phoneNumber,
        'name': u.name,
        'email': u.email,
        'userDescription': u.userDescription,
        'isOnline': u.isOnline == true ? 1 : 0,
        'displayPicture': u.displayPicture,
        'displayPictureUrl': u.displayPictureUrl,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await db.insert(userGroupsTableName, {
        'groupId': g.groupId,
        'userId': g.userId,
        'isAdmin': g.isAdmin == true ? 1 : 0,
        'updaterId': g.updaterId,
        'createdAt': g.createdAt,
        'updatedAt': g.updatedAt,
        'isRemoved': g.isRemoved == true ? 1 : 0,

      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<GroupData>> fetchAllGroups() async {
    final db = await DataBaseService().database;
    final groupRows = await db.query(groupsTableName);

    List<GroupData> groupList = [];

    for (final group in groupRows) {
      final groupId = group['id'] as int;

      final joined = await db.rawQuery('''
        SELECT u.*, ug.groupId, ug.isAdmin, ug.updaterId
        FROM $userGroupsTableName ug
        JOIN $usersTableName u ON u.userId = ug.userId
        WHERE ug.groupId = ?
      ''', [groupId]);

      final users = joined.map((row) {
        return User(
          userInfo: UserInfo(
            userId: row['userId'] as int,
            countryCode: row['countryCode'] as int,
            phoneNumber: row['phoneNumber'] as String,
            name: row['name'] as String,
            email: row['email'] as String,
            userDescription: row['userDescription'] as String?,
            isOnline: row['isOnline'] == 1,
            displayPicture: row['displayPicture'] as String?,
            displayPictureUrl: row['displayPictureUrl'] as String?,
          ),
          userGroupInfo: UserGroupInfo(
            groupId: row['groupId'] as int,
            userId: row['userId'] as int,
            isAdmin: row['isAdmin'] == 1,
            updaterId: row['updaterId'] as int?,
          ),
        );
      }).toList();

      groupList.add(GroupData(
        group: Group(
          id: group['id'] as int,
          name: group['name'] as String,
          displayPicture: group['displayPicture'] as String?,
          groupDescription: group['groupDescription'] as String?,
          creatorId: group['creatorId'] as int,
          isActive: group['isActive'] == 1,
        ),
        users: users,
      ));
    }

    return groupList;
  }

  Future<void> deleteGroup(int groupId) async {
    final db = await DataBaseService().database;
    await db.delete(groupsTableName, where: 'id = ?', whereArgs: [groupId]);
    // users table is NOT deleted — only user_groups cascades
  }

  Future<void> updateGroupDetails(int groupId, {
    String? name,
    String? description,
    String? displayPicture,
  }) async {
    final db = await DataBaseService().database;
    final Map<String, dynamic> updateData = {};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['groupDescription'] = description;
    if (displayPicture != null) updateData['displayPicture'] = displayPicture;

    if (updateData.isNotEmpty) {
      await db.update(
        groupsTableName,
        updateData,
        where: 'id = ?',
        whereArgs: [groupId],
      );
    }
  }

  Future<void> deleteGroupsTable() async {
    final db = await DataBaseService().database;

    // Drop user_groups first due to foreign key constraints
    await db.execute('DROP TABLE IF EXISTS $userGroupsTableName;');
    await db.execute('DROP TABLE IF EXISTS $usersTableName;');
    await db.execute('DROP TABLE IF EXISTS $groupsTableName;');
    await createTable(db);
  }

}

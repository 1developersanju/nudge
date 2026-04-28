import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nudge_study.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE topics (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        topicId TEXT NOT NULL,
        dueAt TEXT NOT NULL,
        wave INTEGER NOT NULL,
        status INTEGER NOT NULL,
        FOREIGN KEY (topicId) REFERENCES topics (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> insertTopic(LearningTopic topic) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.insert(
        'topics',
        {
          'id': topic.id,
          'title': topic.title,
          'notes': topic.notes,
          'createdAt': topic.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (final review in topic.reviews) {
        await txn.insert(
          'reviews',
          {
            'id': review.id,
            'topicId': topic.id,
            'dueAt': review.dueAt.toIso8601String(),
            'wave': review.wave.index,
            'status': review.status.index,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<LearningTopic>> getAllTopics() async {
    final db = await instance.database;

    final topicMaps = await db.query(
      'topics',
      orderBy: 'createdAt DESC',
    );

    final List<LearningTopic> topics = [];

    for (final topicMap in topicMaps) {
      final reviewMaps = await db.query(
        'reviews',
        where: 'topicId = ?',
        whereArgs: [topicMap['id']],
      );

      final List<ReviewEvent> reviews = reviewMaps.map((rMap) {
        return ReviewEvent(
          id: rMap['id'] as String,
          dueAt: DateTime.parse(rMap['dueAt'] as String),
          wave: ReviewWave.values[rMap['wave'] as int],
          status: ReviewStatus.values[rMap['status'] as int],
        );
      }).toList();

      topics.add(LearningTopic(
        id: topicMap['id'] as String,
        title: topicMap['title'] as String,
        notes: topicMap['notes'] as String?,
        createdAt: DateTime.parse(topicMap['createdAt'] as String),
        reviews: reviews,
      ));
    }

    return topics;
  }

  Future<void> updateTopic(LearningTopic topic) async {
    final db = await instance.database;
    await db.update(
      'topics',
      {
        'title': topic.title,
        'notes': topic.notes,
      },
      where: 'id = ?',
      whereArgs: [topic.id],
    );
  }

  Future<void> deleteTopic(String id) async {
    final db = await instance.database;
    // Due to ON DELETE CASCADE, reviews will be deleted automatically if we enable foreign keys.
    // However, sqflite doesn't enable foreign keys by default. 
    // It's safer to explicitly delete reviews first.
    await db.transaction((txn) async {
      await txn.delete(
        'reviews',
        where: 'topicId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        'topics',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updateReview(ReviewEvent review) async {
    final db = await instance.database;
    await db.update(
      'reviews',
      {
        'dueAt': review.dueAt.toIso8601String(),
        'status': review.status.index,
      },
      where: 'id = ?',
      whereArgs: [review.id],
    );
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('reviews');
      await txn.delete('topics');
    });
  }
}

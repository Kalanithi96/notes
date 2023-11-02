const dbName = 'notes.db';
const userTable = 'user';
const notesTable = 'notes';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const titleColumn = 'title';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE "user" (
                                  "id"	INTEGER NOT NULL,
                                  "email"	TEXT NOT NULL UNIQUE,
                                  PRIMARY KEY("id" AUTOINCREMENT)
                                );''';
const createNotesTable = '''CREATE TABLE "notes" (
                                  "id"	INTEGER NOT NULL UNIQUE,
                                  "user_id"	INTEGER NOT NULL,
                                  "text"	TEXT,
                                  "title"	TEXT NOT NULL,
                                  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                                  FOREIGN KEY("user_id") REFERENCES "user"("id") ON UPDATE CASCADE ON DELETE CASCADE,
                                  PRIMARY KEY("id")
                                );''';
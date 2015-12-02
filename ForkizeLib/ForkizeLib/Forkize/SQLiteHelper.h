//
//  Helper.h
//  ForkizeLib
//
//  Created by Artak Martirosyan on 9/9/15.
//  Copyright (c) 2015 Artak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define SQLITE_ROW_CALLBACK(X) BOOL (^X)(SQLiteRow *) = ^(SQLiteRow *row)
#define THROW_CANT_CREATE_INSTANCE 	@throw [NSException exceptionWithName:@"Can't create instance" reason:@"Default constructor must not be used" userInfo:nil]


@class SQLiteRow;
@interface SQLiteStatement : NSObject {
@private
	sqlite3_stmt *statement_;	//Strong
	sqlite3 *database_;			//Weak
}

- (void)setString:(NSString *)string forParam:(NSString *)param;
- (void)setInteger:(NSInteger)integer forParam:(NSString *)param;
- (void)setDate:(NSDate *)date forParam:(NSString *)param;
- (void)setFloat:(float)value forParam:(NSString *)param;

- (void)reset;

- (void)executeQueryWithCallBack:(BOOL (^)(SQLiteRow *))callBack;
- (NSInteger)executeUpdate;
- (NSInteger) executeSelectColumnInt;

- (NSInteger)lastId;

@end

@interface SQLiteRow : NSObject {
@private
	sqlite3_stmt *statement_;	//Weak
}

- (NSString *)stringAtIndex:(NSInteger)index;
- (NSInteger)integerAtIndex:(NSInteger)index;
- (NSDate *)dateAtIndex:(NSInteger)index;
- (float)floatAtIndex:(NSInteger)index;

@end

@interface SQLiteDatabase : NSObject {
@private
	sqlite3 *database_;
}

- (id)initWithDBPath:(NSString *)dbPath;

- (SQLiteStatement *)statementWithSQLString:(NSString *)sqlString;
- (NSInteger)executeInTransaction:(SQLiteStatement *)statements, ...;
- (BOOL)execute:(NSString *)sql;
- (BOOL)executeFile:(NSString *)filePath;

- (void)beginTransaction;
- (void)commit;
- (void)rollback;


@end

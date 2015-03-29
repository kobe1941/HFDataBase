//
//  HFDBManager.m
//  HFDatabase
//
//  Created by 胡峰 on 14-11-24.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import "HFDBManager.h"
#import <sqlite3.h>
#import "Person.h"

const NSString *PersonTable = @"PersonTable";

@interface HFDBManager ()
{
    sqlite3 *_database;
}

@property (nonatomic, copy) NSString *SqliteName;
@property (nonatomic, copy) NSString *tableName;


@end

@implementation HFDBManager

+ (instancetype)shareManager
{
    static HFDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
        
    });
    
    return manager;
}

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *path = [paths lastObject];
    
    return [path stringByAppendingString:@"/test.sqlite"]; // 可以定义成任何类型的文件
}

- (BOOL)openSqliteDatabase
{
    if (sqlite3_open([[self dataFilePath] UTF8String], &_database) != SQLITE_OK)
    {
        sqlite3_close(_database);
        
        NSAssert(0, @"数据库打开失败");
        
        return NO;
    }
    
    return YES;
}

- (BOOL)createTableWithName:(NSString *)aTableName
{
    [self openSqliteDatabase];
    
    self.tableName = aTableName;
    
    // 同一张表，主键的名字不能更换，除非删掉表、数据库或者删掉app重装
    NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('id' INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 'name' TEXT, 'desc' TEXT)",aTableName];
    
    char *errorMsg;
    
    if (sqlite3_exec(_database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(_database);
        
        NSAssert(0, @"创建表失败:%s",errorMsg);
        
        return NO;
    }
    
    return YES;
}

#pragma mark - 插入数据

- (void)insertPerson:(Person *)aPerson toTable:(NSString *)aTableName
{
    [self openSqliteDatabase];
    
    if (![self isTableExist:aTableName])
    {
        [self createTableWithName:aTableName];
        
        NSLog(@"表不存在，重新创建表成功");
    }
    
    
    NSString *insertString = [NSString stringWithFormat:@"insert into '%@'(name,desc) values(?,?)",aTableName];
    
    sqlite3_stmt *stmt;
    
    NSString *aName = aPerson.name;
    NSString *aDesc = aPerson.desc;
    
    int result = sqlite3_prepare_v2(_database, [insertString UTF8String], -1, &stmt, nil);
    if (result == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [aName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [aDesc UTF8String], -1, NULL);
        
    } else
    {
        NSAssert(0, @"插入数据库出错,err code: %d",result);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
    {
        NSAssert(0, @"数据库插入失败!!");
    }
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(_database);
}

#pragma mark - 更新数据

- (void)updatePerson:(Person *)aPerson withTable:(NSString *)aTableName
{
    [self openSqliteDatabase];
    
    if (![self isTableExist:aTableName])
    {
        NSLog(@"表不存在，请检查!");
        
        sqlite3_close(_database);
        return;
    }
    
//    NSString *updateString = [NSString stringWithFormat:@"UPDATE '%@' SET name = ?, desc = ? where id = '%d'",aTableName,aPerson.personID];
    NSString *updateString = [NSString stringWithFormat:@"UPDATE '%@' SET name = ?, desc = ? where id = ?",aTableName];
    
    
    sqlite3_stmt *stmt;
    
    NSString *aName = aPerson.name;
    NSString *aDesc = aPerson.desc;
    
    int result = sqlite3_prepare_v2(_database, [updateString UTF8String], -1, &stmt, nil);
    
    if (result != SQLITE_OK)
    {
        NSAssert(0, @"更新数据库出错,err code: %d",result);
        sqlite3_close(_database);
        return;
    }
    
    sqlite3_bind_text(stmt, 1, [aName UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 2, [aDesc UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(stmt, 3, aPerson.personID);
    
    // 执行SQL语句,这里才是更新数据库，前面只是做准备
    if (sqlite3_step(stmt) == SQLITE_ERROR)
    {
        NSAssert(0, @"数据库更新失败!!");
        sqlite3_close(_database);
        return;
    }
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(_database);
}

// 第二种更新方法
- (void)update2Person:(Person *)aPerson withTable:(NSString *)aTableName
{
    [self openSqliteDatabase];
    
    if (![self isTableExist:aTableName])
    {
        NSLog(@"表不存在，请检查!");
        sqlite3_close(_database);
        return;
    }
    
    NSString *updateString = [NSString stringWithFormat:@"UPDATE '%@' SET name = '%@', desc = '%@' where id = '%d'",aTableName,aPerson.name,aPerson.desc,aPerson.personID];
    
    if (sqlite3_exec(_database, [updateString UTF8String], NULL, NULL, nil) != SQLITE_OK)
    {
        NSAssert(NO, @"更新失败");
        sqlite3_close(_database);
        return;
    }
    
    sqlite3_close(_database);
}


#pragma mark - 删除一个数据

- (BOOL)deletePerson:(Person *)aPerson fromTable:(NSString *)aTableName
{
    [self openSqliteDatabase];
    
    char *errMsg;
    
    NSString *deleteString = [NSString stringWithFormat:@"delete from '%@' where id = '%d'",aTableName,aPerson.personID];
    
    if (sqlite3_exec(_database, [deleteString UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
    {
        NSAssert(NO, @"删除数据出错");
        
        sqlite3_close(_database);
        return NO;
    }
    
    sqlite3_close(_database);
    
    return YES;
}

#pragma mark - 查询数据

- (NSArray *)getAllPersonsWithTableName:(NSString *)aTableName
{
    [self openSqliteDatabase];

    
    if (![self isTableExist:aTableName])
    {
        NSLog(@"要查询的表不存在，请检查表名");
        return nil;
    }
    
    NSString *query = [NSString stringWithFormat:@"select * from '%@'",aTableName];
    
    sqlite3_stmt *stmt;
    
    NSMutableArray *mutable = [NSMutableArray array];
    
    int result = sqlite3_prepare_v2(_database, [query UTF8String], -1, &stmt, nil);
    
    if (result == SQLITE_OK)
    {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            unsigned int personId = (int)sqlite3_column_int(stmt, 0);
            
            char *name = (char *)sqlite3_column_text(stmt, 1);
            NSString *nameString = [[NSString alloc] initWithUTF8String:name];
            
            char *desc = (char *)sqlite3_column_text(stmt, 2);
            NSString *descString = [[NSString alloc] initWithUTF8String:desc];

            NSLog(@"id=%d,name = %s,desc = %s",personId,name,desc);
            
            Person *person = [[Person alloc] initWithName:nameString desc:descString personId:personId];
            [mutable addObject:person];
        }
        
        sqlite3_finalize(stmt);

    } else
    {
        NSLog(@"error code = %d",result);
    }
    
    sqlite3_close(_database);
    
    return mutable;
}

#pragma mark - 清除一个表的数据

- (void)deleteTableWithName:(NSString *)aTableName
{
    [self openSqliteDatabase];
    
    if (![self isTableExist:aTableName])
    {
        NSLog(@"要清空的表不存在");
        return;
    }
    
    char *errmsg;
    
    NSString *dropString = [NSString stringWithFormat:@"delete from '%@'",aTableName];
    
    int result = sqlite3_exec(_database, [dropString UTF8String], NULL, NULL, &errmsg);
    
    if (result != SQLITE_OK)
    {
        NSLog(@"删除出错--错误码%d--%p",result,errmsg);
    }
    
    // 表的名字必须由''括起来
    NSString *resetString = [NSString stringWithFormat:@"UPDATE sqlite_sequence SET seq = 0 WHERE name = '%@'",aTableName];
    
    // 将所有的表的自增列全部清0，测试通过.
//    NSString *resetString = [NSString stringWithFormat:@"delete from sqlite_sequence"];
    
    
    result = sqlite3_exec(_database, [resetString UTF8String], NULL, NULL, &errmsg);
    if (result != SQLITE_OK)
    {
        NSLog(@"主键清0失败--错误码%d-%s",result,errmsg);
    }
    
    
    sqlite3_close(_database);
}

#pragma mark - 删除一个表
- (void)dropTableWithName:(NSString *)aTableName
{
    [self openSqliteDatabase];

    
    if (![self isTableExist:aTableName])
    {
        NSLog(@"要删除的表不存在");
        return;
    }
    
    char *errMsg;
    NSString *deleteString = [NSString stringWithFormat:@"drop table if exists '%@'",aTableName];
    
    int result = sqlite3_exec(_database, [deleteString UTF8String], NULL, NULL, &errMsg);
    
    if (result != SQLITE_OK)
    {
        NSLog(@"删除表失败 - %d",result);
    }
    
    sqlite3_close(_database);
}

#pragma mark - 判断该表是否存在
- (BOOL)isTableExist:(NSString *)aTableName
{
    BOOL exist = NO;
    sqlite3_stmt *stmt;
    
    NSString *judgeString = [NSString stringWithFormat:@"SELECT name FROM sqlite_master where type ='table' and name = '%@';",aTableName];
    const char *sql_stmt = [judgeString UTF8String];
    
    if (sqlite3_prepare_v2(_database, sql_stmt, -1, &stmt, nil) == SQLITE_OK)
    {
        int temp = sqlite3_step(stmt);
        if (temp == SQLITE_ROW)
        {
            exist = YES;
        } else
        {
            NSLog(@"temp = %d",temp);
        }
    }
    
    sqlite3_finalize(stmt);
    
    return exist;
}
@end
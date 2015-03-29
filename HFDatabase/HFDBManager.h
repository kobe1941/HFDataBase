//
//  HFDBManager.h
//  HFDatabase
//
//  Created by 胡峰 on 14-11-24.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSString *PersonTable;

@class Person;

@interface HFDBManager : NSObject

+ (instancetype)shareManager;


- (BOOL)createTableWithName:(NSString *)aTableName;

// 清除表的数据
- (void)deleteTableWithName:(NSString *)aTableName;

// 删除表
- (void)dropTableWithName:(NSString *)aTableName;


- (NSArray *)getAllPersonsWithTableName:(NSString *)aTableName;

// 插入
- (void)insertPerson:(Person *)aPerson toTable:(NSString *)aTableName;

// 更新
- (void)updatePerson:(Person *)aPerson withTable:(NSString *)aTableName;

// 删除一个数据
- (BOOL)deletePerson:(Person *)aPerson fromTable:(NSString *)aTableName;

@end
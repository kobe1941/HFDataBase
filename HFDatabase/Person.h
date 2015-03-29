//
//  Person.h
//  HFDatabase
//
//  Created by 胡峰 on 14-11-25.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Person : NSObject


@property (nonatomic, assign) int personID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;

- (instancetype)initWithName:(NSString *)aName desc:(NSString *)aDesc personId:(int)aId;

@end

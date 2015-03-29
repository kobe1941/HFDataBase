//
//  Person.m
//  HFDatabase
//
//  Created by 胡峰 on 14-11-25.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import "Person.h"



@implementation Person

- (instancetype)initWithName:(NSString *)aName desc:(NSString *)aDesc personId:(int)aId
{
    self = [super init];
    
    if (self)
    {
        self.name = aName;
        self.desc = aDesc;
        self.personID = aId;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%p,%@,[id =%d, name = %@,desc = %@]>",self,[self class],self.personID,self.name,self.desc];
}

- (NSString *)debugDescription
{
    return [self description];
}

@end

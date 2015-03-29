//
//  DetailViewController.h
//  HFDatabase
//
//  Created by 胡峰 on 14-11-24.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import <UIkit/UIKit.h>

@class Person;

@interface DetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextView *desc;

@property (nonatomic, strong) Person *person;

@end

//
//  DetailViewController.m
//  HFDatabase
//
//  Created by 胡峰 on 14-11-24.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import "DetailViewController.h"

#import "HFDBManager.h"

#import "Person.h"

@interface DetailViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) HFDBManager *DBManager;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.name.text = self.person.name;
    self.desc.text = self.person.desc;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}


#pragma mark - getter Methods

- (HFDBManager *)DBManager
{
    if (!_DBManager)
    {
        _DBManager = [HFDBManager shareManager];
    }
    
    return _DBManager;
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self textFieldDidEndEditing:textField];
    
    return YES;
}

#pragma mark - UITextViewDelegate Methods

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
    
}


- (IBAction)saveData:(id)sender
{
    [self.name resignFirstResponder];
    
    [self.desc resignFirstResponder];
    

    
    if (self.person)
    {
        // 更新数据
        self.person.name = self.name.text;
        self.person.desc = self.desc.text;
        [self.DBManager updatePerson:self.person withTable:[PersonTable copy]];
        
    } else
    {
        // 插入数据
        
        Person *person = [[Person alloc] initWithName:self.name.text desc:self.desc.text personId:0];
        
        [self.DBManager insertPerson:person toTable:[PersonTable copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end

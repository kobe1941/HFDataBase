//
//  ViewController.m
//  HFDatabase
//
//  Created by 胡峰 on 14-11-24.
//  Copyright (c) 2014年 胡峰. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"

#import "HFDBManager.h"

#import "Person.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HFDBManager *DBManager;

@property (nonatomic, strong) NSMutableArray *allData;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAllData)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
     self.allData = nil;
    
    [self.tableView reloadData];
}

#pragma mark - getter Metods

- (HFDBManager *)DBManager
{
    if (!_DBManager)
    {
        _DBManager = [HFDBManager shareManager];
    }
    
    return _DBManager;
}

- (NSMutableArray *)allData
{
    if (!_allData)
    {
        _allData = [NSMutableArray arrayWithArray:[self.DBManager getAllPersonsWithTableName:[PersonTable copy]]];
    }
    
    return _allData;
}

#pragma mark - 清空表中的数据
- (void)deleteAllData
{
    [self.DBManager deleteTableWithName:[PersonTable copy]];

    
    self.allData = nil;
    
    [self.tableView reloadData];
}

#pragma mark - 增加一个数据
- (void)addPerson
{
    DetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    Person *person = [self.allData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@-%@",person.name,person.desc];
    
    return cell;
}


#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 修改信息
    DetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    Person *person = [self.allData objectAtIndex:indexPath.row];
    
    detailVC.person = person;
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete)
    {
        return;
    }
    
    Person *person = [self.allData objectAtIndex:indexPath.row];
    
    if (![self.DBManager deletePerson:person fromTable:[PersonTable copy]])
    {
        return;
    }
    
    [self.allData removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

@end
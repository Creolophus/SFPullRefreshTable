//
//  TopLoadViewController.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "TopLoadViewController.h"
#import "SFPullRefreshTableView.h"

@interface TopLoadViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *items;
@property (assign, nonatomic) NSInteger page;

@property (strong, nonatomic) SFPullRefreshTableView *table;

@end


@implementation TopLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _page = 0;
    _items = [NSMutableArray array];
    for (int i=0; i<10; i++) {
        [_items insertObject:[NSString stringWithFormat:@"this is row%i", i+_page*10] atIndex:0];
    }
    _page++;
    
    _table = [[SFPullRefreshTableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain pullRefreshType:PRTypeTopLoad];
    _table.dataSource = self;
    _table.delegate = self;
    [self.view addSubview:_table];
    
    [_table addLoadTarget:self action:@selector(loadStrings)];
    [_table addRefreshTarget:self action:@selector(loadStrings)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    _table.contentOffset = CGPointMake(0, _table.contentSize.height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStrings
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_table.isRefreshing) {
            [_items removeAllObjects];
            _page = 0;
        }
        for (int i=0; i<10; i++) {
            [_items insertObject:[NSString stringWithFormat:@"this is row%i", i+_page*10] atIndex:0];
        }
        _page++;
        if (_page == 3) {
            _table.reachedEnd = YES;
        }
        [_table reloadData];
        [_table finishLoading];
    });
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [_items objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

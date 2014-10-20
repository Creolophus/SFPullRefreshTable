//
//  PullingRefreshTableView.h
//  PullingTableView
//
//  Created by danal on 3/6/12.If you want use it,please leave my name here
//  Copyright (c) 2012 danal Luo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PRTypeNormal = 0,
    PRTypeTopRefresh,
    PRTypeBottomLoad,
    PRTypeTopRefreshBottomLoad,
    PRTypeTopLoad,
} PullRefreshType;

typedef void (^RefreshHandler)();
typedef void (^LoadHandler)();

@interface SFPullRefreshTableView : UITableView 

@property (assign, nonatomic) BOOL reachedEnd;
@property (assign, nonatomic) BOOL isRefreshing;
@property (assign, nonatomic) BOOL isLoading;

/**
 *  设置尾部控件的文字
 */
@property (copy, nonatomic) NSString *pullToRefreshText; // 默认:@"下拉加载更多"
@property (copy, nonatomic) NSString *releaseToRefreshText; // 默认:@"松开立即加载更多数据"
@property (copy, nonatomic) NSString *refreshingText; // 默认:@"正在刷新"
@property (copy, nonatomic) NSString *loadingText; // 默认:@"正在加载"
@property (copy, nonatomic) NSString *reachEndText; // 默认:@"没有啦！"

@property (copy, nonatomic) RefreshHandler refreshHandler;
@property (copy, nonatomic) LoadHandler loadHandler;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullRefreshType:(PullRefreshType)prType;
- (void)finishLoading;
- (void)addRefreshTarget:(id)target action:(SEL)action;
- (void)addLoadTarget:(id)target action:(SEL)action;

@end
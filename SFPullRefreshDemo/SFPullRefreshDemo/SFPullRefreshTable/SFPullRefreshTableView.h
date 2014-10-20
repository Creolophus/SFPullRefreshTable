//
//  SFPullRefreshTableView.h
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PRTypeNormal = 0, //默认的UITableView
    PRTypeTopRefresh, //只顶部刷新
    PRTypeBottomLoad, //只底部加载更多
    PRTypeTopRefreshBottomLoad, //顶部刷新，底部加载更多
    PRTypeTopLoad, //只顶部加载更多
} PullRefreshType;

typedef void (^RefreshHandler)();
typedef void (^LoadHandler)();

@interface SFPullRefreshTableView : UITableView 

/**
 *  若数据加载完，可以设置YES，来告诉用户到达最末端了。
 */
@property (assign, nonatomic) BOOL reachedEnd;

/**
 *  判断table是不是在刷新。
 *  当从服务器获取到数据时，可以根据这个变量来决定是否需要删除之前的数据。
 */
@property (assign, nonatomic) BOOL isRefreshing;

/**
 *  当table第一次加载时，并且 PullRefreshType == PRTypeTopLoad, 可以设置这个变量来让table是否滚到最底端。
 *  默认值是YES。
 */
@property (assign, nonatomic) BOOL scrollToBottomIfTopLoad;

// 设置尾部控件的文字
/**
 *  下拉刷新的文字
 *  默认:@"下拉加载更多"
 */
@property (copy, nonatomic) NSString *pullToRefreshText;
/**
 *  松开刷新的文字
 *  默认:@"松开刷新"
 */
@property (copy, nonatomic) NSString *releaseToRefreshText;
/**
 *  正在刷新的文字
 *  默认:@"正在刷新"
 */
@property (copy, nonatomic) NSString *refreshingText;
/**
 *  正在加载的文字
 *  默认:@"正在加载"
 */
@property (copy, nonatomic) NSString *loadingText;
/**
 *  数据加载完的文字
 *  默认:@"没有啦！"
 */
@property (copy, nonatomic) NSString *reachEndText;

/**
 *  刷新的回调block，可以用来处理刷新的逻辑
 */
@property (copy, nonatomic) RefreshHandler refreshHandler;
/**
 *  加载的回调block，可以用来处理加载的逻辑
 */
@property (copy, nonatomic) LoadHandler loadHandler;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullRefreshType:(PullRefreshType)prType;

/**
 *  结束加载或刷新
 */
- (void)finishLoading;

/**
 *  也可以用该方法来处理刷新，如果同时设置了refreshHandler，则该方法无效
 *
 *  @param target 处理刷新的对象
 *  @param action 处理的方法
 */
- (void)addRefreshTarget:(id)target action:(SEL)action;
/**
 *  也可以用该方法来处理加载更多，如果同时设置了loadHandler，则该方法无效
 *
 *  @param target 处理加载更多的对象
 *  @param action 处理的方法
 */
- (void)addLoadTarget:(id)target action:(SEL)action;

@end
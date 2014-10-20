//
//  SFPullRefreshTableView.m
//  SFPullRefreshDemo
//
//  Created by shaohua.chen on 10/16/14.
//  Copyright (c) 2014 shaohua.chen. All rights reserved.
//

#import "SFPullRefreshTableView.h"
#import <QuartzCore/QuartzCore.h>

#define PRRefreshControlHeight 60.0
#define PRLoadControlHeight 50.0

#define KeyPathContentSize @"contentSize"
#define KeyPathContentOffset @"contentOffset"

#define PRArrowWidth 20.0
#define PRArrowHeight 40.0

#define PRTextColor [UIColor colorWithRed:108.0/255 green:108.0/255 blue:108.0/255 alpha:1.0]
#define PRBackgroundColor [UIColor clearColor]

#define PRAnimationDuration 0.2

typedef enum {
    PRStateNormal = 0,
    PRStatePullToRefresh,
    PRStateReleaseToRefresh,
    PRStateRefreshing,
    PRStateLoading,
    PRStateReachEnd
} PRState;

@interface SFPRView : UIView

@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL isRefresh;
@property (nonatomic) PRState state;

@property (copy, nonatomic) NSString *pullToRefreshText; // 默认:@"下拉加载更多"
@property (copy, nonatomic) NSString *releaseToRefreshText; // 默认:@"松开立即加载更多数据"
@property (copy, nonatomic) NSString *refreshingText; // 默认:@"正在刷新"
@property (copy, nonatomic) NSString *loadingText; // 默认:@"正在加载"
@property (copy, nonatomic) NSString *reachEndText; // 默认:@"没有啦！"

@property (strong, nonatomic) UILabel *stateLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIImageView *arrowImgView;
@property (strong, nonatomic) CALayer *arrow;

- (id)initWithFrame:(CGRect)frame isRefresh:(BOOL)isRefresh;
- (void)updateRefreshDate:(NSDate *)date;

@end

@implementation SFPRView

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame isRefresh:YES];
    if (self) {
        
    }
    return self;
}

//Default is at top
- (id)initWithFrame:(CGRect)frame isRefresh:(BOOL)isRefresh {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = PRBackgroundColor;
        
        _isRefresh = isRefresh;
        
        _stateLabel = [[UILabel alloc] init ];
        _stateLabel.font = [UIFont systemFontOfSize:15.0];
        _stateLabel.textColor = PRTextColor;
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.backgroundColor = PRBackgroundColor;
        _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_stateLabel];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:_activityView];
        
        if (_isRefresh)
        {
            _dateLabel = [[UILabel alloc] init ];
            _dateLabel.font = [UIFont systemFontOfSize:15.0];
            _dateLabel.textColor = PRTextColor;
            _dateLabel.textAlignment = NSTextAlignmentCenter;
            _dateLabel.backgroundColor = PRBackgroundColor;
            _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self addSubview:_dateLabel];
            
            _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20) ];
            [self addSubview:_arrowImgView];
            
            _arrow = [CALayer layer];
            _arrow.frame = CGRectMake(0, 0, 20, 20);
            _arrow.contentsGravity = kCAGravityResizeAspect;
            _arrow.contents = (id)[UIImage imageWithCGImage:[UIImage imageNamed:@"blueArrow.png"].CGImage scale:1 orientation:UIImageOrientationDown].CGImage;
            [self.layer addSublayer:_arrow];
        }
        
        [self layouts];
        
        [self updateRefreshDate:[NSDate date]];
        
    }
    return self;
}

- (void)layouts{
    
    if (_isRefresh) {
        [_dateLabel setFrame:CGRectMake(0, PRRefreshControlHeight/2, self.frame.size.width, PRRefreshControlHeight/2)];
        
        [_stateLabel setFrame:CGRectMake(0, 0, self.frame.size.width, PRRefreshControlHeight/2)];
        
        [_arrowImgView setFrame:CGRectMake(40, PRRefreshControlHeight/2-PRArrowHeight/2, PRArrowWidth, PRArrowHeight)];
        
        UIImage *arrow = [UIImage imageNamed:@"blueArrow"];
        _arrow.contents = (id)arrow.CGImage;
        _arrow.transform = CATransform3DIdentity;
        [_arrow setFrame:_arrowImgView.frame];
        
        _activityView.center = _arrowImgView.center;
    } else {
        [_stateLabel setFrame:CGRectMake(0, 0, self.frame.size.width, PRLoadControlHeight)];
        _activityView.center = CGPointMake(90, PRLoadControlHeight/2);
    }
}

- (NSString *)pullToRefreshText
{
    if (!_pullToRefreshText) {
        _pullToRefreshText = @"下拉刷新";
    }
    return _pullToRefreshText;
}

- (NSString *)releaseToRefreshText
{
    if (!_releaseToRefreshText) {
        _releaseToRefreshText = @"松开刷新";
    }
    return _releaseToRefreshText;
}

- (NSString *)refreshingText
{
    if (!_refreshingText) {
        _refreshingText = @"正在刷新...";
    }
    return _refreshingText;
}

- (NSString *)loadingText
{
    if (!_loadingText) {
        _loadingText = @"正在加载...";
    }
    return _loadingText;
}

- (NSString *)reachEndText
{
    if (!_reachEndText) {
        _reachEndText = @"没有啦！";
    }
    return _reachEndText;
}

- (void)setState:(PRState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    switch (_state) {
        case PRStatePullToRefresh:
        {
            _stateLabel.text = self.pullToRefreshText;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            
            _arrow.hidden = NO;
            [CATransaction begin];
            [CATransaction setAnimationDuration:PRAnimationDuration];
            _arrow.transform = CATransform3DIdentity;
            [CATransaction commit];
            
            break;
        }
        case PRStateReleaseToRefresh:
        {
            _stateLabel.text = self.releaseToRefreshText;
            
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            _arrow.hidden = NO;
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.1];
            _arrow.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            [CATransaction commit];
            break;
        }
        case PRStateRefreshing:
        {
            _arrow.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
            _stateLabel.text = self.refreshingText;
            break;
        }
        case PRStateLoading:
        {
            _arrow.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
            _stateLabel.text = self.loadingText;
            break;
        }
        case PRStateNormal:
        {
            _arrow.hidden = YES;
            _activityView.hidden = YES;
            [_activityView stopAnimating];
            _stateLabel.text = @"加载更多";
            break;
        }
        case PRStateReachEnd:
        {
            _stateLabel.text = self.reachEndText;
            _arrow.hidden = YES;
            [_activityView stopAnimating];
            _activityView.hidden = YES;
            break;
        }
        default:
            break;
    }
}

- (void)updateRefreshDate:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    NSString *dateString = [df stringFromDate:date];
    NSString *title = NSLocalizedString(@"今天", nil);
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                               fromDate:date toDate:[NSDate date] options:0];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    if (year == 0 && month == 0 && day < 3) {
        if (day == 0) {
            title = NSLocalizedString(@"今天",nil);
        } else if (day == 1) {
            title = NSLocalizedString(@"昨天",nil);
        } else if (day == 2) {
            title = NSLocalizedString(@"前天",nil);
        }
        df.dateFormat = [NSString stringWithFormat:@"%@ HH:mm",title];
        dateString = [df stringFromDate:date];
        
    }
    _dateLabel.text = [NSString stringWithFormat:@"%@: %@",
                       NSLocalizedString(@"最后更新", @""),
                       dateString];
}

@end




@interface SFPullRefreshTableView ()<UIScrollViewDelegate>

@property (assign, nonatomic) PullRefreshType prType;

@property (assign, nonatomic) CGFloat orignContentOffsetY; //若navigationBar半透明，则table会有一个初始的contentOffset，和contentInset
@property (assign, nonatomic) CGFloat orignContentInsetTop;

@property (weak, nonatomic) id refreshTarget;
@property (assign, nonatomic) SEL refreshAction;

@property (weak, nonatomic) id loadTarget;
@property (assign, nonatomic) SEL loadAction;

@property (strong, nonatomic) SFPRView *refreshView;
@property (strong, nonatomic) SFPRView *loadView;

@end

@implementation SFPullRefreshTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [self initWithFrame:frame style:style pullRefreshType:PRTypeNormal];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style pullRefreshType:(PullRefreshType)prType
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        UIView *bgView = [[UIView alloc] init];
        bgView.backgroundColor = [UIColor clearColor];
        self.tableFooterView = bgView;
        self.tableHeaderView = bgView;
        
        _scrollToBottomIfTopLoad = NO;
        _isRefreshing = NO;
        _orignContentOffsetY = -CGFLOAT_MAX;
        _orignContentInsetTop = -CGFLOAT_MAX;
        self.prType = prType;
        
        [self addObserver:self forKeyPath:KeyPathContentSize options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self addObserver:self forKeyPath:KeyPathContentOffset options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:KeyPathContentSize];
    [self removeObserver:self forKeyPath:KeyPathContentOffset];
}

- (void)setPullToRefreshText:(NSString *)pullToRefreshText
{
    self.refreshView.pullToRefreshText = pullToRefreshText;
}

- (void)setReleaseToRefreshText:(NSString *)releaseToRefreshText
{
    self.refreshView.releaseToRefreshText = releaseToRefreshText;
}

- (void)setRefreshingText:(NSString *)refreshingText
{
    self.refreshView.refreshingText = refreshingText;
}

- (void)setLoadingText:(NSString *)loadingText
{
    self.loadView.loadingText = loadingText;
}

- (void)setReachEndText:(NSString *)reachEndText
{
    self.loadView.reachEndText = reachEndText;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    _orignContentInsetTop = self.contentInset.top;
    _orignContentOffsetY = self.contentOffset.y;
}

- (void)setPrType:(PullRefreshType)prType
{
    _prType = prType;
    switch (prType) {
        case PRTypeTopRefresh:
        {
            if (!_refreshView) {
                _refreshView = [[SFPRView alloc] initWithFrame:CGRectMake(0, -PRRefreshControlHeight, self.frame.size.width, PRRefreshControlHeight) isRefresh:YES];
            }
            [self addSubview:_refreshView];
            break;
        }
        case PRTypeBottomLoad:
        {
            if (!_loadView) {
                _loadView = [[SFPRView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, PRLoadControlHeight) isRefresh:NO];
            }
            [self addSubview:_loadView];
            break;
        }
        case PRTypeTopRefreshBottomLoad:
        {
            if (!_refreshView) {
                _refreshView = [[SFPRView alloc] initWithFrame:CGRectMake(0, -PRRefreshControlHeight, self.frame.size.width, PRRefreshControlHeight) isRefresh:YES];
            }
            [self addSubview:_refreshView];

            if (!_loadView) {
                _loadView = [[SFPRView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, PRLoadControlHeight) isRefresh:NO];
            }
            [self addSubview:_loadView];
            break;
        }
        case PRTypeTopLoad:
        {
            _scrollToBottomIfTopLoad = YES;
            if (!_loadView) {
                _loadView = [[SFPRView alloc] initWithFrame:CGRectMake(0, -PRLoadControlHeight, self.frame.size.width, PRLoadControlHeight) isRefresh:NO];
            }
            [self addSubview:_loadView];
            break;
        }
        default:
            break;
    }
}

- (void)setReachedEnd:(BOOL)reachedEnd{
    _reachedEnd = reachedEnd;
    if (_reachedEnd){
        _loadView.state = PRStateReachEnd;
    }
}

- (void)addRefreshTarget:(id)target action:(SEL)action
{
    _refreshTarget = target;
    _refreshAction = action;
}

- (void)addLoadTarget:(id)target action:(SEL)action
{
    _loadTarget = target;
    _loadAction = action;
}


#pragma mark - Scroll methods
- (void)tableViewDidScroll{

    if (_loadView.state == PRStateLoading || _refreshView.state == PRStateRefreshing) {
        return;
    }

    CGPoint offset = self.contentOffset;
    offset.y -= _orignContentOffsetY;
    CGSize size = self.frame.size;
    CGSize contentSize = self.contentSize;
    if (contentSize.height < self.frame.size.height) {
        contentSize.height = self.frame.size.height;
    }

    if (_prType == PRTypeTopLoad) {
        if (_reachedEnd) {
            _loadView.state = PRStateReachEnd;
            return;
        }
        if (offset.y<0) {
            
            _loadView.state = PRStateLoading;
            if (_loadHandler) {
                _loadHandler();
            }
            else if (_loadTarget && [_loadTarget respondsToSelector:_loadAction])
            {
                ((void (*)(id, SEL))[_loadTarget methodForSelector:_loadAction])(_loadTarget, _loadAction);
            }
            
            [UIView animateWithDuration:PRAnimationDuration/2 animations:^{
                self.contentInset = UIEdgeInsetsMake(PRLoadControlHeight+_orignContentInsetTop, 0, 0, 0);
            }];
        }
    }
    else
    {
        if (offset.y < -PRRefreshControlHeight) {   //header totally appeard
            _refreshView.state = PRStateReleaseToRefresh;
        } else if (offset.y > -PRRefreshControlHeight && offset.y < 0){ //header part appeared
            _refreshView.state = PRStatePullToRefresh;
        }
        float yMargin = self.contentOffset.y + size.height - contentSize.height;
        if ( yMargin > 0 && (_prType == PRTypeBottomLoad || _prType == PRTypeTopRefreshBottomLoad) && !_reachedEnd ){  //footer will appeared
            
            _loadView.state = PRStateLoading;
            if (_loadHandler) {
                _loadHandler();
            }
            else if (_loadTarget && [_loadTarget respondsToSelector:_loadAction])
            {
                ((void (*)(id, SEL))[_loadTarget methodForSelector:_loadAction])(_loadTarget, _loadAction);
            }
            
            [UIView animateWithDuration:PRAnimationDuration/2 animations:^{
                self.contentInset = UIEdgeInsetsMake(_orignContentInsetTop, 0, PRLoadControlHeight, 0);
            }];
        }
    }
    
}

- (void)tableViewDidEndDragging{
    
    if (_refreshView.state != PRStateReleaseToRefresh || _loadView.state == PRStateLoading) {
        return;
    }
    _isRefreshing = YES;
    _reachedEnd = NO;
    _refreshView.state = PRStateRefreshing;
    if (_refreshHandler) {
        _refreshHandler();
    }
    else if (_refreshTarget && [_refreshTarget respondsToSelector:_refreshAction])
    {
        ((void (*)(id, SEL))[_refreshTarget methodForSelector:_refreshAction])(_refreshTarget, _refreshAction);
    }
    
    [UIView animateWithDuration:PRAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contentInset = UIEdgeInsetsMake(PRRefreshControlHeight+_orignContentInsetTop, 0, 0, 0);
    } completion:nil];
}

- (void)finishLoading
{
    [self finishLoadingWithOffset:0];
}

- (void)finishLoadingWithOffset:(CGFloat)offset
{
    _isRefreshing = NO;
    
    if (_loadView.state == PRStateLoading) {
        _loadView.state = PRStateNormal;
    }
    else if (_refreshView.state == PRStateRefreshing) {
        _refreshView.state = PRStatePullToRefresh;
        [_refreshView updateRefreshDate:[NSDate date]];
        [UIView animateWithDuration:PRAnimationDuration delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.contentInset = UIEdgeInsetsMake(_orignContentInsetTop, 0, 0, 0);
        } completion:nil];
    }
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if (object != self) {
        return;
    }
    if ([keyPath isEqualToString:KeyPathContentSize]) {
        CGRect frame = _loadView.frame;
        if (_prType == PRTypeTopRefreshBottomLoad || _prType == PRTypeBottomLoad) {
            CGSize contentSize = self.contentSize;
            frame.origin.y = contentSize.height < self.frame.size.height ? self.frame.size.height : contentSize.height;
        }
        _loadView.frame = frame;
        
        if (_prType == PRTypeTopLoad) {
            CGFloat preContentHeight = [[change objectForKey:@"old"] CGSizeValue].height;
            CGFloat curContentHeight = [[change objectForKey:@"new"] CGSizeValue].height;
            if (curContentHeight-preContentHeight>0) {
                CGPoint offset = self.contentOffset;
                if (preContentHeight == 0 && _scrollToBottomIfTopLoad) {
                    offset.y = curContentHeight>self.frame.size.height?(curContentHeight-self.frame.size.height):0;
                }
                if (preContentHeight > 0)
                {
                    offset.y += curContentHeight-preContentHeight;
                }
                self.contentOffset = offset;
            }
        }
    }
    else if ([keyPath isEqualToString:KeyPathContentOffset])
    {
        if (_orignContentOffsetY <-1000) { // table初始化的时候contentOffset也会有变化，_orignContentOffsetY初始化为很小的负数
            return;
        }
        [self tableViewDidScroll];
        if (!self.isDragging) {
            [self tableViewDidEndDragging];
        }
    }
}

@end
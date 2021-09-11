//
//  LyRefreshControl.m
//  react-native-ly-refresh-control
//
//  Created by 邓博 on 2021/9/11.
//

#import "LyRefreshControl.h"

#import "RCTUtils.h"
#import <React/RCTRefreshableProtocol.h>

@interface LyRefreshControl () <RCTRefreshableProtocol>
@end

@implementation LyRefreshControl {
    BOOL _isInitialRender;
    BOOL _currentRefreshingState;
    UInt64 _currentRefreshingStateClock;
    UInt64 _currentRefreshingStateTimestamp;
    BOOL _refreshingProgrammatically;
    NSString *_title;
    UIColor *_titleColor;
}

- (instancetype)init
{
  if ((self = [super init])) {
      [self setRefreshingTarget:self refreshingAction:@selector(refreshControlValueChanged)];
    _currentRefreshingStateClock = 1;
    _currentRefreshingStateTimestamp = 0;
    _isInitialRender = true;
    _currentRefreshingState = false;
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
    CGFloat width = self.scrollView.frame.size.width ?: [UIScreen mainScreen].bounds.size.width;
    CGFloat height = 88;
    CGFloat y = -height;
    [super setFrame:CGRectMake(frame.origin.x, y, width, height)];
}

RCT_NOT_IMPLEMENTED(-(instancetype)initWithCoder : (NSCoder *)aDecoder)

- (void)layoutSubviews
{
  [super layoutSubviews];

  // Fix for bug #7976
  // TODO: Remove when updating to use iOS 10 refreshControl UIScrollView prop.
  if (self.backgroundColor == nil) {
    self.backgroundColor = [UIColor clearColor];
  }

  // If the control is refreshing when mounted we need to call
  // beginRefreshing in layoutSubview or it doesn't work.
  if (_currentRefreshingState && _isInitialRender) {
    [self beginRefreshingProgrammatically];
  }
  _isInitialRender = false;
}

- (void)beginRefreshingProgrammatically
{
  UInt64 beginRefreshingTimestamp = _currentRefreshingStateTimestamp;
  _refreshingProgrammatically = YES;
  // When using begin refreshing we need to adjust the ScrollView content offset manually.
  UIScrollView *scrollView = (UIScrollView *)self.superview;
  // Fix for bug #24855
  [self sizeToFit];
  CGPoint offset = {scrollView.contentOffset.x, scrollView.contentOffset.y - self.frame.size.height};

  // `beginRefreshing` must be called after the animation is done. This is why it is impossible
  // to use `setContentOffset` with `animated:YES`.
  [UIView animateWithDuration:0.25
      delay:0
      options:UIViewAnimationOptionBeginFromCurrentState
      animations:^(void) {
        [scrollView setContentOffset:offset];
      }
      completion:^(__unused BOOL finished) {
        if (beginRefreshingTimestamp == self->_currentRefreshingStateTimestamp) {
          [super beginRefreshing];
          [self setCurrentRefreshingState:super.refreshing];
        }
      }];
}

- (void)endRefreshingProgrammatically
{
  // The contentOffset of the scrollview MUST be greater than the contentInset before calling
  // endRefreshing otherwise the next pull to refresh will not work properly.
  UIScrollView *scrollView = (UIScrollView *)self.superview;
  if (_refreshingProgrammatically && scrollView.contentOffset.y < -scrollView.contentInset.top) {
    UInt64 endRefreshingTimestamp = _currentRefreshingStateTimestamp;
    CGPoint offset = {scrollView.contentOffset.x, -scrollView.contentInset.top};
    [UIView animateWithDuration:0.25
        delay:0
        options:UIViewAnimationOptionBeginFromCurrentState
        animations:^(void) {
          [scrollView setContentOffset:offset];
        }
        completion:^(__unused BOOL finished) {
          if (endRefreshingTimestamp == self->_currentRefreshingStateTimestamp) {
            [super endRefreshing];
            [self setCurrentRefreshingState:super.refreshing];
          }
        }];
  } else {
    [super endRefreshing];
  }
}

- (NSString *)title
{
  return _title;
}

- (void)setTitle:(NSString *)title
{
  _title = title;
  [self _updateTitle];
}

- (void)setIdleImageSources:(NSArray<RCTImageSource *> *)idleImageSources
{
    _idleImageSources = idleImageSources;
    [self prepare];
}

- (void)setRefreshingImageSources:(NSArray<RCTImageSource *> *)refreshingImageSources
{
    _refreshingImageSources = refreshingImageSources;
    [self prepare];
}

- (void)setTitleColor:(UIColor *)color
{
  _titleColor = color;
  [self _updateTitle];
}

- (void)_updateTitle
{
  if (!_title) {
    return;
  }

//  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
//  if (_titleColor) {
//    attributes[NSForegroundColorAttributeName] = _titleColor;
//  }

//  self.attributedTitle = [[NSAttributedString alloc] initWithString:_title attributes:attributes];
}

- (void)setRefreshing:(BOOL)refreshing
{
  if (_currentRefreshingState != refreshing) {
    [self setCurrentRefreshingState:refreshing];

    if (refreshing) {
      if (!_isInitialRender) {
        [self beginRefreshingProgrammatically];
      }
    } else {
      [self endRefreshingProgrammatically];
    }
  }
}

- (void)setCurrentRefreshingState:(BOOL)refreshing
{
  _currentRefreshingState = refreshing;
  _currentRefreshingStateTimestamp = _currentRefreshingStateClock++;
}

- (void)refreshControlValueChanged
{
  [self setCurrentRefreshingState:super.refreshing];
  _refreshingProgrammatically = NO;

  if (_onRefresh) {
    _onRefresh(nil);
  }
}

- (void)prepare
{
    [super prepare];

    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 0; i < [_idleImageSources count]; i++) {
        RCTImageSource *source = _idleImageSources[i];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:source.request.URL]];
        [idleImages addObject:image];
    }

     [self setImages:idleImages forState:MJRefreshStateIdle];

    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    for (NSUInteger i = 0; i < [_refreshingImageSources count]; i++) {
        RCTImageSource *source = _refreshingImageSources[i];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:source.request.URL]];
        [refreshingImages addObject:image];
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];

    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}

@end

#import <React/RCTViewManager.h>
#import <React/RCTUIManager.h>
#import <React/RCTImageSource.h>

#import "LyRefreshControl.h"
#import "RCTRefreshableProtocol.h"

@interface LyRefreshControlViewManager : RCTViewManager
@end

@implementation LyRefreshControlViewManager

RCT_EXPORT_MODULE(LyRefreshControlView)

- (UIView *)view
{
  return [LyRefreshControl new];
}

RCT_EXPORT_VIEW_PROPERTY(onRefresh, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(refreshing, BOOL)
RCT_EXPORT_VIEW_PROPERTY(tintColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(title, NSString)
RCT_EXPORT_VIEW_PROPERTY(titleColor, UIColor)
RCT_REMAP_VIEW_PROPERTY(idleSources, idleImageSources, NSArray<RCTImageSource *>);
RCT_REMAP_VIEW_PROPERTY(refreshingSources, refreshingImageSources, NSArray<RCTImageSource *>);

RCT_EXPORT_METHOD(setNativeRefreshing : (nonnull NSNumber *)viewTag toRefreshing : (BOOL)refreshing)
{
  [self.bridge.uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    UIView *view = viewRegistry[viewTag];

    if ([view conformsToProtocol:@protocol(RCTRefreshableProtocol)]) {
      [(id<RCTRefreshableProtocol>)view setRefreshing:refreshing];
    } else {
      RCTLogError(@"view must conform to protocol RCTRefreshableProtocol");
    }
  }];
}

@end

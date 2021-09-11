//
//  LyRefreshControl.h
//  react-native-ly-refresh-control
//
//  Created by 邓博 on 2021/9/11.
//

#import <UIKit/UIKit.h>

#import <React/RCTComponent.h>
#import <React/RCTScrollableProtocol.h>
#import <React/RCTImageSource.h>
#import <MJRefresh/MJRefresh.h>

NS_ASSUME_NONNULL_BEGIN

@interface LyRefreshControl : MJRefreshGifHeader <RCTCustomRefreshContolProtocol>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) RCTDirectEventBlock onRefresh;
@property (nonatomic, copy) NSArray<RCTImageSource *> *idleImageSources;
@property (nonatomic, copy) NSArray<RCTImageSource *> *refreshingImageSources;

@end

NS_ASSUME_NONNULL_END

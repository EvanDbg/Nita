#import <UIKit/UIKit.h>
#import <Cephei/HBPreferences.h>
#import <substrate.h>
#import "WeatherHeaders.h"

HBPreferences* preferences;

BOOL dpkgInvalid = NO;

extern BOOL enabled;

WATodayAutoupdatingLocationModel *todayUpdateModel;

// Visibility(Carrier)
BOOL showEmojiSwitch = YES;
BOOL showTemperatureSwitch = NO;

// Visibility(Time)
BOOL showEmojiAfterTimeSwitch = YES;

// Miscellaneous
BOOL hideBreadcrumbsSwitch = YES;
BOOL hideLocationServiceIconSwitch = YES;

// Data Refreshing
BOOL refreshWeatherDataControlCenterSwitch = YES;
BOOL refreshWeatherDataNotificationCenterSwitch = NO;
BOOL refreshWeatherDataDisplayWakeSwitch = YES;

@interface _UIStatusBarStringView : UILabel
@property(nonatomic, copy)NSString* originalText;
@end

@interface SBIconController : UIViewController
@end

@interface UIStatusBarItem : NSObject
+(id)itemWithType:(int)arg1 idiom:(long long)arg2;
@end
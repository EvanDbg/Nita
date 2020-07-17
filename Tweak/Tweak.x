#import "Nita.h"

BOOL enabled;

NSString* conditions = nil; // weather condition which will be converted to an emoji
NSString* weatherString = nil; // emoji will be assigned to this variable
NSString* temperature = nil;

static NSString* nameForCondition(int condition) {
	MSImageRef weather = MSGetImageByName("/System/Library/PrivateFrameworks/Weather.framework/Weather");
    CFStringRef *_weatherDescription = (CFStringRef*)MSFindSymbol(weather, "_WeatherDescription") + condition;
    NSString *cond = (__bridge id)*_weatherDescription;
    return [[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/Weather.framework"] 
				localizedStringForKey:cond value:@"" table:@"WeatherFrameworkLocalizableStrings"];
}

static NSDictionary* weatherConditionsDict() {
    NSDictionary *conditions = [[NSDictionary alloc] initWithObjectsAndKeys: 
		@"🌩️", /*@"SevereThunderstorm",*/ @3, 
		@"🌧", /*@"Rain",*/ @12, 
		@"🌩️", /*@"Thunderstorm",*/ @4, 
		@"🌫️", /*@@"Haze",*/ @21, 
		@"⛅", /*@"PartlyCloudyDay",*/ @30, 
		@"🌨️", /*@"MixedRainAndSnow",*/ @5, 
		@"🌨️", /*@"SnowFlurries",*/ @13, 
		@"🌫️", /*@"Smoky",*/ @22, 
		@"🌨️", /*@"MixedRainAndSleet",*/ @6, 
		@"🌃", /*@"ClearNight",*/ @31, 
		@"🌨️", /*@"SnowShowers",*/ @14, 
		@"🌨️", /*@"MixedSnowAndSleet",*/ @7, 
		@"🍃", /*@"Breezy",*/ @23, 
		@"🌨️", /*@"ScatteredSnowShowers",*/ @40, 
		@"☂️", /*@"FreezingDrizzle",*/ @8, 
		@"❄️", /*@"BlowingSnow",*/ @15, 
		@"☀️", /*@"Sunny",*/ @32, 
		@"☂️", /*@"Drizzle",*/ @9, 
		@"🌬️", /*@"Windy",*/ @24, 
		@"✨", /*@"MostlySunnyNight",*/ @33, 
		@"❄️", /*@"Snow",*/ @16, 
		@"🌨️", /*@"HeavySnow",*/ @41, 
		@"🥶", /*@"Frigid",*/ @25, 
		@"🌨️", /*@"ScatteredSnowShowers",*/ @42, 
		@"🌤", /*@"MostlySunnyDay",*/ @34, 
		@"🧊", /*@"Hail",*/ @17, 
		@"☃️", /*@"Blizzard",*/ @43, 
		@"☁️", /*@"Cloudy",*/ @26, 
		@"☔", /*@"MixedRainFall",*/ @35, 
		@"🌨️", /*@"Sleet",*/ @18, 
		@"⛅", /*@"PartlyCloudyDay",*/ @44, 
		@"☁️", /*@"MostlyCloudyNight",*/ @27, 
		@"🔥", /*@"Hot",*/ @36, 
		@"😷", /*@"Dust",*/ @19, 
		@"☔", /*@"HeavyRain",*/ @45, 
		@"⛅", /*@"MostlyCloudyDay",*/ @28, 
		@"⛈️", /*@"IsolatedThunderstorms",*/ @37, 
		@"🌨️", /*@"SnowShowers",*/ @46, 
		@"☁️", /*@"PartlyCloudyNight",*/ @29, 
		@"🌧️", /*@"ScatteredShowers",*/ @38, 
		@"⛈️", /*@"IsolatedThundershowers",*/ @47, 
		@"⛈️", /*@"ScatteredThunderstorms",*/ @39, 
		@"🌪️", /*@"Tornado",*/ @0, 
		@"🌧️", /*@"FreezingRain",*/ @10, 
		@"🌪️", /*@"TropicalStorm",*/ @1, 
		@"🌧️", /*@"Showers1",*/ @11, 
		@"🌀", /*@"Hurricane",*/ @2, 
		@"🌫️", /*@"Fog",*/ @20, nil];
    return conditions;
}

static void updateCondition() {
	WeatherPreferences *wPrefs = [%c(WeatherPreferences) sharedPreferences];
	todayUpdateModel = [%c(WATodayAutoupdatingLocationModel) autoupdatingLocationModelWithPreferences:wPrefs effectiveBundleIdentifier:@"com.apple.weather"];
	[todayUpdateModel setLocationServicesActive:YES];
	[todayUpdateModel setIsLocationTrackingEnabled:YES];

	[todayUpdateModel executeModelUpdateWithCompletion:^(BOOL arg1, NSError *arg2) {
		if (todayUpdateModel.forecastModel.city) {
			[todayUpdateModel setIsLocationTrackingEnabled:NO];
			if (todayUpdateModel != nil && todayUpdateModel.forecastModel.currentConditions != nil) {
				NSNumber* conditionCode = [NSNumber numberWithUnsignedLongLong:(todayUpdateModel.forecastModel.currentConditions.conditionCode)];
				NSDictionary* dict = weatherConditionsDict();
				weatherString = [dict objectForKey:conditionCode] ? [[dict objectForKey:conditionCode] stringValue] : @"";
				conditions = nameForCondition([conditionCode intValue]);
				temperature = [NSString stringWithFormat:@"%d℃", (int)todayUpdateModel.forecastModel.city.temperature.celsius];
			}
		}
	}];
}

%group Nita

%hook _UIStatusBarStringView

- (void)setText:(id)arg1 {

	%orig; // making sure originalText is being initialized before comparing it

	if (!([[self originalText] containsString:@":"] || [[self originalText] containsString:@"%"] || [[self originalText] containsString:@"3G"] || [[self originalText] containsString:@"4G"] || [[self originalText] containsString:@"5G"] || [[self originalText] containsString:@"LTE"])) {

		// assign the emoji (and optionally the temperature or only text) to the carrier
		if (showEmojiSwitch && !showTemperatureSwitch)
			%orig(weatherString);
		else if (showEmojiSwitch && showTemperatureSwitch)
			%orig([NSString stringWithFormat:@"%@ %@", weatherString, temperature]); // that's why i use a variable for the condition, so i can easily add the temperature
		else if (!showEmojiSwitch && showTemperatureSwitch)
			%orig([NSString stringWithFormat:@"%@", temperature]);
		else
			%orig(conditions);
	} else {
		%orig;
	}

}
%end

// Hide Breadcrumbs

%hook SBDeviceApplicationSceneStatusBarBreadcrumbProvider // iOS 13

+ (BOOL)_shouldAddBreadcrumbToActivatingSceneEntity:(id)arg1 sceneHandle:(id)arg2 withTransitionContext:(id)arg3 {

	if (hideBreadcrumbsSwitch)
		return NO;
	else
		return %orig;

}

%end

%hook SBMainDisplaySceneManager // iOS 12

- (BOOL)_shouldBreadcrumbApplicationSceneEntity:(id)arg1 withTransitionContext:(id)arg2 {

	if (hideBreadcrumbsSwitch)
		return NO;
	else
		return %orig;

}

%end

// Update Weather Data

%hook SBControlCenterController // when opening control center

- (void)_willPresent {

	%orig;

	if (refreshWeatherDataControlCenterSwitch)
		updateCondition();

}

%end

%hook SBCoverSheetPrimarySlidingViewController // when sliding down notitication center

- (void)viewWillAppear:(BOOL)animated {

	%orig;

	if (refreshWeatherDataNotificationCenterSwitch)
		updateCondition();

}

%end

%hook SBBacklightController // when turning on screen

- (void)turnOnScreenFullyWithBacklightSource:(long long)source {

	%orig;

	if (source != 26 && refreshWeatherDataDisplayWakeSwitch)
		updateCondition();

}

%end

%end

%group NitaIntegrityFail

%hook SBIconController

- (void)viewDidAppear:(BOOL)animated {

    %orig;
	
    if (!dpkgInvalid) return;
		UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Nita"
		message:@"Seriously? Pirating a free Tweak is awful!\nPiracy repo's Tweaks could contain Malware if you didn't know that, so go ahead and get Nita from the official Source https://repo.litten.love/.\nIf you're seeing this but you got it from the official source then make sure to add https://repo.litten.love to Cydia or Sileo."
		preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Okey" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {

			UIApplication* application = [UIApplication sharedApplication];
			[application openURL:[NSURL URLWithString:@"https://repo.litten.love/"] options:@{} completionHandler:nil];

	}];

		[alertController addAction:cancelAction];

		[self presentViewController:alertController animated:YES completion:nil];

}

%end

%end

%ctor {

	dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/love.litten.nita.list"];

    if (!dpkgInvalid) dpkgInvalid = ![[NSFileManager defaultManager] fileExistsAtPath:@"/var/lib/dpkg/info/love.litten.nita.md5sums"];

    if (dpkgInvalid) {
        %init(NitaIntegrityFail);
        return;
    }

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.nitapreferences"];

    [preferences registerBool:&enabled default:nil forKey:@"Enabled"];

	// Visibility
	[preferences registerBool:&showEmojiSwitch default:YES forKey:@"showEmoji"];
	[preferences registerBool:&showTemperatureSwitch default:NO forKey:@"showTemperature"];

	// Miscellaneous
	[preferences registerBool:&hideBreadcrumbsSwitch default:YES forKey:@"hideBreadcrumbs"];

	// Data Refreshing
	[preferences registerBool:&refreshWeatherDataControlCenterSwitch default:YES forKey:@"refreshWeatherDataControlCenter"];
	[preferences registerBool:&refreshWeatherDataNotificationCenterSwitch default:NO forKey:@"refreshWeatherDataNotificationCenter"];
	[preferences registerBool:&refreshWeatherDataDisplayWakeSwitch default:YES forKey:@"refreshWeatherDataDisplayWake"];

	if (!dpkgInvalid && enabled) {
        BOOL ok = false;
        
        ok = ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"/var/lib/dpkg/info/%@%@%@%@%@%@%@%@%@%@%@.nita.md5sums", @"l", @"o", @"v", @"e", @".", @"l", @"i", @"t", @"t", @"e", @"n"]]
        );

        if (ok && [@"litten" isEqualToString:@"litten"]) {
			%init(Nita);
            return;
        } else {
            dpkgInvalid = YES;
        }
    }

}
#import "NTAContributorsSubPrefsListController.h"

@implementation NTAContributorsSubPrefsListController

- (instancetype)init {

    self = [super init];

    if (self) {
        NTAAppearanceSettings* appearanceSettings = [[NTAAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;

}

- (id)specifiers {

    return _specifiers;

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    [self.navigationController.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

}

- (void)loadFromSpecifier:(PSSpecifier *)specifier {

    NSString *sub = [specifier propertyForKey:@"NTASub"];
    NSString *title = [specifier name];

    _specifiers = [[self loadSpecifiersFromPlistName:sub target:self] retain];

    [self setTitle:title];
    [self.navigationItem setTitle:title];

}

- (void)setSpecifier:(PSSpecifier *)specifier {

    [self loadFromSpecifier:specifier];
    [super setSpecifier:specifier];

}

- (bool)shouldReloadSpecifiersOnResume {

    return false;

}

@end
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface CyDeleteSettingsController : PSListController {
	bool _cydiaPresent;
	bool _icyPresent;
}
- (id)navigationTitle;
- (id)specifiers;
@end

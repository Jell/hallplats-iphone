/**
 Application delegate.
 */

//
//  AugmentedMPNAppDelegate.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

@class MainViewController;

@interface AugmentedMPNAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;							/**< Main Window*/
    MainViewController *mainViewController;		/**< Main Controller*/
	UIImagePickerController *camera;			/**< Camera display*/
}

@property (retain) IBOutlet UIWindow *window;
@property (retain) MainViewController *mainViewController;
@property (retain) UIImagePickerController *camera;

@end


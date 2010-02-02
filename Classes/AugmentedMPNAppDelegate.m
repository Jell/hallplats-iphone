//
//  AugmentedMPNAppDelegate.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AugmentedMPNAppDelegate.h"
#import "MainViewController.h"

@implementation AugmentedMPNAppDelegate


@synthesize window;
@synthesize mainViewController;
@synthesize camera;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
    mainViewController.view.frame = [UIScreen mainScreen].applicationFrame;
	//[window addSubview:[mainViewController view]];

	
	camera = [[[UIImagePickerController alloc] init] autorelease];
	camera.sourceType = UIImagePickerControllerSourceTypeCamera;
	camera.showsCameraControls = NO;
	camera.cameraOverlayView = [mainViewController view];
	camera.navigationBarHidden = YES;
	camera.toolbarHidden = YES;
	camera.wantsFullScreenLayout = YES;
	
	/* scale camera view to full screen */
	camera.cameraViewTransform=CGAffineTransformScale(camera.cameraViewTransform, 1.0, 1.13); 
	
	[window addSubview:[camera view]];
	
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end

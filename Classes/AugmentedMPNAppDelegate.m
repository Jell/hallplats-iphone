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
	
	camera = [[[UIImagePickerController alloc] init] autorelease];
	camera.sourceType = UIImagePickerControllerSourceTypeCamera;
	camera.view.frame = [UIScreen mainScreen].applicationFrame;
	camera.cameraOverlayView = [mainViewController view];
	camera.showsCameraControls = NO;
	camera.navigationBarHidden = YES;
	camera.toolbarHidden = YES;
	camera.wantsFullScreenLayout = YES;
	
	/* scale camera view to full screen */
	//camera.cameraViewTransform=CGAffineTransformScale(camera.cameraViewTransform, 1.09, 1.09); 
	
	[window addSubview:[camera view]];
	[window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
	[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:NO];
}

- (void)timerUpdate:(id)sender{
	[mainViewController becomeFirstResponder];
}

- (void)dealloc {
    [mainViewController release];
    [window release];
    [super dealloc];
}

@end

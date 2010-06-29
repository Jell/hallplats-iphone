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
	[window makeKeyAndVisible];
	
    
	MainViewController *aController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
	self.mainViewController = aController;
	[aController release];
	
	camera = [[[UIImagePickerController alloc] init] autorelease];
	camera.sourceType = UIImagePickerControllerSourceTypeCamera;
	
	
	camera.view.frame = CGRectMake(0, 0, 320, 480);
	//camera.cameraOverlayView = [mainViewController view];
	camera.showsCameraControls = NO;
	camera.toolbar.hidden = YES;
	camera.navigationBar.hidden = YES;
	
	/* scale camera view to full screen */
	camera.cameraViewTransform=CGAffineTransformScale(camera.cameraViewTransform, 1.25, 1.25); 
	
	splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
	
	[window addSubview:[camera view]];
	[window addSubview:[mainViewController view]];
	[window addSubview:splashView];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
	
	[self performSelector:@selector(fadeSplash) withObject:nil afterDelay:1.5];
	
}

-(void)fadeSplash
{
	[UIView beginAnimations:@"removesplash" context:nil];
	[UIView setAnimationDuration:0.5];
    [splashView setAlpha:0];
    [UIView commitAnimations];
	
	[self performSelector:@selector(removeSplash) withObject:nil afterDelay:1.5];
}

-(void)removeSplash
{
	[splashView removeFromSuperview];
	[splashView release];
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

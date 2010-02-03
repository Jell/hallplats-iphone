//
//  MainViewController.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@implementation MainViewController
@synthesize accelerometer;
@synthesize viewDisplayedController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	accelerometer = [UIAccelerometer sharedAccelerometer];
	[accelerometer setUpdateInterval:1.0f / 60.0f];
	[accelerometer setDelegate:self];
	
	viewDisplayedController = [[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil];
	[viewDisplayed addSubview:viewDisplayedController.view];
	augmentedIsOn = TRUE;
	
}



 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
	 return FALSE;
 }


- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}


- (IBAction)showInfo {    
	
	FlipsideViewController *controller = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
	controller.delegate = self;

	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}
 

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	
	if(augmentedIsOn){
		if(acceleration.z < -0.9 && (acceleration.y > -0.2 &&
									 acceleration.y <  0.2 &&
									 acceleration.x > -0.2 &&
									 acceleration.x <  0.2)){
			[[viewDisplayed.subviews objectAtIndex:0] removeFromSuperview];
			[viewDisplayedController release];
			viewDisplayedController = [[MapViewController alloc] initWithNibName:@"MapView" bundle:nil];
			/*if(self.interfaceOrientation == UIInterfaceOrientationPortrait ||
				self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
				[viewDisplayedController.view setFrame:CGRectMake(0, 0, 480, 460)];
			}else{
				[viewDisplayedController.view setFrame:CGRectMake(0, -70, 480, 460)];
			}*/
			[viewDisplayed addSubview:viewDisplayedController.view];
			CATransition *applicationLoadViewIn = [CATransition animation];
			[applicationLoadViewIn setDuration:0.5];
			[applicationLoadViewIn setType:kCATransitionPush];
			[applicationLoadViewIn setSubtype:kCATransitionFromTop];
			[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
			[[viewDisplayed layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
			augmentedIsOn = FALSE;
		}
	}else{
		if(acceleration.z > -0.7 &&
		   acceleration.z <  0.0 && (acceleration.y < -0.8 ||
									 acceleration.y >  0.8 ||
									 acceleration.x < -0.8 ||
									 acceleration.x >  0.8) ){
			[[viewDisplayed.subviews objectAtIndex:0] removeFromSuperview];
			[viewDisplayedController release];
			viewDisplayedController = [[AugmentedViewController alloc] initWithNibName:@"AugmentedView" bundle:nil];
			/*
			if(self.interfaceOrientation == UIInterfaceOrientationPortrait ||
			   self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
			}else{
				[viewDisplayedController.view setFrame:CGRectMake(0, -70, 480, 460)];
			}*/
			[viewDisplayed addSubview:viewDisplayedController.view];
			CATransition *applicationLoadViewIn = [CATransition animation];
			[applicationLoadViewIn setDuration:0.5];
			[applicationLoadViewIn setType:kCATransitionPush];
			[applicationLoadViewIn setSubtype:kCATransitionFromBottom];
			[applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
			[[viewDisplayed layer] addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];			
			augmentedIsOn = TRUE;
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[accelerometer release];
	[viewDisplayedController release];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[accelerometer release];
	[viewDisplayedController release];
    [super dealloc];
}


@end

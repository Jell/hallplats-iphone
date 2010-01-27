//
//  MainViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-26.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MapViewController.h"
#import "AugmentedViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIAccelerometerDelegate> {
	IBOutlet UIView *viewDisplayed;
	UIViewController *viewDisplayedController;
	UIAccelerometer *accelerometer;
	bool augmentedIsOn;
}

@property (nonatomic, retain) UIAccelerometer *accelerometer;
@property (nonatomic, retain) UIViewController *viewDisplayedController;

- (IBAction)showInfo;

@end

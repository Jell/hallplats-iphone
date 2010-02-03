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
#import "ARViewProtocol.h"
#import <QuartzCore/QuartzCore.h>

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIAccelerometerDelegate, CLLocationManagerDelegate> {
	IBOutlet UIView *viewDisplayed;
	CLLocation *currentLocation;
	UIViewController<ARViewDelegate> *viewDisplayedController;
	CLLocationManager *mLocationManager;
	UIAccelerometer *mAccelerometer;
	bool augmentedIsOn;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *mLocationManager;
@property (nonatomic, retain) UIAccelerometer *mAccelerometer;
@property (nonatomic, retain) UIViewController *viewDisplayedController;

- (IBAction)showInfo;
- (void)loadMapView;
- (void)loadAugmentedView;

@end

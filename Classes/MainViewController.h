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
	UIViewController<ARViewDelegate> *viewDisplayedController;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UIButton *updateButton;
	
	CLLocationManager *mLocationManager;
	UIAccelerometer *mAccelerometer;
	MPNApiHandler *mpnApiHandler;
	UIInterfaceOrientation mInterfaceOrientation;
	bool augmentedIsOn;
	NSOperationQueue *opQueue;
	CLLocation *currentLocation;
	NSArray *annotationList;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) CLLocationManager *mLocationManager;
@property (nonatomic, retain) NSArray *annotationList;
@property (nonatomic, retain) MPNApiHandler *mpnApiHandler;
@property (nonatomic, retain) UIAccelerometer *mAccelerometer;
@property (nonatomic, retain) UIViewController *viewDisplayedController;

- (IBAction)showInfo;
- (void)loadMapView;
- (void)loadAugmentedView;
- (void)loadViewController:(UIViewController<ARViewDelegate> *)viewController withTransition:(CATransition *)transition;
- (IBAction)updateInfo;
- (void) performUpdate:(id)object;
- (void) updatePerformed:(id)response;

@end

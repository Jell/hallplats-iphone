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
#import "VTApiHandler.h"

#define ACCELERATION_BUFFER_SIZE 5

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIAccelerometerDelegate, CLLocationManagerDelegate> {
	IBOutlet UIView *viewDisplayed;
	UIViewController<ARViewDelegate> *viewDisplayedController;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UIButton *updateButton;
	
	CLLocationManager *mLocationManager;
	UIAccelerometer *mAccelerometer;
	VTApiHandler *mVTApiHandler;
	
	UIInterfaceOrientation mInterfaceOrientation;
	bool augmentedIsOn;
	bool firstLocationUpdate;
	NSOperationQueue *opQueue;
	CLLocation *currentLocation;
	NSArray *annotationList;
	float xxArray[ACCELERATION_BUFFER_SIZE];
	float yyArray[ACCELERATION_BUFFER_SIZE];
	float zzArray[ACCELERATION_BUFFER_SIZE];
	float xxAverage;
	float yyAverage;
	float zzAverage;
	int accelerationBufferIndex;
}

@property (retain) CLLocation *currentLocation;
@property (retain) CLLocationManager *mLocationManager;
@property (retain) NSArray *annotationList;
@property (retain) VTApiHandler *mVTApiHandler;
@property (retain) UIAccelerometer *mAccelerometer;
@property (retain) UIViewController *viewDisplayedController;

- (IBAction)showInfo;
- (void)loadMapView;
- (void)loadAugmentedView;
- (void)loadViewController:(UIViewController<ARViewDelegate> *)viewController withTransition:(CATransition *)transition;
- (IBAction)updateInfo;
- (void) performUpdate:(id)object;
- (void) updatePerformed:(id)response;

@end

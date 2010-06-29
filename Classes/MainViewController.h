/**
 Used to switch between Map View and Augmented View and to dispatch events.
 */

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

#define ACCELERATION_BUFFER_SIZE 10

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIAccelerometerDelegate, CLLocationManagerDelegate> {
	IBOutlet UIView *viewDisplayed;									/**< The view container in which the Map View or Augmented View are displayed*/
	IBOutlet UIView *loadingDisplay;
	UIViewController<ARViewDelegate> *viewDisplayedController;		/**< Pointer to current display type (Map or Augmented)*/
	
	MapViewController *mMapViewController;							/**< Map View Controller*/
	AugmentedViewController *mAugmentedViewController;				/**< Augmented View Controller*/
	
	CLLocationManager *mLocationManager;							/**< Responsible for dispatching location updates*/
	UIAccelerometer *mAccelerometer;								/**< Responsible for dispatching acceleration updates*/
	VTApiHandler *mVTApiHandler;									/**< Used to interact with the Västtrafik API*/
	
	UIInterfaceOrientation mInterfaceOrientation;					/**< Current orientation of the device*/										
	bool firstLocationUpdate;
	bool secondLocationUpdate;
	NSOperationQueue *opQueue;										/**< Operation Queue used for multithreading*/
	CLLocation *currentLocation;									/**< Current User location*/
	NSArray *annotationList;										/**< List of VTAnnotation*/
	
	float xxArray[ACCELERATION_BUFFER_SIZE];						/**< Acceleration Buffer along x axis*/
	float yyArray[ACCELERATION_BUFFER_SIZE];						/**< Acceleration Buffer along y axis*/
	float zzArray[ACCELERATION_BUFFER_SIZE];						/**< Acceleration Buffer along z axis*/
	float xxAverage;												/**< Acceleration Average along x axis*/
	float yyAverage;												/**< Acceleration Average along y axis*/
	float zzAverage;												/**< Acceleration Average along z axis*/
	int accelerationBufferIndex;
	
	IBOutlet UIButton *lockButton;
	//NSTimer * timer;
}

//@property (nonatomic, retain) NSTimer * timer;
@property (retain) CLLocation *currentLocation;
@property (retain) CLLocationManager *mLocationManager;
@property (retain) NSArray *annotationList;
@property (retain) VTApiHandler *mVTApiHandler;
@property (retain) UIAccelerometer *mAccelerometer;
@property (assign) UIViewController *viewDisplayedController;
@property (retain) MapViewController *mMapViewController;
@property (retain) AugmentedViewController *mAugmentedViewController;

-(IBAction)lockPress;

/** Load the Map View on screen*/
- (void)loadMapView;

/** Load the Augmented View on screen*/
- (void)loadAugmentedView;

/** Generic function to load a view controller*/
- (void)loadViewController:(UIViewController<ARViewDelegate> *)viewController withTransition:(CATransition *)transition;

/** Updates the Annotation List*/
- (void) performUpdate:(id)object;

/** Launches a thread that updates the Annotation List*/
- (void) beginUdpate:(id)object;

/** Update the system state according to the update that has been performed*/
- (void) updatePerformed:(id)response;

@end

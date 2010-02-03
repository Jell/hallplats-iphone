//
//  MapViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "JSON.h"
#import "AddressAnnotation.h"
#include "Math.h"
#import "ARViewProtocol.h"

@interface MapViewController : UIViewController <ARViewDelegate, MKMapViewDelegate>{
	IBOutlet MKMapView *mMapView;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	CLLocation *currentLocation;
	NSOperationQueue *opQueue;
	NSArray *poiList;
}

@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) NSArray *poiList;

- (IBAction)updateInfo;
- (NSString *)stringWithUrl:(NSURL *)url;
- (id) objectWithUrl:(NSURL *)url;
- (void) performUpdate:(id)object;
- (void) updatePerformed:(NSString *)text;

@end

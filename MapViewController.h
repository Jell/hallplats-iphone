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
#include "Math.h"
#import "ARViewProtocol.h"
#import "MPNApiHandler.h"

@interface MapViewController : UIViewController <ARViewDelegate, MKMapViewDelegate>{
	IBOutlet MKMapView *mMapView;
	IBOutlet UIImageView *arrowView;
	CLLocation *currentLocation;
	NSArray *annotationList;
	float phase;
}

@property (assign) CLLocation *currentLocation;
@property (assign) NSArray *annotationList;

- (void)rotateMapWithTeta:(float)teta;

@end

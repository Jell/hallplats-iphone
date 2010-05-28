/**
 Controller responsible for handling a Map View.
 */

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
#import "VTAnnotation.h"

@interface MapViewController : UIViewController <ARViewDelegate, MKMapViewDelegate>{
	IBOutlet MKMapView *mMapView;			/**< Google Map View */
	IBOutlet UIImageView *arrowView;		/**< Arrow image indicating the user's orientation */
	int selectedPoi;						/**< Currently selected Poi index */
	CLLocation *currentLocation;			/**< Current user's Location */
	NSArray *annotationList;				/**< Annotation List */
	float phase;							/**< Orientation Phase */
	float mTeta;
	bool recentering;						/**< Boolean indicating if the map is beeing centered */
	id delegate;
}

@property float mTeta;
@property (assign) id delegate;
@property (assign) CLLocation *currentLocation;
@property (assign) NSArray *annotationList;

/** Rotate the map view at a given angle */
- (void)rotateMap;

@end

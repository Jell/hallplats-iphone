/**
 Controls the display of an AugmentedView.
 */

//
//  AugmentedViewController.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "ARViewProtocol.h"
#import "AugmentedPoi.h"
#import "AugmentedCalloutBubbleController.h"
#import "VTAnnotation.h"

#define HEADING_BUFFER_SIZE 1
@interface AugmentedViewController : UIViewController <ARViewDelegate>{
	IBOutlet UIView *poiOverlay;					/**< View container for Poi display */
	IBOutlet UIView *gridView;						/**< Perspective Grid View */
	AugmentedCalloutBubbleController *calloutBubble;	/**< Poi call out bubble controller */
	int selectedPoi;								/**< Currently selected POI, -1 if none is selected */
	NSMutableArray *ar_poiList;						/**< List containing the POI */
	NSMutableArray *ar_poiViews;					/**< List containing the POI views */
	CLLocation *currentLocation;					/**< Current location of the user */
	float angleXY;									/**< Angle at which the iPhone is held on the XY plane*/
	float maxDistance;								/**< Distance to the furthest POI */
	float minDistance;								/**< Distance to the closest POI */
}

@property (retain) NSMutableArray *ar_poiList;
@property (retain) NSMutableArray *ar_poiViews;
@property (assign)  CLLocation *currentLocation;

/** Moves the perspective grid according to the given orientation
 @param teta current azimuth of the user from -pi to pi */
-(void)translateGridWithTeta:(float)teta;

/** Position the given view according to its azimuth and distance to current location
 @param aView the view to position
 @param teta azimuth of the POI represented by the view, valued from -pi to pi
 @param distance distance of the POI represented by the view, must be greater than 0
 @param scaleEnabled If set to YES, the view is scaled to perspective*/
-(void)translateView:(UIView *)aView withTeta:(float)teta andDistance:(float)distance withScale:(BOOL)scaleEnabled;

/** Projection from radial coorditates to plane */
-(float)translationFromAngle:(float)teta;

/** Creates a transform matrix corresponding to the given translation and distance
 @param translation
 @param distance must be greater than zero */
-(CATransform3D)make3dTransformWithTranslation:(float)translation andDistance:(float)distance;

/** Performed when a POI is selected */
-(void) poiSelected:(id) poiViewId;

/** Add a POI view to the Poi overlay */
-(void)addPoiView;

@end

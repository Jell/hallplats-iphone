/**
 Container for representing an Annotation in an Augmented View.
 @see VTAnnotation
 @see AugmentedViewController
 */

//
//  AugmentedPOI.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "VTAnnotation.h"

@interface AugmentedPoi : NSObject {
	float azimuth;
	VTAnnotation *annotation;
}

@property float azimuth;						/**<Azimuth of the POI from origin */
@property (readonly) float distance;			/**<Distance of the POI from origin */
@property(assign) VTAnnotation *annotation;		/**<Reference to the annotation */

/** Initialize an Augmented Poi with an Annotation and an origin */
-(id)initWithAnnotation:(VTAnnotation *) anAnnotation fromOrigin:(CLLocationCoordinate2D)origin;

/** Updates Azimuth */
-(void)updateAngleFrom:(CLLocationCoordinate2D)origin;

@end

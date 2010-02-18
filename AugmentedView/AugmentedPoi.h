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
	float teta;
	float distance;
	VTAnnotation *annotation;
}

@property float teta;
@property float distance;
@property(assign) VTAnnotation *annotation;

-(id)initWithAnnotation:(VTAnnotation *) anAnnotation fromOrigin:(CLLocationCoordinate2D)origin;
-(void)updateFrom:(CLLocationCoordinate2D)origin;
-(void)updateAngleFrom:(CLLocationCoordinate2D)origin;
-(void)updateDistanceFrom:(CLLocationCoordinate2D)origin;

@end

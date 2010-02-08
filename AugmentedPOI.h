//
//  AugmentedPOI.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "AugmentedPOI.h"

@interface AugmentedPOI : NSObject {
	float teta;
	MPNAnnotation *annotation;
}

@property float teta;
@property(assign) MPNAnnotation *annotation;

-(id)initWithAnnotation:(MPNAnnotation *) anAnnotation fromOrigin:(CLLocationCoordinate2D)origin;
-(void)updateAngleFrom:(CLLocationCoordinate2D)origin;

@end

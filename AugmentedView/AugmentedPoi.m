//
//  AugmentedPOI.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedPoi.h"


@implementation AugmentedPoi
@synthesize azimuth;
@synthesize annotation;
@synthesize pixelDist;

-(id)initWithAnnotation:(VTAnnotation *) anAnnotation fromOrigin:(CLLocationCoordinate2D)origin
{
	self.annotation = anAnnotation;
	[self updateAngleFrom:origin];
	
	return self;
}

-(void)updateAngleFrom:(CLLocationCoordinate2D)origin
{
	float lat1 = origin.latitude * 3.14 / 180.0;
	float lon1 = origin.longitude * 3.14 / 180.0;
	
	float lat2 = annotation.coordinate.latitude * 3.14 / 180.0;
	float lon2 = annotation.coordinate.longitude * 3.14 / 180.0;
	
	if(lat1 == lat2 && lon1 == lon2){
		azimuth = 0.0;
	}else{
		float dLon = lon2-lon1; 
		
		float y = sin(dLon) * cos(lat2);
		float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
		
		azimuth = atan2(-x, -y);
	}
}

-(float)distance{
	return annotation.distance;
}

- (void)dealloc {
    [super dealloc];
}

@end

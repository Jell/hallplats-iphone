//
//  AugmentedPOI.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-05.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AugmentedPoi.h"


@implementation AugmentedPoi
@synthesize teta;
@synthesize annotation;
@synthesize distance;

-(id)initWithAnnotation:(VTAnnotation *) anAnnotation fromOrigin:(CLLocationCoordinate2D)origin
{
	self.annotation = anAnnotation;
	[self updateAngleFrom:origin];
	[self updateDistanceFrom:origin];
	
	return self;
}

-(void)updateFrom:(CLLocationCoordinate2D)origin
{
	[self updateAngleFrom:origin];
	[self updateDistanceFrom:origin];
}

-(void)updateAngleFrom:(CLLocationCoordinate2D)origin
{
	
	float lat1 = origin.latitude * 3.14 / 180.0;
	float lon1 = origin.longitude * 3.14 / 180.0;
	
	float lat2 = annotation.coordinate.latitude * 3.14 / 180.0;
	float lon2 = annotation.coordinate.longitude * 3.14 / 180.0;
	
	if(lat1 == lat2 && lon1 == lon2){
		teta = 0.0;
	}else{
		float dLon = lon2-lon1; 
		
		float y = sin(dLon) * cos(lat2);
		float x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
		
		teta = atan2(-x, -y);
	}
	/*
	 self.teta = atan2((origin.latitude - annotation.coordinate.latitude)* (110.574 + 0.562 * abs(origin.latitude / 90)),
	 (origin.longitude - annotation.coordinate.longitude) * 111.320 * cos(origin.latitude * 3.14 / 180));
	 */
}

-(void)updateDistanceFrom:(CLLocationCoordinate2D)origin
{
	float lat1 = origin.latitude * 3.14 / 180.0;
	float lon1 = origin.longitude * 3.14 / 180.0;
	
	float lat2 = annotation.coordinate.latitude * 3.14 / 180.0;
	float lon2 = annotation.coordinate.longitude * 3.14 / 180.0;
	
	const float R = 6371.0; // km
	distance = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(lon2-lon1)) * R;
}

- (void)dealloc {
    [super dealloc];
}

@end

//
//  VTAnnotation.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VTAnnotation.h"


@implementation VTAnnotation
@synthesize coordinate;
@synthesize friendly_name, stop_name, county, order, distance, stop_id, stop_id_with_hash_key,shortcut,stop_type;

- (NSString *)subtitle{
	return [NSString stringWithFormat:@"%@", mSubTitle];
}

- (NSString *)title{
	return [NSString stringWithFormat:@"%@", mTitle];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	NSLog(@"%f,%f",c.latitude,c.longitude);
	return self;
}

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle{
	mTitle = title;
	mSubTitle = subtitle;
}
@end

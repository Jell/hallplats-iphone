//
//  MPNAnnotation.m
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MPNAnnotation.h"

@implementation MPNAnnotation
@synthesize coordinate;
@synthesize poi_id, postal_code, marker_icon, description_html, po_box,
thumb_icon_url, street, site_type, phone, homepage, email;

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

- (void)dealloc {
    [super dealloc];
}


@end

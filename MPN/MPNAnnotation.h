//
//  MPNAnnotation.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MPNAnnotation : NSObject <MKAnnotation>{
	int poi_id;
	
	CLLocationCoordinate2D coordinate;
	NSString *mTitle;
	NSString *mSubTitle;
	
	NSString *postal_code;
	NSString *marker_icon;
	NSString *description_html;
	NSString *po_box;
	NSString *thumb_icon_url;
	NSString *street;
	NSString *site_type;
	NSString *phone;
	NSString *homepage;
	NSString *email;
}

@property int poi_id;
@property(retain) NSString *postal_code;
@property(retain) NSString *marker_icon;
@property(retain) NSString *description_html;
@property(retain) NSString *po_box;
@property(retain) NSString *thumb_icon_url;
@property(retain) NSString *street;
@property(retain) NSString *site_type;
@property(retain) NSString *phone;
@property(retain) NSString *homepage;
@property(retain) NSString *email;

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;
@end

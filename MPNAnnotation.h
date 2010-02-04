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
	CLLocationCoordinate2D coordinate;
	NSString *mTitle;
	NSString *mSubTitle;
}

-(void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;
@end

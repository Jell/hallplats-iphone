//
//  VTForecast.h
//  AugmentedMPN
//
//  Created by Jean-Louis on 2010-02-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VTForecast : NSObject {
	NSString *lineNumber;
	UIColor *foregroundColor;
	UIColor *backgroundColor;
	NSString *imageType;
	NSString *destination;
	NSString *nastaTime;
	BOOL nastaHandicap;
	NSString *darefterTime;
	BOOL darefterHandicap;
}

@property(retain) NSString *lineNumber;
@property(retain) UIColor *foregroundColor;
@property(retain) UIColor *backgroundColor;
@property(retain) NSString *imageType;
@property(retain) NSString *destination;
@property(retain) NSString *nastaTime;
@property BOOL nastaHandicap;
@property(retain) NSString *darefterTime;
@property BOOL darefterHandicap;

@end

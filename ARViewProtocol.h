/*
 *  MPNViewDisplayProtocol.h
 *  AugmentedMPN
 *
 *  Created by Jean-Louis on 2010-02-03.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */
@protocol ARViewDelegate <UIAccelerometerDelegate, CLLocationManagerDelegate>
-(void)setCurrentLocation:(CLLocation *)location;
-(void)setAnnotationList:(NSArray *)newList;
-(void)setOrientation:(UIInterfaceOrientation)orientation;
@end


//
//  MizoonRootControllerDelegate.h
//  Mizoon
//
//  Created by Daryoush Paknad on 9/23/10.
//  Copyright 2010 Mizoon. All rights reserved.
//


@protocol MizoonRootControllerDelegate<NSObject>

//! Called before the view controller is removed.
//!
//! @param newViewID: the contents of the API response, typically a JSON
//!   string.  GAPlace and GAParent provide JSON parsing functions.
- (void) willRemoveView:(int)newViewID;


@end

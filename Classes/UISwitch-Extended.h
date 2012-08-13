//
//  UISwitch-Extended.h
//  Mizoon
//
//  Created by Daryoush Paknad on 6/30/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISwitch (tagged)
+ (UISwitch *) switchWithLeftText: (NSString *) tag1 andRight: (NSString *) tag2;
@property (nonatomic, readonly)	UILabel *label1;
@property (nonatomic, readonly)	UILabel *label2;
@end
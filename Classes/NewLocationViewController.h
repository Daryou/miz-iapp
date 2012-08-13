//
//  NewPlaceViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 8/26/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewLocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UITableView			*NLTableView;
	UIPickerView		*catPicker;
	UIPickerView		*subCatPicker;	
	UITextField			*locName;
	UITextField			*locDescription;
}

@property (nonatomic, retain) UITableView	*NLTableView;
@property (nonatomic, retain) UITextField	*locName;
@property (nonatomic, retain) UITextField	*locDescription;
@property (nonatomic, retain) UIPickerView	*catPicker;
@property (nonatomic, retain) UIPickerView	*subCatPicker;


@end

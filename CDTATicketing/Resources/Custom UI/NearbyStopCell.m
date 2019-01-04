//
//  NearbyStopCell.m
//  CDTA
//
//  Created by CooCooTech on 10/2/13.
//  Copyright (c) 2013 CooCoo. All rights reserved.
//

#import "NearbyStopCell.h"

int const SHOW_ARRIVALS_TAG = 1;

@implementation NearbyStopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view.tag == SHOW_ARRIVALS_TAG) {
        if (self.showArrivalsCallback) {
            self.showArrivalsCallback();
        }
    } else {
        if (self.selectCellCallback) {
            self.selectCellCallback();
        }
    }
}

@end
